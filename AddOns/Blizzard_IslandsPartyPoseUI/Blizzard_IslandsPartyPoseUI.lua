IslandsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function IslandsPartyPoseMixin:SetRewards()
	self.pendingRewardData = {};

	local name, typeID, subtypeID, iconTextureFile, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();
	if not numRewards or numRewards == 0 then
		self.RewardAnimations.RewardFrame:Hide();
		return;
	end

	local continuableContainer = ContinuableContainer:Create();
	for i = 1, numRewards do
		local texture, quantity, isBonus, bonusQuantity, name, quality, id, objectType = GetLFGCompletionRewardItem(i);
		if objectType == "item" then
			local item = Item:CreateFromItemID(id);
			continuableContainer:AddContinuable(item);
		end
	end

	continuableContainer:ContinueOnLoad(function()
		for i = 1, numRewards do
			local texture, quantity, isBonus, bonusQuantity, name, quality, id, objectType = GetLFGCompletionRewardItem(i);
			local originalQuantity = quantity;
			local isCurrencyContainer = false;
			local objectLink = GetLFGCompletionRewardItemLink(i);
			if (objectType == "currency") then
				isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(id, quantity);
				name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(id, quantity, name, texture, quality);
			end

			self:AddReward(name, texture, quality, id, objectType, objectLink, quantity, originalQuantity, isCurrencyContainer);
		end

		table.sort(self.pendingRewardData, function(left, right)
			if left.isCurrencyContainer ~= right.isCurrencyContainer then
				return left.isCurrencyContainer;
			end
			if left.objectType ~= right.objectType then
				return left.objectType < right.objectType; -- Not really important, just that the order is consistent
			end
			return left.id < right.id;
		end);

		self.RewardAnimations.RewardFrame:Show();
		self:PlayNextRewardAnimation();
	end);
end

function IslandsPartyPoseMixin:SetLeaveButtonText()
	self.LeaveButton:SetText(ISLAND_LEAVE);
end

do
	local islandsStyleData =
	{
		Horde =
		{
			topperOffset = -37,
			Topper = "scoreboard-horde-header",
			topperBehindFrame = false,

			TitleBG = "scoreboard-header-horde",
			ModelSceneBG = "scoreboard-background-islands-horde",

			Top = "_scoreboard-horde-tiletop",
			Bottom = "_scoreboard-horde-tilebottom",
			Left = "!scoreboard-horde-tileleft",
			Right = "!scoreboard-horde-tileright",
			TopLeft = "scoreboard-horde-corner",
			TopRight = "scoreboard-horde-corner",
			BottomLeft = "scoreboard-horde-corner",
			BottomRight = "scoreboard-horde-corner",

			-- one-off
			bottomCornerYOffset = -24;
		},

		Alliance =
		{
			topperOffset = -28,
			Topper = "scoreboard-alliance-header",
			topperBehindFrame = false,

			TitleBG = "scoreboard-header-alliance",
			ModelSceneBG = "scoreboard-background-islands-alliance",

			Top = "_scoreboard-alliance-tiletop",
			Bottom = "_scoreboard-alliance-tilebottom",
			Left = "!scoreboard-alliance-tileleft",
			Right = "!scoreboard-alliance-tileright",
			TopLeft = "scoreboard-alliance-corner",
			TopRight = "scoreboard-alliance-corner",
			BottomLeft = "scoreboard-alliance-corner",
			BottomRight = "scoreboard-alliance-corner",

			-- one-off
			bottomCornerYOffset = -20;
		},
	};

	function IslandsPartyPoseMixin:LoadScreenData(mapID, winner)
		local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID);
		UIWidgetManager:RegisterWidgetSetContainer(partyPoseInfo.widgetSetID, self.Score);

		self:SetLeaveButtonText();

		local winnerFactionGroup = PLAYER_FACTION_GROUP[winner];
		local playerFactionGroup = UnitFactionGroup("player");
		self:PlaySounds(partyPoseInfo, winnerFactionGroup);
		if (winnerFactionGroup == playerFactionGroup) then
			self.TitleText:SetText(PARTY_POSE_VICTORY);
			self:SetModelScene(partyPoseInfo.victoryModelSceneID, LE_PARTY_CATEGORY_INSTANCE);
		else
			self.TitleText:SetText(PARTY_POSE_DEFEAT);
			self:SetModelScene(partyPoseInfo.defeatModelSceneID, LE_PARTY_CATEGORY_INSTANCE);
		end

		self:SetupTheme(islandsStyleData[playerFactionGroup]);
	end
end

function IslandsPartyPoseMixin:OnLoad()
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	PartyPoseMixin.OnLoad(self); 
end

function IslandsPartyPoseMixin:OnEvent(event, ...)
	if ( event == "LFG_COMPLETION_REWARD" ) then
		self:SetRewards();
	end
	PartyPoseMixin.OnEvent(self, event); 
end