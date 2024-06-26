---
local ALTFONT = 'fonts/font_eroded'
local FONT =  'fonts/font_medium_mf' -- or tweak_data.hud_present.title_font or tweak_data.hud_players.name_font or 'fonts/font_eroded' or 'core/fonts/system_font'
local FONTLARGE = 'fonts/font_large_mf'
local clGood =  cl.YellowGreen
local clBad =  cl.Gold
local isNil = function(a) return a == nil end
local ModPath = rawget(_G,'ModPath') and debug.getinfo(1).source:match("^.(.+/)[^/]+$") or PocoDir
local LocJSONFileName = ModPath..'loc/hud3_locale$.json'
local LocationJSONFilename = ModPath..'loc/hud3_rooms'
local LocationJSONFileExt = '.json'

local Icon = {
	A=57344, B=57345, X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, DRC = 1035, Deg = 1024, PM= 1030, No = 1033,
}
for k, v in pairs(Icon) do
	Icon[k] = utf8.char(v)
end
local now = function() return managers.player:player_timer():time() end
local PocoEvent = {
	In = 'onEnter',
	Out = 'onExit',
	Pressed = 'onPressed',
	Released = 'onReleased',
	PressedAlt = 'onPressedAlt',
	ReleasedAlt = 'onReleasedAlt',
	Click = 'onClick',
	WheelUp = 'onWheelUp',
	WheelDown = 'onWheelDown',
	Move = 'onMove',
}
local O, L, me, blendMode, interactionCircleAlpha, buffO, floatO, popupO, hitO
PocoHud3Class = {
	ALTFONT	= ALTFONT	,
	FONT		= FONT		,
	FONTLARGE = FONTLARGE,
	clGood	= clGood	,
	clBad		= clBad		,
	Icon		= Icon		,
	PocoEvent = PocoEvent,
}
PocoHud3Class.loadVar = function(_O,_me,_L)
	O = _O
	L = _L
	me = _me
	clGood = O:get('root','colorPositive')
	clBad = O:get('root','colorNegative')
	blendMode = O:get('root', 'blendMode') == 1 and 'add' or 'normal'
	interactionCircleAlpha = O:get("buff", "interactionCircle") and 1 or 0
	buffO = O:get("buff")
	floatO = O:get("float")
	popupO = O:get("popup")
	hitO = O:get("hit")
end

--- miniClass start ---
local TBuff = class()
PocoHud3Class.TBuff = TBuff
function TBuff:init(owner,data)
	self.owner = owner
	self.ppnl = owner.pnl.buff
	self:set(data)
end
function TBuff:set(data)
	self.dead = false
	local st = self.data and self.data.st
	if data.t then
		local s = now()
		data.st = s
		data.et = s + data.t
	end
	self.data = data
	if st and data.et ~= 1 then
		self.data.st = st
	end
end
function TBuff:Extend(st, et)
	if et then
		self.data.st = st
		self.data.et = et
	else
		local s = now()
		self.data.st = s
		self.data.et = s + st
	end
end
function TBuff:D(decrease)
	self.data.et = self.data.et - decrease
end
function TBuff:_make()
	local style = buffO.style
	local vanilla = style == 2
	local glowy = style == 3

	local size = style==2 and 40 or buffO.buffSize
	local data = self.data
	local simple = self.owner:_isSimple(data.key)
	self.created = true
	if simple then
		local simpleRadius = buffO.simpleBusySize
		local pnl = self.ppnl:panel({x = (self.owner.ww or 0)/2-simpleRadius,y=(self.owner.hh or 0)/2-simpleRadius, w=simpleRadius*2,h=simpleRadius*2})
		self.pnl = pnl
		local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
		self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = simpleRadius, sides = 64, current = 20, total = 64, blend_mode = blendMode, layer = 0, alpha = interactionCircleAlpha} )
	elseif vanilla then
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, align='center', font_size = size/2, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal'}
		self.bg = HUDBGBox_create( pnl, { w = size, h = size, x = 0, y = 0 }, { color = cl.White, blend_mode = 'normal' } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = blendMode, layer=1, x=0,y=0, color=style==2 and cl.White or data.good and clGood or clBad } ) or nil
		if self.bmp then
			if self.bmp:width() > size then
				self.bmp:set_size(size,size)
			end
			self.bmp:set_center(5+size + size/2,size/2)
		end
		pnl:set_shape(0,0,size*2+5,size*1.25)
		pnl:set_position(-100,-100)
	else
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		self.lbl = pnl:text{text='', font=FONT, font_size = size/4, color = data.color or data.good and clGood or clBad, x=1,y=1, layer=2, blend_mode = 'normal', rotation = 360}
		self.bg = pnl:bitmap( { name='bg', texture= 'guis/textures/pd2/hud_tabs',texture_rect=  { 105, 34, 19, 19 }, color= cl.Black:with_alpha(0.2), layer=0, x=0,y=0 } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = blendMode, layer=1, x=0,y=0, color=data.good and clGood or clBad } ) or nil
		if glowy then
			self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = 'guis/textures/pd2/specialization/progress_ring',
			radius = size/2*1.2, sides = 64, current = 20, total = 64, blend_mode = blendMode, layer = 0, alpha = interactionCircleAlpha} )
			self.pie:set_position( -size*0.1, -size*0.1)
		else
			local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
			self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = blendMode, layer = 0, alpha = interactionCircleAlpha} )
			self.pie:set_position(0, 0)
		end
		if self.bmp then
			if self.bmp:width() > 0.7*size then
				self.bmp:set_size(0.7*size,0.7*size)
			end
			self.bmp:set_center(size/2,size/2)
		end
		pnl:set_shape(0,0,size,size*1.25)
		self.bg:set_size(size,size)
		pnl:set_position(-100,-100)
	end
end
function TBuff:draw(t,x,y)
	if not self.dead then
		if not self.created then
			self:_make()
		end
		local data = self.data
		local st,et = data.st,data.et or 0
		local prog = (now()-st)/(et-st)
		local style = buffO.style
		local vanilla = style == 2
		--local glowy = style == 3
		local simple = self.owner:_isSimple(data.key)
		if (prog >= 1 or prog < 0) and et ~= 1 then
			self.dead = true
		elseif alive(self.pnl) then
			if et == 1 then
				prog = st
			end
			x = self.x and self.x + (x-self.x)/5 or x
			y = self.y and self.y + (y-self.y)/5 or y
			if not simple then
				self.pnl:set_center(x,y)
			end
			self.x = x
			self.y = y
			local txts
			if simple then

			elseif vanilla then
				local sTxt = self.owner:_lbl(nil,data.text)
				if et == 1 then -- Special
					sTxt = sTxt ~= '' and (sTxt or ''):gsub(' ','\n') or  _.f(prog*100,1)..'%'
				else
					sTxt = _.f(et-now(),1)..'s'
				end
				txts = {{sTxt,cl.White}}
			else
				if type(data.text)=='table' then
					txts = data.text
				else
					txts = {{data.text and data.text..' ' or '',data.color}}
					table.insert(txts,{_.f(et ~= 1 and et-now() or prog*100)..(et == 1 and '%' or 's'),data.good and clGood or clBad})
				end
			end
			if not simple then
				if buffO.textOnBuff or vanilla then
					self.owner:_lbl(self.lbl,txts)
				end
				local _x,_y,w,h = self.lbl:text_rect()
				self.lbl:set_size(w,h)
				if vanilla then
					local ww, hh = self.bg:size()
					self.lbl:set_center(ww/2,hh/2)
				else
					local ww, hh = self.pnl:size()
					self.lbl:set_center(ww/2,hh-h/2)
				end
			end
			if self.pie then
				if buffO.mirrorDirection then
					self.pie._circle:set_rotation(-(1-prog)*360)
				end
				self.pie:set_current(1-prog)
			end
			if not self.dying then
				self.pnl:set_alpha(1)
			end
		end
	end
end
function TBuff:_fade(pnl, done_cb, seconds)
	local pnl = self.pnl
	if not pnl then return end
	pnl:set_visible(true)
	pnl:set_alpha(1)
	local t = seconds
	while alive(pnl) and t > 0 do
		if not self.dead then
			self.dying = false
			break
		end
		local dt = coroutine.yield()
		t = t - dt
		pnl:set_alpha((self.lastD or 1) * t/seconds)
	end
	if self.dying then
		pnl:set_visible(false)
		if done_cb then done_cb(pnl) end
	end
