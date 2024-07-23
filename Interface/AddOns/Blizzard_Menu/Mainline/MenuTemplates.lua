-- Requires the button to be configured by ButtonStateBehaviorMixin
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

function WowStyle1DropdownMixin:GetArrowAtlas()
	return GetWowStyle1ArrowButtonState(self);
end

function WowStyle1FilterDropdownMixin:GetBackgroundAtlas()
	if self:IsEnabled() then
		if self:IsDownOver() then
			return "common-dropdown-b-button-pressedhover";
		elseif self:IsOver() then
			return "common-dropdown-b-button-hover";
		elseif self:IsDown() then
			return "common-dropdown-b-button-pressed";
		elseif self:IsMenuOpen() then	
			return "common-dropdown-b-button-open";
		else
			return "common-dropdown-b-button";
		end
	end
	return "common-dropdown-b-button-disabled";
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

function MenuStyle1Mixin:GetInset()
	return 8, 8, 8, 15; -- L, T, R, B
end

function MenuStyle1Mixin:GetChildExtentPadding()
	return 20, 0;
end