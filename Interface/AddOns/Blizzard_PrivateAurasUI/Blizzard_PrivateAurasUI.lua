local _, PrivateAuras = ...;

local CUF_AURA_BOTTOM_OFFSET = 2;
local BOSS_DEBUFF_SCALE_INCREASE = 1.5;

local DispelOverlayOrientation = EnumUtil.MakeEnum(
	"VerticalTopToBottom",
	"VerticalBottomToTop",
	"HorizontalLeftToRight"
);

local dispelAtlases =
{
	["Magic"] = "RaidFrame-Icon-DebuffMagic",
	["Curse"] = "RaidFrame-Icon-DebuffCurse",
	["Disease"] = "RaidFrame-Icon-DebuffDisease",
	["Poison"] = "RaidFrame-Icon-DebuffPoison",
	["Bleed"] = "RaidFrame-Icon-DebuffBleed",
};

AddTooltipDataAccessor(GameTooltipDataMixin, "SetUnitPrivateAura", "GetUnitPrivateAura");

local PrivateAuraFramePool = CreateFramePool("FRAME", nil, "PrivateAuraTemplate", function(pool, frame) frame:Reset(); end);
local PrivateAuraEventFramePool = CreateFramePool("FRAME", nil, "PrivateAuraUnitWatcherTemplate"); -- TODO: Maybe this isn't required, but something has to maintain a list
local PrivateAuraDispelOverlayFramePool = CreateFramePool("Frame", nil, "CompactUnitFrameDispelOverlayTemplate");

CompactDispelDebuffMixin = {}; -- CreateFromMixins(CompactAuraTooltipMixin);

function CompactDispelDebuffMixin:OnEnter()
	-- TODO: Implement OnEnter logic
end

function CompactDispelDebuffMixin:OnLeave()
	-- TODO: Implement OnEnter logic
end

function CompactDispelDebuffMixin:UpdateTooltip()
	-- TODO: Nope, needs to change.
	PrivateAurasTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().displayedUnit, self.auraInstanceID, "RAID");
end

-- This is largely a modified copy of AuraButtonMixin
PrivateAuraMixin = {};

function PrivateAuraMixin:OnLoad()
	self.Symbol:Hide();
	self.TempEnchantBorder:Hide();
end

function PrivateAuraMixin:Reset()
	self.hideDuration = false;
	self.useIconSizeForAuraSize = false;

	self.DebuffBorder:SetSize(40, 40);

	self:ClearOverrideSize();
end

function PrivateAuraMixin:ShowTooltip()
	if self.auraInfo.isPrivate then
		PrivateAurasTooltip:SetUnitPrivateAura(self.unit, self.auraInfo.auraInstanceID);
	else
		PrivateAurasTooltip:SetUnitAuraByAuraInstanceID(self.unit, self.auraInfo.auraInstanceID);
	end
end

function PrivateAuraMixin:OnEnter()
	PrivateAurasTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	PrivateAurasTooltip:SetFrameLevel(self:GetFrameLevel() + 2);
	self:ShowTooltip();

	self.needsOnUpdateMouseFocus = true;
	self:UpdateOnUpdate();
end

function PrivateAuraMixin:OnLeave()
	PrivateAurasTooltip:Hide();

	self.needsOnUpdateMouseFocus = false;
	self:UpdateOnUpdate();
end

function PrivateAuraMixin:OnUpdate()
	-- Update duration
	self:UpdateDuration(self.timeLeft);

	-- Update our timeLeft
	local timeLeft = self.auraInfo.expirationTime - GetTime();
	if self.auraInfo.timeMod and self.auraInfo.timeMod > 0 then
		timeLeft = timeLeft / self.auraInfo.timeMod;
	end
	self.timeLeft = math.max(timeLeft, 0);
	if SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD then
		local aboveMinThreshold = self.timeLeft > SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD;
		local belowMaxThreshold = not SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD or self.timeLeft < SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD;
		if aboveMinThreshold and belowMaxThreshold then
			self.Duration:SetFontObject(SMALLER_AURA_DURATION_FONT);
			self.Duration:SetPoint("TOP", self, "BOTTOM", 0, SMALLER_AURA_DURATION_OFFSET_Y);
		else
			self.Duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			self.Duration:SetPoint("TOP", self, "BOTTOM");
		end
	end

	if self:IsMouseMotionFocus() then
		self:ShowTooltip();
	end
end

function PrivateAuraMixin:SetInitialDuration(auraInfo)
	if auraInfo.expirationTime and auraInfo.expirationTime > 0 then
		local timeLeft = auraInfo.expirationTime - GetTime();
		self.timeMod = auraInfo.timeMod or 1;
		timeLeft = timeLeft / self.timeMod;

		self.timeLeft = timeLeft;
		self.needsOnUpdateTimeLeft = true;
	else
		self.Duration:Hide();
		self.timeLeft = nil;
		self.needsOnUpdateTimeLeft = false;
	end

	self:UpdateOnUpdate();
end

function PrivateAuraMixin:UpdateDuration(timeLeft)
	if timeLeft and (timeLeft > 0) and not self.hideDuration and CVarCallbackRegistry:GetCVarValueBool("buffDurations") then
		self.Duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));
		if timeLeft < BUFF_DURATION_WARNING_TIME then
			self.Duration:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			self.Duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		self.Duration:Show();
	else
		self.Duration:Hide();
	end
end

function PrivateAuraMixin:UpdateOnUpdate()
	local needsOnUpdate = self.needsOnUpdateMouseFocus or self.needsOnUpdateTimeLeft;
	if needsOnUpdate ~= self.hasOnUpdate then
		self.hasOnUpdate = needsOnUpdate;
		if needsOnUpdate then
			self:SetScript("OnUpdate", self.OnUpdate);
		else
			self:SetScript("OnUpdate", nil);
		end
	end
end

local s_showDispelType = false;
do
	local callback = C_FunctionContainers.CreateCallback(function(show)
		s_showDispelType = show;
	end);
	C_UnitAurasPrivate.SetShowDispelTypeCallback(callback);
end

function PrivateAuraMixin:GetCountText()
	if self.auraInfo.applications >= 100 then
		return BUFF_STACKS_OVERFLOW;
	elseif self.auraInfo.applications > 1 then
		return tostring(self.auraInfo.applications);
	end

	return nil;
end


function PrivateAuraMixin:SetOverrideSize(width, height)
	self.overrideWidth = width;
	self.overrideHeight = height;
end

function PrivateAuraMixin:ClearOverrideSize()
	self:SetOverrideSize();
