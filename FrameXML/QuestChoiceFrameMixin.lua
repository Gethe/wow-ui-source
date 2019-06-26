MAX_PLAYER_CHOICE_OPTIONS = 4;
CURRENCY_SPACING = 5;
CURRENCY_HEIGHT = 20;
MAX_CURRENCIES = 3;
REWARDS_WIDTH = 200;
INIT_REWARDS_HEIGHT = 18; --basically total vertical padding between rewards
INIT_OPTION_HEIGHT = 278;

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
	BaseLayoutMixin.OnLoad(self);

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
	BaseLayoutMixin.OnUpdate(self);
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

		widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight();

		local widgetWidth = widgetFrame:GetWidgetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	if lastTopWidget and lastBottomWidget then
		widgetsHeight = widgetsHeight + 20;
	end

	widgetsHeight = math.max(widgetsHeight, 1);
	maxWidgetWidth = math.max(maxWidgetWidth, 1);

	widgetContainer:SetHeight(widgetsHeight);
	widgetContainer:SetWidth(maxWidgetWidth);
end

function QuestChoiceFrameMixin:WidgetLayout(widgetContainer, sortedWidgets)
	WidgetsLayout(widgetContainer, sortedWidgets);
	self.optionsAligned = false;
	self:MarkDirty();
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

function QuestChoiceFrameMixin:OnCleaned()
	if not self.optionsAligned then
		self:AlignOptionHeights();
	end
end

function QuestChoiceFrameMixin:AlignOptionHeights()
	if not self.numActiveOptions then
		return;
	end

	local initOptionHeight = self.initOptionHeight or INIT_OPTION_HEIGHT;

	-- Get the max height option
	local maxOptionHeight = 0;
	local maxHeightOption;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		local optionHeight = option:GetHeight();
		if optionHeight > maxOptionHeight then
			maxHeightOption = option;
			maxOptionHeight = optionHeight;
		end
	end

	-- If the max height option is smaller than the initHeight, add height to its padding container
	if initOptionHeight > maxOptionHeight then
		maxHeightOption:AddPaddingHeight(initOptionHeight - maxOptionHeight);
	end

	-- Now get the max padding frame height
	local maxPaddingHeight = 0;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		maxPaddingHeight = math.max(maxPaddingHeight, option:GetPaddingHeight());
	end

	-- And set all padding frame heights to the max padding frame height (so top and bottom widgets align)
	maxOptionHeight = 0;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		local optionPaddingHeight = option:GetPaddingHeight();

		-- If optionPaddingHeight is 1 or less there is nothing in it, so don't bother (we don't want an empty padding container to make a large option even larger)
		if optionPaddingHeight > 1 then
			local heightDiff = maxPaddingHeight - optionPaddingHeight;
			option:AddPaddingHeight(heightDiff);
		end

		maxOptionHeight = math.max(maxOptionHeight, option:GetHeight());	-- Might as well calculate the new maxOptionHeight while we are in here 
	end

	-- Then loop through again and adjust the padding offset and heights to make all the options the same height
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		option:UpdatePadding(maxOptionHeight);
	end

	if not self.fixedPaddingAndSpacing then
		if self.numActiveOptions == 1 then
			self.leftPadding = (self.fixedWidth - self.Option1:GetWidth()) / 2;
			self.rightPadding = 0;
			self.spacing = 0;
		elseif self.numActiveOptions == 4 then
			self.leftPadding = 50;
			self.rightPadding = 50;
			self.spacing = 20;
		else
			self.leftPadding = self.defaultLeftPadding;
			self.rightPadding = self.defaultRightPadding;
			self.spacing = self.defaultSpacing;
		end
	end

	-- NOTE: It is very important that you set optionsAligned to true here, otherwise the Layout call will cause AlignOptionHeights to get called again
	self.optionsAligned = true;

	self:Layout(); -- Note that we call Layout here and not MarkDirty. Otherwise the Layout won't happen until the next frame and you will see a pop as things get adjsuted
end

function QuestChoiceFrameMixin:GetNumOptions()
	return self.numActiveOptions;
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

function QuestChoiceFrameMixin:UpdateNumActiveOptions(choiceInfo)
	self.numActiveOptions = 0;
	self.anOptionHasMultipleButtons = false;
	self.optionData = {};

	local groupOptionMap = {};
	for i=1, choiceInfo.numOptions do
		local optionInfo = C_QuestChoice.GetQuestChoiceOptionInfo(i);
		if not optionInfo then
			return;	-- End of the valid options
		end

		if not optionInfo.groupID or not groupOptionMap[optionInfo.groupID] then
			-- This option is either not part of a group or is part of a NEW group
			if self.numActiveOptions == MAX_PLAYER_CHOICE_OPTIONS then
				self:ThrowTooManyOptionsError(choiceInfo.choiceID, optionInfo.responseID);	-- This will cause a lua error and execution will stop
			end

			self.numActiveOptions = self.numActiveOptions + 1;
			table.insert(self.optionData, optionInfo);
			if optionInfo.groupID then
				groupOptionMap[optionInfo.groupID] = #self.optionData;
			end
		else
			-- This option is part of a group that already exists...add its info to that option
			local existingGroupOptionIndex = groupOptionMap[optionInfo.groupID];
			local existingGroupOptionInfo = self.optionData[existingGroupOptionIndex];
			existingGroupOptionInfo.secondOptionInfo = optionInfo;

			-- for grouped options the art is only desaturated if all of them are
			if not optionInfo.desaturatedArt then
				existingGroupOptionInfo.desaturatedArt = false;
			end

			self.anOptionHasMultipleButtons = true;
		end
	end
