WarfrontsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function WarfrontsPartyPoseMixin:PlayRewardsAnimations()
	self.RewardAnimations.RewardFrame:Show();
	if (self:CanResumeAnimation()) then
		self:PlayNextRewardAnimation();
	end
	self.isPlayingRewards = true;
end

function WarfrontsPartyPoseMixin:SetLeaveButtonText()
	self.LeaveButton:SetText(WARFRONTS_LEAVE);
end

do
	local themeData =
	{
		Horde =
		{
			topperOffset = -37,
			borderPaddingX = 30,
			borderPaddingY = 20,
			Topper = "scoreboard-horde-header",
			TitleBG = "scoreboard-header-horde",
			nineSliceLayout = "PartyPoseKit",
			nineSliceTextureKitName = "horde",
			partyCategory = LE_PARTY_CATEGORY_HOME,
		},

		Alliance =
		{
			topperOffset = -28,
			borderPaddingX = 30,
			borderPaddingY = 20,
			Topper = "scoreboard-alliance-header",
			TitleBG = "scoreboard-header-alliance",
			nineSliceLayout = "PartyPoseKit",
			nineSliceTextureKitName = "alliance",
			partyCategory = LE_PARTY_CATEGORY_HOME,
		},
	}

	local modelSceneData =
	{
		-- Horde Arathi
		[1876] =
		{
			addModelSceneActors =
			{
				grunt1 = 83860, -- ORCMALE_HD.m2 (Grunt)
				grunt2 = 87186, -- TROLLFEMALE_HD.m2 (Witch Doctor)
				grunt3 = 85979, -- BLOODELFFEMALE_HD.m2 (Warcaster)
				grunt4 = 81941, -- GOBLINMALE.m2 (Wistel)
				grunt5 = 83958, -- TROLLMALE_HD.m2 (Axe Thrower)
				grunt6 = 84011, -- TAURENFEMALE_HD.m2 (Warrior)
				grunt7 = 83858, -- ORCFEMALE_HD.m2 (Grunt)
				grunt8 = 83766, -- ORCMALE_HD.m2 (Peon)
			},

			ModelSceneBG = "scoreboard-background-warfronts-horde",
		},

		-- Alliance Arathi
		[1943] =
		{
			addModelSceneActors =
			{
				grunt1 = 86715, -- humanguard_m.m2 (human male footman)
				grunt2 = 86833, -- DWARFFEMALE_HD.m2 (dwarf female rifleman)
				grunt3 = 84310, -- GNOMEFEMALE_HD.m2 (gnome female engineer)
				grunt4 = 86989, -- HUMANFEMALE_HD.m2 (human female priest)
				grunt5 = 86823, -- DWARFMALE_HD.m2 (dwarf male rifleman)
				grunt6 = 86814, -- humanknight_m.m2 (human male knight)
				grunt7 = 87004, -- HUMANFEMALE_HD.m2 (human female sorceress)
				grunt8 = 87528, -- draeneipeacekeeper_m.m2 (draenei male paladin)
			},

			ModelSceneBG = "scoreboard-background-warfronts-alliance",
		},

		-- Horde Darkshore
		[2111] =
		{
			addModelSceneActors =
			{
				grunt1 = 88884, -- fleshgolem2.m2 (abomination)
				grunt2 = 88884, -- fleshgolem2.m2 (abomination)
				grunt3 = 88884, -- fleshgolem2.m2 (abomination)
				grunt4 = 88884, -- fleshgolem2.m2 (abomination)
				grunt5 = 88884, -- fleshgolem2.m2 (abomination)
				grunt6 = 88884, -- fleshgolem2.m2 (abomination)
				grunt7 = 88884, -- fleshgolem2.m2 (abomination)
				grunt8 = 88884, -- fleshgolem2.m2 (abomination)
			},

			ModelSceneBG = "scoreboard-background-warfronts-darkshore-horde",
		},

		-- Alliance Darkshore
		[2105] =
		{
			addModelSceneActors =
			{
				grunt1 = 87180, -- wisp_norig.m2 (wisp)
				grunt2 = 87180, -- wisp_norig.m2 (wisp)
				grunt3 = 87180, -- wisp_norig.m2 (wisp)
				grunt4 = 87180, -- wisp_norig.m2 (wisp)
				grunt5 = 87180, -- wisp_norig.m2 (wisp)
				grunt6 = 87180, -- wisp_norig.m2 (wisp)
				grunt7 = 87180, -- wisp_norig.m2 (wisp)
				grunt8 = 87180, -- wisp_norig.m2 (wisp)
			},

			ModelSceneBG = "scoreboard-background-warfronts-darkshore-alliance",
		},
	}

	function WarfrontsPartyPoseMixin:GetPartyPoseData(mapID, winner)
		local partyPoseData = PartyPoseMixin.GetPartyPoseData(self, mapID, winner);
		local playerFactionGroup = UnitFactionGroup("player");
		partyPoseData.themeData = themeData[playerFactionGroup];
		partyPoseData.modelSceneData = modelSceneData[mapID];
		return partyPoseData;
	end
end

function WarfrontsPartyPoseMixin:OnLoad()
	self:RegisterEvent("SCENARIO_COMPLETED");
	self:RegisterEvent("QUEST_LOOT_RECEIVED");
	self:RegisterEvent("QUEST_CURRENCY_LOOT_RECEIVED");
	PartyPoseMixin.OnLoad(self);
	self.isPlayingRewards = false;
end

function WarfrontsPartyPoseMixin:OnHide()
	self.questID = nil;
	self.isPlayingRewards = false;
end

function WarfrontsPartyPoseMixin:OnEvent(event, ...)
	PartyPoseMixin.OnEvent(self, event, ...);
	if (event == "SCENARIO_COMPLETED") then
		self.pendingRewardData = {};
		self.questID = ...;
	elseif (event == "QUEST_LOOT_RECEIVED") then
		local questID, rewardItemLink, quantity = ...;
		if (questID == self.questID) then
			local item = Item:CreateFromItemLink(rewardItemLink);
			item:ContinueOnItemLoad(function()
				local id = item:GetItemID();
				local quality = item:GetItemQuality();
				local texture = item:GetItemIcon();
				local name = item:GetItemName();
				self:AddReward(name, texture, quality, id, "item", rewardItemLink, quantity, quantity, false);
				if (not self.isPlayingRewards) then
					self:PlayRewardsAnimations();
				end
			end);
		end
	elseif (event == "QUEST_CURRENCY_LOOT_RECEIVED") then
		local questID, currencyId, quantity = ...;
		if (questID == self.questID) then
			local name, _, texture, _, _, _, _, quality = GetCurrencyInfo(currencyId);
			local originalQuantity = quantity;
			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(currencyId, quantity);
			name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyId, quantity, name, texture, quality);
			self:AddReward(name, texture, quality, currencyId, "currency", currencyLink, quantity, originalQuantity, isCurrencyContainer);
			if (not self.isPlayingRewards) then
				self:PlayRewardsAnimations();
			end
		end
	end
end