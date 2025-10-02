-- Requires the button to inherit ButtonStateBehaviorMixin
function GetWowStyle1ArrowButtonState(button)
	if button:IsEnabled() then
		if button:IsDownOver() then
			return "common-dropdown-a-button-pressedhover";
		elseif button:IsOver() then
			return "common-dropdown-a-button-hover";
		elseif button:IsDown() then
			return "common-dropdown-a-button-pressed";
		elseif button:IsMenuOpen() then
			return "common-dropdown-a-button-open";
		else
			return "common-dropdown-a-button";
		end
	end
	return "common-dropdown-a-button-disabled";
end

-- Requires the button to inherit ButtonStateBehaviorMixin
function GetWowStyle1ArrowButtonShadowlessState(button)
	if button:IsEnabled() then
		if button:IsDownOver() then
			return "common-dropdown-a-button-shadowless-pressedhover";
		elseif button:IsOver() then
			return "common-dropdown-a-button-shadowless-hover";
		elseif button:IsDown() then
			return "common-dropdown-a-button-shadowless-pressed";
		elseif button:IsMenuOpen() then
			return "common-dropdown-a-button-shadowless-open";
		else
			return "common-dropdown-a-button-shadowless";
		end
	end
	return "common-dropdown-a-button-shadowless-disabled";
end

function WowStyle1DropdownMixin:GetArrowAtlas()
	return GetWowStyle1ArrowButtonState(self);
end

function WowStyle1ArrowDropdownMixin:OnButtonStateChanged()
	local atlas = nil;
	if self.hasShadow then
		atlas = GetWowStyle1ArrowButtonState(self);
	else
		atlas = GetWowStyle1ArrowButtonShadowlessState(self);
	end
	self.Arrow:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

MenuStyle1Mixin = CreateFromMixins(MenuStyleMixin);

function MenuStyle1Mixin:Generate()
	local background = self:AttachTexture();
	background:SetAtlas("common-dropdown-bg");

	local x, y = 10, 3;
	background:SetPoint("TOPLEFT", -x, y);
	background:SetPoint("BOTTOMRIGHT", x, -y);
	background:SetAlpha(.925);
end

do
	local inset = 
	{
		left = 8, 
		top = 8, 
		right = 8,
		bottom = 15,
	};

	function MenuStyle1Mixin:GetInset()
		return inset;
	end
end

do
	local padding = 
	{
		width = 20, 
		height = 0, 
	};

	function MenuStyle1Mixin:GetChildExtentPadding()
		return padding;
	end
end