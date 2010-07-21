--Widget Handlers
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
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("UNIT_HEAL_PREDICTION");
	
	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self.maxDispelDebuffs = 0;
	CompactUnitFrame_SetUpClicks(self);
	
	tinsert(UnitPopupFrames, self.dropDown:GetName());
end

function CompactUnitFrame_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if ( event == self.updateAllEvent ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
		CompactUnitFrame_UpdateAuras(self);	--We filter differently based on whether the player is in Combat, so we need to update when that changes.
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		CompactUnitFrame_UpdateRoleIcon(self);
	elseif ( arg1 == self.unit ) then
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
		elseif ( event == "UNIT_DISPLAYPOWER" ) then
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
		end
	end
end

--DEBUG FIXME - We should really try to avoid having OnUpdate on every frame. An event when going in/out of range would be greatly preferred.
function CompactUnitFrame_OnUpdate(self, elapsed)
	CompactUnitFrame_UpdateInRange(self);
end

--Externally accessed functions
function CompactUnitFrame_SetUnit(frame, unit)
	frame.unit = unit;
	frame:SetAttribute("unit", unit);
	if ( unit ) then
		CompactUnitFrame_RegisterEvents(frame);
	else
		CompactUnitFrame_UnregisterEvents(frame);
	end
	CompactUnitFrame_UpdateAll(frame);
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
function CompactUnitFrame_SetUpFrame(frame, func)
	func(frame);
	CompactUnitFrame_UpdateAll(frame);
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

function CompactUnitFrame_SetUpdateAllEvent(frame, updateAllEvent)
	if ( frame.updateAllEvent ) then
		frame:UnregisterEvent(frame.updateAllEvent);
	end
	frame.updateAllEvent = updateAllEvent;
	frame:RegisterEvent(updateAllEvent);
end
--Internally accessed functions

--Update Functions
function CompactUnitFrame_UpdateAll(frame)
	CompactUnitFrame_UpateVisible(frame);
	if ( UnitExists(frame.unit) ) then
		CompactUnitFrame_UpdateMaxHealth(frame);
		CompactUnitFrame_UpdateHealth(frame);
		CompactUnitFrame_UpdateHealthColor(frame);
		CompactUnitFrame_UpdateMaxPower(frame);
		CompactUnitFrame_UpdatePower(frame);
		CompactUnitFrame_UpdatePowerColor(frame);
		CompactUnitFrame_UpdateName(frame);
		CompactUnitFrame_UpdateAuras(frame);
		CompactUnitFrame_UpdateSelectionHighlight(frame);
		CompactUnitFrame_UpdateAggroHighlight(frame);
		CompactUnitFrame_UpdateInRange(frame);
		CompactUnitFrame_UpdateStatusText(frame);
		CompactUnitFrame_UpdateHealPrediction(frame);
		CompactUnitFrame_UpdateRoleIcon(frame);
	end
end

function CompactUnitFrame_UpateVisible(frame)
	if ( UnitExists(frame.unit) ) then
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
		if ( classColor) then
			r, g, b = classColor.r, classColor.g, classColor.b;
		else
			r, g, b = GameTooltip_UnitColor(frame.unit);
		end
	end
	frame.healthBar:SetStatusBarColor(r, g, b);
end

function CompactUnitFrame_UpdateMaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.unit);
	frame.healthBar:SetMinMaxValues(0, maxHealth);
	frame.myHealPredictionBar:SetMinMaxValues(0, maxHealth);
	frame.otherHealPredictionBar:SetMinMaxValues(0, maxHealth);
end

function CompactUnitFrame_UpdateHealth(frame)
	frame.healthBar:SetValue(UnitHealth(frame.unit));
end

function CompactUnitFrame_UpdateMaxPower(frame)
	frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.unit));
end

function CompactUnitFrame_UpdatePower(frame)
	frame.powerBar:SetValue(UnitPower(frame.unit));
end

function CompactUnitFrame_UpdatePowerColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Set it to the proper power type color.
		local powerType, powerToken, altR, altG, altB = UnitPowerType(frame.unit);
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
	frame.powerBar:SetStatusBarColor(r, g, b);
end

function CompactUnitFrame_UpdateName(frame)
	frame.name:SetText(GetUnitName(frame.unit, true));
end

function CompactUnitFrame_UpdateAuras(frame)
	CompactUnitFrame_UpdateBuffs(frame);
	CompactUnitFrame_UpdateDebuffs(frame);
	CompactUnitFrame_UpdateDispellableDebuffs(frame);
end

