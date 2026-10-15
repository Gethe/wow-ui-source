ColoredProgressBarMixin = {};

ColoredProgressBarMixin.ColorType =
{
	Red = 1,
	Green = 2,
	Blue = 3,
	White = 4,
};

function ColoredProgressBarMixin:OnLoad()
	self:SetFillPercent(0);
end

function ColoredProgressBarMixin:SetText(text)
	self.Text:SetText(text);
end

function ColoredProgressBarMixin:SetFillWidth(width)
	self.Fill:SetWidth(width);
end

function ColoredProgressBarMixin:SetFillPercent(percent)
	local p = math.min(1, math.max(0, percent));
	self:SetFillWidth(p * self:GetWidth());

	self.Fill:SetTexCoord(0, p, 1, 0);
end

function ColoredProgressBarMixin:SetFillTextureByColorType(colorType)
	if colorType == ColoredProgressBarMixin.ColorType.Red then
		self.Fill:SetAtlas("common-stat-bar-red", TextureKitConstants.UseAtlasSize);
	elseif colorType == ColoredProgressBarMixin.ColorType.Green then
		self.Fill:SetAtlas("common-stat-bar-green", TextureKitConstants.UseAtlasSize);
	elseif colorType == ColoredProgressBarMixin.ColorType.Blue then
		self.Fill:SetAtlas("common-stat-bar-blue", TextureKitConstants.UseAtlasSize);
	elseif colorType == ColoredProgressBarMixin.ColorType.White then
		self.Fill:SetAtlas("common-stat-bar-white", TextureKitConstants.UseAtlasSize);
	end
end
