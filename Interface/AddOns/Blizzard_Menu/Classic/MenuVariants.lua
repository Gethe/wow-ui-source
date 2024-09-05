function MenuVariants.GetDefaultMenuMixin()
	return MenuStyle1Mixin;
end

function MenuVariants.GetDefaultContextMenuMixin()
	return MenuStyle2Mixin;
end

function MenuVariants.CreateCheckbox(text, frame, isSelected, data)
	local leftTexture1 = frame:AttachTexture();
	frame.leftTexture1 = leftTexture1;
	leftTexture1:SetPoint("LEFT");

	local atlas = nil;
	if isSelected(data) then
		atlas = "common-dropdown-icon-checkmark-yellow-classic";
	else
		atlas = "common-dropdown-ticksquare-classic";
	end
	
	leftTexture1:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 2, -1);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);

	return leftTexture1;
end

function MenuVariants.CreateRadio(text, frame, isSelected, data)
	local leftTexture1 = frame:AttachTexture();
	frame.leftTexture1 = leftTexture1;
	leftTexture1:SetPoint("LEFT");

	local atlas = nil;
	if isSelected(data) then
		atlas = "common-dropdown-icon-radialtick-yellow-classic";
	else
		atlas = "common-dropdown-tickradial-classic";
	end
	
	leftTexture1:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	local fontString = frame:AttachFontString();
	frame.fontString = fontString;
	fontString:SetPoint("LEFT", leftTexture1, "RIGHT", 2, 0);
	fontString:SetHeight(20);
	fontString:SetTextToFit(text);

	return leftTexture1, leftTexture2;
end