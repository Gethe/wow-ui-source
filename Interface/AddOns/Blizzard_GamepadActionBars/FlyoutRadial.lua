local RADIAN_FULL_CIRCLE = 2 * math.pi;
local RADIAN_HALF_CIRCLE = RADIAN_FULL_CIRCLE * 0.5;
local RADIAN_QUARTER_CIRCLE = RADIAN_FULL_CIRCLE * 0.25;
local RADIAN_HALF_QUARTER_CIRCLE = RADIAN_QUARTER_CIRCLE * 0.5;
local SEGMENT_COUNT = 8;
local RADIAN_SEGMENT_SIZE = RADIAN_FULL_CIRCLE / SEGMENT_COUNT;
local TRIGGER_SENSITIVITY = 0.5;

local CIRCLE_STYLE_PROPERTIES = {
	backgroundAtlas = "gamepad-flyout-circular-base",
	backdropAtlas = "gamepad-flyout-circular-slot-backdrop",
	cooldownSwipeTexture = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
	disabledAtlas = "gamepad-flyout-circular-slot-disabled",
	downAtlas = "gamepad-flyout-circular-slot-down",
	downMaskAtlas = "gamepad-flyout-circular-slot-down-mask",
	maskAtlas = "gamepad-flyout-circular-slot-mask",
	normalAtlas = "gamepad-flyout-circular-slot-normal",
	overAtlas = "gamepad-flyout-circular-slot-over",
	overOverlayAtlas = "gamepad-flyout-circular-slot-over-border",
	selectedAtlas = "gamepad-flyout-circular-slot-selected",
	selectedOverlayAtlas = "gamepad-flyout-circular-slot-highlight",
	autoCastCornersAtlas = "gamepad-actionbar-circleslot-petautocastcorners",
	autoCastMaskAtlas = "gamepad-actionbar-circleslot-petautocast-mask",
	autoCastCornersOffset = 1,
	iconSize = 36,
	pushedIconOffset = -2,
	pushedIconSize = 33,
	offsetRadius = 60,
	cardinalArrowOffset = 38,
	diagonalArrowOffset = 38,
};

local SQUARE_STYLE_PROPERTIES = {
	backgroundAtlas = "gamepad-flyout-square-base",
	backdropAtlas = "gamepad-flyout-square-slot-backdrop",
	disabledAtlas = "gamepad-flyout-square-slot-disabled",
	downAtlas = "gamepad-flyout-square-slot-down",
	downMaskAtlas = "gamepad-flyout-square-slot-down-mask",
	maskAtlas = "gamepad-flyout-square-slot-mask",
	normalAtlas = "gamepad-flyout-square-slot-normal",
	overAtlas = "gamepad-flyout-square-slot-over",
	overOverlayAtlas = "gamepad-flyout-square-slot-over-border",
	selectedAtlas = "gamepad-flyout-square-slot-selected",
	selectedOverlayAtlas = "gamepad-flyout-square-slot-highlight",
	autoCastCornersAtlas = "gamepad-actionbar-squareslot-petautocastcorners",
	autoCastMaskAtlas = "gamepad-actionbar-squareslot-petautocast-mask",
	autoCastCornersOffset = 2,
	iconSize = 36,
	pushedIconOffset = -2,
	pushedIconSize = 33,
	offsetRadius = 60,
	cardinalArrowOffset = 40,
	diagonalArrowOffset = 36,
};

--------------------------------------------------------------------------------
-- GamepadFlyoutPopupButtonMixin
--------------------------------------------------------------------------------

GamepadFlyoutPopupButtonMixin = {};