end
function TBuff:destroy(skipAnim)
	local pnl = self.pnl
	if self.created and alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate( callback(self, self, '_fade'), callback(self, self, 'destroy', true), 0.25 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.buffs[self.data.key] = nil
		end
	end
end
local TGaugeBuff = class(TBuff)
PocoHud3Class.TGaugeBuff = TGaugeBuff
function TGaugeBuff:set(data)
	data.et = 1
	TGaugeBuff.super.set(self, data)
end
function TGaugeBuff:Extend(progress, text)
	self.data.st = progress
	self.data.text = text
end
	-------
local TPop = class()
PocoHud3Class.TPop = TPop
function TPop:init(owner,data)
	self.owner = owner
	self.data = data
	self.data.st=now()
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TPop:_make()
	local size = popupO.size
	local pnl = self.ppnl:panel({x = 0, y = 0, w=200, h=100})
    local data = self.data
    if data.crit then
        size = size * 1.2;
    end
	self.pnl = pnl
	self.lbl = pnl:text{text='', font=FONT, font_size = size, color = data.color or data.good and clGood or clBad, x=0,y=0, layer=3, blend_mode = blendMode}
	local _txt = self.owner:_lbl(self.lbl,data.text)
	self.lblBg = pnl:text{text=_txt, font=FONT, font_size = size, color = cl.Black, x=1,y=1, layer=2, blend_mode = 'normal'}
	local x,y,w,h = self.lblBg:text_rect()
	pnl:set_shape(-100,-100,w,h)
end
function TPop:draw(t)
	if not self.dead and alive(self.pnl) then
		local camPos = self.owner.camPos
		local data = self.data
		local st,et = data.st,data.et
		local prog = (now()-st)/(et-st)
		local pos = data.pos + Vector3()
		local nl_dir = pos - camPos
		mvector3.normalize(nl_dir)
		local dot = mvector3.dot(self.owner.nl_cam_forward, nl_dir)
		self.pnl:set_visible(dot > 0)
		if dot > 0 then
			local pPos = self.owner:_v2p(pos)
			if not data.stay then
				mvector3.set_y(pPos,pPos.y - math.lerp(100,0, math.pow(1-prog,7)))
			end

			if prog >= 1 then
				self.dead = true
			else
				local isADS = self.owner.ADS
				local dx,dy,d,ww,hh = 0,0,1,self.owner.ww,self.owner.hh
				self.pnl:set_center(pPos.x,pPos.y)
				if isADS then
					dx = pPos.x - ww/2
					dy = pPos.y - hh/2
					d = math.clamp((dx*dx+dy*dy)/1000,0,1)
				else
					d = 1-math.pow(prog,5)
				end
				d = math.min(d,self.owner:_visibility(false))
				self.pnl:set_alpha(math.min(1-prog,d))
			end
		end
	end
end
function TPop:destroy(key)
	self.ppnl:remove(self.pnl)
	if key then
		self.owner.pops[key] = nil
	end
end

local drillNumber
local TFloat = class()
PocoHud3Class.TFloat = TFloat
function TFloat:init(owner, data)
	if managers.job:current_level_id() == 'help' then
		drillNumber = drillNumber or 0
	end
	self.owner = owner
	self.category = data.category
	self.unit = data.unit
	self.key = data.key
	self.tag = data.tag or {}
	self.temp = data.temp
	self.lastT = type(self.temp) == 'number' and self.temp or now()
	if data.unit and alive(data.unit) then
		if data.unit:timer_gui() then
			self.isDrill = true
			self.MaxTime = owner:_time(data.unit:timer_gui()._timer or 0)
		elseif data.unit:digital_gui() then
			self.MaxTime = tonumber(data.unit:digital_gui()._timer) or 0
			self._MaxTime = owner:_time(self.MaxTime)
		end
	end
	self.ppnl = owner.pnl.pop
	self:_make()
end
function TFloat:__shadow(x)
	if x then
		self.lblShadow1:set_x(x+1)
		self.lblShadow2:set_x(x-1)
	else
		self.lblShadow1:set_text(self._txts)
		self.lblShadow2:set_text(self._txts)
	end
end
function TFloat:_make()
	local size = floatO.size
	local m = floatO.margin
	local pnl = self.ppnl:panel({x = 0,y=-size, w=300,h=100})
	local texture = 'guis/textures/pd2/hud_health' or 'guis/textures/pd2/hud_progress_32px'
	self.pnl = pnl
	self.bg = floatO.frame
		and HUDBGBox_create(pnl, {x= 0,y= 0,w= 1,h= 1},{color=cl.White:with_alpha(1)})
		or pnl:bitmap( { name='blur', texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, x=0,y=0 } )
	self.pie = CircleBitmapGuiObject:new( pnl, { use_bg = false, x=m,y=m,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = 'normal', layer = 4} )
	self.pieBg = pnl:bitmap( { name='pieBg', texture='guis/textures/pd2/hud_progress_active', w = size, h = size, layer=3, x=m,y=m, color=cl.Black:with_alpha(0.5) } )
	self.lbl = pnl:text{text='text', font=FONT, font_size = size, color = cl.White, x=size+m*2,y=m, layer=3, blend_mode = 'normal'}
	self.lblShadow1 = pnl:text{text='shadow', font=FONT, font_size = size, color = cl.Black:with_alpha(0.3), x=1+size+m*2,y=1+m, layer=2, blend_mode = 'normal'}
	self.lblShadow2 = pnl:text{text='shadow', font=FONT, font_size = size, color = cl.Black:with_alpha(0.3), x=size+m*2-1,y=1+m, layer=2, blend_mode = 'normal'}
end

function TFloat:_getName()
	local name = self._name or 'Drill'
	local host = self._host
	--[[local a = not name:find('The ') and 'A' or ''
	if a then
		local n = name:sub(1,1):lower()
		if n == 'a' or n == 'e' or n == 'i' or n == 'o' or n == 'u' then
			a = a .. 'n'
		end
	end]]
	return _.s(a or '',name,host and PocoLocale._drillOn or nil,host)
end
function TFloat:_getHost()
	local mD = self.unit and alive(self.unit) and self.unit:mission_door_device()
	local pD = mD and mD._parent_door
	local key = pD and pD:name():key()
	if key and not PocoLocale._drillHosts[key] then
		_(os.date(),'Found a new DrillHost',key,'\n')
	end
	return key and PocoLocale._drillHosts[key] or nil
end

function TFloat:get_name(name, def)
	local newname = def or name

	if PocoLocale._drillNames[name] then
		newname = PocoLocale._drillNames[name]
	elseif PocoLocale._drillNamesGuess then
		for k, v in pairs(PocoLocale._drillNamesGuess) do
			if name:find(k) then
				newname = v
			end
		end
	end

	if drillNumber and self.isDrill then
		if not self.num then
			drillNumber = drillNumber + 1
			self.num = drillNumber
		end

		newname = newname..'_'..self.num
	end

	return newname or ''
end
function TFloat:SetDead()
	self.dead = true
end
function TFloat:draw(t)
	if not alive(self.unit) or (self.temp and (t-self.lastT>0.5)) and not self.dead then
		self.dead = true
	end
	if self.dead and not self.dying then
		self:destroy()
		return
	end
	if not alive(self.pnl) then
		return
	end
	local verbose = self.owner.verbose
	local onScr = floatO.keepOnScreen
	local size = floatO.size
	local m = floatO.margin
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos
	local category = self.category
	local unit = self.unit
	if not alive(unit) then return end
	local dx,dy,d,pDist,ww,hh= 0,0,1,0,self.owner.ww,self.owner.hh
	local pos = self.owner:_pos(unit,true)
	local nl_dir = pos - camPos
	local dir = pos - camPos
	mvector3.normalize(nl_dir)
	local dot = mvector3.dot(self.owner.nl_cam_forward, nl_dir)
	local pPos = self.owner:_v2p(pos)
	local out = false
	if onScr and (category == 1 or self.temp) then
		local _sm = {floatO.keepOnScreenMarginX, floatO.keepOnScreenMarginY}
		local sm = {x = _sm[1]/100, y = _sm[2]/100}
		local xm = {x = 1-sm.x, y = 1-sm.y}
		if dot < 0
			or pPos.x < sm.x*ww or pPos.y < sm.y*hh
			or pPos.x > xm.x*ww or pPos.y > xm.y*hh then
			local abs = math.abs
			local rr = (hh*(0.5-sm.y))/(ww*(0.5-sm.x))
			local cV = Vector3(ww/2,hh/2,0)
			local dV = pPos:with_z(0) - cV
			local mul = 1
			mvector3.normalize(dV)
			if abs(dV.x * rr) > abs(dV.y) then -- x
				mul = ww*(0.5-sm.x)/dV.x
			else -- y
				mul = hh*(0.5-sm.y)/dV.y
			end
			out = true
			pPos = cV + dV*abs(mul)
		end
	end
	dx = pPos.x - ww/2
	dy = pPos.y - hh/2
	pDist = dx*dx+dy*dy
	self.pnl:set_visible((onScr and out) or dot > 0)
	if dot > 0 or onScr then
		local prog, txts = 0, {}
		if category == 0 then -- Unit
            local charDmg = unit:character_damage()
			local cHealth = charDmg and charDmg._health and charDmg._health*10 or 0
			local fHealth = cHealth > 0 and charDmg and (charDmg._HEALTH_INIT and charDmg._HEALTH_INIT*10 or charDmg._health_max and charDmg._health_max*10) or 1
			prog = cHealth / fHealth
            local isTeamAi = (charDmg and charDmg.force_custody) and true or false
			local cCarry = unit:carry_data()
			local isCiv = unit and managers.enemy:is_civilian(unit)
			local color = isCiv and cl.Lime or math.lerp(cl.Red:with_alpha(0.8), cl.Yellow, prog)
			if self.tag and self.tag.minion then
				color = self.owner:_color(self.tag.minion)
			end
			--local distance = unit and mvector3.distance( unit:position(), camPos ) or 0
			if cCarry then
				color = cl.White
				txts[1] = {managers.localization:text(tweak_data.carry[cCarry._carry_id].name_id) or 'Bag',color}
			else
				local index = 1
				local isPager = (unit and unit:interaction() and unit:interaction().tweak_data or '') == 'corpse_alarm_pager'
				if isPager then
					local pager = managers.groupai:state():whisper_mode()
									and unit:interaction()
									and unit:interaction()._pager
					if pager then
						local eT,tT = now()-pager, unit:interaction()._pagerT or 12
						local r = eT/tT
						local pColor = math.lerp(cl.Red:with_alpha(0.8), cl.Yellow, 1-r)
						if r < 1 then
							prog = 1 - r
							txts[index] = {_.s(_.f(tT - eT),'/',_.f(tT)),pColor}
							index = index + 1
						end
					end
				end
				if pDist > 100000 then
                    prog = 0
				elseif cHealth == 0 then
					if floatO.showKillConfirm then
						txts[index] = {Icon.Skull,color}
						index = index + 1
					else
						self.dead = true
						return
					end
                else
                    local isMinion = false
                    local unitTweak = unit and alive(unit) and unit:base() and unit:base()._tweak_table
                    local isSpecial = unitTweak and unit:base().has_tag and unit:base():has_tag("special") or self.owner._special_units_id[statsTweak]
					if unitTweak and unit:base()._poco_convert then
						isMinion = true
						self.showTarget = floatO.showTargetsConvert
					end
                    local showTarget = self.showTarget
					if showTarget == nil then
						if isMinion then
							if floatO.showTargetsConvert then
								showTarget = true
							end
						elseif isCiv then
							if floatO.showTargetsCivs then
								showTarget = true
							end
						elseif isSpecial then
							if floatO.showTargetsSpecials then
								showTarget = true
							end
						elseif unit:base() and unit:base().sentry_gun then
							if floatO.showTargetsOther then
								showTarget = true
							end
						elseif isTeamAi or (charDmg and charDmg.damage_tase) then
							if isTeamAi then
								if floatO.showTargetsTeamAi then
									showTarget = true
								end
							else
								if floatO.showTargets then
									showTarget = true
								end
							end
						elseif floatO.showTargetsOther then
							showTarget = true
						end
					end
                    if showTarget then
						self.showTarget = true
						txts[index] = {_.f(cHealth)..'/'.._.f(fHealth),color}
						index = index + 1
                        if floatO.showNPCDistance == 2 or (verbose and floatO.showNPCDistance == 1) then
							txts[index] = {' '..math.ceil(dir:length()/100)..'m',cl.White}
                        end
					else
						self.showTarget = false
						prog = 0
                    end
				end
			end
			pPos = pPos:with_y(pPos.y-size*2)
		elseif category == 1 then -- Drill
			local tGUI = unit and unit:timer_gui()
			local dGUI = unit and unit:digital_gui()
			local name
			local leftT
			if not alive(unit) then
				self.dead = true
			elseif tGUI then -- TimerGui or SecurityLockGui
				local t_left = tGUI._time_left or tGUI._current_timer
				if not t_left then
					return
				end
				if t_left <= 0 then
					self.dead = true
				end
				if unit then
					name = unit:interaction() and unit:interaction().tweak_data
					name = name and name:gsub('_jammed',''):gsub('_upgrade','') or 'process'
					-- Adds '+' if the drill will auto-restart
					name = self:get_name(name) .. ((unit:base() and (unit:base()._autorepair or unit:base()._autorepair_client)) and "+" or "")
				end
				leftT = t_left
				prog = 1-t_left/tGUI._timer
				local stuck = tGUI._jammed or not tGUI._powered
				if pDist < 10000 or verbose then
					txts[1] = {_.s(name..':',self.owner:_time(t_left)..(stuck and '!' or ''),'/',self.MaxTime),stuck and cl.Red or cl.White}
				else
					txts[1] = {_.s(self.owner:_time(t_left))..(stuck and '!' or ''),stuck and cl.Red or cl.White}
				end
			elseif dGUI then -- DigitalGui
				if not (dGUI._ws and dGUI._ws:visible()) or (dGUI._floored_last_timer <= 0) or (dGUI.is_visible and not dGUI:is_visible()) then
					return self:destroy(1)
				else
					self:renew()
				end
				name = self:get_name('digitalgui', 'Timelock')
				leftT = dGUI._timer
				prog = 1-dGUI._timer/math.max(self.MaxTime,1)
				if pDist < 10000 or verbose then
					txts[1] = {_.s(name..':',self.owner:_time(dGUI._timer),'/',self._MaxTime),cl.White}
				else
					txts[1] = {_.s(self.owner:_time(dGUI._timer)),cl.White}
				end
			end
			if not self._name then
				self._name = name
				self._host = self:_getHost()
			end
			if self.isDrill and not self._almost and leftT and leftT <= 10 then
				self._almost = true
				me:Chat('drillAlmostDone',_.s(self:_getName(),PocoLocale._drillAlmost))
			end
		elseif category == 2 then -- Deadsimple text
			local name = self.tag and self.tag.text
			if name and (pDist < 1e6/dir:length() or verbose) then
				txts[1] = {name,cl.White}
			end
			pPos = pPos:with_y(pPos.y-size)
			self.bg:set_visible(false)
			prog = 0
		end
		if not floatO.blurBackground then
			self.bg:set_visible(false)
		end
		if prog > 0 then
			self.pie:set_current(prog)
			self.pieBg:set_visible(true)
			self.lbl:set_x(2*m+size)
			self:__shadow(2*m+size)
		else
			self.pie:set_visible(false)
			self.pieBg:set_visible(false)
			if #txts == 0 then
				self.bg:set_visible(false)
			end
			self.lbl:set_x(m)
			self:__shadow(m)
		end
		if self._txts ~= self.owner:_lbl(nil,txts) then
			self._txts = self.owner:_lbl(self.lbl,txts)
			self:__shadow()
		end
		local __,__,w,h = self.lbl:text_rect()
		h = math.max(h,size)
		self.pnl:set_size(m*2+(w>0 and w+m+1 or 0)+(prog>0 and size or 0),h+2*m)
        self.bg:set_size(self.pnl:size())
		self.pnl:set_center( pPos.x,pPos.y)
		if isADS then
			d = math.clamp((pDist-1000)/2000,0.4,1)
		else
			d = 1
		end
		d = math.min(d,floatO.opacity/100)
		if not (unit and unit:contour() and #(unit:contour()._contour_list or {}) > 0) then
			d = math.min(d,self.owner:_visibility(pos))
		end
		if out then
			d = math.min(d,0.5)
		end
		if not self.dying then
			self.pnl:set_alpha(d)
			self.lastD = d -- d is for starting alpha
		end
	end
end
function TFloat:renew(data)
	if data then
		self.tag = data.tag
		if type(data.temp)=='number' then
			self.temp = data.temp
			self.lastT = math.max(self.lastT,data.temp)
		end
	end
	if self.temp then
		self.lastT = math.max(self.lastT,now())
	end
	self.dead = false
end
function TFloat:destroy(skipAnim)
	if self.category == 1 and self.isDrill and not self._done and not me._endGameT then
		local r,err = pcall(function()
			self._done = true
			me:Chat('drillDone',_.s(self:_getName(),PocoLocale._drillDone))
		end)
		if not r then me:err(err) end
	end

	local pnl = self.pnl
	if alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate(callback(self, TBuff, '_fade'), callback(self, self, 'destroy', true), 0.2)
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.floats[self.key] = nil
		end
	end
end
local TMinionFloat = class(TFloat)
PocoHud3Class.TMinionFloat = TMinionFloat
function TMinionFloat:renew(data)
	self.dead = false
end
function TMinionFloat:draw(t)
	if not alive(self.unit) and not self.dead then
		self.dead = true
	end
	if self.dead and not self.dying then
		self:destroy()
		return
	end
	if not alive(self.pnl) then
		return
	end
	local verbose = self.owner.verbose
	local onScr = floatO.keepOnScreen
	local size = floatO.size
	local m = floatO.margin
	local isADS = self.owner.ADS
	local camPos = self.owner.camPos
	local unit = self.unit
	if not alive(unit) then return end
	local dx,dy,d,pDist,ww,hh= 0,0,1,0,self.owner.ww,self.owner.hh
	local pos = self.owner:_pos(unit,true)
	local nl_dir = pos - camPos
	local dir = pos - camPos
	mvector3.normalize(nl_dir)
	local dot = mvector3.dot(self.owner.nl_cam_forward, nl_dir)
	local pPos = self.owner:_v2p(pos)
	local out = false
	if onScr then
		local _sm = {floatO.keepOnScreenMarginX, floatO.keepOnScreenMarginY}
		local sm = {x = _sm[1]/100, y = _sm[2]/100}
		local xm = {x = 1-sm.x, y = 1-sm.y}
		if dot < 0
			or pPos.x < sm.x*ww or pPos.y < sm.y*hh
			or pPos.x > xm.x*ww or pPos.y > xm.y*hh then
			local abs = math.abs
			local rr = (hh*(0.5-sm.y))/(ww*(0.5-sm.x))
			local cV = Vector3(ww/2,hh/2,0)
			local dV = pPos:with_z(0) - cV
			local mul = 1
			mvector3.normalize(dV)
			if abs(dV.x * rr) > abs(dV.y) then -- x
				mul = ww*(0.5-sm.x)/dV.x
			else -- y
				mul = hh*(0.5-sm.y)/dV.y
			end
			out = true
			pPos = cV + dV*abs(mul)
		end
	end
	dx = pPos.x - ww/2
	dy = pPos.y - hh/2
	pDist = dx*dx+dy*dy
	self.pnl:set_visible((onScr and out) or dot > 0)
	if dot > 0 or onScr then
		local prog, txts = 0, {}
		local charDmg = unit:character_damage()
		local cHealth = charDmg and charDmg._health and charDmg._health*10 or 0
		local fHealth = cHealth > 0 and charDmg and (charDmg._HEALTH_INIT and charDmg._HEALTH_INIT*10 or charDmg._health_max and charDmg._health_max*10) or 1
		prog = cHealth / fHealth
		local color = math.lerp(cl.Red:with_alpha(0.8), cl.Yellow, prog)
		if self.tag and self.tag.minion then
			color = self.owner:_color(self.tag.minion)
		end
		--local distance = unit and mvector3.distance( unit:position(), camPos ) or 0
		local index = 1
		if pDist > 100000 then
			prog = 0
		elseif cHealth == 0 then
			if floatO.showKillConfirm then
				txts[index] = {Icon.Skull,color}
				index = index + 1
			else
				self.dead = true
				return
			end
		elseif floatO.showTargetsConvert then
			txts[index] = {_.f(cHealth)..'/'.._.f(fHealth),color}
			index = index + 1
			if floatO.showNPCDistance == 2 or (verbose and floatO.showNPCDistance == 1) then
				txts[index] = {' '..math.ceil(dir:length()/100)..'m',cl.White}
			end
		else
			prog = 0
		end
		pPos = pPos:with_y(pPos.y-size*2)
		if not floatO.blurBackground then
			self.bg:set_visible(false)
		end
		if prog > 0 then
			self.pie:set_current(prog)
			self.pieBg:set_visible(true)
			self.lbl:set_x(2*m+size)
			self:__shadow(2*m+size)
		else
			self.pie:set_visible(false)
			self.pieBg:set_visible(false)
			if #txts == 0 then
				self.bg:set_visible(false)
			end
			self.lbl:set_x(m)
			self:__shadow(m)
		end
		if self._txts ~= self.owner:_lbl(nil,txts) then
			self._txts = self.owner:_lbl(self.lbl,txts)
			self:__shadow()
		end
		local __,__,w,h = self.lbl:text_rect()
		h = math.max(h,size)
		self.pnl:set_size(m*2+(w>0 and w+m+1 or 0)+(prog>0 and size or 0),h+2*m)
        self.bg:set_size(self.pnl:size())
		self.pnl:set_center( pPos.x,pPos.y)
		if isADS then
			d = math.clamp((pDist-1000)/2000,0.4,1)
		else
			d = 1
		end
		d = math.min(d,floatO.opacity/100)
		if not (unit and unit:contour() and #(unit:contour()._contour_list or {}) > 0) then
			d = math.min(d,self.owner:_visibility(pos))
		end
		if out then
			d = math.min(d,0.5)
		end
		if not self.dying then
			self.pnl:set_alpha(d)
			self.lastD = d -- d is for starting alpha
		end
	end
end
local THitDirection = class()
PocoHud3Class.THitDirection = THitDirection
function THitDirection:init(owner, data)
	self.owner = owner
	self.ppnl = owner.pnl.buff
	self.data = data
	local pnl = self.ppnl:panel{x = 0,y=0, w=200,h=200}
	local rate = 1 - (data.rate or 1)
	local color = data.dodge and hitO.dodgeColor or data.shield and math.lerp(hitO.shieldColor, hitO.shieldColorDepleted, rate) or math.lerp(hitO.healthColor, hitO.healthColorDepleted, rate)

	self.pnl = pnl
	local bmp = pnl:bitmap{
		name = 'hit', rotation = 360, visible = true,
		texture = 'guis/textures/pd2/hitdirection',
		color = color,
		blend_mode='add', alpha = 1, halign = 'right'
	}
	self.bmp = bmp
	bmp:set_center(100,100)
	if hitO.number and not data.dodge then
		local nSize = hitO.numberSize
		local font = hitO.numberDefaultFont and FONT or ALTFONT
		local lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = tostring(data.dmg * 10),
			color = color,
			align = 'center',
			layer = 1
		}
		lbl:set_center(100,100)
		self.lbl = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = text,
			color = cl.Black:with_alpha(0.2),
			align = 'center',
			layer = 1
		}
		lbl:set_center(101,101)
		self.lbl1 = lbl
		lbl = pnl:text{
			x = 1,y = 1,font = font, font_size = nSize,
			w = nSize*3, h = nSize,
			text = text,
			color = cl.Black:with_alpha(0.2),
			align = 'center',
			layer = 1
		}
		lbl:set_center(99,101)
		self.lbl2 = lbl
	end
	local du = hitO.duration
	if du == 0 then
		du = self.data.time or 2
	end
	pnl:animate(callback(self, self, 'draw'), callback(self, self, 'destroy'), du)
end
function THitDirection:draw(pnl, done_cb, seconds)
	local ww,hh = self.owner.ww, self.owner.hh
	pnl:set_visible(true)
	self.bmp:set_alpha(1)
	local t = seconds
	while alive(pnl) and t > 0 do
		if self.owner.dead then
			break
		end
		local dt = coroutine.yield()
		t = t - dt
		local p = t / seconds
		local p_pow = math.pow(p, 0.5)
		self.bmp:set_alpha(p_pow * hitO.opacity/100)

		local target_vec = self.data.mobPos - self.owner.camPos
		local fwd = self.owner.nl_cam_forward
		local angle = target_vec:to_polar_with_reference(fwd, math.UP).spin
		local r = hitO.sizeStart + (1 - p_pow) * (hitO.sizeEnd-hitO.sizeStart)

		self.bmp:set_rotation(-(angle+90))
		if self.lbl then
			self.lbl:set_rotation(-(angle))
			self.lbl1:set_rotation(-(angle))
			self.lbl2:set_rotation(-(angle))
		end
		pnl:set_center(ww/2-math.sin(angle)*r,hh/2-math.cos(angle)*r)
	end
	pnl:set_visible(false)
	if done_cb then done_cb(pnl) end
end
function THitDirection:destroy()
	self.ppnl:remove(self.pnl)
	self = nil
end
--- Location start ---
local PocoLocation = {
	rooms = {},
	r = Draw:pen('no_z', cl.Red:with_alpha(0.5)),
	g = Draw:pen('no_z', cl.Green:with_alpha(0.5)),
	b = Draw:pen('no_z', cl.Blue:with_alpha(0.5)),
}
PocoHud3Class.PocoLocation = PocoLocation
function PocoLocation:new()
	Poco.room = self
	self:load()
end

function PocoLocation:newRoom(name)
	local currentRoom = {}
	self.currentName = name
	self.currentRoom = currentRoom
	_.c('NewRoom',name)
end

function PocoLocation:endRoom()
	local lvl = managers.job:current_level_id() or ''
	local currentRooms = self.rooms[lvl] or {}
	if type(currentRooms) == 'string' then
		currentRooms = self.rooms[currentRooms] or {}
	end
	self.rooms[lvl] = currentRooms
	self.currentRooms = currentRooms
	local parsedRoom -- {x,y,z,x,y,z}
	if self.currentRoom then
		local mi,ma = {}, {}
		for i,point in pairs(self.currentRoom) do
			mi.x = mi.x and math.min(point.x,mi.x) or point.x
			mi.y = mi.y and math.min(point.y,mi.y) or point.y
			mi.z = mi.z and math.min(point.z,mi.z) or point.z
			ma.x = ma.x and math.max(point.x,ma.x) or point.x
			ma.y = ma.y and math.max(point.y,ma.y) or point.y
			ma.z = ma.z and math.max(point.z,ma.z) or point.z
		end
		parsedRoom = {mi,ma}
	end

	if parsedRoom then
		currentRooms[self.currentName] = parsedRoom
		_.c('EndRoom',self.currentName)
	end
end

function PocoLocation:addPoint(pos)
	if self.currentRoom then
		table.insert(self.currentRoom,pos)
		_.c('AddPoint',tostring(pos))
	else
		_.c('AddPoint','NoRoom')
	end
end

function PocoLocation:_drawBox(pen,a,b)
	if not (pen and a and a.x) then
		return
	end
	pen:sphere(Vector3(a.x,a.y,a.z),3)
	pen:sphere(Vector3(b.x,b.y,b.z),3)

	pen:line(Vector3(a.x,a.y,a.z),Vector3(a.x,b.y,a.z))
	pen:line(Vector3(a.x,a.y,a.z),Vector3(b.x,a.y,a.z))
	pen:line(Vector3(a.x,b.y,a.z),Vector3(b.x,b.y,a.z))
	pen:line(Vector3(b.x,a.y,a.z),Vector3(b.x,b.y,a.z))

	pen:line(Vector3(a.x,a.y,b.z),Vector3(a.x,b.y,b.z))
	pen:line(Vector3(a.x,a.y,b.z),Vector3(b.x,a.y,b.z))
	pen:line(Vector3(a.x,b.y,b.z),Vector3(b.x,b.y,b.z))
	pen:line(Vector3(b.x,a.y,b.z),Vector3(b.x,b.y,b.z))

	pen:line(Vector3(a.x,a.y,a.z),Vector3(a.x,a.y,b.z))
	pen:line(Vector3(a.x,b.y,a.z),Vector3(a.x,b.y,b.z))
	pen:line(Vector3(b.x,a.y,a.z),Vector3(b.x,a.y,b.z))
	pen:line(Vector3(b.x,b.y,a.z),Vector3(b.x,b.y,b.z))

end

function PocoLocation:get(pos,translate)
	local found, foundVol
	if pos and pos.x then
		local x,y,z = pos.x,pos.y,pos.z
		for name,room in pairs(self.currentRooms or {}) do
			local mi,ma = room[1],room[2]
			if (mi.x <= x and ma.x >= x) and
				(mi.y <= y and ma.y >= y) and
				(mi.z <= z and ma.z >= z) then
				local vol = math.abs((ma.x-mi.x)*(ma.y-mi.y)*(ma.z-mi.z))
				if not found or foundVol > vol then
					found = name
					foundVol = vol
				end
			end
		end
	end
	if found and translate then
		return found -- TODO
	else
		return found,foundVol
	end
end

function PocoLocation:update(t, dt)
	local ff = Poco.ff or _.g('setup:freeflight()')
	if ff then
		Poco.ff = ff
		ff:update(t, dt)
	end
	if not Poco.roomOn then return end

	local fCam = ff and ff:enabled() and ff._camera_object
	--local pos = fCam and fCam:position() or _.g('managers.player:player_unit():position()')
--	_.d('Room',self:get(pos) or 'None',#(self.currentRooms or {}))
	local ray = fCam and World:raycast("ray", fCam:position(), fCam:position() + fCam:rotation():y() * 10000) or _.r()
	if ray and ray.position then
		local g = 20
		local pos = Vector3(math.floor(ray.position.x/g+0.5)*g,math.floor(ray.position.y/g+0.5)*g,math.floor(ray.position.z/g+0.5)*g)
		if pos ~= self.pos then
			self.pos = pos
			self.b:sphere(pos,10)
		else
			self.r:sphere(pos,10)
		end
		if t - (self._lastIn or 0) > 0.5 then
			if shift() then
				if ctrl() then
					self:endRoom()
					self._lastIn = t
				else
					self:addPoint(pos)
					self._lastIn = t
				end
			end
		end
	end
	if self.currentRoom then
		local mi,ma = {}, {}
		for i,point in pairs(self.currentRoom) do
			mi.x = mi.x and math.min(point.x,mi.x) or point.x
			mi.y = mi.y and math.min(point.y,mi.y) or point.y
			mi.z = mi.z and math.min(point.z,mi.z) or point.z
			ma.x = ma.x and math.max(point.x,ma.x) or point.x
			ma.y = ma.y and math.max(point.y,ma.y) or point.y
			ma.z = ma.z and math.max(point.z,ma.z) or point.z
		end
		if mi.x then
			self:_drawBox(self.g,mi,ma)
		end
	end
	for k,room in pairs(self.currentRooms or {}) do
		local mi,ma = room[1],room[2]
		if mi.x then
			self:_drawBox(self.b,mi,ma)
		end

	end
end
--- End of Location1
--[[
1. _.g('managers.player:player_unit():movement():nav_tracker():nav_segment()')
2. managers.navigation:get_nav_seg_metadata(_1_)
3.
]]

--- End of Location2

function PocoLocation:load()
	local lang = PocoHud3Class.O('root','languageRooms')
	lang = lang ~= 'EN' and lang or ''
	local f, _ = io.open(LocationJSONFilename..lang..LocationJSONFileExt, 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = JSON:decode(t)
		if type(o) == 'table' then
			self.rooms = o
			self:endRoom()
			result = true
		end
		f:close()
	else
		f, _ = io.open(LocationJSONFilename..LocationJSONFileExt, 'r')
		if f then
			local t = f:read('*all')
			local o = JSON:decode(t)
			if type(o) == 'table' then
				self.rooms = o
				self:endRoom()
				result = true
			end
			f:close()
		end
	end
	return result
end

function PocoLocation:save()
	local f = io.open(LocationJSONFilename, 'w')
	if f then
		f:write(JSON:encode_pretty(self.rooms))
		f:close()
	end
end

--- GUI start ---
local Layers = {
	Blur = 1001,
	Bg = 1002,
	TabHeader = 1003
}
local PocoUIElem = class()
local PocoUIHintLabel -- forward-declared
function PocoUIElem:init(parent,config)
	config = _.m({
		w = 400,h = 20,
	}, config)

	self.parent = parent
	self.config = config or {}
	self.ppnl = config.pnl or parent.pnl
	self.pnl = self.ppnl:panel({ name = config.name, x=config.x, y=config.y, w = config.w, h = config.h})
	self.status = 0

	if self.config[PocoEvent.Click] then
		self:_bind(PocoEvent.Out, function(self)
			self._pressed = nil
		end):_bind(PocoEvent.Pressed, function(self,x,y)
			self._pressed = true
		end):_bind(PocoEvent.Released, function(self,x,y)
			if self._pressed then
				self._pressed = nil
				return self:fire(PocoEvent.Click,x,y)
			end
		end)
	end

	if config.hintText then
		PocoUIHintLabel.makeHintPanel(self)
	end
end

function PocoUIElem:postInit()
	for event,eventVal in pairs(PocoEvent) do
		if self.config[eventVal] then
			self.parent:addHotZone(eventVal,self)
		end
	end
	self._bind = function()
		_('Warning:PocoUIElem._bind was called too late')
	end
end

function PocoUIElem:set_y(y)
	self.pnl:set_y(y)
end

function PocoUIElem:set_center_x(x)
	self.pnl:set_center_x(x)
end

function PocoUIElem:set_x(x)
	self.pnl:set_x(x)
end

function PocoUIElem:inside(x,y)
	return alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:_bind(eventVal,cbk)
	if not self.config[eventVal] then
		self.config[eventVal] = cbk
	else
		local _old = self.config[eventVal]
		self.config[eventVal] = function(...)
			local result = _old(...)
			if not result then
				result = cbk(...)
			else
			end
			return result
		end
	end
	return self
end

function PocoUIElem:sound(sound)
	managers.menu_component:post_event(sound)
end

function PocoUIElem:hide()
	self._hide = true
	if alive(self.pnl) then
		self.pnl:set_visible(false)
	end
end

function PocoUIElem:setLabel(text)
	if alive(self.lbl) then
		self.lbl:set_text(text)
	end
end

function PocoUIElem:disable()
	self._disabled = true
end

function PocoUIElem:isHot(event,x,y)
	return not self._disabled and not self._hide and alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:fire(event,x,y)
	if self.parent.dead or not alive(self.pnl) then return end
	local result = {self.config[event](self,x,y)}
	local sound = {
		onPressed = 'prompt_enter'
	}
	if self.config[event] then
		if self.result == false then
			self:sound('menu_error')
			self.result = nil
			return true
		elseif self.mute then
			self.mute = nil
			return true
		end
		if sound[event] then
			self:sound(sound[event])
		end
		return unpack(result)
	end
end

local PocoRoseButton = class(PocoUIElem)
PocoHud3Class.PocoRoseButton = PocoRoseButton
function PocoRoseButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self.pnl:set_center(config.x,config.y)

	local spnl
	local clShadow = cl.Black:with_alpha(0.8)
	local __, lbl = _.l({
		pnl = self.pnl,x=-1, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl1 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=1, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl2 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=1, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl3 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=-1, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = clShadow,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)
	self.lbl4 = lbl
	__, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center', layer = 1
	},config.text,config.autoSize)
	self.lbl = lbl
	self.mul = 1
	self.pnl:animate(function(p)
		while alive(p) do
			local mul = math.ceil(100*self.mul)/100
			local t = config.fontSize*mul
			local r = self._r or 0
			r = r + (t-r)/10
			if p:visible() and math.abs(r - (self._r or 0)) > 0.1 then
				self._r = r
				self.lbl1:set_font_size(r)
				self.lbl2:set_font_size(r)
				self.lbl3:set_font_size(r)
				self.lbl4:set_font_size(r)
				self.lbl:set_font_size(r)
				self.lbl:set_alpha(r/config.fontSize/1.4)
			end
			coroutine.yield()
		end
	end)


	self:_bind(PocoEvent.In, function(self,x,y)
		if alive(self.pnl) then
			spnl = self.pnl:panel{}
			BoxGuiObject:new(spnl, {sides = {1,1,1,1}})
			spnl:rect{color=cl.Black,alpha=0.2,layer=-1}
			me._say = config.value
			self:sound('slider_grab')
			self.mul = 1.6
		end
	end):_bind(PocoEvent.Out, function(self,x,y)
		if alive(self.pnl) then
			if spnl then
				self.pnl:remove(spnl)
				spnl = nil
			end
			self.mul = 1
			me._say = nil
		end
	end)
	if not inherited then
		self:postInit(self)
	end
end

PocoUIHintLabel = class(PocoUIElem) -- Forward-declared as local
PocoHud3Class.PocoUIHintLabel = PocoUIHintLabel
function PocoUIHintLabel:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text or 'Err: No text given',config.autoSize)
	self.lbl = lbl

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIHintLabel:makeHintPanel()
	local config = self.config
	local hintPnl

	local _reposition = function(x,y)
		if hintPnl then
			x = math.max(0,math.min(self.ppnl:w()-hintPnl:w(),x+10))
			y = math.max(self.ppnl:world_y(),math.min((me.hh or 0)-20-hintPnl:h(),y))
			hintPnl:set_world_position(x,y+20)
		end
	end
	local _buildOne = function(x,y)
		hintPnl = self.ppnl:panel{
			x = 0, y = 0, w = 800, h = 200
		}
		local __, hintLbl = _.l({
			pnl = hintPnl,x=5, y=5, font = config.hintFont or FONT, font_size = config.hintFontSize or 18, color = config.hintFontColor or cl.White,
			align = config.align, vertical = config.vAlign, layer = 2, rotation = 360
		},config.hintText or '',true)
		hintPnl:set_size(hintLbl:size())
		hintPnl:grow(10,10)
		hintPnl:rect{ color = cl.Black:with_alpha(0.7), layer = 1, rotation = 360}
		_reposition(x,y)
	end
	self:_bind(PocoEvent.In, function(self,x,y)
		if not hintPnl then
			_buildOne(x,y)
		end
	end):_bind(PocoEvent.Out, function(self,x,y)
		if hintPnl then
			if alive(hintPnl) then
				self.ppnl:remove(hintPnl)
			end
			hintPnl = nil
		end
	end):_bind(PocoEvent.Move, function(self,x,y)
		_reposition(x,y)
	end)

end

local PocoUIButton = class(PocoUIElem)
PocoHud3Class.PocoUIButton = PocoUIButton
function PocoUIButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	local spnl = self.pnl:panel{}
	BoxGuiObject:new(spnl, {sides = {1,1,1,1}})
	spnl:rect{color=cl.Black,alpha=0.5,layer=-1}
	spnl:set_visible(false)
	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font or FONT, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)

	self:_bind(PocoEvent.In, function(self,x,y)
		spnl:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		spnl:set_visible(false)
	end)

	self.lbl = lbl
	if not inherited then
		self:postInit(self)
	end
