local AddonName = ...;

function BehavioralMessaging_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function BehavioralMessagingTray_OnNotification(event, ...)
	if BehavioralMessaging_LoadUI() then
		BehavioralMessagingTray:OnEvent(event, ...);
	end
end

function AddBehavioralMessagingTrayToStatusFrames(statusFrames)
	if C_AddOns.IsAddOnLoaded(AddonName) and BehavioralMessagingTray:IsShown() then
		table.insert(statusFrames, BehavioralMessagingTray);
	end
end
