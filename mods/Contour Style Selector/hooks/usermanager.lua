core:module("UserManager")

Hooks:PostHook(GenericUserManager, "init", "init", function(self)
	if not Global.user_manager.setting_data_map["video_contour"] then
		self:setup_setting("video_contour", "video_contour", nil)
	end
end)

Hooks:PostHook(GenericUserManager, "reset_video_setting_map", "ContourSS_reset_video_setting_map", function(self)
	self:set_setting("video_contour", self:get_default_setting("video_contour"))
end)

Hooks:PostHook(GenericUserManager, "sanitize_settings", "ContourSS_sanitize_settings", function(self)
	local contour = self:get_setting("video_contour")
	local contour_valid = false

	for _, c in ipairs(_G.tweak_data.contour_styles) do
		if contour == c.value then
			contour_valid = true

			break
		end
	end

	if not contour_valid then
		self:set_setting("video_contour", nil)
	end
end)