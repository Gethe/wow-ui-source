
local TALENTS_LAYOUT = {
	[1] = { row = 1, links = { }, talentType = RELIC_TALENT_TYPE_NEUTRAL },
	[2] = { row = 2, links = { 1 }, talentType = RELIC_TALENT_TYPE_VOID },
	[3] = { row = 2, links = { 1 }, talentType = RELIC_TALENT_TYPE_LIGHT },
	[4] = { row = 3, links = { 2 }, talentType = RELIC_TALENT_TYPE_VOID },
	[5] = { row = 3, links = { 2, 3 }, talentType = RELIC_TALENT_TYPE_NEUTRAL },
	[6] = { row = 3, links = { 3 }, talentType = RELIC_TALENT_TYPE_LIGHT },
};

local TALENT_MODEL_SCENE_ID = 61;
local LIGHT_EFFECT_MODEL_ID = 166335;
local VOID_EFFECT_MODEL_ID = 953305;

local TALENT_TYPES = {
	[RELIC_TALENT_TYPE_LIGHT] =		{ 	stones = { key = "LightStones", template = "ArtifactRelicTalentLightStonesTemplate" },
										glow = "Lighttrait-glow",
										backGlow = "Lighttrait-backglow",
										border = "Lighttrait-border",
										effectTag = "lightEffect",
										effectID = LIGHT_EFFECT_MODEL_ID,
										activationTextures = {
											BigWhirls = "ArtifactsFX-Whirls",
											SpinningGlows = "ArtifactsFX-SpinningGlowys",
											SpinningGlows2 = "ArtifactsFX-SpinningGlowys",
											RingGlow = "ArtifactsFX-YellowRing",
											RingBurst = "ArtifactsFX-YellowRing",
											StarBurst = "ArtifactsFX-StarBurst",
											PointBurstLeft = "ArtifactsFX-PointSideBurstLeft",
											PointBurstRight = "ArtifactsFX-PointSideBurstRight",
										},
									},
	[RELIC_TALENT_TYPE_VOID] =		{ 	stones = { key = "DarkStones", template = "ArtifactRelicTalentVoidStonesTemplate" },
										glow = "Darktrait-glow",
										backGlow = "Darktrait-backglow",
										border = "Darktrait-border",
										effectTag = "voidEffect",
										effectID = VOID_EFFECT_MODEL_ID,
										activationTextures = {
											BigWhirls = "ArtifactsFX-Whirls-Purple",
											SpinningGlows = "ArtifactsFX-SpinningGlowys-Purple",
											SpinningGlows2 = "ArtifactsFX-SpinningGlowys-Purple",
											RingGlow = "ArtifactsFX-YellowRing-Purple",
											RingBurst = "ArtifactsFX-YellowRing-Purple",
											StarBurst = "ArtifactsFX-StarBurst-Purple",
											PointBurstLeft = "ArtifactsFX-PointSideBurstLeft-Purple",
											PointBurstRight = "ArtifactsFX-PointSideBurstRight-Purple",
										},
									},
	[RELIC_TALENT_TYPE_NEUTRAL] =	{ 	border = "Mixedtrait-border" },
};

local TALENT_STYLES = {
	[RELIC_TALENT_STYLE_CLOSED] = 		{ borderDesaturated = true, iconDesaturated = true, showStones = false, glowAnim = false, showModelScene = false },
	[RELIC_TALENT_STYLE_OPEN] = 		{ borderDesaturated = false, iconDesaturated = false, showStones = false, glowAnim = false, showModelScene = false },
	[RELIC_TALENT_STYLE_AVAILABLE] =	{ borderDesaturated = false, iconDesaturated = false, showStones = true, glowAnim = true, showModelScene = true  },
	[RELIC_TALENT_STYLE_CHOSEN] = 		{ borderDesaturated = false, iconDesaturated = false, showStones = false, glowAnim = false, showModelScene = false },
};

local LINK_STYLES = {
	[RELIC_TALENT_LINK_STYLE_DISABLED] =	{ ActiveTexture = false, DisabledTexture = true, AnimFrame = false },
	[RELIC_TALENT_LINK_STYLE_POTENTIAL] =	{ ActiveTexture = false, DisabledTexture = false, AnimFrame = true },
	[RELIC_TALENT_LINK_STYLE_ACTIVE] =		{ ActiveTexture = true, DisabledTexture = false, AnimFrame = false },
};

