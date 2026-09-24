GroupTargeting = Mixin(CreateFrame("Frame", "GamepadGroupTargetingFrame"), CallbackRegistryMixin);
GroupTargeting:GenerateCallbackEvents({"GroupTargetingStateChanged"});
GroupTargeting.OnLoad(GroupTargeting);

function GroupTargeting:RegisterGroupTargetingStateChanged(callback, owner)
	self:RegisterCallback("GroupTargetingStateChanged", callback, owner);
end

function GroupTargeting:UnregisterGroupTargetingStateChanged(owner)
	self:UnregisterCallback("GroupTargetingStateChanged", owner);
end

function GroupTargeting:OnGroupTargetingChanged(active)
	self:TriggerEvent("GroupTargetingStateChanged", active);
	self:RefreshSmartNavigationPointer();
end

function GroupTargeting:RefreshSmartNavigationPointer()
	local anyModifierActive = GamepadMode.IsHUDBindingModifierDown() or GamepadMode.IsTargetingModifierDown();
	local showCursorActive = not self.isTargetingActive or not anyModifierActive;
	SmartNavigation:ShowCursorAsActive(showCursorActive);
end

function GroupTargeting:Init()
	self.TargetHighlight = CreateFrame("Frame", nil, self);

	self.isTargetingActive = false;
	self.inHoverMode = false;
	self.opening = false;

	self.currentTargetingContainer = nil;

	self:CreateHighlight();
	self:SetupFooters();

	self:SetScript("OnEvent", self.OnEvent);

	GamepadMode.RegisterInputModifierStateChangeCallback(GenerateClosure(self.RefreshSmartNavigationPointer, self), self);
	GamepadMode.RegisterTargetModifierStateChanged(GenerateClosure(self.RefreshSmartNavigationPointer, self), self);
	SmartNavigation:RegisterCallback("SelectedButtonUpdated", self.OnPlayerSelected, self);
end

function GroupTargeting:OnEvent(event, ...)
	if (event == "PLAYER_TARGET_CHANGED") then
		self:UpdateTarget();
	elseif (event == "GROUP_ROSTER_UPDATE") then
		self:RefreshTargeting();
	end
end

function GroupTargeting:CreateHighlight()
	-- TODO: Replace with actual art. Would only be used when in hover mode
	-- TODO: highlight specific to type of targeting? Party vs Raid
	local function MakeLine()
		local line = self.TargetHighlight:CreateLine();
		line:SetThickness(3);
		line:SetColorTexture(0,0,1,1);
		return line;
	end

	self.TargetHighlight.line1 = MakeLine();
	self.TargetHighlight.line1:SetStartPoint("TOPLEFT", self.TargetHighlight);
	self.TargetHighlight.line1:SetEndPoint("BOTTOMLEFT", self.TargetHighlight);
	self.TargetHighlight.line2 = MakeLine();
	self.TargetHighlight.line2:SetStartPoint("TOPLEFT", self.TargetHighlight);
	self.TargetHighlight.line2:SetEndPoint("TOPRIGHT", self.TargetHighlight);
	self.TargetHighlight.line3 = MakeLine();
	self.TargetHighlight.line3:SetStartPoint("TOPRIGHT", self.TargetHighlight);
	self.TargetHighlight.line3:SetEndPoint("BOTTOMRIGHT", self.TargetHighlight);
	self.TargetHighlight.line4 = MakeLine();
	self.TargetHighlight.line4:SetStartPoint("BOTTOMRIGHT", self.TargetHighlight);
	self.TargetHighlight.line4:SetEndPoint("BOTTOMLEFT", self.TargetHighlight);
end

function GroupTargeting:StartTargeting(inContainer, extraContainers)
	if self.isTargetingActive then
		return;
	end

	self.inHoverMode = GetCVarBool("GamepadRaidTargetingHoverMode");

	self.currentTargetingContainer = inContainer;
	self.currentExtraContainers = extraContainers;

	RaidTargetingManager:SetActive(true);
	self.opening = true;
	SmartNavigation:HandlePanelOpen(inContainer, extraContainers);
	SmartNavigation:SetWrapping(inContainer, true);
	SmartNavigation:SetUseGridNavigation(inContainer, true);
	self:SetStartTarget();
	SmartNavigation:Show();
	self.opening = false;

	self.isTargetingActive = true;

	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	self:OnGroupTargetingChanged(true);
	self:UpdateFooter();