end

function PrivateAuraMixin:GetBaseAuraSize(anchorInfo)
	local width = self.overrideWidth or anchorInfo.iconWidth;
	local height = self.overrideHeight or anchorInfo.iconHeight;
	return width, height;
end

function PrivateAuraMixin:GetAuraSize(aura, anchorInfo)
	local width, height = self:GetBaseAuraSize(anchorInfo);

	-- NOTE: aura being optional was added late to account for frame reservations and grid layouts. The issue is that if we need to display a layout with a stride, like a grid layout
	-- then the frames cannot be anchored to each other (chain layout would be ideal, but doesn't support stride)
	if aura and anchorInfo.containerSettings and anchorInfo.containerSettings.displayLargerRoleSpecificDebuffs and (aura.isBossAura or AuraUtil.IsRoleAura(aura)) then
		return width * BOSS_DEBUFF_SCALE_INCREASE, height * BOSS_DEBUFF_SCALE_INCREASE;
	end

	return width, height;
end

function PrivateAuraMixin:UpdateSizeFromAnchor(aura, anchorInfo)
	if anchorInfo.iconWidth and anchorInfo.iconHeight then
		local width, height = self:GetAuraSize(aura, anchorInfo);
		self.Icon:SetSize(width, height);

		if self.useIconSizeForAuraSize then
			self:SetSize(width, height);
		else
			-- Use template size for the aura, defined in .../Blizzard_BuffFrame/BuffFrameTemplates.xml
			self:SetSize(30, 40);
		end

		local scale = anchorInfo.borderScale;
		if scale then
			-- Since this is just for the border around the icon and that's square, using width is ok.
			local debuffBorderSize = width + (5 * scale);
			self.DebuffBorder:SetSize(debuffBorderSize, debuffBorderSize);
		end
	end
end

function PrivateAuraMixin:GetAuraInstanceID()
	return self.auraInfo and self.auraInfo.auraInstanceID;
end

function PrivateAuraMixin:Update(auraInfo, unit, anchorInfo)
	self:Show();

	self.auraInfo = auraInfo;
	self.unit = unit;
	self.anchorInfo = anchorInfo;

	if auraInfo.isHarmful then
		self.DebuffBorder:Show();
		self.Symbol:Show();

		AuraUtil.SetAuraSymbol(self.Symbol, auraInfo.dispelName);
		AuraUtil.SetAuraBorderAtlas(self.DebuffBorder, auraInfo.dispelName, anchorInfo:ShouldShowDispelType());
	else
		self.DebuffBorder:Hide();
		self.Symbol:Hide();
	end

	self:SetInitialDuration(auraInfo);
	self.Icon:SetTexture(auraInfo.icon);

	local countText = self:GetCountText(auraInfo);
	if countText then
		self.Count:SetText(countText);
		self.Count:Show();
	else
		self.Count:Hide();
	end

	if anchorInfo.showCountdownFrame and auraInfo.expirationTime and auraInfo.expirationTime ~= 0 then
		local startTime = auraInfo.expirationTime - auraInfo.duration;
		CooldownFrame_Set(self.Cooldown, startTime, auraInfo.duration, true);
		self.Cooldown:SetHideCountdownNumbers(not anchorInfo.showCountdownNumbers);
	else
		CooldownFrame_Clear(self.Cooldown);
	end

	if self:IsMouseMotionFocus() then
		self:ShowTooltip();
	end

	self:UpdateSizeFromAnchor(auraInfo, anchorInfo);
end

function PrivateAuraMixin:GetDebuffSize(aura)
	-- NOTE: These are always square, using the iconWidth as the size.
	if self.containerSettings.displayLargerRoleSpecificDebuffs and (aura.isBossAura or AuraUtil.IsRoleAura(aura)) then
		return self.iconWidth * BOSS_DEBUFF_SCALE_INCREASE;
	else
		return self.iconWidth;
	end
end

--
-- Some machinery to ensure that the PrivateAura code never accidentally calls hooked methods on the container frame.
-- Anything that needs to be called on the container frame
--

local InboundFrameAPI = CopyTable(GetFrameMetatable().__index);
local InboundContainerFrameMixin = {};

function InboundContainerFrameMixin:Init(containerFrame)
	self[0] = rawget(containerFrame, 0);
end

function InboundContainerFrameMixin:GetAttribute(attribute)
	return InboundFrameAPI.GetAttribute(self, attribute);
end

function InboundContainerFrameMixin:SetAttribute(attribute, value)
	return InboundFrameAPI.SetAttribute(self, attribute, value);
end

function InboundContainerFrameMixin:SetScript(scriptType, fn)
	return InboundFrameAPI.SetScript(self, scriptType, fn);
end

function InboundContainerFrameMixin:GetScript(scriptType)
	return InboundFrameAPI.GetScript(self, scriptType);
end

--
-- PrivateAuraAnchorContainerMixin
-- This is used to manage PA anchors that handle the layout of multiple auras and the dispel display overlay/icons
-- These can roughly be thought of as an entire CompactUnitFrame but for aura displays that need to remain entirely in the secure environment.
--

PrivateAuraAnchorContainerMixin = {};

function PrivateAuraAnchorContainerMixin:ReadContainerSettings()
	local containerFrame = self:GetContainer();

	self.containerSettings = {
		maxBuffs = containerFrame:GetAttribute("max-buffs"),
		maxDebuffs = containerFrame:GetAttribute("max-debuffs"),
		maxDispelDebuffs = containerFrame:GetAttribute("max-dispel-debuffs"),
		auraOrganizationType = containerFrame:GetAttribute("aura-organization-type"),
		alwaysHideDuration = containerFrame:GetAttribute("always-hide-duration"),
		setAuraSizeToIconSize = containerFrame:GetAttribute("set-aura-size-to-icon-size"),
		displayLargerRoleSpecificDebuffs = containerFrame:GetAttribute("display-larger-role-specific-debuffs"),
		showDispelIndicatorOverlay = containerFrame:GetAttribute("show-dispel-indicator-overlay"),
		showBigDefensive = containerFrame:GetAttribute("show-big-defensive"),
		bigDefensiveSize = containerFrame:GetAttribute("big-defensive-size"),
		powerBarUsedHeight = containerFrame:GetAttribute("power-bar-used-height"),
		groupType = containerFrame:GetAttribute("group-type"),
		displayOnlyDispellableDebuffs = containerFrame:GetAttribute("display-only-dispellable-debuffs"),
		ignoreBuffs = containerFrame:GetAttribute("ignore-buffs"),
		ignoreDebuffs = containerFrame:GetAttribute("ignore-debuffs"),
		ignoreDispelDebuffs = containerFrame:GetAttribute("ignore-dispel-debuffs"),
		dispelIndicatorOption = containerFrame:GetAttribute("dispel-indicator-option"),
		suppressDispelBorderIcons = containerFrame:GetAttribute("suppress-dispel-border-icons"),
		iconSize = containerFrame:GetAttribute("icon-size"),
	};

	self.iconWidth = self.containerSettings.iconSize;
	self.iconHeight = self.containerSettings.iconSize;
	self.isPartyFrameCached = self:IsPartyFrame();
end

function PrivateAuraAnchorContainerMixin:OnAnchorAdded(watcher)
	local containerFrame = CreateAndInitFromMixin(InboundContainerFrameMixin, self.parent);
	self.container = containerFrame;
	self.watcher = watcher;
	self.blockedAuras = {};
	self:ReadContainerSettings();
	self:CreatePriorityTables();
	self:RegisterContainerEventFrame();
	self:ReserveAuraFramesForContainer();
	self:UpdateAuraFrameLayout();
	self:RegisterSettingsChangeHandler();
end

function PrivateAuraAnchorContainerMixin:OnAnchorRemoved()
	self:UnregisterContainerEventFrame();
	self:ResetReservedAuraFramesForContainer();
	self:UnregisterSettingsChangeHandler();
end

function PrivateAuraAnchorContainerMixin:UpdateFromSettings()
	self:ReadContainerSettings();
	self:ResizeReservedAuraFramesForContainer();
	self:UpdateAuraFrameLayout();

	self.watcher:MarkDirty();
end

function PrivateAuraAnchorContainerMixin:CreatePriorityTables()
	self.debuffs = TableUtil.CreatePriorityTable(AuraUtil.UnitFrameDebuffComparator, TableUtil.Constants.AssociativePriorityTable);
	self.buffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	self.bigDefensives = TableUtil.CreatePriorityTable(AuraUtil.BigDefensiveAuraCompare, TableUtil.Constants.AssociativePriorityTable);

	self.dispels = {};
	for dispelType, _ in pairs(AuraUtil.DispellableDebuffTypes) do
		self.dispels[dispelType] = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	end
end

function PrivateAuraAnchorContainerMixin:ClearPriorityTables()
	self.debuffs:Clear();
	self.buffs:Clear();
	self.bigDefensives:Clear();

	for _, priorityTable in pairs(self.dispels) do
		priorityTable:Clear();
	end
end

function PrivateAuraAnchorContainerMixin:IsPartyFrame()
	return self.containerSettings.groupType == CompactRaidGroupTypeEnum.Raid or self.containerSettings.groupType == CompactRaidGroupTypeEnum.Party;
end

function PrivateAuraAnchorContainerMixin:ShouldDisplayDispelIndicator(aura)
	local dispelIndicatorOption = self.containerSettings.dispelIndicatorOption;

	if dispelIndicatorOption == Enum.RaidDispelDisplayType.Disabled then
		return false;
	elseif aura.isHarmful and aura.dispelName and aura.dispelName ~= "" then
		if dispelIndicatorOption == Enum.RaidDispelDisplayType.DisplayAll then
			return true;
		elseif dispelIndicatorOption == Enum.RaidDispelDisplayType.DispellableByMe then
			return aura.canActivePlayerDispel;
		end
	end

	return false;
end

function PrivateAuraAnchorContainerMixin:CheckAddDispel(aura)
	if self:ShouldDisplayDispelIndicator(aura) then
		self.dispels[aura.dispelName][aura.auraInstanceID] = aura;
		self.dispelsChanged = true;
	end
end

function PrivateAuraAnchorContainerMixin:ProcessAura(aura)
	if aura.hideOnPartyFrames and self.isPartyFrameCached then
		return;
	end

	self:CheckAddDispel(aura);

	local displayOnlyDispellableDebuffs = self.containerSettings.displayOnlyDispellableDebuffs;
	local ignoreBuffs = self.containerSettings.ignoreBuffs;
	local ignoreDebuffs = self.containerSettings.ignoreDebuffs;
	local ignoreDispelDebuffs = self.containerSettings.ignoreDispelDebuffs;

	local auraType = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
	if (auraType == AuraUtil.AuraUpdateChangedType.Debuff) or (auraType == AuraUtil.AuraUpdateChangedType.Dispel) then
		self.debuffs[aura.auraInstanceID] = aura;
		self.debuffsChanged = true;
	elseif auraType == AuraUtil.AuraUpdateChangedType.Buff then
		self.buffs[aura.auraInstanceID] = aura;
		self.buffsChanged = true;
	end

	if AuraUtil.IsBigDefensive(aura) then
		self.bigDefensives[aura.auraInstanceID] = aura;
		self.buffsChanged = true;
	end
end

function PrivateAuraAnchorContainerMixin:ParseAllAuras(privateAuras)
	self.debuffsChanged = true;
	self.buffsChanged = true;
	self.dispelsChanged = true;

	self:ClearPriorityTables();

	local function HandleAura(aura)
		aura.isPrivate = false;
		self:ProcessAura(aura);
	end

	local batchCount = nil;
	local usePackedAura = true;
	AuraUtil.ForEachAura(self.watcher:GetUnit(), AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.watcher:GetUnit(), AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Raid), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.watcher:GetUnit(), AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), batchCount, HandleAura, usePackedAura);

	privateAuras = privateAuras or C_UnitAurasPrivate.GetAllPrivateAuras(self.watcher:GetUnit());

	for _, aura in pairs(privateAuras) do
		aura.isPrivate = true;
		self:ProcessAura(aura);
	end
