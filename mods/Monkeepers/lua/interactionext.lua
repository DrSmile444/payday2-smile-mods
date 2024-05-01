local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local mvec3_dis = mvector3.distance

local mkp_original_carryinteractionext_collisioncallback = CarryInteractionExt._collision_callback
function CarryInteractionExt:_collision_callback(...)
	local need_register_collision

	local carry_data = self._unit:carry_data()
	local mkp_throw_t = carry_data.mkp_throw_t
	carry_data.mkp_throw_t = nil
	if carry_data.mkp_callback and not carry_data:is_linked_to_unit() then
		if carry_data.mkp_spawn_position and mvec3_dis(self._unit:position(), carry_data.mkp_spawn_position) < 60 then
			need_register_collision = true
		else
			carry_data.mkp_callback()
		end
	end

	mkp_original_carryinteractionext_collisioncallback(self, ...)

	if need_register_collision then
		if carry_data:can_explode() and not carry_data:explode_sequence_started() then
			-- qued
		else
			carry_data.mkp_throw_t = mkp_throw_t
			self:register_collision_callbacks()
		end
	end
end

local mkp_original_carryinteractionext_syncinteracted = CarryInteractionExt.sync_interacted
function CarryInteractionExt:sync_interacted(peer, player, ...)
	local instigator = player or peer and peer:unit()
	if alive(instigator) then
		self._unit:carry_data():mkp_on_picked_up_carry(instigator)
	end

	mkp_original_carryinteractionext_syncinteracted(self, peer, player, ...)
end

if not Keepers then
	return
end

local mkp_original_baseinteractionext_setactive = BaseInteractionExt.set_active
function BaseInteractionExt:set_active(...)
	local was_active = self._active

	mkp_original_baseinteractionext_setactive(self, ...)

	if not was_active and self._active and not self._disabled and self._unit:slot() == 1 then
		local cd = self._unit:carry_data()
		if cd and not Monkeepers:is_unit_routed(self._unit) then
			local route = Monkeepers:find_route(self:interact_position(), cd._carry_id, self.tweak_data)
			if route then
				cd:mkp_chk_register_carry_SO(nil, route, true)
			end
		end
	end
end
