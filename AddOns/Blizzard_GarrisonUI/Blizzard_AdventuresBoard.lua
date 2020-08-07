
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
	local paddingY = 20;
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
	local paddingY = 6;
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


function AdventuresBoardMixin:TriggerEnemyTargetingReticles(targetingIndices, useLoop)
	for _, targetingIndex in ipairs(targetingIndices) do
		if  targetingIndex >= Enum.GarrAutoBoardIndex.EnemyLeftFront and targetingIndex <= Enum.GarrAutoBoardIndex.EnemyRightBack then
			local frameToPlayAnimation = self:GetFrameByBoardIndex(targetingIndex);

			if frameToPlayAnimation:IsShown() then
				if not useLoop then 
					frameToPlayAnimation.EnemyTargetingIndicatorFrame:Play();
				else
					frameToPlayAnimation.EnemyTargetingIndicatorFrame:Loop();
				end
			else
				local socketToPlayEmptyAnimation = self:GetSocketByBoardIndex(targetingIndex);
				if not useLoop then
					socketToPlayEmptyAnimation.DesaturatedTargetingIndicatorFrame:Play();
				else
					socketToPlayEmptyAnimation.DesaturatedTargetingIndicatorFrame:Loop();
				end
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
	sourceFrame:StartCooldown(combatLogEvent.spellID);
end

function AdventuresBoardCombatMixin:UpdateCooldownsFromNewRound()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		enemyFrame:AdvanceCooldowns();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		followerFrame:AdvanceCooldowns();
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