-- version
local version = 1;
local remoteVersion = http.Get( "https://aw-cdn.ragesource.net/aw/version.txt" );
local skipVersionCheck = false
if remoteVersion == nil then
	print( "An error occured while checking for updates. Please try again." );
	return
elseif  version ~= tonumber( remoteVersion ) and skipVersionCheck == false then
	client.ChatTeamSay( "Download the newest version from www.aimware.net/forum/thread-96791.html" );
	return;
end

-- serverlist
print("getting server list...")
local SEServerList = http.Get( "https://aw-cdn.ragesource.net/aw/serverlist.txt" );
local SELocations = {};
for i in string.gmatch( SEServerList, "(.-);" ) do
   table.insert( SELocations, i );
   print( "#", i, SELocations[i] );
end
if SELocations[1] == nil then
	print( "An error occured while downloading the server list. Please try again" );
	return;
end


-- UI
local UI_MiscRef 					= gui.Reference( "MISC", "GENERAL", "Main" );
local UI_GroupBox 					= gui.Groupbox( UI_MiscRef, "Shared ESP" );
local UI_Enable 					= gui.Checkbox( UI_GroupBox, "se_enable", "Enable Shared ESP", 1 );

local UI_Location					= gui.Combobox( UI_GroupBox, "se_location", "Relay", table.unpack( SELocations ) );
local UI_MultiboxShare				= gui.Multibox( UI_GroupBox, "Share" )
local UI_ShareLP					= gui.Checkbox( UI_MultiboxShare, "se_share_localplayer", "Local Player", 1 );
local UI_ShareEnemy 				= gui.Checkbox( UI_MultiboxShare, "se_share_enemy", "Enemy", 1 )
local UI_ShareTeam					= gui.Checkbox( UI_MultiboxShare, "se_share_team", "Team", 1 );

local UI_MultiboxDraw				= gui.Multibox( UI_GroupBox, "Draw" )
local UI_DrawLP						= gui.Checkbox( UI_MultiboxDraw, "se_draw_localplayer", "Local Player", 0 );
local UI_DrawEnemy 					= gui.Checkbox( UI_MultiboxDraw, "se_draw_enemy", "Enemy", 1 )
local UI_DrawTeam					= gui.Checkbox( UI_MultiboxDraw, "se_draw_team", "Team", 1 );

local UI_DrawOnlyDormant			= gui.Checkbox( UI_GroupBox, "se_draw_only_dormant", "Draw Dormant Players Only", 0 );

-- Colors UI
local UI_ColorLP					= gui.ColorEntry( "se_color_lp", "Shared ESP Local Player", 7, 240, 231, 111);
local UI_ColorEnemy					= gui.ColorEntry( "se_color_enemy", "Shared ESP Enemy", 255, 255, 255, 255);
local UI_ColorTeam					= gui.ColorEntry( "se_color_team", "Shared ESP Team", 255, 0, 189, 158);
local UI_ColorFont					= gui.ColorEntry( "se_color_font", "Shared ESP Font", 255, 255, 255, 255);
local UI_ColorHealth				= gui.ColorEntry( "se_color_health", "Shared ESP Health",  80, 161, 255, 100);

-- Visual Options UI
local UI_VisBox 					= gui.Checkbox( UI_GroupBox, "se_vis_box", "2D Box", 1 );
local UI_VisHealth 					= gui.Checkbox( UI_GroupBox, "se_vis_health", "Health Bar", 1 );
local UI_VisHealthNumber			= gui.Checkbox( UI_GroupBox, "se_vis_health_nr", "Health Number", 1 );
local UI_VisName					= gui.Checkbox( UI_GroupBox, "se_vis_name", "Name", 1 );
local UI_VisWeapon 					= gui.Checkbox( UI_GroupBox, "se_vis_weapon", "Weapon", 1 );
local UI_VisAmmo 					= gui.Checkbox( UI_GroupBox, "se_vis_ammo", "Ammo", 1 );


