
StatusTrackingBarInfo = { };

-- Used for indexing bars
StatusTrackingBarInfo.BarsEnum = {
	None = -1,
	Reputation = 1,
	Honor = 2,
	Artifact = 3,
	Experience = 4,
	Azerite = 5,
	HouseFavor = 6,
}

StatusTrackingBarInfo.BarPriorities = {
	[StatusTrackingBarInfo.BarsEnum.Azerite] = 0,
	[StatusTrackingBarInfo.BarsEnum.Reputation] = 1,
	[StatusTrackingBarInfo.BarsEnum.Honor] = 2,
	[StatusTrackingBarInfo.BarsEnum.Artifact] = 3,
	[StatusTrackingBarInfo.BarsEnum.Experience] = 4,
	[StatusTrackingBarInfo.BarsEnum.HouseFavor] = 5,
}

StatusTrackingManagerMixin = { };

function StatusTrackingManagerMixin:OnLoad()
	self.shownBarIndices = {};

	self:RegisterEvents();
end

function StatusTrackingManagerMixin:RegisterEvents()
	-- Override me!
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
	-- Override me!
	return false;
end

function StatusTrackingManagerMixin:GetBarPriority(barIndex)
	return StatusTrackingBarInfo.BarPriorities[barIndex] or -1;
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
	for _, barIndex in pairs(StatusTrackingBarInfo.BarsEnum) do
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
		local newBarIndex = newBarIndicesToShow[i] or StatusTrackingBarInfo.BarsEnum.None;
		local oldBarIndex = self.shownBarIndices[i];

		if newBarIndex ~= oldBarIndex then
			-- If the bar being shown in this container is already being shown in another container then
			-- make both containers fade out fully before actually assigning the new bars.
			-- This will lead to the bars fading in together rather than staggering.
			if (newBarIndex ~= StatusTrackingBarInfo.BarsEnum.None and tContains(self.shownBarIndices, newBarIndex))
			or (oldBarIndex ~= StatusTrackingBarInfo.BarsEnum.None and tContains(newBarIndicesToShow, oldBarIndex)) then
				newBarIndex = StatusTrackingBarInfo.BarsEnum.None;
				barContainer:SubscribeToOnFinishedAnimating(self, onFinishedAnimating);
			end
		end

		barContainer:SetShownBar(newBarIndex);
	end

	self.shownBarIndices = newBarIndicesToShow;

	self:UpdateBarVisuals();
end

function StatusTrackingManagerMixin:UpdateBarVisuals()
	-- Override me!
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

function StatusTrackingManagerMixin:GetNumBarsInDefaultPosition()
	local count = 0;
	for i, barContainer in ipairs(self.barContainers) do
		if (barContainer:IsShown() and barContainer:IsInDefaultPosition()) then
			count = count + 1;
		end
	end

	return count;
end

StatusTrackingBarContainerMixin = {};

function StatusTrackingBarContainerMixin:StatusTrackingBarContainer_OnLoad()
	self.bars = {};

	self:InitializeBars()

	for _, bar in pairs(self.bars) do
		bar:Hide();
	end
	self.shownBarIndex = StatusTrackingBarInfo.BarsEnum.None;
end

function StatusTrackingBarContainerMixin:InitializeBars()
	-- Override me!
end

function StatusTrackingBarContainerMixin:SetShownBar(barIndex)
	if self.shownBarIndex == barIndex then
		self.pendingBarToShowIndex = nil;
		return;
	end

	self.pendingBarToShowIndex = barIndex;

	-- Fade in/out functions will handle applying the new bar to show
	if not self:IsVisible() or self:GetAlpha() <= 0 then
		if self.pendingBarToShowIndex == StatusTrackingBarInfo.BarsEnum.None then
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

	local oldBar = self:GetShownBar();
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
	self:SetShown(self.shownBarIndex ~= StatusTrackingBarInfo.BarsEnum.None or self.isInEditMode);
	UIParent_ManageFramePositions();
end

function StatusTrackingBarContainerMixin:FadeIn()
	-- Before fading in make sure to apply any pending bars to show
	self:ApplyPendingBarToShow();
	self:UpdateShownState();

	-- If we aren't showing a bar then don't fade in
	if self.shownBarIndex == StatusTrackingBarInfo.BarsEnum.None then
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

function StatusTrackingBarContainerMixin:GetShownBar()
	return self.bars[self.shownBarIndex];
end

function StatusTrackingBarContainerMixin:IsShownBarAnimating()
	local shownBar = self:GetShownBar();
	return shownBar and (shownBar.StatusBar:IsAnimating() or shownBar.StatusBar:IsDirty());
end

function StatusTrackingBarContainerMixin:SubscribeToShownBarOnFinishedAnimating()
	local shownBar = self:GetShownBar();
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
	local shownBar = self:GetShownBar();
	if shownBar then
		shownBar:UpdateAll();
	end
end

function StatusTrackingBarContainerMixin:UpdateBarTextVisibility()
	local shownBar = self:GetShownBar();
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
	local shownBar = self:GetShownBar();
	if shownBar then
		shownBar:UpdateTick();
	end
end

function StatusTrackingBarContainerMixin:ShowText()
	local shownBar = self:GetShownBar();
	if shownBar then
		shownBar:ShowText();
	end
end

function StatusTrackingBarContainerMixin:HideText()
	local shownBar = self:GetShownBar();
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
