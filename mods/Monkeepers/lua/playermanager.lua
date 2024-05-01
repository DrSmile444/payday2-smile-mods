local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.Monkeepers = _G.Monkeepers or {}
Monkeepers.path = ModPath
Monkeepers.data_path = SavePath .. 'monkeepers.txt'

Monkeepers.draw_debug = false
Monkeepers.brush_start = Draw:brush(Color(100, 0, 0, 255) / 255, 2)
Monkeepers.brush_link = Draw:brush(Color(100, 192, 255, 0) / 255, 2)
Monkeepers.brush_link_to_dropzone = Draw:brush(Color(236, 192, 255, 0) / 255, 2)
Monkeepers.brush_end = Draw:brush(Color(100, 0, 255, 0) / 255, 2)

Monkeepers.last_interaction_type = {}
Monkeepers.last_interaction_was_carrydrop = {}
Monkeepers.last_carry_pickup_pos = {}
Monkeepers.routes = {}
Monkeepers.lootareas = {}
Monkeepers.ziplines = {}
Monkeepers.radius_pickup_zone = 600
Monkeepers.radius_zipline_zone = 1400
Monkeepers.min_distance_to_create_route = 700
Monkeepers.min_distance_to_create_route_from_shelf = 1400
Monkeepers.max_lifetime_of_unused_route = 90
Monkeepers.delay_on_failure = 10
Monkeepers.fetch_icon = 'wp_arrow'
Monkeepers.transport_icon = 'pd2_loot'
Monkeepers.SO_prefix = 'mkp_monkey_'
Monkeepers.default_behaviour = 'type'
Monkeepers.behaviours = {
	'disabled',
	'id',
	'type',
	'any',
}
Monkeepers.neighborhood = {
	dah = {
		[163] = 1,
		[166] = 1,
		[167] = 1,
	},
	family = {
		[2] = 1,
		[3] = 1,
		[4] = 1,
	},
	fex = {
		[28] = 1,
		[310] = 1,
	},
	flat = {
		[43] = 1,
		[250] = 1,
		[44] = 2,
		[270] = 2,
		[41] = 3,
		[123] = 3,
	},
	firestarter_1 = {
		[25] = 1,
		[28] = 1,
		[37] = 1,
		[75] = 2,
		[76] = 2,
		[29] = 3,
		[59] = 3,
		[26] = 4,
		[38] = 4,
		[54] = 4,
		[18] = 5,
		[61] = 5,
	},
	friend = {
		[22] = 1,
		[42] = 1,
		[45] = 2,
		[102] = 2,
		[46] = 3,
		[69] = 3,
		[11] = 4,
		[12] = 4,
		[18] = 4,
	},
	mus = {
		[38] = 1,
		[39] = 1,
		[64] = 2,
		[65] = 2,
		[53] = 3,
		[54] = 3,
		[60] = 4,
		[61] = 4,
		[67] = 5,
		[68] = 5,
		[69] = 5,
		[71] = 5,
		[72] = 5,
		[73] = 5,
		[158] = 5,
		[121] = 6,
		[122] = 6,
		[123] = 6,
		[130] = 7,
		[132] = 7,
		[133] = 7,
		[134] = 7,
		[125] = 8,
		[126] = 8,
		[127] = 8,
		[128] = 8,
	},
	rvd2 = {
		[13] = 1,
		[53] = 1,
		[67] = 1,
		[71] = 1,
		[72] = 1,
	},
}

local mvec3_add = mvector3.add
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_z = mvector3.z
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

function Monkeepers:setup()
	if Global.game_settings and Global.game_settings.level_id then
		self.neighborhood = self.neighborhood[Global.game_settings.level_id] or {}
	end

	if Keepers then
		self.min_distance_to_create_route_from_shelf = self.min_distance_to_create_route
	end
end

