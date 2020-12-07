
local EnemyOrder = {
	Enum.GarrAutoBoardIndex.EnemyLeftBack,
	Enum.GarrAutoBoardIndex.EnemyCenterLeftBack,
	Enum.GarrAutoBoardIndex.EnemyCenterRightBack,
	Enum.GarrAutoBoardIndex.EnemyRightBack,
	Enum.GarrAutoBoardIndex.EnemyLeftFront,
	Enum.GarrAutoBoardIndex.EnemyCenterLeftFront,
	Enum.GarrAutoBoardIndex.EnemyCenterRightFront,
	Enum.GarrAutoBoardIndex.EnemyRightFront,
};

local FollowerOrder = {
	Enum.GarrAutoBoardIndex.AllyLeftFront,
	Enum.GarrAutoBoardIndex.AllyCenterFront,
	Enum.GarrAutoBoardIndex.AllyRightFront,
	Enum.GarrAutoBoardIndex.AllyLeftBack,
	Enum.GarrAutoBoardIndex.AllyRightBack,
};

local BackFollowerPositions = {
	Enum.GarrAutoBoardIndex.AllyLeftBack,
	Enum.GarrAutoBoardIndex.AllyRightBack,
};

local EnemySocketAtlasNames = {
	"Adventures-Mission-Enemy-Socket-01",
	"Adventures-Mission-Enemy-Socket-02",
	"Adventures-Mission-Enemy-Socket-03",
	"Adventures-Mission-Enemy-Socket-04",
};

local FollowerSocketAtlasNames = {
	"Adventures-Mission-Follower-Socket-01",
	"Adventures-Mission-Follower-Socket-02",
	"Adventures-Mission-Follower-Socket-03",
	"Adventures-Mission-Follower-Socket-04",
}


AdventuresBoardMixin = {};

function AdventuresBoardMixin:OnLoad()
	self.framesByBoardIndex = {};
	self.socketsByBoardIndex = {};
	self.enemyFramePool = CreateFramePool("FRAME", self.EnemyContainer, self.enemyTemplate);
	self.followerFramePool = CreateFramePool("FRAME", self.FollowerContainer, self.followerTemplate);
	self.enemySocketFramePool = CreateFramePool("FRAME", self, self.enemySocketTemplate);
	self.followerSocketFramePool = CreateFramePool("FRAME", self, self.followerSocketTemplate);
	
	self.socketTexturePool = CreateTexturePool(self, "BACKGROUND");

	self:CreateEnemyFrames();
	self:CreateFollowerFrames();
end

function AdventuresBoardMixin:OnShow()
	if not self.containerLayoutUpdated then
		self.FollowerContainer:Layout();
		self.EnemyContainer:Layout();
		self.containerLayoutUpdated = true;
	end
end

function AdventuresBoardMixin:GetMainFrame()
	return self:GetParent():GetParent():GetParent();
end

function AdventuresBoardMixin:GetFrameByBoardIndex(boardIndex)
	return self.framesByBoardIndex[boardIndex];
end

function AdventuresBoardMixin:GetSocketByBoardIndex(boardIndex)
	return self.socketsByBoardIndex[boardIndex];
end

function AdventuresBoardMixin:Reset()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		if enemyFrame.Reset then
			enemyFrame:Reset();
		end
		enemyFrame:Hide();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		if followerFrame.Reset then
			followerFrame:Reset();
		end
		followerFrame:Hide();
	end
end

function AdventuresBoardMixin:EnumerateEnemies()
	return self.enemyFramePool:EnumerateActive();
end

function AdventuresBoardMixin:EnumerateFollowers()
	return self.followerFramePool:EnumerateActive();
end

function AdventuresBoardMixin:EnumerateFollowerSockets()
	return self.followerSocketFramePool:EnumerateActive();
end

function AdventuresBoardMixin:RegisterFrame(boardIndex, socket, frame)
	self.framesByBoardIndex[boardIndex] = frame;
	self.socketsByBoardIndex[boardIndex] = socket;
end

