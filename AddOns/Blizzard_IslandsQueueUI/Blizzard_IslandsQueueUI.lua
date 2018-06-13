local ISLANDS_QUEUE_WIDGET_SET_ID = 127; 
local ISLANDS_QUEUE_LEFT_CARD_ROTATION = math.rad(-4.91);
local ISLANDS_QUEUE_RIGHT_CARD_ROTATION = math.rad(1.15); 
IslandsQueueWeeklyQuestMixin = { }; 

local ButtonTooltips = 
{
	PLAYER_DIFFICULTY1,
	PLAYER_DIFFICULTY2,
	PLAYER_DIFFICULTY6,
	PVP_FLAG,	
};

function IslandsQueueWeeklyQuestMixin:OnEvent(event, ...)
	if (event == "QUEST_LOG_UPDATE") then
		self:Refresh();
	end
end

function IslandsQueueWeeklyQuestMixin:OnShow()
	self:RegisterEvent("QUEST_LOG_UPDATE"); 
	self.questID = C_IslandsQueue.GetIslandsWeeklyQuestID();
	self.QuestReward.questID = self.questID;
	self:Refresh(); 
end

function IslandsQueueWeeklyQuestMixin:OnHide()
	self:UnregisterEvent("QUEST_LOG_UPDATE"); 
	self.OverlayFrame.Spark:Hide(); 
end

function IslandsQueueWeeklyQuestMixin:UpdateRewardInformation()
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(self.questID);
	for i = 1, numQuestCurrencies do
		local name, texture, quantity, currencyID = GetQuestLogRewardCurrencyInfo(i, self.questID);
		local quality = select(8, GetCurrencyInfo(currencyID));
		name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, texture, quality);
		self.QuestReward.Icon:SetTexture(texture);
	end
end

function IslandsQueueWeeklyQuestMixin:UpdateQuestProgressBar()
	local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(self.questID, 1, false);
	
	self.StatusBar:SetMinMaxValues(0, numRequired); 
	self.StatusBar:SetValue(numFulfilled); 
	self.OverlayFrame.Text:SetText(ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS:format(numFulfilled, numRequired));
	
	self.objectiveText = objectiveText;
	if (numFulfilled > 0) then 
		local sparkSet = math.max((numFulfilled  / numRequired) * (self.StatusBar:GetWidth()), 0);
		self.OverlayFrame.Spark:ClearAllPoints();
		self.OverlayFrame.Spark:SetPoint("CENTER", self.StatusBar, "LEFT", sparkSet, 2);
		self.OverlayFrame.Spark:Show(); 
	else
		self.OverlayFrame.Spark:Hide();
	end
end

function IslandsQueueWeeklyQuestMixin:Refresh()
	if (HaveQuestData(self.questID) and HaveQuestRewardData(self.questID)) then 
		self:UpdateRewardInformation(); 
		self:UpdateQuestProgressBar(); 
	end
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
			widgetFrame.Portrait:SetRotation(ISLANDS_QUEUE_LEFT_CARD_ROTATION);
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.LeftCard)
		elseif ( index == 2 ) then 
			widgetFrame.Background:SetRotation(0); 
			widgetFrame.Portrait:SetRotation(0);
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.CenterCard)
		elseif ( index == 3 ) then 
			widgetFrame.Background:SetRotation(ISLANDS_QUEUE_RIGHT_CARD_ROTATION); 
			widgetFrame.Portrait:SetRotation(ISLANDS_QUEUE_RIGHT_CARD_ROTATION);
			SetWidgetFrameAnchors(widgetFrame, widgetContainer.RightCard)
		end
	end
end

function IslandsQueueFrameMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\icon_treasuremap");	
	UIWidgetManager:RegisterWidgetSetContainer(ISLANDS_QUEUE_WIDGET_SET_ID, self.IslandCardsFrame, WidgetsLayout);
	self:RegisterEvent("ISLANDS_QUEUE_CLOSE"); 
end

function IslandsQueueFrameMixin:OnEvent(event, ...) 
	if (event == "ISLANDS_QUEUE_CLOSE") then
		HideUIPanel(self);
	end
end

function IslandsQueueFrameMixin:OnShow()
	self.DifficultySelectorFrame:SetInitialDifficulty(); 
end

function IslandsQueueFrameMixin:OnHide()
	C_IslandsQueue.CloseIslandsQueueScreen();
end

IslandsQueueFrameDifficultyMixin = { }; 

function IslandsQueueFrameDifficultyMixin:OnQueueClick()
	C_IslandsQueue.QueueForIsland(self:GetActiveDifficulty());
end

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
		button.tooltipText = ButtonTooltips[buttonIndex]; 
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

function IslandsQueueFrameDifficultyMixin:GetActiveDifficulty()
	return self.activeDifficulty; 
end