
local TALENTS_LAYOUT = {
	[1] = { row = 1, links = { }, talentType = RELIC_TALENT_TYPE_NEUTRAL, revealDelay = 0 },
	[2] = { row = 2, links = { 1 }, talentType = RELIC_TALENT_TYPE_VOID, revealDelay = 0.5 },
	[3] = { row = 2, links = { 1 }, talentType = RELIC_TALENT_TYPE_LIGHT, revealDelay = 0.5 },
	[4] = { row = 3, links = { 2 }, talentType = RELIC_TALENT_TYPE_VOID, revealDelay = 1 },
	[5] = { row = 3, links = { 2, 3 }, talentType = RELIC_TALENT_TYPE_NEUTRAL, revealDelay = 1 },
	[6] = { row = 3, links = { 3 }, talentType = RELIC_TALENT_TYPE_LIGHT, revealDelay = 1 },
};

local TALENT_MODEL_SCENE_ID = 61;
local LIGHT_EFFECT_MODEL_ID = 166335;
local VOID_EFFECT_MODEL_ID = 953305;
local NEUTRAL_EFFECT_MODEL_ID = 1381636;
local LINK_REVEAL_EXTRA_DELAY_TIME = 0.5;

local TALENT_TYPES = {
	[RELIC_TALENT_TYPE_LIGHT] =		{ 	stones = { key = "LightStones", template = "ArtifactRelicTalentLightStonesTemplate" },
										glow = "Lighttrait-glow",
										backGlow = "Lighttrait-backglow",
										border = "Lighttrait-border",
										chosenBorder = "Lighttrait-border-selected",
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
										revealTextures = {
											StarBurst = "AftLevelup-WhiteStarBurst",
											Whirls = "ArtifactsFX-Whirls",
											Ring = "ArtifactsFX-YellowRing",
											RingStationary = "ArtifactsFX-YellowRing",
											TraitGlow = "Artifacts-PerkRing-WhiteGlow",
										},
										transitionTextures = {
											SpinningGlows = "ArtifactsFX-SpinningGlowys",
											RingGlow = "ArtifactsFX-YellowRing",
											PointBurstLeft = "ArtifactsFX-PointSideBurstLeft",
											PointBurstRight = "ArtifactsFX-PointSideBurstRight",
										},
										runeSuffix = "light",
									},
	[RELIC_TALENT_TYPE_VOID] =		{ 	stones = { key = "DarkStones", template = "ArtifactRelicTalentVoidStonesTemplate" },
										glow = "Darktrait-glow",
										backGlow = "Darktrait-backglow",
										border = "Darktrait-border",
										chosenBorder = "Darktrait-border-selected",
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
										revealTextures = {
											StarBurst = "AftLevelup-PurpleStarBurst",
											Whirls = "ArtifactsFX-Whirls-Purple",
											Ring = "ArtifactsFX-YellowRing-Purple",
											RingStationary = "ArtifactsFX-YellowRing-Purple",
											TraitGlow = "Artifacts-PerkRing-PurpleGlow",
										},
										transitionTextures = {
											SpinningGlows = "ArtifactsFX-SpinningGlowys-Purple",
											RingGlow = "ArtifactsFX-YellowRing-Purple",
											PointBurstLeft = "ArtifactsFX-PointSideBurstLeft-Purple",
											PointBurstRight = "ArtifactsFX-PointSideBurstRight-Purple",
										},
										runeSuffix = "purple",
									},
	[RELIC_TALENT_TYPE_NEUTRAL] =	{ 	stones = { key = "NeutralStones", template = "ArtifactRelicTalentNeutralStonesTemplate" },
										glow = "Neutraltrait-Glow",
										backGlow = "Neutraltrait-backglow",
										border = "Neutraltrait-border",
										chosenBorder = "Neutraltrait-border-selected",
										effectTag = "neutralEff",
										effectID = NEUTRAL_EFFECT_MODEL_ID,
										runeSuffix = "neutral",
										activationTextures = nil, 	-- set in ArtifactRelicForgeMixin:OnLoad
										revealTextures = {
											StarBurst = "AftLevelup-NeutralStarBurst",
											Whirls = "ArtifactsFX-Whirls-Neutral",
											Ring = "ArtifactsFX-YellowRing-Neutral",
											RingStationary = "ArtifactsFX-YellowRing-Neutral",
											TraitGlow = "Artifacts-PerkRing-NeutralGlow",
										},
										transitionTextures = {
											SpinningGlows = "ArtifactsFX-SpinningGlowys",
											RingGlow = "ArtifactsFX-YellowRing-Neutral",
											PointBurstLeft = "ArtifactsFX-PointSideBurstLeft",
											PointBurstRight = "ArtifactsFX-PointSideBurstRight",
										},
									},
};

local TALENT_STYLES = {
	[RELIC_TALENT_STYLE_CLOSED] = 		{ borderDesaturated = true, iconDesaturated = true, showStones = false, glowAnim = false, showModelScene = false, iconVertexColorLevel = 0.4, borderVertexColorLevel = 1, overrideBorderTexture = "Darktrait-border" },
	[RELIC_TALENT_STYLE_UPCOMING] = 	{ borderDesaturated = false, iconDesaturated = false, showStones = false, glowAnim = false, showModelScene = false, iconVertexColorLevel = 0.5, borderVertexColorLevel = 0.8 },
	[RELIC_TALENT_STYLE_AVAILABLE] =	{ borderDesaturated = false, iconDesaturated = false, showStones = true, glowAnim = true, showModelScene = true, iconVertexColorLevel = 1, borderVertexColorLevel = 1 },
	[RELIC_TALENT_STYLE_CHOSEN] = 		{ borderDesaturated = false, iconDesaturated = false, showStones = false, glowAnim = false, showModelScene = false, iconVertexColorLevel = 1, borderVertexColorLevel = 1 },
};

