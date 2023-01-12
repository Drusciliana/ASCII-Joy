--[[
* Ashita - Copyright (c) 2014 - 2023 atom0s [atom0s@live.com]
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
addon.version = '1.3.4';
addon.desc = 'Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!';
addon.link = 'Discord name is just plain old D. (with the period), #2154 if that helps. Stay on top of updates! https://github.com/Drusciliana/ASCII-Joy';

require ('common');
local chat = require('chat');
local fonts = require('fonts');
local primitives = require('primitives');
local settings = require('settings');

-------------- START Global Variables
local default_settings =
T{
    options = T{
    party =     true, 		
    solo =      false, 
    alliance =  false,
    order =     true,		
    monster =   true, 		
    moninfo =   false, 
    monabov =   true,
    tarplay =   false,
    playwin =   true,
    exp =       false,
    zilda =     false,
    grow =      true,
    cast =      true,
    fairy =     true,
    offset =    -4
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
    all1font = T{
        font_family = "Consolas",
        position_x = 450, 		
        position_y = 650,
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
    all2font = T{
        font_family = "Consolas",
        position_x = 500, 		
        position_y = 550,
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
    castfont = T{
        font_family = "Consolas",
        position_x = 500, 		
        position_y = 700,
        font_height = 10,
        color = 0xffffffff,
        bold = true,
        locked = false,
        text = '',
        background = T{
            color = 0xff000000,
            visible = true
        }
    },
    expfont = T{
        font_family = "Consolas",
        position_x = 0, 		
        position_y = 900,
        font_height = 12,
        color = 0xffffffff,
        bold = true,
        locked = false,
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
    subtarfont = T{
        font_family = "Consolas",  		
        position_x = 800, 		
        position_y = 250,
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
-- Stuff to stop the for loop in finding mobs. Put it out here so it doesn't get overwritten every render call when the loop stops.
local MobStr = ''; 
local MobName = ''; 
local MobAggro = '';
local MobJob = '   '; -- Placeholder -- 
local MobWeak = '             Monster Info unavailable'; 
local LastMob = 0;
local MobLvl = 0; 
local MobDefEva ='(   ????   )';
local MobType = '     ???     ';
local MobLvlStr = '???';
local SneakAttack = false;
local CheckLock = true; 
local GotPacket = true; -- Latch so we don't flood server with packets.
local PetTargetsID = 0;
local checker = T{ ---- From Atom0s' checker addon.
    conditions = T{
        [0xAA] = '+EVA, +DEF',
        [0xAB] = '    +EVA  ',
        [0xAC] = '+EVA, -DEF',
        [0xAD] = '    +DEF  ',
        [0xAE] = '          ',
        [0xAF] = '    -DEF  ',
        [0xB0] = '-EVA, +DEF',
        [0xB1] = '    -EVA  ',
        [0xB2] = '-EVA, -DEF',	
	},
    types = T{
        [0x40] = ' |cffa0a0a0|    Too Weak|r',
        [0x41] = ' |cff00ff00|  Incr. Easy|r',
        [0x42] = ' |cff00a000|   Easy Prey|r',
        [0x43] = ' |cffffffff|Decent Chal.|r',
        [0x44] = ' |cffa0a000|  Even Match|r',
        [0x45] = ' |cffffff00|       Tough|r',
        [0x46] = ' |cffa00000|  Very Tough|r',
        [0x47] = ' |cffff0000| Incr. Tough|r',
    },
};
-------------------------------------------------------------------
local tick = 0;
local afktimer = 0;
local FairyPosX = 0;
local FairyPosy = 0;
local FairyMessage = '';
local FairyMesTimer = 0;
local FairySafeTime = 0;
local Progress = 0; -- For Cast Bar. Can't find variable to show if we are casting or interrupted or not. Maybe missing something.
local LastZone = 9999; -- To remember when we are zoning.
local mb_data = {};
local arraySize = 0;
local HeartNum = {};
local HeartContainer = 
	--Lame attempt at an array (only way I could get new primitive library to work. PrimitiveManager handled textures differently it seems).
T{
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

local Sword = -- Trying to change TP to look like sword icons.
T{
	[1] = {},
	[2] = {},
	[3] = {}
}

local Fairy = -- This would probably turn out to be annoying. Oh well. Haha.
T{
    [1] = {},
    [2] = {}
}

local jobs = T{
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

local ascii = T{                    -- FONT INFORMATION, WORKING VARIABLES.
    font_a = nil, -- Alliance 1
    font_b = nil, -- Allaince 2
    font_c = nil, -- Cast Bar
    font_d = nil, -- Experience Bar
    font_e = nil, -- Party Zone Name
    font_f = T{ }, -- Party	Mana
    font_g = T{ }, -- Party HP
    font_h = T{ }, -- Party Space
--  font_i
--  font_j
--  font_k
    font_l = nil, -- Monster Checker
    font_m = nil, -- Monster HP
    font_n = nil, -- Monster Name
    font_o = nil, -- Monster Aggro/Weak
    font_p = nil, -- Tar/Sub Name
    font_q = nil, -- Player Health
    font_r = nil, -- Pet Name
    font_s = nil, -- Pet HP
    font_t = nil, -- Pet Mana/TP
    font_u = nil, -- Player HP/Mana/TP
    font_v = nil, -- Fairy Message
    font_w = nil, -- Pet Target
--  font_x
--  font_y
--  font_z
	-------
    settings = settings.load(default_settings)
}
------------ END Global Variables

local function update_settings(s)

    if (s ~= nil) then
        ascii.settings = s;
    end

    if (ascii.font_a ~= nil) then
        ascii.font_a:apply(ascii.settings.all1font);
    end
    if (ascii.font_b ~= nil) then
        ascii.font_b:apply(ascii.settings.all2font);
    end
    if (ascii.font_c ~= nil) then
        ascii.font_c:apply(ascii.settings.castfont);
    end
    if (ascii.font_d ~= nil) then
        ascii.font_d:apply(ascii.settings.expfont);
    end
    if (ascii.font_e ~= nil) then
        ascii.font_e:apply(ascii.settings.partyfont);
    end
    if (ascii.font_l ~= nil) then
        ascii.font_l:apply(ascii.settings.monsterfont);
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
        ascii.font_p:apply(ascii.settings.subtarfont);
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
    if (ascii.font_v ~= nil) then
        ascii.font_v:apply(ascii.settings.selffont);
    end
    if (ascii.font_w ~= nil) then
        ascii.font_w:apply(ascii.settings.selffont);
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

local function save_everything() -- Need this to save window locations, so not to assign new values every render call.
    ascii.settings.all1font.position_x = ascii.font_a.position_x;
    ascii.settings.all2font.position_x = ascii.font_b.position_x;
    ascii.settings.castfont.position_x = ascii.font_c.position_x;
    ascii.settings.selffont.position_x = ascii.font_q.position_x;
    ascii.settings.partyfont.position_x = ascii.font_e.position_x;
    ascii.settings.monsterfont.position_x = ascii.font_m.position_x;
    ascii.settings.subtarfont.position_x = ascii.font_p.position_x;
    ascii.settings.expfont.position_x = ascii.font_d.position_x;
    ascii.settings.all1font.position_y = ascii.font_a.position_y
    ascii.settings.all2font.position_y = ascii.font_b.position_y    
    ascii.settings.castfont.position_y = ascii.font_c.position_y; 
    ascii.settings.selffont.position_y = ascii.font_q.position_y; 
    ascii.settings.partyfont.position_y = ascii.font_e.position_y;
    ascii.settings.monsterfont.position_y = ascii.font_m.position_y;
    ascii.settings.subtarfont.position_y = ascii.font_p.position_y;
    ascii.settings.expfont.position_y = ascii.font_d.position_y;    
    settings.save();
end

local function SendCheckPacket(mobIndex)
    local mobId = AshitaCore:GetMemoryManager():GetEntity():GetServerId(mobIndex);
    local checkPacket = struct.pack('LLHHBBBB', 0, mobId, mobIndex, 0x00, 0x00, 0x00, 0x00, 0x00):totable();
    AshitaCore:GetPacketManager():AddOutgoingPacket(0xDD, checkPacket);
end

local function GetEntityByServerId(ServerID)
    for x = 0, 2303 do
        local TempEntity = GetEntity(x);
        if (TempEntity ~= nil and TempEntity.ServerId == ServerID) then
            return TempEntity;
        end
    end
    return nil;
end

local function GetFairyMessage (mestype)
    local Message = 'Blah!';
    local count = 0;
    local _, fairy_data = pcall(require,'data.'..tostring('Fairy'));
    if (fairy_data == nil or type(fairy_data) ~= 'table') then
        fairy_data = { };
    else
        count = #fairy_data[mestype];
        Message = fairy_data[mestype][math.random(1,count)];
    end
    return Message;
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
-- Sword TP Icons
    for x = 1, 3 do
        Sword[x] = primitives.new();
        Sword[x].position_x = 0;
        Sword[x].position_y = 0;
        Sword[x].width = 48;
        Sword[x].height = 48;
        Sword[x].color = 0xffffffff;
        Sword[x].texture = ('%s\\addons\\%s\\icons\\%s.png'):fmt(AshitaCore:GetInstallPath(),'ASCII-Joy', (x+5)); -- 1 to 5 reserved for hearts.
        Sword[x].visible = false;
    end
    -- Anooying Fairy AFK Icons
    for x = 1, 2 do
        Fairy[x] = primitives.new();
        Fairy[x].position_x = 0;
        Fairy[x].position_y = 0;
        Fairy[x].width = 48;
        Fairy[x].height = 48;
        Fairy[x].color = 0xffffffff;
        Fairy[x].texture = ('%s\\addons\\%s\\icons\\%s.png'):fmt(AshitaCore:GetInstallPath(),'ASCII-Joy', (x+8)); -- 1 - 8 reserved for hearts and swords.
        Fairy[x].visible = false;
    end
-- Cast Bar label
    ascii.font_c = fonts.new(ascii.settings.castfont);
-- Exp Bar label
    ascii.font_d = fonts.new(ascii.settings.expfont);
-- Monster Window labels
    ascii.font_l = fonts.new(ascii.settings.monsterfont);
    ascii.font_m = fonts.new(ascii.settings.monsterfont);
    ascii.font_n = fonts.new(ascii.settings.monsterfont);
    ascii.font_o = fonts.new(ascii.settings.monsterfont);
    ascii.font_p = fonts.new(ascii.settings.subtarfont);
---- Player Window labels
    ascii.font_q = fonts.new(ascii.settings.selffont);
    ascii.font_r = fonts.new(ascii.settings.selffont);
    ascii.font_s = fonts.new(ascii.settings.selffont);
    ascii.font_t = fonts.new(ascii.settings.selffont);
    ascii.font_u = fonts.new(ascii.settings.selffont);
    ascii.font_v = fonts.new(ascii.settings.selffont);
    ascii.font_w = fonts.new(ascii.settings.selffont);
---- Party Window labels
    ascii.font_a = fonts.new(ascii.settings.all1font);
    ascii.font_b = fonts.new(ascii.settings.all2font);
    ascii.font_e = fonts.new(ascii.settings.partyfont);
--    for x = 0, 17 do  -- Not ready do try alliance yet
    for x = 0, 17 do
        ascii.font_f[x] = fonts.new(ascii.settings.partyfont);
        ascii.font_h[x] = fonts.new(ascii.settings.partyfont);
    end
    for x = 0, 5 do -- no font_g in alliance windows, don't waste the memory making more than 5.
        ascii.font_g[x] = fonts.new(ascii.settings.partyfont);
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

    if (ascii.font_a ~= nil) then
	    ascii.font_a:destroy();
	    ascii.font_a = nil;
    end
    if (ascii.font_b ~= nil) then
	    ascii.font_b:destroy();
	    ascii.font_b = nil;
    end
    if (ascii.font_c ~= nil) then
	    ascii.font_c:destroy();
	    ascii.font_c = nil;
    end
    if (ascii.font_d ~= nil) then
	    ascii.font_d:destroy();
	    ascii.font_d = nil;
    end
    if (ascii.font_e ~= nil) then
	    ascii.font_e:destroy();
	    ascii.font_e = nil;
    end
    if (ascii.font_l ~= nil) then
	    ascii.font_l:destroy();
	    ascii.font_l = nil;
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
    if (ascii.font_v ~= nil) then
	    ascii.font_v:destroy();
	    ascii.font_v = nil;
    end
    if (ascii.font_w ~= nil) then
	    ascii.font_w:destroy();
	    ascii.font_w = nil;
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
                HeartContainer[x][y] = T{ };
            end;
        end;
        HeartContainer = T{ };
    end    
    if (Sword ~= nil) then
        for x = 1, 3 do
            Sword[x].visible = false;
            Sword[x]:destroy();
            Sword[x] = T{ };
        end
        Sword = T{ };
    end	
    if (Fairy ~= nil) then
        for x = 1, 2 do
            Fairy[x].visible = false;
            Fairy[x]:destroy();
            Fairy[x] = T{ };
        end
        Fairy = T{ };
    end	
end);

local function FairyCatch(type, X, Y)
    FairyMessage = GetFairyMessage(type);  
    local NewFairyPosX = X;
    local NewFairyPosY = Y; 
    if (type == 1 or type == 5) then -- Make Idle  and Death Catch only teleport it around randomly.
        NewFairyPosX = math.random(100, 1800);
        NewFairyPosY = math.random(100, 900);
    elseif (type == 3) then
        NewFairyPosX = ascii.font_m.position_x;
        NewFairyPosY = ascii.font_m.position_y;
    end

    for x = 1, 2 do 
        Fairy[x].visible = false;
        Fairy[x]:destroy(); -- Destroy them for those cheating and holding down the Shift Key the whole time.
        Fairy[x] = primitives.new();
        Fairy[x].position_x = NewFairyPosX;
        Fairy[x].position_y = NewFairyPosY;
        Fairy[x].width = 48;
        Fairy[x].height = 48;
        Fairy[x].color = 0xffffffff;
        Fairy[x].texture = ('%s\\addons\\%s\\icons\\%s.png'):fmt(AshitaCore:GetInstallPath(),'ASCII-Joy', (x+8)); -- 1 through 8 reserved for hearts and swords.
        Fairy[x].visible = false; -- Had a reason, there was a need, to declare visible false before and after the destroy. Forget. 
    end
    FairyMesTimer = 0; -- Start the timer.    
    FairySafeTime = 0;
    return NewFairyPosX, NewFairyPosY;
end    

local function FairyFun(playerent)
        ---Types are 1 for idle, 3 for Sneak Attack, 5 for Death.
    local FairyWing = 0;
    local FairyTime = 10000; -- How many frames until AFK?
    local FairyShow = false;
    local FairyType = 0;

    if (playerent == nil) then
        return;
    end

    if (SneakAttack == true and playerent.HPPercent > 0) then -- Sneak Attack and alive.
        FairyType = 3;
    elseif (playerent.HPPercent <= 0) then -- Dead.
        FairyType = 5;
    else -- Must be idling.
        FairyType = 1;
    end

    if (Fairy[1].visible == true or Fairy[2].visble == true) then
        for x = 1, 2 do
            Fairy[x].visible = false; -- Blank them.
        end
    end

    if (FairyType == 1 or FairyType == 5 or FairyType == 3) then -- Main Function
        afktimer = afktimer + 1;        
        if ((AshitaCore:GetMemoryManager():GetCastBar():GetPercent() ~= 1 and Progress ~= (AshitaCore:GetMemoryManager():GetCastBar():GetPercent() * 100)) or
            playerent.AnimationTime ~= 0 or (playerent.ActionTimer2 ~= 0 and playerent.ActionTimer2 < 1800)) then
                afktimer = 0;  -- All this means is if we are casting, fighting, or moving. Therefore, not AFK.
        end

        if (FairyPosX == 0 or FairyPosY == 0 or afktimer == FairyTime)  then 
            FairyPosX = math.random(100, 1700);
            FairyPosY = math.random(100, 900);
            for x = 1, 2 do
                Fairy[x].position_x = FairyPosX;
                Fairy[x].position_y = FairyPosY;
            end
        end

        if (afktimer > FairyTime or (FairyType == 5 and afktimer > (FairyTime / 10)) or FairyType == 3) then -- Why wait if they're dead?
            if (afktimer > 60000) then -- We don't know how large the integer can be, so we don't want to exceed it's boundaries.
                afktimer = FairyTime + 1; -- This way the Fairy  never resets to random location. Will go on forever.
            end

            FairyMesTimer = FairyMesTimer + 1;

            if (FairyType ~= 3) then
                if (FairyPosX ~= Fairy[1].position_x or FairyPosY ~= Fairy[1].position_y or
                    FairyPosX ~= Fairy[2].position_x or FairyPosY ~= Fairy[2].position_y) then -- Catching the Fairy?
                        FairyPosX, FairyPosY = FairyCatch(FairyType, FairyPosX, FairyPosY);
                end
            elseif ((Fairy[1].position_x > (ascii.font_m.position_x + 40) or Fairy[1].position_x < ascii.font_m.position_x or
                    Fairy[2].position_x > (ascii.font_m.position_x + 40) or Fairy[2].position_x < ascii.font_m.position_x or
                    Fairy[1].position_y > (ascii.font_m.position_y + 20) or Fairy[1].position_y < (ascii.font_m.position_y - 20) or  
                    Fairy[2].position_y > (ascii.font_m.position_y + 20) or Fairy[2].position_y < (ascii.font_m.position_y - 20)) and 
                    (Fairy[1].visible == true or Fairy[2].visible == true)) then -- Put the True condition to make sure she's already there, to prevent initial False Positive checks on Sneak Attack?
                        FairyPosX, FairyPosY = FairyCatch(FairyType, FairyPosX, FairyPosY);
            end             

            FairySafeTime = FairySafeTime + 1;
            if (FairyType == 3) then
                FairyTime = FairyTime / 2;
            end
            if (FairySafeTime >= (FairyTime / 10)) then
                FairySafeTime = 0;
                FairyMessage = GetFairyMessage(FairyType + 1);
                FairyMesTimer = 0; -- Start the timer.
            end

            FairyPosX = FairyPosX + math.random(-4, 4);
            FairyPosY = FairyPosY + math.random(-4, 4);
            if (FairyType == 3) then -- Keep her near the Monster Bar.
                if (FairyPosX > (ascii.font_m.position_x + 40) or FairyPosX < ascii.font_m.position_x or -- Started at + 20, so including that shift.
                    FairyPosY > (ascii.font_m.position_y + 20) or FairyPosY < (ascii.font_m.position_y - 20)) then
                        FairyPosX = ascii.font_m.position_x + 20;
                        FairyPosY = ascii.font_m.position_y;
                        for x = 1, 2 do
                            Fairy[x].position_x = FairyPosX;
                            Fairy[x].position_y = FairyPosY;
                        end
                end
            end

            if (FairyPosX < 0 or FairyPosY < 0 or FairyPosX > 1800 or FairyPosY > 900) then
                if (FairyType ~= 3) then -- Try to keep it from going off the edges of the screen (not sure people's resolution).
                    FairyPosX = math.random(100, 1800);
                    FairyPosY = math.random(100, 900);
                end
            end
            FairyShow = true;
        else
            Fairy[1].visible = false;
            Fairy[2].visible = false;
            FairyShow = false;
        end
    end 

        -- Always here.
    if (FairyShow == true) then
        if (FairyMesTimer >= 200) then -- Leave at 200 frames
            FairyMesTimer = 0; -- Reset the timer and the messages
            FairyMessage = '';
            FairtMesNum = 0;
        end

        for x = 1, 2 do -- Actually move it.
            Fairy[x].position_x = FairyPosX;
            Fairy[x].position_y = FairyPosY;
        end
        _, FairyWing = math.modf(tick / 10);
        if (FairyWing >= .5) then
            Fairy[1].visible = true;
            Fairy[2].visible = false;
        else
            Fairy[1].visible = false;
            Fairy[2].visible = true;
        end

        if (FairyMesTimer < 100) then -- Leave at 100 frames.
            ascii.font_v.font_family = 'Arial';
            ascii.font_v.font_height = 16;
            ascii.font_v.color = 0xff000000;
            ascii.font_v.bold = true;
            ascii.font_v.locked = true;
            if (Fairy[1].position_x < 1600) then -- Keep the text on the screen.
                ascii.font_v.right_justified = false;
                ascii.font_v.position_x = Fairy[1].position_x + 48; 
            else
                ascii.font_v.right_justified = true;
                ascii.font_v.position_x = Fairy[1].position_x;
            end
            if (Fairy[1].position_y < 80) then -- Keep the text on the screen.
                ascii.font_v.position_y = Fairy[1].position_y + 30;
            else
                ascii.font_v.position_y = Fairy[1].position_y - 30;
            end
            ascii.font_v.background.color = 0xffffffff;
            ascii.font_v.background.visible = true;
            ascii.font_v.visible = true;
            ascii.font_v.text = FairyMessage;
        else
            ascii.font_v.text = '';
            ascii.font_v.visible = false;
        end
    else
        ascii.font_v.text = '';
        ascii.font_v.visible = false;
    end
 end
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

    local offset = ascii.settings.options.offset;
    local solo = 0; 

		--** Hopefully cleans and fixes everything up while zoning or loading
    if (player:GetMainJobLevel() == 0 or player == nil or playerent == nil) then 
        for x = 0, 17 do
           ascii.font_f[x].visible = false;
           if (x <= 5) then -- font_g isn't used with alliance, so never greater than 5. Will nil out otherwise.
                ascii.font_g[x].visible = false;
           end
           ascii.font_h[x].visible = false;
        end
        for x = 1, 12 do
            for y = 1, 5 do
                HeartContainer[x][y].visible = false;
            end	
        end
        for x = 1, 3 do
            Sword[x].visible = false;
        end
        for x = 1, 2 do
            Fairy[x].visible = false;
        end
        ascii.font_a.visible = false;
        ascii.font_b.visible = false;
        ascii.font_c.visible = false;
        ascii.font_d.visible = false;        
        ascii.font_e.visible = false;
        ascii.font_l.visible = false;
        ascii.font_m.visible = false;
        ascii.font_n.visible = false;
        ascii.font_o.visible = false;
        ascii.font_p.visible = false;
        ascii.font_q.visible = false;
        ascii.font_r.visible = false;
        ascii.font_s.visible = false;
        ascii.font_t.visible = false;
        ascii.font_u.visible = false;
        ascii.font_v.visible = false;
        ascii.font_w.visible = false;
        return;
    else
        ascii.font_a.locked = false; --
        ascii.font_b.locked = false; --
        ascii.font_c.locked = false; --
        ascii.font_d.locked = false; --
        ascii.font_e.locked = false; -- Seem to have to have these here.
        ascii.font_m.locked = false; -- Declaring these (not true) doesn't work, from the settings making all set true.
        ascii.font_p.locked = false; --
        ascii.font_q.locked = false; -- Oh well.
    end 
		  -- *** START HERE ***
    tick = tick + 1;
    if (tick >= 30) then -- Not sure why I use greater than. Maybe bad feeling tick will increment too soon one day. Haha.
        CheckLock = false; -- We don't want to flood the server too much, only unlock the Check every 30 renders.
       	tick = 0;
    end

    for x = 0, 5 do --** Alliance may be different 
        if (party:GetMemberIsActive(x) == 1) then
            solo = solo + 1;
        end
    end

    if (ascii.settings.options.fairy == true and ascii.settings.options.zilda == true) then
        FairyFun(playerent);
    end 
				--** Changing zones? Pull a new data file
    ZoneIDStart = party:GetMemberZone(0);
	----** WE NEED DATAFILES EVEN WITHOUT MONSTER WINDOW TO COMPARE NPC's, MONSTERS, OBJECTS, PLAYERS, etc. FOR TARGET WINDOW! MAYBE?
	----** OR IN CASE MONSTER WINDOW IS TURNED ON BEFORE THEY ZONE, WHEN LASTZONE AND ZONEIDSTART WOULD BE THE SAME ANYWAY.
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

-------- Cast Bar
    if (ascii.settings.options.cast == true) then
        local CastBar = AshitaCore:GetMemoryManager():GetCastBar();
        local CastPer = 100 * CastBar:GetPercent();
        local CastType = CastBar:GetCastType();
                 --      |123456789012345678901234567890
        local CastStr = '|_____________________________|cffffffff||'; -- It disappears when it's filled, so only show 29 spaces or it will look like a blank one is always there.
        local CastChk = math.floor(CastPer / (100/30)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
        local CastColor = '|cffff1493|';
    	
        if (CastType ~= 0) then
            CastColor = '|cffffffff|';
        elseif (CastType ~= 1) then
            CastColor = '|cffffff00|';
        elseif (CastType ~= 2) then
            CastColor = '|cff00ffff|';
        elseif (CastType ~= 3) then
            CastColor = '|cffff00ff|';
        end

        CastStr = string.gsub(CastStr,'_',CastColor..'@',CastChk);
	    CastStr = string.gsub(CastStr,'_',' ');

        if (CastPer < 100 and Progress ~= CastPer) then  -- VVV
            Progress = CastPer; -- Only way to see if the Cast Bar is actually moving, that I can think of.
            ascii.font_c.visible = true;
        else
            ascii.font_c.visible = false;
        end
        ascii.font_c.text = CastStr;
    end
-------- END Cast Bar

-------- Experience Bar
    if (ascii.settings.options.exp == true) then     --  100 Squares? VVV  VVV
        if (player ~= nil) then
            local ExpStr = '||cffffff00|____________________________________________________________________________________________________|cffffffff||'
            local ExpNeed = player:GetExpNeeded();
            local ExpCurr = player:GetExpCurrent();
            local ExpPer = 100 * (ExpCurr/ExpNeed);
            local ExpChk = math.floor(ExpPer / (100/100)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!

            ExpStr = string.gsub(ExpStr,'_','#',ExpChk);
            ExpStr = string.gsub(ExpStr,'_',' ');
            ascii.font_d.visible = true;
            ascii.font_d.font_height = 12;
            ascii.font_d.text = ExpStr;
        end
    end
-------- EBD Experience Bar

-------- Party Window
    if (ascii.settings.options.party == true) then
        local cury = 0;
        local newy = 0;
        local spcy = 0;
        local leadstar = '|r ';
        local partyfontsize = ascii.settings.partyfont.font_height; 
        local fontsize = partyfontsize * 2; 
        local elsewhere = true;
        local StartNumber = 0;
        local EndNumber = 5;
        local Order = 1;
        local First = -1;
        if (ascii.settings.options.order == true) then
            StartNumber = 5;
            EndNumber = 0;
            Order = -1;
        end

        for x = StartNumber, EndNumber, Order do  
        --for x = 0, 5 do
            elsewhere = true;
    
            if (party:GetMemberIsActive(x) == 0) then
                ascii.font_f[x].visible = false;
                ascii.font_g[x].visible = false;
                ascii.font_h[x].visible = false;
            else
                if (party:GetMemberZone(0) == party:GetMemberZone(x)) then 
                    elsewhere = false;  
                end
        ----- Setup Party Window (NEATEST I THINK I CAN MAKE IT, WORKS BEST ON 10 POINT FONTS at 1920x1080)
	    ----- "cur" is Health, "new" is Mana, "spc" is blank line between party members -- MAYBE PUT SOME SORT OF FOUND CHECK FOR THE FIRST PERSON IF GOING DESCENDING ORDER.
                if (spcy == 0) then -- Maybe make this spcy == 0, as it would only be 0 for the first player in the group, then it would be set, was x == 0;
                    spcy = ascii.font_e.GetPositionY();
                else
                    spcy = cury - fontsize - offset;
                end
                if (First == -1) then
                    First = x;
                end
                newy = spcy - fontsize - offset;
                cury = newy - fontsize - offset;               
                
                ascii.font_f[x].position_x = ascii.font_e.position_x;
                ascii.font_f[x].position_y = cury;
                ascii.font_g[x].position_x = ascii.font_e.position_x;
                ascii.font_g[x].position_y = newy;
                ascii.font_h[x].position_x = ascii.font_e.position_x;
                ascii.font_h[x].position_y = spcy;

                local ZoneName = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(x));
                local Name = party:GetMemberName(x);
                local Health = party:GetMemberHP(x);
                local HPValue = party:GetMemberHPPercent(x);
                local HPCheck = math.floor(HPValue / (100/20)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                local HealthStr = '';
                local HPColor = '';
                local hResult = '____________________|cffffffff|';
                local NameColor = '|cff00ffff|';
                local Output = '';
                local OutTwo = '';
                local OutThr = '';
                local TarStar = ' ';
    ----  Name Color Matching if Target is in Party
                if (target == nil) then
                    NameColor = '|cff00ffff|';
                else
                    local ID = party:GetMemberTargetIndex(x);
                    local ATA = target:GetActionTargetActive();
                    local ATSI = target:GetActionTargetServerId();
                    local TargetID = target:GetTargetIndex(0); -- 0 is target, 1 is subtarget?
                    NameColor = '|cff00ffff|';
                    TarStar = ' ';
                    if ((ID == TargetID or (party:GetMemberServerId(x) == ATSI and ATA == 1)) and elsewhere == false) then 
                        if (party:GetMemberServerId(x) == ATSI and ATA == 1) then -- some reason changing combat targets triggers purple on player.
                            if(target:GetTargetIndex(1) or target:GetIsSubTargetActive() == 1) then -- Not sure why I made that a boolean? Forgot.
                                NameColor = '|cffaf4be2|';
                                TarStar = '|cffff69B4|*';
                            end
                        elseif (ID == TargetID and ID ~= 0) then
                            NameColor = '|cffffff00|';
                        end
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
                    hResult = string.gsub(hResult,'_',HPColor..'#',HPCheck);	
                    hResult = string.gsub(hResult,'_',' ');
                end

                HealthStr = tostring(Health);
    	        while HealthStr:len() < 4 do 
                    HealthStr = " "..HealthStr; 
                end

    ---- Format Player names to 10 characters
                while Name:len() < 9 do 
                    Name = " "..Name; 
                end
                Name = string.sub(Name, 1, 9);
		
    -------- Get Party Mana, TP, Class
                local Mana = party:GetMemberMP(x);
                local MaValue = party:GetMemberMPPercent(x);
                local MaCheck = math.floor(MaValue / (100/13)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                local mResult = '|r|_____________|cffffffff||';
                local MaColor = '|r';
                local TP = party:GetMemberTP(x);
                local TPColor = '|c77777777|';
                local MJob = '';
                local SJob = '';
                local TJob = ''; -- Total, Sum of M and S.
                local ManaStr = '';
                local TPValue = '';

    ---- Get Party Members' Job(s)
                if (party:GetMemberMainJob(x) == nil or party:GetMemberMainJob(x) == 0 or party:GetMemberMainJob(x) > 22) then
                    TJob = 'XXX/XXX';
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
                mResult = string.gsub(mResult,'_',MaColor..'@',MaCheck); 
                mResult = string.gsub(mResult,'_',' ');

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
                
                if (solo <= 1 and ascii.settings.options.solo == true) then -- Making text for font_e, the movable zone name line.
                    OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(0)); 
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
                    ascii.font_e.visible = true;
                    if (HPValue <= 33 and elsewhere == false) then
                        if (tick >= 15 and party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and party:GetMemberMainJob(x) ~= 0) then
                            ascii.font_f[x].background.color = 0x5fff0000;
                        else
                            ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                        end
                    else
                        ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                    end

                    if (elsewhere == false and ((party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and 
                                 party:GetMemberMainJob(x) ~= 0) or (party:GetMemberMainJob(x) == 0 and party:GetMemberHPPercent(x) > 0))) then  -- Try to put in Zone Name for far away friends
                        if (party:GetMemberMainJob(x) == 0 or party:GetMemberMainJob(x) > 22) then
                            TJob = ' ANON? ';
                        end
                        Output = (TarStar..NameColor..Name..leadstar..'|'..hResult..'||cff00ff00|'..HealthStr);
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

                        Output = (' '..NameColor..Name..leadstar..'| |cc0c0c0c0| '..tostring(ZoneName)..'|r  ');
                        OutTwo = '                                     ';
                        ascii.font_f[x].text = tostring(Output);
                        ascii.font_g[x].text = tostring(OutTwo);
                    end	    
                end

                if (x == First) then      -- We only want the bottom line to be moveable: "e" -- Was 0, now StartNum, now First
                    OutThr = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(0));
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
                    ascii.font_e.visible = true; -- Don't need to have a text set for font_e since it should have been set when it was 0.
                    ascii.font_h[x].visible = true;
                    ascii.font_h[x].text = tostring(OutThr);
                end
            end
        end -- End Player Party Main Window
        -- ALLIANCE WINDOWS
        if (ascii.settings.options.alliance == true) then
            for z = 1, 2 do
                local startnum = 0;
                local endnum = 0;
                local count = 0;
                local offtooff = 0;
                local increment = 0;
                if (ascii.font_e.font_height == 14) then
                    offtooff = 1;
                end
                if (ascii.settings.options.order == true) then
                    startnum = 11;
                    endnum = 6;
                    increment = -1;
                    if (z == 2) then
                        startnum = 17;
                        endnum = 12;
                    end
                else
                    startnum = 6;
                    endnum = 11;
                    increment = 1;
                    if (z == 2) then
                        startnum = 12;
                        endnum = 17;
                    end
                end
                for x = startnum, endnum, increment do
                    if (party:GetMemberIsActive(0) ~= x) then 
                        count = count + 1;
                    end
                end

                if (count == 0) then
                    for x = startnum, endnum, increment do  
                        ascii.font_f[x].visible = false;
                        ascii.font_h[x].visible = false;
                    end
                    if (z == 1) then
                        ascii.font_a.visible = false; -- Since there's no players in this Alliance, no sense seeing it.
                    else
                        ascii.font_b.visible = false; -- Since there's no players in this Alliance, no sense seeing it.
                    end
                else
                    for x = startnum, endnum do  
                        elsewhere = true;

                        if (party:GetMemberIsActive(x) == 0) then 
                            ascii.font_f[x].visible = false;
                            ascii.font_h[x].visible = false;
                        else
                            if (party:GetMemberZone(x) == party:GetMemberZone(0)) then 
                                elsewhere = false;  
                            end
             ----- Setup Alliance Windows
             ----- "cur" is Health, "new" is Mana, "spc" is blank line between party members
                            if (x == startnum) then
                                if (z == 1) then
                                    spcy = ascii.font_a.GetPositionY();
                                else
                                    spcy = ascii.font_b.GetPositionY();
                                end
                            else
                                spcy = cury - 20 - offset - offtooff; -- fontsize is 10 and it was doubled in the normal party function. Put in offset to the offset.
                            end
                            cury = spcy - 20 - offset - offtooff; -- fontsize is 10 and it was doubled in the normal party function. Put in offset to the offset.
                            if (z == 1) then
                                ascii.font_f[x].position_x = ascii.font_a.position_x;
                                ascii.font_h[x].position_x = ascii.font_a.position_x;
                            else
                                ascii.font_f[x].position_x = ascii.font_b.position_x;
                                ascii.font_h[x].position_x = ascii.font_b.position_x;
                            end

                            ascii.font_f[x].position_y = cury;
                            ascii.font_h[x].position_y = spcy;
                            ascii.font_f[x].font_height = 10;
                            ascii.font_h[x].font_height = 10;

                            local ZoneName = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(x)); 
                            local Name = party:GetMemberName(x);
                            local Health = party:GetMemberHP(x);
                            local HPValue = party:GetMemberHPPercent(x);
                            local HPCheck = math.floor(HPValue / (100/20)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                            local HealthStr = '';
                            local HPColor = '';
                            local hResult = '____________________|cffffffff|';
                            local NameColor = '|cff00ffff|';
                            local Output = '';
                            local OutTwo = '';
                            local OutThr = '';
                            local TarStar = ' ';
              ----  Name Color Matching if Target is in Alliance
                            if (target == nil) then
                                NameColor = '|cff00ffff|';
                            else
                                local ID = party:GetMemberTargetIndex(x); 
                                local ATA = target:GetActionTargetActive();
                                local ATSI = target:GetActionTargetServerId();
                                local TargetID = target:GetTargetIndex(0); -- 0 is target, 1 is subtarget?
                                NameColor = '|cff00ffff|';
                                TarStar = ' ';                          
                                if ((ID == TargetID or (party:GetMemberServerId(x) == ATSI and ATA == 1)) and elsewhere == false) then
                                    if (party:GetMemberServerId(x) == ATSI and ATA == 1) then -- some reason changing combat targets triggers purple on player.
                                        if(target:GetTargetIndex(1) ~= 0 or target:GetIsSubTargetActive() == 1) then 
                                            NameColor = '|cffaf4be2|';
                                            TarStar = '|cffff69B4|*';
                                        end
                                    elseif (ID == TargetID and ID ~= 0) then
                                        NameColor = '|cffffff00|';
                                    end
                                end
                            end
               ---- Find Color for HP Bar and Overall HP Output for Alliance
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
                                hResult = string.gsub(hResult,'_',HPColor..'#',HPCheck);	
                                hResult = string.gsub(hResult,'_',' ');
                            end

                            HealthStr = tostring(Health);
                            while HealthStr:len() < 4 do 
                                HealthStr = " "..HealthStr; 
                            end

               ---- Format Player names to 8 characters for Alliance
                            while Name:len() < 8 do 
                                Name = " "..Name; 
                            end
                            Name = string.sub(Name, 1, 8);
               -------- Get TP for Alliance
                            local TP = party:GetMemberTP(x); 
                            local TPColor = '|c77777777|';
                            local TPValue = '';

                            if (TP >= 1000) then
                                TPColor = '|cff00FF00|';
                            else
                                TPColor = '|cffc0c0c0|';
                            end

                            TPValue = tostring(TP);
                            while TPValue:len() < 4 do 
                                TPValue = " "..TPValue; 
                            end

                ---- Final Window Output for Alliance
                            if (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId1()) then 
                                leadstar = '|cffffff00|*|r';
                            elseif (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId2()) then 
                                leadstar = '|cffffff00|*|r';
                            elseif (party:GetMemberServerId(x) == party:GetAlliancePartyLeaderServerId3()) then 
                                leadstar = '|cffffff00|*|r';
                            else
                                leadstar = ' |r';
                            end
 
                            ascii.font_f[x].visible = true;
                            if (z == 1) then
                                ascii.font_a.visible = true;
                            else
                                ascii.font_b.visible = true;
                            end
                            if (HPValue <= 33 and elsewhere == false) then
                                if (tick >= 15 and party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and party:GetMemberMainJob(x) ~= 0) then 
                                    ascii.font_f[x].background.color = 0x5fff0000;
                                else
                                    ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                                end
                            else
                                ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                            end 
                                                            
                            if (elsewhere == false and ((party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and 
                                    party:GetMemberMainJob(x) ~= 0) or (party:GetMemberMainJob(x) == 0 and party:GetMemberHPPercent(x) > 0))) then  -- Try to put in Zone Name for far away friends
                                Output = (TarStar..NameColor..Name..leadstar..' '..TPValue..'|'..hResult..'||cff00ff00|'..HealthStr);
                                ascii.font_f[x].text = tostring(Output);
                            else 
                                if (ZoneName == nil) then
                                    ZoneName = 'BROKEN PLAYER ZONE';
                                end
                                while ZoneName:len() < 21 do
                                    ZoneName = " "..ZoneName;
                                end
                                ZoneName = string.sub(ZoneName, 1, 21);
                                Output = (' '..NameColor..Name..leadstar..'| |cc0c0c0c0| '..tostring(ZoneName)..'|r  ');
                                ascii.font_f[x].text = tostring(Output);
                            end	    

                            if (x == 6 or x == 12) then      
                                if (x == 6) then
                                    OutThr = 'Alliance 1';
                                else
                                    OutThr = 'Alliance 2';
                                end
                                while OutThr:len() < 39 do
                                    OutThr = " "..OutThr;
                                end
                                OutThr = string.sub(OutThr, 1, 39);
                                OutThr = " "..OutThr.." ";
                                ascii.font_h[x].visible = false;
                                if (z == 1) then
                                    ascii.font_a.visible = true;
                                    ascii.font_a.text = OutThr;
                                else
                                    ascii.font_b.visible = true;
                                    ascii.font_b.text = OutThr;
                                end
                            else
                                OutThr = '                                         ';
                                if (z == 1) then
                                    ascii.font_a.visible = true; 
                                else  -- ^^^ VVV ^^^ VVV --Other window is checked for visible in count section above. No need to alternate blanking.
                                    ascii.font_b.visible = true; 
                                end
                                ascii.font_h[x].visible = true;
                                ascii.font_h[x].text = tostring(OutThr);
                            end
                        end
                    end
                end
            end
        else
            ascii.font_a.visible = false;
            ascii.font_b.visible = false;
            for x = 6, 17 do
                ascii.font_f[x].visible = false;
                ascii.font_h[x].visible = false;
            end
        end 
    else
        ascii.font_a.visible = false;
        ascii.font_b.visible = false;
        ascii.font_e.visible = false;
        for x = 0, 17 do 
            ascii.font_f[x].visible = false;
            ascii.font_h[x].visible = false;
        end
        for x = 0, 5 do  -- No font_g in alliance, so don't waste memory using higher than 5.
            ascii.font_g[x].visible = false;
        end
    end -- End Alliance Windows
-------- END Party Window

-------- Monster Window
    if (ascii.settings.options.monster == true) then
        local TarID = 0;
        local tarmob = nil;  -- Entity
        local submob = nil;  -- Entity
        local spawn = 0;
        local tarserverid = 0;
        local MobHPP = 0;
        local MobHPCheck = 0;
        local centerjust = true;
        local OutFou = '';
        local OutFiv = '';
        local OutSix = '';
        local OutSev = '';
        local OutEig = '';
        local mobResult = '|cffff0000|_____________________________________________'
        local monsterfontsize = ascii.settings.monsterfont.font_height;
   
        if(target ~= nil) then
            if (target:GetIsSubTargetActive() > 0) then
                TarID = target:GetTargetIndex(1); ---- If the target has a sub ID, use that and refence that instead.
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
            if (spawn == 16 and tarserverid > 0 and LastMob ~= tarserverid and GotPacket == false and ascii.settings.options.moninfo == true) then 
                for i = 1, arraySize do	----- START FOR LOOP      --^^^ No sense wasting clock cycles if we have all the info.
                    if (mb_data[i] ~= nil) then  -- Vicrelant's ibar addon incorporated here.
                        if (tonumber(mb_data[i].id) == tarserverid) then
				---- Start the checker
                            if (CheckLock == false) then
                                MobDefEva = '(   ????   )';
                                MobType = '     ???     '; -- We want these blank until we actually find the packet on the same mob, which will stop the loop.
                                MobLvlStr = '???'; --            the packet on the same mob, which will stop the loop.
                                MobLvl = 0;
                                SendCheckPacket(TarID);
                                CheckLock = true;
                            end
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

                            MobWeak = 'ID: '..TarID..'  Aggro: |cffff0000|'..MobAggro..' WEAK: '..mb_data[i].weak;
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
                            MobWeak = string.gsub(MobWeak,'Impact','|cffa0a0a0|IMP');
                            MobWeak = string.gsub(MobWeak,'To','|cffa0a0a0|H2H'); -- The Phrase 'Hand-To-Hand' screws this all up! Haha!
                            MobWeak = string.gsub(MobWeak,'Hand','');             -- Gotta sub out three times!
                            MobWeak = string.gsub(MobWeak,'-','');               --

                            LastMob = tarserverid;
                            break;
                        end -- END md_data/tarserverid compare
                    end  -- END mb_data nil if 
                end                         ----- END FOR LOOP
            else
                GotPacket = false;
            end -- END Scanning Monsters.

            if (MobLvl == 0 or MobLvl == 666) then
                MobLvlStr = '???'
            else
                MobLvlStr = tostring(MobLvl);
            end
            while MobLvlStr:len() < 3 do
                MobLvlStr = " "..MobLvlStr;
            end
          
            OutEig = '  |cffffffff|'..' LVL: '..tostring(MobLvlStr)..'   '..MobJob..'|cffffffff|  | '..MobType..' '..MobDefEva; --..'| ID: '..TarID;
            while MobName:len() < 47 do 
                if (centerjust == true) then
                    MobName = " "..MobName; 
                    centerjust = false;
                else
                    MobName = MobName.." ";
                    centerjust = true;
                end
            end
            MobHPCheck = math.floor(MobHPP / (100/46)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
           --[[MobStr = tostring(MobHPP);  ------ Let's not put Monster HP% in for now, defeats purpose of the bar.
            while MobStr:len() < 3 do 
                MobStr = " "..MobStr; 
            end  ]]
            if (spawn == 16) then
                mobResult = string.gsub(mobResult,'_','#',MobHPCheck);
                mobResult = string.gsub(mobResult,'_',' ');
                mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
            elseif (spawn == 1 and ascii.settings.options.tarplay == true) then
                mobResult = '|cff00ff44|_____________________________________________'
                mobResult = string.gsub(mobResult,'_','#',MobHPCheck);
                mobResult = string.gsub(mobResult,'_',' ');
                mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
                ascii.font_o.visible = false;
                ascii.font_l.visible = false;
            else
                ascii.font_m.visible = false;
                ascii.font_n.visible = false;
                ascii.font_o.visible = false;
                ascii.font_l.visible = false;
            end
        else
            MobDefEva = '(   ????   )';
            MobType = '     ???     ';
            MobLvlStr = '???';
            GotPacket = false;
        end -- END If Target Isn't Nil.
        
        if (spawn == 16 or (spawn == 1 and ascii.settings.options.tarplay == true)) then     -- Differentiate Monsters from NPC's/Players/Goblin Footprints/etc.
            ------ SNEAK ATTACK FUNCTION!!!
            if ((player:GetMainJob() == 6 or player:GetSubJob() == 6) and spawn == 16) then
                local pX = AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionX(party:GetMemberTargetIndex(0)); 
                local pY = AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionY(party:GetMemberTargetIndex(0)); 
                local mX = AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionX(TarID);
                local mY = AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionY(TarID);
                local MobHead = AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionYaw(TarID) * (180 / math.pi);
                local PlayHead = playerent.Heading * (180 / math.pi);  -- ^^^ Don't use Heading for mobs since it doesn't change if they turn while moving. Odd.
                local EndAng = PlayHead + 45;
                local StartAng = PlayHead - 45;
                local Sneak = 0; 
                local Dist = math.sqrt(tarmob.Distance);  
                local relX = (mX - pX); -- puts pX at the center of unit circle? (px-mx) seems to give relative angle of me in relation to it
                local relY = (mY - pY); -- REMEMBER THE GAME LOOKS AT INCREASING Y TO GO DOWN. LIKE MONITOR COORDS START IN UPPER LEFT CORNER.
                local Bearing = math.atan2(relY,relX) * (-180 / math.pi); -- Arctangent? We back in high school? Brings back bad memories. Haha!

                if (MobHead > 360) then
                    MobHead = MobHead - 360;
                elseif (MobHead < 0) then
                    MobHead = MobHead + 360;
                end

                if (PlayHead > 360) then
                    PlayHead = PlayHead - 360; -- Angle I'm facing. Game makes angles go clockwise. They never had a maffs class...
                elseif (PlayHead < 0) then
                    PlayHead = PlayHead + 360;
                end

                Sneak = math.abs(MobHead - PlayHead); -- Is the mob facing the same direction as us (sneaking up behind it)?
            
                if (Sneak > 180) then
                    Sneak = 360 - Sneak;
                end

                if (StartAng > 360) then
                    StartAng = StartAng - 360;
                elseif (StartAng < 0) then
                    StartAng = StartAng + 360;
                end

                if (EndAng > 360) then
                    EndAng = EndAng - 360;
                elseif (EndAng < 0) then
                    EndAng = EndAng + 360;
                end
			
                if (Bearing > 360) then
                    Bearing = Bearing - 360;
                elseif (Bearing < 0) then
                    Bearing = Bearing + 360;
                end

                if(StartAng < EndAng) then    ---- DO WE WANT THE END RESULT AS BACKGROUND COLOR CHANGE?
                    if (Sneak <= 45 and Dist <= 3 and StartAng <= Bearing and Bearing <= EndAng) then
                        if (ascii.settings.options.zilda == true and ascii.settings.options.fairy == true) then
                            SneakAttack = true;
                        else
                            ascii.font_m.background.color = 0xFF000044;
                        end
                    else
                        if (ascii.settings.options.zilda == true and ascii.settings.options.fairy == true) then
                            SneakAttack = false;
                        else
                            ascii.font_m.background.color = ascii.settings.monsterfont.background.color;
                        end
                    end
                else
                    if (Sneak <= 45 and Dist <= 3 and (StartAng <= Bearing or Bearing <= EndAng)) then
                        if (ascii.settings.options.zilda == true and ascii.settings.options.fairy == true) then
                            SneakAttack = true;
                        else
                            ascii.font_m.background.color = 0xFF000044;
                        end
                    else
                        if (ascii.settings.options.zilda == true and ascii.settings.options.fairy == true) then
                            SneakAttack = false;
                        else
                            ascii.font_m.background.color = ascii.settings.monsterfont.background.color;
                        end
                    end
                end
            end
	-------------- END SNEAK ATTACK FUNCTION!
            OutFou = mobResult;
            OutFiv = MobName;
            OutSix = MobWeak;
            ascii.font_m.visible = true;
            ascii.font_m.text = tostring(OutFou);
            ascii.font_n.position_x = ascii.font_m.position_x;	
            ascii.font_l.position_x = ascii.font_m.position_x;
            if (ascii.settings.options.monabov ~= true) then  
                ascii.font_n.position_y = ascii.font_m.position_y - (monsterfontsize * 2) - offset;
            else
                ascii.font_n.position_y = ascii.font_m.position_y + (monsterfontsize * 2) + offset;
            end
            ascii.font_n.visible = true;
            ascii.font_n.text = tostring(OutFiv);
            if (ascii.settings.options.moninfo == true and spawn == 16) then
                ascii.font_o.position_x = ascii.font_m.position_x;
                if (ascii.settings.options.monabov ~= true) then
                    ascii.font_l.position_y = ascii.font_n.position_y - (monsterfontsize * 2) - offset;
                    ascii.font_o.position_y = ascii.font_l.position_y - (monsterfontsize * 2) - offset;
                else	
                    ascii.font_l.position_y = ascii.font_n.position_y + (monsterfontsize * 2) + offset;
                    ascii.font_o.position_y = ascii.font_l.position_y + (monsterfontsize * 2) + offset;
                end
                ascii.font_l.visible = true;
                ascii.font_o.visible = true;
                ascii.font_l.text = tostring(OutEig);
                ascii.font_o.text = tostring(OutSix);
            else
                ascii.font_l.visible = false;                 
                ascii.font_o.visible = false;
            end
        else
            ascii.font_m.visible = false;    -- This all needs to be here or it will try to make a window for non-monsters
            ascii.font_n.visible = false;    --
            ascii.font_o.visible = false;    --
            ascii.font_l.visible = false;    --
            SneakAttack = false; 
        end

        if (tarmob == nil) then 		-- Have nothing targetted
            ascii.font_p.visible = false;
        else
            if(tarmob ~= nil and target:GetIsSubTargetActive() == 0 ) then 	
					-- Have a Non-Monster Target and no Sub-Target
                if (spawn ~= 16) then -- Main Target is not Monster
                    if (spawn == 1 and ascii.settings.options.tarplay == true) then
                        ascii.font_p.visible = false;
                    else
                        ascii.font_p.visible = true;
                    end
                    OutSev = tarmob.Name;
                else 				-- Main Target is Monster and no Sub-Target
                    ascii.font_p.visible = false;
                    OutSev = tarmob.Name; -- Shouldn't be seen, but filling values anyway to not cause any possible issues
                end
            else 				-- Have a Target and Sub-Target
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
        ascii.font_p.background.visible = false;
        ascii.font_p.text = OutSev; -- Target/Sub-Target Name
    else
        ascii.font_l.visible = false;
        ascii.font_m.visible = false;
        ascii.font_n.visible = false;
        ascii.font_o.visible = false;
        ascii.font_p.visible = false;
    end
-------- END Mob Info Window

-------- Player Window
    if(ascii.settings.options.playwin == true) then
        local sResult = '{__________________________________________________|cffffffff|}';
        local playernumber = 0;

        if (player == nil or playerent == nil) then 
            return; 
        end
		
        local HPValue = playerent.HPPercent;
        local HPCheck = math.floor(HPValue / (100 / 50));
        local HPColor = '';
        local selffontsize = ascii.settings.selffont.font_height;
        local SelfTP = party:GetMemberTP(0); -- playernumber
        local SelfHP = party:GetMemberHP(0); -- playernumber
        local SelfHPMax = player:GetHPMax();
        local SelfMP = party:GetMemberMP(0); -- playernumber
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
            SelfTPStr = '|cff70ff70|'..SelfTPStr..'|r';
        else
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
            local HeartMax = 0;
            local SwordNum = 1; -- Don't like putting 0 since there is no Sword-0. Just in case.

            if(ascii.settings.options.grow == false) then
                HeartMax = 12;
            else
                HeartMax , _ = 3 + math.modf(SelfHPMax / 111); -- Always start with 3 HeartContainers, get another every 111 Max HP afterwards. 12 at 1k.
                if (HeartMax > 12) then 
                    HeartMax = 12;  -- Always keep the Maximum at 12.
                end
            end

            HeartFull , HeartFrac = math.modf(HPValue / (100 / HeartMax));  -- DENOMINATOR IS HOW MANY HEART CONTAINERS
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
                if(HeartFullTot == 0 and HPValue > 0) then -- To not show some health as zero Hearts when near Death.
                    HeartNum[value] = 2 -- 1/4 Heart
                else
                    HeartNum[value] = 1 -- EMPTY HEART for less than 10 percent when not near Death.
                end
            end
	
            value = value + 1; -- Increase value from the fractional Heart

            while value <= HeartMax do
                HeartNum[value] = 1; -- EMPTY HEART
                value = value + 1;
            end
				-- DRAW HEARTS
            for x = 1, 12 do
                for y = 1, 5 do
                    HeartContainer[x][y].visible = false; -- Need to constantly blank every heart in the array, if they are needed or not.
                end
            end

            for x = 1, HeartMax do  -- Now we can draw however many Heart Containers we want.
                HeartContainer[x][HeartNum[x]].position_x = ascii.font_q.position_x + 85 + (x * 48);
                HeartContainer[x][HeartNum[x]].position_y = ascii.font_q.position_y;
                HeartContainer[x][HeartNum[x]].locked = true;
                HeartContainer[x][HeartNum[x]].visible = true;
            end

            for x = 1, 3 do -- Always blank the Swords, just like the Hearts.
                Sword[x].visible = false;
            end

            if (SelfTP >= 1000) then
                if (SelfTP >= 3000) then
                    SwordNum = 3;
                elseif (SelfTP >= 2000) then
                    SwordNum = 2;
                elseif (SelfTP >= 1000) then
                    SwordNum = 1;
                end

                Sword[SwordNum].position_x = ascii.font_q.position_x + 85 + (8 * 48); -- Put it under the 8th Heart Container?
                Sword[SwordNum].position_y = ascii.font_q.position_y + 48;
                if (ascii.settings.selffont.font_height == 14) then
                    Sword[SwordNum].position_x = Sword[SwordNum].position_x + 48; -- Then move it depending on text font size to line it up to the edge of the window.
                elseif (ascii.settings.selffont.font_height == 10) then
                    Sword[SwordNum].position_x = Sword[SwordNum].position_x - 96;
                end                        
                Sword[SwordNum].locked = true;
                Sword[SwordNum].visible = true;
            end

            if (HPValue <= 0) then
                sResult = ' |cffff0000|DEAD ';
            else
                sResult = ' LIFE ';
            end   

            ascii.font_q.font_height  = 30; --[[2 * selffontsize;]]    -- TWO SETS OF THESE LINE PLACEMENTS, ONE FOR HEART ONE FOR REGULAR. THIS IS HEART.
            ascii.font_s.position_x = ascii.font_r.position_x;
            ascii.font_s.position_y = ascii.font_r.position_y + (selffontsize * 2) + offset;
            ascii.font_t.position_x = ascii.font_s.position_x;
            ascii.font_t.position_y = ascii.font_s.position_y + (selffontsize * 2) + offset;
            local push = 0;
            if (ascii.font_r.font_height == 10) then -- push is for moving the hp/mana number and pet name line to proper spacing under large LIFE word.
                push = 4;
            elseif (ascii.font_r.font_height == 14) then
                push = -3;
            end
            ascii.font_r.position_x = ascii.font_q.position_x;
            ascii.font_r.position_y = push + ascii.font_q.position_y + (selffontsize * 2) + offset + 28;
            ascii.font_u.position_x = ascii.font_q.position_x;
            ascii.font_u.position_y = push + ascii.font_q.position_y + (selffontsize * 2) + offset + 28;
	                                                                                                               --VV VV VV Remove TP for now for the sword, and add 4 spaces.
            SelfStr = SelfStr..SelfHPStr..' / '..SelfHPMStr..'   |cffff40b0|'..SelfMPStr..' / '..SelfMPMStr..'     '..--[[SelfTPStr..' ']]'     '; 
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
                sResult = string.gsub(sResult,'_',HPColor .. '#',HPCheck);
                sResult = string.gsub(sResult,'_',' ');
            end

            ascii.font_q.font_height = ascii.settings.selffont.font_height; -- TWO SETS OF THESE LINE PLACEMENTS, ONE FOR HEART ONE FOR REGULAR. THIS IS REGULAR.
            ascii.font_s.position_x = ascii.font_r.position_x;
            ascii.font_s.position_y = ascii.font_r.position_y + (selffontsize * 2) + offset;
            ascii.font_t.position_x = ascii.font_s.position_x;
            ascii.font_t.position_y = ascii.font_s.position_y + (selffontsize * 2) + offset;
            ascii.font_r.position_x = ascii.font_q.position_x;
            ascii.font_r.position_y = ascii.font_q.position_y + (selffontsize * 2) + offset;
            ascii.font_u.position_x = ascii.font_q.position_x;
            ascii.font_u.position_y = ascii.font_q.position_y + (selffontsize * 2) + offset;
            ascii.font_w.position_x = ascii.font_t.position_x;
            ascii.font_w.position_y = ascii.font_t.position_y + (selffontsize * 2) + offset;            
        end ------------- END 'Q' Stuff

        if (HPValue <= 33 and tick >= 15) then
            ascii.font_q.background.color = 0x5FFF0000;
            ascii.font_u.background.color = 0x5FFF0000;
        else
            ascii.font_q.background.color = ascii.settings.selffont.background.color;
            ascii.font_u.background.color = ascii.settings.selffont.background.color;
        end
   
        ascii.font_u.visible = true; 
        ascii.font_u.text = SelfStr; -- TEST NUMBERS HERE
        ascii.font_q.visible = true;
        ascii.font_q.text = string.format(sResult);

        local pet = GetEntity(playerent.PetTargetIndex);

        if (playerent.PetTargetIndex > 0 and pet ~= nil) then ---- PLAYER HAS PET
            ascii.font_r.visible = true;
            ascii.font_s.visible = true;
            ascii.font_t.visible = true;
            local petname = pet.Name;
            local pettp = player:GetPetTP();
            local petmp = player:GetPetMPPercent();
            local pResult = '{|cff00ffff|__________________________________________________|cffffffff|}'; 
            local PHValue = pet.HPPercent;
            local PHCheck = math.floor(PHValue / (100 / 50));
            local tResult  = '|cffffffff|{____________________|cffffffff|}';
            local pmResult = '|cffffffff|{____________________|cffffffff|}';
            local PTCheck = math.floor(pettp / (3000 / 20));
            local PTColor = '|cff7f7f7f|';
            local PMCheck = math.floor(petmp / (100 / 20));
            local PMColor = '|cfff48dff|';
            local PetTarget = nil;

            while (petname:len() < 15) do
                petname = petname.." ";
            end

            ascii.font_r.background.visible = false;
            ascii.font_r.text = string.format(petname);
            pResult = string.gsub(pResult,'_','#',PHCheck);
            pResult = string.gsub(pResult,'_',' ');
            ascii.font_s.text = string.format(pResult);

            if (pettp >= 1000) then
                PTColor = '|cff40a040|';
            end

            if (petmp >= 100) then
                PMColor = '|cffff00cc|';
            end
            
            tResult = string.gsub(tResult,'_',PTColor..'#',PTCheck);
            tResult = string.gsub(tResult,'_',' ');
            pmResult = string.gsub(pmResult,'_',PMColor..'#',PMCheck);
            pmResult = string.gsub(pmResult,'_',' ');
            ascii.font_t.text = string.format(tResult..'        '..pmResult);

        -- Pet's target function
            if (PetTargetsID > 0 and PetTargetsID ~= target:GetServerId(0) and PetTargetsID ~= target:GetServerId(1)) then
                PetTarget = GetEntityByServerId(PetTargetsID); -- PetsTargetsID is a ServerID
                if (PetTarget ~= nil) then
                    local PetTarHPPer = 0;
                    local PetTarName = '';
                    local PetTarResult = '|cffffffff|{|cffff7700|______________________________|cffffffff|}'; 
                    local PTTCheck = 0;
                    PetTarHPPer = PetTarget.HPPercent;
                    PetTarName = PetTarget.Name;
                    if (PetTarName ~= nil) then
                        while PetTarName:len() < 19 do 
                            PetTarName = " "..PetTarName; 
                        end
                        PetTarName = string.sub(PetTarName, 1, 19);
                    end
                    PTTCheck = math.floor(PetTarHPPer / (100 / 30));
                    PetTarResult = string.gsub(PetTarResult,'_','#',PTTCheck);
                    PetTarResult = string.gsub(PetTarResult,'_',' ');
                    ascii.font_w.visible = true;
                    ascii.font_w.text = tostring(PetTarName..' '..PetTarResult);
                else
                    ascii.font_w.visible = false;
                end
            else
                ascii.font_w.visible = false;
            end
        else
            ascii.font_r.visible = false;
            ascii.font_s.visible = false;
            ascii.font_t.visible = false;
            ascii.font_w.visible = false;
        end
    else
        ascii.font_q.visible = false;
        ascii.font_r.visible = false;
        ascii.font_s.visible = false;
        ascii.font_t.visible = false;
        ascii.font_u.visible = false;
        ascii.font_w.visible = false;
        for x = 1, 12 do
            for y = 1, 5 do
                HeartContainer[x][y].visible = false;
            end	
        end
        for x = 1, 3 do
            Sword[x].visible = false;
        end
    end
-------- END Player Window
end);  ------------ END MAIN FUNCTION

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
        { '/ASCII-Joy back     ', 'Toggles Window Backgrounds. Rotates through (off / light / dark).' },
        { '/ASCII-Joy font     ', 'Toggles Window fonts between Consolas and Courier New.' },
        { '/ASCII-Joy size     ', 'Toggles through 3 different size fonts (10, 12, 14).' },
        { '/ASCII-Joy offset # ', 'Pixel-shifts the line-spacing (+/-)# pixels (Use if spaces between lines look funny)' },
        { '/ASCII-Joy cast     ', 'Toggles the Cast Bar.' },
        { '/ASCII-Joy exp      ', 'Toggles the Experience Bar.'},
        { '/ASCII-Joy party    ', 'Toggles the Party Window on and off.' },
        { '/ASCII-Joy order    ', 'Toggles Party Window list sorting (Ascending/Descending).' },
        { '/ASCII-Joy alliance ', 'Toggles Alliance Windows (WILL COST SOME FPS, FOR SURE).'},
        { '/ASCII-Joy solo     ', 'Toggles seeing yourself in Party Window while solo (Zone Name remains).' },
        { '/ASCII-Joy player   ', 'Toggles Player Window of your own HP Bar, TP, Mana, Pet info (if you have one).' },
        { '/ASCII-Joy zilda    ', 'Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!' },
        { '/ASCII-Joy grow     ', 'Toggles if you always see 12 Heart Containers, or get more as you level up (up to 12 Max).' },
        { '/ASCII-Joy fairy    ', 'Toggles whether the Fairy will grace you with her presence, depending on your point of view.' },
        { '/ASCII-Joy monster ', 'Toggles the Monster Health/Sub-Target Window.' },
        { '/ASCII-Joy mon-pos ', 'Toggles Monster info Above/Below their Health Bar.' },
        { '/ASCII-Joy mon-info', 'Toggles Aggro/Weak info. Not live info, pulled from file.' },
        { '/ASCII-Joy tarplay ', 'Toggles ability to see other Players Health in the Monster Health Window.' },
        { '',''},
        { '','To move the Cast Bar, Shift-LeftClick-Drag the bar around while casting (sorry, only way to see it).'},
        { '','To move the Experience Bar, Shift-LeftClick-Drag the Bar itself.' },
        { '','To move the Party Window, Shift-LeftClick-Drag the line with Zone Name.' },
        { '','To move the Monster Window, Shift-LeftClick-Drag the line with the Monster Health.' },
        { '','To move the Target/Sub-Target Name, Shift-LeftClick-Drag the italicized Name.' },
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
            ascii.settings.castfont.font_family = 'Courier New';
            ascii.settings.monsterfont.font_family = 'Courier New';
            ascii.settings.selffont.font_family = 'Courier New';
            ascii.settings.partyfont.font_family = 'Courier New';
            ascii.settings.all2font.font_family = 'Courier New';
            ascii.settings.all1font.font_family = 'Courier New';            
            print(chat.header(addon.name):append(chat.message('Your FONTS will be Old School Courier New.')));
        elseif(ascii.settings.monsterfont.font_family == 'Courier New') then
            ascii.settings.castfont.font_family = 'Consolas';
            ascii.settings.monsterfont.font_family = 'Consolas';
            ascii.settings.selffont.font_family = 'Consolas';
            ascii.settings.partyfont.font_family = 'Consolas';
            ascii.settings.all2font.font_family = 'Consolas';
            ascii.settings.all1font.font_family = 'Consolas';
            print(chat.header(addon.name):append(chat.message('Your FONTS will be New School Consolas.')));
        end
        save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
        update_settings(); -- Updating Settings actually applies them too.
        return;
    end

    if (#args == 2 and args[2]:any('cast')) then
        ascii.settings.options.cast = not ascii.settings.options.cast;
        if(ascii.settings.options.cast == true) then
            print(chat.header(addon.name):append(chat.message('Cast Bar ENABLED.')));
        elseif(ascii.settings.options.cast == false) then
            print(chat.header(addon.name):append(chat.message('Cast Bar DISABLED.')));
        end
        save_everything();
        return;
    end

    if (#args == 2 and args[2]:any('exp')) then
        ascii.settings.options.exp = not ascii.settings.options.exp;
        if(ascii.settings.options.exp == true) then
            print(chat.header(addon.name):append(chat.message('Experience Bar ENABLED.')));
        elseif(ascii.settings.options.exp == false) then
            print(chat.header(addon.name):append(chat.message('Experience Bar DISABLED.')));
            ascii.font_d.visible = false;
        end
        save_everything();
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
            ascii.settings.castfont.background.color = 0x5F000000;
            ascii.settings.monsterfont.background.color = 0x5F000000;
            ascii.settings.selffont.background.color = 0x5F000000;
            ascii.settings.partyfont.background.color = 0x5F000000;
            ascii.settings.all2font.background.color = 0x5F000000;
            ascii.settings.all1font.background.color = 0x5F000000;
            print(chat.header(addon.name):append(chat.message('Window Backgrounds will be LIGHT (Translucent).')));
        elseif(ascii.settings.monsterfont.background.color == 0x5F000000) then
            ascii.settings.castfont.background.color = 0xFF000000;
            ascii.settings.monsterfont.background.color = 0xFF000000;
            ascii.settings.selffont.background.color = 0xFF000000;
            ascii.settings.partyfont.background.color = 0xFF000000;
            ascii.settings.all2font.background.color = 0xFF000000;
            ascii.settings.all1font.background.color = 0xFF000000;
            print(chat.header(addon.name):append(chat.message('Window Backgrounds will be DARK (Opaque).')));
        elseif(ascii.settings.monsterfont.background.color == 0xFF000000) then
            ascii.settings.castfont.background.color = 0x00000000;
            ascii.settings.monsterfont.background.color = 0x00000000;
            ascii.settings.selffont.background.color = 0x00000000;
            ascii.settings.partyfont.background.color = 0x00000000;
            ascii.settings.all2font.background.color = 0x00000000;
            ascii.settings.all1font.background.color = 0x00000000;
            print(chat.header(addon.name):append(chat.message('Window Backgrounds will be OFF (Invisible).')));		
        end
        save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
        update_settings(); -- Updating Settings actually applies them too.
        return;
    end

    if (#args == 2 and args[2]:any('size')) then
        if(ascii.settings.monsterfont.font_height == 10) then
            ascii.settings.castfont.font_height = 12;
            ascii.settings.monsterfont.font_height = 12;
            ascii.settings.selffont.font_height = 12;
            ascii.settings.partyfont.font_height = 12;
            print(chat.header(addon.name):append(chat.message('Font size will be Medium (12).')));
        elseif(ascii.settings.monsterfont.font_height == 12) then
            ascii.settings.castfont.font_height = 14;
            ascii.settings.monsterfont.font_height = 14;
            ascii.settings.selffont.font_height = 14;
            ascii.settings.partyfont.font_height = 14;
            print(chat.header(addon.name):append(chat.message('Font size will be Large (14).')));
        elseif(ascii.settings.monsterfont.font_height == 14) then
            ascii.settings.castfont.font_height = 10;
            ascii.settings.monsterfont.font_height = 10;
            ascii.settings.selffont.font_height = 10;
            ascii.settings.partyfont.font_height = 10;
            print(chat.header(addon.name):append(chat.message('Font size will be Small (10).')));		
        end
        save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
        update_settings(); -- Updating Settings actually applies them too.
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

    if (#args == 2 and args[2]:any('order')) then
        if(ascii.settings.options.party == true) then
            ascii.settings.options.order = not ascii.settings.options.order;
            if(ascii.settings.options.order == true) then
                print(chat.header(addon.name):append(chat.message('You will see the Party Window in ASCENDING Order (You at the top).')));
            elseif(ascii.settings.options.order == false) then
                print(chat.header(addon.name):append(chat.message('You will see the Party Window in DESCENDING Order (You at the bottom).')));
            end
            save_everything();
            return;
        else
            print(chat.header(addon.name):append(chat.message('You need the Party Window enabled to toggle this.')));
            return;
        end
    end

    if (#args == 2 and args[2]:any('alliance')) then
        if(ascii.settings.options.party == true) then
            ascii.settings.options.alliance = not ascii.settings.options.alliance;
            if(ascii.settings.options.alliance == false) then
                print(chat.header(addon.name):append(chat.message('You will NOT see Alliance Windows.')));
            elseif(ascii.settings.options.alliance == true) then
                print(chat.header(addon.name):append(chat.message('You WILL see Alliance Windows.')));
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

    if (#args == 2 and args[2]:any('tarplay')) then
        if(ascii.settings.options.monster == true) then
            ascii.settings.options.tarplay = not ascii.settings.options.tarplay;
            if(ascii.settings.options.tarplay == true) then
                print(chat.header(addon.name):append(chat.message('You will see Players in the Monster Health Window.')));
            elseif(ascii.settings.options.tarplay == false) then
                print(chat.header(addon.name):append(chat.message('You will NOT see Players in the Monster Health Window.')));
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

    if (#args == 3 and args[2]:any('offset')) then
        local change = args[3]:number_or(0);
        if(change > 10 or change < -10) then
            print(chat.header(addon.name):append(chat.message('Valid Offset range is -10 to 10.')));
            return;
        end
        ascii.settings.options.offset = change;
        print(chat.header(addon.name):append(chat.message('Your Line Spacing Offset is now %d'):fmt(change)));
        save_everything(); -- We will lose window positiions if they were moved from updating, so we will save twice.
        update_settings();
        return;
    end

    if (#args == 2 and args[2]:any('zilda')) then
        if(ascii.settings.options.playwin == true) then
            ascii.settings.options.zilda = not ascii.settings.options.zilda;
            if(ascii.settings.options.zilda == true) then
                print(chat.header(addon.name):append(chat.message('You WILL see LIFE HEARTS from "The Myth of Zilda(tm)"!')));
            elseif(ascii.settings.options.zilda == false) then -- Get rid of everything if they toggle it off.
                for x = 1, 12 do  
                    for y = 1, 5 do
                        HeartContainer[x][y].visible = false; -- Need to constantly blank these if we want them off.
                    end
                end
                for x = 1, 3 do
                    Sword[x].visible = false; -- Blank the Swords too.
                end
                ascii.font_v.visible = false;
                for x = 1, 2 do
                    Fairy[x].visible = false;
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

    if (#args == 2 and args[2]:any('grow')) then
        if(ascii.settings.options.playwin == true) then
            if(ascii.settings.options.zilda == true) then
                ascii.settings.options.grow = not ascii.settings.options.grow;
                if(ascii.settings.options.grow == false) then
                    print(chat.header(addon.name):append(chat.message('You will always see the Full 12 Heart Containers')));
                elseif(ascii.settings.options.grow == true) then
                    print(chat.header(addon.name):append(chat.message('You will earn more Heart Containers as you level up (12 Maximum).')));
                end
                save_everything();
                return;
            else
                print(chat.header(addon.name):append(chat.message('You need to have Icons from "The Myth of Zilda(tm)" enabled to toggle this.')));
                return;
            end
        else
            print(chat.header(addon.name):append(chat.message('You need the Player Window enabled to toggle this.')));
            return;
        end
    end

    if (#args == 2 and args[2]:any('fairy')) then
        if(ascii.settings.options.playwin == true) then
            if(ascii.settings.options.zilda == true) then
                ascii.settings.options.fairy = not ascii.settings.options.fairy;
                if(ascii.settings.options.fairy == false) then
                    print(chat.header(addon.name):append(chat.message('The Fairy will leave you alone and has flown home. Maybe.')));
                    ascii.font_v.visible = false;
                    for x = 1, 2 do
                        Fairy[x].visible = false;
                    end
                elseif(ascii.settings.options.fairy == true) then
                    print(chat.header(addon.name):append(chat.message('The Fairy will now lie in wait, stalking you...')));
                end
                save_everything();
                return;
            else
                print(chat.header(addon.name):append(chat.message('You need to have Icons from "The Myth of Zilda(tm)" enabled to toggle this.')));
                return;
            end
        else
            print(chat.header(addon.name):append(chat.message('You need the Player Window enabled to toggle this.')));
            return;
        end
    end    
    -- Unhandled: Print help information..
    print_help(true);
end);

ashita.events.register('packet_in', 'packet_in_cb', function (e) -- Checker and petinfo addon by Atom0s. Used with permission.
    -- Packet: Zone Enter / Zone Leave
    if (e.id == 0x000A or e.id == 0x000B) then
        return;
    end

    -- Packet: Message Basic
    if (e.id == 0x0029) then
        local p1    = struct.unpack('l', e.data, 0x0C + 0x01); -- Param 1 (Level)
        local p2    = struct.unpack('L', e.data, 0x10 + 0x01); -- Param 2 (Check Type)
        local m     = struct.unpack('H', e.data, 0x18 + 0x01); -- Message (Defense / Evasion)

        -- Obtain the target entity..
        local target = struct.unpack('H', e.data, 0x16 + 0x01);
        local entity = GetEntity(target);
        if (entity == nil) then
            return;
        end

        -- Ensure this is a /check message..
        if (m ~= 0xF9 and (not checker.conditions:haskey(m) or not checker.types:haskey(p2))) then
            return;
        end

        -- Obtain the string form of the conditions and type..
        local c = checker.conditions[m];
        local t = checker.types[p2];

        if (c == nil or t == nil) then -- Otherwise it will crash getting the length of 'c' three lines down. (Happened)
            return;
        end
        MobLvl = p1;
        MobDefEva = tostring(#c > 0 and c:enclose('(', ')') or c);
        MobType = tostring(t);
        GotPacket = true;
		
        -- Mark the packet as handled..
        e.blocked = true;
    end

        -- Packet: Action
    if (e.id == 0x0028) then
        local player = GetPlayerEntity();
        if (player == nil or player.PetTargetIndex == 0) then
            return;
        end
    
        local pet = GetEntity(player.PetTargetIndex);
        if (pet == nil) then
            return;
        end
    
        local data = struct.unpack('I', e.data_modified, 0x05 + 0x01);
        if (data ~= 0 and data == pet.ServerId) then
            PetTargetsID = ashita.bits.unpack_be(e.data_modified:totable(), 0x96, 0x20);
            return;
        end

        return;
    end
    
        -- Packet: Pet Sync
    if (e.id == 0x0068) then
        local player = GetPlayerEntity();
        if (player == nil) then
            PetTargetsID = nil;
            return;
        end
    
        local owner = struct.unpack('I', e.data_modified, 0x08 + 0x01);
        if (owner == player.ServerId) then
            PetTargetsID = struct.unpack('I', e.data_modified, 0x14 + 0x01);
        end

        return;
    end
end);