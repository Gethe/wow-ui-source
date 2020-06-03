AdventuresRewardsScreenMixin = {};

function AdventuresRewardsScreenMixin:OnLoad() 
	self.rewardsPool = CreateFramePool("FRAME", self.FinalRewardsPanel.SpoilsFrame.RewardsEarnedFrame, "GarrisonMissionListButtonRewardTemplate");
	self.followerPool = CreateFramePool("FRAME", self.FinalRewardsPanel.SpoilsFrame.FollowerExperienceEarnedFrame, "AdventuresRewardsPaddedFollower");
end

function AdventuresRewardsScreenMixin:Reset() 
	self:Hide();
	self:HideAllPanels();
end

function AdventuresRewardsScreenMixin:ShowAdventureVictoryStateScreen(combatWon)
	local adventuresEmblemFormat = "Adventures-EndCombat-%s";

	if combatWon then
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
		local kit = covenantData and covenantData.textureKit or "Kyrian";
		self.CombatCompleteSuccessFrame.CovenantCrest:SetAtlas(adventuresEmblemFormat:format(kit), true);
		self:ShowCombatCompleteSuccessPanel();
	else
		self.CombatCompleteSuccessFrame.CovenantCrest:SetAtlas(adventuresEmblemFormat:format("Fail"), true);
		self:ShowCombatCompleteSuccessPanel();
	end
	self:Show();
end

function AdventuresRewardsScreenMixin:ShowRewardsScreen(missionInfo)
	self.missionInfo = missionInfo;
	
	self.FinalRewardsPanel.MissionName:SetText(missionInfo.name);
	self:SetRewards(missionInfo.rewards);

	self:ShowFinalRewardsPanel();
end

function AdventuresRewardsScreenMixin:HideAllPanels()
	self.CombatCompleteSuccessFrame:Hide();
	self.TreasureChestFrame:Hide();
	self.FinalRewardsPanel:Hide();
end

function AdventuresRewardsScreenMixin:ShowCombatCompleteSuccessPanel()
	self.CombatCompleteSuccessFrame:Show();
	self.TreasureChestFrame:Hide();
	self.FinalRewardsPanel:Hide();
end

function AdventuresRewardsScreenMixin:ShowTreasureChestPanel()
	self.CombatCompleteSuccessFrame:Hide();
	self.TreasureChestFrame:Show();
	self.FinalRewardsPanel:Hide();
end

function AdventuresRewardsScreenMixin:ShowFinalRewardsPanel() 
	self.CombatCompleteSuccessFrame:Hide();
	self.TreasureChestFrame:Hide();
	self.FinalRewardsPanel:Show();
end

function AdventuresRewardsScreenMixin:SetRewards(rewards)
	self.rewardsPool:ReleaseAll();
	for i, reward in ipairs(rewards) do 
		local rewardFrame = self.rewardsPool:Acquire();
		rewardFrame.layoutIndex = i;
		local currencyMultipliers = {}; --Automissions do not have currency multipliers
		GarrisonMissionButton_SetReward(rewardFrame, reward, currencyMultipliers);
		rewardFrame:Show();
	end

	self.FinalRewardsPanel.SpoilsFrame.RewardsEarnedFrame:Layout();
	self.FinalRewardsPanel.SpoilsFrame:Layout();
	self.FinalRewardsPanel.RewardsEarnedLabel:SetPoint("BOTTOM", self.FinalRewardsPanel.SpoilsFrame.RewardsEarnedFrame, "TOP", 0, 0);
end

function AdventuresRewardsScreenMixin:PopulateFollowerInfo(followerInfo)
	self.followerPool:ReleaseAll();
	self.FinalRewardsPanel.FollowerProgressLabel:Hide();

	local layoutIndex = 1;
	for guid, info in pairs(followerInfo) do 
		--Don't show followers that don't have experience to gain
		if followerInfo.maxXP and followerInfo.maxXP ~= 0 then
			local followerFrame = self.followerPool:Acquire();
			followerFrame.layoutIndex = layoutIndex;
			followerFrame.RewardsFollower:SetFollowerInfo(info);
			followerFrame:Show();

			layoutIndex = layoutIndex + 1;
		end
	end

	if layoutIndex > 1 then 
		self.FinalRewardsPanel.SpoilsFrame.FollowerExperienceEarnedFrame:Layout();
		self.FinalRewardsPanel.SpoilsFrame:Layout();
		self.FinalRewardsPanel.FollowerProgressLabel:Show();
	end

	self.FinalRewardsPanel.SpoilsFrame:Layout();
	self.FinalRewardsPanel.FollowerProgressLabel:SetPoint("BOTTOM", self.FinalRewardsPanel.SpoilsFrame.FollowerExperienceEarnedFrame, "TOP", 0, 0);
end

---------------------------------------------------
--	Adventures Rewards Screen Continue Button Mixin	
---------------------------------------------------

AdventuresRewardsScreenContinueButtonMixin = {}

function AdventuresRewardsScreenContinueButtonMixin:OnClick()
	local missionCompleteScreen = self:GetParent():GetParent():GetParent();
	missionCompleteScreen:CloseMissionComplete();
end

---------------------------------------------------
--	Adventures Rewards Follower Mixin	
---------------------------------------------------

AdventuresRewardsFollowerMixin = {}

local ExpGainAnimDuration = 1.3;

function AdventuresRewardsFollowerMixin:SetFollowerInfo(info)
	self.info = info;
	self.PuckBorder:SetAtlas("Adventurers-Followers-Frame");
	self.Portrait:SetTexture(info.portraitIconID);
	CooldownFrame_SetDisplayAsPercentage(self.FollowerExperienceDisplay,  self.info.currentExperience / self.info.maxExperience);
end

function AdventuresRewardsFollowerMixin:UpdateExperience()
	--TODO: Task WOW9-30940 to finish the animations here with proper exp values

	local currentExperience = self.info.currentExperience;
	local maxExperience = self.info.maxExperience;
	local missionExperience = 500; --self.awardedExperience, tbd
	local dinged = false;

	local function ExperienceGainEasingUpdate(elapsedTime, duration)
		local progress = math.min(currentExperience + EasingUtil.InOutQuartic(elapsedTime / duration) * missionExperience, maxExperience);
	
		if progress == maxExperience and not dinged then
			--play level up animation, increment level
			dinged = true;
		end

		CooldownFrame_SetDisplayAsPercentage(self.FollowerExperienceDisplay,  progress / maxExperience);
	end

	local function ExperienceGainOnFinish()
	end

	ScriptAnimationUtil.StartScriptAnimation(self.FollowerExperienceDisplay, ExperienceGainEasingUpdate, ExpGainAnimDuration, ExperienceGainOnFinish);
end