local LINK_STYLE_ACTIVE_ELEMENT = {
	[RELIC_TALENT_LINK_STYLE_DISABLED]	= "DisabledTexture",
	[RELIC_TALENT_LINK_STYLE_POTENTIAL] = "PotentialTexture",
	[RELIC_TALENT_LINK_STYLE_ACTIVE]	= "ActiveTexture",
	[RELIC_TALENT_LINK_STYLE_UPCOMING]	= "DimTexture",
	[RELIC_TALENT_LINK_STYLE_AVAILABLE] = "AnimFrame",
};

local PREVIEW_RELIC_SLOT = 4;

local LINK_SIDE_LEFT = 1;
local LINK_SIDE_RIGHT = 2;

UIPanelWindows["ArtifactRelicForgeFrame"] =		{ area = "left",	pushable = 0, xoffset = 35, yoffset = -9, bottomClampOverride = 100, showFailedFunc = C_ArtifactRelicForgeUI.Clear, };

StaticPopupDialogs["CONFIRM_RELIC_ATTUNE"] = {
	text = CONFIRM_RELIC_ATTUNE,
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, previewRelicFrame)
		previewRelicFrame:SetRelicFromCursor();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,

	showAlert = true,
	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

StaticPopupDialogs["CONFIRM_RELIC_TALENT"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, data)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RELIC_FORGE_LEARN_TRAIT, true);
		C_ArtifactRelicForgeUI.AddRelicTalent(data.relicSlot, data.talentIndex);
	end,

	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

-- ===========================================================================================================================
ArtifactRelicForgeMixin = {};

function ArtifactRelicForgeMixin:OnLoad()
	self.Inset:SetPoint("TOPLEFT", 20, -170);
	self.Inset:SetPoint("BOTTOMRIGHT", -24, 26);

	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideButtonBar(self);
	self.Inset:Hide();
	self.TopTileStreaks:Hide();

	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, LINK_SIDE_LEFT, self.Talent1, self.Talent2);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, LINK_SIDE_RIGHT, self.Talent1, self.Talent3);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, LINK_SIDE_LEFT, self.Talent2, self.Talent4);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_VOID, LINK_SIDE_RIGHT, self.Talent2, self.Talent5);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, LINK_SIDE_LEFT, self.Talent3, self.Talent5);
	self:CreateLink(RELIC_TALENT_LINK_TYPE_LIGHT, LINK_SIDE_RIGHT, self.Talent3, self.Talent6);

	self.activationFramesPool = CreateFramePool("FRAME", self, "ArtifactRelicTalentActivationFrameTemplate", function(pool, activationFrame) activationFrame:OnReset(pool); end);

	-- neutral talent activation is same as light
	TALENT_TYPES[RELIC_TALENT_TYPE_NEUTRAL].activationTextures = TALENT_TYPES[RELIC_TALENT_TYPE_LIGHT].activationTextures;

	self.revealAnimCounter = 0;
end

function ArtifactRelicForgeMixin:OnShow()
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	self:SetRelicSlot(1);
	self:RefreshAll();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function ArtifactRelicForgeMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED");
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	C_ArtifactRelicForgeUI.Clear();
	self:ClearAnimations();
	self:CloseDialogs();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function ArtifactRelicForgeMixin:OnEvent(event, ...)
	if ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
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
		elseif ( self.relicSlot == PREVIEW_RELIC_SLOT ) then
			self:SetRelicSlot(self.previousSocketedRelicSlot or 1);
		else
			self.PreviewRelicFrame:Update();
		end
	end
end

local TUTORIALS = {
	[1] = { id = LE_FRAME_TUTORIAL_RELIC_FORGE_SOCKETED_RELIC, text = RELIC_FORGE_TUTORIAL_SOCKETED_RELIC, xOffset = 16, yOffset = -121, buttonText = NEXT },
	[2] = { id = LE_FRAME_TUTORIAL_RELIC_FORGE_PREVIEW_RELIC, text = RELIC_FORGE_TUTORIAL_PREVIEW_RELIC, xOffset = 275, yOffset = -121, buttonText = OKAY },
};

function ArtifactRelicForgeMixin:CheckTutorials()
	if ( not self:IsRevealingTalents() and not self:IsPreviewRelicSelected() and C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self.relicSlot) ) then
		for i, tutorialData in ipairs(TUTORIALS) do
			if ( not GetCVarBitfield("closedInfoFrames", tutorialData.id) ) then
				local glowBox = self.TutorialFrame.GlowBox;
				glowBox.Text:SetText(tutorialData.text);
				glowBox:SetHeight(glowBox.Text:GetHeight() + 58);
				glowBox:ClearAllPoints();
				glowBox:SetPoint("TOPLEFT", tutorialData.xOffset, tutorialData.yOffset);
				glowBox.Button:SetText(tutorialData.buttonText);
				self.TutorialFrame.id = tutorialData.id;
				self.TutorialFrame:Show();
				return;
			end
		end
	end
	self.TutorialFrame:Hide();
	self.TutorialFrame.id = nil;
