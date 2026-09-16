local _addonName, addonTable = ...;

local PLAYER_UNITS = { "player", "vehicle", "pet" };

local function AssertPositiveNumber(value, argumentName)
	assert(type(value) == "number" and value > 0, argumentName .. " must be a positive number.");
	return value;
end

local function AssertNonNegativeInteger(value, argumentName)
	assert(type(value) == "number" and value >= 0 and value == math.floor(value), argumentName .. " must be a non-negative integer.");
	return value;
end

TargetFrameAuraContainerSharedMixin = CreateFromMixins(ManagedAuraContainerSharedMixin);

function TargetFrameAuraContainerSharedMixin:GetBuffTemplate()
	return addonTable.GetTargetFrameBuffButtonTemplate();
end

function TargetFrameAuraContainerSharedMixin:GetDebuffTemplate()
	return addonTable.GetTargetFrameDebuffButtonTemplate();
end

function TargetFrameAuraContainerSharedMixin:GetBuffFilterString()
	return self.buffFilterString;
end

function TargetFrameAuraContainerSharedMixin:SetBuffFilterString(filterString)
	assert(AuraUtil.IsValidFilterString(filterString));

	if self.buffFilterString ~= filterString then
		self.buffFilterString = filterString;
		self.buffAuraGroup:SetFilterString(filterString);
		self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
	end
end

function TargetFrameAuraContainerSharedMixin:GetDebuffFilterString()
	return self.debuffFilterString;
end

function TargetFrameAuraContainerSharedMixin:SetDebuffFilterString(filterString)
	assert(AuraUtil.IsValidFilterString(filterString));

	if self.debuffFilterString ~= filterString then
		self.debuffFilterString = filterString;
		self.debuffAuraGroup:SetFilterString(filterString);
		self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
	end
end

function TargetFrameAuraContainerSharedMixin:GetMaxBuffs()
	return self.maxBuffs;
end

function TargetFrameAuraContainerSharedMixin:SetMaxBuffs(maxBuffs)
	maxBuffs = AssertNonNegativeInteger(maxBuffs, "maxBuffs");

	if self.maxBuffs ~= maxBuffs then
		self.maxBuffs = maxBuffs;
		self.buffAuraGroup:SetMaxFrameCount(maxBuffs);
		self:RequestFrameAssignmentRefresh();
	end
end

function TargetFrameAuraContainerSharedMixin:GetMaxDebuffs()
	return self.maxDebuffs;
end

function TargetFrameAuraContainerSharedMixin:SetMaxDebuffs(maxDebuffs)
	maxDebuffs = AssertNonNegativeInteger(maxDebuffs, "maxDebuffs");

	if self.maxDebuffs ~= maxDebuffs then
		self.maxDebuffs = maxDebuffs;
		self.debuffAuraGroup:SetMaxFrameCount(maxDebuffs);
		self:RequestFrameAssignmentRefresh();
	end
end

function TargetFrameAuraContainerSharedMixin:IsFlowLayoutMirroredVertically()
	local flowLayout = self:GetFlowLayout();
	return flowLayout:GetAnchorPoint() == "BOTTOMLEFT" and flowLayout:GetVerticalGrowthDirection() == AnchorUtil.FlowDirection.Up;
end

function TargetFrameAuraContainerSharedMixin:SetFlowLayoutMirroredVertically(mirrorVertically)
	mirrorVertically = mirrorVertically == true;

	local flowLayout = self:GetFlowLayout();
	local anchorPoint = mirrorVertically and "BOTTOMLEFT" or "TOPLEFT";
	local verticalDirection = mirrorVertically and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down;
	local horizontalDirection = flowLayout:GetHorizontalGrowthDirection();

	local changed = flowLayout:SetAnchorPoint(anchorPoint);
	changed = flowLayout:SetGrowthDirection(horizontalDirection, verticalDirection) or changed;

	if changed then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:ShouldShowAuraCount()
	return self.showAuraCount;
end

function TargetFrameAuraContainerSharedMixin:SetShowAuraCount(showAuraCount)
	showAuraCount = showAuraCount == true;

	if self.showAuraCount ~= showAuraCount then
		self.showAuraCount = showAuraCount;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameDisplay);
	end
end

function TargetFrameAuraContainerSharedMixin:IsPlayerTarget()
	return self.playerIsTarget;
