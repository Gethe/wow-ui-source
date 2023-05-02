-- Used for indexing bars
local BarsEnum = {
	None = -1,
	Reputation = 1,
	Honor = 2,
	Artifact = 3,
	Experience = 4,
	Azerite = 5,
}

local BarPriorities = {
	[BarsEnum.Azerite] = 0,
	[BarsEnum.Reputation] = 1,
	[BarsEnum.Honor] = 2,
	[BarsEnum.Artifact] = 3,
	[BarsEnum.Experience] = 4,
}

StatusTrackingManagerMixin = { };

function StatusTrackingManagerMixin:OnLoad()
	self.shownBarIndices = {};

	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
	self:RegisterEvent("ENABLE_XP_GAIN");
	self:RegisterEvent("DISABLE_XP_GAIN");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterUnitEvent("UNIT_LEVEL", "player");
end

function StatusTrackingManagerMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		self:UpdateBarTextVisibility();
	end

	if UnitExists("player") then
		for _, barContainer in ipairs(self.barContainers) do
			barContainer:UpdateShownBarAll();
		end

		self:UpdateBarsShown();
	end
end

function StatusTrackingManagerMixin:CanShowBar(barIndex)
	if barIndex == BarsEnum.Reputation then
		local name, reaction, minFaction, maxFaction, value, factionID = GetWatchedFactionInfo();
		return name ~= nil;
	elseif barIndex == BarsEnum.Honor then
		return IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP();
	elseif barIndex == BarsEnum.Artifact then
		return HasArtifactEquipped() and not C_ArtifactUI.IsEquippedArtifactMaxed() and not C_ArtifactUI.IsEquippedArtifactDisabled();
	elseif barIndex == BarsEnum.Experience then
		return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled();
	elseif barIndex == BarsEnum.Azerite then
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();
		return not C_AzeriteItem.IsAzeriteItemAtMaxLevel() and azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem);
	end

	return false;
end

function StatusTrackingManagerMixin:GetBarPriority(barIndex)
	return BarPriorities[barIndex] or -1;
end

function StatusTrackingManagerMixin:UpdateBarsShown()
	local function onFinishedAnimating(barContainer)
		barContainer:UnsubscribeFromOnFinishedAnimating(self);
		self:UpdateBarsShown();
	end

	-- If any bar is animating then wait for that animation to end before updating shown bars
	for i, barContainer in ipairs(self.barContainers) do
		if barContainer:IsAnimating() then
			barContainer:SubscribeToOnFinishedAnimating(self, onFinishedAnimating);
			return;
		end
	end

	-- Determine what bars should be shown
	local newBarIndicesToShow = {};
	for _, barIndex in pairs(BarsEnum) do
		if self:CanShowBar(barIndex) then
			table.insert(newBarIndicesToShow, barIndex);
		end
	end
	table.sort(newBarIndicesToShow, function(left, right) return self:GetBarPriority(left) > self:GetBarPriority(right) end);

	-- We can only show as many bars as we have containers for
	while #newBarIndicesToShow > #self.barContainers do
		table.remove(newBarIndicesToShow, #newBarIndicesToShow);
	end

	-- Assign the bar indices to the bar containers
	for i = 1, #self.barContainers do
		local barContainer = self.barContainers[i];
		local newBarIndex = newBarIndicesToShow[i] or BarsEnum.None;
		local oldBarIndex = self.shownBarIndices[i];

		if newBarIndex ~= oldBarIndex then
			-- If the bar being shown in this container is already being shown in another container then
			-- make both containers fade out fully before actually assigning the new bars.
			-- This will lead to the bars fading in together rather than staggering.
			if (newBarIndex ~= BarsEnum.None and tContains(self.shownBarIndices, newBarIndex))
			or (oldBarIndex ~= BarsEnum.None and tContains(newBarIndicesToShow, oldBarIndex)) then
				newBarIndex = BarsEnum.None;
				barContainer:SubscribeToOnFinishedAnimating(self, onFinishedAnimating);
			end
		end

		barContainer:SetShownBar(newBarIndex);
	end

	self.shownBarIndices = newBarIndicesToShow;
end

function StatusTrackingManagerMixin:SetTextLocked(isLocked)
	if self.textLocked ~= isLocked then
		self.textLocked = isLocked;
		self:UpdateBarTextVisibility();
	end
end

function StatusTrackingManagerMixin:IsTextLocked()
	return self.textLocked;
end

function StatusTrackingManagerMixin:UpdateBarTextVisibility()
	for i, barContainer in ipairs(self.barContainers) do
		barContainer:UpdateBarTextVisibility();
	end
end

function StatusTrackingManagerMixin:SetBarAnimation(Animation)
	for i, barContainer in ipairs(self.barContainers) do
		barContainer:SetBarAnimation(Animation);
	end
end

function StatusTrackingManagerMixin:UpdateBarTicks()
	for i, barContainer in ipairs(self.barContainers) do
		barContainer:UpdateBarTick();
	end
end

function StatusTrackingManagerMixin:ShowVisibleBarText()
	for i, barContainer in ipairs(self.barContainers) do
		barContainer:ShowText();
	end
end

function StatusTrackingManagerMixin:HideVisibleBarText()
	for i, barContainer in ipairs(self.barContainers) do
		barContainer:HideText();
	end
end

StatusTrackingBarContainerMixin = {};

function StatusTrackingBarContainerMixin:StatusTrackingBarContainer_OnLoad()
	self.bars = {};

	local barWidth = self:GetWidth() - 6;
	local barHeight = self:GetHeight() - 6;
	local function AddBar(barIndex, template)
		local bar = CreateFrame("FRAME", nil, self, template);
		bar.barIndex = barIndex;
		bar:ClearAllPoints();
		bar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 5);
		bar.StatusBar:SetSize(barWidth, barHeight);
		bar:SetSize(barWidth, barHeight);

		if bar.fadeOutEntireBarAtMaxLevel then
			bar.StatusBar:SetLevelUpMaxAlphaAnimation(self.MaxLevelFadeOutAnimation);
		end

		self.bars[barIndex] = bar;
	end

	AddBar(BarsEnum.Reputation, "ReputationStatusBarTemplate");
	AddBar(BarsEnum.Honor, "HonorStatusBarTemplate");
	AddBar(BarsEnum.Artifact, "ArtifactStatusBarTemplate");
	AddBar(BarsEnum.Experience, "ExpStatusBarTemplate");
	AddBar(BarsEnum.Azerite, "AzeriteBarTemplate");

	for _, bar in pairs(self.bars) do
		bar:Hide();
	end
	self.shownBarIndex = BarsEnum.None;
