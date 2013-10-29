local NUM_ITEMS_PER_ROW = 4;

function ProductChoiceFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PRODUCT_CHOICE_UPDATE");
	self:RegisterEvent("PRODUCT_ASSIGN_TO_TARGET_FAILED");
	ButtonFrameTemplate_HidePortrait(self);

	self.TitleText:SetText(RECRUIT_A_FRIEND_REWARDS);
	
	ProductChoiceFrame_ShowAlerts(self);
end

function ProductChoiceFrame_OnEvent(self, event, ...)
	if ( event == "PRODUCT_CHOICE_UPDATE" ) then
		ProductChoiceFrame_ShowAlerts(self);
	elseif ( event == "PLAYER_LOGIN" ) then
		ProductChoiceFrame_ShowAlerts(self);
	elseif ( event == "PRODUCT_ASSIGN_TO_TARGET_FAILED" ) then
		StaticPopup_Show("PRODUCT_ASSIGN_TO_TARGET_FAILED");
	end
end

function ProductChoiceFrame_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	if ( self.secondAlertFrame ) then
		self.secondAlertFrame:Hide();
	end
end

function ProductChoiceFrame_OnFriendsListShown()
	if ( ProductChoiceFrame.mainAlertFrame ) then
		ProductChoiceFrame.mainAlertFrame:Hide();
	end
end

function ProductChoiceFrame_ShowAlerts(self, forceShowMain, forceShowSecond)
	if ( #C_ProductChoice.GetChoices() > 0 ) then
		--Create the frames if they don't already exist.
		--If we created them, we haven't displayed them yet and so should show them.
		if ( not self.mainAlertFrame ) then
			forceShowMain = true;
			self.mainAlertFrame = CreateFrame("FRAME", nil, FriendsMicroButton, "RecruitInfoDialogTemplate");
		end
		if ( not self.secondAlertFrame ) then
			forceShowSecond = true;
			self.secondAlertFrame = CreateFrame("FRAME", nil, FriendsTabHeaderRecruitAFriendButton, "RecruitInfoDialogTemplate");
		end

		--Show the alerts we want to show
		if ( forceShowMain ) then
			self.mainAlertFrame:SetPoint("LEFT", FriendsMicroButton, "RIGHT", 15, 0);
			RecruitAFriend_ShowInfoDialog(self.mainAlertFrame, RAF_PRODUCT_CHOICE_EARNED, true);
		end
		if ( forceShowSecond ) then
			self.secondAlertFrame:SetPoint("LEFT", FriendsTabHeaderRecruitAFriendButton, "RIGHT", 15, 0);
			RecruitAFriend_ShowInfoDialog(self.secondAlertFrame, RAF_PRODUCT_CHOICE_CLAIM, false);
		end
	end
end

function ProductChoiceFrame_Update(self)
	local selectedID = self.selectedData and self.selectedData.id;
	for i = 1, #self.Inset.Buttons do
		local button = self.Inset.Buttons[i];
		button:SetChecked(button.data.id == selectedID);

		local enableHighlight = (not button.data.disabled) and (button.data.id ~= selectedID) and (not self.rotatingID);
		button:GetHighlightTexture():SetAlpha(enableHighlight and 1 or 0);
	end

	self.Inset.ClaimButton:SetEnabled(selectedID ~= nil);
end

function ProductChoiceFrameItem_SetUpDisplay(self, data)
	self.Name:SetText(data.name);
	if ( data.subtitle ) then
		self.SubTitle:SetFormattedText(PRODUCT_CHOICE_SUBTEXT, data.subtitle);
		self.SubTitle:Show();
	else
		self.SubTitle:Hide();
	end
	self.Covers.CheckMark:SetShown(data.alreadyHas);
	self.Covers.Disabled:SetShown(data.disabled);
	if ( data.modelDisplayID ) then
		self.Model:SetDisplayInfo(data.modelDisplayID);
		Model_Reset(self.Model);
		self.Model:Show();
		self.Shadow:Show();
		self.Icon:Hide();
		self.IconBorder:Hide();
	else
		self.Shadow:Hide();
		self.Model:Hide();
		self.Shadow:Hide();
		SetPortraitToTexture(self.Icon, data.textureName);
		self.Icon:Show();
		self.IconBorder:Show();
	end
end

function ProductChoiceFrame_SetUp(self)
	self.selectedData = nil;
	self.Inset.NoTakeBacksies:Hide();

	local choices = C_ProductChoice.GetChoices();
	if ( #choices == 0 ) then
		return;
	end

	self.choiceID = choices[1];

	local products = C_ProductChoice.GetProducts(self.choiceID);
	for i=1, #products do
		local data = products[i];
		local button = self.Inset.Buttons[i];
		if ( not button ) then
			button = CreateFrame("CheckButton", nil, self.Inset, "ProductChoiceItemTemplate");
			self.Inset.Buttons[i] = button;
			if ( (i % NUM_ITEMS_PER_ROW) == 1 ) then
				button:SetPoint("TOPLEFT", self.Inset.Buttons[i - NUM_ITEMS_PER_ROW], "BOTTOMLEFT", 0, -10);
			else
				button:SetPoint("TOPLEFT", self.Inset.Buttons[i - 1], "TOPRIGHT", 10, 0);
			end
		end
		button.data = data;
		button.Model.PreviewButton:Show();

		ProductChoiceFrameItem_SetUpDisplay(button, data);
	end
	--Hide unused buttons
	for i=#products + 1, #self.Inset.Buttons do
		self.Inset.Buttons[i]:Hide();
	end
	ProductChoiceFrame_Update(self);
end

function ProductChoiceFrame_StartRotating(self, id)
	self.rotatingID = id;
	ProductChoiceFrame_Update(self);
end

function ProductChoiceFrame_StopRotating(self)
	self.rotatingID = nil;
	ProductChoiceFrame_Update(self);
end

function ProductChoiceItem_OnClick(self, button)
	if ( self.data.modelDisplayID and IsModifiedClick("DRESSUP") ) then
		ModelPreviewFrame_ShowModel(self.data.modelDisplayID);
	else
		if ( not self.data.disabled ) then
			PlaySound("igMainMenuOptionCheckBoxOn");
			ProductChoiceFrame.selectedData = self.data;
		end
	end
	ProductChoiceFrame_Update(ProductChoiceFrame);
end

function ProductChoiceFrame_ClaimItem()
	local frame = ProductChoiceFrame.Inset.NoTakeBacksies;

	local hasMore = #C_ProductChoice.GetChoices() > 1;
	if ( C_ProductChoice.MakeSelection(frame.choiceID, frame.data.id) ) then
		if ( hasMore ) then
			ProductChoiceFrame_ShowAlerts(ProductChoiceFrame, false, true);
		end
	else
		StaticPopup_Show("PRODUCT_ASSIGN_TO_TARGET_FAILED");
	end
	ProductChoiceFrame.data = nil;
	ProductChoiceFrame:Hide();
end

function ProductChoiceFrameInsetClaimButton_OnClick(self, button)
	local frame = ProductChoiceFrame;
	PlaySound("igCharacterInfoOpen");
	ProductChoiceFrame_ShowConfirmation(frame.Inset.NoTakeBacksies, frame.choiceID, frame.selectedData);
end

function ProductChoiceFrame_ShowConfirmation(confirmationFrame, choiceID, data)
	confirmationFrame.choiceID = choiceID;
	confirmationFrame.data = data;
	ProductChoiceFrameItem_SetUpDisplay(confirmationFrame.Dialog.ItemPreview, data);
	confirmationFrame:Show();
end
