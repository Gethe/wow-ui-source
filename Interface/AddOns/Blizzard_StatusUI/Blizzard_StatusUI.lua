
StatusUIMixin = {};

function StatusUIMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self.Pulse, "gmglow");
	for index, region in enumerate_regions(self.Pulse) do
		region:SetBlendMode("ADD");
	end
	self.Pulse.Anim:Play();

	self:SetWidth(math.max(self.TitleText:GetWidth(), self.SubtitleText:GetWidth()) + 50);
	self:SetHeight(self.TitleText:GetHeight() + self.SubtitleText:GetHeight() + 20);

	local bgR, bgG, bgB = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB();
	self.NineSlice:SetCenterColor(bgR, bgG, bgB, 1);
end

function StatusUIMixin:OnShow()
	UIParent_UpdateTopFramePositions();
end

function StatusUIMixin:OnHide()
	UIParent_UpdateTopFramePositions();
end
