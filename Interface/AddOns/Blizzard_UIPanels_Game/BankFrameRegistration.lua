do
	local attributes = 
	{ 
		area = "left",
		pushable = 6,
		width = 425,
	};
	if bankFrameWidthOverride then
		attributes["width"] = bankFrameWidthOverride
	end
	RegisterUIPanel(BankFrame, attributes);
end
