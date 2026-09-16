local AddonName = ...;

function WowSurvey_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function WowSurveyStatusFrame_OnSurveyDelivered(event)
	if WowSurvey_LoadUI() then
		WowSurveyStatusFrame:OnEvent(event);
	end
end

function AddWowSurveyStatusFrameToStatusFrames(statusFrames)
	if C_AddOns.IsAddOnLoaded(AddonName) and WowSurveyStatusFrame:IsShown() then
		table.insert(statusFrames, WowSurveyStatusFrame);
	end
end