end

local PocoUIValue = class(PocoUIElem)
PocoHud3Class.PocoUIValue = PocoUIValue
function PocoUIValue:init(parent,config,inherited)
	PocoUIElem.init(self,parent,config,true)

	local bg = self.pnl:rect{color = cl.White:with_alpha(0.1),layer=-1}
	bg:set_visible(false)
	self:_bind(PocoEvent.In, function(self,x,y)
		bg:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		bg:set_visible(false)
	end)

	local __, lbl = _.l({
			pnl = self.pnl,x=5, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.lbl = lbl
	self.lbl:set_center_y(config.h/2)
	local __, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = FONT, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.valLbl = lbl
	self.valLbl:set_center_y(config.h/2)

	if not config.noArrow then
		self.arrowLeft = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				0,
				5,
				15,
				20
			},
			color = cl.White,
			x = 0,
			y = 0,
			blend_mode = blendMode
		})
		self.arrowRight = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				10,
				5,
				20,
				20
			},
			color = cl.White,
			x = 20,
			y = 1,
			blend_mode = blendMode,
			--rotation = 180,
		})
		self.arrowRight:set_right(config.w)
		self.arrowLeft:set_left(config.w/2)

		self.arrowLeft:set_center_y(config.h/2)
		self.arrowRight:set_center_y(config.h/2)

		local shift = function()
			return Poco._kbd:down(42) or Poco._kbd:down(54)
		end

		self:_bind(PocoEvent.Pressed,function(self,x,y)
			if self.arrowRight:inside(x,y) then
				self:next()
			elseif self.arrowLeft:inside(x,y) then
				self:prev()
			else
				self.mute = true
			end
		end):_bind(PocoEvent.Move,function(self,x,y)
			if self.arrowRight:inside(x,y) or self.arrowLeft:inside(x,y) then
				self.cursor = 'link'
			elseif shift() then
				self.cursor = 'grab'
			else
				self.cursor = 'arrow'
			end
		end):_bind(PocoEvent.WheelUp,function()
			if shift() then
				self:sound('slider_increase')
				return true, self:next()
			end
		end):_bind(PocoEvent.WheelDown,function(...)
			if shift() then
				self:sound('slider_decrease')
				return true, self:prev()
			end
		end)
	end


	-- Always inherited though
