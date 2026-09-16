local Utility = require(".Utility");

local BUTTON_COLOR = { 0, 1, 0, 0.2 };
local SCROLL_FRAME_COLOR = { 1, 1, 0, 0.2 };

local DebugOverlayMixin = {};

function DebugOverlayMixin:Init()
	self.noEdit = true;
	self.texture = self:CreateTexture(nil, "BACKGROUND");
	self.texture.noEdit = true;
	self.texture:SetAllPoints(self);
	self.texture:Show();
end

function DebugOverlayMixin:Reset()
	self:ClearAllPoints();
	self:Hide();
end

function DebugOverlayMixin:SetColor(color)
	self.texture:SetColorTexture(unpack(color));
end

local SmartNavigationDebug = CreateFrame("FRAME", "SmartNavigationDebug");

function SmartNavigationDebug:Init()
	local function InitOverlayFrame(frame)
		Mixin(frame, DebugOverlayMixin);
		frame:Init();
	end

	local function ResetOverlayFrame(_, frame)
		frame:Reset();
	end

	self.frames = {};
	self.noEdit = true;
	self.overlayPool = CreateFramePool("FRAME", self, nil, ResetOverlayFrame, nil, InitOverlayFrame);

	self:Hide();
	self:SetFrameLevel(10000);
	self:SetFrameStrata("TOOLTIP");
	self:SetParent(nil);
	self:SetAllPoints(GetAppropriateTopLevelParent());
	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
end

function SmartNavigationDebug:OnShow()
	self:EnableUpdate();
end

function SmartNavigationDebug:OnHide()
	self:DisableUpdate();
end

function SmartNavigationDebug:EnableUpdate()
	self.isUpdateEnabled = true;

	if not self.isHooked then
		self.isHooked = true;

		-- Hooking SmartNavigation's OnUpdate rather than using our own for two reasons:
		--	1. SmartNav's OnUpdate is only active while SmartNav is active
		--	2. We want ours to run after SmartNav's
		SmartNavigation:HookScript("OnUpdate", GenerateClosure(self.OnUpdate, self));

		-- Run one more update on hide to clear the overlay
		SmartNavigation:HookScript("OnHide", GenerateClosure(self.OnUpdate, self));
	end
end

function SmartNavigationDebug:DisableUpdate()
	self.isUpdateEnabled = false;
end

function SmartNavigationDebug:OnUpdate()
	local prevFrames = self.frames;

	self.frames = {};

	if self.isUpdateEnabled then
		local nav = SmartNavigation;
		local panelInfo = nav.activeInfo;
		local focusGroup = panelInfo and SmartNavigation:GetActiveGroup(panelInfo);

		Utility.ForEachScrollFrameInGroup(focusGroup, function(scrollFrame)
			self:AddOverlay(scrollFrame, prevFrames, SCROLL_FRAME_COLOR);
		end);

		Utility.ForEachButtonInGroup(focusGroup, function(button)
			if self:IsButtonValid(button, panelInfo) then
				self:AddOverlay(button, prevFrames, BUTTON_COLOR);
			end
		end);
	end

	for _, overlay in pairs(prevFrames) do
		self.overlayPool:Release(overlay);
	end
end

function SmartNavigationDebug:AddOverlay(frame, prevFrames, color)
	if self.frames[frame] then
		-- This is just protection against bugs, as if this _does_ happen we would have an
		-- infinitely growing overlay frame pool.
		local name = frame:GetDebugName();
		error("The frame '"..name.."' appears twice in SmartNav data, which shouldn't happen");
	end

	local overlay = prevFrames[frame];

	if overlay then
		prevFrames[frame] = nil;
	else
		overlay = self.overlayPool:Acquire();
		overlay:SetAllPoints(frame);
		overlay:SetColor(color);
		overlay:Show();
	end

	self.frames[frame] = overlay;
end

function SmartNavigationDebug:IsButtonValid(button, panelInfo)
	if SmartNavigation_IsFrameIgnored(button) then
		return false;
	end

	if panelInfo.canNavigateTo and not panelInfo.canNavigateTo(button) then
		return false;
	end

	return button:IsVisible() and button:IsRectValid();
end

SmartNavigationDebug:Init();
