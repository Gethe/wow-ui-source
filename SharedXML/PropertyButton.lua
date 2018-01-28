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

	if self.highlightAtlas then
		self:SetHighlightAtlas(self.highlightAtlas, "ADD");
	end
end

function PropertyButtonMixin:AddStateAtlas(stateValue, atlas)
	self.stateAtlases = self.stateAtlases or {};
	self.stateAtlases[stateValue] = atlas;
end

function PropertyButtonMixin:GetStateAtlas(stateValue)
	return self.stateAtlases and self.stateAtlases[stateValue] or "";
end

function PropertyButtonMixin:SetIconToState(state)
	if self.Icon then
		self.Icon:SetAtlas(self:GetStateAtlas(state));
	end
end

function PropertyButtonMixin:SetIconStateQueryFunction(iconStateQuery)
	self.iconStateQuery = iconStateQuery;
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