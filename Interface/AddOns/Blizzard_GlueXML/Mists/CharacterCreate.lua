MAX_RACES = 13;
MAX_CLASSES_PER_RACE = 11;
SHOW_UNAVAILABLE_CLASSES = true;

WORGEN_RACE_ID = 22;
GILNEAN_RACE_ID = 23;
HAIR_COLOR_OPTION_INDEX = 4;

FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateRaceInfoFrame",
	"CharacterCreateClassInfoFrame",
	"CharacterCreateClassFrame",
	"CharacterCreateRaceFrame",
	"CharacterCreatePreviewFrame",
	"CharacterCustomizationFrame"
};

BANNER_DEFAULT_TEXTURE_COORDS = {0.109375, 0.890625, 0.201171875, 0.80078125};
BANNER_DEFAULT_SIZE = {200, 308};

PREVIEW_FRAME_HEIGHT = 130;
PREVIEW_FRAME_X_OFFSET = 19;
PREVIEW_FRAME_Y_OFFSET = -7;

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

BANNER_VERTEX_COLORS = {
	["Alliance"] = PLAYER_FACTION_COLOR_ALLIANCE,
	["Horde"] = PLAYER_FACTION_COLOR_HORDE,
	["Player"] = WHITE_FONT_COLOR,
};

function CharacterCreate_CreateLight(intensity)
	local light = {};

	light["omnidirectional"] = false;
	light["point"] = {
		["x"] = 0.0,
		["y"] = 0.0,
		["z"] = 0.0
	};

	light["ambientIntensity"] = intensity;
	light["ambientColor"] = {
		["r"] = 1.0,
		["g"] = 1.0,
		["b"] = 1.0
	};

	light["diffuseIntensity"] = 0;
	light["diffuseColor"] = nil;

	return light;
end

CHARACTER_CREATE_STATES = {
	"CLASSRACE",
	"CUSTOMIZATION"
};

MODEL_CAMERA_CONFIG = {
	[0] = {  -- Changed from 2
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
	[1] = { -- Changed from 3
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

function CharacterCreate_SelectForm(alternate)
	CharacterCreateAlternateFormTop:SetChecked(not alternate);
	CharacterCreateAlternateFormBottom:SetChecked(alternate);

	if (C_CharacterCreation.IsViewingAlteredForm() ~= alternate) then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
		SetViewingAlteredForm(alternate);
		CharacterCreate_PrepPreviewModels(true);
		CharacterCreate_ResetFeaturesDisplay();
	end
end

-- pandaren stuff related to faction change
function CharacterCreate_EnableNextButton(enabled)
	local button = CharCreateOkayButton;
	button:SetEnabled(enabled);
	button.Arrow:SetDesaturated(not enabled);
	button.TopGlow:SetShown(enabled);
	button.BottomGlow:SetShown(enabled);
end

function CharacterCustomizationFrame_OnShow ()
	-- reset size/tex coord to default to facilitate switching between genders for Pandaren
	CharacterCustomizationFrameBanner:SetSize(BANNER_DEFAULT_SIZE[1], BANNER_DEFAULT_SIZE[2]);
	CharacterCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], BANNER_DEFAULT_TEXTURE_COORDS[3], BANNER_DEFAULT_TEXTURE_COORDS[4]);

	-- check each button and hide it if there are no values select
	local resize = 0;
	local lastGood = 0;
	local isSkinVariantHair = C_CharacterCreation.GetSkinVariationIsHairColor();
	local isDefaultSet = 0;
	local checkedButton = 1;
	
	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1;
	end
	for i=1, NUM_CHAR_CUSTOMIZATIONS do

		local featureType = i - 1;
		local numVariations = C_CharacterCreation.GetNumFeatureVariations(featureType);

		if numVariations <= 1 and (isSkinVariantHair and featureType == Enum.CharCustomizationType.HairColor) then
			resize = resize + 1;
			_G["CharacterCustomizationButtonFrame"..i]:Hide();
		else
			_G["CharacterCustomizationButtonFrame"..i]:Show();
			_G["CharacterCustomizationButtonFrame"..i]:SetChecked(false); -- we will handle default selection
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( isDefaultSet == 0 and CharacterCreateFrame.customizationType == i) then
				isDefaultSet = 1;
				checkedButton = i;
			end
			-- set your anchor to be the last good, this currently means button 1 HAS to be shown
			if (i > 1) then  
				_G["CharacterCustomizationButtonFrame"..i]:SetPoint( "TOP",_G["CharacterCustomizationButtonFrame"..lastGood]:GetName() , "BOTTOM");
			end
			lastGood = i;
		end
	end

	if (isDefaultSet == 0) then 
		CharacterCreateFrame.customizationType = lastGood;
		checkedButton = lastGood;
	end
	_G["CharacterCustomizationButtonFrame"..checkedButton]:SetChecked(true);

	if (resize > 0) then
		-- we need to resize and remap the banner texture		
		local buttonx, buttony = CharacterCustomizationButtonFrame1:GetSize()
		local screenamount = resize*buttony;
		local frameX, frameY = CharacterCustomizationFrameBanner:GetSize();
		local pctShrink = .2*resize; 
		local uvXDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[2] - BANNER_DEFAULT_TEXTURE_COORDS[1];
		local uvYDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[4] - BANNER_DEFAULT_TEXTURE_COORDS[3];
		local newYUV = pctShrink*uvYDefaultSize + BANNER_DEFAULT_TEXTURE_COORDS[3];
		-- end coord stay the same
		CharacterCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], newYUV, BANNER_DEFAULT_TEXTURE_COORDS[4]);
		CharacterCustomizationFrameBanner:SetSize(frameX, frameY - screenamount);
	end
	
	CharacterCreateRandomizeButton:SetPoint("TOP", _G["CharacterCustomizationButtonFrame"..lastGood]:GetName(), "BOTTOM", 0, 0);
