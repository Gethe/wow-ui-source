CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 14;
MAX_CLASSES_PER_RACE = 11;
NUM_CHAR_CUSTOMIZATIONS = 5;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;
NUM_PREVIEW_FRAMES = 14;
WORGEN_RACE_ID = 6;
PANDAREN_RACE_ID = 13;

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;
PAID_SERVICE_CHARACTER_ID = nil;
PAID_SERVICE_TYPE = nil;

PREVIEW_FRAME_HEIGHT = 130;
PREVIEW_FRAME_X_OFFSET = 19;
PREVIEW_FRAME_Y_OFFSET = -7;

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19, 0, 0, 0.2, 0.29, 0.33, 0.91},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05, 0.2, 0, 0, 0.90, 0.05, 0.07},
	["Player"] = {0.2, 0.5, 0.2, 0.05, 0.2, 0.05, 0.05, 0.2, 0.05, 1, 1, 1},
};
FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
};
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
	["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
	["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
	["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},
	
	["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
	["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},

	["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},  
	["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
	["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
	["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},
	
	["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},   
	["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0}, 
	["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0}, 
	["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0}, 

	["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0}, 

	["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75}, 

	["GOBLIN_MALE"]		= {0.625, 0.750, 0.25, 0.5},
	["GOBLIN_FEMALE"]	= {0.625, 0.750, 0.75, 1.0},

	["WORGEN_MALE"]		= {0.625, 0.750, 0, 0.25},
	["WORGEN_FEMALE"]	= {0.625, 0.750, 0.5, 0.75},
	
	["PANDAREN_MALE"]	= {0.750, 0.875, 0, 0.25},
	["PANDAREN_FEMALE"]	= {0.750, 0.875, 0.5, 0.75},
};
CLASS_ICON_TCOORDS = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]	= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]	= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]	= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]	= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]	= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]	= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, 0.49609375, 0.5, 0.75},
	["MONK"]	= {0.49609375, 0.7421875, 0.5, 0.75},
};
MODEL_CAMERA_CONFIG = {
	[2] = { 
		["Draenei"] = { tx = 0.191, ty = -0.015, tz = 2.302, cz = 2.160, distance = 1.116, light =  0.80 },
		["NightElf"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 0.830, light =  0.85 },
		["Scourge"] = { tx = 0.094, ty = -0.172, tz = 1.675, cz = 1.478, distance = 0.691, light =  0.80 },
		["Orc"] = { tx = 0.346, ty = -0.001, tz = 1.878, cz = 1.793, distance = 1.074, light =  0.80 },
		["Gnome"] = { tx = 0.051, ty = 0.015, tz = 0.845, cz = 0.821, distance = 0.821, light =  0.85 },
		["Dwarf"] = { tx = 0.037, ty = 0.009, tz = 1.298, cz = 1.265, distance = 0.839, light =  0.85 },
		["Tauren"] = { tx = 0.516, ty = -0.003, tz = 1.654, cz = 1.647, distance = 1.266, light =  0.80 },
		["Troll"] = { tx = 0.402, ty = 0.016, tz = 2.076, cz = 1.980, distance = 0.943, light =  0.75 },
		["Worgen"] = { tx = 0.473, ty = 0.012, tz = 1.972, cz = 1.570, distance = 1.423, light =  0.80 },
		["WorgenAlt"] = { tx = 0.055, ty = 0.006, tz = 1.863, cz = 1.749, distance = 0.714, light =  0.75 },
		["BloodElf"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 0.727, light =  0.80 },
		["Human"] = { tx = 0.055, ty = 0.006, tz = 1.863, cz = 1.749, distance = 0.714, light =  0.75 },
		["Pandaren"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
		["Goblin"] = { tx = 0.127, ty = -0.022, tz = 1.104, cz = 1.009, distance = 0.830, light =  0.80 },
	},
	[3] = {
		["Draenei"] = { tx = 0.155, ty = 0.009, tz = 2.177, cz = 1.971, distance = 0.734, light =  0.75 },
		["NightElf"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 0.682, light =  0.85 },
		["Scourge"] = { tx = 0.198, ty = 0.001, tz = 1.669, cz = 1.509, distance = 0.563, light =  0.75 },
		["Orc"] = { tx = -0.069, ty = -0.007, tz = 1.863, cz = 1.718, distance = 0.585, light =  0.75 },
		["Gnome"] = { tx = 0.031, ty = 0.009, tz = 0.787, cz = 0.693, distance = 0.726, light =  0.85 },
		["Dwarf"] = { tx = -0.060, ty = -0.010, tz = 1.326, cz = 1.343, distance = 0.720, light =  0.80 },
		["Tauren"] = { tx = 0.337, ty = -0.008, tz = 1.918, cz = 1.855, distance = 0.891, light =  0.75 },
		["Troll"] = { tx = 0.031, ty = -0.082, tz = 2.226, cz = 2.248, distance = 0.674, light =  0.75 },
		["Worgen"] = { tx = 0.067, ty = -0.044, tz = 2.227, cz = 2.013, distance = 1.178, light =  0.80 },
		["WorgenAlt"] = { tx = -0.044, ty = -0.015, tz = 1.755, cz = 1.689, distance = 0.612, light =  0.75 },
		["BloodElf"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 0.717, light =  0.80 },
		["Human"] = { tx = -0.044, ty = -0.015, tz = 1.755, cz = 1.689, distance = 0.612, light =  0.75 },
		["Pandaren"] = { tx = 0.122, ty = -0.002, tz = 1.999, cz = 1.925, distance = 1.065, light =  0.90 },
		["Goblin"] = { tx = -0.076, ty = 0.006, tz = 1.191, cz = 1.137, distance = 0.970, light =  0.80 },
	}
};

BANNER_DEFAULT_TEXTURE_COORDS = {0.109375, 0.890625, 0.201171875, 0.80078125};
BANNER_DEFAULT_SIZE = {200, 308};

CHAR_CUSTOMIZE_HAIR_COLOR = 4;

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
	self:RegisterEvent("GLUE_UPDATE_EXPANSION_LEVEL");

	self:SetSequence(0);
	self:SetCamera(0);

	CharacterCreate.numRaces = 0;
	CharacterCreate.selectedRace = 0;
	CharacterCreate.numClasses = 0;
	CharacterCreate.selectedClass = 0;
	CharacterCreate.selectedGender = 0;

	SetCharCustomizeFrame("CharacterCreate");

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharCreateCustomizationButton"..i].text:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"]);
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	if( IsBlizzCon() ) then
		CharCreateBackButton:Disable();
	end

	CharacterCreateFrame.state = "CLASSRACE";
	
	CharCreatePreviewFrame.previews = { };
end

function CharacterCreate_OnShow()
	for i=1, MAX_CLASSES_PER_RACE, 1 do
		local button = _G["CharCreateClassButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end
	for i=1, MAX_RACES, 1 do
		local button = _G["CharCreateRaceButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end

	if ( PAID_SERVICE_TYPE ) then
		CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
		CharacterCreateNameEdit:SetText( PaidChange_GetName() );
	else
		--randomly selects a combination
		ResetCharCustomize();
		CharacterCreateNameEdit:SetText("");
		CharCreateRandomizeButton:Show();
	end

	-- Pandarens doing paid faction change
	if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE and GetSelectedRace() == PANDAREN_RACE_ID ) then
		PandarenFactionButtons_Show();
	else
		PandarenFactionButtons_Hide();
	end
	
	CharacterCreateEnumerateRaces(GetAvailableRaces());
	SetCharacterRace(GetSelectedRace());
	
	CharacterCreateEnumerateClasses(GetAvailableClasses());
	local _,_,index = GetSelectedClass();
	SetCharacterClass(index);

	SetCharacterGender(GetSelectedSex())
	
	-- Hair customization stuff
	CharacterCreate_UpdateHairCustomization();

	SetCharacterCreateFacing(-15);
	
	-- setup customization
	CharacterChangeFixup();

	SetFaceCustomizeCamera(false);
	
	if( IsBlizzCon() ) then
		BLIZZCON_IS_A_GO = false;
		CharacterCreateAllianceLabel:Hide();
		CharacterCreateHordeLabel:Hide();
		CharacterCreateGender:Hide();
		CharCreateRandomizeButton:Hide();
		CharacterCreateRandomName:Hide();
		CharacterCreateGenderButtonMale:Hide();
		CharacterCreateGenderButtonFemale:Hide();
		CharacterCreateBanners:Hide();
		CharacterCreateOuterBorder1:Hide();
		CharacterCreateOuterBorder2:Hide();
		CharacterCreateOuterBorder3:Hide();
		CharacterCreateConfigurationBackground:Hide();

		CharCreateBlizzconFrame:Show();
		CharCreateBlizzconFrame2:Show();

		for i=1, MAX_RACES, 1 do
			_G["CharacterCreateRaceButton"..i]:Hide();
		end
		
		for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
			_G["CharacterCustomizationButtonFrame"..i]:Hide();
		end

--		CharacterCreateClassName:Hide();
--		CharacterCreateClassName:ClearAllPoints();
--		CharacterCreateClassName:SetPoint("BOTTOM", CharCreateBlizzconFrame, "BOTTOM", 0, 15);
--		CharacterCreateClassName:SetFontObject(GlueFontNormalGigantor);
		
		local previous = nil;
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			local button = _G["CharacterCreateClassButton"..i];
			if ( i == 2 or i == 6 or i == 9 or i == 11 ) then
				button:Hide();
			else
				button:SetSize(64,64);
				button:GetNormalTexture():SetSize(64,64);
				button:GetPushedTexture():SetSize(64,64);
				_G["CharacterCreateClassButton"..i.."BevelEdge"]:SetSize(64,64);
				_G["CharacterCreateClassButton"..i.."Shadow"]:SetSize(84,84);
				_G["CharacterCreateClassButton"..i.."DisableTexture"]:SetSize(60,60);
				button:ClearAllPoints();
				if ( i == 1 ) then
					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "BOTTOMLEFT", 70, 20);
--				elseif ( i == 5 ) then
--					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "TOP", 50, 30);
--				elseif ( i == 10 ) then
--					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "TOP", 0, 290);
				else
					button:SetPoint("BOTTOM", previous, "TOP", 0, 20)
				end
				previous = button;
			end
		end
	end
end

function CharacterCreate_OnHide()
	PAID_SERVICE_CHARACTER_ID = nil;
	PAID_SERVICE_TYPE = nil;
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		CharacterCreate_Back();
	end
	-- character previews will need to be redone if coming back to character create. One reason is all the memory used for
	-- tracking the frames (on the c side) will get released if the user returns to the login screen
	CharCreatePreviewFrame.rebuildPreviews = true;
end

function CharacterCreate_OnEvent(event, arg1, arg2, arg3)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		if ( arg1 == 0 ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(arg2);
		end
		CharacterCreateRandomName:Enable();
		CharCreateOkayButton:Enable();
		PlaySound("gsCharacterCreationLook");
	elseif ( event == "GLUE_UPDATE_EXPANSION_LEVEL" ) then
		-- Expansion level changed while online, so enable buttons as needed
		if ( CharacterCreateFrame:IsShown() ) then
			CharacterCreateEnumerateRaces(GetAvailableRaces());
			CharacterCreateEnumerateClasses(GetAvailableClasses());
		end
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing();
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate(self, elapsed)
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff);
		CharCreate_RotatePreviews();
	end
	CharacterCreateWhileMouseDown_Update(elapsed);
end

function CharacterCreateEnumerateRaces(...)
	CharacterCreate.numRaces = select("#", ...)/3;
	if ( CharacterCreate.numRaces > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		return;
	end
	local coords;
	local index = 1;
	local button;
	local gender;
	local selectedSex = GetSelectedSex();
	if ( selectedSex == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	for i=1, select("#", ...), 3 do
		local name = select(i, ...);
		coords = RACE_ICON_TCOORDS[strupper(select(i+1, ...).."_"..gender)];
		_G["CharCreateRaceButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateRaceButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateRaceButton"..index];
		if ( not button  ) then
			return;
		end
		if( not IsBlizzCon() ) then
			button:Show();
		end
		button.nameFrame.text:SetText(name);
		if ( select(i+2, ...) == 1 ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.name = name;
			button.tooltip = name;
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.name = name;
			local disabledReason = _G[strupper(select(i+1, ...).."_".."DISABLED")];
			if ( disabledReason ) then
				button.tooltip = name.."|n"..disabledReason;
			else
				button.tooltip = nil;
			end
		end
		index = index + 1;
	end
	for i=CharacterCreate.numRaces + 1, MAX_RACES, 1 do
		_G["CharCreateRaceButton"..i]:Hide();
	end
end

function CharacterCreateEnumerateClasses(...)
	CharacterCreate.numClasses = select("#", ...)/3;
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end
	local coords;
	local index = 1;
	local button;
	for i=1, select("#", ...), 3 do
		coords = CLASS_ICON_TCOORDS[strupper(select(i+1, ...))];
		_G["CharCreateClassButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateClassButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateClassButton"..index];
		button:Show();
		button.nameFrame.text:SetText(select(i, ...));
		if ( select(i+2, ...) == true ) then
			if (IsRaceClassValid(CharacterCreate.selectedRace, index)) then
				button:Enable();
				SetButtonDesaturated(button);
				button.tooltip = nil;
				_G["CharCreateClassButton"..index.."DisableTexture"]:Hide();
			else
				button:Disable();
				SetButtonDesaturated(button, 1);
				button.tooltip = CLASS_DISABLED;
				_G["CharCreateClassButton"..index.."DisableTexture"]:Show();
			end
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")];
			_G["CharCreateClassButton"..index.."DisableTexture"]:Show();
		end
		if( IsBlizzCon() ) then
			button.text:SetText(select(i, ...));
			button.text:Show();
		end
		index = index + 1;
	end
	for i=CharacterCreate.numClasses + 1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharCreateClassButton"..i]:Hide();
	end
end

function SetCharacterRace(id)
	if( IsBlizzCon() ) then
		id = 7;
	end

	CharacterCreate.selectedRace = id;
	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharCreateRaceButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end

	local name, faction = GetFactionForRace(CharacterCreate.selectedRace);

	-- during a paid service we have to set alliance/horde for neutral races
	-- hard-coded for Pandaren because of alliance/horde pseudo buttons
	local canProceed = true;
	if ( id == PANDAREN_RACE_ID and PAID_SERVICE_TYPE ) then
		local _, currentFaction = PaidChange_GetCurrentFaction();
		if ( PaidChange_GetCurrentRaceIndex() == PANDAREN_RACE_ID and PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
			-- this is an original pandaren staying or becoming selected
			-- check the pseudo-buttons
			faction = PandarenFactionButtons_GetSelectedFaction();
			if ( faction == currentFaction ) then
				canProceed = false;
			end
		else
			-- for faction change use the opposite faction of current character
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				if ( currentFaction == "Horde" ) then
					faction = "Alliance";
				elseif ( currentFaction == "Alliance" ) then
					faction = "Horde";
				end
			-- for race change and customization use the same faction as current character
			else
				faction = currentFaction;
			end
		end
	else
		PandarenFactionButtons_ClearSelection();
	end
	CharCreate_EnableNextButton(canProceed);

	-- Set background
	local backgroundFilename = GetCreateBackgroundModel(faction);
	SetBackgroundModel(CharacterCreate, backgroundFilename);

	-- Set backdrop colors based on faction
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	CharCreateRaceFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateClassFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreatePreviewFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrameBanner:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	CharCreateRaceInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateClassInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	
	-- race info
	local frame = CharCreateRaceInfoFrame;
	local race, fileString = GetNameForRace();
	frame.title:SetText(race);
	fileString = strupper(fileString);
	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local raceText = _G["RACE_INFO_"..fileString];
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	local abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	end
	CharCreateRaceInfoFrameScrollFrameScrollBar:SetValue(0);
	CharCreateRaceInfoFrame.scrollFrame.scrollChild.infoText:SetText(GetFlavorText("RACE_INFO_"..strupper(fileString), GetSelectedSex()).."|n|n");
	if ( abilityText and abilityText ~= "" ) then
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	else
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText("");
	end	

	-- Altered form
	if (HasAlteredForm()) then
		SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, 22, GetSelectedSex());
		SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, 23, GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		if( IsViewingAlteredForm() ) then
			CharacterCreateAlternateFormTop:SetChecked(false);
			CharacterCreateAlternateFormBottom:SetChecked(true);
		else
			CharacterCreateAlternateFormTop:SetChecked(true);
			CharacterCreateAlternateFormBottom:SetChecked(false);
		end
	else
		CharacterCreateAlternateFormTop:Hide();
		CharacterCreateAlternateFormBottom:Hide();
	end
end

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharCreateClassButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
			if( IsBlizzCon() ) then
				button.selection:Show();
			end
		else
			button:SetChecked(0);
			button.selection:Hide();
		end
	end
	
	-- class info
	local frame = CharCreateClassInfoFrame;
	local className, classFileName, _, tank, healer, damage = GetSelectedClass();
	local abilityIndex = 0;
	local tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	local abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	end
	CharCreateClassInfoFrame.title:SetText(className);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.infoText:SetText(GetFlavorText("CLASS_"..strupper(classFileName), GetSelectedSex()).."|n|n");
	CharCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);
end

function CharacterCreate_OnChar()
end

function CharacterCreate_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back();
	elseif ( key == "ENTER" ) then
		CharacterCreate_Forward();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CharacterCreate_UpdateModel(self)
	UpdateCustomizationScene();
	self:AdvanceTime();
end

function CharacterCreate_Finish()
	PlaySound("gsCharacterCreationCreateChar");
	if( IsBlizzCon() ) then
		CreateCharacter(CharacterCreateNameEdit:GetText());
		BLIZZCON_IS_A_GO = true;
		return;
	end

	-- If something disabled this button, ignore this message.
	-- This can happen if you press enter while it's disabled, for example.
	if ( not CharCreateOkayButton:IsEnabled() ) then
		return;
	end

	if ( PAID_SERVICE_TYPE ) then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		-- if using templates, pandaren must pick a faction
		local _, faction = GetFactionForRace(CharacterCreate.selectedRace);
		if ( ( IsUsingCharacterTemplate() or IsForcingCharacterTemplate() ) and ( faction ~= "Alliance" and faction ~= "Horde" ) ) then
			CharacterTemplateConfirmDialog:Show();
		else
			CreateCharacter(CharacterCreateNameEdit:GetText());
		end
	end
end

function CharacterCreate_Back()
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		PlaySound("gsCharacterCreationCancel");
		CharacterCreateFrame.state = "CLASSRACE"
		CharCreateClassFrame:Show();
		CharCreateRaceFrame:Show();
		CharCreateMoreInfoButton:Show();
		CharCreateCustomizationFrame:Hide();
		CharCreatePreviewFrame:Hide();
		CharCreateOkayButton:SetText(CUSTOMIZE);
		CharacterCreateNameEdit:Hide();
		CharacterCreateRandomName:Hide();

		--back to awesome gear
		SetSelectedPreviewGearType(1);

		-- back to normal camera
		SetFaceCustomizeCamera(false);

		return;
	end

	if( IsBlizzCon() ) then
		return;
	end

	PlaySound("gsCharacterCreationCancel");
	CHARACTER_SELECT_BACK_FROM_CREATE = true;
	SetGlueScreen("charselect");
end

function CharacterCreate_Forward()
	if ( CharacterCreateFrame.state == "CLASSRACE" ) then
		CharacterCreateFrame.state = "CUSTOMIZATION"
		PlaySound("gsCharacterSelectionCreateNew");
		CharCreateClassFrame:Hide();
		CharCreateRaceFrame:Hide();
		CharCreateMoreInfoButton:Hide();
		CharCreateCustomizationFrame:Show();
		CharCreatePreviewFrame:Show();
		CharacterTemplateConfirmDialog:Hide();

		CharCreate_PrepPreviewModels();
		if ( CharacterCreateFrame.customizationType ) then
			CharCreate_ResetFeaturesDisplay();
		else
			CharCreateSelectCustomizationType(1);
		end

		CharCreateOkayButton:SetText(FINISH);
		CharacterCreateNameEdit:Show();
		if ( ALLOW_RANDOM_NAME_BUTTON ) then
			CharacterCreateRandomName:Show();
		end

		--You just went to customization mode - show the boring start gear
		SetSelectedPreviewGearType(0);

		-- set cam
		if (CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType > 1) then
			SetFaceCustomizeCamera(true);
		else
			SetFaceCustomizeCamera(false);
		end
	else
		CharacterCreate_Finish();
	end
end

function CharCreateCustomizationFrame_OnShow ()
	-- reset size/tex coord to default to facilitate switching between genders for Pandaren
	CharCreateCustomizationFrameBanner:SetSize(BANNER_DEFAULT_SIZE[1], BANNER_DEFAULT_SIZE[2]);
	CharCreateCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], BANNER_DEFAULT_TEXTURE_COORDS[3], BANNER_DEFAULT_TEXTURE_COORDS[4]);

	-- check each button and hide it if there are no values select
	local resize = 0;
	local lastGood = 0;
	local isSkinVariantHair = GetSkinVariationIsHairColor(CharacterCreate.selectedRace);
	local isDefaultSet = 0;
	local checkedButton = 1;

	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1;
	end
	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		if ( ( GetNumFeatureVariationsForType(i) <= 1 ) or ( isSkinVariantHair and i == CHAR_CUSTOMIZE_HAIR_COLOR ) ) then
			resize = resize + 1;
			_G["CharCreateCustomizationButton"..i]:Hide();
		else
			_G["CharCreateCustomizationButton"..i]:Show();
			_G["CharCreateCustomizationButton"..i]:SetChecked(0); -- we will handle default selection
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( isDefaultSet == 0 and CharacterCreateFrame.customizationType == i) then
				isDefaultSet = 1;
				checkedButton = i;
			end
			-- set your anchor to be the last good, this currently means button 1 HAS to be shown
			if (i > 1) then  
				_G["CharCreateCustomizationButton"..i]:SetPoint( "TOP",_G["CharCreateCustomizationButton"..lastGood]:GetName() , "BOTTOM");
			end
			lastGood = i;
		end
	end

	if (isDefaultSet == 0) then 
		CharacterCreateFrame.customizationType = lastGood;
		checkedButton = lastGood;
	end
	_G["CharCreateCustomizationButton"..checkedButton]:SetChecked(1);

	if (resize > 0) then
	-- we need to resize and remap the banner texture
		local buttonx, buttony = CharCreateCustomizationButton1:GetSize()
		local screenamount = resize*buttony;
		local frameX, frameY = CharCreateCustomizationFrameBanner:GetSize();
		local pctShrink = .2*resize; 
		local uvXDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[2] - BANNER_DEFAULT_TEXTURE_COORDS[1];
		local uvYDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[4] - BANNER_DEFAULT_TEXTURE_COORDS[3];
		local newYUV = pctShrink*uvYDefaultSize + BANNER_DEFAULT_TEXTURE_COORDS[3];
		-- end coord stay the same
		CharCreateCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], newYUV, BANNER_DEFAULT_TEXTURE_COORDS[4]);
		CharCreateCustomizationFrameBanner:SetSize(frameX, frameY - screenamount);
	end
	
	CharCreateRandomizeButton:SetPoint("TOP", _G["CharCreateCustomizationButton"..lastGood]:GetName(), "BOTTOM", 0, 0);
end

function CharacterClass_OnClick(self, id)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		local _,_,currClass = GetSelectedClass();
		if ( currClass ~= id ) then
			SetSelectedClass(id);
			SetCharacterClass(id);
			SetCharacterRace(GetSelectedRace());
			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function CharacterRace_OnClick(self, id, forceSelect)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		if ( GetSelectedRace() ~= id or forceSelect ) then
			SetSelectedRace(id);
			SetCharacterRace(id);
			SetCharacterGender(GetSelectedSex());
			SetCharacterCreateFacing(-15);
			CharacterCreateEnumerateClasses(GetAvailableClasses());
			local _,_,classIndex = GetSelectedClass();
			if ( PAID_SERVICE_TYPE ) then
				classIndex = PaidChange_GetCurrentClassIndex();
				SetSelectedClass(classIndex);	-- selecting a race would have changed class to default
			end
			SetCharacterClass(classIndex);
			
			-- Hair customization stuff
			CharacterCreate_UpdateHairCustomization();
				
			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function SetCharacterGender(sex)
	if( IsBlizzCon() ) then
		sex = 2;
	end
	local gender;
	SetSelectedSex(sex);
	if ( sex == SEX_MALE ) then
		CharCreateMaleButton:SetChecked(1);
		CharCreateFemaleButton:SetChecked(0);
	else
		CharCreateMaleButton:SetChecked(0);
		CharCreateFemaleButton:SetChecked(1);
	end

	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces(GetAvailableRaces());
	CharacterCreateEnumerateClasses(GetAvailableClasses());
 	SetCharacterRace(GetSelectedRace());
	
	local _,_,classIndex = GetSelectedClass();
	if ( PAID_SERVICE_TYPE ) then
		classIndex = PaidChange_GetCurrentClassIndex();
		PandarenFactionButtons_SetTextures();
	end
	SetCharacterClass(classIndex);

	CharacterCreate_UpdateHairCustomization();
	CharacterChangeFixup();

	-- Update preview models if on customization step
	if ( CharCreatePreviewFrame:IsShown() ) then
		CharCreateCustomizationFrame_OnShow(); -- buttons may need to reset for dirty Pandarens
		CharCreate_PrepPreviewModels();
		CharCreate_ResetFeaturesDisplay();
	end
end

function CharacterCustomization_Left(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable();
	CharacterCreateNameEdit:SetText("...");
	RequestRandomName();
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook");
	RandomizeCharCustomization();
	CharCreate_ResetFeaturesDisplay();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreate_UpdateHairCustomization()
	CharCreateCustomizationButton3.text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"]);
	CharCreateCustomizationButton4.text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"]);
	CharCreateCustomizationButton5.text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( not icon ) then
		return;
	end
	
	icon:SetDesaturated(desaturated);
end

function GetFlavorText(tagname, sex)
	local primary, secondary;
	if ( sex == SEX_MALE ) then
		primary = "";
		secondary = "_FEMALE";
	else
		primary = "_FEMALE";
		secondary = "";
	end
	local text = _G[tagname..primary];
	if ( (text == nil) or (text == "") ) then
		text = _G[tagname..secondary];
	end
	return text;
end

function CharacterCreate_DeathKnightSwap(self)
	local _, classFilename = GetSelectedClass();
	if ( classFilename == "DEATHKNIGHT" ) then
		if (self.currentModel ~= "DEATHKNIGHT") then
			self.currentModel = "DEATHKNIGHT";
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentModel == "DEATHKNIGHT") then
			self.currentModel = nil;
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		-- no class changing as a paid service
		CharCreateClassFrame:SetAlpha(0.5);
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			if (CharacterCreate.selectedClass ~= i) then
				local button = _G["CharCreateClassButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			end
		end

		local numAllowedRaces = 0;
		for i=1, MAX_RACES, 1 do
			local allow = false;
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				local faction = PaidChange_GetCurrentFaction();
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) ~= faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true;
				end
			elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
				local faction = PaidChange_GetCurrentFaction();
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) == faction or IsNeutralRace(i)) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true
				end
			elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
				if ( i == CharacterCreate.selectedRace ) then
					allow = true
				end
			end
			if (not allow) then
				local button = _G["CharCreateRaceButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			else
				numAllowedRaces = numAllowedRaces + 1;
			end
		end
		if ( numAllowedRaces > 1 ) then
			CharCreateRaceButtonsFrame:SetAlpha(1);
		else
			CharCreateRaceButtonsFrame:SetAlpha(0.5);
		end
	else
		CharCreateRaceButtonsFrame:SetAlpha(1);
		CharCreateClassFrame:SetAlpha(1);
	end
end

function CharCreateSelectCustomizationType(newType)
	-- deselect previous type selection
	if ( CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType ~= newType ) then
		_G["CharCreateCustomizationButton"..CharacterCreateFrame.customizationType]:SetChecked(0);
	end
	_G["CharCreateCustomizationButton"..newType]:SetChecked(1);
	CharacterCreateFrame.customizationType = newType;
	CharCreate_ResetFeaturesDisplay();

	if (newType > 1) then
		SetFaceCustomizeCamera(true);
	else
		SetFaceCustomizeCamera(false);
	end
end

function CharCreate_ResetFeaturesDisplay()
	SetPreviewFramesFeature(CharacterCreateFrame.customizationType);
	-- set the previews scrollframe container height
	-- since the first and the last previews need to be in the center position when scrolled all the way
	-- to the top or to the bottom, there will be gaps of height equal to 2 previews on each side
	local numTotalButtons = GetNumFeatureVariations() + 4;
	CharCreatePreviewFrame.scrollFrame.container:SetHeight(numTotalButtons * PREVIEW_FRAME_HEIGHT - PREVIEW_FRAME_Y_OFFSET);	

	for _, previewFrame in pairs(CharCreatePreviewFrame.previews) do
		previewFrame.featureType = 0;
	end

	CharCreate_DisplayPreviewModels();
end

function CharCreate_PrepPreviewModels(reloadModels)
	local displayFrame = CharCreatePreviewFrame;

	-- clear models if rebuildPreviews got flagged
	local rebuildPreviews = displayFrame.rebuildPreviews;
	displayFrame.rebuildPreviews = nil;

	-- need to reload models class was swapped to or from DK
	local _, class = GetSelectedClass();
	if ( class == "DEATHKNIGHT" or displayFrame.lastClass == "DEATHKNIGHT" ) and ( class ~= displayFrame.lastClass ) then 
		reloadModels = true;
	end
	displayFrame.lastClass = class;

	-- always clear the featureType
	for index, previewFrame in pairs(displayFrame.previews) do
		previewFrame.featureType = 0;
		-- force model reload in some cases
		if ( reloadModels or rebuildPreviews ) then
			previewFrame.race = nil;
			previewFrame.gender = nil;
		end
		if ( rebuildPreviews ) then
			SetPreviewFrame(previewFrame.model:GetName(), index);
		end
	end
end

function CharCreate_DisplayPreviewModels(selectionIndex)
	if ( not selectionIndex ) then
		selectionIndex = GetSelectedFeatureVariation();
	end

	local displayFrame = CharCreatePreviewFrame;
	local previews = displayFrame.previews;
	local numVariations = GetNumFeatureVariations();
	local currentFeatureType = CharacterCreateFrame.customizationType;

	local race = GetSelectedRace();
	local gender = GetSelectedSex();
	
	-- HACK: Worgen fix for portrait camera position
	local cameraID = 0;
	if ( race == WORGEN_RACE_ID and gender == SEX_MALE and not IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	-- get data for target/camera/light
	local _, raceFileName = GetNameForRace();
	if ( IsViewingAlteredForm() ) then
		raceFileName = raceFileName.."Alt";
	end
	local config = MODEL_CAMERA_CONFIG[gender][raceFileName];

	-- selection index is the center preview
	-- there are 2 previews above and 2 below, and will pad it out to 1 more on each side, for a total of 7 previews to set up
	for index = selectionIndex - 3, selectionIndex + 3 do
		-- there is empty space both at the beginning and at end of the list, each gap the height of 2 previews
		if ( index > 0 and index <= numVariations ) then
			local previewFrame = previews[index];
			-- create button if we don't have it yet
			if ( not previewFrame ) then
				previewFrame = CreateFrame("FRAME", "PreviewFrame"..index, displayFrame.scrollFrame.container, "CharCreatePreviewFrameTemplate");
				-- index + 1 because of 2 gaps at the top and -1 for the current preview
				previewFrame:SetPoint("TOPLEFT", PREVIEW_FRAME_X_OFFSET, (index + 1) * -PREVIEW_FRAME_HEIGHT + PREVIEW_FRAME_Y_OFFSET);
				previewFrame.button.index = index;
				previews[index] = previewFrame;
				SetPreviewFrame(previewFrame.model:GetName(), index);
			end
			-- load model if needed, may have been cleared by different race/gender selection
			if ( previewFrame.race ~= race or previewFrame.gender ~= gender ) then
				SetPreviewFrameModel(index);
				previewFrame.race = race;
				previewFrame.gender = gender;
				-- apply settings
				local model = previewFrame.model;
				model:SetCustomCamera(cameraID);
				local scale = model:GetWorldScale();
				model:SetCameraTarget(config.tx * scale, config.ty * scale, config.tz * scale);
				model:SetCameraDistance(config.distance * scale);
				local cx, cy, cz = model:GetCameraPosition();
				model:SetCameraPosition(cx, cy, config.cz * scale);
				model:SetLight(1, 0, 0, 0, 0, config.light, 1.0, 1.0, 1.0);
			end
			-- need to reset the model if it was last used to preview a different feature
			if ( previewFrame.featureType ~= currentFeatureType ) then
				ResetPreviewFrameModel(index);
				ShowPreviewFrameVariation(index);
				previewFrame.featureType = currentFeatureType;
			end
			previewFrame:Show();
		else
			-- need to hide tail previews when going to features with fewer styles
			if ( previews[index] ) then
				previews[index]:Hide();
			end
		end
	end
	displayFrame.border.number:SetText(selectionIndex);
	displayFrame.selectionIndex = selectionIndex;
	CharCreate_RotatePreviews();
	CharCreatePreviewFrame_UpdateStyleButtons();
	-- scroll to center the selection
	if ( not displayFrame.animating ) then
		displayFrame.scrollFrame:SetVerticalScroll((selectionIndex - 1) * PREVIEW_FRAME_HEIGHT);
	end
end


function CharCreate_RotatePreviews()
	if ( CharCreatePreviewFrame:IsShown() ) then
		local facing = ((GetCharacterCreateFacing())/ -180) * math.pi;
		local previews = CharCreatePreviewFrame.previews;
		for index = CharCreatePreviewFrame.selectionIndex - 3, CharCreatePreviewFrame.selectionIndex + 3 do
			local previewFrame = previews[index];
			if ( previewFrame and previewFrame.model:HasCustomCamera() ) then
				previewFrame.model:SetCameraFacing(facing);
			end
		end
	end
end

function CharCreate_ChangeFeatureVariation(delta)
	local numVariations = GetNumFeatureVariations();
	local startIndex = GetSelectedFeatureVariation();
	local endIndex = startIndex + delta;
	if ( endIndex < 1 or endIndex > numVariations ) then
		return;
	end
	PlaySound("gsCharacterCreationClass");
	CharCreatePreviewFrame_SelectFeatureVariation(endIndex);
end

function CharCreatePreviewFrameButton_OnClick(self)
	PlaySound("gsCharacterCreationClass");
	CharCreatePreviewFrame_SelectFeatureVariation(self.index);
end

function CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex;
		end
	else
		local startIndex = GetSelectedFeatureVariation();
		SelectFeatureVariation(endIndex);
		CharCreatePreviewFrame_UpdateStyleButtons();
		CharCreatePreviewFrame_StartAnimating(startIndex, endIndex);
	end
end

function CharCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		return;
	else
		self.startIndex = startIndex;
		self.currentIndex = startIndex;
		self.endIndex = endIndex;
		self.queuedIndex = nil;
		self.direction = 1;
		if ( self.startIndex > self.endIndex ) then
			self.direction = -1;
		end
		self.movedTotal = 0;
		self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
		self.animating = true;
	end
end

function CharCreatePreviewFrame_StopAnimating()
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		self.animating = false;
	end
end

local ANIMATION_SPEED = 5;
function CharCreatePreviewFrame_OnUpdate(self, elapsed)
	if ( self.animating ) then
		local moveIncrement = PREVIEW_FRAME_HEIGHT * elapsed * ANIMATION_SPEED;
		self.movedTotal = self.movedTotal + moveIncrement;
		self.scrollFrame:SetVerticalScroll((self.startIndex - 1) * PREVIEW_FRAME_HEIGHT + self.movedTotal * self.direction);		
		self.moveUntilUpdate = self.moveUntilUpdate - moveIncrement;
		if ( self.moveUntilUpdate <= 0 ) then
			self.currentIndex = self.currentIndex + self.direction;
			self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
			-- reset movedTotal to account for rounding errors
			self.movedTotal = abs(self.startIndex - self.currentIndex) * PREVIEW_FRAME_HEIGHT;
			CharCreate_DisplayPreviewModels(self.currentIndex);
		end
		if ( self.currentIndex == self.endIndex ) then
			self.animating = false;
			CharCreate_DisplayPreviewModels();
			if ( self.queuedIndex ) then
				local newIndex = self.queuedIndex;
				self.queuedIndex = nil;
				SelectFeatureVariation(newIndex);
				CharCreatePreviewFrame_UpdateStyleButtons();
				CharCreatePreviewFrame_StartAnimating(self.endIndex, newIndex);	
			end
		end
	end
end

function CharCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = GetSelectedFeatureVariation();
	local numVariations = GetNumFeatureVariations();
	if ( selectionIndex == 1 ) then
		CharCreateStyleUpButton:SetEnabled(false);
		CharCreateStyleUpButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleUpButton:SetEnabled(true);
		CharCreateStyleUpButton.arrow:SetDesaturated(false);
	end
	if ( selectionIndex == numVariations ) then
		CharCreateStyleDownButton:SetEnabled(false);
		CharCreateStyleDownButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleDownButton:SetEnabled(true);
		CharCreateStyleDownButton.arrow:SetDesaturated(false);
	end
end

local TotalTime = 0;
local KeepScrolling = nil;
local TIME_TO_SCROLL = 0.5;
function CharacterCreateWhileMouseDown_OnMouseDown(direction)
	TIME_TO_SCROLL = 0.5;
	TotalTime = 0;
	KeepScrolling = direction;
end
function CharacterCreateWhileMouseDown_OnMouseUp()
	KeepScrolling = nil;
end
function CharacterCreateWhileMouseDown_Update(elapsed)
	if ( KeepScrolling ) then
		TotalTime = TotalTime + elapsed;
		if ( TotalTime >= TIME_TO_SCROLL ) then
			CharCreate_ChangeFeatureVariation(KeepScrolling);
			TIME_TO_SCROLL = 0.25;
			TotalTime = 0;
		end
	end
end

-- pandaren stuff related to faction change
function CharCreate_EnableNextButton(enabled)
	local button = CharCreateOkayButton;
	button:SetEnabled(enabled);
	button.Arrow:SetDesaturated(not enabled);
	button.TopGlow:SetShown(enabled);
	button.BottomGlow:SetShown(enabled);
end

function PandarenFactionButtons_OnLoad(self)
	self.PandarenButton = CharCreateRaceButton13;
end

function PandarenFactionButtons_Show()
	local frame = CharCreatePandarenFactionFrame;
	-- set the name
	local raceName = GetNameForRace();
	frame.AllianceButton.nameFrame.text:SetText(raceName);
	frame.AllianceButton.tooltip = raceName;
	frame.HordeButton.nameFrame.text:SetText(raceName);
	frame.HordeButton.tooltip = raceName;
	-- set the texture
	PandarenFactionButtons_SetTextures();
	-- set selected button
	local _, faction = PaidChange_GetCurrentFaction();
	-- deselect first in case of multiple pandaren faction changes
	PandarenFactionButtons_ClearSelection();
	frame[faction.."Button"]:SetChecked(1);
	-- show the frame on top of the normal pandaren button
	frame:Show();
	frame:SetFrameLevel(frame.PandarenButton:GetFrameLevel() + 2);
	CharCreate_EnableNextButton(false);
end

function PandarenFactionButtons_Hide()
	CharCreatePandarenFactionFrame:Hide();
	CharCreate_EnableNextButton(true);
end

function PandarenFactionButtons_SetTextures()
	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local coords = RACE_ICON_TCOORDS["PANDAREN_"..gender];
	CharCreatePandarenFactionFrameAllianceButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameAllianceButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameHordeButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameHordeButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);	
end

function PandarenFactionButtons_ClearSelection()
	CharCreatePandarenFactionFrame.AllianceButton:SetChecked(0);
	CharCreatePandarenFactionFrame.HordeButton:SetChecked(0);
end

function PandarenFactionButtons_GetSelectedFaction()
	if ( CharCreatePandarenFactionFrame.AllianceButton:GetChecked() ) then
		return "Alliance";
	elseif ( CharCreatePandarenFactionFrame.HordeButton:GetChecked() ) then
		return "Horde";
	end
end

function PandarenFactionButton_OnClick(self)
	PandarenFactionButtons_ClearSelection();
	self:SetChecked(1);
	CharacterRace_OnClick(CharCreatePandarenFactionFrame.PandarenButton, CharCreatePandarenFactionFrame.PandarenButton:GetID(), true);
end
