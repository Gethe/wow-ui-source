--------------------------------------------------------------------------------
--
-- ClassNameplateBarWindwalkerMonk
--
--------------------------------------------------------------------------------


ClassNameplateBarWindwalkerMonk = {};

function ClassNameplateBarWindwalkerMonk:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarWindwalkerMonk:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarWindwalkerMonk:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarWindwalkerMonk:UpdateMaxPower()
	MonkPowerBar.UpdateMaxPower(self);
end

function ClassNameplateBarWindwalkerMonk:UpdatePower()
	MonkPowerBar.UpdatePower(self);
end


--------------------------------------------------------------------------------
--
-- ClassNameplateBarBrewmasterMonk
--
--------------------------------------------------------------------------------

ClassNameplateBarBrewmasterMonk = {};

function ClassNameplateBarBrewmasterMonk:OnLoad()
	self.class = "MONK";
	self.spec = SPEC_MONK_BREWMASTER;
	self.powerToken = "STAGGER";
	self.overrideTargetMode = false;
	self.paddingOverride = 0;
	self.currValue = 0;
	self.Border:SetVertexColor(0, 0, 0, 1);
	self.Border:SetBorderSizes(nil, nil, 0, 0);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarBrewmasterMonk:UpdateMaxPower()
	local maxhealth = UnitHealthMax("player");
	self:SetMinMaxValues(0, maxhealth);
end

function ClassNameplateBarBrewmasterMonk:OnUpdate()
	self:UpdatePower();
end

function ClassNameplateBarBrewmasterMonk:UpdatePower()
	local currstagger = UnitStagger("player");
	if (not currstagger) then
		return;
	end
	self:SetValue(currstagger);
	self.value = currstagger;
	self:UpdateMaxPower();

	local _, maxstagger = self:GetMinMaxValues();
	local percent = currstagger/maxstagger;
	local info = PowerBarColor[BREWMASTER_POWER_BAR_NAME];

	if (percent > STAGGER_YELLOW_TRANSITION and percent < STAGGER_RED_TRANSITION) then
		info = info[STAGGER_YELLOW_INDEX];
	elseif (percent > STAGGER_RED_TRANSITION) then
		info = info[STAGGER_RED_INDEX];
	else
		info = info[STAGGER_GREEN_INDEX];
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function ClassNameplateBarBrewmasterMonk:OnOptionsUpdated()
	self:OnSizeChanged();
end

function ClassNameplateBarBrewmasterMonk:OnSizeChanged() -- override
	PixelUtil.SetHeight(self, DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight);
	self.Border:UpdateSizes();
end