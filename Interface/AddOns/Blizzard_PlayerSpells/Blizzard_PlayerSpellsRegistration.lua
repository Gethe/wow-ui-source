do
	local settings =
	{
		area = "centerOrLeft",
		pushable = 3,
		checkFit = 1,
		checkFitExtraWidth = 200,
		checkFitExtraHeight = 140,
		whileDead = 1,
		allowOtherPanels = 1,
		yoffset = 75,

		autoMinimizeWithOtherPanels = 1,
		autoMinimizeOnCondition = PlayerSpellsFrame.ShouldAutoMinimize,
		setMinimizedFunc = PlayerSpellsFrame.SetMinimized,
	};

	RegisterUIPanel(PlayerSpellsFrame, settings);
end