end

function ArtifactRelicForgeMixin:AdvanceTutorial()
	if ( not self.TutorialFrame.id ) then
		return;
	end
	SetCVarBitfield("closedInfoFrames", self.TutorialFrame.id, true);
	self:CheckTutorials();
end

function ArtifactRelicForgeMixin:CloseDialogs()
	StaticPopup_Hide("CONFIRM_RELIC_TALENT");
	StaticPopup_Hide("CONFIRM_RELIC_ATTUNE");
end

function ArtifactRelicForgeMixin:CreateLink(linkType, linkSide, fromButton, toButton)
	local template = (linkType == RELIC_TALENT_LINK_TYPE_LIGHT and "ArtifactRelicTalentLightLinkTemplate") or "ArtifactRelicTalentVoidLinkTemplate";
	local link = CreateFrame("FRAME", nil, self, template);
	link:SetUp(linkSide, fromButton, toButton);
end

function ArtifactRelicForgeMixin:SetRelicSlot(relicSlot)
	if ( self.relicSlot ~= relicSlot ) then
		self.currentRelicAttuned = nil;
		self:ClearAnimations();
		self:CloseDialogs();
		if ( self.relicSlot ~= PREVIEW_RELIC_SLOT ) then
			self.previousSocketedRelicSlot = self.relicSlot;
		end
	end
	self.relicSlot = relicSlot;
	self:RefreshAll();
end

function ArtifactRelicForgeMixin:IsRelicSlotSelected(relicSlot)
	return self.relicSlot == relicSlot;
end

function ArtifactRelicForgeMixin:ClearAnimations()
	for i, talentButton in ipairs(self.Talents) do
		talentButton.isChosen = nil;
		talentButton:StopTriggeredAnimations();
	end
	for i, link in ipairs(self.Links) do
		link:StopTriggeredAnimations();
	end
	self.activationFramesPool:ReleaseAll();
	self.revealAnimCounter = 0;
end

function ArtifactRelicForgeMixin:RefreshAll()
	self.TitleContainer:EvaluateRelics();
	self:RefreshTalents();
	self:RefreshRelics();
	self.PreviewRelicFrame:Update();
	self:CheckTutorials();
end

function ArtifactRelicForgeMixin:RefreshRelics()
	for i, relicSlotButton in ipairs(self.TitleContainer.RelicSlots) do
		if relicSlotButton:GetID() == self.relicSlot then
			local isAttuned, canAttune = C_ArtifactUI.GetRelicAttuneInfo(self.relicSlot)
			relicSlotButton.SelectedCircle:Show();
			relicSlotButton.SelectedGlow:Show();
			relicSlotButton.DarkGlow:Hide();
		else
			relicSlotButton.SelectedCircle:Hide();
			relicSlotButton.SelectedGlow:Hide();
			relicSlotButton.DarkGlow:Show();
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

	local revealTalents = false;
	if ( not talents ) then
		for i, talentButton in ipairs(self.Talents) do
			talentButton:Hide();
		end
		for i, link in ipairs(self.Links) do
			link:SetStyle(RELIC_TALENT_LINK_STYLE_DISABLED);
		end
		C_ArtifactRelicForgeUI.AttuneSocketedRelic(self.relicSlot);
		self.currentRelicAttuned = false;
		return;
	else
		if ( self.currentRelicAttuned == false ) then
			revealTalents = true;
		end
		self.currentRelicAttuned = true;
	end

	local currentRelicRank, canAddTalent = C_ArtifactUI.GetRelicSlotRankInfo(self.relicSlot);
	if ( not currentRelicRank ) then
		currentRelicRank = 0;
	end

	for index, talentInfo in ipairs(talents) do
		local talentButton = self.Talents[index];
		talentButton:Show();
		talentButton.powerID = talentInfo.powerID;
		talentButton.IconFrame.Icon:SetTexture(talentInfo.icon);
		talentButton.canChoose = talentInfo.canChoose;
		local isChosenChanged = (talentButton.isChosen == false and talentInfo.isChosen == true);
		talentButton.isChosen = talentInfo.isChosen;
		local layoutInfo = talentButton:GetLayoutInfo();
		talentButton.isUpcoming = false;
		if ( layoutInfo.row == currentRelicRank + 1 ) then
			if ( #layoutInfo.links == 0 ) then
				talentButton.isUpcoming = true;
			else
				for i, talentIndex in ipairs(layoutInfo.links) do
					if ( self.Talents[talentIndex].isChosen ) then
						talentButton.isUpcoming = true;
						break;
					end
				end
			end
		end

		talentButton:EvaluateTalentType();
		talentButton:EvaluateStyle();

		if ( isChosenChanged ) then
			local activationFrame = self.activationFramesPool:Acquire();
			activationFrame:SetUpAndPlay(talentButton);
			local chosenParent = talentButton:GetChosenParent();
			if ( chosenParent and chosenParent.ConversionBorder ) then
				chosenParent.ConversionBorder.Anim:Play();
			end
		elseif ( not talentInfo.isChosen and talentButton.activationFrame ) then
			-- another relic was socketed in this slot while an activation anim was playing
			talentButton.activationFrame:Remove();
		end
	end

	for i, link in ipairs(self.Links) do
		link:EvaluateStyle();
	end

	if ( revealTalents ) then
		self:RevealTalents();
	end

	if ( self.mousedOverTalent ) then
		self.mousedOverTalent:OnEnter();
	end

	self.newRelic = nil;
end

function ArtifactRelicForgeMixin:RevealTalents()
	for i, talentButton in ipairs(self.Talents) do
		talentButton:StartRevealAnim();
	end
	for i, link in ipairs(self.Links) do
		link:StartRevealAnim();
	end
	-- counter for buttons only since they start first and finish last
	self.revealAnimCounter = #self.Talents;

	PlaySound(SOUNDKIT.UI_73_ARTIFACT_RELICS_TRAIT_REVEAL_ONLY);
end

function ArtifactRelicForgeMixin:OnRevealAnimFinished()
	self.revealAnimCounter = self.revealAnimCounter - 1;
	if ( self.revealAnimCounter == 0 ) then
		self:CheckTutorials();
		self:RefreshTalents();
	end
end

function ArtifactRelicForgeMixin:IsRevealingTalents()
	return self.revealAnimCounter > 0;
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
	if ( index == 1 ) then
		C_ArtifactRelicForgeUI.AddRelicTalent(self.relicSlot, index);
	else
		local dialogText = RELIC_FORGE_CONFIRM_TRAIT;
		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RELIC_FORGE_LEARN_TRAIT) ) then
			dialogText = RELIC_FORGE_CONFIRM_TRAIT_FIRST_TIME;
		end
		StaticPopup_Show("CONFIRM_RELIC_TALENT", dialogText, nil, { relicSlot = self.relicSlot, talentIndex = index });
	end
