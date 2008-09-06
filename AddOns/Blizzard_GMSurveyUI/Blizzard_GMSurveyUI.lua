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
		questionFrame = _G["GMSurveyQuestion"..i];
		if ( surveyQuestion ) then
			GMSurveyFrame.numQuestions = GMSurveyFrame.numQuestions + 1;
			_G["GMSurveyQuestion"..i.."Text"]:SetText(surveyQuestion);
			questionFrame:Show();
		else
			questionFrame:Hide();
		end
		questionFrame:SetHeight(_G["GMSurveyQuestion"..i.."Text"]:GetHeight() + 55);
	end

	if ( GMSurveyFrame.numQuestions == 0 ) then
		-- Had no questions
		return;
	end
	GMSurveyAdditionalCommentsText:SetPoint("TOPLEFT", "GMSurveyQuestion"..GMSurveyFrame.numQuestions, "BOTTOMLEFT", 10, -10);
end

function GMSurveyScrollFrame_OnLoad(self)
	ScrollFrame_OnLoad(self);
	self.scrollBarHideable = 1;

	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", GMSurveyScrollFrame_OnEvent);
end

function GMSurveyScrollFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_GMSurveyUI") ) then
			return;
		end

		-- expand and contract scroll frame contents depending on scroll bar visibility
		local scrollBar = _G[self:GetName().."ScrollBar"];
		scrollBar.Show = 
			function (self)
				local scrollFrame = self:GetParent();
				local scrollFrameParent = scrollFrame:GetParent();
				local scrollBarOffset = scrollFrame.scrollBarWidth;
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrameParent, "BOTTOMRIGHT", -55 - scrollBarOffset, 48);
				scrollFrame:GetScrollChild():SetWidth(scrollFrame:GetWidth());

				getmetatable(self).__index.Show(self);
			end
		scrollBar.Hide = 
			function (self)
				local scrollFrame = self:GetParent();
				local scrollFrameParent = scrollFrame:GetParent();
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrameParent, "BOTTOMRIGHT", -55, 48);
				scrollFrame:GetScrollChild():SetWidth(scrollFrame:GetWidth());

				getmetatable(self).__index.Hide(self);
			end

		self.scrollBarWidth = 25;	-- looks better than actual scroll bar width

		-- force an update
		ScrollFrame_OnScrollRangeChanged(self);

		-- we don't need this event any more
		self:UnregisterEvent(event)		
	end
end

function GMSurveyQuestion_OnLoad(self)
	self:SetBackdropBorderColor(0.5,0.5,0.5);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	local name = self:GetName();
	self.radioButtons = {
		[0] = _G[name.."RadioButton0"],
		_G[name.."RadioButton1"],
		_G[name.."RadioButton2"],
		_G[name.."RadioButton3"],
		_G[name.."RadioButton4"],
		_G[name.."RadioButton5"],
	};
	local radioButtons = self.radioButtons;
	radioButtons[1]:SetPoint("LEFT", radioButtons[0], "RIGHT", GMSURVEY_NA_SPACING, 0);
	radioButtons[2]:SetPoint("LEFT", radioButtons[1], "RIGHT", GMSURVEY_RATING_SPACING, 0);
	radioButtons[3]:SetPoint("LEFT", radioButtons[2], "RIGHT", GMSURVEY_RATING_SPACING, 0);
	radioButtons[4]:SetPoint("LEFT", radioButtons[3], "RIGHT", GMSURVEY_RATING_SPACING, 0);
	radioButtons[5]:SetPoint("LEFT", radioButtons[4], "RIGHT", GMSURVEY_RATING_SPACING, 0);
end

function GMSurveyQuestion_OnShow(self)
	GMSurveyRadioButton_OnClick(self.radioButtons[0]);
end

function GMSurveyRadioButton_OnClick(self)
	local owner = self:GetParent();
	local id = self:GetID();
	if ( id == owner.selectedRadioButton ) then
		return;
	else
		owner.selectedRadioButton = id;
	end
	local radioButtons = owner.radioButtons;
	for i=0, #radioButtons do
		radioButton = radioButtons[i];
		if ( i == owner.selectedRadioButton ) then
			radioButton:SetChecked(1);
			radioButton:Disable();
		else
			radioButton:SetChecked(0);
			radioButton:Enable();
		end
	end
end

function GMSurveyCommentScrollFrame_OnLoad(self)
	self.scrollBarHideable = 1;

	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", GMSurveyCommentScrollFrame_OnEvent);
end

function GMSurveyCommentScrollFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_GMSurveyUI") ) then
			return;
		end

		-- expand and contract scroll frame contents depending on scroll bar visibility
		local scrollBar = _G[self:GetName().."ScrollBar"];
		scrollBar.Show = 
			function (self)
				local scrollFrame = self:GetParent();
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrame:GetParent(), "BOTTOMRIGHT", -10 - self:GetWidth(), 5);
				local scrollFrameWidth = scrollFrame:GetWidth();
				scrollFrame:GetScrollChild():SetWidth(scrollFrameWidth);
				-- adjust content width
				GMSurveyFrameComment:SetWidth(scrollFrameWidth);
				getmetatable(self).__index.Show(self);
			end
		scrollBar.Hide = 
			function (self)
				local scrollFrame = self:GetParent();
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrame:GetParent(), "BOTTOMRIGHT", -10, 5);
				local scrollFrameWidth = scrollFrame:GetWidth();
				scrollFrame:GetScrollChild():SetWidth(scrollFrameWidth);
				-- adjust content width
				GMSurveyFrameComment:SetWidth(scrollFrameWidth);
				getmetatable(self).__index.Hide(self);
			end

		-- force an update
		ScrollFrame_OnScrollRangeChanged(self);

		-- we don't need this event any more
		self:UnregisterEvent(event)		
	end
end

function GMSurveySubmitButton_OnClick()
	for i=1, GMSurveyFrame.numQuestions do
		GMSurveyAnswerSubmit(i, _G["GMSurveyQuestion"..i].selectedRadioButton, "");
	end
	GMSurveyCommentSubmit(GMSurveyFrameComment:GetText());
	GMSurveySubmit();
	TicketStatusFrame.hasGMSurvey = nil;
	HideUIPanel(GMSurveyFrame);
	UIErrorsFrame:AddMessage(GMSURVEY_SUBMITTED, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0);
end
