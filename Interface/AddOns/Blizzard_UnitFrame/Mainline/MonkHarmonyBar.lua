local DefaulChiSpacing = 3; -- Default spacing between chi orbs
local TightChiSpacing = 2;	-- Spacing between chi orbs when num orb threshold is reached
local TightChiSpacingThreshold = 6;	-- Threshold of chi orb counts to start using tight spacing

MonkPowerBar = {};

function MonkPowerBar:UpdatePower()
	local numChi = UnitPower(self:GetUnit(), Enum.PowerType.Chi);
	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= numChi);
	end
end

function MonkPowerBar:UpdateMaxPower()
	local maxPoints = UnitPowerMax(self:GetUnit(), self.powerType);
	if maxPoints >= TightChiSpacingThreshold then
		self.spacing = TightChiSpacing;
	else
		self.spacing = DefaulChiSpacing;
	end
	ClassResourceBarMixin.UpdateMaxPower(self);
end


MonkLightEnergyMixin = {};

function MonkLightEnergyMixin:Setup()
	self.active = nil;
	self:ResetVisuals();
	self:Show();
end

function MonkLightEnergyMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	Pool_HideAndClearAnchors(framePool, self);
end

function MonkLightEnergyMixin:SetActive(active)
	if self.active == active then
		return;
	end

	self.active = active;

	self:ResetVisuals();

	if self.active then
		self.FB_Wind_FX:SetAlpha(1);
		self.activate:Restart();
	else
		self.Chi_BG:SetAlpha(1);
		self.deactivate:Restart();
	end
end

function MonkLightEnergyMixin:ResetVisuals()
	self.activate:Stop();
	self.deactivate:Stop();

	self.Chi_Icon:SetAlpha(0);
	self.Chi_Icon:SetAlpha(0);
	self.Chi_BG_Active:SetAlpha(0);

	if self.fxTextures then
		for _, fxTexture in ipairs(self.fxTextures) do
			fxTexture:SetAlpha(0);
		end
	end
end