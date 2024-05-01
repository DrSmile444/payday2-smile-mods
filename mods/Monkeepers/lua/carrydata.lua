local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

Monkeepers:setup()

local mvec3_cpy = mvector3.copy

function CarryData:mkp_on_picked_up_carry(instigator)
	self.mkp_callback = nil

	if self._carry_SO_data then
		local carrier = self._carry_SO_data.carrier
		if alive(carrier) and carrier:key() ~= instigator:key() then
			carrier:brain():set_objective(nil)
		end
	end

	local carry_id = self:carry_id()
	if Monkeepers:is_acceptable_carry(carry_id) then
		local interaction = alive(self._unit) and self._unit:interaction()
		local peer = managers.network:session():peer_by_unit(instigator)
		if peer and interaction then
			self:mkp_unregister_carry_SO()

			local peer_id = peer:id()
			local last_interaction_was_carrydrop = interaction.tweak_data:sub(-10, -1) == 'carry_drop'
			Monkeepers.last_interaction_was_carrydrop[peer_id] = last_interaction_was_carrydrop
			Monkeepers.last_interaction_type[peer_id] = interaction.tweak_data

			local pickup_pos
			local instigator_pos = mvec3_cpy(instigator:position())
			if not self:is_linked_to_unit() then
				pickup_pos = instigator_pos
			end
			Monkeepers.last_carry_pickup_pos[peer_id] = pickup_pos

			local route = Monkeepers:find_route(instigator:position(), carry_id)
			if not route then
				DelayedCalls:Add('DelayedModMKP_triggerload_' .. peer_id, 2, function()
					if alive(instigator) and instigator:movement():current_state_name() == 'carry' then
						if not Monkeepers:bag_zipline_near_pos(instigator_pos) then
							Monkeepers:order_criminal_AI_to_grab_bags(instigator, instigator_pos, carry_id)
						end
					end
				end)
			end
		end
	end
end

local mkp_original_carrydata_chkregisterstealSO = CarryData._chk_register_steal_SO
function CarryData:_chk_register_steal_SO()
	self:mkp_chk_register_carry_SO_delayed()

	if self._register_steal_SO_clbk_id then
		local tracker_pickup = managers.navigation:create_nav_tracker(self._unit:position(), false)
		local pickup_nav_seg = tracker_pickup:nav_segment()
		managers.navigation:destroy_nav_tracker(tracker_pickup)
		local drop_point = managers.groupai:state():get_safe_enemy_loot_drop_point(pickup_nav_seg)
		if not drop_point then
			return -- otherwise a SO is created without a secure_pos / drop_objective.pos
		end
	end

	mkp_original_carrydata_chkregisterstealSO(self)
end

function CarryData:mkp_make_drop_objective(route)
	local drop_pos = mvec3_cpy(route.throw_pos)
	local drop_nav_seg = managers.navigation:get_nav_seg_from_pos(drop_pos)
	local drop_area = managers.groupai:state():get_area_from_nav_seg_id(drop_nav_seg)

	local drop_objective = {
		kpr_icon = Monkeepers.transport_icon,
		mkp_route = route,
		type = 'act',
		action_duration = 0.2,
		pose = 'stand',
		nav_seg = drop_nav_seg,
		pos = drop_pos,
		rot = route.rot,
		area = drop_area,
		fail_clbk = callback(self, self, 'mkp_on_carry_SO_failed', route),
		complete_clbk = callback(self, self, 'mkp_on_carry_SO_completed', route),
		action = {
			variant = 'gesture_stop',
			align_sync = true,
			body_part = 1,
			type = 'act',
			blocks = {
				aim = -1,
				turn = -1,
			}
		}
	}

	return drop_objective
end

