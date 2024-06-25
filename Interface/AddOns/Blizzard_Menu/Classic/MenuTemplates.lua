function WowStyle1DropdownMixin:GetArrowAtlas()
	if self:IsEnabled() then
		if self:IsDownOver() then
			return "common-dropdown-classic-a-buttonDown-pressedhover";
		elseif self:IsOver() then
			return "common-dropdown-classic-a-buttonDown-hover";
		elseif self:IsDown() then
			return "common-dropdown-classic-a-buttonDown-pressed";
		else
			return "common-dropdown-classic-a-buttonDown";
		end
	end
	return "common-dropdown-classic-a-buttonDown-disabled";
end

function WowStyle1DropdownMixin:OnSizeChanged(width, height)
	if width <= 60 then
		self.Background:SetAtlas("common-dropdown-classic-textholder-small", TextureKitConstants.UseAtlasSize);
	else
		self.Background:SetAtlas("common-dropdown-classic-textholder", TextureKitConstants.UseAtlasSize);
	end
end

function WowStyle1FilterDropdownMixin:GetBackgroundAtlas()
	if self:IsEnabled() then
		if self:IsDownOver() then
			return "common-dropdown-classic-b-button-pressedhover";
		elseif self:IsOver() then
			return "common-dropdown-classic-b-button-hover";
		elseif self:IsDown() then
			return "common-dropdown-classic-b-button-pressed";
		else
			return "common-dropdown-classic-b-button";
		end
	end
	return "common-dropdown-b-button-disabled";
end

MenuStyle1Mixin = CreateFromMixins(MenuStyleMixin);

function MenuStyle1Mixin:Generate()
	local background = self:AttachTexture();
	background:SetAtlas("common-dropdown-classic-bg");
	background:SetPoint("TOPLEFT", -3, 3);
	background:SetPoint("BOTTOMRIGHT", 3, -4);

	local background2 = self:AttachTexture();
	background2:SetColorTexture(0, 0, 0, .8);
	background2:SetPoint("TOPLEFT", background, "TOPLEFT", 6, -6);
	background2:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT", -6, 6);
	local layer, subLevel = background:GetDrawLayer();
	background2:SetDrawLayer(layer, subLevel - 1);
end

function MenuStyle1Mixin:GetInset()
	return 12, 7, 12, 7; -- L, T, R, B
end

MenuStyle2Mixin = CreateFromMixins(MenuStyleMixin);

function MenuStyle2Mixin:Generate()
	local background = self:AttachTexture();
	background:SetAtlas("common-dropdown-classic-b-bg");
	background:SetPoint("TOPLEFT", -3, 1);
	background:SetPoint("BOTTOMRIGHT", 3, -4);

	local background2 = self:AttachTexture();
	background2:SetColorTexture(0, 0, 0, .8);
	background2:SetPoint("TOPLEFT", background, "TOPLEFT", 7, -4);
	background2:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT", -8, 8);
	local layer, subLevel = background:GetDrawLayer();
	background2:SetDrawLayer(layer, subLevel - 1);
end

function MenuStyle2Mixin:GetInset()
	return 14, 14, 14, 14; -- L, T, R, B
end
