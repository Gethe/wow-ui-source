
function StatusTrackingManagerMixin:RegisterEvents()
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
	self:RegisterEvent("ENABLE_XP_GAIN");
	self:RegisterEvent("DISABLE_XP_GAIN");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRACKED_HOUSE_CHANGED");
	self:RegisterEvent("PLAYER_MAX_LEVEL_UPDATE");
	self:RegisterUnitEvent("UNIT_LEVEL", "player");
end

function StatusTrackingManagerMixin:CanShowBar(barIndex)
	if barIndex == StatusTrackingBarInfo.BarsEnum.Reputation then
		local watchedFactionData = C_Reputation.GetWatchedFactionData();
		return watchedFactionData and watchedFactionData.name ~= "";
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.Honor then
		return IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP();
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.Artifact then
		return HasArtifactEquipped() and not C_ArtifactUI.IsEquippedArtifactMaxed() and not C_ArtifactUI.IsEquippedArtifactDisabled();
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.Experience then
		return GameRulesUtil.CanShowExperienceBar();
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.Azerite then
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();
		return not C_AzeriteItem.IsAzeriteItemAtMaxLevel() and azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem);
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.HouseFavor then
		return C_Housing.GetTrackedHouseGuid();
	end

	return false;
end

function StatusTrackingBarContainerMixin:InitializeBars()
	self:SetSize(self:GetExpectedWidth(), STATUS_BAR_CONTAINER_HEIGHT);
	self:UpdateDividers(self:GetExpectedSegments());

	local barWidth = self:GetWidth() - STATUS_BAR_SIZE_ADJUSTMENT;
	local barHeight = self:GetHeight() - STATUS_BAR_SIZE_ADJUSTMENT;

	local function AddBar(barIndex, template)
		local bar = CreateFrame("FRAME", nil, self, template);
		bar.barIndex = barIndex;
		bar:ClearAllPoints();
		bar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, STATUS_BAR_SIZE_ADJUSTMENT - 1);
		bar.StatusBar:SetSize(barWidth, barHeight);
		bar:SetSize(barWidth, barHeight);

		if bar.fadeOutEntireBarAtMaxLevel then
			bar.StatusBar:SetLevelUpMaxAlphaAnimation(self.MaxLevelFadeOutAnimation);
		end

		self.bars[barIndex] = bar;
	end

	AddBar(StatusTrackingBarInfo.BarsEnum.Reputation, "ReputationStatusBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.Honor, "HonorStatusBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.Artifact, "ArtifactStatusBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.Experience, "ExpStatusBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.Azerite, "AzeriteBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.HouseFavor, "HouseFavorBarTemplate");
end

function StatusTrackingManagerMixin:CheckForLayoutChange()
	for i, barContainer in ipairs(self.barContainers) do
		local numSegments = barContainer:GetExpectedSegments();
		barContainer:ResizeContainerBars();
		barContainer:UpdateDividers(numSegments);
	end
end

function StatusTrackingBarContainerMixin:GetExpectedWidth()
	return InputUtil.IsGamepadUIEnabled() and STATUS_BAR_CONTAINER_WIDTH_GAMEPAD or STATUS_BAR_CONTAINER_WIDTH;
end

function StatusTrackingBarContainerMixin:GetExpectedSegments()
	return InputUtil.IsGamepadUIEnabled() and STATUS_BAR_NUM_SEGMENTS_GAMEPAD or STATUS_BAR_NUM_SEGMENTS;
end

function StatusTrackingBarContainerMixin:ResizeContainerBars()
	local barWidth = self:GetWidth() - STATUS_BAR_SIZE_ADJUSTMENT;
	local barHeight = self:GetHeight() - STATUS_BAR_SIZE_ADJUSTMENT;

	for i, bar in ipairs(self.bars) do
		bar:SetSize(barWidth, barHeight);
		bar.StatusBar:SetSize(barWidth, barHeight);
	end
end

function StatusTrackingBarContainerMixin:UpdateDividers(numSegments)
	if not self.HorizontalDividersPool then 
		self.HorizontalDividersPool = CreateFramePool("FRAME", self, "StatusBarDividerTemplate");
	end
	self.HorizontalDividersPool:ReleaseAll();

	if numSegments <= 1 then
		return;
	end

	local dividersPool = self.HorizontalDividersPool;
	local segmentWidth = self:GetWidth() / numSegments;

	for i = 1, numSegments - 1 do
		local xOffset = segmentWidth * i;
		local divider = dividersPool:Acquire();
		divider:SetPoint("LEFT", self, "LEFT", xOffset, 0);
		divider:Show();
	end
end
