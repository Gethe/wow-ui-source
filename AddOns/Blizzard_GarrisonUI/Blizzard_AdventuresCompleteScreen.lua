
local SlowSpeed = 1.0;
local FastSpeed = 2 * SlowSpeed;


AdventuresCompleteScreenContinueButtonMixin = {};

function AdventuresCompleteScreenContinueButtonMixin:OnClick()
	local completeScreen = self:GetParent():GetParent();
	if completeScreen.replayFinished then 
		completeScreen:ShowRewardsScreen();
	else
		completeScreen:SkipToTheEndOfMission();
	end
end


AdventuresCompleteScreenSpeedButtonMixin = {};

function AdventuresCompleteScreenSpeedButtonMixin:OnClick()
	local completeScreen = self:GetParent():GetParent();
	completeScreen:ToggleReplaySpeed();
end

function AdventuresCompleteScreenSpeedButtonMixin:SetSpeedUpShown(shown)
	self.SpeedUp:SetShown(shown);
end

AdventuresCompleteScreenReplayButtonMixin = {};

function AdventuresCompleteScreenReplayButtonMixin:OnClick()
	local completeScreen = self:GetParent():GetParent();
	completeScreen:ResetReplay();
end


AdventuresCompleteScreenMixin = {};

local AdventuresCompleteScreenEvents = {
	"GARRISON_MISSION_COMPLETE_RESPONSE",
};

function AdventuresCompleteScreenMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AdventuresCompleteScreenEvents);
end

function AdventuresCompleteScreenMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AdventuresCompleteScreenEvents);
end

function AdventuresCompleteScreenMixin:OnLoad()
	GarrisonMissionComplete.OnLoad(self);

	self.replaySpeed = SlowSpeed;

	self.ModelScene:SetEffectSpeed(self.replaySpeed);
end

function AdventuresCompleteScreenMixin:UpdateMissionReplay(elapsed)
	self.replayTimeElapsed = self.replayTimeElapsed + (elapsed * self:GetReplaySpeed());
	self:AdvanceReplay();
end

function AdventuresCompleteScreenMixin:OnEvent(event, ...)
	if event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
		self:OnMissionCompleteResponse(...);
	end
end

function AdventuresCompleteScreenMixin:SetAnimationControl()
end

function AdventuresCompleteScreenMixin:ShowRewardsScreen()
	if self.currentMission then
		self.RewardsScreen:ShowRewardsScreen(self.currentMission);

		self:DisableCompleteFrameButtons();
	end
end

function AdventuresCompleteScreenMixin:CloseMissionComplete()
	if self.currentMission then
		C_Garrison.MissionBonusRoll(self.currentMission.missionID);
	end
	
	self:GetCovenantMissionFrame():CloseMissionComplete();
end

function AdventuresCompleteScreenMixin:GetFrameFromBoardIndex(boardIndex)
	return self.Board:GetFrameByBoardIndex(boardIndex);
end

function AdventuresCompleteScreenMixin:SetCurrentMission(mission)
	self.currentMission = mission;
   	self.missionEncounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);

   	self.followerGUIDToInfo = {};
   	for i, followerGUID in ipairs(mission.followers) do
   		self.followerGUIDToInfo[followerGUID] = C_Garrison.GetFollowerMissionCompleteInfo(followerGUID);	
   	end

   	self:ResetMissionDisplay();
	self.RewardsScreen:PopulateFollowerInfo(self.followerGUIDToInfo);

	if not mission.completed then
   		C_Garrison.MarkMissionComplete(self.currentMission.missionID);
	else
		C_Garrison.RegenerateCombatLog(self.currentMission.missionID);
	end
end