end

function GroupTargeting:StopTargeting()
	if not self.isTargetingActive then
		return;
	end

	self.currentTargetingContainer = nil;
	self.currentExtraContainers = nil;

	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("GROUP_ROSTER_UPDATE");

	GamepadMode.UnregisterCrossBarModifierStateChanged(self);

	self.isTargetingActive = false;

	self:OnGroupTargetingChanged(false);

	RaidTargetingManager:SetActive(false);
	SmartNavigation:HandlePanelClose(self.currentTargetingContainer);
	SmartNavigation:Hide();

	self:UpdateFooter();
end

function GroupTargeting:OnPlayerSelected()
	if (not self.isTargetingActive or self.opening) then
		return;
	end

	local selectedPlayerFrame = SmartNavigation:GetCurrentButton();

	if selectedPlayerFrame then
		self.currentFrameSelected = selectedPlayerFrame;
		self.currentUnitTarget = selectedPlayerFrame.unit;

		RaidTargetingManager:SetTargetUnit(selectedPlayerFrame.unit);

		if self.inHoverMode then
			self.TargetHighlight:ClearAllPoints();
			self.TargetHighlight:SetPoint("TOPLEFT", selectedPlayerFrame);
			self.TargetHighlight:SetPoint("BOTTOMRIGHT", selectedPlayerFrame);
			self.TargetHighlight:Show();
		else
			selectedPlayerFrame:Click();
			self.TargetHighlight:Hide();
		end
	else
		self.TargetHighlight:Hide();
	end
end

function GroupTargeting:SetStartTarget()
	local targetToMatch = "target";

	if not UnitInAnyGroup("target") then
		targetToMatch = "player";
	end

	local function MatchTargetFunc(inFrame)
		if inFrame.unit then
			return UnitIsUnit(inFrame.unit, targetToMatch);
		else
			return false;
		end
	end

	local buttonFrame = SmartNavigation:FindButton(MatchTargetFunc);

	if buttonFrame then
		SmartNavigation:SetTargetButtonForFrame(self.currentTargetingContainer, buttonFrame);
	else
		SmartNavigation:SetTargetButtonForFrame(self.currentTargetingContainer, nil);
	end
end

function GroupTargeting:UpdateTarget()
	local function MatchTargetFunc(inFrame)
		if inFrame.unit then
			return UnitIsUnit(inFrame.unit, "target");
		else
			return false;
		end
	end

	if self.currentUnitTarget then
		if UnitIsUnit(self.currentUnitTarget, "target") then
			return;
		end
	end

	local buttonFrame = SmartNavigation:FindButton(MatchTargetFunc);

	if buttonFrame then
		SmartNavigation:SelectButton(buttonFrame);
	end
end

function GroupTargeting:RefreshTargeting()
	if not self.refreshing then
		self.refreshing = true;
		RunNextFrame(function()
			SmartNavigation:RefreshButtonGroups(self.currentTargetingContainer, self.currentExtraContainers);
			self:SetStartTarget();
			SmartNavigation:SelectFirstButton(true);
			self:UpdateFooter();
			self.refreshing = nil;
		end);
	end
end

function GroupTargeting:IsActive()
	return self.isTargetingActive;
end

function GroupTargeting:SetupFooters()
	local navigateDPad = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD, nil, ACTION_LABEL_SELECT);
	local closeTargeting = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, nil, GROUP_TARGETING_CLOSE);

	self.targetingActiveDPadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(PartyFrame, "TargetingActiveDPadFooter");
	self.targetingActiveDPadFooter:AddPromptedBinding(navigateDPad);
	self.targetingActiveDPadFooter:AddPromptedBinding(closeTargeting);
	self.targetingActiveDPadFooter:Finalize();

	self:UpdateFooter();
end

function GroupTargeting:UpdateFooter()
	if self.currentTargetingContainer then
		self.targetingActiveDPadFooter:SetParentFrame(self.currentTargetingContainer);
		self.targetingActiveDPadFooter:ShowAndActivateBindings();
	else
		self.targetingActiveDPadFooter:HideAndDeactivateBindings();
	end
end

GroupTargeting:Init();
