local headshot, melee = false, false

Hooks:PreHook(CopDamage, "damage_bullet", "sa_redone_cd_damage_bullet", function(self, attack_data)
  if _G.SA_loud then return end
  local hs = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
  attack_data.sa_headshot = hs
end)

Hooks:PreHook(CopDamage, "damage_melee", "sa_redone_cd_damage_melee", function(self, attack_data)
  if _G.SA_loud then return end
  attack_data.melee = true
end)

Hooks:PreHook(CopDamage, "sync_damage_bullet", "sa_redone_cd_sync_damage_bullet", function(self, attacker_unit, damage_percent, i_body)
  if _G.SA_loud then return end
  local body = self._unit:body(i_body)
	headshot = self._head_body_name and body and body:name() == self._ids_head_body_name
end)

Hooks:PreHook(CopDamage, "sync_damage_melee", "sa_redone_cd_sync_damage_melee", function(self)
    if _G.SA_loud then return end
    melee = true
end)

Hooks:PreHook(CopDamage, "_on_damage_received", "sa_redone_cd_on_damage_received", function(self, attack_data)
  if _G.SA_loud then return end
  attack_data.sa_headshot = attack_data.sa_headshot or headshot
  attack_data.melee = attack_data.melee or melee
  headshot, melee = false, false
end)