end

function PocoUIValue:next()
	self.result = false
end

function PocoUIValue:prev()
	self.result = false
end

function PocoUIValue:isValid(val)
	return true
end

function PocoUIValue:isDefault(val)
	if val == nil then
		val = self:val()
	end
	return O:isDefault(self.config.category,self.config.name,val)
end

function PocoUIValue:_markDefault(set)
	if self.config.category then
		local isChanged = O:isChanged(self.config.category,self.config.name,set)
		_.l(self.lbl,{self.config.text,self:isDefault(set) and cl.White or (isChanged and cl.LightSkyBlue or cl.DarkKhaki)})
	end
end

function PocoUIValue:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			_.l(self.valLbl,set,true)
			self.valLbl:set_center_x(self.config.valX or 12*self.config.w/16)
			self.valLbl:set_x(math.floor(self.valLbl:x()))
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

local PocoUIBoolean = class(PocoUIValue)
PocoHud3Class.PocoUIBoolean = PocoUIBoolean
function PocoUIBoolean:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self.tick = self.pnl:bitmap({
		name = 'tick',
		texture = 'guis/textures/menu_tickbox',
		texture_rect = {
			0,
			0,
			24,
			24
		},
		w = 24,
		h = 24,
		color = cl.White
	})
	self.tick:set_center_y(config.h/2)

	self.lbl:set_x(self.lbl:x()+20)
	self.valLbl:set_visible(false)
	self:val(config.value or false)
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self:val(not self:val())
		self:sound('box_'..(self:val() and 'tick' or 'untick'))
		self.mute = true
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIBoolean:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			if self.tick then
				if not set then
					self.tick:set_texture_rect(0,0,24,24)
				else
					self.tick:set_texture_rect(24,0,24,24)
				end
			end
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