local PREVIEW_RELIC_SLOT = 4;

UIPanelWindows["ArtifactRelicForgeFrame"] =		{ area = "left",	pushable = 0, xoffset = 35, yoffset = -9, bottomClampOverride = 100, showFailedFunc = C_ArtifactRelicForgeUI.Clear, };

-- ===========================================================================================================================
ArtifactRelicForgeMixin = {};

function ArtifactRelicForgeMixin:OnLoad()
	self.Inset:SetPoint("TOPLEFT", 20, -170);
	self.Inset:SetPoint("BOTTOMRIGHT", -24, 26);

	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideButtonBar(self);
	self.Inset:Hide();
	self.TopTileStreaks:Hide();

	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, self.Talent1, self.Talent2);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, self.Talent1, self.Talent3);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, self.Talent2, self.Talent4);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, self.Talent2, self.Talent5);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, self.Talent3, self.Talent5);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, self.Talent3, self.Talent6);

	self.activationFramesPool = CreateFramePool("FRAME", self, "ArtifactRelicTalentActivationFrameTemplate", function(pool, activationFrame) activationFrame:OnReset(pool); end);

	-- neutral talent activation is same as light
	TALENT_TYPES[RELIC_TALENT_TYPE_NEUTRAL].activationTextures = TALENT_TYPES[RELIC_TALENT_TYPE_LIGHT].activationTextures;
end

function ArtifactRelicForgeMixin:OnShow()
	self:RegisterEvent("ARTIFACT_RELIC_TALENT_ADDED");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	self:SetRelicSlot(1);
	self:RefreshAll();
end

function ArtifactRelicForgeMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_RELIC_TALENT_ADDED");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED");
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	C_ArtifactRelicForgeUI.Clear();
	self:ClearActivations();
end

function ArtifactRelicForgeMixin:OnEvent(event, ...)
	if ( event == "ARTIFACT_RELIC_TALENT_ADDED" ) then
		self:RefreshTalents();
	elseif ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		for i, talentButton in ipairs(self.Talents) do
			if ( talentButton.ModelScene ) then
				talentButton.ModelScene.effectID = nil;
			end
		end
		self:RefreshTalents();
	elseif ( event == "ARTIFACT_RELIC_FORGE_UPDATE" ) then
		self:RefreshAll();
	elseif ( event == "ARTIFACT_RELIC_FORGE_CLOSE" ) then
		HideUIPanel(self);
	elseif ( event == "ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED" ) then
		local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
		if ( relicItemID ) then
			self:SetRelicSlot(PREVIEW_RELIC_SLOT);
		else
			self:SetRelicSlot(1);
		end
	end
end

function ArtifactRelicForgeMixin:CreateLink(linkType, fromButton, toButton)
	local template = (linkType == RELIC_TALENT_LINK_TYPE_LIGHT and "ArtifactRelicTalentLightLinkTemplate") or "ArtifactRelicTalentVoidLinkTemplate";
	local link = CreateFrame("FRAME", nil, self, template);
	link:SetUp(fromButton, toButton);
end

function ArtifactRelicForgeMixin:SetRelicSlot(relicSlot)
	if ( self.relicSlot ~= relicSlot ) then
		self:ClearActivations();
	end
	self.relicSlot = relicSlot;
	self:RefreshAll();
end

function ArtifactRelicForgeMixin:ClearActivations()
	for i, talentButton in ipairs(self.Talents) do
		talentButton.isChosen = nil;
	end
	self.activationFramesPool:ReleaseAll();
end

function ArtifactRelicForgeMixin:RefreshAll()
	self.TitleContainer:EvaluateRelics();
	self:RefreshTalents();
	self:RefreshRelics();
	self.PreviewRelicFrame:Update();
end

