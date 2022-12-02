************************ ASCII-Joy v1.1.0  rel. Nov. 28, 2022
****** Credit and Thanks goes out to: 
****** Atom0s for his guidance and use of his various addons as examples and inspiration...
****** Vicrelant for the use of the monster data tables from his addon.

* OVERVIEW *
    Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!
	(Best used at 1920x1080 resolution, but maybe something else may work for you.)

* FEATURES *
    Party Window will monitor your party member's HP, MP, TP with HP changing colors depending on how injured they are.
	TP will change color when it gets over 1000. MP will get brighter when the MP gauge is full. The name of the person
	in your party you may be trying to cast on will also change color. The Leader of the Party is also noted. Also now
        tells you the name of the zone someone is in if they aren't in your zone.

    Monster Window tracks the HP percentage, mob class, aggro types, weaknesses, and your current sub-target.
        -- Now incorporates the "checker" addon, showing live data of Monster Level, Defense, Evasion modifiers 
		(after small delay as to not flood the server). Doesn't work on Notorious Monsters (by design).
	-- If you currently use the "checker" addon, you can disable/unload it to stop chat line spam as this triggers it.
        -- Now has a feature that if you are a Thief (Main or Sub), there is a Sneak Attack helper that will change the color
                of the monster's health background if you're within the rear cone of the monster, facing it's rear, and 
                within 3 yalms.

    Self Window monitors your own HP, MP, TP with HP changing colors depending how injured you are. If you have a pet, then
	it will also monitor the Pet's HP, MP, TP with both TP gauges changing colors over 1000.

    Can have your Health Bar look like Hearts from the ancient game "The Myth of Zilda(tm)"!

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
        /ASCII-Joy size      Toggles through 3 different sizes fonts (10, 12, 14).
        /ASCII-Joy offset #  Pixel-shifts the line-spacing (+/-)# pixels (Use if spaces between lines looks funny).
        /ASCII-Joy party     Toggles the Party Window on and off.
        /ASCII-Joy solo      Toggles seeing yourself in Party Window while solo (Zone Name remains).
        /ASCII-Joy player    Toggles Player Window of your own HP Bar, TP, Mana, Pet info. (if you have one)
        /ASCII-Joy zilda     Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!
        /ASCII-Joy monster   Toggles the Monster Health/Sub-Target Window
        /ASCII-Joy mon-pos   Toggles Monster info Above/Below their Health Bar.
        /ASCII-Joy mon-info  Toggles Aggro/Weak info. Not live info, pulled from file.
        /ASCII-Joy mon-sub   Toggles Target/Sub Name Above/Below the Monster Health Bar.
                             If you have no monster targetted, this is the name of who/what
                             you have targetted. If you do have a monster targetted, this is
                             who/what you are trying to use a spell/skill/item/whatever on.
	
        To move the Cast Bar, Shift-LeftClick-Drag the bar around while casting (sorry, only way to see it).
        To move the Party Window, Shift-LeftClick-Drag the line with Zone Name.
        To move the Monster Window, Shift-LeftClick-Drag the line with the Monster Health.
        To move the Player Window, Shift-LeftClick-Drag the line with your own Health.
        If you have Life Hearts from "The Myth of Zilda(tm)", Shift-LeftClick-Drag the word "LIFE".
        You must use "/ASCII-Joy save", change zones, or unload/load the addon to save Window positions.

***
*** Thank you for taking the time to try this addon. Hope you loot lots of stuffs with it.
***
*** --- Drusciliana
***   

	