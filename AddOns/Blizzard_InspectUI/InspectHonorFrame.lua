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
	
	local sessionHK, sessionDK, yesterdayHK, yesterdayHonor, thisweekHK, thisweekHonor, lastweekHK, lastweekHonor, lastweekStanding, lifetimeHK, lifetimeDK, lifetimeRank = GetInspectHonorData();

	-- Yesterday's values
	InspectHonorFrameYesterdayHKValue:SetText(yesterdayHK);
	InspectHonorFrameYesterdayContributionValue:SetText(yesterdayHonor);

	-- This week's values
	InspectHonorFrameThisWeekHKValue:SetText(thisweekHK);
	InspectHonorFrameThisWeekContributionValue:SetText(thisweekHonor);
	
	-- Last Week's values
	InspectHonorFrameLastWeekHKValue:SetText(lastweekHK);
	InspectHonorFrameLastWeekContributionValue:SetText(lastweekHonor);
	InspectHonorFrameLastWeekStandingValue:SetText(lastweekStanding);

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

	-- Set icon
	if ( rankNumber > 0 ) then
		InspectHonorFramePvPIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank",rankNumber));
		InspectHonorFramePvPIcon:Show();
	else
		InspectHonorFramePvPIcon:Hide();
	end

	-- Set rank progress and bar color
	local factionGroup, factionName = UnitFactionGroup("target");
	if ( factionGroup == "Alliance" ) then
		InspectHonorFrameProgressBar:SetStatusBarColor(0.05, 0.15, 0.36);
	else
		InspectHonorFrameProgressBar:SetStatusBarColor(0.63, 0.09, 0.09);
	end
	InspectHonorFrameProgressBar:SetValue(GetInspectPVPRankProgress());

	-- Recenter rank text
	InspectHonorFrameCurrentPVPTitle:SetPoint("TOP", "InspectHonorFrame", "TOP", - InspectHonorFrameCurrentPVPRank:GetWidth()/2, -83);
end