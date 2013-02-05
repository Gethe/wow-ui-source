MAX_NUM_OPTIONS = 2;
CURRENCY_SPACING = 5;
CURRENCY_HEIGHT = 20;
MAX_CURRENCIES = 3;

function QuestChoiceFrame_OnEvent(self, event) 
	if (event == "QUEST_CHOICE_UPDATE") then
		QuestChoiceFrame_Update(self)
	end
end

function QuestChoiceFrame_Show()
	local self = QuestChoiceFrame;
	if (not self:IsShown()) then
		ShowUIPanel(self)
		QuestChoiceFrame_Update(QuestChoiceFrame);
	end
end

function QuestChoiceFrame_Update(self)
	
	local choiceID, questionText, numOptions = GetQuestChoiceInfo();
	if (not choiceID or choiceID==0) then
		self:Hide();
		return;
	end
	self.choiceID = choiceID;
	self.QuestionText:SetText(questionText);
	
	for i=1, numOptions do
		local optID, buttonText, description, artFile = GetQuestChoiceOptionInfo(i);
		local option = QuestChoiceFrame["Option"..i];
		option.optID = optID;
		option.OptionButton:SetText(buttonText);
		option.OptionText:SetText(description);
		option.Artwork:SetTexture(artFile);
		
	end
	
	QuestInfo_ShowRewards()
end

function QuestInfo_ShowRewards()
	local rewardFrame;
	local title, skillID, skillPoints, money, xp, numItems, numCurrencies, numChoices, numReps;
	local name, texture, quantity, itemFrame;
	local currID, factionID;
	
	for i=1, MAX_NUM_OPTIONS do
		rewardFrame = QuestChoiceFrame["Option"..i].Rewards;
		title, skillID, skillPoints, money, xp, numItems, numCurrencies, numChoices, numReps = GetQuestChoiceRewardInfo(i)
		
		if (numItems ~= 0) then
			itemID, name, texture, quantity = GetQuestChoiceRewardItem(i, 1); --for now there is only ever 1 item by design
			rewardFrame.Item.itemID = itemID;
			rewardFrame.Item:Show();
			rewardFrame.Item.name:SetText(name)
			SetItemButtonCount(rewardFrame.Item, quantity);
			SetItemButtonTexture(rewardFrame.Item, texture);
		else
			rewardFrame.Item:Hide();
		end
		
		if (numCurrencies ~= 0) then
			local width, currency;
			local totalWidth = 0;
			for j=1, numCurrencies do
				currency = rewardFrame.Currencies["Currency"..j];
				currID, texture, quantity = GetQuestChoiceRewardCurrency(i, j); --there should only be one currency reward
				currency.currencyID = currID;
				currency.Icon:SetTexture("Interface\\Icons\\"..texture);
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
		else
			rewardFrame.Currencies:Hide();
		end
		
		
		if (numReps ~= 0) then
			factionID, quantity = GetQuestChoiceRewardFaction(i, 1); --there should only be one reputation reward
			factionName = GetFactionInfoByID(factionID);
			rewardFrame.ReputationsFrame.Reputation1.Faction:SetText(format(REWARD_REPUTATION, factionName));
			rewardFrame.ReputationsFrame.Reputation1.Amount:SetText(quantity);
			rewardFrame.ReputationsFrame:Show();
		else
			rewardFrame.ReputationsFrame:Hide();
		end
	end
end