-- Overrides BaseActionButtonMixin:UpdateButtonArt
function GamepadFlyoutPopupButtonMixin:UpdateButtonArt()
	-- The style may not have been determined yet at the point this is first called
	if not self.style then
		return;
	end

	local textures = {
		{ self.icon, nil, "BORDER" },
		{ self.CheckedTexture, self.style.selectedAtlas, "BACKGROUND" },
		{ self.CheckedOverlayTexture, self.style.selectedOverlayAtlas, nil },
		{ self.DisabledTexture, self.style.disabledAtlas, "BACKGROUND" },
		{ self.IconMask, self.style.maskAtlas, nil },
		{ self.HighlightTexture, self.style.overOverlayAtlas, "ARTWORK" },
		{ self.NormalTexture, self.style.normalAtlas, "BACKGROUND" },
		{ self.PushedTexture, self.style.downAtlas, "BACKGROUND" },
		{ self.AutoCastOverlay.Corners, self.style.autoCastCornersAtlas, nil },
		{ self.AutoCastOverlay.Mask, self.style.autoCastMaskAtlas, nil },
	};

	for _, texture in ipairs(textures) do
		local frame, atlas, layer = unpack(texture);
		frame:ClearAllPoints();
		frame:SetPoint("CENTER");

		if atlas then
			frame:SetAtlas(atlas, true);
		end

		if layer then
			frame:SetDrawLayer(layer);
		end
	end

	self.cooldown:SetSwipeTexture(self.style.cooldownSwipeTexture);
	self.icon:SetSize(self.style.iconSize, self.style.iconSize);

	local cornersOffset = self.style.autoCastCornersOffset;
	local maskOffset = -2;
	self.AutoCastOverlay:SetAllPoints();
	self.AutoCastOverlay.Corners:ClearAllPoints();
	self.AutoCastOverlay.Corners:SetPoint("TOPLEFT", cornersOffset, -cornersOffset);
	self.AutoCastOverlay.Corners:SetPoint("BOTTOMRIGHT", -cornersOffset, cornersOffset);
	self.AutoCastOverlay.Mask:ClearAllPoints();
	self.AutoCastOverlay.Mask:SetPoint("TOPLEFT", maskOffset, -maskOffset);
	self.AutoCastOverlay.Mask:SetPoint("BOTTOMRIGHT", -maskOffset, maskOffset);
	self.AutoCastOverlay.Shine:SetAllPoints();

	self:UpdateState();

	-- Unused textures
	self.SlotArt:Hide();
	self.SlotBackground:Hide();
end

function GamepadFlyoutPopupButtonMixin:OnEnter()
	self.isMouseOver = true;
	self:UpdateMouseState();
end

function GamepadFlyoutPopupButtonMixin:OnLeave()
	-- Once the mouse has left the element, it is no longer considered pushed with our native
	-- button behavior, so match that here.
	self.isMouseDown = false;
	self.isMouseOver = false;
	self:UpdateMouseState();
end

function GamepadFlyoutPopupButtonMixin:OnMouseDown(button)
	if button == "LeftButton" then
		self.isMouseDown = true;
		self:UpdateMouseState();
	end
end

function GamepadFlyoutPopupButtonMixin:OnMouseUp(button)
	if button == "LeftButton" then
		self.isMouseDown = false;
		self:UpdateMouseState();
	end
end

function GamepadFlyoutPopupButtonMixin:UpdateMouseState()
	-- Hiding/showing HighlightTexture manually instead of using the HIGHLIGHT layer since the
	-- HIGHLIGHT layer is the highest, and the selection arrow should appear on top of it
	if self.isMouseOver and self.isMouseDown then
		self.HighlightTexture:Hide();
		self.IconMask:SetAtlas(self.style.downMaskAtlas, true);
		self.icon:SetPoint("CENTER", 0, self.style.pushedIconOffset);
	else
		self.HighlightTexture:SetShown(self.isSelected or self.isMouseOver);
		self.IconMask:SetAtlas(self.style.maskAtlas, true);
		self.icon:SetPoint("CENTER");
	end
end

function GamepadFlyoutPopupButtonMixin:GetStateTexture()
	local state = self:GetButtonState();

	if state == "NORMAL" then
		return self.NormalTexture;
	elseif state == "PUSHED" then
		return self.PushedTexture;
	elseif state == "DISABLED" then
		return self.DisabledTexture;
	end
end

-- Overrides ActionBarActionButtonMixin:UpdateState
function GamepadFlyoutPopupButtonMixin:UpdateState()
	local isChecked = self.spellID and C_Spell.IsActiveSpell(self.spellID);
	self:SetChecked(isChecked);
	self.CheckedOverlayTexture:SetShown(isChecked);
end

function GamepadFlyoutPopupButtonMixin:HandleClick()
	if self.spellID and C_Spell.IsActiveSpell(self.spellID) then
		C_Spell.CancelSpellByID(self.spellID);
		return true;
	end

	return false;
end

-- Overrides SpellFlyoutPopupButtonMixin:OnClick
function GamepadFlyoutPopupButtonMixin:OnClick()
	if not self:HandleClick() then
		FlyoutPopupButtonMixin.OnClick(self);
	end
end

--------------------------------------------------------------------------------
-- GamepadFlyoutMixin
--------------------------------------------------------------------------------

