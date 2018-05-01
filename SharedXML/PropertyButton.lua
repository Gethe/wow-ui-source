PropertyButtonMixin = {};

function PropertyButtonMixin:OnLoad()
	if self.fixedWidth then
		self:SetWidth(self.fixedWidth);
	end

	if self.fixedHeight then
		self:SetHeight(self.fixedHeight);
	end

	if self.iconKey then
		self.Icon = self:CreateTexture(nil, "OVERLAY");

		if self.fixedIconWidth and self.fixedIconHeight then
			self.Icon:SetSize(self.fixedIconWidth, self.fixedIconHeight);
		end

		self.Icon:SetPoint("CENTER");
	end

	if self.normalAtlas then
		self:SetNormalAtlas(self.normalAtlas);
	end

	if self.pushedAtlas then
		self:SetPushedAtlas(self.pushedAtlas);
	end

	self:UpdateHighlight();
end

function PropertyButtonMixin:AddStateAtlas(stateValue, atlas)
	self.stateAtlases = self.stateAtlases or {};
	self.stateAtlases[stateValue] = atlas;
end

function PropertyButtonMixin:AddStateAtlasFallback(atlas)
	self.stateAtlasFallback = atlas;
end

function PropertyButtonMixin:GetStateAtlas(stateValue)
	if self.stateAtlases and self.stateAtlases[stateValue] then
		return self.stateAtlases[stateValue];
	elseif self.stateAtlasFallback then
		return self.stateAtlasFallback;
	else
		return "";
	end
end

function PropertyButtonMixin:SetIconToState(state)
	if self.Icon then
		self.Icon:SetAtlas(self:GetStateAtlas(state));
	end

	self:UpdateHighlight(state);
end

function PropertyButtonMixin:UpdateHighlight(state)
	-- If this wasn't already using a fixed highlight, potentially set up highlight from this icon
	if self:HasHighlightAtlas() then
		self:SetHighlight(self.highlightAtlas);
	else
		if self:IsUsingIconAsHighlight() then
			self:SetHighlight(self:GetStateAtlas(state));
			self:GetHighlightTexture():SetAlpha(.7); -- TODO: Drive from property on frame?  All icon highlights currently at 70%
		else
			self:ClearHighlight();
		end
	end

	-- Highlight may not exist, see if this is actually required
	if self.needsHighlightAnchorUpdate then
		self.needsHighlightAnchorUpdate = nil;
		local highlightTexture = self:GetHighlightTexture();
		if highlightTexture then
			highlightTexture:ClearAllPoints();
			highlightTexture:SetAllPoints(self:IsUsingIconAsHighlight() and self.Icon or self);
		end
	end
end

function PropertyButtonMixin:SetHighlight(highlight)
	if highlight then
		self:SetHighlightAtlas(highlight, "ADD");
	else
		self:ClearHighlight();
	end
end

function PropertyButtonMixin:ClearHighlight()
	self:SetHighlightTexture(nil); -- TODO: Add consistent API for clearing a highlight
end

function PropertyButtonMixin:SetIconStateQueryFunction(iconStateQuery)
	self.iconStateQuery = iconStateQuery;
end

function PropertyButtonMixin:SetUseIconAsHighlight(useIconAsHighlight)
	if self.useIconAsHighlight ~= useIconAsHighlight then
		self.useIconAsHighlight = useIconAsHighlight;
		self.needsHighlightAnchorUpdate = true;
	end
end

function PropertyButtonMixin:IsUsingIconAsHighlight()
	return self.useIconAsHighlight;
end

function PropertyButtonMixin:HasHighlightAtlas()
	return self.highlightAtlas ~= nil and self.highlightAtlas ~= "";
end

function PropertyButtonMixin:OnClick()
	if self.customToggleFunctionName then
		self[self.customToggleFunctionName](self);
	else
		self:CallMutator(not self:CallAccessor());
	end
end

function PropertyButtonMixin:OnMouseDown()
	if self.Icon then
		local alpha = self.iconPushedAlpha or 1;
		local offsetX = self.iconPushedOffsetX or -1;
		local offsetY = self.iconPushedOffsetY or -1;

		self.Icon:SetAlpha(alpha);
		self.Icon:SetPoint("CENTER", self, "CENTER", offsetX, offsetY);
	end
end

function PropertyButtonMixin:OnMouseUp()
	if self.Icon then
		local alpha = self.iconNormalAlpha or 1;

		self.Icon:SetAlpha(alpha);
		self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
	end
end

function PropertyButtonMixin:UpdateVisibleState()
	if PropertyBindingMixin.UpdateVisibleState(self) then
		local state = self:CallAccessor();
		self:SetIconToState(state);
		self:UpdateTooltipForState(state);
	end
end