local UI_TeamBasedColor				= gui.Checkbox( UI_GroupBox, "se_teambased_color", "Team Based Colors", 0 );

-- Settings
local SEEnable 		= gui.GetValue( "se_enable" );
local SEShareLP 	= gui.GetValue( "se_share_localplayer" );
local SEShareEnemy 	= gui.GetValue( "se_share_enemy" );
local SEShareTeam 	= gui.GetValue( "se_share_team" );

local SEDrawLP		= gui.GetValue( "se_draw_localplayer" );
local SEDrawEnemy	= gui.GetValue( "se_draw_enemy" );
local SEDrawTeam 	= gui.GetValue( "se_draw_team" );

local SEColorLP		= { gui.GetValue( "se_color_lp" ) };
local SEColorEnemy	= { gui.GetValue( "se_color_enemy" ) };
local SEColorTeam	= { gui.GetValue( "se_color_team" ) };
local SEColorFont	= { gui.GetValue( "se_color_font" ) };
local SEColorHealth	= { gui.GetValue( "se_color_health" ) };

local SEDrawOnlyDormant = gui.GetValue( "se_draw_only_dormant" );

local SEVisBox 		= gui.GetValue( "se_vis_box" );
local SEVisHealth 	= gui.GetValue( "se_vis_health" );
local SEVisHealthNr = gui.GetValue( "se_vis_health_nr" );
local SEVisName 	= gui.GetValue( "se_vis_name" );
local SEVisWeapon 	= gui.GetValue( "se_vis_weapon" );
local SEVisAmmo 	= gui.GetValue( "se_vis_ammo" );


local SETeamBasedColor = gui.GetValue( "se_teambased_color" );

local SEServerAddress 		= SELocations[ gui.GetValue( "se_location" ) ];
local SEServerAddressOld 	= SEServerAddress;

-- Tiktok
local SETicksSinceRoundstart = 0;

-- NetZZZwerk
local SESocket = network.Socket( "UDP" );
local SEServerPort = "12345";

local SEServerIP = network.GetAddrInfo( SEServerAddress );
local SEClientPort = "1337";

-- XD"""Entities"""XD
local _players = entities.FindByClass( "CCSPlayer" );
local _localPlayer = entities.GetLocalPlayer();
local _sharedPlayers = {};

-- weapon table
local weaponTab = {
	["knife"] 	= 1,
	["glock"] 	= 2,
	["elite"] 	= 3,
	["p250"] 	= 4,
	["tec9"] 	= 5,
	["deagle"] 	= 6,
	["nova"] 	= 7,
	["xm1014"] 	= 8,
	["sawedoff"] = 9,
	["m249"] 	= 10,
	["negev"] 	= 11,
	["mac10"] 	= 12,
	["mp7"] 	= 13,
	["ump45"] 	= 14,
	["p90"] 	= 15,
	["bizon"] 	= 16,
	["galilar"] = 17,
	["ak47"] 	= 18,
	["ss08"] 	= 19,
	["ssg553"] 	= 20,
	["awp"] 	= 21,
	["g3sg1"] 	= 22,
	["taser"] 	= 23,
	["c4"] 		= 24,
	["smokegrenade"] 	= 25,
	["hegrenade"] 		= 26,
	["flashbang"] 		= 27,
	["molotovgrenade"] 	= 28,
	["decoygrenade"] 	= 29,
	["shield"] 			= 30,
	["item_healthshot"] = 31,
	["hkp2000"] 		= 32,
	["fiveseven"] 		= 33,
	["mag7"] 			= 34,
	["hkp2000"] 		= 35,
	["mp9"] 			= 36,
	["famas"] 			= 37,
	["m4a1"] 			= 38,
	["aug"] 			= 39,
	["scar20"] 			= 40,
	["unknown"]			= 99
}

-- Functions
function find(tbl, val)
    for k, v in pairs(tbl) do
        if v == val then return k end
    end
    return "unknown"
end


