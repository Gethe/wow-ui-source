IslandsQueueFrameMixin = { }; 

function IslandsQueueFrameMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\icon_treasuremap");	
end

function IslandsQueueFrameMixin:UpdateIslandCard(cardInfo, cardIndex)
	if (cardIndex > #self.IslandCardsFrame.IslandCards) then
		return;
	end
	
	local islandCard = self.IslandCardsFrame.IslandCards[cardIndex]; 

	islandCard.TitleScroll.IslandName:SetText(cardInfo.name); 
	islandCard.CardArt:SetAtlas(cardInfo.cardArtAtlas); 
end

function IslandsQueueFrameMixin:UpdateCardInformationByDifficulty(difficultySelection)
	local islandCardsInformation = C_IslandsQueue.GetIslandInfoByDifficulty(difficultySelection); 
	
	if (not islandCardsInformation) then
		return; 
	end
	
	for cardIndex, islandsInfo in ipairs(islandCardsInformation) do
		self:UpdateIslandCard(islandsInfo, cardIndex); 
	end
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
	
	local difficultyButtonPool = self.difficultyPool;
	local islandDifficultyIds = C_IslandsQueue.GetIslandDifficultyIds();
	local firstDifficulty = islandDifficultyIds[1]; 
	
	for button in difficultyButtonPool:EnumerateActive() do
		if (button.difficulty == firstDifficulty) then 
			self:SetActiveDifficulty(button);	-- The first one should be selected by default. 
			return; 
		end
	end
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
			self:GetParent():UpdateCardInformationByDifficulty(button.difficulty);
		else
			button.SelectedTexture:SetShown(false);
		end
	end
end