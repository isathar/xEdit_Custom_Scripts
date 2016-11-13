{*
			Skyrim SE: NPC Perks Patcher

  - Distributes perks to all loaded NPCs based on their skills and character class
  
*}
unit NPCPerksPatcher;

uses 'NPCPerks\utils\util_ConfigFiles';


const
  sPatchAuthor = 'NPCPerks Patcher';
  sPatchDescr = 'patch plugin for NPC Perks and Spells';
  sPerkRank1 = '1';
  // npc filter ini
  sINIFileFilters = 'Edit Scripts/NPCPerks/config/Filter_NPCs.ini';
  // perks filter ini
  sINIFilePerks = 'Edit Scripts/NPCPerks/config/Filter_Perks.ini';

var
  patch: IInterface;
  
  Filter_Races, Filter_NPCID_S, Filter_NPCID_C: TStringList;
  Perks_Names, Perks_Skills, Perks_Reqs: TStringList;


// ***************************************************
// filter/perk lists creation
function BuildLists: integer;
var
  i, j, k, l, tempskill: integer;
  f, p, q, r, s, t, u: IInterface;
  editstr, editstr2: string;
  include_skills, index_skills, configlist, perks_base, excludestart, excludeids: TStringList;
  bfound: boolean;
begin
  // **** NPC Filters
  q := GetConfigFile(sINIFileFilters);
  
  // build race list
  Filter_Races := GetSectionByHeader_SL(q, '[Include_Races]');
  // build edid lists
  Filter_NPCID_S := GetSectionByHeader_SL(q, '[ExcludeNPCs_IDs_Start]');
  Filter_NPCID_C := GetSectionByHeader_SL(q, '[ExcludeNPCs_IDs_Find]');
  
  
  Perks_Names := TStringList.Create;
  Perks_Skills := TStringList.Create;
  Perks_Reqs := TStringList.Create;
  
  configlist := GetConfigFile(sINIFilePerks);
  include_skills := GetSectionByHeader_SL(configlist, '[Include_Skills]');
  index_skills := GetSectionByHeader_SL(configlist, '[Index_Skills]');
  
  perks_base := GetSectionByHeader_SL(configlist, '[Base_Perks]');
  excludestart := GetSectionByHeader_SL(configlist, '[Exclude_Start]');
  excludeids := GetSectionByHeader_SL(configlist, '[Exclude_EDID]');
  
  bfound := false;
  
  // **** Perks
  
  // for each file
  for i := 0 to Pred(FileCount) do begin
    f := FileByIndex(i);
    p := GroupBySignature(f, 'PERK');
	//AddMessage('Processing ' + Name(f));
	
	// for each perk
    for j := 0 to Pred(ElementCount(p)) do begin
      r := ElementByIndex(p, j);
	  
	  // only process once
      if IsMaster(r) then begin
        r := WinningOverride(r);
		bfound := false;
		
		// don't include if Hidden or not Playable
		s := ElementByName(r, 'DATA - Data');
		t := ElementByName(s, 'Playable');
		l := GetEditValue(t);
		
		if l = 1 then begin
		  t := ElementByName(s, 'Hidden');
		  l := GetEditValue(t);
		  if l = 0 then begin
		    
			// EDID filters
			editstr := EditorID(r);
			
	        // edid start
	        for i := 0 to Pred(excludestart.Count) do begin
	          editstr2 := excludestart[i];
	          l := pos(editstr2,editstr);
	          if l = 1 then begin
		        bfound := true;
	  	        break;
	          end;
  	        end;
			// edid match
			if not bFound then begin
			  for i := 0 to Pred(excludeids.Count) do begin
	            editstr2 := excludeids[i];
	            if editstr2 = editstr then begin
		          bfound := true;
	  	          break;
	            end;
  	          end;
			end;
			
			if not bFound then begin
			  // check skill conditions
			  s := ElementByName(r, 'Conditions');
			  if ElementCount(s) > 0 then begin
				for k := 0 to Pred(ElementCount(s)) do begin
				  t := ElementByIndex(s, k);
				  u := ElementByPath(t, 'CTDA\Function');
				  editstr := GetEditValue(u);
				  
				  // check if a skill condition exists
				  if editstr = 'GetBaseActorValue' then begin
				    u := ElementByPath(t, 'CTDA\Comparison Value - Float');
				    tempskill := GetEditValue(u);
					editstr2 := tempskill;
					u := ElementByPath(t, 'CTDA\Actor Value');
					
					editstr := GetEditValue(u);
					bfound := true;
					
					// compare against included skills
					l := include_skills.IndexOf(editstr);
					if l > -1 then begin
					  // add to skill name + requirement lists
					  Perks_Names.Add(Name(r));
					  editstr := index_skills[l];
					  Perks_Skills.Add(editstr);
					  Perks_Reqs.Add(tempskill);
					  //AddMessage('Passed (WC): ' + Name(r) + ' -- ' + editstr + ' -- ' + editstr2);
					end;
					break;
				  end;
				end;
			  end;
			  
			  // the perk has no skill conditions
			  if not bfound then begin
				editstr2 := EditorID(r);
				// check if the perk is a skill's novice level
				l := perks_base.IndexOf(editstr2);
				if l > -1 then begin
				  editstr := index_skills[l];
				  Perks_Names.Add(Name(r));
				  Perks_Skills.Add(editstr);
				  Perks_Reqs.Add('0');
				  bfound := true;
				  //AddMessage('Passed (Base): ' + Name(r) + ' -- ' + editstr + ' -- ' + '0.000000');
				end
				else begin
				  if not bfound then begin
				    // add if no conditions exist
				    Perks_Names.Add(Name(r));
				    Perks_Skills.Add('-1');
				    Perks_Reqs.Add('0');
				    bfound := true;
				    //AddMessage('Passed (NC): ' + Name(r) + ', no conditions');
			      end;
				end;
			  end;
			  
			  if bfound then
			    AddRequiredElementMasters(r, patch, False);
			  
			end;
		  end;
		end;
	  end;
	end;
	
  end;
  
