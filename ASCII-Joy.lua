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

addon.author   = 'Drusciliana';
addon.name     = 'ASCII-Joy';
addon.version  = '1.0.2';
addon.desc = 'Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!';
addon.link = 'Discord name is just plain old D. (with the period), #2154 if that helps. Shoot a message with questions/comments/concerns.'

require ('common')
local chat = require('chat');
local fonts = require('fonts');
local settings = require('settings');
local d3d8 = require('d3d8');
local d3d8_device = d3d8.get_device();

-------------- START Global Variables
local default_settings =
T{
    options = T{
    party = 	true, 		
    solo = 		true, 		
    monster = 	true, 		
    moninfo  = 	true, 
    monabov =   true,
	monsbab = 	false,		
    playwin =   true,
    zilda =	    false
    },
    partyfont = T{
        name = "Consolas",  		
        position = T{ 400, 600 },
        size = 10
    },
    monsterfont = T{
        name = "Consolas",  		
        position = T{ 800, 200 },
        size = 10
    },
    selffont = T{
        name = "Consolas",		
        position = T{ 800, 600 },
        size = 10
    },
	default = true;
};

--** Not a fan of this settings thing with the external file defaults, it's why defaults
--** are declared here. External default file seems redundant. New characters wouldn't
--** have a settings.lua file since it would load in the folder for that new character, 
--** so the default would be pulled from the .lua here. Maybe I'm wrong.

local ascii_config = T{ };   

local ascii = T{
    settings = settings.load(default_settings),
};

local f = {};
local g = {};
local h = {};
local tick = 0;
local LastZone = 9999; -- To remember when we are zoning.
local mb_data = {};
local arraySize = 0;
local HeartNum = {};
local heart = {};
local HeartContainer =
{
	[1] = {  },
	[2] = {  },
	[3] = {  },
	[4] = {  },
	[5] = {  },
	[6] = {  },
	[7] = {  },
	[8] = {  },
	[9] = {  },
	[10]= {  },
    [11]= {  },
    [12]= {  }
};

