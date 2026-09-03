function GameEvent.CheckPlayerEnteringWorldDeath()
	if CheckHardcoreGuildLeadStatus() and (UnitIsDead("player") or UnitIsGhost("player")) then
		ShowHardcoreGuildHandoff();
	elseif GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 then
		StaticPopup_Show(GetDeathStaticPopup());
	end
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

function GameEvent.HandlePlayerGuildUpdate(_dispatcher, _event)
	if CheckHardcoreGuildLeadStatus() and (UnitIsDead("player") or UnitIsGhost("player")) then
		ShowHardcoreGuildHandoff();
	end
end

function GameEvent.HandlePlayerDead(_dispatcher, _event, _arg1)
	if not StaticPopup_Visible("DEATH") then
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