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

local function ShouldCloseSocialUIInsteadOfRequesting(tabType, alreadyShowingWhatWasRequested)
	if not SocialUIFrame:IsShown() then
		return false;
	end

	if alreadyShowingWhatWasRequested then
		return true;
	end

	-- You should always be able to toggle the window closed, even when we couldn't get you to the tab you asked for
	local requestedTabIsAvailable = SocialUIFrame:GetDataForAvailableTab(tabType) ~= nil;
	return not requestedTabIsAvailable;
end

function SocialUIControl.ToggleToTab(tabType)
	local tabAlreadySelected = SocialUIFrame:GetSelectedTab() == tabType;
	if ShouldCloseSocialUIInsteadOfRequesting(tabType, tabAlreadySelected) then
		SocialUIControl.Toggle();
	else
		SocialUIFrame:TriggerEvent(SocialUIFrameMixin.Event.OpenToTabRequested, tabType);
	end
end

function SocialUIControl.OpenToTab(tabType)
	SocialUIFrame:TriggerEvent(SocialUIFrameMixin.Event.OpenToTabRequested, tabType);
end

function SocialUIControl.ToggleToTabAndSideWindow(tabType, sideWindowType)
	local tabAlreadySelected = SocialUIFrame:GetSelectedTab() == tabType;
	local sideWindowTypeAlreadyActive = SocialUIFrame:GetActiveSideWindowType() == sideWindowType;

	local requestedTabAndWindowAlreadyActive = tabAlreadySelected and sideWindowTypeAlreadyActive;
	if ShouldCloseSocialUIInsteadOfRequesting(tabType, requestedTabAndWindowAlreadyActive) then
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
