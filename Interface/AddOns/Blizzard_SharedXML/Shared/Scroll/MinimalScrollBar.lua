
MinimalScrollBarStepperScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function MinimalScrollBarStepperScriptsMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Texture);

	self:DesaturateIfDisabled();
end

function MinimalScrollBarStepperScriptsMixin:GetAtlas()
	if self:IsEnabled() then
		if self.down then
			return self.downTexture;
		elseif self.over then
			return self.overTexture;
		end
	end
	return self.normalTexture;
end

function MinimalScrollBarStepperScriptsMixin:OnButtonStateChanged()
	self.Texture:SetAtlas(self:GetAtlas(), TextureKitConstants.UseAtlasSize);
end

MinimalScrollBarThumbScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function MinimalScrollBarThumbScriptsMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	self:DesaturateIfDisabled();
end

function MinimalScrollBarThumbScriptsMixin:GetAtlas()
	if self:IsEnabled() then
		if self.down then
			return self.downMiddleTexture, self.downBeginTexture, self.downEndTexture;
		elseif self.over then
			return self.overMiddleTexture, self.overBeginTexture, self.overEndTexture;
		end
	end
	return self.upMiddleTexture, self.upBeginTexture, self.upEndTexture;
end

function MinimalScrollBarThumbScriptsMixin:OnButtonStateChanged()
	local middleAtlas, beginAtlas, endAtlas = self:GetAtlas();
	self.Middle:SetAtlas(middleAtlas, TextureKitConstants.UseAtlasSize);
	self.Begin:SetAtlas(beginAtlas, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(endAtlas, TextureKitConstants.UseAtlasSize);
end

function MinimalScrollBarThumbScriptsMixin:OnSizeChanged(width, height)
	local info = C_Texture.GetAtlasInfo(self.Middle:GetAtlas());
	if self.isHorizontal then
		self.Middle:SetWidth(width);
		local u = math.min(width / info.width, 1);
		self.Middle:SetTexCoord(0, u, 0, 1);
	else
		self.Middle:SetHeight(height);
		local v = math.min(height / info.height, 1);
		self.Middle:SetTexCoord(0, 1, 0, v);
	end
end