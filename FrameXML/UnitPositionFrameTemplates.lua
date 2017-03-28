UNIT_POSITION_FRAME_DEFAULT_PIN_SIZE = 40;
UNIT_POSITION_FRAME_DEFAULT_SUBLEVEL = 7;
UNIT_POSITION_FRAME_DEFAULT_TEXTURE = "WhiteCircle-RaidBlips";
UNIT_POSITION_FRAME_DEFAULT_SHOULD_SHOW_UNITS = true;
UNIT_POSITION_FRAME_DEFAULT_USE_CLASS_COLOR = true;

-- NOTE: This is only using a single set of PVPQuery timers.  There's no reason to have a different set per-instance.
PVPAFK_QUERY_DELAY_SECONDS = 5;
local pvpAFKQueryTimers = {}

function SetPVPAFKQueryDelaySeconds(seconds)
	PVPAFK_QUERY_DELAY_SECONDS = seconds;
end

function GetIsPVPInactive(unit, timeNowSeconds)
	if not UnitExists(unit) then
		return false;
	end

	local cachedData = pvpAFKQueryTimers[unit];
	if not cachedData then
		local inactive = PlayerIsPVPInactive(unit);
		pvpAFKQueryTimers[unit] = { inactive = inactive, nextQueryTimeSeconds = timeNowSeconds + PVPAFK_QUERY_DELAY_SECONDS };
		return inactive;
	end

	 if timeNowSeconds >= cachedData.nextQueryTimeSeconds then
		cachedData.inactive = PlayerIsPVPInactive(unit);
		cachedData.nextQueryTimeSeconds = timeNowSeconds + PVPAFK_QUERY_DELAY_SECONDS;
	 end

	 return cachedData.inactive;
end

function CheckColorOverrideForPVPInactive(unit, timeNow, r, g, b)
	if GetIsPVPInactive(unit, timeNow) then
		return 0.5, 0.2, 0.8;
	end

	return r, g, b;
end

UnitPositionFrameMixin = {}

function UnitPositionFrameMixin:OnLoad()
	self:ResetCurrentMouseOverUnits();
	self.excludedMouseOverUnits = {};
	self.unitAppearanceData = {};

	self:UpdateAppearanceData();

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function UnitPositionFrameMixin:OnHide()
	self:ResetCurrentMouseOverUnits();
end

function UnitPositionFrameMixin:OnEvent(event, ...)
	if event == "GROUP_ROSTER_UPDATE" then
		self:UpdateAppearanceData();
	end
end

function UnitPositionFrameMixin:UpdateAppearanceData()
	self:SetPinTexture("raid", "WhiteCircle-RaidBlips");
	self:SetPinTexture("party", IsInRaid() and "WhiteDotCircle-RaidBlips" or "WhiteCircle-RaidBlips");
end

function UnitPositionFrameMixin:ResetCurrentMouseOverUnits()
	self.currentMouseOverUnits = {}
	self.currentMouseOverUnitCount = 0;
end

function UnitPositionFrameMixin:GetOrCreateUnitAppearanceData(unitType)
	local data = self.unitAppearanceData[unitType];
	if not data then
		data = {
			size = UNIT_POSITION_FRAME_DEFAULT_PIN_SIZE,
			sublevel = UNIT_POSITION_FRAME_DEFAULT_SUBLEVEL,
			texture = UNIT_POSITION_FRAME_DEFAULT_TEXTURE,
			shouldShow = UNIT_POSITION_FRAME_DEFAULT_SHOULD_SHOW_UNITS,
			useClassColor = unitType ~= "player", -- UNIT_POSITION_FRAME_DEFAULT_USE_CLASS_COLOR
			showRotation = unitType == "player"; -- There's no point in trying to show rotation for anything except the local player.

		};

		self.unitAppearanceData[unitType] = data;
	end

	return data;
end

function UnitPositionFrameMixin:SetPinSize(unitType, size)
	self:GetOrCreateUnitAppearanceData(unitType).size = size;
end

function UnitPositionFrameMixin:SetPinTexture(unitType, texture)
	self:GetOrCreateUnitAppearanceData(unitType).texture = texture;
end

function UnitPositionFrameMixin:SetPinSubLevel(unitType, sublevel)
	self:GetOrCreateUnitAppearanceData(unitType).sublevel = sublevel;
end

function UnitPositionFrameMixin:SetShouldShowUnits(unitType, show)
	self:GetOrCreateUnitAppearanceData(unitType).shouldShow = show;
end

function UnitPositionFrameMixin:SetUseClassColor(unitType, useClassColor)
	self:GetOrCreateUnitAppearanceData(unitType).useClassColor = useClassColor;
end

