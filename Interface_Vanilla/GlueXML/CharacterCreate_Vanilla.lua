MAX_RACES = 8;
MAX_CLASSES_PER_RACE = 8;
SHOW_UNAVAILABLE_CLASSES = false;

FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
	"CharacterCreateCharacterFaction",
};

RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.25, 0, 0.25},
	["DWARF_MALE"]		= {0.25, 0.5, 0, 0.25},
	["GNOME_MALE"]		= {0.5, 0.75, 0, 0.25},
	["NIGHTELF_MALE"]	= {0.75, 1.0, 0, 0.25},
	
	["TAUREN_MALE"]		= {0, 0.25, 0.25, 0.5},
	["SCOURGE_MALE"]	= {0.25, 0.5, 0.25, 0.5},
	["TROLL_MALE"]		= {0.5, 0.75, 0.25, 0.5},
	["ORC_MALE"]		= {0.75, 1.0, 0.25, 0.5},

	["HUMAN_FEMALE"]	= {0, 0.25, 0.5, 0.75},  
	["DWARF_FEMALE"]	= {0.25, 0.5, 0.5, 0.75},
	["GNOME_FEMALE"]	= {0.5, 0.75, 0.5, 0.75},
	["NIGHTELF_FEMALE"]	= {0.75, 1.0, 0.5, 0.75},
	
	["TAUREN_FEMALE"]	= {0, 0.25, 0.75, 1.0},   
	["SCOURGE_FEMALE"]	= {0.25, 0.5, 0.75, 1.0}, 
	["TROLL_FEMALE"]	= {0.5, 0.75, 0.75, 1.0}, 
	["ORC_FEMALE"]		= {0.75, 1.0, 0.75, 1.0}, 
};

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;

	UpdateCharacterRaceLabelText();

	--twain SetSelectedRace(id);
	-- Set Faction
	local name, faction = C_CharacterCreation.GetFactionForRace(CharacterCreate.selectedRace);
	if ( faction == "Alliance" ) then
		CharacterCreateFactionIcon:SetTexCoord(0, 0.5, 0, 1.0);
	else
		CharacterCreateFactionIcon:SetTexCoord(0.5, 1.0, 0, 1.0);
	end
	CharacterCreateFactionScrollFrameScrollBar:SetValue(0);
	CharacterCreateFactionLabel:SetText(name);
	CharacterCreateFactionText:SetText(_G["FACTION_INFO_"..strupper(faction)]);
	CharacterCreateFactionScrollFrame:UpdateScrollChildRect();
	--CharacterCreateCharacterFaction:SetHeight(CharacterCreateFactionText:GetHeight() + 40);

	-- Set Race
	local race, fileString = C_CharacterCreation.GetNameForRace(CharacterCreate.selectedRace);
	CharacterCreateRaceLabel:SetText(race);
	fileString = strupper(fileString);
	if ( C_CharacterCreation.GetSelectedSex() == Enum.UnitSex.Male ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local coords = RACE_ICON_TCOORDS[fileString.."_"..gender];
	CharacterCreateRaceIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	local raceText = _G["RACE_INFO_"..fileString];

	-- Loop over all the ability strings we can find and concatenate them into a giant block.
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	abilityText = "";
	if (tempText) then
		abilityText = tempText;
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];

		while ( tempText ) do
			-- If we found another ability, throw on a couple line breaks before adding it.
			abilityText = abilityText.."\n\n"..tempText;
			abilityIndex = abilityIndex + 1;
			tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
		end
		abilityText = abilityText.."\n"; -- A bit of spacing at the bottom (to match Classic).
	end


	CharacterCreateRaceScrollFrameScrollBar:SetValue(0);
	if ( abilityText and abilityText ~= "" ) then
		CharacterCreateRaceText:SetText(_G["RACE_INFO_"..fileString]);
		CharacterCreateRaceAbilityText:SetText(abilityText);
	else
		CharacterCreateRaceText:SetText(_G["RACE_INFO_"..fileString]);
		CharacterCreateRaceAbilityText:SetText("");
	end
	CharacterCreateRaceScrollFrame:UpdateScrollChildRect();
	--CharacterCreateCharacterRace:SetHeight(CharacterCreateRaceText:GetHeight() + 40);

	-- Set backdrop colors based on faction
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	local frame;
	for index, value in ipairs(FRAMES_TO_BACKDROP_COLOR) do
		frame = _G[value];
		--frame:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
		frame:SetBackdropColor(backdropColor.color:GetRGB());
	end

	SetBackgroundModel(CharacterCreate, C_CharacterCreation.GetCreateBackgroundModel());
	--twainUpdateCustomizationBackground();
	
	CharacterCreateEnumerateClasses();
	SetDefaultClass();

	-- Hair customization stuff
	CharacterCreate_UpdateFacialHairCustomization();
	CharacterCreate_UpdateCustomizationOptions();
end

