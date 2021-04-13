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
	["IconBorder"] = "CovenantSanctum-Upgrade-Icon-Border-%s",
};

local abilityFrameTextureKitRegions = { 
	["Border"] = "covenantchoice-offering-ability-frame-%s",
}

local featureButtonTextureKitRegions = {
	["NormalTexture"] = "covenantsanctum-icon-border-%s",
};

local soulbindAtlasTexture = "covenantchoice-offering-portrait-%s-%s";

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
	self.SoulbindButtonsPool = CreateFramePool("BUTTON", self.InfoPanel, "CovenantSoulbindButtonTemplate");
end 

function CovenantPreviewFrameMixin:OnShow()
	self:RegisterEvent("COVENANT_PREVIEW_CLOSE");
	self:RegisterEvent("PLAYER_CHOICE_CLOSE");
	UpdateScaleForFit(self); 
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
		self:Hide();
	end 
end 

function CovenantPreviewFrameMixin:HandleEscape()
	self:Hide();
end 

function CovenantPreviewFrameMixin:Reset()
	self.lastAbility = nil;
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
	return firstValue < secondValue;
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

	
	if (covenantInfo.covenantSoulbinds and #covenantInfo.covenantSoulbinds > 1) then
		table.sort(covenantInfo.covenantSoulbinds, function(a, b) 
			return CovenantPreviewSortFunction(a.sortOrder, b.sortOrder); 
		end);
	end 

	self:SetupAbilityButtons(covenantInfo.covenantAbilities);
	self:SetupSoulbindButtons(covenantInfo.covenantSoulbinds);
	self:SetupCovenantInfoPanel(covenantInfo); 
	self:SetupCovenantFeature(covenantInfo.featureInfo) 
	self:Show();
end 

function CovenantPreviewFrameMixin:SetupCovenantFeature(covenantFeatureInfo) 
	local featureButton = self.InfoPanel.CovenantFeatureFrame.CovenantFeatureButton
	self:SetupTextureKits(featureButton, featureButtonTextureKitRegions);
	featureButton:Setup(covenantFeatureInfo); 
end 

function CovenantPreviewFrameMixin:SetupAbilityButtons(covenantAbilities)
	self:SetupTextureKits(self.InfoPanel.AbilitiesFrame, abilityFrameTextureKitRegions);
	self.lastAbility = nil;
	self.AbilityButtonsPool:ReleaseAll(); 
	for abilityIndex, ability in ipairs(covenantAbilities) do 
		self.lastAbility = self:SetupAndGetAbilityButton(abilityIndex, ability);
	end 
end 

function CovenantPreviewFrameMixin:SetupAndGetAbilityButton(index, abilityInfo)
	local abilityButton = self.AbilityButtonsPool:Acquire(); 

	if(not self.lastAbility) then 
		abilityButton:SetPoint("TOP", self.InfoPanel.AbilitiesFrame.Border, "TOP", 0, -23); 
	else 
		abilityButton:SetPoint("TOP", self.lastAbility, "BOTTOM", 0, -3);
	end		

	self:SetupTextureKits(abilityButton, abilityButtonTextureKitRegions);
	abilityButton:SetupButton(abilityInfo);
	return abilityButton;
end 


function CovenantPreviewFrameMixin:SetupSoulbindButtons(soulbinds)
	self.lastSoulbind = nil;
	self.SoulbindButtonsPool:ReleaseAll(); 
	for soulbindIndex, soulbind in ipairs(soulbinds) do 
		self.lastSoulbind = self:SetupAndGetSoulbindButton(soulbindIndex, soulbind);
	end 
end 

function CovenantPreviewFrameMixin:SetupAndGetSoulbindButton(index, soulbindInfo)
	local soulbindButton = self.SoulbindButtonsPool:Acquire(); 

	if(not self.lastSoulbind) then 
		soulbindButton:SetPoint("LEFT", self.InfoPanel.SoulbindsFrame, "LEFT", 0, 10); 
	else 
		soulbindButton:SetPoint("LEFT", self.lastSoulbind, "RIGHT", -20, 0);
	end		
	local soulbindButtonAtlas = soulbindAtlasTexture:format(self.uiTextureKit, soulbindInfo.uiTextureKit); 
	if(soulbindButtonAtlas) then 
		soulbindButton.Icon:SetAtlas(soulbindAtlasTexture:format(self.uiTextureKit, soulbindInfo.uiTextureKit))
	end 
	soulbindButton:SetupButton(soulbindInfo);
	return soulbindButton;
end 

function CovenantPreviewFrameMixin:SetupModelSceneFrame(transmogSetID, mountID)
	self:SetupTextureKits(self.ModelSceneContainer, modelSceneContainerTextureKitRegions);

	SetUpTransmogAndMountDressupFrame(self.ModelSceneContainer, transmogSetID, mountID, 414, 432, "CENTER", "CENTER", 0 , 0, true); 
	local sources = C_TransmogSets.GetAllSourceIDs(transmogSetID);
	DressUpTransmogSet(sources, TransmogAndMountDressupFrame);
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
	EmbeddedItemTooltip:Hide();
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

	self.Icon:SetTexture(spellIcon);
	self:Show();
end 

CovenantFeatureButtonMixin = { };

function CovenantFeatureButtonMixin:Setup(covenantFeatureInfo)
	self.Icon:SetTexture(covenantFeatureInfo.texture);
	self.name = covenantFeatureInfo.name; 
	self.description = covenantFeatureInfo.description;
end 

function CovenantFeatureButtonMixin:OnEnter()
	EmbeddedItemTooltip:Hide();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -30, -30);
	GameTooltip_AddHighlightLine(GameTooltip, self.name); 
	GameTooltip_AddNormalLine(GameTooltip, self.description);
	GameTooltip:Show(); 
end 

function CovenantFeatureButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

CovenantSoulbindButtonMixin = { };
function CovenantSoulbindButtonMixin:SetupButton(soulbindInfo) 
	self.spellID = soulbindInfo.spellID; 
	self.name = soulbindInfo.name
	self:Show();
end 

function CovenantSoulbindButtonMixin:OnEnter() 
	if(not self:IsMouseOver()) then 
		return; 
	end

	GameTooltip:Hide(); 

	local spell = Spell:CreateFromSpellID(self.spellID);
	self.spellDataLoadedCancelCallback = spell:ContinueWithCancelOnSpellLoad(function()
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -10);
		GameTooltip_AddHighlightLine(EmbeddedItemTooltip, self.name);
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip); 
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, COVENANT_PREVIEW_SOULBIND_SPELL_INTRO);
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip); 
		EmbeddedItemTooltip_SetSpellWithTextureByID(EmbeddedItemTooltip.ItemTooltip, self.spellID, spell:GetSpellTexture());
		EmbeddedItemTooltip:Show();
		self.spellDataLoadedCancelCallback = nil;
	end);
end

function CovenantSoulbindButtonMixin:OnLeave() 
	EmbeddedItemTooltip:Hide();
	if self.spellDataLoadedCancelCallback then
		self.spellDataLoadedCancelCallback();
		self.spellDataLoadedCancelCallback = nil;
	end
end

CovenantPreviewModelSceneContainerMixin = { };
function CovenantPreviewModelSceneContainerMixin:ShouldAcceptDressUp()
	return false;
end