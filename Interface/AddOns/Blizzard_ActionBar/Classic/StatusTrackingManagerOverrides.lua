
function StatusTrackingManagerMixin:RegisterEvents()
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("ENABLE_XP_GAIN");
	self:RegisterEvent("DISABLE_XP_GAIN");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("PLAYER_MAX_LEVEL_UPDATE");
	self:RegisterUnitEvent("UNIT_LEVEL", "player");
end

function StatusTrackingManagerMixin:CanShowBar(barIndex)
	if barIndex == StatusTrackingBarInfo.BarsEnum.Reputation then
		local watchedFactionData = C_Reputation.GetWatchedFactionData();
		return watchedFactionData and watchedFactionData.name ~= "";
	elseif barIndex == StatusTrackingBarInfo.BarsEnum.Experience then
		return GameRulesUtil.CanShowExperienceBar();
	end

	return false;
end

function StatusTrackingManagerMixin:UpdateBarVisuals()
	local firstBarContainer = self.barContainers[1];
	local inDefaultPosition = firstBarContainer:IsInDefaultPosition();
	local inDefaultPositionAndVisible = inDefaultPosition and firstBarContainer:IsShown();

	firstBarContainer:UseMainMenuBarArt(inDefaultPosition);

	MainMenuBar_SetMaxLevelBarShown(not inDefaultPositionAndVisible);

	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		self:SetScale(self.WrathScale);
	else
		self:SetScale(self.ClassicScale);
	end
end

function StatusTrackingBarContainerMixin:InitializeBars()
	local barWidth = self:GetWidth();
	local barHeight = self:GetHeight();
	local function AddBar(barIndex, template)
		local bar = CreateFrame("FRAME", nil, self, template);
		bar.barIndex = barIndex;
		bar:ClearAllPoints();
		bar:SetAllPoints(self);
		bar.StatusBar:SetSize(barWidth, barHeight);
		bar:SetSize(barWidth, barHeight);

		self.bars[barIndex] = bar;
	end

	AddBar(StatusTrackingBarInfo.BarsEnum.Reputation, "ReputationStatusBarTemplate");
	AddBar(StatusTrackingBarInfo.BarsEnum.Experience, "ExpStatusBarTemplate");
end

function StatusTrackingBarContainerMixin:UseMainMenuBarArt(useMainMenuBarArt)
	for index, texture in ipairs(self.MainMenuBarTextures) do
		texture:SetShown(useMainMenuBarArt);
	end
	for index, texture in ipairs(self.StandaloneTextures) do
		texture:SetShown(not useMainMenuBarArt);
	end
end
