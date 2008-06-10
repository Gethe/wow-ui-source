MAX_RADIO_BUTTONS = 5;
MAX_SURVEY_QUESTIONS = 10;
GMSURVEY_NA_SPACING = 70;
GMSURVEY_RATING_SPACING = 60;

UIPanelWindows["GMSurveyFrame"] = { area = "center", pushable = 0, whileDead = 1 };

function GMSurveyFrame_Update()
	GMSurveyFrame.numQuestions = 0;
	local surveyQuestion;
	local questionFrame;
	for i=1, MAX_SURVEY_QUESTIONS do
		surveyQuestion = GMSurveyQuestion(i);
		questionFrame = getglobal("GMSurveyQuestion"..i);
		if ( surveyQuestion ) then
			GMSurveyFrame.numQuestions = GMSurveyFrame.numQuestions + 1;
			getglobal("GMSurveyQuestion"..i.."Text"):SetText(surveyQuestion);
			questionFrame:Show();
		else
			questionFrame:Hide();
		end
		questionFrame:SetHeight(getglobal("GMSurveyQuestion"..i.."Text"):GetHeight() + 55);
	end

	if ( GMSurveyFrame.numQuestions == 0 ) then
		-- Had no questions
		return;
	end
	GMSurveyAdditionalCommentsText:SetPoint("TOPLEFT", "GMSurveyQuestion"..GMSurveyFrame.numQuestions, "BOTTOMLEFT", 10, -10);
	GMSurveyScrollFrame:UpdateScrollChildRect();

	-- see if has a scrollbar and resize accordingly
	local scrollBarOffset = 26;
	if ( GMSurveyScrollFrame:GetVerticalScrollRange() ~= 0 ) then
		scrollBarOffset = 0;
	end
	GMSurveyScrollFrame:SetPoint("TOPRIGHT", GMSurveyFrame, "TOPRIGHT", -105+scrollBarOffset, -55);
	GMSurveyScrollFrame:SetWidth(541+scrollBarOffset);
	GMSurveyCommentFrame:SetWidth(543+scrollBarOffset);
	GMSurveyCommentScrollFrame:SetWidth(505+scrollBarOffset);
	GMSurveyFrameComment:SetWidth(505+scrollBarOffset);
	for i=1, GMSurveyFrame.numQuestions do
		questionFrame = getglobal("GMSurveyQuestion"..i);
		questionFrame:SetWidth(543+scrollBarOffset);
	end
end

function GMSurveyRadioButton_OnClick(owner, id)
	if ( not owner ) then
		owner = this:GetParent();
	end
	if ( not id ) then
		id = this:GetID();
	end
	if ( id == owner.selectedRadioButton ) then
		return;
	else
		owner.selectedRadioButton = id;
	end
	local radioButton;
	for i=0, MAX_RADIO_BUTTONS do
		radioButton = getglobal(owner:GetName().."RadioButton"..i);
		if ( i == owner.selectedRadioButton ) then
			radioButton:SetChecked(1);
			radioButton:Disable();
		else
			radioButton:SetChecked(0);
			radioButton:Enable();
		end
	end
end

function GMSurveySubmitButton_OnClick()
	for i=1, GMSurveyFrame.numQuestions do
		GMSurveyAnswerSubmit(i, getglobal("GMSurveyQuestion"..i).selectedRadioButton, "");
	end
	GMSurveyCommentSubmit(GMSurveyFrameComment:GetText());
	GMSurveySubmit();
	TicketStatusFrame.hasGMSurvey = nil;
	HideUIPanel(GMSurveyFrame);
	UIErrorsFrame:AddMessage(GMSURVEY_SUBMITTED, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0);
end

-- Only needs to be used if the survey frame is too narrow in foreign languages
function GMSurveyFrameSetWidth(width)
	GMSurveyFrame:SetWidth(width);
	GMSurveyScrollChildFrame:SetWidth(width-100);
	GMSurveyAdditionalCommentsText:SetWidth(width-100);
	GMSurveyFrameComment:SetWidth(width-150);
end