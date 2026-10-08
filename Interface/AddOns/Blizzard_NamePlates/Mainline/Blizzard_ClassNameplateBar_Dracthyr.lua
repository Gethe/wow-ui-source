--------------------------------------------------------------------------------
--
-- ClassNameplateBarDracthyr
--
--------------------------------------------------------------------------------


ClassNameplateBarDracthyr = { };

function ClassNameplateBarDracthyr:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarDracthyr:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarDracthyr:SetupDracthyr()
	local shouldShowBar = ClassPowerBar.ShouldShowBar(self);
	if shouldShowBar then
		self:ShowNameplateBar();
	else
		self:HideNameplateBar();
	end

	return shouldShowBar;
end

function ClassNameplateBarDracthyr:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarDracthyr:UpdatePower()
	EssencePowerBar.UpdatePower(self);
end


--------------------------------------------------------------------------------
--
-- ClassNameplateEbonMightBar
--
--------------------------------------------------------------------------------


ClassNameplateEbonMightBar = {};

function ClassNameplateEbonMightBar:Initialize()
	self.Border:SetVertexColor(0, 0, 0, 1);
	self.Border:SetBorderSizes(nil, nil, 0, 0);
	EvokerEbonMightBarMixin.Initialize(self);
end