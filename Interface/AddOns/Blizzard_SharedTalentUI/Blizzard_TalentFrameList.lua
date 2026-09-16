
-- Talent frame lists display talents in a vertical list, with each talent button stacked on top of the next.

TalentFrameListMixin = {};

function TalentFrameListMixin:UpdateAllTalentButtonPositions()
	-- Overrides TalentFrameBaseMixin.

	local isVertical = self.isVertical;
	local previousButton = nil;
	local buttons = self:GetButtonsInDefaultOrder();

	-- Start with the spacing between buttons
	local totalButtonLength = self.buttonSpacing * (#buttons - 1);

	for _i, talentButton in ipairs(buttons) do
		totalButtonLength = totalButtonLength + (isVertical and talentButton:GetHeight() or talentButton:GetWidth());

		if not previousButton then
			talentButton:SetPoint("TOPLEFT");
		else
			if isVertical then
				talentButton:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -self.buttonSpacing);
			else
				talentButton:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", self.buttonSpacing, 0);
			end
		end

		previousButton = talentButton;
	end

	if self.centerAlign then
		local initialButton = buttons[1];
		if not initialButton then
			return
		end

		if isVertical then
			local height = self.ButtonsParent:GetHeight();
			initialButton:AdjustPointsOffset(0, -(height - totalButtonLength) / 2);
		else
			local width = self.ButtonsParent:GetWidth();
			initialButton:AdjustPointsOffset((width - totalButtonLength) / 2, 0);
		end
	end
end
