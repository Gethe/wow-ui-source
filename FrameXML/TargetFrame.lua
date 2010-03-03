MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;
MAX_BOSS_FRAMES = 4;

-- aura positioning constants
local AURA_START_X = 5;
local AURA_START_Y = 32;
local AURA_OFFSET_Y = 3;
local LARGE_AURA_SIZE = 21;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 122;
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

-- focus frame scales
local LARGE_FOCUS_SCALE = 1;
local SMALL_FOCUS_SCALE = 0.75;
local SMALL_FOCUS_UPSCALE = 1.333;

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

function TargetFrame_OnLoad(self, unit, menuFunc)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	
	local thisName = self:GetName();
	self.borderTexture = _G[thisName.."TextureFrameTexture"];
	self.highLevelTexture = _G[thisName.."TextureFrameHighLevelTexture"];	
	self.pvpIcon = _G[thisName.."TextureFramePVPIcon"];
	self.leaderIcon = _G[thisName.."TextureFrameLeaderIcon"];
	self.raidTargetIcon = _G[thisName.."TextureFrameRaidTargetIcon"];
	self.levelText = _G[thisName.."TextureFrameLevelText"];
	self.deadText = _G[thisName.."TextureFrameDeadText"];
	self.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
	-- set simple frame
	if ( not self.showLevel ) then
		self.highLevelTexture:Hide();
		self.levelText:Hide();
	end
	-- set threat frame
	local threatFrame;
	if ( self.showThreat ) then
		threatFrame = _G[thisName.."Flash"];
	end
	-- set portrait frame
	local portraitFrame;
	if ( self.showPortrait ) then
		portraitFrame = _G[thisName.."Portrait"];
	end
	
	UnitFrame_Initialize(self, unit, _G[thisName.."TextureFrameName"], portraitFrame,
						 _G[thisName.."HealthBar"], _G[thisName.."TextureFrameHealthBarText"],
						 _G[thisName.."ManaBar"], _G[thisName.."TextureFrameManaBarText"],
	                     threatFrame, "player", _G[thisName.."NumericalThreat"]);
						
	TargetFrame_Update(self);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("CVAR_UPDATE");
	if ( self.showLevel ) then
		self:RegisterEvent("UNIT_LEVEL");
	end
	self:RegisterEvent("UNIT_FACTION");
	if ( self.showClassification ) then
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	end
	self:RegisterEvent("UNIT_AURA");
	if ( self.showLeader ) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	end
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	
	local frameLevel = _G[thisName.."TextureFrame"]:GetFrameLevel();
	self.healthbar:SetFrameLevel(frameLevel-1);
	self.manabar:SetFrameLevel(frameLevel-1);

	local showmenu;
	if ( menuFunc ) then
		UIDropDownMenu_Initialize(_G[thisName.."DropDown"], menuFunc, "MENU");
		showmenu = function()
			ToggleDropDownMenu(1, nil, _G[thisName.."DropDown"], thisName, 120, 10);
		end		
	end
	SecureUnitButton_OnLoad(self, self.unit, showmenu);
end