local PocoUINumValue = class(PocoUIValue)
PocoHud3Class.PocoUINumValue = PocoUINumValue
function PocoUINumValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(tonumber(config.value) or 0)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUINumValue:next(predict)
	local tVal = self:val()+(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:prev(predict)
	local tVal = self:val()-(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:isValid(val,silent)
	local result = (type(val) == 'number') and (val <= (self.config.max or 100)) and (val >= (self.config.min or 0))
	if not silent then
		self.result = result
	end
	return result
end

function PocoUINumValue:val(set)
	local result = PocoUIValue.val(self,set)
	if set and self.config.vanity then
		_.l(self.valLbl,self.config.vanity[self:val()+1] or self:val(),true)
		self.valLbl:set_center_x(3*self.config.w/4)
		self.valLbl:set_x(math.floor(self.valLbl:x()))
	end
	if set and self.arrowLeft then
		self.arrowLeft:set_alpha(self:prev(1) and 1 or 0.1)
		self.arrowRight:set_alpha(self:next(1) and 1 or 0.1)
	end
	return result
end

local PocoUIChooseValue = class(PocoUIValue)
PocoHud3Class.PocoUIChooseValue = PocoUIChooseValue
function PocoUIChooseValue:init(parent,config,inherited)
	PocoUIValue.init(self,parent,config,true)
	-- abstract
end

function PocoUIChooseValue:selection()
	return self.config.selection or {}
end

function PocoUIChooseValue:go(delta)
	local val = self:val()
	local sel = self:selection()
	local keys = table.map_keys(sel)
	local ind = table.index_of(keys,val)
	self:val(keys[ind+delta] or delta>0 and keys[1] or keys[#keys] )
end

function PocoUIChooseValue:next()
	self:go(1)
end

function PocoUIChooseValue:prev()
	self:go(-1)
end

function PocoUIChooseValue:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()]
	end
end

local PocoUIBooleanValue = class(PocoUIChooseValue)
PocoHud3Class.PocoUIBooleanValue = PocoUIBooleanValue

function PocoUIBooleanValue:init(parent,config,inherited)
	PocoUIChooseValue.init(self,parent,config,true)
	self:val(isNil(config.value) and 'YES' or config.value)
	if not inherited then
		self:postInit(self)
	end
end

function PocoUIBooleanValue:selection()
	return {YES = true, NO = false}
end

local PocoUIReversedBooleanValue = class(PocoUIBooleanValue)
PocoHud3Class.PocoUIReversedBooleanValue = PocoUIReversedBooleanValue

function PocoUIReversedBooleanValue:selection()
	return {YES=true,NO=false}
end

local PocoUIColorValue = class(PocoUIChooseValue)
PocoHud3Class.PocoUIColorValue = PocoUIColorValue
function PocoUIColorValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(config.value or 'White')

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIColorValue:selection()
	return cl
end

function PocoUIColorValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		local color = cl[val] or cl.White
		_.l(self.valLbl,{val,color})
	end
	return val
end

local PocoUIKeyValue = class(PocoUIValue)
PocoHud3Class.PocoUIKeyValue = PocoUIKeyValue
function PocoUIKeyValue:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self:val(config.value or '')
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self.mute = true
		if self._waiting then
			self:sound('menu_error')
			self:cancel()
		else
			self:sound('prompt_enter')
			self:setup()
		end
	end):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:sound('menu_error')
			self:cancel()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIKeyValue:setup()
	self._waiting = true
	me._focused = self
	me._ws:connect_keyboard(Input:keyboard())
	local onKeyPress = function(o, key)
		me._stringFocused = now()
		local keyName = Input:keyboard():button_name_str(key)
		--if key == Idstring('backspace') then
		--	self:sound('menu_error')
		--	self:val('')
		--	self:cancel()
		--	return
		--end
		local ignore = ('enter,space,esc,num abnt c1,num abnt c2,@,ax,convert,kana,kanji,no convert,oem 102,stop,unlabeled,yen,mouse 8,mouse 9'):split(',')
		for __,iKey in pairs(ignore) do
			if key == Idstring(iKey) then
				if iKey ~= 'esc' then
					managers.menu:show_key_binding_forbidden({KEY = keyName})
				end
				self:sound('menu_error')
				self:cancel()
				return
			end
		end
		Poco:ignoreBind()
		self:sound('menu_skill_investment')
		self:val(keyName)
		self:cancel()
	end
	_.l(self.valLbl,'_',true)
	self.valLbl:key_press(onKeyPress)
end

function PocoUIKeyValue:cancel()
	self._waiting = nil
	me._ws:disconnect_keyboard()
	me._focused = nil
	self.valLbl:key_press(nil)
	self:val(self:val())
end

function PocoUIKeyValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		if set == '' then
			set = {'NONE',cl.Silver}
		else
			set = set:upper()
		end
		_.l(self.valLbl,set,true)
	end
	return val
end

local PocoUIStringValue = class(PocoUIValue)
PocoHud3Class.PocoUIStringValue = PocoUIStringValue
function PocoUIStringValue:init(parent,config,inherited)
	config.noArrow = not config.selection
	self.super.init(self,parent,config,true)
	self:_initLayout()
	self:val(config.value or '')
	self.box = self.pnl:rect{color = cl.White:with_alpha(0.3), visible = false}
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		if self.arrowLeft and self.arrowLeft:inside(x,y) then
			return
		elseif self.arrowRight and self.arrowRight:inside(x,y) then
			return
		elseif not self._editing then
			self:startEdit()
			self:selectAll()
		else
			if now() - (self._lastClick or 0) < 0.3 then
				self:selectAll()
			elseif self.valLbl:inside(x,y) then
				self:_setCaret(x)
			else
				self:endEdit()
			end
		end
		self._lastClick = now()
	end):_bind(PocoEvent.WheelUp,self.next):_bind(PocoEvent.WheelDown,self.prev):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:sound('menu_error')
			self:endEdit()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIStringValue:selection()
	return self.config.selection or {}
end

function PocoUIStringValue:prev()
	PocoUIChooseValue.go(self,-1)
	self._lastClick = now()
end

function PocoUIStringValue:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()] or self:val()
	end
end

function PocoUIStringValue:next()
	PocoUIChooseValue.go(self,1)
	self._lastClick = now()
end

function PocoUIStringValue:_initLayout()
	if not self.config.valX and self.config.text:gsub(' ','') == '' then
		self.config.valX = self.config.w / 2
	end
end

function PocoUIStringValue:val(set)
	if set then
		set = utf8.sub(set,1,self.config.max or 15)
	end
	local result =  PocoUIValue.val(self,set)
	self:repaint()
	if set then
		local text = self:selection()[result]
		if text then
			_.l(self.valLbl,text,true)
			self.valLbl:set_center_x(self.config.valX or 12*self.config.w/16)
			self.valLbl:set_x(math.floor(self.valLbl:x()))
		end
	end
	return result
end

function PocoUIStringValue:startEdit()
	self._editing = true
	self.box:set_visible(true)
	me._ws:connect_keyboard(Input:keyboard())
	me._focused = self
	self.pnl:enter_text(callback(self, self, 'enter_text'))
	self.pnl:key_press(callback(self, self, 'key_press'))
	self.pnl:key_release(callback(self, self, 'key_release'))
	local l = utf8.len(self:val())
	self.valLbl:set_selection(l,l)
	self._rename_caret = self.pnl:rect({
		name = 'caret',
		layer = -1,
		x = 10,
		y = 10,
		w = 2,
		h = 2,
		color = cl.Red
	})
	self:repaint()
	self._rename_caret:animate(self.blink)
	self.beforeVal = self:val()
end

function PocoUIStringValue:selectAll()
	self:_select(0, utf8.len(self:val()))
	self._start = 0
	self._shift = nil
	self:repaint()
end

function PocoUIStringValue:_select(tS,tE)
	local s,e = self.valLbl:selection()
	local l = utf8.len(self:val())
	if tS and tE then
		s, e = math.max(0,tS),math.min(tE,l)
		if s == e then
			self._start = s
		end
		self.valLbl:set_selection(s,e)
	else
		return s,e
	end
end

function PocoUIStringValue:select(delta,shift)
	local s, e = self:_select()
	if shift then -- start Shift
		self._start = s
		self._shift = true
	elseif shift == false then
		self._shift = nil
	elseif self._shift then -- grow selection
		local ss = self._start
		if delta > 0 then
			if ss == s then
				self:_select(ss,e+delta)
			else
				self:_select(s+delta,ss)
			end
		elseif delta < 0 then
			if ss == e then
				self:_select(s+delta,ss)
			else
				self:_select(ss,e+delta)
			end
		end
	else -- simpleMove
		self:_select(s+delta,s+delta)
	end
end

function PocoUIStringValue:_setCaret(worldX)
	local lbl = self.valLbl
	local l = utf8.len(self:val())
	if l == 0 then
		self:select(0,0)
	end
	local c, x, y, w, h = -1
	repeat
		c = c + 1
		self:_select(c,c)
		x, y, w, h = self.valLbl:selection_rect()
	until x>=worldX or c > l
	self:_select(c-1,c-1)
	self:repaint()
end

function PocoUIStringValue:endEdit(cancel)
	self._editing = nil
	me._focused = nil
	self.box:set_visible(false)
	me._ws:disconnect_keyboard()
	self:_select(0,0)
	self.pnl:enter_text(nil)
	self.pnl:key_press(nil)
	self.pnl:key_release(nil)
	self.pnl:remove(self._rename_caret)
	self._rename_caret = nil
	if cancel then
		self:val(self.beforeVal)
	end
	self.beforeVal = nil
end

function PocoUIStringValue:repaint()
	me._stringFocused = now()
	if self.box then
		local x,y,w,h = self.valLbl:shape()
		x, y, w, h = x-5, y-5, w+10, math.max(h+10,self.config.h+10)
		self.box:set_shape(x,y,w,h)
	end
	if self._rename_caret then
		local x, y, w, h = self.valLbl:selection_rect()
		if x == 0 then
			x,y = self.valLbl:world_position()
		end
		w = math.max(w,3)
		h = math.max(h,20)
		self._rename_caret:set_world_shape(x,y,w,h)
	end
end

function PocoUIStringValue.blink(o)
	while alive(o) do
		o:set_color(cl.White:with_alpha(0.1))
		wait(0.2)
		o:set_color(cl.White:with_alpha(0.5))
		wait(0.3)
	end
end

function PocoUIStringValue:enter_text(o, s)
	if self._editing then
		self.valLbl:replace_text(s)
		self:val(self.valLbl:text())
	end
end

function PocoUIStringValue:key_release(o, k)
	if k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,false)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = false
	end
end

function PocoUIStringValue:key_press(o, k)
	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:disable_input(0.2)
	end
	local lbl = self.valLbl
	local n = utf8.len(lbl:text())
	local s, e = lbl:selection()
	if k == Idstring('delete') then
		if s == e and s > 0 then
			lbl:set_selection(s, e+1)
		end
		self:enter_text('')
	elseif k == Idstring('backspace') then
		if s == e and s > 0 then
			lbl:set_selection(s - 1, e)
		end
		self:enter_text('')
	elseif k == Idstring('left') then
		self:select(-1)
		--[[
		if s < e then
			lbl:set_selection(s, s)
		elseif s > 0 then
			lbl:set_selection(s - 1, s - 1)
		end]]

	elseif k == Idstring('right') then
		self:select(1)
		--[[
		if s < e then
			lbl:set_selection(e, e)
		elseif s < n then
			lbl:set_selection(s + 1, s + 1)
		end]]
	elseif k == Idstring('end') then
		lbl:set_selection(n, n)
	elseif k == Idstring('home') then
		lbl:set_selection(0, 0)
	elseif k == Idstring('enter') or k == Idstring('tab') then
		self:endEdit()
	elseif k == Idstring('esc') then
		self:endEdit(true)
		return
	elseif k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,true)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = true
	elseif self._key_ctrl_pressed == true then
		return
	end
	self:repaint()
end

local PocoScrollBox = class(PocoUIElem)
PocoHud3Class.PocoScrollBox = PocoScrollBox
function PocoScrollBox:init(parent,config,inherited)
	self.parent = parent
	self.config = config
	self.wrapper = config.pnl:panel(config)
	self.pnl = self.wrapper:panel{ x=0, y=0, w =self.wrapper:w(), h = self.wrapper:h(), name = 'content'}
	local m,sW = 10,4
	local sH = self.wrapper:h()-(2*m)
	local _matchScroll = function()
		local pH,wH = self.pnl:h(), self.wrapper:h()
		self.sPnl:set_y(m-self.pnl:y()*wH/pH)
		self.sPnl:set_h(self.wrapper:h()/self.pnl:h() * sH - m)
	end
	self._matchScroll = _matchScroll
	self.sPnl = self.wrapper:panel{ x=self.wrapper:w()-sW-m/2, y=m, w =sW, h = sH, name = 'scroll', visible = false}
	BoxGuiObject:new(self.sPnl, { sides = {2,2,0,0} }):set_aligns('scale', 'scale')
	self.sPnl:stop()
	self.sPnl:animate(function(p)
		while alive(p) do
			if p:visible() then
				local a = math.max(0.05,0.3-now()+(self._t or 0))*4
				if a ~= self._a then
					p:set_alpha(a)
					self._a = a
				end
			end
			coroutine.yield()
		end
	end)

	self.pnl:stop()
	self.pnl:animate(function(panel)
		while alive(panel) do
			if panel:visible() then
				local tY,cY = math.floor(self.y or 0),math.floor(panel:y())
				local rY = math.floor(cY + ((tY-cY)/5))
				if tY~=rY then
					if math.abs(tY - rY)<5 then
						rY = tY
					end
					rY = math.floor(rY + 1)
					self._t = now()
					panel:set_y(rY)
					_matchScroll()
				end
			end
			coroutine.yield()
		end
	end)

	local scrollStep = 60
	self:_bind(PocoEvent.WheelUp,function(_self,x,y)
		if not shift() and self:canScroll(false,x,y) then
			return true, self:scroll(scrollStep)
		end
	end):_bind(PocoEvent.WheelDown,function(_self,x,y)
		if not shift() and self:canScroll(true,x,y) then
			return true, self:scroll(-scrollStep)
		end
	end)
	if not inherited then
		self:postInit(self)
	end
end

function PocoScrollBox:set_h(_h)
	self.pnl:set_h(math.max(self.wrapper:h(),_h or 0))
	if self.pnl:h() > self.wrapper:h() then
		self.sPnl:set_visible(true)
	else
		self.sPnl:set_visible(false)
		self:scroll(0,true)
	end
	self:_matchScroll()
end

function PocoScrollBox:isLarge()
	return self.pnl:h() > self.wrapper:h()
end

function PocoScrollBox:canScroll(down,x,y)
	local result = self:isLarge() and self.wrapper:inside(x,y) and self
	if (self._errCnt or 0) > 1 then
		local pos = self.y or 0
		if (pos == 0) ~= down then
			result = false
		end
	end
	return result
end

function PocoScrollBox:scroll(val,force)
	local tVal = force and 0 or (self.y or 0) + val
	local pVal = math.clamp(tVal,self.wrapper:h()-self.pnl:h()-20,0)
	if pVal ~= tVal then
		self._errCnt = 1+ (self._errCnt or 0)
	else
		self._errCnt = 0
		if not force then
			managers.menu:post_event(val>0 and 'slider_increase' or 'slider_decrease')
		end
	end
	self.y = pVal
end

local PocoTab = class()
PocoHud3Class.PocoTab = PocoTab
function PocoTab:init(parent,ppnl,tabName)
	self.parent = parent -- tabs
	self.ppnl = ppnl
	self.name = tabName
	self.hotZones = {}
	self.box = PocoScrollBox:new(self,{ pnl = ppnl, x=0, y=parent.config.th,w = ppnl:w(), h = ppnl:h()-parent.config.th, name = tabName})
	self.pnl = self.box.pnl

end

function PocoTab:insideTabHeader(x,y,noChildren)
	local result = self.bg and alive(self.bg) and self.bg:inside(x, y) and self
	if not result and not noChildren then
		if self._children then
			for name,child in pairs(self._children) do
				if child.currentTab and child.currentTab:insideTabHeader(x,y) then
					return child,false
				end
			end
		end
	end
	return result,true
end

