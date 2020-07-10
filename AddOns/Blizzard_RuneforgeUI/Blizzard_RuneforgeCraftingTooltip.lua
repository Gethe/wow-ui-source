
RunforgeFrameTooltipMixin = CreateFromMixins(RuneforgeSystemMixin);

function RunforgeFrameTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self);
	SharedTooltip_SetBackdropStyle(self, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);

	local pulseStyle = CopyTable(GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
	pulseStyle.bgFile = nil;
	self.PulseOverlay:SetBackdrop(pulseStyle);
	self.PulseOverlay.TopOverlay:SetAtlas(pulseStyle.overlayAtlasTop, true);
	self.PulseOverlay.TopOverlay:SetScale(pulseStyle.overlayAtlasTopScale);
	self.PulseOverlay.TopOverlay:SetPoint("CENTER", self.PulseOverlay, "TOP", 0, pulseStyle.overlayAtlasTopYOffset);

	local regions = {self.PulseOverlay:GetRegions()};
	for i, region in ipairs(regions) do
		region:SetBlendMode("ADD");
	end
end

function RunforgeFrameTooltipMixin:OnShow()
	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnEnter, self.StartPulse, self);
	runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnLeave, self.StopPulse, self);
end

function RunforgeFrameTooltipMixin:OnHide()
	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnEnter, self);
	runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event.ItemSlotOnLeave, self);

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

function RunforgeFrameTooltipMixin:StartPulse()
	self.PulseOverlay:Show();
end

function RunforgeFrameTooltipMixin:StopPulse()
	self.PulseOverlay:Hide();
end

function RunforgeFrameTooltipMixin:GetRuneforgeFrame()
	return self:GetParent();
end
