function MenuVariants.GetDefaultMenuMixin()
	return MenuStyle1Mixin;
end

function MenuVariants.GetDefaultContextMenuMixin()
	return MenuStyle1Mixin;
end

function MenuVariants.CreateCheckbox(text, frame, isSelected, data)
	local leftTexture1, leftTexture2 = MenuTemplates.CreateSelectionTextures(frame, isSelected, data, 
		"common-dropdown-ticksquare", "common-dropdown-icon-checkmark-yellow");
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
		"common-dropdown-tickradial", "common-dropdown-icon-radialtick-yellow");
	leftTexture1:SetPoint("LEFT", -3, 0);
	if leftTexture2 then
		leftTexture2:SetPoint("TOPLEFT", leftTexture1, "TOPLEFT");
	end

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 1, 0);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);

	return leftTexture1, leftTexture2;
end

function MenuVariants.CreateSearchEntry(text, frame, data)
	local leftTexture1 = frame:AttachTexture();
	frame.leftTexture1 = leftTexture1;
	leftTexture1:SetAtlas("common-search-magnifyingglass", TextureKitConstants.IgnoreAtlasSize);
	leftTexture1:SetSize(12, 12);
	leftTexture1:SetPoint("LEFT", -1, 1);

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 7, 0);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);
	fontString:SetAlpha(0.5);

	return leftTexture1;
end
