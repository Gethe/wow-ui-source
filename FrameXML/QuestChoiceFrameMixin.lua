CURRENCY_SPACING = 5;
CURRENCY_HEIGHT = 20;
MAX_CURRENCIES = 3;
REWARDS_WIDTH = 200;
INIT_REWARDS_HEIGHT = 18; --basically total vertical padding between rewards
INIT_OPTION_HEIGHT = 278;
INIT_WINDOW_HEIGHT = 480;
OPTION_STATIC_HEIGHT = 114; --height of artwork and minimum padding

GORGROND_GARRISON_ALLIANCE_CHOICE = 55;
GORGROND_GARRISON_HORDE_CHOICE = 56;

StaticPopupDialogs["CONFIRM_GORGROND_GARRISON_CHOICE"] = {
	text = CONFIRM_GORGROND_GARRISON_CHOICE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		SendQuestChoiceResponse(self.data.response);
		HideUIPanel(self.data.owner);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_PLAYER_CHOICE"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		SendQuestChoiceResponse(self.data.response);
		HideUIPanel(self.data.owner);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

QuestChoiceFrameMixin = {};

function QuestChoiceFrameMixin:OnLoad()
	self.defaultLeftPadding = self.leftPadding;
	self.defaultRightPadding = self.rightPadding;
	self.defaultSpacing = self.spacing;

	if self.optionTextColor then
		for _, option in ipairs(self.Options) do
			option.OptionText:SetTextColor(self.optionTextColor:GetRGBA());
		end
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("QUEST_CHOICE_CLOSE");
end

function QuestChoiceFrameMixin:OnEvent(event)
	if (event == "QUEST_CHOICE_UPDATE") then
		self:SetPendingUpdate();
	elseif (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" or event == "QUEST_CHOICE_CLOSE") then
		HideUIPanel(self);
	end
end

function QuestChoiceFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
end

function QuestChoiceFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	CloseQuestChoice();
	StaticPopup_Hide("CONFIRM_GORGROND_GARRISON_CHOICE");

	for i = 1, #self.Options do
		local option = self.Options[i];
		self:UpdateOptionWidgetRegistration(option, nil);
	end
end

function QuestChoiceFrameMixin:OnUpdate(elapsed)
	if self.hasPendingUpdate then
		self:Update();
	end
end

function QuestChoiceFrameMixin:SetPendingUpdate()
	self.hasPendingUpdate = true;
end

function QuestChoiceFrameMixin:TryShow()
	if (not self:IsShown()) then
		ShowUIPanel(self)
	end

	self:Update();
end

function QuestChoiceFrameMixin:WidgetLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	self:UpdateHeight();
end

function QuestChoiceFrameMixin:WidgetInit(widgetFrame)
	if self.optionTextColor and widgetFrame.GatherColorableFontStrings then
		local fontStrings = widgetFrame:GatherColorableFontStrings();
		for _, fontString in ipairs(fontStrings) do
			fontString:SetTextColor(self.optionTextColor:GetRGBA());
		end
	end
end

function QuestChoiceFrameMixin:UpdateOptionWidgetRegistration(option, widgetSetID)
	if option.widgetSetID and option.widgetSetID ~= widgetSetID then
		UIWidgetManager:UnregisterWidgetSetContainer(option.widgetSetID, option.WidgetContainer);
		option.WidgetContainer:Hide();
	end

	if widgetSetID then
		UIWidgetManager:RegisterWidgetSetContainer(widgetSetID, option.WidgetContainer, function(...) self:WidgetLayout(...) end, function(...) self:WidgetInit(...) end);
		option.WidgetContainer:Show();
	end

	option.widgetSetID = widgetSetID;
end

function QuestChoiceFrameMixin:UpdateHeight()
	--make window taller if there is too much stuff
	local initOptionHeight = self.initOptionHeight or INIT_OPTION_HEIGHT;
	local optionStaticHeight = self.optionStaticHeight or OPTION_STATIC_HEIGHT;
	local maxHeight = initOptionHeight;
	for i=1, self.numActiveOptionFrames do
		local option = self.Options[i];
		local currHeight = optionStaticHeight;

		currHeight = currHeight + option.OptionText:GetContentHeight() + option.OptionButtonsContainer:GetHeight();
		if (option.Rewards) then
			currHeight = currHeight + option.Rewards:GetHeight() + 25;
		end
		if option.WidgetContainer and option.WidgetContainer:IsShown() then
			currHeight = currHeight + option.WidgetContainer:GetHeight() + 5;
		end
		maxHeight = math.max(currHeight, maxHeight);
	end
	for i=1, self.numActiveOptionFrames do
		local option = self.Options[i];
		option:SetHeight(maxHeight);
	end
	local heightDiff = maxHeight - initOptionHeight;
	heightDiff = max(heightDiff, 0);
	local initWindowHeight = self.initWindowHeight or INIT_WINDOW_HEIGHT;
	self:SetHeight(initWindowHeight + heightDiff);
	if (self.OnHeightChanged) then
		self:OnHeightChanged(heightDiff);
	end
	
	for i = 1, #self.Options do
		self.Options[i]:SetShown(i <= self.numActiveOptionFrames);
	end
	if not self.fixedPaddingAndSpacing then
		if self.numActiveOptionFrames == 1 then
			self.leftPadding = (self.fixedWidth - self.Option1:GetWidth()) / 2;
			self.rightPadding = 0;
			self.spacing = 0;
		elseif self.numActiveOptionFrames == 4 then
			self.leftPadding = 50;
			self.rightPadding = 50;
			self.spacing = 20;
		else
			self.leftPadding = self.defaultLeftPadding;
			self.rightPadding = self.defaultRightPadding;
			self.spacing = self.defaultSpacing;
		end
	end

	self:Layout();
end

function QuestChoiceFrameMixin:GetExistingOptionForGroup(groupID)
	if groupID then
		for i, option in ipairs(self.Options) do
			if option.groupID == groupID then
				return option;
			end
		end
	end
	return nil;
end

function QuestChoiceFrameMixin:GetNumOptions()
	return self.numActiveOptionFrames;
end

function QuestChoiceFrameMixin:Update()
	self.hasPendingUpdate = false;

	local choiceID, questionText, numOptions = GetQuestChoiceInfo();
	if (not choiceID or choiceID == 0) then
		self:Hide();
		return;
	end
	for i, option in ipairs(self.Options) do
		option.groupID = nil;
	end
	self.choiceID = choiceID;
	self.QuestionText:SetText(questionText);

	self.numActiveOptionFrames = 0;
	for i=1, numOptions do
		local optID, buttonText, description, header, artFile, confirmationText, widgetSetID, disabled, groupID = GetQuestChoiceOptionInfo(i);

		local existingOption = self:GetExistingOptionForGroup(groupID);
		local button;
		if existingOption then
			-- only supporting two grouped options
			existingOption.hasMultipleButtons = true;
			button = existingOption.OptionButtonsContainer.OptionButton2;
			if not disabled then
				existingOption.hasActiveButton = true;
			end
		else
			self.numActiveOptionFrames = self.numActiveOptionFrames + 1;
			local option = self.Options[self.numActiveOptionFrames];
			option.hasMultipleButtons = false;
			option.hasActiveButton = not disabled;
			option.groupID = groupID;
			option.optID = optID;
			button = option.OptionButtonsContainer.OptionButton1;
			option.OptionText:SetText(description);
			option:ConfigureHeader(header);
			option.Artwork:SetTexture(artFile);

			self:UpdateOptionWidgetRegistration(option, widgetSetID);
		end
		button.confirmationText = confirmationText;
		button:SetText(buttonText);
		button.optID = optID;
		button:SetEnabled(not disabled);
	end

	-- buttons
	for i = 1, self.numActiveOptionFrames do
		local option = self.Options[i];
		option:ConfigureButtons();
	end

	if self.numActiveOptionFrames < #self.Options then
		for i = self.numActiveOptionFrames + 1, #self.Options do
			local option = self.Options[i];
			self:UpdateOptionWidgetRegistration(option, nil);
		end
	end

	self:ShowRewards()

	self:UpdateHeight();
end

function QuestChoiceFrameMixin:ShowRewards()
	for i=1, self.numActiveOptionFrames do
		local rewardFrame = self["Option"..i].Rewards;
		local height = INIT_REWARDS_HEIGHT;
		local title, skillID, skillPoints, money, xp, numItems, numCurrencies, numChoices, numReps = GetQuestChoiceRewardInfo(i);

		if (numItems ~= 0) then
			local itemID, name, texture, quantity, quality, itemLink = GetQuestChoiceRewardItem(i, 1); --for now there is only ever 1 item by design
			if itemID then
				rewardFrame.Item.itemID = itemID;
				rewardFrame.Item:Show();
				rewardFrame.Item.Name:SetText(name)
				SetItemButtonCount(rewardFrame.Item, quantity);
				SetItemButtonTexture(rewardFrame.Item, texture);
				SetItemButtonQuality(rewardFrame.Item, quality, itemID);
				rewardFrame.Item.itemLink = itemLink;
				height = height + rewardFrame.Item:GetHeight();
			else
				rewardFrame.Item:Hide();
			end
		else
			rewardFrame.Item:Hide();
		end

		if (numCurrencies ~= 0) then
			local width, currency;
			local totalWidth = 0;
			for j=1, numCurrencies do
				currency = rewardFrame.Currencies["Currency"..j];
				local currID, texture, quantity = GetQuestChoiceRewardCurrency(i, j); --there should only be one currency reward
				currency.currencyID = currID;
				currency.Icon:SetTexture(texture);
				currency.Quantity:SetText(quantity);
				--set width of currency frame to barely hold icon and string
				width = currency.Icon:GetWidth() + CURRENCY_SPACING + currency.Quantity:GetWidth();
				currency:SetSize(width, CURRENCY_HEIGHT);
				totalWidth = totalWidth + width;
			end
			--calculate amount of space between each currency, and adjust positions
			local space = (rewardFrame.Currencies:GetWidth() - totalWidth) / (numCurrencies + 1);
			currency = rewardFrame.Currencies.Currency1;
			currency:SetPoint("TOPLEFT", rewardFrame.Currencies, "TOPLEFT", space, 0)
			local prevFrame = currency;
			for j=2, numCurrencies do
				currency = rewardFrame.Currencies["Currency"..j];
				currency:SetPoint("LEFT", prevFrame, "RIGHT", space, 0);
				prevFrame = currency;
				currency:Show();
			end
			--hide extra currency frames
			for j=numCurrencies+1, MAX_CURRENCIES do
				currency = rewardFrame.Currencies["Currency"..j];
				currency:Hide();
				currency.currencyID = nil;
			end
			--show currencies and reanchor if there are no item rewards
			rewardFrame.Currencies:Show();
			if (numItems == 0) then
				rewardFrame.Currencies:SetPoint("TOPLEFT", rewardFrame, "TOPLEFT", 0, -5);
			else
				rewardFrame.Currencies:SetPoint("TOPLEFT", rewardFrame.Item, "BOTTOMLEFT", -30, -5);
			end
			height =  height + rewardFrame.Currencies:GetHeight();
		else
			rewardFrame.Currencies:Hide();
		end


		if (numReps ~= 0) then
			local repFrame = rewardFrame.ReputationsFrame.Reputation1;
			local factionFrame = repFrame.Faction;
			local amountFrame = repFrame.Amount;
			local dummyString = self.DummyString;
			local factionID, quantity = GetQuestChoiceRewardFaction(i, 1); --there should only be one reputation reward
			local factionName = format(REWARD_REPUTATION, GetFactionInfoByID(factionID));
			dummyString:SetText(factionName);
			factionFrame:SetText(factionName);
			amountFrame:SetText(quantity);
			local amountWidth = amountFrame:GetWidth();
			local factionWidth = dummyString:GetWidth();
			if ((amountWidth + factionWidth) > REWARDS_WIDTH) then
				factionFrame:SetWidth(REWARDS_WIDTH - amountWidth - 5);
				repFrame.tooltip = factionName;
			else
				factionFrame:SetWidth(factionWidth);
				repFrame.tooltip = nil
			end
			rewardFrame.ReputationsFrame:Show();
			height = height + rewardFrame.ReputationsFrame:GetHeight()
		else
			rewardFrame.ReputationsFrame:Hide();
		end
		rewardFrame:SetHeight(height);
	end
end

QuestChoiceOptionButtonMixin = {};

function QuestChoiceOptionButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local parent = self:GetParent():GetParent();
	if ( self.optID ) then
		if ( IsInGroup() and (parent.choiceID == GORGROND_GARRISON_ALLIANCE_CHOICE or parent.choiceID == GORGROND_GARRISON_HORDE_CHOICE) ) then
			StaticPopup_Show("CONFIRM_GORGROND_GARRISON_CHOICE", nil, nil, { response = self.optID, owner = parent:GetParent() });
		elseif ( self.confirmationText ) then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", self.confirmationText, nil, { response = self.optID, owner = parent:GetParent() });
		else
			SendQuestChoiceResponse(self.optID);
			local keepOpenAfterChoice = select(6, GetQuestChoiceInfo());
			if ( not keepOpenAfterChoice ) then
				HideUIPanel(parent:GetParent());
			end
		end
	end
end

function QuestChoiceOptionButtonMixin:OnEnter()
	if ( self.Text:IsTruncated() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text:GetText(), 1, 1, 1, 1, true);
		GameTooltip:Show();
	end
end

function QuestChoiceOptionButtonMixin:OnLeave()
	GameTooltip:Hide();
end

QuestChoiceItemButtonMixin = {};

function QuestChoiceItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	if GameTooltip:SetItemByID(self.itemID) then
		self.UpdateTooltip = self.OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function QuestChoiceItemButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function QuestChoiceItemButtonMixin:OnModifiedClick(button)
	local modifiedClick = IsModifiedClick();
	if ( modifiedClick ) then
		HandleModifiedItemClick(self.itemLink);
	end
end

QuestChoiceOptionFrameMixin = {};

function QuestChoiceOptionFrameMixin:ConfigureButtons()
	local parent = self:GetParent();
	local secondButton = self.OptionButtonsContainer.OptionButton2;
	if self.hasMultipleButtons then
		secondButton:Show();
		secondButton:ClearAllPoints();
		local firstButton = self.OptionButtonsContainer.OptionButton1;
		self.OptionButtonsContainer:SetSize(parent.optionButtonWidth, parent.optionButtonHeight * 2 + parent.optionButtonVerticalSpacing);
		secondButton:SetPoint("TOP", firstButton, "BOTTOM", 0, -parent.optionButtonVerticalSpacing);
	else
		secondButton:Hide();
		self.OptionButtonsContainer:SetSize(parent.optionButtonWidth, parent.optionButtonHeight);
	end
end

function QuestChoiceOptionFrameMixin:ConfigureHeader(header)
	if header and #header > 0 then
		self.Header:Show();
		self.Header.Text:SetText(header);
	else
		self.Header:Hide();
	end
end