function AdventuresCompleteScreenMixin:ResetMissionDisplay()
	local mission = self.currentMission;

   	local board = self.Board;
   	board:Reset();

   	local missionInfo = self.MissionInfo;
   	missionInfo.Title:SetText(mission.name);
   	GarrisonTruncationFrame_Check(missionInfo.Title);
   
   	-- rare
   	local color = mission.isRare and RARE_MISSION_COLOR or BLACK_FONT_COLOR;
   	local r, g, b = color:GetRGB();
   	local a = 0.4;
   	missionInfo.IconBG:SetVertexColor(r, g, b, a);

   	missionInfo.MissionType:SetAtlas(mission.typeAtlas, true);
   
   	for i, encounter in ipairs(self.missionEncounters) do
   		local encounterFrame = self:GetFrameFromBoardIndex(encounter.boardIndex);
   		encounterFrame:SetEncounter(encounter);
   		encounterFrame:Show();
   	end
   
   	local encounterIndex = 1;
   	for i, followerGUID in ipairs(mission.followers) do
   		local missionCompleteInfo = self.followerGUIDToInfo[followerGUID];			
   		local followerFrame = self:GetFrameFromBoardIndex(missionCompleteInfo.boardIndex);
		followerFrame:SetFollowerGUID(followerGUID, missionCompleteInfo);
		followerFrame:Show();
   	end

	self.AdventuresCombatLog:Clear();
	self.RewardsScreen:Reset();
	self.CompleteFrame.ContinueButton:SetText(CONTINUE);
	self.replayFinished = false;
	self:EnableCompleteFrameButtons();
end

function AdventuresCompleteScreenMixin:OnMissionCompleteResponse(missionID, canComplete, succeeded, overmaxSucceeded, followerDeaths, autoCombatResult)
	if self.currentMission and self.currentMission.missionID == missionID then
		self.autoCombatResult = autoCombatResult;
		if autoCombatResult then
			self:StartMissionReplay();
		end
	end
end

function AdventuresCompleteScreenMixin:ResetReplay()
	self.ModelScene:ClearEffects();
	self:ResetMissionDisplay();
	self:StartMissionReplay();
end

function AdventuresCompleteScreenMixin:StartMissionReplay()
	self.CompleteFrame.ReplayButton:SetEnabled(false);
	self:SetReplaySpeed(SlowSpeed);

	self.AdventuresCombatLog:Clear();
	self.replayTimeElapsed = 0;
	self.replayRoundIndex = 1;
	self:SetScript("OnUpdate", AdventuresCompleteScreenMixin.UpdateMissionReplay);

	local roundIndex = 1;
	self:StartReplayRound(roundIndex);
end

function AdventuresCompleteScreenMixin:GetReplaySpeed()
	return self.replaySpeed;
end

function AdventuresCompleteScreenMixin:ToggleReplaySpeed()
	if self.replaySpeed > SlowSpeed then
		self:SetReplaySpeed(SlowSpeed);
	else
		self:SetReplaySpeed(FastSpeed);
	end
end

function AdventuresCompleteScreenMixin:SetReplaySpeed(replaySpeed)
	self.replaySpeed = replaySpeed;

	self.ModelScene:SetEffectSpeed(replaySpeed);

	self.CompleteFrame.SpeedButton:SetSpeedUpShown(self:IsReplaySpeedFast());
end

function AdventuresCompleteScreenMixin:IsReplaySpeedFast()
	return self.replaySpeed > SlowSpeed;
end

function AdventuresCompleteScreenMixin:GetReplayRound(roundIndex)
	return self.autoCombatResult.combatLog[roundIndex];
end

function AdventuresCompleteScreenMixin:GetNumReplayRounds()
	return #self.autoCombatResult.combatLog;
end

function AdventuresCompleteScreenMixin:GetReplayTimeElapsed()
	return self.replayTimeElapsed;
end

function AdventuresCompleteScreenMixin:IsReplayEventFinished()
	if self.replayEffectInProgress then
		return false;
	end
	
	local replayTimeElapsed = self:GetReplayTimeElapsed();
	if self.replayEffectResolutionTime then
		local timeSinceResolution = replayTimeElapsed - self.replayEffectResolutionTime;
		return timeSinceResolution > 0.2;
	end

	local eventTime = replayTimeElapsed - self.eventStartTime;
	return eventTime > 0.5;
end

function AdventuresCompleteScreenMixin:StartReplayRound(roundIndex)
	self.replayRoundIndex = roundIndex;
	self.roundStartTime = self:GetReplayTimeElapsed();
	self.AdventuresCombatLog:AddCombatRoundHeader(roundIndex, self:GetNumReplayRounds());
	self.Board:UpdateCooldownsFromNewRound();

	local eventIndex = 1;
	self:StartReplayEvent(roundIndex, eventIndex);
end