function ArtifactRelicForgeMixin:RefreshRelics()
	for i, relicSlotButton in ipairs(self.TitleContainer.RelicSlots) do
		if relicSlotButton:GetID() == self.relicSlot then
			local isAttuned, canAttune = C_ArtifactUI.GetRelicAttuneInfo(self.relicSlot)
			relicSlotButton.SelectedCircle:Show();
			relicSlotButton.SelectedGlow:Show();
			relicSlotButton.DarkGlow:Hide();
			relicSlotButton.AttuneButton:SetShown(canAttune);
		else
			relicSlotButton.SelectedCircle:Hide();
			relicSlotButton.SelectedGlow:Hide();
			relicSlotButton.DarkGlow:Show();
			relicSlotButton.AttuneButton:Hide();
		end
	end
end

function ArtifactRelicForgeMixin:RefreshTalents()
	local talents;
	if ( self.relicSlot == PREVIEW_RELIC_SLOT ) then
		talents = C_ArtifactRelicForgeUI.GetPreviewRelicTalents();
	else
		talents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self.relicSlot);
	end

	if ( not talents ) then
		for i, talentButton in ipairs(self.Talents) do
			talentButton:Hide();
		end
		for i, link in ipairs(self.Links) do
			link:SetStyle(RELIC_TALENT_LINK_STYLE_DISABLED);
		end
		return;
	end
	
	for index, talentInfo in ipairs(talents) do
		local talentButton = self.Talents[index];
		talentButton:Show();
		talentButton.powerID = talentInfo.powerID;
		talentButton.IconFrame.Icon:SetTexture(talentInfo.icon);
		talentButton.canChoose = talentInfo.canChoose;
		local isChosenChanged = (talentButton.isChosen == false and talentInfo.isChosen == true);
		talentButton.isChosen = talentInfo.isChosen;
	
		-- TODO: Is there a better way?
		if ( index == 5 ) then
			if ( talents[2].isChosen ) then
				talentButton:SetTalentType(RELIC_TALENT_TYPE_LIGHT);
			elseif ( talents[3].isChosen ) then
				talentButton:SetTalentType(RELIC_TALENT_TYPE_VOID);
			else
				talentButton:SetTalentType(RELIC_TALENT_TYPE_NEUTRAL);
			end
		end

		talentButton:EvaluateStyle();

		if ( isChosenChanged ) then
			local activationFrame = self.activationFramesPool:Acquire();
			activationFrame:SetUpAndPlay(talentButton);
		elseif ( not talentInfo.isChosen and self.activationFrame ) then
			-- another relic was socketed in this slot while an activation anim was playing
			self.activationFrame:Remove();
		end
	end

	for i, link in ipairs(self.Links) do
		link:EvaluateStyle();
	end
end

function ArtifactRelicForgeMixin:HasChoiceInRow(row)
	for i, talentInfo in ipairs(TALENTS_LAYOUT) do
		if ( talentInfo.row == row and self.Talents[i].isChosen ) then
			return true;
		end
	end
	return false;
end

function ArtifactRelicForgeMixin:HasChoiceInSameRowAsTalentButton(button)
	local layoutInfo = button:GetLayoutInfo();
	return self:HasChoiceInRow(layoutInfo.row);
end

function ArtifactRelicForgeMixin:ChooseTalent(index)
	C_ArtifactRelicForgeUI.AddRelicTalent(self.relicSlot, index);
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseEnter()
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseLeave()
end

--========================================================================================================================
ArtifactRelicForgeTitleTemplateMixin = CreateFromMixins(ArtifactTitleTemplateMixin);

function ArtifactRelicForgeTitleTemplateMixin:RefreshTitle()
end

function ArtifactRelicForgeTitleTemplateMixin:ApplyCursorRelicToSlot(relicSlotIndex)
	ArtifactTitleTemplateMixin.ApplyCursorRelicToSlot(self, relicSlotIndex);
	self:GetParent():SetRelicSlot(relicSlotIndex);
end

function ArtifactRelicForgeTitleTemplateMixin:OnRelicSlotClicked(button)
	local relicSlotIndex = button:GetID();
	if ( CursorHasItem() ) then
		local type, itemID, itemLink = GetCursorInfo();
		if ( C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex) ) then
			local itemName = C_ArtifactUI.GetRelicInfo(relicSlotIndex);
			if itemName then
				StaticPopup_Show("CONFIRM_RELIC_REPLACE", nil, nil, { titleContainer = self, relicSlotIndex = relicSlotIndex });
			else
				self:ApplyCursorRelicToSlot(i);
			end
			return;
		end
	end
	if ( C_ArtifactUI.GetRelicInfo(relicSlotIndex) ) then
		self:GetParent():SetRelicSlot(relicSlotIndex);
	end
