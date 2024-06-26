local TRUE, FALSE = true, false
local scheme = {
	root = { '_opt_root_desc',
		blendMode = {'num', 1, {1, 2}, "_opt_blendMode_desc","blendMode"},
		detailedModeKey = {'key','`',nil,'_opt_detailedModeKey_desc'},
		detailedModeToggle = {'bool',FALSE,nil,'_opt_detailedModeToggle_desc'},
		showMusicTitlePrefix = {'string','Now Playing: ',nil,'_opt_showMusicTitlePrefix_desc'},
		showMusicTitle = {'bool',TRUE,nil,'_opt_showMusicTitle_desc'},
		shuffleMusic = {'bool',FALSE,nil,'_opt_shuffleMusic_desc'},
		pocoRoseKey = {'key','n',nil,'_opt_pocoRoseKey_desc'},
		pocoRoseKey2 = {'key','m',nil,'_opt_pocoRoseKey2_desc'},
		optionsMenuKey = {'key','backspace',nil,'_opt_optionsMenuKey_desc'},
		pocoRoseHalt = {'bool',FALSE,nil,'_opt_pocoRoseHalt_desc'},
		language = {'string','EN',nil,'_opt_language_desc','language'},
		languageIngame = {'string','EN',nil,'_opt_languageIngame_desc','language'},
		languageRooms = {'string','EN',nil,'_opt_languageRooms_desc','language'},
		colorPositive = {'color','YellowGreen','color','_opt_colorPositive_desc',nil,nil,2},
		colorNegative = {'color','Gold','color','_opt_colorNegative_desc',nil,nil,2},
		['24HourClock'] = {'bool',TRUE,nil,'_opt_24HourClock_desc'},
		detailedModeByDefault = {"bool",FALSE,nil,"_opt_detailedModeByDefault_desc"}
	}, corner = {	'_opt_corner_desc',
		color  = {'color','White','color','_opt_color_desc'},
		opacity = {'num',80,{0,100},'_opt_opacity_desc',nil,5},
		size  = {'num',22,{10,30},'_opt_size_desc'},
		defaultFont  = {'bool',TRUE,nil,'_opt_defaultFont_desc'},
		detailedOnly  = {'bool',FALSE,nil,'_opt_detailedOnly_desc'},
		showFPS  = {'bool',TRUE,nil,'_opt_showFPS_desc'},
		showClockIngame  = {'bool',FALSE,nil,'_opt_showClockIngame_desc'},
		showClockOutgame  = {'bool',TRUE,nil,'_opt_showClockOutgame_desc'},
	}, buff = {	'_opt_buff_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},

		xPosition = {'num',10,{0,100},'_opt_xPosition_desc',nil,2,1},
		yPosition = {'num',22,{0,100},'_opt_yPosition_desc',nil,2,1},
		maxFPS  = {'num',50,nil,'_opt_maxFPS_desc',nil,5,3},
		buffSize = {'num',70,nil,'_opt_buffSize_desc',nil,nil,2},
		gap = {'num',10,nil,'_opt_gap_desc',nil,nil,2},
		justify = {'num',1,{1,3},'_opt_justify_desc','align',nil,2},
		mirrorDirection = {'bool',TRUE,nil,'_opt_mirrorDirection_desc',nil,nil,2},
		style = {'num',1,{1,3},'_opt_style_desc','style',nil,2},
		textOnBuff = {'bool',TRUE,nil,'_opt_textOnBuff_desc',nil,nil,2},
		interactionCircle = {'bool',TRUE,nil,"_opt_interactionCircle_desc",nil,nil,2},

		showAIReviveCooldown = {'bool',TRUE,nil,'_opt_showAIReviveCooldown_desc'},
		showBerserker = {'bool',TRUE,nil,'_opt_showBerserker_desc'},
		showSwanSong = {'bool',TRUE,nil,'_opt_showSwanSong_desc'},
		showPainkiller = {'bool',TRUE,nil,'_opt_showPainkiller_desc'},
		showStamina = {'bool',TRUE,nil,'_opt_showStamina_desc'},
		showCharge = {'bool',TRUE,nil,'_opt_showCharge_desc'},
		showTransition = {'bool',TRUE,nil,'_opt_showTransition_desc'},
		showCarryDrop = {'bool',TRUE,nil,'_opt_showCarryDrop_desc'},
		showInteract = {'bool',TRUE,nil,'_opt_showInteract_desc'},
		showInteraction = {'bool',TRUE,nil,'_opt_showInteraction_desc'},
		showInspire = {'bool',TRUE,nil,'_opt_showInspire_desc'},
		showBoost = {'bool',TRUE,nil,'_opt_showBoost_desc'},
		showShield = {'bool',TRUE,nil,'_opt_showShield_desc'},
		showECM = {'bool',TRUE,nil,'_opt_showECM_desc'},
		showFeedback = {'bool',TRUE,nil,'_opt_showFeedback_desc'},
		showTapeLoop = {'bool',TRUE,nil,'_opt_showTapeLoop_desc'},
		showOverkill = {'bool',TRUE,nil,'_opt_showOverkill_desc'},
		showCombatMedic = {'bool',TRUE,nil,'_opt_showCombatMedic_desc'},
		showUnderdog = {'bool',TRUE,nil,'_opt_showUnderdog_desc'},
		showBulletstorm = {'bool',TRUE,nil,'_opt_showBulletstorm_desc'},
		showBulletstormPotential = {'bool',TRUE,nil,"_opt_showBulletstormPotential_desc"},
		BulletstormPotentialResolution = {'num',4,{1,10},"_opt_BulletstormPotentialResolution_desc"},
		showSuppressed = {'bool',FALSE,nil,'_opt_showSuppressed_desc'},
		showReload = {'bool',TRUE,nil,'_opt_showReload_desc'},
		showTriggerHappy = {'bool',TRUE,nil,'_opt_showTriggerHappy_desc'},
		showFirstAid = {'bool',TRUE,nil,'_opt_showFirstAid_desc'},
		showLifeLeech = {'bool',TRUE,nil,'_opt_showLifeLeech_desc'},
		showCloseCombat = {'bool',TRUE,nil,'_opt_showCloseCombat_desc'},
		showGamblerAmmo = {'bool',TRUE,nil,'_opt_showGambler_desc'},
		showGamblerHealth = {'bool',TRUE,nil,'_opt_showGambler_desc'},
		showSecondWind = {'bool',TRUE,nil,'_opt_showSecondWind_desc'},
		showKingpinInjector = {'bool',TRUE,nil,'_opt_showKingpinInjector_desc'},
		showKingpinInjectorCooldown = {'bool',TRUE,nil,'_opt_showKingpinInjectorCooldown_desc'},
		showCopycatGracePeriod = {"bool",TRUE,nil,"_opt_showCopycatGracePeriod_desc"},
		showCopycatGracePeriodCooldown = {"bool",TRUE,nil,"_opt_showCopycatGracePeriodCooldown_desc"},
		showCopycatHeadGamesCooldown = {"bool",TRUE,nil,"_opt_showCopycatHeadGamesCooldown_desc"},
		showLeechAmpule = {'bool',TRUE,nil,'_opt_showLeechAmpule_desc'},
		showLeechAmpuleCooldown = {'bool',TRUE,nil,'_opt_showLeechAmpuleCooldown_desc'},
		showLeechImmunityDuration = {'bool',TRUE,nil,"_opt_showLeechImmunityDuration_desc"},
		showHackerTemporaryDodge = {'bool',TRUE,nil,'_opt_showHackerTemporaryDodge_desc'},
		showHackerPocketECMJammerCooldown = {'bool',TRUE,nil,'_opt_showHackerPocketECMJammerCooldown_desc'},
		showHackerPocketECMJammerJammerEffect = {'bool',TRUE,nil,'_opt_showHackerPocketECMJammerJammerEffect_desc'},
		showHackerPocketECMJammerFeedbackEffect = {'bool',TRUE,nil,'_opt_showHackerPocketECMJammerFeedbackEffect_desc'},
		showStoicDelayDamage = {'bool',TRUE,nil,'_opt_showStoicDelayDamage_desc'},
		showStoicHipFlaskCooldown = {'bool',TRUE,nil,'_opt_showStoicHipFlaskCooldown_desc'},
		showSicarioSmokeGrenade = {'bool',TRUE,nil,'_opt_showSicarioSmokeGrenade_desc'},
		showSicarioSmokeGrenadeCooldown = {'bool',TRUE,nil,"_opt_showSicarioSmokeGrenadeCooldown_desc"},
		showSicarioTwitchGauge = {'bool',TRUE,nil,"_opt_showSicarioTwitchGauge_desc"},
		showSicarioTwitchCooldown = {'bool',TRUE,nil,"_opt_showSicarioTwitchCooldown_desc"},
		showTagTeamEffect = {'bool',TRUE,nil,"_opt_showTagTeamEffect_desc"},
		showTagTeamTagged = {'bool',TRUE,nil,"_opt_showTagTeamTagged_desc"},
		showTagTeamCooldown = {'bool',TRUE,nil,'_opt_showTagTeamCooldown_desc'},
		showInspireReviveCooldown = {'bool',TRUE,nil,'_opt_showInspireReviveCooldown_desc'},
		showUppersCooldown = {'bool',TRUE,nil,"_opt_showUppersCooldown_desc"},
		showArmorerInvulnerabilityCooldown = {'bool',TRUE,nil,"_opt_showArmorerInvulnerabilityCooldown_desc"},
		showAggressiveReloadDuration = {'bool',TRUE,nil,"_opt_showAggressiveReloadDuration_desc"},
		showAnarchistDamageCooldown = {'bool',TRUE,nil,"_opt_showAnarchistDamageCooldown_desc"},
		showImmunity = {'bool',TRUE,nil,"_opt_showImmunity_desc"},
		showAnarchistRegenTick = {'bool',TRUE,nil,"_opt_showAnarchistRegenTick_desc"},
		showPersistentAnarchistRegenTick = {'bool',FALSE,nil,"_opt_showPersistentAnarchistRegenTick_desc"},
		showAnarchistRegenGain = {'bool',TRUE,nil,"_opt_showAnarchistRegenGain_desc"},
		showBikerKillsGauge = {'bool',TRUE,nil,"_opt_showBikerKillsGauge_desc"},
		showBikerCooldown = {'bool',TRUE,nil,"_opt_showBikerCooldown_desc"},
		BikerKillsGaugeResolution = {'num',2,{1,10},"_opt_BikerKillsGaugeResolution_desc"},
		showUppersRangeGauge = {'bool',TRUE,nil,"_opt_showUppersRangeGauge_desc"},
		UppersRangeResolution = {'num',4,{1,25},"_opt_UppersRangeResolution_desc"},
		showDodgeChanceGauge = {'bool',TRUE,nil,"_opt_showDodgeChanceGauge_desc"},
		showPersistentDodgeChanceGauge = {'bool',FALSE,nil,"_opt_showPersistentDodgeChanceGauge_desc"},
		showCriticalChanceGauge = {'bool',TRUE,nil,"_opt_showCriticalChanceGauge_desc"},
		showUpYouGoDuration = {'bool',TRUE,nil,"_opt_showUpYouGoDuration_desc"},
		showRunningFromDeathMovementDuration = {'bool',TRUE,nil,"_opt_showRunningFromDeathMovementDuration_desc"},
		showRunningFromDeathWeaponDuration = {'bool',TRUE,nil,"_opt_showRunningFromDeathWeaponDuration_desc"},
		showUnseenStrikeCriticalBoostDuration = {'bool',TRUE,nil,"_opt_showUnseenStrikeCriticalBoostDuration_desc"},
		showUnseenStrikeDamageAvoidanceDuration = {'bool',TRUE,nil,"_opt_showUnseenStrikeDamageAvoidanceDuration_desc"},
		showForcedFriendshipStack = {'bool',TRUE,nil,"_opt_showForcedFriendshipStack_desc"},
		showForcedFriendshipPercentage = {'bool',FALSE,nil,"_opt_showForcedFriendshipPercentage_desc"},
		showGrinderRegenPeriod = {'bool',TRUE,nil,"_opt_showGrinderRegenPeriod_desc"},
		showGrinderStackCooldown = {'bool',TRUE,nil,"_opt_showGrinderStackCooldown_desc"},
		showManiacAccumulatedStacks = {'bool',TRUE,nil,"_opt_showManiacAccumulatedStacks_desc"},
		showManiacDecayTicks = {'bool',TRUE,nil,"_opt_showManiacDecayTicks_desc"},
		showManiacStackTicks = {'bool',TRUE,nil,"_opt_showManiacStackTicks_desc"},
		ManiacAccumulatedStacksResolution = {'num',2,{1,10},"_opt_ManiacAccumulatedStacksResolution_desc"},
		showHostageTakerMuscleRegen = {'bool',TRUE,nil,"_opt_showHostageTakerMuscleRegen_desc"},
		showBloodthirstMeleeBoostGauge = {'bool',TRUE,nil,"_opt_showBloodthirstMeleeBoostGauge_desc"},
		showDireNeedDuration = {'bool',TRUE,nil,"_opt_showDireNeedDuration_desc"},
		DireNeedDurationResolution = {'num',4,{1,10},"_opt_DireNeedDurationResolution_desc"},
		showSixthSenseInitial = {'bool',TRUE,nil,"_opt_showSixthSenseInitial_desc"},
		showSixthSenseSubsequent = {'bool',TRUE,nil,"_opt_showSixthSenseSubsequent_desc"},
		showSixthSenseHighlighted = {'bool',TRUE,nil,"_opt_showSixthSenseHighlighted_desc"},
		showBullseyeCooldown = {'bool',TRUE,nil,"_opt_showBullseyeCooldown_desc"},
		showAmmoEfficiencyDuration = {'bool',TRUE,nil,"_opt_showAmmoEfficiencyDuration_desc"},
		showAmmoEfficiencyStack = {'bool',TRUE,nil,"_opt_showAmmoEfficiencyStack_desc"},
		showBloodthirstReloadBoostDuration = {'bool',TRUE,nil,"_opt_showBloodthirstReloadBoostDuration_desc"},
		showLockAndLoadReloadBoost = {'bool',TRUE,nil,"_opt_showLockAndLoadReloadBoost_desc"},
		LockAndLoadResolution = {'num',4,{1,15},"_opt_LockAndLoadResolution_desc"},
		showSociopathCooldowns = {'bool',TRUE,nil,"_opt_showSociopathCooldowns_desc"},
		showReplenishThrowableAI = {"bool",TRUE,nil,"_opt_showReplenishThrowableAI_desc"},

		noSprintDelay  = {'bool',TRUE,nil,'_opt_noSprintDelay_desc',nil,nil,4},
		hideInteractionCircle  = {'bool',FALSE,nil,'_opt_hideInteractionCircle_desc',nil,nil,4},
		simpleBusyIndicator = {'bool',TRUE,nil,'_opt_simpleBusyIndicator_desc',nil,nil,4},
		simpleBusySize = {'num',10,{5,30},'_opt_simpleBusySize_desc',nil,5,4},
	}, playerBottom = {	'_opt_playerBottom_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		size = {'num',17,{15,30},'_opt_size_desc',nil,2,1},
		offset = {'num',0,{-30,30},'_opt_offset_desc',nil,2,1},
		offsetX = {'num',0,{-3000,3000},'_opt_offsetX_desc',nil,2,1},
		offsetXTeam = {'num',0,{-3000,3000},'_opt_offsetXTeam_desc',nil,2,1},
		underneath = {'bool',TRUE,nil,'_opt_underneath_desc',nil,nil,1},
		uppercaseNames = {'bool',TRUE,nil,'_opt_uppercaseNames_desc',nil,nil,1},
		showClock = {'num',2,{0,2},'_opt_showClock_desc','Verbose'},
		showFpsBottom = {'num',0,{0,2},'_opt_showFpsBottom_desc','Verbose'},
		showRank = {'bool',TRUE,nil,'_opt_showRank_desc'},
		onlyMe = {'bool',FALSE,nil,'_opt_onlyMe_desc'},
		rankToPlaytime = {'bool',FALSE,nil,'_opt_rankToPlaytime_desc'},
		showInteraction = {'num',2,{0,2},'_opt_showInteraction_desc','Verbose'},
		showInteractionTime = {'num',2,{0,2},'_opt_showInteractionTime_desc','Verbose'},
		showKill = {'num',2,{0,2},'_opt_showKill_desc','Verbose'},
		showPosition = {'num',2,{0,2},'_opt_showPosition_desc','Verbose'},
		showSpecial = {'num',2,{0,2},'_opt_showSpecial_desc','Verbose'},
        showHead = {'num',2,{0,2},'_opt_showHead_desc','Verbose'},
		showInspire = {'num',2,{0,2},'_opt_showInspire_desc2','Verbose'},
		showAverageDamage = {'num',1,{0,2},'_opt_showAverageDamage_desc','Verbose'},
		showHostages = {'num',1,{0,2},'_opt_showHostages_desc','Verbose'},
		showDistance = {'num',2,{0,2},'_opt_showDistance_desc','Verbose'},
		showDowns = {'num',2,{0,2},'_opt_showDowns_desc','Verbose'},
		showPing = {'num',2,{0,2},'_opt_showPing_desc','Verbose'},
		showConvertedEnemy = {'num',1,{0,2},'_opt_showConvertedEnemy_desc','Verbose'},
		showDetectionRisk = {'num',1,{0,2},'_opt_showDetectionRisk_desc','Verbose'},
		showPlaytime = {'num',1,{0,2},'_opt_showPlaytime_desc','Verbose'},
		showIncapacitations = {'num',2,{0,2},'_opt_showIncapacitations_desc','Verbose'},
		showAccuracy = {'num',1,{0,2},'_opt_showAccuracy_desc','Verbose'},
	}, popup = {	'_opt_popup_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		size  = {'num',22,{10,30},'_opt_size_desc',nil,nil,1},
		damageDecay  = {'num',10,{2,15},'_opt_damageDecay_desc',nil,nil,1},
		myDamage  = {'bool',TRUE,nil,'_opt_myDamage_desc',nil,nil,2},
        myCrits  = {'bool',TRUE,nil,'_opt_myCrits_desc',nil,nil,4},
		crewDamage  = {'bool',TRUE,nil,'_opt_crewDamage_desc',nil,nil,2},
		AiDamage  = {'bool',TRUE,nil,'_opt_AiDamage_desc',nil,nil,3},
		handsUp  = {'bool',TRUE,nil,'_opt_handsUp_desc',nil,nil,4},
		dominated  = {'bool',TRUE,nil,'_opt_dominated_desc',nil,nil,4},
	}, chat = {	'_opt_chat_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		fallbackToMe = {'bool',TRUE,nil,'_opt_fallbackToMe_desc',nil,nil,1},
		includeLocation = {'bool',TRUE,nil,'_opt_includeLocation_desc',nil,nil,1},
		midStat  = {'num',1,{0,5},'_opt_midStat_desc','ChatSend',nil,2},
		endStat  = {'num',1,{0,5},'_opt_endStat_desc','ChatSend',nil,2},
		dominated  = {'num',1,{0,5},'_opt_dominated_desc','ChatSend',nil,3},
		converted  = {'num',1,{0,5},'_opt_converted_desc','ChatSend',nil,3},
		minionLost  = {'num',1,{0,5},'_opt_minionLost_desc','ChatSend',nil,3},
		minionShot  = {'num',1,{0,5},'_opt_minionShot_desc','ChatSend',nil,3},
		custody  = {'num',1,{0,5},'_opt_custody_desc','ChatSend',nil,3},
		downed  = {'num',1,{0,5},'_opt_downed_desc','ChatSend',nil,3},
		downedWarning  = {'num',1,{0,5},'_opt_downedWarning_desc','ChatSend',nil,3},
		replenished  = {'num',1,{0,5},'_opt_replenished_desc','ChatSend',nil,3},
		replenishedFAK = {'num',1,{0,5},"_opt_replenishedFAK_desc","ChatSend",nil,3},
		messiah  = {'num',1,{0,5},'_opt_messiah_desc','ChatSend',nil,4},
		specOps  = {'num',1,{0,5},'_opt_specOps_desc','ChatSend',nil,4},
		havePagers  = {'num',1,{0,5},'_opt_havePagers_desc','ChatSend',nil,4},
		haveCivilians  = {'num',1,{0,5},'_opt_haveCivilians_desc','ChatSend',nil,4},
		drillDone = {'num',1,{0,5},'_opt_drillDone_desc','ChatSend',nil,5},
		drillAlmostDone = {'num',1,{0,5},'_opt_drillAlmostDone_desc','ChatSend',nil,5},
	}, hit = { '_opt_hit_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		duration  = {'num',0,{0,10},'_opt_duration_desc','Auto',nil,1},
		opacity  = {'num',50,{0,100},'_opt_opacity_desc',nil,5,1},
		number  = {'bool',TRUE,nil,'_opt_number_desc',nil,nil,1},
		numberSize  = {'num',25,{20,30},'_opt_numberSize_desc',nil,nil,1},
		numberDefaultFont  = {'bool',FALSE,nil,'_opt_numberDefaultFont_desc',nil,nil,1},
		sizeStart  = {'num',100,{50,250},'_opt_sizeStart_desc',nil,50,2},
		sizeEnd  = {'num',200,{50,500},'_opt_sizeEnd_desc',nil,50,3},
		shieldColor = {'color','LightGray','color','_opt_shieldColor_desc',nil,nil,4},
		healthColor = {'color','Red','color','_opt_healthColor_desc',nil,nil,5},
		shieldColorDepleted = {'color','DarkGray','color','_opt_shieldColorDepleted_desc',nil,nil,4},
		healthColorDepleted = {'color','Maroon','color','_opt_healthColorDepleted_desc',nil,nil,5},
		dodgeColor = {'color','Aqua','color','_opt_dodgeColor_desc',nil,nil,6}
	}, float = { '_opt_float_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		frame = {'bool',FALSE,nil,'_opt_frame_desc',nil,nil,3},
		size = {'num',15,{10,20},'_opt_size_desc',nil,nil,1},
		margin = {'num',3,{0,5},'_opt_margin_desc',nil,nil,1},
		keepOnScreen = {'bool',TRUE,nil,'_opt_keepOnScreen_desc',nil,nil,2},
		keepOnScreenMarginX = {'num',2,{0,20},'_opt_keepOnScreenMarginX_desc',nil,nil,2},
		keepOnScreenMarginY = {'num',15,{0,20},'_opt_keepOnScreenMarginY_desc',nil,nil,2},
		opacity  = {'num',90,{10,100},'_opt_opacity_desc',nil,5,1},
		showTargets = {'bool',TRUE,nil,'_opt_showTargets_desc',nil,nil,4},
        showTargetsConvert = {'bool',TRUE,nil,'_opt_showTargetsConvert_desc',nil,nil,4},
        showTargetsCivs = {'bool',TRUE,nil,'_opt_showTargetsCivs_desc',nil,nil,4},
        showTargetsSpecials = {'bool',TRUE,nil,'_opt_showTargetsSpecials_desc',nil,nil,4},
        showTargetsDeployables = {'bool',TRUE,nil,'_opt_showTargetsDeployables_desc',nil,nil,4},
        showTargetsTeamAi = {'bool',TRUE,nil,'_opt_showTargetsTeamAi_desc',nil,nil,4},
        showTargetsOther = {'bool',TRUE,nil,'_opt_showTargetsOther_desc',nil,nil,4},
		showDrills = {'bool',TRUE,nil,'_opt_showDrills_desc'},
		showHighlighted = {'bool',TRUE,nil,'_opt_showHighlighted_desc'},
		showConvertedEnemy = {'bool',TRUE,nil,'_opt_showConvertedEnemy_desc2'},
		showBags = {'bool',TRUE,nil,'_opt_showBags_desc'},
		blurBackground = {'bool',TRUE,nil,'_opt_blurBackground_desc'},
		showNPCDistance = {'num',1,{0,2},'_opt_showNPCDistance_desc','Verbose'},
		showKillConfirm = {'bool',TRUE,nil,"_opt_showKillConfirm_desc"}
	}, game = {	'_opt_game_desc',
		ingameJoinRemaining = {'bool',TRUE,nil,'_opt_ingameJoinRemaining_desc',nil,nil,1},
		showRankInKickMenu = {'bool',TRUE,nil,'_opt_showRankInKickMenu_desc',nil,nil,1},
		corpseRagdollTimeout = {'num',3,{2,10},'_opt_corpseRagdollTimeout_desc','corpse',nil,3},
		subtitleFontSize = {'num',20,{10,30},'_opt_subtitleFontSize_desc',nil,nil,2},
		subtitleFontColor = {'color','White',nil,'_opt_subtitleFontColor_desc',nil,nil,2},
		subtitleOpacity = {'num',100,{10,100},'_opt_subtitleOpacity_desc',nil,10,2},
		truncateNames = {'num',1,{1,8},'_opt_truncateNames_desc','truncateNames',nil,4},
		truncateTags = {'bool',TRUE,nil,'_opt_truncateTags_desc',nil,nil,4},
		sortCrimenet = {'bool',TRUE,nil,'_opt_sortCrimenet_desc',nil,nil,5},
		gridCrimenet = {'bool',TRUE,nil,'_opt_gridCrimenet_desc',nil,nil,5},
		colorizeCrimenet = {'bool',FALSE,nil,'_opt_colorizeCrimenet_desc',nil,nil,5},
		resizeCrimenet = {'num',2,{1,5},'_opt_resizeCrimenet_desc','resizeCrimenet',nil,5},
		gainIndicator = {'num',2,{1,3},'_opt_gainIndicator_desc','cantedSight'},
		disableVanillaHit = {"bool",FALSE,nil,"_opt_disableVanillaHit_desc"}
	}, performance = { '_opt_performance_desc',
		blockBloodDecals = {"bool",FALSE,nil,"_opt_blockBloodDecals_desc",nil,nil},
		blockBulletDecals = {"bool",FALSE,nil,"_opt_blockBulletDecals_desc",nil,nil},
		blockCorpses = {"bool",FALSE,nil,"_opt_blockCorpses_desc",nil,nil},
		blockHelmets = {"bool",FALSE,nil,"_opt_blockHelmets_desc",nil,nil},
		blockMagazines = {"bool",FALSE,nil,"_opt_blockMagazines_desc",nil,nil},
		blockShields = {"bool",FALSE,nil,"_opt_blockShields_desc",nil,nil},
		reduceShotgunSpam = {"bool",FALSE,nil,"_opt_reduceShotgunSpam_desc",nil,nil}
	}, name_label = { '_opt_nameLabel_desc',
		showInfamyIcon = {"bool",TRUE,nil,"_opt_showInfamyIcon_desc",nil,nil},
		showLevelAndInfamy = {"bool",TRUE,nil,"_opt_showLevelAndInfamy_desc",nil,nil},
		showBoost = {"bool",TRUE,nil,"_opt_showBoost_desc",nil,nil},
		boostScale = {"num",1,{0.5,2.1},"_opt_boostScale_desc",nil,0.1}
	}
}
local _vanity = {
	ChatSend = '_vanity_chatsend',
	Verbose = '_vanity_verbose',
	align = '_vanity_align',
	style = '_vanity_style',
	Auto = '_vanity_auto',
	corpse = '_vanity_corpse',
	blendMode = '_vanity_blendMode',
	cantedSight = '_vanity_cantedsight',
	truncateNames = '_vanity_truncatenames',
	resizeCrimenet = '_vanity_resizeCrimenet',
	language = {EN='English', DA='Dansk', DE='Deutsch', ES='Español', FR='Français',ID = 'Bahasa Indonesia', IT='Italiano',NL='Nederlands',NO='Norsk',PL='Polski',PT='Português (PT)',PT_BR='Português (BR)', RU='Русский', KR='한국어(KR)', CN_HK='繁體中文 (香港)(CN_HK)',CN='简体中文 (中国大陆)(CN)' },
}
----------------------------------------------------
local SavePath = rawget(_G,'SavePath') or PocoDir
local JSONFileName = SavePath .. "hud3_config.json"

