MinimalScrollBarStepperScriptsMixin = CreateFromMixins(ScrollBarButtonBehaviorMixin);

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

function MinimalScrollBarStepperScriptsMixin:UpdateAtlas()
	self.Texture:SetAtlas(self:GetAtlas(), TextureKitConstants.UseAtlasSize);
end

function MinimalScrollBarStepperScriptsMixin:OnEnter()
	if ScrollBarButtonBehaviorMixin.OnEnter(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarStepperScriptsMixin:OnLeave()
	if ScrollBarButtonBehaviorMixin.OnLeave(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarStepperScriptsMixin:OnMouseDown()
	if ScrollBarButtonBehaviorMixin.OnMouseDown(self) then
		self:UpdateAtlas();
		self.Texture:AdjustPointsOffset(1, -1);
	end
end

function MinimalScrollBarStepperScriptsMixin:OnMouseUp()
	if ScrollBarButtonBehaviorMixin.OnMouseUp(self) then
		self:UpdateAtlas();
		self.Texture:AdjustPointsOffset(-1, 1);
	end
end

function MinimalScrollBarStepperScriptsMixin:OnEnable()
	self:UpdateAtlas();
	self:DesaturateHierarchy(0);
end

function MinimalScrollBarStepperScriptsMixin:OnDisable()
	ScrollBarButtonBehaviorMixin.OnDisable(self);
	self:UpdateAtlas();

	self:DesaturateHierarchy(1);
	self.Texture:ClearPointsOffset();
end

MinimalScrollBarThumbScriptsMixin = CreateFromMixins(ScrollBarButtonBehaviorMixin);

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

function MinimalScrollBarThumbScriptsMixin:UpdateAtlas()
	local middleAtlas, beginAtlas, endAtlas = self:GetAtlas();
	self.Middle:SetAtlas(middleAtlas, TextureKitConstants.UseAtlasSize);
	self.Begin:SetAtlas(beginAtlas, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(endAtlas, TextureKitConstants.UseAtlasSize);
end

function MinimalScrollBarThumbScriptsMixin:OnEnter()
	if ScrollBarButtonBehaviorMixin.OnEnter(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarThumbScriptsMixin:OnLeave()
	if ScrollBarButtonBehaviorMixin.OnLeave(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarThumbScriptsMixin:OnMouseDown()
	if ScrollBarButtonBehaviorMixin.OnMouseDown(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarThumbScriptsMixin:OnMouseUp()
	if ScrollBarButtonBehaviorMixin.OnMouseUp(self) then
		self:UpdateAtlas();
	end
end

function MinimalScrollBarThumbScriptsMixin:OnEnable()
	self:UpdateAtlas();
	self:DesaturateHierarchy(0);
end

function MinimalScrollBarThumbScriptsMixin:OnDisable()
	ScrollBarButtonBehaviorMixin.OnDisable(self);
	self:UpdateAtlas();

	self:DesaturateHierarchy(1);
end

function MinimalScrollBarThumbScriptsMixin:OnSizeChanged(width, height)
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