Hooks:PostHook(PlayerTweakData, "init", "sa_redone_ptd_init", function(self)
  self.alarm_pager.bluff_success_chance = {100}
  self.alarm_pager.bluff_success_chance_w_skill = {100}
end)