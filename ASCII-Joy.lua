--[[
* Ashita - Copyright (c) 2014 - 2017 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--
--------------------------------------------------------------------------------------------------------------------------
-- Credit to Vicrelant for the data files for mobs and to Atom0s for his guidance and using his addons as a base for this.
--------------------------------------------------------------------------------------------------------------------------

addon.author  = 'Drusciliana';
addon.name    = 'ASCII-Joy';
addon.version = '1.0.5';
addon.desc = 'Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!';
addon.link = 'Discord name is just plain old D. (with the period), #2154 if that helps. Stay on top of updates! https://github.com/Drusciliana/ASCII-Joy';


require ('common')
local chat = require('chat');
local fonts = require('fonts');
local primitives = require('primitives')
local settings = require('settings');

-------------- START Global Variables
local default_settings =
T{
    options = T{
    party = 	true, 		
    solo = 		false, 		
    monster = 	true, 		
    moninfo = 	true, 
    monabov =   true,
	monsbab = 	false,		
    playwin =   true,
    zilda =	    false
	},
    partyfont = T{
        font_family = "Consolas",
		position_x = 400, 		
        position_y = 600,
		font_height = 10,
		color = 0xffffffff,
		bold = true,
		right_justified = true,
		locked = true,
		text = '',
		background = T{
			color = 0xff000000,
		    visible = true
		}
    },
    monsterfont = T{
        font_family = "Consolas",  		
		position_x = 800, 		
        position_y = 200,
		font_height = 10,
		color = 0xffffffff,
		bold = true,
		text = '',
		right_justified = true,
		locked = true,
		background = T{
			color = 0xff000000,
		    visible = true
		}
    },
    selffont = T{
        font_family = "Consolas",		
		position_x = 800, 		
        position_y = 600,
		font_height = 10,
		color = 0xffffffff,
		bold = true,
		text = '',
		locked = true,
		background = T{
			color = 0xff000000,
		    visible = true
		}
    },
};

local tick = 0;
local LastZone = 9999; -- To remember when we are zoning.
local mb_data = {};
local arraySize = 0;
local HeartNum = {};
local HeartContainer = 
	--Lame attempt at an array (only way I could get new primitive library to work. PrimitiveManager handled textures differently it seems).
{
	[1] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[2] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[3] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[4] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[5] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[6] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[7] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[8] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[9] = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
	[10]= { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
    [11]= { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} },
    [12]= { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} }
};

local jobs = {
	[0]  = '   ', -- Some Trust party npc's on some servers actually are set to 0 for job or subjob. 
	[1]  = 'WAR',
	[2]  = 'MNK',
	[3]  = 'WHM',
	[4]  = 'BLM',
	[5]  = 'RDM',
	[6]  = 'THF',
	[7]  = 'PLD',
	[8]  = 'DRK',
	[9]  = 'BST',
	[10] = 'BRD',
	[11] = 'RNG',
	[12] = 'SAM',
	[13] = 'NIN',
	[14] = 'DRG',
	[15] = 'SMN',
	[16] = 'BLU',
	[17] = 'COR',
	[18] = 'PUP',
	[19] = 'DNC',
	[20] = 'SCH',
	[21] = 'GEO',
	[22] = 'RUN'
};

local ascii = T{
	font_e = nil,
	font_m = nil,
	font_n = nil,
	font_o = nil,
	font_p = nil,
	font_q = nil,
	font_r = nil,
	font_s = nil,
	font_t = nil,
	font_u = nil,
    font_f = T{ },	
	font_g = T{ },
	font_h = T{ },
	-------
    settings = settings.load(default_settings)
}
------------ END Global Variables

local function update_settings(s)

    if (s ~= nil) then
        ascii.settings = s;
    end

	if (ascii.font_e ~= nil) then
        ascii.font_e:apply(ascii.settings.partyfont);
    end
	if (ascii.font_m ~= nil) then
        ascii.font_m:apply(ascii.settings.monsterfont);
    end
	if (ascii.font_n ~= nil) then
        ascii.font_n:apply(ascii.settings.monsterfont);
    end
	if (ascii.font_o ~= nil) then
        ascii.font_o:apply(ascii.settings.monsterfont);
    end
	if (ascii.font_p ~= nil) then
        ascii.font_p:apply(ascii.settings.monsterfont);
    end
	if (ascii.font_q ~= nil) then
        ascii.font_q:apply(ascii.settings.selffont);
    end
	if (ascii.font_r ~= nil) then
        ascii.font_r:apply(ascii.settings.selffont);
    end
	if (ascii.font_s ~= nil) then
        ascii.font_s:apply(ascii.settings.selffont);
    end
	if (ascii.font_t ~= nil) then
        ascii.font_t:apply(ascii.settings.selffont);
    end
	if (ascii.font_u ~= nil) then
        ascii.font_u:apply(ascii.settings.selffont);
    end
    ascii.font_f:each(function (v, _)
        if (v ~= nil) then
            v:apply(ascii.settings.partyfont);
        end
    end);
	ascii.font_g:each(function (v, _)
        if (v ~= nil) then
            v:apply(ascii.settings.partyfont);
        end
    end);
	ascii.font_h:each(function (v, _)
        if (v ~= nil) then
            v:apply(ascii.settings.partyfont);
        end
    end);

    settings.save();
end
--[[
* Registers a callback for the settings to monitor for character switches.
--]]
settings.register('settings', 'settings_update', update_settings);

local function save_everything() -- Need this to save window locations, so not to assign values every render call.
	ascii.settings.selffont.position_x = ascii.font_q.position_x;
	ascii.settings.partyfont.position_x = ascii.font_e.position_x;
	ascii.settings.monsterfont.position_x = ascii.font_m.position_x;
	ascii.settings.selffont.position_y = ascii.font_q.position_y; 
	ascii.settings.partyfont.position_y = ascii.font_e.position_y;
	ascii.settings.monsterfont.position_y = ascii.font_m.position_y;
    settings.save();
end
----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function ()

--[[ HEART CONTAINERS
    Make an array and have the textures change similar to a mechanical slot machine.
 	    Rotate the Y axis along the X axis to get our result line, essentially)
		Why have 17 when I can have 60 textures! (PrimitiveManager could make my Heart Life Bar in 17.)]]
    for x = 1, 12 do
		for y = 1, 5 do  
		HeartContainer[x][y] = primitives.new();
		HeartContainer[x][y].position_x = 0;
        HeartContainer[x][y].position_y = 0;
	    HeartContainer[x][y].width = 48;
	    HeartContainer[x][y].height = 48;
	    HeartContainer[x][y].color = 0xffffffff;
		HeartContainer[x][y].texture = ('%s\\addons\\%s\\icons\\%s.png'):fmt(AshitaCore:GetInstallPath(),'ASCII-Joy', y);
        HeartContainer[x][y].visible = false;
	    end
    end

