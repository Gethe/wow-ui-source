local l10nTable = {
	zhCN = {
		localize = function()
			TimerunningFirstTimeDialog.InfoPanel.Logo:SetAtlas("timerunning-infographic-logo-cn");
			TimerunningChoiceDialogCreateStandard:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning.Glow.RotatingGlow:Hide();
		end,
	},
	zhTW = {
		localize = function()
			TimerunningFirstTimeDialog.InfoPanel.Logo:SetAtlas("timerunning-infographic-logo-tw");
			TimerunningChoiceDialogCreateStandard:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning.Glow.RotatingGlow:Hide();
		end,
	},
};

SetupLocalization(l10nTable);