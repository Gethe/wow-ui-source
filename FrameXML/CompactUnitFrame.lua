--Widget Handlers
local OPTION_TABLE_NONE = {};
BOSS_DEBUFF_SIZE_INCREASE = 9;
CUF_READY_CHECK_DECAY_TIME = 11;
DISTANCE_THRESHOLD_SQUARED = 250*250;
CUF_NAME_SECTION_SIZE = 15;
CUF_AURA_BOTTOM_OFFSET = 2;

function CompactUnitFrame_OnLoad(self)
	-- Names are required for concatenation of compact unit frame names. Search for
	-- Name.."HealthBar" for examples. This is ignored by nameplates.
	if not self.ignoreCUFNameRequirement and not self:GetName() then
		self:Hide();
		error("CompactUnitFrames must have a name");
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_POWER_BAR_SHOW");
	self:RegisterEvent("UNIT_POWER_BAR_HIDE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED");
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED");
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED");
	self:RegisterEvent("UNIT_PHASE");
	self:RegisterEvent("UNIT_CTR_OPTIONS");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterEvent("INCOMING_SUMMON_CHANGED");
	-- also see CompactUnitFrame_UpdateUnitEvents for more events

	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self.maxDispelDebuffs = 0;
	CompactUnitFrame_SetOptionTable(self, OPTION_TABLE_NONE);

	if not self.disableMouse then
		CompactUnitFrame_SetUpClicks(self);
	end
end

function CompactUnitFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...;
	if ( event == self.updateAllEvent and (not self.updateAllFilter or self.updateAllFilter(self, event, ...)) ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
		CompactUnitFrame_UpdateName(self);
		CompactUnitFrame_UpdateWidgetsOnlyMode(self);
		CompactUnitFrame_UpdateHealthBorder(self);
		CompactUnitFrame_UpdateWidgetSet(self);
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
		CompactUnitFrame_UpdateAuras(self);	--We filter differently based on whether the player is in Combat, so we need to update when that changes.
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		CompactUnitFrame_UpdateRoleIcon(self);
	elseif ( event == "READY_CHECK" ) then
		CompactUnitFrame_UpdateReadyCheck(self);
	elseif ( event == "READY_CHECK_FINISHED" ) then
		CompactUnitFrame_FinishReadyCheck(self);
	elseif ( event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" ) then	--Alternate power info may now be available.
		CompactUnitFrame_UpdateMaxPower(self);
		CompactUnitFrame_UpdatePower(self);
		CompactUnitFrame_UpdatePowerColor(self);
	else
		local unitMatches = arg1 == self.unit or arg1 == self.displayedUnit;
		if ( unitMatches ) then
			if ( event == "UNIT_MAXHEALTH" ) then
				CompactUnitFrame_UpdateMaxHealth(self);
				CompactUnitFrame_UpdateHealth(self);
				CompactUnitFrame_UpdateHealPrediction(self);
			elseif ( event == "UNIT_HEALTH" ) then
				CompactUnitFrame_UpdateHealth(self);
				CompactUnitFrame_UpdateStatusText(self);
				CompactUnitFrame_UpdateHealPrediction(self);
			elseif ( event == "UNIT_MAXPOWER" ) then
				CompactUnitFrame_UpdateMaxPower(self);
				CompactUnitFrame_UpdatePower(self);
			elseif ( event == "UNIT_POWER_UPDATE" ) then
				CompactUnitFrame_UpdatePower(self);
			elseif ( event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_BAR_SHOW" or event == "UNIT_POWER_BAR_HIDE" ) then
				CompactUnitFrame_UpdateMaxPower(self);
				CompactUnitFrame_UpdatePower(self);
				CompactUnitFrame_UpdatePowerColor(self);
			elseif ( event == "UNIT_NAME_UPDATE" ) then
				CompactUnitFrame_UpdateName(self);
				CompactUnitFrame_UpdateHealth(self);		--This may signify that the unit is a new pet who replaced an old pet, and needs a health update
				CompactUnitFrame_UpdateHealthColor(self);	--This may signify that we now have the unit's class (the name cache entry has been received).
			elseif ( event == "UNIT_AURA" ) then
				CompactUnitFrame_UpdateAuras(self);
			elseif ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
				CompactUnitFrame_UpdateAggroHighlight(self);
				CompactUnitFrame_UpdateAggroFlash(self);
				CompactUnitFrame_UpdateHealthBorder(self);
			elseif ( event == "UNIT_THREAT_LIST_UPDATE" ) then
				if ( self.optionTable.considerSelectionInCombatAsHostile ) then
					CompactUnitFrame_UpdateHealthColor(self);
					CompactUnitFrame_UpdateName(self);
				end
				CompactUnitFrame_UpdateAggroFlash(self);
				CompactUnitFrame_UpdateHealthBorder(self);
			elseif ( event == "UNIT_CONNECTION" ) then
				--Might want to set the health/mana to max as well so it's easily visible? This happens unless the player is out of AOI.
				CompactUnitFrame_UpdateHealthColor(self);
				CompactUnitFrame_UpdatePowerColor(self);
				CompactUnitFrame_UpdateStatusText(self);
			elseif ( event == "UNIT_HEAL_PREDICTION" ) then
				CompactUnitFrame_UpdateHealPrediction(self);
			elseif ( event == "UNIT_PET" ) then
				CompactUnitFrame_UpdateAll(self);
			elseif ( event == "READY_CHECK_CONFIRM" ) then
				CompactUnitFrame_UpdateReadyCheck(self);
			elseif ( event == "INCOMING_RESURRECT_CHANGED" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			elseif ( event == "UNIT_OTHER_PARTY_CHANGED" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			elseif ( event == "UNIT_ABSORB_AMOUNT_CHANGED" ) then
				CompactUnitFrame_UpdateHealPrediction(self);
			elseif ( event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
				CompactUnitFrame_UpdateHealPrediction(self);
			elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
				CompactUnitFrame_UpdateStatusText(self);
			elseif ( event == "UNIT_PHASE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			elseif ( event == "GROUP_JOINED" ) then
				CompactUnitFrame_UpdateAggroFlash(self);
				CompactUnitFrame_UpdateHealthBorder(self);
			elseif ( event == "GROUP_LEFT" ) then
				CompactUnitFrame_UpdateHealthBorder(self);
			elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
				CompactUnitFrame_UpdateClassificationIndicator(self);
			elseif ( event == "INCOMING_SUMMON_CHANGED" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			end
		end

		if ( unitMatches or arg1 == "player" ) then
			if ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" ) then
				CompactUnitFrame_UpdateAll(self);
			end
		end
	end
end

--DEBUG FIXME - We should really try to avoid having OnUpdate on every frame. An event when going in/out of range would be greatly preferred.
function CompactUnitFrame_OnUpdate(self, elapsed)
	CompactUnitFrame_UpdateInRange(self);
	CompactUnitFrame_UpdateDistance(self);
	CompactUnitFrame_CheckReadyCheckDecay(self, elapsed);
end

--Externally accessed functions
function CompactUnitFrame_SetUnit(frame, unit)
	if ( unit ~= frame.unit or frame.hideCastbar ~= frame.optionTable.hideCastbar ) then
		frame.unit = unit;
		frame.displayedUnit = unit;	--May differ from unit if unit is in a vehicle.
		frame.inVehicle = false;
		frame.readyCheckStatus = nil
		frame.readyCheckDecay = nil;
		frame.isTanking = nil;
		frame.hideCastbar = frame.optionTable.hideCastbar;
		frame.healthBar.healthBackground = nil;
		frame:SetAttribute("unit", unit);
		if ( unit ) then
			CompactUnitFrame_RegisterEvents(frame);
		else
			CompactUnitFrame_UnregisterEvents(frame);
		end
		if ( unit and not frame.optionTable.hideCastbar ) then
			if ( frame.castBar ) then
				CastingBarFrame_SetUnit(frame.castBar, unit, false, true);
			end
		else
			if ( frame.castBar ) then
				CastingBarFrame_SetUnit(frame.castBar, nil, nil, nil);
			end
		end
		CompactUnitFrame_UpdateAll(frame);
	end
end

--PLEEEEEASE FIX ME. This makes me very very sad. (Unfortunately, there isn't a great way to deal with the lack of "raid1targettarget" events though)
function CompactUnitFrame_SetUpdateAllOnUpdate(self, doUpdate)
	if ( doUpdate ) then
		if ( not self.onUpdateFrame ) then
			self.onUpdateFrame = CreateFrame("Frame")	--Need to use this so UpdateAll is called even when the frame is hidden.
			self.onUpdateFrame.func = function(updateFrame, elapsed) if ( self.displayedUnit ) then CompactUnitFrame_UpdateAll(self) end end;
		end
		self.onUpdateFrame:SetScript("OnUpdate", self.onUpdateFrame.func);
	else
		if ( self.onUpdateFrame ) then
			self.onUpdateFrame:SetScript("OnUpdate", nil);
		end
	end
end

--Things you'll have to set up to get everything looking right:
--1. Frame size
--2. Health/Mana bar positions
--3. Health/Mana bar textures (also, optionally, background textures)
--4. Name position
--5. Buff/Debuff/Dispellable positions
--6. Call CompactUnitFrame_SetMaxBuffs, _SetMaxDebuffs, and _SetMaxDispelDebuffs. (If you're setting it to greater than the default, make sure to create new buff/debuff frames and position them.)
--7. Selection highlight position and texture.
--8. Aggro highlight position and texture
--9. Role icon position
function CompactUnitFrame_SetUpFrame(frame, func)
	func(frame);
	CompactUnitFrame_UpdateAll(frame);
end

function CompactUnitFrame_SetOptionTable(frame, optionTable)
	frame.optionTable = optionTable;
	--CompactUnitFrame_UpdateAll(frame);
end

function CompactUnitFrame_RegisterEvents(frame)
	local onEventHandler = frame.OnEvent or CompactUnitFrame_OnEvent;
	frame:SetScript("OnEvent", onEventHandler);

	CompactUnitFrame_UpdateUnitEvents(frame);

	local onUpdate = frame.OnUpdate or CompactUnitFrame_OnUpdate;
	frame:SetScript("OnUpdate", onUpdate);
end

function CompactUnitFrame_UpdateUnitEvents(frame)
	local unit = frame.unit;
	local displayedUnit;
	if ( unit ~= frame.displayedUnit ) then
		displayedUnit = frame.displayedUnit;
	end
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_HEALTH", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_MAXPOWER", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit, displayedUnit);
	frame:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", unit, displayedUnit);
	frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", unit, displayedUnit);
end

function CompactUnitFrame_UnregisterEvents(frame)
	frame:SetScript("OnEvent", nil);
	frame:SetScript("OnUpdate", nil);
end

function CompactUnitFrame_SetUpClicks(frame)
	frame:SetAttribute("*type1", "target");
    frame:SetAttribute("*type2", "menu");
	--NOTE: Make sure you also change the CompactAuraTemplate. (It has to be registered for clicks to be able to pass them through.)
	frame:RegisterForClicks("LeftButtonDown", "RightButtonUp");
	CompactUnitFrame_SetMenuFunc(frame, CompactUnitFrameDropDown_Initialize);
end

function CompactUnitFrame_SetMenuFunc(frame, menuFunc)
	UIDropDownMenu_Initialize(frame.dropDown, menuFunc, "MENU");
	frame.menu = function()
		ToggleDropDownMenu(1, nil, frame.dropDown, frame:GetName(), 0, 0);
	end
end

function CompactUnitFrame_SetMaxBuffs(frame, numBuffs)
	frame.maxBuffs = numBuffs;
end

function CompactUnitFrame_SetMaxDebuffs(frame, numDebuffs)
	frame.maxDebuffs = numDebuffs;
end

function CompactUnitFrame_SetMaxDispelDebuffs(frame, numDispelDebuffs)
	frame.maxDispelDebuffs = numDispelDebuffs;
end

function CompactUnitFrame_SetUpdateAllEvent(frame, updateAllEvent, updateAllFilter)
	if ( frame.updateAllEvent ) then
		frame:UnregisterEvent(frame.updateAllEvent);
	end
	frame.updateAllEvent = updateAllEvent;
	frame.updateAllFilter = updateAllFilter;
	frame:RegisterEvent(updateAllEvent);
end

--Internally accessed functions

--Update Functions
function CompactUnitFrame_UpdateAll(frame)
	CompactUnitFrame_UpdateInVehicle(frame);
	CompactUnitFrame_UpdateVisible(frame);
	if ( UnitExists(frame.displayedUnit) ) then
		CompactUnitFrame_UpdateMaxHealth(frame);
		CompactUnitFrame_UpdateHealth(frame);
		CompactUnitFrame_UpdateHealthColor(frame);
		CompactUnitFrame_UpdateMaxPower(frame);
		CompactUnitFrame_UpdatePower(frame);
		CompactUnitFrame_UpdatePowerColor(frame);
		CompactUnitFrame_UpdateName(frame);
		CompactUnitFrame_UpdateWidgetsOnlyMode(frame);
		CompactUnitFrame_UpdateSelectionHighlight(frame);
		CompactUnitFrame_UpdateAggroHighlight(frame);
		CompactUnitFrame_UpdateAggroFlash(frame);
		CompactUnitFrame_UpdateHealthBorder(frame);
		CompactUnitFrame_UpdateInRange(frame);
		CompactUnitFrame_UpdateStatusText(frame);
		CompactUnitFrame_UpdateHealPrediction(frame);
		CompactUnitFrame_UpdateRoleIcon(frame);
		CompactUnitFrame_UpdateReadyCheck(frame);
		CompactUnitFrame_UpdateAuras(frame);
		CompactUnitFrame_UpdateCenterStatusIcon(frame);
		CompactUnitFrame_UpdateClassificationIndicator(frame);
		CompactUnitFrame_UpdateWidgetSet(frame);
	end
end

function CompactUnitFrame_UpdateInVehicle(frame)
	local shouldTargetVehicle = UnitHasVehicleUI(frame.unit);
	local unitVehicleToken;

	if ( shouldTargetVehicle ) then
		local raidID = UnitInRaid(frame.unit);
		if ( raidID and not UnitTargetsVehicleInRaidUI(frame.unit) ) then
			shouldTargetVehicle = false;
		end
	end

	if ( shouldTargetVehicle ) then
		local prefix, id, suffix = string.match(frame.unit, "([^%d]+)([%d]*)(.*)")
		unitVehicleToken = prefix.."pet"..id..suffix;
		if ( not UnitExists(unitVehicleToken) ) then
			shouldTargetVehicle = false;
		end
	end

	if ( shouldTargetVehicle ) then
		if ( not frame.hasValidVehicleDisplay ) then
			frame.hasValidVehicleDisplay = true;
			frame.displayedUnit = unitVehicleToken;
			frame:SetAttribute("unit", frame.displayedUnit);
			CompactUnitFrame_UpdateUnitEvents(frame);
		end
	else
		if ( frame.hasValidVehicleDisplay ) then
			frame.hasValidVehicleDisplay = false;
			frame.displayedUnit = frame.unit;
			frame:SetAttribute("unit", frame.displayedUnit);
			CompactUnitFrame_UpdateUnitEvents(frame);
		end
	end
end

function CompactUnitFrame_UpdateVisible(frame)
	if ( UnitExists(frame.unit) or UnitExists(frame.displayedUnit) ) then
		if ( not frame.unitExists ) then
			frame.newUnit = true;
		end

		frame.unitExists = true;
		frame:Show();
	else
		CompactUnitFrame_ClearWidgetSet(frame);
		frame:Hide();
		frame.unitExists = false;
	end
end

function CompactUnitFrame_IsTapDenied(frame)
	return frame.optionTable.greyOutWhenTapDenied and not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit);
end

local function IsOnThreatList(threatStatus)
	return threatStatus ~= nil
end

function CompactUnitFrame_IsOnThreatListWithPlayer(unit)
	local _, threatStatus = UnitDetailedThreatSituation("player", unit);
	return IsOnThreatList(threatStatus);
end

function CompactUnitFrame_UpdateHealthColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		if ( frame.optionTable.healthBarColorOverride ) then
			local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
		else
			--Try to color it by class.
			local localizedClass, englishClass = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[englishClass];
			--debug
			--classColor = RAID_CLASS_COLORS["PRIEST"];
			if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) or UnitTreatAsPlayerForDisplay(frame.unit)) and classColor and frame.optionTable.useClassColors ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = 0.9, 0.9, 0.9;
			elseif ( frame.optionTable.colorHealthBySelection ) then
				-- Use color based on the type of unit (neutral, etc.)
				if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
					r, g, b = 1.0, 0.0, 0.0;
				elseif ( UnitIsPlayer(frame.displayedUnit) and UnitIsFriend("player", frame.displayedUnit) ) then
					-- We don't want to use the selection color for friendly player nameplates because
					-- it doesn't show player health clearly enough.
					r, g, b = 0.667, 0.667, 1.0;
				else
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
				end
			elseif ( UnitIsFriend("player", frame.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
		frame.healthBar:SetStatusBarColor(r, g, b);

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b);
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1);
		end

		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b;
	end
end

function CompactUnitFrame_UpdateMaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	if ( frame.optionTable.smoothHealthUpdates ) then
		frame.healthBar:SetMinMaxSmoothedValue(0, maxHealth);
	else
		frame.healthBar:SetMinMaxValues(0, maxHealth);
	end

	CompactUnitFrame_UpdateHealPrediction(frame);
end

function CompactUnitFrame_UpdateHealth(frame)
	local health = UnitHealth(frame.displayedUnit);
	if ( frame.optionTable.smoothHealthUpdates ) then
		if ( frame.newUnit ) then
			frame.healthBar:ResetSmoothedValue(health);
			frame.newUnit = false;
		else
			frame.healthBar:SetSmoothedValue(health);
		end
	else
		PixelUtil.SetStatusBarValue(frame.healthBar, health);
	end
end

local function CompactUnitFrame_GetDisplayedPowerID(frame)
	local barInfo = GetUnitPowerBarInfo(frame.displayedUnit);
	if ( barInfo and barInfo.showOnRaid and (UnitInParty(frame.unit) or UnitInRaid(frame.unit)) ) then
		return ALTERNATE_POWER_INDEX;
	else
		return (UnitPowerType(frame.displayedUnit));
	end
end

function CompactUnitFrame_UpdateMaxPower(frame)
	if frame.powerBar then
		frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.displayedUnit, CompactUnitFrame_GetDisplayedPowerID(frame)));
	end
end

function CompactUnitFrame_UpdatePower(frame)
	if frame.powerBar then
		PixelUtil.SetStatusBarValue(frame.powerBar, UnitPower(frame.displayedUnit, CompactUnitFrame_GetDisplayedPowerID(frame)));
	end
end

function CompactUnitFrame_UpdatePowerColor(frame)
	if not frame.powerBar then
		return;
	end

	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Set it to the proper power type color.
		local barInfo = GetUnitPowerBarInfo(frame.unit);
		if ( barInfo and barInfo.showOnRaid ) then
			r, g, b = 0.7, 0.7, 0.6;
		else
			local powerType, powerToken, altR, altG, altB = UnitPowerType(frame.displayedUnit);
			local prefix = _G[powerToken];
			local info = PowerBarColor[powerToken];
			if ( info ) then
					r, g, b = info.r, info.g, info.b;
			else
				if ( not altR) then
					-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
					info = PowerBarColor[powerType] or PowerBarColor["MANA"];
					r, g, b = info.r, info.g, info.b;
				else
					r, g, b = altR, altG, altB;
				end
			end
		end
	end
	frame.powerBar:SetStatusBarColor(r, g, b);
end

function ShouldShowName(frame)
	if UnitNameplateShowsWidgetsOnly(frame.unit) then
		return false;
	end
	if ( frame.optionTable.displayName ) then
		local failedRequirement = false;
		if ( frame.optionTable.displayNameByPlayerNameRules ) then
			if ( UnitShouldDisplayName(frame.unit) ) then
				return true;
			end
			failedRequirement = true;
		end

		if ( frame.optionTable.displayNameWhenSelected ) then
			if ( UnitIsUnit(frame.unit, "target") ) then
				return true;
			end
			failedRequirement = true;
		end

		return not failedRequirement;
	end

	return false;
end

function CompactUnitFrame_UpdateWidgetsOnlyMode(frame)
	local inWidgetsOnlyMode = UnitNameplateShowsWidgetsOnly(frame.unit);

	frame.healthBar:SetShown(not inWidgetsOnlyMode and not frame.hideHealthbar);

	if frame.castBar and not frame.optionTable.hideCastbar then
		if inWidgetsOnlyMode then
			CastingBarFrame_SetUnit(frame.castBar, nil, nil, nil);
			frame.hideCastbar = true;
		else
			CastingBarFrame_SetUnit(frame.castBar, frame.unit, false, true);
		end
	end

	if frame.BuffFrame then
		frame.BuffFrame:SetShown(not inWidgetsOnlyMode);
	end

	if frame.ClassificationFrame then
		frame.ClassificationFrame:SetShown(not inWidgetsOnlyMode);
	end

	if frame.RaidTargetFrame then
		frame.RaidTargetFrame:SetShown(not inWidgetsOnlyMode);
	end

	if frame.WidgetContainer then
		frame.WidgetContainer:ClearAllPoints();
		if inWidgetsOnlyMode then
			PixelUtil.SetPoint(frame.WidgetContainer, "BOTTOM", frame, "BOTTOM", 0, 0);
		else
			PixelUtil.SetPoint(frame.WidgetContainer, "TOP", frame.castBar, "BOTTOM", 0, 0);
		end
	end
end

function CompactUnitFrame_UpdateName(frame)
	if frame.UpdateNameOverride and frame:UpdateNameOverride() then
		return;
	end

	if ( not ShouldShowName(frame) ) then
		frame.name:Hide();
	else
		local name = GetUnitName(frame.unit, true);
		if ( C_Commentator.IsSpectating() and name ) then
			local overrideName = C_Commentator.GetPlayerOverrideName(name);
			if overrideName then
				name = overrideName;
			end
		end

		frame.name:SetText(name);

		if ( CompactUnitFrame_IsTapDenied(frame) ) then
			-- Use grey if not a player and can't get tap on unit
			frame.name:SetVertexColor(0.5, 0.5, 0.5);
		elseif ( frame.optionTable.colorNameBySelection ) then
			if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
				frame.name:SetVertexColor(1.0, 0.0, 0.0);
			else
				frame.name:SetVertexColor(UnitSelectionColor(frame.unit, frame.optionTable.colorNameWithExtendedColors));
			end
		end

		frame.name:Show();
	end
end

function CompactUnitFrame_UpdateSelectionHighlight(frame)
	if ( not frame.optionTable.displaySelectionHighlight ) then
		frame.selectionHighlight:Hide();
		return;
	end

	if ( UnitIsUnit(frame.displayedUnit, "target") ) then
		frame.selectionHighlight:Show();
	else
		frame.selectionHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateAggroHighlight(frame)
	if ( not frame.optionTable.displayAggroHighlight ) then
		if ( not frame.optionTable.playLoseAggroHighlight ) then
			frame.aggroHighlight:Hide();
		end
		return;
	end

	local status = UnitThreatSituation(frame.displayedUnit);
	if ( status and status > 0 ) then
		frame.aggroHighlight:SetVertexColor(GetThreatStatusColor(status));
		frame.aggroHighlight:Show();
	else
		frame.aggroHighlight:Hide();
	end
end

local function IsPlayerEffectivelyTank()
	local assignedRole = UnitGroupRolesAssigned("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return spec and GetSpecializationRole(spec) == "TANK";
	end

	return assignedRole == "TANK";
end

local function SetBorderColor(frame, r, g, b, a)
	frame.healthBar.border:SetVertexColor(r, g, b, a);
	if frame.castBar and frame.castBar.border then
		frame.castBar.border:SetVertexColor(r, g, b, a);
	end
end

function CompactUnitFrame_UpdateHealthBorder(frame)
	if frame.UpdateHealthBorderOverride and frame:UpdateHealthBorderOverride() then
		return;
	end

	if frame.optionTable.selectedBorderColor and UnitIsUnit(frame.displayedUnit, "target") then
		SetBorderColor(frame, frame.optionTable.selectedBorderColor:GetRGBA());
		return;
	end

	if frame.optionTable.tankBorderColor and IsInGroup() and IsPlayerEffectivelyTank() then
		local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit);
		local showTankingColor = (not isTanking) and IsOnThreatList(threatStatus) and IsInGroup();
		if showTankingColor then
			SetBorderColor(frame, frame.optionTable.tankBorderColor:GetRGBA());
			return;
		end
	end

	if frame.optionTable.defaultBorderColor then
		SetBorderColor(frame, frame.optionTable.defaultBorderColor:GetRGBA());
		return;
	end
end

function CompactUnitFrame_UpdateAggroFlash(frame)
	if ( frame.optionTable.displayAggroHighlight or not frame.optionTable.playLoseAggroHighlight ) then
		return;
	end

	if ( not IsPlayerEffectivelyTank() ) then
		return;
	end

	local isTanking = UnitDetailedThreatSituation("player", frame.displayedUnit);
	if ( frame.isTanking ~= isTanking ) then
		if ( frame.isTanking and not isTanking ) then
			frame.aggroHighlight:Show();
			frame.LoseAggroAnim:Play();
		end
		frame.isTanking = isTanking;
	end
	if ( not frame.LoseAggroAnim:IsPlaying() ) then
		frame.aggroHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateInRange(frame)
	if ( not frame.optionTable.fadeOutOfRange ) then
		return;
	end

	local inRange, checkedRange = UnitInRange(frame.displayedUnit);
	if ( checkedRange and not inRange ) then	--If we weren't able to check the range for some reason, we'll just treat them as in-range (for example, enemy units)
		frame:SetAlpha(0.55);
	else
		frame:SetAlpha(1);
	end
end

function CompactUnitFrame_UpdateDistance(frame)
	local distance, checkedDistance = UnitDistanceSquared(frame.displayedUnit);

	if ( checkedDistance ) then
		local inDistance = distance < DISTANCE_THRESHOLD_SQUARED;
		if ( inDistance ~= frame.inDistance ) then
			frame.inDistance = inDistance;
			CompactUnitFrame_UpdateCenterStatusIcon(frame);
		end
	end
end

function CompactUnitFrame_UpdateStatusText(frame)
	if ( not frame.statusText ) then
		return;
	end
	if ( not frame.optionTable.displayStatusText ) then
		frame.statusText:Hide();
		return;
	end

	if ( not UnitIsConnected(frame.unit) ) then
		frame.statusText:SetText(PLAYER_OFFLINE)
		frame.statusText:Show();
	elseif ( UnitIsDeadOrGhost(frame.displayedUnit) ) then
		frame.statusText:SetText(DEAD);
		frame.statusText:Show();
	elseif ( frame.optionTable.healthText == "health" ) then
		frame.statusText:SetText(UnitHealth(frame.displayedUnit));
		frame.statusText:Show();
	elseif ( frame.optionTable.healthText == "losthealth" ) then
		local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit);
		if ( healthLost > 0 ) then
			frame.statusText:SetFormattedText(LOST_HEALTH, healthLost);
			frame.statusText:Show();
		else
			frame.statusText:Hide();
		end
	elseif ( (frame.optionTable.healthText == "perc") and (UnitHealthMax(frame.displayedUnit) > 0) ) then
		local perc = math.ceil(100 * (UnitHealth(frame.displayedUnit)/UnitHealthMax(frame.displayedUnit)));
		frame.statusText:SetFormattedText("%d%%", perc);
		frame.statusText:Show();
	else
		frame.statusText:Hide();
	end
end

local fakeIndex = 1;
local fakeSetup = {
	{
		myHeal = 1000,
		allHeal = 1500,
		absorb = 1200,
		healAbsorb = 0,
		healthMult = .5;
	},
	{
		myHeal = 2500,
		allHeal = 5000,
		absorb = 2000,
		healAbsorb = 12000,
		healthMult = .5;
	}
};

--WARNING: This function is very similar to the function UnitFrameHealPredictionBars_Update in UnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
local MAX_INCOMING_HEAL_OVERFLOW = 1.05;
function CompactUnitFrame_UpdateHealPrediction(frame)
	--if not frame.fakeIndex then
	--	frame.fakeIndex = fakeIndex;
	--	fakeIndex = fakeIndex + 1;
	--	if fakeIndex > #fakeSetup then
	--		fakeIndex = 1;
	--	end
	--end
	--local fake = fakeSetup[frame.fakeIndex];

	local _, maxHealth = frame.healthBar:GetMinMaxValues();
	local health = frame.healthBar:GetValue();
	--health = maxHealth * fake.healthMult;
	--PixelUtil.SetStatusBarValue(frame.healthBar, health);

	if ( maxHealth <= 0 ) then
		return;
	end

	if ( not frame.optionTable.displayHealPrediction ) then
		frame.myHealPrediction:Hide();
		frame.otherHealPrediction:Hide();
		frame.totalAbsorb:Hide();
		frame.totalAbsorbOverlay:Hide();
		frame.overAbsorbGlow:Hide();
		frame.myHealAbsorb:Hide();
		frame.myHealAbsorbLeftShadow:Hide();
		frame.myHealAbsorbRightShadow:Hide();
		frame.overHealAbsorbGlow:Hide();
		return;
	end

	local myIncomingHeal = UnitGetIncomingHeals(frame.displayedUnit, "player") or 0;
	--myIncomingHeal = fake.myHeal;
	local allIncomingHeal = UnitGetIncomingHeals(frame.displayedUnit) or 0;
	--allIncomingHeal = fake.allHeal;
	local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
	--totalAbsorb = fake.absorb;

	--We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(frame.displayedUnit) or 0;
	--myCurrentHealAbsorb = fake.healAbsorb;
	if ( health < myCurrentHealAbsorb ) then
		frame.overHealAbsorbGlow:Show();
		myCurrentHealAbsorb = health;
	else
		frame.overHealAbsorbGlow:Hide();
	end

	local customOptions = frame.customOptions;
	local maxHealOverflowRatio = customOptions and customOptions.maxHealOverflowRatio or MAX_INCOMING_HEAL_OVERFLOW;
	--See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if ( health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * maxHealOverflowRatio ) then
		allIncomingHeal = maxHealth * maxHealOverflowRatio - health + myCurrentHealAbsorb;
	end

	local otherIncomingHeal = 0;

	--Split up incoming heals.
	if ( allIncomingHeal >= myIncomingHeal ) then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end

	local overAbsorb = false;
	--We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	if ( health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth ) then
		if ( totalAbsorb > 0 ) then
			overAbsorb = true;
		end

		if ( allIncomingHeal > myCurrentHealAbsorb ) then
			totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
		else
			totalAbsorb = max(0,maxHealth - health);
		end
	end
	if ( overAbsorb ) then
		frame.overAbsorbGlow:Show();
	else
		frame.overAbsorbGlow:Hide();
	end

	local healthTexture = frame.healthBar:GetStatusBarTexture();

	local myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;

	local healAbsorbTexture = nil;

	--If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
	--heal absorb will be completely overlayed by the incoming heals so we don't show it.
	if ( myCurrentHealAbsorb > allIncomingHeal ) then
		local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
		local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;
		healAbsorbTexture = CompactUnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.myHealAbsorb, shownHealAbsorb, -shownHealAbsorbPercent);

		--If there are incoming heals the left shadow would be overlayed by the incoming heals
		--so it isn't shown.
		if ( allIncomingHeal > 0 ) then
			frame.myHealAbsorbLeftShadow:Hide();
		else
			frame.myHealAbsorbLeftShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPLEFT", 0, 0);
			frame.myHealAbsorbLeftShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMLEFT", 0, 0);
			frame.myHealAbsorbLeftShadow:Show();
		end

		-- The right shadow is only shown if there are absorbs on the health bar.
		if ( totalAbsorb > 0 ) then
			frame.myHealAbsorbRightShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPRIGHT", -8, 0);
			frame.myHealAbsorbRightShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMRIGHT", -8, 0);
			frame.myHealAbsorbRightShadow:Show();
		else
			frame.myHealAbsorbRightShadow:Hide();
		end
	else
		frame.myHealAbsorb:Hide();
		frame.myHealAbsorbRightShadow:Hide();
		frame.myHealAbsorbLeftShadow:Hide();
	end

	--Show myIncomingHeal on the health bar.
	local incomingHealsTexture = CompactUnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.myHealPrediction, myIncomingHeal, -myCurrentHealAbsorbPercent);
	--Append otherIncomingHeal on the health bar.
	incomingHealsTexture = CompactUnitFrameUtil_UpdateFillBar(frame, incomingHealsTexture, frame.otherHealPrediction, otherIncomingHeal);

	--Appen absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if ( healAbsorbTexture ) then
		--If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		--Otherwise, append the absorb to the end of the the incomingHeals part;
		appendTexture = incomingHealsTexture;
	end
	CompactUnitFrameUtil_UpdateFillBar(frame, appendTexture, frame.totalAbsorb, totalAbsorb)
end

--WARNING: This function is very similar to the function UnitFrameUtil_UpdateFillBar in UnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
function CompactUnitFrameUtil_UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	local totalWidth, totalHeight = frame.healthBar:GetSize();

	if ( totalWidth == 0 or amount == 0 ) then
		bar:Hide();
		if ( bar.overlay ) then
			bar.overlay:Hide();
		end
		return previousTexture;
	end

	local barOffsetX = 0;
	if ( barOffsetXPercent ) then
		barOffsetX = totalWidth * barOffsetXPercent;
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);

	local _, totalMax = frame.healthBar:GetMinMaxValues();

	local barSize = (amount / totalMax) * totalWidth;
	bar:SetWidth(barSize);
	bar:Show();
	if ( bar.overlay ) then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
		bar.overlay:Show();
	end
	return bar;