function CompactUnitFrame_UpdateSelectionHighlight(frame)
	if ( UnitIsUnit(frame.unit, "target") ) then
		frame.selectionHighlight:Show();
	else
		frame.selectionHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateAggroHighlight(frame)
	local status = UnitThreatSituation(frame.unit);
	if ( status and status > 0 ) then
		frame.aggroHighlight:SetVertexColor(GetThreatStatusColor(status));
		frame.aggroHighlight:Show();
	else
		frame.aggroHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateInRange(frame)
	local inRange, checkedRange = UnitInRange(frame.unit);
	if ( checkedRange and not inRange ) then	--If we weren't able to check the range for some reason, we'll just treat them as in-range (for example, enemy units)
		frame:SetAlpha(0.4);
	else
		frame:SetAlpha(1);
	end
end

function CompactUnitFrame_UpdateStatusText(frame)
	if ( not UnitIsConnected(frame.unit) ) then
		frame.statusText:SetText(PLAYER_OFFLINE)
		frame.statusText:Show();
	elseif ( UnitIsDead(frame.unit) ) then
		frame.statusText:SetText(DEAD);
		frame.statusText:Show();
	else
		frame.statusText:Hide();
	end
end

local MAX_INCOMING_HEAL_OVERFLOW = 1.05;
function CompactUnitFrame_UpdateHealPrediction(frame)
	local myIncomingHeal = UnitGetIncomingHeals(frame.unit, "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0;
	
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
end

function CompactUnitFrame_UpdateRoleIcon(frame)
	local role = UnitGroupRolesAssigned(frame.unit);
	local size = frame.roleIcon:GetHeight();	--We keep the height so that it carries from the set up, but we decrease the width to 0 to allow room for things anchored to the role (e.g. name).
	if ( role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		frame.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
		frame.roleIcon:Show();
		frame.roleIcon:SetSize(size, size);
	else
		frame.roleIcon:Hide();
		frame.roleIcon:SetSize(1, size);
	end
end

--Other internal functions
function CompactUnitFrame_UpdateBuffs(frame)
	local index = 1;
	local frameNum = 1;
	local filter = nil;
	while ( frameNum <= frame.maxBuffs ) do
		local buffName = UnitBuff(frame.unit, index, filter);
		if ( buffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayBuff(frame.unit, index, filter) ) then
				local buffFrame = frame.buffFrames[frameNum];
				CompactUnitFrame_UtilSetBuff(buffFrame, frame.unit, index, filter);
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
	local index = 1;
	local frameNum = 1;
	local filter = nil;
	while ( frameNum <= frame.maxDebuffs ) do
		local debuffName = UnitDebuff(frame.unit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayDebuff(frame.unit, index, filter) ) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.unit, index, filter);
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
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(frame.unit, index, filter);
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
		local dispellDebuffFrame = frame.dispelDebuffFrames[frameNum];
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

function CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff(unit, index, filter);
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
			name = GetRaidRosterInfo(id +1);
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

function DefaultCompactUnitFrameSetup(frame)
	frame:SetSize(72, 36)
	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 9);
	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");
	frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0);
	frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
	frame.powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill", "BORDER");
	frame.powerBar.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Background");
	
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
	
	frame.roleIcon:ClearAllPoints();
	frame.roleIcon:SetPoint("TOPLEFT", 3, -2);
	frame.roleIcon:SetSize(12, 12);
	
	frame.name:SetPoint("TOPLEFT", frame.roleIcon, "TOPRIGHT", 0, -1);
	frame.name:SetPoint("TOPRIGHT", -3, -3);
	frame.name:SetJustifyH("LEFT");
	
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, 10);
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 10);
	frame.statusText:SetHeight(12);
	
	CompactUnitFrame_SetMaxBuffs(frame, 3);
	CompactUnitFrame_SetMaxDebuffs(frame, 3);
	CompactUnitFrame_SetMaxDispelDebuffs(frame, 3);
	
	frame.buffFrames[1]:SetPoint("BOTTOMRIGHT", -3, 10);
	for i=1, #frame.buffFrames do
		if ( i > 1 ) then
			frame.buffFrames[i]:SetPoint("RIGHT", frame.buffFrames[i - 1], "LEFT", 0, 0);
		end
		frame.buffFrames[i]:SetSize(11, 11);
	end
	
	frame.debuffFrames[1]:SetPoint("BOTTOMLEFT", 3, 10);
	for i=1, #frame.debuffFrames do
		if ( i > 1 ) then
			frame.debuffFrames[i]:SetPoint("LEFT", frame.debuffFrames[i - 1], "RIGHT", 0, 0);
		end
		frame.debuffFrames[i]:SetSize(11, 11);
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
end