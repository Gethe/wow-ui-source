local DAMAGE_METER_ENABLED_CVAR = "damageMeterEnabled";
CVarCallbackRegistry:SetCVarCachable(DAMAGE_METER_ENABLED_CVAR);

local MAX_DAMAGE_METER_WINDOW_FRAMES = 3;

DamageMeterMixin = {};

function DamageMeterMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCallback(DAMAGE_METER_ENABLED_CVAR, self.OnEnabledCVarChanged, self);

	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	local windowResetCallback = function(pool, windowFrame)
		Pool_HideAndClearAnchors(pool, windowFrame);
	end;
	self.windowPool = CreateFramePool("FRAME", self, "DamageMeterWindowTemplate", windowResetCallback);

	-- Create the Primary Window Frame, which much always exist and can't be deleted.
	self:CreateNewWindowFrame();
end

function DamageMeterMixin:OnEvent(event, ...)
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_LEVEL_CHANGED" then
		self:UpdateShownState();
	end
end

function DamageMeterMixin:OnVariablesLoaded()
	self:UpdateShownState();
end

function DamageMeterMixin:OnEnabledCVarChanged()
	self:UpdateShownState();
end

function DamageMeterMixin:GetWindowList()
	return self.windowList;
end

function DamageMeterMixin:RefreshWindows()
	self.windowPool:ReleaseAll();
	self.windowFrames = {};

	local relativePoint = "TOPLEFT";
	local relativeFrame = self;
	local windowFrameIndex = 1;

	local windowList = self:GetWindowList();
	for i, windowData in ipairs(windowList) do
		local windowFrame = self.windowPool:Acquire();
		windowFrame:SetDamageMeterOwner(self, windowFrameIndex);
		windowFrame:SetTrackedStat(windowData.trackedStat);
		windowFrame:SetPoint("TOPLEFT", relativeFrame, relativePoint);
		windowFrame:Show();

		relativePoint = "BOTTOMLEFT";
		relativeFrame = windowFrame;

		windowFrameIndex = windowFrameIndex + 1;
		table.insert(self.windowFrames, windowFrame );
	end
end

function DamageMeterMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;

	self:UpdateShownState();
end

function DamageMeterMixin:IsEditing()
	return self.isEditing;
end

function DamageMeterMixin:ShouldBeShown()
	if self:IsEditing() then
		return true;
	end

	if CVarCallbackRegistry:GetCVarValueBool(DAMAGE_METER_ENABLED_CVAR) ~= true then
		return false;
	end

	local isAvailable, _failureReason = C_DamageMeter.IsDamageMeterAvailable();
	if not isAvailable then
		return false;
	end

	if self.visibility then
		if self.visibility == Enum.DamageMeterVisibility.Always then
			return true;
		elseif self.visibility == Enum.DamageMeterVisibility.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibility == Enum.DamageMeterVisibility.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: " .. self.visibleSetting);
		end
	end

	return true;
end

function DamageMeterMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
end

function DamageMeterMixin:RefreshLayout()
	for windowFrame in self.windowPool:EnumerateActive() do
		windowFrame:RefreshLayout();
	end
end

function DamageMeterMixin:GetWindowFrame(index)
	return self.windowFrames and self.windowFrames[index] or nil;
end

function DamageMeterMixin:GetPrimaryWindowFrame()
	return self:GetWindowFrame(1);
end

function DamageMeterMixin:GetMaxWindowFrameCount()
	return MAX_DAMAGE_METER_WINDOW_FRAMES;
end

function DamageMeterMixin:GetCurrentWindowFrameCount()
	return self.windowFrames and #self.windowFrames or 0;
end

function DamageMeterMixin:CanCreateNewWindowFrame()
	return self:GetCurrentWindowFrameCount() < self:GetMaxWindowFrameCount();
end

function DamageMeterMixin:CreateNewWindowFrame()
	if self:CanCreateNewWindowFrame() ~= true then
		return;
	end

	if not self.windowList then
		self.windowList = {};
	end

	table.insert(self.windowList, {trackedStat = "Damage Done"} );

	self:RefreshWindows();
end

function DamageMeterMixin:CanDeleteWindowFrame(windowFrame)
	return self:GetPrimaryWindowFrame() ~= windowFrame;
end

function DamageMeterMixin:DeleteWindowFrame(windowFrame)
	if self:CanDeleteWindowFrame(windowFrame) ~= true then
		return;
	end

	table.remove(self.windowList, windowFrame:GetWindowFrameIndex());

	self:RefreshWindows();
end
