Hooks:PostHook(CoreEnvironmentControllerManager, "init", "ContourSS_init", function(self)
	self._GAME_DEFAULT_CONTOUR = "contour_default"
	self._default_contour = self._GAME_DEFAULT_COLOR_GRADING
	self._ignore_user_contour = false
end)

function CoreEnvironmentControllerManager:set_default_contour(contour, ignore_user_setting)
	self._default_contour = contour or self._GAME_DEFAULT_COLOR_GRADING
	self._ignore_user_contour = ignore_user_setting or false
end

function CoreEnvironmentControllerManager:game_default_contour()
	return self._GAME_DEFAULT_CONTOUR
end

function CoreEnvironmentControllerManager:default_contour()
	return self._default_contour
end

Hooks:PostHook(CoreEnvironmentControllerManager, "refresh_render_settings", "ContourSS_refresh_render_settings", function(self, vp)
	if not alive(self._vp) then
		return
	end

	local contour = self._default_contour

	if not self._ignore_user_contour then
		contour = managers.user:get_setting("video_contour") or self._default_contour
	end

	self._vp:vp():set_post_processor_effect("World", Idstring("contour_post"), Idstring(contour))
end)