end

function ArtifactRelicForgeMixin:GetLinkBetween(fromButton, toButton)
	for i, link in ipairs(self.Links) do
		if ( link.fromButton == fromButton and link.toButton == toButton ) then
			return link;
		end
	end
	return nil;
end

function ArtifactRelicForgeMixin:IsPreviewRelicSelected()
	return self.relicSlot == PREVIEW_RELIC_SLOT;
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseEnter()
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseLeave()
end

function ArtifactRelicForgeMixin:OnNewSocketedRelic(relicSlotIndex)
	self.newRelic = true;
	self:SetRelicSlot(relicSlotIndex);
end

--========================================================================================================================
ArtifactRelicForgeTitleTemplateMixin = CreateFromMixins(ArtifactTitleTemplateMixin);

function ArtifactRelicForgeTitleTemplateMixin:RefreshTitle()
end

function ArtifactRelicForgeTitleTemplateMixin:ApplyCursorRelicToSlot(relicSlotIndex)
	ArtifactTitleTemplateMixin.ApplyCursorRelicToSlot(self, relicSlotIndex);
	self:GetParent():OnNewSocketedRelic(relicSlotIndex);
end

function ArtifactRelicForgeTitleTemplateMixin:OnCursorUpdate()
	ArtifactTitleTemplateMixin.OnCursorUpdate(self);
	self:GetParent().PreviewRelicFrame:RefreshPulse();
end

function ArtifactRelicForgeTitleTemplateMixin:OnRelicSlotClicked(button)
	if ( not ArtifactTitleTemplateMixin.OnRelicSlotClicked(self, button) ) then
		local relicSlotIndex = button:GetID();
		if ( C_ArtifactUI.GetRelicInfo(relicSlotIndex) ) then
			if ( not self:GetParent():IsRelicSlotSelected(relicSlotIndex) ) then
				PlaySound(SOUNDKIT.PUT_DOWN_GEMS, nil, SOUNDKIT_ALLOW_DUPLICATES);
				self:GetParent():SetRelicSlot(relicSlotIndex);
			end
		end
	end
end

--========================================================================================================================
ArtifactRelicTalentButtonMixin = { };

function ArtifactRelicTalentButtonMixin:OnLoad()
	local layoutInfo = self:GetLayoutInfo();
	self:SetTalentType(layoutInfo.talentType);
	self.RevealAnim.Start:SetEndDelay(layoutInfo.revealDelay);
end

function ArtifactRelicTalentButtonMixin:OnClick()
	if ( ChatEdit_TryInsertChatLink(C_ArtifactUI.GetPowerHyperlink(self:GetPowerID())) ) then
		return;
	end

	if ( self.canChoose ) then
		self:GetParent():ChooseTalent(self:GetID());
	else
		local errorText = self:GetChooseError();
		if ( errorText ) then
			UIErrorsFrame:AddMessage(errorText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1.0);
		end
	end
end

