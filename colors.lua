-- Use !colors on the server to see which character is which color

colors = {

	-- General
	weapon = "\fX";			-- weapon names
	errors = "\f3";			-- errors (missing or invalid user inputs)


	-- Players
	
	player_text = "\fQ";		-- default text color for every player

	unarmed_name = "\f2";		-- unarmed name
	moderator1_name = "\f9";	-- moderator L1 name
	moderator2_name = "\f9";	-- moderator L2 name
	admin_name = "\f3";		-- admin name


	-- !maptop, !mapbest, !mrank and MOTD 

	m_title = "\fF";
	m_rank = "\fH";
	m_name = "\fM";
	m_time = "\f9";
	m_date = "\f1";
	m_default = "\fJ";		-- single characters in strings (':'; '('; ')'; ',')
	m_empty = "\f3";		-- no records for a specific weapon
	m_weapon = "\fX";
	m_weapon_highlight = "\f2";
	
	
	-- !gtop and !grank
	
	g_title = "\fJ";
	g_rank = "\f8";
	g_name = "\fR";
	g_points = "\fU";
	g_best_times = "\fP";
	g_records = "\fP";
	g_default = "\fJ";
	g_empty = "\f3";
	g_weapon = "\fX";
	
	g_rank_total = "\fH";
	g_points_total = "\f9";
	g_best_times_total = "\fG";
	g_records_total = "\fK";
	g_weapon_total = "\f2";
	g_default_total = "\fM";
	
	
	-- onFlagAction
	flagaction_rank = "\fH";
	flagaction_norecord = "\f9";
	flagaction_name = "\fM";
	flagaction_default = "\fJ";
	flagaction_time = "\f9";
	
	
	-- MOTD
	motd_stats_norecord = "\f3";
	motd_stats_missing_weapons = "\f3";
	motd_stats_default = "\fJ";
	motd_stats_amount_players = "\fH";
	motd_stats_amount_weapons = "\fH";
	
	motd_best_default = "\fJ";
	motd_best_name = "\fM";
	motd_best_time = "\f9";
	
	
	-- onPlayerConnect
	playerconnect_autokick_name = "\f2";
	playerconnect_autokick_default = "\f3";
	
	playerconnect_greet_default = "\fJ";
	playerconnect_greet_name = "\f2";
	
	playerconnect_geoip_name = "\f2";
	playerconnect_geoip_cn = "\f1";
	playerconnect_geoip_country = "\f8";
	playerconnect_geoip_ip = "\f9";
	playerconnect_geoip_default = "\fJ";
	
	playerconnect_instruction_default = "\fF";
	playerconnect_instruction_command = "\fH";
	
	
	-- onPlayerDisconnect
	playerdisconnect_banned_name = "\f2";
	playerdisconnect_banned_default = "\f3";
	

	-- cmds

	cmds_title = "\fP";		-- title
	cmds_cmd = "\fN";		-- commands
	cmds_alias = "\f5";


	-- allcmds

	cmds_0_title = "\f2"; 		-- sub title (Level 0)
	cmds_0_cmd = "\fN";		-- commands (Level 0)

	cmds_1_title = "\f9";		-- sub title (Level 1)
	cmds_1_cmd = "\f8";		-- commands (Level 1)

	cmds_2_title = "\f9";		-- sub title (Level 2)
	cmds_2_cmd = "\f8";		-- commands (Level 2)

	cmds_admin_title = "\f3";	-- sub title (admin)
	cmds_admin_cmd = "\f3";		-- commands (admin)
	
	cmds_weapon_title = "\fG";
	cmds_weapon_default = "\fM";


	-- others
	
	special_warning = "\f3";	-- warnings while in special mode (knife/pistol only)
	no_permission = "\f3";

}
