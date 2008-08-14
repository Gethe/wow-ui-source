
NUM_THREAT_BARS = 5;

local function ThreatMeter_FindTableIndex(threatTable, isTanking, percentage)
	-- Do an insertion sort based on threat percentage
	for i = 1, threatTable.n do
		local t = threatTable[i];
		if ( isTanking or (not t.isTanking and (percentage > t.percentage)) ) then
			if ( threatTable.n < NUM_THREAT_BARS ) then
				threatTable.n = threatTable.n + 1;
			end
			t = threatTable[threatTable.n];
			for j = threatTable.n-1, i, -1 do
				threatTable[j+1] = threatTable[j];
			end
			threatTable[i] = t;
			return i;
		end
	end
	if ( threatTable.n < NUM_THREAT_BARS ) then
		threatTable.n = threatTable.n + 1;
		return threatTable.n;
	end	
end

function ThreatMeter_InsertTarget(threatTable, target, unit)
	local isTanking, status, percentage = UnitDetailedThreatSituation(target, unit);
	if ( percentage and percentage > 50 ) then
		local index = ThreatMeter_FindTableIndex(threatTable, isTanking, percentage);
		if ( index ) then
			local t = threatTable[index];
			t.unit = target;
			t.name = UnitName(target);
			t.isTanking = isTanking;
			t.percentage = percentage;
			t.r, t.g, t.b = GetThreatStatusColor(status);
		end
	end
end

function ThreatMeter_SetStatusBarIcon(icon, unit)
	if ( UnitIsUnit(unit, "player") ) then
		SetPortraitTexture(icon, unit);
		icon:SetTexCoord(0, 1, 0, 1);
		icon:SetVertexColor(1.0, 1.0, 1.0);
		icon:Show();
	else
		local index = GetRaidTargetIndex(unit);
		if ( index ) then
			icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
			SetRaidTargetIconTexture(icon, index);
			icon:SetVertexColor(1.0, 1.0, 1.0);
			icon:Show();
		elseif ( strfind(unit, "pet", 1, true) ) then
			icon:Hide();
		else
			local class, fileName = UnitClassBase(unit);
			icon:SetTexture("Interface\\Minimap\\ObjectIcons");
			icon:SetTexCoord(0.75, 0.875, 0.5, 1.0);
			local color = RAID_CLASS_COLORS[fileName];
			icon:SetVertexColor(color.r, color.g, color.b);
			icon:Show();
		end
	end
end

function ThreatMeter_Update(self)
	if ( not IsThreatWarningEnabled() or not GetCVarBool("showThreatMeter") ) then
		self:Hide();
		return;
	end

	-- See whether we should show the threat frame
	local unit;
	if ( UnitCanAttack("player", self.startingUnit) ) then
		unit = self.startingUnit;
	elseif ( UnitCanAttack("player", self.startingUnit.."target") ) then
		unit = self.startingUnit.."target";
	else
		self:Hide();
		return;
	end

	-- Add each target on the unit's threat list
	local threatTable = self.threatTable;
	threatTable.n = 0;
	if ( GetNumRaidMembers() > 0 ) then
		for i=1, MAX_RAID_MEMBERS do
			ThreatMeter_InsertTarget(threatTable, "raid"..i, unit);
			ThreatMeter_InsertTarget(threatTable, "raidpet"..i, unit);
		end
	elseif ( GetNumPartyMembers() > 0 ) then
		for i=1, MAX_PARTY_MEMBERS do
			ThreatMeter_InsertTarget(threatTable, "party"..i, unit);
			ThreatMeter_InsertTarget(threatTable, "partypet"..i, unit);
		end
		ThreatMeter_InsertTarget(threatTable, "player", unit);
		ThreatMeter_InsertTarget(threatTable, "pet", unit);
	else
		ThreatMeter_InsertTarget(threatTable, "player", unit);
		ThreatMeter_InsertTarget(threatTable, "pet", unit);
	end

	-- Hide the UI if there's no threat list
	if ( threatTable.n == 0 ) then
		self:Hide();
		return;
	end

	-- Show the status bars for the threat list
	local prefix = self:GetName();
	local tooltip = self.tooltip;
	for i=1, threatTable.n do
		local entry = threatTable[i];
		local statusBar = getglobal(prefix.."StatusBar"..i);
		if ( statusBar ) then
			statusBar.entry = entry;
			statusBar.name:SetText(entry.name);

			ThreatMeter_SetStatusBarIcon(statusBar.icon, entry.unit);

			-- Scale the value to have better range at the high end
			local value;
			local percentage = entry.percentage;
			if ( percentage <= 60 ) then
				value = percentage - 50;
			elseif ( percentage <= 70 ) then
				value = 10 + (percentage - 60) * 2;
			elseif ( percentage <= 80 ) then
				value = 30 + (percentage - 70) * 2;
			elseif ( percentage <= 90 ) then
				value = 50 + (percentage - 80) * 2;
			else
				value = 70 + (percentage - 90) * 3;
			end
			statusBar:SetValue(value);
			statusBar:SetStatusBarColor(entry.r, entry.g, entry.b);
			statusBar:Show();

			if ( tooltip.owner == statusBar ) then
				ThreatMeterStatusBar_UpdateTooltip(tooltip, entry);
			end
		end
	end
	for i = threatTable.n+1, NUM_THREAT_BARS do
		local statusBar = getglobal(prefix.."StatusBar"..i);
		if ( statusBar ) then
			statusBar:Hide();
		end
	end

	-- Show the player's status
	self.name:SetText(UnitName(unit));
	local index = GetRaidTargetIndex(unit);
	if ( index ) then
		SetRaidTargetIconTexture(self.icon, index);
		self.icon:Show();
	else
		self.icon:Hide();
	end
	local status = UnitThreatSituation("player", unit);
	self:SetBackdropBorderColor(GetThreatStatusColor(status));
	self:SetBackdropColor(GetThreatStatusColor(status));

	-- We're done!
	self.unit = unit;
	self.timer = 0.5;	-- Update every 1/2 second
	self:Show();
