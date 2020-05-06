local MAX_ABILITIES_IN_ROW = 2; 

local backgroundTextureKitRegions = {
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
};

local titleTextureKitRegions = {
	["Left"] = "UI-Frame-%s-TitleLeft",
	["Right"] = "UI-Frame-%s-TitleRight",
	["Middle"] = "_UI-Frame-%s-TitleMiddle",
};

local abilityButtonTextureKitRegions = { 
	["Background"] = "CovenantChoice-Offering-Ability-Frame-%s",
	["IconBorder"] = "CovenantChoice-Offering-Ability-Ring-%s",
};

local infoPanelTextureKitRegions = {
	["Parchment"] = "CovenantChoice-Offering-Parchment-%s",
	["Crest"] = "CovenantChoice-Offering-Sigil-%s",
};

local modelSceneContainerTextureKitRegions = {
	["ModelSceneBorder"] = "CovenantChoice-Offering-Preview-Frame-%s",
	["Background"] =  "CovenantChoice-Offering-Preview-Frame-Background-%s",
};

local abilityTypeText = {
	[Enum.CovenantAbilityType.Class] = COVENANT_PREVIEW_CLASS_ABILITY, 
	[Enum.CovenantAbilityType.Racial] = COVENANT_PREVIEW_RACIAL_ABILITY, 
}

--Aubrie TODO fix this up when the artwork for the frames are in.
local covenantNineSlice = {
	["Kyrian"] = "Oribos",
}

CovenantPreviewFrameMixin = { }; 
function CovenantPreviewFrameMixin:OnLoad() 
	self.AbilityButtonsPool = CreateFramePool("BUTTON", self.InfoPanel, "CovenantAbilityButtonTemplate");
end 

function CovenantPreviewFrameMixin:OnShow()
	self:RegisterEvent("COVENANT_PREVIEW_CLOSE");
end

function CovenantPreviewFrameMixin:OnHide()
	if(self.showingFromPlayerChoice) then 
		PlayerChoiceFrame.BlackBackground:Hide(); 
	end 

	self:Reset(); 
	self:UnregisterEvent("COVENANT_PREVIEW_CLOSE");
	C_CovenantPreview.CloseFromUI(); 
end 

function CovenantPreviewFrameMixin:OnEvent(event, ...) 
	if (event == "COVENANT_PREVIEW_CLOSE") then
		HideUIPanel(self);
	end 
end 

function CovenantPreviewFrameMixin:Reset()
	self.lastAbility = nil;
	self.previousRowOption = nil; 
	self.uiTextureKit = nil; 
	self.showingFromPlayerChoice = nil;
end 

function CovenantPreviewFrameMixin:SetupTextureKits(frame, regions, overrideTextureKit)
	if(overrideTextureKit) then 
		SetupTextureKitOnRegions(overrideTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	else
		SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	end 
end 

function CovenantPreviewFrameMixin:SetupFramesWithTextureKit()

	if (not self.showingFromPlayerChoice) then 
		local nineSliceLayout = covenantNineSlice[self.uiTextureKit];

		if(self.uiTextureKit and nineSliceLayout) then 
			NineSliceUtil.ApplyLayoutByName(self.BorderFrame, nineSliceLayout);
		end
	end
	if(self.showingFromPlayerChoice) then 
		PlayerChoiceFrame.BlackBackground:Show(); 
	end 
	self.NineSlice:SetShown(not self.showingFromPlayerChoice);
	self.BorderFrame:SetShown(not self.showingFromPlayerChoice);
	self.CloseButton:SetShown(not self.showingFromPlayerChoice);
	self.SelectButton:SetShown(self.showingFromPlayerChoice);
	self:SetupTextureKits(self.Title, titleTextureKitRegions, nineSliceLayout);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions, nineSliceLayout);
	self:SetupTextureKits(self.InfoPanel, infoPanelTextureKitRegions);
end

function CovenantPreviewFrameMixin:TryShow(covenantInfo)
	if(not covenantInfo) then
		return; 
	end 

	self:Reset();
	self.uiTextureKit = covenantInfo.textureKit; 
	self.showingFromPlayerChoice = covenantInfo.fromPlayerChoice;
	self.Title.Text:SetText(COVENANT_PREVIEW_TITLE:format(covenantInfo.covenantName)); 

	self:SetupFramesWithTextureKit(); 
	self:SetupModelSceneFrame(covenantInfo.transmogSetID, covenantInfo.mountID);
	self:SetupAbilityButtons(covenantInfo.covenantAbilities);
	self:SetupCovenantInfoPanel(covenantInfo); 
	self:Show(); 
end 

function CovenantPreviewFrameMixin:SetupAbilityButtons(covenantAbilities)
	self.lastAbility = nil;
	self.AbilityButtonsPool:ReleaseAll(); 
	for abilityIndex, ability in ipairs(covenantAbilities) do 
		self.lastAbility = self:SetupAndGetAbilityButton(abilityIndex, ability);
	end 
end 

function CovenantPreviewFrameMixin:SetupAndGetAbilityButton(index, abilityInfo)
	local abilityButton = self.AbilityButtonsPool:Acquire(); 

	if(not self.lastAbility) then 
		abilityButton:SetPoint("TOPLEFT", self.InfoPanel.AbilitiesLabel, "BOTTOMLEFT", -5, -15); 
		self.previousRowOption = abilityButton; 
	elseif (mod(index - 1, MAX_ABILITIES_IN_ROW) == 0) then
		abilityButton:SetPoint("TOP", self.previousRowOption, "BOTTOM", 0, -20);
		self.previousRowOption = abilityButton; 
	else 
		abilityButton:SetPoint("LEFT", self.lastAbility, "RIGHT", 30, 0);
	end		

	self:SetupTextureKits(abilityButton, abilityButtonTextureKitRegions);
	abilityButton:SetupButton(abilityInfo);
	return abilityButton;
end 

function CovenantPreviewFrameMixin:SetupModelSceneFrame(transmogSetID, mountID)
	self:SetupTextureKits(self.ModelSceneContainer, modelSceneContainerTextureKitRegions);
	SetUpTransmogAndMountDressupFrame(self.ModelSceneContainer, transmogSetID, mountID, 414, 432, "CENTER", "CENTER", 0 , 0); 
	local sources = C_TransmogSets.GetAllSourceIDs(transmogSetID);
	DressUpTransmogSet(sources);
end 

function CovenantPreviewFrameMixin:SetupCovenantInfoPanel(covenantInfo) 
	local infoPanel = self.InfoPanel; 
	infoPanel.Name:SetText(covenantInfo.covenantName); 
	infoPanel.Location:SetText(COVENANT_PREVIEW_ZONE_HOME:format(covenantInfo.covenantZone));
	infoPanel.Description:SetText(covenantInfo.description);
end 

CovenantAbilityButtonMixin = { }; 
function CovenantAbilityButtonMixin:OnEnter() 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
	GameTooltip:Show(); 
end

function CovenantAbilityButtonMixin:OnLeave() 
	GameTooltip:Hide();
end

function CovenantAbilityButtonMixin:SetupButton(abilityInfo) 
	self.spellID = abilityInfo.spellID; 
	local spellName, _, spellIcon = GetSpellInfo(self.spellID);

	self.Name:SetText(spellName); 
	self.Icon:SetTexture(spellIcon);
	self.Type:SetText(abilityTypeText[abilityInfo.type]); 
	self:Show();
end 