local Option = class()
PocoHud3Class.Option = Option
function Option:init()
	local mt = getmetatable(self)
	mt.__call = function(__, ...)
		return self:get(...)
	end
	setmetatable(self, mt)

	self:default()
	self.scheme = scheme
end

function Option:reset()
	os.remove(JSONFileName)
end

function Option:default(category)
	if category then
		self.items[category] = nil
	else
		self.items = {}
	end
end

function Option:load()
	local f = io.open(JSONFileName, "r")
	if f then
		local o
		local success, _ = pcall(function()
			o = JSON:decode(f:read("*all"))
		end)
		f:close()
		if success then
			if type(o) == "table" then
				self.items = o
			end
		else -- Savefile corrupted; remove it
			self:reset()
		end
	end
end

function Option:save()
	local f = io.open(JSONFileName, 'w')
	if f then
		f:write(JSON:encode_pretty(self.items))
		f:close()
	end
end

function Option:_type(category,name)
	return self:_get(true,category,name)[1]
end

function Option:_range(category,name)
	return self:_get(true,category,name)[3]
end

function Option:_hint(category,name)
	return self:_get(true,category,name)[4]
end

function Option:_vanity(category,name)
	local vanity = self:_get(true,category,name)[5]
	if vanity then
		vanity = _vanity[vanity] or vanity
	end
	return vanity
