function BaseBagSlotButtonMixin:GetSlotAtlases()
	return "bag-border", "bag-border-empty", "bag-border-highlight";
end

function MainMenuBarBackpackMixin:GetSlotAtlases()
	return "bag-main", "bag-main", "bag-main-highlight";
end

function CharacterReagentBagMixin:GetSlotAtlases()
	return "bag-reagent-border", "bag-reagent-border-empty", "bag-border-highlight";
end

function BaseBagSlotButtonMixin:UpdateTextures()
	local size = ContainerFrame_GetContainerNumSlots(self:GetBagID());
	local bagSlotAtlas, bagSlotEmptyAtlas, bagSlotHighlight = self:GetSlotAtlases();
	local atlas = (size and size > 0) and bagSlotAtlas or bagSlotEmptyAtlas;

	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAllPoints(self);
	normalTexture:SetAtlas(atlas);

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:SetAllPoints(self);
	pushedTexture:SetAtlas(atlas);

	local highlight = self:GetHighlightTexture();
	highlight:SetAllPoints(self);
	highlight:SetBlendMode("ADD");
	highlight:SetAlpha(.4);
	highlight:SetAtlas(bagSlotHighlight);

	self.SlotHighlightTexture:SetAtlas(bagSlotHighlight);
end