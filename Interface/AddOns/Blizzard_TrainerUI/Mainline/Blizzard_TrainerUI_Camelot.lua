-- Camelot-specific trainer UI overrides

local NAME_LEFT_OFFSET = 48;
local NAME_RIGHT_PADDING = 5;
local MONEY_RIGHT_OVERHANG = 5;
local NAME_SUBTEXT_SPACING = 5;
local ALTERNATE_COST_INSET = 15; -- matches the alternateCost anchor offset from money's right edge

function TrainerUI_UseCategories()
	return C_Trainer.GetTrainerType() ~= Enum.TrainerType.Pet;
end

function ClassTrainerSkillButtonMixin:UpdateNameWidth()
	local priceWidth = 0;
	if self.money:IsShown() then
		priceWidth = self.money:GetWidth();
	elseif self.alternateCost:IsShown() then
		priceWidth = self.alternateCost:GetStringWidth() + ALTERNATE_COST_INSET;
	end

	-- set max width of name so it fits against the price text.
	local availableWidth = self:GetWidth() + MONEY_RIGHT_OVERHANG - priceWidth - NAME_LEFT_OFFSET - NAME_RIGHT_PADDING;
	local nameWidth = math.max(1, math.min(self.name:GetUnboundedStringWidth(), availableWidth));
	self.name:SetWidth(nameWidth);

	-- Hide sub text if it isn't going to fit.
	local subTextWidth = availableWidth - nameWidth - NAME_SUBTEXT_SPACING;
	local showSubText = subTextWidth >= 1 and self.nameSubText:GetText() ~= "";
	-- nameSubText example "(Rank 4)" or "(Requires: Level 60)"
	self.nameSubText:SetShown(showSubText);

	if showSubText then
		self.nameSubText:SetWordWrap(false);
		self.nameSubText:SetWidth(math.min(self.nameSubText:GetUnboundedStringWidth(), subTextWidth));
	end
end