end

function PrivateAuraAnchorContainerMixin:GetUpdatedAuraByInstance(privateSource, auraInstanceID)
	if privateSource then
		return C_UnitAurasPrivate.GetAuraDataByAuraInstanceIDPrivate(self.watcher:GetUnit(), auraInstanceID);
	else
		return AuraUtil.GetAuraDataByAuraInstanceID(self.watcher:GetUnit(), auraInstanceID);
	end
end

function PrivateAuraAnchorContainerMixin:CheckExistingDispelHasCorrectType(aura, auraInstanceID)
	-- This is the "we're updating" case...double check that if we have an existing entry that the types match
	-- Aura could be nil, auraInstanceID must be valid.
	for dispelName, dispelTable in pairs(self.dispels) do
		local existingDispel = dispelTable[auraInstanceID];
		if existingDispel then
			assertsafe(not aura or aura.dispelName == dispelName, "Dispel name mismatch for type %s with spell %s.", dispelName, tostring(aura and aura.spellId or 0));
			break;
		end
	end
end

function PrivateAuraAnchorContainerMixin:RemoveAura(auraInstanceID)
	if self.buffs[auraInstanceID] ~= nil then
		self.buffs[auraInstanceID] = nil;
		self.buffsChanged = true;
	end

	if self.bigDefensives[auraInstanceID] ~= nil then
		self.bigDefensives[auraInstanceID] = nil;
		self.buffsChanged = true;
	end

	if self.debuffs[auraInstanceID] ~= nil then
		self.debuffs[auraInstanceID] = nil;
		self.debuffsChanged = true;
	end

	for _, dispelTable in pairs(self.dispels) do
		if dispelTable[auraInstanceID] ~= nil then
			dispelTable[auraInstanceID] = nil;
			self.dispelsChanged = true;
			break;
		end
	end