GamepadFlyoutMixin = CreateFromMixins(LayoutMixin, FlyoutPopupMixin);

-- Overrides FlyoutPopupMixin:AttachToButton
function GamepadFlyoutMixin:AttachToButton(button)
	-- Changing parent resets frame strata to that of the parent...
	local prevFrameStrata = self:GetFrameStrata();
	local prevFrameLevel = self:GetFrameLevel();

	FlyoutPopupMixin.AttachToButton(self, button);

	button.Arrow:Hide();

	-- Normally the flyout gets the button as parent, but we inverse that so the button can be
	-- displayed on top of the flyout background.
	self.prevButtonParent = button:GetParent();
	self:SetParent(UIParent);
	self:SetFrameStrata(prevFrameStrata);
	self:SetFrameLevel(prevFrameLevel);

	button:SetParent(self);

	self.SelectionArrow:Hide();
	self.SelectionIndicator:Hide();
end

-- Overrides FlyoutPopupMixin:DetachFromButton
function GamepadFlyoutMixin:DetatchFromButton()
	self.flyoutButton.Arrow:Show();
	self.flyoutButton:SetParent(self.prevButtonParent);

	FlyoutPopupMixin.DetatchFromButton(self);
end

function GamepadFlyoutMixin:OnLoad()
	self.bindings = GamepadMode.CreateBindingGroup("GamepadFlyoutPopupBindings");
	self.bindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.UpdateSelection, self));
	self.bindings:TreatAsCore();
end

function GamepadFlyoutMixin:OnShow()
	GamepadMode.ActivateBindingGroup(self.bindings);

	self:SetScript("OnGamePadButtonDown", self.OnGamePadButtonDown);
end

function GamepadFlyoutMixin:OnHide()
	self:SetScript("OnGamePadButtonDown", nil);

	GamepadMode.DeactivateBindingGroup(self.bindings);

	if self.selection then
		self:SetSelection(nil);
	end
end

function GamepadFlyoutMixin:OnGamePadButtonDown(gamepadKey)
	if self:IsShown() then
		-- Defer this until next frame. Since we indiscriminately close this on any button press
		-- but still let any bound actions for that press go through, pressing the flyout button
		-- again would cause this to close the popup only for it to immediately open again as the
		-- flyout action is re-triggered. By deferring it, the flyout action will instead close
		-- the flyout and this call will no-op.
		local flyoutButton = self.flyoutButton;
		RunNextFrame(function()
			-- Only do it if the flyout button didn't change, so the player can press another
			-- flyout to open it without having it immediately close.
			if self.flyoutButton == flyoutButton then
				self:Close();
			end
		end);
	end

	local propagateInput = true;
	return propagateInput;
end

local function GetSegmentOffset(radius, segmentIndex)
	local angle = RADIAN_HALF_QUARTER_CIRCLE * (segmentIndex - 1);
	local x = math.floor(radius * math.sin(angle) + 0.5);
	local y = math.floor(radius * math.cos(angle) + 0.5);
	return x, y;
end

function GamepadFlyoutMixin:UpdateLayout(flyoutButton)
	self.style = flyoutButton.activeButtonShape == "Square"
		and SQUARE_STYLE_PROPERTIES
		or CIRCLE_STYLE_PROPERTIES;

	for i, backdrop in ipairs(self.SlotBackdrops) do
		local offsetX, offsetY = GetSegmentOffset(self.style.offsetRadius, i);
		backdrop:ClearAllPoints();
		backdrop:SetPoint("CENTER", offsetX, offsetY);
		backdrop:SetAtlas(self.style.backdropAtlas, true);
	end

	for _, button in ipairs(self.buttons) do
		button.style = self.style;
		button:UpdateButtonArt();
		button:UpdateMouseState();
	end

	self:SetFrameStrata("DIALOG");
	self:UpdateBackground();
	self:Layout();

	-- The selection indicator should not be wider than any of the buttons
	local buttonWidth = flyoutButton:GetWidth();
	local indicatorWidth = math.min(buttonWidth, self.style.iconSize);
	self.SelectionIndicator:SetWidth(indicatorWidth);
end

-- Overrides FlyoutPopupMixin:UpdatePosition
function GamepadFlyoutMixin:UpdatePosition()
	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 0);
end

-- Overrides FlyoutPopupMixin:UpdateBackground
function GamepadFlyoutMixin:UpdateBackground()
	self.Background:SetAtlas(self.style.backgroundAtlas, true);
end

