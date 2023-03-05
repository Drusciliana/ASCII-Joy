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
---------------------------------------------------------------------------------------------------------------------------------
-- Credit and Thanks to Atom0s. Solentus, Almavivaconte, Vicrelant, and Thorny for all of their help, inspiration, and guideance.
---------------------------------------------------------------------------------------------------------------------------------

addon.author  = 'Drusciliana';
addon.name    = 'ASCII-Joy';
addon.version = '1.5.0';
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
    aggro =     false;
    tarplay =   false,
    playwin =   true,
    exp =       true,
    zilda =     false,
    grow =      true,
    cast =      true,
    fairy =     true,
    claim =     false,
    debug =     false,
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
    fairyfont = T{
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
------------------------------------------------------------------- Globals! They all have a use out here.
local MobStr = ''; 
local MobName = ''; 
local MobAggro = '';
local MobJob = '   '; -- Placeholder -- 
local MobWeak = '             Monster Info unavailable'; 
local LastMob = 0;
local MobLvl = 0; 
local MobDefEva ='(   ????   )';
local MobType = '     ???     '; -- The Too weak, Even prey, etc...
local MobLvlStr = '???';
local UnableToSee = false;
local SneakAttack = false; -- Obvious.
local CheckLock = 0; -- Part of Latch on checker.
local CheckedTar = 0;
local GotPacket = true; -- Latch so we don't flood server with packets.
local PetTargetsID = 0; -- Obvious.
local TargetsTarget = 0; -- Target Index of Monster's target from Monster Window.
local Listening = 0; -- Latches the OSTime, so we don't flood server with packets.
local Assisting = 0; -- This only blocks the aggro packet from going out. /assist never actually sends a packet if target is monster or you have no target? Make it on a timer then.
local SubIndex = 0; -- For Changing targets. Comparison to ChangeTar in outgoing check.
local MainIndex = 0; -- Index of what the Monster Window is looking at. Not neccessarily TargetIndex(0) or TargetIndex(1).
local GotMob = 0; -- Monster ServerID from Monster Window. We will leave this for our checker function packet sender validation.
local GotMobAct = 0; -- See above. Also part of other things. Must leave this.
local GotMobActParam = 0; -- See above. See above.
local Interrupt = false; -- Obvious.
local MarkTickSee = 0; -- For Unable to See checks.
local PetDebuffs = 0; -- Obvious.
local OSTime = 0; -- Obvious.
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
local DatFound = false;
local SteadyW = false;
local DEBUG1 = nil; -- If there are anymore than 3 of each of these when using Ctrl-F to find, then it means it is in use somewhere.
local DEBUG2 = nil; --
local DEBUG3 = nil; --
local DEBUG4 = nil; --
local PartyHPLast = {};
local PartyTPLast = {};
local PartyMPLast = {};
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

local matchStrings = T{ -- Thanks, Thorny.
    '>> /ja',
    '...A command error',
    '>> /equipset',
    '>> /ma',
    '>> /ws'
};

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
    font_b = nil, -- Alliance 2
    font_c = nil, -- Cast Bar
    font_d = nil, -- Experience Bar
    font_e = nil, -- Party Zone Name
    font_f = T{ }, -- Party	Mana
    font_g = T{ }, -- Party HP
    font_h = T{ }, -- Party Space
    font_i = nil, -- Claim HP
    font_j = nil, -- Claim Name
    font_k = nil, -- Monster Target of Target Bar
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
    font_x = nil, -- Monster Action Bar
    font_y = nil, -- 
    font_z = T{ }, -- 
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
    if (ascii.font_i ~= nil) then
        ascii.font_i:apply(ascii.settings.partyfont);
    end
    if (ascii.font_j ~= nil) then
        ascii.font_j:apply(ascii.settings.partyfont);
    end
    if (ascii.font_k ~= nil) then
        ascii.font_k:apply(ascii.settings.monsterfont);
    end
    if (ascii.font_x ~= nil) then
        ascii.font_x:apply(ascii.settings.monsterfont);
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
    if (ascii.font_y ~= nil) then
        ascii.font_y:apply(ascii.settings.fairyfont);
    end
    ascii.font_z:each(function (v, _)
        if (v ~= nil) then
            v:apply(ascii.settings.fairyfont);
        end
    end);
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
    ascii.settings.fairyfont.position_x = ascii.font_y.position_x;
    ascii.settings.all1font.position_y = ascii.font_a.position_y
    ascii.settings.all2font.position_y = ascii.font_b.position_y    
    ascii.settings.castfont.position_y = ascii.font_c.position_y; 
    ascii.settings.selffont.position_y = ascii.font_q.position_y; 
    ascii.settings.partyfont.position_y = ascii.font_e.position_y;
    ascii.settings.monsterfont.position_y = ascii.font_m.position_y;
    ascii.settings.subtarfont.position_y = ascii.font_p.position_y;
    ascii.settings.expfont.position_y = ascii.font_d.position_y;   
    ascii.settings.fairyfont.position_y = ascii.font_y.position_y; 
    settings.save();
end

local function SendCheckPacket(mobIndex)
    local mobId = AshitaCore:GetMemoryManager():GetEntity():GetServerId(mobIndex);
    if (mobId ~= GotMob) then -- Hopefully won't send packets out looking for the wrong mob.
        return;
    end
    local checkPacket = struct.pack('LLHHBBBB', 0, mobId, mobIndex, 0x00, 0x00, 0x00, 0x00, 0x00):totable();
    AshitaCore:GetPacketManager():AddOutgoingPacket(0xDD, checkPacket);
end

local function SendAssistPacket(mobIndex)
    local mobId = AshitaCore:GetMemoryManager():GetEntity():GetServerId(mobIndex);
    local assistPacket = struct.pack('bbHIhhhhiii', 0x1A, 0x0E, 0, mobId, mobIndex, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00):totable();
    AshitaCore:GetPacketManager():AddOutgoingPacket(0x1A, assistPacket);
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

local function GetStPartyIndex() -- From Thorny. Thanks.
    local ptr = AshitaCore:GetPointerManager():Get('party');
    ptr = ashita.memory.read_uint32(ptr);
    ptr = ashita.memory.read_uint32(ptr);
    local isActive = (ashita.memory.read_uint32(ptr + 0x54) ~= 0);
    if isActive then
        return ashita.memory.read_uint8(ptr + 0x50);
    else
        return nil;
    end
end

local function GetFairyMessage (msgtype)
    local Message = 'Blah!';
    local count = 0;
    local _, fairy_data = pcall(require,'data.'..tostring('Fairy'));
    if (fairy_data == nil or type(fairy_data) ~= 'table') then
        fairy_data = { };
    else
        count = #fairy_data[msgtype];
        Message = fairy_data[msgtype][math.random(1,count)];
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
    ascii.font_y = fonts.new(ascii.settings.fairyfont);
    for x = 1, 10 do 
        ascii.font_z[x] = fonts.new(ascii.settings.fairyfont);
    end
-- Cast Bar label
    ascii.font_c = fonts.new(ascii.settings.castfont);
-- Exp Bar label
    ascii.font_d = fonts.new(ascii.settings.expfont);
-- Monster Window labels
    ascii.font_k = fonts.new(ascii.settings.monsterfont);
    ascii.font_x = fonts.new(ascii.settings.monsterfont);
    ascii.font_l = fonts.new(ascii.settings.monsterfont);
    ascii.font_m = fonts.new(ascii.settings.monsterfont);
    ascii.font_n = fonts.new(ascii.settings.monsterfont);
    ascii.font_o = fonts.new(ascii.settings.monsterfont);
    ascii.font_p = fonts.new(ascii.settings.subtarfont); -- This is subtarfont, NOT monsterfont then thought it's in monster window.
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
    ascii.font_i = fonts.new(ascii.settings.partyfont);
    ascii.font_j = fonts.new(ascii.settings.partyfont);
    for x = 0, 17 do
        ascii.font_f[x] = fonts.new(ascii.settings.partyfont);
        ascii.font_h[x] = fonts.new(ascii.settings.partyfont);
        PartyHPLast = 0;
        PartyTPLast = 0;
        PartyMPLast = 0;
    end
    for x = 0, 5 do -- no font_g in alliance windows, don't waste the memory making more than 5.
        ascii.font_g[x] = fonts.new(ascii.settings.partyfont);
    end

-- Get Info and what not for Mobs upon loading the addon.
    ZoneIDStart = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    if(ZoneIDStart > 0) then
        _, mb_data = pcall(require,'data.'..tostring(ZoneIDStart));
        if (mb_data == nil or type(mb_data) ~= 'table') then
            mb_data = { };
            arraySize = 0;
            DatFound = false;
        else
            arraySize = #(mb_data);
            DatFound = true;
        end
    else
        arraySize = 0;
        DatFound = false;
    end

    print(chat.header(addon.name):append(chat.message('Please type /ASCII-Joy help to bring up the -*extensive*- option menu.')));
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
    if (ascii.font_i ~= nil) then
	    ascii.font_i:destroy();
	    ascii.font_i = nil;
    end
    if (ascii.font_j ~= nil) then
	    ascii.font_j:destroy();
	    ascii.font_j = nil;
    end
    if (ascii.font_k ~= nil) then
	    ascii.font_k:destroy();
	    ascii.font_k = nil;
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
    if (ascii.font_x ~= nil) then
	    ascii.font_x:destroy();
	    ascii.font_x = nil;
    end
    if (ascii.font_y ~= nil) then
	    ascii.font_y:destroy();
	    ascii.font_y = nil;
    end
    if (ascii.font_z ~= nil) then
	    ascii.font_z:each(function (v, _)
		    v:destroy();
	    end);
	    ascii.font_z = T{ };
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
    if (type == 1 or type == 5) then -- Make Idle and Death Catch only teleport it around randomly.
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
    local partytableSID = T{};

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
        for x = 1, 10 do
            ascii.font_z[x].visible = false;
        end
        ascii.font_a.visible = false;
        ascii.font_b.visible = false;
        ascii.font_c.visible = false;
        ascii.font_d.visible = false;        
        ascii.font_e.visible = false;
        ascii.font_i.visible = false;
        ascii.font_j.visible = false;
        ascii.font_k.visible = false;
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
        ascii.font_x.visible = false;
        ascii.font_y.visible = false;

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
        ascii.font_y.locked = false; --
    end 
-- *** START HERE ***
    ---- Our Timing Mechanisms
    OSTime = os.time();
    if (OSTime >= (Listening + 2)) then -- We don't want to flood the server too much, only unlock the Check every 2 seconds.
        Listening = 0; 
    end

    if (OSTime >= (CheckLock + 1)) then -- More important to check for listening than checking.
        CheckLock = 0;
    end

    if (OSTime >= (Assisting + 2)) then -- We must not have received the packet, so turn this off.
        Assisting = 0;
    end

    tick = tick + 1; -- Keep the ticks for the animations of fairy and the flashings.
     if (tick >= 30) then -- Not sure why I use greater than. Maybe bad feeling tick will increment too soon one day. Haha.
       	tick = 0;
    end
    ------------

    -- General party-based housekeeping.
    for x = 0, 17 do 
        if (x < 6) then -- only check 0 through 5 to see if we are solo.
            if (party:GetMemberIsActive(x) == 1) then
                solo = solo + 1; -- Never put anything here that may break the for loop. We need partytableSID filled out.
            end
        end
        partytableSID[x] = party:GetMemberServerId(x);
    end

    if (ascii.settings.options.fairy == true and ascii.settings.options.zilda == true) then
        FairyFun(playerent);
    end 
    ------------
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
                arraySize = 0;
                DatFound = false;
            else
                arraySize = #(mb_data);
                DatFound = true;
            end
            PetDebuffs = 0; -- Zoning makes this wonky. Makes a lot of things wonky.
            SteadyW = false; -- Zoning erases this.
	        LastZone = ZoneIDStart; -- Make these match to compare zoning.
	        save_everything();  -- Let's also save when we zone.
            Assisting = 0; -- Let's set all of our locks to 0 if we are zoning.
            Listening = 0; --
            CheckLock = 0; --
	    end
    end

-------- Cast Bar
    if (ascii.settings.options.cast == true) then
        local CastBar = AshitaCore:GetMemoryManager():GetCastBar();
        local CastPer = 100 * CastBar:GetPercent();
        local CastType = CastBar:GetCastType();
        local CastColor = '|cffff1493|';         
        local CastStr = ''
        local CastChk = math.floor(CastPer / (100/30)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
    	
        if (CastType ~= 0) then
            CastColor = '|cffffffff|';
        elseif (CastType ~= 1) then
            CastColor = '|cffffff00|';
        elseif (CastType ~= 2) then
            CastColor = '|cff00ffff|';
        elseif (CastType ~= 3) then
            CastColor = '|cffff00ff|';
        end
                          --      |123456789012345678901234567890
        CastStr = '|'..CastColor..'_____________________________|cffffffff||'  -- It disappears when it's filled, so only show 29 spaces or it will look like a blank one is always there.
        CastStr = string.gsub(CastStr,'_','@',CastChk);
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
    if (ascii.settings.options.exp == true) then     --  99 Squares? VVV  VVV So there isn't always an empty one at 99.9 percent.
        if (player ~= nil) then
            local ExpStr = '';
            local ExpNeed = 0;
            local ExpCurr = 0;
            local ExtraStr = '';
            if(player:GetIsLimitModeEnabled() == true or ExpCurr == ExpNeed) then -- Can only happen if at max level?
                ExpStr = '||cff00ffff|___________________________________________________________________________________________________|cffffffff||'
                ExpNeed = 10000;
                ExpCurr = player:GetLimitPoints();
                ExtraStr = tostring('|cff00ffff| '..player:GetMeritPoints());
            else
                ExpStr = '||cffffff00|___________________________________________________________________________________________________|cffffffff||'
                ExpNeed = player:GetExpNeeded();
                ExpCurr = player:GetExpCurrent();
            end

            local ExpPer = 100 * (ExpCurr/ExpNeed);
            local ExpChk = math.floor(ExpPer / (100/100)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
            ExpStr = string.gsub(ExpStr,'_','#',ExpChk);
            ExpStr = string.gsub(ExpStr,'_',' ');
            ascii.font_d.visible = true;
            ascii.font_d.font_height = 12;
            ascii.font_d.text = ExpStr..ExtraStr;
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
            elsewhere = true;
            if (party:GetMemberIsActive(x) == 0) then
                ascii.font_f[x].visible = false;
                ascii.font_g[x].visible = false;
                ascii.font_h[x].visible = false;
            else
                if (party:GetMemberZone(0) == party:GetMemberZone(x)) then 
                    elsewhere = false;  
                end
        ----- Setup Party Window (NEATEST I THINK I CAN MAKE IT, WORKS BEST ON 14 POINT FONTS at 1920x1080, at least for me.)
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
                local hResult = '';
                local NameColor = '|cff00ffff|';
                local Output = '';
                local OutTwo = '';
                local OutThr = '';
                local TarStar = ' ';
                local Mana = party:GetMemberMP(x);
                local MaValue = party:GetMemberMPPercent(x);
                local MaCheck = math.floor(MaValue / (100/13)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                local mResult = '';
                local MaColor = '|r';
                local TP = party:GetMemberTP(x);
                local TPColor = '|c77777777|';
                local MJob = '';
                local SJob = '';
                local TJob = ''; -- Total, Sum of M and S.
                local ManaStr = '';
                local TPValue = '';
 
    ----  Name Color Matching if Target is in Party
                if (target == nil) then
                    NameColor = '|cff00ffff|';
                else
                    NameColor = '|cff00ffff|';
                    TarStar = ' ';
                    if ((party:GetMemberTargetIndex(x) == target:GetTargetIndex(0) or GetStPartyIndex() == x) and elsewhere == false) then 
                        if (GetStPartyIndex() == x) then
                            NameColor = '|cffaf4be2|';
                            TarStar = '|cffff69B4|*';
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
                    hResult = HPColor..'____________________|cffffffff|';
                    hResult = string.gsub(hResult,'_','#',HPCheck);	
                    hResult = string.gsub(hResult,'_',' ');
                end

                HealthStr = tostring(Health);
    	        while HealthStr:len() < 4 do 
                    HealthStr = " "..HealthStr; 
                end

    ---- Format Player names to fit.
                while Name:len() < 9 do 
                    Name = " "..Name; 
                end
                Name = string.sub(Name, 1, 9);
		
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

                if (Mana < 1000) then
                    ManaStr = ManaStr..' ';
                end

                mResult = '|r|'..MaColor..'_____________|cffffffff||';
                mResult = string.gsub(mResult,'_','@',MaCheck); 
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

                        Output = TarStar..NameColor..Name..leadstar..'|'..hResult..'||cff00ff00|'..HealthStr;
                        OutTwo = TPColor..'     '..TPValue..'  '..mResult..'|cffff69b4|'..ManaStr..'|cffffffff|'..TJob;
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
                        Output = ' '..NameColor..Name..leadstar..'| |cc0c0c0c0| '..tostring(ZoneName)..'|r  ';
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
                    if (solo <= 1 and ascii.settings.options.solo == true) then -- Are we solo with Solo option toggled?
                        ascii.font_e.visible = false;
                    else
                        ascii.font_e.visible = true;
                        ascii.font_e.text = OutThr;
                    end
                else
                    OutThr = '                                     ';
                    ascii.font_e.visible = true; -- Don't need to have a text set for font_e since it should have been set when it was 0.
                    ascii.font_h[x].visible = true;
                    ascii.font_h[x].text = tostring(OutThr);
                end
            end

            if (ascii.settings.options.claim == true and DatFound == true) then
                local ClaimMob = nil; 
                local TarMob = playerent; -- Need a valid Entity stub. Setting to nil makes it not work sometimes? Weird.
                local ClaimHPP = 0;
                local SID = 0;
                local ClaimResult = '||cffff0000|___________________________________|r|';
                local TarID = 0;         --      12345678901234567890123456789012345
                local ClaimName = '';
                local ClaimCheck = 0;
                
                if (target ~= nil) then
                    if (target:GetIsSubTargetActive() > 0) then
                        TarID = target:GetTargetIndex(1); ---- If the target has a sub ID, use that and refence that instead.
                    else
                        TarID = target:GetTargetIndex(0);
                    end
                    TarMob = GetEntity(TarID);
                else
                    TarMob = playerent; -- Need a valid Entity stub. Setting to nil makes it not work sometimes? Weird.  
                end

                if (arraySize > 0) then
                    for x = 1, arraySize do -- Start the frame eating loop. I don't like it this way. If I put a no-target check, healers not targetting anything won't see the claim.
                        ClaimMob = GetEntity(x);
                        if (ClaimMob ~= nil) then
                            if (ClaimMob.HPPercent > 0 and ClaimMob.ClaimStatus > 0 and (TarMob == nil or TarMob.TargetIndex ~= ClaimMob.TargetIndex)) then
                                for _, value in pairs(partytableSID) do
                                    if (value == ClaimMob.ClaimStatus) then
                                        ClaimHPP = ClaimMob.HPPercent;
                                        ClaimName = ClaimMob.Name;
                                        while ClaimName:len() < 37 do
                                            ClaimName = " "..ClaimName;
                                        end
    
                                        break; -- Let's break and keep ClaimMob assigned.
                                    end
                                end
                            else
                                ClaimMob = nil; -- Keep making this nil in case the loop ends or breaks without valid ClaimMob.
                            end
                        else
                            ClaimMob = nil; -- Keep making this nil in case the loop ends or breaks without valid ClaimMob.
                        end

                        ClaimMob = nil; -- Keep making this nil in case the loop ends or breaks without valid ClaimMob.
                    end
                end

                ascii.font_i.position_x = ascii.font_e.position_x;
                ascii.font_i.position_y = ascii.font_e.position_y + fontsize + offset;
                ascii.font_j.position_x = ascii.font_e.position_x;
                ascii.font_j.position_y = ascii.font_i.position_y + fontsize + offset; -- this is font_i to shift font_j lower than font_i.

                if (ClaimMob ~= nil) then -- We draw the lines now that our target isn't what we have claimed.
                    ClaimCheck = math.floor(ClaimHPP / (100/35)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                    ClaimResult = string.gsub(ClaimResult,'_','#',ClaimCheck);	
                    ClaimResult = string.gsub(ClaimResult,'_',' ');

                    ascii.font_i.text = tostring(ClaimResult);
                    ascii.font_j.text = tostring(ClaimName);

                    ascii.font_i.visible = true;
                    ascii.font_j.visible = true;
                else    
                    ascii.font_i.visible = false;
                    ascii.font_j.visible = false;
                end
            else
                ascii.font_i.visible = false;
                ascii.font_j.visible = false;
            end
        end -- End Player Party Main Window
        -- ALLIANCE WINDOWS
        if (ascii.settings.options.alliance == true) then
            for z = 1, 2 do
                local startnum = 0;
                local endnum = 0;
                local offtooff = 0;
                local increment = 0;
                local allfirst = -1;
                spcy = 0;

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
                    local count = 0;
                    elsewhere = true;
                    if (party:GetMemberIsActive(x) == 0) then 
                        ascii.font_f[x].visible = false;
                        ascii.font_h[x].visible = false;
                    else
                        if (allfirst == -1) then -- If there is no first in the alliance, make this number the first.
                            allfirst = x;
                        end

                        if (party:GetMemberZone(x) == party:GetMemberZone(0)) then 
                            elsewhere = false;  
                        end
             ----- Setup Alliance Windows
             ----- "cur" is Health, "new" is Mana, "spc" is blank line between party members
                        if (spcy == 0) then 
                            if (z == 1) then
                                spcy = ascii.font_a.GetPositionY();
                            else
                                spcy = ascii.font_b.GetPositionY();
                            end
                        else
                            spcy = cury - 20 - offset - offtooff; -- fontsize is 10 and it was doubled in the normal party function. Put in offset to the offset.
                        end

                        cury = spcy - 20 - offset - offtooff; -- fontsize is 10 and it was doubled in the normal party function. Put in offset to the offset.
                        ascii.font_f[x].position_y = cury;
                        ascii.font_h[x].position_y = spcy;
                        ascii.font_f[x].font_height = 10;
                        ascii.font_h[x].font_height = 10;
                        if (z == 1) then
                            ascii.font_f[x].position_x = ascii.font_a.position_x;
                            ascii.font_h[x].position_x = ascii.font_a.position_x;
                        else
                            ascii.font_f[x].position_x = ascii.font_b.position_x;
                            ascii.font_h[x].position_x = ascii.font_b.position_x;
                        end

                        local ZoneName = AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(x)); 
                        local Name = party:GetMemberName(x);
                        local Health = party:GetMemberHP(x);
                        local HPValue = party:GetMemberHPPercent(x);
                        local HPCheck = math.floor(HPValue / (100/20)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                        local HealthStr = '';
                        local HPColor = '';
                        local hResult = '';
                        local NameColor = '|cff00ffff|';
                        local Output = 'XXX';
                        local OutTwo = 'XXX';
                        local OutThr = 'XXX';
                        local TarStar = ' ';
              ----  Name Color Matching if Target is in Alliance
                        if (target == nil) then
                            NameColor = '|cff00ffff|';
                        else
                            NameColor = '|cff00ffff|';
                            TarStar = ' ';                          
                            if ((party:GetMemberTargetIndex(x) == target:GetTargetIndex(0) or GetStPartyIndex() == x) and elsewhere == false) then 
                                if (GetStPartyIndex() == x) then 
                                    NameColor = '|cffaf4be2|';
                                    TarStar = '|cffff69B4|*';
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
                            hResult = HPColor..'____________________|cffffffff|';
                            hResult = string.gsub(hResult,'_','#',HPCheck);	
                            hResult = string.gsub(hResult,'_',' ');
                        end

                        HealthStr = tostring(Health);
                        while HealthStr:len() < 4 do 
                            HealthStr = " "..HealthStr; 
                        end

               -------- Format Player names to 8 characters for Alliance
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
                        if (HPValue <= 33 and elsewhere == false) then
                            if (tick >= 15 and party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and party:GetMemberMainJob(x) ~= 0) then 
                                ascii.font_f[x].background.color = 0x5fff0000;
                            else
                                ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                            end
                        else
                            ascii.font_f[x].background.color = ascii.settings.partyfont.background.color;
                        end 
                                                    
                        if (elsewhere == false and ((party:GetMemberMainJob(x) ~= nil and party:GetMemberMainJob(x) <= 22 and -- This is all for f'ing ANON people. Hate them.
                            party:GetMemberMainJob(x) ~= 0) or (party:GetMemberMainJob(x) == 0 and party:GetMemberHPPercent(x) > 0))) then  -- Try to put in Zone Name for far away friends
                                Output = (TarStar..NameColor..Name..leadstar..' '..TPColor..TPValue..'|r|'..hResult..'||cff00ff00|'..HealthStr);
                                ascii.font_f[x].text = tostring(Output);
                        else 
                            if (ZoneName == nil) then
                                ZoneName = 'BROKEN PLAYER ZONE';
                            end

                            while ZoneName:len() < 21 do
                                ZoneName = " "..ZoneName;
                            end

                            ZoneName = string.sub(ZoneName, 1, 21);
                            Output = ' '..NameColor..Name..leadstar..'     | |cc0c0c0c0| '..tostring(ZoneName)..'|r  ';
                            ascii.font_f[x].text = tostring(Output);
                        end	    

                        if (x == allfirst) then 
                            ascii.font_h[x].visible = false; -- Don't show this for the first person in the alliance.
                        else
                            ascii.font_h[x].visible = true;
                            ascii.font_h[x].text = '                                         ';
                        end

                        if (z == 1) then -- If we are here, we MUST have rendered someone.
                            ascii.font_a.visible = true;
                            ascii.font_a.text = '                               Alliance 1'; 
                        else
                            ascii.font_b.visible = true;
                            ascii.font_b.text = '                               Alliance 2';
                        end

                        count = count + 1; -- Hopefully making the count go after it is rendered works.
                    end

                    if (count == 0) then
                        if (z == 1) then
                            ascii.font_a.visible = false;
                        else
                            ascii.font_b.visible = false;
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
        local MobTarget = 0;
        local centerjust = true;
        local OutFou = '';
        local OutFiv = '';
        local OutSix = '';
        local OutSev = '';
        local OutEig = '';
        local mobResult = '';
        local monsterfontsize = ascii.settings.monsterfont.font_height;
   
        if(target ~= nil) then
            if (target:GetIsSubTargetActive() > 0) then
                TarID = target:GetTargetIndex(1); ---- If the target has a sub ID, use that and refence that instead.
                submob = GetEntity(target:GetTargetIndex(0));
                SubIndex = target:GetTargetIndex(0); -- Global on what the purple arrow is pointing to.
            else
                SubIndex = 0;
                TarID = target:GetTargetIndex(0);
    	    end

            MainIndex = TarID; -- So we have global of what the Monster Window is looking at.
            if (TarID > 0) then 
                tarmob = GetEntity(TarID);
                MobHPP = tarmob.HPPercent;
                spawn = tarmob.SpawnFlags;
                MobName = tarmob.Name; 
                tarserverid = tarmob.ServerId;   -- ServerId is large and unique to the dat file.
                if (spawn == 16) then
                   MobTarget = AshitaCore:GetMemoryManager():GetEntity():GetTargetedIndex(TarID);
                end
            end
			---- Poll everything in the zone to find the mob we want to kill. 
                                                  --CheckedTar is to say if we checked current mob, so we don't get data from one mob onto another. That use to happen.
            if (spawn == 16 and tarserverid > 0 and LastMob ~= tarserverid and CheckedTar ~= TarID and GotPacket == false and ascii.settings.options.moninfo == true) then
                GotMob = tarserverid;
                Listening = 0; -- If targets were quickly switched while listening, stop listening. 
                for i = 1, arraySize do	----- START FOR LOOP      --^^^ No sense wasting clock cycles if we have all the info.
                    if (mb_data[i] ~= nil) then  -- Vicrelant's ibar addon incorporated here.
                        if (tonumber(mb_data[i].id) == tarserverid) then
				---- Start the checker
                            if (CheckLock == 0) then
                                MobDefEva = '(   ????   )';
                                MobType = '     ???     '; -- We want these blank until we actually find the packet on the same mob, which will stop the loop.
                                MobLvlStr = '???'; --            the packet on the same mob, which will stop the loop.
                                MobLvl = 0;
                                SendCheckPacket(TarID);
                                CheckLock = OSTime;
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

                            MobWeak = 'ID: '..string.format('0x%X',TarID)..'  Aggro: |cffff0000|'..MobAggro..' WEAK: '..mb_data[i].weak;
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
                            LastMob = tarserverid; -- Found the mob, now we don't want to run this loop again.
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
          
            OutEig = '  |cffffffff|'..' LVL: '..tostring(MobLvlStr)..'   '..MobJob..'|cffffffff|  | '..MobType..' '..MobDefEva; 
            while MobName:len() < 47 do 
                if (centerjust == true) then
                    MobName = ' '..MobName; 
                    centerjust = false;
                else
                    MobName = MobName..' ';
                    centerjust = true;
                end
            end
            centerjust = true; -- started this at true, so let's put it back there.

            MobHPCheck = math.floor(MobHPP / (100/46)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
           --[[MobStr = tostring(MobHPP);  ------ Let's not put Monster HP% in for now, defeats purpose of the bar.
            while MobStr:len() < 3 do 
                MobStr = " "..MobStr; 
            end  ]]
            if (spawn == 16) then
                local MobHPColor = '|cffff0000|';
                if (ascii.settings.options.aggro == true) then
                    if (Listening == 0 and TarID ~= party:GetMemberTargetIndex(0) and Assisting == 0) then -- Assisting ourselves gets weird, I'd have to believe.
                        Listening = OSTime;
                        SendAssistPacket(TarID);
                    end
                end

                if (tarmob ~= nil and tarmob.ClaimStatus > 0) then
                    mobResult = '|cffff0000|_____________________________________________';
                else
                    mobResult = '|cffffff00|_____________________________________________';
                end

                mobResult = string.gsub(mobResult,'_','#',MobHPCheck);
                mobResult = string.gsub(mobResult,'_',' ');
                mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
            elseif ((spawn == 1 or spawn == 4 or spawn == 8 or spawn == 9 or spawn == 13) and ascii.settings.options.tarplay == true) then
                mobResult = '|cff00ff44|_____________________________________________'
                mobResult = string.gsub(mobResult,'_','#',MobHPCheck);
                mobResult = string.gsub(mobResult,'_',' ');
                mobResult = ''..MobStr..'|cffffffff||'..mobResult..'|cffffffff||';
                GotMob = 0; -- Anytime our target isn't a mob (spawn == 16), make this 0.
                ascii.font_o.visible = false;
                ascii.font_l.visible = false;
            else
                GotMob = 0; -- Anytime our target isn't a mob (spawn == 16), make this 0.
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
            GotMob = 0; -- Anytime our target isn't a mob (spawn == 16), make this 0.
            GotMobAct = 0;
            GotMobActParam = 0;
            TargetsTarget = 0;
        end -- END If Target Isn't Nil.
        
        if (spawn == 16 or ((spawn == 1 or spawn == 4 or spawn == 8 or spawn == 9 or spawn == 13) and ascii.settings.options.tarplay == true)) then     -- Differentiate Monsters from NPC's/Players/Goblin Footprints/etc.
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
                ascii.font_k.position_x = ascii.font_m.position_x;
                ascii.font_x.position_x = ascii.font_m.position_x;
                ascii.font_o.position_x = ascii.font_m.position_x;

                if (ascii.settings.options.monabov ~= true) then
                    ascii.font_k.position_y = ascii.font_m.position_y + (2 * ((monsterfontsize * 2) + offset));
                    ascii.font_x.position_y = ascii.font_m.position_y + (monsterfontsize * 2) + offset;
                    ascii.font_l.position_y = ascii.font_n.position_y - (monsterfontsize * 2) - offset;
                    ascii.font_o.position_y = ascii.font_l.position_y - (monsterfontsize * 2) - offset;
                else	
                    ascii.font_x.position_y = ascii.font_m.position_y - (monsterfontsize * 2) - offset;
                    ascii.font_k.position_y = ascii.font_x.position_y - (monsterfontsize * 2) - offset; -- (2 * ((monsterfontsize * 2) - offset));
                    ascii.font_l.position_y = ascii.font_n.position_y + (monsterfontsize * 2) + offset;
                    ascii.font_o.position_y = ascii.font_l.position_y + (monsterfontsize * 2) + offset;
                end

                -- THANK YOU SO MUCH, ALMAVIVACONTE!
                if (ascii.settings.options.aggro == true and TargetsTarget > 0 and TargetsTarget ~= party:GetMemberTargetIndex(0)) then 
                    local PlayerToT = GetEntity(TargetsTarget);
                    local PlayerToTCheck = 0;
                    local PlayerToTResult = '|cff009944|____________________________________';
                    local PlayerToTHPP = 0;       --    123456789012345678901234567890123456789012345
                    local PlayerToTName = '';

                    if (PlayerToT ~= nil and TargetsTarget ~= tarmob.TargetIndex) then
                       PlayerToTHPP = PlayerToT.HPPercent;
                       PlayerToTName = PlayerToT.Name;

                        if (PlayerToTHPP > 0 and PlayerToTName ~= nil) then -- We draw the lines now that our target isn't what we have claimed.
                            PlayerToTCheck = math.floor(PlayerToTHPP / (100/36)); -- DENOMINATOR OF FRACTION IS HOW MANY SQUARES WE USE FOR BAR!!!!
                            PlayerToTResult = string.gsub(PlayerToTResult,'_','#',PlayerToTCheck);	
                            PlayerToTResult = string.gsub(PlayerToTResult,'_',' ');

                            while PlayerToTName:len() < 8 do
                                PlayerToTName = " "..PlayerToTName;
                            end

                            PlayerToTName = string.sub(PlayerToTName, 1, 8);
                            PlayerToTResult = '|'..PlayerToTResult..'|r| '..PlayerToTName;

                            ascii.font_k.text = PlayerToTResult;
                            ascii.font_k.visible = true;
                        else
                            TargetsTarget = 0;
                            ascii.font_k.visible = false;
                        end
                    else
                        TargetsTarget = 0;
                        ascii.font_k.visible = false;
                    end
                else 
                    TargetsTarget = 0;
                    ascii.font_k.visible = false;
                end

                local MobAbStr = '';                            -- Thanks to BYRTH and SPIKEN of SimpleLog for ideas on how to do this!
                if (GotMobAct == 8) then 
                    local MobSpell = AshitaCore:GetResourceManager():GetSpellById(GotMobActParam);
                    if (MobSpell == nil) then -- NIL CHECK
                        return;
                    end

                    if(Interrupt == false) then
                        MobAbStr = 'CASTING:      '..tostring(MobSpell.Name[1]);
                    else
                        MobAbStr = '                                               ';
                    end
                elseif (GotMobAct == 7) then
                    local MobAbility = '';
                    if (GotMobActParam < 256) then
                        local MobSkill = AshitaCore:GetResourceManager():GetAbilityById(GotMobActParam);
                        if (MobSkill == nil) then -- NIL CHECK
                            return;
                        end

                        MobAbility = tostring(MobSkill.Name[1]);
                    elseif (GotMobActParam == 256) then
                        MobAbility = 'WTF SKILL OF DOOM!';
                    else
                        MobAbility = AshitaCore:GetResourceManager():GetString('monsters.abilities', GotMobActParam - 256, 2) -- Must subtract 256. This table starts at 1.
                        if (MobAbility == nil) then -- NIL CHECK
                            return;
                        end

                        MobAbility = MobAbility:sub(1, #MobAbility - 1); -- The above string adds a "\0" on the end for some reason, screwing the centerjust up.
                    end

                    if(Interrupt == false) then
                        MobAbStr = tostring('USING:      '..MobAbility); -- There was a tostring() for MobAbility
                    else
                        MobAbStr = '                                               ';
                    end
                else
                    MobAbStr = '                                               ';
                end    --       12345678901234567890123456789012345678901234567

                while MobAbStr:len() < 47 do 
                    if (centerjust == true) then
                        MobAbStr = ' '..MobAbStr; 
                        centerjust = false;
                    else
                        MobAbStr = MobAbStr..' ';
                        centerjust = true;
                    end
                end
                centerjust = true; -- started this at true, so let's put it back there.

                if (UnableToSee == true) then
                    local Flasher = 0;
                    
                    _, Flasher = math.modf(tick/6)
                    if (Flasher < .5) then
                        ascii.font_x.background.color = 0x3FFF0000;
                    else  
                        ascii.font_x.background.color = ascii.settings.monsterfont.background.color;
                    end

                    MarkTickSee = MarkTickSee + 1;
                    if (MarkTickSee > 20) then
                        MarkTickSee = 0;
                        UnableToSee = false;
                        ascii.font_x.background.color = ascii.settings.monsterfont.background.color;
                    end
                end

                ascii.font_x.visible = true;
                ascii.font_l.visible = true;
                ascii.font_o.visible = true;
                ascii.font_l.text = tostring(OutEig);
                ascii.font_o.text = tostring(OutSix);
                ascii.font_x.text = tostring(MobAbStr);
            else
                TargetsTarget = 0;
                ascii.font_k.visible = false;  
                ascii.font_x.visible = false;  
                ascii.font_l.visible = false;                 
                ascii.font_o.visible = false;
            end
        else
            ascii.font_m.visible = false;    -- This all needs to be here or it will try to make a window for non-monsters
            ascii.font_n.visible = false;    --
            ascii.font_o.visible = false;    --
            ascii.font_l.visible = false;    --
            ascii.font_k.visible = false;    --
            ascii.font_x.visible = false;    --
            TargetsTarget = 0;
            GotMob = 0; -- Anytime our target isn't a mob (spawn == 16), make this 0.
            GotMobAct = 0;
            GotMobActPAram = 0;
            SneakAttack = false; 
        end

        if (tarmob == nil) then 		-- Have nothing targetted
            ascii.font_p.visible = false;
        else
            if(tarmob ~= nil and target:GetIsSubTargetActive() == 0 ) then 	
					-- Have a Non-Monster Target and no Sub-Target
                if (spawn ~= 16) then -- Main Target is not Monster
                    if ((spawn == 1 or spawn == 4 or spawn == 8 or spawn == 9 or spawn == 13) and ascii.settings.options.tarplay == true) then
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
                    local subspawn = submob.SpawnFlags;
                    if ((subspawn == 1 or subspawn == 4 or subspawn == 8 or subspawn == 9 or subspawn == 13) and ascii.settings.options.tarplay == true) then
                        local subHPP = submob.HPPercent;
                        OutSev = OutSev..' ('..' '..string.format('%2.0f',subHPP)..' )';
                    end
                end
            end
        end

        if (target:GetIsSubTargetActive() == 0) then
            OutSev = '|cFF80FF00|'..OutSev; 
        else
            OutSev = '|cffff1493|' ..--[['|cff7f2be2|'..]]OutSev; -- mAKE THIS MORE NOTICABLE.
        end

        ascii.font_p.font_height  = monsterfontsize + 6; -- was +2
        ascii.font_p.italic = true;
        ascii.font_p.background.visible = false;
        ascii.font_p.text = OutSev; -- Target/Sub-Target Name
    else
        ascii.font_k.visible = false;
        ascii.font_x.visible = false;    
        ascii.font_l.visible = false;
        ascii.font_m.visible = false;
        ascii.font_n.visible = false;
        ascii.font_o.visible = false;
        ascii.font_p.visible = false;
        TargetsTarget = 0;
    end
-------- END Mob Info Window

-------- Player Window
    if(ascii.settings.options.playwin == true) then
        if (player == nil or playerent == nil) then 
            return; 
        end

        local sResult = '';
        local playernumber = 0;
        local HPValue = playerent.HPPercent;
        local HPCheck = math.floor(HPValue / (100 / 50));
        local HPColor = '';
        local selffontsize = ascii.settings.selffont.font_height;
        local SelfTP = party:GetMemberTP(0); 
        local SelfHP = party:GetMemberHP(0); 
        local SelfHPMax = player:GetHPMax();
        local SelfMP = party:GetMemberMP(0); 
        local SelfMPMax = player:GetMPMax();
        local SelfStr = '                   '; -- Let's go some spaces in for Pet Name room
        local SelfTPStr = tostring(SelfTP);
        local SelfHPStr = tostring(SelfHP)
        local SelfMPStr = tostring(SelfMP);
        local SelfMPMStr = tostring(SelfMPMax);
        local SelfHPMStr = tostring(SelfHPMax);
        local pet = GetEntity(playerent.PetTargetIndex);
        while SelfTPStr:len() < 4 do
            SelfTPStr = " "..SelfTPStr;
        end

        if (SelfTP >= 1000) then
            SelfTPStr = '|cff70ff70|'..SelfTPStr..'|r';
        else
            SelfTPStr = '|cffc0c0c0|'..SelfTPStr..'|r';
        end	

        while SelfHPStr:len() < 4 do
            SelfHPStr = " "..SelfHPStr;
        end

        while SelfHPMStr:len() < 4 do
            SelfHPMStr = " "..SelfHPMStr;
        end

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
            local Value = 1; -- VALUE IS PLACEHOLDER IN HEART LINE (1 to 12).
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
                HeartNum[Value] = 5;
                HeartFull = HeartFull - 1;
                Value = Value + 1;
            end	

            if (HeartFrac > .95) then  -- 95 to 100 percent gets 4/4 Heart?
                HeartNum[Value] = 5; -- FULL HEART
            elseif (HeartFrac > .66) then  -- 66 to 95 percent gets 3/4 Heart?
                HeartNum[Value] = 4; -- 3/4 HEART
            elseif (HeartFrac > .33) then  -- 33 to 66 percent gets 1/2 Heart?
                HeartNum[Value] = 3; -- 1/2 HEART
            elseif (HeartFrac > .1) then  -- 10 to 33 percent gets 1/4 Heart?
                HeartNum[Value] = 2; -- 1/4 HEART
            else	
                if(HeartFullTot == 0 and HPValue > 0) then -- To not show some health as zero Hearts when near Death.
                    HeartNum[Value] = 2 -- 1/4 Heart
                else
                    HeartNum[Value] = 1 -- EMPTY HEART for less than 10 percent when not near Death.
                end
            end
	
            Value = Value + 1; -- Increase value from the fractional Heart
            while Value <= HeartMax do
                HeartNum[Value] = 1; -- EMPTY HEART
                Value = Value + 1;
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

            ascii.font_q.font_height  = 30;    -- TWO SETS OF THESE LINE PLACEMENTS, ONE FOR HEART ONE FOR REGULAR. THIS IS HEART.
            ascii.font_s.position_x = ascii.font_r.position_x;
            ascii.font_s.position_y = ascii.font_r.position_y + (selffontsize * 2) + offset;
            ascii.font_t.position_x = ascii.font_s.position_x;
            ascii.font_t.position_y = ascii.font_s.position_y + (selffontsize * 2) + offset;
            ascii.font_w.position_x = ascii.font_t.position_x;
            ascii.font_w.position_y = ascii.font_t.position_y + (selffontsize * 2) + offset; 
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
                sResult = '{'..HPColor..'__________________________________________________|cffffffff|}';
                sResult = string.gsub(sResult,'_','#',HPCheck);
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
        
        if(ascii.settings.options.debug == true and ascii.settings.options.zilda == true) then -- Debug only works in Fairy mode.
            ascii.font_q.font_height  = 20;
            ascii.font_q.text = string.format(sResult..'     '..tostring(DEBUG1)..'  '..tostring(DEBUG2)..'  '..tostring(DEBUG3)..'  '..tostring(DEBUG4));
        else
            ascii.font_q.text = string.format(sResult);
        end

        if (playerent.PetTargetIndex > 0 and pet ~= nil) then ---- PLAYER HAS PET
            local petname = pet.Name;
            local pettp = player:GetPetTP();
            local petmp = player:GetPetMPPercent();
            local pResult = '{|cff00ffff|__________________________________________________|cffffffff|}'; 
            local PHValue = pet.HPPercent;
            local PHCheck = math.floor(PHValue / (100 / 50));
            local tResult  = '';
            local pmResult = '';
            local PTCheck = math.floor(pettp / (3000 / 20));
            local PTColor = '|cff7f7f7f|';
            local PMCheck = math.floor(petmp / (100 / 20));
            local PMColor = '|cfff48dff|';
            local PetTarget = nil;
            local PDebuffs = '      ';
            while (petname:len() < 15) do
                petname = petname.." ";
            end

            ascii.font_r.visible = true;
            ascii.font_s.visible = true;
            ascii.font_t.visible = true;
            ascii.font_r.background.visible = false;
            ascii.font_r.text = string.format(petname);
            pResult = string.gsub(pResult,'_','#',PHCheck);
            pResult = string.gsub(pResult,'_',' ');
            if (SteadyW == true or PetDebuffs == 37) then -- Steady Wing or Stoneskin will put up our shielding thing.
                ascii.font_s.background.color = 0x4FFFFFFF;
                ascii.font_s.background.visible = true;
            else
                ascii.font_s.background.color = ascii.settings.selffont.background.color;
                ascii.font_s.background.visible = ascii.settings.selffont.background.visible;
            end

            ascii.font_s.text = string.format(pResult);
            if (pettp >= 1000) then
                PTColor = '|cff40a040|';
            end

            if (petmp >= 100) then
                PMColor = '|cffff00cc|';
            end
            
            if (PetDebuff == 0) then -- 7, 2, 19, 193, 6, 4, 10, 566, 22, 16, 21, 28, 11 --[[TESTS]], 136, 3, 540, 5
                PDebuffs = '      ';
            elseif (PetDebuffs == 2 or PetDebuffs == 19) then -- Slept, Make these 6 characters long.
                PDebuffs = ' SLEPT';
            elseif (PetDebuffs == 7) then -- Petrified
                PDebuffs = 'PETRI.';
            elseif (PetDebuffs == 193) then -- Lullaby
                PDebuffs = ' LULL ';
            elseif (PetDebuffs == 6) then -- Silence
                PDebuffs = 'SILENT';
            elseif (PetDebuffs == 4 or PetDebuffs == 566) then -- Paralysis
                PDebuffs = 'PARAL.';
            elseif (PetDebuffs == 10) then -- Stun
                PDebuffs = ' STUN ';
            elseif (PetDebuffs == 16) then -- Amnesia
                PDebuffs = 'AMNES.';
            elseif (PetDebuffs == 21) then -- Addle
                PDebuffs = 'ADDLED';
            elseif (PetDebuffs == 22) then -- Intimidated
                PDebuffs = 'INTIM.';
            elseif (PetDebuffs == 28) then -- Terror
                PDebuffs = 'TERROR';
            elseif (PetDebuffs == 11) then -- Bind
                PDebuffs = ' BIND ';
            elseif (PetDebuffs == 136) then -- STR DOWN TEST
                PDebuffs = ' STR  '; ------ TEST 
            elseif (PetDebuffs == 3 or PetDebuffs == 540) then -- poison TEST
                PDebuffs = 'POISON';    
            elseif (PetDebuffs == 5) then -- Blind TEST
                PDebuffs = ' BLIND'; ------ TEST 
            elseif (PetDebuffs > 0) then -- Default
                PDebuffs = '|cffff0000|UNKNWN|r';
            else
                PDebuffs = '      ';
            end

            tResult = '{'..PTColor..'____________________|r}';
            tResult = string.gsub(tResult,'_','#',PTCheck);
            tResult = string.gsub(tResult,'_',' ');
            pmResult = '{'..PMColor..'____________________|r}';
            pmResult = string.gsub(pmResult,'_','#',PMCheck);
            pmResult = string.gsub(pmResult,'_',' ');
            ascii.font_t.text = string.format(tResult..' |cffffff00|'..PDebuffs..'|r '..pmResult);
        -- Pet's target function
            if (PetTargetsID > 0 and PetTargetsID ~= target:GetServerId(0) and PetTargetsID ~= target:GetServerId(1)) then -- Don't see unless the pet's target differs from our own.
                PetTarget = GetEntityByServerId(PetTargetsID); -- PetTargetsID is a ServerID
                if (PetTarget ~= nil) then
                    local PetTarHPPer = 0;
                    local PetTarName = '';
                    local PetTarResult = '{|cffff7700|______________________________|r}'; 
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
            PetDebuffs = 0;
            SteadyW = false;
            ascii.font_r.visible = false;
            ascii.font_s.visible = false;
            ascii.font_t.visible = false;
            ascii.font_w.visible = false;
        end
    else
        PetDebuffs = 0;
        SteadyW = false;
        ascii.font_q.visible = false;
        ascii.font_r.visible = false;
        ascii.font_s.visible = false;
        ascii.font_t.visible = false;
        ascii.font_u.visible = false;
        ascii.font_w.visible = false;
        ascii.font_y.visible = false;
        for x = 1, 10 do
            ascii.font_z.visible = false;
        end

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
        { '/ASCII-Joy claim    ', 'Toggles showing a claimed mob you are not targetting under the Party Window. (Thanks, Dash!)'},
        { '/ASCII-Joy alliance ', 'Toggles Alliance Windows (WILL COST SOME FPS, FOR SURE).'},
        { '/ASCII-Joy solo     ', 'Toggles seeing yourself in Party Window while solo (Zone Name remains).' },
        { '/ASCII-Joy player   ', 'Toggles Player Window of your own HP Bar, TP, Mana, Pet info (if you have one).' },
        { '/ASCII-Joy zilda    ', 'Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!' },
        { '/ASCII-Joy grow     ', 'Toggles if you always see 12 Heart Containers, or get more as you level up (up to 12 Max).' },
        { '/ASCII-Joy fairy    ', 'Toggles whether the Fairy will grace you with her presence, depending on your point of view.' },
        { '/ASCII-Joy monster ', 'Toggles the Monster Health/Sub-Target Window.' },
        { '/ASCII-Joy mon-pos ', 'Toggles Monster info Above/Below their Health Bar.' },
        { '/ASCII-Joy mon-info', 'Toggles Aggro/Weak info. Not live info, pulled from file.' },
        { '/ASCII-Joy aggro',    'Toggles seeing who the Monster is trying to kill. (/ASSIST MAY ACT WEIRD. SEE README!)'},
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
    if (#args == 0) then
        return;
    end

    if (args[1] == '/assist' or args[1] == '/Assist' or args[1] == '/ASSIST') then -- Maybe block assist while targetting a mob?
        if (Assisting == 0) then 
            Assisting = OSTime;
        end

        return;
    end

    if (args[1] ~= '/ASCII-Joy') then
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

    if (#args == 2 and args[2]:any('claim')) then
        if(ascii.settings.options.party == true) then
            ascii.settings.options.claim = not ascii.settings.options.claim;
            if(ascii.settings.options.claim == true) then
                print(chat.header(addon.name):append(chat.message('You will see the Battle Target of the Party.')));
            elseif(ascii.settings.options.claim == false) then
                print(chat.header(addon.name):append(chat.message('You will NOT see the Battle Target of the Party.')));
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

    if (#args == 2 and args[2]:any('debug')) then
        ascii.settings.options.debug = not ascii.settings.options.debug;
        if(ascii.settings.options.debug == false) then
            print(chat.header(addon.name):append(chat.message('DEBUG MODE DISABLED.')));
            DEBUG1 = nil;
            DEBUG2 = nil;
            DEBUG3 = nil;
            DEBUG4 = nil;
        elseif(ascii.settings.options.monster == true) then
            print(chat.header(addon.name):append(chat.message('DEBUG MODE ENABLED.')));
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

    if (#args == 2 and args[2]:any('aggro')) then
        if(ascii.settings.options.monster == true) then
            if(ascii.settings.options.moninfo == true) then
                ascii.settings.options.aggro = not ascii.settings.options.aggro;
                if(ascii.settings.options.aggro == true) then
                    print(chat.header(addon.name):append(chat.message('You will track who the Monster is trying to kill.')));
                elseif(ascii.settings.options.aggro == false) then
                    print(chat.header(addon.name):append(chat.message('You do not care who the Monster is trying to kill.')));
                end

                save_everything();
                return;
            else
                print(chat.header(addon.name):append(chat.message('You need Monster Information (mon-info) enabled to toggle this.')));
                return;
            end
        else
            print(chat.header(addon.name):append(chat.message('You need the Monster Window enabled to toggle this.')));
            return;
        end
    end

    if (#args == 3 and args[2]:any('offset')) then
        local change = args[3]:number_or(0);
        if(change > 10 or change < -10) then
            print(chat.header(addon.name):append(chat.message('Valid Offset range are integers -10 to 10.')));
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
    -- Unhandled: Print stub..
    print(chat.header(addon.name):append(chat.message('Incorrect Syntax. Type<  /ASCII-Joy help  >to bring up the menu of syntax choices.')));
end);

ashita.events.register('packet_in', 'packet_in_cb', function (e) -- Checker and petinfo addon by Atom0s. Used with permission. Rest is mine, Haha.
  -- Packet: Zone Enter / Zone Leave
    if (e.id == 0x000A or e.id == 0x000B) then
        return;
    end

  -- Packet: Message Basic
    if (e.id == 0x0029) then -- Checker stuff
        local p1    = struct.unpack('l', e.data, 0x0C + 0x01); -- Param 1 (Level, for checker)
        local p2    = struct.unpack('L', e.data, 0x10 + 0x01); -- Param 2 (Check Type, for checker)
        local m     = struct.unpack('H', e.data, 0x18 + 0x01); -- Message (Defense / Evasion, for checker)
        local PacketTar = struct.unpack('H', e.data, 0x16 + 0x01); -- This is not ServerID!!!
    ---- Begin message checks
        if (m == 0x05) then -- 5 is Unable to See, 4 is Too far away.
            UnableToSee = true;
        end

        ---- Try to catch Pet things.
        local player = GetPlayerEntity(); -- Let's check for pet status?
        if(player == nil) then
            return;
        elseif (PacketTar ~= nil and PacketTar > 0 and (player.PetTargetIndex == PacketTar --[[TEST-->>]]--[[or PacketTar == player.TargetIndex]])) then -- See if we can snag certain debuffs on the pets. Does this cover AOE? 
            if (m > 1) then -- 1 is normal attack, we don't need to scan through that. 
                for _, value in pairs(T{82, 127, 141, 203, 205, 236, 242, 243, 270, 277, 278, 279, 280, 320, 375, 421, 441, 602, 645}) do -- Applying debuffs. 141 looks ok if /lb is line break.
                    if (p1 == 37) then
                        SteadyW = true;
                        break;
                    end
                    -- ORDER OF IMPORTANCE!!7, 2, 19, 193, 6, 4, 10, 566, 22, 16, 21, 28, 11 --[[TESTS]], 136, 3, 540, 5  -- 37 is stone
                    for _, value in pairs(T{7, 2, 19, 193, 6, 4,     566, 22, 16, 21, 28, 11 --[[TESTS]],3 ,5, 136, 540, 138, 102    }) do -- Same debuffs as Pet Window.
                        if (value == PetDebuffs) then -- if it cycles to where PetDebuffs is, then it must be lower tier debuff. Skip.
                            break;
                        elseif (value == p1) then -- It could only have gotten here if we have cycled before the current PetDebuffs.
                            PetDebuffs = p1; -- local into global. -- Removed 10 (stun) above as we caught one and it never went away.
                            break; -- This breaks the for loop for value == ActParam if we find one.
                        end
                    end
                end

                for _, value in pairs(T{64, 83, 204, 206, 350, 531}) do -- Removing debuffs -- This stays in 0x29.
                    if (value == m) then  -- Need another for value pairs table check to see if it's a debuff we would even track.
                        if (p1 == 37) then
                            SteadyW = false;
                            break;
                        end
                        
                        for _, value in pairs(T{7, 2, 19, 193, 6, 4, 566, 22, 16, 21, 28, 11 --[[TESTS]],3 ,5, 136, 540, 138, 102    }) do -- Same debuffs as Pet Window.
                            if (value == p1 and p1 == PetDebuffs) then -- It could only have gotten here if we have cycled before the current PetDebuffs.
                                PetDebuffs = 0; -- local into global. -- Removed 10 (stun) above as we caught one and it never went away.
                                break; -- This breaks the for loop for value == ActParam if we find one.
                            end
                        end
                    end
                end
            end 
        end
        ---- End Pet things
        
        ---- Checker Begin, Thanks Atom0s.
        -- Ensure this is a /check message.. 
        if (m ~= 0xF9 and (not checker.conditions:haskey(m) or not checker.types:haskey(p2))) then
            return;
        end

        -- Obtain the string form of the conditions and type..
        local c = checker.conditions[m];
        local t = checker.types[p2];
        if (c == nil or t == nil) then -- Otherwise it will crash getting the length of 'c' a few lines down. (Happened)
            return;
        end

        MobLvl = p1;
        MobDefEva = tostring(#c > 0 and c:enclose('(', ')') or c);
        MobType = tostring(t);
        CheckedTar = PacketTar;
        GotPacket = true; -- So we stop trying to check.
        e.blocked = true; -- So we don't fill the chat window.
        return true;
    end---- Checker End
  ------

  -- Packet: Action
    if (e.id == 0x0028) then
        local ServerID = struct.unpack('I', e.data, 0x05 + 0x01); -- ServerID of the Actor.
        local TempPlayer = GetPlayerEntity(); -- This is an Entity structure. Not the same as Player structure. Leave this.
        local TargetCount = ashita.bits.unpack_be(e.data:totable(), 0x48, 0x0A);
        --local ActionCount = each action count is offset by each target, does each target have an action or do they all come after all of the targets?
        local Action = ashita.bits.unpack_be(e.data:totable(),  0x52, 0x04); -- Base Category in the base of that table for 0x28. Not changed by number of targets.
        local ActParam = ashita.bits.unpack_be(e.data:totable(), (0x96 + (TargetCount * 0x24)) + 0x1B, 0x11); -- Which Skill was used? -- was 0xD5 location. First Action only
        local ActMessage = ashita.bits.unpack_be(e.data:totable(), (0x96 + (TargetCount * 0x24)) + 0x1B + 0x11, 0x0A); -- The message from the list -- was 0xD5 + 0x11 location
        local TargetSID = ashita.bits.unpack_be(e.data:totable(), 0x96, 0x20); -- What's in parenethesis above gets us only to actions. need to go further from there.
        local Targets = T{};
        if (TempPlayer == nil) then -- NIL CHECK
            return;
        end

        local Pet = GetEntity(TempPlayer.PetTargetIndex); -- has to be down here in case TempPlayer goes nil for zoning. Happened.
        -------- 
        if (ServerID ~= 0 and ServerID == TempPlayer.ServerId) then -- Handling things we do. ONLY THE PLAYER
            local player = AshitaCore:GetMemoryManager():GetPlayer(); -- This is a Player structure. Not the same as Entity structure. Leave this.
            if (player == nil) then
                return;
            end
             -- ServerID for the target of this action.
            if (player:GetMainJob() == 14 and Pet ~= nil and Action == 6 and Pet.ServerId ~= nil and 
                Pet.ServerId == TargetSID and ActParam == 0 and ActMessage == 100) then 
                    SteadyW = true;
            end
        end

        if (ServerID ~= 0 and ServerID == GotMob) then -- GotMob is the one I am targetting, the only one we care about watching. All this for tracking what mob is doing.
            if (TargetSID > 0 --[[and Action == 1]]) then    ------ Track all actions, not just attacking. First target In Target list is the primary. So we keep TargetSID.
                local MobTargetTarget = GetEntityByServerId(TargetSID); -- At least here it loops less than every frame rendering of TargetsTarget bar.
                if (MobTargetTarget ~= nil and MobTargetTarget.TargetIndex ~= nil and MobTargetTarget.SpawnFlags ~= 16) then 
                    TargetsTarget = MobTargetTarget.TargetIndex; -- TargetsTarget is now using TargetIndex, not ServerID.
                end
            end
            -- Try to find Ability ID of the Monster.
            if (Action == 7 or Action == 8) then -- Start of action, what action done down below. Message 0 is that action was interrupted.
                if (ActMessage == 0) then
                    Interrupt = true;
                else
                    Interrupt = false;
                end
            else
                for _, value in pairs(T{3, 4, 5, 6, 11, 13, 14, 15}) do -- ending a cast? -- DO NOT PUT ANY PET RELATED THINGS HERE!
                    if (value == Action) then
                        ActParam = ashita.bits.unpack_be(e.data:totable(), 0x56, 0x10); -- This is the parameter of the base in that chart.
                        break;
                    end
                end
            end

            GotMobAct = Action; -- Turn locals into globals.
            GotMobActParam = ActParam;
        end

        if (Pet ~= nil and ServerID ~= 0) then -- We have a valid Pet. Leave this as the first pet conditional.
            if (ServerID == Pet.ServerId) then -- Pet is the Actor.
                PetTargetsID = TargetSID;
            end  -- Leave both here in case the pet is doing something to itself, it would be both the Actor and Target?

            for x = 1, TargetCount do -- Hopefully catch the pet in an AoE?
                Targets[x] = ashita.bits.unpack_be(e.data:totable(), 0x96 + ((x - 1) * 0x24), 0x20);  --  0x96 + ((x - 1) * 0x24)
            end

            for _, value in pairs(Targets) do
                if (value == Pet.ServerId --[[TEST-->]]--[[or value == TempPlayer.ServerId]]) then -- Pet is the Target. -- Can always add players SID to test this.
                    if (ActMessage ~= nil and  (ActMessage == 84 or ActMessage == 29)) then
                    PetDebuffs = 4;
                    elseif (ActMessage ~= nil and ActMessage > 1) then -- 1 is normal attack, we don't need to scan through that. -- Applying debuffs. 141 looks ok if /lb is line break.
                        for _, value in pairs(T{82, 127, 141, 203, 205, 230, 236, 237, 242, 243, 270, 267, 268, 271, 277, 278, 279, 280, 320, 375, 421, 441, 602, 645}) do 
                            if (value == ActMessage) then   -- we will need another for loop so we only make PetDebuffs the debillitating ones we care about.
                                if (ActParam == 37) then
                                    SteadyW = true;
                                    break;
                                end
                                                 -- This is in Order of Importance from 0x29 check above.
                                for _, value in pairs(T{7, 2, 19, 193, 6, 4, 566, 22, 16, 21, 28, 11  --[[TESTS]],3 ,5, 136, 540, 138, 102 }) do -- Same debuffs as Pet Window.
                                    if (value == PetDebuffs) then -- if it cycles to where PetDebuffs is, then ActParam must be lower tier debuff. Skip.
                                        break;
                                    elseif (value == ActParam) then
                                        PetDebuffs = ActParam; -- local into global.
                                        break; -- This breaks the for loop for value == ActParam if we find one.
                                    end
                                end
                            end
                        end

                        for _, value in pairs(T{64, 83, 204, 206, 350, 531}) do -- Removing debuffs 
                            if (value == ActMessage) then  -- Need another for value pairs table check to see if it's a debuff we would even track.
                                if (ActParam == 37) then
                                    SteadyW = false;
                                    break;
                                end

                                for _, value in pairs(T{7, 2, 19, 193, 6, 4, 566, 22, 16, 21, 28, 11 --[[TESTS]],3 ,5, 136, 540, 138, 102    }) do -- Same debuffs as Pet Window. 
                                    if (value == ActParam and ActParam == PetDebuffs) then -- It could only have gotten here if we have cycled before the current PetDebuffs.
                                        PetDebuffs = 0; -- local into global. -- Removed 10 (stun) above as we caught one and it never went away.
                                        break; -- This breaks the for loop for value == ActParam if we find one.
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        --------
        return;
    end
  ------   

  -- Pet's Target Stuff
    if (e.id == 0x0068) then
        local player = GetPlayerEntity();
        if (player == nil) then
            PetTargetsID = 0; -- Global
            return;
        end

        local owner = struct.unpack('I', e.data, 0x08 + 0x01);
        if (owner == player.ServerId) then
            PetTargetsID = struct.unpack('I', e.data, 0x14 + 0x01);
        end

        return;
    end
  ------
  -- Target's Target Stuff. Not sure if a lot of these conditions can ever be true. It's just there were a lot of weird problems that needed fixing and now it is too
    if (e.id == 0x0058 --[[Assist Response?]]) then -- hard to tell what is actually needed and what isn't, so I guess they all stay. Haha. Try and clean it later. Maybe.
        if(ascii.settings.options.moninfo == true and ascii.settings.options.aggro == true) then
            local ServerID = struct.unpack('I', e.data, 0x08 + 0x01);
            local AssistTar = GetEntityByServerId(ServerID); -- This is our new target if the packet gets passed. Stop trying to find ways to not use ServerID. Won't work.
            Assisting = 0; -- Assisting is only meant to block new trackings.
            if (AssistTar == nil) then -- I guess our target or someone else is dead. Can't have it trying to target then.
                e.blocked = true;
                return;
            end

            if (AssistTar.SpawnFlags ~= 16) then  
                TargetsTarget = AssistTar.TargetIndex; -- This is blocking trying to target anything that is not a monster.
                e.blocked = true; -- Therefore, do we just pass everything else? That would be any new targets that are living monsters.
                return; 
            end 
        end -- End options check.
    end -- End 0x58 check.
end); 

ashita.events.register('packet_out', 'packet_out_cb', function (e)
    if (e.id == 0x1A) then
       local ActType = struct.unpack('H', e.data_modified, 0x0A + 0x01); 
        if (ActType == 0x0F --[[Switch Target]]) then 
            local ChangeTar = struct.unpack('H', e.data_modified, 0x08 + 0x01); 
            if (ChangeTar == MainIndex) then 
                e.blocked = true; 
                return;
            end

            if (Assisting > 0 and GotMob > 0) then 
                Assisting = 0;
                e.blocked = true;
                return;
            end
        end
    end

    return;
end);

ashita.events.register('text_in', 'chatblock_HandleText', function (e) -- Thanks, Thorny
    for _,match in ipairs(matchStrings) do
        if (string.match(e.message, match)) then
            e.blocked = true;
        end
    end
end);
---------------------------------------------------------------------       FIN