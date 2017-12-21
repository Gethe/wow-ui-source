CURRENCY_SPACING = 5;
CURRENCY_HEIGHT = 20;
MAX_CURRENCIES = 3;
REWARDS_WIDTH = 200;
INIT_REWARDS_HEIGHT = 18; --basically total vertical padding between rewards
INIT_OPTION_HEIGHT = 278;
INIT_WINDOW_HEIGHT = 480;
OPTION_STATIC_HEIGHT = 136; --height of artwork, button, and minimum padding

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
		self:Update();
	end
end

function QuestChoiceFrameMixin:Update()
	self.hasPendingUpdate = false;

	local choiceID, questionText, numOptions = GetQuestChoiceInfo();
	if (not choiceID or choiceID == 0) then
		self:Hide();
		return;
	end
	self.choiceID = choiceID;
	self.QuestionText:SetText(questionText);

	for i=1, numOptions do
		local optID, buttonText, description, header, artFile, confirmationText = GetQuestChoiceOptionInfo(i);
		local option = self.Options[i];
		option.optID = optID;
		option.OptionButton:SetText(buttonText);
		if (option.justifyCenter) then
			option.OptionText:SetText("<html><body><p align=\"CENTER\">"..description.."</p></body></html>");
		else
			option.OptionText:SetText(description);
		end
		if header and #header > 0 then
			option.Header:Show();
			option.Header.Text:SetHeight(0);
			option.Header.Text:SetText(header);
		else
			option.Header:Hide();
		end
		option.Artwork:SetTexture(artFile);
		option.confirmationText = confirmationText;
	end

	self:ShowRewards(numOptions)

	--make window taller if there is too much stuff
	local initOptionHeight = self.initOptionHeight or INIT_OPTION_HEIGHT;
	local optionStaticHeight = self.optionStaticHeight or OPTION_STATIC_HEIGHT;
	local maxHeight = initOptionHeight;
	for i=1, numOptions do
		local option = self.Options[i];
		local currHeight = optionStaticHeight;

		currHeight = currHeight + option.OptionText:GetContentHeight();
		if (option.Rewards) then
			currHeight = currHeight + option.Rewards:GetHeight() + 25;
		end
		maxHeight = math.max(currHeight, maxHeight);
	end
	for i=1, numOptions do
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
		self.Options[i]:SetShown(i <= numOptions);
	end
	if numOptions == 1 then
		self.leftPadding = (self.fixedWidth - self.Option1:GetWidth()) / 2;
		self.rightPadding = 0;
		self.spacing = 0;
	elseif numOptions == 4 then
		self.leftPadding = 50;
		self.rightPadding = 50;
		self.spacing = 20;
	else
		self.leftPadding = self.defaultLeftPadding;
		self.rightPadding = self.defaultRightPadding;
		self.spacing = self.defaultSpacing;
	end

	self:Layout();
end

function QuestChoiceFrameMixin:ShowRewards(numOptions)
	for i=1, numOptions do
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
	local parent = self:GetParent();
	if ( parent.optID ) then
		if ( IsInGroup() and (parent.choiceID == GORGROND_GARRISON_ALLIANCE_CHOICE or parent.choiceID == GORGROND_GARRISON_HORDE_CHOICE) ) then
			StaticPopup_Show("CONFIRM_GORGROND_GARRISON_CHOICE", nil, nil, { response = parent.optID, owner = parent:GetParent() });
		elseif ( parent.confirmationText ) then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", parent.confirmationText, nil, { response = parent.optID, owner = parent:GetParent() });
		else
			SendQuestChoiceResponse(parent.optID);
			HideUIPanel(parent:GetParent());
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