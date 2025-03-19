function Settings.IsPlunderstorm()
	return C_GameModeManager and (C_GameModeManager.GetCurrentGameMode() == Enum.GameMode.Plunderstorm);
end