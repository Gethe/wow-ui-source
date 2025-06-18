-- More hacks...will flag the global strings when i know which branch this will land in
if C_Glue.IsOnGlueScreen() then
	ENABLE_QUEST_TEXT_CONTRAST = "Quest Text Contrast";
	OPTION_TOOLTIP_ENABLE_QUEST_TEXT_CONTRAST = "Makes quest text easier to read";

	QUEST_BG_DEFAULT	= "Default";
	QUEST_BG_LIGHT1 	= "Brown";
	QUEST_BG_LIGHT2 	= "White";
	QUEST_BG_LIGHT3 	= "Black";
	QUEST_BG_DARK 		= "Grey";

	QUEST_TEXT_PREVIEW_BODY = "This preview showcases what your quest description will look like in the quest offer pane when you opt for the alternative background color.";
	QUEST_TEXT_PREVIEW_TITLE = "Example";
end

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