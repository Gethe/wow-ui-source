CHARACTER_FACING_INCREMENT = 2;
NUM_CHAR_CUSTOMIZATIONS = 5;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;

FACTION_BACKDROP_COLOR_TABLE = {
	Alliance = {
		color = GLUE_ALLIANCE_COLOR,
		borderColor = GLUE_ALLIANCE_BORDER_COLOR,
	},
	Horde = {
		color = GLUE_HORDE_COLOR,
		borderColor = GLUE_HORDE_BORDER_COLOR,
	},
};

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_STARTED");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_RESULT");
	self:RegisterEvent("RACE_FACTION_CHANGE_STARTED");
	self:RegisterEvent("RACE_FACTION_CHANGE_RESULT");

	self:SetSequence(0);
	self:SetCamera(0);

	CharacterCreate.numRaces = 0;
	CharacterCreate.selectedRace = 0;
	CharacterCreate.numClasses = 0;
	CharacterCreate.selectedClass = 0;
	CharacterCreate.selectedGender = 0;

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreate");
	C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Starting);
	--CharCreateModel:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8);

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharacterCustomizationButtonFrame"..i.."Text"]:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"]);
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor.borderColor:GetRGB());
	CharacterCreateNameEdit:SetBackdropColor(backdropColor.color:GetRGB());
end

function CharacterCreate_OnShow(self)
	InitializeCharacterScreenData();
	SetInCharacterCreate(true);

	--randomly selects a combination
	C_CharacterCreation.ResetCharCustomize();

	CharacterCreateEnumerateRaces();
	SetDefaultRace();

	CharacterCreateEnumerateClasses();
	SetDefaultClass();

	SetCharacterGender(C_CharacterCreation.GetSelectedSex())
	
	CharacterCreateNameEdit:SetText("");
	C_CharacterCreation.SetCharacterCreateFacing(-15);

	-- Set in locale files. We only support random names for English.
	if ( ALLOW_RANDOM_NAME_BUTTON ) then
		CharacterCreateRandomName:Show();
	end

	SetGameLogo(CharacterCreateLogo);

	if( IsKioskGlueEnabled() ) then
		local templateIndex = Kiosk.GetCharacterTemplateSetIndex();
		if (templateIndex) then
			C_CharacterCreation.SetCharacterTemplate(templateIndex);
		else
			C_CharacterCreation.ClearCharacterTemplate();
		end
	end
end

function CharacterCreate_OnHide()
	SetInCharacterCreate(false);
end

function CharacterCreate_OnEvent(self, event, ...)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		local success, name = ...;
		if ( not success ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(C_CharacterCreation.GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(name);
		end
		CharacterCreateRandomName:Enable();
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		-- Expansion level changed while online, so enable buttons as needed
		if ( CharacterCreateFrame:IsShown() ) then
			CharacterCreateEnumerateRaces();
			CharacterCreateEnumerateClasses();
		end
	elseif ( event == "CHARACTER_CREATION_RESULT" ) then
		local success, errorCode, guid = ...;
		if ( success ) then
			CharacterSelect.selectGuid = guid;
			GlueParent_SetScreen("charselect");
		else
			GlueDialog_Show("OKAY", _G[errorCode]);
		end
	elseif ( event == "CUSTOMIZE_CHARACTER_STARTED" ) then
		GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", CHAR_CUSTOMIZE_IN_PROGRESS);
	elseif ( event == "CUSTOMIZE_CHARACTER_RESULT" ) then
		local success, err = ...;
		if ( success ) then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			GlueDialog_Show("OKAY", _G[err]);
		end
	elseif ( event == "RACE_FACTION_CHANGE_STARTED" ) then
		local changeType = ...;
		if ( changeType == "RACE" ) then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", RACE_CHANGE_IN_PROGRESS);
		elseif ( changeType == "FACTION" ) then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", FACTION_CHANGE_IN_PROGRESS);
		end
	elseif ( event == "RACE_FACTION_CHANGE_RESULT" ) then
		local success, err = ...;
		if ( success ) then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			GlueDialog_Show("OKAY", _G[err]);
		end
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = C_CharacterCreation.GetCharacterCreateFacing();
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
		CHARACTER_CREATE_ROTATION_START_X = x;
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);
	end
end

function CharacterCreate_OnChar()
end

function CharacterCreate_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back();
	elseif ( key == "ENTER" ) then
		CharacterCreate_Okay();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CharacterCreate_UpdateModel(self)
	C_CharacterCreation.UpdateCustomizationScene();
end

function CharacterCreate_Okay()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);

	if( Kiosk.IsEnabled() ) then
		KioskModeSplash:SetAutoEnterWorld(true);
	else
		KioskModeSplash:SetAutoEnterWorld(false)
	end

	C_CharacterCreation.CreateCharacter(CharacterCreateNameEdit:GetText());
