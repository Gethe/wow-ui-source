QuestTextPreviewMixin = CreateFromMixins(AccessibilitySettingsPreviewMixin);

function QuestTextPreviewMixin:UpdatePreview(value)
	self.Background:SetAtlas(QuestTextContrast.GetBackgroundAtlas(value));

	local textColor, titleTextColor = GetMaterialTextColors("Parchment");
	if QuestTextContrast.UseLightText(value) then
		textColor, titleTextColor = GetMaterialTextColors("Stone");
	end
	self.TitleText:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
	self.BodyText:SetTextColor(textColor[1], textColor[2], textColor[3]);
end
