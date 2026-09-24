
function PlayerFrame_OnLoad(self)
	PlayerFrame_OnLoadBase(self);

	local levelBackgroundCircle	= self.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle;
	PlayerLevelText:ClearAllPoints();
	PlayerLevelText:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, -0.5);

	levelBackgroundCircle:Show();

	PlayerPVPTimerText:ClearAllPoints();
	PlayerPVPTimerText:SetPoint("RIGHT", self.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle, "LEFT", 2, 0);
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
		pvpBackground = playerFrameTargetMain.PvpBackgroundCircle,
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

