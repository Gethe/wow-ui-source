
-- TODO:: Replace this with the final model scene.
local AdventuresModelSceneID = 343;


AdventuresCompleteScreenMixin = {};

function AdventuresCompleteScreenMixin:OnLoad()
	GarrisonMissionComplete.OnLoad(self);


	self.ModelScene:SetFromModelSceneID(AdventuresModelSceneID);
end

-- Set dynamically.
function AdventuresCompleteScreenMixin:OnUpdate(elapsed)
	self.replayTimeElapsed = self.replayTimeElapsed + (elapsed * self:GetReplaySpeed());
	self:AdvanceReplay();
end

function AdventuresCompleteScreenMixin:OnEvent(event, ...)
	if event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
		self:OnMissionCompleteResponse(...);
	end
end

function AdventuresCompleteScreenMixin:GetFrameFromBoardIndex(boardIndex)
	return self.Stage.Board:GetFrameByBoardIndex(boardIndex);
end

function AdventuresCompleteScreenMixin:SetCurrentMission(mission)
	self.currentMission = mission;

	self.Stage.Board:Reset();

   	self.NextMissionButton:Enable();
   
   	local stage = self.Stage;
   	stage.Board.FollowerContainer:Show();
   	stage.Board.EnemyContainer.FadeOut:Stop();
   	stage.Board.EnemyContainer:Show();

   	local missionInfo = stage.MissionInfo;
   	missionInfo.Title:SetText(mission.name);
   	GarrisonTruncationFrame_Check(missionInfo.Title);
   
   	self.LoadingFrame:Hide();
   
   	self:StopAnims();
   	self.rollCompleted = false;
   
   	-- rare
   	local color = mission.isRare and RARE_MISSION_COLOR or BLACK_FONT_COLOR;
   	local r, g, b = color:GetRGB();
   	local a = 0.4;
   	missionInfo.IconBG:SetVertexColor(r, g, b, a);

   	local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(mission.missionID);
   	missionInfo.MissionType:SetAtlas(mission.typeAtlas, true);
   
   	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
   	for i, encounter in ipairs(encounters) do
   		local encounterFrame = self:GetFrameFromBoardIndex(encounter.boardIndex);
   		encounterFrame.Name:SetText(encounter.name);
		encounterFrame.Name:Show();
   		encounterFrame.displayID = encounter.displayID;
   		GarrisonEnemyPortait_Set(encounterFrame.Portrait, encounter.portraitFileDataID);
   		-- encounterFrame.Elite:Hide();
   	end
   
   	self.pendingXPAwards = { };
   	self.animInfo = {};
   	stage.followers = {};
   	local encounterIndex = 1;
   	for missionFollowerIndex = 1, #mission.followers do
   		local missionCompleteInfo = C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[missionFollowerIndex]);						
   		local followerFrame = self:GetFrameFromBoardIndex(missionCompleteInfo.boardIndex);

   		if followerFrame then
   			followerFrame.followerID = mission.followers[missionFollowerIndex];
   			self:SetFollowerData(followerFrame, missionCompleteInfo.name, missionCompleteInfo.className, missionCompleteInfo.classAtlas, missionCompleteInfo.portraitIconID, missionCompleteInfo.textureKit);
   			local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.followerID);
   			self:SetFollowerLevel(followerFrame, followerInfo);

   			stage.followers[missionFollowerIndex] = {
				displayIDs = missionCompleteInfo.displayIDs,
				height = missionCompleteInfo.height,
				scale = missionCompleteInfo.scale,
				followerID = mission.followers[missionFollowerIndex],
				isTroop = isTroop,
				durability = followerInfo.durability,
				maxDurability = followerInfo.maxDurability
			};
   		end
   	end

   	C_Garrison.MarkMissionComplete(mission.missionID);
end

function AdventuresCompleteScreenMixin:OnMissionCompleteResponse(missionID, canComplete, succeeded, overmaxSucceeded, followerDeaths, autoCombatResult)
	if self.currentMission and self.currentMission.missionID == missionID then
		self.NextMissionButton:Enable();

		if autoCombatResult then
			self:StartMissionReplay(autoCombatResult);
		end

		-- TODO:: We're automatically completing missions temporarily.
		if canComplete then
			C_Garrison.MissionBonusRoll(self.currentMission.missionID);
		end
	end
end

function AdventuresCompleteScreenMixin:StartMissionReplay(autoCombatResult)
	self.AdventuresCombatLog:Clear();
	self.autoCombatResult = autoCombatResult;
	self.replayTimeElapsed = 0;
	self:SetScript("OnUpdate", AdventuresCompleteScreenMixin.OnUpdate);

	local roundIndex = 1;
	self:StartReplayRound(roundIndex);
end

function AdventuresCompleteScreenMixin:GetReplaySpeed()
	return 1.0;
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

	local eventIndex = 1;
	self:StartReplayEvent(roundIndex, eventIndex);
end

function AdventuresCompleteScreenMixin:StartReplayEvent(roundIndex, eventIndex)
	self.replayEventIndex = eventIndex;
	self.eventStartTime = self:GetReplayTimeElapsed();

	local round = self:GetReplayRound(roundIndex);
	local event = round.events[eventIndex];
	self.AdventuresCombatLog:AddCombatEvent(event);
	self:PlayReplayEffect(event);
end

local function GetEffectForEvent(combatLogEvent)
	-- TODO:: Replace this function.
	local eventType = combatLogEvent.type;
	if eventType == Enum.GarrAutoMissionEventType.MeleeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.MeleeAttack;
	elseif eventType == Enum.GarrAutoMissionEventType.RangeDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	elseif eventType == Enum.GarrAutoMissionEventType.SpellDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	elseif eventType == Enum.GarrAutoMissionEventType.PeriodicDamage then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.ShockTarget;
	elseif eventType == Enum.GarrAutoMissionEventType.ApplyAura then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.ShockTarget;
	elseif eventType == Enum.GarrAutoMissionEventType.Heal then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Regrowth;
	elseif eventType == Enum.GarrAutoMissionEventType.PeriodicHeal then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Regrowth;
	elseif eventType == Enum.GarrAutoMissionEventType.Died then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.ShockTarget;
	elseif eventType == Enum.GarrAutoMissionEventType.RemoveAura then
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.ShockTarget;
	else
		return ScriptedAnimationEffectsUtil.NamedEffectIDs.Fireball;
	end
end

function AdventuresCompleteScreenMixin:PlayReplayEffect(combatLogEvent)	
	local effect = GetEffectForEvent(combatLogEvent);
	local function EffectOnFinish()
		self.Stage.Board:AddCombatEventText(combatLogEvent);
	end

	local sourceFrame = self:GetFrameFromBoardIndex(combatLogEvent.casterBoardIndex);
	for i, target in ipairs(combatLogEvent.targetInfo) do
		local targetFrame = self:GetFrameFromBoardIndex(target.boardIndex);
		self.ModelScene:AddEffect(effect, sourceFrame, targetFrame, EffectOnFinish);
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
	self.AdventuresCombatLog:AddVictoryState(self.autoCombatResult.winner);
end

function AdventuresCompleteScreenMixin:GetCovenantMissionFrame()
	return self:GetParent();
end