function UnitPositionFrameMixin:GetCurrentMouseOverUnits()
	return self.currentMouseOverUnits;
end

function UnitPositionFrameMixin:IsMouseOverUnitExcluded(unit)
	return self.excludedMouseOverUnits[unit];
end

function UnitPositionFrameMixin:SetMouseOverUnitExcluded(unit, excluded)
	if excluded then
		self.excludedMouseOverUnits[unit] = excluded;
	else
		self.excludedMouseOverUnits[unit] = nil;
	end
end

local function UpdateMouseOverUnits(self, ...)
	local mouseOverUnitsChanged = false;
	local newMouseOverUnitCount = select("#", ...);

	-- If the counts match, the entire list needs to be checked
	-- Otherwise, the new list should just completely replace the old
	if (newMouseOverUnitCount == self.currentMouseOverUnitCount) then
		for i = 1, newMouseOverUnitCount do
			local unit = select(i, ...);
			if not self.currentMouseOverUnits[unit] then
				mouseOverUnitsChanged = true;
				break;
			end
		end
	else
		mouseOverUnitsChanged = true;
	end

	if mouseOverUnitsChanged then
		wipe(self.currentMouseOverUnits);
		self.currentMouseOverUnitCount = newMouseOverUnitCount;

		for i = 1, newMouseOverUnitCount do
			local unit = select(i, ...);
			self.currentMouseOverUnits[unit] = true;
		end
	end

	return mouseOverUnitsChanged;
end

function UnitPositionFrameMixin:UpdateUnitTooltips(tooltipFrame)
	local tooltipText = "";
	local prefix = "";
	local timeNow = GetTime();

	for unit in pairs(self.currentMouseOverUnits) do
		local unitName = UnitName(unit);
		if not self:IsMouseOverUnitExcluded(unit) then
			local formattedUnitName = GetIsPVPInactive(unit, timeNow) and format(PLAYER_IS_PVP_AFK, unitName) or unitName;
			tooltipText = tooltipText .. prefix .. formattedUnitName;

			prefix = "\n";
		end
	end

	if tooltipText ~= "" then
		SetMapTooltipPosition(tooltipFrame, self, true);
		tooltipFrame:SetText(tooltipText);
	elseif tooltipFrame:GetOwner() == self then
		tooltipFrame:ClearLines();
		tooltipFrame:Hide();
	end
end

function UnitPositionFrameMixin:UpdateTooltips(tooltipFrame)
	if UpdateMouseOverUnits(self, self:GetMouseOverUnits()) or (self:GetMouseOverUnits() and tooltipFrame:GetOwner() ~= self) then
		self:UpdateUnitTooltips(tooltipFrame);
	end
end

function UnitPositionFrameMixin:AddUnitInternal(timeNow, unit, appearanceData, callAtlasAPI)
	if not appearanceData.shouldShow then
		return;
	end

	local r, g, b = 1, 1, 1;

	if appearanceData.useClassColor then
		local class = select(2, UnitClass(unit));
		r, g, b = GetClassColor(class);
	end

	r, g, b = CheckColorOverrideForPVPInactive(unit, timeNow, r, g, b);

	if callAtlasAPI then
		self:AddUnitAtlas(unit, appearanceData.texture, appearanceData.size, appearanceData.size, r, g, b, 1);
	else
		self:AddUnit(unit, appearanceData.texture, appearanceData.size, appearanceData.size, r, g, b, 1, appearanceData.sublevel, appearanceData.showRotation);
	end
end

function UnitPositionFrameMixin:GetMemberCountAndUnitTokenPrefix()
	if IsInRaid() then
		return MAX_RAID_MEMBERS, "raid";
	elseif IsInGroup() then
		return MAX_PARTY_MEMBERS, "party";
	end

	return 0, "";
end

function UnitPositionFrameMixin:UpdatePlayerPins()
	local timeNow = GetTime();

	self:ClearUnits();
	self:AddUnitInternal(timeNow, "player", self:GetOrCreateUnitAppearanceData("player"));

	local memberCount, unitBase = self:GetMemberCountAndUnitTokenPrefix();
	local overridePartyType = (InActiveBattlefield() and IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME)) and LE_PARTY_CATEGORY_HOME or nil;
	local partyAppearance = self:GetOrCreateUnitAppearanceData("party");
	local raidAppearance = self:GetOrCreateUnitAppearanceData("raid");

	for i = 1, memberCount do
		local unit = unitBase..i;
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local appearanceData = UnitInSubgroup(unit, overridePartyType) and partyAppearance or raidAppearance;
			self:AddUnitInternal(timeNow, unit, appearanceData, true);
		end
	end

	self:FinalizeUnits();
end