function TargetFrame_Update (self)
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not UnitExists(self.unit) ) then
		self:Hide();
	else
		self:Show();

		-- Moved here to avoid taint from functions below
		if ( self.totFrame ) then
			TargetofTarget_Update(self.totFrame);
		end
		
		UnitFrame_Update(self);
		if ( self.showLevel ) then
			TargetFrame_CheckLevel(self);
		end
		TargetFrame_CheckFaction(self);
		if ( self.showClassification ) then
			TargetFrame_CheckClassification(self);
		end
		TargetFrame_CheckDead(self);
		if ( self.showLeader ) then
			if ( UnitIsPartyLeader(self.unit) and (UnitInParty(self.unit) or UnitInRaid(self.unit)) ) then
				if ( HasLFGRestrictions() ) then
					self.leaderIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
					self.leaderIcon:SetTexCoord(0, 0.296875, 0.015625, 0.3125);
				else
					self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
					self.leaderIcon:SetTexCoord(0, 1, 0, 1);
				end
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
		TargetFrame_UpdateAuras(self);
		if ( self.portrait ) then
			self.portrait:SetAlpha(1.0);
		end
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

		if ( UnitExists(self.unit) ) then
			if ( UnitIsEnemy(self.unit, "player") ) then
				PlaySound("igCreatureAggroSelect");
			elseif ( UnitIsFriend("player", self.unit) ) then
				PlaySound("igCharacterNPCSelect");
			else
				PlaySound("igCreatureNeutralSelect");
			end
		end
	elseif ( event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" ) then
		for i = 1, MAX_BOSS_FRAMES do
			TargetFrame_Update(_G["Boss"..i.."TargetFrame"]);
			TargetFrame_UpdateRaidTargetIcon(_G["Boss"..i.."TargetFrame"]);
		end
		CloseDropDownMenus();
		UIParent_ManageFramePositions();
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == self.unit ) then
			TargetFrame_CheckDead(self);
		end
	elseif ( event == "UNIT_LEVEL" ) then
		if ( arg1 == self.unit ) then
			TargetFrame_CheckLevel(self);
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == self.unit or arg1 == "player" ) then
			TargetFrame_CheckFaction(self);
			if ( self.showLevel ) then
				TargetFrame_CheckLevel(self);
			end
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == self.unit ) then
			TargetFrame_CheckClassification(self);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			TargetFrame_UpdateAuras(self);
		end
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		if ( arg1 == self.unit ) then
			if ( UnitIsPartyLeader(self.unit) ) then
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		if (self.unit == "focus") then
			TargetFrame_Update(self);
			-- If this is the focus frame, clear focus if the unit no longer exists
			if (not UnitExists(self.unit)) then
				ClearFocus();
			end
		else
			if ( self.totFrame ) then
				TargetofTarget_Update(self.totFrame);
			end
			TargetFrame_CheckFaction(self);
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		TargetFrame_UpdateRaidTargetIcon(self);
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		if ( UnitExists(self.unit) ) then
			self:Show();
			TargetFrame_Update(self);
			TargetFrame_UpdateRaidTargetIcon(self);
		else
			self:Hide();
		end
		CloseDropDownMenus();
	elseif ( event == "VARIABLES_LOADED" ) then
		FocusFrame_SetSmallSize(not GetCVarBool("fullSizeFocusFrame"));
	elseif ( event == "CVAR_UPDATE" ) then
		if ( arg1 == "SHOW_CASTABLE_DEBUFFS_TEXT" and self:IsShown() ) then
			-- have to set uvar manually or it will be the previous value
			SHOW_CASTABLE_DEBUFFS = GetCVar("showCastableDebuffs");
			TargetFrame_UpdateAuras(self);
		end		
	end
end

function TargetFrame_OnHide (self)
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	CloseDropDownMenus();
end

function TargetFrame_CheckLevel (self)
	local targetLevel = UnitLevel(self.unit);
	
	if ( UnitIsCorpse(self.unit) ) then
		self.levelText:Hide();
		self.highLevelTexture:Show();
	elseif ( targetLevel > 0 ) then
		-- Normal level target
		self.levelText:SetText(targetLevel);
		-- Color level number
		if ( UnitCanAttack("player", self.unit) ) then
			local color = GetQuestDifficultyColor(targetLevel);
			self.levelText:SetVertexColor(color.r, color.g, color.b);
		else
			self.levelText:SetVertexColor(1.0, 0.82, 0.0);
		end
		self.levelText:Show();
		self.highLevelTexture:Hide();
	else
		-- Target is too high level to tell
		self.levelText:Hide();
		self.highLevelTexture:Show();
	end
end

function TargetFrame_CheckFaction (self)
	if ( not UnitPlayerControlled(self.unit) and UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit) and not UnitIsTappedByAllThreatList(self.unit) ) then
		self.nameBackground:SetVertexColor(0.5, 0.5, 0.5);
		if ( self.portrait ) then
			self.portrait:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		self.nameBackground:SetVertexColor(UnitSelectionColor(self.unit));
		if ( self.portrait ) then
			self.portrait:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	if ( self.showPVP ) then
		local factionGroup = UnitFactionGroup(self.unit);
		if ( UnitIsPVPFreeForAll(self.unit) ) then
			self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			self.pvpIcon:Show();
		elseif ( factionGroup and UnitIsPVP(self.unit) ) then
			self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			self.pvpIcon:Show();
		else
			self.pvpIcon:Hide();
		end
	end
