do
	local attributes = {
		area = "center",
		whileDead = 0,
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 1,
		checkFitExtraWidth = 200,
		checkFitExtraHeight = 140,
	};
	RegisterUIPanel(ScribeFrame, attributes);
end
