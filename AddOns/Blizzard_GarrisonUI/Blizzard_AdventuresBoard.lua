
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


AdventuresBoardMixin = {};

function AdventuresBoardMixin:OnLoad()
	self.framesByBoardIndex = {};
	self.enemyFramePool = CreateFramePool("FRAME", self.EnemyContainer, self.enemyTemplate);
	self.followerFramePool = CreateFramePool("FRAME", self.FollowerContainer, self.followerTemplate);
	self:CreateEnemyFrames();
	self:CreateFollowerFrames();
end

function AdventuresBoardMixin:GetFrameByBoardIndex(boardIndex)
	return self.framesByBoardIndex[boardIndex];
end

function AdventuresBoardMixin:Reset()
	for enemyFrame in self.enemyFramePool:EnumerateActive() do
		GarrisonFollowerMission_ResetMissionCompleteEncounter(enemyFrame);
		GarrisonEnemyPortait_Set(enemyFrame.Portrait, nil);
		enemyFrame.Elite:Hide();
	end

	for followerFrame in self.followerFramePool:EnumerateActive() do
		GarrisonMissionComplete_KillFollowerXPAnims(followerFrame);
	end
end

function AdventuresBoardMixin:RegisterFrame(frame)
	self.framesByBoardIndex[frame.boardIndex] = frame;
end

function AdventuresBoardMixin:GenerateFactoryFunction(framePool, boardIndices)
	local function CreateNewFrame(index)
		local newFrame = framePool:Acquire();
		newFrame.boardIndex = boardIndices[index];
		self:RegisterFrame(newFrame);
		newFrame:Show();
		return newFrame;
	end

	return CreateNewFrame;
end

function AdventuresBoardMixin:CreateEnemyFrames()
	if self.enemyFramesCreated then
		return;
	end

	self.enemyFramesCreated = true;

	local boardIndices = EnemyOrder;
	local createNewEnemy = self:GenerateFactoryFunction(self.enemyFramePool, boardIndices);

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
	local createNewFollower = self:GenerateFactoryFunction(self.followerFramePool, boardIndices);

	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.FollowerContainer, "TOPLEFT", 0, 0);

	local direction = nil;
	local stride = 3;
	local paddingX = 6;
	local paddingY = 6;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);

	AnchorUtil.GridLayoutFactoryByCount(createNewFollower, #boardIndices, initialAnchor, layout);

	-- TODO:: Replace this? At least update the value based on new templates
	local backRowAdjustment = 88;
	for i, position in ipairs(BackFollowerPositions) do
		local followerFrame = self:GetFrameByBoardIndex(position);
		
		followerFrame:AdjustPointsOffset(backRowAdjustment, 0);
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

-- TODO:: Finalize table
local EventTypeFormat = {
	[Enum.GarrAutoMissionEventType.MeleeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.RangeDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.SpellDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.PeriodicDamage] = RED_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_NEGATIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.ApplyAura] = WHITE_FONT_COLOR:WrapTextInColorCode("%s"),
	[Enum.GarrAutoMissionEventType.Heal] = GREEN_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_POSITIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.PeriodicHeal] = GREEN_FONT_COLOR:WrapTextInColorCode(SYMBOLIC_POSITIVE_NUMBER),
	[Enum.GarrAutoMissionEventType.Died] = RED_FONT_COLOR:WrapTextInColorCode("%s"),
	[Enum.GarrAutoMissionEventType.RemoveAura] = WHITE_FONT_COLOR:WrapTextInColorCode("%s"),
};

local function GetTargetText(combatLogEvent, targetInfo)
	local eventType = combatLogEvent.type;
	local formatString = EventTypeFormat[eventType];

	-- TODO:: finalize implementation.

	if eventType == Enum.GarrAutoMissionEventType.Died then
		-- TODO:: Replace with animation.
		return formatString:format("Dead");
	elseif eventType == Enum.GarrAutoMissionEventType.ApplyAura then
		-- TODO:: determine if we want to keep these, and localize if so.
		return formatString:format("Applied");
	elseif eventType == Enum.GarrAutoMissionEventType.RemoveAura then
		-- TODO:: determine if we want to keep these, and localize if so.
		return formatString:format("Removed");
	elseif targetInfo.points then
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
		end
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
