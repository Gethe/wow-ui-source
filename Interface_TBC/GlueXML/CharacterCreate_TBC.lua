MAX_RACES = 10;
MAX_CLASSES_PER_RACE = 8;

FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
	"CharacterCreateCharacterFaction",
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
};

function CharacterCreateRaceButton_OnEnter(self)
	if(self:IsEnabled()) then
		return;
	end
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, -8);
	GlueTooltip:SetText(self.tooltip, nil, 1.0, 1.0, 1.0);
	GlueTooltip:Show();
end

function CharacterCreateRaceButton_OnLeave(self)
	GlueTooltip:Hide();
end

function CharacterCreateEnumerateRaces()
	local races = C_CharacterCreation.GetAvailableRaces();
	CharacterCreate.numRaces = #races;
	if ( CharacterCreate.numRaces > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		return;
	end

	local isBoostedCharacter = CharacterUpgrade_IsCreatedCharacterUpgrade() or CharacterUpgrade_IsCreatedCharacterTrialBoost();
	local coords;
	local button;
	local gender;
	if ( C_CharacterCreation.GetSelectedSex() == Enum.UnitSex.Male ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	for index, raceData in pairs(races) do
		coords = RACE_ICON_TCOORDS[strupper(raceData.fileName.."_"..gender)];
		_G["CharacterCreateRaceButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharacterCreateRaceButton"..index];
		button:Show();
		
		if isBoostedCharacter and CharacterUpgradeFlow and CharacterUpgradeFlow.data and CharacterUpgradeFlow.data.boostType and C_CharacterServices.DoesBoostTypeRestrictRace(CharacterUpgradeFlow.data.boostType, raceData.raceID) then
			button:Disable();
			local texture = button:GetNormalTexture();
			if ( texture ) then
				texture:SetDesaturated(true);
			end
			button:SetText("");
			button.tooltip = CHAR_CREATE_NO_BOOST;
		else
			button:Enable();
			local texture = button:GetNormalTexture();
			if ( texture ) then
				texture:SetDesaturated(false);
			end
			button.tooltip = raceData.name;
		end
		button.raceID = raceData.raceID;
	end
	for i=#races + 1, MAX_RACES, 1 do
		_G["CharacterCreateRaceButton"..i]:Hide();
	end
end

function CharacterCreateEnumerateClasses()
	local classes = C_CharacterCreation.GetAvailableClasses();

	local numRaceAvailableClasses = 0;
	local raceAvailableClasses = {};
	for index, classData in pairs(classes) do
		if (classData.enabled) then
			numRaceAvailableClasses = numRaceAvailableClasses + 1;
			raceAvailableClasses[#raceAvailableClasses+1] = index;
		end
	end
	CharacterCreate.numClasses = numRaceAvailableClasses;
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end

	local isBoostedCharacter = CharacterUpgrade_IsCreatedCharacterUpgrade() or CharacterUpgrade_IsCreatedCharacterTrialBoost();
	local coords;
	local button;
	for index, classIndex in ipairs(raceAvailableClasses) do
		local classData = classes[classIndex];
		coords = CLASS_ICON_TCOORDS[strupper(classData.fileName)];
		_G["CharacterCreateClassButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharacterCreateClassButton"..index];

		if (not classData.enabled or (isBoostedCharacter and CharacterUpgradeFlow and CharacterUpgradeFlow.data and CharacterUpgradeFlow.data.boostType and C_CharacterServices.DoesBoostTypeRestrictClass(CharacterUpgradeFlow.data.boostType, classData.classID))) then 
			button:Disable();
		else
			button:Enable();
		end
		button.tooltip = classData.name;
		button.classID = classData.classID;
	end
	for i=numRaceAvailableClasses+1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharacterCreateClassButton"..i]:Hide();
	end
end

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;

	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharacterCreateRaceButton"..i];
		if ( button.raceID == id ) then
			_G["CharacterCreateRaceButton"..i.."HighlightText"]:SetText(button.tooltip);
			button:SetChecked(1);
			button:LockHighlight();
		else
			_G["CharacterCreateRaceButton"..i.."HighlightText"]:SetText("");
			button:SetChecked(0);
			button:UnlockHighlight();
		end
	end

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
	for index, value in ipairs(FRAMES_TO_BACKDROP_COLOR) do
		_G[value]:SetBackdropColor(backdropColor.color:GetRGB());
	end

	SetBackgroundModel(CharacterCreate, C_CharacterCreation.GetCreateBackgroundModel());
	--twainUpdateCustomizationBackground();
	
	CharacterCreateEnumerateClasses();
	SetDefaultClass();

	-- Hair customization stuff
	CharacterCreate_UpdateFacialHairCustomization();
	CharacterCreate_UpdateCustomizationOptions();
end

function SetDefaultClass()
	local class = GetDefaultClass();
	SetCharacterClass(class);
	C_CharacterCreation.SetSelectedClass(class);
end

function SetCharacterClass(id)
	if (not id) then
		-- If no ID is provided, default to the first.
		id = _G["CharacterCreateClassButton1"].classID;
	end

	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharacterCreateClassButton"..i];
		if ( button.classID == id ) then
			_G["CharacterCreateClassButton"..i.."HighlightText"]:SetText(button.tooltip);
			button:SetChecked(1);
			button:LockHighlight();
		else
			_G["CharacterCreateClassButton"..i.."HighlightText"]:SetText("");
			button:UnlockHighlight();
			button:SetChecked(0);
		end
	end
	
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
		CharacterCreateGenderButtonMaleHighlightText:SetText(MALE);
		CharacterCreateGenderButtonMale:SetChecked(1);
		CharacterCreateGenderButtonMale:LockHighlight();
		CharacterCreateGenderButtonFemaleHighlightText:SetText("");
		CharacterCreateGenderButtonFemale:SetChecked(nil);
		CharacterCreateGenderButtonFemale:UnlockHighlight();
	else
		gender = "FEMALE";
		CharacterCreateGenderButtonMaleHighlightText:SetText("");
		CharacterCreateGenderButtonMale:SetChecked(nil);
		CharacterCreateGenderButtonMale:UnlockHighlight();
		CharacterCreateGenderButtonFemaleHighlightText:SetText(FEMALE);
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
	local race, fileString = C_CharacterCreation.GetNameForRace(CharacterCreate.selectedRace);
	CharacterCreateRaceLabel:SetText(race);
	fileString = strupper(fileString);
	local coords = RACE_ICON_TCOORDS[fileString.."_"..gender];
	CharacterCreateRaceIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
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