function ArtifactRelicTalentButtonMixin:OnEnter()
	self:GetParent().mousedOverTalent = self;
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("LEFT", self, "RIGHT", 8, 0);

	GameTooltip:SetArtifactPowerByID(self:GetPowerID());
	if ( self.canChoose ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(RELIC_FORGE_LEARN_TRAIT, GREEN_FONT_COLOR:GetRGB());
	else
		local errorText = self:GetChooseError();
		if ( errorText ) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(errorText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
	end
	GameTooltip:Show();
	self:HighlightLinks();
end

function ArtifactRelicTalentButtonMixin:GetChooseError()
	if ( self.canChoose ) then
		return nil;
	elseif ( self:GetParent():IsPreviewRelicSelected() ) then
		return RELIC_FORGE_SOCKET_PREVIEW_RELIC;
	elseif ( not self.isChosen and not self:IsReachable() ) then
		return RELIC_FORGE_TRAIT_DISABLED;
	else
		local talents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self:GetParent().relicSlot);
		local talentInfo = talents[self:GetID()];
		if ( C_ArtifactUI.GetTotalPurchasedRanks() < talentInfo.requiredArtifactLevel ) then
			return RELIC_FORGE_RANK_REQUIRED:format(talentInfo.tier, talentInfo.requiredArtifactLevel);
		elseif ( not self.isChosen and self:IsReachable() ) then
			return RELIC_FORGE_NO_ACTIVE_LINKS;
		end
	end
	return nil;
end

function ArtifactRelicTalentButtonMixin:OnLeave()
	self:GetParent().mousedOverTalent = nil;
	GameTooltip_Hide();
	self:GetParent():RefreshTalents();
end

function ArtifactRelicTalentButtonMixin:GetPowerID()
	return self.powerID;
end

function ArtifactRelicTalentButtonMixin:IsReachable()
	if ( self.isChosen or self.canChoose or self.isUpcoming ) then
		return true;
	end
	-- a choice in the same row makes this unreachable
	if ( self:GetParent():HasChoiceInSameRowAsTalentButton(self) ) then
		return false;
	end
	local layoutInfo = self:GetLayoutInfo();
	-- the top is always reachable
	if ( #layoutInfo.links == 0 ) then
		return true;
	end
	for i, talentIndex in ipairs(layoutInfo.links) do
		local talentButton =  self:GetParent().Talents[talentIndex];
		if ( talentButton:IsReachable() ) then
			return true;
		end
	end
	return false;
end

function ArtifactRelicTalentButtonMixin:HighlightLinks()
	if ( self.canChoose or not self:IsReachable() or self:GetParent():IsPreviewRelicSelected() ) then
		return;
	end
	self:HighlightParentLinks();
	self:HighlightChildLinks();
end

-- recursive to top
function ArtifactRelicTalentButtonMixin:HighlightParentLinks()
	if ( self.isChosen or self.canChoose or not self:IsReachable() ) then
		return;
	end
	local layoutInfo = self:GetLayoutInfo();
	for i, talentIndex in ipairs(layoutInfo.links) do
		local talentButton = self:GetParent().Talents[talentIndex];
		if ( talentButton:IsReachable() ) then
			local link = self:GetParent():GetLinkBetween(talentButton, self);
			link:SetStyle(RELIC_TALENT_LINK_STYLE_POTENTIAL);
			talentButton:HighlightParentLinks();
		end
	end
end

-- just to the next row down
function ArtifactRelicTalentButtonMixin:HighlightChildLinks()
	-- only highlight if no choice has been made on the children's row
	local layoutInfo = self:GetLayoutInfo();
	if ( self:GetParent():HasChoiceInRow(layoutInfo.row + 1) ) then
		return;
	end
	for i, link in ipairs(self:GetParent().Links) do
		-- no need to highlight link to button that's choosable, the link will be animating already
		if ( link.fromButton == self and not link.toButton.canChoose and link.toButton:IsReachable() ) then
			link:SetStyle(RELIC_TALENT_LINK_STYLE_POTENTIAL);
		end
	end
end

function ArtifactRelicTalentButtonMixin:GetChosenParent()
	local talents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self:GetParent().relicSlot);
	if ( not talents ) then
		return nil;
	end

	local layoutInfo = self:GetLayoutInfo();
	for i, talentIndex in ipairs(layoutInfo.links) do
		if ( talents[talentIndex] and talents[talentIndex].isChosen ) then
			return self:GetParent().Talents[talentIndex];
		end
	end
	return nil;
end

function ArtifactRelicTalentButtonMixin:GetChosenChild()
	local talents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self:GetParent().relicSlot);
	if ( not talents ) then
		return nil;
	end

	local selfIndex = self:GetID();
	for buttonIndex, layoutInfo in ipairs(TALENTS_LAYOUT) do
		for linkIndex, parentButtonIndex in ipairs(layoutInfo.links) do
			if ( parentButtonIndex == selfIndex and talents[buttonIndex].isChosen ) then
				return self:GetParent().Talents[buttonIndex];
			end
		end
	end
	return nil;
end

function ArtifactRelicTalentButtonMixin:EvaluateStyle()
	if ( self.isChosen ) then
		self:SetStyle(RELIC_TALENT_STYLE_CHOSEN);
	elseif ( self.canChoose ) then
		self:SetStyle(RELIC_TALENT_STYLE_AVAILABLE);
	elseif ( self.isUpcoming or self:GetParent():IsPreviewRelicSelected() ) then
		self:SetStyle(RELIC_TALENT_STYLE_UPCOMING);
	else
		self:SetStyle(RELIC_TALENT_STYLE_CLOSED);
	end
end