end

function TargetFrame_CheckClassification (self, forceNormalTexture)
	local texture;
	local classification = UnitClassification(self.unit);
	if ( classification == "worldboss" or classification == "elite" ) then
		texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite";
	elseif ( classification == "rareelite" ) then
		texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite";
	elseif ( classification == "rare" ) then
		texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare";
	end
	if ( texture and not forceNormalTexture) then
		self.borderTexture:SetTexture(texture);
		self.haveElite = true;
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(112);
			self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9);
		end		
	else
		self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
		self.haveElite = nil;
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(93);
			self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
		end	
	end
end

function TargetFrame_CheckDead (self)
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		self.deadText:Show();
	else
		self.deadText:Hide();
	end
end

function TargetFrame_OnUpdate (self, elapsed)
	if ( self.totFrame and self.totFrame:IsShown() ~= UnitExists(self.totFrame.unit) ) then
		TargetofTarget_Update(self.totFrame);
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
	local frameStealable;
	local numBuffs = 0;
	local playerIsTarget = UnitIsUnit(PlayerFrame.unit, self.unit);
	local selfName = self:GetName();

	for i = 1, MAX_TARGET_BUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(self.unit, i);
		frameName = selfName.."Buff"..i;
		frame = _G[frameName];
		if ( not frame ) then
			if ( not icon ) then
				break;
			else
				frame = CreateFrame("Button", frameName, self, "TargetBuffFrameTemplate");
				frame.unit = self.unit;
			end
		end
		if ( icon and ( not self.maxBuffs or i <= self.maxBuffs ) ) then
			frame:SetID(i);

			-- set the icon
			frameIcon = _G[frameName.."Icon"];
			frameIcon:SetTexture(icon);

			-- set the count
			frameCount = _G[frameName.."Count"];
			if ( count > 1 and self.showAuraCount ) then
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
	local isEnemy = UnitCanAttack("player", self.unit);
	for i = 1, MAX_TARGET_DEBUFFS do
		name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(self.unit, i);
		frameName = selfName.."Debuff"..i;
		frame = _G[frameName];
		if ( not frame ) then
			if ( not icon ) then
				break;
			else
				frame = CreateFrame("Button", frameName, self, "TargetDebuffFrameTemplate");
				frame.unit = self.unit;
			end
		end
		if ( icon and ( not self.maxDebuffs or i <= self.maxDebuffs ) and ( SHOW_CASTABLE_DEBUFFS == "0" or not isEnemy or caster == "player" or caster == "vehicle") ) then
			frame:SetID(i);

			-- set the icon
			frameIcon = _G[frameName.."Icon"];
			frameIcon:SetTexture(icon);

			-- set the count
			frameCount = _G[frameName.."Count"];
			if ( count > 1 and self.showAuraCount ) then
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
	
	self.auraRows = 0;
	local haveTargetofTarget;
	if ( self.totFrame ) then
		haveTargetofTarget = self.totFrame:IsShown();
	end
	self.spellbarAnchor = nil;
	local maxRowWidth;
	-- update buff positions
	maxRowWidth = ( haveTargetofTarget and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	TargetFrame_UpdateAuraPositions(self, selfName.."Buff", numBuffs, numDebuffs, largeBuffList, TargetFrame_UpdateBuffAnchor, maxRowWidth, 3);
	-- update debuff positions
	maxRowWidth = ( haveTargetofTarget and self.auraRows < NUM_TOT_AURA_ROWS and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	TargetFrame_UpdateAuraPositions(self, selfName.."Debuff", numDebuffs, numBuffs, largeDebuffList, TargetFrame_UpdateDebuffAnchor, maxRowWidth, 4);
	-- update the spell bar position
	if ( self.spellbar ) then
		Target_Spellbar_AdjustPosition(self.spellbar);
	end
end

function TargetFrame_UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX)
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
			self.auraRows = self.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > maxRowWidth ) then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY);

			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;

			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY);
		end
	end
end

function TargetFrame_UpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[buffName..index];
	if ( index == 1 ) then
		if ( UnitIsFriend("player", self.unit) or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);			
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint("TOPLEFT", self.debuffs, "BOTTOMLEFT", 0, -offsetY);
		end
		self.buffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		self.buffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		self.spellbarAnchor = buff;
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		self.buffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		self.spellbarAnchor = buff;
	else
		-- anchor index is the previous index
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "TOPRIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

