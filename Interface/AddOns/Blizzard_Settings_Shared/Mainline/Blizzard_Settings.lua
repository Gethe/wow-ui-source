function Settings.IsPlunderstorm()
	return C_GameRules and (C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm);
end