end

function TargetFrameAuraContainerSharedMixin:SetPlayerIsTarget(playerIsTarget)
	playerIsTarget = playerIsTarget == true;

	if self.playerIsTarget ~= playerIsTarget then
		self.playerIsTarget = playerIsTarget;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameDisplay);
	end
end

function TargetFrameAuraContainerSharedMixin:IsTargetFriendly()
	return self.targetIsFriendly;
end

function TargetFrameAuraContainerSharedMixin:SetTargetIsFriendly(targetIsFriendly)
	targetIsFriendly = targetIsFriendly == true;

	if self.targetIsFriendly ~= targetIsFriendly then
		self.targetIsFriendly = targetIsFriendly;
		-- A full aura rebuild implies layout groups, but making it explicit here.
		self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
	end
end

function TargetFrameAuraContainerSharedMixin:GetSmallAuraSize()
	return self.smallAuraSize;
end

function TargetFrameAuraContainerSharedMixin:SetSmallAuraSize(size)
	size = AssertPositiveNumber(size, "size");

	if self.smallAuraSize ~= size then
		self.smallAuraSize = size;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetLargeAuraSize()
	return self.largeAuraSize;
end

function TargetFrameAuraContainerSharedMixin:SetLargeAuraSize(size)
	size = AssertPositiveNumber(size, "size");

	if self.largeAuraSize ~= size then
		self.largeAuraSize = size;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetFlowLayoutSpacing()
	return self.flowLayoutElementSpacing, self.flowLayoutLineSpacing;
end

function TargetFrameAuraContainerSharedMixin:SetFlowLayoutSpacing(elementSpacing, lineSpacing)
	assert(type(elementSpacing) == "number", "elementSpacing must be a number");
	assert(type(lineSpacing) == "number", "lineSpacing must be a number");

	if self.flowLayoutElementSpacing ~= elementSpacing or self.flowLayoutLineSpacing ~= lineSpacing then
		self.flowLayoutElementSpacing = elementSpacing;
		self.flowLayoutLineSpacing = lineSpacing;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
	end
end

function TargetFrameAuraContainerSharedMixin:GetConstrainedFlowLayoutLineSize()
	return self.constrainedFlowLayoutLineSize;
end

function TargetFrameAuraContainerSharedMixin:SetConstrainedFlowLayoutLineSize(lineSize)
	lineSize = AssertPositiveNumber(lineSize, "lineSize");

	if self.constrainedFlowLayoutLineSize ~= lineSize then
		self.constrainedFlowLayoutLineSize = lineSize;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetNumConstrainedFlowLayoutLines()
	return self.numConstrainedFlowLayoutLines;
end

function TargetFrameAuraContainerSharedMixin:SetNumConstrainedFlowLayoutLines(numLines)
	numLines = AssertNonNegativeInteger(numLines, "numLines");

	if self.numConstrainedFlowLayoutLines ~= numLines then
		self.numConstrainedFlowLayoutLines = numLines;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetAuraContainerAnchorsChangedCallback()
	return self.auraContainerAnchorsChangedCallback;
end

function TargetFrameAuraContainerSharedMixin:SetAuraContainerAnchorsChangedCallback(callbackFunction)
	assert(callbackFunction == nil or type(callbackFunction) == "function", "callbackFunction must be a function or nil.");

	self.auraContainerAnchorsChangedCallback = callbackFunction;
end

function TargetFrameAuraContainerSharedMixin:GetNumVisibleFlowLayoutLines()
	return self.numVisibleFlowLayoutLines;
end

TargetFrameAuraContainerInboundMixin = CreateFromMixins(ManagedAuraContainerInboundMixin, AuraContainerFlowLayoutInboundMixin, TargetFrameAuraContainerSharedMixin);
TargetFrameAuraContainerPrivateMixin = CreateFromMixins(ManagedAuraContainerPrivateMixin, AuraContainerFlowLayoutPrivateMixin, TargetFrameAuraContainerSharedMixin);

