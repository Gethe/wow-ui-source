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

function AchievementButton_Localize(button)

end

function AchievementComparisonButton_Localize(button)

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
				button.DateCompleted:SetWidth(150);
				button.DateCompleted:SetPoint("TOPRIGHT", -63, -6);
				button.Label:SetPoint("TOP", 0, -4);
				button.Description:SetPoint("TOP", 0, -27);
				button.Description:SetFontObject("AchievementFont_Small");
				button.Shield.Points:SetPoint("CENTER", -1, 4);
			end

			AchievementButton_LocalizeMiniAchievement = function(frame)
				frame.Points:SetFontObject("GameFontWhite");
			end

			AchievementButton_LocalizeProgressBar = function(frame)
				frame.Text:SetPoint("TOP", 0, 1);
			end

			AchievementButton_LocalizeMetaAchievement = function(frame)
				frame.Label:SetFontObject("AchievementFont_Small");
			end

			AchievementFrame_LocalizeCriteria = function(frame)
				frame.Name:SetFontObject("AchievementFont_Small");
			end

			AchievementButton_Localize = function(button)
				button.DateCompleted:SetWidth(80);
				button.DateCompleted:SetJustifyH("CENTER");
				button.Description:SetFontObject("AchievementFont_Small");
				button.HiddenDescription:SetFontObject("AchievementFont_Small");
				button.Shield:SetPoint("TOPRIGHT", -10, 0);
				button.Tabard:SetPoint("TOPRIGHT", -7, -4);
			end

			ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontBlack;
			ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontBlack;

			AchievementComparisonButton_Localize = function(button)
				button.Player.Label:SetPoint("TOP", 0, -4);
				button.Player.Description:SetPoint("TOP", 0, -27);
				button.Player.Description:SetFontObject("AchievementFont_Small");
				button.Friend.Status:SetFontObject("GameFontBlack");
				button.Friend.Status:SetPoint("BOTTOM", 20, 4);
				button.Friend.Shield.Points:SetFontObject("GameFontBlack");
			end

			AchievementCategoryButton_Localize = function(button)
				button.Label:SetPoint("TOPRIGHT", -8, -6);
				button.Label:SetPoint("BOTTOMLEFT", 16, 2);
			end
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);