end

function QuestChoiceFrameMixin:Update()
	self.hasPendingUpdate = false;

	local choiceInfo = C_QuestChoice.GetQuestChoiceInfo();	
	if (not choiceInfo or choiceInfo.choiceID == 0 or choiceInfo.numOptions == 0) then
		self:Hide();
		return;
	end

	self.choiceID = choiceInfo.choiceID;
	self.QuestionText:SetText(choiceInfo.questionText);

	self:UpdateNumActiveOptions(choiceInfo);

	for i, option in ipairs(self.Options) do
		if i > self.numActiveOptions then
			self:UpdateOptionWidgetRegistration(option, nil);
			option:Hide();
		else
			local optionInfo = self.optionData[i];
			option:UpdateOptionSize();
			option:UpdatePadding();
			option.hasDesaturatedArt = optionInfo.desaturatedArt;
			option.optID = optionInfo.responseID;
			option.OptionText:SetText(optionInfo.description);
			option:ConfigureHeader(optionInfo.header, optionInfo.headerIconAtlasElement);
			option:ConfigureSubHeader(optionInfo.subHeader);
			option.Artwork:SetTexture(optionInfo.choiceArtID);
			option.soundKitID = optionInfo.soundKitID; 
			
			self:UpdateOptionWidgetRegistration(option, optionInfo.widgetSetID);
			option:ConfigureButtons(optionInfo);
			option:Show();
		end
	end

	self:ShowRewards();

	self.optionsAligned = false;
	self:MarkDirty();
end

function QuestChoiceFrameMixin:ShowRewards()
	for i=1, self.numActiveOptions do
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
		elseif ( self.confirmation ) then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", self.confirmation, nil, { response = self.optID, owner = parent:GetParent() });
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

-- Override in inheriting mixins as needed
function QuestChoiceOptionFrameMixin:UpdateOptionSize()
end

-- Override in inheriting mixins as needed
function QuestChoiceOptionFrameMixin:UpdateSecondButtonAnchors()
end

function QuestChoiceOptionFrameMixin:ConfigureButton(button, optionInfo)
	button.confirmation = optionInfo.confirmation;
	button.tooltip = optionInfo.buttonTooltip;
	button.rewardQuestID = optionInfo.rewardQuestID;
	button:SetText(optionInfo.buttonText);
	button.optID = optionInfo.responseID;
	button.soundKitID = optionInfo.soundKitID;
	button:SetEnabled(not optionInfo.disabledButton);
end

function QuestChoiceOptionFrameMixin:GetPaddingFrame()
	return self.Rewards;
end

function QuestChoiceOptionFrameMixin:ConfigureButtons(optionInfo)
	local button1 = self.OptionButtonsContainer.OptionButton1;
	local button2 = self.OptionButtonsContainer.OptionButton2;

	self:ConfigureButton(button1, optionInfo);

	local buttonContainerOffset = 5;
	if optionInfo.secondOptionInfo then
		self:ConfigureButton(button2, optionInfo.secondOptionInfo);
		self:UpdateSecondButtonAnchors();
		button2:Show();
	else
		button2:Hide();

		if self:GetParent().anOptionHasMultipleButtons then
			-- If another option has multiple Buttons and we don't, offset the container more
			buttonContainerOffset = 35;
		end
	end

	self.OptionButtonsContainer:SetPoint("TOP", self:GetPaddingFrame(), "BOTTOM", 0, -buttonContainerOffset);
end

-- If we need to make up extra space in this option, adjust the padding frame offset to push it down further and create space
function QuestChoiceOptionFrameMixin:UpdatePadding(maxOptionHeight)
	local yOffset = 5;

	if maxOptionHeight then
		local optionHeight = self:GetHeight();
		if maxOptionHeight > optionHeight then
			local heightDiff = maxOptionHeight - optionHeight;
			yOffset = heightDiff + 5;
			self:SetHeight(maxOptionHeight);
		end
	end

	self:GetPaddingFrame():SetPoint("TOP", self.OptionText, "BOTTOM", 0, -yOffset);
end

function QuestChoiceOptionFrameMixin:AddPaddingHeight(addedHeight)
	self:GetPaddingFrame():SetHeight(self:GetPaddingFrame():GetHeight() + addedHeight);
	self:SetHeight(self:GetHeight() + addedHeight);
end

function QuestChoiceOptionFrameMixin:GetPaddingHeight()
	return self:GetPaddingFrame():GetHeight();
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
