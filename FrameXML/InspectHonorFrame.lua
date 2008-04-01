function InspectHonorFrame_OnLoad()
	this:RegisterEvent("INSPECT_HONOR_UPDATE");
end

function InspectHonorFrame_OnEvent()
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectHonorFrame_Update();
	end
end

function InspectHonorFrame_OnShow()
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		InspectHonorFrame_Update();
	end
end

function InspectHonorFrame_Update()
	local lifetimeRank, sessionHK, sessionDK, yesterdayHK, yesterdayDK, lastweekHK, lastweekDK, lifetimeHK, lifetimeDK, yesterdayContribution, lastweekContribution, lastweekRank = GetInspectHonorData();
	
	-- Yesterday's values
	InspectHonorFrameYesterdayHKValue:SetText(yesterdayHK);
	InspectHonorFrameYesterdayDKValue:SetText(yesterdayDK);
	InspectHonorFrameYesterdayContributionValue:SetText(yesterdayContribution);
	
	-- Last Week's values
	InspectHonorFrameLastWeekHKValue:SetText(lastweekHK);
	InspectHonorFrameLastWeekDKValue:SetText(lastweekDK);
	InspectHonorFrameLastWeekContributionValue:SetText(lastweekContribution);
	InspectHonorFrameLastWeekStandingValue:SetText(lastweekRank);

	-- This session's values
	InspectHonorFrameCurrentHKValue:SetText(sessionHK);
	InspectHonorFrameCurrentDKValue:SetText(sessionDK);
	
	-- Lifetime stats
	InspectHonorFrameLifeTimeHKValue:SetText(lifetimeHK);
	InspectHonorFrameLifeTimeDKValue:SetText(lifetimeDK);
	local rankName, rankNumber = GetPVPRankInfo(lifetimeRank);
	if ( not rankName ) then
		rankName = NONE;
	end
	InspectHonorFrameLifeTimeRankValue:SetText(rankName);

	-- Set rank name and number
	rankName, rankNumber = GetPVPRankInfo(UnitPVPRank("target"));
	if ( not rankName ) then
		rankName = NONE;
	end

	InspectHonorFrameCurrentPVPRank:SetText("("..RANK.." "..rankNumber..")");
	InspectHonorFrameCurrentPVPRank:Show();
	InspectHonorFrameCurrentPVPTitle:SetText(rankName);
	InspectHonorFrameCurrentPVPTitle:Show();

	-- Recenter rank text
	InspectHonorFrameCurrentPVPTitle:SetPoint("TOP", "InspectHonorFrame", "TOP", - InspectHonorFrameCurrentPVPRank:GetWidth()/2, -81);

	-- Set icon
	if ( rankNumber > 0 ) then
		InspectHonorFramePvPIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank",rankNumber));
		InspectHonorFramePvPIcon:Show();
	else
		InspectHonorFramePvPIcon:Hide();
	end
end