end

function CharacterCreate_PrepPreviewModels(reloadModels)
	local displayFrame = CharacterCreatePreviewFrame;

	-- clear models if rebuildPreviews got flagged
	local rebuildPreviews = displayFrame.rebuildPreviews;
	displayFrame.rebuildPreviews = nil;

	-- need to reload models class was swapped to or from DK
	local _, class = C_CharacterCreation.GetSelectedClass();
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
			C_CharacterCreation.SetPreviewFrame(previewFrame.model:GetName(), index-1);
		end
	end
end

function CharacterCreate_ResetFeaturesDisplay()
	C_CharacterCreation.SetPreviewFramesFeature(CharacterCreateFrame.customizationType-1);
	-- set the previews scrollframe container height
	-- since the first and the last previews need to be in the center position when scrolled all the way
	-- to the top or to the bottom, there will be gaps of height equal to 2 previews on each side
	local numTotalButtons = C_CharacterCreation.GetNumFeatureVariations() + 4;
	CharacterCreatePreviewFrame.scrollFrame.container:SetHeight(numTotalButtons * PREVIEW_FRAME_HEIGHT - PREVIEW_FRAME_Y_OFFSET);	

	for _, previewFrame in pairs(CharacterCreatePreviewFrame.previews) do
		previewFrame.featureType = 0;
	end

	CharacterCreate_DisplayPreviewModels();
end

function CharacterCreate_SelectCustomizationType(newType)
	-- deselect previous type selection
	if ( CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType ~= newType ) then
		_G["CharacterCustomizationButtonFrame"..CharacterCreateFrame.customizationType]:SetChecked(false);
	end
	_G["CharacterCustomizationButtonFrame"..newType]:SetChecked(true);
	CharacterCreateFrame.customizationType = newType;
	CharacterCreate_ResetFeaturesDisplay();

	if (newType > 1) then
		C_CharacterCreation.SetFaceCustomizeCamera(true, false);
	else
		C_CharacterCreation.SetFaceCustomizeCamera(false, false);
	end
end

function CharacterCreateRaceButton_OnEnter(self)
	if self.tooltip == nil then
		return;
	end

	if CharacterCreate.selectedRace == self.raceID then
		return;
	end

	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, -8);
	GlueTooltip:SetText(self.tooltip, nil, 1.0, 1.0, 1.0);
	GlueTooltip:Show();
end

function CharacterCreateRaceButton_OnLeave(self)
	GlueTooltip:Hide();
end

function CharacterCreateClassButton_OnEnter(self)
	if(self.tooltip == nil or string.len(self.tooltip) == 0) then
		return;
	end
	if ( CharacterCreate.selectedClass == self:GetID() ) then
		return;
	end
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT", -3, -5);
	GlueTooltip:SetText(self.tooltip, nil, 1.0, 1.0, 1.0);
	GlueTooltip:Show();
end

function CharacterCreateClassButton_OnLeave(self)
	GlueTooltip:Hide();
