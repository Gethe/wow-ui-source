
MainMenuBarEndCapMixin = {};

function MainMenuBarEndCapMixin:OnLoad()
	self.isVisible = true;

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	EventRegistry:RegisterCallback("EditMode.Enter", function()
		self:UpdateVisibility();
	end, self);

	EventRegistry:RegisterCallback("EditMode.Exit", function()
		self:UpdateVisibility();
	end, self);
end

function MainMenuBarEndCapMixin:OnEvent(event, ...)
	-- Wait a frame so the bars have been repositioned for the new size or scale.
	RunNextFrame(GenerateClosure(self.UpdateVisibility, self));
end

function MainMenuBarEndCapMixin:DoesFitOnScreen()
	if not self:IsInDefaultPosition() then
		return true;
	end

	local _, relativeTo, _, offsetX = self:GetPoint(1);
	if not relativeTo then
		return true;
	end

	local anchorLeft, _, anchorWidth = relativeTo:GetScaledRect();
	if not anchorLeft then
		return true;
	end

	local scale = self:GetEffectiveScale();
	local leftInset, rightInset = self:GetClampRectInsets();
	if self.systemIndex == Enum.EditModeMainActionBarEndCapSystemIndices.EndCapLeft then
		local capRight = anchorLeft + offsetX * scale;
		return capRight - (self:GetWidth() - leftInset) * scale >= 0;
	end

	local capLeft = anchorLeft + anchorWidth + offsetX * scale;
	local screenWidth = GetScreenWidth() * UIParent:GetEffectiveScale();
	return capLeft + (self:GetWidth() + rightInset) * scale <= screenWidth;
end

function MainMenuBarEndCapMixin:UpdateVisibility()
	self:SetShown(EditModeManagerFrame:IsEditModeActive() or (self.isVisible and self:DoesFitOnScreen()));
end

function MainMenuBarEndCapMixin:SetVisibilitySetting(visible)
	self.isVisible = visible;
	self:UpdateVisibility();
end
