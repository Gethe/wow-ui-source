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
	local themeData =
	{
		-- Theme
		Horde =
		{
			topperOffset = -37,
			borderPaddingX = 30,
			borderPaddingY = 20,
			Topper = "scoreboard-horde-header",
			TitleBG = "scoreboard-header-horde",
			nineSliceLayout = "UniqueCornersLayout",
			nineSliceTextureKit = "scoreboard-horde",
			partyCategory = LE_PARTY_CATEGORY_INSTANCE,
		},

		Alliance =
		{
			topperOffset = -28,
			borderPaddingX = 30,
			borderPaddingY = 20,
			Topper = "scoreboard-alliance-header",
			TitleBG = "scoreboard-header-alliance",
			nineSliceLayout = "UniqueCornersLayout",
			nineSliceTextureKit = "scoreboard-alliance",
			partyCategory = LE_PARTY_CATEGORY_INSTANCE,
		},
	};

	local modelSceneData =
	{
		Horde =
		{
			ModelSceneBG = "scoreboard-background-islands-horde",
		},

		Alliance =
		{
			ModelSceneBG = "scoreboard-background-islands-alliance",
		},
	};

	function IslandsPartyPoseMixin:GetPartyPoseData(mapID, winner)
		local partyPoseData = PartyPoseMixin.GetPartyPoseData(self, mapID, winner);
		local playerFactionGroup = UnitFactionGroup("player");
		partyPoseData.themeData = themeData[playerFactionGroup];
		partyPoseData.modelSceneData = modelSceneData[playerFactionGroup];
		return partyPoseData;
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