local function fnGetServerIP()
    return( engine.GetServerIP() );
end

local function fnUpdateSettings()
	SEEnable 		= gui.GetValue( "se_enable" );
	
	SEShareLP 		= gui.GetValue( "se_share_localplayer" );
	SEShareEnemy 	= gui.GetValue( "se_share_enemy" );
	SEShareTeam 	= gui.GetValue( "se_share_team" );
	
	SEDrawLP 	= gui.GetValue( "se_draw_localplayer" );
	SEDrawEnemy = gui.GetValue( "se_draw_enemy" );
	SEDrawTeam 	= gui.GetValue( "se_draw_team" );
	
	SEColorLP		= { gui.GetValue( "se_color_lp" ) };
	SEColorEnemy	= { gui.GetValue( "se_color_enemy" ) };
	SEColorTeam		= { gui.GetValue( "se_color_team" ) };
	SEColorFont		= { gui.GetValue( "se_color_font" ) };
	SEColorHealth	= { gui.GetValue( "se_color_health" ) };

	SEDrawOnlyDormant = gui.GetValue( "se_draw_only_dormant" );
	
	SEVisBox 		= gui.GetValue( "se_vis_box" );
	SEVisHealth 	= gui.GetValue( "se_vis_health" );
	SEVisHealthNr 	= gui.GetValue( "se_vis_health_nr" );
	SEVisName 		= gui.GetValue( "se_vis_name" );
	SEVisWeapon 	= gui.GetValue( "se_vis_weapon" );
	SEVisAmmo 		= gui.GetValue( "se_vis_ammo" );
	
	SETeamBasedColor = gui.GetValue( "se_teambased_color" );
	
	SEServerAddress = SELocations[ gui.GetValue( "se_location" ) + 1];
	if SEServerAddress ~= SEServerAddressOld then
		print( "Host:", SEServerAddress );
		SEServerIP = network.GetAddrInfo( SEServerAddress );
		print( "IP:", SEServerIP );
		SEServerAddressOld = SEServerAddress;		
	end
end

local function fnDispatch( dispatchString )
	--print(dispatchString)
	SESocket:SendTo( SEServerIP, SEServerPort, dispatchString );
end

local function fnSplitString(str, sep)
    if (sep == nil) then
        sep = "%s"
    end

    local tab = {}
	
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(tab, str)
    end
	
    return tab
end


local function fnStringifyPlayer( player )
	local absOriginX, absOriginY, absOriginZ = player:GetAbsOrigin();
	absOriginX = math.modf( absOriginX * 100 ) / 100;
	absOriginY = math.modf( absOriginY * 100 ) / 100;
	absOriginZ = math.modf( absOriginZ * 100 ) / 100;
	
	local index = player:GetIndex();
	local isDuck = 0;
	local maxs = { player:GetMaxs() }
	if maxs[3] <= 70 then
		isDuck = 1;
	end
	
	local hp = player:GetHealth();
	
	local weapon = player:GetPropEntity("m_hActiveWeapon")
	local weaponNr = nil;
	local ammo = nil;
    if (weapon ~= nil) then
        local weapon_name = weapon:GetClass()
        weapon_name = weapon_name:gsub("CWeapon", "")
        weapon_name = weapon_name:gsub("CKnife", "knife")
        weapon_name = weapon_name:lower()

        if (weapon_name:sub(1, 1) == "c") then
            weapon_name = weapon_name:sub(2)
        end

        ammo = weapon:GetPropInt("m_iClip1")
		local max_ammo = weapon:GetPropInt("m_iPrimaryReserveAmmoCount")
		weaponNr = weaponTab[weapon_name];
    end
	
	if weaponNr == nil then
	    weaponNr = 99;
	end
	
	if ammo == nil then
		ammo = 99;
	end

	
	return { index, absOriginX, absOriginY, absOriginZ, isDuck, hp, weaponNr, ammo };
end

