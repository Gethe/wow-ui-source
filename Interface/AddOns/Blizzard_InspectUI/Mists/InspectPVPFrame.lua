local arenaFrames;

InspectPVPFrameMixin = {};

function InspectPVPFrameMixin:OnLoad()
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
	arenaFrames = {InspectPVPFrame.Arena2v2, InspectPVPFrame.Arena3v3, InspectPVPFrame.Arena5v5};
end

function InspectPVPFrameMixin:OnEvent(event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		self:Update();
	end
end

function InspectPVPFrameMixin:OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	self:Update();
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		self:Update();
	end
end

function InspectPVPFrameMixin:Update()
	local ratedBGData = C_PaperDollInfo.GetInspectRatedBGData();
	InspectPVPFrame.RatedBG.Rating:SetText(ratedBGData.rating);
	InspectPVPFrame.RatedBG.Wins:SetText(ratedBGData.won);
	for i = 1, MAX_ARENA_TEAMS do
		local arenaRating, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetInspectArenaData(i);
		local frame = arenaFrames[i];
		frame.Rating:SetText(arenaRating);
		frame.Wins:SetText(seasonWon);
	end
end