function TargetFrameAuraContainerPrivateMixin:OnLoad()
	self.flowLayout = CreateAndInitFromMixin(TargetFrameAuraFlowLayoutMixin);
	self.flowLayoutGroups = {};
	self:ApplyFlowLayoutDefaults(self.flowLayout);

	self.numVisibleFlowLayoutLines = 0;
	self.playerIsTarget = false;
	self.targetIsFriendly = false;

	self.auraPools = CreateFramePoolCollection();
	self.auraPools:CreatePool("AuraButton", self, self:GetBuffTemplate(), GenerateClosure(self.ResetPooledAuraFrame, self));
	self.auraPools:CreatePool("AuraButton", self, self:GetDebuffTemplate(), GenerateClosure(self.ResetPooledAuraFrame, self));

	self.buffAuraGroup = self:RegisterAuraGroup("Buffs", {
		filterString = self:GetBuffFilterString(),
		frameProvider = AuraContainerUtil.CreateFramePoolProvider(self.auraPools:GetPool(self:GetBuffTemplate())),
		maxFrameCount = self:GetMaxBuffs()
	});

	self.debuffAuraGroup = self:RegisterAuraGroup("Debuffs", {
		filterString = self:GetDebuffFilterString(),
		frameProvider = AuraContainerUtil.CreateFramePoolProvider(self.auraPools:GetPool(self:GetDebuffTemplate())),
		maxFrameCount = self:GetMaxDebuffs()
	});

	CVarCallbackRegistry:SetCVarCachable("noBuffDebuffFilterOnTarget");

	self:MarkDirty(AuraContainerDirtyMask.All);
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:ShouldIncludeAuraInGroup(auraGroup, _unitToken, auraData, _hasMatchedFilterString)
	if auraGroup == self.buffAuraGroup then
		return self:ShouldShowAuraAsBuff(auraData);
	elseif auraGroup == self.debuffAuraGroup then
		return self:ShouldShowAuraAsDebuff(auraData);
	end

	return false;
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:InitializeAuraGroupFrame(auraGroup, auraFrame, unitToken, auraData)
	if auraGroup == self.buffAuraGroup then
		auraFrame:SetStealableBorderEnabled(not self:IsPlayerTarget());
	end

	auraFrame:SetShowAuraCount(self:ShouldShowAuraCount());
	auraFrame:SetAuraInstance(unitToken, auraData);
	auraFrame:Show();
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:RefreshAuraFrameDisplay()
	local stealableBorderEnabled = not self:IsPlayerTarget();

	for _index, auraFrame in ipairs(self.buffAuraGroup:GetFramesByIndex()) do
		auraFrame:SetStealableBorderEnabled(stealableBorderEnabled);
		auraFrame:SetShowAuraCount(self:ShouldShowAuraCount());
	end

	for _index, auraFrame in ipairs(self.debuffAuraGroup:GetFramesByIndex()) do
		auraFrame:SetShowAuraCount(self:ShouldShowAuraCount());
	end
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:RebuildLayoutGroups()
	local elementSpacing, lineSpacing = self:GetFlowLayoutSpacing();
	local firstAuraGroup, secondAuraGroup;

	-- Note that flow layout collapses groups with no elements, and so the
	-- second group here will shift up if the first is empty.
	if self:IsTargetFriendly() then
		firstAuraGroup = self.buffAuraGroup;
		secondAuraGroup = self.debuffAuraGroup;
	else
		firstAuraGroup = self.debuffAuraGroup;
		secondAuraGroup = self.buffAuraGroup;
	end

	self.flowLayoutGroups =
	{
		-- Closures are intentional because aura processing replaces each group's
		-- visible frame list during refresh.
		{
			elements = function() return firstAuraGroup:GetFramesByIndex(); end,
			elementSpacing = elementSpacing,
			lineSpacing = lineSpacing,
		},
		{
			elements = function() return secondAuraGroup:GetFramesByIndex(); end,
			elementSpacing = elementSpacing,
			lineSpacing = lineSpacing,
			forceNewLine = true,
			groupLineSpacing = lineSpacing,
		},
	};
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:ApplyFlowLayoutDefaults(flowLayout)
	flowLayout:SetLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal);
	flowLayout:SetAnchorPoint("TOPLEFT");
	flowLayout:SetGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down);
	flowLayout:SetPadding(self.flowLayoutPaddingLeft, self.flowLayoutPaddingRight, self.flowLayoutPaddingTop, self.flowLayoutPaddingBottom);
	flowLayout:SetMaximumLineSize(self.flowLayoutLineSize);
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:ApplyLayout()
	self:ApplyFlowLayout();
	self:SignalAuraContainerAnchorsChanged();
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:OnFrameAssignmentsReset()
	self:SetNumVisibleFlowLayoutLines(0);
	self:SetSize(1, 1);