local function fnCreateMoveCb()
	fnUpdateSettings();
	if SEEnable == false then
		return;
	end
	
	-- assign entities
	_players = entities.FindByClass( "CCSPlayer" );
	_localPlayer = entities.GetLocalPlayer();
	
	local dispatchTable = { fnGetServerIP(), SETicksSinceRoundstart }
	local dispatchString = nil;
	
	for i = 1, #_players do
		local player = _players[i];
		
		
		if ( SEShareLP == false and player:GetIndex() == client.GetLocalPlayerIndex() ) then
			-- continue doesn't exist in lua, lolz
			goto skipSend; 
		end
		
		if ( SEShareTeam == false and player:GetTeamNumber() == _localPlayer:GetTeamNumber() and player:GetIndex() ~= client.GetLocalPlayerIndex() ) then
			goto skipSend;
		end
		
		if ( SEShareEnemy == false and player:GetTeamNumber() ~= _localPlayer:GetTeamNumber() and player:GetIndex() ~= client.GetLocalPlayerIndex() ) then
			goto skipSend;
		end
		
		local strPlayer = fnStringifyPlayer( player );
		strPlayer = table.concat( strPlayer, "," );
		table.insert( dispatchTable, strPlayer );
		-- dispatchTable[i] = strPlayer;
		
		dispatchString = table.concat( dispatchTable, "|" );
		if string.len( dispatchString ) >= 1250 then
			fnDispatch( dispatchString );
			dispatchTable = { SETicksSinceRoundstart }
		end
		::skipSend::
	end
	fnDispatch( dispatchString );
	
	SETicksSinceRoundstart = SETicksSinceRoundstart + 1;
end

local function fnGameEventCb(event)
    if event:GetName() == "game_start" or event:GetName() == "round_start" or event:GetName() == "game_end" then
        SETicksSinceRoundstart = 0;
		_sharedPlayers = nil;
		fnDispatch( fnGetServerIP() .. "|" .. "reset" );
    end
end

