--Widget Handlers
local OPTION_TABLE_NONE = {};
BOSS_DEBUFF_SIZE_INCREASE = 9;

function CompactUnitFrame_OnLoad(self)
	if ( not self:GetName() ) then
		self:Hide();
		error("CompactUnitFrames must have a name");	--Sorry! Don't feel like re-writing unit popups.
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_POWER_BAR_SHOW");
	self:RegisterEvent("UNIT_POWER_BAR_HIDE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("UNIT_HEAL_PREDICTION");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	
	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self.maxDispelDebuffs = 0;
	CompactUnitFrame_SetOptionTable(self, OPTION_TABLE_NONE);
	CompactUnitFrame_SetUpClicks(self);
	
	tinsert(UnitPopupFrames, self.dropDown:GetName());
end

function CompactUnitFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...;
	if ( event == self.updateAllEvent and (not self.updateAllFilter or self.updateAllFilter(self, event, ...)) ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
		CompactUnitFrame_UpdateAuras(self);	--We filter differently based on whether the player is in Combat, so we need to update when that changes.
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		CompactUnitFrame_UpdateRoleIcon(self);
	elseif ( event == "READY_CHECK" or event == "READY_CHECK_FINISHED" ) then
		CompactUnitFrame_UpdateReadyCheck(self);
	elseif ( event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" ) then	--Alternate power info may now be available.
		CompactUnitFrame_UpdateMaxPower(self);
		CompactUnitFrame_UpdatePower(self);
		CompactUnitFrame_UpdatePowerColor(self);
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
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
		elseif ( event == "UNIT_POWER" ) then
			CompactUnitFrame_UpdatePower(self);
		elseif ( event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_BAR_SHOW" or event == "UNIT_POWER_BAR_HIDE" ) then
			CompactUnitFrame_UpdateMaxPower(self);
			CompactUnitFrame_UpdatePower(self);
			CompactUnitFrame_UpdatePowerColor(self);
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			CompactUnitFrame_UpdateName(self);
		elseif ( event == "UNIT_AURA" ) then
			CompactUnitFrame_UpdateAuras(self);
		elseif ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
			CompactUnitFrame_UpdateAggroHighlight(self);
		elseif ( event == "UNIT_CONNECTION" ) then
			--Might want to set the health/mana to max as well so it's easily visible? This happens unless the player is out of AOI.
			CompactUnitFrame_UpdateHealthColor(self);
			CompactUnitFrame_UpdatePowerColor(self);
			CompactUnitFrame_UpdateStatusText(self);
		elseif ( event == "UNIT_HEAL_PREDICTION" ) then
			CompactUnitFrame_UpdateHealPrediction(self);
		elseif ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" ) then
			CompactUnitFrame_UpdateAll(self);
		elseif ( event == "READY_CHECK_CONFIRM" ) then
			CompactUnitFrame_UpdateReadyCheck(self);
		end
	end
end

--DEBUG FIXME - We should really try to avoid having OnUpdate on every frame. An event when going in/out of range would be greatly preferred.
function CompactUnitFrame_OnUpdate(self, elapsed)
	CompactUnitFrame_UpdateInRange(self);
end

--Externally accessed functions
function CompactUnitFrame_SetUnit(frame, unit)
	if ( unit ~= frame.unit ) then
		frame.unit = unit;
		frame.displayedUnit = unit;	--May differ from unit if unit is in a vehicle.
		frame.inVehicle = false;
		frame:SetAttribute("unit", unit);
		if ( unit ) then
			CompactUnitFrame_RegisterEvents(frame);
		else
			CompactUnitFrame_UnregisterEvents(frame);
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
	frame:SetScript("OnEvent", CompactUnitFrame_OnEvent);
	frame:SetScript("OnUpdate", CompactUnitFrame_OnUpdate);
end

function CompactUnitFrame_UnregisterEvents(frame)
	frame:SetScript("OnEvent", nil);
	frame:SetScript("OnUpdate", nil);
end

function CompactUnitFrame_SetUpClicks(frame)
	frame:SetAttribute("*type1", "target");
    frame:SetAttribute("*type2", "menu");
	--NOTE: Make sure you also change the CompactAuraTemplate. (It has to be registered for clicks to be able to pass them through.)
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
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
	CompactUnitFrame_UpateVisible(frame);
	if ( UnitExists(frame.displayedUnit) ) then
		CompactUnitFrame_UpdateMaxHealth(frame);
		CompactUnitFrame_UpdateHealth(frame);
		CompactUnitFrame_UpdateHealthColor(frame);
		CompactUnitFrame_UpdateMaxPower(frame);
		CompactUnitFrame_UpdatePower(frame);
		CompactUnitFrame_UpdatePowerColor(frame);
		CompactUnitFrame_UpdateName(frame);
		CompactUnitFrame_UpdateSelectionHighlight(frame);
		CompactUnitFrame_UpdateAggroHighlight(frame);
		CompactUnitFrame_UpdateInRange(frame);
		CompactUnitFrame_UpdateStatusText(frame);
		CompactUnitFrame_UpdateHealPrediction(frame);
		CompactUnitFrame_UpdateRoleIcon(frame);
		CompactUnitFrame_UpdateReadyCheck(frame);
		CompactUnitFrame_UpdateAuras(frame);
	end
end

function CompactUnitFrame_UpdateInVehicle(frame)
	if ( UnitHasVehicleUI(frame.unit) ) then
		if ( not frame.inVehicle ) then
			frame.inVehicle = true;
			local prefix, id, suffix = string.match(frame.unit, "([^%d]+)([%d]*)(.*)")
			frame.displayedUnit = prefix.."pet"..id..suffix;
			frame:SetAttribute("unit", frame.displayedUnit);
		end
	else
		if ( frame.inVehicle ) then
			frame.inVehicle = false;
			frame.displayedUnit = frame.unit;
			frame:SetAttribute("unit", frame.displayedUnit);
		end
	end
end

function CompactUnitFrame_UpateVisible(frame)
	if ( UnitExists(frame.unit) or UnitExists(frame.displayedUnit) ) then
		frame:Show();
	else
		frame:Hide();
	end
end

function CompactUnitFrame_UpdateHealthColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Try to color it by class.
		local localizedClass, englishClass = UnitClass(frame.unit);
		local classColor = RAID_CLASS_COLORS[englishClass];
		if ( classColor and frame.optionTable.useClassColors ) then
			r, g, b = classColor.r, classColor.g, classColor.b;
		else
			if ( UnitIsFriend("player", frame.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	frame.healthBar:SetStatusBarColor(r, g, b);
end

function CompactUnitFrame_UpdateMaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	frame.healthBar:SetMinMaxValues(0, maxHealth);
	frame.myHealPredictionBar:SetMinMaxValues(0, maxHealth);
	frame.otherHealPredictionBar:SetMinMaxValues(0, maxHealth);
end

function CompactUnitFrame_UpdateHealth(frame)
	frame.healthBar:SetValue(UnitHealth(frame.displayedUnit));
end

local function CompactUnitFrame_GetDisplayedPowerID(frame)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip = UnitAlternatePowerInfo(frame.displayedUnit);
	if ( showOnRaid and (UnitInParty(frame.unit) or UnitInRaid(frame.unit)) ) then
		return ALTERNATE_POWER_INDEX;
	else
		return (UnitPowerType(frame.displayedUnit));
	end
end

function CompactUnitFrame_UpdateMaxPower(frame)	
	frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.displayedUnit, CompactUnitFrame_GetDisplayedPowerID(frame)));
end

function CompactUnitFrame_UpdatePower(frame)
	frame.powerBar:SetValue(UnitPower(frame.displayedUnit, CompactUnitFrame_GetDisplayedPowerID(frame)));
end

function CompactUnitFrame_UpdatePowerColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Set it to the proper power type color.
		local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip = UnitAlternatePowerInfo(frame.unit);
		if ( showOnRaid ) then
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

function CompactUnitFrame_UpdateName(frame)
	if ( not frame.optionTable.displayName ) then
		frame.name:Hide();
		return;
	end
	
	frame.name:SetText(GetUnitName(frame.unit, true));
	frame.name:Show();
end

function CompactUnitFrame_UpdateAuras(frame)
	CompactUnitFrame_UpdateBuffs(frame);
	CompactUnitFrame_UpdateDebuffs(frame);
	CompactUnitFrame_UpdateDispellableDebuffs(frame);
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
		frame.aggroHighlight:Hide();
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

function CompactUnitFrame_UpdateInRange(frame)
	if ( not frame.optionTable.fadeOutOfRange ) then
		frame:SetAlpha(1);
		return;
	end
	
	local inRange, checkedRange = UnitInRange(frame.displayedUnit);
	if ( checkedRange and not inRange ) then	--If we weren't able to check the range for some reason, we'll just treat them as in-range (for example, enemy units)
		frame:SetAlpha(0.55);
	else
		frame:SetAlpha(1);
	end
end

function CompactUnitFrame_UpdateStatusText(frame)
	if ( not frame.optionTable.displayStatusText ) then
		frame.statusText:Hide();
		return;
	end
	
	if ( not UnitIsConnected(frame.unit) ) then
		frame.statusText:SetText(PLAYER_OFFLINE)
		frame.statusText:Show();
	elseif ( UnitIsDead(frame.displayedUnit) ) then
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
	elseif ( frame.optionTable.healthText == "perc" ) then
		local perc = math.ceil(100 * (UnitHealth(frame.displayedUnit)/UnitHealthMax(frame.displayedUnit)));
		frame.statusText:SetFormattedText("%d%%", perc);
		frame.statusText:Show();
	else
		frame.statusText:Hide();
	end
end

local MAX_INCOMING_HEAL_OVERFLOW = 1.05;
function CompactUnitFrame_UpdateHealPrediction(frame)
	if ( not frame.optionTable.displayHealPrediction ) then
		frame.myHealPredictionBar:Hide();
		frame.otherHealPredictionBar:Hide();
		return;
	end

	local myIncomingHeal = UnitGetIncomingHeals(frame.displayedUnit, "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals(frame.displayedUnit) or 0;
	
	--Make sure we don't go too far out of the frame.
	local health = frame.healthBar:GetValue();
	local _, maxHealth = frame.healthBar:GetMinMaxValues();
	
	--See how far we're going over.
	if ( health + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
		allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health;
	end
	
	--Transfer my incoming heals out of the allIncomingHeal
	if ( allIncomingHeal < myIncomingHeal ) then
		myIncomingHeal = allIncomingHeal;
		allIncomingHeal = 0;
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal;
	end
		
	frame.myHealPredictionBar:SetValue(myIncomingHeal);
	frame.otherHealPredictionBar:SetValue(allIncomingHeal);
	
	frame.myHealPredictionBar:Show();
	frame.otherHealPredictionBar:Show();
end

function CompactUnitFrame_UpdateRoleIcon(frame)
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
	local readyCheckStatus = GetReadyCheckStatus(frame.unit);
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

--Other internal functions
function CompactUnitFrame_UpdateBuffs(frame)
	if ( not frame.optionTable.displayBuffs ) then
		CompactUnitFrame_HideAllBuffs(frame);
		return;
	end
	
	local index = 1;
	local frameNum = 1;
	local filter = nil;
	while ( frameNum <= frame.maxBuffs ) do
		local buffName = UnitBuff(frame.displayedUnit, index, filter);
		if ( buffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayBuff(frame.displayedUnit, index, filter) ) then
				local buffFrame = frame.buffFrames[frameNum];
				CompactUnitFrame_UtilSetBuff(buffFrame, frame.displayedUnit, index, filter);
				frameNum = frameNum + 1;
			end
		else
			break;
		end
		index = index + 1;
	end
	for i=frameNum, frame.maxBuffs do
		local buffFrame = frame.buffFrames[i];
		buffFrame:Hide();
	end
end

function CompactUnitFrame_UpdateDebuffs(frame)
	if ( not frame.optionTable.displayDebuffs ) then
		CompactUnitFrame_HideAllDebuffs(frame);
		return;
	end
	
	local index = 1;
	local frameNum = 1;
	local filter = nil;
	local maxDebuffs = frame.maxDebuffs;
	--First, we go through displaying boss debuffs.
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayDebuff(frame.displayedUnit, index, filter) and CompactUnitFrame_UtilIsBossDebuff(frame.displayedUnit, index, filter) ) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter);
				CompactUnitFrame_UtilSetDebuffBossDebuff(debuffFrame, true);
				frameNum = frameNum + 1;
				--Boss debuffs are about twice as big as normal debuffs, so display one less.
				local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize
				maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
			end
		else
			break;
		end
		index = index + 1;
	end
	
	if ( frame.optionTable.displayOnlyDispellableDebuffs ) then
		filter = "RAID";
	end
	
	index = 1;
	--Now, we display all normal debuffs.
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayDebuff(frame.displayedUnit, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(frame.displayedUnit, index, filter)) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter);
				CompactUnitFrame_UtilSetDebuffBossDebuff(debuffFrame, false);
				frameNum = frameNum + 1;
			end
		else
			break;
		end
		index = index + 1;
	end
	
	for i=frameNum, frame.maxDebuffs do
		local debuffFrame = frame.debuffFrames[i];
		debuffFrame:Hide();
	end
end

local dispellableDebuffTypes = { Magic = true, Curse = true, Disease = true, Poison = true};
function CompactUnitFrame_UpdateDispellableDebuffs(frame)
	if ( not frame.optionTable.displayDispelDebuffs ) then
		CompactUnitFrame_HideAllDispelDebuffs(frame);
		return;
	end
	
	--Clear what we currently have.
	for debuffType, display in pairs(dispellableDebuffTypes) do
		if ( display ) then
			frame["hasDispel"..debuffType] = false;
		end
	end
	
	local index = 1;
	local frameNum = 1;
	local filter = "RAID";	--Only dispellable debuffs.
	while ( frameNum <= frame.maxDispelDebuffs ) do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(frame.displayedUnit, index, filter);
		if ( dispellableDebuffTypes[debuffType] and not frame["hasDispel"..debuffType] ) then
			frame["hasDispel"..debuffType] = true;
			local dispellDebuffFrame = frame.dispelDebuffFrames[frameNum];
			CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
			frameNum = frameNum + 1;
		elseif ( not name ) then
			break;
		end
		index = index + 1;
	end
	for i=frameNum, frame.maxDispelDebuffs do
		local dispellDebuffFrame = frame.dispelDebuffFrames[i];
		dispellDebuffFrame:Hide();
	end
end

--Utility Functions
function CompactUnitFrame_UtilShouldDisplayBuff(unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura = UnitBuff(unit, index, filter);
	if ( UnitAffectingCombat("player") ) then
		return (unitCaster == "player" or unitCaster == "pet") and not shouldConsolidate and duration > 0 and canApplyAura;
	else
		return canApplyAura;
	end
end

function CompactUnitFrame_HideAllBuffs(frame)
	for i=1, #frame.buffFrames do
		frame.buffFrames[i]:Hide();
	end
end

function CompactUnitFrame_UtilSetBuff(buffFrame, unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura = UnitBuff(unit, index, filter);
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 10 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	buffFrame:SetID(index);
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		buffFrame.cooldown:SetCooldown(startTime, duration);
		buffFrame.cooldown:Show();
	else
		buffFrame.cooldown:Hide();
	end
	buffFrame:Show();
end

function CompactUnitFrame_UtilShouldDisplayDebuff(unit, index, filter)
	--local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(unit, index, filter);
	return true;
end

function CompactUnitFrame_UtilIsBossDebuff(unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff = UnitDebuff(unit, index, filter);
	return isBossDebuff;
end

function CompactUnitFrame_HideAllDebuffs(frame)
	for i=1, #frame.debuffFrames do
		frame.debuffFrames[i]:Hide();
	end
end

function CompactUnitFrame_UtilSetDebuffBossDebuff(debuffFrame, isBossDebuff)
	if ( isBossDebuff ) then
		debuffFrame:SetSize(debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE, debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE);
	else
		debuffFrame:SetSize(debuffFrame.baseSize, debuffFrame.baseSize);
	end
end

function CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(unit, index, filter);
	debuffFrame.filter = filter;
	debuffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 10 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		debuffFrame.count:Show();
		debuffFrame.count:SetText(countText);
	else
		debuffFrame.count:Hide();
	end
	debuffFrame:SetID(index);
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		debuffFrame.cooldown:SetCooldown(startTime, duration);
		debuffFrame.cooldown:Show();
	else
		debuffFrame.cooldown:Hide();
	end
	
	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
	
	debuffFrame:Show();
end

function CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
	dispellDebuffFrame:Show();
	dispellDebuffFrame.icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..debuffType);
	dispellDebuffFrame:SetID(index);
end

function CompactUnitFrame_HideAllDispelDebuffs(frame)
	for i=1, #frame.dispelDebuffFrames do
		frame.dispelDebuffFrames[i]:Hide();
	end
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
			name = GetRaidRosterInfo(id);
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
	healthText = "none",
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
	
	frame:SetSize(options.width, options.height)
	local powerBarHeight = 8;
	local powerBarUsedHeight = options.displayPowerBar and powerBarHeight or 0;
	
	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);
	
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1 + powerBarUsedHeight);
	
	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");
	
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
	
	frame.myHealPredictionBar:SetPoint("TOPLEFT", frame.healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
	frame.myHealPredictionBar:SetPoint("BOTTOMLEFT", frame.healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
	frame.myHealPredictionBar:SetWidth(options.width);
	frame.myHealPredictionBar:SetStatusBarTexture("", "BORDER", -1);
	frame.myHealPredictionBar:GetStatusBarTexture():SetTexture(1, 1, 1);
	frame.myHealPredictionBar:GetStatusBarTexture():SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);
	
	frame.otherHealPredictionBar:SetPoint("TOPLEFT", frame.myHealPredictionBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
	frame.otherHealPredictionBar:SetPoint("BOTTOMLEFT", frame.myHealPredictionBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
	frame.otherHealPredictionBar:SetWidth(options.width);
	frame.otherHealPredictionBar:SetStatusBarTexture("", "BORDER", -1);
	frame.otherHealPredictionBar:GetStatusBarTexture():SetTexture(1, 1, 1);
	frame.otherHealPredictionBar:GetStatusBarTexture():SetGradient("VERTICAL", 11/255, 53/255, 43/255, 21/255, 89/255, 72/255);
	
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
	
	local auraPos, auraOffset;
	if ( options.displayPowerBar ) then
		auraPos = "TOP";
		auraOffset = 2 + powerBarUsedHeight + buffSize;
	else
		auraPos = "BOTTOM";
		auraOffset = 2 + powerBarUsedHeight;
	end
	
	local buffPos, buffRelativePoint, buffOffset = auraPos.."RIGHT", auraPos.."LEFT", auraOffset;
	frame.buffFrames[1]:ClearAllPoints();
	frame.buffFrames[1]:SetPoint(buffPos, frame, "BOTTOMRIGHT", -3, buffOffset);
	for i=1, #frame.buffFrames do
		if ( i > 1 ) then
			frame.buffFrames[i]:ClearAllPoints();
			frame.buffFrames[i]:SetPoint(buffPos, frame.buffFrames[i - 1], buffRelativePoint, 0, 0);
		end
		frame.buffFrames[i]:SetSize(buffSize, buffSize);
	end
	
	local debuffPos, debuffRelativePoint, debuffOffset = auraPos.."LEFT", auraPos.."RIGHT", auraOffset;
	frame.debuffFrames[1]:ClearAllPoints();
	frame.debuffFrames[1]:SetPoint(debuffPos, frame, "BOTTOMLEFT", 3, debuffOffset);
	for i=1, #frame.debuffFrames do
		if ( i > 1 ) then
			frame.debuffFrames[i]:ClearAllPoints();
			frame.debuffFrames[i]:SetPoint(debuffPos, frame.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
		end
		frame.debuffFrames[i].baseSize = buffSize;
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
	frame:SetSize(options.width, options.height)
	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");
	
	frame.myHealPredictionBar:SetPoint("TOPLEFT", frame.healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
	frame.myHealPredictionBar:SetPoint("BOTTOMLEFT", frame.healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
	frame.myHealPredictionBar:SetWidth(70);
	frame.myHealPredictionBar:SetStatusBarTexture("", "BORDER", -1);
	frame.myHealPredictionBar:GetStatusBarTexture():SetTexture(1, 1, 1);
	frame.myHealPredictionBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, 139/255, 20/255, 10/255, 202/255, 29/255);
	
	frame.otherHealPredictionBar:SetPoint("TOPLEFT", frame.myHealPredictionBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
	frame.otherHealPredictionBar:SetPoint("BOTTOMLEFT", frame.myHealPredictionBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
	frame.otherHealPredictionBar:SetWidth(70);
	frame.otherHealPredictionBar:SetStatusBarTexture("", "BORDER", -1);
	frame.otherHealPredictionBar:GetStatusBarTexture():SetTexture(1, 1, 1);
	frame.otherHealPredictionBar:GetStatusBarTexture():SetGradient("VERTICAL", 3/255, 72/255, 5/255, 2/255, 101/255, 18/255);
	
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