local jobs = {
	[0]  = '   ',
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

------------ END Global Variables

--[[
* Updates the font object settings and saves the current settings.
*
* @param {table} s - The new settings table to use for the addon settings. (Optional.)
--]]
local function update_settings(set)

    if (s ~= nil) then
        ascii.settings = s;
    end

	--** This default thing is really perplexing me **--
	--** When the game loads from cold, it always seems to load the default file, and not the character file.
	--** If you unload and load the addon mid-game, it'll load the character file and work.
	--** If you don't put the addon in the default script, and load the addon mid-game, it'll load the character file and work.
	--** Can't seem to figure out why, so brute forcing the default file away and overwriting it.

    if (ascii_config ~= nil) then
   	    local e = AshitaCore:GetFontManager():Get('__asciijoy_partytitle'); 
    	local m = AshitaCore:GetFontManager():Get('__asciijoy_mobhpp');
    	local q = AshitaCore:GetFontManager():Get('__asciijoy_selfhp');

    	ascii_config.selffont.position = { q:GetPositionX(), q:GetPositionY() };
    	ascii_config.partyfont.position = { e:GetPositionX(), e:GetPositionY() };
    	ascii_config.monsterfont.position = { m:GetPositionX(), m:GetPositionY() };	
    end

    settings.save();
    local character_path = settings.settings_path();
    local defaults_path = ('%s\\config\\addons\\%s\\%s\\'):fmt(AshitaCore:GetInstallPath(), addon.name, 'defaults');
    if (character_path == defaults_path) then -- Both paths identical. Ugh.
	    return;
    end
    local cha_file = ('%s\\%s.lua'):fmt(character_path, 'settings');
    local def_file = ('%s\\%s.lua'):fmt(defaults_path, 'settings');
    os.remove(def_file);
    os.rename(cha_file, def_file);

    settings.save();
end
--[[
* Registers a callback for the settings to monitor for character switches.
--]]
settings.register('settings', 'settings_update', update_settings);

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function ()
    local Background = 0x5F000000;
    ascii_config = ascii.settings;

-- Load the individual heart textures
    for x = 1, 5 do  
        heart[x] = AshitaCore:GetPrimitiveManager():Create(string.format('%s%d', '__asciijoy_heart' , x));
        heart[x]:SetPositionX(0);
        heart[x]:SetPositionY(0);
	    heart[x]:SetWidth(48);
	    heart[x]:SetHeight(48);
	    heart[x]:SetColor(0xffffffff);
        heart[x]:SetTextureFromFile(('%s\\addons\\%s\\icons\\%s.png'):fmt(AshitaCore:GetInstallPath(),'ASCII-Joy',x));
        heart[x]:SetVisible(false);
    end

-- Heart Containers
    for x = 1, 12 do
        HeartContainer[x] = AshitaCore:GetPrimitiveManager():Create(string.format('%s%d', '__asciijoy_container' , x));
    end

-- Monster Window labels
    m = AshitaCore:GetFontManager():Create('__asciijoy_mobhpp');
    m:SetColor(0xFFFFFFFF);
    m:SetFontFamily(ascii_config.monsterfont.name);
    m:SetFontHeight(ascii_config.monsterfont.size);
    m:SetBold(true);
    m:SetRightJustified(true);
    m:SetPositionX(ascii_config.monsterfont.position[1]);
    m:SetPositionY(ascii_config.monsterfont.position[2]);
    m:SetText('MOB HP');
    m:GetBackground():SetColor(Background);
    m:GetBackground():SetVisible(true);
    m:SetVisible(false);
    n = AshitaCore:GetFontManager():Create('__asciijoy_mobinfo');
    n:SetColor(0xFFFFFFFF);
    n:SetFontFamily(ascii_config.monsterfont.name);
    n:SetFontHeight(ascii_config.monsterfont.size);
    n:SetBold(true);
    n:SetRightJustified(true);
    n:SetPositionX(0);
    n:SetPositionY(0);
    n:SetText('MOB NAME');
    n:SetLocked(true);
    n:GetBackground():SetColor(Background);
    n:GetBackground():SetVisible(true);
    n:SetVisible(false);
    o = AshitaCore:GetFontManager():Create('__asciijoy_mobweak');
    o:SetColor(0xFFFFFFFF);
    o:SetFontFamily(ascii_config.monsterfont.name);
    o:SetFontHeight(ascii_config.monsterfont.size);
    o:SetBold(true);
    o:SetRightJustified(true);
    o:SetPositionX(0);
    o:SetPositionY(0);
    o:SetText('MOB INFO');
    o:SetLocked(true);
    o:GetBackground():SetColor(Background);
    o:GetBackground():SetVisible(true);
    o:SetVisible(false);
    p = AshitaCore:GetFontManager():Create('__asciijoy_mobsub');
    p:SetColor(0xFF80FF00);
    p:SetFontFamily(ascii_config.monsterfont.name);
    p:SetFontHeight(ascii_config.monsterfont.size);
    p:SetBold(true);
    p:SetRightJustified(true);
    p:SetPositionX(0);
    p:SetPositionY(0);
    p:SetItalic(true);
    p:SetText('TARGET');
    p:SetLocked(true);
    p:GetBackground():SetColor(Background);
    p:GetBackground():SetVisible(true);
    p:SetVisible(false);

---- Player Window labels
    q = AshitaCore:GetFontManager():Create( '__asciijoy_selfhp' );
    q:SetBold(true);
    q:SetColor(0xFFFFFFFF);
    q:SetFontFamily(ascii_config.selffont.name);
    q:SetFontHeight(ascii_config.selffont.size);
    q:SetPositionX(ascii_config.selffont.position[1]);
    q:SetPositionY(ascii_config.selffont.position[2]);
    q:SetText('SELF HP');
    q:SetVisible(false);
    q:GetBackground():SetColor(Background);
    q:GetBackground():SetVisible(true);
    r = AshitaCore:GetFontManager():Create( '__asciijoy_petname' );
    r:SetBold(true);
    r:SetColor(0xFFFFFFFF);
    r:SetFontFamily(ascii_config.selffont.name);
    r:SetFontHeight(ascii_config.selffont.size);
    r:SetPositionX(0);
    r:SetPositionY(0);
    r:SetText('PET NAME');
    r:SetLocked(true)
    r:SetVisible(false);
    r:GetBackground():SetColor(Background);
    r:GetBackground():SetVisible(false);
    s = AshitaCore:GetFontManager():Create( '__asciijoy_pethp' );
    s:SetBold(true);
    s:SetColor(0xFFFFFFFF);
    s:SetFontFamily(ascii_config.selffont.name);
    s:SetFontHeight(ascii_config.selffont.size);
    s:SetPositionX(0);
    s:SetPositionY(0);
    s:SetText('PET HP');
    s:SetLocked(true);
    s:SetVisible(false);
    s:GetBackground():SetColor(Background);
    s:GetBackground():SetVisible(true);
    t = AshitaCore:GetFontManager():Create( '__asciijoy_petinfo' );
    t:SetBold(true);
    t:SetColor(0xFFFFFFFF);
    t:SetFontFamily(ascii_config.selffont.name);
    t:SetFontHeight(ascii_config.selffont.size);
    t:SetPositionX(0);
    t:SetPositionY(0);
    t:SetText('PET INFO');
    t:SetLocked(true);
    t:SetVisible(false);
    t:GetBackground():SetColor(Background);
    t:GetBackground():SetVisible(true);
    u = AshitaCore:GetFontManager():Create( '__asciijoy_selfnum' );
    u:SetBold(true);
    u:SetColor(0xFFFFFFFF);
    u:SetFontFamily(ascii_config.selffont.name);
    u:SetFontHeight(ascii_config.selffont.size);
    u:SetPositionX(0);
    u:SetPositionY(0);
    u:SetText('SELF NUMBERS');
    u:SetLocked(true);
    u:SetVisible(false);   							
    u:GetBackground():SetColor(Background);
    u:GetBackground():SetVisible(true);

---- Party Window labels
    e = AshitaCore:GetFontManager():Create('__asciijoy_partytitle');
    e:SetColor(0xFFFFFFFF);
    e:SetFontFamily(ascii_config.partyfont.name);
    e:SetFontHeight(ascii_config.partyfont.size);
    e:SetBold(true);
    e:SetRightJustified(true);
    e:SetPositionX(ascii_config.partyfont.position[1]);
    e:SetPositionY(ascii_config.partyfont.position[2]);
    e:SetText('TITLE');
    e:SetLocked(false);
    e:GetBackground():SetColor(Background);
    e:GetBackground():SetVisible(true);
    e:SetVisible(false);
--    for x = 0, 17 do  -- Not ready do try alliance yet
    for x = 0, 5 do
        f[x] = AshitaCore:GetFontManager():Create(string.format('%s%d', '__asciijoy_partyhpp', x));
        f[x]:SetColor(0xFFFFFFFF);
        f[x]:SetFontFamily(ascii_config.partyfont.name);
        f[x]:SetFontHeight(ascii_config.partyfont.size);
        f[x]:SetBold(true);
        f[x]:SetRightJustified(true);
        f[x]:SetPositionX(0);
        f[x]:SetPositionY(0);
        f[x]:SetText(string.format('XXX %d', x));
        f[x]:SetLocked(true);
  	    f[x]:GetBackground():SetColor(Background);
        f[x]:GetBackground():SetVisible(true);
        f[x]:SetVisible(false);
	    g[x] = AshitaCore:GetFontManager():Create(string.format('%s%d', '__asciijoy_partympp', x));
        g[x]:SetColor(0xFFFFFFFF);
        g[x]:SetFontFamily(ascii_config.partyfont.name);
        g[x]:SetFontHeight(ascii_config.partyfont.size);
        g[x]:SetBold(true);
        g[x]:SetRightJustified(true);
        g[x]:SetPositionX(0);
        g[x]:SetPositionY(0);
        g[x]:SetText(string.format('YYY %d', x));
        g[x]:SetLocked(true);
        g[x]:GetBackground():SetColor(Background);
        g[x]:GetBackground():SetVisible(true);
        g[x]:SetVisible(false);
	    h[x] = AshitaCore:GetFontManager():Create(string.format('%s%d', '__asciijoy_partyspc', x));
        h[x]:SetColor(0xFFFFFFFF);
        h[x]:SetFontFamily(ascii_config.partyfont.name);
        h[x]:SetFontHeight(ascii_config.partyfont.size);
        h[x]:SetBold(true);
        h[x]:SetRightJustified(true);
        h[x]:SetPositionX(0);
        h[x]:SetPositionY(0);
        h[x]:SetText(string.format('ZZZ %d', x));
        h[x]:SetLocked(true);
        h[x]:GetBackground():SetColor(Background);
        h[x]:GetBackground():SetVisible(true);
        h[x]:SetVisible(false);
    end

-- Get Info and what not for Mobs upon loading the addon.
    ZoneIDStart = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    _, mb_data = pcall(require,'data.'..tostring(ZoneIDStart));
    if (mb_data == nil or type(mb_data) ~= 'table') then
        mb_data = { };
    end
    arraySize = #(mb_data);

    print(chat.header(addon.name):append(chat.message('Please type /ASCII-Joy to bring up the addon menu.')));

end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function ()

    update_settings(ascii_config);

	---- Clean up the mess (it is a mess)
    for x = 1, 5 do
	    AshitaCore:GetPrimitiveManager():Delete(string.format('%s%d', '__asciijoy_heart', x));
    end
    for x = 1, 12 do
	    AshitaCore:GetPrimitiveManager():Delete(string.format('%s%d', '__asciijoy_container', x));
    end    
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_selfhp'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_petname'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_pethp'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_petinfo'));   
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_mobhpp'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_mobinfo'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_mobweak'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_mobsub'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_partytitle'));
    AshitaCore:GetFontManager():Delete(string.format('%s', '__asciijoy_selfnum'));
	