end

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;

	UpdateCharacterRaceLabelText();

	--twain SetSelectedRace(id);
	local name, faction = C_CharacterCreation.GetFactionForRace(CharacterCreate.selectedRace);

	-- Set Race
	local race, fileString = C_CharacterCreation.GetNameForRace(CharacterCreate.selectedRace);
	CharacterCreateRaceInfoFrameTitle:SetText(race);
	fileString = strupper(fileString);

	-- Loop over all the ability strings we can find and concatenate them into a giant block.
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	local abilityText = "";
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
	end

	CharacterCreateRaceInfoFrameScrollFrameScrollBar:SetValue(0);
	if ( abilityText and abilityText ~= "" ) then
		CharacterCreateRaceInfoFrameScrollFrameScrollChildInfoText:SetText(_G["RACE_INFO_"..fileString] .. "\n\n");
		CharacterCreateRaceInfoFrameScrollFrameScrollChildBulletText:SetText(abilityText);
	else
		CharacterCreateRaceInfoFrameScrollFrameScrollChildInfoText:SetText(_G["RACE_INFO_"..fileString] .. "\n\n");
		CharacterCreateRaceInfoFrameScrollFrameScrollChildBulletText:SetText("");
	end
	CharacterCreateRaceInfoFrameScrollFrame:UpdateScrollChildRect();

	-- Set backdrop colors based on faction
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	for index, value in ipairs(FRAMES_TO_BACKDROP_COLOR) do
		if _G[value] then
			_G[value]:SetBackdropColor(backdropColor.color:GetRGB());
		end
	end
	
	local bannerColor = BANNER_VERTEX_COLORS[faction];

	CharacterCustomizationFrameBanner:SetVertexColor(bannerColor["r"], bannerColor["g"], bannerColor["b"]);

	SetBackgroundModel(CharacterCreate, C_CharacterCreation.GetCreateBackgroundModel());

	if (C_CharacterCreation.HasAlteredForm()) then
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, WORGEN_RACE_ID, C_CharacterCreation.GetSelectedSex());
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, GILNEAN_RACE_ID, C_CharacterCreation.GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		CharacterCreateAlternateFormTop:SetChecked(not C_CharacterCreation.IsViewingAlteredForm());
		CharacterCreateAlternateFormBottom:SetChecked(C_CharacterCreation.IsViewingAlteredForm());
	else
		CharacterCreateAlternateFormTop:Hide();
		CharacterCreateAlternateFormBottom:Hide();
	end
	
	CharacterCreateEnumerateClasses();
	SetDefaultClass();

	-- Hair customization stuff
	CharacterCreate_UpdateFacialHairCustomization();
	CharacterCreate_UpdateCustomizationOptions();
end

function UpdateCharacterRaceLabelText()
	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharacterCreateRaceButton"..i];
		_G["CharacterCreateRaceButton"..i.."NameFrameText"]:SetText(button.tooltip);
		if ( button.raceID == CharacterCreate.selectedRace ) then
			button:SetChecked(true);
		else
			button:SetChecked(false);
		end
	end
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
	
	local classes = C_CharacterCreation.GetAvailableClasses();

	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharacterCreateClassButton"..i];
		local className = classes[button.classID].name;
		button.nameFrame.text:SetText(className);
		if ( button.classID == id ) then
			button:SetChecked(1);
		else
			button:SetChecked(nil);
		end
	end
	
	--twain SetSelectedClass(id);
	local classData = C_CharacterCreation.GetSelectedClass();
	local abilityIndex = 0;
	local tempText = _G["CLASS_INFO_"..classData.fileName..abilityIndex];
	local abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["CLASS_INFO_"..classData.fileName..abilityIndex];
	end
	CharacterCreateClassInfoFrameTitle:SetText(classData.name);
	CharacterCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);
	CharacterCreateClassInfoFrameScrollFrameScrollChildBulletText:SetText(abilityText);	
	CharacterCreateClassInfoFrameScrollFrameScrollChildInfoText:SetText(_G["CLASS_"..strupper(classData.fileName)] .. "\n\n");
	CharacterCreateClassInfoFrameScrollFrame:UpdateScrollChildRect();
	
	UpdateGlueTag();
end

