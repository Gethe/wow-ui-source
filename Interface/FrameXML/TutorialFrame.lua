MAX_TUTORIAL_ALERTS = 10;
TUTORIALFRAME_QUEUE = { };
LAST_TUTORIAL_BUTTON_SHOWN = nil;

function TutorialFrame_OnEvent(self, event, ...)
	if ( event == "TUTORIAL_TRIGGER" ) then
		local tutorialID, forceShow = ...;
		TutorialFrame_NewTutorial(tutorialID);
	elseif ( event == "CINEMATIC_STOP" ) then
		TutorialFrame_CheckIntro();
	end
end

function TutorialFrame_OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	if ( not TutorialFrameCheckButton:GetChecked() ) then
		ClearTutorials();
		-- Hide all tutorial buttons
		TutorialFrame_HideAllAlerts();
		SetCVar("showTutorials", "0");
		return;
	end
	-- If closing the intro frame, then reanchor the help tutorial window
	if ( TutorialFrame.id == 42 ) then
		TutorialFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 100);
	end
end

function TutorialFrame_Update(currentTutorial)
	FlagTutorial(currentTutorial);
	TutorialFrame.id = currentTutorial;
	local title = _G["TUTORIAL_TITLE"..currentTutorial];
	local text = _G["TUTORIAL"..currentTutorial];
	if ( title and text) then
		TutorialFrameTitle:SetText(title);
		TutorialFrameText:SetText(text);
	end
	TutorialFrame:SetHeight(TutorialFrameText:GetHeight() + 62);

	-- Remove the tutorial from the queue and reanchor the remaining buttons
	local index = 1;
	while TUTORIALFRAME_QUEUE[index] do
		if ( currentTutorial == TUTORIALFRAME_QUEUE[index][1] ) then
			tremove(TUTORIALFRAME_QUEUE, index);
		end
		index = index + 1;
	end
	-- Go through the queue and reanchor the buttons
	local button;
	LAST_TUTORIAL_BUTTON_SHOWN = nil;
	for index, value in ipairs(TUTORIALFRAME_QUEUE) do
		button = _G[value[2]];
		if ( LAST_TUTORIAL_BUTTON_SHOWN and LAST_TUTORIAL_BUTTON_SHOWN ~= button ) then
			button:SetPoint("BOTTOM", LAST_TUTORIAL_BUTTON_SHOWN, "BOTTOM", 36, 0);
		else
			button:SetPoint("BOTTOM", "TutorialFrameParent", "BOTTOM", 0, 0);
		end
		LAST_TUTORIAL_BUTTON_SHOWN = button;
	end
end

function TutorialFrame_NewTutorial(tutorialID)
	if Kiosk.IsEnabled() then
		return;
	end
	-- Get tutorial button
	local button = TutorialFrame_GetAlertButton();
	-- Not enough tutorial buttons, not sure how to handle this right now
	if ( not button ) then
		return;
	end
	tinsert(TUTORIALFRAME_QUEUE, {tutorialID, button:GetName()});

	if ( LAST_TUTORIAL_BUTTON_SHOWN and LAST_TUTORIAL_BUTTON_SHOWN ~= button ) then
		button:SetPoint("BOTTOM", LAST_TUTORIAL_BUTTON_SHOWN, "BOTTOM", 36, 0);
	else
		-- No button shown so this is the first one
		button:SetPoint("BOTTOM", "TutorialFrameParent", "BOTTOM", 0, 0);
	end
	button.id = tutorialID;
	button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
	LAST_TUTORIAL_BUTTON_SHOWN = button;
	button:Show();
	--UIFrameFlash(button, 0.75, 0.75, 10, 1);
	SetButtonPulse(button, 10, 0.5);

	-- Reset checkbox to a checked state, in case the player previously unchecked it.
	TutorialFrameCheckButton:SetChecked(true)
end

function TutorialFrame_GetAlertButton()
	local button;
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		if ( not button.id) then
			button:ClearAllPoints();
			return button;
		end
		if ( i == MAX_TUTORIAL_ALERTS ) then
			-- No available tutorial buttons
			return nil;
		end
	end
end

function TutorialFrame_HideAllAlerts()
	local button;
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		button.id = nil;
		button.tooltip = nil;
		button:ClearAllPoints();
		ButtonPulse_StopPulse(button);
		button:Hide();
	end
	LAST_TUTORIAL_BUTTON_SHOWN = nil;
	TUTORIALFRAME_QUEUE = { };
end

function TutorialFrame_CheckIntro()
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		if ( button.id == 42 ) then
			button:Click();
			TutorialFrame:SetPoint("BOTTOM", "UIParent", "CENTER", 0, -90);
			return;
		end
	end
end
