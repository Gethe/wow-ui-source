local function LocalizePlayerHitIndicator(offsX, offsY)
	-- Adjust hit/damage anchor point, which is normally centered, to fit "Dodge" and other words in various languages
	PlayerHitIndicator:ClearAllPoints();
	PlayerHitIndicator:SetPoint("LEFT", "PlayerFrame", "TOPLEFT", offsX or 62, offsY or -42);
end

local l10nTable = {
	deDE = {
		localizeFrames = function()
			LocalizePlayerHitIndicator(52, -42);
		end,
	},
	esES = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
	esMX = {
		localizeFrames = LocalizePlayerHitIndicator,
	},
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
		localize = function()
			PlayerLevelText:SetPoint("CENTER", PlayerFrame, "BOTTOMLEFT", 35.5, 31);
			TargetFrame.levelText:SetPoint("CENTER", TargetFrame, "BOTTOMRIGHT", -35.25, 31);
			FocusFrame.levelText:SetPoint("CENTER", FocusFrame, "BOTTOMRIGHT", -35.25, 31);
		end,
	},

	zhTW = {
		localize = function()
			PlayerLevelText:SetPoint("CENTER", PlayerFrame, "BOTTOMLEFT", 35.5, 31);
			TargetFrame.levelText:SetPoint("CENTER", TargetFrame, "BOTTOMRIGHT", -35.25, 31);
			FocusFrame.levelText:SetPoint("CENTER", FocusFrame, "BOTTOMRIGHT", -35.25, 31);
		end,
	},
};

SetupLocalization(l10nTable);
