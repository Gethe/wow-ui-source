local Shared = require(".Shared");

---------------------------------------------------------------------------------------------------

local function SetUpDefaultActionButton(actionButton)
	actionButton:SetAttribute("action", 0);
	actionButton:SetID(0);
	actionButton:UpdateAction();
	actionButton:RegisterForClicks("AnyUp", "AnyDown");

	-- These buttons will never contain actual actions, so unregister them to prevent native events
	-- from overriding state.
	C_ActionBar.UnregisterActionUIButton(actionButton);

	-- Not sure why we only need this for some icons but not others...
	actionButton.SpecialActionIcon:SetDrawLayer("BACKGROUND", 1);

	-- The gamepad action bar button has special behavior to be able to properly handle flyouts,
	-- but that interferes with these buttons which aren't technically actions, but still use the
	-- action button template. Since we can't have flyouts or other actions on these buttons, we
	-- can replace this function with a dummy.
	actionButton.SetActionAttributes = nop;

	-- Most actions on these bars need an icon overlay
	actionButton.IconOverlay = actionButton:CreateTexture();
	actionButton.IconOverlay:SetAllPoints(actionButton.SpecialActionIcon);
	actionButton.IconOverlay:SetDrawLayer("BACKGROUND", 2);

	for i = 1, actionButton.SpecialActionIcon:GetNumMaskTextures() do
		local maskTexture = actionButton.SpecialActionIcon:GetMaskTexture(i);
		actionButton.IconOverlay:AddMaskTexture(maskTexture);
	end
end

local function MoveIconToNewBar(icon, newBar)
	local point, _, relativePoint, offsetX, offsetY = icon:GetPoint();
	icon:ClearAllPoints();
	icon:SetPoint(point, newBar, relativePoint, offsetX, offsetY);
	icon:SetParent(newBar);
end

---------------------------------------------------------------------------------------------------

-- This doesn't inherit GamepadOverrideBarMixin despite being for a set of override bars since
-- almost everything that mixin provides is to override one specific bar on a specific page, based
-- on the setting of a cvar. The target actions bars instead need to always override the top bar on
-- every page.
local StaticOverrideActionBarMixin = CreateFromMixins(GamepadActionBarMixin);

function StaticOverrideActionBarMixin:OnLoad()
	GamepadActionBarMixin.OnLoad(self);

	if self.swapLeftAndRightCvar then
		CVarCallbackRegistry:SetCVarCachable(self.swapLeftAndRightCvar);
		CVarCallbackRegistry:RegisterCallback(self.swapLeftAndRightCvar, self.SetUpActionButtons, self);
	end

	for _, actionButton in ipairs(self.actionButtons) do
		SetUpDefaultActionButton(actionButton);
	end

	-- Ignore dpad/face swapping here; it will be sorted after variables have been loaded. Also
	-- note that these names remain the same even if dpad/face buttons are being swapped.
	-- `dpadLeftButton` refers to the action button that is _normally_ on the dpad left. If
	-- dpad/face buttons are swapped, it instead refers to the left face button. It follows the
	-- action, not the input.
	self.dpadLeftButton = self.Left.ActionButton1;
	self.dpadTopButton = self.Left.ActionButton2;
	self.dpadRightButton = self.Left.ActionButton3;
	self.dpadBottomButton = self.Left.ActionButton4;
	self.faceLeftButton = self.Right.ActionButton1;
	self.faceTopButton = self.Right.ActionButton2;
	self.faceRightButton = self.Right.ActionButton3;
	self.faceBottomButton = self.Right.ActionButton4;

	self.dpadButtons = {
		self.dpadLeftButton,
		self.dpadTopButton,
		self.dpadRightButton,
		self.dpadBottomButton,
	};

	self.faceButtons = {
		self.faceLeftButton,
		self.faceTopButton,
		self.faceRightButton,
		self.faceBottomButton,
	};

	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.PostVariableSetUp, self));
end

function StaticOverrideActionBarMixin:PostVariableSetUp()
	self:SetUpActionButtons();
end

function StaticOverrideActionBarMixin:ShouldSwapLeftAndRightButtons()
	return self.swapLeftAndRightCvar and CVarCallbackRegistry:GetCVarValueBool(self.swapLeftAndRightCvar);
end

function StaticOverrideActionBarMixin:SetUpActionButtons()
	local leftParent = self.Left;
	local rightParent = self.Right;

	if self:ShouldSwapLeftAndRightButtons() then
		leftParent, rightParent = rightParent, leftParent;
	end

	self:ResetDpadLeft();
	self:ResetDpadTop();
	self:ResetDpadRight();
	self:ResetDpadBottom();
	self:ResetFaceLeft();
	self:ResetFaceTop();
	self:ResetFaceRight();
	self:ResetFaceBottom();

	-- Common resets that we want for every button, to avoid repetition
	for _, actionButton in ipairs(self.actionButtons) do
		self:SetButtonEnabled(actionButton, true);
		actionButton:SetScript("OnClick", SecureActionButton_OnClick);
		actionButton.SpecialActionIcon:Hide();
		actionButton.IconOverlay:Hide();
	end

	self.dpadLeftButton = leftParent.ActionButton1;
	self.dpadTopButton = leftParent.ActionButton2;
	self.dpadRightButton = leftParent.ActionButton3;
	self.dpadBottomButton = leftParent.ActionButton4;
	self.faceLeftButton = rightParent.ActionButton1;
	self.faceTopButton = rightParent.ActionButton2;
	self.faceRightButton = rightParent.ActionButton3;
	self.faceBottomButton = rightParent.ActionButton4;

	self:SetUpDpadLeft();
	self:SetUpDpadTop();
	self:SetUpDpadRight();
	self:SetUpDpadBottom();
	self:SetUpFaceLeft();
	self:SetUpFaceTop();
	self:SetUpFaceRight();
	self:SetUpFaceBottom();
