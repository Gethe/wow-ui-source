TUTORIALFRAME_QUEUE = { };

function TutorialFrame_OnHide(self)
	PlaySound("igMainMenuClose");
	if ( not TutorialFrameCheckButton:GetChecked() ) then
		ClearTutorials();
		return;
	end
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TUTORIALFRAME_QUEUE[1] );
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
--	TutorialFrame:SetHeight(TutorialFrameText:GetHeight() + 62);

	-- Remove the tutorial from the queue
	for index, value in pairs(TUTORIALFRAME_QUEUE) do
		if ( value == currentTutorial ) then
			tremove(TUTORIALFRAME_QUEUE, index);
		end
	end
end

function TutorialFrame_NewTutorial(tutorialID)
	if ( not TutorialFrame:IsShown() ) then
		TutorialFrame:Show();
		TutorialFrame_Update(tutorialID);
		return;
	else
		tinsert(TUTORIALFRAME_QUEUE, tutorialID);
	end

	local button = TutorialFrameAlertButton;
	if ( not button:IsShown() ) then
		button.id = tutorialID;
		button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
		button:Show();
	end
end

function TutorialFrame_AlertButton_OnClick(id)
	TutorialFrame:Show();
	TutorialFrame_Update(id);
	if ( getn(TUTORIALFRAME_QUEUE) <= 0 ) then
		TutorialFrameAlertButton:Hide();
	end
end