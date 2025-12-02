do
	local attributes = 
	{ 
		area = "left",
		pushable = 0,
		extraWidthFunc = HousingDashboardFrameMixin.GetPanelExtraWidth,
	};
	RegisterUIPanel(HousingDashboardFrame, attributes);
end