function AdventuresCompleteScreenMixin:StartReplayEvent(roundIndex, eventIndex)
	self.replayEventIndex = eventIndex;
	self.eventStartTime = self:GetReplayTimeElapsed();

	local round = self:GetReplayRound(roundIndex);
	local event = round.events[eventIndex];
	self.AdventuresCombatLog:AddCombatEvent(event);
	self.Board:UpdateCooldownsFromEvent(event);
	self:PlayReplayEffect(event);
end

local AdventuresDamageClass = {
	Enum.Damageclass.Physical,
	Enum.Damageclass.Holy,
	Enum.Damageclass.Fire,
	Enum.Damageclass.Nature,
	Enum.Damageclass.Frost,
	Enum.Damageclass.Shadow,
	Enum.Damageclass.Arcane,
};

local function GetTypeFromSchoolMask(schoolMask)
	for i = #AdventuresDamageClass, 1, -1 do 
		local spellClass = AdventuresDamageClass[i];
		local spellClassMask = bit.lshift(1, spellClass);
		if bit.band(schoolMask, spellClassMask) == spellClassMask then
			return spellClass;
		end
	end

	return Enum.Damageclass.Physical;
end

local AdventuresEffects = {
	Ranged = {
		[Enum.Damageclass.Physical] = 7,
		-- [Enum.Damageclass.Holy] = nil,
		[Enum.Damageclass.Fire] = 1,
		[Enum.Damageclass.Nature] = 6,
		[Enum.Damageclass.Frost] = 9,
		[Enum.Damageclass.Shadow] = 4,
		[Enum.Damageclass.Arcane] = 10,
	},

	Melee = {
		[Enum.Damageclass.Physical] = 12,
		[Enum.Damageclass.Holy] = 19,
		-- [Enum.Damageclass.Fire] = nil,
		-- [Enum.Damageclass.Nature] = nil,
		-- [Enum.Damageclass.Frost] = nil,
		[Enum.Damageclass.Shadow] = 20,
		-- [Enum.Damageclass.Arcane] = nil,
	},

	Heal = 3,
};

local function GetEffectForEvent(combatLogEvent)
	local eventType = combatLogEvent.type;
	local spellClass = GetTypeFromSchoolMask(combatLogEvent.schoolMask);
	if eventType == Enum.GarrAutoMissionEventType.MeleeDamage or eventType == Enum.GarrAutoMissionEventType.SpellMeleeDamage then
		return AdventuresEffects.Melee[spellClass];
	elseif eventType == Enum.GarrAutoMissionEventType.RangeDamage or eventType == Enum.GarrAutoMissionEventType.SpellRangeDamage then
		return AdventuresEffects.Ranged[spellClass];
	elseif eventType == Enum.GarrAutoMissionEventType.Heal or eventType == Enum.GarrAutoMissionEventType.PeriodicHeal then
		return AdventuresEffects.Heal;
	-- elseif eventType == Enum.GarrAutoMissionEventType.PeriodicDamage then
	end

	return nil;
end

