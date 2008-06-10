REQUIRED_REST_HOURS = 5;

function PlayerFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	CombatFeedback_Initialize(PlayerHitIndicator, 30);
	PlayerFrame_Update();
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_COMBAT");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_MAXMANA");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	-- Chinese playtime stuff
	this:RegisterEvent("PLAYTIME_CHANGED");

	PlayerAttackBackground:SetVertexColor(0.8, 0.1, 0.1);
	PlayerAttackBackground:SetAlpha(0.4);
end

function PlayerFrame_Update()
	if ( UnitExists("player") ) then
		PlayerLevelText:SetText(UnitLevel("player"));
		PlayerFrame_UpdatePartyLeader();
		PlayerFrame_UpdatePvPStatus();
		PlayerFrame_UpdateStatus();
		PlayerFrame_UpdatePlaytime();
	end
end

function PlayerFrame_UpdatePartyLeader()
	if ( IsPartyLeader() ) then
		PlayerLeaderIcon:Show();
	else
		PlayerLeaderIcon:Hide();
	end
	local lootMethod;
	local lootMaster;
	lootMethod, lootMaster = GetLootMethod();
	if ( lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
		PlayerMasterIcon:Show();
	else
		PlayerMasterIcon:Hide();
	end
end

function PlayerFrame_UpdatePvPStatus()
	local factionGroup, factionName = UnitFactionGroup("player");
	if ( UnitIsPVPFreeForAll("player") ) then
		PlaySound("igPVPUpdate");
		PlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		PlayerPVPIcon:Show();

		-- Setup newbie tooltip
		PlayerPVPIconHitArea.tooltipTitle = PVPFFA;
		PlayerPVPIconHitArea.tooltipText = NEWBIE_TOOLTIP_PVPFFA;
		PlayerPVPIconHitArea:Show();
	elseif ( factionGroup and UnitIsPVP("player") ) then
		PlaySound("igPVPUpdate");
		PlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		PlayerPVPIcon:Show();

		-- Setup newbie tooltip
		PlayerPVPIconHitArea.tooltipTitle = factionName;
		PlayerPVPIconHitArea.tooltipText = getglobal("NEWBIE_TOOLTIP_"..strupper(factionGroup));
		PlayerPVPIconHitArea:Show();
	else
		PlayerPVPIcon:Hide();
		PlayerPVPIconHitArea:Hide();
	end
end

function PlayerFrame_OnEvent(event)
	UnitFrame_OnEvent(event);

	if ( event == "UNIT_LEVEL" ) then
		if ( arg1 == "player" ) then
			PlayerLevelText:SetText(UnitLevel("player"));
		end
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == "player" ) then
			CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == "player" ) then
			PlayerFrame_UpdatePvPStatus();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		UnitFrame_Update();
		this.inCombat = nil;
		this.onHateList = nil;
		PlayerFrame_Update();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		this.inCombat = 1;
		PlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		this.inCombat = nil;
		PlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_REGEN_DISABLED" ) then
		this.onHateList = 1;
		PlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		this.onHateList = nil;
		PlayerFrame_UpdateStatus();
	elseif ( event == "PLAYER_UPDATE_RESTING" ) then
		PlayerFrame_UpdateStatus();
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		PlayerFrame_UpdateGroupIndicator();
		PlayerFrame_UpdatePartyLeader();
	elseif ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
			PlayerMasterIcon:Show();
		else
			PlayerMasterIcon:Hide();
		end
	elseif ( event == "PLAYTIME_CHANGED" ) then
		PlayerFrame_UpdatePlaytime();
	end
end

function PlayerFrame_OnUpdate(elapsed)
	if ( PlayerStatusTexture:IsVisible() ) then
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
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		PlayerStatusTexture:SetAlpha(alpha);
		PlayerStatusGlow:SetAlpha(alpha);
	end
	CombatFeedback_OnUpdate(elapsed);
end

function PlayerFrame_OnClick(button)
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("player");
		elseif ( CursorHasItem() ) then
			AutoEquipCursorItem();
		else
			TargetUnit("player");
		end
	else
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "PlayerFrame", 106, 27);
		return;
	end
end

function PlayerFrame_OnReceiveDrag()
	if ( CursorHasItem() ) then
		AutoEquipCursorItem();
	end
end

function PlayerFrame_UpdateStatus()
	if ( IsResting() ) then
		PlayerStatusTexture:SetVertexColor(1.0, 0.88, 0.25, 1.0);
		PlayerStatusTexture:Show();
		PlayerRestIcon:Show();
		PlayerAttackIcon:Hide();
		PlayerRestGlow:Show();
		PlayerAttackGlow:Hide();
		PlayerStatusGlow:Show();
		PlayerAttackBackground:Hide();
	elseif ( PlayerFrame.inCombat ) then
		PlayerStatusTexture:SetVertexColor(1.0, 0.0, 0.0, 1.0);
		PlayerStatusTexture:Show();
		PlayerAttackIcon:Show();
		PlayerRestIcon:Hide();
		PlayerAttackGlow:Show();
		PlayerRestGlow:Hide();
		PlayerStatusGlow:Show();
		PlayerAttackBackground:Show();
	elseif ( PlayerFrame.onHateList ) then
		PlayerAttackIcon:Show();
		PlayerRestIcon:Hide();
		PlayerStatusGlow:Hide();
		PlayerAttackBackground:Hide();
	else
		PlayerStatusTexture:Hide();
		PlayerRestIcon:Hide();
		PlayerAttackIcon:Hide();
		PlayerStatusGlow:Hide();
		PlayerAttackBackground:Hide();
	end
end

function PlayerFrame_UpdateGroupIndicator()
	PlayerFrameGroupIndicator:Hide();
	local name, rank, subgroup;
	if ( GetNumRaidMembers() == 0 ) then
		PlayerFrameGroupIndicator:Hide();
		return;
	end
	local numRaidMembers = GetNumRaidMembers();
	for i=1, MAX_RAID_MEMBERS do
		if ( i <= numRaidMembers ) then
			name, rank, subgroup = GetRaidRosterInfo(i);
			-- Set the player's group number indicator
			if ( name == UnitName("player") ) then
				PlayerFrameGroupIndicatorText:SetText(GROUP.." "..subgroup);
				PlayerFrameGroupIndicator:SetWidth(PlayerFrameGroupIndicatorText:GetWidth()+40);
				PlayerFrameGroupIndicator:Show();
			end
		end
	end
end

function PlayerFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, PlayerFrameDropDown_Initialize, "MENU");
end

function PlayerFrameDropDown_Initialize()
	UnitPopup_ShowMenu(PlayerFrameDropDown, "SELF", "player");
end

function PlayerFrame_UpdatePlaytime()
	if ( PartialPlayTime() ) then
		PlayerPlayTimeIcon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeTired");
		PlayerPlayTime.tooltip = format(PLAYTIME_TIRED, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		PlayerPlayTime:Show();
	elseif ( NoPlayTime() ) then
		PlayerPlayTimeIcon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeUnhealthy");
		PlayerPlayTime.tooltip = format(PLAYTIME_UNHEALTHY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		PlayerPlayTime:Show();
	else
		PlayerPlayTime:Hide();
	end
end