function AdventuresBoardMixin:GenerateFactoryFunction(puckFramePool, socketFramePool, boardIndices, socketContainer, socketAtlasCollection)
	local function CreateNewFrame(index)
		local newSocket = socketFramePool:Acquire();
		local useAtlasSize = true;
		newSocket.SocketTexture:SetAtlas(socketAtlasCollection[mod(index, #socketAtlasCollection) + 1], useAtlasSize);
		newSocket:SetParent(socketContainer);
		newSocket:Show();

		local newFrame = puckFramePool:Acquire();
		newFrame.boardIndex = boardIndices[index];
		self:RegisterFrame(newFrame.boardIndex, newSocket, newFrame);
		newFrame:SetPoint("CENTER", newSocket, "CENTER");
		newFrame:Show();

		return newSocket;
	end

	return CreateNewFrame;
end

function AdventuresBoardMixin:CreateEnemyFrames()
	if self.enemyFramesCreated then
		return;
	end

	self.enemyFramesCreated = true;

	local boardIndices = EnemyOrder;
	local createNewEnemy = self:GenerateFactoryFunction(self.enemyFramePool, self.enemySocketFramePool, boardIndices, self.EnemyContainer, EnemySocketAtlasNames);

	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.EnemyContainer, "TOPLEFT", 0, 0);

	local direction = nil;
	local stride = 4;
	local paddingX = 50;
	local paddingY = 28;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);

	AnchorUtil.GridLayoutFactoryByCount(createNewEnemy, #boardIndices, initialAnchor, layout);
end

function AdventuresBoardMixin:CreateFollowerFrames()
	if self.followerFramesCreated then
		return;
	end

	self.followerFramesCreated = true;

	local boardIndices = FollowerOrder;
	local createNewFollower = self:GenerateFactoryFunction(self.followerFramePool, self.followerSocketFramePool, boardIndices, self.FollowerContainer, FollowerSocketAtlasNames);

	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.FollowerContainer, "TOPLEFT", 0, 0);

	local direction = nil;
	local stride = 3;
	local paddingX = 30;
	local paddingY = 10;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);

	AnchorUtil.GridLayoutFactoryByCount(createNewFollower, #boardIndices, initialAnchor, layout);

	local backRowAdjustment = nil;
	for i, position in ipairs(BackFollowerPositions) do
		local followerSocket = self:GetSocketByBoardIndex(position);
		backRowAdjustment = backRowAdjustment or ((followerSocket:GetWidth() + paddingX) / 2);
		followerSocket:AdjustPointsOffset(backRowAdjustment, 0);
	end
end

function AdventuresBoardMixin:ResetFrameLevels()
	local baseEnemyFrameLevel = self.EnemyContainer:GetFrameLevel() + 1;
	for enemyFrame in self:EnumerateEnemies() do
		enemyFrame:SetFrameLevel(baseEnemyFrameLevel);
	end

	local baseFollowerFrameLevel = self.FollowerContainer:GetFrameLevel() + 1;
	for followerFrame in self:EnumerateFollowers() do
		followerFrame:SetFrameLevel(baseFollowerFrameLevel);
	end
end

function AdventuresBoardMixin:RaiseFrameByBoardIndex(boardIndex)
	self:ResetFrameLevels();

	local frame = self:GetFrameByBoardIndex(boardIndex);
	frame:SetFrameLevel(frame:GetFrameLevel() + 50);
end

function AdventuresBoardMixin:GetAnimFrameByAuraType(frame, previewType)
	if bit.band(previewType, Enum.GarrAutoPreviewTargetType.Damage) == Enum.GarrAutoPreviewTargetType.Damage then
		return frame.EnemyTargetingIndicatorFrame;
	elseif bit.band(previewType, Enum.GarrAutoPreviewTargetType.Buff) == Enum.GarrAutoPreviewTargetType.Buff or bit.band(previewType, Enum.GarrAutoPreviewTargetType.Heal) == Enum.GarrAutoPreviewTargetType.Heal then
		if frame.FriendlyTargetingIndicatorFrame then
			frame.FriendlyTargetingIndicatorFrame.SupportColorationAnimator:SetPreviewTargets(previewType, {frame.FriendlyTargetingIndicatorFrame.TargetMarker});
		end
		return frame.FriendlyTargetingIndicatorFrame;
	end

	return nil;
end

function AdventuresBoardMixin:TriggerTargetingReticles(targetInfos, useLoop)
	for _, target in ipairs(targetInfos) do
		local targetingIndex = target.targetIndex
		local frameToPlayAnimation;
		if targetingIndex >= Enum.GarrAutoBoardIndex.EnemyLeftFront and targetingIndex <= Enum.GarrAutoBoardIndex.EnemyRightBack then
			local enemyFrame = self:GetFrameByBoardIndex(targetingIndex);
			frameToPlayAnimation = enemyFrame:IsShown() and enemyFrame or self:GetSocketByBoardIndex(targetingIndex);
		else
			frameToPlayAnimation = self:GetSocketByBoardIndex(targetingIndex);
		end
		
		local animationFrame = self:GetAnimFrameByAuraType(frameToPlayAnimation, target.previewType);
		if animationFrame then
			if useLoop then 
				animationFrame:Loop();

				if bit.band(target.previewType, bit.bor(Enum.GarrAutoPreviewTargetType.Buff, Enum.GarrAutoPreviewTargetType.Heal)) ~= 0 then
					local frameToAddTempEffect = self:GetSocketByBoardIndex(targetingIndex);
					frameToAddTempEffect:SetTempPreviewType(target.previewType);
				end
			else
				animationFrame:Play();
			end
		end
	end
end

function AdventuresBoardMixin:GetHoverTargetingBoardIndex(placerFrame)
	for followerFrame in self:EnumerateFollowers() do
		if followerFrame:IsMouseOver() then
			return followerFrame.boardIndex;
		end
	end

	return nil;
end

function AdventuresBoardMixin:UpdateBoardState(boardTargetInfo)
	for followerSocket in self:EnumerateFollowerSockets() do 
		followerSocket:ClearActiveAndRefresh();
	end

	for _, target in ipairs(boardTargetInfo) do
		local targetingIndex = target.targetIndex
		if targetingIndex >= Enum.GarrAutoBoardIndex.AllyLeftBack and targetingIndex <= Enum.GarrAutoBoardIndex.AllyRightFront then
			local targetFrame = self:GetSocketByBoardIndex(targetingIndex); 
			targetFrame:SetBoardPreviewState(target.previewType);
		end
	end
end

function AdventuresBoardMixin:ShowAssignmentTutorial()
	if not GetCVarBitfield("covenantMissionTutorial", Enum.GarrAutoCombatTutorial.PlaceCompanion) then
		for followerSocket in self:EnumerateFollowerSockets() do
			followerSocket.TutorialRing:Show();
		end

		local helpTipInfo = {
			text = COVENANT_MISSIONS_TUTORIAL_ASSIGNMENT,
			buttonStyle = HelpTip.ButtonStyle.None,
			cvarBitfield = "covenantMissionTutorial",
			bitfieldFlag = Enum.GarrAutoCombatTutorial.PlaceCompanion,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = 5,
			offsetY = 0,
			checkCVars = true,
		}

		HelpTip:Show(self.FollowerContainer, helpTipInfo);
	end
end

function AdventuresBoardMixin:HideAssignmentTutorial()
	if not GetCVarBitfield("covenantMissionTutorial", Enum.GarrAutoCombatTutorial.PlaceCompanion) then
		for followerSocket in self:EnumerateFollowerSockets() do
			followerSocket.TutorialRing:Hide();
		end

		HelpTip:Acknowledge(self.FollowerContainer, COVENANT_MISSIONS_TUTORIAL_ASSIGNMENT);
	end
end

function AdventuresBoardMixin:ShowHealthValues()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		enemyFrame:ShowHealthValues();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		followerFrame:ShowHealthValues();
	end
end

function AdventuresBoardMixin:HideHealthValues()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		enemyFrame:HideHealthValues();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		followerFrame:HideHealthValues();
	end
end

function AdventuresBoardMixin:UpdateHealedFollower(followerID)
	for followerFrame in self.followerFramePool:EnumerateActive() do
		if followerFrame:GetFollowerGUID() == followerID then
			followerFrame:UpdateStats();
			return;
		end
	end
end

function AdventuresBoardMixin:ResetBoardIndicators() 
	for followerFrame in self:EnumerateFollowerSockets() do
		followerFrame:ResetVisibility();
	end
end

AdventuresBoardCombatMixin = CreateFromMixins(AdventuresBoardMixin);

function AdventuresBoardCombatMixin:OnLoad()
	AdventuresBoardMixin.OnLoad(self);

	local function ResetFontString(pool, fontString)
		fontString:Hide();
		fontString:ClearAllPoints();
		fontString:SetAlpha(1.0);
	end

	self.floatingTextPool = CreateFontStringPool(self.TextContainer, "OVERLAY", 0, "MissionCombatTextFontOutline", ResetFontString);
end

function AdventuresBoardCombatMixin:UpdateCooldownsFromEvent(combatLogEvent)
	local sourceFrame = self:GetFrameByBoardIndex(combatLogEvent.casterBoardIndex);
	if sourceFrame then
		sourceFrame:StartCooldown(combatLogEvent.spellID);
	end
end

function AdventuresBoardCombatMixin:UpdateCooldownsFromNewRound()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		enemyFrame:AdvanceCooldowns();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		followerFrame:AdvanceCooldowns();
	end
end

function AdventuresBoardCombatMixin:UpdateBoardAuraState(applying, combatLogEvent)
	if applying then
		self:AddAuraStateReferences(combatLogEvent);
	else
		self:RemoveAuraStateReferences(combatLogEvent);
	end
end

function AdventuresBoardCombatMixin:AddAuraStateReferences(combatLogEvent)
	for _, target in ipairs(combatLogEvent.targetInfo) do
		local targetFrame = self:GetSocketByBoardIndex(target.boardIndex);
		targetFrame:AddAura(combatLogEvent.spellID, combatLogEvent.effectIndex, combatLogEvent.auraType);
	end
end

function AdventuresBoardCombatMixin:RemoveAuraStateReferences(combatLogEvent)
	for _, target in ipairs(combatLogEvent.targetInfo) do
		local targetFrame = self:GetSocketByBoardIndex(target.boardIndex);
		targetFrame:RemoveAura(combatLogEvent.spellID, combatLogEvent.effectIndex, combatLogEvent.auraType);
	end
end

-- TODO:: Finalize table
local EventTypeFormat = {
	[Enum.GarrAutoMissionEventType.MeleeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.RangeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.SpellMeleeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.SpellRangeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.PeriodicDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.Heal] = GREEN_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_POSITIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.PeriodicHeal] = GREEN_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_POSITIVE_NUMBER),
};

