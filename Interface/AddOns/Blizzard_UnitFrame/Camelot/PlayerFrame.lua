
function PlayerFrame_OnLoad(self)
	PlayerFrame_OnLoadBase(self);

	local levelBackgroundCircle	= self.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle;
	PlayerLevelText:ClearAllPoints();
	PlayerLevelText:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, -0.5);

	levelBackgroundCircle:Show();
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

function PlayerFrame_ShowPrestigeWithAtlas(atlas, factionGroup, honorRewardInfo)
	return PlayerFrame_ShowPvPIcon(factionGroup);
end


function PlayerFrame_ShowPvPIcon(factionGroup, ffaState)
	local playerFrameTargetMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;
	local pvpBG = playerFrameTargetMain.PvpBackgroundCircle;
	local pvpIcon = playerFrameTargetMain.PvpBackgroundIcon;

	pvpBG:SetScale(0.8);
	pvpIcon:SetScale(0.8);
	pvpBG:SetPoint("TOP", pvpBG:GetParent(), "TOPLEFT", 20, -50);
	pvpIcon:SetPoint("CENTER", pvpBG, "CENTER", 0, 0);
	PlayerPVPTimerText:ClearAllPoints();
	PlayerPVPTimerText:SetPoint("RIGHT", pvpBG, "LEFT", 2, 0);

	if (ffaState == "FFA") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-FFAIcon", TextureKitConstants.UseAtlasSize);
	elseif (factionGroup == "Horde") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-SmallCircle-Horde", TextureKitConstants.UseAtlasSize);
	elseif (factionGroup == "Alliance") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-SmallCircle-Alliance", TextureKitConstants.UseAtlasSize);
	end

	pvpBG:Show();
	pvpIcon:Show();
	return pvpIcon;
end

function PlayerFrame_HidePvPFrames()
	local playerFrameTargetMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain;
	local pvpBG = playerFrameTargetMain.PvpBackgroundCircle;
	local pvpIcon = playerFrameTargetMain.PvpBackgroundIcon;

	pvpBG:Hide();
	pvpIcon:Hide();
	PlayerPVPTimerText:Hide();
	PlayerPVPTimerText.timeLeft = nil;
end

-- Camelot renders its PvP badge into PlayerFrameContentMain, not the Mainline-only PlayerFrameContentContextual
-- regions that UnitFrameUtil.UpdateUnitPvPIndicator targets, so this reimplements the pre-UnitFrameUtil update logic.
function PlayerFrame_UpdatePvPStatus()
	local unitFramePvPContextualDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UnitFramePvPContextualDisabled);
	if unitFramePvPContextualDisabled then
		PlayerFrame_HidePvPFrames();
		return;
	end

	local factionGroup = UnitFactionGroup("player");

	if (UnitIsPVPFreeForAll("player")) then
		if (PlayerFrame_CanPlayPVPUpdateSound()) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end
		local honorLevel = UnitHonorLevel("player");
		local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
		if (honorRewardInfo) then
			PlayerFrame_ShowPrestigeWithAtlas("honorsystem-portrait-neutral", factionGroup, honorRewardInfo);
		else
			PlayerFrame_ShowPvPIcon(factionGroup, "FFA");
		end

		PlayerPVPTimerText:Hide();
		PlayerPVPTimerText.timeLeft = nil;
	elseif (factionGroup and factionGroup ~= "Neutral" and UnitIsPVP("player")) then
		if (PlayerFrame_CanPlayPVPUpdateSound()) then
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end

		-- ugly special case handling for mercenary mode
		if (UnitIsMercenary("player")) then
			if (factionGroup == "Horde") then
				factionGroup = "Alliance";
			elseif (factionGroup == "Alliance") then
				factionGroup = "Horde";
			end
		end

		local honorLevel = UnitHonorLevel("player");
		local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);

		if (honorRewardInfo) then
			PlayerFrame_ShowPrestigeWithAtlas("honorsystem-portrait-"..factionGroup, factionGroup, honorRewardInfo);
		else
			PlayerFrame_ShowPvPIcon(factionGroup);
		end
	else
		PlayerFrame_HidePvPFrames();
	end
end

