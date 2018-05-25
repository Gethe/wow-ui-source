local ISLANDS_QUEUE_WIDGET_SET_ID = 127; 
local ISLANDS_QUEUE_LEFT_CARD_ROTATION = math.rad(-4.91);
local ISLANDS_QUEUE_RIGHT_CARD_ROTATION = math.rad(1.15); 

IslandsQueueWeeklyQuestMixin = { }; 

function IslandsQueueWeeklyQuestMixin:OnLoad()
	
end

function IslandsQueueWeeklyQuestMixin:SetupReward(questID)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	local currencies = { };
	for i = 1, numQuestCurrencies do
		local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID);
		local rarity = select(8, GetCurrencyInfo(currencyID));
		local currencyInfo = { name = name, texture = texture, numItems = numItems, currencyID = currencyID, rarity = rarity };
	end
end

function IslandsQueueWeeklyQuestMixin:Update(questID) 

end

IslandsQueueFrameMixin = { }; 

local function SetWidgetFrameAnchors(frame, anchorFrame)
	frame:SetPoint("CENTER", anchorFrame.Background, "CENTER", 0,0); 
	frame.Text:SetPoint("CENTER", anchorFrame.TitleScroll, "CENTER", 0, 0);
	frame:SetFrameLevel(anchorFrame:GetFrameLevel() +10);
end

local function WidgetsLayout(widgetContainer, sortedWidgets)
	for index, widgetFrame in ipairs(sortedWidgets) do	
		if ( index == 1 ) then
			widgetFrame.Background:SetRotation(ISLANDS_QUEUE_LEFT_CARD_ROTATION); 
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.LeftCard)
		elseif ( index == 2 ) then 
			widgetFrame.Background:SetRotation(0); 
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.CenterCard)
		elseif ( index == 3 ) then 
			widgetFrame.Background:SetRotation(ISLANDS_QUEUE_RIGHT_CARD_ROTATION); 
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.RightCard)
		end
	end
end

function IslandsQueueFrameMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\icon_treasuremap");	
	UIWidgetManager:RegisterWidgetSetContainer(ISLANDS_QUEUE_WIDGET_SET_ID, self.IslandCardsFrame, WidgetsLayout);
end

function IslandsQueueFrameMixin:OnShow()
	self.DifficultySelectorFrame:SetInitialDifficulty(); 
end

IslandsQueueFrameDifficultyMixin = { }; 

function IslandsQueueFrameDifficultyMixin:OnLoad()
	self.difficultyPool = CreateFramePool("BUTTON", self, "IslandsQueueFrameDifficultyButtonTemplate");
end

function IslandsQueueFrameDifficultyMixin:SetInitialDifficulty()
	self:RefreshDifficultyButtons(); 
	
	local firstDifficulty = self.difficultyPool:GetNextActive(); 
	self:SetActiveDifficulty(firstDifficulty); 
end

function IslandsQueueFrameDifficultyMixin:RefreshDifficultyButtons()
	local islandDifficultyIds = C_IslandsQueue.GetIslandDifficultyIds();
	self.difficultyPool:ReleaseAll(); 
	
	for buttonIndex, islandDifficultyId in ipairs(islandDifficultyIds) do
		local button = self.difficultyPool:Acquire();		
		if (buttonIndex == 1) then 
			button:SetPoint("CENTER", self.Background, "CENTER", -60, 15); 
		else
			button:SetPoint("RIGHT", self.previousDifficulty, "RIGHT", 40, 0);
		end
		button.NormalTexture:SetAtlas("islands-queue-difficultyselector-"..buttonIndex);
		self.previousDifficulty = button; 
		button.difficulty = islandDifficultyId;
		button:Show(); 
	end
end

function IslandsQueueFrameDifficultyMixin:SetActiveDifficulty(difficultyButton)
	self.activeDifficulty = difficultyButton.difficulty;
	
	for button in self.difficultyPool:EnumerateActive() do
		if (button.difficulty == self.activeDifficulty) then 
			button.SelectedTexture:SetShown(true);
		else
			button.SelectedTexture:SetShown(false);
		end
	end
end