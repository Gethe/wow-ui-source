function GetBottomManagedFrameContainer()
	return BottomManagedFrameContainer;
end

function GetRightManagedFrameContainer()
	return RightManagedFrameContainer;
end

function GetPlayerBottomManagedFrameContainer()
	return PlayerBottomManagedFrameContainer;
end

local TOP_LEVEL_PARENT_SHOWN_EVENT = "UI.TopLevelParentShown";
local TOP_LEVEL_PARENT_HIDDEN_EVENT = "UI.TopLevelParentHidden";

ManagedFrameMixin = { };
function ManagedFrameMixin:OnShow()
	self.layoutParent:AddManagedFrame(self);
end

function ManagedFrameMixin:OnHide()
	self.layoutParent:RemoveManagedFrame(self);
end

local function IsActionBarOverriden()
	return OverrideActionBar and OverrideActionBar:IsShown() or false;
end

local function UpdateFrameAlphaState(frame, isActionBarOverriden)
	if frame.hideWhenActionBarIsOverriden then
		local setToAlpha = isActionBarOverriden and 0 or 1;
		frame:SetAlpha(setToAlpha);

		if frame.ignoreInLayoutWhenActionBarIsOverriden then
			frame.ignoreInLayout = isActionBarOverriden;
		end
	end
end

ManagedFrameContainerMixin = {};

function ManagedFrameContainerMixin:OnLoad()
	self.showingFrames = {};
end

function ManagedFrameContainerMixin:UpdateFrame(frame)
	frame:ClearAllPoints();
	frame:SetParent(frame.layoutOnBottom and self.BottomManagedLayoutContainer or self);
	self:Layout();
	self.BottomManagedLayoutContainer:Layout();

	if frame.isRightManagedFrame and ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end
end

function ManagedFrameContainerMixin:AddManagedFrame(frame)
	if frame.ignoreFramePositionManager then
		return;
	end

	if frame.IsInDefaultPosition and not frame:IsInDefaultPosition() then
		return;
	end

	if not frame:IsShown() then
		return;
	end

	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden and not self.showingFrames[frame] then
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end

	self.showingFrames[frame] = frame;
	self:UpdateFrame(frame);
end

function ManagedFrameContainerMixin:UpdateManagedFrames()
	for _, frame in pairs(self.showingFrames) do
		if frame then
			self:UpdateFrame(frame);
		end
	end

	self:AnimInManagedFrames();
end

function ManagedFrameContainerMixin:ClearManagedFrames()
	self:AnimOutManagedFrames();
end

function ManagedFrameContainerMixin:RemoveManagedFrame(frame)
	if not self.showingFrames[frame] then
		return;
	end
	self.showingFrames[frame] = nil;

	if not frame.IsInDefaultPosition then
		frame:ClearAllPoints();
	end

	if ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end

	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden then
		local isActionBarOverridenForFrame = false;
		UpdateFrameAlphaState(frame, isActionBarOverridenForFrame);
	end

	self:Layout();
	self.BottomManagedLayoutContainer:Layout();
end

function ManagedFrameContainerMixin:UpdateManagedFramesAlphaState()
	local isActionBarOverriden = IsActionBarOverriden();
	for frame in pairs(self.showingFrames) do
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end
end

function ManagedFrameContainerMixin:AnimOutManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(0);
	end
end

function ManagedFrameContainerMixin:AnimInManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(1);
	end
end

local function UpdateManagedFrameContainers()
	local bottomManagedFrameContainer = GetBottomManagedFrameContainer and GetBottomManagedFrameContainer();
	if ( bottomManagedFrameContainer ) then
		bottomManagedFrameContainer:UpdateManagedFrames();
	end

	local rightManagedFrameContainer = GetRightManagedFrameContainer and GetRightManagedFrameContainer();
	if ( rightManagedFrameContainer ) then
		rightManagedFrameContainer:UpdateManagedFrames();
	end
end

local function ClearManagedFrameContainers()
	local bottomManagedFrameContainer = GetBottomManagedFrameContainer and GetBottomManagedFrameContainer();
	if ( bottomManagedFrameContainer ) then
		bottomManagedFrameContainer:ClearManagedFrames();
	end

	local rightManagedFrameContainer = GetRightManagedFrameContainer and GetRightManagedFrameContainer();
	if ( rightManagedFrameContainer ) then
		rightManagedFrameContainer:ClearManagedFrames();
	end
end

EventRegistry:RegisterCallback(TOP_LEVEL_PARENT_SHOWN_EVENT, UpdateManagedFrameContainers);
EventRegistry:RegisterCallback(TOP_LEVEL_PARENT_HIDDEN_EVENT, ClearManagedFrameContainers);

if UIParent:IsShown() then
	UpdateManagedFrameContainers();
else
	ClearManagedFrameContainers();
end