function Monkeepers:load_settings()
	local behaviour_ids = {}
	for id, behaviour in ipairs(self.behaviours) do
		behaviour_ids[behaviour] = id
	end

	self.default_behaviour_id = behaviour_ids[self.default_behaviour]

	self.settings = {
		disable_catch_thrown_bags = false,
		framing_frame_2 = behaviour_ids.id,
		nail = behaviour_ids.id,
	}

	local file = io.open(self.data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			if type(v) == 'string' then
				self.settings[k] = behaviour_ids[v]
			else
				self.settings[k] = v
			end
		end
		file:close()
	end

	self:update_current_behaviour()
end

function Monkeepers:save_settings()
	local file = io.open(self.data_path, 'w+')
	if file then
		local out = {}
		for k, v in pairs(self.settings) do
			if v ~= self.default_behaviour_id then
				out[k] = self.behaviours[v] or v
			end
		end
		file:write(json.encode(out))
		file:close()
	end
end

function Monkeepers:update_current_behaviour()
	local level_id = Global.game_settings and Global.game_settings.level_id or ''
	level_id = level_id:gsub('_night$', ''):gsub('_day$', '')
	self.current_behaviour_id = self.settings[level_id] or self.default_behaviour_id
	self.disabled = self.current_behaviour_id == 1
end

function Monkeepers:same_neighborhood(navseg1, navseg2)
	if navseg1 == navseg2 then
		return true
	elseif self.neighborhood[navseg1] and self.neighborhood[navseg1] == self.neighborhood[navseg2] then
		return true
	end

	return false
end

function Monkeepers:is_acceptable_carry(carry_id)
	local acceptable_carry = {
		breaching_charges = true,
		cage_bag = true,
		lance_bag_large = true,
		safe_wpn = true,
		safe_ovk = true,
		winch_part = true,
		winch_part_2 = true,
		winch_part_3 = true,
	}
	if acceptable_carry[carry_id] then
		return true
	end

	local td = tweak_data.carry[carry_id]
	if td.bag_value or td.AI_carry then
		return true
	end

	return false
end

function Monkeepers:carry_id_match(carry_id1, carry_id2)
	if self.current_behaviour_id == 1 then
		return false
	elseif self.current_behaviour_id == 2 then
		return carry_id1 == carry_id2
	elseif self.current_behaviour_id == 3 then
		local tdc = tweak_data.carry
		local type1 = tdc[carry_id1] and tdc[carry_id1].type
		local type2 = tdc[carry_id2] and tdc[carry_id2].type
		return type1 and type2 and tdc.types[type1].throw_distance_multiplier == tdc.types[type2].throw_distance_multiplier
	elseif self.current_behaviour_id == 4 then
		return true
	else
		return nil
	end
end

function Monkeepers:get_closest_bag_from(pos, bags)
	local min_dis = 100000000000
	local closest_bag
	for _, bag in ipairs(bags) do
		local dis = mvec3_dis_sq(bag:position(), pos)
		if dis < min_dis then
			closest_bag = bag
			min_dis = dis
		end
	end
	return closest_bag
end

local lootbag_vec = Vector3(0, 0, 100)
local lootbag_mask = World:make_slot_mask(14)
function Monkeepers:get_bags_around(pos, radius, include_carried, include_routed, carry_id)
	local pos1 = tmp_vec1
	local pos2 = tmp_vec2
	mvec3_set(pos1, pos)
	mvec3_set(pos2, pos)
	mvec3_add(pos1, lootbag_vec)
	mvec3_add(pos1, lootbag_vec) -- oui, 2
	mvec3_sub(pos2, lootbag_vec)
	local result = World:find_units('intersect', 'cylinder', pos1, pos2, radius or self.radius_pickup_zone, lootbag_mask)
	for i = #result, 1, -1 do
		local unit = result[i]
		local cd = alive(unit) and unit.carry_data and unit:carry_data()
		if not cd
			or not include_carried and cd:is_linked_to_unit()
			or not include_routed and cd._carry_SO_data
			or carry_id and not self:carry_id_match(carry_id, cd:carry_id())
		then
			table.remove(result, i)
		end
	end
	return result
end

local ids_weapon_case = Idstring('units/payday2/equipment/gen_interactable_weapon_case_2x1/gen_interactable_weapon_case_2x1')
function Monkeepers:get_interactions_around(pos, radius, interaction_type, carry_id)
	local result = {}

	if interaction_type == 'diamonds_pickup_full' then
		if Global.game_settings.level_id == 'dah' and not managers.groupai:state():whisper_mode() then
			interaction_type = 'diamonds_pickup'
		end
	end

	if interaction_type and interaction_type:sub(-10, -1) == 'carry_drop' then
		-- qued
	elseif Keepers then
		local processed_units = {}

		local navseg = managers.navigation:get_nav_seg_from_pos(pos, false)
		for _, int_unit in ipairs(managers.interaction._interactive_units) do
			if alive(int_unit) then
				processed_units[int_unit:key()] = true
				local cd = int_unit:carry_data()
				if cd then
					if not carry_id or cd:carry_id() == carry_id then
						local interaction = int_unit:interaction()
						if interaction_type and interaction.tweak_data ~= interaction_type then
							-- qued
						elseif carry_id and not self:carry_id_match(carry_id, cd:carry_id()) then
							-- qued
						else
							local i_pos = interaction:interact_position()
							if self:same_neighborhood(managers.navigation:get_nav_seg_from_pos(i_pos, false), navseg) or radius and mvec3_dis(pos, i_pos) < radius then
								if Keepers:is_unit_interactable(int_unit) then
									table.insert(result, int_unit)
								end
							end
						end
					end
				elseif interaction_type == 'take_weapons' and int_unit:name() == ids_weapon_case then
					local interaction = int_unit:interaction()
					local i_pos = interaction:interact_position()
					if self:same_neighborhood(managers.navigation:get_nav_seg_from_pos(i_pos, false), navseg) or radius and mvec3_dis(pos, i_pos) < radius then
						if Keepers:is_unit_interactable(int_unit) then
							table.insert(result, int_unit)
						end
					end
				end
			end
		end

		for ukey, int_unit in pairs(Keepers:get_covered_interactable_units()) do
			local cd = alive(int_unit) and int_unit:carry_data()
			if cd then
				if processed_units[ukey] then
					-- qued
				elseif not carry_id or cd:carry_id() == carry_id then
					local interaction = int_unit:interaction()
					if interaction_type and interaction.tweak_data ~= interaction_type then
						-- qued
					elseif carry_id and not self:carry_id_match(carry_id, cd:carry_id()) then
						-- qued
					elseif interaction._remove_on_interact then
						local i_pos = interaction:interact_position()
						if self:same_neighborhood(managers.navigation:get_nav_seg_from_pos(i_pos, false), navseg) or radius and mvec3_dis(pos, i_pos) < radius then
							if Keepers:is_unit_interactable(int_unit) then
								table.insert(result, int_unit)
							end
						end
					end
				end
			end
		end
	end

	return result
end

function Monkeepers:is_dropzone_ready(dropzone, position)
	if not dropzone or type(dropzone) ~= 'table' then
		-- qued
	elseif type(dropzone.sync_store_loot_in_vehicle) == 'function' then
		if alive(dropzone._unit) and dropzone:is_interaction_enabled(VehicleDrivingExt.INTERACT_LOOT) then
			if not dropzone._tweak_data or #dropzone._loot < dropzone._tweak_data.max_loot_bags then
				return not position or mvec3_dis(position, dropzone._unit:position()) < 20
			end
		end
	elseif type(dropzone.enabled) == 'function' then
		return dropzone:enabled()
	end

	return false
end

function Monkeepers:another_route_has_priority(tested_route, sanitize)
	local t = TimerManager:game():time()

	if sanitize then
		local routes_in_use = {}

		for _, unit in ipairs(managers.interaction._interactive_units) do
			local carry_data = alive(unit) and unit.carry_data and unit:carry_data()
			if carry_data then
				local carry_SO_data = carry_data._carry_SO_data
				if carry_SO_data and carry_SO_data.mkp_route then
					routes_in_use[carry_SO_data.mkp_route] = true
				end
			end
		end

		for i = #self.routes, 1, -1 do
			local route = self.routes[i]
			if route.dropzone or routes_in_use[route] then
				-- qued
			elseif route.created_t + self.max_lifetime_of_unused_route < t then
				self:remove_route(i)
			end
		end
	end

	local older_routes = {}
	for _, route in ipairs(self.routes) do
		if route.created_t < tested_route.created_t then
			if not route.failed_t or t - route.failed_t > self.delay_on_failure then
				if not route.dropzone or self:is_dropzone_ready(route.dropzone) then
					older_routes[route] = true
				end
			end
		end
	end

	for _, unit in ipairs(managers.interaction._interactive_units) do
		local carry_data = alive(unit) and unit.carry_data and unit:carry_data()
		if carry_data and not carry_data:is_linked_to_unit() then
			local so_data = carry_data._carry_SO_data
			if so_data and so_data.SO_registered then
				if so_data.mkp_route and older_routes[so_data.mkp_route] then
					return true
				end
			end
		end
	end

	return false
end

function Monkeepers:bag_zipline_near_pos(pos)
	for _, zipline in ipairs(self.ziplines) do
		if zipline._enabled and zipline._usage_type == 'bag' then
			if mvec3_dis(pos, zipline._start_pos) < self.radius_zipline_zone then
				return true
			end
		end
	end
	return false
end

function Monkeepers:draw_routes()
	for _, route in ipairs(self.routes) do
		self:draw_route(route)
	end
end

local brush_vec = Vector3(0, 0, 5)
function Monkeepers:draw_route(route)
	self.brush_start:cylinder(route.pickup_pos, route.pickup_pos + brush_vec, self.radius_pickup_zone)
	self.brush_end:cylinder(route.throw_pos, route.throw_pos + brush_vec, 50)
	local brush = route.dropzone and self.brush_link_to_dropzone or self.brush_link
	brush:cone(route.throw_pos, route.pickup_pos, 20)
end

function Monkeepers:add_route(route)
	route.obsolete = nil
	return table.insert(self.routes, route)
end

function Monkeepers:remove_route(i)
	local route = table.remove(self.routes, i)
	if route then
		route.obsolete = true
	end
	return route
end

function Monkeepers:create_route(pickup_pos, land_pos, dest_pos, dest_rot, dest_dir, throw_distance_multiplier_upgrade_level, dropzone, carry_id, interaction_type)
	local new_route = {
		carry_id = carry_id,
		interaction_type = interaction_type,
		created_t = 0,
		pickup_pos = mvec3_cpy(pickup_pos),
		throw_pos = mvec3_cpy(dest_pos),
		land_pos = mvec3_cpy(land_pos),
		rot = Rotation(dest_rot:yaw(), 0, 0),
		dir = mvec3_cpy(dest_dir),
		throw_distance_multiplier_upgrade_level = throw_distance_multiplier_upgrade_level,
		dropzone = dropzone
	}

	local previously_created_t = self:destroy_route(pickup_pos, false, false, carry_id, interaction_type, new_route)
	new_route.created_t = previously_created_t or TimerManager:game():time()

	if self.draw_debug then
		self:draw_route(new_route)
	end

	return new_route
end

function Monkeepers:register_interact_SO(route, interactive_unit)
	if not alive(interactive_unit) or not interactive_unit:interaction():active() then
		return false
	end

	local objective = Keepers:get_special_objective(nil, false, nil, nil, interactive_unit)
	if not objective then
		return false
	end

	objective.mkp_route = route
	objective.complete_clbk = function(interactor)
		local old = {}
		for _, int_unit in ipairs(managers.interaction._interactive_units) do
			old[int_unit:key()] = true
		end

		objective.bot_unit = interactor
		Keepers:on_completed_SO(objective)

		if route.obsolete then
			return
		end

		for _, int_unit in ipairs(managers.interaction._interactive_units) do
			if not old[int_unit:key()] and alive(int_unit) then
				if int_unit:name() == Idstring('units/payday2/equipment/gen_interactable_weapon_case_2x1/spawn_ak47') then
					local so_id = int_unit:carry_data():mkp_chk_register_carry_SO(nil, route, true)
					if so_id then
						DelayedCalls:Add('DelayedModMKP_registerinteractSO_' .. so_id, 0, function()
							local so = managers.groupai:state()._special_objectives[so_id]
							if so then
								-- forced gstate:_execute_so()
								local objective_copy = managers.groupai:state().clone_objective(so.data.objective)
								interactor:brain():set_objective(objective_copy)
								if so.data.admin_clbk then
									so.data.admin_clbk(interactor)
								end
								if so.non_repeatable then
									so.administered[interactor:key()] = true
								end
								if so.remaining_usage == 1 then
									managers.groupai:state():remove_special_objective(so_id)
								end
							end
						end)
					end
				end
				break
			end
		end
	end

	objective.fail_clbk = function(interactor)
		Keepers:on_failed_SO(objective)
		if not route.obsolete then
			Monkeepers:register_interact_SO(route, interactive_unit)
		end
	end

	local so_id = self.SO_prefix .. tostring(interactive_unit:key())
	local so_descriptor = {
		interval = 1,
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		mkp_route = route,
		objective = objective,
		search_pos = objective.pos,
		AI_group = 'friendlies',
		verification_clbk = function(candidate_unit)
			return self:verify_pickup_SO(candidate_unit, route, objective)
		end,
	}

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	return true
end

function Monkeepers:verify_pickup_SO(candidate_unit, route, pickup_objective)
	local candidate_movement = candidate_unit:movement()
	if candidate_movement:cool() then
		return false
	end

	if candidate_movement.carrying_bag and candidate_movement:carrying_bag() then
		return false
	end

	if candidate_movement:chk_action_forbidden('walk') then
		return false
	end

	if route and route.dropzone and not self:is_dropzone_ready(route.dropzone, route.position) then
		return false
	end

	if pickup_objective and alive(pickup_objective.mkp_bag) and not pickup_objective.kpr_colray_body then
		-- item may not be ready yet if under others (think coke on HM D2)
		local interaction = pickup_objective.mkp_bag:interaction()
		if not interaction or interaction:disabled() or not interaction:active() then
			return false
		end
	end

	if candidate_unit:base().kpr_is_keeper then
		if pickup_objective
			and pickup_objective.kpr_recruit_keepers_around_pos
			and pickup_objective.kpr_recruit_keepers_dis
			and mvec3_dis(candidate_unit:position(), pickup_objective.kpr_recruit_keepers_around_pos) <= pickup_objective.kpr_recruit_keepers_dis
		then
			-- qued
		else
			return false
		end
	else
		local objective = candidate_unit:brain():objective()
		if objective and objective.type ~= 'follow' then
			return false
		end
	end

	for id, so in pairs(managers.groupai:state()._special_objectives) do
		if so.data and so.data.AI_group == 'friendlies' and type(id) == 'string' and id:find('revive') then
			return false
		end
	end

	if route then
		local t = TimerManager:game():time()
		if route.failed_t and t - route.failed_t < self.delay_on_failure then
			return false
		end

		if self:another_route_has_priority(route, true) then
			return false
		end
	end

	return true
end

function Monkeepers:register_route_SO(route)
	local bags_nearby_previous_pos = self:get_bags_around(route.pickup_pos, nil, false, not route.interaction_type, route.carry_id)
	local filters = self:get_dropzone_filters(route.dropzone)
	for _, bag_unit in ipairs(bags_nearby_previous_pos) do
		local carry_data = bag_unit:carry_data()
		if carry_data and (not filters or filters[carry_data._carry_id]) then
			carry_data:mkp_chk_register_carry_SO(nil, route, false)
		end
	end

	if route.interaction_type then
		for _, interactive_unit in ipairs(self:get_interactions_around(route.pickup_pos, nil, route.interaction_type)) do
			local carry_data = interactive_unit:carry_data()
			if not carry_data then
				self:register_interact_SO(route, interactive_unit)
			elseif self:carry_id_match(route.carry_id, carry_data._carry_id) then
				carry_data:mkp_chk_register_carry_SO(nil, route, true)
			end
		end
	end
end

function Monkeepers:is_unit_routed(unit)
	if alive(unit) then
		for so_id, so in pairs(managers.groupai:state()._special_objectives) do
			local mkp_bag = so.data and so.data.objective and so.data.objective.mkp_bag
			if alive(mkp_bag) and mkp_bag:key() == unit:key() then
				return true
			end
		end
	end

	return false
end

function Monkeepers:cancel_everything()
	while self:remove_route(1) do
	end

	for _, unit in ipairs(managers.interaction._interactive_units) do
		if alive(unit) and unit.carry_data then
			local carry_data = unit:carry_data()
			if carry_data then
				self:cancel_bag_SO(unit, true)
			end
		end
	end

	for so_id, so in pairs(managers.groupai:state()._special_objectives) do
		if type(so_id) == 'string' and so_id:find(self.SO_prefix) == 1 then
			local mkp_bag = so.data and so.data.objective and so.data.objective.mkp_bag
			if alive(mkp_bag) then
				self:cancel_bag_SO(mkp_bag, true)
			else
				managers.groupai:state():remove_special_objective(so_id)
			end
		end
	end

	for ukey, record in pairs(managers.groupai:state()._ai_criminals) do
		local objective = record.unit:brain():objective()
		if objective and (objective.mkp_bag or objective.mkp_route) then
			record.unit:brain():set_objective(nil)
		end
	end
end

function Monkeepers:destroy_route_by_data(route_to_remove, remove_SO)
	local route_i
	if type(route_to_remove) == 'number' then
		route_i = route_to_remove
	elseif type(route_to_remove) == 'table' then
		route_i = table.index_of(self.routes, route_to_remove)
	else
		return false
	end

	local removed_route = self:remove_route(route_i)

	if remove_SO and removed_route then
		local bags = World:find_units_quick('all', 14)
		for i = #bags, 1, -1 do
			local unit = bags[i]
			local carry_data = alive(unit) and unit.carry_data and unit:carry_data()
			if carry_data and carry_data._carry_SO_data then
				if carry_data._carry_SO_data.mkp_route == removed_route then
					self:cancel_bag_SO(unit, false)
				end
			end
		end

		local to_cancel = {}
		for _, so in pairs(managers.groupai:state()._special_objectives) do
			if so.data.mkp_route == removed_route then
				local mkp_bag = so.data and so.data.objective and so.data.objective.mkp_bag
				if alive(mkp_bag) then
					table.insert(to_cancel, mkp_bag)
				end
			end
		end
		for _, mkp_bag in ipairs(to_cancel) do
			self:cancel_bag_SO(mkp_bag, false)
		end
	end

	return removed_route
end

function Monkeepers:refresh_drop_objectives(old_route, new_route)
	for _, record in pairs(managers.groupai:state()._ai_criminals) do
		local unit = record.unit
		local objective = alive(unit) and unit:brain():objective()
		if objective and objective.mkp_route == old_route then
			local bag = unit:movement()._carry_unit
			if bag then
				local new_objective = bag:carry_data():mkp_make_drop_objective(new_route)
				unit:brain():set_objective(new_objective)
			end
		end
	end
end

function Monkeepers:destroy_route(pos, remove_SO, forced_interrupt, carry_id, interaction_type, replacement_route)
	local created_t

	for i = #self.routes, 1, -1 do
		local route = self.routes[i]
		if route.interaction_type == interaction_type and self:carry_id_match(carry_id, route.carry_id) then
			if mvec3_dis(route.pickup_pos, pos) < self.radius_pickup_zone then
				created_t = math.min(created_t or route.created_t, route.created_t)
				self:destroy_route_by_data(i, remove_SO)

				if replacement_route then
					self:refresh_drop_objectives(route, replacement_route)
				end
			end
		end
	end

	return created_t
end

function Monkeepers:cancel_bag_SO(bag_unit, forced_interrupt)
	local cd = alive(bag_unit) and bag_unit:carry_data()
	if cd then
		if forced_interrupt then
			local carrier = cd:is_linked_to_unit()
			if alive(carrier) then
				local objective = carrier:brain():objective()
				if objective and objective.mkp_route then
					local followup = objective.followup_objective
					carrier:brain():set_objective(followup and followup.type == 'follow' and followup or nil)
				end
			end
		end

		if cd._carry_SO_data then
			cd:mkp_unregister_carry_SO()
		end
	end
end

function Monkeepers:destroy_opposite_route(new_pickup_pos, new_land_pos, carry_id)
	for i = #self.routes, 1, -1 do
		local route = self.routes[i]
		if self:carry_id_match(carry_id, route.carry_id) then
			if mvec3_dis(route.pickup_pos, new_land_pos) < self.radius_pickup_zone and mvec3_dis(route.land_pos, new_pickup_pos) < self.radius_pickup_zone then
				self:remove_route(i)
				local bags_nearby_previous_pos = self:get_bags_around(route.pickup_pos, nil, false, true, carry_id)
				for _, bag_unit in ipairs(bags_nearby_previous_pos) do
					self:cancel_bag_SO(bag_unit, true)
				end
			end
		end
	end
end

function Monkeepers:make_route(peer, land_pos, dest_pos, dest_rot, dest_dir, throw_distance_multiplier_upgrade_level, dropzone, carry_id)
	local peer_id = peer:id()
	local pickup_pos = self.last_carry_pickup_pos[peer_id] or dropzone and dest_pos
	if pickup_pos then
		local interaction_type = not self.last_interaction_was_carrydrop[peer_id] and self.last_interaction_type[peer_id] or nil
		local do_create
		if interaction_type == 'gen_pku_fusion_reactor' then
			-- no, no, nooo
		elseif dropzone then
			do_create = true
		elseif math.abs(land_pos.z - pickup_pos.z) > 250 then
			do_create = true
		elseif interaction_type then
			do_create = mvec3_dis(land_pos, pickup_pos) > self.min_distance_to_create_route_from_shelf
		else
			do_create = mvec3_dis(land_pos, pickup_pos) > self.min_distance_to_create_route
		end

		if do_create then
			if not interaction_type then
				self:destroy_opposite_route(pickup_pos, land_pos, carry_id)
			end
			local route = self:create_route(pickup_pos, land_pos, dest_pos, dest_rot, dest_dir, throw_distance_multiplier_upgrade_level, dropzone, carry_id, interaction_type)
			self:add_route(route)
			return route

		elseif self.last_interaction_was_carrydrop[peer_id] then
			self:destroy_route(pickup_pos, true, true, carry_id, interaction_type)
		end
	end
end

function Monkeepers:find_route(pos, carry_id, interaction_type)
	local closest_route
	local min_dis = 100000000
	local pos_z = mvec3_z(pos)

	for _, route in ipairs(self.routes) do
		if self:carry_id_match(carry_id, route.carry_id) then
			if not interaction_type then
				if math.abs(pos_z - mvec3_z(route.pickup_pos)) <= 100 then
					local dis = mvec3_dis(pos, route.pickup_pos)
					if dis < min_dis then
						min_dis = dis
						if min_dis < self.radius_pickup_zone then
							closest_route = route
						end
					end
				end
			elseif interaction_type == route.interaction_type then
				if self:same_neighborhood(managers.navigation:get_nav_seg_from_pos(pos, false), managers.navigation:get_nav_seg_from_pos(route.pickup_pos, false)) then
					closest_route = route
					break
				end
			end
		end
	end

	return closest_route
end

function Monkeepers:order_criminal_AI_to_grab_bags(instigator, around_pos, carry_id)
	local bags, things
	for ukey, record in pairs(managers.groupai:state()._ai_criminals) do
		local unit = record.unit
		if alive(unit) and not unit:movement():carrying_bag() then
			local objective = unit:brain():objective()
			if objective and objective.type == 'follow' and objective.follow_unit == instigator then
				bags = bags or self:get_bags_around(around_pos, 700, false, false, carry_id)
				local bag = table.remove(bags)
				if bag then
					local carry_data = bag.carry_data and bag:carry_data()
					if carry_data and carry_data:mkp_chk_register_carry_SO(objective) then
						objective.mkp_mimic_pick = true
					end

				else
					things = things or self:get_interactions_around(around_pos, 400, nil, carry_id)
					local thing = table.remove(things)
					while thing do
						local carry_data = thing.carry_data and thing:carry_data()
						if carry_data and carry_data:mkp_chk_register_carry_SO(objective) then
							objective.mkp_mimic_pick = true
							break
						end
						thing = table.remove(things)
					end
				end
			end
		end
	end
end

function Monkeepers:order_criminal_AI_to_drop_bags_immediately(peer)
	for ukey, record in pairs(managers.groupai:state()._ai_criminals) do
		local bot_unit = record.unit
		if alive(bot_unit) and bot_unit:movement():carrying_bag() and bot_unit:movement().mkp_autopicked then
			local objective = bot_unit:brain():objective()
			if objective and objective.type == 'follow' and objective.follow_unit == peer:unit() then
				local carry = bot_unit:movement():carry_data()
				bot_unit:movement():throw_bag()
				if carry then
					carry._carry_SO_data = nil
				end
			end
		end
	end
end

function Monkeepers:assign_drop_objective_to_criminal_AI(peer, route)
	local filters = self:get_dropzone_filters(route.dropzone)
	for ukey, record in pairs(managers.groupai:state()._ai_criminals) do
		local bot_unit = record.unit
		if alive(bot_unit) then
			local unit_brain = bot_unit:brain()
			local objective = unit_brain:objective()
			if objective then
				if objective.type == 'follow' and objective.follow_unit == peer:unit() then
					local carry_data = bot_unit:movement():carry_data()
					if not carry_data then
						-- qued
					elseif filters and not filters[carry_data._carry_id] then
						-- qued
					elseif self:carry_id_match(route.carry_id, carry_data._carry_id) then
						local drop_objective = carry_data:mkp_make_drop_objective(route)
						drop_objective.followup_objective = objective
						unit_brain:set_objective(drop_objective)
					end

				elseif alive(objective.mkp_bag) then
					local objective_y, objective_z = nil, objective
					while objective_z.followup_objective do
						objective_y = objective_z
						objective_z = objective_z.followup_objective
					end
					if objective_y and not objective_y.mkp_route and objective_z.type == 'follow' and objective_z.follow_unit == peer:unit() then
						local carry_data = objective.mkp_bag:carry_data()
						if not filters or filters[carry_data._carry_id] then
							local drop_objective = carry_data:mkp_make_drop_objective(route)
							drop_objective.followup_objective = objective_z
							objective_y.followup_objective = drop_objective
						end
					end
				end

				if managers.groupai:state():whisper_mode() then
					bot_unit:movement():set_attention(nil)
				end
			end
		end
	end
end

function Monkeepers:get_dropzone_filters(dropzone)
	if type(dropzone) ~= 'table' then
		return
	end

	local results

	if dropzone._rules_elements then
		-- good map maker
		for _, element in ipairs(dropzone._rules_elements) do
			local rules = element and element._values and element._values.rules
			local ids = rules and rules.loot and rules.loot.carry_ids
			if ids then
				results = results or {}
				for cid in pairs(ids) do
					results[cid] = cid
				end
			end
		end
		return results
	end

	if dropzone._values and dropzone._values.on_executed then
		for _, data in ipairs(dropzone._values.on_executed) do
			local element = managers.mission:get_element_by_id(data.id)
			if element and element.class == 'ElementCarry' then
				local filter = element._values.type_filter
				if not filter or filter == 'none' then
					return
				end
				-- most probably bad map maker
				results = results or {}
				results[filter] = filter
			end
		end
		return results
	end
end

if Network:is_server() then
	local mkp_original_playermanager_serverdropcarry = PlayerManager.server_drop_carry
	function PlayerManager:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
		local unit = mkp_original_playermanager_serverdropcarry(self, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)

		if not alive(unit) then
			-- qued
		elseif not Monkeepers:is_acceptable_carry(carry_id) then
			-- qued
		elseif zipline_unit then
			-- qued
		elseif peer then
			local carry_data = unit:carry_data()
			if carry_data then
				carry_data.mkp_spawn_position = mvec3_cpy(position)
				local peer_unit = peer:unit()
				local pos = mvec3_cpy(peer_unit:position())
				local rot = peer:id() == 1 and managers.viewport:get_current_camera_rotation() or peer_unit:rotation()
				rot = Rotation(rot:yaw(), 0, 0)
				local dir = mvec3_cpy(dir)

				local mkp_callback
				local collision_callback = function(dropzone, dropzone_position)
					if carry_data.mkp_callback ~= mkp_callback or not alive(unit) then
						return
					end
					carry_data.mkp_callback = nil

					local route = Monkeepers:make_route(peer, unit:position(), pos, rot, dir, throw_distance_multiplier_upgrade_level, dropzone, carry_id)
					if route then
						if dropzone then
							route.position = dropzone_position and mvec3_cpy(dropzone_position)
						end
						Monkeepers:register_route_SO(route)
						Monkeepers:assign_drop_objective_to_criminal_AI(peer, route)
					elseif not carry_data:is_linked_to_unit() then
						Monkeepers:order_criminal_AI_to_drop_bags_immediately(peer)
					end
				end

				mkp_callback = function(dropzone, dropzone_position)
					if dropzone then
						collision_callback(dropzone, dropzone_position)
					else
						DelayedCalls:Add('DelayedModMKP_collisioncallback_' .. tostring(unit:key()), 1, function()
							collision_callback(dropzone, dropzone_position)
						end)
					end
				end
				carry_data.mkp_callback = mkp_callback
			end
		end

		return unit
	end
end

Monkeepers:load_settings()