end

function PrivateAuraAnchorContainerMixin:HandleUpdateInfo(privateSource, unitAuraUpdateInfo)
	if not unitAuraUpdateInfo or unitAuraUpdateInfo.isFullUpdate then
		self:ParseAllAuras();
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				aura.isPrivate = privateSource;
				self:ProcessAura(aura);
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				local updatedAura = self:GetUpdatedAuraByInstance(privateSource, auraInstanceID);
				self:CheckExistingDispelHasCorrectType(updatedAura, auraInstanceID);

				if updatedAura then
					updatedAura.isPrivate = privateSource;
					self:ProcessAura(updatedAura);
				else
					self:RemoveAura(auraInstanceID);
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				self:RemoveAura(auraInstanceID);
			end
		end
	end

	if self.buffsChanged or self.debuffsChanged or self.dispelsChanged then
		local skipParse = true;
		self.watcher:MarkDirty(skipParse);
	end
end

function PrivateAuraAnchorContainerMixin:HideFrameCollection(frameCollection, startingIndex)
	if frameCollection then
		for i = startingIndex or 1, #frameCollection do
			frameCollection[i]:Hide();
		end
	end
end

function PrivateAuraAnchorContainerMixin:UpdateSingleAuraFrame(auraContainer, containerIndex, aura)
	if not self:IsAuraInstanceIDBlocked(aura.auraInstanceID) then
		auraContainer[containerIndex]:Update(aura, self.watcher:GetUnit(), self);
		return containerIndex + 1;
	end

	return containerIndex;
end

function PrivateAuraAnchorContainerMixin:CheckUpdateBuffFrames()
	if self.buffsChanged then
		self.buffsChanged = false;

		-- Process center "big defensives" first because if one of those shows, then that aura should be skipped in the buffs section.
		if self.CenterDefensiveBuff then
			self:ClearBlockedAura(self.CenterDefensiveBuff:GetAuraInstanceID());
			if self.containerSettings.showBigDefensive and self.bigDefensives:Size() ~= 0 then
				local bigDefensiveAura = self.bigDefensives:GetTop();
				self:AddBlockedAura(bigDefensiveAura.auraInstanceID);

				self.CenterDefensiveBuff:Update(bigDefensiveAura, self.watcher:GetUnit(), self);
			else
				self.CenterDefensiveBuff:Hide();
			end
		end

		local frameNum = 1;
		local maxBuffs = self.containerSettings.maxBuffs;
		self.buffs:Iterate(function(auraInstanceID, aura)
			if frameNum > maxBuffs then
				return true;
			end

			frameNum = self:UpdateSingleAuraFrame(self.buffFrames, frameNum, aura);
			return false;
		end);

		self:HideFrameCollection(self.buffFrames, frameNum);
	end
end

function PrivateAuraAnchorContainerMixin:CheckUpdateDebuffFrames()
	if self.debuffsChanged then
		self.debuffsChanged = false;

		local frameNum = 1;
		local maxDebuffs = self.containerSettings.maxDebuffs;
		self.debuffs:Iterate(function(auraInstanceID, aura)
			if frameNum > maxDebuffs then
				return true;
			end

			frameNum = self:UpdateSingleAuraFrame(self.debuffFrames, frameNum, aura);
			return false;
		end);

		self:HideFrameCollection(self.debuffFrames, frameNum);
	end
end

function PrivateAuraAnchorContainerMixin:SetDispelDebuff(dispellDebuffFrame, aura)
	dispellDebuffFrame:Show();
	dispellDebuffFrame:SetAtlas(dispelAtlases[aura.dispelName]);
	dispellDebuffFrame.aura = aura;

	-- The behavior is that the last one set will "win"
	if self.containerSettings.showDispelIndicatorOverlay then
		self:SetDispelOverlayAura(aura);
	end
end

function PrivateAuraAnchorContainerMixin:CheckUpdateDispelIndicatorFrames(frame)
	if self.dispelsChanged then
		self.dispelsChanged = false;

		-- Preemptively hide the dispel overlay, it will be shown if there are any dispels to worry about.
		self:SetDispelOverlayAura(nil);

		local frameNum = 1;
		local maxDispelDebuffs = self.containerSettings.maxDispelDebuffs;
		for dispelName, auraTbl in pairs(self.dispels) do
			if frameNum > maxDispelDebuffs then
				break;
			end

			if auraTbl:Size() ~= 0 then
				local aura = auraTbl:GetTop();
				assertsafe(dispelName == aura.dispelName, "Dispel name mismatch for type %s with spell %d.", dispelName, aura.spellId);

				if aura.dispelName then
					local dispellDebuffFrame = self.DispelOverlay.dispelDebuffFrames[frameNum];
					self:SetDispelDebuff(dispellDebuffFrame, aura);
					frameNum = frameNum + 1;
				end
			end
		end

		self:HideFrameCollection(self.DispelOverlay.dispelDebuffFrames, frameNum);
	end
end

function PrivateAuraAnchorContainerMixin:Update()
	self:CheckUpdateBuffFrames();
	self:CheckUpdateDebuffFrames();
	self:CheckUpdateDispelIndicatorFrames();
end

function PrivateAuraAnchorContainerMixin:GetContainer()
	return self.container;
end

