{*
			Config File Utilites
  
  - tools for managing ini/text files using TStringLists
  - commented lines are removed (if marked by ;)
  - sections are read until the first blank line
  
*}
unit util_ConfigFiles;

//**********************************************************************
// ************************ Read Operations ****************************
//**********************************************************************


//======= Direct Interface

// *********************************************************************
// returns a full config file as a TStringList
function GetConfigFile(cfgfilename: string) : TStringList;
var
  tempSL: TStringList;
  i: integer;
  filestring: string;
  checkint: integer;
begin
   tempSL := TStringList.Create;
   Result := TStringList.Create;
  
  // load the file
  tempSL.LoadFromFile(cfgfilename);
  
  // filter out comments denoted by ; or # and build the list
  for i := 0 to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	checkint := pos(';',filestring);
	if checkint <> 1 then
	  Result.Add(filestring);
  end;
end;

// *********************************************************************
// returns a TStringList to use as an index for sections
function GetConfigSectionIndex(cfgfilename: string) : TStringList;
var
  tempSL: TStringList;
  i: integer;
  filestring: string;
  checkint: integer;
begin
   tempSL := TStringList.Create;
   Result := TStringList.Create;
  
  // load the file
  tempSL.LoadFromFile(cfgfilename);
  
  // filter out comments denoted by ; or # and build the list
  for i := 0 to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	checkint := pos('[',filestring);
	if checkint = 1 then
	    Result.Add(filestring);
  end;
end;

// *********************************************************************
// returns a section of a config file 
// - slower than GetSectionByHeader_SL
// - uses [] to mark headers and a blank line to mark the section's end
function ParseSectionFromFile(cfgfilename: string; headingtext: string) : TStringList;
var
  tempSL: TStringList;
  i, j: integer;
  filestring: string;
  checkint: integer;
begin
  tempSL := TStringList.Create;
  Result := TStringList.Create;
  
  // load the file
  tempSL.LoadFromFile(cfgfilename);
  // find the section heading
  j := tempSL.IndexOf(headingtext) + 1;
  
  for i := j to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	checkint := pos(';',filestring);
	// check for comment lines
	if checkint <> 1 then begin
	  // check for the end of the section
	  checkint := length(filestring);
	  if checkint = 0 then
  	    break
	  else
	    Result.Add(filestring);
	end;
  end;
end;

// *********************************************************************
// returns a setting's value from a config file as a string (bool only)
// - setting format: settingvalue=xx
function GetConfigSettingBool(cfgfilename: string; settingname: string) : boolean;
var
  tempSL: TStringList;
  i: integer;
  filestring: string;
  checkint: integer;
begin
  tempSL := TStringList.Create;
  Result := true;
  // load the file
  tempSL.LoadFromFile(cfgfilename);
  for i := 0 to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	checkint := pos(settingname,filestring);
	if checkint > 0 then begin
	  checkint := pos('=1',filestring);
	  if checkint > 0 then begin
  	    Result := true;
	    break;
	  end;
	end;
  end;
end;


//======= TStringList Interface

// *********************************************************************
// returns a section of a config file stored in a TStringList
// - uses [] to mark headers and a blank line to mark the section's end
function GetSectionByHeader_SL(tempSL: TStringList; headingtext: string) : TStringList;
var
  i, j: integer;
  filestring: string;
  checkint: integer;
begin
  Result := TStringList.Create;
  j := tempSL.IndexOf(headingtext) + 1;
  for i := j to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	// check for the end of the section
	checkint := length(filestring);
	if checkint = 0 then
  	  break
	else
	  Result.Add(filestring);
  end;
end;

// *********************************************************************
// returns a setting's value from a config file stored in a TStringList (bool only)
// - setting format: name=value
function GetConfigSettingBool(tempSL: TStringList; settingname: string) : boolean;
var
  i: integer;
  filestring: string;
  checkint: integer;
begin
  Result := false;
  for i := 0 to Pred(tempSL.Count) do begin
    filestring := tempSL[i];
	checkint := pos(settingname,filestring);
	if checkint > 0 then begin
	  checkint := pos('=1',filestring);
	  if checkint > 0 then begin
  	    Result := true;
	    break;
	  end;
	end;
  end;
  
end;


end.