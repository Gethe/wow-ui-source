local MAX_GAME_TOOLTIP_AURAS = 5;
local AURA_TEXTURE_SETTINGS = {
	width = 16,
	height = 16,
	margin = { left = 2, right = 6, top = 2, bottom = 2 },
	anchor = Enum.TooltipTextureAnchor.LeftCenter,
};

-- Set up the aura watcher used in GameTooltip_WoWHackUpdateAuraWatcher
local s_auraWatcher = CreateFrame("FRAME");
do
	s_auraWatcher:Hide();
	s_auraWatcher:SetScript("OnShow", function(self)
		self:RegisterUnitEvent("UNIT_AURA", self.unit);
	end);

	s_auraWatcher:SetScript("OnHide", function(self)
		self:UnregisterEvent("UNIT_AURA");
	end);

	s_auraWatcher:SetScript("OnEvent", function(self)
		self:GetParent():RefreshData();
	end);
end

local function GameTooltip_WoWHackGetDisplayedUnit(tooltip)
	local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
	local tooltipData = tooltipInfo and tooltipInfo.tooltipData;
	local guid = tooltipData and tooltipData.guid;
	if guid then
		return UnitTokenFromGUID(guid);
	else
		return nil;
	end
end

local function GameTooltip_WoWHackHide(tooltip)
	return tooltip == GameTooltip;
end

local function GameTooltip_WoWHackGetAuras(tooltip)
	local unit = GameTooltip_WoWHackGetDisplayedUnit(tooltip);
	if not unit or not UnitExists(unit) then
		return nil;
	end

	local auras = C_UnitAuras.GetUnitAuras(unit, "HARMFUL", MAX_GAME_TOOLTIP_AURAS);
	local remainingAuraCount = MAX_GAME_TOOLTIP_AURAS - #auras;
	if remainingAuraCount > 0 then
		local helpfulAuras = C_UnitAuras.GetUnitAuras(unit, "HELPFUL", remainingAuraCount);
		for _, auraData in ipairs(helpfulAuras) do
			tinsert(auras, auraData);
		end
	end

	return auras, unit;
end

local function GameTooltip_WoWHackUpdateAuraWatcher(tooltip, unit)
	s_auraWatcher.unit = unit;
	GameTooltip_InsertFrame(tooltip, s_auraWatcher);
end

local function GameTooltip_WoWHackAddAuras(tooltip)
	if tooltip ~= GameTooltip then
		return;
	end

	local auras, unit = GameTooltip_WoWHackGetAuras(tooltip);
	if not auras then
		return;
	end

	for _, auraData in ipairs(auras) do
		tooltip:AddLine(secretwrap(auraData.name));
		tooltip:AddTexture(secretwrap(auraData.icon), AURA_TEXTURE_SETTINGS);
	end

	GameTooltip_WoWHackUpdateAuraWatcher(tooltip, unit);
end

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitLevel, GameTooltip_WoWHackHide);
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitType, GameTooltip_WoWHackHide);
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitThreat, GameTooltip_WoWHackHide);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, GameTooltip_WoWHackAddAuras);