function PrivateAuraAnchorContainerMixin:RegisterContainerEventFrame()
	if not self.eventFrame then
		self.eventFrame = PrivateAuraEventFramePool:Acquire();
		assertsafe(self.eventFrame:GetScript("OnEvent") == nil, "Event frame acquired when it already had an OnEvent script, UnregisterContainerEventFrame wasn't called");

		-- Preempt the machinery that will register the eventFrame for events as needed
		self.eventFrame:Hide();

		self.eventFrame:SetScript("OnEvent", function(_, event, ...)
			if event == "UNIT_AURA" then
				local eventUnit, updateInfo = ...;
				assertsafe(UnitIsUnit(eventUnit, self.watcher:GetUnit()), "Received UNIT_AURA for wrong unit. Expected %s, got %s", self.watcher:GetUnit(), eventUnit);
				self:HandleUpdateInfo(false, updateInfo);
			elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
				self:HandleUpdateInfo(false, nil);
			elseif event == "UNIT_AURA_BLOCKED" then
				local eventUnit, auraInstanceID = ...;
				assertsafe(UnitIsUnit(eventUnit, self.watcher:GetUnit()), "Received UNIT_AURA_BLOCKED for wrong unit. Expected %s, got %s", self.watcher:GetUnit(), eventUnit);
				self:AddBlockedAura(auraInstanceID);
			elseif event == "UNIT_AURA_BLOCK_LIST_CLEARED" then
				local eventUnit = ...;
				assertsafe(UnitIsUnit(eventUnit, self.watcher:GetUnit()), "Received UNIT_AURA_BLOCK_LIST_CLEARED for wrong unit. Expected %s, got %s", self.watcher:GetUnit(), eventUnit);
				self:ClearBlockedAuras();
			end
		end);

		self.eventFrame:SetScript("OnShow", function()
			self:RegisterUnitEvents();
		end);

		self.eventFrame:SetScript("OnHide", function()
			self:UnregisterUnitEvents();
		end);

		self.eventFrame:SetParent(self:GetContainer());

		-- Trigger the event registration
		self.eventFrame:Show();
	end
end

function PrivateAuraAnchorContainerMixin:UnregisterContainerEventFrame()
	if self.eventFrame then
		self.eventFrame:SetScript("OnEvent", nil);
		self.eventFrame:SetScript("OnShow", nil);
		self.eventFrame:SetScript("OnHide", nil);
		self:UnregisterUnitEvents();

		PrivateAuraEventFramePool:Release(self.eventFrame);
		self.eventFrame = nil;
	end
end

function PrivateAuraAnchorContainerMixin:RegisterUnitEvents()
	self.eventFrame:RegisterUnitEvent("UNIT_AURA", self.watcher:GetUnit());
	self.eventFrame:RegisterUnitEvent("UNIT_AURA_BLOCKED", self.watcher:GetUnit());
	self.eventFrame:RegisterUnitEvent("UNIT_AURA_BLOCK_LIST_CLEARED", self.watcher:GetUnit());
	self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
end

function PrivateAuraAnchorContainerMixin:UnregisterUnitEvents()
	self.eventFrame:UnregisterEvent("UNIT_AURA");
	self.eventFrame:UnregisterEvent("UNIT_AURA_BLOCKED");
	self.eventFrame:UnregisterEvent("UNIT_AURA_BLOCK_LIST_CLEARED");
	self.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
	self.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
end

function PrivateAuraAnchorContainerMixin:RegisterSettingsChangeHandler()
	local container = self:GetContainer();
	if not assertsafe(container:GetScript("OnAttributeChanged") == nil, "Container frame already has an OnAttributeChanged script") then
		return;
	end

	container:SetScript("OnAttributeChanged", function(_, attribute, value)
		if attribute == "update-settings" then
			self:UpdateFromSettings();
		end
	end);
end

function PrivateAuraAnchorContainerMixin:UnregisterSettingsChangeHandler()
	local container = self:GetContainer();
	if not assertsafe(container:GetScript("OnAttributeChanged") ~= nil, "Container frame does not have an OnAttributeChanged script") then
		return;
	end

	container:SetScript("OnAttributeChanged", nil);
end

function PrivateAuraAnchorContainerMixin:ReserveSingleAuraFrame(frameLevel)
	local auraFrame = PrivateAuraFramePool:Acquire();
	auraFrame.hideDuration = self.containerSettings.alwaysHideDuration;
	auraFrame.useIconSizeForAuraSize = self.containerSettings.setAuraSizeToIconSize;
	auraFrame:Hide();
	auraFrame:SetParent(self:GetContainer());
	auraFrame:SetFrameLevel(frameLevel);

	return auraFrame;
end

function PrivateAuraAnchorContainerMixin:ReserveContainedAuraFrames(tableKey, count, frameLevel)
	assertsafe(self[tableKey] == nil, "Attempting to reserve aura frames for %s when they have not been released.", tableKey);
	local auraTable = {};
	self[tableKey] = auraTable;

	for i = 1, count do
		local auraFrame = self:ReserveSingleAuraFrame(frameLevel);
		auraFrame:UpdateSizeFromAnchor(nil, self); -- HACK: Ensure that the base size on buffs are set before using GridLayout.

		table.insert(auraTable, auraFrame);
	end
end

function PrivateAuraAnchorContainerMixin:ReleaseAuraFrames(tableKey)
	local auraTable = self[tableKey];
	self[tableKey] = nil;
	for _i, auraFrame in ipairs(auraTable) do
		PrivateAuraFramePool:Release(auraFrame);
	end
end

function PrivateAuraAnchorContainerMixin:ReserveAuraFramesForContainer()
	local dispelOverlayFrameLevel = 200;
	local debuffFrameLevel = 175;
	local bigDefensiveFrameLevel  = 150;
	local buffsFrameLevel = 125;

	self:ReserveContainedAuraFrames("debuffFrames", self.containerSettings.maxDebuffs, debuffFrameLevel);
	self:ReserveContainedAuraFrames("buffFrames", self.containerSettings.maxBuffs, buffsFrameLevel);

	if not self.CenterDefensiveBuff and self.containerSettings.showBigDefensive then
		self.CenterDefensiveBuff = self:ReserveSingleAuraFrame(bigDefensiveFrameLevel);
		self.CenterDefensiveBuff:SetParentKey("CenterDefensiveBuff"); -- TODO: Is this really necessary? I swear it didn't appear before I did this, look into it.
		self.CenterDefensiveBuff:ClearAllPoints();
		self.CenterDefensiveBuff:SetPoint("CENTER", self:GetContainer(), "CENTER", 0, 0);
		self.CenterDefensiveBuff:SetOverrideSize(self.containerSettings.bigDefensiveSize, self.containerSettings.bigDefensiveSize);
	end

	if not self.DispelOverlay then
		self.DispelOverlay = PrivateAuraDispelOverlayFramePool:Acquire();
		self.DispelOverlay:SetParent(self:GetContainer());
		self.DispelOverlay:SetAllPoints(self:GetContainer());
		self.DispelOverlay:SetParentKey("DispelOverlay"); -- TODO: Is this really necessary? I swear it didn't appear before I did this, look into it.
		self.DispelOverlay:SetFrameLevel(dispelOverlayFrameLevel);
	end
