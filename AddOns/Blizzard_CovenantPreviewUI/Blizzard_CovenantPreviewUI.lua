local MAX_ABILITIES_IN_ROW = 2; 

local backgroundTextureKitRegions = {
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
};

local titleTextureKitRegions = {
	["Left"] = "UI-Frame-%s-TitleLeft",
	["Right"] = "UI-Frame-%s-TitleRight",
	["Middle"] = "_UI-Frame-%s-TitleMiddle",
}

local abilityTypeText = {
	[Enum.CovenantAbilityType.Class] = COVENANT_PREVIEW_CLASS_ABILITY, 
	[Enum.CovenantAbilityType.Racial] = COVENANT_PREVIEW_RACIAL_ABILITY, 
}

local covenantNineSlice = {
	["Oribos"] = "Oribos",
}

CovenantPreviewFrameMixin = { }; 
function CovenantPreviewFrameMixin:OnLoad() 
	self.AbilityButtonsPool = CreateFramePool("BUTTON", self.InfoPanel, "CovenantAbilityButtonTemplate");
end 

function CovenantPreviewFrameMixin:OnShow()
	self:RegisterEvent("COVENANT_PREVIEW_CLOSE");
end

function CovenantPreviewFrameMixin:OnHide()
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
end 

function CovenantPreviewFrameMixin:SetupTextureKits(frame, regions)
	SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

function CovenantPreviewFrameMixin:SetupFramesWithTextureKit()
	local nineSliceLayout = covenantNineSlice[self.uiTextureKit];

	if(self.uiTextureKit and nineSliceLayout) then 
		NineSliceUtil.ApplyLayoutByName(self.BorderFrame, nineSliceLayout);
	end

	self:SetupTextureKits(self.Title, titleTextureKitRegions);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions);
end

function CovenantPreviewFrameMixin:TryShow(covenantInfo)
	if(not covenantInfo) then
		return; 
	end 

	self:Reset();
	self.uiTextureKit = covenantInfo.textureKit; 
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
		abilityButton:SetPoint("TOP", self.InfoPanel.Description, "BOTTOMLEFT", 0, -20); 
		self.previousRowOption = abilityButton; 
	elseif (mod(index - 1, MAX_ABILITIES_IN_ROW) == 0) then
		abilityButton:SetPoint("TOP", self.previousRowOption, "BOTTOM", 0, -20);
		self.previousRowOption = abilityButton; 
	else 
		abilityButton:SetPoint("LEFT", self.lastAbility, "RIGHT", 50, 0);
	end		

	abilityButton:SetupButton(abilityInfo);
	return abilityButton;
end 

function CovenantPreviewFrameMixin:SetupModelSceneFrame(transmogSetID, mountID)
	SetUpTransmogAndMountDressupFrame(self.ModelSceneContainer, transmogSetID, mountID, 400, 500, "CENTER", "CENTER", 0 , 0); 
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
