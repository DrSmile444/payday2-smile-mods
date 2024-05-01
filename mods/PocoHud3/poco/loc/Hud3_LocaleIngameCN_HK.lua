PocoLocale = {}

PocoLocale._BAGS = {
	ammo = '彈藥包',
	medic = '醫療箱',
	body = '尸體袋',
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
	_mob_gangster = '一名黑幫',
	_mob_gensec = '一名Gensec保安',
	_mob_heavy_swat = '一名重型特警',
	_mob_security = '一名保安',
	_mob_shield = '一名護盾',
	_mob_sniper = '一名狙擊手',
	_mob_spooc = '一名幻影',
	_mob_swat = '一名特警',
	_mob_tank = '一名重裝坦克',
	_mob_taser = '一名泰瑟',
	
	_msg_around = '[1] 的附近',
	_msg_captured = '[1] 已被主宰。[2]',
	_msg_converted = '[1] 已説服並轉化了 [2]。[3]',
	_msg_custody = '[1] 已被拘留',
	_msg_downed = '[1] 已倒地',
	_msg_downedWarning = '警告：[1] 剩餘0次倒地次數',
	_msg_minionLost = '[1] 失去了一名變節敵人 ([2][3])',
	_msg_minionShot = '[1] 誤擊 [2] 的變節敵人并使其受到傷害值 [3]',
	_msg_not_implemented = '暫時沒有實行',
	_msg_replenished = '[1] 回復生命值 [2]% [3]',
	_msg_replenishedDown = '(+[1] 倒地次數)',
	_msg_replenishedDownPlu = '(+[1] 倒地次數)',
	_msg_replenishedDownFak = '(急救包)',
	_msg_used_doctorbag = "[1] 已使用了一個醫療包 (+[2] [3])",
	_msg_used_doctorbag_down = "倒地次數",
	_msg_used_doctorbag_downs = "倒地次數",
	_msg_used_fak = "[1] 已使用了一個急救包",
	_msg_usedPistolMessiah = '已使用彌賽亞',
	_msg_usedPistolMessiahCharges = '[1] 充能次數',
	_msg_usedPistolMessiahChargesPlu = '[1] 充能次數',
	_msg_specOps = '一個蓋奇特別行動DLC物品已被拾取',
	_msg_havePagers = '你還能回答 [1] 個對講機',
	_msg_haveCivilians = '你還能擊殺 [1] 個平民',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = '鑽機',
	lance = '熱力鑽機',
	uload_database = '正在上傳',
	votingmachine2 = '投票機',
	hold_download_keys = '加密密鑰',
	hold_hack_comp = '安全檢查',
	hold_analyze_evidence = '證據解析',
	digitalgui = '定時鎖',
	huge_lance = '野獸鑽機',
	pd1_drill = '狂熱鑽機',
	cas_copy_usb = '賓客名單',
	are_laptop = '烟火控制駭入',
	invisible_interaction_open = '駭入中',
	process = '處理中',
	hold_charge_gun = '武器充能',
	security_station = '駭入'
}

PocoLocale._drillNamesGuess = {
	laptop = '駭入中',
	hack = '駭入中',
	drill = '鑽機',
	lance = '鑽機',
	saw = '電鋸',
	load = '加載中',
	copy = '拷貝中'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = '一個迷你保險箱',
	['e87e439e3e1a7313'] = '一個迷你鈦合金保險箱',
	['ad6fb7a483695e19'] = '一個保險箱',
	['dbfbfbb21eddcd30'] = '一個鈦合金保險箱',
	['3e964910f730f3d7'] = '一個巨型保險箱',
	['246cc067a20249df'] = '一個巨型鈦合金保險箱',
	['8834e3a4da3df5c6'] = '一個立式保險箱',
	['e3ab30d889c6db5f'] = '一個立式鈦合金保險箱',
	['4407f5e571e2f51a'] = '一扇門',
	['0afafcebe54ae7c4'] = '一扇鐵欄門',
	['1153b673d51ed6ad'] = '一輛Gensec卡車',
	['04080fd150a77c7f'] = '一輛撞毀的Gensec卡車',
	['0d07ff22a1333115'] = '一輛被伏擊的Gensec卡車',
	['a8715759c090b251'] = '一扇柵欄門',
	['a7b371bf0e3fd30a'] = '一個卡車鉸鏈',
	['07e2cf254ef76c5e'] = '一扇地庫鐵欄門',
	['d475830b4e6eda32'] = '一扇地庫門',
	['b2928ed7d5b8797e'] = '一扇鐵欄門',
	['43132b0a273df773'] = '一扇辦公室門',
	['b8ebd1a5a8426e52'] = '一個藝術品保險箱'
}

PocoLocale._drillOn = '放置的'
PocoLocale._drillAlmost = '剩餘不到10秒'
PocoLocale._drillDone = '已經完成'

PocoLocale._convertOwn = '自己'
PocoLocale._handsUp = '已投降'
PocoLocale._Intimidated = '已主宰'
PocoLocale._s = ''

PocoLocale._Someone = '其他'
PocoLocale._hours = '小時數'