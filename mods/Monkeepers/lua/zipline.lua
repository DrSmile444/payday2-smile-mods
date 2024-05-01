local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function ZipLine:mkp_update_zipline(force_remove)
	if force_remove or not self:is_usage_type_bag() then
		table.delete(Monkeepers.ziplines, self)
	else
		table.insert(Monkeepers.ziplines, self)
	end
end

local mkp_original_zipline_setusagetype = ZipLine.set_usage_type
function ZipLine:set_usage_type(...)
	mkp_original_zipline_setusagetype(self, ...)
	self:mkp_update_zipline()
end

local mkp_original_zipline_destroy = ZipLine.destroy
function ZipLine:destroy(...)
	self:mkp_update_zipline(true)
	mkp_original_zipline_destroy(self, ...)
end

local mkp_original_zipline_checkinteractionactivestate = ZipLine._check_interaction_active_state
function ZipLine:_check_interaction_active_state()
	mkp_original_zipline_checkinteractionactivestate(self)

	if self.mkp_so_id then
		managers.groupai:state():remove_special_objective(self.mkp_so_id)
	end

	if Keepers and self:is_usage_type_bag() and not self:is_interact_blocked() then
		local tracker = managers.navigation:create_nav_tracker(self._unit:interaction():interact_position(), true)
		local pos = tracker:field_position()
		managers.navigation:destroy_nav_tracker(tracker)

		local bags = Monkeepers:get_bags_around(pos, Monkeepers.radius_zipline_zone, false, false)
		local closest_bag = Monkeepers:get_closest_bag_from(pos, bags)
		if closest_bag then
			local zipline_objective = Keepers:get_special_objective(nil, false, nil, nil, self._unit)
			if zipline_objective then
				zipline_objective.duration = 0.1
				zipline_objective.action_duration = 0.1
				zipline_objective.mkp_needs_bot_unit = true
				zipline_objective.kpr_icon = Monkeepers.transport_icon
				local cd = closest_bag:carry_data()
				if cd:mkp_chk_register_carry_SO(zipline_objective) then
					self.mkp_so_id = cd._carry_SO_data.SO_id
					cd._carry_SO_data.pickup_objective.kpr_recruit_keepers_dis = Monkeepers.radius_zipline_zone
					cd._carry_SO_data.pickup_objective.kpr_recruit_keepers_around_pos = self._unit:position()
				end
			end
		end
	end
end
