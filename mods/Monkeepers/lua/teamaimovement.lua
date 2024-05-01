local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local mkp_original_teamaimovement_setcarryingbag = TeamAIMovement.set_carrying_bag
function TeamAIMovement:set_carrying_bag(unit)
	local previous_carry_unit = self._carry_unit

	mkp_original_teamaimovement_setcarryingbag(self, unit)

	if alive(unit) then
		local carry_data = unit:carry_data()
		local latest_peer_id = carry_data:latest_peer_id()
		if latest_peer_id and latest_peer_id > 0 then
			carry_data:set_latest_peer_id(0)
			carry_data.mkp_callback = nil
			self.mkp_autopicked = false
			if not self._ext_base.kpr_is_keeper then
				local route = Monkeepers:find_route(self._unit:position(), carry_data:carry_id())
				if route then
					local drop_objective = carry_data:mkp_make_drop_objective(route)
					self._ext_brain:set_objective(drop_objective)
				end
			end
		else
			local objective = self._ext_brain:objective()
			if objective and (objective.mkp_route or objective.mkp_mimic_pick) then
				self.mkp_autopicked = true
			end
			if managers.groupai:state():whisper_mode() then
				self:set_attention(nil)
			end
		end
	elseif previous_carry_unit then
		local was_autopicked = self.mkp_autopicked
		self.mkp_autopicked = nil
		if was_autopicked then
			local objective = self._ext_brain:objective()
			if objective then
				self._ext_brain._logic_data.objective_failed_clbk(self._unit, objective)
			end
		end
	end
end
