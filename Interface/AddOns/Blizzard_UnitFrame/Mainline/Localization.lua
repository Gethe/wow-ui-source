local function LocalizePlayerHitIndicator()
	-- Adjust hit/damage anchor point
	local PlayerHitIndicator = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator;

	PlayerHitIndicator.HitText:ClearAllPoints();
	PlayerHitIndicator.HitText:SetPoint("LEFT", PlayerHitIndicator, "TOPLEFT", 24, -50);
end

local l10nTable = {
	deDE = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	enGB = {},
	enUS = {},
	esES = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	esMX = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	ptPT = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	ruRU = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	zhCN = {
		localizeFrames = function ()
			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "CENTER", 0, 1);
			PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrameHealthBarText:GetParent(), "LEFT", 0, 1);
			PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrameHealthBarText:GetParent(), "RIGHT", 0, 1);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "CENTER", 2, 1);
			PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrameManaBarText:GetParent(), "LEFT", 4, 1);
			PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrameManaBarText:GetParent(), "RIGHT", 0, 1);

			-- Player Frame
			PlayerLevelText:SetPoint("TOPRIGHT", -24.5, -26);

			local playerFrameHealthBar = PlayerFrame_GetHealthBar();
			playerFrameHealthBar.TextString:SetPoint("CENTER", 0, 1);
			playerFrameHealthBar.LeftText:SetPoint("LEFT", 2, 1);
			playerFrameHealthBar.RightText:SetPoint("RIGHT", -2, 1);

			local playerFrameManaBar = PlayerFrame_GetManaBar();
			playerFrameManaBar.ManaBarText:SetPoint("CENTER", 0, 1);
			playerFrameManaBar.LeftText:SetPoint("LEFT", 2, 1);
			playerFrameManaBar.RightText:SetPoint("RIGHT", -2, 1);

			-- Target Frame
			local targetFrameContentMain = TargetFrame.TargetFrameContent.TargetFrameContentMain;
			targetFrameContentMain.LevelText:SetPoint("TOPLEFT", targetFrameContentMain.ReputationColor, "TOPRIGHT", -133, 1);
			targetFrameContentMain.Name:SetPoint("TOPLEFT", targetFrameContentMain.ReputationColor, "TOPRIGHT", -106, 1);

			local targetFrameHealthBar = targetFrameContentMain.HealthBarsContainer;
			targetFrameHealthBar.HealthBarText:SetPoint("CENTER", 0, 2);
			targetFrameHealthBar.LeftText:SetPoint("LEFT", 2, 2);
			targetFrameHealthBar.RightText:SetPoint("RIGHT", -5, 2);
			targetFrameHealthBar.DeadText:SetPoint("CENTER", 0, 2);
			targetFrameHealthBar.UnconsciousText:SetPoint("CENTER", 0, 2);

			local targetFrameManaBar = targetFrameContentMain.ManaBar;
			targetFrameManaBar.ManaBarText:SetPoint("CENTER", -4, 1);
			targetFrameManaBar.LeftText:SetPoint("LEFT", 2, 1);
			targetFrameManaBar.RightText:SetPoint("RIGHT", -13, 1);
		end
	},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
			-- Player Frame
			PlayerLevelText:SetPoint("TOPRIGHT", -24.5, -26);

			-- Target Frame
			local targetFrameContentMain = TargetFrame.TargetFrameContent.TargetFrameContentMain;
			targetFrameContentMain.LevelText:SetPoint("TOPLEFT", targetFrameContentMain.ReputationColor, "TOPRIGHT", -133, 1);
			targetFrameContentMain.Name:SetPoint("TOPLEFT", targetFrameContentMain.ReputationColor, "TOPRIGHT", -106, 2);
			targetFrameContentMain.HealthBarsContainer.DeadText:SetPoint("CENTER", 0, 2);
			targetFrameContentMain.HealthBarsContainer.UnconsciousText:SetPoint("CENTER", 0, 2);
        end,
    },
};

SetupLocalization(l10nTable);