--    for x = 0, 17 do   -- Not ready to try alliance yet
    for x = 0, 5 do
        AshitaCore:GetFontManager():Delete(string.format('%s%d', '__asciijoy_partyhpp', x));
        AshitaCore:GetFontManager():Delete(string.format('%s%d', '__asciijoy_partyspc', x));
        AshitaCore:GetFontManager():Delete(string.format('%s%d', '__asciijoy_partympp', x));
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
	    for x = 0, 5 do --** May be different for alliance -- Need to Get these again because of the X loop.
	        f[x]:SetVisible(false);
	        g[x]:SetVisible(false);
	        h[x]:SetVisible(false);
	    end
	    e:SetVisible(false);
	    m:SetVisible(false);
	    n:SetVisible(false);
	    o:SetVisible(false);
	    p:SetVisible(false);
	    q:SetVisible(false);
	    r:SetVisible(false);
	    s:SetVisible(false);
	    t:SetVisible(false);
	    u:SetVisible(false);
	    return;
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
            ascii_config.selffont.position = { q:GetPositionX(), q:GetPositionY() }; -- Let's save when we zone.
            ascii_config.partyfont.position = { e:GetPositionX(), e:GetPositionY() };
    	    ascii_config.monsterfont.position = { m:GetPositionX(), m:GetPositionY() };	
	        update_settings(ascii_config); 
	    end
    end

    if (ascii_config.options.party == true) then
        local cury = 0;
        local newy = 0;
        local spcy = 0;
        local leadstar = '|r ';
        local partyfontsize = ascii_config.partyfont.size;
        local fontsize = ((partyfontsize * 2) - 1);
		local elsewhere = true;
        for x = 0, 5 do  -- Need to Get these again because of the X loop.
		    elsewhere = true;
	        if (party:GetMemberIsActive(x) == 0) then
	            f[x]:SetVisible(false);
	            g[x]:SetVisible(false);
	            h[x]:SetVisible(false);
            else
	            if(party:GetMemberZone(playerfound) == party:GetMemberZone(x)) then
		            elsewhere = false;  
	            end
        ----- Setup Party Window (NEATEST I THINK I CAN MAKE IT, WORKS BEST ON 10 POINT FONTS at 1920x1080)
	    ----- "cur" is Health, "new" is Mana, "spc" is blank line between party members
	            spcy = e:GetPositionY() - (x * (3*(fontsize + 2)));	    
	            newy = spcy - 2 - fontsize;
	            cury = newy - 2 - fontsize;

                f[x]:SetPositionX(e:GetPositionX());
                f[x]:SetPositionY(cury);
	            f[x]:SetBold(true);

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
                    if (ID == TargetID and elsewhere == false) then
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

                g[x]:SetPositionX(e:GetPositionX());
                g[x]:SetPositionY(newy);
	            g[x]:SetBold(true);
                h[x]:SetPositionX(e:GetPositionX());
                h[x]:SetPositionY(spcy);
	            h[x]:SetBold(true);

    ---- Get Party Members' Job(s)
	            
				if (party:GetMemberMainJob(x) == nil or party:GetMemberMainJob(x) == 0 or party:GetMemberMainJob(x) > 22) then
				    TJob = 'NPC';
			    else	
					MJob = jobs[party:GetMemberMainJob(x)];
	                if (party:GetMemberSubJobLevel(x) ~= nil and party:GetMemberSubJobLevel(x) > 0 and party:GetMemberSubJobLevel(x) < 23) then
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

	            if (solo <= 1 and ascii_config.options.solo == true) then
		            OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(playerfound));;
	                while OutThr:len() < 35 do
	                    OutThr = " "..OutThr;
		            end
		            OutThr = string.sub(OutThr, 1, 35);
	 	            OutThr = " "..OutThr.." ";
	                e:SetVisible(true);
	                e:SetText(tostring(OutThr));
	                f[x]:SetVisible(false);
	                g[x]:SetVisible(false);
  	                h[x]:SetVisible(false);   
    	        else
	                f[x]:SetVisible(true);
                    g[x]:SetVisible(true);
	                e:SetVisible(true);

        	        if (HPValue <= 33 and elsewhere == false) then
            	        if (tick >= 15) then
                            f[x]:GetBackground():SetColor(0x5fff0000);
                        else
                	        f[x]:GetBackground():SetColor(0x5F000000);
                        end
                    else
            	        f[x]:GetBackground():SetColor(0x5F000000);
		            end

	                if (elsewhere == false) then      			-- Try to put in Zone Name for far away friends
                        Output = (NameColor..Name..leadstar..'|'..hResult..'||cff00ff00|'..HealthStr);
	                    OutTwo = (TPColor..'     '..TPValue..'  '..mResult..'|cffff69b4|'..ManaStr..' |cffffffff|'..TJob);
	                    f[x]:SetText(tostring(Output));
	                    g[x]:SetText(tostring(OutTwo));
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
	                    f[x]:SetText(tostring(Output));
	                    g[x]:SetText(tostring(OutTwo));
	                end	    
	            end

	            if (x == playerfound) then      -- We only want the bottom line to be moveable: "e"
		            OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(playerfound));;
	                while OutThr:len() < 35 do
	                    OutThr = " "..OutThr;
		            end
		            OutThr = string.sub(OutThr, 1, 35);
	 	            OutThr = " "..OutThr.." ";
	                h[x]:SetVisible(false);
		            e:SetVisible(true);
		            e:SetText(OutThr);
	            else
		            OutThr = '                                     ';
	                e:SetVisible(true); 
	    	        h[x]:SetVisible(true);
 	                h[x]:SetText(tostring(OutThr));
	            end
            end
        end
    else
 	    e:SetVisible(false);
	    for x = 0, 5 do --** May be different for alliance
	        f[x]:SetVisible(false);
	        g[x]:SetVisible(false);
	        h[x]:SetVisible(false);
	    end
    end
