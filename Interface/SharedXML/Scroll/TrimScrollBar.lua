WowTrimScrollBarMixin = {};

function WowTrimScrollBarMixin:OnLoad()
	ScrollBarMixin.OnLoad(self);

	if self.hideBackground then
		self.Background:Hide();
	end
	
	if self.hideBackplate then
		self.Backplate:Hide();
	end

	if self.backplateAlpha then
		self.Backplate:SetAlpha(self.backplateAlpha);
	end
end

WowTrimScrollBarStepperMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function WowTrimScrollBarStepperMixin:OnLoad()
	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Texture, self.Overlay);
end

function WowTrimScrollBarStepperMixin:GetAtlas()
	if self:IsEnabled() then
		if self:IsDown() then
			return self.downTexture;
		end
		return self.upTexture;
	end
	return self.disabledTexture;
end

function WowTrimScrollBarStepperMixin:OnButtonStateChanged()
	self.Texture:SetAtlas(self:GetAtlas(), TextureKitConstants.UseAtlasSize);
	self.Overlay:SetShown(self:IsOver());
end

WowScrollBarThumbScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function WowScrollBarThumbScriptsMixin:OnLoad()
	self:OnButtonStateChanged();
end

function WowScrollBarThumbScriptsMixin:GetAtlas()
	if self:IsEnabled() then
		if self.over then
			return self.overMiddleTexture, self.overBeginTexture, self.overEndTexture;
		end
		return self.upMiddleTexture, self.upBeginTexture, self.upEndTexture;
	end
	return self.disabledMiddleTexture, self.disabledBeginTexture, self.disabledEndTexture;
end

function WowScrollBarThumbScriptsMixin:OnButtonStateChanged()
	local middleAtlas, beginAtlas, endAtlas = self:GetAtlas();
	self.Middle:SetAtlas(middleAtlas, TextureKitConstants.UseAtlasSize);
	self.Begin:SetAtlas(beginAtlas, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(endAtlas, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarThumbScriptsMixin:OnSizeChanged(width, height)
	self:OnButtonStateChanged();
	local info = C_Texture.GetAtlasInfo(self.Middle:GetAtlas());
	if self.isHorizontal then
		self.Middle:SetWidth(width);
		local u = width / info.width;
		self.Middle:SetTexCoord(0, u, 0, 1);
	else
		self.Middle:SetHeight(height);
		local v = height / info.height;
		self.Middle:SetTexCoord(0, 1, 0, v);
	end
end