end

function Option:_step(category,name)
	return self:_get(true,category,name)[6]
end

function Option:_sort(category,name)
	return self:_get(true,category,name)[7]
end

function Option:set(category, name, value)
	self.items[category] = self.items[category] or {}
	self.items[category][name] = value
end

function Option:_get(isScheme, category, name)
	local o = isScheme and self.scheme or self.items
	local result = o[category] and o[category][name]
	if result == nil then
		if isScheme then
			_('_get was Nil', category, name) -- this should NOT happen
		end
		result = isScheme and {} or nil
	end
	return result
end

function Option:get(category,name,raw)
	if not name then
		return self:getCategory(category,raw)
	end
	local result = self:_get(false,category,name)
	if result == nil then
		result = self:_default(category,name)
	end
	if not raw then
		local type = self:_type(category,name)
		if type == 'color' then
			return cl[result] or cl.White
		end
	end
	return result
end

function Option:getCategory(category,raw)
	local result = {}
	for name in pairs(self.scheme[category] or {}) do
		result[name] = self:get(category,name,raw)
	end
	return result
end

function Option:_default(category,name)
	return self:_get(true,category,name)[2]
end

function Option:isDefault(category,name,value)
	return value == self:_default(category,name)
end

function Option:isChanged(category,name,value)
	return value ~= self:get(category,name)
end