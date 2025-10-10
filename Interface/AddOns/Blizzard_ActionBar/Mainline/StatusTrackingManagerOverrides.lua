
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
	local barWidth = self:GetWidth() - 6;
	local barHeight = self:GetHeight() - 6;
	local function AddBar(barIndex, template)
		local bar = CreateFrame("FRAME", nil, self, template);
		bar.barIndex = barIndex;
		bar:ClearAllPoints();
		bar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 5);
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
