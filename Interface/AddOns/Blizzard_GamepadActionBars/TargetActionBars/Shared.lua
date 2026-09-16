local Shared = {};

Shared.INACTIVE_BAR_FADE_DURATION = 2;
Shared.INACTIVE_BAR_FADE_OPACITY = 0.3;

function Shared.SetButtonHandler(actionButton, fn, upAndDown)
	actionButton:SetScript("OnClick", function(_, _, down)
		GamepadTargetLogic:ConsumeModifier();
		if down or upAndDown then
			fn(down);
		end
	end);
end

local function GetNextRaidTargetMarkerIndex(direction)
	local currentMarker = GetRaidTargetIndex("target");
	local firstMarker = (direction > 0) and 1 or Constants.RaidMarkerConsts.MAX_RAID_TARGETS_USER;
	local lastMarker = firstMarker + direction * (Constants.RaidMarkerConsts.MAX_RAID_TARGETS_USER - 1);
	local firstMarkerToCheck = currentMarker and (currentMarker + direction) or firstMarker;

	-- If we've wrapped around, the next action should be to remove the marker rather than wrap
	if firstMarkerToCheck == lastMarker + direction then
		return nil;
	end

	local reverseSearch = direction < 0;
	local nextMarker = GetNextAvailableRaidTargetMarkerIndex(
		firstMarkerToCheck,
		reverseSearch,
		false, -- wrapSearch
		true); -- treatDeadNonFriendlyMarkersAsAvailable

	if nextMarker == 0 then
		-- If all markers are used already, make the binding move the first one
		if not currentMarker then
			return firstMarker;
		end
		return nil;
	end

	return nextMarker;
end

function Shared.ResetTargetMarkerButton(actionBar, actionButton)
	if actionButton.playerTargetChangedOwner then
		EventRegistry:UnregisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", actionButton.playerTargetChangedOwner);
		actionButton.playerTargetChangedOwner = nil;
	end

	if actionButton.raidTargetUpdateOwner then
		EventRegistry:UnregisterFrameEventAndCallback("RAID_TARGET_UPDATE", actionButton.raidTargetUpdateOwner);
		actionButton.raidTargetUpdateOwner = nil;
	end

	actionButton.SpecialActionIcon:SetAllPoints();
	actionButton.SpecialActionIcon:SetDesaturated(false);
end

function Shared.SetUpTargetMarkerButton(actionBar, actionButton, direction)
	local function UpdateState()
		local nextMarker = GetNextRaidTargetMarkerIndex(direction);
		local markerToShow = nextMarker or GetRaidTargetIndex("target");
		local targetExists = UnitExists("target");

		SetRaidTargetIconTexture(actionButton.SpecialActionIcon, markerToShow);
		actionBar:SetButtonEnabled(actionButton, targetExists and not Kiosk.IsEnabled());
		actionButton.IconOverlay:SetShown(not nextMarker);
	end

	local function ApplyOrClearMarker()
		if UnitExists("target") then
			local nextMarker = GetNextRaidTargetMarkerIndex(direction);
			SetRaidTarget("target", nextMarker or 0);
			UpdateState();
		else
			UIErrorsFrame:AddExternalErrorMessage(ERR_GENERIC_NO_TARGET);
		end
	end

	actionButton.playerTargetChangedOwner = EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", UpdateState);
	actionButton.raidTargetUpdateOwner = EventRegistry:RegisterFrameEventAndCallback("RAID_TARGET_UPDATE", UpdateState);

	UpdateState();

	actionButton.SpecialActionIcon:ClearAllPoints();
	actionButton.SpecialActionIcon:SetPoint("TOPLEFT", 6, -6);
	actionButton.SpecialActionIcon:SetPoint("BOTTOMRIGHT", -6, 6);
	actionButton.SpecialActionIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
	actionButton.SpecialActionIcon:Show();
	actionButton.IconOverlay:SetAtlas("gamepad-actionbar-circleslot-permabound");

	Shared.SetButtonHandler(actionButton, ApplyOrClearMarker);
end

function Shared.RefreshAssistButton(actionBar, actionButton)
	-- Don't allow assisting the player themselves
	if UnitExists("targettarget") and not UnitIsUnit("player", "targettarget") then
		SetPortraitTexture(actionButton.SpecialActionIcon, "targettarget");
		actionButton.SpecialActionIcon:Show();
		actionBar:SetButtonEnabled(actionButton, true);
	else
		actionButton.SpecialActionIcon:Hide();
		actionBar:SetButtonEnabled(actionButton, false);
	end
end

function Shared.ResetTargetingButton(actionButton)
	actionButton:SetAttribute("type", "action");
	actionButton:SetAttribute("unit", nil);
end

function Shared.SetUpTargetingButton(actionButton, unitToken)
	actionButton:SetAttribute("type", "target");
	actionButton:SetAttribute("unit", unitToken);
	actionButton:SetScript("OnClick", function(_, button, down)
		GamepadTargetLogic:ConsumeModifier();
		SecureActionButton_OnClick(actionButton, button, down);
	end);
end

---------------------------------------------------------------------------------------------------

local SharedBarStateMixin = {};

Shared.SharedBarStateMixin = SharedBarStateMixin;

function SharedBarStateMixin:Init(pageUnit)
	self.fadeOutDelay = CVarCallbackRegistry:GetCVarNumberOrDefault("GamepadTargetingModifierVisualDelay");
	self.pageUnit = pageUnit;

	CVarCallbackRegistry:RegisterCallback("GamepadTargetingModifierVisualDelay", function(_, value)
		self.fadeOutDelay = tonumber(value);
	end);
end

function SharedBarStateMixin:FadeOutInactiveBars()
	if self.restoreTimer then
		self.restoreTimer:Cancel();
		self.restoreTimer = nil;
	end

	if self.fadeOutTimer or self.hasStartedFading then
		return;
	end

	local function BeginFadeOut()
		local fadeInfo = {
			mode = "OUT",
			timeToFade = Shared.INACTIVE_BAR_FADE_DURATION,
			endAlpha = Shared.INACTIVE_BAR_FADE_OPACITY,
		};

		for _, actionBar in pairs(self.pageUnit.actionBars) do
			local isTopAnchored = actionBar:GetParent() == self.pageUnit.TopCenteredAnchor;
			if not isTopAnchored then
				if actionBar:IsShown() then
					UIFrameFade(actionBar, fadeInfo);
				else
					actionBar:SetAlpha(Shared.INACTIVE_BAR_FADE_OPACITY);
				end
			end
		end

		self.hasStartedFading = true;
		self.fadeOutTimer = nil;
	end

	self.fadeOutTimer = C_Timer.NewTimer(self.fadeOutDelay, BeginFadeOut);
end

function SharedBarStateMixin:RestoreInactiveBars()
	-- Wait until the end of the frame with restoring, since another modifier may activate
	-- immediately after, in which case we want to continue fading.
	if self.restoreTimer then
		return;
	end

	self.restoreTimer = C_Timer.NewTimer(0, function()
		self.restoreTimer = nil;

		if self.hasStartedFading then
			for _, actionBar in pairs(self.pageUnit.actionBars) do
				if actionBar.fadeInfo then
					UIFrameFadeRemoveFrame(actionBar);
					actionBar.fadeInfo = nil;
				end
				actionBar:SetAlpha(1);
			end
			self.hasStartedFading = false;
		elseif self.fadeOutTimer then
			self.fadeOutTimer:Cancel();
			self.fadeOutTimer = nil;
		end
	end);
end

return Shared;