end

function CompactUnitFrame_UpdateRoleIcon(frame)
	if not frame.roleIcon then
		return;
	end

	local size = frame.roleIcon:GetHeight();	--We keep the height so that it carries from the set up, but we decrease the width to 1 to allow room for things anchored to the role (e.g. name).
	local raidID = UnitInRaid(frame.unit);
	if ( UnitInVehicle(frame.unit) and UnitHasVehicleUI(frame.unit) ) then
		frame.roleIcon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon");
		frame.roleIcon:SetTexCoord(0, 1, 0, 1);
		frame.roleIcon:Show();
		frame.roleIcon:SetSize(size, size);
	elseif ( frame.optionTable.displayRaidRoleIcon and raidID and select(10, GetRaidRosterInfo(raidID)) ) then
		local role = select(10, GetRaidRosterInfo(raidID));
		frame.roleIcon:SetTexture("Interface\\GroupFrame\\UI-Group-"..role.."Icon");
		frame.roleIcon:SetTexCoord(0, 1, 0, 1);
		frame.roleIcon:Show();
		frame.roleIcon:SetSize(size, size);
	else
		local role = UnitGroupRolesAssigned(frame.unit);
		if ( frame.optionTable.displayRoleIcon and (role == "TANK" or role == "HEALER" or role == "DAMAGER") ) then
			frame.roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
			frame.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
			frame.roleIcon:Show();
			frame.roleIcon:SetSize(size, size);
		else
			frame.roleIcon:Hide();
			frame.roleIcon:SetSize(1, size);
		end
	end
