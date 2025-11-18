GlueGameLogoMixin = { };

function GlueGameLogoMixin:OnLoad()
	self:RegisterEvent("GAME_MODE_DISPLAY_INFO_UPDATED");
	self.gameLogoDefaultHeight = self:GetHeight();
	self.gameModeRecordID = C_GameRules.GetCurrentGameModeRecordID();
end

function GlueGameLogoMixin:OnShow()
	self:UpdateLogoTexture();
end

function GlueGameLogoMixin:OnEvent(event)
	if (event == "GAME_MODE_DISPLAY_INFO_UPDATED") then
		-- Use the current game mode logo whenever the game mode display info is updated.
		-- This can be overwritten via `GlueGameLogoMixin:SetGameMode` if desaired.
		self.gameModeRecordID = C_GameRules.GetCurrentGameModeRecordID();

		self:UpdateLogoTexture();
	end
end

function GlueGameLogoMixin:SetExpansion(expansionLevel)
	self.expansionLevel = expansionLevel;
	self:UpdateLogoTexture();
end

function GlueGameLogoMixin:SetReleaseType(releaseType)
	self.releaseType = releaseType;
	self:UpdateLogoTexture();
end

function GlueGameLogoMixin:SetGameMode(gameModeRecordID)
	self.gameModeRecordID = gameModeRecordID;
	self:UpdateLogoTexture();
end

function GlueGameLogoMixin:SetGameLogoDefaultHeight(gameLogoDefaultHeight)
	self.gameLogoDefaultHeight = gameLogoDefaultHeight;
	self:UpdateLogoTexture();
end

function GlueGameLogoMixin:UpdateLogoTexture()
	local expansionLevel = self.expansionLevel or GetClientDisplayExpansionLevel();
	local releaseType = self.releaseType or LE_RELEASE_TYPE_CLASSIC;

	if(GetCNLogoReleaseType) then
		releaseType = GetCNLogoReleaseType();
	end

	local logo = nil;
	local logoHeight = 0;
	local logoVerticalOffset = 0;

	if self.gameModeRecordID ~= nil then
		local gameModeDisplayInfo = C_GameRules.GetGameModeDisplayInfoByRecordID(self.gameModeRecordID);
		if gameModeDisplayInfo then
			logo = gameModeDisplayInfo.logo;
			if self.useShrunkenLogoHeight and gameModeDisplayInfo.logoShrunkenHeight > 0 then
				logoHeight = gameModeDisplayInfo.logoShrunkenHeight;
			else
				logoHeight = gameModeDisplayInfo.logoHeight;
			end
			logoVerticalOffset = gameModeDisplayInfo.logoVerticalOffset;
		end
	end

	local expansionLogo = self:GetDisplayedExpansionLogo(expansionLevel, releaseType);
	logo = logo or expansionLogo;

	if logo then
		self.LogoTexture:SetTexture(logo);
		self:Show();
	else
		self:Hide();
	end

	if logoHeight == 0 then
		logoHeight = self.gameLogoDefaultHeight;
	end

	self.LogoTexture:SetSize(logoHeight * 2, logoHeight);
	self.LogoTexture:SetPoint("TOP", 0, logoVerticalOffset);
end

function GlueGameLogoMixin:GetDisplayedExpansionLogo(expansionLevel, desiredReleaseType)
	local expansionInfo = GetExpansionDisplayInfo(expansionLevel, desiredReleaseType);

	if expansionInfo then
		return expansionInfo.logo;
	end

	return nil;
end