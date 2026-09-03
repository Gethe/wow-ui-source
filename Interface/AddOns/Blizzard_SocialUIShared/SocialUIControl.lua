function ToggleSocialUI()
	if SocialUIControl.IsEnabled() then
		SocialUIControl.Toggle();
	end
end

SocialUIControl = {};

function SocialUIControl.IsEnabled()
	return C_SocialUI.IsSystemEnabled() and SocialUIFrame ~= nil;
end

function SocialUIControl.Toggle()
	if C_Glue.IsOnGlueScreen() then
		SocialUIFrame:SetShown(not SocialUIFrame:IsShown());
	else
		ToggleUIPanel(SocialUIFrame);
	end
end

function SocialUIControl.ToggleToTab(tabType)
	local isAlreadyShowingRequestedTab = SocialUIFrame:IsShown() and SocialUIFrame:GetSelectedTab() == tabType;
	if isAlreadyShowingRequestedTab then
		SocialUIControl.Toggle();
	else
		SocialUIFrame:TriggerEvent(SocialUIFrameMixin.Event.OpenToTabRequested, tabType);
	end
end

function SocialUIControl.OpenToTab(tabType)
	SocialUIFrame:TriggerEvent(SocialUIFrameMixin.Event.OpenToTabRequested, tabType);
end

function SocialUIControl.ToggleToTabAndSideWindow(tabType, sideWindowType)
	local socialUIShown = SocialUIFrame:IsShown();
	local tabAlreadySelected = SocialUIFrame:GetSelectedTab() == tabType;
	local sideWindowTypeAlreadyActive = SocialUIFrame:GetActiveSideWindowType() == sideWindowType;

	local isAlreadyShowingRequestedTabAndWindow = socialUIShown and tabAlreadySelected and sideWindowTypeAlreadyActive;
	if isAlreadyShowingRequestedTabAndWindow then
		SocialUIControl.Toggle();
	else
		SocialUIFrame:TriggerEvent(SocialUIFrameMixin.Event.OpenToTabAndSideWindowRequested, tabType, sideWindowType);
	end
end

function SocialUIControl.Hide()
	local alreadyHidden = not SocialUIFrame:IsShown();
	if alreadyHidden then
		return;
	end

	if C_Glue.IsOnGlueScreen() then
		SocialUIFrame:Hide();
	else
		HideUIPanel(SocialUIFrame);
	end
end
