ArtifactPerksMixin = {}

function ArtifactPerksMixin:OnShow()	
	self.modelTransformElapsed = 0;
	self:RegisterEvent("CURSOR_UPDATE");
end

function ArtifactPerksMixin:OnHide()	
	self:UnregisterEvent("CURSOR_UPDATE");
end

function ArtifactPerksMixin:OnEvent(event, ...)
	if event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	end
end

function ArtifactPerksMixin:OnAppearanceChanging()
	self.isAppearanceChanging = true;
end

function ArtifactPerksMixin:RefreshModel()
	local itemID, altItemID, _, _, _, _, _, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetArtifactInfo();
	local _, _, _, _, _, _, uiCameraID, altHandUICameraID, _, _, _, modelAlpha, modelDesaturation, suppressGlobalAnim = C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID);

	self.Model.uiCameraID = uiCameraID;
	self.Model.desaturation = modelDesaturation;
	if itemAppearanceID then
		self.Model:SetItemAppearance(itemAppearanceID);
	else
		self.Model:SetItem(itemID, appearanceModID);
	end

	self.Model.BackgroundFront:SetAlpha(1.0 - (modelAlpha or 1.0));

	self.Model:SetModelDrawLayer(altOnTop and "BORDER" or "ARTWORK");
	self.AltModel:SetModelDrawLayer(altOnTop and "ARTWORK" or "BORDER");

	self.Model:SetSuppressGlobalAnimationTrack(suppressGlobalAnim);
	self.AltModel:SetSuppressGlobalAnimationTrack(suppressGlobalAnim);
	
	if altItemID and altHandUICameraID then
		self.AltModel.uiCameraID = altHandUICameraID;
		self.AltModel.desaturation = modelDesaturation;
		if altItemAppearanceID then
			self.AltModel:SetItemAppearance(altItemAppearanceID);
		else
			self.AltModel:SetItem(altItemID, appearanceModID);
		end

		self.AltModel:Show();
	else
		self.AltModel:Hide();
	end
end

function ArtifactsModelTemplate_OnModelLoaded(self)
	local CUSTOM_ANIMATION_SEQUENCE = 213;
	local animationSequence = self:HasAnimation(CUSTOM_ANIMATION_SEQUENCE) and CUSTOM_ANIMATION_SEQUENCE or 0;

	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
	self:SetLight(true, false, 0, 0, 0, .7, 1.0, 1.0, 1.0);
				
	self:SetDesaturation(self.desaturation or .5);

	self:SetAnimation(animationSequence, 0);
end

function ArtifactPerksMixin:RefreshBackground()
	local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	if textureKit then
		local bgAtlas = ("%s-BG"):format(textureKit);
		self.BackgroundBack:SetAtlas(bgAtlas);
		self.Model.BackgroundFront:SetAtlas(bgAtlas);
	end
end

function ArtifactPerksMixin:OnUpdate(elapsed)
	self:TryRefresh();
end