local function fnDrawESP()
	if SEEnable == false then
		return;
	end


	sPlayers = _sharedPlayers;
	if sPlayers == nil then return; end
	
	for i = 1, #sPlayers do
		local index = tonumber( sPlayers[i]["index"] );
		local absOriginX = tonumber( sPlayers[i]["absOriginX"] );
		local absOriginY = tonumber( sPlayers[i]["absOriginY"] );
		local absOriginZ = tonumber( sPlayers[i]["absOriginZ"] );
		local isDuck = tonumber( sPlayers[i]["isDuck"] );
		local hp = tonumber( sPlayers[i]["hp"] );
		local weaponNr = tonumber( sPlayers[i]["weapon"] );
		local weapon = find( weaponTab, weaponNr );
		local ammo = tonumber( sPlayers[i]["ammo"] );
		
		if ( index == nil or absOriginX == nil or absOriginY == nil or absOriginZ == nil or hp == nil or weapon == nil ) then 
			goto skipDraw
		end
	
		local ent = entities.GetByIndex( index );
		
		-- useful information we need
		local lpIndex 	= client.GetLocalPlayerIndex();
		local lpTeamNr 	= _localPlayer:GetTeamNumber();
		local entIndex 	= index;
		if ent ~= nil then
			local entTeamNr	= ent:GetTeamNumber()
		end
		
		-- very poor dormancy check since I was unable to find something like m_bDormant in https://aimware.net/asset/txt/csgorecvprops.txt
		if SEDrawOnlyDormant then
			if ent ~= nil then
				goto skipDraw;
			end
		end
		
	
		-- we don't need to draw ourselves when being in first person
		if ( index == lpIndex and ( gui.GetValue("vis_thirdperson_dist") <= 0.1 ) ) then
			goto skipDraw;
		end		
		
		
		-- teamcheck n stuff	
		if ( SEDrawLP == false and index == lpIndex ) then
			-- continue still does not exist in lua -_-
			goto skipDraw; 
		end
		
		local enemy = true;
		
		if ent ~= nil then
			if ent:GetTeamNumber() == _localPlayer:GetTeamNumber() then
				enemy = false;
				if SEDrawTeam == false and index ~= lpIndex then
					goto skipDraw;
				end
			end
		end
	
		
	
		if SEDrawEnemy == false and enemy == true then
			goto skipDraw;
		end
	
		
		-- don't render *DEAD* people
		if hp <= 0 then goto skipDraw end
		
		-- maxs 16, 16, 72/54
		-- mins -16, -16, 0.0
		local topPos = absOriginZ + 72.0 + 10;
		if tonumber(isDuck) == 1 then
			topPos = absOriginZ + 54.0 + 10;
		end
		
		local botPos = absOriginZ - 10;
		
		local topW2S = { client.WorldToScreen( absOriginX, absOriginY, topPos ) };
		local botW2S = { client.WorldToScreen( absOriginX, absOriginY, botPos ) };
		
		local box = {}
		
		if (topW2S[1] ~= nil and topW2S[2] ~= nil and botW2S[1] ~= nil and botW2S[2] ~= nil) then
			local height = botW2S[2] - topW2S[2];
			local width = height / 2.2;
			local left = botW2S[1] - width / 2
			local right = (botW2S[1] - width / 2) + width
			local top = topW2S[2] + width / 5
			local bottom = topW2S[2] + height

			box = {left = left, right = right, top = top, bottom = bottom}
			
			-- setting colors for box
			draw.Color( SEColorEnemy[1], SEColorEnemy[2], SEColorEnemy[3], SEColorEnemy[4] );
			if enemy == false then
				draw.Color( SEColorTeam[1], SEColorTeam[2], SEColorTeam[3], SEColorTeam[4] );
			end
			if enemy == false and index == lpIndex then
				draw.Color( SEColorLP[1], SEColorLP[2], SEColorLP[3], SEColorLP[4] );
			end
			
			-- draw box
			if SEVisBox then
				draw.RoundedRect( left, top, right, bottom );
			end
			
			-- health bar
			if SEVisHealth then
				draw.Color( 0, 0, 0, 200 );
				draw.RoundedRectFill( left - 8,  top, left - 2, bottom );
				local hpMin = math.min( hp, 100 );
				local height = bottom - top - 1;

				local healthbarHeight = ( hpMin / 100 ) * height;
		
				draw.Color( SEColorHealth[1], SEColorHealth[2], SEColorHealth[3], SEColorHealth[4] );
				draw.RoundedRectFill( left - 7, bottom - healthbarHeight, left - 3, bottom - 1 );
			end
			
			-- health number
			if SEVisHealthNr then
				draw.Color ( SEColorFont[1], SEColorFont[2], SEColorFont[3], SEColorFont[4] );
				if SETeamBasedColor then
					draw.Color ( SEColorEnemy[1], SEColorEnemy[2], SEColorEnemy[3], SEColorEnemy[4] );
					
					if enemy == false then
						draw.Color( SEColorTeam[1], SEColorTeam[2], SEColorTeam[3], SEColorTeam[4] );
					end
					
					if index == lpIndex then
						draw.Color( SEColorLP[1], SEColorLP[2], SEColorLP[3], SEColorLP[4] );
					end
				end
				
				local x = right + 3;
				local y = top;
				draw.Text( x, y, hp );
				draw.TextShadow( x, y, hp );
			end
			
			
			-- nickname
			if SEVisName then
				local nickname = client.GetPlayerNameByIndex( entIndex );
				draw.Color ( SEColorFont[1], SEColorFont[2], SEColorFont[3], SEColorFont[4] );
				
				if SETeamBasedColor then
					draw.Color ( SEColorEnemy[1], SEColorEnemy[2], SEColorEnemy[3], SEColorEnemy[4] );
					
					if enemy == false then
						draw.Color( SEColorTeam[1], SEColorTeam[2], SEColorTeam[3], SEColorTeam[4] );
					end
					
					if index == lpIndex then
						draw.Color( SEColorLP[1], SEColorLP[2], SEColorLP[3], SEColorLP[4] );
					end
					
				end
				
				local x = left + (right - left) / 2;
				local y = top - 15;
				local w, h = draw.GetTextSize( nickname );
				x = x - w / 2;
				draw.Text( x, y, nickname );
				draw.TextShadow( x, y, nickname );
			end
			
			-- weapon
			if SEVisWeapon then
				draw.Color ( SEColorFont[1], SEColorFont[2], SEColorFont[3], SEColorFont[4] );
				local x = left + (right - left) / 2;
				local y = bottom;
				local w, h = draw.GetTextSize( weapon );
				x = x - w / 2;
				
				if SETeamBasedColor then
					draw.Color ( SEColorEnemy[1], SEColorEnemy[2], SEColorEnemy[3], SEColorEnemy[4] );
					
					if enemy == false then
						draw.Color( SEColorTeam[1], SEColorTeam[2], SEColorTeam[3], SEColorTeam[4] );
					end
					
					if index == lpIndex then
						draw.Color( SEColorLP[1], SEColorLP[2], SEColorLP[3], SEColorLP[4] );
					end
					
				end
				
				
				draw.Text( x, y, weapon );
				draw.TextShadow( x, y, weapon );
			end
			
			-- amo bar
			if SEVisAmmo then
				draw.Color ( SEColorFont[1], SEColorFont[2], SEColorFont[3], SEColorFont[4] );
				local x = left + (right - left) / 2;
				local y = bottom + 10;
				local w, h = draw.GetTextSize( ammo );
				x = x - w / 2;
			
				if SETeamBasedColor then
					draw.Color ( SEColorEnemy[1], SEColorEnemy[2], SEColorEnemy[3], SEColorEnemy[4] );
					
					if enemy == false then
						draw.Color( SEColorTeam[1], SEColorTeam[2], SEColorTeam[3], SEColorTeam[4] );
					end
					
					if index == lpIndex then
						draw.Color( SEColorLP[1], SEColorLP[2], SEColorLP[3], SEColorLP[4] );
					end
					
				end
				
				
				draw.Text( x, y, ammo );
				draw.TextShadow( x, y, ammo );
			end
			
		end
		
		
		local x, y = client.WorldToScreen( sPlayers[i]["absOriginX"], sPlayers[i]["absOriginY"], sPlayers[i]["absOriginZ"] );
		if x ~= nil and y ~= nil then
			--draw.FilledRect(x, y, x + 10, y + 10);
		end
		::skipDraw::
	end
