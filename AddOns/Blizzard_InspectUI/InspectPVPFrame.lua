
function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
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
	InspectPVPFrame.RatedBG.Record:SetText(won.."-"..(played-won));
end