function CarryData:mkp_make_pickup_objective(followup_objective)
	local pickup_objective

	if Keepers then
		pickup_objective = Keepers:get_special_objective(nil, false, nil, nil, self._unit)
		if pickup_objective then
			pickup_objective.mkp_needs_bot_unit = true
			if self._unit:interaction().tweak_data:sub(-10, -1) == 'carry_drop' then
				pickup_objective.action_start_clbk = function(...)
					local mkp_route = self._carry_SO_data and self._carry_SO_data.mkp_route
					if mkp_route and mkp_route.dropzone and not Monkeepers:is_dropzone_ready(mkp_route.dropzone, mkp_route.position) then
						if alive(self._carry_SO_data.carrier) then
							self._carry_SO_data.carrier:brain():set_objective(nil)
							return
						end
					end
					Keepers:on_action_started_SO(pickup_objective)
				end

				pickup_objective.complete_clbk = function(carrier)
					self:mkp_on_pickup_SO_completed(carrier)
					Keepers:on_completed_SO(pickup_objective)
				end
			end

			pickup_objective.fail_clbk = function(carrier)
				Keepers:on_failed_SO(pickup_objective)
				self:mkp_on_pickup_SO_failed(carrier)
			end

			if followup_objective then
				local obj = pickup_objective
				while obj.followup_objective do
					obj = obj.followup_objective
				end
				obj.followup_objective = followup_objective
			end
		end
	end

	if not pickup_objective then
		if self._unit:slot() ~= 14 or self._unit:interaction().tweak_data:sub(-10, -1) ~= 'carry_drop' then
			return
		end

		local tracker_pickup = managers.navigation:create_nav_tracker(self._unit:position(), false)
		local pickup_nav_seg = tracker_pickup:nav_segment()
		local pickup_pos = tracker_pickup:field_position()
		local pickup_area = managers.groupai:state():get_area_from_nav_seg_id(pickup_nav_seg)
		managers.navigation:destroy_nav_tracker(tracker_pickup)

		pickup_objective = {
			type = 'act',
			haste = 'run',
			pose = 'crouch',
			nav_seg = pickup_nav_seg,
			area = pickup_area,
			pos = pickup_pos,
			fail_clbk = callback(self, self, 'mkp_on_pickup_SO_failed'),
			complete_clbk = callback(self, self, 'mkp_on_pickup_SO_completed'),
			action = {
				variant = 'untie',
				align_sync = true,
				body_part = 1,
				type = 'act'
			},
			action_duration = 1,
			followup_objective = followup_objective
		}
	end

	pickup_objective.kpr_icon = Monkeepers.fetch_icon
	pickup_objective.destroy_clbk_key = false
	pickup_objective.interrupt_health = 0.4
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	pickup_objective.mkp_crowd_interrupt = math.floor((11 - difficulty_index) * 1.5)
	pickup_objective.mkp_bag = self._unit
	pickup_objective.action.kpr_so_expiration = nil

	if pickup_objective.followup_objective and pickup_objective.followup_objective ~= followup_objective then
		pickup_objective.followup_objective.mkp_bag = pickup_objective.mkp_bag
	end

	return pickup_objective
end

function CarryData:mkp_chk_register_carry_SO_delayed(followup_objective, forced_route, can_move, forced)
	if forced then
		-- qued
	elseif self.delayed_mkp_chk_register_carry_SO then
		return
	end
	self.delayed_mkp_chk_register_carry_SO = true

	DelayedCalls:Add('DelayedMonkeepers_chkregistercarrySO_' .. tostring(self._unit:key()), 2, function()
		self.delayed_mkp_chk_register_carry_SO = nil
		self:mkp_chk_register_carry_SO(followup_objective, forced_route, can_move)
	end)
end

