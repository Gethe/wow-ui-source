
LFG_EYE_TEXTURES = { };
LFG_EYE_TEXTURES["default"] = { file = "Interface\\LFGFrame\\LFG-Eye", width = 512, height = 256, frames = 29, iconSize = 64, delay = 0.1 };
LFG_EYE_TEXTURES["raid"] = { file = "Interface\\LFGFrame\\LFR-Anim", width = 256, height = 256, frames = 16, iconSize = 64, delay = 0.05 };
LFG_EYE_TEXTURES["unknown"] = { file = "Interface\\LFGFrame\\WaitAnim", width = 128, height = 128, frames = 4, iconSize = 64, delay = 0.25 };


-------------------------------------------------------
----------LFGEyeTemplateMixin
-------------------------------------------------------
LFGEyeTemplateMixin = {};

function LFGEyeTemplateMixin:OnLoad()
	self:StopAnimating();
end

function LFGEyeTemplateMixin:OnUpdate(elapsed)
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	AnimateTexCoords(self.Texture, textureInfo.width, textureInfo.height, textureInfo.iconSize, textureInfo.iconSize, textureInfo.frames, elapsed, textureInfo.delay)
end

function LFGEyeTemplateMixin:StartAnimating()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function LFGEyeTemplateMixin:StopAnimating()
	self:SetScript("OnUpdate", nil);
	if ( self.Texture.frame ) then
		self.Texture.frame = 1;	--To start the animation over.
	end
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	self.Texture:SetTexCoord(0, textureInfo.iconSize / textureInfo.width, 0, textureInfo.iconSize / textureInfo.height);
end
