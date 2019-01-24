MAX_PLAYER_CHOICE_OPTIONS = 4;
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
	local choiceInfo = C_QuestChoice.GetQuestChoiceInfo();
	if(choiceInfo and choiceInfo.soundKitID) then 
		PlaySound(choiceInfo.soundKitID);
	else 
		PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	end 
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

local function IsTopWidget(widgetFrame)
	return widgetFrame.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay;
end

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 0;

	local lastTopWidget, lastBottomWidget;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if IsTopWidget(widgetFrame) then
			if lastTopWidget then
				widgetFrame:SetPoint("TOP", lastTopWidget, "BOTTOM", 0, 0);
			else
				widgetFrame:SetPoint("TOP", widgetContainer, "TOP", 0, 0);
			end

			lastTopWidget = widgetFrame;
		else
			if lastBottomWidget then
				lastBottomWidget:SetPoint("BOTTOM", widgetFrame, "TOP", 0, 0);
			end

			widgetFrame:SetPoint("BOTTOM", widgetContainer, "BOTTOM", 0, 0);

			lastBottomWidget = widgetFrame;
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();

		local widgetWidth = widgetFrame:GetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	widgetsHeight = math.max(widgetsHeight, 1);
	maxWidgetWidth = math.max(maxWidgetWidth, 1);

	widgetContainer.nativeHeight = widgetsHeight;
	widgetContainer:SetHeight(widgetsHeight);
	widgetContainer:SetWidth(maxWidgetWidth);
end

function QuestChoiceFrameMixin:WidgetLayout(widgetContainer, sortedWidgets)
	WidgetsLayout(widgetContainer, sortedWidgets);
	self:UpdateHeight();
end

function QuestChoiceFrameMixin:WidgetInit(widgetFrame)
	if self.optionDescriptionColor and widgetFrame.SetFontStringColor then
		widgetFrame:SetFontStringColor(self.optionDescriptionColor);
	end
end

function QuestChoiceFrameMixin:UpdateOptionWidgetRegistration(option, widgetSetID)
	if not option.WidgetContainer then
		return;
	end

	option.WidgetContainer:RegisterForWidgetSet(widgetSetID,  function(...) self:WidgetLayout(...) end, function(...) self:WidgetInit(...) end);
end

function QuestChoiceFrameMixin:UpdateHeight()
	--make window taller if there is too much stuff
	local initOptionHeight = self.initOptionHeight or INIT_OPTION_HEIGHT;
	local optionStaticHeight = self.optionStaticHeight or OPTION_STATIC_HEIGHT;
	local maxHeight = initOptionHeight;

	self.maxWidgetsHeight = 0;
	self.maxDescriptionHeight = 0;
	for i=1, self.numActiveOptionFrames do
		local option = self.Options[i];
		self.maxDescriptionHeight = math.max(self.maxDescriptionHeight, option.OptionText:GetContentHeight());
		if option.WidgetContainer and option.WidgetContainer:IsShown() then
			self.maxWidgetsHeight = math.max(self.maxWidgetsHeight, option.WidgetContainer.nativeHeight);
		end
	end

	for i=1, self.numActiveOptionFrames do
		local option = self.Options[i];
		local currHeight = optionStaticHeight;

		currHeight = currHeight + option.OptionText:GetContentHeight() + option.OptionButtonsContainer:GetHeight() + self.maxWidgetsHeight;
		if (option.Rewards) then
			currHeight = currHeight + option.Rewards:GetHeight() + 25;
		end
		if option.SubHeader and option.SubHeader:IsShown() then
			currHeight = currHeight + option.SubHeader:GetHeight() + 2;
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

	for i = 1, self.numActiveOptionFrames do
		local option = self.Options[i];
		option:UpdateWidgetContainerAnchor(anOptionHasMultipleButtons);
		option:UpdateWidgetContainerHeight();
	end
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

function QuestChoiceFrameMixin:ThrowTooManyOptionsError(playerChoiceID, badOptID)
	local showingOptionIDs = {};
	for _, option in ipairs(self.Options) do
		table.insert(showingOptionIDs, option.optID);
	end

	table.insert(showingOptionIDs, badOptID);
	local errorMessage = "|n|nPLAYERCHOICE DATA ERROR: Too many visible options! Max allowed is "..MAX_PLAYER_CHOICE_OPTIONS..".|n|nCurrently showing PlayerChoice ID "..playerChoiceID.."|nCurrently showing OptionIDs: "..table.concat(showingOptionIDs, ", ").."|n";
	error(errorMessage);
end

