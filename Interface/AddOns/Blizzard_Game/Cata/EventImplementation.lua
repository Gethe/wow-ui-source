
function GameEvent.HandleArenaTeamInviteCancel(_dispatcher, _event)
	StaticPopup_Hide("ARENA_TEAM_INVITE");
end

function GameEvent.HandlePlayerAlive(_dispatcher, _event)
	StaticPopup_Hide("DEATH");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	SetGhostFrameShown(UnitIsGhost("player"));
end

function GameEvent.HandlePlayerUnghost(_dispatcher, _event)
	StaticPopup_Hide("RESURRECT");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	StaticPopup_Hide("SKINNED");
	StaticPopup_Hide("SKINNED_REPOP");
	SetGhostFrameShown(false);
end

function GameEvent.HandleForgeMasterOpened(_dispatcher, _event)
	ShowReforgingFrame();
end

function GameEvent.HandleForgeMasterClosed(_dispatcher, _event)
	HideReforgingFrame();
end

function GameEvent.HandleArchaeologyToggle(_dispatcher, _event)
	ArchaeologyFrame_ToggleUI();
end

function GameEvent.HandleArchaeologySurveyCast(dispatcher, event, ...)
	ArcheologyDigsiteProgressBar_OnSurveyCast(event, ...);
	dispatcher:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");
end

function GameEvent.HandlePlayerControlGained(_dispatcher, _event)
end

function GameEvent.HandleNotchedDisplayModeChanged(_dispatcher, _event)
end
