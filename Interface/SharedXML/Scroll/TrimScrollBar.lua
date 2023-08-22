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

function WowTrimScrollBarStepperMixin:GetAtlas()
	if self:IsEnabled() then
		if self.down then
			return self.downTexture;
		end
		return self.upTexture;
	end
	return self.disabledTexture;
end

function WowTrimScrollBarStepperMixin:UpdateAtlas()
	self.Texture:SetAtlas(self:GetAtlas(), TextureKitConstants.UseAtlasSize);
end

function WowTrimScrollBarStepperMixin:OnEnter()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self.Overlay:Show();
	end
end

function WowTrimScrollBarStepperMixin:OnLeave()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self.Overlay:Hide();
	end
end

function WowTrimScrollBarStepperMixin:OnMouseDown()
	if ButtonStateBehaviorMixin.OnMouseDown(self) then
		self:UpdateAtlas();
		self.Texture:AdjustPointsOffset(-1, 0);
		self.Overlay:AdjustPointsOffset(-1, -1);
	end
end

function WowTrimScrollBarStepperMixin:OnMouseUp()
	if ButtonStateBehaviorMixin.OnMouseUp(self) then
		self:UpdateAtlas();
		self.Texture:AdjustPointsOffset(1, 0);
		self.Overlay:AdjustPointsOffset(1, 1);
	end
end

function WowTrimScrollBarStepperMixin:OnEnable()
	self:UpdateAtlas();
end

function WowTrimScrollBarStepperMixin:OnDisable()
	ButtonStateBehaviorMixin.OnDisable(self);
	self:UpdateAtlas();

	self.Texture:ClearPointsOffset();
	self.Overlay:ClearPointsOffset();
end

WowScrollBarThumbScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function WowScrollBarThumbScriptsMixin:OnLoad()
	self:UpdateAtlas();
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

function WowScrollBarThumbScriptsMixin:UpdateAtlas()
	local middleAtlas, beginAtlas, endAtlas = self:GetAtlas();
	self.Middle:SetAtlas(middleAtlas, TextureKitConstants.UseAtlasSize);
	self.Begin:SetAtlas(beginAtlas, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(endAtlas, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarThumbScriptsMixin:OnEnter()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self:UpdateAtlas();
	end
end
function WowScrollBarThumbScriptsMixin:OnLeave()
	if ButtonStateBehaviorMixin.OnLeave(self) then
		self:UpdateAtlas();
	end
end

function WowScrollBarThumbScriptsMixin:OnEnable()
	self:UpdateAtlas();
end

function WowScrollBarThumbScriptsMixin:OnDisable()
	ButtonStateBehaviorMixin.OnDisable(self);
	self:UpdateAtlas();
end

function WowScrollBarThumbScriptsMixin:OnSizeChanged(width, height)
	self:UpdateAtlas();
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