
SpinnerMixin = {};

function SpinnerMixin:OnShow()
	if self.Shadow then
		self.Shadow:SetAlpha(self:GetShadowAlpha());
		self:UpdateShadowSize();
		self:SetScript("OnSizeChanged", self.OnSizeChanged);
	end

    self.Anim:Restart();
end

function SpinnerMixin:OnHide()
	self:SetScript("OnSizeChanged", nil);
    self.Anim:Stop();
end

function SpinnerMixin:OnSizeChanged()
	self:UpdateShadowSize();
end

function SpinnerMixin:SetDesaturated(desaturated)
    self.Ring:SetDesaturated(desaturated);
    self.Sparks:SetDesaturated(desaturated);

	if self.Shadow then
		self.Shadow:SetDesaturated(desaturated);
	end
end

function SpinnerMixin:GetShadowAlpha()
	return self.shadowAlpha or 0.5;
end

function SpinnerMixin:SetShadowEnabled(enabled)
	if self.shadowEnabled ~= enabled then
		self.shadowEnabled = enabled;

		if enabled and not self.Shadow then
			self.Shadow = self:CreateTexture(nil, "BACKGROUND");
			self.Shadow:SetAtlas("Spinner_Shadow", TextureKitConstants.UseAtlasSize);
			self.Shadow:SetAlpha(self:GetShadowAlpha());
			self.Shadow:SetPoint("CENTER");
		end

		self:UpdateShadowSize();

		if self.Shadow then
			self.Shadow:SetShown(enabled);
		end
	end
end

function SpinnerMixin:UpdateShadowSize()
	if self.Shadow then
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
end

function SpinnerMixin:UpdateTheme(useDarkMode)
	self:SetShadowEnabled(not useDarkMode);
end

SpinnerWithShadowMixin = {};

function SpinnerWithShadowMixin:SpinnerWithShadow_OnLoad()
	self:SetShadowEnabled(true);
end