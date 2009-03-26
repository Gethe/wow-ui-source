MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;

-- aura positioning constants
local AURA_START_X = 5;
local AURA_START_Y = 32;
local AURA_OFFSET_Y = 3;
local LARGE_AURA_SIZE = 21;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 122;
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

function TargetFrame_OnLoad (self)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	TargetFrame_Update(self);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");

	local frameLevel = TargetFrameTextureFrame:GetFrameLevel();
	TargetFrameHealthBar:SetFrameLevel(frameLevel-1);
	TargetFrameManaBar:SetFrameLevel(frameLevel-1);
	TargetFrameSpellBar:SetFrameLevel(frameLevel-1);

	local showmenu = function()
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "TargetFrame", 120, 10);
	end
	SecureUnitButton_OnLoad(self, "target", showmenu);
end

function TargetFrame_Update (self)
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not UnitExists("target") ) then
		self:Hide();
	else
		self:Show();

		-- Moved here to avoid taint from functions below
		TargetofTarget_Update();

		UnitFrame_Update(self);
		TargetFrame_CheckLevel(self);
		TargetFrame_CheckFaction(self);
		TargetFrame_CheckClassification(self);
		TargetFrame_CheckDead(self);
		if ( UnitIsPartyLeader("target") ) then
			TargetLeaderIcon:Show();
		else
			TargetLeaderIcon:Hide();
		end
		TargetFrame_UpdateAuras(self);
		TargetPortrait:SetAlpha(1.0);
	end
end

function TargetFrame_OnEvent (self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		TargetFrame_Update(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		TargetFrame_Update(self);
		TargetFrame_UpdateRaidTargetIcon(self);
		CloseDropDownMenus();

		if ( UnitExists("target") ) then
			if ( UnitIsEnemy("target", "player") ) then
				PlaySound("igCreatureAggroSelect");
			elseif ( UnitIsFriend("player", "target") ) then
				PlaySound("igCharacterNPCSelect");
			else
				PlaySound("igCreatureNeutralSelect");
			end
		end
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckDead(self);
		end
	elseif ( event == "UNIT_LEVEL" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckLevel(self);
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == "target" or arg1 == "player" ) then
			TargetFrame_CheckFaction(self);
			TargetFrame_CheckLevel(self);
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckClassification(self);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == "target" ) then
			TargetFrame_UpdateAuras(self);
		end
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		if ( arg1 == "target" ) then
			if ( UnitIsPartyLeader("target") ) then
				TargetLeaderIcon:Show();
			else
				TargetLeaderIcon:Hide();
			end
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		TargetofTarget_Update();
		TargetFrame_CheckFaction(self);
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		TargetFrame_UpdateRaidTargetIcon(self);
	end
end

function TargetFrame_OnHide (self)
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	CloseDropDownMenus();
end

function TargetFrame_CheckLevel (self)
	local targetLevel = UnitLevel("target");
	
	if ( UnitIsCorpse("target") ) then
		TargetLevelText:Hide();
		TargetHighLevelTexture:Show();
	elseif ( targetLevel > 0 ) then
		-- Normal level target
		TargetLevelText:SetText(targetLevel);
		-- Color level number
		if ( UnitCanAttack("player", "target") ) then
			local color = GetDifficultyColor(targetLevel);
			TargetLevelText:SetVertexColor(color.r, color.g, color.b);
		else
			TargetLevelText:SetVertexColor(1.0, 0.82, 0.0);
		end
		TargetLevelText:Show();
		TargetHighLevelTexture:Hide();
	else
		-- Target is too high level to tell
		TargetLevelText:Hide();
		TargetHighLevelTexture:Show();
	end
end

function TargetFrame_CheckFaction (self)
	if ( not UnitPlayerControlled("target") and UnitIsTapped("target") and not UnitIsTappedByPlayer("target") and not UnitIsTappedByAllThreatList("target") ) then
		TargetFrameNameBackground:SetVertexColor(0.5, 0.5, 0.5);
		TargetPortrait:SetVertexColor(0.5, 0.5, 0.5);
	else
		TargetFrameNameBackground:SetVertexColor(UnitSelectionColor("target"));
		TargetPortrait:SetVertexColor(1.0, 1.0, 1.0);
	end

	local factionGroup = UnitFactionGroup("target");
	if ( UnitIsPVPFreeForAll("target") ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		TargetPVPIcon:Show();
	elseif ( factionGroup and UnitIsPVP("target") ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		TargetPVPIcon:Show();
	else
		TargetPVPIcon:Hide();
	end
end

function TargetFrame_CheckClassification (self)
	local classification = UnitClassification("target");
	if ( classification == "worldboss" ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
		TargetFrameFlash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
		TargetFrameFlash:SetWidth(242);
		TargetFrameFlash:SetHeight(112);
		TargetFrameFlash:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -22, 9);
	elseif ( classification == "rareelite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite");
		TargetFrameFlash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
		TargetFrameFlash:SetWidth(242);
		TargetFrameFlash:SetHeight(112);
		TargetFrameFlash:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -22, 9);
	elseif ( classification == "elite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
		TargetFrameFlash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
		TargetFrameFlash:SetWidth(242);
		TargetFrameFlash:SetHeight(112);
		TargetFrameFlash:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -22, 9);
	elseif ( classification == "rare"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare");
		TargetFrameFlash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
		TargetFrameFlash:SetWidth(242);
		TargetFrameFlash:SetHeight(112);
		TargetFrameFlash:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -22, 9);
	else
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
		TargetFrameFlash:SetTexCoord(0, 0.9453125, 0, 0.181640625);
		TargetFrameFlash:SetWidth(242);
		TargetFrameFlash:SetHeight(93);
		TargetFrameFlash:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -24, 0);
	end
end

function TargetFrame_CheckDead (self)
	if ( (UnitHealth("target") <= 0) and UnitIsConnected("target") ) then
		TargetDeadText:Show();
	else
		TargetDeadText:Hide();
	end
end

function TargetFrame_OnUpdate (self, elapsed)
	if ( TargetofTargetFrame:IsShown() ~= UnitExists("targettarget") ) then
		TargetofTarget_Update();
	end
	
	self.elapsed = (self.elapsed or 0) + elapsed;
	if ( self.elapsed > 0.5 ) then
		self.elapsed = 0;
		UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator, self.feedbackUnit);
	end