function GamepadFlyoutMixin:UpdateSelection(inX, inY)
	local magnitudeSq = (inX * inX) + (inY * inY);
	local deadzoneSq = TRIGGER_SENSITIVITY * TRIGGER_SENSITIVITY;

	if magnitudeSq < deadzoneSq then
		if self.selection then
			self.selection:Click();
			self:SetSelection(nil);
			self:Close();
		else
			self.SelectionIndicator:Hide();
		end
		return;
	end

	-- Switching X and Y effectively rotates the cicle to have 0 up.
	local angleRadians = math.atan2(inX, inY);

	-- Buttons have their center at the angle their layout index indicates, which means the actual
	-- button starts half a segment earlier. So the button at layoutIndex 1 should start at a
	-- negative angle.
	local halfSegmentSize = RADIAN_SEGMENT_SIZE * 0.5;
	local angle = (angleRadians + halfSegmentSize) % RADIAN_FULL_CIRCLE;
	local segmentIndex = math.floor(angle / RADIAN_SEGMENT_SIZE) + 1;
	local newSelection = nil;

	for _, button in ipairs(self.buttons) do
		if button.layoutIndex == segmentIndex then
			newSelection = button;
			break;
		end
	end

	self.SelectionIndicator:Show();
	self:UpdateSelectionIndicators(segmentIndex);
	self:SetSelection(newSelection);
end

function GamepadFlyoutMixin:UpdateSelectionIndicators(segmentIndex)
	local isCardinal = bit.band(segmentIndex, 1) == 1;
	local offset = isCardinal and self.style.cardinalArrowOffset or self.style.diagonalArrowOffset;
	local angle = RADIAN_HALF_QUARTER_CIRCLE * (segmentIndex - 1);
	local arrowX, arrowY = GetSegmentOffset(offset, segmentIndex);

	self.SelectionArrow:ClearAllPoints();
	self.SelectionArrow:SetPoint("CENTER", self, "CENTER", arrowX, arrowY);
	self.SelectionArrow.Texture:SetRotation(RADIAN_QUARTER_CIRCLE - angle);

	self.SelectionIndicator:SetRotation(RADIAN_HALF_CIRCLE - angle);
end

function GamepadFlyoutMixin:SetSelection(button)
	if self.selection == button then
		return;
	end

	if self.selection then
		self.selection.isSelected = false;
		self.selection:UpdateMouseState();

		if not button then
			GameTooltip:Hide();
			self.SelectionArrow:Hide();
			self.SelectionIndicator:SetDesaturated(true);
		end
	end

	if button then
		if not self.selection then
			GameTooltip:Show();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		end

		button.isSelected = true;
		button:UpdateMouseState();

		if button.SetTooltip then
			button:SetTooltip(GameTooltip);
		else
			GameTooltip:SetSpellByID(button.spellID, false, true);
		end

		self.SelectionArrow:Show();
		self.SelectionIndicator:SetDesaturated(false);
	end

	self.selection = button;
end

-- Called by LayoutMixin
function GamepadFlyoutMixin:LayoutChildren(children)
	if #children == 0 then
		return 0, 0, false;
	end

	local minX, maxX = math.huge, -math.huge;
	local minY, maxY = math.huge, -math.huge;

	for _, backdrop in ipairs(self.SlotBackdrops) do
		backdrop:Show();
	end

	for _, child in ipairs(children) do
		local childWidth, childHeight = self:GetChildSize(child);
		local childOffsetX, childOffsetY = GetSegmentOffset(self.style.offsetRadius, child.layoutIndex);

		minX = math.min(minX, childOffsetX - childWidth * 0.5);
		maxX = math.max(maxX, childOffsetX + childWidth * 0.5);
		minY = math.min(minY, childOffsetY - childHeight * 0.5);
		maxY = math.max(maxY, childOffsetY + childHeight * 0.5);

		child:ClearAllPoints();
		child:SetPoint("CENTER", childOffsetX, childOffsetY);

		local backdrop = self.SlotBackdrops[child.layoutIndex];
		if backdrop then
			backdrop:Hide();
		end
	end

	local childrenWidth = maxX - minX;
	local childrenHeight = maxY - minY;
	local hasExpandableChild = false;

	return childrenWidth, childrenHeight, hasExpandableChild;
end

-- Overrides LayoutMixin:CalculateFrameSize
function GamepadFlyoutMixin:CalculateFrameSize()
	-- Keep the size static
	return self:GetSize();
end