function CarryData:mkp_chk_register_carry_SO(followup_objective, forced_route, can_move)
	if not alive(self._unit) then
		return
	end

	if not Network:is_server() or not managers.navigation:is_data_ready() then
		return
	end

	if not Monkeepers:is_acceptable_carry(self._carry_id) then
		return
	end

	if not can_move then
		local body = self._unit:body('hinge_body_1') or self._unit:body(0)
		if body and body:active() then
			local vel = body:velocity()
			mvector3.set_z(vel, 0) -- ex haunted bag with Vector3(-1.48051, -0.692436, -4.67971)
			if vel:length() > 2 then
				return
			end
		end
	end

	if self._carry_SO_data then
		local objective_y, objective_z = nil, self._carry_SO_data.pickup_objective
		while objective_z.followup_objective do
			objective_y = objective_z
			objective_z = objective_z.followup_objective
		end

		local last_type = objective_y and objective_z.type
		if last_type == 'follow' and (not followup_objective or followup_objective.type ~= last_type)
			or last_type == 'act' and objective_z.mkp_route and objective_z.mkp_route.obsolete
		then
			local route = forced_route or Monkeepers:find_route(self._unit:position(), self:carry_id())
			if route then
				self._carry_SO_data.mkp_route = route
				local new_drop_objective = self:mkp_make_drop_objective(route)

				if self._carry_SO_data.carrier then
					local objective = self._carry_SO_data.carrier:brain():objective()
					if objective and objective.followup_objective == objective_z then -- first objective is cloned when assigning SO
						objective.followup_objective = new_drop_objective
					end
				end

				objective_y.followup_objective = new_drop_objective
			end
		end
		return
	end

	local route, drop_objective
	if followup_objective then
		drop_objective = followup_objective
	else
		route = forced_route or Monkeepers:find_route(self._unit:position(), self:carry_id())
		if not route then
			return
		end
		drop_objective = self:mkp_make_drop_objective(route)
	end

	local pickup_objective = self:mkp_make_pickup_objective(drop_objective)
	if not pickup_objective then
		return
	end

	local so_descriptor = {
		interval = 1,
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		mkp_route = route,
		objective = pickup_objective,
		search_pos = pickup_objective.pos,
		verification_clbk = callback(self, self, 'mkp_clbk_pickup_SO_verification'),
		AI_group = 'friendlies',
		admin_clbk = callback(self, self, 'mkp_on_pickup_SO_administered')
	}

	local so_id = Monkeepers.SO_prefix .. tostring(self._unit:key())
	self._carry_SO_data = {
		mkp_route = route,
		SO_registered = true,
		picked_up = false,
		SO_id = so_id,
		pickup_area = pickup_objective.area,
		pickup_objective = pickup_objective
	}

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	return so_id
end

CarryData.mkp_unregister_steal_SO = CarryData._unregister_steal_SO
function CarryData:_unregister_steal_SO()
	self:mkp_unregister_steal_SO()
	self:mkp_unregister_carry_SO()
end

function CarryData:mkp_unregister_carry_SO()
	if self._carry_SO_data and (self._carry_SO_data.SO_registered or self._carry_SO_data.carrier) then
		managers.groupai:state():remove_special_objective(self._carry_SO_data.SO_id)
		self._carry_SO_data = nil
	end
end

function CarryData:mkp_clbk_pickup_SO_verification(candidate_unit)
	if not self._carry_SO_data or not self._carry_SO_data.SO_id then
		return
	end

	local route = self._carry_SO_data.mkp_route
	if not Monkeepers:verify_pickup_SO(candidate_unit, route, self._carry_SO_data.pickup_objective) then
		return
	end

	return true
end

function CarryData:mkp_on_pickup_SO_administered(carrier)
	self._carry_SO_data.carrier = carrier
	self._carry_SO_data.SO_registered = false

	local obj = self._carry_SO_data.pickup_objective
	while obj do
		if obj.mkp_needs_bot_unit then
			obj.mkp_needs_bot_unit = nil
			obj.bot_unit = carrier
		end
		obj = obj.followup_objective
	end

	managers.groupai:state():unregister_loot(self._unit:key())
end

