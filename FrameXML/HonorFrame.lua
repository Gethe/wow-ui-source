function HonorFrame_OnLoad()
	this:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
end

function HonorFrame_OnEvent()
	if ( event == "PLAYER_PVP_KILLS_CHANGED" or event == "PLAYER_PVP_RANK_CHANGED") then
		HonorFrame_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		HonorFrame_Update(1);
	end
end

function HonorFrame_Update(updateAll)
	local hk, dk, contribution, rank, highestRank, rankName, rankNumber;
	
	-- This only gets set on player entering the world
	if ( updateAll ) then
		-- Yesterday's values
		hk, dk, contribution = GetPVPYesterdayStats();
		HonorFrameYesterdayHKValue:SetText(hk);
		HonorFrameYesterdayDKValue:SetText(dk);
		HonorFrameYesterdayContributionValue:SetText(contribution);
		-- Last Week's values
		hk, dk, contribution, rank = GetPVPLastWeekStats();
		HonorFrameLastWeekHKValue:SetText(hk);
		HonorFrameLastWeekDKValue:SetText(dk);
		HonorFrameLastWeekContributionValue:SetText(contribution);
		HonorFrameLastWeekStandingValue:SetText(rank);
	end
	
	-- This session's values
	hk, dk = GetPVPSessionStats();
	HonorFrameCurrentHKValue:SetText(hk);
	HonorFrameCurrentDKValue:SetText(dk);
	
	-- Lifetime stats
	hk, dk, highestRank = GetPVPLifetimeStats();
	HonorFrameLifeTimeHKValue:SetText(hk);
	HonorFrameLifeTimeDKValue:SetText(dk);
	rankName, rankNumber = GetPVPRankInfo(highestRank);
	if ( not rankName ) then
		rankName = NONE;
	end
	HonorFrameLifeTimeRankValue:SetText(rankName);

	-- Set rank name and number
	rankName, rankNumber = GetPVPRankInfo(UnitPVPRank("player"));
	if ( not rankName ) then
		rankName = NONE;
	end
	HonorFrameCurrentPVPTitle:SetText(rankName);
	HonorFrameCurrentPVPRank:SetText("("..RANK.." "..rankNumber..")");
	
	-- Set icon
	if ( rankNumber > 0 ) then
		HonorFramePvPIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank",rankNumber));
		HonorFramePvPIcon:Show();
	else
		HonorFramePvPIcon:Hide();
	end
	
	-- Recenter rank text
	HonorFrameCurrentPVPTitle:SetPoint("TOP", "HonorFrame", "TOP", - HonorFrameCurrentPVPRank:GetWidth()/2, -81);
end