-- Monster Window labels
    ascii.font_m = fonts.new(ascii.settings.monsterfont);
	ascii.font_n = fonts.new(ascii.settings.monsterfont);
    ascii.font_o = fonts.new(ascii.settings.monsterfont);
    ascii.font_p = fonts.new(ascii.settings.monsterfont);
---- Player Window labels
    ascii.font_q = fonts.new(ascii.settings.selffont);
    ascii.font_r = fonts.new(ascii.settings.selffont);
    ascii.font_s = fonts.new(ascii.settings.selffont);
    ascii.font_t = fonts.new(ascii.settings.selffont);
    ascii.font_u = fonts.new(ascii.settings.selffont);
---- Party Window labels
    ascii.font_e = fonts.new(ascii.settings.partyfont);
--    for x = 0, 17 do  -- Not ready do try alliance yet
    for x = 0, 5 do
        ascii.font_f[x] = fonts.new(ascii.settings.partyfont);
        ascii.font_g[x] = fonts.new(ascii.settings.partyfont);
        ascii.font_h[x] = fonts.new(ascii.settings.partyfont);
    end

-- Get Info and what not for Mobs upon loading the addon.
    ZoneIDStart = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    _, mb_data = pcall(require,'data.'..tostring(ZoneIDStart));
    if (mb_data == nil or type(mb_data) ~= 'table') then
        mb_data = { };
    end
    arraySize = #(mb_data);

    print(chat.header(addon.name):append(chat.message('Please type /ASCII-Joy to bring up the *extensive* addon menu.')));

end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function ()

    save_everything();

    if (ascii.font_e ~= nil) then
	    ascii.font_e:destroy();
	    ascii.font_e = nil;
    end
    if (ascii.font_m ~= nil) then
	    ascii.font_m:destroy();
	    ascii.font_m = nil;
    end
    if (ascii.font_n ~= nil) then
	    ascii.font_n:destroy();
	    ascii.font_n = nil;
    end
    if (ascii.font_o ~= nil) then
	    ascii.font_o:destroy();
	    ascii.font_o = nil;
    end
    if (ascii.font_p ~= nil) then
	    ascii.font_p:destroy();
	    ascii.font_p = nil;
    end
    if (ascii.font_q ~= nil) then
	    ascii.font_q:destroy();
	    ascii.font_q = nil;
    end
    if (ascii.font_r ~= nil) then
	    ascii.font_r:destroy();
	    ascii.font_r = nil;
    end
    if (ascii.font_s ~= nil) then
	    ascii.font_s:destroy();
	    ascii.font_s = nil;
    end
    if (ascii.font_t ~= nil) then
	    ascii.font_t:destroy();
	    ascii.font_t = nil;
    end
    if (ascii.font_u ~= nil) then
	    ascii.font_u:destroy();
	    ascii.font_u = nil;
    end
    if (ascii.font_f ~= nil) then
	    ascii.font_f:each(function (v, _)
		    v:destroy();
	    end);
	    ascii.font_f = T{ };
    end
    if (ascii.font_g ~= nil) then
	    ascii.font_g:each(function (v, _)
		    v:destroy();
	    end);
	    ascii.font_g = T{ };
    end
    if (ascii.font_h ~= nil) then
	    ascii.font_h:each(function (v, _)
		    v:destroy();
	    end);
	    ascii.font_h = T{ };
    end
    if (HeartContainer ~= nil) then
        for x = 1, 12 do
            for y = 1, 5 do
		        HeartContainer[x][y].visible = false;
		        HeartContainer[x][y]:destroy();
	        end;
	    end;
	    HeartContainer = T{ };
    end    
end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'present_cb', function ()
    -- Obtain needed information managers..
    local party     = AshitaCore:GetMemoryManager():GetParty();
    local target    = AshitaCore:GetMemoryManager():GetTarget();  
    local player    = AshitaCore:GetMemoryManager():GetPlayer();
    local playerent = GetPlayerEntity(); 

    -- Don't show the party window if we're alone? Also need that playerfound for making entities for personal stats. Ugh.
    local playerfound = 99;
    local solo = 0; 
    for x = 0, 5 do --** Alliance may be different
	    if(player ~= nil and playerent ~= nil) then
            if(playerent.TargetIndex == party:GetMemberTargetIndex(x)) then
	        playerfound = x;
	    end
	    if (party:GetMemberIsActive(x) == 1) then
	        solo = solo + 1;
	    end
	end
    end
		--** Hopefully cleans and fixes everything up while zoning or loading
    if (player:GetMainJobLevel() == 0) then 
	    for x = 0, 5 do --** May be different for alliance.
	       ascii.font_f[x].visible = false;
	       ascii.font_g[x].visible = false;
	       ascii.font_h[x].visible = false;
	    end
		for x = 1, 12 do
			for y = 1, 5 do
			    HeartContainer[x][y].visible = false;
			end	
		end
	    ascii.font_e.visible = false;
	    ascii.font_m.visible = false;
	    ascii.font_n.visible = false;
	    ascii.font_o.visible = false;
	    ascii.font_p.visible = false;
	    ascii.font_q.visible = false;
	    ascii.font_r.visible = false;
	    ascii.font_s.visible = false;
	    ascii.font_t.visible = false;
	    ascii.font_u.visible = false;
	    return;
	else
		ascii.font_e.locked = false; -- Seem to have to have these here.
        ascii.font_m.locked = false; -- Declaring these (not true) doesn't work, from the settings making all set true.
		ascii.font_q.locked = false; -- Oh well.
    end 
		  -- *** START HERE ***
    tick = tick + 1;
    if (tick >= 30) then
       	tick = 0;
    end
				--** Changing zones? Pull a new data file
    ZoneIDStart = party:GetMemberZone(playerfound);
	----** WE NEED DATAFILES EVEN WITHOUT MONSTER WINDOW TO COMPARE NPC's, MONSTERS, OBJECTS, PLAYERS, etc. FOR TARGET WINDOW! MAYBE?
    if (ZoneIDStart > 0 and LastZone ~= ZoneIDStart) then  -- We're not in some limbo zone, and we're in a different zone than before.
        local zonefile = io.open(('%s\\addons\\ASCII-Joy\\data\\%s.lua'):fmt(AshitaCore:GetInstallPath(), tostring(ZoneIDStart)), 'r');
        if (zonefile ~= nil) then -- We have a file.
  	        io.close(zonefile); 
  	        _, mb_data = pcall(require,'data.'..tostring(ZoneIDStart));
	        if (mb_data == nil or type(mb_data) ~= 'table') then
	            mb_data = { };
	        end
	        arraySize = #(mb_data);
	        LastZone = ZoneIDStart; -- Make these match to compare zoning.
	        save_everything();  -- Let's also save when we zone.
	    end
    end
