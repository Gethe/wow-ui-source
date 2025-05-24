CharacterSelectListMoveButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function CharacterSelectListMoveButtonMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Arrow);
end

-- Make sure to reset the state of things when the buttons are hidden.  Fixes cases where you are pressed,
-- but move the mouse off the character, which hides the arrow buttons and could  persist the wrong state.
function CharacterSelectListMoveButtonMixin:OnHide()
	ButtonStateBehaviorMixin.OnDisable(self);
end

function CharacterSelectListMoveButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	if self:IsEnabled() then
		self.Highlight:Show();
	end
end

function CharacterSelectListMoveButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	if self:IsEnabled() then
		self.Highlight:Hide();
	end

	-- Ensure the parent state resets if needed (if mouse moved quickly off of this button AND the parent)
	local isSelected = true;
	self:GetParent():OnLeave(isSelected);
end

function CharacterSelectListMoveButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():GetParent():MoveCharacter(self.moveOffset);
end

function CharacterSelectListMoveButtonMixin:OnButtonStateChanged()
	local atlas;
	if self:IsDown() then
		atlas = self.arrowPressed;
	elseif self:IsOver() then
		atlas = self.arrowHighlight;
	else
		atlas = self.arrowNormal;
	end

	self.Arrow:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

function CharacterSelectListMoveButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);
	self.Arrow:SetShown(enabled);
end