function CarryData:mkp_on_pickup_SO_completed(carrier)
	if not self._carry_SO_data then
		carrier:brain():set_objective(nil)
		return
	elseif not self._carry_SO_data.carrier then
		carrier:brain():set_objective(nil)
		return
	elseif self._carry_SO_data.carrier ~= carrier then
		carrier:brain():set_objective(nil)
		return
	end

	local mkp_route = self._carry_SO_data.mkp_route
	if not Keepers and mkp_route and mkp_route.dropzone and not Monkeepers:is_dropzone_ready(mkp_route.dropzone, mkp_route.position) then
		carrier:brain():set_objective(nil)
		if not self:is_linked_to_unit() then
			self:mkp_chk_register_carry_SO_delayed(nil, mkp_route, true, true)
		end
		return
	end

	if carrier:movement():carrying_bag() then
		carrier:brain():set_objective(nil)
		return
	end

	if not alive(self._unit) then
		carrier:brain():set_objective(nil)
		return
	end

	local objective = carrier:brain():objective()
	local follow_unit = objective and objective.follow_unit
	if alive(follow_unit) and follow_unit:movement():current_state_name() ~= 'carry' then
		self._carry_SO_data = nil
		self:mkp_chk_register_carry_SO()
		carrier:brain():set_objective(nil)
		return
	end

	if self._steal_SO_data and alive(self._steal_SO_data.thief) then
		self._steal_SO_data.thief:brain():set_objective(nil)
	end
	self:mkp_unregister_steal_SO()

	self._carry_SO_data.picked_up = true
	self:link_to(carrier, false)
	self:trigger_load(carrier)
end

local mkp_original_carrydata_onpickupsocompleted = CarryData.on_pickup_SO_completed
function CarryData:on_pickup_SO_completed(thief)
	if self._carry_SO_data and alive(self._carry_SO_data.carrier) then
		self._carry_SO_data.carrier:brain():set_objective(nil)
	end
	self:mkp_unregister_carry_SO()
	mkp_original_carrydata_onpickupsocompleted(self, thief)
end

function CarryData:mkp_on_pickup_SO_failed(carrier)
	if not self._carry_SO_data then
		return
	elseif not self._carry_SO_data.carrier then
		return
	elseif self._carry_SO_data.carrier ~= carrier then
		return
	end

	local route = self._carry_SO_data.mkp_route
	if route and alive(carrier) then
		if carrier:slot() == 16 and carrier:character_damage():need_revive() then
			route.failed_t = TimerManager:game():time()
		end
	end

	self._carry_SO_data = nil

	if not self:is_linked_to_unit() then
		self:mkp_chk_register_carry_SO(nil, route)
	end
end

local mkp_original_carrydata_onpickupsofailed = CarryData.on_pickup_SO_failed
function CarryData:on_pickup_SO_failed(thief)
	if self._steal_SO_data then
		mkp_original_carrydata_onpickupsofailed(self, thief)
	end
end

function CarryData:mkp_on_carry_SO_completed(route, carrier)
	if not self._carry_SO_data then
		-- qued
	elseif not self._carry_SO_data.carrier then
		return
	elseif self._carry_SO_data.carrier ~= carrier then
		return
	end

	self._carry_SO_data = nil

	local bag = carrier:movement()._carry_unit -- shelves unit != bag unit
	if alive(bag) then
		if route.dropzone and not Monkeepers:is_dropzone_ready(route.dropzone, route.position) then
			carrier:movement():throw_bag()
		else
			local cd = bag:carry_data()
			cd:unlink()
			carrier:movement()._was_carrying = { unit = bag }
			local throw_distance_multiplier = managers.player:upgrade_value_by_level('carry', 'throw_distance_multiplier', route.throw_distance_multiplier_upgrade_level, 1)
			local carry_type = tweak_data.carry[cd._carry_id].type
			throw_distance_multiplier = throw_distance_multiplier * tweak_data.carry.types[carry_type].throw_distance_multiplier
			cd:set_position_and_throw(bag:position(), 600 * throw_distance_multiplier * route.dir, 100)
		end
	end

	local followup_id, followup_so
	for id, so in pairs(managers.groupai:state()._special_objectives) do
		if so.data and so.data.AI_group == 'friendlies' and type(id) == 'string' then
			if id:find('revive') then
				return
			elseif so.data.administered then
				-- qued
			elseif not so.data.mkp_route or Monkeepers:another_route_has_priority(so.data.mkp_route) then
				-- qued
			else
				followup_id = id
				followup_so = so
			end
		end
	end

	if followup_id then
		if managers.groupai:state():_execute_so(followup_so.data, followup_so.rooms, followup_so.administered) then
			if followup_so.non_repeatable then
				followup_so.administered[carrier:key()] = true
			end
			managers.groupai:state():remove_special_objective(followup_id)
		end
	end
