---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("TextureKitConstants");
	Import("C_Texture");
end
----------------

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
		local u = width / info.width;
		self.Middle:SetTexCoord(0, u, 0, 1);
	else
		self.Middle:SetHeight(height);
		local v = height / info.height;
		self.Middle:SetTexCoord(0, 1, 0, v);
	end
end