-------- END Party Window

-------- Monster Window
    if (ascii_config.options.monster == true) then
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
	    local monsterfontsize = ascii_config.monsterfont.size;

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
	        if (tarserverid > 0) then
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
  	--[[    MobStr = tostring(MobHPP);  ------ Let's not put Monster HP% in for now
    	    while MobStr:len() < 3 do 
		        MobStr = " "..MobStr; 
	        end  ]]
	        if (NoMob == true and spawn ~= 16) then
	            m:SetVisible(false);
	            n:SetVisible(false);
	            o:SetVisible(false);
	        else
		        mobResult = string.gsub(mobResult,'_',MobHPColor..'#|c00000000|',MobHPCheck);
	            mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
	        end
	    else
	        NoMob = true;
	    end
        
 	    if (NoMob == true and spawn ~= 16) then     -- Differentiate Monsters from NPC's/Players/Goblin Footprints/etc.
            m:SetVisible(false);    -- This all needs to be here or it will try to make a window for non-monsters
	        n:SetVisible(false);    --
 	        o:SetVisible(false);    --
	    else
	        OutFou = mobResult;
            OutFiv = MobInfo;
	        OutSix = MobWeak;
            m:SetVisible(true);
            m:SetBold(true);
	        m:SetText(tostring(OutFou));
            n:SetPositionX(m:GetPositionX());	
	        if (ascii_config.options.monabov ~= true) then  
  	            n:SetPositionY(m:GetPositionY() + ((monsterfontsize * 2) + 1));
	        else
	            n:SetPositionY(m:GetPositionY() - ((monsterfontsize * 2) + 1));
	        end
            n:SetVisible(true);
            n:SetBold(true);
	        n:SetText(tostring(OutFiv));
	        if (ascii_config.options.moninfo == true) then
                o:SetPositionX(m:GetPositionX());
	            if (ascii_config.options.monabov ~= true) then
                    o:SetPositionY(n:GetPositionY() + ((monsterfontsize * 2) + 1));
	            else	
		            o:SetPositionY(n:GetPositionY() - ((monsterfontsize * 2) + 1));
	            end
                o:SetVisible(true);
                o:SetBold(true);
	            o:SetText(tostring(OutSix));
	        else
	            o:SetVisible(false);
	        end
	    end

	    if (tarmob == nil) then 					-- Have nothing targetted
 	        p:SetVisible(false);
	    else
	        p:SetPositionX(m:GetPositionX());
	        if (ascii_config.options.monsbab ~= true) then  
	            p:SetPositionY(m:GetPositionY() + (4 * ((monsterfontsize * 2) - 1)));
	        else
	            p:SetPositionY(m:GetPositionY() - (4 * ((monsterfontsize * 2) - 1)));
	        end

	        if(tarmob ~= nil and target:GetIsSubTargetActive() == 0 ) then 	
									-- Have a Non-Monster Target and no Sub-Target
	            if (NoMob == true) then -- Main Target is not Monster
	   	            p:SetVisible(true);
		            OutSev = tarmob.Name;
	            else 							-- Main Target is Monster and no Sub-Target
	   	            p:SetVisible(false);
		            OutSev = tarmob.Name; -- Shouldn't be seen, but filling values anyway to not cause any possible issues
	            end
	        else 							-- Have a Target and Sub-Target
	            p:SetVisible(true);
	            if (submob ~= nil) then
 	    	        OutSev = submob.Name;
	            end
	        end
	    end

	    p:SetFontHeight(monsterfontsize + 2);
        p:SetText(OutSev); -- Target/Sub-Target Name
    else
        m:SetVisible(false);
	    n:SetVisible(false);
 	    o:SetVisible(false);
	    p:SetVisible(false);
    end
