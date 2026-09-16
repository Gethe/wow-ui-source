ClassNameplateBarFeralDruid = {};

function ClassNameplateBarFeralDruid:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarFeralDruid:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarFeralDruid:ShouldShowBar()
	local shouldShowBar = DruidComboPointBarMixin.ShouldShowBar(self);
	if shouldShowBar then
		self:ShowNameplateBar();
	else
		self:HideNameplateBar();
	end
	return shouldShowBar;
end

function ClassNameplateBarFeralDruid:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarFeralDruid:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarFeralDruid:UpdatePower()
	DruidComboPointBarMixin.UpdatePower(self);
end