function TargetFrame_UpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[debuffName..index];
	local isFriend = UnitIsFriend("player", self.unit);
	if ( index == 1 ) then
		if ( isFriend and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint("TOPLEFT", self.buffs, "BOTTOMLEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);
		end
		self.debuffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		self.debuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[debuffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		self.debuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
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
			if ( self.portrait ) then
				self.portrait:SetAlpha(alpha);
			end
		end
	end
end

function TargetHealthCheck (self)
	if ( UnitIsPlayer(self.unit) ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		local parent = self:GetParent();
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = self:GetValue();
		parent.unitHPPercent = unitCurrHP / unitHPMax;
		if ( self.portrait ) then
			if ( UnitIsDead(self.unit) ) then
				parent.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
			elseif ( UnitIsGhost(self.unit) ) then
				parent.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
			elseif ( (parent.unitHPPercent > 0) and (parent.unitHPPercent <= 0.2) ) then
				parent.portrait:SetVertexColor(1.0, 0.0, 0.0);
			else
				parent.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
			end
		end
	end
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
	local index = GetRaidTargetIndex(self.unit);
	if ( index ) then
		SetRaidTargetIconTexture(self.raidTargetIcon, index);
		self.raidTargetIcon:Show();
	else
		self.raidTargetIcon:Hide();
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

function TargetFrame_CreateTargetofTarget(self, unit)
	local thisName = self:GetName().."ToT";
	local frame = CreateFrame("BUTTON", thisName, self, "TargetofTargetFrameTemplate");
	self.totFrame = frame;
	UnitFrame_Initialize(frame, unit, _G[thisName.."TextureFrameName"], _G[thisName.."Portrait"],
						 _G[thisName.."HealthBar"], _G[thisName.."TextureFrameHealthBarText"],
						 _G[thisName.."ManaBar"], _G[thisName.."TextureFrameManaBarText"]);
	SetTextStatusBarTextZeroText(frame.healthbar, DEAD);
	frame.deadText = _G[thisName.."TextureFrameDeadText"];
	SecureUnitButton_OnLoad(frame, unit);
end

function TargetofTarget_OnHide(self)
	TargetFrame_UpdateAuras(self:GetParent());
end

function TargetofTarget_Update(self, elapsed)
	local show;
	local parent = self:GetParent();
	if ( SHOW_TARGET_OF_TARGET == "1" and UnitExists(parent.unit) and UnitExists(self.unit) and ( not UnitIsUnit(PlayerFrame.unit, parent.unit) ) and ( UnitHealth(parent.unit) > 0 ) ) then
		if ( ( SHOW_TARGET_OF_TARGET_STATE == "5" ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "4" and ( (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "3" and ( (GetNumRaidMembers() == 0) and (GetNumPartyMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "2" and ( (GetNumPartyMembers() > 0) and (GetNumRaidMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "1" and ( GetNumRaidMembers() > 0 ) ) ) then
			show = true;
		end
	end

	if ( show ) then
		if ( not self:IsShown() ) then
			self:Show();
			if ( parent.spellbar ) then
				parent.haveToT = true;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
		UnitFrame_Update(self);
		TargetofTarget_CheckDead(self);
		TargetofTargetHealthCheck(self);
		RefreshDebuffs(self, self.unit);
	else
		if ( self:IsShown() ) then
			self:Hide();
			if ( parent.spellbar ) then
				parent.haveToT = nil;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
	end
end

function TargetofTarget_CheckDead(self)
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		self.background:SetAlpha(0.9);
		self.deadText:Show();
	else
		self.background:SetAlpha(1);
		self.deadText:Hide();
	end
end

function TargetofTargetHealthCheck(self)
	if ( UnitIsPlayer(self.unit) ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self.healthbar:GetMinMaxValues();
		unitCurrHP = self.healthbar:GetValue();
		self.unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead(self.unit) ) then
			self.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost(self.unit) ) then
			self.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			self.portrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			self.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end

function SetTargetSpellbarAspect(self)
	local targetFrameSpellBarName = self:GetName();

	local frameText = _G[targetFrameSpellBarName.."Text"];
	if ( frameText ) then
		frameText:SetFontObject(SystemFont_Shadow_Small);
		frameText:ClearAllPoints();
		frameText:SetPoint("TOP", self, "TOP", 0, 4);
	end

	local frameBorder = _G[targetFrameSpellBarName.."Border"];
	if ( frameBorder ) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		frameBorder:SetWidth(197);
		frameBorder:SetHeight(49);
		frameBorder:ClearAllPoints();
		frameBorder:SetPoint("TOP", self, "TOP", 0, 20);
	end
	
	local frameBorderShield = _G[targetFrameSpellBarName.."BorderShield"];
	if ( frameBorderShield ) then
		frameBorderShield:SetWidth(197);
		frameBorderShield:SetHeight(49);
		frameBorderShield:ClearAllPoints();
		frameBorderShield:SetPoint("TOP", self, "TOP", -5, 20);
	end

	local frameFlash = _G[targetFrameSpellBarName.."Flash"];
	if ( frameFlash ) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		frameFlash:SetWidth(197);
		frameFlash:SetHeight(49);
		frameFlash:ClearAllPoints();
		frameFlash:SetPoint("TOP", self, "TOP", 0, 20);
	end
end

function TargetFrame_CreateSpellbar(self, event)
	local name = self:GetName().."SpellBar";
	local spellbar = CreateFrame("STATUSBAR", name, self, "TargetSpellBarTemplate");
	spellbar:SetFrameLevel(_G[self:GetName().."TextureFrame"]:GetFrameLevel() - 1);
	self.spellbar = spellbar;
	self.auraRows = 0;
	spellbar.unit = self.unit;
	spellbar:RegisterEvent("CVAR_UPDATE");
	spellbar:RegisterEvent("VARIABLES_LOADED");
		
	CastingBarFrame_OnLoad(spellbar, spellbar.unit, false, true);
	if ( event ) then
		spellbar.updateEvent = event;
		spellbar:RegisterEvent(event);
	end
	
	local barIcon =_G[name.."Icon"];
	barIcon:Show();

	SetTargetSpellbarAspect(spellbar);
	
	--The target casting bar has less room for text than most, so shorten it
	_G[name.."Text"]:SetWidth(150)
	-- check to see if the castbar should be shown
	if ( GetCVar("showTargetCastbar") == "0") then
		spellbar.showCastbar = false;	
	end	
end

function Target_Spellbar_OnEvent(self, event, ...)
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
	elseif ( event == self.updateEvent ) then	
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = self.unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = self.unit;
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
		-- The position depends on the classification of the target
		Target_Spellbar_AdjustPosition(self);
	end
	CastingBarFrame_OnEvent(self, event, arg1, select(2, ...));
end

function Target_Spellbar_AdjustPosition(self)
	-- this may need to be reworked, but it covers all cases within 3 conditionals
	local parentFrame = self:GetParent();
	if ( parentFrame.haveToT ) then
		if ( parentFrame.auraRows <= 1 ) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -21 );
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		end
	elseif ( parentFrame.haveElite ) then
		if ( parentFrame.auraRows <= 1 ) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -5 );
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		end
	else
		if ( parentFrame.auraRows > 0 ) then
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		else
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 7 );
		end
	end
end

-- *********************************************************************************
-- Boss Frames
-- *********************************************************************************

function BossTargetFrame_OnLoad(self, unit, event)
	self.noTextPrefix = true;
	self.showLevel = true;
	self.showThreat = true;
	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	TargetFrame_OnLoad(self, unit, BossTargetFrameDropDown_Initialize);
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT");
	self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss");
	self.levelText:SetPoint("CENTER", 12, -16);
	self.raidTargetIcon:SetPoint("RIGHT", -90, 0);
	self.threatNumericIndicator:SetPoint("BOTTOM", self, "TOP", -85, -22);
	self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss-Flash");
	self.threatIndicator:SetTexCoord(0.0, 0.945, 0.0, 0.73125);
	self:SetHitRectInsets(0, 95, 15, 30);
	self:SetScale(0.75);
	if ( event ) then
		self:RegisterEvent(event);
	end
end

function BossTargetFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "BOSS", self:GetParent().unit);
end

-- *********************************************************************************
-- Focus Frame
-- *********************************************************************************

function FocusFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "FOCUS", "focus", SET_FOCUS);
end

FOCUS_FRAME_LOCKED = true;
function FocusFrame_IsLocked()
	return FOCUS_FRAME_LOCKED;
end

function FocusFrame_SetLock(locked)
	FOCUS_FRAME_LOCKED = locked;
end

function FocusFrame_OnDragStart(self, button)
	FOCUS_FRAME_MOVING = false;
	if ( not FOCUS_FRAME_LOCKED ) then
		local cursorX, cursorY = GetCursorPosition();
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
		FOCUS_FRAME_MOVING = true;
	end
end

function FocusFrame_OnDragStop(self)
	if ( not FOCUS_FRAME_LOCKED and FOCUS_FRAME_MOVING ) then
		self:StopMovingOrSizing();
		self:SetFrameStrata("BACKGROUND");
		if ( self:GetBottom() < 15 + MainMenuBar:GetHeight() ) then
			local anchorX = self:GetLeft();
			local anchorY = 60;
			if ( self.smallSize ) then
				anchorY = 90;	-- empirically determined
			end
			self:SetPoint("BOTTOMLEFT", anchorX, anchorY);
		end
		FOCUS_FRAME_MOVING = false;
	end
end

function FocusFrame_SetSmallSize(smallSize, onChange)
	if ( smallSize and not FocusFrame.smallSize ) then
		local x = FocusFrame:GetLeft();
		local y = FocusFrame:GetTop();
		FocusFrame.smallSize = true;	
		FocusFrame.maxBuffs = 0;
		FocusFrame.maxDebuffs = 8;		
		FocusFrame:SetScale(SMALL_FOCUS_SCALE);
		FocusFrameToT:SetScale(SMALL_FOCUS_UPSCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17);
		FocusFrame.TOT_AURA_ROW_WIDTH = 80;	-- not as much room for auras with scaled-up ToT frame
		FocusFrame.spellbar:SetScale(SMALL_FOCUS_UPSCALE);		
		FocusFrameTextureFrameName:SetFontObject(FocusFontSmall);
		FocusFrameHealthBar.TextString:SetFontObject(TextStatusBarTextLarge);
		FocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 4)
		FocusFrameTextureFrameName:SetWidth(120);
		if ( onChange ) then
			-- the frame needs to be repositioned because anchor offsets get adjusted with scale			
			FocusFrame:ClearAllPoints();
			FocusFrame:SetPoint("TOPLEFT", x * SMALL_FOCUS_UPSCALE + 29, (y - GetScreenHeight()) * SMALL_FOCUS_UPSCALE - 13);
		end
		FocusFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = nil;
		FocusFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");	
		FocusFrame.showLeader = nil;
		FocusFrame.showPVP = nil;
		FocusFrame.pvpIcon:Hide();
		FocusFrame.leaderIcon:Hide();
		FocusFrame.showAuraCount = nil;
		TargetFrame_CheckClassification(FocusFrame, true);
		TargetFrame_Update(FocusFrame);
	elseif ( not smallSize and FocusFrame.smallSize ) then
		local x = FocusFrame:GetLeft();
		local y = FocusFrame:GetTop();		
		FocusFrame.smallSize = false;	
		FocusFrame.maxBuffs = nil;
		FocusFrame.maxDebuffs = nil;
		FocusFrame:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -35, -10);
		FocusFrame.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
		FocusFrame.spellbar:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameTextureFrameName:SetFontObject(GameFontNormalSmall);
		FocusFrameHealthBar.TextString:SetFontObject(TextStatusBarText);
		FocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 3)
		FocusFrameTextureFrameName:SetWidth(100);
		if ( onChange ) then
			-- the frame needs to be repositioned because anchor offsets get adjusted with scale		
			FocusFrame:ClearAllPoints();		
			FocusFrame:SetPoint("TOPLEFT", (x - 29) / SMALL_FOCUS_UPSCALE, (y + 13) / SMALL_FOCUS_UPSCALE - GetScreenHeight());
		end
		FocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = true;
		FocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
		FocusFrame.showPVP = true;
		FocusFrame.showLeader = true;
		FocusFrame.showAuraCount = true;
		TargetFrame_Update(FocusFrame);
	end
end