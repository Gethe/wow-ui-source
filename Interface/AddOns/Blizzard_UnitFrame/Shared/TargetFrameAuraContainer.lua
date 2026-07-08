local _addonName, addonTable = ...;

local PLAYER_UNITS = { "player", "vehicle", "pet" };

local function AssertNumber(value, argumentName)
	assert(type(value) == "number", argumentName .. " must be a number.");
	return value;
end

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
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameAssignments);
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
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameAssignments);
	end
end

function TargetFrameAuraContainerSharedMixin:ShouldMirrorAurasVertically()
	return self.mirrorVertically;
end

function TargetFrameAuraContainerSharedMixin:SetMirrorAurasVertically(mirrorVertically)
	mirrorVertically = mirrorVertically == true;

	if self.mirrorVertically ~= mirrorVertically then
		self.mirrorVertically = mirrorVertically;
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

function TargetFrameAuraContainerSharedMixin:GetAuraPadding()
	return self.auraPaddingLeft, self.auraPaddingRight, self.auraPaddingTop, self.auraPaddingBottom;
end

function TargetFrameAuraContainerSharedMixin:SetAuraPadding(left, right, top, bottom)
	left = AssertNumber(left, "left");
	right = AssertNumber(right, "right");
	top = AssertNumber(top, "top");
	bottom = AssertNumber(bottom, "bottom");

	if self.auraPaddingLeft ~= left or self.auraPaddingRight ~= right or self.auraPaddingTop ~= top or self.auraPaddingBottom ~= bottom then
		self.auraPaddingLeft = left;
		self.auraPaddingRight = right;
		self.auraPaddingTop = top;
		self.auraPaddingBottom = bottom;

		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetAuraSpacing()
	return self.auraElementSpacingX, self.auraElementSpacingY;
end

function TargetFrameAuraContainerSharedMixin:SetAuraSpacing(elementSpacingX, elementSpacingY)
	elementSpacingX = AssertNumber(elementSpacingX, "elementSpacingX");
	elementSpacingY = AssertNumber(elementSpacingY, "elementSpacingY");

	if self.auraElementSpacingX ~= elementSpacingX or self.auraElementSpacingY ~= elementSpacingY then
		self.auraElementSpacingX = elementSpacingX;
		self.auraElementSpacingY = elementSpacingY;

		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
	end
end

function TargetFrameAuraContainerSharedMixin:GetAuraRowWidth()
	return self.auraRowWidth;
end

function TargetFrameAuraContainerSharedMixin:SetAuraRowWidth(rowWidth)
	rowWidth = AssertPositiveNumber(rowWidth, "rowWidth");

	if self.auraRowWidth ~= rowWidth then
		self.auraRowWidth = rowWidth;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetConstrainedAuraRowWidth()
	return self.constrainedAuraRowWidth;
end

function TargetFrameAuraContainerSharedMixin:SetConstrainedAuraRowWidth(rowWidth)
	rowWidth = AssertPositiveNumber(rowWidth, "rowWidth");

	if self.constrainedAuraRowWidth ~= rowWidth then
		self.constrainedAuraRowWidth = rowWidth;
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
	end
end

function TargetFrameAuraContainerSharedMixin:GetNumConstrainedAuraRows()
	return self.numConstrainedAuraRows;
end

function TargetFrameAuraContainerSharedMixin:SetNumConstrainedAuraRows(numRows)
	numRows = AssertNonNegativeInteger(numRows, "numRows");

	if self.numConstrainedAuraRows ~= numRows then
		self.numConstrainedAuraRows = numRows;
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

function TargetFrameAuraContainerSharedMixin:GetNumVisibleAuraRows()
	return self.numVisibleAuraRows;
end

TargetFrameAuraContainerInboundMixin = CreateFromMixins(ManagedAuraContainerInboundMixin, TargetFrameAuraContainerSharedMixin);
TargetFrameAuraContainerPrivateMixin = CreateFromMixins(ManagedAuraContainerPrivateMixin, TargetFrameAuraContainerSharedMixin);