-------- Party Window
    if (ascii.settings.options.party == true) then
        local cury = 0;
        local newy = 0;
        local spcy = 0;
        local leadstar = '|r ';
        local partyfontsize = ascii.settings.partyfont.font_height;
        local fontsize = ((partyfontsize * 2) - 1);
		local elsewhere = true;
        for x = 0, 5 do  
		    elsewhere = true;
	        if (party:GetMemberIsActive(x) == 0) then
	           ascii.font_f[x].visible = false;
	           ascii.font_g[x].visible = false;
	           ascii.font_h[x].visible = false;
            else
	            if(party:GetMemberZone(playerfound) == party:GetMemberZone(x)) then
		            elsewhere = false;  
	            end
        ----- Setup Party Window (NEATEST I THINK I CAN MAKE IT, WORKS BEST ON 10 POINT FONTS at 1920x1080)
	    ----- "cur" is Health, "new" is Mana, "spc" is blank line between party members
	            spcy =ascii.font_e.GetPositionY() - (x * (3*(fontsize + 2)));	    
	            newy = spcy - 2 - fontsize;
	            cury = newy - 2 - fontsize;

               ascii.font_f[x].position_x = ascii.font_e.position_x;
               ascii.font_f[x].position_y = cury;
	           ascii.font_f[x].bold = true;

	            local ZoneName = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(x));
	            local Name = party:GetMemberName(x);
	            local Health = party:GetMemberHP(x);
                local HPValue = party:GetMemberHPPercent(x);
	            local HPCheck = math.floor(HPValue / (100/20)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
	            local HealthStr = '';
	            local HPColor = '';
                local hResult = '|c00000000|____________________|r';
	            local NameColor = '|cff00ffff|';
   	            local Output = '';
	            local OutTwo = '';
	            local OutThr = '';

    ----  Name Color Matching if Target is in Party
                if (target == nil) then
	                NameColor = '|cff00ffff|';
                else
                    local ID = party:GetMemberTargetIndex(x);
		            local TargetID = target:GetTargetIndex(0);
                    if (ID == TargetID and elsewhere == false) then -- Have seen far away people with purple names.
                        NameColor = '|cff7f2be2|';
                    else
                        NameColor = '|cff00ffff|';
	                end
	            end
	
    ---- Find Color for HP Bar and Overall HP Output
   	            if (HPValue >= 100) then 
		            HPColor = '|cff00ff00|';
	            elseif (HPValue >= 75) then
		            HPColor = '|cff008000|';
	            elseif (HPValue >= 50) then
		            HPColor = '|cffffff00|';
	            elseif (HPValue >= 25) then	
		            HPColor = '|cffffA000|';
	            elseif (HPValue >= 13) then 
		            HPColor = '|cffff0000|';
	            else
		            HPColor = '|c80A00000|';
	            end

	            if (HPValue <= 0) then
	                hResult = '        |cffaf0000|DEAD        |r';
	            else
                    hResult = string.gsub(hResult,'_',HPColor..'#|c00000000|',HPCheck);	
	            end

	            HealthStr = tostring(Health);
    	        while HealthStr:len() < 4 do 
		            HealthStr = " "..HealthStr; 
	            end

    ---- Format Player names to 10 characters
	            while Name:len() < 10 do 
		            Name = " "..Name; 
	            end
                Name = string.sub(Name, 1, 10);
		
    -------- Get Party Mana, TP, Class
	            local Mana = party:GetMemberMP(x);
                local MaValue = party:GetMemberMPPercent(x);
	            local MaCheck = math.floor(MaValue / (100/13)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                local mResult = '|r||c00000000|_____________|r|';
	            local MaColor = '|r';
	            local TP = party:GetMemberTP(x);
	            local TPColor = '|c77777777|';
	            local MJob = '';
	            local SJob = '';
	            local TJob = '';
	            local ManaStr = '';
		        local TPValue = '';

                ascii.font_g[x].position_x = (ascii.font_e.position_x);
                ascii.font_g[x].position_y = (newy);
	            ascii.font_g[x].bold = (true);
                ascii.font_h[x].position_x = (ascii.font_e.position_x);
                ascii.font_h[x].position_y = (spcy);
	            ascii.font_h[x].bold = (true);

    ---- Get Party Members' Job(s)
			    if (party:GetMemberMainJob(x) == nil or party:GetMemberMainJob(x) == 0 or party:GetMemberMainJob(x) > 22) then
				    TJob = 'NPC';
			    else	
					MJob = jobs[party:GetMemberMainJob(x)];
	                if (party:GetMemberSubJobLevel(x) ~= nil and party:GetMemberSubJobLevel(x) > 0 and party:GetMemberSubJob(x) ~= nil) then
	   	                SJob = '/'..jobs[party:GetMemberSubJob(x)];
	                end
	                TJob = MJob..SJob;
    	            while TJob:len() < 7 do 
		                TJob = " "..TJob; 
					end
	            end

    ---- Get Color of Mana bar and Overall Mana Output
   	            if (MaValue >= 100) then 
		            MaColor = '|cffff1493|';
	            else
		            MaColor = '|cffff69b4|';
	            end

	            ManaStr = tostring(Mana);
	            while ManaStr:len() < 3 do 
		            ManaStr = " "..ManaStr; 
	            end
                mResult = string.gsub(mResult,'_',MaColor..'@|c00000000|',MaCheck);

    ---- Get Color for TP
	            if (TP >= 1000) then
		            TPColor = '|cff00FF00|';
	            else
		            TPColor = '|cffc0c0c0|';
	            end

	            TPValue = tostring(TP);
    	        while TPValue:len() < 4 do 
		            TPValue = " "..TPValue; 
	            end

    ---- Final Window Output
	            if (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId1()) then
		            leadstar = '|cffffff00|*|r';
	            elseif (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId2()) then
		            leadstar = '|cffffff00|*|r';
	            elseif (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId3()) then
		            leadstar = '|cffffff00|*|r';
	            else
		            leadstar = '|r ';
	            end

	            if (solo <= 1 and ascii.settings.options.solo == true) then
		            OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(playerfound));;
	                while OutThr:len() < 35 do
	                    OutThr = " "..OutThr;
		            end
		            OutThr = string.sub(OutThr, 1, 35);
	 	            OutThr = " "..OutThr.." ";
	                ascii.font_e.visible = true;
	                ascii.font_e.text = tostring(OutThr);
	                ascii.font_f[x].visible = false;
	                ascii.font_g[x].visible = false;
  	                ascii.font_h[x].visible = false;   
    	        else
	                ascii.font_f[x].visible = true;
                    ascii.font_g[x].visible = true;
					ascii.font_e.bold = true;
	                ascii.font_e.visible = true;

        	        if (HPValue <= 33 and elsewhere == false) then
            	        if (tick >= 15) then
                           ascii.font_f[x].background.color = 0x5fff0000;
                        else
                	       ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                        end
                    else
            	       ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
		            end

	                if (elsewhere == false) then      			-- Try to put in Zone Name for far away friends
                        Output = (NameColor..Name..leadstar..'|'..hResult..'||cff00ff00|'..HealthStr);
	                    OutTwo = (TPColor..'     '..TPValue..'  '..mResult..'|cffff69b4|'..ManaStr..' |cffffffff|'..TJob);
	                    ascii.font_f[x].text = tostring(Output);
	                    ascii.font_g[x].text = tostring(OutTwo);
	                else 
		                if (ZoneName == nil) then
			                ZoneName = 'BROKEN PLAYER ZONE';
		                end
	 	                while ZoneName:len() < 21 do
		                    ZoneName = " "..ZoneName;
		                end
		                ZoneName = string.sub(ZoneName, 1, 21);

	                    Output = (NameColor..Name..leadstar..'| |cc0c0c0c0|'..' '..tostring(ZoneName)..'|r  ');
	 	                OutTwo = '                                     ';
	                    ascii.font_f[x].text = tostring(Output);
	                    ascii.font_g[x].text = tostring(OutTwo);
	                end	    
	            end

	            if (x == playerfound) then      -- We only want the bottom line to be moveable: "e"
		            OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(playerfound));;
	                while OutThr:len() < 35 do
	                    OutThr = " "..OutThr;
		            end
		            OutThr = string.sub(OutThr, 1, 35);
	 	            OutThr = " "..OutThr.." ";
	                ascii.font_h[x].visible = false;
		            ascii.font_e.visible = true;
		            ascii.font_e.text = OutThr;
	            else
		            OutThr = '                                     ';
	                ascii.font_e.visible = true; 
	    	        ascii.font_h[x].visible = true;
 	                ascii.font_h[x].text = tostring(OutThr);
	            end
            end
        end
    else
 	   ascii.font_e.visible = (false);
	    for x = 0, 5 do --** May be different for alliance
	        ascii.font_f[x].visible = false;
	        ascii.font_g[x].visible = false;
	        ascii.font_h[x].visible = false;
	    end
		for x = 1, 12 do
			for y = 1, 5 do
			    HeartContainer[x][y].visible = false;
			end	
		end
    end
