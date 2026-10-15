local HandlePlayerEnteringWorld = GameEvent.HandlePlayerEnteringWorld;

function GameEvent.HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload)
	HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload);

	if CheckHardcoreGuildLeadStatus() and (UnitIsDead("player") or UnitIsGhost("player")) then
		ShowHardcoreGuildHandoff();
	elseif GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 then
		StaticPopup_Show(GetDeathStaticPopup());
	end

	SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());

	return true;
end

function GameEvent.HandlePlayerDead(_dispatcher, _event)
	if not StaticPopup_Visible(GetDeathStaticPopup()) then
		CloseAllWindows(1);
	end

	if (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer() or C_GameRules.IsHardcoreActive()) then
		if CheckHardcoreGuildLeadStatus() then
			ShowHardcoreGuildHandoff();
		else
			StaticPopup_Show(GetDeathStaticPopup());
		end
	end
end

function GameEvent.HandleSelfResSpellChanged(_dispatcher, _event)
	if StaticPopup_Visible(GetDeathStaticPopup()) then
		StaticPopup_Show(GetDeathStaticPopup());
	end
end

function GameEvent.HandlePlayerAlive(_dispatcher, _event)
	StaticPopup_Hide("DEATH");
	StaticPopup_Hide("HARDCORE_DEATH");
	StaticPopup_Hide("HARDCORE_DEATH_GUILD_HANDOFF");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	StaticPopup_Hide("RESURRECT");

	SetGhostFrameShown(CanPortGraveyard() and UnitIsGhost("player"));
end

function GameEvent.HandleDeleteItemConfirm(_dispatcher, _event, arg1, arg2, _arg3, arg4, arg5)
	if arg2 >= Enum.ItemQuality.Rare and arg2 ~= Enum.ItemQuality.Heirloom then
		if arg4 == 1 then
			if InputUtil.IsGamepadUIEnabled() then
				StaticPopup_Show("DELETE_GOOD_QUEST_ITEM_GAMEPAD", arg1, nil, { itemGUID = arg5 });
			else
				StaticPopup_Show("DELETE_GOOD_QUEST_ITEM", arg1, nil, { itemGUID = arg5 });
			end
		else
			if InputUtil.IsGamepadUIEnabled() then
				StaticPopup_Show("DELETE_GOOD_ITEM_GAMEPAD", arg1, nil, { itemGUID = arg5 });
			else
				StaticPopup_Show("DELETE_GOOD_ITEM", arg1, nil, { itemGUID = arg5 });
			end
		end
	else
		if arg4 == 1 then
			StaticPopup_Show("DELETE_QUEST_ITEM", arg1, nil, { itemGUID = arg5 });
		else
			StaticPopup_Show("DELETE_ITEM", arg1, nil, { itemGUID = arg5 });
		end
	end
end

function GameEvent.HandleCursorChanged(_dispatcher, _event)
	if not CursorHasItem() and not InputUtil.IsGamepadUIEnabled() then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	end
end

function GameEvent.HandlePlayerGuildUpdate(_dispatcher, _event)
	if CheckHardcoreGuildLeadStatus() and (UnitIsDead("player") or UnitIsGhost("player")) then
		ShowHardcoreGuildHandoff();
	end
end

function GameEvent.HandleDuelToTheDeathRequested(_dispatcher, _event, arg1)
	StaticPopup_Show("DUEL_TO_THE_DEATH_REQUESTED", arg1, arg1);
end

function GameEvent.HandleTrainerShow(_dispatcher, _event)
	ClassTrainerFrame_LoadUI();
	ShowUIPanel(ClassTrainerFrame);
end

function GameEvent.HandleLFGEnabledStateChanged(_dispatcher, _event)
	SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());
end

function GameEvent.HandleCorpseInRange(_dispatcher, _event)
	if C_GameRules.IsHardcoreActive() then
		if not IsGuildLeader() then
			StaticPopup_Show("HARDCORE_RECOVER_CORPSE");
		end
	else
		StaticPopup_Show("RECOVER_CORPSE");
	end
end

function GameEvent.HandleCorpseOutOfRange(_dispatcher, _event)
	StaticPopup_Hide("HARDCORE_RECOVER_CORPSE");
	StaticPopup_Hide("HARDCORE_CORPSE_INSTANCE");
	StaticPopup_Hide("RECOVER_CORPSE");
	StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
	StaticPopup_Hide("XP_LOSS");
end

function GameEvent.HandleUpdateBattlefieldStatus(_dispatcher, _event)
	-- Camelot doesn't use the pvpUI
end