end

local largeBuffList = {};
local largeDebuffList = {};

function TargetFrame_UpdateAuras (self)
	local frame, frameName;
	local frameIcon, frameCount, frameCooldown;

	local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable;
	local playerIsTarget = UnitIsUnit(PlayerFrame.unit, "target");

	local frameStealable;
	local numBuffs = 0;
	for i=1, MAX_TARGET_BUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff("target", i);
		frameName = "TargetFrameBuff"..i;
		frame = _G[frameName];
		if ( not frame ) then
			if ( not icon ) then
				break;
			else
				frame = CreateFrame("Button", frameName, TargetFrame, "TargetBuffFrameTemplate");
				frame.unit = "target";
			end
		end
		if ( icon ) then
			frame:SetID(i);

			-- set the icon
			frameIcon = _G[frameName.."Icon"];
			frameIcon:SetTexture(icon);

			-- set the count
			frameCount = _G[frameName.."Count"];
			if ( count > 1 ) then
				frameCount:SetText(count);
				frameCount:Show();
			else
				frameCount:Hide();
			end

			-- Handle cooldowns
			frameCooldown = _G[frameName.."Cooldown"];
			if ( duration > 0 ) then
				frameCooldown:Show();
				CooldownFrame_SetTimer(frameCooldown, expirationTime - duration, duration, 1);
			else
				frameCooldown:Hide();
			end

			-- Show stealable frame if the target is not a player and the buff is stealable.
			frameStealable = _G[frameName.."Stealable"];
			if ( not playerIsTarget and isStealable ) then
				frameStealable:Show();
			else
				frameStealable:Hide();
			end

			-- set the buff to be big if the target is not the player and the buff is cast by the player or his pet
			largeBuffList[i] = (not playerIsTarget and PLAYER_UNITS[caster]);

			numBuffs = numBuffs + 1;

			frame:ClearAllPoints();
			frame:Show();
		else
			frame:Hide();
		end
	end

	local color;
	local frameBorder;
	local numDebuffs = 0;
	for i=1, MAX_TARGET_DEBUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff("target", i);
		frameName = "TargetFrameDebuff"..i;
		frame = _G[frameName];
		if ( not frame ) then
			if ( not icon ) then
				break;
			else
				frame = CreateFrame("Button", frameName, TargetFrame, "TargetDebuffFrameTemplate");
				frame.unit = "target";
			end
		end
		if ( icon ) then
			frame:SetID(i);

			-- set the icon
			frameIcon = _G[frameName.."Icon"];
			frameIcon:SetTexture(icon);

			-- set the count
			frameCount = _G[frameName.."Count"];
			if ( count > 1 ) then
				frameCount:SetText(count);
				frameCount:Show();
			else
				frameCount:Hide();
			end

			-- Handle cooldowns
			frameCooldown = _G[frameName.."Cooldown"];
			if ( duration > 0 ) then
				frameCooldown:Show();
				CooldownFrame_SetTimer(frameCooldown, expirationTime - duration, duration, 1);
			else
				frameCooldown:Hide();
			end

			-- set debuff type color
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			frameBorder = _G[frameName.."Border"];
			frameBorder:SetVertexColor(color.r, color.g, color.b);

			-- set the debuff to be big if the buff is cast by the player or his pet
			largeDebuffList[i] = (PLAYER_UNITS[caster]);

			numDebuffs = numDebuffs + 1;

			frame:ClearAllPoints();
			frame:Show();
		else
			frame:Hide();
		end
	end

	TargetFrame.auraRows = 0;
	local haveTargetofTarget = TargetofTargetFrame:IsShown();
	local maxRowWidth;
	-- update buff positions
	maxRowWidth = ( haveTargetofTarget and TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	TargetFrame_UpdateAuraPositions("TargetFrameBuff", numBuffs, numDebuffs, largeBuffList, TargetFrame_UpdateBuffAnchor, maxRowWidth, 3);
	-- update debuff positions
	maxRowWidth = ( haveTargetofTarget and TargetFrame.auraRows < NUM_TOT_AURA_ROWS and TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	TargetFrame_UpdateAuraPositions("TargetFrameDebuff", numDebuffs, numBuffs, largeDebuffList, TargetFrame_UpdateDebuffAnchor, maxRowWidth, 4);
	-- update the spell bar position
	Target_Spellbar_AdjustPosition();
end

function TargetFrame_UpdateAuraPositions(auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX)
	-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

	-- Position auras
	local size;
	local offsetY = AURA_OFFSET_Y;
	-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
	local rowWidth = 0;
	local firstBuffOnRow = 1;
	for i=1, numAuras do
		-- update size and offset info based on large aura status
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end

		-- anchor the current aura
		if ( i == 1 ) then
			rowWidth = size;
			TargetFrame.auraRows = TargetFrame.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > maxRowWidth ) then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			updateFunc(auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY);

			rowWidth = size;
			TargetFrame.auraRows = TargetFrame.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;

			if ( TargetFrame.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY);
		end
	end
end

function TargetFrame_UpdateBuffAnchor(buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[buffName..index];

	if ( index == 1 ) then
		if ( UnitIsFriend("player", "target") or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint("TOPLEFT", TargetFrameDebuffs, "BOTTOMLEFT", 0, -offsetY);
		end
		TargetFrameBuffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
	else
		-- anchor index is the previous index
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "TOPRIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

function TargetFrame_UpdateDebuffAnchor(debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[debuffName..index];

	if ( index == 1 ) then
		if ( UnitIsFriend("player", "target") and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint("TOPLEFT", TargetFrameBuffs, "BOTTOMLEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);
		end
		TargetFrameDebuffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[debuffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
	else
		-- anchor index is the previous index
		buff:SetPoint("TOPLEFT", _G[debuffName..(index-1)], "TOPRIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
	local debuffFrame =_G[debuffName..index.."Border"];
	debuffFrame:SetWidth(size+2);
	debuffFrame:SetHeight(size+2);
end

function TargetFrame_HealthUpdate (self, elapsed, unit)
	if ( UnitIsPlayer(unit) ) then
		if ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			local alpha = 255;
			local counter = self.statusCounter + elapsed;
			local sign    = self.statusSign;
	
			if ( counter > 0.5 ) then
				sign = -sign;
				self.statusSign = sign;
			end
			counter = mod(counter, 0.5);
			self.statusCounter = counter;
	
			if ( sign == 1 ) then
				alpha = (127  + (counter * 256)) / 255;
			else
				alpha = (255 - (counter * 256)) / 255;
			end
			TargetPortrait:SetAlpha(alpha);
		end
	end
end

function TargetHealthCheck (self)
	if ( UnitIsPlayer("target") ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = self:GetValue();
		self:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("target") ) then
			TargetPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("target") ) then
			TargetPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (self:GetParent().unitHPPercent > 0) and (self:GetParent().unitHPPercent <= 0.2) ) then
			TargetPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end

function TargetFrameDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, TargetFrameDropDown_Initialize, "MENU");
end

function TargetFrameDropDown_Initialize (self)
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("target", "vehicle") ) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif ( UnitIsUnit("target", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("target") ) then
		id = UnitInRaid("target");
		if ( id ) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id +1);
		elseif ( UnitInParty("target") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, "target", name, id);
	end
end



-- Raid target icon function
RAID_TARGET_ICON_DIMENSION = 64;
RAID_TARGET_TEXTURE_DIMENSION = 256;
RAID_TARGET_TEXTURE_COLUMNS = 4;
RAID_TARGET_TEXTURE_ROWS = 4;
function TargetFrame_UpdateRaidTargetIcon (self)
	local index = GetRaidTargetIndex("target");
	if ( index ) then
		SetRaidTargetIconTexture(TargetRaidTargetIcon, index);
		TargetRaidTargetIcon:Show();
	else
		TargetRaidTargetIcon:Hide();
	end
end


function SetRaidTargetIconTexture (texture, raidTargetIconIndex)
	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function SetRaidTargetIcon (unit, index)
	if ( GetRaidTargetIndex(unit) and GetRaidTargetIndex(unit) == index ) then
		SetRaidTarget(unit, 0);
	else
		SetRaidTarget(unit, index);
	end
end

function TargetofTarget_OnLoad (self)
	UnitFrame_Initialize(self, "targettarget", TargetofTargetName, TargetofTargetPortrait,
		TargetofTargetHealthBar, TargetofTargetHealthBarText,
		TargetofTargetManaBar, TargetofTargetFrameManaBarText,
		TargetofTargetThreatIndicator, "player");
	SetTextStatusBarTextZeroText(TargetofTargetHealthBar, DEAD);
	self:RegisterEvent("UNIT_AURA");

	SecureUnitButton_OnLoad(self, "targettarget");
end

function TargetofTarget_OnHide (self)
	TargetFrame_UpdateAuras(self);
end

function TargetofTarget_Update (self, elapsed)
	if ( not self ) then
		self = TargetofTargetFrame;
	end

	local show;
	if ( SHOW_TARGET_OF_TARGET == "1" and UnitExists("target") and UnitExists("targettarget") and ( not UnitIsUnit(PlayerFrame.unit, "target") ) and ( UnitHealth("target") > 0 ) ) then
		if ( ( SHOW_TARGET_OF_TARGET_STATE == "5" ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "4" and ( (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "3" and ( (GetNumRaidMembers() == 0) and (GetNumPartyMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "2" and ( (GetNumPartyMembers() > 0) and (GetNumRaidMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "1" and ( GetNumRaidMembers() > 0 ) ) ) then
			show = true;
		end
	end

	if ( show ) then
		if ( not TargetofTargetFrame:IsShown() ) then
			TargetofTargetFrame:Show();
			Target_Spellbar_AdjustPosition();
		end
		UnitFrame_Update(self);
		TargetofTarget_CheckDead();
		TargetofTargetHealthCheck();
		RefreshDebuffs(TargetofTargetFrame, "targettarget");
	else
		if ( TargetofTargetFrame:IsShown() ) then
			TargetofTargetFrame:Hide();
			Target_Spellbar_AdjustPosition();
		end
	end
end

function TargetofTarget_CheckDead ()
	if ( (UnitHealth("targettarget") <= 0) and UnitIsConnected("targettarget") ) then
		TargetofTargetBackground:SetAlpha(0.9);
		TargetofTargetDeadText:Show();
	else
		TargetofTargetBackground:SetAlpha(1);
		TargetofTargetDeadText:Hide();
	end
end

function TargetofTargetHealthCheck ()
	if ( UnitIsPlayer("targettarget") ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = TargetofTargetHealthBar:GetMinMaxValues();
		unitCurrHP = TargetofTargetHealthBar:GetValue();
		TargetofTargetFrame.unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("targettarget") ) then
			TargetofTargetPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("targettarget") ) then
			TargetofTargetPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (TargetofTargetFrame.unitHPPercent > 0) and (TargetofTargetFrame.unitHPPercent <= 0.2) ) then
			TargetofTargetPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetofTargetPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end


function SetTargetSpellbarAspect()
	local targetFrameSpellBarName = TargetFrameSpellBar:GetName();

	local frameText = _G[targetFrameSpellBarName.."Text"];
	if ( frameText ) then
		frameText:SetFontObject(SystemFont_Shadow_Small);
		frameText:ClearAllPoints();
		frameText:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 4);
	end

	local frameBorder = _G[targetFrameSpellBarName.."Border"];
	if ( frameBorder ) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		frameBorder:SetWidth(197);
		frameBorder:SetHeight(49);
		frameBorder:ClearAllPoints();
		frameBorder:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 20);
	end

	local frameFlash = _G[targetFrameSpellBarName.."Flash"];
	if ( frameFlash ) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		frameFlash:SetWidth(197);
		frameFlash:SetHeight(49);
		frameFlash:ClearAllPoints();
		frameFlash:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 20);
	end
end

function Target_Spellbar_OnLoad (self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	
	CastingBarFrame_OnLoad(self, "target", false);

	local name = self:GetName();

	local barIcon =_G[name.."Icon"];
	barIcon:Show();

	SetTargetSpellbarAspect();
	
	--The target casting bar has less room for text than most, so shorten it
	_G[name.."Text"]:SetWidth(150)
	-- check to see if the castbar should be shown
	if ( GetCVar("showTargetCastbar") == "0") then
		self.showCastbar = false;	
	end
end

function Target_Spellbar_OnEvent (self, event, ...)
	local arg1 = ...
	
	--	Check for target specific events
	if ( (event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "SHOW_TARGET_CASTBAR")) ) then
		if ( GetCVar("showTargetCastbar") == "0") then
			self.showCastbar = false;
		else
			self.showCastbar = true;
		end
		
		if ( not self.showCastbar ) then
			self:Hide();
		elseif ( self.casting or self.channeling ) then
			self:Show();
		end
		return;
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = "target";
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = "target";
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
		-- The position depends on the classification of the target
		Target_Spellbar_AdjustPosition();
	end
	CastingBarFrame_OnEvent(self, event, arg1, select(2, ...));
end

function Target_Spellbar_AdjustPosition ()
	local yPos = 5;
	if ( TargetFrame.auraRows ) then
		if ( TargetFrame.auraRows <= NUM_TOT_AURA_ROWS ) then
			yPos = 38;
		else
			yPos = 19 * TargetFrame.auraRows;
		end
	end
	if ( TargetofTargetFrame:IsShown() ) then
		if ( yPos <= 25 ) then
			yPos = yPos + 25;
		end
	else
		yPos = yPos - 5;
		local classification = UnitClassification("target");
		if ( (yPos < 17) and ((classification == "worldboss") or (classification == "rareelite") or (classification == "elite") or (classification == "rare")) ) then
			yPos = 17;
		end
	end
	TargetFrameSpellBar:SetPoint("BOTTOM", "TargetFrame", "BOTTOM", -15, -yPos);
end
