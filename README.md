# ASCII-Joy
UI windows for FFXI

****** Credit and Thanks goes out to: 
****** Atom0s for his guidance and use of his various addons as examples and inspiration...
****** Vicrelant for the use of the monster data tables in his addon.

* OVERVIEW *
    Relive the glory days before there were graphics, when MUDs were still cool, all while having a somewhat functional UI!
	(Best used at 1920x1080 resolution, but maybe something else may work for you.)

* FEATURES *
    Party Window will monitor your party member's HP, MP, TP with HP changing colors depending on how injured they are.
	TP will change color when it gets over 1000. MP will get brighter when the MP gauge is full. The name of the person
	in your party you may be trying to cast on will also change color. The Leader of the Party is also noted.

    Monster Window tracks the HP percentage, mob class, aggro types, weaknesses, and your current sub-target.

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
  /ASCII-Joy party     Toggles the Party Window on and off.
	/ASCII-Joy solo      Toggles seeing yourself in Party Window while solo.
	/ASCII-Joy player    Toggles Player Window of your own HP Bar, TP, Mana, Pet info. (if you have one)
	/ASCII-Joy zilda     Toggles Health bar from ASCII to Hearts from "The Myth of Zilda(tm)"!
	/ASCII-Joy monster   Toggles the Monster Health/Sub-Target Window
	/ASCII-Joy mon-pos   Toggles Monster info Above/Below their Health Bar.
	/ASCII-Joy mon-info  Toggles Aggro/Weak info. Not live info, pulled from file.
	/ASCII-Joy mon-sub   Toggles Target/Sub Name Above/Below the Monster Health Bar.
	                     If you have no monster targetted, this is the name of who/what
	                     you have targetted. If you do have a monster targetted, this is
	                     who/what you are trying to use a spell/skill/item/whatever on.
	
	To move the Party Window, Shift-LeftClick-Drag the line with Zone Name.
	To move the Monster Window, Shift-LeftClick-Drag the line with the Monster Health.
	To move the Player Window, Shift-LeftClick-Drag the line with your own Health.
	If you have Life Hearts from "The Myth of Zilda(tm)", Shift-LeftClick-Drag the word "LIFE".

	You must use "/ASCII-Joy save", change zones, or unload/load the addon to save positions.


* SETTINGS DESCRIPTIONS (Not very informative) *
    party - Do you want to see the Party Window, including what zone you are in?

    solo - Do you want the Party Window to disappear when you are solo? (true makes it disappear). [requires party to be true.]
		- You may still be considered in the party by the game if everyone leaves and you don't, so may still see it. Weird game.
		- The Zone Name will still remain.

    player - Do you want to see your own Health, TP, Mana, and Pet Info? (if should you have one)

    zilda - See some hearts from some other game to represent your health. (Thanks to Solentus for this idea.)

    monster - Do you want to see the Monster Health Bar Window?

    mon-info - Do you want to see additional information about the monster (weaknesses, aggro)? [requires monster to be true.]
 	Not live info, pulled from a file. Can't verify 100% it's entirely correct, but seems ok. 
 
    mon-pos - Do you want to see the Monster Info above the Monster Health Bar?  [requires monster to be true.]

    mon-sub - Do you want the Target/Sub Name to be above the Monster Health Bar? (NPC's, players, etc.) [requires monster to be true.]
  
***
*** Thank you for taking the time to try this addon. Hope you loot lots of stuffs with it.
***
*** --- Drusciliana
***   