function ArtifactRelicTalentButtonMixin:SetStyle(style)
	if ( not self:CanChangeStyle() ) then
		return;
	end

	local talentTypeInfo = TALENT_TYPES[self.talentType];
	local styleInfo = TALENT_STYLES[style];
	local activeBorder;
	if ( self.isChosen ) then
		activeBorder = self.IconFrame.ChosenBorder;
		self.IconFrame.Border:Hide();
	else
		activeBorder = self.IconFrame.Border;
		self.IconFrame.ChosenBorder:Hide();
	end
	if ( styleInfo.overrideBorderTexture ) then
		self.IconFrame.Border:SetAtlas(styleInfo.overrideBorderTexture, true);
	else
		self.IconFrame.Border:SetAtlas(talentTypeInfo.border, true);
	end
	activeBorder:Show();
	activeBorder:SetDesaturated(styleInfo.borderDesaturated);
	activeBorder:SetVertexColor(styleInfo.borderVertexColorLevel, styleInfo.borderVertexColorLevel, styleInfo.borderVertexColorLevel);
	self.IconFrame.Icon:SetDesaturated(styleInfo.iconDesaturated);
	self.IconFrame.Icon:SetVertexColor(styleInfo.iconVertexColorLevel, styleInfo.iconVertexColorLevel, styleInfo.iconVertexColorLevel);
	if ( styleInfo.glowAnim ) then
		self.GlowAnim:Play();
	else
		self.GlowTexture:SetAlpha(0);
		self.BackGlowTexture:SetAlpha(0);
		self.GlowAnim:Stop();
	end
	if ( self.Stones ) then
		if ( styleInfo.showStones ) then
			self.Stones:Show();
			-- if parent was just chosen, then transition
			local parent = self:GetChosenParent();
			if ( parent and parent.activationFrame ) then
				self:StartTransitionAnim(0.5);
			end
			-- Transition will take care of stones anim
			if ( not self.TransitionAnim:IsPlaying() ) then
				self.Stones.FloatingAnim:Play();
			end
		else
			self.Stones:Hide();
			self.Stones.FloatingAnim:Stop();
		end
	end
	if ( styleInfo.showModelScene ) then
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

function ArtifactRelicTalentButtonMixin:EvaluateTalentType()
	local layoutInfo = self:GetLayoutInfo();
	-- only neutrals can change
	if ( layoutInfo.talentType ~= RELIC_TALENT_TYPE_NEUTRAL ) then
		return;
	end
	-- and only if not at the preview
	if ( not self:GetParent():IsPreviewRelicSelected() ) then
		local determiningButton = self:GetChosenParent();
		if ( not determiningButton ) then
			determiningButton = self:GetChosenChild();
		end
		if ( determiningButton ) then
			self:SetTalentType(determiningButton.talentType);
			return;
		end
	end
	-- Nothing chosen connects to this
	self:SetTalentType(RELIC_TALENT_TYPE_NEUTRAL);
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
	if ( talentTypeInfo.revealTextures ) then
		for key, atlas in pairs(talentTypeInfo.revealTextures) do
			self.IconFrame[key]:SetAtlas(atlas, true);
		end
	end
	if ( talentTypeInfo.transitionTextures ) then
		for key, atlas in pairs(talentTypeInfo.transitionTextures) do
			self.IconFrame[key]:SetAtlas(atlas, true);
		end
	end
	self.IconFrame.Border:SetAtlas(talentTypeInfo.border, true);
	self.IconFrame.ChosenBorder:SetAtlas(talentTypeInfo.chosenBorder, true);
end

function ArtifactRelicTalentButtonMixin:SetRandomRune()
	local NUM_RUNE_TYPES = 6;
	local runeIndex = math.random(1, NUM_RUNE_TYPES);
	local talentTypeInfo = TALENT_TYPES[self.talentType];
	self.Rune:SetAtlas(("Rune-%02d-"):format(runeIndex)..talentTypeInfo.runeSuffix, true);
end

function ArtifactRelicTalentButtonMixin:StartRevealAnim()
	if ( self.canChoose ) then
		self:SetStyle(RELIC_TALENT_STYLE_UPCOMING);
	end
	self:LockStyleChanges();
	self:SetRandomRune();
	self.RevealAnim:Stop();
	self.RevealAnim:Play();
end

function ArtifactRelicTalentButtonMixin:OnRevealAnimFinished()
	self:UnlockStyleChanges();
	self:GetParent():OnRevealAnimFinished();
	if ( self.canChoose ) then
		self:EvaluateStyle();
		self:StartTransitionAnim();
	end
end

function ArtifactRelicTalentButtonMixin:StartTransitionAnim(delay)
	if ( self.TransitionAnim:IsPlaying() ) then
		return;
	end

	self:LockStyleChanges();
	self.Stones.FloatingAnim:Stop();
	self.GlowAnim:Stop();
	self.TransitionAnim.Start:SetEndDelay(delay or 0);
	self.TransitionAnim:Stop();
	self.TransitionAnim:Play();
	local chosenParent = self:GetChosenParent();
	if ( chosenParent ) then
		local link = self:GetParent():GetLinkBetween(chosenParent, self);
		link:StartTransitionAnim();
	end
end

function ArtifactRelicTalentButtonMixin:OnTransitionAnimFinished()
	self:UnlockStyleChanges();
	self:EvaluateStyle();
	self.Stones.FloatingAnim:Play();
end

function ArtifactRelicTalentButtonMixin:LockStyleChanges()
	self.styleChangesLocked = true;
end

function ArtifactRelicTalentButtonMixin:UnlockStyleChanges()
	self.styleChangesLocked = false;
