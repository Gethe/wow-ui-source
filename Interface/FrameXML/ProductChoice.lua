local NUM_ITEMS_PER_ROW = 5;
local NUM_ITEMS_PER_PAGE = 10;

function ProductChoiceFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PRODUCT_CHOICE_UPDATE");
	self:RegisterEvent("PRODUCT_ASSIGN_TO_TARGET_FAILED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	ButtonFrameTemplate_HidePortrait(self);

	self.TitleText:SetText(RECRUIT_A_FRIEND_REWARDS);
	self.selectedPageNum = 1;

	ProductChoiceFrame_ShowAlerts(self);
end

function ProductChoiceFrame_OnEvent(self, event, ...)
	if ( event == "PRODUCT_CHOICE_UPDATE" ) then
		ProductChoiceFrame_ShowAlerts(self);
	elseif ( event == "PLAYER_LOGIN" ) then
		ProductChoiceFrame_ShowAlerts(self);
	elseif ( event == "PRODUCT_ASSIGN_TO_TARGET_FAILED" ) then
		StaticPopup_Show("PRODUCT_ASSIGN_TO_TARGET_FAILED");
	elseif ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if ( ProductChoiceFrame.Inset.NoTakeBacksies.Dialog.ItemPreview:IsVisible() ) then
			ProductChoiceFrame_RefreshConfirmationModel(ProductChoiceFrame.Inset.NoTakeBacksies, true);
		end
		
		if ( ProductChoiceFrame:IsVisible() ) then
			ProductChoiceFrame_SetUp(ProductChoiceFrame, true);
		end
	end
end

function ProductChoiceFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	if ( self.secondAlertFrame ) then
		self.secondAlertFrame:Hide();
	end
end

function ProductChoiceFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( self.Inset.PrevPageButton:IsShown() and self.Inset.PrevPageButton:IsEnabled() ) then
			ProductChoiceFrame_PageClick(self.Inset.PrevPageButton, false);
		end
	else
		if ( self.Inset.NextPageButton:IsShown() and self.Inset.NextPageButton:IsEnabled() ) then
			ProductChoiceFrame_PageClick(self.Inset.NextPageButton, true);
		end	
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
			self.mainAlertFrame = CreateFrame("FRAME", nil, QuickJoinToastButton, "RecruitInfoDialogTemplate");
		end
		if ( not self.secondAlertFrame ) then
			forceShowSecond = true;
			self.secondAlertFrame = CreateFrame("FRAME", nil, FriendsTabHeaderRecruitAFriendButton, "RecruitInfoDialogTemplate");
		end

		--Show the alerts we want to show
		if ( forceShowMain ) then
			self.mainAlertFrame:SetPoint("LEFT", QuickJoinToastButton, "RIGHT", 15, 0);
			RecruitAFriend_ShowInfoDialog(self.mainAlertFrame, RAF_PRODUCT_CHOICE_EARNED, true);
		end
		if ( forceShowSecond ) then
			self.secondAlertFrame:SetPoint("LEFT", FriendsTabHeaderRecruitAFriendButton, "RIGHT", 25, 0);
			RecruitAFriend_ShowInfoDialog(self.secondAlertFrame, RAF_PRODUCT_CHOICE_CLAIM, false);
		end
	end
end

function ProductChoiceFrame_Update(self)
	local selectedID = self.selectedData and self.selectedData.id;
	for i = 1, #self.Inset.Buttons do
		local button = self.Inset.Buttons[i];
		if ( button.data ) then
			button:SetChecked(button.data.id == selectedID);

			local enableHighlight = (not button.data.disabled) and (button.data.id ~= selectedID) and (not self.rotatingID);
			button:GetHighlightTexture():SetAlpha(enableHighlight and 1 or 0);
		end
	end

	self.Inset.ClaimButton:SetEnabled(selectedID ~= nil);
end

function ProductChoiceFrameItem_SetUpDisplay(self, data, forceUpdate)
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
		self.ModelScene:SetFromModelSceneID(data.modelSceneID, forceUpdate);

		local item = self.ModelScene:GetActorByTag("item");
		if ( item ) then
			item:SetModelByCreatureDisplayID(data.modelDisplayID);
			item:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
		end
		
		self.ModelScene:Show();
		self.Shadow:Show();
		self.Icon:Hide();
		self.IconBorder:Hide();
	else
		self.Shadow:Hide();
		self.ModelScene:Hide();
		self.Shadow:Hide();
		SetPortraitToTexture(self.Icon, data.textureName);
		self.Icon:Show();
		self.IconBorder:Show();
	end
end

function ProductChoiceFrame_SetUp(self, forceUpdate)
	self.selectedData = nil;

	local choices = C_ProductChoice.GetChoices();
	if ( #choices == 0 ) then
		return;
	end

	self.choiceID = choices[1];

	local pageNum = self.selectedPageNum;

	local products = C_ProductChoice.GetProducts(self.choiceID);

	for i=1, NUM_ITEMS_PER_PAGE do
		local data = products[i + NUM_ITEMS_PER_PAGE * (pageNum - 1)];
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
		if ( not data ) then
			button:Hide();
		else
			button.data = data;
			button.ModelScene.PreviewButton:Show();

			ProductChoiceFrameItem_SetUpDisplay(button, data, forceUpdate);
			button:Show();
		end
	end

	if ( #products > NUM_ITEMS_PER_PAGE ) then
		-- 10, 10/8 = 1, 2 remain 
		local numPages = math.ceil(#products / NUM_ITEMS_PER_PAGE);
		self.Inset.PageText:SetText(PRODUCT_CHOICE_PAGE_NUMBER:format(pageNum,numPages));
		self.Inset.PageText:Show();
		self.Inset.NextPageButton:Show();
		self.Inset.PrevPageButton:Show();
		self.Inset.PrevPageButton:SetEnabled(pageNum ~= 1);
		self.Inset.NextPageButton:SetEnabled(pageNum ~= numPages);
	else
		self.Inset.PageText:Hide();
		self.Inset.NextPageButton:Hide();
		self.Inset.PrevPageButton:Hide();
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
		ModelPreviewFrame_ShowModel(self.data.modelDisplayID, self.data.modelSceneID);
	else
		if ( not self.data.disabled ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	ProductChoiceFrame_ShowConfirmation(frame.Inset.NoTakeBacksies, frame.choiceID, frame.selectedData);
end

function ProductChoiceFrame_ShowConfirmation(confirmationFrame, choiceID, data)
	confirmationFrame.choiceID = choiceID;
	confirmationFrame.data = data;
	ProductChoiceFrameItem_SetUpDisplay(confirmationFrame.Dialog.ItemPreview, data);
	confirmationFrame:Show();
end

function ProductChoiceFrame_RefreshConfirmationModel(confirmationFrame, forceUpdate)
	ProductChoiceFrameItem_SetUpDisplay(confirmationFrame.Dialog.ItemPreview, confirmationFrame.data, forceUpdate);
end

function ProductChoiceFrame_PageClick(self, advance)
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	local frame = ProductChoiceFrame;
	frame.selectedData = nil;
	if (advance) then
		frame.selectedPageNum = frame.selectedPageNum + 1;
	else
		frame.selectedPageNum = frame.selectedPageNum - 1;
	end

	ProductChoiceFrame_SetUp(frame);
end

function ProductChoiceItemDisplay_OnMouseDown(self, ...)
	self.ModelScene:OnMouseDown(...);
end

function ProductChoiceItemDisplay_OnMouseUp(self, ...)
	self.ModelScene:OnMouseUp(...);
end