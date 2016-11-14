WIP xEdit scripts for skyrim/Skyrim SE.

I will be updating and adding more scripts and better instructions over time. 
- For now, this is mostly wip stuff I'm testing while learning the process by trying to create something like Automatic Perks/Spells/Potion Distribution.


SkyrimSE - NPC Perks Patcher.pas
- Distributes all loaded perks to all loaded NPCs based on their skill levels and character classes. Filter configuration files are included in NPCPerks/config.
- Ordinator is not currently supported since it changes editor IDs for vanilla perks.
- Tested with the base game, DLCs, Immersive Patrols, and the Populated series.
- The script skips all perks marked non-playable or hidden for now.
- It still needs some cleaning and optimization, but it's working so far.
  
  
  
Usage:
-  Load any plugins you want to process NPCs from (including official files), run the script (Apply Script).