end

function StaticOverrideActionBarMixin:SetButtonEnabled(actionButton, isEnabled)
	actionButton:SetEnabled(isEnabled);
	actionButton:SetAlpha(isEnabled and 1 or Shared.INACTIVE_BAR_FADE_OPACITY);
end

function StaticOverrideActionBarMixin:ResetDpadLeft() end
function StaticOverrideActionBarMixin:ResetDpadTop() end
function StaticOverrideActionBarMixin:ResetDpadRight() end
function StaticOverrideActionBarMixin:ResetDpadBottom() end
function StaticOverrideActionBarMixin:ResetFaceLeft() end
function StaticOverrideActionBarMixin:ResetFaceTop() end
function StaticOverrideActionBarMixin:ResetFaceRight() end
function StaticOverrideActionBarMixin:ResetFaceBottom() end

function StaticOverrideActionBarMixin:SetUpDpadLeft() self:SetButtonEnabled(self.dpadLeftButton, false); end
function StaticOverrideActionBarMixin:SetUpDpadTop() self:SetButtonEnabled(self.dpadTopButton, false); end
function StaticOverrideActionBarMixin:SetUpDpadRight() self:SetButtonEnabled(self.dpadRightButton, false); end
function StaticOverrideActionBarMixin:SetUpDpadBottom() self:SetButtonEnabled(self.dpadBottomButton, false); end
function StaticOverrideActionBarMixin:SetUpFaceLeft() self:SetButtonEnabled(self.faceLeftButton, false); end
function StaticOverrideActionBarMixin:SetUpFaceTop() self:SetButtonEnabled(self.faceTopButton, false); end
function StaticOverrideActionBarMixin:SetUpFaceRight() self:SetButtonEnabled(self.faceRightButton, false); end
function StaticOverrideActionBarMixin:SetUpFaceBottom() self:SetButtonEnabled(self.faceBottomButton, false); end

function StaticOverrideActionBarMixin:RefreshActionBarVisibility()
	if self.isOverrideBarActive then
		GamepadActionBarMixin.RefreshActionBarVisibility(self);
	else
		self:Hide();
	end
end

function StaticOverrideActionBarMixin:IsBarActivelyOverridingActionBar(actionBar)
	return self ~= actionBar and self.isOverrideBarActive and actionBar:GetParent() == self:GetParent();
end

function StaticOverrideActionBarMixin:PageChangeHandler(oldPageNum)
	-- These bars always override the top bar on all pages, so we don't need to do anything on page change
end

function StaticOverrideActionBarMixin:ActivateOverrideBar()
	if self.isOverrideBarActive then
		return;
	end

	self.isOverrideBarActive = true;

	-- We may have to override multiple bars, as the bar in that location may have already been
	-- overridden, in which case we also want to override the override bar.
	local actionBarToOverride = self:GetParent().Bar;
	actionBarToOverride:Hide();

	for _, overrideBar in ipairs(self.pagingUnitOwner.overrideBars) do
		if overrideBar ~= self and overrideBar:IsBarActivelyOverridingActionBar(actionBarToOverride) then
			overrideBar:Hide();
		end
	end

	self:Show();
	self.pagingUnitOwner:ActionBarModKeyDownStateCheck();
	self.pagingUnitOwner.targetingBarsSharedState:FadeOutInactiveBars();

	if actionBarToOverride.modifierIcon then
		MoveIconToNewBar(actionBarToOverride.modifierIcon, self);
	end
end

function StaticOverrideActionBarMixin:DeactivateOverrideBar()
	if not self.isOverrideBarActive then
		return;
	end

	self.isOverrideBarActive = false;

	self:Hide();
	self.pagingUnitOwner:ActionBarModKeyDownStateCheck();
	self.pagingUnitOwner.targetingBarsSharedState:RestoreInactiveBars();

	local actionBarToRestore = self:GetParent().Bar;
	local restoredBar;

	for _, overrideBar in ipairs(self.pagingUnitOwner.overrideBars) do
		if overrideBar ~= self and overrideBar:IsBarActivelyOverridingActionBar(actionBarToRestore) then
			overrideBar:Show();
			restoredBar = overrideBar;
			break;
		end
	end

	if not restoredBar then
		actionBarToRestore:Show();
		restoredBar = actionBarToRestore;
	end

	if actionBarToRestore.modifierIcon then
		MoveIconToNewBar(actionBarToRestore.modifierIcon, restoredBar);
	end
end

function StaticOverrideActionBarMixin:ActivateOrDeactivateOverrideBar(activate)
	if activate then
		self:ActivateOverrideBar();
	else
		self:DeactivateOverrideBar();
	end
end

return StaticOverrideActionBarMixin;
