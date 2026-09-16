GamepadHudModeMixin = CreateFromMixins(CallbackRegistryMixin);

GamepadHudModeMixin:GenerateCallbackEvents({
	"SelectionStateEntered",
	"SelectionStateExited",
});

local function HudInfoLessThanCmp(a, b)
	local aFrameX, aFrameY = GetScaledCenter(a.frame);
	local bFrameX, bFrameY = GetScaledCenter(b.frame);

	-- Compare vertically for stacked frames
	if aFrameX == bFrameX then
		if aFrameY == bFrameY then
			--[[
				If the frames overlap at the exact same position, treat the one that was
				registered with the HUD Mode system first as the lesser frame.
			]]
			return a:GetID() < b:GetID();
		end
		return aFrameY > bFrameY;
	end

	return aFrameX < bFrameX;
end

local function ArrayIndexOf(tbl, obj)
	for k, v in ipairs(tbl) do
		if v == obj then
			return k;
		end
	end

	return nil;
end

function GamepadHudModeMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.hudInfoList = {};

	self.currentHudIndex = nil;
	self.isFrameActive = false;
	self.nextFrameRegistrationID = 1;

	-- Setup HUD Mode bindings.
	self.hudModeGeneralBindings = GamepadMode.CreateBindingGroup("GamepadHudModeGeneralBindings");
	self.hudModeGeneralBindings:BlockDpadAndFaceButtons();
	self.hudModeGeneralBindings:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.SelectNextHudFrame, self));
	self.hudModeGeneralBindings:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.SelectPreviousHudFrame, self));
	self.hudModeGeneralBindings:AddFunctionBinding(GAMEPAD_FACE_BOTTOM,  GenerateClosure(self.ActivateHudFrame, self));

	self.hudModeActiveFrameBindings = GamepadMode.CreateBindingGroup("GamepadHudModeActiveFrameBindings");
	self.hudModeActiveFrameBindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.Exit, self));
	self.hudModeActiveFrameBindings:AddFunctionBinding(GAMEPAD_MENU_LEFT, GenerateClosure(self.ToggleEditMode, self));
end

function GamepadHudModeMixin:OnShow()
	self.isFrameActive = false;
	self.currentHudIndex = nil;

	local startingFrame = ObjectiveTrackerFrame;
	local startingHudInfo = self:GetHudInfoByFrame(startingFrame);
	local startingHudIndex = self:GetIndexByHudInfo(startingHudInfo);

	-- If the starting frame is unavailable, find the first available frame.
	if (not startingHudInfo or not startingHudInfo:IsAvailable()) then
		startingHudIndex = self:GetFirstAvailableHudIndex();
	end

	if startingHudIndex then
		self:SelectHudFrame(startingHudIndex);
	else
		-- If there are no available frames, cancel HUD Mode
		self:Hide();
		return;
	end

	GamepadMode.ActivateBindingGroup(self.hudModeGeneralBindings);
	GamepadMode.ActivateBindingGroup(self.hudModeActiveFrameBindings, GAMEPAD_BINDS_ALWAYS_ON_TOP);
	self:TriggerEvent(self.Event.SelectionStateEntered);

	self.GamepadHudCursor:Show();
	GamepadMode.FrameControlsManager:HideActiveFrames();

	GamepadPersistentInputLegend:RefreshVisibility();

	local function HandleHUDModePanelOpening(frame)
		if (not frame) then
			return;
		end

		--[[
			If the player starts opening panels while in HUD Mode, close any context menus the player may have opened
			while in HUD Mode using the mouse or gamepad (handles opening panels with keyboard shortcuts while context
			menus are open in HUD Mode) and exit HUD Mode.
		]]
		Menu.GetManager():CloseMenus();
		self:Hide();
	end

	EventRegistry:RegisterCallback("UIParentPanelManager.ShowUIPanel", function(_, frame)
		HandleHUDModePanelOpening(frame);
	end, self);

	-- Bags don't use ShowUIPanel.
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function(_, bagFrame)
		HandleHUDModePanelOpening(bagFrame);
	end, self);
end