local function GetTargetText(combatLogEvent, targetInfo)
	local eventType = combatLogEvent.type;
	local formatString = EventTypeFormat[eventType];

	if formatString and targetInfo.points then
		return formatString:format(targetInfo.points);
	end

	return nil;
end

function AdventuresBoardCombatMixin:AddCombatEventText(combatLogEvent)
	local sourceFrame = self:GetFrameByBoardIndex(combatLogEvent.casterBoardIndex);
	for i, target in ipairs(combatLogEvent.targetInfo) do
		local text = GetTargetText(combatLogEvent, target);
		if text then
			local targetFrame = self:GetFrameByBoardIndex(target.boardIndex);
			self:AddCombatText(text, sourceFrame, targetFrame);
			targetFrame:SetMaxHealth(target.maxHealth);
			targetFrame:SetHealth(target.newHealth);
		end
	end

	--celebration noise on final enemy kill 
	if combatLogEvent.type == Enum.GarrAutoMissionEventType.Died then
		for enemyFrame in self.enemyFramePool:EnumerateActive() do
			local currentHealth = enemyFrame:GetHealth();
			if currentHealth and currentHealth ~= 0 then
				return;
			end
		end

		PlaySound(SOUNDKIT.UI_ADVENTURES_FINAL_DEATH);
	end