-------- END Party Window

-------- Monster Window
    if (ascii.settings.options.monster == true) then
	    local TarID = 0;
	    local tarmob = nil;  -- Entity
	    local submob = nil;  -- Entity
	    local NoMob = true;
	    local spawn = 0;
	    local tarserverid = 0;
	    local MobHPP = 0;
	    local MobHPCheck = 0;
	    local MobStr = '';
	    local MobName = '';
	    local MobJob = '   '; -- Placeholder
	    local OutFou = '';
	    local OutFiv = '';
	    local OutSix = '';
	    local OutSev = '';
        local MobAggro = '';
        local MobHPColor = '|cffff0000|';
        local mobResult = '|c00000000|_____________________________________________|r'
	    local MobInfo = '                                     ';
	    local MobWeak = '             Monster Info unavailable';
	    local monsterfontsize = ascii.settings.monsterfont.font_height;

   ---- If the target has a sub ID, use that and refence that instead.
   	    if(target ~= nil) then
    	    if (target:GetIsSubTargetActive() > 0) then
        	    TarID = target:GetTargetIndex(1);
		        submob = GetEntity(target:GetTargetIndex(0));
    	    else
         	    TarID = target:GetTargetIndex(0);
    	    end
	   
	        if (TarID > 0) then 
	            tarmob = GetEntity(TarID);
	            MobHPP = tarmob.HPPercent;
		        spawn = tarmob.SpawnFlags;
	            MobName = tarmob.Name; 
	            tarserverid = tarmob.ServerId;   -- ServerId is large and unique to the dat file.
	        end
			---- Poll everything in the zone to find the mob we want to kill
	        if (tarserverid > 0) then -- Vicrelant's ibar addon incorporated here.
	            for i = 1, arraySize do	        ----- START FOR LOOP
		            if (mb_data[i] ~= nil) then
		                if (tonumber(mb_data[i].id) == tarserverid) then
			---- Get Mob Job
		                    if (tonumber(mb_data[i].mj) ~= 0 and tonumber(mb_data[i].mj) <= 22) then
		                        MobJob = jobs[tonumber(mb_data[i].mj)];
			                else
			                    MobJob = 'MOB';
		                    end
			---- Get Mob Aggro types
		                    if (mb_data[i].links == 'Y') then
			                    MobAggro = mb_data[i].aggro .. ',L';
		                    else
			                    MobAggro = mb_data[i].aggro;
 		                    end

		                    MobWeak = 'Aggro: |cffff0000|'..MobAggro..' WEAK: '..mb_data[i].weak;
		                    MobWeak = string.gsub(MobWeak,'WEAK:','|cffffffff|WEAK:');
		                    MobWeak = string.gsub(MobWeak,'Piercing','|cffa0a0a0|PRC');
		                    MobWeak = string.gsub(MobWeak,'Fire','|cffff0000|FIR');
		                    MobWeak = string.gsub(MobWeak,'Ice','|cff00bcff|ICE');
		                    MobWeak = string.gsub(MobWeak,'Wind','|cffcafae9|AIR');
		                    MobWeak = string.gsub(MobWeak,'Lightning','|cffd0f04f|LTN');
		                    MobWeak = string.gsub(MobWeak,'Water','|cff4f7af0|WAT');
		                    MobWeak = string.gsub(MobWeak,'Earth','|cff2bc03b|EAR');
		                    MobWeak = string.gsub(MobWeak,'Light','|cffeedaf9|LIG');
		                    MobWeak = string.gsub(MobWeak,'Dark','|cff5239f0|DRK');
		                    NoMob = false;
		                    break;
		                else
                            NoMob = true;
		                end -- END md_data/tarserverid compare
		            else
		                NoMob = true;  
		            end  -- END mb_data nil if 
	            end                         ----- END FOR LOOP
	        else
	            NoMob = true;  
	        end

            MobInfo = MobName..'  |cffa0a0a0|'..MobJob..' '; 
            while MobInfo:len() < 58 do 
	            MobInfo = " "..MobInfo; 
	        end

 	        MobHPCheck = math.floor(MobHPP / (100/46)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
  	        --[[MobStr = tostring(MobHPP);  ------ Let's not put Monster HP% in for now, defeats purpose of the bar.
    	    while MobStr:len() < 3 do 
		        MobStr = " "..MobStr; 
	        end  ]]
	        if (NoMob == true and spawn ~= 16) then
	            ascii.font_m.visible = false;
	            ascii.font_n.visible = false;
	            ascii.font_o.visible = false;
	        else
		        mobResult = string.gsub(mobResult,'_',MobHPColor..'#|c00000000|',MobHPCheck);
	            mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
	        end
	    else
	        NoMob = true;
	    end
        
 	    if (NoMob == true and spawn ~= 16) then     -- Differentiate Monsters from NPC's/Players/Goblin Footprints/etc.
            ascii.font_m.visible = false;    -- This all needs to be here or it will try to make a window for non-monsters
	        ascii.font_n.visible = false;    --
 	        ascii.font_o.visible = false;    --
	    else
	        OutFou = mobResult;
            OutFiv = MobInfo;
	        OutSix = MobWeak;
            ascii.font_m.visible = true;
            ascii.font_m.bold = true;
	        ascii.font_m.text = tostring(OutFou);
            ascii.font_n.position_x = ascii.font_m.position_x;	
	        if (ascii.settings.options.monabov ~= true) then  
  	            ascii.font_n.position_y = ascii.font_m.position_y + ((monsterfontsize * 2) + 1);
	        else
	            ascii.font_n.position_y = ascii.font_m.position_y - ((monsterfontsize * 2) + 1);
	        end
            ascii.font_n.visible = true;
            ascii.font_n.bold = true;
	        ascii.font_n.text = tostring(OutFiv);
	        if (ascii.settings.options.moninfo == true) then
                ascii.font_o.position_x = ascii.font_m.position_x;
	            if (ascii.settings.options.monabov ~= true) then
                    ascii.font_o.position_y = ascii.font_n.position_y + ((monsterfontsize * 2) + 1);
	            else	
		            ascii.font_o.position_y = ascii.font_n.position_y - ((monsterfontsize * 2) + 1);
	            end
                ascii.font_o.visible = true;
                ascii.font_o.bold = true;
	            ascii.font_o.text = tostring(OutSix);
	        else
	            ascii.font_o.visible = false;
	        end
	    end

	    if (tarmob == nil) then 					-- Have nothing targetted
 	        ascii.font_p.visible = false;
	    else
	        ascii.font_p.position_x = ascii.font_m.position_x;
	        if (ascii.settings.options.monsbab ~= true) then  
	            ascii.font_p.position_y = ascii.font_m.position_y + (4 * ((monsterfontsize * 2) - 1));
	        else
	            ascii.font_p.position_y = ascii.font_m.position_y - (4 * ((monsterfontsize * 2) - 1));
	        end

	        if(tarmob ~= nil and target:GetIsSubTargetActive() == 0 ) then 	
									-- Have a Non-Monster Target and no Sub-Target
	            if (NoMob == true) then -- Main Target is not Monster
	   	            ascii.font_p.visible = true;
		            OutSev = tarmob.Name;
	            else 							-- Main Target is Monster and no Sub-Target
	   	           ascii.font_p.visible = false;
		            OutSev = tarmob.Name; -- Shouldn't be seen, but filling values anyway to not cause any possible issues
	            end
	        else 							-- Have a Target and Sub-Target
	           ascii.font_p.visible = true;
	            if (submob ~= nil) then
 	    	        OutSev = submob.Name;
	            end
	        end
	    end
	    if (target:GetIsSubTargetActive() == 0) then
            OutSev = '|cFF80FF00|'..OutSev; 
		else
			OutSev = '|cff7f2be2|'..OutSev; 
		end
	    ascii.font_p.font_height  = monsterfontsize + 2;
		ascii.font_p.italic = true;
		ascii.font_p.bold = true;
	    ascii.font_p.background.visible = false;
	    ascii.font_p.text = OutSev; -- Target/Sub-Target Name
    else
        ascii.font_m.visible = false;
	    ascii.font_n.visible = false;
 	    ascii.font_o.visible = false;
	    ascii.font_p.visible = false;
    end
-------- END Mob Info Window

-------- Player Window
    if(ascii.settings.options.playwin == true) then
        local sResult = '{__________________________________________________|r}'; 
	    local playernumber = 0;

	    if (player == nil or playerent == nil) then 
	        return; 
	    end
			-- This is a convoluted way to get your own stats...
        for x = 0, 5 do 
	        if(player ~= nil and playerent ~= nil) then
                if(playerent.TargetIndex == party:GetMemberTargetIndex(x)) then
	                playernumber = x;  -- Not the same as playerfound!!!
		        break;
	            end
	        end
        end
			
	    local HPValue = playerent.HPPercent;
	    local HPCheck = math.floor(HPValue / (100 / 50));
	    local HPColor = '';
	    local selffontsize = ascii.settings.selffont.font_height;
	    local SelfTP = party:GetMemberTP(playernumber);
	    local SelfHP = party:GetMemberHP(playernumber);
	    local SelfHPMax = player:GetHPMax();
	    local SelfMP = party:GetMemberMP(playernumber);
	    local SelfMPMax = player:GetMPMax();
	    local SelfStr = '                   '; -- Let's go some spaces in for Pet Name room
	    local SelfTPStr = '    '; -- 4 Characters
	    local SelfHPStr = '    '; -- 4 Characters
	    local SelfMPStr = '   ';  -- 3 Characters
	    local SelfMPMStr = '    '; -- 4 Characters
	    local SelfHPMStr = '    '; -- 4 Characters

	    SelfTPStr = tostring(SelfTP);
	    while SelfTPStr:len() < 4 do
	        SelfTPStr = " "..SelfTPStr;
        end
	    if (SelfTP >= 1000) then
	        --u:background.color  =  (0x5f003f00); -- Not sure if we would want this bar colored?
	        SelfTPStr = '|cff70ff70|'..SelfTPStr..'|r';
	    else
	        --u:background.color  =  (0x5f000000);
	        SelfTPStr = '|cffc0c0c0|'..SelfTPStr..'|r';
	    end	

	    SelfHPStr = tostring(SelfHP);
	    SelfHPMStr = tostring(SelfHPMax);
	    while SelfHPStr:len() < 4 do
	        SelfHPStr = " "..SelfHPStr;
        end
	    while SelfHPMStr:len() < 4 do
	        SelfHPMStr = " "..SelfHPMStr;
        end

	    SelfMPStr = tostring(SelfMP);
	    SelfMPMStr = tostring(SelfMPMax);
	    while SelfMPStr:len() < 3 do
	        SelfMPStr = " "..SelfMPStr;
        end
	    while SelfMPMStr:len() < 3 do
	        SelfMPMStr = " "..SelfMPMStr;
        end
------------- HEART STUFF
	    if(ascii.settings.options.zilda == true) then
	        local HeartFullTot = 0;
	        local HeartFull = 0;
	        local HeartFrac = 0;
	        local value = 1; -- VALUE IS PLACEHOLDER IN HEART LINE (1 to 12).

	        HeartFull , HeartFrac = math.modf(HPValue / (100 / 12));  -- DENOMINATOR IS HOW MANY HEART CONTAINERS
	        HeartFullTot = HeartFull;

	        while HeartFull > 0 do
	            HeartNum[value] = 5;
	            HeartFull = HeartFull - 1;
	            value = value + 1;
	        end	

	        if (HeartFrac > .95) then  -- 95 to 100 percent gets 4/4 Heart?
	            HeartNum[value] = 5; -- FULL HEART
	        elseif (HeartFrac > .66) then  -- 66 to 95 percent gets 3/4 Heart?
	            HeartNum[value] = 4; -- 3/4 HEART
	        elseif (HeartFrac > .33) then  -- 33 to 66 percent gets 1/2 Heart?
	            HeartNum[value] = 3; -- 1/2 HEART
	        elseif (HeartFrac > .1) then  -- 10 to 33 percent gets 1/4 Heart?
	            HeartNum[value] = 2; -- 1/4 HEART
	        else	
	            if(HeartFullTot == 0) then -- To not show some health as zero Hearts when near Death.
		            HeartNum[value] = 2 -- 1/4 Heart
	            else
		        HeartNum[value] = 1 -- EMPTY HEART for less than 10 percent when not near Death.
	            end
	        end
	
	        value = value + 1; -- Increase value from the fractional Heart

	        while value <= 12 do
	            HeartNum[value] = 1; -- EMPTY HEART
	            value = value + 1;
	        end
				-- DRAW HEARTS
	        for x = 1, 12 do
				for y = 1, 5 do
                    HeartContainer[x][y].visible = false; -- Need to constantly blank every heart in the array.
				end
	            HeartContainer[x][HeartNum[x]].position_x = ascii.font_q.position_x + 85 + (x * 48);
	            HeartContainer[x][HeartNum[x]].position_y = ascii.font_q.position_y;
				HeartContainer[x][HeartNum[x]].locked = true;
	            HeartContainer[x][HeartNum[x]].visible = true;
			end

            if (HPValue <= 0) then
                sResult = ' |cffff0000|DEAD ';
	        else
		        sResult = ' LIFE ';
	        end   

            ascii.font_s.position_x = ascii.font_q.position_x;
	        ascii.font_s.position_y = ascii.font_q.position_y + ((selffontsize * 4) + 2 + 27);
            ascii.font_t.position_x = ascii.font_q.position_x;
	        ascii.font_t.position_y = ascii.font_q.position_y + ((selffontsize * 6) + 3 + 27);
            ascii.font_r.position_x = ascii.font_q.position_x;
	        ascii.font_r.position_y = ascii.font_q.position_y + ((selffontsize * 2) + 1 + 27);
            ascii.font_u.position_x = ascii.font_q.position_x;
	        ascii.font_u.position_y = ascii.font_q.position_y + ((selffontsize * 2) + 1 + 27)
	        ascii.font_q.font_height  = 24;

	        SelfStr = SelfStr..SelfHPStr..' / '..SelfHPMStr..'   |cffff40b0|'..SelfMPStr..' / '..SelfMPMStr..'     '..SelfTPStr..' ';
	    else	-------------- THIS IS 'Q' LINE?
	        SelfStr = SelfStr..SelfTPStr..'     '..SelfHPStr..' / '..SelfHPMStr..'   |cffff40b0|'..SelfMPStr..' / '..SelfMPMStr..' |r';

	        if (HPValue >= 100) then 
		        HPColor = '|cff00ff00|';
	        elseif (HPValue >= 75) then
		        HPColor = '|cff008000|';
	        elseif (HPValue >= 50) then
		        HPColor = '|cffffff80|';
	        elseif (HPValue >= 25) then	
		        HPColor = '|cffffA000|';
	        elseif (HPValue >= 16) then 
		        HPColor = '|cffff0000|';
	        else
		        HPColor = '|cA0A00000|';
	        end

	        if (HPValue <= 0) then
	            sResult = '                   |cffff0000|YOU ARE DEAD!                    |r';
	        else
   	            sResult = string.gsub(sResult,'_',HPColor .. '#|c00000000|',HPCheck);
	        end
	        ascii.font_q.font_height  = 10;
            ascii.font_s.position_x = ascii.font_q.position_x;
	        ascii.font_s.position_y = ascii.font_q.position_y + ((selffontsize * 4) + 2);
            ascii.font_t.position_x = ascii.font_q.position_x;
	        ascii.font_t.position_y = ascii.font_q.position_y + ((selffontsize * 6) + 3);
            ascii.font_r.position_x = ascii.font_q.position_x;
	        ascii.font_r.position_y = ascii.font_q.position_y + ((selffontsize * 2) + 1);
            ascii.font_u.position_x = ascii.font_q.position_x;
	        ascii.font_u.position_y = ascii.font_q.position_y + ((selffontsize * 2) + 1)
	    end ------------- END 'Q' Stuff

        if (HPValue <= 33) then
            if (tick >= 15) then
                ascii.font_q.background.color = 0x5FFF0000;
		        ascii.font_u.background.color = 0x5FFF0000;
            else
                ascii.font_q.background.color = ascii.settings.selffont.background.color;
		        ascii.font_u.background.color = ascii.settings.selffont.background.color;
            end
        else
            ascii.font_q.background.color = ascii.settings.selffont.background.color;
	        ascii.font_u.background.color = ascii.settings.selffont.background.color;
	    end
   
	    ascii.font_u.visible = true; 
	    ascii.font_u.text = SelfStr;
	    ascii.font_q.visible = true;
	    ascii.font_q.text = string.format(sResult);
---- PET STUFF
        local pet = GetEntity(playerent.PetTargetIndex);

        if (playerent.PetTargetIndex > 0 and pet ~= nil) then ---- PLAYER HAS PET
            ascii.font_r.visible = true;
	        ascii.font_s.visible = true;
	        ascii.font_t.visible = true;
	        local petname = pet.Name;
            local pettp = player:GetPetTP();
            local petmp = player:GetPetMPPercent();
	        local pResult = '|cffffffff|{|c00000000|__________________________________________________|cffffffff|}'; 
	        local PHValue = pet.HPPercent;
	        local PHCheck = math.floor(PHValue / (100 / 50));
			local tResult  = '|cffffffff|{|c00000000|____________________|r}';
			local pmResult = '|cffffffff|{|c00000000|____________________|r}';
			local PTCheck = math.floor(pettp / (3000 / 20));
			local PTColor = '|cff7f7f7f|';
			local tResult = string.gsub(tResult,'_',PTColor..'#|c00000000|',PTCheck);
			local PMCheck = math.floor(petmp / (100 / 20));
			local PMColor = '|cfff48dff|';

	        while (petname:len() < 15) do
	            petname = petname.." ";
	        end
			ascii.font_r.background.visible = false;
	        ascii.font_r.text = (string.format(petname));
            pResult = string.gsub(pResult,'_','|cff49497e|#|c00000000|',PHCheck);
	        ascii.font_s.text = (string.format(pResult));

	        if (pettp >= 1000) then
	            PTColor = '|cff40a040|';
	        end

	        if (petmp >= 100) then
	            PMColor = '|cfeb63fa|';
	        end
            pmResult = string.gsub(pmResult,'_',PMColor..'#|c00000000|',PMCheck);
	        ascii.font_t.text = (string.format(tResult..'        '..pmResult));
	    else
            ascii.font_r.visible = false;
	        ascii.font_s.visible = false;
	        ascii.font_t.visible = false;
        end
    else
	    ascii.font_q.visible = false;
        ascii.font_r.visible = false;
	    ascii.font_s.visible = false;
	    ascii.font_t.visible = false;
	    ascii.font_u.visible = false;
    end
-------- END Self Window
end);  ------------ END MAIN FUNCTION

