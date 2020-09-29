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
			nineSliceLayout = "IdenticalCornersLayout",
			nineSliceTextureKit = "horde",
			partyCategory = LE_PARTY_CATEGORY_HOME,
		},

		Alliance =
		{
			topperOffset = -28,
			borderPaddingX = 30,
			borderPaddingY = 20,
			Topper = "scoreboard-alliance-header",
			TitleBG = "scoreboard-header-alliance",
			nineSliceLayout = "IdenticalCornersLayout",
			nineSliceTextureKit = "alliance",
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
				grunt1 = 83860, -- Orc Male Grunt
				grunt2 = 87186, -- Troll Female Witch Doctor
				grunt3 = 85979, -- Blood Elf Female Warcaster
				grunt4 = 81941, -- Goblin Male Wistel
				grunt5 = 83958, -- Troll Male Axe Thrower
				grunt6 = 84011, -- Tauren Female Warrior
				grunt7 = 83858, -- Orc Female Grunt
				grunt8 = 83766, -- Orc Male Peon
			},

			ModelSceneBG = "scoreboard-background-warfronts-horde",
		},

		-- Alliance Arathi
		[1943] =
		{
			addModelSceneActors =
			{
				grunt1 = 86715, -- Human Male Footman
				grunt2 = 86833, -- Dwarf Female Rifleman
				grunt3 = 84310, -- Gnome Female Engineer
				grunt4 = 86989, -- Guman Female Priest
				grunt5 = 86823, -- Dwarf Male Rifleman
				grunt6 = 86814, -- Human Male Knight
				grunt7 = 87004, -- Human Female Sorceress
				grunt8 = 87528, -- Draenei Male Paladin
			},

			ModelSceneBG = "scoreboard-background-warfronts-alliance",
		},

		-- Horde Darkshore
		[2111] =
		{
			addModelSceneActors =
			{
				grunt1 = 90225, -- Female Goblin (Mizzyk)
				grunt2 = 88848, -- Male Undead Alchemist
				grunt3 = 90077, -- Female Blood Elf Dark Ranger
				grunt4 = 90325, -- Goblin Male (Zarvik Blastwix)
				grunt5 = 89568, -- Undead Male (Father Norlath)
				grunt6 = 88845, -- Undead Male Lancer
				grunt7 = 88889, -- Female Undead Alchemist
				grunt8 = 90370, -- Undead Female (Apothecary Zinge)
			},

			ModelSceneBG = "scoreboard-background-warfronts-darkshore-horde",
		},

		-- Alliance Darkshore
		[2105] =
		{
			addModelSceneActors =
			{
				grunt1 = 69424, -- Moonsaber
				grunt2 = 89354, -- Night Elf Female Sentinel
				grunt3 = 88840, -- Night Elf Female Huntress
				grunt4 = 34520, -- Human Female (Lorna Crowley)
				grunt5 = 88878, -- Night Elf Male Sentinel
				grunt6 = 88882, -- Night Elf Male Druid
				grunt7 = 89222, -- Worgen Male Footman
				grunt8 = 33840, -- Worgen Female (Celestine of the Harvest)
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
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyId);
			local name = currencyInfo.name;
			local texture = currencyInfo.iconFileID;
			local quality = currencyInfo.quality;
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