end


local function fnDrawCb()
	local msg, ip, port = SESocket:RecvFrom( "0.0.0.0", SEClientPort, 1600 );
	
	if msg then
        local splittedMessage = fnSplitString( msg, "|" );
		--print(splittedMessage[1])
		_sharedPlayers = {}
		for i = 1, #splittedMessage do
			local tempString = fnSplitString( splittedMessage[i], "," );
			local player = {
				index = tempString[1];
				absOriginX = tempString[2],
				absOriginY = tempString[3],
				absOriginZ = tempString[4],
				isDuck = tempString[5],
				hp = tempString[6],
				weapon = tempString[7],
				ammo = tempString[8]
			};
			-- today's presentation: "why does lua suck so hard?"
			-- table.insert(tab, x) is 7!!! times slower than tab[i] = x
			_sharedPlayers[i] = player;
		end
    end
	
	fnDrawESP(_sharedPlayers);	
end

if SESocket:Bind( "0.0.0.0" , SEClientPort ) then
    print( "Socket listening on", SEClientPort );
end

-- listeners
client.AllowListener("game_start");
client.AllowListener("round_start");
client.AllowListener("game_end");

-- callbacks
callbacks.Register("FireGameEvent", fnGameEventCb);
callbacks.Register("CreateMove", "MoveEvent", fnCreateMoveCb);
callbacks.Register("Draw", fnDrawCb);