end

local FloatingCombatTextAnimationTranslation = 40;
local FloatingCombatTextAnimationAlpha = -1.0;
local FloatingCombatTextVariationFunction = ScriptAnimationUtil.GenerateEasedVariationCallback(EasingUtil.InOutQuartic, 0, FloatingCombatTextAnimationTranslation, FloatingCombatTextAnimationAlpha);
local FloatingCombatTextAnimDuration = 1.3;
local BaseFloatingCombatTextOffsetY = 0;
function AdventuresBoardCombatMixin:AddCombatText(text, source, target)
	local fontString = self.floatingTextPool:Acquire();
	fontString:SetPoint("CENTER", target, "CENTER", 0, BaseFloatingCombatTextOffsetY);
	fontString:SetText(text);

	local function FloatingCombatTextOnFinished()
		self.floatingTextPool:Release(fontString);
	end

	ScriptAnimationUtil.StartScriptAnimation(fontString, FloatingCombatTextVariationFunction, FloatingCombatTextAnimDuration, FloatingCombatTextOnFinished);
	fontString:Show();
end

function AdventuresBoardCombatMixin:GetMainFrame()
	return self:GetParent():GetParent();
end


-------------------------------------------------
--- AdventuresSocketMixin for aura management ---
-------------------------------------------------

