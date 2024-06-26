Hooks:RegisterHook("MenuManagerInitialize")
Hooks:RegisterHook("MenuManagerPostInitialize")
Hooks:PostHook(MenuManager, "init", "BLT.MenuManager.init", function(self)
	Hooks:Call("MenuManagerInitialize", self)
	Hooks:Call("MenuManagerPostInitialize", self)
end)

Hooks:RegisterHook("MenuManagerOnOpenMenu")
Hooks:PostHook(MenuManager, "open_menu", "BLT.MenuManager.open_menu", function(self, menu_name, position)
	Hooks:Call("MenuManagerOnOpenMenu", self, menu_name, position)
end)

function MenuManager:show_download_progress(mod_name)
	local dialog_data = {}
	dialog_data.title = managers.localization:text("base_mod_download_downloading_mod", { ["mod_name"] = mod_name })
	dialog_data.mod_name = mod_name or "No Mod Name"

	local ok_button = {}
	ok_button.cancel_button = true
	ok_button.text = managers.localization:text("dialog_ok")

	dialog_data.focus_button = 1
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show_download_progress(dialog_data)
end

-- Add menus
Hooks:Add("MenuManagerPostInitialize", "MenuManagerPostInitialize_Base", function(menu_manager)
	local success, err = pcall(function()
		-- Setup lua mods menu
		menu_manager:_base_process_menu(
			{ "menu_main" },
			"mods_options",
			"options",
			"MenuManager_Base_SetupModsMenu",
			"MenuManager_Base_PopulateModsMenu",
			"MenuManager_Base_BuildModsMenu"
		)

		-- Setup mod options/keybinds menu
		menu_manager:_base_process_menu(
			{ "menu_main", "menu_pause" },
			"video",
			"options",
			"MenuManager_Base_SetupModOptionsMenu",
			"MenuManager_Base_PopulateModOptionsMenu",
			"MenuManager_Base_BuildModOptionsMenu"
		)

		-- Allow custom menus on the main menu (and lobby) and the pause menu
		menu_manager:_base_process_menu({ "menu_main" })
		menu_manager:_base_process_menu({ "menu_pause" })
	end)
	if not success then
		BLT:Log(LogLevel.ERROR, tostring(err))
	end
end)

function MenuManager:_base_process_menu(menu_names, parent_menu_name, parent_menu_button, setup_hook, populate_hook, build_hook)
	for k, v in pairs(menu_names) do
		local menu = self._registered_menus[v]
		if menu then
			local nodes = menu.logic._data._nodes
			local hook_id_setup = setup_hook or "MenuManagerSetupCustomMenus"
			local hook_id_populate = populate_hook or "MenuManagerPopulateCustomMenus"
			local hook_id_build = build_hook or "MenuManagerBuildCustomMenus"

			MenuHelper:SetupMenu(nodes, parent_menu_name or "video")
			MenuHelper:SetupMenuButton(nodes, parent_menu_button or "options", not parent_menu_button and "sound")

			Hooks:RegisterHook(hook_id_setup)
			Hooks:RegisterHook(hook_id_populate)
			Hooks:RegisterHook(hook_id_build)

			Hooks:Call(hook_id_setup, self, nodes)
			Hooks:Call(hook_id_populate, self, nodes)
			Hooks:Call(hook_id_build, self, nodes)
		end
	end
end

-- Create this function if it doesn't exist
function MenuCallbackHandler:can_toggle_chat()
	if managers and managers.menu then
		local input = managers.menu:active_menu() and managers.menu:active_menu().input
		return not input or input.can_toggle_chat and input:can_toggle_chat()
	else
		return true
	end
end

--------------------------------------------------------------------------------
-- Add BLT save function

Hooks:Register("BLTOnSaveData")
function MenuCallbackHandler:perform_blt_save()
	BLT:Log(LogLevel.INFO, "[BLT] Performing save...")

	Hooks:Call("BLTOnSaveData", BLT.save_data)

	local success = io.save_as_json(BLT.save_data, BLTModManager.Constants:ModManagerSaveFile(BLT:IsVr()))
	if not success then
		BLT:Log(LogLevel.ERROR, "[BLT] Could not save file " .. BLTModManager.Constants:ModManagerSaveFile(BLT:IsVr()))
	end
end

function MenuCallbackHandler:close_blt_mods()
	managers.menu_component:close_blt_mods_gui()
end

function MenuCallbackHandler:close_blt_download_manager()
	managers.menu_component:close_blt_download_manager_gui()
end

--------------------------------------------------------------------------------
-- Add BLT dll update notification

function MenuCallbackHandler:blt_update_dll_dialog(update)
	local update_url = update:GetUpdateMiscData().update_url

	local dialog_data = {}
	dialog_data.title = managers.localization:text("blt_update_dll_title")
	dialog_data.text = managers.localization:text("blt_update_dll_text")

	local download_button = {}
	download_button.text = managers.localization:text("blt_update_dll_goto_website")
	download_button.callback_func = callback(self, self, "clbk_goto_paydaymods_download", update_url)

	local ok_button = {}
	ok_button.text = managers.localization:text("blt_update_later")
	ok_button.cancel_button = true

	dialog_data.button_list = { download_button, ok_button }
	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:clbk_goto_paydaymods_download(update_url)
	os.execute("cmd /c start " .. update_url)
end

--------------------------------------------------------------------------------
-- Add visibility callback for showing keybinds

function MenuCallbackHandler:blt_show_keybinds_item()
	return BLT.Keybinds and BLT.Keybinds:has_menu_keybinds()
end

--------------------------------------------------------------------------------
-- Add settings callbacks

function MenuCallbackHandler:blt_choose_language(item)
	if BLT.Localization then
		BLT.Localization:set_language(item:value())
	end
end

function MenuCallbackHandler:blt_choose_log_level(item)
	BLTLogs.log_level = math.clamp(item:value(), _G.LogLevel.NONE, _G.LogLevel.ALL)
end

function MenuCallbackHandler:blt_choose_log_lifetime(item)
	BLTLogs.lifetime = item:value()
end
