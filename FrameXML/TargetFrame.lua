MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 5;
CURRENT_TARGETTARGET = nil;

UnitReactionColor = {
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.5, b = 0.0 },
	{ r = 1.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
};

function TargetFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	this.unitHPPercent = 1;
	TargetFrame_Update();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
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
end

function TargetFrame_Update()
	if ( UnitExists("target") ) then
		this:Show();
		UnitFrame_Update();
		TargetFrame_CheckLevel();
		TargetFrame_CheckFaction();
		TargetFrame_CheckClassification();
		TargetFrame_CheckDead();
		TargetFrame_CheckDishonorableKill();
		if ( UnitIsPartyLeader("target") ) then
			TargetLeaderIcon:Show();
		else
			TargetLeaderIcon:Hide();
		end
		TargetDebuffButton_Update();
		TargetPortrait:SetAlpha(1.0);
	else
		this:Hide();
	end
end

function TargetFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "PLAYER_ENTERING_WORLD"  and ( not TargetFrame:IsVisible() ) ) then
		TargetFrame_Update();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		TargetFrame_Update();
		TargetFrame_UpdateRaidTargetIcon();
		TargetofTarget_Update();
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
		TargetFrame_CheckFaction();
		TargetofTarget_Update();
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		TargetFrame_UpdateRaidTargetIcon();
	end
end

function TargetFrame_OnShow()
	if ( UnitIsEnemy("target", "player") ) then
		PlaySound("igCreatureAggroSelect");
	elseif ( UnitIsFriend("player", "target") ) then
		PlaySound("igCharacterNPCSelect");
	else
		PlaySound("igCreatureNeutralSelect");
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
		elseif ( UnitIsPVP("target") ) then
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
		TargetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
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
		--TargetofTargetDeadText:Show();
	else
		TargetDeadText:Hide();
		--TargetofTargetDeadText:Hide();
	end
end

function TargetFrame_CheckDishonorableKill()
	if ( UnitIsCivilian("target") ) then
		-- Is a dishonorable kill
		--[[
		this.name:SetText(RED_FONT_COLOR_CODE..PVP_RANK_CIVILIAN..FONT_COLOR_CODE_CLOSE);
		TargetFrameNameBackground:SetVertexColor(0.36, 0.05, 0.05);
		]]--
		TargetFrameNameBackground:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function TargetFrame_OnClick(button)
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("target");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("target");
		end
	else
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "TargetFrame", 120, 10);
	end
end

function TargetFrame_OnUpdate()
	if ( TargetofTargetFrame:IsShown() ~= UnitExists("targettarget") ) then
		TargetofTarget_Update();
	end
end