end

function ArtifactRelicTalentButtonMixin:CanChangeStyle()
	return not self.styleChangesLocked;
end

function ArtifactRelicTalentButtonMixin:StopTriggeredAnimations()
	self.RevealAnim:Stop();
	self.TransitionAnim:Stop();
	self:UnlockStyleChanges();
	self:EvaluateStyle();
	if ( self.ConversionBorder ) then
		self.ConversionBorder.Anim:Stop();
	end
end

--========================================================================================================================
ArtifactRelicTalentLinkMixin = { };

function ArtifactRelicTalentLinkMixin:OnLoad()
	if ( self.linkType == RELIC_TALENT_LINK_TYPE_LIGHT ) then
		self.DimTexture:SetVertexColor(0.5, 0.5, 0.5);
	elseif ( self.linkType == RELIC_TALENT_LINK_TYPE_VOID ) then
		self.DimTexture:SetVertexColor(0.6, 0.6, 0.6);
	end
end

function ArtifactRelicTalentLinkMixin:SetUp(linkSide, fromButton, toButton)
	self.fromButton = fromButton;
	self.toButton = toButton;
	if ( linkSide == LINK_SIDE_RIGHT ) then
		for i, element in ipairs(self.Elements) do
			if ( element:GetObjectType() == "Texture" ) then
				element:SetTexCoord(1, 0, 0, 1);
			end
		end
		self.AnimFrame.Background:SetTexCoord(1, 0, 0, 1);
		self.AnimFrame.Glow:SetTexCoord(1, 0, 0, 1);
		self.AnimFrame.Anim.BallTravel:SetOffset(37, -40);
		self.AnimFrame.Ball:SetPoint("CENTER", -19, 26);
		self:SetPoint("TOPLEFT", fromButton, "BOTTOMRIGHT", -16, 2);
	elseif ( linkSide == LINK_SIDE_LEFT ) then
		self:SetPoint("TOPRIGHT", fromButton, "BOTTOMLEFT", 16, 2);
	end
	local layoutInfo = fromButton:GetLayoutInfo();
	self.RevealAnim.Start:SetEndDelay(layoutInfo.revealDelay + LINK_REVEAL_EXTRA_DELAY_TIME);
end

function ArtifactRelicTalentLinkMixin:EvaluateStyle()
	if ( self.fromButton.isChosen and self.toButton.isChosen ) then
		self:SetStyle(RELIC_TALENT_LINK_STYLE_ACTIVE);
	elseif ( (self.fromButton.isChosen and self.toButton.isUpcoming) or self:GetParent():IsPreviewRelicSelected() ) then
		self:SetStyle(RELIC_TALENT_LINK_STYLE_UPCOMING);
	elseif ( self.fromButton.isChosen and not self:GetParent():HasChoiceInSameRowAsTalentButton(self.toButton) ) then
		self:SetStyle(RELIC_TALENT_LINK_STYLE_AVAILABLE);
	else
		self:SetStyle(RELIC_TALENT_LINK_STYLE_DISABLED);
	end
end

function ArtifactRelicTalentLinkMixin:SetStyle(style)
	if ( not self:CanChangeStyle() ) then
		return;
	end

	local activeElement = self[LINK_STYLE_ACTIVE_ELEMENT[style]];
	for _, element in ipairs(self.Elements) do
		element:SetShown(element == activeElement);
	end
end

function ArtifactRelicTalentLinkMixin:StartRevealAnim()
	if ( self:GetParent():IsPreviewRelicSelected() ) then
		self.RevealAnim.Start:SetTargetKey(self.DimTexture);
		self.RevealAnim.TargetAlpha:SetTargetKey(self.DimTexture);
	else
		self.RevealAnim.Start:SetTargetKey(self.DisabledTexture);
		self.RevealAnim.TargetAlpha:SetTargetKey(self.DisabledTexture);
	end
	self:LockStyleChanges();
	self.RevealTexture:Show();
	self.RevealAnim:Stop();
	self.RevealAnim:Play();
end

function ArtifactRelicTalentLinkMixin:OnRevealAnimFinished()
	self:UnlockStyleChanges();
	self:EvaluateStyle();
end

function ArtifactRelicTalentLinkMixin:StartTransitionAnim()
	if ( self.TransitionAnim:IsPlaying() ) then
		return;
	end

	self:SetStyle(RELIC_TALENT_LINK_STYLE_DISABLED);
	self:LockStyleChanges();
	self.DisabledTexture:Show();
	self.TransitionTexture:Show();
	self.TransitionAnim:Stop();
	self.TransitionTexture:SetAlpha(0);
	self.TransitionAnim:Play();
end

function ArtifactRelicTalentLinkMixin:OnTransitionAnimFinished()
	self.DisabledTexture:SetAlpha(1);
	self:UnlockStyleChanges();
	self:EvaluateStyle();
end

function ArtifactRelicTalentLinkMixin:LockStyleChanges()
	self.styleChangesLocked = true;
end

function ArtifactRelicTalentLinkMixin:UnlockStyleChanges()
	self.styleChangesLocked = false;
end

function ArtifactRelicTalentLinkMixin:CanChangeStyle()
	return not self.styleChangesLocked;
end