function GamepadHudModeMixin:OnHide()
	self:HideFrameHudElements();
	GamepadMode.DeactivateBindingGroup(self.hudModeActiveFrameBindings);
	GamepadMode.DeactivateBindingGroup(self.hudModeGeneralBindings);
	self:TriggerEvent(self.Event.SelectionStateExited);

	if self.isFrameActive then
		local currentHudInfo = self:GetCurrentHudInfo();
		currentHudInfo:DeactivateInfoFrame();
	end

	GamepadMode.FrameControlsManager:RefreshFocus(); -- Trigger a refresh manually; HUD Mode doesn't change focused windows but may make things focusable.
	GamepadPersistentInputLegend:RefreshVisibility();

	EventRegistry:UnregisterCallback("UIParentPanelManager.ShowUIPanel", self);
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
end

function GamepadHudModeMixin:RegisterForHudMode(frame, cursorAnchor, activateFunction, deactivateFunction, availabilityFunction)
	local hudInfo = CreateAndInitFromMixin(GamepadHudInfoMixin,
										   frame,
										   cursorAnchor,
										   activateFunction,
										   deactivateFunction,
										   availabilityFunction);
	hudInfo:SetID(self.nextFrameRegistrationID);
	self.nextFrameRegistrationID = self.nextFrameRegistrationID + 1;
	table.insert(self.hudInfoList, hudInfo);
end

function GamepadHudModeMixin:GetHudInfoByFrame(frame)
	for i, hudInfo in ipairs(self.hudInfoList) do
		if hudInfo.frame == frame then
			return hudInfo, i;
		end
	end
	return nil, 0;
end

function GamepadHudModeMixin:GetHudInfoByIndex(index)
	return self.hudInfoList[index];
end

function GamepadHudModeMixin:GetIndexByHudInfo(info)
	return ArrayIndexOf(self.hudInfoList, info);
end

function GamepadHudModeMixin:GetCurrentHudInfo()
	return self.hudInfoList[self.currentHudIndex];
end

function GamepadHudModeMixin:GetFirstAvailableHudIndex()
	for index, hudInfo in ipairs(self.hudInfoList) do
		if hudInfo:IsAvailable() then
			return index;
		end
	end
	return nil;
end

function GamepadHudModeMixin:UpdateCursorPosition(info, skipIntroAnim)
	local cursorAnchor = info.cursorAnchor;
	self.GamepadHudCursor:ClearAllPoints();
	self.GamepadHudCursor:SetPoint(cursorAnchor.point, cursorAnchor.relativeTo, cursorAnchor.relativePoint, cursorAnchor.x, cursorAnchor.y);

	local introAnim = self.GamepadHudCursor.IntroAnim;
	if introAnim:IsPlaying() then
		introAnim:Finish();
	end

	-- Unless told to skip, play the cursor refocus animation when swapping HUD Mode regions since it may be a large jump.
	if (not skipIntroAnim) then
		introAnim:Play();
	end
end

function GamepadHudModeMixin:SelectHudFrame(index, skipCursorIntroAnim)
	local nextHudInfo = self:GetHudInfoByIndex(index);
	if nextHudInfo then
		if nextHudInfo:IsAvailable() then
			self:UpdateCursorPosition(nextHudInfo, skipCursorIntroAnim);
			self.currentHudIndex = index;
		end
	end
end

function GamepadHudModeMixin:StartHudModeOnFrame(frame)
	local hudInfo, hudIndex = self:GetHudInfoByFrame(frame);
	if (hudInfo and hudInfo:IsAvailable()) then
		self:Show();
		self:SelectHudFrame(hudIndex);
		self:ActivateHudFrame();
	end
end