end;


// ****************************************************
// filters NPCs that will receive perks/spells
function CheckAgainstFilters(r: IInterface): boolean;
var
  racetmp, configtmp, flagstmp, flagtmp: IInterface;
  filestring, curedid, lccuredid, currace: string;
  i, checkint: integer;
  flagbool: int;
begin
  Result := false;
  
  //** Template Flags
  // ACBS - Configuration
  configtmp := ElementBySignature(r, 'ACBS');
  // Template Flags
  flagstmp := ElementByIndex(configtmp, 8);
  // Use Spell List
  // - determines if spells and perks can be added to NPC in editor
  flagtmp := ElementByName(flagstmp, 'Use Spell List');
  if Assigned(flagtmp) then begin
    flagbool := GetEditValue(flagtmp);
    Result := not (boolean(flagbool));
  end
  else
    Result := true;
  
  //** Race
  if Result then begin
    Result := false;
    racetmp := ElementBySignature(r, 'RNAM');
    currace := GetEditValue(racetmp);
    for i := 0 to Pred(Filter_Races.Count) do begin
      filestring := Filter_Races[i];
	  checkint := pos(filestring,currace);
	  if checkint = 1 then begin
	    Result := true;
	    break;
	  end;
    end;
	
	//** EDID
	if Result then begin
	  curedid := EditorID(r);
	  lccuredid := LowerCase(curedid);
	  
	  // filter by start
	  for i := 0 to Pred(Filter_NPCID_S.Count) do begin
	    filestring := Filter_NPCID_S[i];
	    checkint := pos(filestring,lccuredid);
	    if checkint = 1 then begin
		  Result := false;
	  	  break;
	    end;
  	  end;
	  
	  // filter by contents
	  if Result then begin
	    for i := 0 to Pred(Filter_NPCID_C.Count) do begin
	      filestring := Filter_NPCID_C[i];
	  	  checkint := pos(filestring,lccuredid);
		  if checkint > 0 then begin
		    Result := false;
		    break;
		  end;
	    end;
	  end;
	end;
  end;
  
end;


// ***************************************************
// add a list of perks to an NPC
function AddNPCPerks(r: IInterface; addperks: TStringList): integer;
var
  perk, perklist: IInterface;
  i, j, k: integer;
  npcNeedsPerk: boolean;
  perkName: string;
begin
  Result := 0;
  perklist := ElementByPath(r, 'Perks');
  j := 0;
  
  // create a perk list if none exists
  if not Assigned(perklist) then begin
    perklist := Add(r, 'Perks', False);
    perk := ElementByIndex(perklist, 0);
	j := 1;
	Result := 1;
    SetElementEditValues(perk, 'Perk', addperks[0]);
    SetElementEditValues(perk, 'Rank', sPerkRank1);
  end;
  
  for k := j to Pred(addperks.Count) do begin
    npcNeedsPerk := true;
	
    for i := 0 to ElementCount(perklist) - 1 do begin
      perk := ElementByIndex(perklist, i);
      perkName := GetElementEditValues(perk, 'Perk');
      if perkName = addperks[k] then
        npcNeedsPerk := false;
    end;
    
    if npcNeedsPerk then begin
      perk := ElementAssign(perklist, HighInteger, nil, false);
      SetElementEditValues(perk, 'Perk', addperks[k]);
      SetElementEditValues(perk, 'Rank', sPerkRank1);
	  Inc(Result);
    end;
  end;
  
end;


