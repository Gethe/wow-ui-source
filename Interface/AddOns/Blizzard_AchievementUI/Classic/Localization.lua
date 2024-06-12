-- This file is executed at the end of addon load

function AchievementFrameSummary_LocalizeButton (button)

end

function AchievementButton_LocalizeMiniAchievement (frame)

end

function AchievementButton_LocalizeProgressBar (frame)

end

function AchievementButton_LocalizeMetaAchievement (frame)

end

function AchievementFrame_LocalizeCriteria (frame)

end

function AchievementCategoryButton_Localize(button)

end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {},
	zhTW = {
		localize = function()
			AchievementFrameSummary_LocalizeButton = function(button)
				button.label:SetPoint("TOP", 0, -4);
				button.description:SetPoint("TOP", 0, -27);
				button.description:SetFontObject("AchievementFont_Small");
				button.shield.points:SetPoint("CENTER", -1, 4);
			end

			AchievementButton_LocalizeMiniAchievement = function(frame)
				frame.points:SetFontObject("GameFontWhite");
			end

			AchievementButton_LocalizeProgressBar = function(frame)
				frame.text:SetPoint("TOP", 0, 1);
			end

			AchievementButton_LocalizeMetaAchievement = function(frame)
				frame.label:SetFontObject("AchievementFont_Small");
			end

			AchievementFrame_LocalizeCriteria = function(frame)
				frame.name:SetFontObject("AchievementFont_Small");
			end

			AchievementButton_Localize = function(button)
				button.description:SetFontObject("AchievementFont_Small");
				button.hiddenDescription:SetFontObject("AchievementFont_Small");
				button.shield:SetPoint("TOPRIGHT", -10, 0);
			end

			ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontBlack;
			ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontBlack;

			AchievementComparisonButton_Localize = function(button)
				button.player.label:SetPoint("TOP", 0, -4);
				button.player.description:SetPoint("TOP", 0, -27);
				button.player.description:SetFontObject("AchievementFont_Small");
				button.friend.status:SetFontObject("GameFontBlack");
				button.friend.status:SetPoint("BOTTOM", 20, 4);
				button.friend.shield.points:SetFontObject("GameFontBlack");
			end

			for _, button in next, AchievementFrameAchievementsContainer.buttons do
				AchievementButton_Localize(button);
			end

			for _, button in next, AchievementFrameComparisonContainer.buttons do
				AchievementComparisonButton_Localize(button);
			end
		end,
	},
};

SetupLocalization(l10nTable);