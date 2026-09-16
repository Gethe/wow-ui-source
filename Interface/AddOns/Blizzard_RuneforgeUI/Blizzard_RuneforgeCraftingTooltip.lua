
RunforgeFrameTooltipMixin = CreateFromMixins(RuneforgeSystemMixin);

function RunforgeFrameTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self);
	SharedTooltip_SetBackdropStyle(self, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);

	local pulseStyle = CopyTable(GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
	pulseStyle.padding = nil;
	SharedTooltip_SetBackdropStyle(self.PulseOverlay, pulseStyle);

	local regions = {self.PulseOverlay.TopOverlay, self.PulseOverlay.NineSlice:GetRegions()};
	for i, region in ipairs(regions) do
		region:SetBlendMode("ADD");
	end
end

function RunforgeFrameTooltipMixin:OnShow()
	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnEnter, self.OnItemSlotOnEnter, self);
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnLeave, self.OnItemSlotOnLeave, self);
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemSlotOnEnter, self.OnUpgradeItemSlotOnEnter, self);
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemSlotOnLeave, self.OnUpgradeItemSlotOnLeave, self);
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self.Refresh, self);
end

function RunforgeFrameTooltipMixin:OnHide()
	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnEnter, self);
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnLeave, self);
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemSlotOnEnter, self);
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemSlotOnLeave, self);
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self);

	self:StopPulse();
end

function RunforgeFrameTooltipMixin:Init()
	-- These need to be registered after RuneforgeFrame's OnLoad. They are not unregistered,
	-- as they control showing/hiding of the tooltip.
	self:RegisterRefreshMethod(self.Refresh);
end

function RunforgeFrameTooltipMixin:Refresh()
	self:GetRuneforgeFrame():RefreshResultTooltip();
end

function RunforgeFrameTooltipMixin:OnItemSlotOnEnter()
	local runeforgeFrame = self:GetRuneforgeFrame();
	if self:IsRuneforgeUpgrading() and runeforgeFrame:HasUpgradeItem() then
		runeforgeFrame:ShowComparisonTooltip();
	else
		self.PulseOverlay:Show();
	end
end

function RunforgeFrameTooltipMixin:OnItemSlotOnLeave()
	self.PulseOverlay:Hide();
	GameTooltip_Hide();
	self:GetRuneforgeFrame():RefreshResultTooltip();
end

function RunforgeFrameTooltipMixin:OnUpgradeItemSlotOnEnter()
	if self:GetRuneforgeFrame():HasUpgradeItem() then
		self.PulseOverlay:Show();
	end
end

function RunforgeFrameTooltipMixin:OnUpgradeItemSlotOnLeave()
	self.PulseOverlay:Hide();
end

function RunforgeFrameTooltipMixin:StartPulse()
	self.PulseOverlay:Show();
end

function RunforgeFrameTooltipMixin:StopPulse()
	self.PulseOverlay:Hide();
end

function RunforgeFrameTooltipMixin:GetRuneforgeFrame()
	return self:GetParent();
end