function SetCharacterGender(sex)
	C_CharacterCreation.SetSelectedSex(sex);

	if ( sex == Enum.UnitSex.Male ) then
		CharacterCreateGenderButtonMale:SetChecked(true);
		CharacterCreateGenderButtonFemale:SetChecked(false);
	else
		CharacterCreateGenderButtonMale:SetChecked(false);
		CharacterCreateGenderButtonFemale:SetChecked(true);
	end

	if (SetCharacterGenderAppend) then
		SetCharacterGenderAppend(sex);
	end
	
	--twain SetSelectedSex(id);
	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces();

	-- Update facial hair customization since gender can affect this
	CharacterCreate_UpdateFacialHairCustomization();

	-- Update right hand race portrait to reflect gender change
	-- Set Race
	if (CharacterCreate.selectedRace > 0) then
		UpdateCharacterRaceLabelText();
	end

	if (C_CharacterCreation.HasAlteredForm()) then
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, WORGEN_RACE_ID, sex);
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, GILNEAN_RACE_ID, sex);
	end

	-- Update class labels to reflect gender change
	-- Set Class
	CharacterCreateEnumerateClasses(); -- Update class tooltips.

	-- Update preview models if on customization step
	if ( CharacterCreatePreviewFrame:IsShown() ) then
		CharacterCustomizationFrame_OnShow();
		CharacterCreate_PrepPreviewModels();
		CharacterCreate_ResetFeaturesDisplay();
	end
end

function CharacterCreate_UpdateFacialHairCustomization()
	local facialHairType = C_CharacterCreation.GetCustomizationDetails(4);
	if ( facialHairType == "" ) then
		CharacterCustomizationButtonFrame5:Hide();
		CharacterCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -2);
	else
		CharacterCustomizationButtonFrame5Text:SetText(facialHairType);
		CharacterCustomizationButtonFrame5:Show();
		CharacterCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -2);
	end
end

function SetViewingAlteredForm(alternateForm)
	C_CharacterCreation.SetViewingAlteredForm(alternateForm);
	CharacterCreate_UpdateCustomizationOptions();
	CharacterCustomizationFrame_OnShow();
end

function CheckSelfFoundButton()
	-- Not implemented
end

function CharacterCreate_CancelReincarnation()
	-- Not implemented
end

local ANIMATION_SPEED = 5;
function CharacterCreatePreviewFrame_OnUpdate(self, elapsed)
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
			CharacterCreate_DisplayPreviewModels(self.currentIndex);
		end
		if ( self.currentIndex == self.endIndex ) then
			self.animating = false;
			CharacterCreate_DisplayPreviewModels();
			if ( self.queuedIndex ) then
				local newIndex = self.queuedIndex;
				self.queuedIndex = nil;
				C_CharacterCreation.SelectFeatureVariation(newIndex-1);
				CharacterCreatePreviewFrame_UpdateStyleButtons();
				CharacterCreatePreviewFrame_StartAnimating(self.endIndex, newIndex);	
			end
		end
	end
	CharacterCreateWhileMouseDown_Update(elapsed);
end

function CharacterCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharacterCreatePreviewFrame;
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex;
		end
	else
		local startIndex = C_CharacterCreation.GetSelectedFeatureVariation()+1;
		C_CharacterCreation.SelectFeatureVariation(endIndex-1);
		CharacterCreatePreviewFrame_UpdateStyleButtons();
		CharacterCreatePreviewFrame_StartAnimating(startIndex, endIndex);
	end
end