end

function CompactUnitFrame_UpdateReadyCheck(frame)
	if ( not frame.readyCheckIcon or frame.readyCheckDecay and GetReadyCheckTimeLeft() <= 0 ) then
		return;
	end

	local readyCheckStatus = GetReadyCheckStatus(frame.unit);
	frame.readyCheckStatus = readyCheckStatus;
	if ( readyCheckStatus == "ready" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE);
		frame.readyCheckIcon:Show();
	elseif ( readyCheckStatus == "notready" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
		frame.readyCheckIcon:Show();
	elseif ( readyCheckStatus == "waiting" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
		frame.readyCheckIcon:Show();
	else
		frame.readyCheckIcon:Hide();
	end
end

function CompactUnitFrame_FinishReadyCheck(frame)
	if ( not frame.readyCheckIcon)  then
		return;
	end
	if ( frame:IsVisible() ) then
		frame.readyCheckDecay = CUF_READY_CHECK_DECAY_TIME;

		if ( frame.readyCheckStatus == "waiting" ) then	--If you haven't responded, you are not ready.
			frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
			frame.readyCheckIcon:Show();
		end
	else
		CompactUnitFrame_UpdateReadyCheck(frame);
	end
end

function CompactUnitFrame_CheckReadyCheckDecay(frame, elapsed)
	if ( frame.readyCheckDecay ) then
		if ( frame.readyCheckDecay > 0 ) then
			frame.readyCheckDecay = frame.readyCheckDecay - elapsed;
		else
			frame.readyCheckDecay = nil;
			CompactUnitFrame_UpdateReadyCheck(frame);
		end
	end
end

function CompactUnitFrame_UpdateCenterStatusIcon(frame)
	if ( frame.centerStatusIcon ) then
		if ( frame.optionTable.displayInOtherGroup and UnitInOtherParty(frame.unit) ) then
			frame.centerStatusIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye");
			frame.centerStatusIcon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5);
			frame.centerStatusIcon.border:SetTexture("Interface\\Common\\RingBorder");
			frame.centerStatusIcon.border:Show();
			frame.centerStatusIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE;
			frame.centerStatusIcon:Show();
		elseif ( frame.optionTable.displayIncomingResurrect and UnitHasIncomingResurrection(frame.unit) ) then
			frame.centerStatusIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez");
			frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
			frame.centerStatusIcon.border:Hide();
			frame.centerStatusIcon.tooltip = nil;
			frame.centerStatusIcon:Show();
		elseif ( frame.optionTable.displayIncomingSummon and C_IncomingSummon.HasIncomingSummon(frame.unit) ) then
			local status = C_IncomingSummon.IncomingSummonStatus(frame.unit);
			if(status == Enum.SummonStatus.Pending) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonPending");
				frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING;
				frame.centerStatusIcon:Show();
			elseif( status == Enum.SummonStatus.Accepted ) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
				frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED;
				frame.centerStatusIcon:Show();
			elseif( status == Enum.SummonStatus.Declined ) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
				frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
				frame.centerStatusIcon:Show();
			end
		else
			if frame.inDistance and frame.optionTable.displayInOtherPhase then
				local phaseReason = UnitPhaseReason(frame.unit);
				if phaseReason then
					frame.centerStatusIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
					frame.centerStatusIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
					frame.centerStatusIcon.border:Hide();
					frame.centerStatusIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, frame.unit);
					frame.centerStatusIcon:Show();
					return;
				end
			end

			frame.centerStatusIcon:Hide();
		end
	end
