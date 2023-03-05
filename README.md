************************ ASCII-Joy v1.5.0  rel. Feb. 23, 2023          
****** Credit and Thanks goes out to:           
****** Atom0s for his guidance and use of his various addons as examples and inspiration...           
****** Solentus and Dash for their ideas and explanations of the game.            
****** Almavivaconte, and Thorny for answering any questions that I had.           
****** Vicrelant for the use of the monster data tables from his addon.            

* 1.5.1 Changes:
- Added limit points to XP bar, will toggle between the two.
- Think I fixed Alliance Windows (said that before though).
- Changed color for Monster health that isn't claimed.
- Still working on catching Pet debuffs (getting a little better).
- Little more optimization, maybe get a frame or two back.

* 1.5.0 Comparisons to 1.4.0:
     - Added ability to track who the mob has aggro on in the Monster Window (small delay on it) (need "mon-info" and "aggro" toggled).
     - Added ability to watch if the targetting monster is casting or using a skiil (need "mon-info" toggled).
     - Added ability to track a mob your party has claimed in the Party Window (for healer types, mostly works) (need "claim" toggled).
     - Added ability to monitor "some" debillitating status effects on pets. Maybe. (W.I.P.)
     - More efficient Sub-Target checking/selection in Party Window. (Thanks, Thorny!)
     - Various Alliance Window issues were fixed.
     - Various general fixes and optimizations.

- Known Issues * - Party Members set to Anonymous show they are far away when dead.    - Level Sync and Raise Sickness wearing off taking a while to accurately show max hp again. Odd.
     - Sometimes the Alliance Windows stay after the Alliance has disbanded. Odd, again. If this poses an issue for you, disable 
       the Alliance Windows with "/ASCII-Joy alliance".

- POSSIBLE COMPATIBILITY ISSUES WITH THE ADDON "SimpleLog", since "SimpleLog" blocks some packets, certain things may not work. 
    The only fix for this that I've found is that in the default.txt in the scripts folder, make sure you load ASCII-Joy 
    BEFORE you load "Simplelog". This issue only affects Pet functionality it would seem. Maybe tracking mob actions. 
    This issue doesn't happen for everyone. More Oddness.

* OVERVIEW *
    Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!
	(Best used at 1920x1080 resolution, but maybe something else may work for you.) 
        -- MOVING THINGS ACTS FUNNY IN WINDOWED MODE, PLEASE USE FULLSCREEN OR BORDERLESS WINDOW.
        -- You often have to click somewhere outside of the intended line to move things. 

* FEATURES *
    Party Window will monitor your party member's HP, MP, TP with HP changing colors depending on how injured they are.
	TP will change color when it gets over 1000. MP will get brighter when the MP gauge is full. The name of the person
	in your party you may be trying to cast on will also change color. The Leader of the Party is also noted. Also now
        tells you the name of the zone someone is in if they aren't in your zone. Now also tracks Alliance Members. This is
        toggleable due to the fact it is extremely cumbersome and may cause a dramatic FPS loss for some. Sorry. Caveat Empor.
        Can also show the Party's claimed Battle Target if you aren't currently targetting it (Dash's idea). 

    Monster Window tracks the HP percentage, mob class, aggro types, weaknesses, and your current sub-target.
        -- Now incorporates the "checker" addon, showing live data of Monster Level, Defense, Evasion modifiers 
		(after small delay as to not flood the server). Doesn't work on Notorious Monsters (by design).
	-- If you currently use the "checker" addon, you can disable/unload it to stop chat line spam as this triggers it.
        -- Now tracks if the targetted monster is casting or using a spell with "mon-info" option enabled.
        -- Now can track who the targetted monster has aggro on with "aggro" options enabled. 
        -- Now can track what the monster is doing, so you can try and interrupt and not have to stare at chat spam.

    Self Window monitors your own HP, MP, TP with HP changing colors depending how injured you are. If you have a pet, then
	it will also monitor the Pet's HP, MP, TP with both TP gauges changing colors over 1000. Now also tracks the pet's
        target if it differs from your own. Now can also track certain debuffs on the pet. Sometimes.

    Can have your Health Bar and TP look like Icons from the ancient game "The Myth of Zilda(tm)"!

    Job Helpers! Certain jobs have little quirks added for aiding: (I don't play a lot of jobs. If you have ideas, let me know!)
        -- Thief (Main or Sub): there is a Sneak Attack helper that will change the color of the Monster's Health background
           if you're within the rear cone of the monster, facing it's rear, and within 3.5 yalms.
        -- Dragoon: Will change the background of the Wyvern's health when Steady Wing is active in the Pet Window. Also (sometimes)
           it will try and monitor disabling status effects (sleep, paralyze, petrify, etc.).
          

    (All defaults are in silly places, please feel free to play around and move them. Instructions below.)

* CHAT WINDOW CONFIG *
    Type in the chat window "/ASCII-Joy help" (without quotes and sadly, case sensitive) to bring up the help window.
	Will automatically save window positions when you zone, in case you forget to save.	
	Toggling any option will automatically save.

    ADVISORY : Every enabled option may decrease performance. All calculations are done in one game frame render. YMMV.

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
        /ASCII-Joy claim     Toggles showing a claimed monster you aren't targetting under the Party Window. (Thanks, Dash!)
        /ASCII-Joy alliance  Toggles Alliance Windows (WILL COST SOME FPS WHEN FULL, FOR SURE).
        /ASCII-Joy solo      Toggles seeing yourself in Party Window while solo (Zone Name remains).
        /ASCII-Joy player    Toggles Player Window of your own HP Bar, TP, Mana, Pet info (if you have one).
        /ASCII-Joy zilda     Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"! (Thanks, Solentus!)
        /ASCII-Joy grow      Toggles if you always see 12 Heart Containers, or get more as you level up (up to 12 Max).
        /ASCII-Joy fairy     Toggles whether the Fairy will grace you with her presence, depending on your point of view.
        /ASCII-Joy monster   Toggles the Monster Health/Sub-Target Window
        /ASCII-Joy mon-pos   Toggles Monster info Above/Below their Health Bar.
        /ASCII-Joy mon-info  Toggles Aggro/Weak info. Not live info, pulled from file. Also tracks Monster's Target.
        /ASCII-Joy aggro     Toggles seeing who the Monster is trying to kill. (/assist may act weird, see BELOW)
        /ASCII-Joy tarplay   Toggles ability to see other Players Health if targetting them in the Monster Health Window.
        
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
*** Questions, Comments, Suggestions are always welcome.
*** --- Drusciliana (D. on Discord, #2154 if that helps).
***   

	