AdventuresSocketMixin = {}

function AdventuresSocketMixin:OnLoad()
	self:ResetVisibility();
end

function AdventuresSocketMixin:OnShow()
	EventRegistry:RegisterCallback("CovenantMission.CancelTargetingAnimation", self.ClearTempAndRefresh, self);
	EventRegistry:RegisterCallback("CovenantMission.CancelLoopingTargetingAnimation", self.ClearTempAndRefresh, self);
end

function AdventuresSocketMixin:OnHide()
	EventRegistry:UnregisterCallback("CovenantMission.CancelTargetingAnimation", self);
	EventRegistry:UnregisterCallback("CovenantMission.CancelLoopingTargetingAnimation", self);
end

function AdventuresSocketMixin:GetBoard()
	return self:GetParent():GetParent();
end

function AdventuresSocketMixin:ResetVisibility()
	self:ClearActiveAuras();
	self:ClearTemporaryAuras();
	self.AuraContainer.BuffIcon:Hide();
	self.AuraContainer.DebuffIcon:Hide();
	self.AuraContainer.HealingIcon:Hide();
end

function AdventuresSocketMixin:ClearActiveAuras()
	self.activeBuffs = {};
	self.activeDebuffs = {};
	self.activeHealing = {};
end

function AdventuresSocketMixin:ClearActiveAndRefresh()
	self:ClearActiveAuras();
	self:UpdateAuraVisibility();
	HelpTip:Hide(self.AuraContainer, COVENANT_MISSIONS_TUTORIAL_BENEFICIAL_EFFECT);
end

function AdventuresSocketMixin:ClearTemporaryAuras()
	self.temporaryPreviewType = 0;
end

function AdventuresSocketMixin:ClearTempAndRefresh()
	self:ClearTemporaryAuras();
	self:UpdateAuraVisibility();
end

function AdventuresSocketMixin:SetTempPreviewType(auraType)	
	self.temporaryPreviewType = CovenantMission_GetSupportColorationPreviewType(auraType);

	self:UpdateAuraVisibility();
end

