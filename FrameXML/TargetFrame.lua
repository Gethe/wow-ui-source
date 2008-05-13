MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;
CURRENT_TARGET_NUM_DEBUFFS = 0;
TARGET_BUFFS_PER_ROW = 8;
TARGET_DEBUFFS_PER_ROW = 8;
LARGE_BUFF_SIZE = 21;
LARGE_BUFF_FRAME_SIZE = 23;
SMALL_BUFF_SIZE = 17;
SMALL_BUFF_FRAME_SIZE = 19;

UnitReactionColor = {
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.5, b = 0.0 },
	{ r = 1.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
};

function TargetFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	this.unitHPPercent = 1;

	this.buffStartX = 5;
	this.buffStartY = 32;
	this.buffSpacing = 3;

	TargetFrame_Update();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("PLAYER_FOCUS_CHANGED");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("PLAYER_FLAGS_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("RAID_TARGET_UPDATE");

	local frameLevel = TargetFrameTextureFrame:GetFrameLevel();
	TargetFrameHealthBar:SetFrameLevel(frameLevel-1);
	TargetFrameManaBar:SetFrameLevel(frameLevel-1);
	TargetFrameSpellBar:SetFrameLevel(frameLevel-1);

	local showmenu = function()
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "TargetFrame", 120, 10);
	end
	SecureUnitButton_OnLoad(this, "target", showmenu);
end

function TargetFrame_Update()
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not UnitExists("target") ) then
		this:Hide();
	else
		this:Show();

		-- Moved here to avoid taint from functions below
		TargetofTarget_Update();

		UnitFrame_Update();
		TargetFrame_CheckLevel();
		TargetFrame_CheckFaction();
		TargetFrame_CheckClassification();
		TargetFrame_CheckDead();
		TargetFrame_CheckFocus();
		if ( UnitIsPartyLeader("target") ) then
			TargetLeaderIcon:Show();
		else
			TargetLeaderIcon:Hide();
		end
		TargetDebuffButton_Update();
		TargetPortrait:SetAlpha(1.0);
	end
end

function TargetFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		TargetFrame_Update();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		TargetFrame_Update();
		TargetFrame_UpdateRaidTargetIcon();
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
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		TargetFrame_CheckFocus();
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckDead();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckLevel();
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == "target" or arg1 == "player" ) then
			TargetFrame_CheckFaction();
			TargetFrame_CheckLevel();
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == "target" ) then
			TargetFrame_CheckClassification();
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == "target" ) then
			TargetDebuffButton_Update();
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
		TargetFrame_CheckFaction();
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		TargetFrame_UpdateRaidTargetIcon();
	end
end

function TargetFrame_OnHide()
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	CloseDropDownMenus();
end

function TargetFrame_CheckLevel()
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

function TargetFrame_CheckFaction()
	if ( UnitPlayerControlled("target") ) then
		local r, g, b;
		if ( UnitCanAttack("target", "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", "target") ) then
				r = 0.0;
				g = 0.0;
				b = 1.0;
			else
				r = UnitReactionColor[2].r;
				g = UnitReactionColor[2].g;
				b = UnitReactionColor[2].b;
			end
		elseif ( UnitCanAttack("player", "target") ) then
			-- Players we can attack but which are not hostile are yellow
			r = UnitReactionColor[4].r;
			g = UnitReactionColor[4].g;
			b = UnitReactionColor[4].b;
		elseif ( UnitIsPVP("target") and not UnitIsPVPSanctuary("target") and not UnitIsPVPSanctuary("player") ) then
			-- Players we can assist but are PvP flagged are green
			r = UnitReactionColor[6].r;
			g = UnitReactionColor[6].g;
			b = UnitReactionColor[6].b;
		else
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.0;
			g = 0.0;
			b = 1.0;
		end
		TargetFrameNameBackground:SetVertexColor(r, g, b);
		TargetPortrait:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( UnitIsTapped("target") and not UnitIsTappedByPlayer("target") ) then
		TargetFrameNameBackground:SetVertexColor(0.5, 0.5, 0.5);
		TargetPortrait:SetVertexColor(0.5, 0.5, 0.5);
	else
		local reaction = UnitReaction("target", "player");
		if ( reaction ) then
			local r, g, b;
			r = UnitReactionColor[reaction].r;
			g = UnitReactionColor[reaction].g;
			b = UnitReactionColor[reaction].b;
			TargetFrameNameBackground:SetVertexColor(r, g, b);
		else
			TargetFrameNameBackground:SetVertexColor(0, 0, 1.0);
		end
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