function GamepadHudModeMixin:SelectNextHudFrame()
	local index = self.currentHudIndex + 1;
	while index ~= self.currentHudIndex do
		if (index > #self.hudInfoList) then
			index = 1;
		end

		local nextHudInfo = self:GetHudInfoByIndex(index);
		if (nextHudInfo and nextHudInfo:IsAvailable()) then
			self:SelectHudFrame(index);
		else
			index = index + 1;
		end
	end
end

function GamepadHudModeMixin:SelectPreviousHudFrame()
	local index = self.currentHudIndex - 1;
	while index ~= self.currentHudIndex do
		if (index < 1) then
			index = #self.hudInfoList;
		end

		local previousHudInfo = self:GetHudInfoByIndex(index);
		if (previousHudInfo and previousHudInfo:IsAvailable()) then
			self:SelectHudFrame(index);
		else
			index = index - 1;
		end
	end
end

function GamepadHudModeMixin:SelectFirstAvailableHudFrame(skipIntroAnim)
	local index = self:GetFirstAvailableHudIndex();
	if index then
		self:SelectHudFrame(index, skipIntroAnim);
	else
		self:Hide();
	end
end

function GamepadHudModeMixin:IsFrameSelected(frame)
	local frameInfo, frameIndex = self:GetHudInfoByFrame(frame);
	if (not frameInfo) then
		return false;
	end

	return frameIndex == self.currentHudIndex;
end

function GamepadHudModeMixin:IsHudModeActiveFrame(frame)
	return self.isFrameActive and self:IsFrameSelected(frame);
end

function GamepadHudModeMixin:IsFrameAnAvailableOption(frame)
	local frameInfo = self:GetHudInfoByFrame(frame);
	return frameInfo and frameInfo:IsAvailable();
end

function GamepadHudModeMixin:HasActiveFrame()
	return self.isFrameActive;
end

function GamepadHudModeMixin:IsHUDModeActive()
	return self:IsShown();
end

function GamepadHudModeMixin:RefreshSelectionState()
	if (self.isFrameActive or not self:IsHUDModeActive()) then
		return;
	end

	local currentHUDInfo = self:GetHudInfoByIndex(self.currentHudIndex);
	if (currentHUDInfo and currentHUDInfo:IsAvailable()) then
		local updatedHUDInfoIndex = self:GetIndexByHudInfo(currentHUDInfo);
		local skipCursorIntroAnim = true;
		self:SelectHudFrame(updatedHUDInfoIndex, skipCursorIntroAnim);
	else
		self:SelectFirstAvailableHudFrame();
	end
end

function GamepadHudModeMixin:HideFrameHudElements()
	self.GamepadHudCursor:Hide();
end

function GamepadHudModeMixin:ShowFrameHudElements()
	self.GamepadHudCursor:Show();
end

function GamepadHudModeMixin:SelectAndActivateFrame(frame)
	local frameHUDInfo, frameIndex = self:GetHudInfoByFrame(frame);
	if (frameHUDInfo) then
		self:SelectHudFrame(frameIndex);
		self:ActivateHudFrame();
		return;
	end
	self:Hide();
end

function GamepadHudModeMixin:ActivateHudFrame()
	self:HideFrameHudElements();

	GamepadMode.DeactivateBindingGroup(self.hudModeGeneralBindings);
	self:TriggerEvent(self.Event.SelectionStateExited);

	local currentHudInfo = self:GetCurrentHudInfo();
	currentHudInfo:ActivateInfoFrame();
	self.isFrameActive = true;
end

function GamepadHudModeMixin:Exit()
	self:Hide();
end

function GamepadHudModeMixin:ToggleEditMode()
	if not self.isFrameActive then
	end
end

GamepadHudInfoMixin = {};

function GamepadHudInfoMixin:Init(frame, cursorAnchor, activateFunction, deactivateFunction, availabilityFunction)
	self.frame = frame;
	self.cursorAnchor = cursorAnchor;
	self.activateFunction = activateFunction;
	self.deactivateFunction = deactivateFunction;
	self.availabilityFunction = availabilityFunction;
end

function GamepadHudInfoMixin:ActivateInfoFrame()
	if self.activateFunction then
		self.activateFunction();
	end
end

function GamepadHudInfoMixin:DeactivateInfoFrame()
	if self.deactivateFunction then
		self.deactivateFunction();
	end
end

function GamepadHudInfoMixin:IsAvailable()
	if self.availabilityFunction then
		return self.availabilityFunction();
	else
		return true;
	end
end

function GamepadHudInfoMixin:SetID(id)
	self.id = id;
end

function GamepadHudInfoMixin:GetID()
	return self.id;
end

function GamepadHudInfoMixin:GetFrame()
	return self.frame;
end

function GamepadHudInfoMixin:SetCustomHUDModeExitHandler(exitHandlerFunc)
	self.exitHandlerFunc = exitHandlerFunc;
end

function GamepadHudInfoMixin:GetCustomHUDModeExitHandler()
	return self.exitHandlerFunc;
end