--[[
* Prints the addon help information.
*
* @param {boolean} isError - Flag if this function was invoked due to an error.
--]]
local function print_help(isError)
    -- Print the help header..
    if (isError) then
        print(chat.header(addon.name):append(chat.error('Invalid command syntax for command: ')):append(chat.success('/' .. addon.name)));
    else
        print(chat.header(addon.name):append(chat.message('Available commands:')));
    end

    local cmds = T{
	    { '   - (CASE SENSITIVE, sorry!)', 'Refer to README file for more information.' },
	    { '  ', 'Toggling any option will automatically save.' },
        { '/ASCII-Joy help     ', 'Displays this help information.' },
        { '/ASCII-Joy save     ', 'Saves the positions of the windows after you move them.' },
		{ '/ASCII-Joy back     ', 'Toggles Window Backgrounds. Rotates through (off / light / dark) (Requires Restart).' },
		{ '/ASCII-Joy font     ', 'Toggles Window fonts between Consolas and Courier New.'},
        { '/ASCII-Joy party    ', 'Toggles the Party Window on and off.' },
	    { '/ASCII-Joy solo     ', 'Toggles seeing yourself in Party Window while solo (Zone Name remains).' },
	    { '/ASCII-Joy player   ', 'Toggles Player Window of your own HP Bar, TP, Mana, Pet info. (if you have one)' },
        { '/ASCII-Joy zilda     ', 'Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!' },
	    { '/ASCII-Joy monster ', 'Toggles the Monster Health/Sub-Target Window.' },
	    { '/ASCII-Joy mon-pos ', 'Toggles Monster info Above/Below their Health Bar.' },
	    { '/ASCII-Joy mon-info', 'Toggles Aggro/Weak info. Not live info, pulled from file.' },
	    { '/ASCII-Joy mon-sub ', 'Toggles Target/Sub Name Above/Below the Monster Health Bar.' },
	    { '                   ', 'If you have no monster targetted, this is the name of who/what' },
	    { '                   ', 'you have targetted. If you do have a monster targetted, this is' },
	    { '                   ', 'who/what you are trying to use a spell/skill/item/whatever on.' },
	    { '',''},
	    { '','To move the Party Window, Shift-LeftClick-Drag the line with Zone Name.' },
	    { '','To move the Monster Window, Shift-LeftClick-Drag the line with the Monster Health.' },
	    { '','To move the Player Window, Shift-LeftClick-Drag the line with your own Health.' },
	    { '','  If you have Life Hearts from "The Myth of Zilda(tm)", Shift-LeftClick-Drag the word "LIFE".' },
	    { '','You must use </ASCII-Joy save>, change zones, or unload/load the addon to save positions.' },
    };

    -- Print the command list..
    cmds:ieach(function (v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);
end

ashita.events.register('command', 'command_cb', function (ee)
    -- Parse the command arguments..
    local args = ee.command:args();
    if (#args == 0 or args[1] ~= '/ASCII-Joy') then
        return;
    end

    -- Block all ASCII-Joy related commands..
    ee.blocked = true;

    if (#args == 2 and args[2]:any('help')) then
        print_help(false);
        return;
    end

    if (#args == 2 and args[2]:any('save')) then
        print(chat.header(addon.name):append(chat.message('Window Positions saved, Thank you!')));
		save_everything();
        return;
    end

	if (#args == 2 and args[2]:any('font')) then
		if(ascii.settings.monsterfont.font_family == 'Consolas') then
			ascii.settings.monsterfont.font_family = 'Courier New';
			ascii.settings.selffont.font_family = 'Courier New';
			ascii.settings.partyfont.font_family = 'Courier New';
	        print(chat.header(addon.name):append(chat.message('Your FONTS will be Old School Courier New.')));
	    elseif(ascii.settings.monsterfont.font_family == 'Courier New') then
			ascii.settings.monsterfont.font_family = 'Consolas';
			ascii.settings.selffont.font_family = 'Consolas';
			ascii.settings.partyfont.font_family = 'Consolas';
	        print(chat.header(addon.name):append(chat.message('Your FONTS will be New School Consolas.')));
	    end
		save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
	    update_settings();
        return;
    end

    if (#args == 2 and args[2]:any('party')) then
		ascii.settings.options.party = not ascii.settings.options.party;
	    if(ascii.settings.options.party == true) then
	        print(chat.header(addon.name):append(chat.message('Party Window ENABLED.')));
	    elseif(ascii.settings.options.party == false) then
	        print(chat.header(addon.name):append(chat.message('Party Window DISABLED.')));
	    end
	    save_everything();
        return;
    end

    if (#args == 2 and args[2]:any('back')) then
		if(ascii.settings.monsterfont.background.color == 0x00000000) then
			ascii.settings.monsterfont.background.color = 0x5F000000;
			ascii.settings.selffont.background.color = 0x5F000000;
			ascii.settings.partyfont.background.color = 0x5F000000;
			print(chat.header(addon.name):append(chat.message('Window Backgrounds will be LIGHT (Translucent).')));
		elseif(ascii.settings.monsterfont.background.color == 0x5F000000) then
			ascii.settings.monsterfont.background.color = 0xFF000000;
			ascii.settings.selffont.background.color = 0xFF000000;
			ascii.settings.partyfont.background.color = 0xFF000000;
			print(chat.header(addon.name):append(chat.message('Window Backgrounds will be DARK (Opaque).')));
		elseif(ascii.settings.monsterfont.background.color == 0xFF000000) then
			ascii.settings.monsterfont.background.color = 0x00000000;
			ascii.settings.selffont.background.color = 0x00000000;
			ascii.settings.partyfont.background.color = 0x00000000;
			print(chat.header(addon.name):append(chat.message('Window Backgrounds will be OFF (Invisible).')));		
		end
		save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
		update_settings();
        return;
    end

    if (#args == 2 and args[2]:any('player')) then
		ascii.settings.options.playwin = not ascii.settings.options.playwin;
	    if(ascii.settings.options.playwin == false) then
	        print(chat.header(addon.name):append(chat.message('Player Window DISABLED.')));
	    elseif(ascii.settings.options.playwin == true) then
	        print(chat.header(addon.name):append(chat.message('Player Window ENABLED.')));
	    end
	    save_everything();
        return;
    end

    if (#args == 2 and args[2]:any('solo')) then
        if(ascii.settings.options.party == true) then
			ascii.settings.options.solo = not ascii.settings.options.solo;
	        if(ascii.settings.options.solo == true) then
	            print(chat.header(addon.name):append(chat.message('You will NOT see yourself in the Party Window while Solo.')));
	        elseif(ascii.settings.options.solo == false) then
	            print(chat.header(addon.name):append(chat.message('You WILL see yourself in the Party Window while Solo.')));
	        end
	        save_everything();
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Party Window enabled to toggle this.')));
	    return;
        end
    end

    if (#args == 2 and args[2]:any('monster')) then
		ascii.settings.options.monster = not ascii.settings.options.monster;
	    if(ascii.settings.options.monster == false) then
	        print(chat.header(addon.name):append(chat.message('Monster Window DISABLED.')));
	    elseif(ascii.settings.options.monster == true) then
	        print(chat.header(addon.name):append(chat.message('Monster Window ENABLED.')));
	    end
	    save_everything();
        return;
    end

    if (#args == 2 and args[2]:any('mon-pos')) then
        if(ascii.settings.options.monster == true) then
			ascii.settings.options.monabov = not ascii.settings.options.monabov;
	        if(ascii.settings.options.monabov == true) then
	            print(chat.header(addon.name):append(chat.message('You will see the monster info ABOVE their Health Bar.')));
	        elseif(ascii.settings.options.monabov == false) then
	            print(chat.header(addon.name):append(chat.message('You will see the monster info BELOW their Health Bar.')));
	        end
	        save_everything();
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Monster Window enabled to toggle this.')));
	        return;
        end
    end

    if (#args == 2 and args[2]:any('mon-info')) then
        if(ascii.settings.options.monster == true) then
			ascii.settings.options.moninfo = not ascii.settings.options.moninfo;
	        if(ascii.settings.options.moninfo == true) then
	            print(chat.header(addon.name):append(chat.message('You WILL see the Monster Extended Info.')));
	        elseif(ascii.settings.options.moninfo == false) then
	            print(chat.header(addon.name):append(chat.message('You will NOT see the Monster Extended Info.')));
	        end
	        save_everything();
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Monster Window enabled to toggle this.')));
	        return;
        end
    end

    if (#args == 2 and args[2]:any('zilda')) then
        if(ascii.settings.options.playwin == true) then
			ascii.settings.options.zilda = not ascii.settings.options.zilda;
	        if(ascii.settings.options.zilda == true) then
	            print(chat.header(addon.name):append(chat.message('You WILL see LIFE HEARTS from "The Myth of Zilda(tm)"!')));
	        elseif(ascii.settings.options.zilda == false) then
				for x = 1, 12 do  
					for y = 1, 5 do
						HeartContainer[x][y].visible = false; -- Need to constantly blank these if we want them off
					end
                end
	            print(chat.header(addon.name):append(chat.message('You will see the Old School ASCII Health Bar.')));
	        end
	        save_everything();
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Player Window enabled to toggle this.')));
	        return;
        end
    end

    -- Unhandled: Print help information..
    print_help(true);
end);