end

--========================================================================================================================
ArtifactRelicTalentButtonMixin = { };

function ArtifactRelicTalentButtonMixin:OnLoad()
	local layoutInfo = self:GetLayoutInfo();
	self:SetTalentType(layoutInfo.talentType);
end

function ArtifactRelicTalentButtonMixin:OnClick()
	if ( self.canChoose ) then
		self:GetParent():ChooseTalent(self:GetID());
	end
end

function ArtifactRelicTalentButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetArtifactPowerByID(self.powerID);
end

function ArtifactRelicTalentButtonMixin:EvaluateStyle()
	if ( self.isChosen ) then
		self:SetStyle(RELIC_TALENT_STYLE_CHOSEN);
	elseif ( self.canChoose ) then
		self:SetStyle(RELIC_TALENT_STYLE_AVAILABLE);
	else
		self:SetStyle(RELIC_TALENT_STYLE_CLOSED);
	end
end

function ArtifactRelicTalentButtonMixin:SetStyle(style)
	local styleInfo = TALENT_STYLES[style];
	self.IconFrame.Border:SetDesaturated(styleInfo.borderDesaturated);
	self.IconFrame.Icon:SetDesaturated(styleInfo.iconDesaturated);
	if ( styleInfo.glowAnim ) then
		self.GlowAnim:Play();
	else
		self.GlowAnim:Stop();
	end
	if ( self.Stones ) then
		if ( styleInfo.showStones ) then
			self.Stones:Show();
			self.Stones.FloatingAnim:Play();
		else
			self.Stones:Hide();
			self.Stones.FloatingAnim:Stop();
		end
	end
	if ( styleInfo.showModelScene ) then
		local talentTypeInfo = TALENT_TYPES[self.talentType];
		if ( talentTypeInfo.effectTag ) then	
			if ( self.ModelScene.effectID ~= talentTypeInfo.effectID ) then
				self.ModelScene:Show();
				self.ModelScene:SetFromModelSceneID(TALENT_MODEL_SCENE_ID, true);
				local effect = self.ModelScene:GetActorByTag(talentTypeInfo.effectTag);
				if ( effect ) then
					effect:SetModelByFileID(talentTypeInfo.effectID);
					self.ModelScene.effectID = talentTypeInfo.effectID;
				end
			end
		else
			self.ModelScene:Hide();
		end
	else
		self.ModelScene:Hide();
	end
end

function ArtifactRelicTalentButtonMixin:GetLayoutInfo()
	return TALENTS_LAYOUT[self:GetID()];
end

function ArtifactRelicTalentButtonMixin:SetTalentType(talentType)
	if ( self.talentType == talentType ) then
		return;
	end
	self.talentType = talentType;

	local talentTypeInfo = TALENT_TYPES[talentType];
	if ( talentTypeInfo.stones ) then
		if ( not self[talentTypeInfo.stones.key] ) then
			self[talentTypeInfo.stones.key] = CreateFrame("FRAME", nil, self, talentTypeInfo.stones.template);
			self[talentTypeInfo.stones.key]:SetPoint("CENTER");
		end
		-- hide existing stones
		if ( self.Stones ) then
			self.Stones:Hide();
		end
		self.Stones = self[talentTypeInfo.stones.key];
	end
	if ( talentTypeInfo.glow ) then
		self.GlowTexture:SetAtlas(talentTypeInfo.glow, true);
	end
	if ( talentTypeInfo.backGlow ) then
		self.BackGlowTexture:SetAtlas(talentTypeInfo.backGlow, true);
	end
	self.IconFrame.Border:SetAtlas(talentTypeInfo.border);
end

--========================================================================================================================
ArtifactRelicTalentLinkMixin = { };

function ArtifactRelicTalentLinkMixin:SetUp(fromButton, toButton)
	self.fromButton = fromButton;
	self.toButton = toButton;
	if ( self.linkType == RELIC_TALENT_LINK_TYPE_LIGHT ) then
		self:SetPoint("TOPLEFT", fromButton, "BOTTOMRIGHT", -16, 2);
	elseif ( self.linkType == RELIC_TALENT_LINK_TYPE_VOID ) then
		self:SetPoint("TOPRIGHT", fromButton, "BOTTOMLEFT", 16, 2);
	end
