MinimalTabMixin = {};

function MinimalTabMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);

	self.Text:SetText(self.tabText);
	self:SetWidth(self.Text:GetStringWidth() + 40);

	self:OnSelected(false);
end

function MinimalTabMixin:GetAtlas()
	if self:IsSelected() then
		return self.selectedLeftTexture, self.selectedRightTexture, self.selectedMiddleTexture;
	end

	if self.over then
		return self.overLeftTexture, self.overRightTexture, self.overMiddleTexture;
	end
	return self.upLeftTexture, self.upRightTexture, self.upMiddleTexture;
end

function MinimalTabMixin:UpdateAtlas()
	local leftAtlas, rightAtlas, middleAtlas = self:GetAtlas();
	self.Left:SetAtlas(leftAtlas, TextureKitConstants.UseAtlasSize);
	self.Right:SetAtlas(rightAtlas, TextureKitConstants.UseAtlasSize);
	self.Middle:SetAtlas(middleAtlas, TextureKitConstants.UseAtlasSize);
end

function MinimalTabMixin:OnSelected(newSelected)
	self:UpdateAtlas();

	if newSelected then
		self.Text:SetPoint("BOTTOM", 0, 6);
		self.Text:SetFontObject("GameFontHighlightSmall");
	else
		self.Text:SetPoint("BOTTOM", 0, 4);
		self.Text:SetFontObject("GameFontNormalSmall");
	end
end

function MinimalTabMixin:OnEnter()
	self:UpdateAtlas();
end

function MinimalTabMixin:OnLeave()
	self:UpdateAtlas();
end

function MinimalTabMixin:OnEnable()
	self:UpdateAtlas();
end

function MinimalTabMixin:OnDisable()
	self:UpdateAtlas();
end