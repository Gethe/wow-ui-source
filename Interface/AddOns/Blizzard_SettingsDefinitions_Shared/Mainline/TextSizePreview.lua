AccessibilityFontPreviewMixin = CreateFromMixins(AccessibilitySettingsPreviewMixin);

function AccessibilityFontPreviewMixin:UpdatePreview(value)
	self.TitleText:SetFontHeight(TextSizeManager:GetResizedFontHeight("UserScaledFontHeader", value));
	self.BodyText:SetFontHeight(TextSizeManager:GetResizedFontHeight("UserScaledFontBody", value));

	self:Layout();
end