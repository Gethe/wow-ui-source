
function DynamicResizeButton_Resize(self)
	local currentWidth = self:GetWidth();
	local textWidth = self:GetTextWidth() + self.padding;
	local newWidth = math.max(currentWidth, textWidth);
	if self.maxWidth then
		newWidth = math.min(newWidth, self.maxWidth);
	end

	self:SetWidth(newWidth);
end
