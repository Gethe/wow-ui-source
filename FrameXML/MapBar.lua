local function getEmbeddedFactionIcon()
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		return "|TInterface\\TargetingFrame\\UI-PVP-ALLIANCE:19:16:0:0:64:64:0:32:0:38|t";
	elseif ( factionGroup == "Horde" ) then
		return "|TInterface\\TargetingFrame\\UI-PVP-HORDE:18:19:0:0:64:64:0:38:0:36|t";
	else --Say what?
		return "";
	end
end

function MapBarFrame_OnLoad(self)
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("MAP_BAR_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.Spark:ClearAllPoints();
	self.Spark:SetPoint("CENTER", self:GetStatusBarTexture(), "RIGHT", 0, 0);
	MapBarFrame_Update(self);
	MapBarFrame_UpdateLayout(self);

	self.BarTexture:SetDrawLayer("BORDER");
end

function MapBarFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "WORLD_MAP_UPDATE" or
		event == "MAP_BAR_UPDATE" ) then
		MapBarFrame_Update(self);
	end
end

function MapBarFrame_OnEnter(self)
	local tag = C_MapBar.GetTag();
	local phase = C_MapBar.GetPhaseIndex();
	local participation = C_MapBar.GetParticipationPercentage();

	local title = MapBarFrame_GetString("TITLE", tag, phase);
	local tooltipText = MapBarFrame_GetString("TOOLTIP", tag, phase);
	local percentage = math.floor(100 * C_MapBar.GetCurrentValue() / C_MapBar.GetMaxValue());
	WorldMapTooltip.MB_using = true;
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
	WorldMapTooltip:SetText(format(MAP_BAR_TOOLTIP_TITLE, title, percentage), 1, 1, 1);
	WorldMapTooltip:AddLine(tooltipText, nil, nil, nil, true);
	WorldMapTooltip:AddLine(format(MAP_BAR_PARTICIPATION, getEmbeddedFactionIcon(), participation), 1, 1, 1);
	WorldMapTooltip:Show();
end

function MapBarFrame_OnLeave(self)
	WorldMapTooltip.MB_using = false;
	WorldMapTooltip:Hide();
end

function MapBarFrame_Update(self)
	if ( C_MapBar.BarIsShown() ) then
		local tag = C_MapBar.GetTag();
		local phase = C_MapBar.GetPhaseIndex();

		local title = MapBarFrame_GetString("TITLE", tag, phase);
		local desc = MapBarFrame_GetString("DESCRIPTION", tag, phase);
		if ( title and desc ) then
			self.Title:SetText(title);
			self.Description:SetText(desc);
			self:SetMinMaxValues(0, C_MapBar.GetMaxValue());
			self:SetValue(C_MapBar.GetCurrentValue());
			self:Show();
			return;
		end
	end
	self:Hide();
end

function MapBarFrame_UpdateLayout(self)
	self:SetFrameLevel(WorldMapPOIFrame:GetFrameLevel() + 1);
	if ( WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE ) then
		self:SetScale(1);
		self:SetPoint("TOPLEFT", WorldMapButton, "TOPLEFT", 150, -70);
	elseif ( WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE ) then
		self:SetScale(1);
		self:SetPoint("TOPLEFT", WorldMapButton, "TOPLEFT", 115, -65);
	else --We'll treat it like it's WORLDMAP_WINDOWED_SIZE
		self:SetScale(0.8);
		self:SetPoint("TOPLEFT", WorldMapButton, "TOPLEFT", 100, -85);
	end
end

function MapBarFrame_GetString(stringType, tag, phase)
	local factionGroup = UnitFactionGroup("player");
	local str = _G["MAP_BAR_"..tag.."_"..strupper(factionGroup).."_"..stringType..phase];
	if ( str ) then
		return str;
	end
	return _G["MAP_BAR_"..tag.."_"..stringType..phase];
end