end

function CompactUnitFrame_UpdateClassificationIndicator(frame)
	if frame.classificationIndicator then
		if frame.optionTable.showPvPClassificationIndicator and CompactUnitFrame_UpdatePvPClassificationIndicator(frame) then
			return;
		elseif ( frame.optionTable.showClassificationIndicator ) then
			local classification = UnitClassification(frame.unit);
			if ( classification == "elite" or classification == "worldboss" ) then
				frame.classificationIndicator:SetAtlas("nameplates-icon-elite-gold");
				frame.classificationIndicator:Show();
			elseif ( classification == "rareelite" or classification == "rare" ) then
				frame.classificationIndicator:SetAtlas("nameplates-icon-elite-silver");
				frame.classificationIndicator:Show();
			else
				frame.classificationIndicator:Hide();
			end
		else
			frame.classificationIndicator:Hide();
		end
	end
end

function CompactUnitFrame_UpdateWidgetSet(frame)
	if not frame.WidgetContainer then
		return;
	end

	local widgetSetID = UnitWidgetSet(frame.unit);
	frame.WidgetContainer:RegisterForWidgetSet(widgetSetID, DefaultWidgetLayout, nil, frame.unit);
end

function CompactUnitFrame_ClearWidgetSet(frame)
	if frame.WidgetContainer then
		frame.WidgetContainer:UnregisterForWidgetSet();
	end
end

--Other internal functions
do
	local function SetDebuffsHelper(debuffFrames, frameNum, maxDebuffs, filter, isBossAura, isBossBuff, auras)
		if auras then
			for i = 1,#auras do
				local aura = auras[i];
				if frameNum > maxDebuffs then
					break;
				end
				local debuffFrame = debuffFrames[frameNum];
				local index, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId = aura[1], aura[2], aura[3], aura[4], aura[5], aura[6], aura[7], aura[8], aura[9], aura[10], aura[11];
				local unit = nil;
				CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter, isBossAura, isBossBuff, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId);
				frameNum = frameNum + 1;

				if isBossAura then
					--Boss auras are about twice as big as normal debuffs, so we may need to display fewer buffs
					local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize;
					maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
				end
			end
		end
		return frameNum, maxDebuffs;
	end

	local function NumElements(arr)
		return arr and #arr or 0;
	end
	
	local dispellableDebuffTypes = { Magic = true, Curse = true, Disease = true, Poison = true};

	-- This interleaves updating buffFrames, debuffFrames and dispelDebuffFrames to reduce the number of calls to UnitAuraSlots/UnitAuraBySlot
	local function CompactUnitFrame_UpdateAurasInternal(frame)
		local doneWithBuffs = not frame.buffFrames or not frame.optionTable.displayBuffs or frame.maxBuffs == 0;
		local doneWithDebuffs = not frame.debuffFrames or not frame.optionTable.displayDebuffs or frame.maxDebuffs == 0;
		local doneWithDispelDebuffs = not frame.dispelDebuffFrames or not frame.optionTable.displayDispelDebuffs or frame.maxDispelDebuffs == 0;

		local numUsedBuffs = 0;
		local numUsedDebuffs = 0;
		local numUsedDispelDebuffs = 0;

		local displayOnlyDispellableDebuffs = frame.optionTable.displayOnlyDispellableDebuffs;

		-- The following is the priority order for debuffs
		local bossDebuffs, bossBuffs, priorityDebuffs, nonBossDebuffs, nonBossRaidDebuffs;
		local index = 1;
		local batchCount = frame.maxDebuffs;

		if not doneWithDebuffs then
			AuraUtil.ForEachAura(frame.displayedUnit, "HARMFUL", batchCount, function(...)
				if CompactUnitFrame_Util_IsBossAura(...) then
					if not bossDebuffs then
						bossDebuffs = {};
					end
					tinsert(bossDebuffs, {index, ...});
					numUsedDebuffs = numUsedDebuffs + 1;
					if numUsedDebuffs == frame.maxDebuffs then
						doneWithDebuffs = true;
						return true;
					end
				elseif CompactUnitFrame_Util_IsPriorityDebuff(...) then
					if not priorityDebuffs then
						priorityDebuffs = {};
					end
					tinsert(priorityDebuffs, {index, ...});
				elseif not displayOnlyDispellableDebuffs and CompactUnitFrame_Util_ShouldDisplayDebuff(...) then
					if not nonBossDebuffs then
						nonBossDebuffs = {};
					end
					tinsert(nonBossDebuffs, {index, ...});
				end

				index = index + 1;
				return false;
			end);
		end

		if not doneWithBuffs or not doneWithDebuffs then
			index = 1;
			batchCount = math.max(frame.maxDebuffs, frame.maxBuffs);
			AuraUtil.ForEachAura(frame.displayedUnit, "HELPFUL", batchCount, function(...)
				if CompactUnitFrame_Util_IsBossAura(...) then
					-- Boss Auras are considered Debuffs for our purposes.
					if not doneWithDebuffs then
						if not bossBuffs then
							bossBuffs = {};
						end
						tinsert(bossBuffs, {index, ...});
						numUsedDebuffs = numUsedDebuffs + 1;
						if numUsedDebuffs == frame.maxDebuffs then
							doneWithDebuffs = true;
						end
					end
				elseif CompactUnitFrame_UtilShouldDisplayBuff(...) then
					if not doneWithBuffs then
						numUsedBuffs = numUsedBuffs + 1;
						local buffFrame = frame.buffFrames[numUsedBuffs];
						CompactUnitFrame_UtilSetBuff(buffFrame, index, ...);
						if numUsedBuffs == frame.maxBuffs then
							doneWithBuffs = true;
						end
					end
				end

				index = index + 1;
				return doneWithBuffs and doneWithDebuffs;
			end);
		end

		numUsedDebuffs = math.min(frame.maxDebuffs, numUsedDebuffs + NumElements(priorityDebuffs));
		if numUsedDebuffs == frame.maxDebuffs then
			doneWithDebuffs = true;
		end

		if not doneWithDispelDebuffs then
			--Clear what we currently have for dispellable debuffs
			for debuffType, display in pairs(dispellableDebuffTypes) do
				if ( display ) then
					frame["hasDispel"..debuffType] = false;
				end
			end
		end

		if not doneWithDispelDebuffs or not doneWithDebuffs then
			batchCount = math.max(frame.maxDebuffs, frame.maxDispelDebuffs);
			index = 1;
			AuraUtil.ForEachAura(frame.displayedUnit, "HARMFUL|RAID", batchCount, function(...)
				if not doneWithDebuffs and displayOnlyDispellableDebuffs then
					if CompactUnitFrame_Util_ShouldDisplayDebuff(...) and not CompactUnitFrame_Util_IsBossAura(...) and not CompactUnitFrame_Util_IsPriorityDebuff(...) then
						if not nonBossRaidDebuffs then
							nonBossRaidDebuffs = {};
						end
						tinsert(nonBossRaidDebuffs, {index, ...});
						numUsedDebuffs = numUsedDebuffs + 1;
						if numUsedDebuffs == frame.maxDebuffs then
							doneWithDebuffs = true;
						end
					end
				end
				if not doneWithDispelDebuffs then
					local debuffType = select(4, ...);
					if ( dispellableDebuffTypes[debuffType] and not frame["hasDispel"..debuffType] ) then
						frame["hasDispel"..debuffType] = true;
						numUsedDispelDebuffs = numUsedDispelDebuffs + 1;
						local dispellDebuffFrame = frame.dispelDebuffFrames[numUsedDispelDebuffs];
						CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
						if numUsedDispelDebuffs == frame.maxDispelDebuffs then
							doneWithDispelDebuffs = true;
						end
					end
				end
				index = index + 1;
				return (doneWithDebuffs or not displayOnlyDispellableDebuffs) and doneWithDispelDebuffs;
			end);
		end

		local frameNum = 1;
		local maxDebuffs = frame.maxDebuffs;

		do
			local isBossAura = true;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, bossDebuffs);
		end
		do
			local isBossAura = true;
			local isBossBuff = true;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HELPFUL", isBossAura, isBossBuff, bossBuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, priorityDebuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL|RAID", isBossAura, isBossBuff, nonBossRaidDebuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, nonBossDebuffs);
		end
		numUsedDebuffs = frameNum - 1;

		CompactUnitFrame_HideAllBuffs(frame, numUsedBuffs + 1);
		CompactUnitFrame_HideAllDebuffs(frame, numUsedDebuffs + 1);
		CompactUnitFrame_HideAllDispelDebuffs(frame, numUsedDispelDebuffs + 1);
	end

	function CompactUnitFrame_UpdateAuras(frame)
		if CompactUnitFrame_UpdateAuras_BackwardsCompat then
			CompactUnitFrame_UpdateAuras_BackwardsCompat(frame);
		end

		CompactUnitFrame_UpdateAurasInternal(frame);
		CompactUnitFrame_UpdateClassificationIndicator(frame);
	end
end