function ArtifactRelicTalentLinkMixin:StopTriggeredAnimations()
	self.RevealAnim:Stop();
	self.RevealTexture:Hide();
	self.TransitionAnim:Stop();
	self.TransitionTexture:Hide();
	self.DisabledTexture:SetAlpha(1);
	self:UnlockStyleChanges();
	self:EvaluateStyle();
end

--========================================================================================================================
ArtifactRelicForgePreviewRelicMixin = { };

function ArtifactRelicForgePreviewRelicMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.UpdateTooltip = self.OnEnter;
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
	local relicItemLink = C_ArtifactRelicForgeUI.GetPreviewRelicItemLink();
	if ( relicItemLink ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(relicItemLink);
	else
		local type, itemID, itemLink = GetCursorInfo();
		if type ~= "item" or not IsArtifactRelicItem(itemID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(RELIC_FORGE_PREVIEW_RELIC_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR:GetRGB());
			GameTooltip:AddLine(RELIC_FORGE_PREVIEW_RELIC_TOOLTIP, nil, nil, nil, true);
			GameTooltip:Show();
		end
	end
end

function ArtifactRelicForgePreviewRelicMixin:OnClick(button)
	if ( button == "LeftButton" ) then
		local canSet, bindWarning = C_ArtifactRelicForgeUI.CanSetPreviewRelicFromCursor();
		if ( canSet ) then
			if ( bindWarning ) then
				StaticPopup_Show("CONFIRM_RELIC_ATTUNE", nil, nil, self);
			else
				self:SetRelicFromCursor();
			end
		else
			local type, itemID, itemLink = GetCursorInfo();
			if type == "item" and IsArtifactRelicItem(itemID) then
				UIErrorsFrame:AddMessage(ERR_ARTIFACT_RELIC_DOES_NOT_MATCH_ARTIFACT, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1.0);
			else
				if ( C_ArtifactRelicForgeUI.GetPreviewRelicItemID() and not self:GetParent():IsRelicSlotSelected(PREVIEW_RELIC_SLOT) ) then
					PlaySound(SOUNDKIT.PUT_DOWN_GEMS, nil, SOUNDKIT_ALLOW_DUPLICATES);
					self:GetParent():SetRelicSlot(PREVIEW_RELIC_SLOT);
				end
			end
		end
	elseif ( button == "RightButton" and C_ArtifactRelicForgeUI.GetPreviewRelicItemID() ) then
		C_ArtifactRelicForgeUI.ClearPreviewRelic();
		PlaySound(SOUNDKIT.PICK_UP_GEMS);
	end
end

function ArtifactRelicForgePreviewRelicMixin:Update()
	local isSelected = (self:GetParent().relicSlot == PREVIEW_RELIC_SLOT);
	self:GetParent().PreviewRelicCover:SetShown(isSelected);
	self.SelectedGlow:SetShown(isSelected);
	self.SelectedGlow2:SetShown(isSelected);
	local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
	if ( relicItemID ) then
		local itemID, class, subClass, invType, texture = GetItemInfoInstant(relicItemID);
		self.Icon:SetTexture(texture);
		self.Border:SetAtlas("Relicforge-Slot-frame-Active", true);
	else
		self.Icon:SetTexture();
		self.Border:SetAtlas("Relicforge-Slot-frame", true);
	end
	self:RefreshPulse();
end

function ArtifactRelicForgePreviewRelicMixin:OnDragStart()
	C_ArtifactRelicForgeUI.PickUpPreviewRelic();
end

function ArtifactRelicForgePreviewRelicMixin:SetRelicFromCursor()
	C_ArtifactRelicForgeUI.SetPreviewRelicFromCursor();
	local isAttuned, canAttune = C_ArtifactRelicForgeUI.GetPreviewRelicAttuneInfo();
	if ( canAttune ) then
		C_ArtifactRelicForgeUI.AttunePreviewRelic();
	end
end

function ArtifactRelicForgePreviewRelicMixin:RefreshPulse()
	local canSet, bindWarning = C_ArtifactRelicForgeUI.CanSetPreviewRelicFromCursor();
	if ( canSet ) then
		self.PulseBorder:Show();
		if ( C_ArtifactRelicForgeUI.GetPreviewRelicItemID() ) then
			self.PulseBorder:SetAtlas("Relicforge-Slot-frame", true);
			self.PulseBorder.AnimWhenEmpty:Stop();
			self.PulseBorder.AnimWhenFull:Play();
		else
			self.PulseBorder:SetAtlas("Relicforge-Slot-frame-Active", true);
			self.PulseBorder.AnimWhenEmpty:Play();
			self.PulseBorder.AnimWhenFull:Stop();
		end
	else
		self.PulseBorder:Hide();
		self.PulseBorder.AnimWhenEmpty:Stop();
		self.PulseBorder.AnimWhenFull:Stop();
	end
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
	-- sound
	local currentRelicRank, canAddTalent = C_ArtifactUI.GetRelicSlotRankInfo(self:GetParent().relicSlot);
	if ( canAddTalent ) then
		PlaySound(SOUNDKIT.UI_73_ARTIFACT_RELICS_TRAIT_SELECT_AND_REVEAL, nil, SOUNDKIT_ALLOW_DUPLICATES);
	else
		PlaySound(SOUNDKIT.UI_73_ARTIFACT_RELICS_TRAIT_SELECT_ONLY, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end
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