end

function ArtifactRelicTalentLinkMixin:EvaluateStyle()
	if ( self.fromButton.isChosen and self.toButton.isChosen ) then
		self:SetStyle(RELIC_TALENT_LINK_STYLE_ACTIVE);
	elseif ( self.fromButton.isChosen and not self:GetParent():HasChoiceInSameRowAsTalentButton(self.toButton) ) then
		self:SetStyle(RELIC_TALENT_LINK_STYLE_POTENTIAL);
	else
		self:SetStyle(RELIC_TALENT_LINK_STYLE_DISABLED);
	end
end

function ArtifactRelicTalentLinkMixin:SetStyle(style)
	local styleInfo = LINK_STYLES[style];
	for key, enabled in pairs(styleInfo) do
		self[key]:SetShown(enabled);
	end
end

--========================================================================================================================
ArtifactRelicForgePreviewRelicMixin = { };

function ArtifactRelicForgePreviewRelicMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
end

function ArtifactRelicForgePreviewRelicMixin:OnShow()
	self:RegisterEvent("ARTIFACT_PENDING_ATTUNE_RELIC_UPDATE");
	self:Update();
end

function ArtifactRelicForgePreviewRelicMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_PENDING_ATTUNE_RELIC_UPDATE");
end

function ArtifactRelicForgePreviewRelicMixin:OnEvent(event, ...)
	self:Update();
end

function ArtifactRelicForgePreviewRelicMixin:OnEnter()
	local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
	if ( relicItemID ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetItemByID(relicItemID);
	end
end

function ArtifactRelicForgePreviewRelicMixin:OnClick(button)
	if ( button == "LeftButton" ) then
		local type, itemID, itemLink = GetCursorInfo();
		if type == "item" and IsArtifactRelicItem(itemID) then
			C_ArtifactRelicForgeUI.SetPreviewRelicFromCursor();
		else
			if ( C_ArtifactRelicForgeUI.GetPreviewRelicItemID() ) then
				self:GetParent():SetRelicSlot(PREVIEW_RELIC_SLOT);
			end
		end
	elseif ( button == "RightButton" ) then
		C_ArtifactRelicForgeUI.ClearPreviewRelic();
	end
end

function ArtifactRelicForgePreviewRelicMixin:Update()
	local isSelected = (self:GetParent().relicSlot == PREVIEW_RELIC_SLOT);
	self.SelectedGlow:SetShown(isSelected);
	local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
	if ( relicItemID ) then
		local itemID, class, subClass, invType, texture = GetItemInfoInstant(relicItemID);
		self.Icon:SetTexture(texture);
		local isAttuned, canAttune = C_ArtifactRelicForgeUI.GetPreviewRelicAttuneInfo();
		self.AttuneButton:SetShown(isSelected and canAttune);
	else
		self.Icon:SetTexture();
		self.AttuneButton:Hide();
	end
end

function ArtifactRelicForgePreviewRelicMixin:OnDragStart()
	C_ArtifactRelicForgeUI.PickUpPreviewRelic();
end

--========================================================================================================================
ArtifactRelicTalentActivationMixin = { };

function ArtifactRelicTalentActivationMixin:SetUpAndPlay(talentButton)
	self:SetPoint("CENTER", talentButton, "CENTER");
	self:Show();
	if ( self.talentType ~= talentButton.talentType ) then
		self.talentType = talentButton.talentType
		for key, atlas in pairs(TALENT_TYPES[self.talentType].activationTextures) do
			self[key]:SetAtlas(atlas, true);
		end
	end
	self.Anim:Stop();
	self.Anim:Play();
	-- linkage
	talentButton.activationFrame = self;
	self.talentButton = talentButton;
end

function ArtifactRelicTalentActivationMixin:Remove()
	self:GetParent().activationFramesPool:Release(self);
end

function ArtifactRelicTalentActivationMixin:OnReset(pool)
	FramePool_HideAndClearAnchors(pool, self);
	-- clear linkage
	if ( self.talentButton ) then
		self.talentButton.activationFrame = nil;
		self.talentButton = nil;
	end
end