function TargetDebuffButton_Update()
	local buff, buffButton;
	local button;
	local numBuffs = 0;

	for i=1, MAX_TARGET_BUFFS do
		buff = UnitBuff("target", i);
		button = getglobal("TargetFrameBuff"..i);
		if ( buff ) then
			getglobal("TargetFrameBuff"..i.."Icon"):SetTexture(buff);
			button:Show();
			button.id = i;
			numBuffs = numBuffs + 1; 
		else
			button:Hide();
		end
	end

	local debuff, debuffButton, debuffStack, debuffType, color;
	local debuffCount;
	local numDebuffs = 0;
	for i=1, MAX_TARGET_DEBUFFS do

		local debuffBorder = getglobal("TargetFrameDebuff"..i.."Border");
		debuff, debuffStack, debuffType = UnitDebuff("target", i);
		button = getglobal("TargetFrameDebuff"..i);
		if ( debuff ) then
			getglobal("TargetFrameDebuff"..i.."Icon"):SetTexture(debuff);
			debuffCount = getglobal("TargetFrameDebuff"..i.."Count");
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			if ( debuffStack > 1 ) then
				debuffCount:SetText(debuffStack);
				debuffCount:Show();
			else
				debuffCount:Hide();
			end
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			button:Show();
			numDebuffs = numDebuffs + 1;
		else
			button:Hide();
		end
		button.id = i;
	end

	local debuffFrame, debuffWrap, debuffSize, debuffFrameSize;
	local targetofTarget = TargetofTargetFrame:IsShown();

	if ( UnitIsFriend("player", "target") ) then
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrameBuff1", "BOTTOMLEFT", 0, -2);
	else
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		if ( targetofTarget ) then
			if ( numDebuffs < 5 ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
			elseif ( numDebuffs >= 5 and numDebuffs < 10  ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
			elseif (  numDebuffs >= 10 ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff11", "BOTTOMLEFT", 0, -2);
			end
		else
			TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff7", "BOTTOMLEFT", 0, -2);
		end
	end
	
	-- set the wrap point for the rows of de/buffs.
	if ( targetofTarget ) then
		debuffWrap = 5;
	else
		debuffWrap = 6;
	end

	-- and shrinks the debuffs if they begin to overlap the TargetFrame
	if ( ( targetofTarget and ( numBuffs == 5 ) ) or ( numDebuffs >= debuffWrap ) ) then
		debuffSize = 17;
		debuffFrameSize = 19;
	else
		debuffSize = 21;
		debuffFrameSize = 23;
	end
	
	-- resize Buffs
	for i=1, 5 do
		button = getglobal("TargetFrameBuff"..i);
		if ( button ) then
			button:SetWidth(debuffSize);
			button:SetHeight(debuffSize);
		end
	end

	-- resize Debuffs
	for i=1, 6 do
		button = getglobal("TargetFrameDebuff"..i);
		debuffFrame = getglobal("TargetFrameDebuff"..i.."Border");
		if ( debuffFrame ) then
			debuffFrame:SetWidth(debuffFrameSize);
			debuffFrame:SetHeight(debuffFrameSize);
		end
		button:SetWidth(debuffSize);
		button:SetHeight(debuffSize);
	end

	-- Reset anchors for debuff wrapping
	getglobal("TargetFrameDebuff"..debuffWrap):ClearAllPoints();
	getglobal("TargetFrameDebuff"..debuffWrap):SetPoint("LEFT", getglobal("TargetFrameDebuff"..(debuffWrap - 1)), "RIGHT", 3, 0);
	getglobal("TargetFrameDebuff"..(debuffWrap + 1)):ClearAllPoints();
	getglobal("TargetFrameDebuff"..(debuffWrap + 1)):SetPoint("TOPLEFT", "TargetFrameDebuff1", "BOTTOMLEFT", 0, -2);
	getglobal("TargetFrameDebuff"..(debuffWrap + 2)):ClearAllPoints();
	getglobal("TargetFrameDebuff"..(debuffWrap + 2)):SetPoint("LEFT", getglobal("TargetFrameDebuff"..(debuffWrap + 1)), "RIGHT", 3, 0);

	-- Set anchor for the last row if debuffWrap is 5
	if ( debuffWrap == 5 ) then
		TargetFrameDebuff11:ClearAllPoints();
		TargetFrameDebuff11:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
	else
		TargetFrameDebuff11:ClearAllPoints();
		TargetFrameDebuff11:SetPoint("LEFT", "TargetFrameDebuff10", "RIGHT", 3, 0);
	end

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
		local unitMinHP, unitMaxHP, unitCurrHP;
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
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("target", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("target") ) then
		if ( UnitInParty("target") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(TargetFrameDropDown, menu, "target", name);
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

function TargetofTarget_OnUpdate(elapsed)
	if ( CURRENT_TARGETTARGET ~= UnitName("targettarget") ) then
		CURRENT_TARGETTARGET = UnitName("targettarget");
		SetPortraitTexture(this.portrait, this.unit);
		this.name:SetText(GetUnitName(this.unit));
	end
	TargetofTarget_Update();
end

function TargetofTarget_Update()
	if ( UnitExists("target")  and  UnitExists("targettarget")  and ( not UnitIsUnit("player", "target") ) and ( UnitHealth("target") > 0 ) and SHOW_TARGET_OF_TARGET == "1" ) then
		if ( ( SHOW_TARGET_OF_TARGET_STATE == "1")  and ( GetNumRaidMembers() > 0 ) ) then
			TargetofTargetFrame:Show();
		elseif ( SHOW_TARGET_OF_TARGET_STATE == "2")  then
			if ( GetNumPartyMembers() ~= 0 and GetNumRaidMembers() == 0 ) then
				TargetofTargetFrame:Show();
			else
				TargetofTargetFrame:Hide();
			end
		elseif ( SHOW_TARGET_OF_TARGET_STATE == "3") then
			if ( GetNumRaidMembers() == 0 ) then
				if ( GetNumPartyMembers() == 0 ) then
					TargetofTargetFrame:Show();
				else
					TargetofTargetFrame:Hide();
				end
			end
		elseif ( ( SHOW_TARGET_OF_TARGET_STATE == "4")  and ( ( GetNumRaidMembers() > 0 ) or  ( GetNumPartyMembers() > 0 ) ) ) then
			TargetofTargetFrame:Show();
		elseif ( ( SHOW_TARGET_OF_TARGET_STATE == "5") ) then
			TargetofTargetFrame:Show();
		else
			TargetofTargetFrame:Hide();
		end
	else
		TargetofTargetFrame:Hide();
	end

	if ( TargetofTargetFrame:IsShown() ) then
		UnitFrameHealthBar_Update(this.healthbar, this.unit);
		UnitFrameManaBar_Update(this.manabar, this.unit);
		TargetofTarget_CheckDead();
		TargetofTargetPortrait:SetAlpha(1.0);
		TargetDebuffButton_Update();
		RefreshBuffs(this, 0, "targettarget");
	end
end


function TargetofTarget_OnClick(button)
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("targettarget");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("targettarget");
		else
			TargetUnit("targettarget");
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
		local unitMinHP, unitMaxHP, unitCurrHP;
		unitHPMin, unitHPMax = this:GetMinMaxValues();
		unitCurrHP = this:GetValue();
		this:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("targettarget") ) then
			TargetofTargetPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("targettarget") ) then
			TargetofTargetPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (this:GetParent().unitHPPercent > 0) and (this:GetParent().unitHPPercent <= 0.2) ) then
			TargetofTargetPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetofTargetPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end


