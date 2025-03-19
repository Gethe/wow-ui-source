ClassNameplateBarDeathKnight = Mixin({}, RuneFrameMixin);

function ClassNameplateBarDeathKnight:OnLoad()
	RuneFrameMixin.OnLoad(self);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarDeathKnight:OnEvent(event, ...)
	RuneFrameMixin.OnEvent(self, event, ...);

	return ClassNameplateBar.OnEvent(self, event, ...);
end