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
			PlayerFrame_UpdateLevelTextAnchor = function(level)
				if ( level >= 100 ) then
					PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -62, -15);
				else
					PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -61, -15);
				end
			end

			TargetFrame_UpdateLevelTextAnchor = function(self, targetLevel)
				if ( targetLevel >= 100 ) then
					self.levelText:SetPoint("CENTER", 61, -15);
				else
					self.levelText:SetPoint("CENTER", 62, -15);
				end
			end

			BossTargetFrame_UpdateLevelTextAnchor = function(self, targetLevel)
				self.levelText:SetPoint("CENTER", 11, -16);
			end
		end,
	},

	zhTW = {
		localize = function()
			PlayerFrame_UpdateLevelTextAnchor = function(level)
				PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -61, -15);
			end

			TargetFrame_UpdateLevelTextAnchor = function(self, targetLevel)
				if ( targetLevel >= 100 ) then
					self.levelText:SetPoint("CENTER", 61, -15);
				else
					self.levelText:SetPoint("CENTER", 62, -15);
				end
			end

			BossTargetFrame_UpdateLevelTextAnchor = function(self, targetLevel)
				self.levelText:SetPoint("CENTER", 11, -16);
			end
		end,
	},
};

SetupLocalization(l10nTable);