function QuestChoiceFrameMixin:Update()
	self.hasPendingUpdate = false;

	local choiceInfo = C_QuestChoice.GetQuestChoiceInfo();	
	if (not choiceInfo or choiceInfo.choiceID == 0 or choiceInfo.numOptions == 0) then
		self:Hide();
		return;
	end
	for i, option in ipairs(self.Options) do
		option.groupID = nil;
	end
	self.choiceID = choiceInfo.choiceID;
	self.QuestionText:SetText(choiceInfo.questionText);

	self.numActiveOptionFrames = 0;

	local anOptionHasMultipleButtons = false;

	for i=1, choiceInfo.numOptions do
		local optionInfo = C_QuestChoice.GetQuestChoiceOptionInfo(i);

		local existingOption = self:GetExistingOptionForGroup(optionInfo.groupID);
		local button;

		if not existingOption and self:GetNumOptions() == MAX_PLAYER_CHOICE_OPTIONS then
			self:ThrowTooManyOptionsError(choiceInfo.choiceID, optionInfo.responseID);	-- This will cause a lua error and execution will stop
		end

		if existingOption then
			-- only supporting two grouped options
			existingOption.hasMultipleButtons = true;
			anOptionHasMultipleButtons = true;
			button = existingOption.OptionButtonsContainer.OptionButton2;
			if not optionInfo.disabledButton then
				existingOption.hasActiveButton = true;
			end
			-- for grouped options the art is only desaturated if all of them are
			if not optionInfo.desaturatedArt then
				existingOption.hasDesaturatedArt = false;
			end
		else
			self.numActiveOptionFrames = self.numActiveOptionFrames + 1;
			local option = self.Options[self.numActiveOptionFrames];
			option.hasMultipleButtons = false;
			option.hasActiveButton = not optionInfo.disabledButton;
			option.hasDesaturatedArt = optionInfo.desaturatedArt;
			option.groupID = optionInfo.groupID;
			option.optID = optionInfo.responseID;
			button = option.OptionButtonsContainer.OptionButton1;
			option.OptionText:SetText(optionInfo.description);
			option:ConfigureHeader(optionInfo.header, optionInfo.headerIconAtlasElement);
			option:ConfigureSubHeader(optionInfo.subHeader);
			option.Artwork:SetTexture(optionInfo.choiceArtID);
			option.soundKitID = optionInfo.soundKitID; 
			
			self:UpdateOptionWidgetRegistration(option, optionInfo.widgetSetID);
		end
		button.confirmationText = optionInfo.confirmationText;
		button.tooltip = optionInfo.buttonTooltip;
		button.rewardQuestID = optionInfo.rewardQuestID;
		button:SetText(optionInfo.buttonText);
		button.optID = optionInfo.responseID;
		button.soundKitID = optionInfo.soundKitID;
		button:SetEnabled(not optionInfo.disabledButton);
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
	if(self.soundKitID) then 
		PlaySound(self.soundKitID);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	local parent = self:GetParent():GetParent();
	if ( self.optID ) then
		if ( IsInGroup() and (parent.choiceID == GORGROND_GARRISON_ALLIANCE_CHOICE or parent.choiceID == GORGROND_GARRISON_HORDE_CHOICE) ) then
			StaticPopup_Show("CONFIRM_GORGROND_GARRISON_CHOICE", nil, nil, { response = self.optID, owner = parent:GetParent() });
		elseif ( self.confirmationText ) then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", self.confirmationText, nil, { response = self.optID, owner = parent:GetParent() });
		else
			SendQuestChoiceResponse(self.optID);
			local choiceInfo = C_QuestChoice.GetQuestChoiceInfo();
			if ( not choiceInfo.keepOpenAfterChoice ) then
				HideUIPanel(parent:GetParent());
			end
		end
	end
end

function QuestChoiceOptionButtonMixin:OnEnter()
	if self.tooltip or self.rewardQuestID or self.Text:IsTruncated() then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");

		if self.rewardQuestID and not HaveQuestRewardData(self.rewardQuestID) then
			GameTooltip_SetTitle(EmbeddedItemTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		else
			if self.Text:IsTruncated() then
				GameTooltip_SetTitle(EmbeddedItemTooltip, self.Text:GetText(), nil, true);
			end

			if self.tooltip then
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, self.tooltip, true);
			end

			if self.rewardQuestID then
				GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip, self.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_QUEST_CHOICE);
			end
		end

		EmbeddedItemTooltip:Show();
	else
		EmbeddedItemTooltip:Hide();
	end

	self.UpdateTooltip = self.OnEnter;
end

function QuestChoiceOptionButtonMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
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

function QuestChoiceOptionFrameMixin:UpdateWidgetContainerAnchor(anOptionHasMultipleButtons)
	local parent = self:GetParent();
	if anOptionHasMultipleButtons and not self.hasMultipleButtons then
		self.additionalHeight = parent.optionButtonHeight + parent.optionButtonVerticalSpacing + 5;
	else
		self.additionalHeight = 5;
	end

	self.WidgetContainer:SetPoint("BOTTOM", self.OptionButtonsContainer, "TOP", 0, self.additionalHeight);
end

function QuestChoiceOptionFrameMixin:UpdateWidgetContainerHeight()
	local parent = self:GetParent();
	if parent.maxDescriptionHeight and parent.maxDescriptionHeight > 0 then
		local y1 = self.OptionText:GetTop() - parent.maxDescriptionHeight - 5;
		local y2 = self.OptionButtonsContainer:GetTop() + self.additionalHeight;
		local spaceToFill = y1 - y2;
		local newHeight = math.max(spaceToFill, parent.maxWidgetsHeight);
		self.WidgetContainer:SetHeight(newHeight);
	end
end

local HEADER_TEXT_AREA_WIDTH = 195;

function QuestChoiceOptionFrameMixin:ConfigureHeader(header, headerIconAtlasElement)
	if header and #header > 0 then
		if headerIconAtlasElement then
			self.Header.Icon:SetAtlas(headerIconAtlasElement, true);
			self.Header.Icon:Show();
			self.Header.Text:SetWidth(HEADER_TEXT_AREA_WIDTH - (self.Header.Icon:GetWidth() + self.Header.spacing));
		else
			self.Header.Icon:Hide();
			self.Header.Text:SetWidth(HEADER_TEXT_AREA_WIDTH);
		end

		self.Header.Text:SetText(header);

		if self.Header.Text:GetNumLines() > 1 then
			self.Header.Text:SetWidth(self.Header.Text:GetWrappedWidth());
		else
			self.Header.Text:SetWidth(self.Header.Text:GetStringWidth());
		end

		self.Header:Show();
		self.Header:Layout();	-- Force a layout in case it was already shown
	else
		self.Header:Hide();
	end
end

function QuestChoiceOptionFrameMixin:ConfigureSubHeader(subHeader)
	-- Subheader is currently only supported for warboards
end
