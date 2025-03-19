-- Base mixin for alternate power bars attached to the player's nameplate (Personal Resources)
ClassNameplateAlternatePowerBarBaseMixin = CreateFromMixins(AlternatePowerBarBaseMixin);

local DefaultBarArtInfo = {r = 0, g = 0, b = 1};

function ClassNameplateAlternatePowerBarBaseMixin:Initialize()
	self:SetScale(self.scale or 1);

	AlternatePowerBarBaseMixin.Initialize(self);
end

function ClassNameplateAlternatePowerBarBaseMixin:OnShow()
	self:UpdatePower();
	-- Important to update size on showing as nameplates often play a shrinking animation just before being hidden
	self:OnSizeChanged();
end

function ClassNameplateAlternatePowerBarBaseMixin:AttachBarToUnitUI()
	self:Show();
	NamePlateDriverFrame:SetClassNameplateAlternatePowerBar(self);
end

function ClassNameplateAlternatePowerBarBaseMixin:RemoveBarFromUnitUI()
	if NamePlateDriverFrame:GetClassNameplateAlternatePowerBar() == self then
		NamePlateDriverFrame:SetClassNameplateAlternatePowerBar(nil);
	end
end

function ClassNameplateAlternatePowerBarBaseMixin:UpdateArt()
	local info = self.overrideArtInfo or PowerBarColor[self.powerName];
	if not info or not info.r then
		info = DefaultBarArtInfo;
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function ClassNameplateAlternatePowerBarBaseMixin:OnOptionsUpdated()
	self:OnSizeChanged();
end

function ClassNameplateAlternatePowerBarBaseMixin:OnSizeChanged()
	PixelUtil.SetHeight(self, DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight);
	self.Border:UpdateSizes();
end