function PocoTab:addHotZone(event,item)
	self.hotZones[event] = self.hotZones[event] or {}
	table.insert(self.hotZones[event],item)
end

function PocoTab:isHot(event, x, y, autoFire)
	if self.hotZones[event] and alive(self.pnl) and self.box.wrapper:inside(x,y) then
		for i,hotZone in pairs(self.hotZones[event]) do
			if hotZone:isHot(event, x,y) then
				if autoFire then
					local r = hotZone:fire(event, x, y)
					if r then
						return r
					end
				else
					return hotZone
				end
			end
		end
	end
	if self._children then
		for name,child in pairs(self._children) do
			local cResult = child.currentTab and child.currentTab:isHot(event,x,y,autoFire)
			if cResult then return cResult end
		end
	end
	return false
end

function PocoTab:scroll(val, force)
	return self.box:scroll(val,force)
--	return self.pnl:set_y(pVal)
end

function PocoTab:canScroll(down,x,y)
	return self.box:canScroll(down,x,y)
end

function PocoTab:set_h(h)
	self.box:set_h(h)
end

function PocoTab:children(child)
	if child then
		local children = self._children or {}
		children[#children+1] = child
		self._children = children
	end
end

function PocoTab:destroy()
	self.dead = true
	for name,child in pairs(self._children or {}) do
		child:destroy()
	end
end

local PocoTabs = class()
PocoHud3Class.PocoTabs = PocoTabs
function PocoTabs:init(ws,config) -- name,x,y,w,th,h,alt
	self._ws = ws
	config.fontSize = config.fontSize or 20
	self.config = config
	self.pTab = config.pTab
	if self.pTab then
		self.pTab:children(self)
	end
	self.alt = config.alt
	self.pnl = (self.pTab and self.pTab.pnl or ws:panel()):panel{ name = config.name , x = config.x, y = config.y, w = config.w, h = config.h, layer = self.pTab and 0 or Layers.TabHeader}
	self.items = {} -- array of PocoTab
	self._children = {} -- array of PocoTabs
	self.sPnl = self.pnl:panel{ name = config.name , x = 0, y = config.th, w = config.w, h = config.h-config.th}
	if not self.alt then
		BoxGuiObject:new(self.sPnl, {
			sides = {
				1,
				1,
				2,
				1
			}
		})
	end
end

function PocoTabs:canScroll(down,x,y)
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:canScroll(down,x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end
	if self.currentTab then
		return self.currentTab:canScroll(down,x,y)
	end
end

function PocoTabs:insideTabHeader(x,y,noChildren)
	for ind,tab in pairs(self.items) do
		local tResult = {tab:insideTabHeader(x,y,true)}
		if tResult[1] and self.tabIndex ~= ind then
			return self, ind
		end
	end
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:insideTabHeader(x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end

	local dY = y-self.pnl:world_y()
	if dY>0 and self.config.th >= dY then
		if self.currentTab then
			return self, 0
		end
	end
end

function PocoTabs:goTo(index)
	local cnt = #self.items
	if index < 1 or index > cnt then
		return
	end
	if index ~= self.tabIndex then
		managers.menu:post_event('slider_release' or 'Play_star_hit')
		self.tabIndex = index
		self:repaint()
	end
end
function PocoTabs:move(delta)
	self:goTo((self.tabIndex or 1) + delta)
end
function PocoTabs:add(tabName)
	local item = PocoTab:new(self,self.pnl,tabName)
	table.insert(self.items,item)
	self.tabIndex = self.tabIndex or 1
	self:repaint()
	return item
end

function PocoTabs:repaint()
	local cnt = #self.items
	local x = 0
	if cnt == 0 then return end
	local tabIndex = self.tabIndex or 1
	for key,itm in pairs(self.items) do
		local isSelected = key == tabIndex
		if isSelected then
			self.currentTab = itm
		end
		local hPnl = self.pnl:panel{w = 200, h = self.config.th, x = x, y = 0}
		if itm.hPnl then
			self.pnl:remove(itm.hPnl)
		end
		if not self.alt then
			local bg = hPnl:bitmap({
				name = 'tab_top',
				texture = 'guis/textures/pd2/shared_tab_box',
				w = self.config.w, h = self.config.th + 3,
				color = cl.White:with_alpha(isSelected and 1 or 0.1)
			})
			local lbl = hPnl:text({
				x = 10, y = 0, w = 400, h = self.config.th,
				name = 'tab_name', text = itm.name,
				font = FONT,
				font_size = self.config.fontSize,
				color = isSelected and cl.Black or cl.White,
				layer = 1,
				align = 'center',
				vertical = 'center'
			})
			local xx,yy,w,h = lbl:text_rect()

			lbl:set_size(w,self.config.th)

			bg:set_w(w + 20)
			x = x + w + 22
			itm.bg = bg
		end
		itm.hPnl = hPnl
		if itm.box then
			itm.box.wrapper:set_visible(isSelected)
		end
		itm.pnl:set_visible(isSelected)
	end
	if self.currentTab then
		self.currentTab:scroll(0,true)
	end
end

function PocoTabs:destroy(ws)
	for k,v in pairs(self.items) do
		v:destroy()
	end
	self._ws:panel():remove(self.pnl)
end
------------
local PocoMenu = class()
PocoHud3Class.PocoMenu = PocoMenu
function PocoMenu:init(ws,alternative)
	self._ws = ws
	self.alt = alternative
	if alternative then
		self.pnl = ws:panel():panel({ name = 'bg' })
		self.gui = PocoTabs:new(ws,{name = 'PocoRose',x = 0, y = -1, w = ws:width(), th = 1, h = ws:height()+1, pTab = nil, alt = true})

	else
		self.gui = PocoTabs:new(ws,{name = 'PocoMenu',x = 10, y = 10, w = 1200, th = 30, h = ws:height()-20, pTab = nil})

		self.pnl = ws:panel():panel({ name = 'bg' })
		self.pnl:rect{color = cl.Black:with_alpha(0.7),layer = Layers.Bg}
		self.pnl:bitmap({
			layer = Layers.Blur,
			texture = 'guis/textures/test_blur_df',
			w = self.pnl:w(),h = self.pnl:h(),
			render_template = 'VertexColorTexturedBlur3D'
		})
		local __, lbl = _.l({pnl = self.pnl,x = 1010, y = 20, font = FONT, font_size = 17, layer = Layers.TabHeader},
			{'Bksp or Dbl-right-click to dismiss',cl.Gray},true)
		lbl:set_right(1000)
	end

	PocoMenu.m_id = PocoMenu.m_id or managers.mouse_pointer:get_id()
	managers.mouse_pointer:use_mouse{
		id = PocoMenu.m_id,
		mouse_move = callback(self, self, 'mouse_moved',true),
		mouse_press = callback(self, self, 'mouse_pressed',true),
		mouse_release = callback(self, self, 'mouse_released',true)
	}

	self._lastMove = 0
end

function PocoMenu:_fade(pnl, out, done_cb, seconds)
	local pnl = self.pnl
	pnl:set_visible( true )
	pnl:set_alpha( out and 1 or 0 )
	local t = seconds
	if self.alt and not out then
		managers.mouse_pointer:set_mouse_world_position(pnl:w()/2, pnl:h()/2)
	end
	while alive(pnl) and t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local r = t/seconds
		pnl:set_alpha(out and r or 1-r)
		if self._tabs then
			for i,tabs in pairs(self._tabs) do
				tabs.pnl:set_alpha(out and r or 1-r)
			end
		end
		if self.gui and self.gui.pnl then
			self.gui.pnl:set_alpha(out and r or 1-r)
		end
	end
	if done_cb then
		done_cb()
	end
end

function PocoMenu:fadeIn()
	self.pnl:stop()
	self.pnl:animate(callback(self, self, '_fade'), false, nil, self.alt and 0.1 or 0.25)
end

function PocoMenu:fadeOut(cbk)
	self.pnl:stop()
	self.pnl:animate(callback(self, self, '_fade'), true, cbk, self.alt and 0.1 or 0.25)
end

function PocoMenu:add(...)
	self._tabs = self._tabs or {}
	local newTabs = self.gui:add(...)
	table.insert(self._tabs,newTabs)
	return newTabs
end

function PocoMenu:update(...)
end

function PocoMenu:destroy()
	if self.dead then return end
	self.dead = true
	if PocoMenu.m_id then
		managers.mouse_pointer:remove_mouse(PocoMenu.m_id)
	end

	if self.gui then
		self.gui:destroy()
	end
	if self.pnl then
		self._ws:panel():remove(self.pnl)
	end

end

function PocoMenu:mouse_moved(alt, panel, x, y)
	if not me or me.dead then return end
	local ret = function (a,b)
		if alt then
			managers.mouse_pointer:set_pointer_image(b)
		end
		return a, b
	end
	if self.dead then return end
	--if not inGame and alt then return end
	local isNewPos = self._x ~= x or self._y ~= y
	if isNewPos then
		self._close = nil
	else
		return
	end
	self._x = x
	self._y = y
	local _fireMouseOut = function()
		if self.lastHot then
			self.lastHot:fire(PocoEvent.Out,x,y)
			self.lastHot = nil
		end
	end
	local currentTab = self.gui and self.gui.currentTab

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.Move, x,y)
	if hotElem then
		hotElem:fire(PocoEvent.Move,x,y)
	end

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.In, x,y)
	if hotElem then
		if hotElem ~= self.lastHot then
			_fireMouseOut()
			self.lastHot = hotElem
			hotElem:fire(PocoEvent.In,x,y)
		end
	elseif isNewPos then
		_fireMouseOut()
	end
	local hotElem = currentTab and currentTab:isHot(PocoEvent.Pressed, x,y)
	if hotElem then
		return ret(true, hotElem.cursor or 'link')
	end
	if self.gui then
		local tabHdr = {self.gui:insideTabHeader(x,y)}
		if isNewPos and tabHdr[1] then
			return ret(true, tabHdr[2]~=0 and 'link' or 'arrow')
		end
	end
	return ret( true, 'arrow' )
end

function PocoMenu:mouse_pressed(alt, panel, button, x, y)
	if not me or me.dead then return end
	if self.dead then return end
	if self.alt then return end
	local tabT = 0.02
	pcall(function()
		local currentTab = self.gui and self.gui.currentTab
		if button == Idstring('mouse wheel down') then
			if currentTab:isHot(PocoEvent.WheelDown, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(1)
			end
		elseif button == Idstring('mouse wheel up') then
			if currentTab:isHot(PocoEvent.WheelUp, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(-1)
			end
		end

		if button == Idstring('0') then
			local focused = me._focused
			if focused and not focused:inside(x,y) then
				focused:fire(PocoEvent.Click,x,y)
				me._focused = nil
			end
			local tabs, tabInd = self.gui:insideTabHeader(x,y)
			if tabs and self.tabIndex ~= tabInd then
				if tabInd == 0 then
					tabs.currentTab:scroll(0,true)
				else
					tabs:goTo(tabInd)
				end
				return true
			end
			return currentTab and currentTab:isHot(PocoEvent.Pressed, x,y, true)
		end
		if button == Idstring('1') then
			return currentTab and currentTab:isHot(PocoEvent.PressedAlt, x,y, true)
		end
	end)
end

function PocoMenu:mouse_released(alt, panel, button, x, y)
	if not me or me.dead then return end
	if self.dead then return end
	if self.alt then return end
	local currentTab = self.gui and self.gui.currentTab
	if button == Idstring('0') then
		return currentTab and currentTab:isHot(PocoEvent.Released, x,y, true)
	end
	if button == Idstring('1') then
		local hot = currentTab and currentTab:isHot(PocoEvent.ReleasedAlt, x,y, true)
		if not hot then
			if self._close then
				me:Menu(true)
			else
				self._close = true
			end
		end
		return hot
	end
end

------------------------------
--- PocoHud3:Menu functions
------------------------------
local titlecase = function(str)
	local buff = {}
	for word in string.gmatch(str, '%S+') do
		local first, rest = string.sub(word, 1, 1), string.sub(word, 2)
		table.insert(buff, string.upper(first) .. string.lower(rest))
	end
	return table.concat(buff, ' ')
end

function PocoHud3Class._open(url)
	if shift() then
		os.execute("start " .. url)
	elseif managers.network and managers.network.account and managers.network.account.overlay_activate then
		managers.network.account:overlay_activate("url", url)
	end
	managers.menu:post_event(shift() and 'trip_mine_sensor_alarm' and 'camera_monitor_engage')
end

function PocoHud3Class._drawHeistStats(tab)
	local oTabs = PocoTabs:new(me._ws,{name = 'Options',x = 10, y = 10, w = 1150, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
	local x, y, tbl = 10, 10, {}
	local narrative = tweak_data.narrative

	-- [1] Per Heist
	local oTab = oTabs:add(L('_tab_stat_perheist'))
	local pnl = oTab.pnl
	local w, h, ww, hh = 0,0, pnl:size()
	local font,fontSize = tweak_data.menu.pd2_small_font, tweak_data.menu.pd2_small_font_size*0.98
	local _rowCnt = 0
	tbl[1] = {
		{L('_word_broker'),cl.BlanchedAlmond},
		L('_word_job'),
		'',
		'', -- Normal diff, no skulls
		{Icon.Skull, cl.PaleGoldenrod},
		{Icon.Skull .. Icon.Skull, cl.LavenderBlush},
		{string.rep(Icon.Skull, 3),cl.Wheat},
		{string.rep(Icon.Skull, 4),cl.Chocolate},
		{string.rep(Icon.Skull, 5),cl.Tomato},
		{string.rep(Icon.Skull, 6),cl.Crimson},
		L('_word_heat')
	}
	local risks = { 'risk_pd', 'risk_swat', 'risk_fbi', 'risk_death_squad', 'risk_easy_wish', 'risk_murder_squad', 'risk_sm_wish' }
	local function addJob(host, heist, jobData)
		if jobData.wrapped_to_job then
			jobData = narrative.jobs[jobData.wrapped_to_job]
		end
		local job_string = managers.localization:to_upper_text(jobData.name_id or heist) or heist
		job_string = job_string .. (string.find(heist, '_night') and ' '..L('_tab_stat_night') or '')
		local pro = jobData.professional
		if pro then
			job_string = {job_string, cl.Red}
		end
		local rowObj = { host and utf8.to_upper(host) or L('_word_na'), job_string, ''}
		for i, _ in ipairs(risks) do
			--local c = managers.statistics:completed_job( heist, tweak_data:index_to_difficulty( i + 1 ) )
			local diff = i + 1
			local c = managers.statistics._global.sessions.jobs[(heist .. '_' .. tweak_data:index_to_difficulty(diff) .. '_completed'):gsub('_wrapper','')] or 0
			local f = managers.statistics._global.sessions.jobs[(heist .. '_' .. tweak_data:index_to_difficulty(diff) .. '_started'):gsub('_wrapper','')] or 0
			if i > 1 or not pro then
				table.insert(rowObj, {{c, c<1 and cl.Salmon or cl.White:with_alpha(0.8)},{' / '..f,cl.White:with_alpha(0.4)}})
			else
				table.insert(rowObj, {c > 0 and c or L('_word_na'), cl.Tan:with_alpha(0.4)})
			end
		end
		local multi = managers.job:get_job_heat_multipliers(heist)
		local color = multi >= 1 and math.lerp( cl.Khaki, cl.Chartreuse, 6*(multi - 1) ) or math.lerp( cl.Crimson, cl.OrangeRed, 3*(multi - 0.7) )
		table.insert(rowObj,{{_.f(multi*100,5)..'%',color},{' ('..(managers.job:get_job_heat(heist) or '?')..')',color:with_alpha(0.3)}})
		tbl[#tbl+1] = rowObj
	end
	local contacts = narrative.contacts
	local contacts_sorted = {}
	-- Query all "visible" contacts in Contract Broker
	for contact, contact_data in pairs(contacts) do
		if not contact_data.hidden then
			contacts_sorted[#contacts_sorted + 1] = contact
		end
	end
	table.sort(contacts_sorted, function(a, b)
		return a:upper() < b:upper()
	end)
	local jobs = narrative.jobs
	for _, contact in ipairs(contacts_sorted) do
		for _, job_index in ipairs(narrative._jobs_index) do
			local job_data = jobs[job_index]
			if job_data and job_data.contact == contact then
				addJob(contact:gsub('the_', ''), job_index, job_data)
			end
		end
	end
	local _lastHost = ''
	for row, _tbl in pairs(tbl) do
		if _lastHost == _tbl[1] then
			_tbl[1] = ''
		else
			_lastHost = _tbl[1]
		end
		_rowCnt = _rowCnt + 1
		y = me:_drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
	end
	oTab:set_h(y)

	-- [2] Per day
	local host_list = tweak_data.achievement.job_list
	local level_list, job_list, mask_list, weapon_list = tweak_data.statistics:statistics_table()
	oTab = oTabs:add(L('_tab_stat_perday'))
	pnl = oTab.pnl
	y = 10
	local descs = {}
	tbl = {}
	tbl[#tbl+1] = {{L('_word_heist'),cl.BlanchedAlmond},{L('_word_day'),cl.Honeydew},{L('_word_started'),cl.LavenderBlush},{L('_word_completed'),cl.Wheat},L('_word_time')}
	local levels = _.g('managers.statistics._global.sessions.levels') or {}
	-- search JobsChain
	local addDay = function(val,prefix,suffix)
		if not level_list[table.get_key(level_list,val)] or not tweak_data.levels[val] then return end
		if table.get_key(level_list,val) then
			level_list[table.get_key(level_list,val)] = nil
		end
		local level = levels[val]
		if not level then return end
		local isAlt = val:match('_night$') or val:match('_day$')
		local name = managers.localization:to_upper_text(tweak_data.levels[val].name_id)
		if type(prefix) == 'string' then
			if (prefix:find(val) or managers.localization:to_upper_text(prefix) == name ) and not val:find('_%d') then
				prefix = {Icon.Ghost,cl.Gray}
			else
				prefix = managers.localization:to_upper_text(prefix)
			end
		end
		name = name .. (isAlt and ' '..L('_tab_stat'..isAlt) or '')
		local _c = function(n,color)
			return {n,n and n>0 and (color or cl.Lime) or cl.Gray }
		end
		local _s = function(...)
			local t = {}
			for i,v in pairs{...} do
				t[i] = _.s(v)
			end
			return table.concat(t)
		end
		local t = level.time / 60
		local avg = t / math.max(1,level.completed)
		tbl[#tbl+1] = {
			prefix,
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,align='left',text=name,hintText=suffix}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text=level.started,hintText={
				L('_desc_heist_count_started_1'),
				_c(level.from_beginning),'\n',
				L('_desc_heist_count_started_2'),
				_c(level.drop_in)
			}}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text=level.completed,hintText={L('_desc_heist_count_completed'), _c(level.quited,cl.Red)}}),
			PocoUIHintLabel:new(oTab,{x=0,y=0,w=200,h=fontSize,text={
				t>0 and (
					t > 60 and L('_desc_heist_time_hm',{math.floor(t/60),math.floor(t%60)}) or L('_desc_heist_time_m',{_.f(t)} )
				) or {L('_word_na'),cl.Gray}
			},hintText={
				L('_desc_heist_time_average'),L('_desc_heist_time_ms',{math.floor(avg),math.floor(avg*60%60)})
			},avg>0 and cl.Lime or cl.Gray})
		}
	end
	for host, _jobs in _.p(host_list) do
		local __jobs = table.deepcopy(_jobs)
		for _, heist in _.p(job_list) do
			local jobData = narrative:job_data(heist)

			if jobData and jobData.contact:gsub('the_','') == host:gsub('the_','') then
				jobData = jobs[heist]
				local jobName
				if jobData.wrapped_to_job then
					jobName = jobs[jobData.wrapped_to_job].name_id
				else
					jobName = jobData.name_id
				end
				if jobData and jobData.job_wrapper then
					for k,realJobs in pairs(jobData.job_wrapper) do
						table.insert(__jobs,realJobs)
					end
				end
				if jobData.chain then
					for day,level in pairs(jobData.chain) do
						local lID = level.level_id
						if lID then
							addDay(lID,jobName,L('_desc_heist_day',{day}))
						else -- alt Days
							for alt,_level in pairs(level) do
								addDay(_level.level_id,jobName,L('_desc_heist_dayalt',{day,alt}))
							end
						end
					end
				else
					_('no chain?',jobData.name_id)
				end
			end
		end
	end
	-- the rest
	tbl[#tbl+1] = {{L('_desc_heist_unlisted'),cl.DodgerBlue}}
	for key,val in _.p(level_list) do
		addDay(val,{Icon.Ghost,cl.DodgerBlue})
	end

	-- draw
	_rowCnt = 0
	for row, _tbl in pairs(tbl) do
		if _lastHost == _tbl[1] then
			_tbl[1] = ''
		else
			_lastHost = _tbl[1]
			_tbl[1] = type(_tbl[1]) == 'string' and {_tbl[1],cl.BlanchedAlmond} or _tbl[1]
		end
		_rowCnt = _rowCnt + 1
		y = me:_drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
	end
	local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=fontSize, pnl = pnl, x = 10, y = y+10},L('_desc_heist_may_not_match'),true)

	oTab:set_h(lbl:bottom())
end

function PocoHud3Class._drawUpgrades(tab, data, isTeam, desc, offsetY)
	local pnl = tab.pnl
	offsetY = offsetY or 0
	pnl:text{
		x = 10, y = offsetY+10, w = 600, h = 30,
		name = 'tab_desc', text = Icon.Chapter..' '..desc,
		font = FONTLARGE, font_size = 25, color = cl.CornFlowerBlue,
	}
	local large = 5
	local y,fontSize,w = offsetY+35, 19, pnl:w()
	if data then
		local merged = table.deepcopy(data)
		for category, upgrades in _.p(merged) do
			local row,cnt = {},0
			y = me:_drawRow(pnl,fontSize*1.1,{{titlecase(category:gsub('_',' ')),cl.Peru},''},5,y,w)
			for name, value in _.p(upgrades) do
				local isMulti = name:find('multiplier') or name:find('_chance') or name:find('_mul')
				local val = isTeam and managers.player:team_upgrade_value(category, name, 1) or managers.player:upgrade_value(category, name, 1)
				if not (isMulti and val == 1) then
					cnt = cnt + 1
					if isMulti and type(val) == 'number' then
						val = _.s(val*100) .. '%'
					elseif type(val) == 'table' then
						val = _.s( type(val[1]) == 'number' and _.s(val[1]*100) .. '%' or _.s(val[1]==true and L('_word_yes') or val[1]), _.s(val[2],'sec') )
					elseif val == true then
						val = L('_word_yes')
					else
						val = _.s(val)
					end
					row[#row+1] = {
						{(name:gsub('_multiplier',''):gsub('_',' '))..' ',cl.WhiteSmoke}
					}
					row[#row+1] = {
						{val..' ',cl.LightSteelBlue}
					}

					if #row> large then
						y = me:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
						row = {}
					end
				end
			end
			if cnt == 0 then
				row[#row+1] =  {L('_desc_not_in_effect'),cl.LightSteelBlue}
			end
			if #row > 0 then
				while (#row <= large) do
					table.insert(row,'')
				end
				y = me:_drawRow(pnl,fontSize,row,15,y,w,true,{0,1,0,1,0,1})
				row = {}
			end
		end
		tab:set_h(y)
	else
		y = me:_drawRow(pnl,fontSize,{{L('_desc_no_upgrades_acquired'),cl.White:with_alpha(0.5)},'\n'},0,y,w)
	end
	return y
end

function PocoHud3Class._drawAbout(tab,REV,TAG)
	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('https://modworkshop.net/mod/40870')
		end,
		x = 10, y = 10, w = 200,h=100,
		text={{'PocoHud3 r'},{REV,cl.Gray},{' by ',cl.White},{'Zenyr',cl.MediumTurquoise},{'\n'..TAG,cl.Silver}},
		hintText = {{L('_about_group_btn'),cl.LightSkyBlue},'\n',L('_about_hold_shift')}
	})

	local self = me
	local oTabs = PocoTabs:new(self._ws,{name = 'abouts',x = 220, y = 10, w = tab.pnl:width()-230, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})

	local oTab = oTabs:add(L('_about_trans_volunteers'))
	local y = 10
	local w = oTab.pnl:width()-20
	local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_presented'),true)
	y = y + 20
	lbl:set_w(w)
	__, lbl = _.l({font=FONT, color=cl.White, font_size=25, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_names'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)

	__, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_special_thanks'),true)
	y = y + 20
	lbl:set_w(w)

	__, lbl = _.l({font=FONT, color=cl.Silver, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)

	__, lbl = _.l({font=FONT, color=cl.LightSteelBlue, font_size=20, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_volunteers'),true)
	y = y + lbl:h()
	lbl:set_w(w)
	oTab:set_h(y)

	__, lbl = _.l({font=FONT, color=cl.Silver, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_fullList'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)
	oTab:set_h(y)

	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('https://steamcommunity.com/profiles/76561198078556212/')
		end,
		x = 10, y = 120, w = 200,h=40,
		text={'Current maintainer:\nDom',cl.OrangeRed},
		hintText = L('{_about_hold_shift}')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			PocoHud3Class._open('http://msdn.microsoft.com/en-us/library/ie/aa358803(v=vs.85).aspx')
		end,
		x = 10, y = 170, w = 200,h=40,
		text={L('_about_colors'), cl.Silver},-- no moar fun tho
		hintText = {L('_about_colors_hint'),'\n',L('_about_hold_shift')}
	})

end

function PocoHud3Class._drawOptions(tab)
	local self = me
	local objs = {}
	self.onMenuDismiss = function()
		O:default()
		for __,obj in pairs(objs) do
			if not obj[1]:isDefault() then
				O:set(obj[2],obj[3],obj[1]:val())
			end
		end
		O:save()
		me:Menu(true)
	end
	PocoUIButton:new(tab,{
		onClick = function()
			-- -- Poor man's Fix start
			-- local dialog_data = {}
			-- dialog_data.title = string.upper( L('_client_name') .. ' : Not reloaded on purpose')
			-- dialog_data.text = 'Some changes will be applied on restart due to slight issues.\n'.. 'Sorry for inconvenience!'
			-- local ok_button = {}
			-- ok_button.text = managers.localization:text("dialog_ok")
			-- dialog_data.button_list = {ok_button}
			-- managers.system_menu:show(dialog_data)
			PocoHud3Class.TPocoHud3.Toggle()
			PocoHud3 = nil -- will reload on its own
		end,
		x = 20, y = 10, w = 400, h=50,
		fontSize = 30,font = FONTLARGE,
		text={L('_btn_apply_and_reload'),cl.SteelBlue},
		hintText = L('_desc_apply_and_reload')
	})

	PocoUIButton:new(tab,{
		onClick = function()
			for __,obj in pairs(objs) do
				obj[1]:val(O:get(obj[2],obj[3],true))
			end
		end,
		x = 500, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_discard'),cl.Gray},
		hintText = L('_desc_discard')
	})
	PocoUIButton:new(tab,{
		onClick = function()
			managers.menu:show_default_option_dialog({
				text =  L('_desc_reset')..'\n'..L('_desc_reset_ask'),
				callback = function()
					for __,obj in pairs(objs) do
						obj[1]:val(O:_default(obj[2],obj[3]))
					end
				end
			})
		end,
		x = 710, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_reset'),cl.Gray},
		hintText = L('_desc_reset')
	})

	local oTabs = PocoTabs:new(self._ws,{name = 'Options',x = 10, y = 70, w = tab.pnl:width()-20, th = 30, fontSize = 18, h = tab.pnl:height()-80, pTab = tab})
	for category, objects in _.p(O.scheme) do
		local _y, m, half = 10, 5
		local x,y = function()
			return half and 440 or 10
		end, function(h)
			_y = _y + h + m
			return _y - h - m
		end

		local oTab = oTabs:add(L('_tab_'..category))
		if objects[1] then
			local txts = L:parse(objects[1])
			local __, lbl = _.l({font=FONT, color=cl.LightSteelBlue, alpha=0.9, font_size=20, pnl = oTab.pnl, x = x(), y = y(0)},txts,true)
			y(lbl:h())
			--[[oTab.pnl:bitmap({
				texture = 'guis/textures/pd2/shared_lines',	wrap_mode = 'wrap',
				color = cl.White, x = 5, y = y(3), w = oTab.pnl:w()-10, h = 3, alpha = 0.3 })]]
		end

		local c = 0
		local _sy,_ty = _y
		for name,values in _.p(objects,function(a,b)
			local t1, t2 = O:_type(category,a),O:_type(category,b)
			local s1, s2 = O:_sort(category,a) or 99,O:_sort(category,b) or 99
			if a == 'enable' then
				return true
			elseif b == 'enable' then
				return  false
			elseif s1 ~= s2 and type(s1) == type(s2) then
				return s1 < s2
			elseif t1 == 'bool' and t2 ~= 'bool' then
				return true
			elseif t1 ~= 'bool' and t2 == 'bool' then
				return false
			end
			return tostring(a) < tostring(b)
		end) do
			if type(name) ~= 'number' then
				c = c + 1
				if not half and c > table.size(objects) / 2 then
					half = true
					_ty = _y
					_y = _sy
				end
				local type = O:_type(category,name)
				local value = O:get(category,name,true)
				local hint = O:_hint(category,name)
				if hint:find('EN,') then
					_(_.i( L(hint), {depth=2}))
				end
				hint = hint and L(hint)
				local tName = L('_opt_'..name)
				if type == 'bool' then
					objs[#objs+1] = {PocoUIBoolean:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName , value = value ,
						hintText = hint
					}),category,name}
				elseif type == 'color' then
					objs[#objs+1] = {PocoUIColorValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'key' then
					objs[#objs+1] = {PocoUIKeyValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'num' then
					local range = O:_range(category,name) or {}
					local vanity = O:_vanity(category,name)
					if vanity then
						vanity = PocoHud3Class.L(vanity):split(',')
					end
					local step = O:_step(category,name)

					objs[#objs+1] = {PocoUINumValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name, step = step,
						fontSize = 20, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'string' then
					local selection = O:_vanity(category,name)

					objs[#objs+1] = {PocoUIStringValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value, selection = selection,
						hintText = hint
					}),category,name}
				else
					PocoUIButton:new(oTab,{
						hintText = L('_msg_not_implemented'),
						x = x()+10, y = y(30), w=390, h=30,
						text=_.s(name,type,value)
					})
				end
			end
		end
		oTab:set_h(math.max(_y,_ty)+40)
	end
end

function PocoHud3Class._drawRose(tab, rose2)
	local pnl = tab.pnl
	local layout
	if not rose2 then -- this IS rose2
		layout = {
		{	false,	false,	{'_rose_whattodo','v36'},	false,	false,	},
		{	{'_rose_stuck','v52'},	{'_rose_allofthem','p28'},	{'_rose_gtfu','f36x_any'},	{'_rose_sniper','f34x_any'},	{'_rose_dozer','f30x_any'},	},
		{	{'_rose_badsmell','v53'},	{'_rose_drillinplace','g21'},	{'_rose_hello','v56'},	{'_rose_cloaker','f33x_any'},	{'_rose_shield','f31x_any'},	},
		{	{'_rose_help','p45'},	{'_rose_payday','v21'},	false,	{'_rose_manager','v33'},	{'_rose_taser','f32x_any'},	},
		{	{'_rose_flashbanged','g41x_any'},	{'_rose_fwb','v34'},	{'_rose_letsrock','a01x_any'},	{'_rose_captain','f45x_any'},	{'_rose_turret','v45'},	},
		{	{'_rose_comeon','p04'},	{'_rose_planb','p21'},	{'_rose_woohoo','v55'},	{'_rose_interrogation','f46x_any'},	{'_rose_swatvan','p42'},	},
		{	{'_rose_reviving','s08x_sin'},	false,	{'_rose_door','v15'},	false,	{'_rose_medic','f47x_any'},	},
		}
	else
		layout = {
		{	{'_rose_whistle','whistling_attention'},	{'_rose_cable','g26'},	{'_rose_medbag','g80x_plu'},	{'_rose_shoot','g23'},	{'_rose_drill','g61'},	},
		{	{'_rose_overrun','g68'},	{'_rose_timetogo','g17'},	{'_rose_thisway','g12'},	{'_rose_straight','g19'},	{'_rose_cantstay','g69'},	},
		{	{'_rose_almost','g28'},	{'_rose_getout','g07'},	{'_rose_upstairs','g02'},	{'_rose_hurry','g09'},	{'_rose_alright','g92'},	},
		{	{'_rose_letsgo','g13'},	{'_rose_left','g03'},	false,	{'_rose_right','g04'},	{'_rose_thanks','s05x_sin'},	},
		{	{'_rose_halfway','t02x_sin'},	{'_rose_careful','g10'},	{'_rose_downstairs','g01'},	{'_rose_inside','g08'},	{'_rose_anysecond','t03x_sin'},	},
		{	{'_rose_fewminutes','t01x_sin'},	{'_rose_down','g20'},	{'_rose_wrong','g11'},	{'_rose_defended','g16'},	{'_rose_cams','g25'},	},
		{	false,	{'_rose_shit','g60'},	{'_rose_ammo','g81x_plu'},	{'_rose_fuck','g29'},	false,	},
		}
	end

	layout = L:parse(layout)
	local w,h = 200,70
	local ox,oy = pnl:w()/2 - 2*w,pnl:h()/2 - 3*h
	for y,row in pairs(layout) do
		for x, obj in pairs(row) do
			if obj then
				local xx = ox + (x-1)*w
				local yy = oy + (y-1)*h
				if x == 3 then
					yy = yy + h*0.5*(y > 4 and 1 or -1)
				end
				if y == 4 then
					xx = xx + w*0.3*(x > 3 and 1 or -1)
				end
				PocoRoseButton:new(tab,{
					x = xx, y = yy, w=w, h=h,
					fontSize = 20, text=obj[1]:upper(), value=obj[2]
				})
			end
		end
	end
	local sPnl = pnl:panel{alpha = 0.4}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black,
			1,
			cl.Black:with_alpha(0)
		},
		orientation = "vertical",
		h = pnl:h() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(0),
			1,
			cl.Black:with_alpha(1)
		},
		orientation = "vertical",
		y = pnl:h() / 3 * 2,
		h = pnl:h() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(1),
			1,
			cl.Black:with_alpha(0)
		},
		orientation = 'horizontal',
		w = pnl:w() / 3
	}
	sPnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(0),
			1,
			cl.Black:with_alpha(1)
		},
		orientation = 'horizontal',
		x = pnl:w() / 3 * 2,
		w = pnl:w() / 3
	}
	--pnl:bitmap{ texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, w = pnl:w(), h = pnl:h()}
end

function PocoHud3Class._drawJukebox(tab)
	-- revised old code I made. also thx to PierreDjays for basic idea.
	local music
	music = {
		play = function(num)
			music.stop()

			if not managers.music.attempt_play
				or not managers.music:attempt_play(num, managers.music._last or 'setup', true)
			then
				Global.music_manager.source:set_switch( "music_randomizer", num )
			else
				me._music_started = managers.localization:text('menu_jukebox_'..num)
				if me._music_started:begins('ERROR') then
					me._music_started = num:gsub('_', ' '):sub(2)
					me._music_started = num:sub(1,1):upper()..me._music_started
				end
			end
			Global.music_manager.current_track = num
			music.set(managers.music._last or 'setup')
		end,
		set = function(mode)
			managers.music._last = type(mode)~='table' and mode
			managers.music._skip_play = nil
			managers.music:post_event( type(mode)=='table' and mode[1] or "music_heist_"..mode )
		end,
		stop = function()
			if managers.music.stop_custom then
				managers.music:stop_custom()
			end
			managers.music:stop()
		end
	}
	PocoUIButton:new(tab,{
		onClick = function(self)
				music.stop()
		end,
		x = 440, y = 40, w = 200,h=40,
		text=L('_tab_juke_stop')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('setup')
		end,
		x = 440, y = 90, w = 200,h=40,
		text=L('_tab_juke_stealth')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('control')
		end,
		x = 440, y = 140, w = 200,h=40,
		text=L('_tab_juke_control')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('anticipation')
		end,
		x = 440, y = 190, w = 200,h=40,
		text=L('_tab_juke_anticipation')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			music.set('assault')
		end,
		x = 440, y = 240, w = 200,h=40,
		text=L('_tab_juke_assault')
	})

	local __, lbl = _.l({pnl = tab.pnl, x=440, y= 290, font = FONT, font_size = 20, color = cl.Gray},L('_tab_juke_shuffle_tip'),true)


	local _addItems = function(oTab,inGame)
		local y = 10
		local track_list,track_locked
		if inGame then
			track_list,track_locked = managers.music:jukebox_music_tracks()
		else
			track_list,track_locked = managers.music:jukebox_menu_tracks()
		end
		for __, track_name in pairs(track_list or {}) do
			local text = managers.localization:text((inGame and 'menu_jukebox_' or 'menu_jukebox_screen_')..track_name)
			local listed = inGame and managers.music:playlist_contains(track_name) or managers.music:playlist_menu_contains(track_name)
			local locked = track_locked[track_name]
			local hint = locked and managers.localization:text("menu_jukebox_locked_" .. locked) or nil
			PocoUIButton:new(oTab,{
				onClick = function(self)
					if not locked then
						music[inGame and 'play' or 'set'](inGame and track_name or {track_name})
					end
				end,
				x = 10, y = y, w = 400,h=30,
				text={text,locked and cl.Red or listed and cl.White or cl.Gray},
				hintText = hint
			})
			y = y + 35
		end
		oTab:set_h(y)
	end

	local oTabs = PocoTabs:new(me._ws,{name = 'jukeboxes',x = 10, y = 10, w = 420, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
	-- [1] Heist musics
	_addItems(oTabs:add(L('_tab_juke_heist')), true)
	-- [2] Menu musics
	_addItems(oTabs:add(L('_tab_juke_menu')), false)
end

----------------------------------
-- Localizer : Auto Localizer
----------------------------------
local Localizer = class()
PocoHud3Class.Localizer = Localizer
function Localizer:init()
	-- Shorthand L(o,c)
	local mt = getmetatable(self)
	mt.__call = function(__, ...)
		return self:parse(...)
	end
	setmetatable(self, mt)

	self.parser = {
		string = function(str,context)
			if str == '##' then -- Special case: omit string instructor
				return ''
			end
			-- parse 'something {color|key|alpha} something'
			local p,exploded = 1,{}
			for s,tag,e in str:gmatch('(){(.-)}()') do
					table.insert(exploded,str:sub(p,s-1))
					if tag:find('|') then
						local key,color = tag:match('^(.-)|(.+)$')
						local alpha
						if color:find('|') then
							color, alpha = color:match('(.+)|(.+)')
							alpha = tonumber(alpha)
						end
						color = cl[color] or cl.White
						if alpha then
							color = color:with_alpha(alpha)
						end
						table.insert(exploded,{key,color})
					else
						table.insert(exploded,tag)
					end
					p = e
			end
			table.insert(exploded,str:sub(p,str:len()))
			if exploded[2] then
				return self:parse(exploded,context)
			else
				return str:find('^[_!]') and self:parse(self:get(str,context),context) or str
			end
		end,
		table = function(tbl,context)
			local r = {}
			for k,v in pairs(tbl) do
				r[k] = self:parse(v,context)
			end
			return r
		end
	}
	self._data = {}
end

function Localizer:get(key,context)
	local val = PocoLocale._defaultLocaleData[key] or self._data[key] or PocoHud3Class.Icon[key:gsub('_','')]
	if val and type(context)=='table' then
		for k,v in pairs(context) do
			val = val:gsub('%['..k..'%]',v)
		end
	end
	return val or _.s('?:',key)
end

function Localizer:load()
	local lang = PocoHud3Class.O('root','language')
	local f, err = io.open(LocJSONFileName:gsub('%$',lang), 'r')
	if f then
		local t = f:read('*all')
		local o = JSON:decode(t)
		if type(o) == "table" then
			_('Locale',lang,'loaded')
			self._data = o
		end
		f:close()
	else
		_('Locale',lang,'NOT loaded')
	end

	if lang ~= "EN" then
		f, err = io.open(LocJSONFileName:gsub('%$','EN'), 'r')
		if f then
			local t = f:read('*all')
			local o = JSON:decode(t)
			if type(o) == 'table' then
				for key, value in pairs(o) do
					if not self._data[key] then
						self._data[key] = value
					end
				end
			end
			f:close()
		end
	end
end

function Localizer:parse(object,context)
	local t = type(object)
	return self.parser[t] and self.parser[t](object,context) or object
end