// ***************************************************
//  returns a TStringList of available perks for the given skills and class
function GetValidPerksForNPC(skills: IInterface; classskills: IInterface) : TStringList;
var
  skill: IInterface;
  i, j, skillval, checkval, skillint: integer;
  skillname, filestring, skillstr: string;
begin
  Result := TStringList.Create;
  
  for j := 0 to Pred(Perks_Names.Count) do begin
    checkval := Perks_Skills[j];
	if checkval = -1 then
	  Result.Add(Perks_Names[j]);
  end;
  
  for i := 0 to Pred(ElementCount(skills)) do begin
    // check character class skills
    skill := ElementByIndex(classskills, i);
    skillval := GetEditValue(skill);
	if skillval > 0 then begin
	  for j := 0 to Pred(Perks_Names.Count) do begin
	    skillint := Perks_Skills[j];
		if skillint = i then begin
	      // check NPC skills
	      skill := ElementByIndex(skills, i);
	      skillname := Name(skill);
		  skillval := GetEditValue(skill);
	      checkval := Perks_Reqs[j];
		  if skillval >= checkval then begin
		    skillname := Perks_Names[j];
		    Result.Add(skillname);
		  end;
		end;
	  end;
	end;
  end;
end;


// ***************************************************
// process
function ProcessNPC(r: IInterface): boolean;
var
  s, skillstop, skills, perklist, npcclass, classvar, classdata, classskills, racetmp: IInterface;
  tempSL, tempAdd: TStringList;
  i: integer;
begin
  tempSL := TStringList.Create;
  Result := false;
  
    npcclass := ElementBySignature(r, 'CNAM');
    
    classvar := LinksTo(npcclass);
    classdata := ElementBySignature(classvar, 'DATA');
    classskills := ElementByName(classdata, 'Skill Weights');
    
    skillstop := ElementBySignature(r, 'DNAM');
    skills := ElementByIndex(skillstop, 0);
    
    tempAdd := GetValidPerksForNPC(skills, classskills);
    if tempAdd.Count > 0 then
      tempSL.AddStrings(tempAdd);
    
  
  // modify patch records
  if tempSL.Count > 0 then begin
    s := CopyToPatch(r, False);
	if not Assigned(s) then
  	    Exit;
    if AddNPCPerks(s, tempSL) > 0 then
	  Result := true;
  end;
  
end;


// ***************************************************
// create and initialize new patch plugin
function CreatePatchPlugin: IInterface;
var
  header: IInterface;
begin
  Result := AddNewFile;

  if not Assigned(Result) then
    Exit;
  
  // set plugin's author and description
  header := ElementByIndex(Result, 0);
  Add(header, 'CNAM', True);
  Add(header, 'SNAM', True);
  SetElementEditValues(header, 'CNAM', sPatchAuthor);
  SetElementEditValues(header, 'SNAM', sPatchDescr);
end;


// ***************************************************
// copy changed data to patch
function CopyToPatch(r: IInterface; AsNew: Boolean): IInterface;
var
  rec: IInterface;
begin
  try
    AddRequiredElementMasters(r, patch, AsNew);
    rec := wbCopyElementToFile(r, patch, AsNew, True);
    Result := rec;
  except
    AddMessage('Patching failed: ' + FullPath(r));
    if not AsNew then
      rec := WinningOverride(r);
    if GetFileName(rec) = GetFileName(patch) then
      Remove(rec);
  end;
end;


// ***************************************************
// init
function Initialize: integer;
var
  i, j, countEdited: integer;
  f, g, r: IInterface;
  editStr: string;
begin
  // create the patch plugin
  patch := CreatePatchPlugin;
  if not Assigned(patch) then
    Exit;
  
   // load ini files to stringlists
  BuildLists;
  
  countEdited := 0;
  
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
	if not SameText(GetFileName(f), GetFileName(patch)) then begin
      g := GroupBySignature(f, 'NPC_');
	  AddMessage('Processing ' + Name(f));
      for j := 0 to ElementCount(g) - 1 do begin
        r := ElementByIndex(g, j);
	    // patch once for each record
        if IsMaster(r) then begin
          // patch the last overriding record from the current load order
          r := WinningOverride(r);
		  // check NPC against filters
          if CheckAgainstFilters(r) then begin
   	        if ProcessNPC(r) then
		      Inc(countEdited);
	      end;
		end;
	  end;
    end;
  end;
  editStr := countEdited;
  AddMessage('Edited ' + editStr + ' NPCs ');
end;


// ***************************************************
// finalize
function Finalize: integer;
begin
  // sort masters in patch plugin
  if Assigned(patch) then begin
    CleanMasters(patch);
    SortMasters(patch);
  end;
  Filter_Races.Free;
  Filter_NPCID_S.Free;
  Filter_NPCID_C.Free;
  Perks_Names.Free;
  Perks_Reqs.Free;
end;

end.