function AdventuresCompleteScreenMixin:PlayReplayEffect(combatLogEvent)
	self.replayEffectResolutionTime = nil;

	local noTargets = #combatLogEvent.targetInfo == 0;
	if noTargets then
		return;
	end

	local effect = GetEffectForEvent(combatLogEvent);
	if effect then
		self.replayEffectInProgress = true;

		local sourceBoardIndex = combatLogEvent.casterBoardIndex;
		local sourceFrame = self:GetFrameFromBoardIndex(sourceBoardIndex);
		self.Board:RaiseFrameByBoardIndex(sourceBoardIndex);

		local effectInfo = ScriptedAnimationEffectsUtil.GetEffectByID(effect);
		local secondaryEffect = effectInfo and effectInfo.finishEffectID or nil;

		local function AddCombatText(effectSequenceIndex)
			self.Board:AddCombatEventText(combatLogEvent);
			return false;
		end

		-- If there's a secondary effect, then play the primary effect on the primary target, and 
		-- the secondary effect on all targets. Otherwise, play the primary effect on all targets together.
		if secondaryEffect then
			local function PrimaryEffectOnFinish(effectSequenceIndex)
				AddCombatText(effectSequenceIndex);

				local effectInfo = ScriptedAnimationEffectsUtil.GetEffectByID(effect);
				local secondaryEffect = effectInfo and effectInfo.finishEffectID or nil;
				if secondaryEffect then
					for i = 2, #combatLogEvent.targetInfo do
						local boardIndex = combatLogEvent.targetInfo[i].boardIndex;
						local targetFrame = self:GetFrameFromBoardIndex(boardIndex);
						self.ModelScene:AddEffect(secondaryEffect, sourceFrame, targetFrame);
					end
				end

				return false;
			end

			local function EffectOnResolution()
				self:OnReplayEffectResolved();
			end
			
			local primaryTarget = self:GetFrameFromBoardIndex(combatLogEvent.targetInfo[1].boardIndex);
			self.ModelScene:AddEffect(effect, sourceFrame, primaryTarget, PrimaryEffectOnFinish, EffectOnResolution);
		else
			local resolutionCount = #combatLogEvent.targetInfo;
			local function MultiEffectOnResolution()
				resolutionCount = resolutionCount - 1;
				if resolutionCount == 0 then
					self:OnReplayEffectResolved();
				end
			end
			for i, target in ipairs(combatLogEvent.targetInfo) do
				local targetFrame = self:GetFrameFromBoardIndex(target.boardIndex);
				local effectOnFinish = (i == 1) and AddCombatText or nil; -- The first effect adds an aggregate combat log event.
				self.ModelScene:AddEffect(effect, sourceFrame, targetFrame, effectOnFinish, MultiEffectOnResolution);
			end
		end
	else
		self.Board:AddCombatEventText(combatLogEvent);
	end
end

function AdventuresCompleteScreenMixin:OnReplayEffectResolved()
	self.replayEffectInProgress = nil;
	self.replayEffectResolutionTime = self:GetReplayTimeElapsed();
end

function AdventuresCompleteScreenMixin:AdvanceReplay()
	local currentRound = self:GetReplayRound(self.replayRoundIndex);
	if self:IsReplayEventFinished() then
		if self.replayEventIndex < #currentRound.events then
			self:StartReplayEvent(self.replayRoundIndex, self.replayEventIndex + 1);
		elseif self.replayRoundIndex < self:GetNumReplayRounds() then
			self:StartReplayRound(self.replayRoundIndex + 1);
		else
			self:FinishReplay();
		end
	end
end

function AdventuresCompleteScreenMixin:FinishReplay()
	self:SetScript("OnUpdate", nil);
	self.CompleteFrame.ReplayButton:SetEnabled(true);
	self.AdventuresCombatLog:AddVictoryState(self.autoCombatResult.winner);
	self.RewardsScreen:ShowAdventureVictoryStateScreen(self.autoCombatResult.winner);
	self.replayFinished = true;
	self.CompleteFrame.ContinueButton:SetText(COVENANT_MISSIONS_COMPLETE_SCREEN_REWARDS);
end

function AdventuresCompleteScreenMixin:SkipToTheEndOfMission()
	self.ModelScene:ClearEffects();
	
	--Finish current round
	local currentRound = self:GetReplayRound(self.replayRoundIndex);
	--Previous eventIndex already printed
	for eventIndex = self.replayEventIndex + 1, #currentRound.events do
		self.AdventuresCombatLog:AddCombatEvent(currentRound.events[eventIndex]);
	end

	--dump the rest
	for roundIndex = self.replayRoundIndex + 1, self:GetNumReplayRounds() do 
		local round = self:GetReplayRound(roundIndex);
		self.AdventuresCombatLog:AddCombatRound(roundIndex, round, self:GetNumReplayRounds());
	end

	self:FinishReplay();
end

function AdventuresCompleteScreenMixin:GetCovenantMissionFrame()
	return self:GetParent();
end

function AdventuresCompleteScreenMixin:DisableCompleteFrameButtons()
	local completeFrame = self.CompleteFrame;

	completeFrame.ContinueButton:Disable();
	completeFrame.SpeedButton:Disable();
	completeFrame.ReplayButton:Disable();
end


function AdventuresCompleteScreenMixin:EnableCompleteFrameButtons()
	local completeFrame = self.CompleteFrame;

	completeFrame.ContinueButton:Enable();
	completeFrame.SpeedButton:Enable();
	completeFrame.ReplayButton:Enable();
end