function UpdateCharacterRaceLabelText()
	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharacterCreateRaceButton"..i];
		if ( button.raceID == CharacterCreate.selectedRace ) then
			_G["CharacterCreateRaceButton"..i.."HighlightText"]:SetText(button.tooltip);
			button:SetChecked(1);
		else
			_G["CharacterCreateRaceButton"..i.."HighlightText"]:SetText("");
			button:SetChecked(nil);
		end
	end
end

function UpdateCharacterClassLabelText(text)
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharacterCreateClassButton"..i];
		if ( button.classID == CharacterCreate.selectedClass) then
			if(text) then
				_G["CharacterCreateClassButton"..i.."HighlightText"]:SetText(text);
			else
				_G["CharacterCreateClassButton"..i.."HighlightText"]:SetText(button.tooltip);
			end
			button:SetChecked(1);
			button:LockHighlight();
		else
			_G["CharacterCreateClassButton"..i.."HighlightText"]:SetText("");
			button:UnlockHighlight();
			button:SetChecked(0);
		end
	end
end

function SetDefaultClass()
	-- In Classic, changing race will default the Class to the first available one (i.e. Warrior).
	local classID = _G["CharacterCreateClassButton1"].classID;
	if ( classID ) then
		C_CharacterCreation.SetSelectedClass(classID);
	end

	-- This should be the same as the classID above. Just making sure we stay consistent!
	local classData = C_CharacterCreation.GetSelectedClass();
	SetCharacterClass(classData.classID);
end

function SetCharacterClass(id)
	if (not id) then
		-- If no ID is provided, default to the first.
		id = _G["CharacterCreateClassButton1"].classID;
	end

	CharacterCreate.selectedClass = id;
	UpdateCharacterClassLabelText();
	
	--twain SetSelectedClass(id);
	local classData = C_CharacterCreation.GetSelectedClass();
	local coords = CLASS_ICON_TCOORDS[classData.fileName];
	CharacterCreateClassIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharacterCreateClassLabel:SetText(classData.name);
	CharacterCreateClassScrollFrameScrollBar:SetValue(0);
	CharacterCreateClassText:SetText(_G["CLASS_"..strupper(classData.fileName)]);
	CharacterCreateClassScrollFrame:UpdateScrollChildRect();
	--CharacterCreateCharacterClass:SetHeight(CharacterCreateClassText:GetHeight() + 45);
end

function SetCharacterGender(sex)
	local gender;
	C_CharacterCreation.SetSelectedSex(sex);
	if ( sex == Enum.UnitSex.Male ) then
		gender = "MALE";
		CharacterCreateGenderButtonMale:SetChecked(1);
		CharacterCreateGenderButtonMale:LockHighlight();
		CharacterCreateGenderButtonFemale:SetChecked(nil);
		CharacterCreateGenderButtonFemale:UnlockHighlight();
	else
		gender = "FEMALE";
		CharacterCreateGenderButtonMale:SetChecked(nil);
		CharacterCreateGenderButtonMale:UnlockHighlight();
		CharacterCreateGenderButtonFemale:SetChecked(1);
		CharacterCreateGenderButtonFemale:LockHighlight();
	end
	
	--twain SetSelectedSex(id);
	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces();

	-- Update facial hair customization since gender can affect this
	CharacterCreate_UpdateFacialHairCustomization();

	-- Update right hand race portrait to reflect gender change
	-- Set Race
	if (CharacterCreate.selectedRace > 0) then
		local race, fileString = C_CharacterCreation.GetNameForRace(CharacterCreate.selectedRace);
		CharacterCreateRaceLabel:SetText(race);
		fileString = strupper(fileString);
		local coords = RACE_ICON_TCOORDS[fileString.."_"..gender];
		CharacterCreateRaceIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		UpdateCharacterRaceLabelText();
	end
	-- Update class labels to reflect gender change
	-- Set Class
	local classData = C_CharacterCreation.GetSelectedClass();
	CharacterCreateClassLabel:SetText(classData.name);
	UpdateCharacterClassLabelText(classData.name);
	CharacterCreateEnumerateClasses(); -- Update class tooltips.
end

function CharacterCreate_UpdateFacialHairCustomization()
	local facialHairType = C_CharacterCreation.GetCustomizationDetails(4);
	if ( facialHairType == "" ) then
		CharacterCustomizationButtonFrame5:Hide();
		CharCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -5);
	else
		CharacterCustomizationButtonFrame5Text:SetText(facialHairType);
		CharacterCustomizationButtonFrame5:Show();
		CharCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -5);
	end
end

function CharacterCreate_ToggleSelfFound(self)
	C_CharacterCreation.ToggleSelfFoundMode(self:GetChecked());
end

function CheckSelfFoundButton()
	if (C_GameRules.IsSelfFoundAllowed()) then
		CharacterCreateSelfFound:Show();
	else
		CharacterCreateSelfFound:Hide();
	end
end

function CharacterCreate_CancelReincarnation()
	CharacterCreateNameEdit:Enable();
    CharacterCreateRandomName:Enable();
	CharacterReincarnatePopUpDialog:Hide();
	C_Reincarnation.StopReincarnation();
end