do
	local attributes = 
	{ 
		area = "center",
		pushable = 2,
	};
	RegisterUIPanel(HousingCreateGuildNeighborhoodFrame, attributes);
    RegisterUIPanel(HousingCreateNeighborhoodCharterFrame, attributes);
    RegisterUIPanel(HousingCreateCharterNeighborhoodConfirmationFrame, attributes);
end