end

function PrivateAuraAnchorContainerMixin:ResizeReservedAuraFramesForContainer()
	if self.CenterDefensiveBuff then
		self.CenterDefensiveBuff:SetOverrideSize(self.containerSettings.bigDefensiveSize, self.containerSettings.bigDefensiveSize);
	end
end

function PrivateAuraAnchorContainerMixin:ResetReservedAuraFramesForContainer()
	self:ReleaseAuraFrames("buffFrames");
	self:ReleaseAuraFrames("debuffFrames");

	if self.DispelOverlay then
		PrivateAuraDispelOverlayFramePool:Release(self.DispelOverlay);
		self.DispelOverlay = nil;
	end

	if self.CenterDefensiveBuff then
		PrivateAuraFramePool:Release(self.CenterDefensiveBuff);
		self.CenterDefensiveBuff = nil;
	end
end

local PrivateAuraUnitFrameLayoutTemplates = {
	[Enum.RaidAuraOrganizationType.Legacy] = {
		Buffs = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomRightToTopLeft, 3),
			Anchor = CreateAnchor("BOTTOMRIGHT", "placeholder", "BOTTOMRIGHT", 0, 0),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return -3 - dispelOffset, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight + dispelOffset;
			end,
		},

		Debuffs = {
			useChainLayout = true,
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomLeftToTopRight, 3),
			Anchor = CreateAnchor("BOTTOMLEFT", "placeholder", "BOTTOMLEFT", 0, 0),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return 3 + dispelOffset, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight + dispelOffset;
			end,
		},

		Dispel = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.RightToLeft, 3),
			Anchor = CreateAnchor("TOPRIGHT", "placeholder", "TOPRIGHT", -3, -2),
		},

		DispelOverlay = {
			LayoutFunction = function(obj)
				if obj.DispelOverlay then
					obj.DispelOverlay:SetOrientation(DispelOverlayOrientation.VerticalTopToBottom, 0, 0);
				end
			end,
		},
	},

	[Enum.RaidAuraOrganizationType.BuffsTopDebuffsBottom] =	{
		Buffs = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, 6),
			Anchor = CreateAnchor("TOPRIGHT", "placeholder", "TOPRIGHT", -3, -3),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return -3 - dispelOffset, -3 - dispelOffset;
			end,
		},

		Debuffs = {
			useChainLayout = true,
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomRightToTopLeft, 3),
			Anchor = CreateAnchor("BOTTOMRIGHT", "placeholder", "BOTTOMRIGHT", 0, 0),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return -3 - dispelOffset, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight + dispelOffset;
			end,
		},

		Dispel = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomLeftToTopRight, 3),
			Anchor = CreateAnchor("BOTTOMLEFT", "placeholder", "BOTTOMLEFT", 0, 0),
			GetOffsets = function(obj)
				return 3, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight;
			end,
		},

		DispelOverlay = {
			LayoutFunction = function(obj)
				if obj.DispelOverlay then
					obj.DispelOverlay:SetOrientation(DispelOverlayOrientation.VerticalBottomToTop, 0, -obj.containerSettings.powerBarUsedHeight);
				end
			end,
		},
	},

	[Enum.RaidAuraOrganizationType.BuffsRightDebuffsLeft] = {
		Buffs = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomRightToTopLeft, 3),
			Anchor = CreateAnchor("BOTTOMRIGHT", "placeholder", "BOTTOMRIGHT", 0, 0),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return -3 - dispelOffset, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight + dispelOffset;
			end,
		},

		Debuffs = {
			useChainLayout = true,
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomLeftToTopRight, 3),
			Anchor = CreateAnchor("BOTTOMLEFT", "placeholder", "BOTTOMLEFT", 0, 0),
			GetOffsets = function(obj)
				local dispelOffset = obj.dispelOverlayAuraOffset or 0;
				return 3 + dispelOffset, CUF_AURA_BOTTOM_OFFSET + obj.containerSettings.powerBarUsedHeight + dispelOffset;
			end,
		},

		Dispel = {
			Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.LeftToRight, 3),
			Anchor = CreateAnchor("TOPLEFT", "placeholder", "TOPLEFT", 3, -2),
		},

		DispelOverlay = {
			LayoutFunction = function(obj)
				if obj.DispelOverlay then
					obj.DispelOverlay:SetOrientation(DispelOverlayOrientation.HorizontalLeftToRight, 0, 0);
				end
			end,
		},
	},
};

function PrivateAuraAnchorContainerMixin:UpdateContainerAnchor(layoutData)
	layoutData.Anchor:SetRelativeTo(self.container);

	if layoutData.GetOffsets then
		layoutData.Anchor:SetOffsets(layoutData.GetOffsets(self));
	end
end

function PrivateAuraAnchorContainerMixin:LayoutContainerFrames(frames, templateType, containerTypeKey)
	if not frames then
		return;
	end

	local layoutData = PrivateAuraUnitFrameLayoutTemplates[templateType][containerTypeKey];
	self:UpdateContainerAnchor(layoutData);

	for _index, containedFrame in pairs(frames) do
		containedFrame:ClearAllPoints();
	end

	if layoutData.useChainLayout then
		local resetAnchorOffsetsAfterInitialAnchor = true;
		AnchorUtil.ChainLayout(frames, layoutData.Anchor, layoutData.Layout, resetAnchorOffsetsAfterInitialAnchor);
	else
		AnchorUtil.GridLayout(frames, layoutData.Anchor, layoutData.Layout);
	end
end

function PrivateAuraAnchorContainerMixin:LayoutContainerFrameElement(element, templateType, containerTypeKey)
	if element then
		element:ClearAllPoints();
	end

	local layoutData = PrivateAuraUnitFrameLayoutTemplates[templateType][containerTypeKey];
	layoutData.LayoutFunction(self);
end

function PrivateAuraAnchorContainerMixin:SetDispelOverlayAura(aura)
	if self.DispelOverlay then
		local shown = aura and aura.dispelName;
		if shown ~= self.DispelOverlay:IsShown() then
			if shown then
				self.DispelOverlay:SetDispelType(aura.dispelName);
				self.DispelOverlay:Show();
				self.dispelOverlayAuraOffset = 2;
			else
				self.DispelOverlay:Hide();
				self.dispelOverlayAuraOffset = 0;
			end

			self:UpdateAuraFrameLayout();
		end
	end
