function GameEvent.HandleArenaTeamInviteRequest(_dispatcher, _event, arg1, arg2)
	StaticPopup_Show("ARENA_TEAM_INVITE", arg1, arg2);
end

function GameEvent.HandlePlayerAlive(_dispatcher, _event)
	StaticPopup_Hide("DEATH");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
end

function GameEvent.HandlePlayerUnghost(_dispatcher, _event)
	StaticPopup_Hide("RESURRECT");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	StaticPopup_Hide("SKINNED");
	StaticPopup_Hide("SKINNED_REPOP");
end

function GameEvent.HandlePlayerDead(_dispatcher, _event)
	if not StaticPopup_Visible("DEATH") then
		CloseAllWindows(1);
	end
	if (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer()) then
		StaticPopup_Show("DEATH");
	end
end

function GameEvent.HandleSelfResSpellChanged(_dispatcher, _event)
	if StaticPopup_Visible("DEATH") then
		StaticPopup_Show("DEATH");
	end
end

function GameEvent.HandleResurrectRequest(_dispatcher, _event, arg1)
	if C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() then
		return true;
	end
	if ResurrectHasSickness() then
		StaticPopup_Show("RESURRECT", arg1);
	elseif ResurrectHasTimer() then
		StaticPopup_Show("RESURRECT_NO_SICKNESS", arg1);
	else
		StaticPopup_Show("RESURRECT_NO_TIMER", arg1);
	end
	return false;
end

function GameEvent.HandleEquipBindConfirm(_dispatcher, _event, arg1)
	StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
	StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	StaticPopup_Show("EQUIP_BIND", nil, nil, arg1);
end

function GameEvent.HandleEquipBindTradeableConfirm(_dispatcher, _event, arg1)
	StaticPopup_Hide("EQUIP_BIND");
	StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
	StaticPopup_Show("EQUIP_BIND_TRADEABLE", nil, nil, arg1);
end

function GameEvent.HandleCorpseInRange(_dispatcher, _event)
	StaticPopup_Show("RECOVER_CORPSE");
end

function GameEvent.HandleCorpseOutOfRange(_dispatcher, _event)
	StaticPopup_Hide("RECOVER_CORPSE");
	StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
	StaticPopup_Hide("XP_LOSS");
end

function GameEvent.HandleSocketInfoUpdate(_dispatcher, _event)
	ShowItemSocketingFrame();
end

function GameEvent.HandleSettingsLoaded(_dispatcher, _event)
	MultiActionBar_Update();
end

function GameEvent.HandleGuildBankFrameOpened(_dispatcher, _event)
	ShowGuildBankFrame();
end

function GameEvent.HandleGuildBankFrameClosed(_dispatcher, _event)
	HideGuildBankFrame();
end

function GameEvent.CheckPlayerEnteringWorldDeath()
	if GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 then
		StaticPopup_Show("DEATH");
	end
end

function GameEvent.CheckArenaInstance(instanceType)
	if instanceType == "arena" or instanceType == "pvp" then
		Arena_LoadUI();
	end
end
