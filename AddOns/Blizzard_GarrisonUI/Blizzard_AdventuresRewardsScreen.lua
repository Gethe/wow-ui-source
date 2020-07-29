AdventuresRewardsScreenMixin = {};

local followerXPTable = {};

function AdventuresRewardsScreenMixin:OnLoad() 
	followerXPTable = C_Garrison.GetFollowerXPTable(Enum.GarrisonFollowerType.FollowerType_9_0);
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
	self.FinalRewardsPanel:Hide();
end

function AdventuresRewardsScreenMixin:ShowCombatCompleteSuccessPanel()
	self.CombatCompleteSuccessFrame:Show();
	self.FinalRewardsPanel:Hide();
end

function AdventuresRewardsScreenMixin:ShowFinalRewardsPanel() 
	self.CombatCompleteSuccessFrame:Hide();
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

function AdventuresRewardsScreenMixin:PopulateFollowerInfo(followerInfo, missionInfo)
	self.followerPool:ReleaseAll();
	self.FinalRewardsPanel.FollowerProgressLabel:Hide();
	
	local layoutIndex = 1;
	for guid, info in pairs(followerInfo) do 
		--Don't show followers that don't have experience to gain
		if info.maxXP and info.maxXP ~= 0 then
			local followerFrame = self.followerPool:Acquire();
			followerFrame.layoutIndex = layoutIndex;
			followerFrame.RewardsFollower:SetFollowerInfo(info, missionInfo.xp);
			followerFrame:Show();

			layoutIndex = layoutIndex + 1;
		end
	end

	self.FinalRewardsPanel.SpoilsFrame.FollowerExperienceEarnedFrame:SetShown(layoutIndex > 1);
	if layoutIndex > 1 then 
		local largePaddingForText = 80;
		local smallPaddingToFit = 30;

		self.FinalRewardsPanel.SpoilsFrame.FollowerExperienceEarnedFrame:Layout();
		self.FinalRewardsPanel.FollowerProgressLabel:Show();
		self.FinalRewardsPanel.SpoilsFrame.spacing = layoutIndex > 4 and smallPaddingToFit or largePaddingForText;
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

local ExpGainAnimDuration = 1.7;

function AdventuresRewardsFollowerMixin:SetFollowerInfo(info, xp)
	self:SetupPortrait(info);
	self.xp = xp;
	self.LevelUpAnimFrame:Hide();
	if self.info.maxXP ~= 0 then 
		CooldownFrame_SetDisplayAsPercentage(self.FollowerExperienceDisplay,  self.info.currentXP / self.info.maxXP);
	end
end

function AdventuresRewardsFollowerMixin:UpdateExperience()
	local currentExperience = self.info.currentXP;
	local maxExperience = self.info.maxXP;
	local missionExperience = self.xp;
	local storedExperience = 0;
	local totalLevelUps = 0;
	self.XPFloatingText.Text:SetFormattedText(XP_GAIN, missionExperience);

	local function ExperienceGainEasingUpdate(elapsedTime, duration)
		local progress = math.min(currentExperience - storedExperience + EasingUtil.InOutQuartic(elapsedTime / duration) * missionExperience, maxExperience);
		
		if progress == maxExperience and maxExperience ~= 0 then
			--play level up animation, increment level
			self.LevelUpAnimFrame.Anim:Stop(); --in case there's one playing already
			self.LevelUpAnimFrame:Show();
			self.LevelUpAnimFrame.Anim:Play();
			
			storedExperience = storedExperience + progress;
			totalLevelUps = totalLevelUps + 1;
			
			maxExperience = followerXPTable[self.info.level + totalLevelUps];
			self.LevelDisplayFrame.LevelText:SetText(self.info.level + totalLevelUps);
			progress = 0;
		end

		CooldownFrame_SetDisplayAsPercentage(self.FollowerExperienceDisplay,  progress / maxExperience);
	end

	local function StartExperienceAnimation()
		if not self:IsVisible() then
			return;
		end
		
		self.XPFloatingText.FadeIn:Play();
		local onFinish = nil;
		ScriptAnimationUtil.StartScriptAnimation(self.FollowerExperienceDisplay, ExperienceGainEasingUpdate, ExpGainAnimDuration, onFinish);
	end

	C_Timer.After(self:GetParent().layoutIndex / 2, StartExperienceAnimation);
end