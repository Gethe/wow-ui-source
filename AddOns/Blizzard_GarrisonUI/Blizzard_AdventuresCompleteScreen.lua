
-- TODO:: Replace this with the final model scene.
local AdventuresModelSceneID = 343;

local SlowSpeed = 1.0;
local FastSpeed = 2 * SlowSpeed;


AdventuresCompleteScreenContinueButtonMixin = {};

function AdventuresCompleteScreenContinueButtonMixin:OnClick()
	local completeScreen = self:GetParent():GetParent();
	completeScreen:CloseMissionComplete();
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

	self.ModelScene:SetFromModelSceneID(AdventuresModelSceneID);
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

   	C_Garrison.MarkMissionComplete(self.currentMission.missionID);

   	-- TEMP:: Claim rewards so the mission disappears.
   	C_Garrison.MissionBonusRoll(self.currentMission.missionID);
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

function AdventuresCompleteScreenMixin:IsReplayEventFinished(round, eventIndex, eventTime)
	return eventTime > 1.0;
end

function AdventuresCompleteScreenMixin:StartReplayRound(roundIndex)
	self.replayRoundIndex = roundIndex;
	self.roundStartTime = self:GetReplayTimeElapsed();
	self.AdventuresCombatLog:AddCombatRoundHeader(roundIndex);
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

local function GetEffectForEvent(combatLogEvent)
	-- TODO:: Replace this function.
	local eventType = combatLogEvent.type;
	if eventType == Enum.GarrAutoMissionEventType.MeleeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.MeleeAttack;
	elseif eventType == Enum.GarrAutoMissionEventType.RangeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	elseif eventType == Enum.GarrAutoMissionEventType.SpellMeleeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	elseif eventType == Enum.GarrAutoMissionEventType.SpellRangeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	elseif eventType == Enum.GarrAutoMissionEventType.PeriodicDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.ShockTarget;
	elseif eventType == Enum.GarrAutoMissionEventType.Heal then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Regrowth;
	elseif eventType == Enum.GarrAutoMissionEventType.PeriodicHeal then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Regrowth;
	end

	return nil;
end

function AdventuresCompleteScreenMixin:PlayReplayEffect(combatLogEvent)	
	local effect = GetEffectForEvent(combatLogEvent);
	if effect then
		local function EffectOnFinish()
			self.Board:AddCombatEventText(combatLogEvent);
		end

		local sourceFrame = self:GetFrameFromBoardIndex(combatLogEvent.casterBoardIndex);
		for i, target in ipairs(combatLogEvent.targetInfo) do
			local targetFrame = self:GetFrameFromBoardIndex(target.boardIndex);
			self.ModelScene:AddEffect(effect, sourceFrame, targetFrame, EffectOnFinish);
		end
	else
		self.Board:AddCombatEventText(combatLogEvent);
	end
end

function AdventuresCompleteScreenMixin:AdvanceReplay()
	local replayTimeElapsed = self:GetReplayTimeElapsed();
	local currentRound = self:GetReplayRound(self.replayRoundIndex);
	local eventTime = replayTimeElapsed - self.eventStartTime;
	if self:IsReplayEventFinished(currentRound, self.replayEventIndex, eventTime) then
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
end

function AdventuresCompleteScreenMixin:GetCovenantMissionFrame()
	return self:GetParent();
end
