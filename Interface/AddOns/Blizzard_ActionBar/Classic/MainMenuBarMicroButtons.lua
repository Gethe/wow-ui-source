-- Leaving in some of the original alert pane priorities (but commented out) so we don't have to go find them again.
-- These came from SVN revision 401288.
-- If we add those alerts, uncomment them below.
MAIN_MENU_MICRO_ALERT_PRIORITY = {
	--"CollectionsMicroButtonAlert",
	"TalentMicroButtonAlert",
	--"EJMicroButtonAlert",
};

function MainMenuMicroButton_ShowAlert(alert, text, tutorialIndex)
	if not g_microButtonAlertsEnabled then
		return false;
	end

	if tutorialIndex and GetCVarBitfield("closedInfoFrames", tutorialIndex) then
		return false;
	end

	local isHighestPriority = false;
	for i, priorityFrameName in ipairs(MAIN_MENU_MICRO_ALERT_PRIORITY) do
		local priorityFrame = _G[priorityFrameName];
		if alert == priorityFrame then
			isHighestPriority = true;
		end

		if priorityFrame:IsShown() then
			if not isHighestPriority then
				-- Higher priority is shown
				return false;
			end

			-- Lower priority alert is visible, kill it
			priorityFrame:Hide();
		end
	end
	alert.Text:SetText(text);
	alert:SetHeight(alert.Text:GetHeight()+42);
	alert.tutorialIndex = tutorialIndex;
	alert:Show();

	g_visibleMicroButtonAlerts[alert] = true;

	return alert:IsShown();
end

function MainMenuMicroButton_HideAlert(microButton)
	-- no-op for Classic
end