end

function PrivateAuraAnchorContainerMixin:UpdateAuraFrameLayout()
	local auraOrganizationType = self.containerSettings.auraOrganizationType;
	self:LayoutContainerFrames(self.buffFrames, auraOrganizationType, "Buffs");
	self:LayoutContainerFrames(self.debuffFrames, auraOrganizationType, "Debuffs");
	self:LayoutContainerFrames(self.DispelOverlay.dispelDebuffFrames, auraOrganizationType, "Dispel");
	self:LayoutContainerFrameElement(nil, auraOrganizationType, "DispelOverlay");
end

function PrivateAuraAnchorContainerMixin:ShouldShowDispelType()
	return not self.containerSettings.suppressDispelBorderIcons;
end

function PrivateAuraAnchorContainerMixin:IsAuraInstanceIDBlocked(auraInstanceID)
	if auraInstanceID then
		return not not self.blockedAuras[auraInstanceID];
	end

	return false;
end

function PrivateAuraAnchorContainerMixin:AddBlockedAura(auraInstanceID)
	if auraInstanceID then
		self.blockedAuras[auraInstanceID] = true;
	end
end

function PrivateAuraAnchorContainerMixin:ClearBlockedAura(auraInstanceID)
	if auraInstanceID then
		self.blockedAuras[auraInstanceID] = nil;
	end
end

function PrivateAuraAnchorContainerMixin:ClearBlockedAuras()
	self.blockedAuras = {};
end

PrivateAuraAnchorSingleMixin = {};

function PrivateAuraAnchorSingleMixin:OnAnchorAdded(watcher)
	self.watcher = watcher;
	self:ReserveAuraFramesForContainer();
end

function PrivateAuraAnchorSingleMixin:OnAnchorRemoved()
	self:ResetReservedAuraFramesForContainer();
end

function PrivateAuraAnchorSingleMixin:ReserveAuraFramesForContainer()
	self.reservedAuraFrame = PrivateAuraFramePool:Acquire();
	self.reservedAuraFrame:SetFrameLevel(0);
end

function PrivateAuraAnchorSingleMixin:ResetReservedAuraFramesForContainer()
	if self.reservedAuraFrame then
		PrivateAuraFramePool:Release(self.reservedAuraFrame);
		self.reservedAuraFrame = nil;
	end
end

function PrivateAuraAnchorSingleMixin:Update()
	local auraInfo = self.watcher:GetAuraInfoForIndex(self.auraIndex);
	if auraInfo then
		local debuffFrame = self.reservedAuraFrame;
		C_UnitAurasPrivate.AnchorPrivateAura(debuffFrame, debuffFrame.Icon, debuffFrame.Duration, self.anchorID);

		debuffFrame:Update(auraInfo, self.watcher:GetUnit(), self);
	else
		self.reservedAuraFrame:Hide();
	end
end

function PrivateAuraAnchorSingleMixin:ParseAllAuras(_privateAuras)
	-- nop, only containers need to worry about this one
end

function PrivateAuraAnchorSingleMixin:HandleUpdateInfo(_privateSource, _updateInfo)
	-- nop, only containers need to worry about this one
end

function PrivateAuraAnchorSingleMixin:ShouldShowDispelType()
	return s_showDispelType;
end

--
-- UnitWatchers
--

PrivateAuras.unitWatchers = {};

-- Base private aura watcher for a particular unit
local PrivateAuraUnitWatcher = {};
PrivateAuras.PrivateAuraUnitWatcher = PrivateAuraUnitWatcher;

function PrivateAuraUnitWatcher:CreatePriorityTables()
	self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
end

function PrivateAuraUnitWatcher:Init(unit)
	assert(not PrivateAuras.unitWatchers[unit], "PrivateAuraUnitWatcher: Tried to instantiate for unit that already has a watcher.");

	self:CreatePriorityTables();

	self.unit = unit;
	self.anchors = {};

	self.callback = C_FunctionContainers.CreateCallback(function(updateInfo)
		if self:HandleUpdateInfo(true, updateInfo) then
			local skipParse = true;
			self:MarkDirty(skipParse);
		end
	end);

	C_UnitAurasPrivate.AddPrivateAuraUpdateCallback(unit, self.callback);

	self:MarkDirty();
end

function PrivateAuraUnitWatcher:GetUnit()
	return self.unit;
end

function PrivateAuraUnitWatcher:GetAuras()
	return self.auras;
end

function PrivateAuraUnitWatcher:ProcessAura(privateSource, aura)
	if self:ShouldAddAura(privateSource, aura) then
		aura.isPrivate = privateSource;
		self.auras[aura.auraInstanceID] = aura;
		return true;
	end

	return false;
end

function PrivateAuraUnitWatcher:ProcessAuras(privateSource, auras)
	local aurasAdded = false;
	for _, aura in ipairs(auras) do
		aurasAdded = self:ProcessAura(privateSource, aura) or aurasAdded;
	end
	return aurasAdded;
end

function PrivateAuraUnitWatcher:UpdateAuraByIndex()
	self.privateAurasByIndex = {};

	self.auras:Iterate(function(auraID, auraInfo)
		if auraInfo.isPrivate then
			table.insert(self.privateAurasByIndex, auraInfo);
		end

		return false; -- keep iterating
	end);
end

function PrivateAuraUnitWatcher:GetAuraInfoForIndex(index)
	return self.privateAurasByIndex[index];
end

function PrivateAuraUnitWatcher:ClearPriorityTables()
	self.auras:Clear();
end

function PrivateAuraUnitWatcher:ParseAllAuras()
	self:ClearPriorityTables();

	local privateAuras = C_UnitAurasPrivate.GetAllPrivateAuras(self.unit);

	self:ProcessAuras(true, privateAuras);
	self:UpdateAuraByIndex();

	for _, anchor in pairs(self.anchors) do
		anchor:ParseAllAuras(privateAuras);
	end
end

function PrivateAuraUnitWatcher:ShouldAddAura(privateSource, _auraInfo)
	-- For now, any private aura on the unit should always display
	return privateSource;
end

