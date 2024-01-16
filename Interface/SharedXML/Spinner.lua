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

	Import("C_Texture");

	setfenv(1, tbl);
end
----------------

SpinnerMixin = {};

function SpinnerMixin:OnShow()
    self.Anim:Restart();
end

function SpinnerMixin:OnHide()
    self.Anim:Stop();
end

function SpinnerMixin:SetDesaturated(desaturated)
    self.Ring:SetDesaturated(desaturated);
    self.Sparks:SetDesaturated(desaturated);
end


SpinnerWithShadowMixin = {};

function SpinnerWithShadowMixin:SpinnerWithShadow_OnShow()
	self.Shadow:SetAlpha(self.shadowAlpha);
	self:UpdateShadowSize();
	self:SetScript("OnSizeChanged", self.OnSizeChanged);
end

function SpinnerWithShadowMixin:SpinnerWithShadow_OnHide()
	self:SetScript("OnSizeChanged", nil);
end

function SpinnerWithShadowMixin:OnSizeChanged()
	self:UpdateShadowSize();
end

function SpinnerWithShadowMixin:UpdateShadowSize()
	if not self.shadowSizeScalar then
		local ringAtlas = self.Ring:GetAtlas();
		local shadowAtlas = self.Shadow:GetAtlas();
		local ringAtlasInfo = C_Texture.GetAtlasInfo(ringAtlas);
		local shadowAtlasInfo = C_Texture.GetAtlasInfo(shadowAtlas);
		self.shadowSizeScalar = shadowAtlasInfo.width / ringAtlasInfo.width;
	end

	local width, height  = self:GetSize();
	self.Shadow:SetSize(width * self.shadowSizeScalar, height * self.shadowSizeScalar);
end

function SpinnerWithShadowMixin:SetDesaturated(desaturated)
	SpinnerMixin.SetDesaturated(self, desaturated);
	self.Shadow:SetDesaturated(desaturated);
end