-------- END Mob Info Window

-------- Player Window
    if(ascii_config.options.playwin == true) then
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
	    local selffontsize = ascii_config.selffont.size;
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
	        --u:GetBackground():SetColor(0x5f003f00);
	        SelfTPStr = '|cff70ff70|'..SelfTPStr..'|r';
	    else
	        --u:GetBackground():SetColor(0x5f000000);
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
	    if(ascii_config.options.zilda == true) then
	        local HeartFullTot = 0;
	        local HeartFull = 0;
	        local HeartFrac = 0;
	        local value = 1;

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
	            if(heart[HeartNum[x]] == nil) then
		            HeartContainer[x] = heart[1];
	            else
	                HeartContainer[x] = heart[HeartNum[x]];
	            end
	            HeartContainer[x]:SetPositionX(q:GetPositionX() + 85 + (x * 48));
	            HeartContainer[x]:SetPositionY(q:GetPositionY());
	            HeartContainer[x]:SetDrawFlags(1);
	            HeartContainer[x]:Render();
	            HeartContainer[x]:SetVisible(true);
	        end

            if (HPValue <= 0) then
                sResult = ' |cffff0000|DEAD ';
	        else
		        sResult = ' LIFE ';
	        end   

            s:SetPositionX(q:GetPositionX());
	        s:SetPositionY(q:GetPositionY() + ((selffontsize * 4) + 2 + 27));
            t:SetPositionX(q:GetPositionX());
	        t:SetPositionY(q:GetPositionY() + ((selffontsize * 6) + 3 + 27));
            r:SetPositionX(q:GetPositionX());
	        r:SetPositionY(q:GetPositionY() + ((selffontsize * 2) + 1 + 27));
            u:SetPositionX(q:GetPositionX());
	        u:SetPositionY(q:GetPositionY() + ((selffontsize * 2) + 1 + 27))
	        q:SetFontHeight(24);

	        SelfStr = SelfStr..SelfHPStr..' / '..SelfHPMStr..'   |cffff40b0|'..SelfMPStr..' / '..SelfMPMStr..'     '..SelfTPStr..' ';
	    else	-------------- THIS IS 'Q' LINE?
	        SelfStr = SelfStr..SelfTPStr..'     '..SelfHPStr..' / '..SelfHPMStr..'   |cffff40b0|'..SelfMPStr..' / '..SelfMPMStr..' |r';

	        if (HPValue >= 100) then 
		        HPColor = '|cff00ff00|';
	        elseif (HPValue >= 75) then
		        HPColor = '|cff008000|';
	        elseif (HPValue >= 50) then
		        HPColor = '|cffffff00|';
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
	        q:SetFontHeight(10);
            s:SetPositionX(q:GetPositionX());
	        s:SetPositionY(q:GetPositionY() + ((selffontsize * 4) + 2));
            t:SetPositionX(q:GetPositionX());
	        t:SetPositionY(q:GetPositionY() + ((selffontsize * 6) + 3));
            r:SetPositionX(q:GetPositionX());
	        r:SetPositionY(q:GetPositionY() + ((selffontsize * 2) + 1));
            u:SetPositionX(q:GetPositionX());
	        u:SetPositionY(q:GetPositionY() + ((selffontsize * 2) + 1))
	    end ------------- END 'Q' Stuff

        if (HPValue <= 33) then
            if (tick >= 15) then
                q:GetBackground():SetColor(0x5fFF0000);
		        u:GetBackground():SetColor(0x5FFF0000);
            else
                q:GetBackground():SetColor(0x5F000000);
		        u:GetBackground():SetColor(0x5F000000);
            end
        else
            q:GetBackground():SetColor(0x5F000000);
	        u:GetBackground():SetColor(0x5F000000);
	    end
   
	    u:SetVisible(true); 
	    u:SetText(SelfStr);
	    q:SetVisible(true);
	    q:SetText(string.format(sResult));

