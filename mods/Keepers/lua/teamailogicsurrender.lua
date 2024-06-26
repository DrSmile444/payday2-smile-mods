local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_teamailogicsurrender_enter = TeamAILogicSurrender.enter
function TeamAILogicSurrender.enter(data, new_logic_name, enter_params)
	if data.unit:unit_data().name_label_id then
		Keepers:reset_label(data.unit, false)
		LuaNetworking:SendToPeers('KeeperOFF', Keepers:get_lua_networking_text(0, data.unit, nil))
	end

	kpr_original_teamailogicsurrender_enter(data, new_logic_name, enter_params)
end