function CharacterCreate_DisplayPreviewModels(selectionIndex)
	if ( not selectionIndex ) then
		selectionIndex = C_CharacterCreation.GetSelectedFeatureVariation()+1;
	end

	local displayFrame = CharacterCreatePreviewFrame;
	local previews = displayFrame.previews;
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
	local currentFeatureType = CharacterCreateFrame.customizationType;

	local race = C_CharacterCreation.GetSelectedRace();
	local gender = C_CharacterCreation.GetSelectedSex();
	
	-- HACK: Worgen fix for portrait camera position
	local cameraID = 0;
	if ( race == WORGEN_RACE_ID and gender == Enum.UnitSex.Male and not C_CharacterCreation.IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	-- get data for target/camera/light
	local _, raceFileName = C_CharacterCreation.GetNameForRace(race);
	if ( C_CharacterCreation.IsViewingAlteredForm() ) then
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
				previewFrame = CreateFrame("FRAME", "PreviewFrame"..index, displayFrame.scrollFrame.container, "CharacterCreatePreviewFrameTemplate");
				-- index + 1 because of 2 gaps at the top and -1 for the current preview
				previewFrame:SetPoint("TOPLEFT", PREVIEW_FRAME_X_OFFSET, (index + 1) * -PREVIEW_FRAME_HEIGHT + PREVIEW_FRAME_Y_OFFSET);
				previewFrame.button.index = index;
				previews[index] = previewFrame;
				C_CharacterCreation.SetPreviewFrame(previewFrame.model:GetName(), index-1);
			end
			-- load model if needed, may have been cleared by different race/gender selection
			if ( previewFrame.race ~= race or previewFrame.gender ~= gender ) then
				C_CharacterCreation.UpdatePreviewFrameModel(index-1);
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

				local light = CharacterCreate_CreateLight(config.light);

				model:SetLight(true, light);
			end
			-- need to reset the model if it was last used to preview a different feature
			if ( previewFrame.featureType ~= currentFeatureType ) then
				C_CharacterCreation.UpdatePreviewFrameModel(index-1);
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
	CharacterCreate_RotatePreviews();
	CharacterCreatePreviewFrame_UpdateStyleButtons();
	-- scroll to center the selection
	if ( not displayFrame.animating ) then
		displayFrame.scrollFrame:SetVerticalScroll((selectionIndex - 1) * PREVIEW_FRAME_HEIGHT);
	end
end

function CharacterCreatePreviewFrameButton_OnClick(self)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharacterCreatePreviewFrame_SelectFeatureVariation(self.index);
end

function CharacterCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = C_CharacterCreation.GetSelectedFeatureVariation()+1;
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
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

function CharacterCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	local self = CharacterCreatePreviewFrame;
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

function CharacterCreatePreviewFrame_StopAnimating()
	local self = CharacterCreatePreviewFrame;
	if ( self.animating ) then
		self.animating = false;
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

function CharacterCreate_ChangeFeatureVariation(delta)
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
	local startIndex = C_CharacterCreation.GetSelectedFeatureVariation()+1;
	local endIndex = startIndex + delta;
	if ( endIndex < 1 or endIndex > numVariations ) then
		return;
	end
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharacterCreatePreviewFrame_SelectFeatureVariation(endIndex);
end

function CharacterCreateWhileMouseDown_Update(elapsed)
	if ( KeepScrolling ) then
		TotalTime = TotalTime + elapsed;
		if ( TotalTime >= TIME_TO_SCROLL ) then
			CharacterCreate_ChangeFeatureVariation(KeepScrolling);
			TIME_TO_SCROLL = 0.25;
			TotalTime = 0;
		end
	end
end

CharacterCreateIconButtonMixin = {};
CharacterCreateScrollFrameMixin = {};

function CharacterCreateIconButtonMixin:OnMouseDown()
    local shadowSizeDown = self.shadowSizeDown or 52

    if self:IsEnabled() then
        self.bevel:SetPoint("CENTER", self, "CENTER", 2, -2);
        self.shadow:SetSize(shadowSizeDown, shadowSizeDown);
    end
end

function CharacterCreateIconButtonMixin:OnMouseUp()
    local shadowSizeUp = self.shadowSizeUp or 58

    if self:IsEnabled() then
        self.bevel:SetPoint("CENTER", self, "CENTER", 0, 0);
        self.shadow:SetSize(shadowSizeUp, shadowSizeUp);
    end
end

function CharacterCreate_MoreInfoToggle(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (self.infoShown) then
		self.infoShown = nil;
		CharacterCreateMoreInfoButtonTopGlow:Hide();
		CharacterCreateMoreInfoButtonBottomGlow:Hide();
		CharacterCreateRaceInfoFrame:Hide();
		CharacterCreateClassInfoFrame:Hide();
	else
		self.infoShown = true;
		CharacterCreateMoreInfoButtonTopGlow:Show();
		CharacterCreateMoreInfoButtonBottomGlow:Show();
		CharacterCreateRaceInfoFrame:Show();
		CharacterCreateClassInfoFrame:Show();
	end
end

function CharacterCreateScrollFrameMixin:OnLoad()
	CharacterCreateRaceScrollFrameScrollBar:ClearAllPoints();
	CharacterCreateRaceScrollFrameScrollBar:SetPoint("TOPLEFT", CharacterCreateRaceScrollFrame, "TOPRIGHT", 7, 4);
	CharacterCreateRaceScrollFrameScrollBar:SetPoint("BOTTOMLEFT", CharacterCreateRaceScrollFrame, "BOTTOMRIGHT", 7, 12);
	GlueScrollFrame_OnScrollRangeChanged(self);
end

function CharacterCreateScrollFrameMixin:OnScrollRangeChanged(xrange, yrange)
	GlueScrollFrame_OnScrollRangeChanged(self, yrange);
end