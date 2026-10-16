function PlayerFrame_OnLoad(self)
	PlayerFrame_OnLoadBase(self);

	local playerFrameContentMain = self.PlayerFrameContent.PlayerFrameContentMain;

	-- Prevent Mainline standard localization overrides from changing the level text position.
	playerFrameContentMain.skipLevelTextLocalizationAdjustment = true;

	PlayerName:SetJustifyH("CENTER");
	PlayerName:SetWidth(116);

	local levelBackgroundCircle	= playerFrameContentMain.LevelBackgroundCircle;
	PlayerLevelText:ClearAllPoints();
	PlayerLevelText:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, -0.5);
	levelBackgroundCircle:Show();

	PlayerPVPTimerText:ClearAllPoints();
	PlayerPVPTimerText:SetPoint("RIGHT", playerFrameContentMain.PvpBackgroundIcon, "LEFT", 2, 0);
end

function PlayerFrame_GetLevelRGBA()
	return 1.0, 1.0, 1.0, 1.0;
end

function PlayerFrame_CanPlayPVPUpdateSound()
	local playerFrameTargetMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;

	return not playerFrameTargetMain.PvpBackgroundIcon:IsShown();
end

function PlayerFrame_ShowRoleIconInsideInstances()
	return false;
end

function PlayerFrame_GetPvPIndicatorElements()
	local playerFrameTargetMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;
	return {
		pvpIcon = playerFrameTargetMain.PvpBackgroundIcon,
	};
end

-- Camelot's timer text is anchored once in OnLoad, so only the visibility rule is needed here.
function PlayerFrame_UpdatePvPTimerText(displayInfo, elements)
	if (displayInfo.isFreeForAll or not displayInfo.showPvPIcon) then
		PlayerPVPTimerText:Hide();
		PlayerPVPTimerText.timeLeft = nil;
	end
end

function PlayerFrame_UpdatePlayerNameTextAnchor()
	PlayerName:ClearAllPoints();
	local playerFrameTargetMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;
	PlayerName:SetPoint("CENTER", playerFrameTargetMain, "TOPLEFT", 149, -37);
end

function PlayerFrame_UpdateFlashTextureVisuals()
	local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	local alternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	if alternatePowerBar then
		frameFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-InCombat", TextureKitConstants.UseAtlasSize);
		frameFlash:SetPoint("CENTER", frameFlash:GetParent(), "CENTER", 0, 0);
	else
		frameFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize);
		frameFlash:SetPoint("CENTER", frameFlash:GetParent(), "CENTER", 0, 0);
	end
end

function PlayerFrame_UpdateStatusTextureVisuals()
	local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;
	local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
	statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize);
	statusTexture:SetPoint("TOPLEFT", frameFlash:GetParent(), "TOPLEFT", 17, -14);
end

function PlayerFrame_UpdateHealthBarVisuals()
	local healthBarContainer = PlayerFrame_GetHealthBarContainer();
	local healthBar = PlayerFrame_GetHealthBar();

	healthBarContainer:SetWidth(124);
	healthBarContainer:SetHeight(15);
	healthBarContainer:SetPoint("TOPLEFT", 87, -46);
	healthBar:SetHeight(20);
	healthBar:ClearAllPoints();
	healthBar:SetPoint("TOPLEFT", healthBarContainer, "TOPLEFT", 0, 3);

	healthBarContainer.HealthBarMask:SetHeight(32);
	healthBarContainer.HealthBarMask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 6);
	healthBarContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask");
end

function PlayerFrame_UpdateManaBarVisuals()
	local manaBar = PlayerFrame_GetManaBar();

	manaBar:SetHeight(10);
	manaBar:SetWidth(124);
	manaBar:SetPoint("TOPLEFT", 87, -61);

	manaBar.ManaBarMask:SetWidth(128);
	local alternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	local maskTexture = alternatePowerBar and "Unit_BarMask" or "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask";
	manaBar.ManaBarMask:SetAtlas(maskTexture, TextureKitConstants.UseAtlasSize);
end