PocoLocale = {}

PocoLocale._BAGS = {
	ammo = '弹药包',
	medic = '医疗箱',
	body = '尸体袋',
	fak = '急救包',
	grenades = '手雷箱'
}

PocoLocale._defaultLocaleData = {

	-- no need to translate this
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\ngabsF\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = '一名Gensec精英',
	_mob_cop = '一名警察',
	_mob_fbi = '一名FBI特工',
	_mob_fbi_heavy_swat = '一名FBI重型特警',
	_mob_fbi_swat = '一名FBI特警',
	_mob_gangster = '一名黑帮',
	_mob_gensec = '一名Gensec保安',
	_mob_heavy_swat = '一名重型特警',
	_mob_security = '一名保安',
	_mob_shield = '一名护盾',
	_mob_sniper = '一名狙击手',
	_mob_spooc = '一名幻影',
	_mob_swat = '一名特警',
	_mob_tank = '一名重装坦克',
	_mob_taser = '一名泰瑟',
	
	_msg_around = '[1] 的附近',
	_msg_captured = '[1] 已被主宰。[2]',
	_msg_converted = '[1] 已说服并转化了 [2]。[3]',
	_msg_custody = '[1] 已被拘留',
	_msg_downed = '[1] 已倒地',
	_msg_downedWarning = '警告：[1] 剩余0次倒地次数',
	_msg_minionLost = '[1] 失去了一名变节敌人 ([2][3])',
	_msg_minionShot = '[1] 误击 [2] 的变节敌人并使其受到伤害值 [3]',
	_msg_not_implemented = '暂时没有实行',
	_msg_replenished = '[1] 回复生命值 [2]% [3]',
	_msg_replenishedDown = '(+[1] 倒地次数)',
	_msg_replenishedDownPlu = '(+[1] 倒地次数)',
	_msg_replenishedDownFak = '(急救包)',
	_msg_used_doctorbag = "[1] 已使用了一个医疗包 (+[2] [3])",
	_msg_used_doctorbag_down = "倒地次数",
	_msg_used_doctorbag_downs = "倒地次数",
	_msg_used_fak = "[1] 已使用了一个急救包",
	_msg_usedPistolMessiah = '已使用弥赛亚',
	_msg_usedPistolMessiahCharges = '[1] 充能次数',
	_msg_usedPistolMessiahChargesPlu = '[1] 充能次数',
	_msg_specOps = '一个盖奇特别行动DLC物品已被拾取',
	_msg_havePagers = '你还能回答 [1] 个对讲机',
	_msg_haveCivilians = '你还能击杀 [1] 个平民',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = '钻机',
	lance = '热力钻机',
	uload_database = '正在上传',
	votingmachine2 = '投票机',
	hold_download_keys = '加密密钥',
	hold_hack_comp = '安全检查',
	hold_analyze_evidence = '证据解析',
	digitalgui = '定时锁',
	huge_lance = '野兽钻机',
	pd1_drill = '狂热钻机',
	cas_copy_usb = '宾客名单',
	are_laptop = '烟火控制骇入',
	invisible_interaction_open = '骇入中',
	process = '处理中',
	hold_charge_gun = '武器充能',
	security_station = '骇入'
}

PocoLocale._drillNamesGuess = {
	laptop = '骇入中',
	hack = '骇入中',
	drill = '钻机',
	lance = '钻机',
	saw = '电锯',
	load = '加载中',
	copy = '拷贝中'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = '一个迷你保险箱',
	['e87e439e3e1a7313'] = '一个迷你钛合金保险箱',
	['ad6fb7a483695e19'] = '一个保险箱',
	['dbfbfbb21eddcd30'] = '一个钛合金保险箱',
	['3e964910f730f3d7'] = '一个巨型保险箱',
	['246cc067a20249df'] = '一个巨型钛合金保险箱',
	['8834e3a4da3df5c6'] = '一个立式保险箱',
	['e3ab30d889c6db5f'] = '一个立式钛合金保险箱',
	['4407f5e571e2f51a'] = '一扇门',
	['0afafcebe54ae7c4'] = '一扇铁栏门',
	['1153b673d51ed6ad'] = '一辆Gensec卡车',
	['04080fd150a77c7f'] = '一辆撞毁的Gensec卡车',
	['0d07ff22a1333115'] = '一辆被伏击的Gensec卡车',
	['a8715759c090b251'] = '一扇栅栏门',
	['a7b371bf0e3fd30a'] = '一个卡车铰链',
	['07e2cf254ef76c5e'] = '一扇地库铁栏门',
	['d475830b4e6eda32'] = '一扇地库门',
	['b2928ed7d5b8797e'] = '一扇铁栏门',
	['43132b0a273df773'] = '一扇办公室门',
	['b8ebd1a5a8426e52'] = '一个艺术品保险箱'
}

PocoLocale._drillOn = '放置的'
PocoLocale._drillAlmost = '剩余不到10秒'
PocoLocale._drillDone = '已经完成'

PocoLocale._convertOwn = '自己'
PocoLocale._handsUp = '已投降'
PocoLocale._Intimidated = '已主宰'
PocoLocale._s = ''

PocoLocale._Someone = '其他'
PocoLocale._hours = '小时数'