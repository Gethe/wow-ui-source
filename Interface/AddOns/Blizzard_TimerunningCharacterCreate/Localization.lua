local l10nTable = {
	zhCN = {
		localize = function()
			TimerunningFirstTimeDialog:UpdateState();
			TimerunningChoiceDialogCreateStandard:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning.Glow.RotatingGlow:Hide();
		end,
	},
	zhTW = {
		localize = function()
			TimerunningFirstTimeDialog:UpdateState();
			TimerunningChoiceDialogCreateStandard:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning:SetHeight(220);
			TimerunningChoiceDialogCreateTimerunning.Glow.RotatingGlow:Hide();
		end,
	},
};

SetupLocalization(l10nTable);
