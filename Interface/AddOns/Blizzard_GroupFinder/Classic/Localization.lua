local l10nTable = {
	ruRU = {
		localize = function()
			LFGRewardsFrame_AdjustFont = function(self)
				self.title:SetFontObject(QuestTitleFontBlackShadowSmaller);
			end
		end,
	},
};

SetupLocalization(l10nTable);