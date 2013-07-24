local arenaFrames;

function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
	arenaFrames = {InspectPVPFrame.Arena2v2, InspectPVPFrame.Arena3v3, InspectPVPFrame.Arena5v5};
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	InspectPVPFrame_Update();
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_Update()
	local rating, played, won = GetInspectRatedBGData();
	InspectPVPFrame.RatedBG.Rating:SetText(rating);
	InspectPVPFrame.RatedBG.Wins:SetText(won);
	for i=1, MAX_ARENA_TEAMS do
		local arenarating, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetInspectArenaData(i);
		local frame = arenaFrames[i];
		frame.Rating:SetText(arenarating);
		frame.Wins:SetText(seasonWon);
	end
end