end

local mkp_original_carrydata_setpositionandthrow = CarryData.set_position_and_throw
function CarryData:set_position_and_throw(...)
	self.mkp_throw_t = TimerManager:game():time()
	mkp_original_carrydata_setpositionandthrow(self, ...)
end

function CarryData:mkp_on_carry_SO_failed(route, carrier)
	if carrier and self._carry_SO_data and self._carry_SO_data.carrier and self._carry_SO_data.carrier ~= carrier then
		return
	end

	if route then
		route.failed_t = TimerManager:game():time()
	end

	self._carry_SO_data = nil

	local bag = carrier:movement()._carry_unit -- shelves unit != bag unit
	if alive(bag) then
		if route and route.obsolete then
			-- qued
		else
			carrier:movement():throw_bag()
			bag:carry_data():mkp_chk_register_carry_SO_delayed(nil, route, true, true)
		end
	end
end

local mkp_original_carrydata_clbkbodyactivestate = CarryData.clbk_body_active_state
function CarryData:clbk_body_active_state(...)
	-- don't think bag has arrived when it has not even left yet
	if not self.mkp_throw_t or TimerManager:game():time() - self.mkp_throw_t > 0.5 then
		mkp_original_carrydata_clbkbodyactivestate(self, ...)
	end
end

local mkp_original_carrydata_updatethrowlink = CarryData._update_throw_link
function CarryData:_update_throw_link(unit, t, dt)
	if Monkeepers.settings.disable_catch_thrown_bags then
		return true
	elseif self.mkp_throw_t then
		return true
	end

	return mkp_original_carrydata_updatethrowlink(self, unit, t, dt)
end

local mkp_original_carrydata_linkto = CarryData.link_to
function CarryData:link_to(parent_unit, ...)
	if self._steal_SO_data and self._steal_SO_data.thief == parent_unit then
		self.mkp_stolen_position = self.mkp_stolen_position or mvec3_cpy(parent_unit:position())
	else
		self.mkp_stolen_position = nil
	end

	return mkp_original_carrydata_linkto(self, parent_unit, ...)
end

function CarryData:mkp_register_putbackintoplace_SO()
	if self._carry_SO_data or self:is_linked_to_unit() then
		return
	end

	if not self.mkp_stolen_position then
		return
	end

	local fake_route = {
		created_t = 0,
		throw_pos = mvec3_cpy(self.mkp_stolen_position),
		land_pos = mvec3_cpy(self.mkp_stolen_position),
		rot = Rotation(0, 0, 0),
		dir = Vector3(0, 0, 0),
		throw_distance_multiplier_upgrade_level = 0,
	}
	self:mkp_chk_register_carry_SO(nil, fake_route, true)

	return true
end

function CarryData:mkp_assign_SO(bot_unit)
	if not alive(bot_unit) then
		return
	end

	if not self._carry_SO_data or not self._carry_SO_data.SO_registered or self._carry_SO_data.carrier and self._carry_SO_data.carrier ~= bot_unit then
		return
	end

	local so_id = self._carry_SO_data.SO_id
	if not so_id then
		return
	end

	local gstate = managers.groupai:state()
	local so = gstate._special_objectives[so_id]
	local so_data = so and so.data
	if not so_data then
		return
	end

	if so_data.verification_clbk and not so_data.verification_clbk(bot_unit) then
		return
	end

	local obj = gstate.clone_objective(so_data.objective)
	bot_unit:brain():set_objective(obj)

	if so_data.admin_clbk then
		so_data.admin_clbk(bot_unit)
	end

	gstate:remove_special_objective(so_id)

	return obj
end