end

function StatusTrackingBarContainerMixin:SetShownBar(barIndex)
	if self.shownBarIndex == barIndex then
		self.pendingBarToShowIndex = nil;
		return;
	end

	self.pendingBarToShowIndex = barIndex;

	-- Fade in/out functions will handle applying the new bar to show
	if not self:IsVisible() or self:GetAlpha() <= 0 then
		if self.pendingBarToShowIndex == BarsEnum.None then
			-- If we don't have a bar to show and we're already not visible then just apply the pending bar to show
			-- This will handle hiding the currently shown bar
			self:ApplyPendingBarToShow();
		else
			-- If you're already not visible and we have a bar to show then fade in
			self:FadeIn();
		end
	else
		self:FadeOut();
	end
end

function StatusTrackingBarContainerMixin:ApplyPendingBarToShow()
	if not self.pendingBarToShowIndex then
		return;
	end

	if self.shownBarIndex == self.pendingBarToShowIndex then
		self.pendingBarToShowIndex = nil;
		return;
	end

	local oldBar = self.bars[self.shownBarIndex];
	if oldBar then
		oldBar:Hide();
	end

	local newBar = self.bars[self.pendingBarToShowIndex];
	if newBar then
		newBar:UpdateAll();
		newBar:Show();
	end

	self.shownBarIndex = self.pendingBarToShowIndex;
	self.pendingBarToShowIndex = nil;
end

function StatusTrackingBarContainerMixin:UpdateShownState()
	self:SetShown(self.shownBarIndex ~= BarsEnum.None or self.isInEditMode);
end

function StatusTrackingBarContainerMixin:FadeIn()
	-- Before fading in make sure to apply any pending bars to show
	self:ApplyPendingBarToShow();
	self:UpdateShownState();

	-- If we aren't showing a bar then don't fade in
	if self.shownBarIndex == BarsEnum.None then
		self:CheckIfStillAnimating();
		return;
	end

	if self.FadeInAnimation:IsPlaying() or self:GetAlpha() >= 1 then
		return;
	end

	if self.FadeOutAnimation:IsPlaying() or self.MaxLevelFadeOutAnimation:IsPlaying() then
		self.FadeOutAnimation:Stop();
		self.MaxLevelFadeOutAnimation:Stop();
	end

	self.FadeInAnimation:Restart();
end

