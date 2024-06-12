function MenuVariants.GetDefaultMenuMixin()
	return MenuStyle2Mixin;
end

function MenuVariants.GetDefaultContextMenuMixin()
	return MenuStyle2Mixin;
end

function MenuVariants.CreateCheckbox(text, frame, isSelected, data)
	local leftTexture1, leftTexture2 = MenuTemplates.CreateSelectionTextures(frame, isSelected, data, 
		"common-dropdown-ticksquare-classic", "common-dropdown-icon-checkmark-yellow-classic");
	leftTexture1:SetPoint("LEFT");
	if leftTexture2 then
		leftTexture2:SetPoint("CENTER", leftTexture1, "CENTER", 2, 1);
	end

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 7, 1);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);

	return leftTexture1, leftTexture2;
end

function MenuVariants.CreateRadio(text, frame, isSelected, data)
	local leftTexture1, leftTexture2 = MenuTemplates.CreateSelectionTextures(frame, isSelected, data, 
		"common-dropdown-tickradial-classic", "common-dropdown-icon-radialtick-yellow-classic");
	leftTexture1:SetPoint("LEFT", -3, 0);
	if leftTexture2 then
		leftTexture2:SetPoint("TOPLEFT", leftTexture1, "TOPLEFT");
	end

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 3, 0);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);

	return leftTexture1, leftTexture2;
end