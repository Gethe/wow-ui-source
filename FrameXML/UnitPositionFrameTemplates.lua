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
end

function UnitPositionFrameMixin:OnHide()
	self:ResetCurrentMouseOverUnits();
end

function UnitPositionFrameMixin:ResetCurrentMouseOverUnits()
	self.currentMouseOverUnits = {}
	self.currentMouseOverUnitCount = 0;
end

function UnitPositionFrameMixin:SetPlayerArrowSize(arrowSize)
	self.playerArrowSize = arrowSize;
end

function UnitPositionFrameMixin:GetPlayerArrowSize()
	return self.playerArrowSize;
end

function UnitPositionFrameMixin:SetGroupMemberSize(size)
	self.groupMemberSize = size;
end

function UnitPositionFrameMixin:GetGroupMemberSize()
	return self.groupMemberSize;
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