local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_Monkeepers', function(loc)
	local language_filename

	local modname_to_language = {
		['PAYDAY 2 THAI LANGUAGE Mod'] = 'thai.txt',
	}
	for _, mod in ipairs(BLT and BLT.Mods:Mods() or {}) do
		language_filename = mod:IsEnabled() and modname_to_language[mod:GetName()]
		if language_filename then
			break
		end
	end

	if not language_filename then
		for _, filename in pairs(file.GetFiles(Monkeepers.path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file(Monkeepers.path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(Monkeepers.path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_Monkeepers', function(menu_manager)
	function MenuCallbackHandler:MonkeepersDeleteAllRoutes(item)
		if Network:is_server() then
			Monkeepers:cancel_everything()
		end
	end

	function MenuCallbackHandler:MonkeepersHub(item)
		Monkeepers.settings[item:name()] = item:value()
	end

	function MenuCallbackHandler:MonkeepersToggleHub(item)
		Monkeepers.settings[item:name()] = item:value() == 'on'
	end

	function MenuCallbackHandler:MonkeepersChangedFocus(focus)
		if not focus then
			Monkeepers:save_settings()
			Monkeepers:update_current_behaviour()
		end
	end

	MenuHelper:LoadFromJsonFile(Monkeepers.path .. 'menu/options.txt', Monkeepers, Monkeepers.settings)

	Hooks:Add('MenuManagerBuildCustomMenus', 'MenuManagerBuildCustomMenus_Monkeepers', function(menu_manager, nodes)
		nodes.mkp_options_menu:parameters().modifier = {MonkeepersCreator.modify_node}
	end)
end)

_G.MonkeepersCreator = _G.MonkeepersCreator or class()
function MonkeepersCreator.modify_node(node)
	local old_items = node:items()

	node:clean_items()

	for _ = 1, 3 do
		node:add_item(table.remove(old_items, 1))
	end

	local ordered = {}
	for level_id, level_data in pairs(tweak_data.levels) do
		if type(level_data) ~= 'table' then
		elseif not level_data.name_id then
		elseif level_id == 'chill' then
		elseif not managers.localization:exists(level_data.name_id) then
		elseif level_id:match('^skm_') then
		elseif level_id:match('^short[0-9]_') then
		elseif level_id:match('_day$') then
		elseif level_id:match('_night$') then
		else
			table.insert(ordered, {
				level_id = level_id,
				level_data = level_data,
				txt = managers.localization:text(level_data.name_id),
				value = Monkeepers.settings[level_id] or Monkeepers.default_behaviour_id
			})
		end
	end

	table.sort(ordered, function(a, b)
		if a.value ~= b.value then
			if a.value == Monkeepers.default_behaviour_id then
				return false
			elseif b.value == Monkeepers.default_behaviour_id then
				return true
			else
				return a.value < b.value
			end
		else
			return a.txt < b.txt
		end
	end)

	local data = { type = 'MenuItemMultiChoice' }
	for i, behaviour in ipairs(Monkeepers.behaviours) do
		table.insert(data, { _meta = 'option', text_id = 'mkp_behaviour_' .. behaviour, value = i })
	end

	for _, level in ipairs(ordered) do
		local params = {
			name = level.level_id,
			text_id = level.level_data.name_id,
			help_id = managers.localization:text('mkp_options_behaviour_desc', { LEVEL = level.level_id }),
			callback = 'MonkeepersHub',
			to_upper = false,
			localize = true,
			localize_help = false
		}
		local new_item = node:create_item(data, params)
		new_item._current_index = Monkeepers.settings[level.level_id] or Monkeepers.default_behaviour_id
		node:add_item(new_item)
	end

	managers.menu:add_back_button(node)

	return node
end
