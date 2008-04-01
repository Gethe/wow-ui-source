
function PlayerFrame_OnLoad()
	this.statusCounter = 0;
	this.statusSign = -1;
	PlayerLevelText:SetText(UnitLevel("player"));
	CombatFeedback_Initialize(PlayerHitIndicator, 30);
	PlayerFrame_UpdatePartyLeader();
	PlayerFrame_UpdatePvPStatus();
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_COMBAT");
	this:RegisterEvent("UNIT_SPELLMISS");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_MAXMANA");
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- This is for debug feedback for Q/A
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	PlayerAttackBackground:SetVertexColor(0.8, 0.1, 0.1);
	PlayerAttackBackground:SetAlpha(0.4);
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
		return;
	end
	if ( event == "UNIT_COMBAT" ) then
		if ( arg1 == "player" ) then
			CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5);
		end
		return;
	end
	if ( event == "UNIT_SPELLMISS" ) then
		if ( arg1 == "player" ) then
			CombatFeedback_OnSpellMissEvent(arg2);
		end
		return;
	end
	if ( event == "UNIT_PVP_UPDATE" ) then
		if ( arg1 == "player" ) then
			PlayerFrame_UpdatePvPStatus();
		end
		return;
	end
	if ( event == "PLAYER_ENTER_COMBAT" ) then
		this.inCombat = 1;
		PlayerFrame_UpdateStatus();
		return;
	end
	if ( event == "PLAYER_UPDATE_RESTING" ) then
		PlayerFrame_UpdateStatus();
		return;
	end
	if ( event == "PLAYER_LEAVE_COMBAT" ) then
		this.inCombat = nil;
		PlayerFrame_UpdateStatus();
		return;
	end
	if ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" ) then
		PlayerFrame_UpdatePartyLeader();
		return;
	end
	if ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		local lootMethod;
		local lootMaster;
		lootMethod, lootMaster = GetLootMethod();
		if ( lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
			getglobal("PlayerMasterIcon"):Show();
		else
			getglobal("PlayerMasterIcon"):Hide();
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		UnitFrame_UpdateManaType();
		PlayerFrame_UpdateStatus();
	end
	if ( event == "PLAYER_REGEN_DISABLED" ) then
		this.onHateList = 1;
		PlayerFrame_UpdateStatus();
		return;
	end
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		this.onHateList = nil;
		PlayerFrame_UpdateStatus();
		return;
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
		UnitPopup_ShowMenu(this, "SELF", "player");
		UnitPopup:ClearAllPoints();
		UnitPopup:SetPoint("TOPLEFT", "PlayerFrame", "BOTTOMLEFT", 30, 24);
	end
end

function PlayerFrame_OnReceiveDrag()
	if ( CursorHasItem() ) then
		AutoEquipCursorItem();
	end
end

function LootThreshold_OnClick(id)
	SetLootThreshold(id);
	PlayerFrameLootThresholdPopup:Hide();
	PlaySound("UChatScrollButton");
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
	elseif ( this.inCombat and this.onHateList or this.inCombat ) then
		PlayerStatusTexture:SetVertexColor(1.0, 0.0, 0.0, 1.0);
		PlayerStatusTexture:Show();
		PlayerAttackIcon:Show();
		PlayerRestIcon:Hide();
		PlayerAttackGlow:Show();
		PlayerRestGlow:Hide();
		PlayerStatusGlow:Show();
		PlayerAttackBackground:Show();
	elseif ( this.onHateList ) then
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
