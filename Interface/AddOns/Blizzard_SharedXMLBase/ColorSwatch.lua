ColorSwatchMixin = {}

function ColorSwatchMixin:SetColor(color)
	self.Color:SetVertexColor(color:GetRGB());
end

function ColorSwatchMixin:SetColorRGB(r, g, b)
	self.Color:SetVertexColor(r, g, b);
end

function ColorSwatchMixin:SetBorderColor(color)
	self.SwatchBg:SetVertexColor(color:GetRGB());
end

function ColorSwatchMixin:OnEnter()
	self:SetBorderColor(NORMAL_FONT_COLOR);
end

function ColorSwatchMixin:OnLeave()
	self:SetBorderColor(HIGHLIGHT_FONT_COLOR);
end

function ColorSwatchMixin:OnShow()
	PixelUtil.SetSize(self.SwatchBg, 14, 14);
	PixelUtil.SetSize(self.InnerBorder, 12, 12);
	PixelUtil.SetSize(self.Color, 10, 10);
end
