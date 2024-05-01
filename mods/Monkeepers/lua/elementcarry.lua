local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mkp_original_elementcarry_onexecuted = ElementCarry.on_executed
function ElementCarry:on_executed(instigator)
	local op_ok = {
		remove = true,
		secure = true,
		secure_silent = true,
	}
	if alive(instigator) and op_ok[self._values.operation] then
		local pos = instigator:position()
		for _, element in pairs(Monkeepers.lootareas) do
			if element:enabled() and element:_is_inside(pos) then
				local carry_data = instigator:carry_data()
				if carry_data and carry_data.mkp_callback then
					local filters = Monkeepers:get_dropzone_filters(element)
					if not filters or filters[carry_data._carry_id] then
						carry_data.mkp_callback(element)
						carry_data.mkp_callback = nil
						break
					end
				end
			end
		end
	end

	return mkp_original_elementcarry_onexecuted(self, instigator)
end