end

function ThreatMeter_OnLoad(self, unit)
	self:RegisterForDrag("LeftButton");
	self.UpdateTooltip = ThreatMeter_UpdateTooltip;

	if ( unit == "target" ) then
		self:RegisterEvent("PLAYER_TARGET_CHANGED");
	elseif ( unit == "focus" ) then
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	end
	self:RegisterEvent("UNIT_TARGET");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");

	local prefix = self:GetName();
	self.name = _G[prefix.."Name"];
	self.icon = _G[prefix.."Icon"];
	self.tooltip = _G[prefix.."Tooltip"];
	self.tooltip.text = _G[prefix.."TooltipText"];
	self.threatTable = {};
	for i = 1, NUM_THREAT_BARS do
		self.threatTable[i] = {};
	end
	self.startingUnit = unit;
end

function ThreatMeter_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" or
	     event == "PLAYER_FOCUS_CHANGED" or
	     (event == "UNIT_TARGET" and (...) == self.startingUnit) ) then
		-- Possibly change our hidden/shown status
		ThreatMeter_Update(self);
	else
		-- If we're visible, update on the next frame
		self.timer = nil;
	end
end

function ThreatMeter_OnUpdate(self, elapsed)
	if ( not self.timer or self.timer < elapsed ) then
		ThreatMeter_Update(self);
	else
		self.timer = self.timer - elapsed;
	end
end

function ThreatMeter_OnEnter(self)
	ThreatMeter_UpdateTooltip(self);
end

function ThreatMeter_OnLeave(self)
	GameTooltip:Hide();
end

function ThreatMeter_UpdateTooltip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetUnit(self.unit);
end

function ThreatMeterStatusBar_OnLoad(self)
	self:SetMinMaxValues(0, 100);
	self.name = getglobal(self:GetName().."Name");
	self.icon = getglobal(self:GetName().."Icon");
end

function ThreatMeterStatusBar_OnEnter(self)
	if ( not IsMouseButtonDown() ) then
		local tooltip = self:GetParent().tooltip;
		tooltip.owner = self;
		ThreatMeterStatusBar_UpdateTooltip(tooltip, self.entry);
		tooltip:SetPoint("LEFT", self, "RIGHT");
		tooltip:Show();
	end
end

function ThreatMeterStatusBar_OnLeave(self)
	local tooltip = self:GetParent().tooltip;
	tooltip.owner = nil;
	tooltip:Hide();
end

function ThreatMeterStatusBar_UpdateTooltip(tooltip, entry)
	tooltip.text:SetFormattedText("%d%%", math.floor(entry.percentage));
	tooltip:SetBackdropColor(entry.r, entry.g, entry.b);
end
