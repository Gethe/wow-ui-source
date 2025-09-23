GlueDialogButtonMixin = {};

function GlueDialogButtonMixin:OnTextScaleUpdated(scale, registrationInfo)
	self:SetHeight(registrationInfo.baseHeight * scale);

	local dialogInfo = self:GetOwningDialogInfo();
	if dialogInfo and dialogInfo.buttonTextMargin then
		self:SetWidth(self:GetTextWidth() + dialogInfo.buttonTextMargin);
	else
		local weightedScale = TextSizeManager:GetWeightedScale(scale, registrationInfo);
		self:SetWidth(registrationInfo.baseWidth * weightedScale);
	end
end