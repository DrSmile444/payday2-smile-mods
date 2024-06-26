local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_dis_sq = mvector3.distance_sq

local kpr_original_copactionwalk_chkcorrectpose = CopActionWalk._chk_correct_pose
function CopActionWalk:_chk_correct_pose()
	if self._expired and self._action_desc.kpr_so_expiration then
		if self._ext_anim.interact then
			self._expired = false
			return
		end
	end

	kpr_original_copactionwalk_chkcorrectpose(self)
end

local kpr_original_copactionwalk_chkstartanim = CopActionWalk._chk_start_anim
function CopActionWalk:_chk_start_anim(next_pos)
	if self._haste == 'run' and mvec3_dis_sq(next_pos, self._common_data.pos) < 160000 then
		return
	end

	kpr_original_copactionwalk_chkstartanim(self, next_pos)
end
