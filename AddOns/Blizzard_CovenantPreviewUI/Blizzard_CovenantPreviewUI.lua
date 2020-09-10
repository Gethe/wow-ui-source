local MAX_ABILITIES_IN_ROW = 2; 
local PLAYER_CHOICE_TEXTURE_KIT = "Oribos";


local closeButtonBorder = {
	["NightFae"] = {
		closeButtonX = -2,
		closeButtonY = 0,
		closeBorderX = -1,
		closeBorderY = 1,
	},
	["Kyrian"] = { 
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = -1,
		closeBorderY = 1,
	},
	["Venthyr"] = { 
		closeButtonX = 0,
		closeButtonY = 0,
		closeBorderX = -1,
		closeBorderY = 1,
	},
	["Necrolord"] = { 
		closeButtonX = -1,
		closeButtonY = 0,
		closeBorderX = 0,
		closeBorderY = 1,
	},
}

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
	[Enum.CovenantAbilityType.Signature] = COVENANT_PREVIEW_RACIAL_ABILITY, 
}

CovenantPreviewFrameMixin = { }; 
function CovenantPreviewFrameMixin:OnLoad() 
	self.AbilityButtonsPool = CreateFramePool("BUTTON", self.InfoPanel, "CovenantAbilityButtonTemplate");
end 

function CovenantPreviewFrameMixin:OnShow()
	self:RegisterEvent("COVENANT_PREVIEW_CLOSE");
	self:RegisterEvent("PLAYER_CHOICE_CLOSE");
end

function CovenantPreviewFrameMixin:OnHide()
	if(self.showingFromPlayerChoice) then 
		PlayerChoiceFrame.BlackBackground:Hide(); 
	end 

	self:Reset(); 
	self:UnregisterEvent("COVENANT_PREVIEW_CLOSE");
	self:UnregisterEvent("PLAYER_CHOICE_CLOSE");
	C_CovenantPreview.CloseFromUI(); 
end 

function CovenantPreviewFrameMixin:OnEvent(event, ...) 
	if (event == "COVENANT_PREVIEW_CLOSE" or event =="PLAYER_CHOICE_CLOSE") then
		HideUIPanel(self);
	end 
end 

function CovenantPreviewFrameMixin:HandleEscape()
	if (self.showingFromPlayerChoice and PlayerChoiceFrame and PlayerChoiceFrame:IsShown()) then 
		HideUIPanel(PlayerChoiceFrame);
	end 
	HideUIPanel(self);
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

	if (not self.showingFromPlayerChoice and self.uiTextureKit) then 
		NineSliceUtil.ApplyUniqueCornersLayout(self.BorderFrame, self.uiTextureKit);
	end
	self.BorderFrame:SetShown(not self.showingFromPlayerChoice);
	self.CloseButton:SetShown(not self.showingFromPlayerChoice);
	self.SelectButton:SetShown(self.showingFromPlayerChoice);
	self:SetupTextureKits(self.InfoPanel, infoPanelTextureKitRegions);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions, self.uiTextureKit);

	local layout = closeButtonBorder[self.uiTextureKit];
	self.CloseButton:ClearAllPoints(); 
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layout.closeButtonX, layout.closeButtonY);
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", layout.closeBorderX, layout.closeBorderY, self.uiTextureKit);

	if(self.showingFromPlayerChoice) then 
		self:SetupTextureKits(self.Title, titleTextureKitRegions, PLAYER_CHOICE_TEXTURE_KIT);
	else 
		self:SetupTextureKits(self.Title, titleTextureKitRegions, self.uiTextureKit);
	end 

	if(PlayerChoiceFrame) then 
		PlayerChoiceFrame.BlackBackground:SetShown(self.showingFromPlayerChoice);
	end 

	self.Background:SetShown(not self.showingFromPlayerChoice);
end

local function CovenantPreviewSortFunction(firstValue, secondValue)
	return firstValue > secondValue;
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
	
	if (covenantInfo.covenantAbilities and #covenantInfo.covenantAbilities > 1) then
		table.sort(covenantInfo.covenantAbilities, function(a, b) 
			return CovenantPreviewSortFunction(a.type, b.type); 
		end);
	end 

	self:SetupAbilityButtons(covenantInfo.covenantAbilities);
	self:SetupCovenantInfoPanel(covenantInfo); 
	ShowUIPanel(self); 
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
	SetUpTransmogAndMountDressupFrame(self.ModelSceneContainer, transmogSetID, mountID, 414, 432, "CENTER", "CENTER", 0 , 0, true); 
	local sources = C_TransmogSets.GetAllSourceIDs(transmogSetID);
	DressUpTransmogSet(sources);

	TransmogAndMountDressupFrame:RemoveWeapons(); 
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