local PvPClassificationIcons = {
	[Enum.PvPUnitClassification.FlagCarrierHorde] = "nameplates-icon-flag-horde",
	[Enum.PvPUnitClassification.FlagCarrierAlliance] = "nameplates-icon-flag-alliance",
	[Enum.PvPUnitClassification.FlagCarrierNeutral] = "nameplates-icon-flag-neutral",
	[Enum.PvPUnitClassification.CartRunnerHorde] = "nameplates-icon-cart-horde",
	[Enum.PvPUnitClassification.CartRunnerAlliance] = "nameplates-icon-cart-alliance",
	[Enum.PvPUnitClassification.AssassinHorde] = "nameplates-icon-bounty-horde",
	[Enum.PvPUnitClassification.AssassinAlliance] = "nameplates-icon-bounty-alliance",
	[Enum.PvPUnitClassification.OrbCarrierBlue] = "nameplates-icon-orb-blue",
	[Enum.PvPUnitClassification.OrbCarrierGreen] = "nameplates-icon-orb-green",
	[Enum.PvPUnitClassification.OrbCarrierOrange] = "nameplates-icon-orb-orange",
	[Enum.PvPUnitClassification.OrbCarrierPurple] = "nameplates-icon-orb-purple",
}

function CompactUnitFrame_UpdatePvPClassificationIndicator(frame)
	local classificationIcon = PvPClassificationIcons[UnitPvpClassification(frame.unit)];

	if classificationIcon then
		frame.classificationIndicator:SetAtlas(classificationIcon);
		frame.classificationIndicator:Show();
	end

	return classificationIcon ~= nil;
end

--Utility Functions
function CompactUnitFrame_UtilShouldDisplayBuff(...)
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = ...;

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
	else
		return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId);
	end
end

function CompactUnitFrame_HideAllBuffs(frame, startingIndex)
	if frame.buffFrames then
		for i=startingIndex or 1, #frame.buffFrames do
			frame.buffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_HideAllDebuffs(frame, startingIndex)
	if frame.debuffFrames then
		for i=startingIndex or 1, #frame.debuffFrames do
			frame.debuffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_HideAllDispelDebuffs(frame, startingIndex)
	if frame.dispelDebuffFrames then
		for i=startingIndex or 1, #frame.dispelDebuffFrames do
			frame.dispelDebuffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_UtilSetBuff(buffFrame, index, ...)
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = ...;
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	buffFrame:SetID(index);
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(buffFrame.cooldown);
	end
	buffFrame:Show();
end

function CompactUnitFrame_Util_ShouldDisplayDebuff(...)
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = ...;

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end

function CompactUnitFrame_Util_IsBossAura(...)
	return select(12, ...);
end

do
	local _, classFilename = UnitClass("player");
	if ( classFilename == "PALADIN" ) then
		CompactUnitFrame_Util_IsPriorityDebuff = function(...)
			local spellId = select(10, ...);
			local isForbearance = (spellId == 25771);
			return isForbearance or SpellIsPriorityAura(spellId);
		end
	else
		CompactUnitFrame_Util_IsPriorityDebuff = function(...)
			local spellId = select(10, ...);
			return SpellIsPriorityAura(spellId);
		end
	end
end

function CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter, isBossAura, isBossBuff, ...)
	-- make sure you are using the correct index here!
	--isBossAura says make this look large.
	--isBossBuff looks in HELPFULL auras otherwise it looks in HARMFULL ones
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = ...;
	if name == nil then
		-- for backwards compatibility - this functionality will be removed in a future update
		if unit then
			if (isBossBuff) then
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitBuff(unit, index, filter);
			else
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(unit, index, filter);
			end
		else
			return;
		end
	end
	debuffFrame.filter = filter;
	debuffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		debuffFrame.count:Show();
		debuffFrame.count:SetText(countText);
	else
		debuffFrame.count:Hide();
	end
	debuffFrame:SetID(index);
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(debuffFrame.cooldown);
	end

	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	debuffFrame.border:SetVertexColor(color.r, color.g, color.b);

	debuffFrame.isBossBuff = isBossBuff;
	if ( isBossAura ) then
		local size = min(debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE, debuffFrame.maxHeight);
		debuffFrame:SetSize(size, size);
	else
		debuffFrame:SetSize(debuffFrame.baseSize, debuffFrame.baseSize);
	end

	debuffFrame:Show();
end

function CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
	dispellDebuffFrame:Show();
	dispellDebuffFrame.icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..debuffType);
	dispellDebuffFrame:SetID(index);
end

--Dropdown
function CompactUnitFrameDropDown_Initialize(self)
	local unit = self:GetParent().unit;
	if ( not unit ) then
		return;
	end
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit(unit, "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit(unit, "vehicle") ) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif ( UnitIsUnit(unit, "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer(unit) ) then
		id = UnitInRaid(unit);
		if ( id ) then
			menu = "RAID_PLAYER";
		elseif ( UnitInParty(unit) ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, unit, name, id);
	end
end

------The default setup function
local texCoords = {
	["Raid-AggroFrame"] = {  0.00781250, 0.55468750, 0.00781250, 0.27343750 },
	["Raid-TargetFrame"] = { 0.00781250, 0.55468750, 0.28906250, 0.55468750 },
}

DefaultCompactUnitFrameOptions = {
	useClassColors = true,
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	displayStatusText = true,
	displayHealPrediction = true,
	displayRoleIcon = true,
	displayRaidRoleIcon = true,
	displayDispelDebuffs = true,
	displayBuffs = true,
	displayDebuffs = true,
	displayOnlyDispellableDebuffs = false,
	displayNonBossDebuffs = true,
	healthText = "none",
	displayIncomingResurrect = true,
	displayIncomingSummon = true,
	displayInOtherGroup = true,
	displayInOtherPhase = true,

	--If class colors are enabled also show the class colors for npcs in your raid frames or
	--raid-frame-style party frames.
	allowClassColorsForNPCs = true,
}

local NATIVE_UNIT_FRAME_HEIGHT = 36;
local NATIVE_UNIT_FRAME_WIDTH = 72;
DefaultCompactUnitFrameSetupOptions = {
	displayPowerBar = true,
	height = NATIVE_UNIT_FRAME_HEIGHT,
	width = NATIVE_UNIT_FRAME_WIDTH,
	displayBorder = true,
}