function ArtifactPerksMixin:RefreshPowers(newItem)
	if newItem or not self.powerIDToPowerButton then
		self.powerIDToPowerButton = {};
	end

	self.startingPowerButton = nil;

	local powers = C_ArtifactUI.GetPowers();
	for i, powerID in ipairs(powers) do
		local powerButton = self.powerIDToPowerButton[powerID];

		if not powerButton then
			powerButton = self:GetOrCreatePowerButton(i);
			self.powerIDToPowerButton[powerID] = powerButton;

			powerButton:ClearOldData();
		end

		powerButton:SetupButton(powerID, self.BackgroundBack);
		powerButton.links = {};
		powerButton.owner = self;

		if powerButton:IsStart() then
			self.startingPowerButton = powerButton;
		end

		powerButton:SetShown(powerButton:ShouldBeVisible());
	end

	self:HideUnusedWidgets(self.PowerButtons, #powers);
	self:RefreshDependencies(powers);
	self:RefreshRelics();
end

function ArtifactPerksMixin:GetOrCreatePowerButton(powerIndex)
	local button = self.PowerButtons and self.PowerButtons[powerIndex];
	if button then
		return button;
	end
	return CreateFrame("BUTTON", nil, self, "ArtifactPowerButtonTemplate");
end

function ArtifactPerksMixin:GetOrCreateDependencyLine(lineIndex)
	local lineContainer = self.DependencyLines and self.DependencyLines[lineIndex];
	if lineContainer then
		lineContainer:Show();
		return lineContainer;
	end

	lineContainer = CreateFrame("FRAME", nil, self, "ArtifactDependencyLineTemplate");

	return lineContainer;
end

function ArtifactPerksMixin:HideUnusedWidgets(widgetTable, numUsed, customHideFunc)
	if widgetTable then
		for i = numUsed + 1, #widgetTable do
			widgetTable[i]:Hide();
			if customHideFunc then
				customHideFunc(widgetTable[i]);
			end
		end
	end
end

function ArtifactPerksMixin:TryRefresh()
	if self.perksDirty then
		if self.newItem then
			self.numRevealsPlaying = nil;
			self:HideAllLines();
			self:RefreshBackground();
		end

		if self.newItem or self.isAppearanceChanging then
			self:RefreshModel();
		end

		self.queuePlayingReveal = false;
		local hasBoughtAnyPowers = C_ArtifactUI.GetTotalPurchasedRanks() > 0;
		if self.newItem then
			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
		elseif self.hasBoughtAnyPowers ~= hasBoughtAnyPowers then
			self:HideAllLines();

			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
			if hasBoughtAnyPowers then
				self.queuePlayingReveal = true;
			end
		end

		self:RefreshPowers(self.newItem);
		
		self.TitleContainer:SetPointsRemaining(C_ArtifactUI.GetPointsRemaining());

		self.perksDirty = false;
		self.newItem = nil;
		self.isAppearanceChanging = nil;
		if self.queuePlayingReveal then
			self:PlayReveal();
		end
	end
end

function ArtifactPerksMixin:Refresh(newItem)
	self.perksDirty = true;
	self.newItem = self.newItem or newItem;
end

local LINE_FADE_ANIM_TYPE_CONNECTED = 1;
local LINE_FADE_ANIM_TYPE_UNLOCKED = 2;
local LINE_FADE_ANIM_TYPE_LOCKED = 3;

local function PlayLineFadeAnim(lineContainer, lineAnimType)
	lineContainer.FadeAnim:Finish();

	lineContainer.FadeAnim.Background:SetFromAlpha(lineContainer.Background:GetAlpha());
	lineContainer.FadeAnim.Fill:SetFromAlpha(lineContainer.Fill:GetAlpha());
	lineContainer.FadeAnim.FillScroll1:SetFromAlpha(lineContainer.FillScroll1:GetAlpha());
	lineContainer.FadeAnim.FillScroll2:SetFromAlpha(lineContainer.FillScroll2:GetAlpha());

	if lineAnimType == LINE_FADE_ANIM_TYPE_CONNECTED then
		lineContainer.ScrollAnim:Play();

		lineContainer.FadeAnim.Background:SetToAlpha(0.0);
		lineContainer.FadeAnim.Fill:SetToAlpha(1.0);
		lineContainer.FadeAnim.FillScroll1:SetToAlpha(1.0);
		lineContainer.FadeAnim.FillScroll2:SetToAlpha(1.0);

	elseif lineAnimType == LINE_FADE_ANIM_TYPE_UNLOCKED then
		lineContainer.ScrollAnim:Stop();

		lineContainer.FadeAnim.Background:SetToAlpha(1.0);
		lineContainer.FadeAnim.Fill:SetToAlpha(1.0);
		lineContainer.FadeAnim.FillScroll1:SetToAlpha(0.0);
		lineContainer.FadeAnim.FillScroll2:SetToAlpha(0.0);

	elseif lineAnimType == LINE_FADE_ANIM_TYPE_LOCKED then
		lineContainer.ScrollAnim:Stop();

		lineContainer.FadeAnim.Background:SetToAlpha(0.85);
		lineContainer.FadeAnim.Fill:SetToAlpha(0.0);
		lineContainer.FadeAnim.FillScroll1:SetToAlpha(0.0);
		lineContainer.FadeAnim.FillScroll2:SetToAlpha(0.0);
	end
	lineContainer.animType = lineAnimType;
	lineContainer.FadeAnim:Play();
end

local function OnUnusedLineHidden(lineContainer)
	lineContainer.animType = nil;
	lineContainer.FadeAnim:Stop();
	lineContainer.RevealAnim:Stop();

	lineContainer.Background:SetAlpha(0.0);
	lineContainer.Fill:SetAlpha(0.0);
	lineContainer.FillScroll1:SetAlpha(0.0);
	lineContainer.FillScroll2:SetAlpha(0.0);
end

function ArtifactPerksMixin:RefreshDependencies(powers)
	local numUsedLines = 0;

	if ArtifactUI_CanViewArtifact() then
		local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();

		for i, fromPowerID in ipairs(powers) do
			local fromButton = self.powerIDToPowerButton[fromPowerID];
			local fromLinks = C_ArtifactUI.GetPowerLinks(fromPowerID);
			if fromLinks then
				for j, toPowerID in ipairs(fromLinks) do
					if not fromButton.links[toPowerID] then
						local toButton = self.powerIDToPowerButton[toPowerID];
						if toButton and not toButton.links[fromPowerID] then
							numUsedLines = numUsedLines + 1;
							local lineContainer = self:GetOrCreateDependencyLine(numUsedLines);

							lineContainer.Fill:SetStartPoint("CENTER", fromButton);
							lineContainer.Fill:SetEndPoint("CENTER", toButton);

							if self.hasBoughtAnyPowers or ((toButton:IsStart() or toButton.prereqsMet) and (fromButton:IsStart() or fromButton.prereqsMet)) then
								local hasSpentAny = fromButton.hasSpentAny and toButton.hasSpentAny;
								if hasSpentAny or (fromButton.isCompletelyPurchased and (toButton.couldSpendPoints or toButton.isMaxRank)) or (toButton.isCompletelyPurchased and (fromButton.couldSpendPoints or fromButton.isMaxRank)) then
									if (fromButton.isCompletelyPurchased and toButton.hasSpentAny) or (toButton.isCompletelyPurchased and fromButton.hasSpentAny) then
										lineContainer.Fill:SetVertexColor(barConnectedR, barConnectedG, barConnectedB);
										lineContainer.FillScroll1:SetVertexColor(barConnectedR, barConnectedG, barConnectedB);
										lineContainer.FillScroll2:SetVertexColor(barConnectedR, barConnectedG, barConnectedB);

										lineContainer.FillScroll1:Show();
										lineContainer.FillScroll1:SetStartPoint("CENTER", fromButton);
										lineContainer.FillScroll1:SetEndPoint("CENTER", toButton);

										lineContainer.FillScroll2:Show();
										lineContainer.FillScroll2:SetStartPoint("CENTER", fromButton);
										lineContainer.FillScroll2:SetEndPoint("CENTER", toButton);

										PlayLineFadeAnim(lineContainer, LINE_FADE_ANIM_TYPE_CONNECTED);
									else
										lineContainer.Fill:SetVertexColor(barDisconnectedR, barDisconnectedG, barDisconnectedB);

										lineContainer.Background:SetStartPoint("CENTER", fromButton);
										lineContainer.Background:SetEndPoint("CENTER", toButton);

										PlayLineFadeAnim(lineContainer, LINE_FADE_ANIM_TYPE_UNLOCKED);
									end
								else
									lineContainer.Fill:SetVertexColor(barConnectedR, barConnectedG, barConnectedB);
									lineContainer.Background:SetStartPoint("CENTER", fromButton);
									lineContainer.Background:SetEndPoint("CENTER", toButton);

									PlayLineFadeAnim(lineContainer, LINE_FADE_ANIM_TYPE_LOCKED);
								end
							end

							fromButton.links[toPowerID] = lineContainer;
							toButton.links[fromPowerID] = lineContainer;
						end
					end
				end
			end
		end
	end

	self:HideUnusedWidgets(self.DependencyLines, numUsedLines, OnUnusedLineHidden);
end

local function RelicRefreshHelper(self, relicSlotIndex, powersAffected, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		powersAffected[powerID] = true;
		self:AddRelicToPower(powerID, relicSlotIndex);
	end
end

function ArtifactPerksMixin:RefreshRelics()
	local powersAffected = {};
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		RelicRefreshHelper(self, relicSlotIndex, powersAffected, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
	end

	for powerID, button in pairs(self.powerIDToPowerButton) do
		if not powersAffected[powerID] then
			button:RemoveRelicType();
		end
	end
end

function ArtifactPerksMixin:AddRelicToPower(powerID, relicSlotIndex)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		local relicType = C_ArtifactUI.GetRelicSlotType(relicSlotIndex);
		local lockedReason, relicName, relicIcon, relicLink = C_ArtifactUI.GetRelicInfo(relicSlotIndex);
		button:ApplyRelicType(relicType, relicLink, self.newItem);
	end
end

local function RelicHighlightHelper(self, highlightEnabled, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled);
	end
end

local function RelicMouseOverHighlightHelper(self, highlightEnabled, tempRelicType, tempRelicLink, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled, tempRelicType, tempRelicLink);
	end
end

function ArtifactPerksMixin:OnRelicSlotMouseEnter(relicSlotIndex)
	RelicHighlightHelper(self, true, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
end

function ArtifactPerksMixin:OnRelicSlotMouseLeave(relicSlotIndex)
	RelicHighlightHelper(self, false, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));

	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:ShowHighlightForRelicItemID(itemID)
	local couldFitInAnySlot = false;
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		if C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex) then
			self.TitleContainer:SetRelicSlotHighlighted(relicSlotIndex, true);
			couldFitInAnySlot = true;
		end
	end

	if couldFitInAnySlot then
		local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfoByItemID(itemID);
		RelicMouseOverHighlightHelper(self, true, relicType, relicLink, C_ArtifactUI.GetPowersAffectedByRelicItemID(itemID));
	end
end

function ArtifactPerksMixin:HideHighlightForRelicItemID(itemID)
	RelicMouseOverHighlightHelper(self, false, nil, nil, C_ArtifactUI.GetPowersAffectedByRelicItemID(itemID));
	self.TitleContainer:RefreshCursorRelicHighlights();
end

function ArtifactPerksMixin:RefreshCursorHighlights()
	local type, itemID = GetCursorInfo();
	if type == "item" and IsArtifactRelicItem(itemID) then
		self.cursorItemID = itemID;
		self:ShowHighlightForRelicItemID(self.cursorItemID);
	elseif self.cursorItemID then
		self:HideHighlightForRelicItemID(self.cursorItemID);
		self.cursorItemID = nil;
	end
end

function ArtifactPerksMixin:OnCursorUpdate()
	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:SetRelicPowerHighlightEnabled(powerID, highlight, tempRelicType, tempRelicLink)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		if highlight and tempRelicType and tempRelicLink then
			button:ApplyTemporaryRelicType(tempRelicType, tempRelicLink);
		else
			button:RemoveTemporaryRelicType();
		end
		button:SetRelicHighlightEnabled(highlight);
	end
end

function ArtifactPerksMixin:HideAllLines()
	self:HideUnusedWidgets(self.DependencyLines, 0, OnUnusedLineHidden);
end

ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE = .005;
ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE = .0019;

local function OnLineRevealFinished(animGroup)
	local lineContainer = animGroup:GetParent();
	if lineContainer.animType then
		PlayLineFadeAnim(lineContainer, lineContainer.animType);
	end
end

local function QueueReveal(self, powerButton, distance)
	if powerButton:IsStart() or powerButton:QueueRevealAnimation(distance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE) then
		for linkedPowerID, linkedLineContainer in pairs(powerButton.links) do
			local linkedPowerButton = self.powerIDToPowerButton[linkedPowerID];
			
			if linkedPowerButton.hasSpentAny then
				QueueReveal(self, linkedPowerButton, distance);
			else 
				local distanceToLink = powerButton:CalculateDistanceTo(linkedPowerButton);
				local totalDistance = distance + distanceToLink;

				QueueReveal(self, linkedPowerButton, totalDistance);

				linkedLineContainer.FadeAnim:Stop();
				linkedLineContainer.ScrollAnim:Stop();

				linkedLineContainer.Background:SetAlpha(0.0);
				linkedLineContainer.Fill:SetAlpha(0.0);
				linkedLineContainer.FillScroll1:SetAlpha(0.0);
				linkedLineContainer.FillScroll2:SetAlpha(0.0);

				local delay = powerButton:IsStart() and .1 or totalDistance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE;
				if not linkedLineContainer.RevealAnim:IsPlaying() or delay < linkedLineContainer.RevealAnim.Start1:GetEndDelay() then
					linkedLineContainer.RevealAnim.Start1:SetEndDelay(delay);
					linkedLineContainer.RevealAnim.Start2:SetEndDelay(delay);

					linkedLineContainer.RevealAnim.LineScale:SetDuration(distanceToLink * ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE);

					linkedLineContainer.RevealAnim:SetScript("OnFinished", OnLineRevealFinished);
					linkedLineContainer.RevealAnim:Play();
				end
			end
		end
	end
end

local function OnRevealFinished(powerButton)
	powerButton.owner:OnRevealAnimationFinished(powerButton);
end

function ArtifactPerksMixin:PlayReveal()
	if self.startingPowerButton and not self.numRevealsPlaying then
		self.numRevealsPlaying = 0;

		QueueReveal(self, self.startingPowerButton, 0);

		for powerID, powerButton in pairs(self.powerIDToPowerButton) do
			if powerButton:ShouldBeVisible() and powerButton:PlayRevealAnimation(OnRevealFinished) then
				powerButton:SetLocked(true);
				self.numRevealsPlaying = self.numRevealsPlaying + 1;
			end
		end

		PlaySound("UI_70_Artifact_Forge_Trait_FirstTrait");
	end
end

function ArtifactPerksMixin:OnRevealAnimationFinished(powerButton)
	if self.numRevealsPlaying then
		self.numRevealsPlaying = self.numRevealsPlaying - 1;
		if self.numRevealsPlaying == 0 then
			self.numRevealsPlaying = nil;
			for powerID, powerButton in pairs(self.powerIDToPowerButton) do
				powerButton:SetLocked(false);
			end
		end
	end
end

------------------------------------------------------------------
--   ArtifactTitleTemplate
------------------------------------------------------------------


ArtifactTitleTemplateMixin = {}

function ArtifactTitleTemplateMixin:RefreshTitle()
	self.PointsRemainingLabel:SnapToTarget();

	local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	self.ArtifactName:SetText(titleName);
	self.ArtifactName:SetVertexColor(titleR, titleG, titleB);

	if textureKit then
		local headerAtlas = ("%s-Header"):format(textureKit);
		self.Background:SetAtlas(headerAtlas, true);
		self.Background:Show();
	else
		self.Background:Hide();
	end
end

function ArtifactTitleTemplateMixin:OnShow()
	self:RefreshTitle();
	self:EvaluateRelics();

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("CURSOR_UPDATE");
end

function ArtifactTitleTemplateMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_UPDATE");
	self:UnregisterEvent("CURSOR_UPDATE");
	StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
end

function ArtifactTitleTemplateMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		local newItem = ...;
		if newItem then
			self:RefreshTitle();
		end
		self:EvaluateRelics();
		self:RefreshRelicTooltips();
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	end
end

function ArtifactTitleTemplateMixin:OnCursorUpdate()
	if not CursorHasItem() then
		StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
	end

	self:RefreshCursorRelicHighlights();
end

function ArtifactTitleTemplateMixin:RefreshCursorRelicHighlights()
	for relicSlotIndex in ipairs(self.RelicSlots) do
		self:SetRelicSlotHighlighted(relicSlotIndex, C_ArtifactUI.CanApplyCursorRelicToSlot(relicSlotIndex));
	end
end

function ArtifactTitleTemplateMixin:SetRelicSlotHighlighted(relicSlotIndex, highlighted)
	local relicSlot = self.RelicSlots[relicSlotIndex];
	if relicSlot:IsShown() then
		if highlighted then
			relicSlot:LockHighlight();
			relicSlot.CanSlotAnim:Play();
		else
			relicSlot:UnlockHighlight();
			relicSlot.CanSlotAnim:Stop();
			relicSlot.HighlightTexture:SetAlpha(1);
		end
	end
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseEnter(relicSlot)
	if relicSlot.lockedReason then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(LOCKED_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			if relicSlot.lockedReason == "" then
				GameTooltip:AddLine(LOCKED_RELIC_TOOLTIP_BODY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			else
				GameTooltip:AddLine(relicSlot.lockedReason, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
		end
	elseif relicSlot.relicLink then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		GameTooltip:SetHyperlink(relicSlot.relicLink);
	elseif relicSlot.relicType then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(EMPTY_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			GameTooltip:AddLine(EMPTY_RELIC_TOOLTIP_BODY:format(slotName), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			GameTooltip:Show();
		end
	end
	self:GetParent():OnRelicSlotMouseEnter(relicSlot.relicSlotIndex);
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseLeave(relicSlot)
	GameTooltip_Hide();
	self:GetParent():OnRelicSlotMouseLeave(relicSlot.relicSlotIndex);
end

StaticPopupDialogs["CONFIRM_RELIC_REPLACE"] = {
	text = CONFIRM_ACCEPT_RELIC,
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, relicSlotIndex)
		C_ArtifactUI.ApplyCursorRelicToSlot(relicSlotIndex);
		ArtifactFrame.PerksTab.TitleContainer.RelicSlots[relicSlotIndex].GlowAnim:Play();
		PlaySound("UI_70_Artifact_Forge_Relic_Place");
	end,
	OnCancel = function()
		ClearCursor();
	end,

	showAlert = true,
	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

function ArtifactTitleTemplateMixin:OnRelicSlotClicked(relicSlot)
	for i = 1, #self.RelicSlots do
		if self.RelicSlots[i] == relicSlot then
			if C_ArtifactUI.CanApplyCursorRelicToSlot(i) then
				local _, itemName = C_ArtifactUI.GetRelicInfo(i);
				if itemName then
					StaticPopup_Show("CONFIRM_RELIC_REPLACE", nil, nil, i);
				else
					C_ArtifactUI.ApplyCursorRelicToSlot(i);
					self.RelicSlots[i].GlowAnim:Play();
					PlaySound("UI_70_Artifact_Forge_Relic_Place");
				end
			else
				local _, itemID = GetCursorInfo();
				if itemID and IsArtifactRelicItem(itemID) then
					UIErrorsFrame:AddMessage(RELIC_SLOT_INVALID, 1.0, 0.1, 0.1, 1.0);
				end
			end
			break;
		end
	end
end

function ArtifactTitleTemplateMixin:RefreshRelicTooltips()
	for i = 1, #self.RelicSlots do
		if GameTooltip:IsOwned(self.RelicSlots[i]) then
			self.RelicSlots[i]:GetScript("OnEnter")(self.RelicSlots[i]);
			break;
		end
	end
end

function ArtifactTitleTemplateMixin:EvaluateRelics()
	local numRelicSlots = ArtifactUI_CanViewArtifact() and C_ArtifactUI.GetNumRelicSlots() or 0;

	self:SetExpandedState(numRelicSlots > 0);

	for i = 1, numRelicSlots do
		local relicSlot = self.RelicSlots[i];

		local relicType = C_ArtifactUI.GetRelicSlotType(i);

		local relicAtlasName = ("Relic-%s-Slot"):format(relicType);
		relicSlot:GetNormalTexture():SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder1:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder2:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder3:SetAtlas(relicAtlasName, true);
		local lockedReason, relicName, relicIcon, relicLink = C_ArtifactUI.GetRelicInfo(i);
		if lockedReason then
			relicSlot:GetNormalTexture():SetAlpha(.5);
			relicSlot:Disable();
			relicSlot.LockedIcon:Show();
			relicSlot.Icon:SetMask(nil);
			relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
			relicSlot.Glass:Hide();
		else
			relicSlot:GetNormalTexture():SetAlpha(1);
			relicSlot:Enable();
			relicSlot.LockedIcon:Hide();
			if relicIcon then
				relicSlot.Icon:SetSize(34, 34);
				relicSlot.Icon:SetTexture(relicIcon);
				relicSlot.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				relicSlot.Glass:Show();

				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH, true);
				ArtifactRelicHelpBox:Hide();
			else
				relicSlot.Icon:SetMask(nil);
				relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
				relicSlot.Glass:Hide();
			end
		end

		relicSlot.relicLink = relicLink;
		relicSlot.relicType = relicType;
		relicSlot.relicSlotIndex = i;
		relicSlot.lockedReason = lockedReason;
		
		relicSlot:ClearAllPoints();
		local PADDING = 0;
		if i == 1 then
			local offsetX = -(numRelicSlots - 1) * (relicSlot:GetWidth() + PADDING) * .5;
			relicSlot:SetPoint("CENTER", self, "CENTER", offsetX, -6);
		else
			relicSlot:SetPoint("LEFT", self.RelicSlots[i - 1], "RIGHT", PADDING, 0);
		end

		relicSlot:Show();
	end

	for i = numRelicSlots + 1, #self.RelicSlots do
		self.RelicSlots[i]:Hide();
	end
end

function ArtifactTitleTemplateMixin:SetPointsRemaining(value)
	self.PointsRemainingLabel:SetAnimatedValue(value);
end

function ArtifactTitleTemplateMixin:OnUpdate(elapsed)
	self.PointsRemainingLabel:UpdateAnimatedValue(elapsed);
end

function ArtifactTitleTemplateMixin:SetExpandedState(expanded)
	if self.expanded ~= expanded then
		self.expanded = expanded;

		self:SetHeight(self.expanded and 140 or 90);
	end
end