function StatusTrackingBarContainerMixin:FadeOut()
	if self.FadeOutAnimation:IsPlaying() or self.MaxLevelFadeOutAnimation:IsPlaying() or self:GetAlpha() <= 0 then
		return;
	end

	if self.FadeInAnimation:IsPlaying() then
		self.FadeInAnimation:Stop();
	end

	self.FadeOutAnimation:Restart();
end

function StatusTrackingBarContainerMixin:IsShownBarAnimating()
	local shownBar = self.bars[self.shownBarIndex];
	return shownBar and (shownBar.StatusBar:IsAnimating() or shownBar.StatusBar:IsDirty());
end

function StatusTrackingBarContainerMixin:SubscribeToShownBarOnFinishedAnimating()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		if shownBar.StatusBar:IsDirty() then
			shownBar.StatusBar:SubscribeToOnClean(self, function(bar)
				bar:UnsubscribeFromOnClean(self);
				self:CheckIfStillAnimating();
			  end);
		elseif shownBar.StatusBar:IsAnimating() then
			shownBar.StatusBar:SubscribeToOnFinishedAnimating(self, function(bar)
				bar:UnsubscribeFromOnFinishedAnimating(self);
				self:CheckIfStillAnimating();
			end);
		end
	end
end

function StatusTrackingBarContainerMixin:IsAnimating()
	return self.FadeInAnimation:IsPlaying()
		or self.FadeOutAnimation:IsPlaying()
		or self.MaxLevelFadeOutAnimation:IsPlaying()
		or self:IsShownBarAnimating();
end

function StatusTrackingBarContainerMixin:CheckIfStillAnimating()
	if self:IsAnimating() then
		-- If we're still animating then make sure to subscribe to anything that could let us know when we're done animating
		if self:IsShownBarAnimating() then
			self:SubscribeToShownBarOnFinishedAnimating();
		end
		return;
	end

	-- If we finished animating then call our animation callbacks
	if self.animationFinishedCallbacks then
		for i, callback in pairs(self.animationFinishedCallbacks) do
			callback(self);
		end
	end
end

function StatusTrackingBarContainerMixin:SubscribeToOnFinishedAnimating(subscribingFrame, onFinishedCallback)
	if not self.animationFinishedCallbacks then
		self.animationFinishedCallbacks = {};
	end

	self.animationFinishedCallbacks[subscribingFrame] = onFinishedCallback;

	-- Subscribe to anything that could let us know when we're done animating
	if self:IsShownBarAnimating() then
		self:SubscribeToShownBarOnFinishedAnimating();
	end
end

function StatusTrackingBarContainerMixin:UnsubscribeFromOnFinishedAnimating(subscribingFrame)
	if not self.animationFinishedCallbacks then
		return;
	end

	self.animationFinishedCallbacks[subscribingFrame] = nil;
end

function StatusTrackingBarContainerMixin:UpdateShownBarAll()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		shownBar:UpdateAll();
	end
end

function StatusTrackingBarContainerMixin:UpdateBarTextVisibility()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		shownBar:UpdateTextVisibility();
	end
end

function StatusTrackingBarContainerMixin:SetBarAnimation(Animation)
	for i, bar in ipairs(self.bars) do
		bar.StatusBar:SetDeferAnimationCallback(Animation);
	end
end

function StatusTrackingBarContainerMixin:UpdateBarTick()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		shownBar:UpdateTick();
	end
end

function StatusTrackingBarContainerMixin:ShowText()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		shownBar:ShowText();
	end
end

function StatusTrackingBarContainerMixin:HideText()
	local shownBar = self.bars[self.shownBarIndex];
	if shownBar then
		shownBar:HideText();
	end
end

StatusTrackingBarContainerAnimationMixin = {};

function StatusTrackingBarContainerAnimationMixin:OnFinished()
	self:GetParent():CheckIfStillAnimating();
end

StatusTrackingBarContainerFadeOutAnimationMixin = CreateFromMixins(StatusTrackingBarContainerAnimationMixin);

function StatusTrackingBarContainerFadeOutAnimationMixin:OnFinished()
	local barContainer = self:GetParent();

	-- If we have a pending bar to show then call fade in which will handle everything
	if barContainer.pendingBarToShowIndex then
		barContainer:FadeIn();
		return;
	end

	barContainer:UpdateShownState();

	StatusTrackingBarContainerAnimationMixin.OnFinished(self);
end

EditModeStatusTrackingBarContainerMixin = {};

function EditModeStatusTrackingBarContainerMixin:OnLoad()
	self:StatusTrackingBarContainer_OnLoad();
	self:OnSystemLoad();
end