do
	local attributes =
	{
		allowOtherPanels = 1,
		area = "center",
		pushable = 0,
	};

	RegisterUIPanel(HousingCornerstoneFrame, attributes);
	RegisterUIPanel(HousingCornerstonePurchaseFrame, attributes);
	RegisterUIPanel(HousingCornerstoneVisitorFrame, attributes);
	RegisterUIPanel(HousingCornerstoneHouseInfoFrame, attributes);
end
