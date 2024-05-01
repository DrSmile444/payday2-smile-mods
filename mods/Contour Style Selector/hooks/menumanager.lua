function MenuCallbackHandler:choice_choose_contour(item)
	managers.user:set_setting("video_contour", item:value())

	if managers.environment_controller then
		managers.environment_controller:refresh_render_settings()
	end
end

Hooks:Add("MenuManagerBuildCustomMenus", "ContourSS_add_contour_option", function(menu_manager, nodes)
	local adv_video_node = nodes.adv_video

	local params = {
		name = "choose_contour",
		text_id = "menu_contour",
		help_id = "menu_contour_help",
		callback = "choice_choose_contour",
		filter = true,
		localize = true,
		localize_help = true
	}
	local data_node = {
		type = "MenuItemMultiChoice"
	}
	local contour_item = adv_video_node:create_item(data_node, params)

	for index, item in pairs(adv_video_node._items) do
		if item:name() == "choose_color_grading" then
			position = index + 1
			break
		end
	end
	adv_video_node:insert_item(contour_item, position)
end)

Hooks:PostHook(MenuOptionInitiator, "modify_adv_video", "ContourSS_modify_adv_video", function(self, node)
	local contour_item = node:item("choose_contour")
	if contour_item then
		if #contour_item:options() == 0 then
			for id, data in ipairs(tweak_data.contour_styles) do
				local option = CoreMenuItemOption.ItemOption:new(data)

				contour_item:add_option(option)
			end
		end

		contour_item:set_value(managers.user:get_setting("video_contour"))
	end
end)