function TargetFrame_CheckClassification()
	local classification = UnitClassification("target");
	if ( classification == "worldboss" ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
	elseif ( classification == "rareelite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite");
	elseif ( classification == "elite"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
	elseif ( classification == "rare"  ) then
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare");
	else
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
	end
end

function TargetFrame_CheckDead()
	if ( (UnitHealth("target") <= 0) and UnitIsConnected("target") ) then
		TargetDeadText:Show();
	else
		TargetDeadText:Hide();
	end
end

function TargetFrame_CheckFocus()
	if ( UnitIsUnit("target", "focus") ) then
		TargetFrameFlash:Show();
	else
		TargetFrameFlash:Hide();
	end
end

function TargetFrame_OnUpdate()
	if ( TargetofTargetFrame:IsShown() ~= UnitExists("targettarget") ) then
		TargetofTarget_Update();
	end
end

function TargetDebuffButton_Update()
	local button;
	local name, rank, icon, count, duration, timeLeft;
	local buffCount;
	local numBuffs = 0;
	local largeBuffList = {};
	local playerIsTarget = UnitIsUnit("player", "target");
	local cooldown, startCooldownTime;
	for i=1, MAX_TARGET_BUFFS do
		name, rank, icon, count, duration, timeLeft = UnitBuff("target", i);
		button = getglobal("TargetFrameBuff"..i);
		if ( not button ) then
			if ( not icon ) then
				break;
			else
				button = CreateFrame("Button", "TargetFrameBuff"..i, TargetFrame, "TargetBuffButtonTemplate");
			end
		end
		
		if ( icon ) then
			getglobal("TargetFrameBuff"..i.."Icon"):SetTexture(icon);
			buffCount = getglobal("TargetFrameBuff"..i.."Count");
			button:Show();
			if ( count > 1 ) then
				buffCount:SetText(count);
				buffCount:Show();
			else
				buffCount:Hide();
			end
			
			-- Handle cooldowns
			cooldown = getglobal("TargetFrameBuff"..i.."Cooldown");
			if ( duration ) then
				if ( duration > 0 ) then
					cooldown:Show();
					startCooldownTime = GetTime()-(duration-timeLeft);
					CooldownFrame_SetTimer(cooldown, startCooldownTime, duration, 1);
				else
					cooldown:Hide();
				end
				
				-- Set the buff to be big if the buff is cast by the player and the target is not the player
				if ( not playerIsTarget ) then
					largeBuffList[i] = 1;
				end
			else
				cooldown:Hide();
			end

			button.id = i;
			numBuffs = numBuffs + 1; 
			button:ClearAllPoints();
		else
			button:Hide();
		end
	end

	local debuffType, color;
	local debuffCount;
	local numDebuffs = 0;
	local largeDebuffList = {};
	for i=1, MAX_TARGET_DEBUFFS do
		local debuffBorder = getglobal("TargetFrameDebuff"..i.."Border");
		name, rank, icon, count, debuffType, duration, timeLeft = UnitDebuff("target", i);
		button = getglobal("TargetFrameDebuff"..i);
		if ( not button ) then
			if ( not icon ) then
				break;
			else
				button = CreateFrame("Button", "TargetFrameDebuff"..i, TargetFrame, "TargetDebuffButtonTemplate");
				debuffBorder = getglobal("TargetFrameDebuff"..i.."Border");
			end
		end
		if ( icon ) then
			getglobal("TargetFrameDebuff"..i.."Icon"):SetTexture(icon);
			debuffCount = getglobal("TargetFrameDebuff"..i.."Count");
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			if ( count > 1 ) then
				debuffCount:SetText(count);
				debuffCount:Show();
			else
				debuffCount:Hide();
			end

			-- Handle cooldowns
			cooldown = getglobal("TargetFrameDebuff"..i.."Cooldown");
			if ( duration  ) then
				if ( duration > 0 ) then
					cooldown:Show();
					startCooldownTime = GetTime()-(duration-timeLeft);
					CooldownFrame_SetTimer(cooldown, startCooldownTime, duration, 1);
				else
					cooldown:Hide();
				end
				-- Set the buff to be big if the buff is cast by the player
				largeDebuffList[i] = 1;
			else
				cooldown:Hide();
			end
			
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			button:Show();
			numDebuffs = numDebuffs + 1;
			button:ClearAllPoints();
		else
			button:Hide();
		end
		button.id = i;
	end
	
	-- Figure out general information that affects buff sizing and positioning
	local numFirstRowBuffs;
	if ( TargetofTargetFrame:IsShown() ) then
		numFirstRowBuffs = 5;
	else
		numFirstRowBuffs = 6;
	end
		
	-- Reset number of buff rows
	TargetFrame.buffRows = 0;
	-- Position buffs
	local size;
	local previousWasPlayerCast;
	local offset;
	for i=1, numBuffs do
		if ( largeBuffList[i] ) then
			size = LARGE_BUFF_SIZE;
			offset = 3;
			previousWasPlayerCast = 1;
		else
			size = SMALL_BUFF_SIZE;
			offset = 3;
			if ( previousWasPlayerCast ) then
				offset = 6;
				previousWasPlayerCast = nil;
			end
		end
		TargetFrame_UpdateBuffAnchor("TargetFrameBuff", i, numFirstRowBuffs, numDebuffs, size, offset, TargetofTargetFrame:IsShown());
	end
	-- Position debuffs
	previousWasPlayerCast = nil;
	for i=1, numDebuffs do
		if ( largeDebuffList[i] ) then
			size = LARGE_BUFF_SIZE;
			offset = 4;
			previousWasPlayerCast = 1;
		else
			size = SMALL_BUFF_SIZE;
			offset = 4;
			if ( previousWasPlayerCast ) then
				offset = 6;
				previousWasPlayerCast = nil;
			end
		end
		TargetFrame_UpdateDebuffAnchor("TargetFrameDebuff", i, numFirstRowBuffs, numBuffs, size, offset, TargetofTargetFrame:IsShown());
	end

	-- update the spell bar position
	Target_Spellbar_AdjustPosition();
end

function TargetFrame_UpdateBuffAnchor(buffName, index, numFirstRowBuffs, numDebuffs, buffSize, offset, hasTargetofTarget)
	local buff = getglobal(buffName..index);
	
	if ( index == 1 ) then
		if ( UnitIsFriend("player", "target") ) then
			buff:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", TargetFrame.buffStartX, TargetFrame.buffStartY);
		else
			if ( numDebuffs > 0 ) then
				buff:SetPoint("TOPLEFT", TargetFrameDebuffs, "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
			else
				buff:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", TargetFrame.buffStartX, TargetFrame.buffStartY);
			end
		end
		TargetFrameBuffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( index == (numFirstRowBuffs+1) ) then
		buff:SetPoint("TOPLEFT", getglobal(buffName..1), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( hasTargetofTarget and index == (2*numFirstRowBuffs+1) ) then
		buff:SetPoint("TOPLEFT", getglobal(buffName..(numFirstRowBuffs+1)), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( (index > numFirstRowBuffs) and (mod(index+(TARGET_BUFFS_PER_ROW-numFirstRowBuffs), TARGET_BUFFS_PER_ROW) == 1) and not hasTargetofTarget ) then
		-- Make a new row, have to take the number of buffs in the first row into account
		buff:SetPoint("TOPLEFT", getglobal(buffName..(index-TARGET_BUFFS_PER_ROW)), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameBuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	else
		-- Just anchor to previous
		buff:SetPoint("TOPLEFT", getglobal(buffName..(index-1)), "TOPRIGHT", offset, 0);
	end

	-- Resize
	buff:SetWidth(buffSize);
	buff:SetHeight(buffSize);
end

function TargetFrame_UpdateDebuffAnchor(buffName, index, numFirstRowBuffs, numBuffs, buffSize, offset, hasTargetofTarget)
	local buff = getglobal(buffName..index);

	if ( index == 1 ) then
		if ( UnitIsFriend("player", "target") and (numBuffs > 0) ) then
			buff:SetPoint("TOPLEFT", TargetFrameBuffs, "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		else
			buff:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", TargetFrame.buffStartX, TargetFrame.buffStartY);
		end
		TargetFrameDebuffs:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( index == (numFirstRowBuffs+1) ) then
		buff:SetPoint("TOPLEFT", getglobal(buffName..1), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( hasTargetofTarget and index == (2*numFirstRowBuffs+1) ) then
		buff:SetPoint("TOPLEFT", getglobal(buffName..(numFirstRowBuffs+1)), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	elseif ( (index > numFirstRowBuffs) and (mod(index+(TARGET_DEBUFFS_PER_ROW-numFirstRowBuffs), TARGET_DEBUFFS_PER_ROW) == 1) and not hasTargetofTarget ) then
		-- Make a new row
		buff:SetPoint("TOPLEFT", getglobal(buffName..(index-TARGET_DEBUFFS_PER_ROW)), "BOTTOMLEFT", 0, -TargetFrame.buffSpacing);
		TargetFrameDebuffs:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, 0);
		TargetFrame.buffRows = TargetFrame.buffRows+1;
	else
		-- Just anchor to previous
		buff:SetPoint("TOPLEFT", getglobal(buffName..(index-1)), "TOPRIGHT", offset, 0);
	end
	
	-- Resize
	buff:SetWidth(buffSize);
	buff:SetHeight(buffSize);
	local debuffFrame = getglobal(buffName..index.."Border");
	debuffFrame:SetWidth(buffSize+2);
	debuffFrame:SetHeight(buffSize+2);
end

function TargetFrame_HealthUpdate(elapsed, unit)
	if ( UnitIsPlayer(unit) ) then
		if ( (this.unitHPPercent > 0) and (this.unitHPPercent <= 0.2) ) then
			local alpha = 255;
			local counter = this.statusCounter + elapsed;
			local sign    = this.statusSign;
	
			if ( counter > 0.5 ) then
				sign = -sign;
				this.statusSign = sign;
			end
			counter = mod(counter, 0.5);
			this.statusCounter = counter;
	
			if ( sign == 1 ) then
				alpha = (127  + (counter * 256)) / 255;
			else
				alpha = (255 - (counter * 256)) / 255;
			end
			TargetPortrait:SetAlpha(alpha);
		end
	end
end

function TargetHealthCheck()
	if ( UnitIsPlayer("target") ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = this:GetMinMaxValues();
		unitCurrHP = this:GetValue();
		this:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("target") ) then
			TargetPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("target") ) then
			TargetPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (this:GetParent().unitHPPercent > 0) and (this:GetParent().unitHPPercent <= 0.2) ) then
			TargetPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end

function TargetFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, TargetFrameDropDown_Initialize, "MENU");
end

function TargetFrameDropDown_Initialize()
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
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
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(TargetFrameDropDown, menu, "target", name, id);
	end
end



-- Raid target icon function
RAID_TARGET_ICON_DIMENSION = 64;
RAID_TARGET_TEXTURE_DIMENSION = 256;
RAID_TARGET_TEXTURE_COLUMNS = 4;
RAID_TARGET_TEXTURE_ROWS = 4;
function TargetFrame_UpdateRaidTargetIcon()
	local index = GetRaidTargetIndex("target");
	if ( index ) then
		SetRaidTargetIconTexture(TargetRaidTargetIcon, index);
		TargetRaidTargetIcon:Show();
	else
		TargetRaidTargetIcon:Hide();
	end
end


function SetRaidTargetIconTexture(texture, raidTargetIconIndex)
	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function SetRaidTargetIcon(unit, index)
	if ( GetRaidTargetIndex(unit) and GetRaidTargetIndex(unit) == index ) then
		SetRaidTarget(unit, 0);
	else
		SetRaidTarget(unit, index);
	end
end

function TargetofTarget_OnLoad()
	UnitFrame_Initialize("targettarget", TargetofTargetName, TargetofTargetPortrait, TargetofTargetHealthBar, TargetofTargetHealthBarText, TargetofTargetManaBar, TargetofTargetFrameManaBarText);
	SetTextStatusBarTextZeroText(TargetofTargetHealthBar, DEAD);
	this:RegisterEvent("UNIT_AURA");

	SecureUnitButton_OnLoad(this, "targettarget");
end

function TargetofTarget_OnHide()
	TargetDebuffButton_Update();
end

function TargetofTarget_Update()
	local show;
	if ( SHOW_TARGET_OF_TARGET == "1" and UnitExists("target") and UnitExists("targettarget") and ( not UnitIsUnit("player", "target") ) and ( UnitHealth("target") > 0 ) ) then
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
		UnitFrame_Update();
		TargetofTarget_CheckDead();
		TargetofTargetHealthCheck();
		RefreshBuffs(TargetofTargetFrame, 0, "targettarget");
	else
		if ( TargetofTargetFrame:IsShown() ) then
			TargetofTargetFrame:Hide();
			Target_Spellbar_AdjustPosition();
		end
	end
end

function TargetofTarget_CheckDead()
	if ( (UnitHealth("targettarget") <= 0) and UnitIsConnected("targettarget") ) then
		TargetofTargetBackground:SetAlpha(0.9);
		TargetofTargetDeadText:Show();
	else
		TargetofTargetBackground:SetAlpha(1);
		TargetofTargetDeadText:Hide();
	end
end

function TargetofTargetHealthCheck()
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
	local frameText = getglobal(TargetFrameSpellBar:GetName().."Text");
	if ( frameText ) then
		frameText:SetTextHeight(10);
		frameText:ClearAllPoints();
		frameText:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 4);
	end

	local frameBorder = getglobal(TargetFrameSpellBar:GetName().."Border");
	if ( frameBorder ) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		frameBorder:SetWidth(197);
		frameBorder:SetHeight(49);
		frameBorder:ClearAllPoints();
		frameBorder:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 20);
	end

	local frameFlash = getglobal(TargetFrameSpellBar:GetName().."Flash");
	if ( frameFlash ) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		frameFlash:SetWidth(197);
		frameFlash:SetHeight(49);
		frameFlash:ClearAllPoints();
		frameFlash:SetPoint("TOP", TargetFrameSpellBar, "TOP", 0, 20);
	end
end

function Target_Spellbar_OnLoad()
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("CVAR_UPDATE");
	
	CastingBarFrame_OnLoad("target", false);

	local barIcon = getglobal(this:GetName().."Icon");
	barIcon:Show();

	SetTargetSpellbarAspect();
	
	-- check to see if the castbar should be shown
	if ( GetCVar("ShowTargetCastbar") == "0") then
		this.showCastbar = false;	
	end
end

function Target_Spellbar_OnEvent()
	local newevent = event;
	local newarg1 = arg1;
	--	Check for target specific events
	if ( (event == "CVAR_UPDATE") and (arg1 == "SHOW_TARGET_CASTBAR") ) then
		if ( GetCVar("ShowTargetCastbar") == "0") then
			this.showCastbar = false;
		else
			this.showCastbar = true;
		end
		
		if ( not this.showCastbar ) then
			this:Hide();
		elseif ( this.casting or this.channeling ) then
			this:Show();
		end
		return;
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(this.unit);
		local nameSpell  = UnitCastingInfo(this.unit);
		if ( nameChannel ) then
			newevent = "UNIT_SPELLCAST_CHANNEL_START";
			newarg1 = "target";
		elseif ( nameSpell ) then
			newevent = "UNIT_SPELLCAST_START";
			newarg1 = "target";
		else
			this.casting = nil;
			this.channeling = nil;
			this:SetMinMaxValues(0, 0);
			this:SetValue(0);
			this:Hide();
			return;
		end
		-- The position depends on the classification of the target
		Target_Spellbar_AdjustPosition();
	end
	CastingBarFrame_OnEvent(newevent, newarg1);
end

function Target_Spellbar_AdjustPosition()
	local yPos = 5;
	if ( TargetFrame.buffRows and TargetFrame.buffRows <= 2 ) then
		yPos = 38;
	elseif ( TargetFrame.buffRows ) then
		yPos = 19 * TargetFrame.buffRows
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

