
CHARACTER_LIST_X_OFFSET = 3;
CHARACTER_LIST_Y_OFFSET = 1;

function CharacterSelectListMixin:AdjustElements()
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", self:GetParent().VASTokenContainer, "BOTTOMRIGHT", CHARACTER_LIST_X_OFFSET, CHARACTER_LIST_Y_OFFSET);
	self:SetPoint("BOTTOMRIGHT", self:GetParent().ListToggle, "TOPRIGHT", 0, 10);

	self.SearchBox:ClearAllPoints();
	self.SearchBox:SetPoint("TOPLEFT", 33, -25);
	self.SearchBox:SetWidth(308);
end

function CharacterSelectCreateCharacterButtonMixin:OnEnter()
	-- No realm tooltip displayed; we are realmless
end