function TargetFrameAuraContainerPrivateMixin:OnLoad()
	self.flowLayoutDescription = TargetFrameAuraFlowLayoutDescription;
	self.flowLayoutGroups = {};
	self.numVisibleAuraRows = 0;
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
	local elementSpacingX, elementSpacingY = self:GetAuraSpacing();
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
			elementSpacingX = elementSpacingX,
			elementSpacingY = elementSpacingY,
			forceNewRow = false,
			gapX = 0,
			gapY = 0,
		},
		{
			elements = function() return secondAuraGroup:GetFramesByIndex(); end,
			elementSpacingX = elementSpacingX,
			elementSpacingY = elementSpacingY,
			forceNewRow = true,
			gapX = 0,
			gapY = elementSpacingY,
		},
	};
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:ApplyLayout()
	AnchorUtil.ApplyFlowLayout(self, self:GetFlowLayoutGroups(), self.flowLayoutDescription);
	self:SignalAuraContainerAnchorsChanged();
end

--[[override]] function TargetFrameAuraContainerPrivateMixin:OnAuraFramesReset()
	self:SetNumVisibleAuraRows(0);
	self:SetSize(1, 1);
end

function TargetFrameAuraContainerPrivateMixin:ResetPooledAuraFrame(_pool, frame)
	frame:ClearAuraInstance();
	frame:ClearAllPoints();
	frame:Hide();
end

function TargetFrameAuraContainerPrivateMixin:GetFlowLayoutGroups()
	return self.flowLayoutGroups;
end

function TargetFrameAuraContainerPrivateMixin:SetNumVisibleAuraRows(rowCount)
	self.numVisibleAuraRows = rowCount;
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

TargetFrameAuraFlowLayoutDescription = CreateFromMixins(AnchorUtil.FlowLayoutDescriptionBaseMixin);

function TargetFrameAuraFlowLayoutDescription:GetAnchorPoint(container)
	if container:ShouldMirrorAurasVertically() then
		return "BOTTOMLEFT";
	end

	return "TOPLEFT";
end

function TargetFrameAuraFlowLayoutDescription:GetHorizontalGrowthDirection(_container)
	return AnchorUtil.FlowDirection.Right;
end

function TargetFrameAuraFlowLayoutDescription:GetVerticalGrowthDirection(container)
	if container:ShouldMirrorAurasVertically() then
		return AnchorUtil.FlowDirection.Up;
	end

	return AnchorUtil.FlowDirection.Down;
end

function TargetFrameAuraFlowLayoutDescription:GetPadding(container)
	return container:GetAuraPadding();
end

function TargetFrameAuraFlowLayoutDescription:GetRowWidth(container, rowIndex)
	if rowIndex <= container:GetNumConstrainedAuraRows() then
		return container:GetConstrainedAuraRowWidth();
	end

	return container:GetAuraRowWidth();
end

function TargetFrameAuraFlowLayoutDescription:GetElementSize(container, element)
	local _unitToken, auraData = element:GetAuraInstance();

	if auraData ~= nil and container:ShouldShowAuraWithLargeSize(auraData) then
		return container:GetLargeAuraSize(), container:GetLargeAuraSize();
	end

	return container:GetSmallAuraSize(), container:GetSmallAuraSize();
end

function TargetFrameAuraFlowLayoutDescription:ApplyElementLayout(container, element, anchorPoint, offsetX, offsetY, width, height)
	element:ClearAllPoints();
	element:SetPoint(anchorPoint, container, anchorPoint, offsetX, offsetY);
	element:SetSize(width, height);
end

function TargetFrameAuraFlowLayoutDescription:OnLayoutComplete(container, width, height, _hasPlacedElement, rowCount)
	-- Apply secrets here as these may infer presence of auras through publicly
	-- exposed interfaces.
	container:SetSize(secretwrap(width, height));
	container:SetNumVisibleAuraRows(secretwrap(rowCount));
end