function DefaultCompactUnitFrameSetup(frame)
	local options = DefaultCompactUnitFrameSetupOptions;
	local componentScale = min(options.height / NATIVE_UNIT_FRAME_HEIGHT, options.width / NATIVE_UNIT_FRAME_WIDTH);

	frame:SetAlpha(1);

	frame:SetSize(options.width, options.height);
	local powerBarHeight = 8;
	local powerBarUsedHeight = options.displayPowerBar and powerBarHeight or 0;

	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);

	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1 + powerBarUsedHeight);

	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");

	if ( frame.powerBar ) then
		if ( options.displayPowerBar ) then
			if ( options.displayBorder ) then
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2);
			else
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0);
			end
			frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
			frame.powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill", "BORDER");
			frame.powerBar.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Background");
			frame.powerBar:Show();
		else
			frame.powerBar:Hide();
		end
	end

	frame.myHealPrediction:ClearAllPoints();
	frame.myHealPrediction:SetColorTexture(1,1,1);
	frame.myHealPrediction:SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);
	frame.myHealAbsorb:ClearAllPoints();
	frame.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	frame.myHealAbsorbLeftShadow:ClearAllPoints();
	frame.myHealAbsorbRightShadow:ClearAllPoints();
	frame.otherHealPrediction:ClearAllPoints();
	frame.otherHealPrediction:SetColorTexture(1,1,1);
	frame.otherHealPrediction:SetGradient("VERTICAL", 11/255, 53/255, 43/255, 21/255, 89/255, 72/255);
	frame.totalAbsorb:ClearAllPoints();
	frame.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	frame.totalAbsorb.overlay = frame.totalAbsorbOverlay;
	frame.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	frame.totalAbsorbOverlay:SetAllPoints(frame.totalAbsorb);
	frame.totalAbsorbOverlay.tileSize = 32;
	frame.overAbsorbGlow:ClearAllPoints();
	frame.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	frame.overAbsorbGlow:SetBlendMode("ADD");
	frame.overAbsorbGlow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -7, 0);
	frame.overAbsorbGlow:SetPoint("TOPLEFT", frame.healthBar, "TOPRIGHT", -7, 0);
	frame.overAbsorbGlow:SetWidth(16);
	frame.overHealAbsorbGlow:ClearAllPoints();
	frame.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	frame.overHealAbsorbGlow:SetBlendMode("ADD");
	frame.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", 7, 0);
	frame.overHealAbsorbGlow:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", 7, 0);
	frame.overHealAbsorbGlow:SetWidth(16);

	frame.roleIcon:ClearAllPoints();
	frame.roleIcon:SetPoint("TOPLEFT", 3, -2);
	frame.roleIcon:SetSize(12, 12);

	frame.name:SetPoint("TOPLEFT", frame.roleIcon, "TOPRIGHT", 0, -1);
	frame.name:SetPoint("TOPRIGHT", -3, -3);
	frame.name:SetJustifyH("LEFT");

	local NATIVE_FONT_SIZE = 12;
	local fontName, fontSize, fontFlags = frame.statusText:GetFont();
	frame.statusText:SetFont(fontName, NATIVE_FONT_SIZE * componentScale, fontFlags);
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, options.height / 3 - 2);
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, options.height / 3 - 2);
	frame.statusText:SetHeight(12 * componentScale);

	local readyCheckSize = 15 * componentScale;
	frame.readyCheckIcon:ClearAllPoints();
	frame.readyCheckIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, options.height / 3 - 4);
	frame.readyCheckIcon:SetSize(readyCheckSize, readyCheckSize);

	local buffSize = 11 * componentScale;

	CompactUnitFrame_SetMaxBuffs(frame, 3);
	CompactUnitFrame_SetMaxDebuffs(frame, 3);
	CompactUnitFrame_SetMaxDispelDebuffs(frame, 3);

	local buffPos, buffRelativePoint, buffOffset = "BOTTOMRIGHT", "BOTTOMLEFT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.buffFrames[1]:ClearAllPoints();
	frame.buffFrames[1]:SetPoint(buffPos, frame, "BOTTOMRIGHT", -3, buffOffset);
	for i=1, #frame.buffFrames do
		if ( i > 1 ) then
			frame.buffFrames[i]:ClearAllPoints();
			frame.buffFrames[i]:SetPoint(buffPos, frame.buffFrames[i - 1], buffRelativePoint, 0, 0);
		end
		frame.buffFrames[i]:SetSize(buffSize, buffSize);
	end

	local debuffPos, debuffRelativePoint, debuffOffset = "BOTTOMLEFT", "BOTTOMRIGHT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.debuffFrames[1]:ClearAllPoints();
	frame.debuffFrames[1]:SetPoint(debuffPos, frame, "BOTTOMLEFT", 3, debuffOffset);
	for i=1, #frame.debuffFrames do
		if ( i > 1 ) then
			frame.debuffFrames[i]:ClearAllPoints();
			frame.debuffFrames[i]:SetPoint(debuffPos, frame.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
		end
		frame.debuffFrames[i].baseSize = buffSize;
		frame.debuffFrames[i].maxHeight = options.height - powerBarUsedHeight - CUF_AURA_BOTTOM_OFFSET - CUF_NAME_SECTION_SIZE;
		--frame.debuffFrames[i]:SetSize(11, 11);
	end

	frame.dispelDebuffFrames[1]:SetPoint("TOPRIGHT", -3, -2);
	for i=1, #frame.dispelDebuffFrames do
		if ( i > 1 ) then
			frame.dispelDebuffFrames[i]:SetPoint("RIGHT", frame.dispelDebuffFrames[i - 1], "LEFT", 0, 0);
		end
		frame.dispelDebuffFrames[i]:SetSize(12, 12);
	end

	frame.selectionHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.selectionHighlight:SetTexCoord(unpack(texCoords["Raid-TargetFrame"]));
	frame.selectionHighlight:SetAllPoints(frame);

	frame.aggroHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.aggroHighlight:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]));
	frame.aggroHighlight:SetAllPoints(frame);

	frame.centerStatusIcon:ClearAllPoints();
	frame.centerStatusIcon:SetPoint("CENTER", frame, "BOTTOM", 0, options.height / 3 + 2);
	frame.centerStatusIcon:SetSize(buffSize * 2, buffSize * 2);

	if ( options.displayBorder ) then
		frame.horizTopBorder:ClearAllPoints();
		frame.horizTopBorder:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -7);
		frame.horizTopBorder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -7);
		frame.horizTopBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizTopBorder:SetHeight(8);
		frame.horizTopBorder:Show();

		frame.horizBottomBorder:ClearAllPoints();
		frame.horizBottomBorder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1);
		frame.horizBottomBorder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1);
		frame.horizBottomBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizBottomBorder:SetHeight(8);
		frame.horizBottomBorder:Show();

		frame.vertLeftBorder:ClearAllPoints();
		frame.vertLeftBorder:SetPoint("TOPRIGHT", frame, "TOPLEFT", 7, 0);
		frame.vertLeftBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 7, 0);
		frame.vertLeftBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertLeftBorder:SetWidth(8);
		frame.vertLeftBorder:Show();

		frame.vertRightBorder:ClearAllPoints();
		frame.vertRightBorder:SetPoint("TOPLEFT", frame, "TOPRIGHT", -1, 0);
		frame.vertRightBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0);
		frame.vertRightBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertRightBorder:SetWidth(8);
		frame.vertRightBorder:Show();

		if ( options.displayPowerBar ) then
			frame.horizDivider:ClearAllPoints();
			frame.horizDivider:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1 + powerBarUsedHeight);
			frame.horizDivider:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1 + powerBarUsedHeight);
			frame.horizDivider:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
			frame.horizDivider:SetHeight(8);
			frame.horizDivider:Show();
		else
			frame.horizDivider:Hide();
		end
	else
		frame.horizTopBorder:Hide();
		frame.horizBottomBorder:Hide();
		frame.vertLeftBorder:Hide();
		frame.vertRightBorder:Hide();

		frame.horizDivider:Hide();
	end

	CompactUnitFrame_SetOptionTable(frame, DefaultCompactUnitFrameOptions)
end

DefaultCompactMiniFrameOptions = {
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	--displayStatusText = true,
	displayHealPrediction = true,
	--displayDispelDebuffs = true,
}

DefaultCompactMiniFrameSetUpOptions = {
	height = 18,
	width = 72,
	displayBorder = true,
}

function DefaultCompactMiniFrameSetup(frame)
	local options = DefaultCompactMiniFrameSetUpOptions;
	frame:SetAlpha(1);
	frame:SetSize(options.width, options.height);
	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");

	frame.myHealPrediction:ClearAllPoints();
	frame.myHealPrediction:SetColorTexture(1,1,1);
	frame.myHealPrediction:SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);
	frame.myHealAbsorb:ClearAllPoints();
	frame.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	frame.myHealAbsorbLeftShadow:ClearAllPoints();
	frame.myHealAbsorbRightShadow:ClearAllPoints();
	frame.otherHealPrediction:ClearAllPoints();
	frame.otherHealPrediction:SetColorTexture(1,1,1);
	frame.otherHealPrediction:SetGradient("VERTICAL", 3/255, 72/255, 5/255, 2/255, 101/255, 18/255);
	frame.totalAbsorb:ClearAllPoints();
	frame.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	frame.totalAbsorb.overlay = frame.totalAbsorbOverlay;
	frame.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	frame.totalAbsorbOverlay:SetAllPoints(frame.totalAbsorb);
	frame.totalAbsorbOverlay.tileSize = 32;
	frame.overAbsorbGlow:ClearAllPoints();
	frame.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	frame.overAbsorbGlow:SetBlendMode("ADD");
	frame.overAbsorbGlow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -7, 0);
	frame.overAbsorbGlow:SetPoint("TOPLEFT", frame.healthBar, "TOPRIGHT", -7, 0);
	frame.overAbsorbGlow:SetWidth(16);
	frame.overHealAbsorbGlow:ClearAllPoints();
	frame.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	frame.overHealAbsorbGlow:SetBlendMode("ADD");
	frame.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", 7, 0);
	frame.overHealAbsorbGlow:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", 7, 0);
	frame.overHealAbsorbGlow:SetWidth(16);

	frame.name:SetPoint("LEFT", 5, 1);
	frame.name:SetPoint("RIGHT", -3, 1);
	frame.name:SetHeight(12);
	frame.name:SetJustifyH("LEFT");

	frame.selectionHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.selectionHighlight:SetTexCoord(unpack(texCoords["Raid-TargetFrame"]));
	frame.selectionHighlight:SetAllPoints(frame);

	frame.aggroHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.aggroHighlight:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]));
	frame.aggroHighlight:SetAllPoints(frame);

	if ( options.displayBorder ) then
		frame.horizTopBorder:ClearAllPoints();
		frame.horizTopBorder:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -7);
		frame.horizTopBorder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -7);
		frame.horizTopBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizTopBorder:SetHeight(8);
		frame.horizTopBorder:Show();

		frame.horizBottomBorder:ClearAllPoints();
		frame.horizBottomBorder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1);
		frame.horizBottomBorder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1);
		frame.horizBottomBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizBottomBorder:SetHeight(8);
		frame.horizBottomBorder:Show();

		frame.vertLeftBorder:ClearAllPoints();
		frame.vertLeftBorder:SetPoint("TOPRIGHT", frame, "TOPLEFT", 7, 0);
		frame.vertLeftBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 7, 0);
		frame.vertLeftBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertLeftBorder:SetWidth(8);
		frame.vertLeftBorder:Show();

		frame.vertRightBorder:ClearAllPoints();
		frame.vertRightBorder:SetPoint("TOPLEFT", frame, "TOPRIGHT", -1, 0);
		frame.vertRightBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0);
		frame.vertRightBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertRightBorder:SetWidth(8);
		frame.vertRightBorder:Show();
	else
		frame.horizTopBorder:Hide();
		frame.horizBottomBorder:Hide();
		frame.vertLeftBorder:Hide();
		frame.vertRightBorder:Hide();
	end

	CompactUnitFrame_SetOptionTable(frame, DefaultCompactMiniFrameOptions)
end

DefaultCompactNamePlateFriendlyFrameOptions = {
	useClassColors = true,
	displaySelectionHighlight = true,
	displayAggroHighlight = false,
	displayName = true,
	fadeOutOfRange = false,
	--displayStatusText = true,
	displayHealPrediction = true,
	--displayDispelDebuffs = true,
	colorNameBySelection = true,
	colorNameWithExtendedColors = true,
	colorHealthWithExtendedColors = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	showPvPClassificationIndicator = true,

	selectedBorderColor = CreateColor(1, 1, 1, .35),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, .8),
}

DefaultCompactNamePlateEnemyFrameOptions = {
	displaySelectionHighlight = true,
	displayAggroHighlight = false,
	playLoseAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	colorHealthBySelection = true,
	considerSelectionInCombatAsHostile = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	greyOutWhenTapDenied = true,
	showClassificationIndicator = true,
	showPvPClassificationIndicator = true,

	selectedBorderColor = CreateColor(1, 1, 1, .9),
	tankBorderColor = CreateColor(1, 1, 0, .6),
	defaultBorderColor = CreateColor(0, 0, 0, 1),
}