end

function TargetFrameAuraContainerPrivateMixin:ResetPooledAuraFrame(_pool, frame)
	frame:ClearAuraInstance();
	frame:ClearAllPoints();
	frame:Hide();
end

function TargetFrameAuraContainerPrivateMixin:SetNumVisibleFlowLayoutLines(lineCount)
	self.numVisibleFlowLayoutLines = lineCount;
end

function TargetFrameAuraContainerPrivateMixin:SignalAuraContainerAnchorsChanged()
	local callbackFunction = self:GetAuraContainerAnchorsChangedCallback();
	if callbackFunction ~= nil then
		securecall(callbackFunction);
	end
end

function TargetFrameAuraContainerPrivateMixin:ShouldShowAuraAsBuff(auraData)
	if not auraData.isHelpful then
		return false;
	end

	if auraData.isPrivate then
		return true;
	end

	if auraData.isNameplateOnly then
		return false;
	end

	if C_GameRules.IsGameRuleActive(Enum.GameRule.TargetFrameBuffsDisabled) then
		return false;
	end

	return true;
end

function TargetFrameAuraContainerPrivateMixin:ShouldShowAuraAsDebuff(auraData)
	if not auraData.isHarmful then
		return false;
	end

	if auraData.isPrivate then
		return true;
	end

	if CVarCallbackRegistry:GetCVarValueBool("noBuffDebuffFilterOnTarget") then
		return true;
	end

	if auraData.nameplateShowAll then
		return true;
	end

	local caster = auraData.sourceUnit;
	if caster and (UnitIsUnit("player", caster) or UnitIsOwnerOrControllerOfUnit("player", caster)) then
		return true;
	end

	if UnitIsUnit("player", self:GetUnit()) then
		return true;
	end

	local targetIsPlayer = UnitIsPlayer(self:GetUnit());
	local targetIsPlayerPet = UnitIsOtherPlayersPet(self:GetUnit());
	if not targetIsPlayer and not targetIsPlayerPet and not self:IsTargetFriendly() and auraData.isFromPlayerOrPlayerPet then
		return false;
	end

	return true;
end

function TargetFrameAuraContainerPrivateMixin:ShouldShowAuraWithLargeSize(auraData)
	if not auraData.sourceUnit then
		return false;
	end

	for _index, token in ipairs(PLAYER_UNITS) do
		if UnitIsUnit(auraData.sourceUnit, token) or UnitIsOwnerOrControllerOfUnit(token, auraData.sourceUnit) then
			return true;
		end
	end

	return false;
end

TargetFrameAuraFlowLayoutMixin = CreateFromMixins(AnchorUtil.FlowLayoutMixin);

function TargetFrameAuraFlowLayoutMixin:GetMaximumLineSizeForLine(container, lineIndex, _group)
	if lineIndex <= container:GetNumConstrainedFlowLayoutLines() then
		return container:GetConstrainedFlowLayoutLineSize();
	end

	return self:GetMaximumLineSize();
end

function TargetFrameAuraFlowLayoutMixin:GetElementSize(container, element, _group)
	local _unitToken, auraData = element:GetAuraInstance();
	local auraSize = container:GetSmallAuraSize();

	if auraData ~= nil and container:ShouldShowAuraWithLargeSize(auraData) then
		auraSize = container:GetLargeAuraSize();
	end

	return auraSize, auraSize;
end

function TargetFrameAuraFlowLayoutMixin:ApplyElementLayout(container, element, anchorPoint, offsetX, offsetY, width, height)
	element:ClearAllPoints();
	element:SetPoint(anchorPoint, container, anchorPoint, offsetX, offsetY);
	element:SetSize(width, height);
end

function TargetFrameAuraFlowLayoutMixin:OnLayoutComplete(container, width, height, _hasPlacedElement, lineCount)
	-- Apply secrets here as these may infer presence of auras through publicly
	-- exposed interfaces.
	container:SetSize(secretwrap(width, height));
	container:SetNumVisibleFlowLayoutLines(secretwrap(lineCount));
end
