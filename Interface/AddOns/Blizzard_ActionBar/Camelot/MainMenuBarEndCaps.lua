
MainMenuBarEndCapMixin = {};

function MainMenuBarEndCapMixin:OnLoad()
	self.isVisible = true;

	EventRegistry:RegisterCallback("EditMode.Enter", function()
		self:UpdateVisibility();
	end, self);

	EventRegistry:RegisterCallback("EditMode.Exit", function()
		self:UpdateVisibility();
	end, self);
end

function MainMenuBarEndCapMixin:UpdateVisibility()
	self:SetShown(self.isVisible or EditModeManagerFrame:IsEditModeActive());
end

function MainMenuBarEndCapMixin:SetVisibilitySetting(visible)
	self.isVisible = visible;
	self:UpdateVisibility();
end