---- PET STUFF
        local pet = GetEntity(playerent.PetTargetIndex);

        if (playerent.PetTargetIndex > 0 and pet ~= nil) then ---- PLAYER HAS PET
            r:SetVisible(true);
	        s:SetVisible(true);
	        t:SetVisible(true);
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

	        r:SetText(string.format(petname));
            pResult = string.gsub(pResult,'_','|cffce8989|#|c00000000|',PHCheck);
	        s:SetText(string.format(pResult));


	        if (pettp >= 1000) then
	            PTColor = '|cff4040a0|';
	        end

	        if (petmp >= 100) then
	            PMColor = '|cfeb63fa|';
	        end
            pmResult = string.gsub(pmResult,'_',PMColor..'#|c00000000|',PMCheck);
	        t:SetText(string.format(tResult..'        '..pmResult));
	    else
            r:SetVisible(false);
	        s:SetVisible(false);
	        t:SetVisible(false);
        end
    else
	    q:SetVisible(false);
        r:SetVisible(false);
	    s:SetVisible(false);
	    t:SetVisible(false);
	    u:SetVisible(false);
    end
-------- END Self Window
end);

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
        { '/ASCII-Joy party    ', 'Toggles the Party Window on and off.' },
	    { '/ASCII-Joy solo     ', 'Toggles seeing yourself in Party Window while solo.' },
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
        ascii_config.selffont.position = { q:GetPositionX(), q:GetPositionY() };
        ascii_config.partyfont.position = { e:GetPositionX(), e:GetPositionY() };
        ascii_config.monsterfont.position = { m:GetPositionX(), m:GetPositionY() };	
   	    update_settings(ascii_config);
        print(chat.header(addon.name):append(chat.message('Window Positions saved, Thank you')));
        return;
    end

    if (#args == 2 and args[2]:any('party')) then
	    if(ascii_config.options.party == true) then
	        ascii_config.options.party = false;
	        print(chat.header(addon.name):append(chat.message('Party Window DISABLED.')));
	    elseif(ascii_config.options.party == false) then
	        ascii_config.options.party = true;
	        print(chat.header(addon.name):append(chat.message('Party Window ENABLED.')));
	    end
	    update_settings(ascii_config);
        return;
    end

    if (#args == 2 and args[2]:any('player')) then
	    if(ascii_config.options.playwin == true) then
	        ascii_config.options.playwin = false;
	        print(chat.header(addon.name):append(chat.message('Player Window DISABLED.')));
	    elseif(ascii_config.options.playwin == false) then
	        ascii_config.options.playwin = true;
	        print(chat.header(addon.name):append(chat.message('Player Window ENABLED.')));
	    end
	    update_settings(ascii_config);
        return;
    end

    if (#args == 2 and args[2]:any('solo')) then
        if(ascii_config.options.party == true) then
	        if(ascii_config.options.solo == false) then
	            ascii_config.options.solo = true;
	            print(chat.header(addon.name):append(chat.message('You will NOT see yourself in the Party Window while Solo.')));
	        elseif(ascii_config.options.solo == true) then
	            ascii_config.options.solo = false;
	            print(chat.header(addon.name):append(chat.message('You WILL see yourself in the Party Window while Solo.')));
	        end
	        update_settings(ascii_config);
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Party Window enabled to toggle this.')));
	    return;
        end
    end

    if (#args == 2 and args[2]:any('monster')) then
	    if(ascii_config.options.monster == true) then
	        ascii_config.options.monster = false;
	        print(chat.header(addon.name):append(chat.message('Monster Window DISABLED.')));
	    elseif(ascii_config.options.monster == false) then
	        ascii_config.options.monster = true;
	        print(chat.header(addon.name):append(chat.message('Monster Window ENABLED.')));
	    end
	    update_settings(ascii_config);
        return;
    end

    if (#args == 2 and args[2]:any('mon-pos')) then
        if(ascii_config.options.monster == true) then
	        if(ascii_config.options.monabov == false) then
	            ascii_config.options.monabov = true;
	            print(chat.header(addon.name):append(chat.message('You will see the monster info ABOVE their Health Bar.')));
	        elseif(ascii_config.options.monabov == true) then
	            ascii_config.options.monabov = false;
	            print(chat.header(addon.name):append(chat.message('You will see the monster info BELOW their Health Bar.')));
	        end
	        update_settings(ascii_config);
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Monster Window enabled to toggle this.')));
	        return;
        end
    end

    if (#args == 2 and args[2]:any('mon-info')) then
        if(ascii_config.options.monster == true) then
	        if(ascii_config.options.moninfo == false) then
	            ascii_config.options.moninfo = true;
	            print(chat.header(addon.name):append(chat.message('You WILL see the Monster Extended Info.')));
	        elseif(ascii_config.options.moninfo == true) then
	            ascii_config.options.moninfo = false;
	            print(chat.header(addon.name):append(chat.message('You will NOT see the Monster Extended Info.')));
	        end
	        update_settings(ascii_config);
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Monster Window enabled to toggle this.')));
	        return;
        end
    end

    if (#args == 2 and args[2]:any('zilda')) then
        if(ascii_config.options.playwin == true) then
	        if(ascii_config.options.zilda == false) then
	            ascii_config.options.zilda = true;
	            print(chat.header(addon.name):append(chat.message('You WILL see LIFE HEARTS from "The Myth of Zilda(tm)"!')));
	        elseif(ascii_config.options.zilda == true) then
	            ascii_config.options.zilda = false;
	            print(chat.header(addon.name):append(chat.message('You will see the old school ASCII Health Bar.')));
	        end
	        update_settings(ascii_config);
            return;
        else
	        print(chat.header(addon.name):append(chat.message('You need the Player Window enabled to toggle this.')));
	        return;
        end
    end

    -- Unhandled: Print help information..
    print_help(true);
end);