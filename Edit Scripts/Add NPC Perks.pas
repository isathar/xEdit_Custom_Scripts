{*
  SSE: Add NPC Perks.pas
  
  Adds Perk + alchemy/Enchantment skill boosts to selected NPCs
*}
unit NPCPerksPatcher;

const
  sPatchAuthor = 'NPCPerks Patcher';
  sPatchDescr = 'NPC Perks dynamic patch';


var
  patch: IInterface;
  perkToAdd, perkToAdd2, rankToAdd: string;
  verbose: boolean;


// ***************************************************
// add a specific perk to an NPC
function AddNPCPerk(r: IInterface; addperk: string): integer;
var
  perklist, perk: IInterface;
  i: integer;
  npcNeedsPerk: boolean;
  perkName, recname: string;
begin
  npcNeedsPerk := true;
  perklist := ElementByPath(r, 'Perks');
  recname := Name(r);
  
  // if no perk list, create one, and set perk 0.
  // cannot use list add code here because there is already
  // a null entry in the new list, which must be set.
  if not Assigned(perklist) then begin
    perklist := Add(r, 'Perks', False);
    perk := ElementByIndex(perklist, 0);
    SetElementEditValues(perk, 'Perk', addperk);
    SetElementEditValues(perk, 'Rank', rankToAdd);
    Exit;
  end;
  
  for i := 0 to ElementCount(perklist) - 1 do begin
    perk := ElementByIndex(perklist, i);
    perkName := GetElementEditValues( perk, 'Perk');
    if perkName = addperk then begin
	    if verbose then
        AddMessage( '   *** ' + recname + ' already has perk ' + perkName);
      npcNeedsPerk := false;
    end
  end;
  
  if npcNeedsPerk then begin
    if verbose then
      AddMessage( '  +++ adding perk ' + addperk + ' to ' + recname);
    perk := ElementAssign(perklist, HighInteger, nil, false);
    SetElementEditValues(perk, 'Perk', addperk);
    SetElementEditValues(perk, 'Rank', rankToAdd);
  end;
  
  Result := 0;
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
begin
  perkToAdd := 'AlchemySkillBoosts [PERK:000A725C]';
  perkToAdd2 := 'PerkSkillBoosts "Skill Boosts" [PERK:000CF788]';
  rankToAdd := '1';
  verbose := true;
end;

// ***************************************************
// process
function Process(e: IInterface): integer;
var
  r: IInterface;
begin
  // apply only to NPCs
  if Signature(e) <> 'NPC_' then
    Exit;
  
  // patch once for each record
  if not IsMaster(e) then
    Exit;
  
  // patch the last overriding record from the current load order
  e := WinningOverride(e);
  
  // do av checks
  // tbd
  
  // create new patch plugin
  if not Assigned(patch) then begin
    patch := CreatePatchPlugin;
    // check if user canceled
    if not Assigned(patch) then begin
      Finalize;
      Result := 1;
      Exit;
    end;
  end;
  
  // init patch plugin
  r := CopyToPatch(e, False);
  if not Assigned(r) then
    Exit;
  
  // modify patch record
  AddNPCPerk(r, perkToAdd);
  AddNPCPerk(r, perkToAdd2);
  
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
end;

end.