DefaultCompactNamePlatePlayerFrameOptions = {
	displaySelectionHighlight = false,
	displayAggroHighlight = false,
	displayName = false,
	fadeOutOfRange = false,
	displayHealPrediction = true,
	colorNameBySelection = true,
	smoothHealthUpdates = false,
	displayNameWhenSelected = false,
	hideCastbar = true,
	healthBarColorOverride = CreateColor(0, 1, 0),

	defaultBorderColor = CreateColor(0, 0, 0, 1),
}

DefaultCompactNamePlateFrameSetUpOptions = {
	healthBarHeight = 4,
	healthBarAlpha = 0.75,
	castBarHeight = 8,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 10,
	castBarShieldHeight = 12,

	castIconWidth = 10,
	castIconHeight = 10,
}

DefaultCompactNamePlatePlayerFrameSetUpOptions = {
	healthBarHeight = 4,
	healthBarAlpha = 1,
	castBarHeight = 8,
	castBarFontHeight = 10,
	useLargeNameFont = false,

	castBarShieldWidth = 10,
	castBarShieldHeight = 12,

	castIconWidth = 10,
	castIconHeight = 10,
}

function DefaultCompactNamePlateFrameSetup(frame, options)
	if ( not options or type(options) ~= "table" ) then
		error("Cannot setup target nameplate. Missing options table.")
	end

	frame.castBar.Text:SetAllPoints(frame.castBar);
	frame.castBar.Text:SetFontObject(SystemFont_NamePlateCastBar);

	frame.castBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill");

	CastingBarFrame_AddWidgetForFade(frame.castBar, frame.castBar.Icon);
	CastingBarFrame_AddWidgetForFade(frame.castBar, frame.castBar.BorderShield);

	DefaultCompactNamePlateFrameSetupInternal(frame, DefaultCompactNamePlateFrameSetUpOptions, options);
	DefaultCompactNamePlateFrameAnchors(frame);
end

function DefaultCompactNamePlateFrameAnchors(frame)
	if not frame.customOptions or not frame.customOptions.ignoreBarPoints then
	PixelUtil.SetPoint(frame.castBar, "BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 6);
	PixelUtil.SetPoint(frame.castBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 6);

	PixelUtil.SetPoint(frame.healthBar, "BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 2);
	PixelUtil.SetPoint(frame.healthBar, "BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 2);
	end

	DefaultCompactNamePlateFrameAnchorInternal(frame, DefaultCompactNamePlateFrameSetUpOptions);
end

function DefaultCompactNamePlateFriendlyFrameSetup(frame)
	DefaultCompactNamePlateFrameSetup(frame, DefaultCompactNamePlateFriendlyFrameOptions);
end

function DefaultCompactNamePlateEnemyFrameSetup(frame)
	DefaultCompactNamePlateFrameSetup(frame, DefaultCompactNamePlateEnemyFrameOptions);
end

function DefaultCompactNamePlatePlayerFrameAnchor(frame)
	PixelUtil.SetPoint(frame.healthBar, "LEFT", frame, "LEFT", 12, 5);
	PixelUtil.SetPoint(frame.healthBar, "RIGHT", frame, "RIGHT", -12, 5);

	DefaultCompactNamePlateFrameAnchorInternal(frame, DefaultCompactNamePlatePlayerFrameSetUpOptions);
end

function DefaultCompactNamePlatePlayerFrameSetup(frame)
	DefaultCompactNamePlateFrameSetupInternal(frame, DefaultCompactNamePlatePlayerFrameSetUpOptions, DefaultCompactNamePlatePlayerFrameOptions);
	DefaultCompactNamePlatePlayerFrameAnchor(frame);
end

function DefaultCompactNamePlateFrameSetupInternal(frame, setupOptions, frameOptions)
	frame:SetAllPoints(frame:GetParent());

	local customOptions = frame.customOptions;
	frame.castBar:SetHeight(customOptions and customOptions.castBarHeight or setupOptions.castBarHeight);

	local fontName, fontSize, fontFlags = frame.castBar.Text:GetFont();
	frame.castBar.Text:SetFont(fontName, customOptions and customOptions.castBarFontHeight or setupOptions.castBarFontHeight, fontFlags);

	if customOptions and customOptions.nameFont then
		frame.name:SetFontObject(customOptions.nameFont);
	else
	if setupOptions.useFixedSizeFont then
		frame.name:SetIgnoreParentScale(false);
		if setupOptions.useLargeNameFont then
			frame.name:SetFontObject(SystemFont_LargeNamePlateFixed);
		else
			frame.name:SetFontObject(SystemFont_NamePlateFixed);
		end
	else
		frame.name:SetIgnoreParentScale(true);
		if setupOptions.useLargeNameFont then
			frame.name:SetFontObject(SystemFont_LargeNamePlate);
		else
			frame.name:SetFontObject(SystemFont_NamePlate);
		end
	end
	end

	frame.hideHealthbar = setupOptions.hideHealthbar;
	frame.healthBar:SetShown(not setupOptions.hideHealthbar);

	frame.selectionHighlight:SetParent(frame.healthBar);
	frame.aggroHighlight:SetParent(frame.healthBar);

	frame.myHealPrediction = frame.healthBar.myHealPrediction;
	frame.otherHealPrediction = frame.healthBar.otherHealPrediction;
	frame.totalAbsorb = frame.healthBar.totalAbsorb;
	frame.totalAbsorbOverlay = frame.healthBar.totalAbsorbOverlay;
	frame.overAbsorbGlow = frame.healthBar.overAbsorbGlow;
	frame.myHealAbsorb = frame.healthBar.myHealAbsorb;
	frame.myHealAbsorbLeftShadow = frame.healthBar.myHealAbsorbLeftShadow;
	frame.myHealAbsorbRightShadow = frame.healthBar.myHealAbsorbRightShadow;
	frame.overHealAbsorbGlow = frame.healthBar.overHealAbsorbGlow;

	frame.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608);

	frame.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);

	frame.otherHealPrediction:SetVertexColor(0.0, 0.659, 0.608);

	frame.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	frame.totalAbsorb.overlay = frame.totalAbsorbOverlay;

	frame.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	frame.totalAbsorbOverlay.tileSize = 20;

	frame.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	frame.overAbsorbGlow:SetBlendMode("ADD");

	frame.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	frame.overHealAbsorbGlow:SetBlendMode("ADD");
	
	frame.myHealPrediction:ClearAllPoints();

	frame.myHealAbsorb:ClearAllPoints();

	frame.myHealAbsorbLeftShadow:ClearAllPoints();
	frame.myHealAbsorbRightShadow:ClearAllPoints();

	frame.otherHealPrediction:ClearAllPoints();

	frame.totalAbsorb:ClearAllPoints();

	frame.totalAbsorbOverlay:SetAllPoints(frame.totalAbsorb);

	frame.classificationIndicator = frame.ClassificationFrame.classificationIndicator;
	frame.ClassificationFrame.maxScale = setupOptions.maxClassificationScale or frameOptions.maxClassificationScale;
	frame.ClassificationFrame:SetScale(setupOptions.classificationScale or frameOptions.classificationScale or 1.0);

	frame.LoseAggroAnim:Stop();

	CompactUnitFrame_SetOptionTable(frame, frameOptions);
end

function DefaultCompactNamePlateFrameAnchorInternal(frame, setupOptions)
	PixelUtil.SetSize(frame.castBar.BorderShield, setupOptions.castBarShieldWidth, setupOptions.castBarShieldHeight);
	frame.castBar.BorderShield:ClearAllPoints();
	PixelUtil.SetPoint(frame.castBar.BorderShield, "CENTER", frame.castBar, "LEFT", 0, 0);

	local customOptions = frame.customOptions;
	if not customOptions or not customOptions.ignoreIconSize then
	PixelUtil.SetSize(frame.castBar.Icon, setupOptions.castIconWidth, setupOptions.castIconHeight);
	end

	if not customOptions or not customOptions.ignoreIconPoint then
	frame.castBar.Icon:ClearAllPoints();
	PixelUtil.SetPoint(frame.castBar.Icon, "CENTER", frame.castBar, "LEFT", 0, 0);
	end

	if not customOptions or not customOptions.ignoreBarSize then
	PixelUtil.SetHeight(frame.healthBar, setupOptions.healthBarHeight);
	end

	PixelUtil.SetPoint(frame.name, "BOTTOM", frame.healthBar, "TOP", 0, 4);
	PixelUtil.SetHeight(frame.name, frame.name:GetLineHeight());

	if not customOptions or not customOptions.ignoreOverAbsorbGlow then
	frame.overAbsorbGlow:ClearAllPoints();
	PixelUtil.SetPoint(frame.overAbsorbGlow, "BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -4, -1);
	PixelUtil.SetPoint(frame.overAbsorbGlow, "TOPLEFT", frame.healthBar, "TOPRIGHT", -4, 1);
	PixelUtil.SetHeight(frame.overAbsorbGlow, 8);
	end

	if not customOptions or not customOptions.ignoreOverHealAbsorbGlow then
	frame.overHealAbsorbGlow:ClearAllPoints();
	PixelUtil.SetPoint(frame.overHealAbsorbGlow, "BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", 2, -1);
	PixelUtil.SetPoint(frame.overHealAbsorbGlow, "TOPRIGHT", frame.healthBar, "TOPLEFT", 2, 1);
	PixelUtil.SetWidth(frame.overHealAbsorbGlow, 8);
	end

	frame.healthBar.border:UpdateSizes();
end