function AdventuresSocketMixin:SetBoardPreviewState(auraType)
	if bit.band(auraType, Enum.GarrAutoPreviewTargetType.Buff) == Enum.GarrAutoPreviewTargetType.Buff then
		self.activeBuffs[auraType] = true;
	end

	if bit.band(auraType, Enum.GarrAutoPreviewTargetType.Heal) == Enum.GarrAutoPreviewTargetType.Heal then
		self.activeHealing[auraType] = true;
	end

	if not GetCVarBitfield("covenantMissionTutorial", Enum.GarrAutoCombatTutorial.BeneficialEffect) then
		local helpTipInfo = {
			text = COVENANT_MISSIONS_TUTORIAL_BENEFICIAL_EFFECT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "covenantMissionTutorial",
			bitfieldFlag = Enum.GarrAutoCombatTutorial.BeneficialEffect,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = 0,
			offsetY = 0,
			onHideCallback = function(acknowledged, closeFlag) self:GetBoard():GetMainFrame():ProcessTutorials(); end;
			checkCVars = true,
		}
		local mainFrame = self:GetBoard():GetMainFrame();
		mainFrame:QueueTutorial(mainFrame, helpTipInfo, self.AuraContainer);
	end

	self:UpdateAuraVisibility();
end

function AdventuresSocketMixin:AddAura(spellID, effectIndex, auraType)
	local collection = self:GetCollectionByAuraType(auraType);
	if not collection then 
		return;
	end

	if not collection[spellID] then
		collection[spellID] = {};
	end

	collection[spellID][effectIndex] = effectIndex;

	self:UpdateAuraVisibility();
end

function AdventuresSocketMixin:RemoveAura(spellID, effectIndex, auraType)
	local collection = self:GetCollectionByAuraType(auraType);

	if collection[spellID] then
		collection[spellID][effectIndex] = nil;
		
		if next(collection[spellID]) == nil then 
			collection[spellID] = nil;
		end
	end

	self:UpdateAuraVisibility();
end

function AdventuresSocketMixin:UpdateAuraVisibility()
	self.AuraContainer.BuffIcon:SetVisibility((next(self.activeBuffs) ~= nil) or (bit.band(self.temporaryPreviewType, Enum.GarrAutoPreviewTargetType.Buff) == Enum.GarrAutoPreviewTargetType.Buff));
	self.AuraContainer.DebuffIcon:SetVisibility(next(self.activeDebuffs) ~= nil);
	self.AuraContainer.HealingIcon:SetVisibility((next(self.activeHealing) ~= nil) or (bit.band(self.temporaryPreviewType, Enum.GarrAutoPreviewTargetType.Heal) == Enum.GarrAutoPreviewTargetType.Heal));
	self.AuraContainer:Layout();
end

function AdventuresSocketMixin:GetCollectionByAuraType(auraType)
	local auraCollection = {};
	if auraType == Enum.GarrAutoPreviewTargetType.Heal then
		auraCollection = self.activeBuffs;
	elseif  auraType == Enum.GarrAutoPreviewTargetType.Buff then
		auraCollection = self.activeBuffs;
	elseif auraType == Enum.GarrAutoPreviewTargetType.Debuff then
		auraCollection = self.activeDebuffs;
	end

	return auraCollection;
end

AdventuresCombatSocketMixin = {}

function AdventuresCombatSocketMixin:GetCollectionByAuraType(auraType)
	local auraCollection = {};
	if auraType == Enum.GarrAutoPreviewTargetType.Heal then
		auraCollection = self.activeBuffs;
	elseif  auraType == Enum.GarrAutoPreviewTargetType.Buff then
		auraCollection = self.activeBuffs;
	elseif auraType == Enum.GarrAutoPreviewTargetType.Debuff then
		auraCollection = self.activeDebuffs;
	end

	return auraCollection;
end


-------------------------------------------------------
---    Adventures Aura Icon Mixin					---
-------------------------------------------------------

AdventuresBoardAuraIconMixin = {}

function AdventuresBoardAuraIconMixin:OnLoad() 
	local useAtlasSize = true;
	self.IconTexture:SetAtlas(self.textureAtlas, useAtlasSize);
end

function AdventuresBoardAuraIconMixin:SetVisibility(visible)
	if visible then
		self.FadeOut:Stop();
		self:Show();
	elseif self:IsShown() then
		self.FadeIn:Stop();
		self.FadeOut:Play();
	end
end

function AdventuresBoardAuraIconMixin:OnFadeOutFinished()
	self:Hide();
	self:GetParent():Layout();
end