end

function CharacterCreate_Back()
	if( IsKioskGlueEnabled() ) then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
		GlueParent_SetScreen("kioskmodesplash");
	else
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
		CHARACTER_SELECT_BACK_FROM_CREATE = true;
		GlueParent_SetScreen("charselect");
	end
end

function CharacterClass_OnClick(self, id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	C_CharacterCreation.SetSelectedClass(id);
	SetCharacterClass(id);
	SetCharacterRace(C_CharacterCreation.GetSelectedRace());
end

function CharacterRace_OnClick(self, id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	if ( C_CharacterCreation.GetSelectedRace() == id ) then
		self:SetChecked(1);
		return;
	end
	C_CharacterCreation.SetSelectedRace(id);
	SetCharacterRace(id);
	C_CharacterCreation.SetSelectedSex(C_CharacterCreation.GetSelectedSex());
	C_CharacterCreation.SetCharacterCreateFacing(-15);
end

function CharacterCustomization_Left(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	C_CharacterCreation.CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	C_CharacterCreation.CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable();
	CharacterCreateNameEdit:SetText("...");
	C_CharacterCreation.RequestRandomName();
end

function CharacterCreate_Randomize()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	C_CharacterCreation.RandomizeCharCustomization();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreate_UpdateCustomizationOptions()
	for i=Enum.CharCustomizationTypeMeta.MinValue, NUM_CHAR_CUSTOMIZATIONS-1 do
		_G["CharacterCustomizationButtonFrame"..(i+1).."Text"]:SetText(C_CharacterCreation.GetCustomizationDetails(i));
	end
end

function CharacterCreate_getRandomValidRace()
	local races = C_CharacterCreation.GetAvailableRaces();
	local validRaces = {};
	local validItr = 1;
	for index, raceData in pairs(races) do
		local button = _G["CharacterCreateRaceButton"..index];
		if(button:IsEnabled()) then
			validRaces[validItr] = button.raceID;
			validItr = validItr + 1;
		end
	end

	local validRace = 1;
	if(#validRaces > 0) then
		validRace = validRaces[math.random(1, #validRaces)];
	end

	return validRace;
end

function CharacterCreate_getRandomValidClass()
	local classes = C_CharacterCreation.GetAvailableClasses();
	local validClasses = {};
	local validItr = 1;
	for index, classData in pairs(classes) do
		local button = _G["CharacterCreateClassButton"..index];
		if(button:IsEnabled()) then
			validClasses[validItr] = button.classID;
			validItr = validItr + 1;
		end
	end

	local validClass = 1;
	if(#validClasses > 0) then
		validClass = validClasses[math.random(1, #validClasses)];
	end

	return validClass;
end

function SetDefaultRace()
	local defaultRace = C_CharacterCreation.GetSelectedRace();
	if (not CharacterCreate_isRaceEnabled(defaultRace)) then
		defaultRace = CharacterCreate_getRandomValidRace();
		C_CharacterCreation.SetSelectedRace(defaultRace);
	end
	SetCharacterRace(defaultRace);
end

function GetDefaultClass()
	local classData = C_CharacterCreation.GetSelectedClass();
	local classID = classData.classID;
	if (not CharacterCreate_isClassEnabled(classID)) then
		classID = CharacterCreate_getRandomValidClass();
	end

	return classID;
end

function CharacterCreate_isRaceEnabled(race)
	local races = C_CharacterCreation.GetAvailableRaces();
	for index, raceData in pairs(races) do
		local button = _G["CharacterCreateRaceButton"..index];
		if(button.raceID == race) then
			return button:IsEnabled();
		end
	end

	return false;
end

function CharacterCreate_isClassEnabled(class)
	local classes = C_CharacterCreation.GetAvailableClasses();
	for index, classData in pairs(classes) do
		local button = _G["CharacterCreateClassButton"..index];
		if(button.classID == class) then
			return button:IsEnabled();
		end
	end

	return false;
end