function PrivateAuraUnitWatcher:HandleUpdateInfo(privateAuraSource, updateInfo)
	if updateInfo.isFullUpdate then
		self:ParseAllAuras();
		return true;
	end

	local aurasChanged = false;

	if updateInfo.addedAuras then
		if self:ProcessAuras(privateAuraSource, updateInfo.addedAuras) then
			aurasChanged = true;
		end

		for _, aura in ipairs(updateInfo.addedAuras) do
			local appliedSounds = C_UnitAurasPrivate.GetAuraAppliedSoundsForSpell(self.unit, aura.spellId);
			for _, sound in pairs(appliedSounds) do
				PlaySoundFile(sound.soundFileName or sound.soundFileID, sound.outputChannel);
			end
		end
	end

	if updateInfo.updatedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
			if self.auras[auraInstanceID] ~= nil then
				local newAura = C_UnitAurasPrivate.GetAuraDataByAuraInstanceIDPrivate(self.unit, auraInstanceID);
				if newAura then
					newAura.isPrivate = privateAuraSource;
				end
				self.auras[auraInstanceID] = newAura;
				aurasChanged = true;
			end
		end
	end

	if updateInfo.removedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
			if self.auras[auraInstanceID] ~= nil then
				self.auras[auraInstanceID] = nil;
				aurasChanged = true;
			end
		end
	end

	self:UpdateAuraByIndex();

	for _, anchor in pairs(self.anchors) do
		anchor:HandleUpdateInfo(privateAuraSource, updateInfo);
	end

	return aurasChanged;
end

function PrivateAuraUnitWatcher:Clean()
	self.isDirty = false;

	-- This needs to be done first because the actual unit referenced by the watcher may have changed
	-- even if the unit token remains the same
	-- When an actual aura update happens parse isn't required, this is only to handle the case of
	-- group reorganization.
	if not self.skipParse then
		self:ParseAllAuras();
	end

	 self.skipParse = nil;

	for _, anchor in pairs(self.anchors) do
		anchor:Update();
	end
end

function PrivateAuraUnitWatcher:MarkDirty(skipParse)
	if not self.isDirty then
		self.isDirty = true;
		self.skipParse = skipParse;

		if not self.CleanClosure then
			self.CleanClosure = GenerateClosure(self.Clean, self);
		end

		C_Timer.After(0, self.CleanClosure);
	end
end

function PrivateAuraUnitWatcher:IsContainer()
	return self.container ~= nil;
end

function PrivateAuraUnitWatcher:AddAnchor(anchor)
	if anchor.unitToken == self:GetUnit() then
		self.anchors[anchor.anchorID] = anchor;

		if anchor.isContainer then
			Mixin(anchor, PrivateAuraAnchorContainerMixin);
		else
			Mixin(anchor, PrivateAuraAnchorSingleMixin);
		end

		anchor:OnAnchorAdded(self);

		-- Can't immediately instantiate because aura template may not be loaded yet
		self:MarkDirty();
	end
end

function PrivateAuraUnitWatcher:RemoveAnchor(anchorID)
	local anchor = self.anchors[anchorID];
	local removedAnchor = anchor ~= nil;

	if anchor then
		anchor:OnAnchorRemoved();

		self.anchors[anchorID] = nil;
		self:MarkDirty();
	end

	return removedAnchor;
end

function RaidBossEmoteFrame_OnLoad(self) -- Private version override
	RaidNotice_FadeInit(self.slot1);
	RaidNotice_FadeInit(self.slot2);
	self.timings = { };
	self.timings["RAID_NOTICE_MIN_HEIGHT"] = 20.0;
	self.timings["RAID_NOTICE_MAX_HEIGHT"] = 30.0;
	self.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0.2;
	self.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.4;

	self:RegisterEvent("CLEAR_BOSS_EMOTES");

	C_UnitAurasPrivate.SetPrivateWarningTextFrame(self);

	self.privateRaidBossMessageCallback = C_FunctionContainers.CreateCallback(function(chatType, text, playerName, displayTime, playSound)
		local body = format(text, playerName, playerName);	--No need for pflag, monsters can't be afk, dnd, or GMs.
		local color = C_ChatInfo.GetColorForChatType(chatType);
		RaidNotice_AddMessage(self, body, color, displayTime);
		if playSound then
			if chatType == "RAID_BOSS_WHISPER" then
				PlaySound(SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING);
			else
				PlaySound(SOUNDKIT.RAID_BOSS_EMOTE_WARNING);
			end
		end
	end);
	C_UnitAurasPrivate.SetPrivateRaidBossMessageCallback(self.privateRaidBossMessageCallback);
end

function RaidBossEmoteFrame_OnEvent(self, event, ...)  -- Private version override
	if event == "CLEAR_BOSS_EMOTES" then
		RaidNotice_Clear(self);
	end
end

CompactUnitFrameDispelOverlayMixin = {};

function CompactUnitFrameDispelOverlayMixin:SetDispelType(dispelType)
	AuraUtil.SetAuraBorderColor(self.Gradient, dispelType);
	AuraUtil.SetAuraBorderColor(self.Border, dispelType);
end

local dispelOverlayAtlasLookup =
{
	[DispelOverlayOrientation.VerticalTopToBottom] = {
		atlas = "_RaidFrame-Dispel-Highlight-Horizontal", uWrap = TextureKitConstants.AddressModeWrap, vWrap = TextureKitConstants.AddressModeClamp, left = 0, right = 1, bottom = 0, top = 1,
	},
	[DispelOverlayOrientation.VerticalBottomToTop] = {
		atlas = "_RaidFrame-Dispel-Highlight-Horizontal", uWrap = TextureKitConstants.AddressModeWrap, vWrap = TextureKitConstants.AddressModeClamp, left = 0, right = 1, bottom = 1, top = 0,
	},
	[DispelOverlayOrientation.HorizontalLeftToRight] = {
		atlas = "!RaidFrame-Dispel-Vertical", uWrap = TextureKitConstants.AddressModeClamp, vWrap = TextureKitConstants.AddressModeWrap, left = 0, right = 1, bottom = 0, top = 1,
	},
};

function CompactUnitFrameDispelOverlayMixin:SetOrientation(orientation, additionalXOffset, additionalYOffset)
	local setupData = dispelOverlayAtlasLookup[orientation];
	assertsafe(setupData ~= nil, "Unsupported orientation value %s", tostring(orientation));

	self.Gradient:SetTexCoord(setupData.left, setupData.right, setupData.bottom, setupData.top);
	SetTextureWithAddressModeOptions(self.Gradient, setupData.atlas, TextureKitConstants.IgnoreAtlasSize, setupData.uWrap, setupData.vWrap);

	self.Border:ClearAllPoints();
	self.Border:SetPoint("TOPLEFT");
	self.Border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", additionalXOffset, additionalYOffset);
end
