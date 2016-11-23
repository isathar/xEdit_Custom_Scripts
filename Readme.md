WIP xEdit scripts for skyrim/Skyrim SE.

I will be updating and adding more scripts and better instructions over time. 
- For now, this is mostly wip stuff I'm testing while learning the process by trying to create something like Automatic Perks/Spells/Potion Distribution.


SkyrimSE - NPC Perks Patcher.pas
- Distributes all loaded perks to all loaded NPCs based on their skill levels and character classes. Filter configuration files are included in NPCPerks/config.
-- NPCs that are set to inherit their template's spell list are filtered out before name filters are applied, so only NPCs that will actually benefit from perks will get them.
-- Only humanoid races get perks by default. Additional races can be added to NPCPerks/config/Filter_NPCs.ini (under Include_Races) to distribute perks to animals or beasts, as well.
- Ordinator perks may work, but haven't been tested extensively.
- Tested with the base game, DLCs, Immersive Patrols, the Populated series, Warzones SSE (Civil Unrest and Assault Attack), and Alternate Start.
- The script skips all perks marked non-playable or hidden for now.
- It still needs some cleaning and optimization, but it's working so far.
  
  
  
Usage:
-  Load any plugins you want to process NPCs from (including official files), run the script (Apply Script).
