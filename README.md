************************ ASCII-Joy v1.4.1  rel. Jan. 16, 2023     
****** Credit and Thanks goes out to:      
****** Atom0s for his guidance and use of his various addons as examples and inspiration...      
****** Vicrelant for the use of the monster data tables from his addon.     

* 1.4.2 Fixes - Another Alliance Window Fix, also more efficient Sub-Target checking in-party.
* 1.4.1 Fixes - Various Alliance Window issues.
* 1.4.0 Additions/Changes/Fixes compared to 1.3.0:     
  - Added Alliance Windows (Toggleable, read warning). Pet's target tracked if it differs than your own. 
  - Fixed issue with losing combat animations (very odd) when using a pet. Lightened pet HP bar.
  - Target/Sub-Target Name (the green/purple italic name), is now movable (by popular demand).
  - Option Toggle "order" changes Party Window sorting (Ascending/Descending).
  - Option Toggle "tarplay" lets you see other Players' Health in the Monster Health Window.
  - Added Mob Index number to Monster Info Window (by popular demand).
  
* Known Issues * - Party Members set to Anonymous make their stats look weird, or dead, or faraway sometimes.
  - Raise Sickness wearing off taking a while to accurately show max hp again. Odd.

* OVERVIEW *
    Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!
	(Best used at 1920x1080 resolution, but maybe something else may work for you.) 
	
        -- MOVING THINGS ACTS FUNNY IN WINDOW, PLEASE USE FULLSCREEN OR BORDERLESS WINDOW --
        -- You often have to click somewhere outside of the intended line to move things. --

* FEATURES *
    Party Window will monitor your party member's HP, MP, TP with HP changing colors depending on how injured they are.
	TP will change color when it gets over 1000. MP will get brighter when the MP gauge is full. The name of the person
	in your party you may be trying to cast on will also change color. The Leader of the Party is also noted. Also now
        tells you the name of the zone someone is in if they aren't in your zone. Now also tracks Alliance Members. This is
        toggleable due to the fact it is extremely cumbersome and may cause a dramatic FPS loss for some. Sorry. Caveat Empor.

    Monster Window tracks the HP percentage, mob class, aggro types, weaknesses, and your current sub-target.     
        -- Now incorporates the "checker" addon, showing live data of Monster Level, Defense, Evasion modifiers     
		(after small delay as to not flood the server). Doesn't work on Notorious Monsters (by design).     
	-- If you currently use the "checker" addon, you can disable/unload it to stop chat line spam as this triggers it.     
        -- Now has a feature that if you are a Thief (Main or Sub), there is a Sneak Attack helper that will change the color of the monster's health background if you're within the rear cone of the monster, facing it's rear, and      
                within 3 yalms.     

    Self Window monitors your own HP, MP, TP with HP changing colors depending how injured you are. If you have a pet, then
	it will also monitor the Pet's HP, MP, TP with both TP gauges changing colors over 1000. Now also tracks the pet's
        target if it differs from your own.

    Can have your Health Bar and TP look like Icons from the ancient game "The Myth of Zilda(tm)"!

    (All defaults are in silly places, please feel free to play around and move them. Instructions below.)

* CHAT WINDOW CONFIG *
    Type in the chat window "/ASCII-Joy" or "/ASCII-Joy help" (sadly, case sensitive) to bring up the help window.
	Will automatically save window positions when you zone, in case you forget to save.	
	Toggling any option will automatically save.

Here's some Syntax:

        /ASCII-Joy help      Displays this help information.
        /ASCII-Joy save      Saves the positions of the windows after you move them.
        /ASCII-Joy back      Toggles Window Backgrounds. Rotates through (off / light / dark).
        /ASCII-Joy font      Toggles Window fonts between Consolas and Courier New.
        /ASCII-Joy size      Toggles through 3 different size fonts (10, 12, 14).
        /ASCII-Joy offset #  Pixel-shifts the line-spacing (+/-)# pixels (Use if spaces between lines look funny).
        /ASCII-Joy cast      Toggles the Cast Bar.
        /ASCII-Joy exp       Toggles the Experience Bar.
        /ASCII-Joy party     Toggles the Party Window on and off.
        /ASCII-Joy order     Toggles Party Window list sorting (Ascending/Descending).
        /ASCII-Joy alliance  Toggles Alliance Windows (WILL COST SOME FPS, FOR SURE).
        /ASCII-Joy solo      Toggles seeing yourself in Party Window while solo (Zone Name remains).
        /ASCII-Joy player    Toggles Player Window of your own HP Bar, TP, Mana, Pet info (if you have one).
        /ASCII-Joy zilda     Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!
        /ASCII-Joy grow      Toggles if you always see 12 Heart Containers, or get more as you level up (up to 12 Max).
        /ASCII-Joy fairy     Toggles whether the Fairy will grace you with her presence, depending on your point of view.
        /ASCII-Joy monster   Toggles the Monster Health/Sub-Target Window
        /ASCII-Joy mon-pos   Toggles Monster info Above/Below their Health Bar.
        /ASCII-Joy mon-info  Toggles Aggro/Weak info. Not live info, pulled from file.
        /ASCII-Joy tarplay   Toggles ability to see other Players Health in the Monster Health Window.	
	
        To move the Cast Bar, Shift-LeftClick-Drag the bar around while casting (sorry, only way to see it).
        To move the Experience Bar, Shift-LeftClick-Drag the Bar itself.
        To move the Party Window, Shift-LeftClick-Drag the line with Zone Name.
        To move the Monster Window, Shift-LeftClick-Drag the line with the Monster Health.
        To move the Target/Sub-Target Name, Shift-LeftClick-Drag the italicized Name.
        To move the Player Window, Shift-LeftClick-Drag the line with your own Health.
        If you have Life Hearts from "The Myth of Zilda(tm)", Shift-LeftClick-Drag the word "LIFE".
        You must use "/ASCII-Joy save", change zones, or unload/load the addon to save Window positions.

***
*** Thank you for taking the time to try this addon. Hope you loot lots of stuffs with it.
***
*** --- Drusciliana (D. on Discord, #2154 if that helps).
***   

	
