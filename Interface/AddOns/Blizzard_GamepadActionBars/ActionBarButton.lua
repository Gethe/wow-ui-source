local InputDeviceActionButtonTextureSetMixin = {};

function InputDeviceActionButtonTextureSetMixin:Init()
	self.emptySlotSquareBackgroundTextures = {};
	self.emptySlotCircleBackgroundTextures = {};
end

function InputDeviceActionButtonTextureSetMixin:SetEmptySlotSquareBackgroundTextureByIndex(buttonIndex, emptySlotSquareBackgroundTexture)
	self.emptySlotSquareBackgroundTextures[buttonIndex] = emptySlotSquareBackgroundTexture;
end

function InputDeviceActionButtonTextureSetMixin:SetEmptySlotCircleBackgroundTextureByIndex(buttonIndex, emptySlotCircleBackgroundTexture)
	self.emptySlotCircleBackgroundTextures[buttonIndex] = emptySlotCircleBackgroundTexture;
end

function InputDeviceActionButtonTextureSetMixin:GetEmptySlotSquareBackgroundTextureByIndex(buttonIndex)
	return self.emptySlotSquareBackgroundTextures[buttonIndex];
end

function InputDeviceActionButtonTextureSetMixin:GetEmptySlotCircleBackgroundTextureByIndex(buttonIndex)
	return self.emptySlotCircleBackgroundTextures[buttonIndex];
end

local INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS =
{
	Generic = CreateAndInitFromMixin(InputDeviceActionButtonTextureSetMixin),
	Letters = CreateAndInitFromMixin(InputDeviceActionButtonTextureSetMixin),
	Reverse = CreateAndInitFromMixin(InputDeviceActionButtonTextureSetMixin),
	Shapes = CreateAndInitFromMixin(InputDeviceActionButtonTextureSetMixin)
};

local GAMEPAD_ACTION_BAR_BUTTON_INDICES =
{
	LEFT_QUAD_LEFT = 1,
	LEFT_QUAD_TOP = 2,
	LEFT_QUAD_RIGHT = 3,
	LEFT_QUAD_BOTTOM = 4,
	RIGHT_QUAD_LEFT = 5,
	RIGHT_QUAD_TOP = 6,
	RIGHT_QUAD_RIGHT = 7,
	RIGHT_QUAD_BOTTOM = 8
};

local genericTextureSet = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS.Generic;
genericTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_LEFT, "gamepad-actionbar-squareslot-generic-dpadleft-normal");
genericTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_TOP, "gamepad-actionbar-squareslot-generic-dpadup-normal");
genericTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_RIGHT, "gamepad-actionbar-squareslot-generic-dpadright-normal");
genericTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_BOTTOM, "gamepad-actionbar-squareslot-generic-dpaddown-normal");
genericTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_LEFT, "gamepad-actionbar-circleslot-xbox-x-normal");
genericTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_TOP, "gamepad-actionbar-circleslot-xbox-y-normal");
genericTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_RIGHT, "gamepad-actionbar-circleslot-xbox-b-normal");
genericTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_BOTTOM, "gamepad-actionbar-circleslot-xbox-a-normal");

local lettersTextureSet = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS.Letters;
lettersTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_LEFT, "gamepad-actionbar-squareslot-generic-dpadleft-normal");
lettersTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_TOP, "gamepad-actionbar-squareslot-generic-dpadup-normal");
lettersTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_RIGHT, "gamepad-actionbar-squareslot-generic-dpadright-normal");
lettersTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_BOTTOM, "gamepad-actionbar-squareslot-generic-dpaddown-normal");
lettersTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_LEFT, "gamepad-actionbar-circleslot-xbox-x-normal");
lettersTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_TOP, "gamepad-actionbar-circleslot-xbox-y-normal");
lettersTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_RIGHT, "gamepad-actionbar-circleslot-xbox-b-normal");
lettersTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_BOTTOM, "gamepad-actionbar-circleslot-xbox-a-normal");

local shapesTextureSet = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS.Shapes;
shapesTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_LEFT, "gamepad-actionbar-squareslot-generic-dpadleft-normal");
shapesTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_TOP, "gamepad-actionbar-squareslot-generic-dpadup-normal");
shapesTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_RIGHT, "gamepad-actionbar-squareslot-generic-dpadright-normal");
shapesTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_BOTTOM, "gamepad-actionbar-squareslot-generic-dpaddown-normal");
shapesTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_LEFT, "gamepad-actionbar-circleslot-ps-square-normal");
shapesTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_TOP, "gamepad-actionbar-circleslot-ps-triangle-normal");
shapesTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_RIGHT, "gamepad-actionbar-circleslot-ps-circle-normal");
shapesTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_BOTTOM, "gamepad-actionbar-circleslot-ps-cross-normal");

local reverseTextureSet = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS.Reverse;
reverseTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_LEFT, "gamepad-actionbar-squareslot-generic-dpadleft-normal");
reverseTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_TOP, "gamepad-actionbar-squareslot-generic-dpadup-normal");
reverseTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_RIGHT, "gamepad-actionbar-squareslot-generic-dpadright-normal");
reverseTextureSet:SetEmptySlotSquareBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.LEFT_QUAD_BOTTOM, "gamepad-actionbar-squareslot-generic-dpaddown-normal");
reverseTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_LEFT, "gamepad-actionbar-circleslot-xbox-y-normal");
reverseTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_TOP, "gamepad-actionbar-circleslot-xbox-x-normal");
reverseTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_RIGHT, "gamepad-actionbar-circleslot-xbox-a-normal");
reverseTextureSet:SetEmptySlotCircleBackgroundTextureByIndex(GAMEPAD_ACTION_BAR_BUTTON_INDICES.RIGHT_QUAD_BOTTOM, "gamepad-actionbar-circleslot-xbox-b-normal");

local SHARED_AOE_TARGET_HIGHLIGHT_ATLAS = "gamepad-actionbar-targeting-overlayglow";
local SHARED_CHANNEL_FILL_ATLAS = "gamepad-hud-actionbar-channel-fill";
local SHARED_CHANNEL_COMPLETE_GLOW_ATLAS = "gamepad-hud-actionbar-channel-complete-glow";
local SHARED_CASTING_FILL_ATLAS = "gamepad-hud-actionbar-cast-fill";
local SHARED_CASTING_COMPLETE_GLOW_ATLAS = "gamepad-hud-actionbar-casting-complete-glow";
local SHARED_INTERRUPT_HIGHLIGHT_ATLAS = "gamepad-actionbar-interrupt-overlayglow";
local SHARED_AUTO_CAST_RADIAL_ATLAS = "gamepad-actionbar-petautocast-ants";

local SQUARE_NORMAL_FRAME_ATLAS = "gamepad-actionbar-squareslot-border-normal";
local SQUARE_PUSHED_FRAME_ATLAS = "gamepad-actionbar-squareslot-border-pressed";
local SQUARE_ICON_FRAME_BORDER = "UI-HUD-ActionBar-IconFrame-Border";
local SQUARE_HIGHLIGHT_FRAME_ATLAS = "gamepad-actionbar-squareslot-border-hover";
local SQUARE_CHECKED_TEXTURE_ATLAS = "gamepad-actionbar-squareslot-border-selected";
local SQUARE_SPELL_HIGHLIGHT_ATLAS = "gamepad-actionbar-squareslot-border-hover";
local SQUARE_AOE_TARGET_BASE_ATLAS = "gamepad-actionbar-squareslot-aoetarget";
local SQUARE_AOE_TARGET_MASK_ATLAS = "gamepad-actionbar-squareslot-aoetarget-mask";
local SQUARE_CHANNEL_INNER_GLOW_ATLAS = "gamepad-actionbar-squareslot-channel";
local SQUARE_CASTING_INNER_GLOW_ATLAS = "gamepad-actionbar-squareslot-casting";
local SQUARE_CAST_ANIM_FILL_MASK_ATLAS = "UI-HUD-ActionBar-IconFrame-Mask";
local SQUARE_CAST_END_MASK = "gamepad-actionbar-squareslot-castend-mask";
local SQUARE_INTERRUPT_BASE_ATLAS = "gamepad-actionbar-squareslot-interrupt";
local SQUARE_INTERRUPT_HIGHLIGHT_MASK_ATLAS = "gamepad-actionbar-squareslot-interrupt_mask";
local SQUARE_AUTO_CAST_CORNERS_ATLAS = "gamepad-actionbar-squareslot-petautocastcorners";
local SQUARE_AUTO_CAST_MASK_ATLAS = "gamepad-actionbar-squareslot-petautocast-mask";

local CIRCLE_NORMAL_FRAME_ATLAS = "gamepad-actionbar-circleslot-border-normal";
local CIRCLE_PUSHED_FRAME_ATLAS = "gamepad-actionbar-circleslot-border-pressed";
local CIRCLE_ICON_FRAME_BORDER = "gamepad-actionbar-circleslot-iconframe-border";
local CIRCLE_HIGHLIGHT_FRAME_ATLAS = "gamepad-actionbar-circleslot-border-hover";
local CIRCLE_CHECKED_FRAME_ATLAS = "gamepad-actionbar-circleslot-border-selected";
local CIRCLE_SPELL_HIGHLIGHT_ATLAS = "gamepad-actionbar-circleslot-border-hover";
local CIRCLE_AOE_TARGET_BASE_ATLAS = "gamepad-actionbar-circleslot-aoetarget";
local CIRCLE_AOE_TARGET_MASK_ATLAS = "gamepad-actionbar-circleslot-aoetarget-mask";
local CIRCLE_CHANNEL_INNER_GLOW_ATLAS = "gamepad-actionbar-circleslot-channel";
local CIRCLE_CASTING_INNER_GLOW_ATLAS = "gamepad-actionbar-circleslot-casting";
local CIRCLE_CAST_END_MASK = "gamepad-actionbar-circleslot-castend-mask";
local CIRCLE_INTERRUPT_BASE_ATLAS = "gamepad-actionbar-circleslot-interrupt";
local CIRCLE_INTERRUPT_HIGHLIGHT_MASK_ATLAS = "gamepad-actionbar-circleslot-interrupt-mask";
local CIRCLE_AUTO_CAST_CORNERS_ATLAS = "gamepad-actionbar-circleslot-petautocastcorners";
local CIRCLE_AUTO_CAST_MASK_ATLAS = "gamepad-actionbar-circleslot-petautocast-mask";

local BUTTON_SHAPES =
{
	SQUARE = "Square",
	CIRCLE = "Circle"
};

---------------------------------------------------
-- GamepadActionBarButtonCastingAnimAnchorsMixin --
---------------------------------------------------
local GamepadActionBarButtonCastingAnimDataMixin = { data = {} };

function GamepadActionBarButtonCastingAnimDataMixin:RegisterButtonShape(buttonShapeKey)
	self.data[buttonShapeKey] = { collapsedData = {}, expandedData = {} };
end

function GamepadActionBarButtonCastingAnimDataMixin:SetInnerGlowSizeOffset(buttonShapeKey, isCollapsedData, innerGlowSizeOffset)
	if (isCollapsedData) then
		self.data[buttonShapeKey].collapsedData.innerGlowSizeOffset = innerGlowSizeOffset;
	else
		self.data[buttonShapeKey].expandedData.innerGlowSizeOffset = innerGlowSizeOffset;
	end
end

function GamepadActionBarButtonCastingAnimDataMixin:GetInnerGlowSizeOffset(buttonShapeKey, collapsed)
	if (collapsed) then
		return self.data[buttonShapeKey].collapsedData.innerGlowSizeOffset;
	end

	return self.data[buttonShapeKey].expandedData.innerGlowSizeOffset;
end

function GamepadActionBarButtonCastingAnimDataMixin:SetCastFillSizeOffset(buttonShapeKey, isCollapsedData, castFillSizeOffset)
	if (isCollapsedData) then
		self.data[buttonShapeKey].collapsedData.castFillSizeOffset = castFillSizeOffset;
	else
		self.data[buttonShapeKey].expandedData.castFillSizeOffset = castFillSizeOffset;
	end
end

function GamepadActionBarButtonCastingAnimDataMixin:GetCastFillSizeOffset(buttonShapeKey, collapsed)
	if (collapsed) then
		return self.data[buttonShapeKey].collapsedData.castFillSizeOffset;
	end

	return self.data[buttonShapeKey].expandedData.castFillSizeOffset;
end

function GamepadActionBarButtonCastingAnimDataMixin:SetCastFillMaskSizeOffset(buttonShapeKey, isCollapsedData, castFillMaskSizeOffset)
	if (isCollapsedData) then
		self.data[buttonShapeKey].collapsedData.castFillMaskSizeOffset = castFillMaskSizeOffset;
	else
		self.data[buttonShapeKey].expandedData.castFillMaskSizeOffset = castFillMaskSizeOffset;
	end
end

function GamepadActionBarButtonCastingAnimDataMixin:GetCastFillMaskSizeOffset(buttonShapeKey, collapsed)
	if (collapsed) then
		return self.data[buttonShapeKey].collapsedData.castFillMaskSizeOffset;
	end

	return self.data[buttonShapeKey].expandedData.castFillMaskSizeOffset;
end

function GamepadActionBarButtonCastingAnimDataMixin:SetEndMaskSizeOffset(buttonShapeKey, isCollapsedData, endMaskSizeOffset)
	if (isCollapsedData) then
		self.data[buttonShapeKey].collapsedData.endMaskSizeOffset = endMaskSizeOffset;
	else
		self.data[buttonShapeKey].expandedData.endMaskSizeOffset = endMaskSizeOffset;
	end
end

function GamepadActionBarButtonCastingAnimDataMixin:GetEndMaskSizeOffset(buttonShapeKey, collapsed)
	if (collapsed) then
		return self.data[buttonShapeKey].collapsedData.endMaskSizeOffset;
	end

	return self.data[buttonShapeKey].expandedData.endMaskSizeOffset;
end

local castingAnimData = CreateFromMixins(GamepadActionBarButtonCastingAnimDataMixin);

castingAnimData:RegisterButtonShape(BUTTON_SHAPES.CIRCLE);
castingAnimData:RegisterButtonShape(BUTTON_SHAPES.SQUARE);

castingAnimData:SetInnerGlowSizeOffset(BUTTON_SHAPES.CIRCLE, true, -6);
castingAnimData:SetCastFillSizeOffset(BUTTON_SHAPES.CIRCLE, true, -6);
castingAnimData:SetCastFillMaskSizeOffset(BUTTON_SHAPES.CIRCLE, true, -6);
castingAnimData:SetEndMaskSizeOffset(BUTTON_SHAPES.CIRCLE, true, 2);
castingAnimData:SetInnerGlowSizeOffset(BUTTON_SHAPES.CIRCLE, false, -8);
castingAnimData:SetCastFillSizeOffset(BUTTON_SHAPES.CIRCLE, false, -8);
castingAnimData:SetCastFillMaskSizeOffset(BUTTON_SHAPES.CIRCLE, false, -6);
castingAnimData:SetEndMaskSizeOffset(BUTTON_SHAPES.CIRCLE, false, 3);

castingAnimData:SetInnerGlowSizeOffset(BUTTON_SHAPES.SQUARE, true, -4);
castingAnimData:SetCastFillSizeOffset(BUTTON_SHAPES.SQUARE, true, -4);
castingAnimData:SetCastFillMaskSizeOffset(BUTTON_SHAPES.SQUARE, true, 10);
castingAnimData:SetEndMaskSizeOffset(BUTTON_SHAPES.SQUARE, true, 11);
castingAnimData:SetInnerGlowSizeOffset(BUTTON_SHAPES.SQUARE, false, -6);
castingAnimData:SetCastFillSizeOffset(BUTTON_SHAPES.SQUARE, false, -6);
castingAnimData:SetCastFillMaskSizeOffset(BUTTON_SHAPES.SQUARE, false, 10);
castingAnimData:SetEndMaskSizeOffset(BUTTON_SHAPES.SQUARE, false, 17);


---------------------------------
-- GamepadActionBarButtonMixin --
---------------------------------

-- Contains the functions and values shared between both the standard and pet variants of the gamepad action bar button.
GamepadActionBarButtonMixin = {};

function GamepadActionBarButtonMixin:SetShapeToCircle()
	-- Hide generic mask in favor of Gamepad specific masks
	self.IconMask:Hide();

	self.CircleMask:Show();
	self.CircleShadow:Show();
	self.SquareMask:Hide();
	self.SquareShadow:Hide();

	self.activeButtonShape = BUTTON_SHAPES.CIRCLE;

	self:UpdateEmptySlotBackgroundTexture();

	-- Change the border and highlight textures to circle versions.
	self:SetNormalAtlas(CIRCLE_NORMAL_FRAME_ATLAS);
	self:SetPushedAtlas(CIRCLE_PUSHED_FRAME_ATLAS);
	self.HighlightTexture:SetAtlas(CIRCLE_HIGHLIGHT_FRAME_ATLAS);
	self:SetCheckedTexture(CIRCLE_CHECKED_FRAME_ATLAS);
	self.cooldown:SetSwipeTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	self.SpellHighlightTexture:SetAtlas(CIRCLE_SPELL_HIGHLIGHT_ATLAS);
	self.Border:SetAtlas(CIRCLE_ICON_FRAME_BORDER);

	self.TargetReticleAnimFrame.Base:SetAtlas(CIRCLE_AOE_TARGET_BASE_ATLAS);
	self.TargetReticleAnimFrame.Mask:SetAtlas(CIRCLE_AOE_TARGET_MASK_ATLAS);

	self.castingAnimTextureSetupFunc = self.SetCircleCastingTextures;

	self.InterruptDisplay.Base.Base:SetAtlas(CIRCLE_INTERRUPT_BASE_ATLAS);
	self.InterruptDisplay.Highlight.Mask:SetAtlas(CIRCLE_INTERRUPT_HIGHLIGHT_MASK_ATLAS);
	self:ApplyGamepadInterruptAnchorPoints();

	local AUTO_CAST_CORNERS_OFFSET = 3;
	self.AutoCastOverlay.Corners:SetAtlas(CIRCLE_AUTO_CAST_CORNERS_ATLAS);
	self.AutoCastOverlay.Corners:ClearAllPoints();
	self.AutoCastOverlay.Corners:SetPoint("TOPLEFT", AUTO_CAST_CORNERS_OFFSET, -AUTO_CAST_CORNERS_OFFSET);
	self.AutoCastOverlay.Corners:SetPoint("BOTTOMRIGHT", -AUTO_CAST_CORNERS_OFFSET, AUTO_CAST_CORNERS_OFFSET);
	self.AutoCastOverlay.Mask:SetAtlas(CIRCLE_AUTO_CAST_MASK_ATLAS);
end

function GamepadActionBarButtonMixin:SetCircleCastingTextures(isChannelCast)
	local fillFrame = self.SpellCastAnimFrame.Fill;
	local endBurstFrame = self.SpellCastAnimFrame.EndBurst;
	fillFrame.FillMask:SetAtlas("CircleMask");
	endBurstFrame.EndMask:SetAtlas(CIRCLE_CAST_END_MASK);

	if (isChannelCast) then
		fillFrame.InnerGlowTexture:SetAtlas(CIRCLE_CHANNEL_INNER_GLOW_ATLAS, true);
		fillFrame.CastFill:SetAtlas(SHARED_CHANNEL_FILL_ATLAS);
		endBurstFrame.GlowRing:SetAtlas(SHARED_CHANNEL_COMPLETE_GLOW_ATLAS);
	else
		fillFrame.InnerGlowTexture:SetAtlas(CIRCLE_CASTING_INNER_GLOW_ATLAS, true);
		fillFrame.CastFill:SetAtlas(SHARED_CASTING_FILL_ATLAS);
		endBurstFrame.GlowRing:SetAtlas(SHARED_CASTING_COMPLETE_GLOW_ATLAS);
	end
end

function GamepadActionBarButtonMixin:SetShapeToSquare()
	-- Hide generic mask in favor of Gamepad specific masks
	self.IconMask:Hide();

	self.CircleMask:Hide();
	self.CircleShadow:Hide();
	self.SquareShadow:Show();
	self.SquareMask:Show();
	self.activeButtonShape = BUTTON_SHAPES.SQUARE;

	self:UpdateEmptySlotBackgroundTexture();

	-- Change the border and highlight textures to square versions.
	self:SetNormalAtlas(SQUARE_NORMAL_FRAME_ATLAS);
	self:SetPushedAtlas(SQUARE_PUSHED_FRAME_ATLAS);
	self.HighlightTexture:SetAtlas(SQUARE_HIGHLIGHT_FRAME_ATLAS);
	self:SetCheckedTexture(SQUARE_CHECKED_TEXTURE_ATLAS);
	self.SpellHighlightTexture:SetAtlas(SQUARE_SPELL_HIGHLIGHT_ATLAS);
	self.Border:SetAtlas(SQUARE_ICON_FRAME_BORDER);

	self.TargetReticleAnimFrame.Base:SetAtlas(SQUARE_AOE_TARGET_BASE_ATLAS);
	self.TargetReticleAnimFrame.Mask:SetAtlas(SQUARE_AOE_TARGET_MASK_ATLAS);

	self.castingAnimTextureSetupFunc = self.SetSquareCastingTextures;

	self.InterruptDisplay.Base.Base:SetAtlas(SQUARE_INTERRUPT_BASE_ATLAS);
	self.InterruptDisplay.Highlight.Mask:SetAtlas(SQUARE_INTERRUPT_HIGHLIGHT_MASK_ATLAS);
	self:ApplyGamepadInterruptAnchorPoints();

	local AUTO_CAST_CORNERS_OFFSET = 4;
	self.AutoCastOverlay.Corners:SetAtlas(SQUARE_AUTO_CAST_CORNERS_ATLAS);
	self.AutoCastOverlay.Corners:ClearAllPoints();
	self.AutoCastOverlay.Corners:SetPoint("TOPLEFT", AUTO_CAST_CORNERS_OFFSET, -AUTO_CAST_CORNERS_OFFSET);
	self.AutoCastOverlay.Corners:SetPoint("BOTTOMRIGHT", -AUTO_CAST_CORNERS_OFFSET, AUTO_CAST_CORNERS_OFFSET);
	self.AutoCastOverlay.Mask:SetAtlas(SQUARE_AUTO_CAST_MASK_ATLAS);
end

function GamepadActionBarButtonMixin:SetSquareCastingTextures(isChannelCast)
	local fillFrame = self.SpellCastAnimFrame.Fill;
	local endBurstFrame = self.SpellCastAnimFrame.EndBurst;

	if (isChannelCast) then
		fillFrame.InnerGlowTexture:SetAtlas(SQUARE_CHANNEL_INNER_GLOW_ATLAS, true);
		fillFrame.CastFill:SetAtlas(SHARED_CHANNEL_FILL_ATLAS);
		fillFrame.FillMask:SetAtlas(SQUARE_CAST_ANIM_FILL_MASK_ATLAS);

		endBurstFrame.GlowRing:SetAtlas(SHARED_CHANNEL_COMPLETE_GLOW_ATLAS);
		endBurstFrame.EndMask:SetAtlas(SQUARE_CAST_END_MASK);
	else
		fillFrame.InnerGlowTexture:SetAtlas(SQUARE_CASTING_INNER_GLOW_ATLAS, true);
		fillFrame.CastFill:SetAtlas(SHARED_CASTING_FILL_ATLAS);
		fillFrame.FillMask:SetAtlas(SQUARE_CAST_ANIM_FILL_MASK_ATLAS);

		endBurstFrame.GlowRing:SetAtlas(SHARED_CASTING_COMPLETE_GLOW_ATLAS);
		endBurstFrame.EndMask:SetAtlas(SQUARE_CAST_END_MASK);
	end
end

function GamepadActionBarButtonMixin:IsCollapsed()
	return self.collapsed;
end

function GamepadActionBarButtonMixin:Collapse()
	self.collapsed = true;

	-- The cast/channeling animation may be active, so we need to update the anchors to the collapsed version.
	self:UpdateCastingAnimSizeAndPositioning(self.isCastingAnimFillingFromRight);
	self:UpdateInterruptHighlightAnimAnchors();

	-- Slight sizing update needed for auto cast animation.
	self:UpdateAutoCastAnchors();
end

function GamepadActionBarButtonMixin:Expand()
	self.collapsed = false;

	-- The cast/channeling animation may be active, so we need to update the anchors to the expanded version.
	self:UpdateCastingAnimSizeAndPositioning(self.isCastingAnimFillingFromRight);
	self:UpdateInterruptHighlightAnimAnchors();

	-- Slight sizing update needed for auto cast animation.
	self:UpdateAutoCastAnchors();
end

function GamepadActionBarButtonMixin:ApplyGamepadAOETargetAnchorPoints()
	local AOE_TARGET_HIGHLIGHT_OFFSET = 7;
	local AOE_TARGET_MASK_OFFSET = 5;

	self.TargetReticleAnimFrame:ClearAllPoints();
	self.TargetReticleAnimFrame:SetAllPoints();
	self.TargetReticleAnimFrame.Base:ClearAllPoints();
	self.TargetReticleAnimFrame.Base:SetAllPoints();
	self.TargetReticleAnimFrame.Highlight:ClearAllPoints();
	self.TargetReticleAnimFrame.Highlight:SetPoint("TOPLEFT", -AOE_TARGET_HIGHLIGHT_OFFSET, AOE_TARGET_HIGHLIGHT_OFFSET);
	self.TargetReticleAnimFrame.Highlight:SetPoint("BOTTOMRIGHT", AOE_TARGET_HIGHLIGHT_OFFSET, -AOE_TARGET_HIGHLIGHT_OFFSET);
	self.TargetReticleAnimFrame.Mask:ClearAllPoints();
	self.TargetReticleAnimFrame.Mask:SetPoint("TOPLEFT", -AOE_TARGET_MASK_OFFSET, AOE_TARGET_MASK_OFFSET);
	self.TargetReticleAnimFrame.Mask:SetPoint("BOTTOMRIGHT", AOE_TARGET_MASK_OFFSET, -AOE_TARGET_MASK_OFFSET);
end

function GamepadActionBarButtonMixin:ApplyGamepadInterruptAnchorPoints()
	-- Default offsets are for square buttons.
	local interruptBaseOffset = 1;
	local interruptHighlightMaskOffset = 4;

	if (self.activeButtonShape == BUTTON_SHAPES.CIRCLE) then
		interruptBaseOffset = 3;
		interruptHighlightMaskOffset = 3;
	end

	self.InterruptDisplay.Base.Base:ClearAllPoints();
	self.InterruptDisplay.Base.Base:SetAllPoints();
	self.InterruptDisplay.Base:ClearAllPoints();
	self.InterruptDisplay.Base:SetPoint("TOPLEFT", interruptBaseOffset, -interruptBaseOffset);
	self.InterruptDisplay.Base:SetPoint("BOTTOMRIGHT", -interruptBaseOffset, interruptBaseOffset);

	self.InterruptDisplay.Highlight:ClearAllPoints();
	self.InterruptDisplay.Highlight:SetAllPoints();
	self.InterruptDisplay.Highlight.Mask:ClearAllPoints();
	self.InterruptDisplay.Highlight.Mask:SetPoint("TOPLEFT", -interruptHighlightMaskOffset, interruptHighlightMaskOffset);
	self.InterruptDisplay.Highlight.Mask:SetPoint("BOTTOMRIGHT", interruptHighlightMaskOffset, -interruptHighlightMaskOffset);
	self:UpdateInterruptHighlightAnimAnchors();
end

function GamepadActionBarButtonMixin:UpdateInterruptHighlightAnimAnchors()
	local buttonHeight = self:GetHeight();
	self.InterruptDisplay.Highlight.HighlightTexture:SetPoint("CENTER", 0, buttonHeight);
	self.InterruptDisplay.Highlight.AnimIn.Translation:SetOffset(0, -((buttonHeight * 2) + (buttonHeight * 0.5)));
end

function GamepadActionBarButtonMixin:ApplyPressedStyle(pressed)
	if self.clickedUsingMouse and pressed then
		return;
	end

	if self.ApplyExtraButtonStylesForState then
		if pressed then
			self:ApplyExtraButtonStylesForState("PUSHED");
		else
			self:ApplyExtraButtonStylesForState("NORMAL");
		end
	end
end

function GamepadActionBarButtonMixin:UpdateAutoCastAnchors()
	local maskOffset = 4;
	if (self.collapsed) then
		maskOffset = 2;
	end

	self.AutoCastOverlay.Mask:ClearAllPoints();
	self.AutoCastOverlay.Mask:SetPoint("TOPLEFT", -maskOffset, maskOffset);
	self.AutoCastOverlay.Mask:SetPoint("BOTTOMRIGHT", maskOffset, -maskOffset);
end

function GamepadActionBarButtonMixin:SetActionBarParent(actionBar)
	self.parentActionBar = actionBar;
end

function GamepadActionBarButtonMixin:GetActionBarParent()
	return self.parentActionBar;
end

function GamepadActionBarButtonMixin:SetButtonIndexOnActionBar(buttonIndex)
	self.buttonIndexOnActionBar = buttonIndex;
end

function GamepadActionBarButtonMixin:OnLoad()
	self.buttonIndexOnActionBar = 1;	-- This should be updated by the action bar the button is being added to.
	self.SlotBackground:Hide();
	self:ApplyGamepadAOETargetAnchorPoints();
	self.activeButtonShape = BUTTON_SHAPES.SQUARE; -- Action buttons start in the square shape.
	self.collapsed = false;

	self.CooldownFlash:SetAlpha(0);

	self.TargetReticleAnimFrame.Highlight:SetAtlas(SHARED_AOE_TARGET_HIGHLIGHT_ATLAS);
	self.TargetReticleAnimFrame:SetScript("OnHide", GenerateClosure(self.ClearPushedStateAfterAOETargeting, self));

	self.AutoCastOverlay.Shine:SetAtlas(SHARED_AUTO_CAST_RADIAL_ATLAS);
	self.AutoCastOverlay.Shine:ClearAllPoints();
	self.AutoCastOverlay.Shine:SetAllPoints();

	--[[
		Overrides the base action button mixin's version of SetupAnimAtlases so that we can
		update our animation textures to the correct button shape as needed.
	]]
	self.SpellCastAnimFrame.SetupAnimAtlases = GenerateClosure(self.SetupCastingAnim, self);

	self.InterruptDisplay.Highlight.HighlightTexture:SetAtlas(SHARED_INTERRUPT_HIGHLIGHT_ATLAS);
end

function GamepadActionBarButtonMixin:UpdateEmptySlotBackgroundTexture()
	local activeInputDeviceIconSet = InputDeviceIconSetManager:GetActiveInputDeviceIconSet();
	local emptySlotTexture = nil;
	if (self.activeButtonShape == BUTTON_SHAPES.SQUARE) then
		emptySlotTexture = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS[activeInputDeviceIconSet]:GetEmptySlotSquareBackgroundTextureByIndex(self.buttonIndexOnActionBar);
	elseif(self.activeButtonShape == BUTTON_SHAPES.CIRCLE) then
		emptySlotTexture = INPUT_DEVICE_ACTION_BUTTON_TEXTURE_SETS[activeInputDeviceIconSet]:GetEmptySlotCircleBackgroundTextureByIndex(self.buttonIndexOnActionBar);
	end
	self.SlotArt:SetAtlas(emptySlotTexture);
end

--[[
	Called during action button setup. Default all gamepad action bar buttons to square shape,
	and let the GamepadActionBarStyle logic handle changing it to the appropriate type based
	on the active style.
]]
function GamepadActionBarButtonMixin:UpdateButtonArt()
	self:UpdateButtonArtAnchoring();
	self:SetShapeToSquare();
end

function GamepadActionBarButtonMixin:UpdateButtonArtAnchoring()
	self.Flash:ClearAllPoints();
	self.Flash:SetAllPoints(self);

	self.Border:ClearAllPoints();
	self.Border:SetAllPoints(self);

	self.NewActionTexture:ClearAllPoints();
	self.NewActionTexture:SetAllPoints(self);

	self.SpellHighlightTexture:ClearAllPoints();
	self.SpellHighlightTexture:SetAllPoints(self);

	self.NormalTexture:ClearAllPoints();
	self.NormalTexture:SetAllPoints(self);

	self.PushedTexture:ClearAllPoints();
	self.PushedTexture:SetAllPoints(self);

	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetAllPoints(self);

	self.CheckedTexture:ClearAllPoints();
	self.CheckedTexture:SetAllPoints(self);

	self.AutoCastOverlay:ClearAllPoints();
	self.AutoCastOverlay:SetAllPoints();
end

-- Updates the range indicator art state.
function GamepadActionBarButtonMixin:RefreshRange(checksRange, inRange)
	local inputIconTexture = self.ButtonIcon

	if (self.isGamepadPossessBarButton and not UnitExists("target")) then
		self.RangeIndicator:Hide();
		inputIconTexture:SetDisabled();
		return;
	end

	if checksRange then
		self.RangeIndicator:Show();
		if inRange then
			self.RangeIndicator:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB());
			inputIconTexture:SetPressable();
		else
			self.RangeIndicator:SetVertexColor(RED_FONT_COLOR:GetRGB());
			inputIconTexture:SetDisabled();
		end
	else
		self.RangeIndicator:Hide();
		inputIconTexture:SetDisabled();
	end
end

function GamepadActionBarButtonMixin:ClearPushedStateAfterAOETargeting()
	self:SetButtonState("NORMAL");
end

function GamepadActionBarButtonMixin:UpdateCastingAnimSizeAndPositioning(fillFromRight)
	local collapsed = self:IsCollapsed();
	local innerGlowSizeOffset = castingAnimData:GetInnerGlowSizeOffset(self.activeButtonShape, collapsed);
	local castFillSizeOffset = castingAnimData:GetCastFillSizeOffset(self.activeButtonShape, collapsed);
	local castFillMaskSizeOffset = castingAnimData:GetCastFillMaskSizeOffset(self.activeButtonShape, collapsed);
	local endMaskSizeOffset = castingAnimData:GetEndMaskSizeOffset(self.activeButtonShape, collapsed);
	local buttonWidth = self:GetWidth();
	local buttonHeight = self:GetHeight();

	local fillFrame = self.SpellCastAnimFrame.Fill;
	local endBurstFrame = self.SpellCastAnimFrame.EndBurst;

	fillFrame.InnerGlowTexture:SetPoint("CENTER", self);
	fillFrame.InnerGlowTexture:SetSize(buttonWidth + innerGlowSizeOffset, buttonHeight + innerGlowSizeOffset);

	local fillPointOffset = buttonWidth;
	if (not fillFromRight) then
		fillPointOffset = -fillPointOffset;	-- Fill from left to right instead.
	end
	fillFrame.CastFill:SetPoint("CENTER", self, fillPointOffset, 0);
	fillFrame.CastingAnim.CastFillTranslation:SetOffset(-fillPointOffset, 0);
	fillFrame.CastFill:SetSize(buttonWidth + castFillSizeOffset, buttonHeight + castFillSizeOffset);

	fillFrame.FillMask:SetPoint("CENTER", self);
	fillFrame.FillMask:SetSize(buttonWidth + castFillMaskSizeOffset, buttonHeight + castFillMaskSizeOffset);

	endBurstFrame.EndMask:SetPoint("CENTER", self);
	endBurstFrame.EndMask:SetSize(buttonWidth + endMaskSizeOffset, buttonHeight + endMaskSizeOffset);
end

function GamepadActionBarButtonMixin:SetupCastingAnim(_, isChannelCast)
	-- This function is set for the button based on the SetShapeTo<ShapeType> functions.
	self:castingAnimTextureSetupFunc(isChannelCast);
	self:UpdateCastingAnimSizeAndPositioning(isChannelCast);
	self.isCastingAnimFillingFromRight = isChannelCast;
end

--[[
	This function is meant to be called during the setup of the GamepadActionBarEditFrame
	to disable any gameplay animation textures that may be displayed during the edit/binding process,
	hence the reason for clearing the show functions.
]]
function GamepadActionBarButtonMixin:DisableGameplayFeedback()
	local feedbackFrames =
	{
		self.SpellCastAnimFrame,
		self.InterruptDisplay,
		self.Flash,
		self.RangeIndicator,
		self.Border,
		self.AutoCastOverlay
	}
	for _, value in ipairs(feedbackFrames) do
		value:Hide();
		value.SetShown = function() value:Hide() end;
		value.Show = nop;
	end

	--[[
		Disable the action button alpha effect that is displayed on the button when the player doesn't
		have enough resources. In binding mode display the actions in the "usable" state.
	]]
	self.icon:SetVertexColor(1.0, 1.0, 1.0);
	self.icon.SetVertexColor = nop;
end

-----------------------------------------
-- SpellInfoCache
-----------------------------------------

--[[
	For displaying reagents and the correct availability etc. on flyouts, we need info about all
	the spells they contain. That info may not be readily available, so keep a cache of it.
]]
local SpellInfoCache = { cached = {}, pending = {}, requests = {} };

-- Returns a cancellation token if data was requested, or nil if the data is already available.
function SpellInfoCache:RequestData(ids, callback)
	local request = nil;

	for _, id in ipairs(ids) do
		if not self.cached[id] and not self.pending[id] then
			self.pending[id] = true;
			SpellEventListener:AddCallback(id, GenerateClosure(self.OnSpellDataLoad, self, id));
			request = request or {};
			table.insert(request, id);
		end
	end

	if request ~= nil then
		self.requests[request] = callback;
	end

	return request;
end

function SpellInfoCache:CancelRequest(request)
	if request ~= nil then
		self.requests[request] = nil;
	end
end

function SpellInfoCache:OnSpellDataLoad(id)
	self.cached[id] = true;
	self.pending[id] = nil;

	local completed = {};
	for request, _ in pairs(self.requests) do
		tDeleteItem(request, id);
		if #request == 0 then
			table.insert(completed, request);
		end
	end

	for _, request in ipairs(completed) do
		local callback = self.requests[request];
		self.requests[request] = nil;
		callback();
	end
end

-----------------------------------------
-- GamepadActionBarButtonFlyoutMixin --
-----------------------------------------

GamepadActionBarButtonFlyoutMixin = {}

function GamepadActionBarButtonFlyoutMixin:OnLoad()
	self.flyoutArrowAngleRads = 0;
end

-- Overrides FlyoutButtonMixin:UpdateBorderShadow
function GamepadActionBarButtonFlyoutMixin:UpdateBorderShadow()
end

-- Overrides FlyoutButtonMixin:OnPopupToggled
function GamepadActionBarButtonFlyoutMixin:OnPopupToggled()
	if self:IsPopupOpen() then
		self:OnFlyoutOpened();
	else
		self:OnFlyoutClosed();
	end
end

function GamepadActionBarButtonFlyoutMixin:OnFlyoutOpened()
	self.parentActionBar.pagingUnitOwner:OnFlyoutOpened(self);
	self:UpdateArrowPosition();
end

function GamepadActionBarButtonFlyoutMixin:OnFlyoutClosed()
	self.parentActionBar.pagingUnitOwner:OnFlyoutClosed();
	self:SetArrowRotationRadians(0);
end

-- Overrides FlyoutButtonMixin:GetArrowRotation
function GamepadActionBarButtonFlyoutMixin:GetArrowRotation()
	return math.deg(self.flyoutArrowAngleRads);
end

-- Overrides FlyoutButtonMixin:UpdateArrowPosition
function GamepadActionBarButtonFlyoutMixin:UpdateArrowPosition()
	self.Arrow:ClearAllPoints();

	if self:IsPopupOpen() then
		local width = self:GetSize();
		local radius = width * 0.5 + self.openArrowOffset;
		local rotation = self.flyoutArrowAngleRads;
		local xOffset = radius * math.sin(rotation);
		local yOffset = radius * math.cos(rotation);
		self.Arrow:SetPoint("CENTER", xOffset, yOffset);
	else
		self.Arrow:SetPoint("TOP", 0, self.closedArrowOffset);
	end
end

-- Overrides FlyoutButtonMixin:UpdateArrowRotation
function GamepadActionBarButtonFlyoutMixin:UpdateArrowRotation()
	self.Arrow:SetRotation(-self.flyoutArrowAngleRads);
end

function GamepadActionBarButtonFlyoutMixin:SetArrowRotationRadians(rads)
	self.flyoutArrowAngleRads = rads;
	self:UpdateArrowPosition();
	self:UpdateArrowRotation();
end

-- Overrides BaseActionButtonMixin:UpdateFlyoutPopup
function GamepadActionBarButtonFlyoutMixin:UpdateFlyoutPopup(actionType)
	local flyout = GamepadSpellFlyout or SpellFlyout;

	if actionType == "flyout" and flyout then
		self:SetPopup(flyout);
	else
		self:ClearPopup();
	end
end

function GamepadActionBarButtonFlyoutMixin:EnumFlyoutSlotInfo(onlyKnown)
	local _, _, numSlots = GetFlyoutInfo(self.flyoutID);
	local i = 0;

	return function()
		while i < numSlots do
			i = i + 1;
			local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(self.flyoutID, i);
			if isKnown or not onlyKnown then
				return spellID, overrideSpellID, isKnown, spellName, slotSpecID;
			end
		end
	end;
end

-- Overrides ActionBarActionButtonMixin:UpdateCount
function GamepadActionBarButtonFlyoutMixin:UpdateCount()
	if not self.isFlyoutAction then
		return ActionBarActionButtonMixin.UpdateCount(self);
	end

	-- Assume that if all spells have a reagent cost, it's the same reagent
	local onlyKnown = true;
	local isConsumable = false;
	local displayCount = nil;
	for _, overrideSpellID in self:EnumFlyoutSlotInfo(onlyKnown) do
		if not C_Spell.IsConsumableSpell(overrideSpellID) then
			displayCount = nil;
			break;
		end
		if not displayCount then
			displayCount = C_Spell.GetSpellDisplayCount(overrideSpellID, self.maxDisplayCount);
		end
	end

	self.Count:SetText(displayCount or "");
end

-- Overrides ActionBarActionButtonMixin:UpdateState
function GamepadActionBarButtonFlyoutMixin:UpdateState()
	-- Intentionally not checking active spells here, only single spells: For the active spell we
	-- want to show which spell is active, which isn't really possible when they all have the same
	-- checked texture.
	local spellID = self:GetSingleSpellID();

	if spellID then
		self:SetChecked(C_Spell.IsActiveSpell(spellID));
	else
		ActionBarActionButtonMixin.UpdateState(self);
	end
end

-- Overrides ActionBarActionButtonMixin:UpdateUsable
function GamepadActionBarButtonFlyoutMixin:UpdateUsable(action, isUsable, notEnoughMana, isLevelLinkLocked)
	if self.isFlyoutAction then
		isUsable = false;	-- Should be true if _any_ spell is usable
		notEnoughMana = true;	-- Should be true if _all_ spells are too costly
		isLevelLinkLocked = true;	-- Should be true if _all_ spells are locked

		local onlyKnown = true;
		for _, overrideSpellID in self:EnumFlyoutSlotInfo(onlyKnown) do
			if not isUsable or notEnoughMana then
				local isSpellUsable, isSpellTooCostly = C_Spell.IsSpellUsable(overrideSpellID);
				isUsable = isUsable or isSpellUsable;
				notEnoughMana = notEnoughMana and isSpellTooCostly;
			end
			if isLevelLinkLocked then
				isLevelLinkLocked = C_LevelLink.IsSpellLocked(overrideSpellID);
			end
		end
	end

	ActionBarActionButtonMixin.UpdateUsable(self, action, isUsable, notEnoughMana, isLevelLinkLocked);
end

function GamepadActionBarButtonFlyoutMixin:CalculateAction(button)
	-- Reserved slots have no actions and are instead handled with custom scripts.
	if self.pageUnitSlotID and GamepadActionBarBindingUtil.IsReservedPageUnitSlotID(self.pageUnitSlotID) then
		return 0;
	end

	return SecureActionButtonMixin.CalculateAction(self, button);
end

-- Overrides ActionBarActionButtonMixin:UpdateAction
function GamepadActionBarButtonFlyoutMixin:UpdateAction(force)
	-- NOTE: This is called as a result of :SetAttribute, but :SetAttribute is also called by
	-- functions called by this. If this is a recursive call, ignore it.
	if self.isUpdatingAction then
		return;
	end

	self.isUpdatingAction = true;

	-- Normally ActionBarActionButtonMixin.UpdateAction will update self.action, but we don't want
	-- to call that until a bit further down, since it will trigger a bunch of methods that need to
	-- have up-to-date state, so instead we take a sneak peek.
	local action = self:CalculateAction();

	if force or self.action ~= action then
		local wasFlyoutAction = self.isFlyoutAction;
		self.isFlyoutAction = false;
		self.flyoutID = nil;

		if action then
			local actionType, id = GetActionInfo(action);
			if actionType == "flyout" then
				self.isFlyoutAction = true;
				self.flyoutID = id;
			end
		end

		if self.isFlyoutAction ~= wasFlyoutAction then
			if wasFlyoutAction then
				self:UnregisterEvent("BAG_UPDATE");
				self:UnregisterEvent("SPELL_FLYOUT_UPDATE");
				self:UnregisterEvent("UNIT_AURA");
				self:UnregisterEvent("UNIT_POWER_UPDATE");
			else
				self:RegisterEvent("BAG_UPDATE");
				self:RegisterEvent("SPELL_FLYOUT_UPDATE");
				self:RegisterUnitEvent("UNIT_AURA", "player");
				self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");
			end
		end

		self:CacheFlyoutSpellInfo();
		self:SetActionAttributes();
		ActionBarActionButtonMixin.UpdateAction(self, force);
	end

	self.isUpdatingAction = false;
end

function GamepadActionBarButtonFlyoutMixin:CacheFlyoutSpellInfo()
	SpellInfoCache:CancelRequest(self.flyoutSpellInfoRequest);
	self.flyoutSpellInfoRequest = nil;

	if not self.isFlyoutAction then
		return;
	end

	local spellIDs = {};
	local onlyKnown = false;

	for _, overrideSpellID in self:EnumFlyoutSlotInfo(onlyKnown) do
		table.insert(spellIDs, overrideSpellID);
	end

	self.flyoutSpellInfoRequest = SpellInfoCache:RequestData(spellIDs, GenerateClosure(self.Update, self));
end

function GamepadActionBarButtonFlyoutMixin:SetActionAttributes()
	local actionType = "action";
	local spellID = 0;

	if self.isFlyoutAction then
		local knownSpellID = nil;
		local numKnown = 0;
		local onlyKnown = true;

		for _, overrideSpellID in self:EnumFlyoutSlotInfo(onlyKnown) do
			numKnown = numKnown + 1;
			knownSpellID = overrideSpellID;
		end

		if numKnown == 1 then
			actionType = "spell";
			spellID = knownSpellID;
		else
			actionType = "flyout";
			spellID = self.flyoutID;
		end
	end

	self:SetAttribute("type", actionType);
	self:SetAttribute("spell", spellID);

	-- ActionButton_UpdateCooldown looks for a spellID field on the button before falling back to
	-- the action, so set that field to ensure cooldown display works properly.
	self.spellID = (actionType == "spell") and spellID or nil;
end

function GamepadActionBarButtonFlyoutMixin:GetSingleSpellID()
	if self.isFlyoutAction then
		-- If only one of the flyout spells are known, the flyout button should act like that spell
		local actionType = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
		if actionType == "spell" then
			return SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		end
	end
end

function GamepadActionBarButtonFlyoutMixin:GetActiveSpellID()
	if self.isFlyoutAction then
		local onlyKnown = true;
		for _, overrideSpellID in self:EnumFlyoutSlotInfo(onlyKnown) do
			if C_Spell.IsActiveSpell(overrideSpellID) then
				return overrideSpellID;
			end
		end
	end
end

function GamepadActionBarButtonFlyoutMixin:OnEvent(event, ...)
	ActionBarActionButtonMixin.OnEvent(self, event, ...);

	if event == "UNIT_AURA" then
		local unitTarget = ...;
		if unitTarget == "player" then
			self:UpdateFlyoutActionIcon();
		end
	elseif event == "UNIT_POWER_UPDATE" then
		self:UpdateUsable();
	elseif event == "SPELL_FLYOUT_UPDATE" then
		self:UpdateAction(true);
	elseif event == "BAG_UPDATE" then
		self:UpdateCount();
		self:UpdateUsable();
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		self:UpdateFlyoutActionIcon();
	end
end

-- Overrides ActionBarActionButtonMixin:Update
function GamepadActionBarButtonFlyoutMixin:Update(...)
	ActionBarActionButtonMixin.Update(self, ...);
	self:UpdateFlyoutActionIcon();
end

-- ActionBarActionButtonMixin:SetTooltip
function GamepadActionBarButtonFlyoutMixin:SetTooltip()
	local singleSpellID = self:GetSingleSpellID();

	if singleSpellID then
		GameTooltip:Show();
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetSpellByID(singleSpellID);
	else
		ActionBarActionButtonMixin.SetTooltip(self);
	end
end

function GamepadActionBarButtonFlyoutMixin:UpdateFlyoutActionIcon()
	if not self.isFlyoutAction then
		return;
	end

	local spellID = self:GetSingleSpellID() or self:GetActiveSpellID();
	local texture = spellID and C_Spell.GetSpellTexture(spellID) or C_ActionBar.GetActionTexture(self.action);
	self.icon:SetTexture(texture);
end

-----------------------------------------
-- GamepadActionBarStandardButtonMixin --
-----------------------------------------

-- GamepadActionBarButton variant for the standard action buttons on the gamepad action
GamepadActionBarStandardButtonMixin = CreateFromMixins(GamepadActionBarButtonMixin, GamepadActionBarButtonFlyoutMixin);

function GamepadActionBarStandardButtonMixin:OnLoad()
	GamepadActionBarButtonFlyoutMixin.OnLoad(self);
	GamepadActionBarButtonMixin.OnLoad(self);
	ActionBarButtonMixin.ActionBarButtonMixin_OnLoad(self);
	self:SetAttribute("useOnKeyDown", true); -- Forces gamepad buttons to run action on button click down instead of up.
	self.SetButtonArt = function() end;	-- Prevent the ActionButtonOverride.lua defintion from running again.
end

function GamepadActionBarStandardButtonMixin:OnEvent(event, ...)
	GamepadActionBarButtonFlyoutMixin.OnEvent(self, event, ...);

	if event == "ACTION_RANGE_CHECK_UPDATE" then
		local inRange, checksRange = select(2, ...);
		self:RefreshRange(checksRange, inRange);
	end
end

--[[
	Sets the gamepad page unit slot id for this button. This id can be used
	alongside a gamepad page unit page number to calculate the storage index
	containing the action information that should be displayed on this slot
	for the page number.

	See GamepadActionBarConstants.lua for more information on how the IDs are
	mapped to the action bar layout.
]]
function GamepadActionBarStandardButtonMixin:SetGamepadPageUnitSlotID(slotID)
	self.pageUnitSlotID = slotID;
end

function GamepadActionBarStandardButtonMixin:GetGamepadPageUnitSlotID()
	return self.pageUnitSlotID;
end

function GamepadActionBarStandardButtonMixin:UpdateWithStorageId(storageId)
	self:SetID(storageId or 0);
	self:UpdateAction(true);
end

--[[
	Changes the button to display and trigger the action bound to the associated
	button slot on a given page unit page.
]]
function GamepadActionBarStandardButtonMixin:UpdatePageableGamepadButtonAction(page)
	local gamepadActionButtonStorageIndex = GamepadActionBarBindingUtil.GetGamepadStorageSlotIndexFromPageAndPageUnitSlotID(page, self.pageUnitSlotID);
	self:UpdateWithStorageId(gamepadActionButtonStorageIndex);
end

--[[
	Overrides the ActionBarActionButtonMixin version so that the gamepad buttons
	are triggered on down instead of on up.
]]
function GamepadActionBarStandardButtonMixin:TriggerSecureClick(button, down)
	local isKeyPress = true;

	self:ApplyPressedStyle(down);

	--[[
		Handle mouse clicks on the gamepad action button. Allows actions to be
		cast, placed, and dragged off with the mouse as if it was a MKB action button.
	]]
	if (self.clickedUsingMouse) then
		isKeyPress = false;
		if (not down) then
			self.clickedUsingMouse = false;
		end
	end

	local isSecureAction = true;
	SecureActionButton_OnClick(self, button, down, isKeyPress, isSecureAction);
end

function GamepadActionBarStandardButtonMixin:OnMouseDown()
	--[[
		Record that a mouse down occured on the button so the
		TriggerSecureClick function can interpret the click event
		properly.
	]]
	self.clickedUsingMouse = true;
end

function GamepadActionBarStandardButtonMixin:OnDragStart()
	ActionBarActionButtonMixin.OnDragStart(self);

	--[[
		Reset the button's mouse click flag so that when the action is dragged off of this
		button it remains in the gamepad input handling state rather than the cursor state.
	]]
	self.clickedUsingMouse = false;
end

------------------------------------
-- GamepadActionBarPetButtonMixin --
------------------------------------

GamepadActionBarPetButtonMixin = CreateFromMixins(PetActionButtonMixin, GamepadActionBarButtonMixin);

function GamepadActionBarPetButtonMixin:HasAction()
	local petActionButtonID = self:GetID();
	return GetPetActionInfo(petActionButtonID);
end

function GamepadActionBarPetButtonMixin:OnLoad()
	BaseActionButtonMixin.BaseActionButtonMixin_OnLoad(self);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self.cooldown:SetSwipeColor(0, 0, 0);

	GamepadActionBarButtonMixin.OnLoad(self);
	self.isGamepadPossessBarButton = true;
end

function GamepadActionBarPetButtonMixin:OnClick(button, down)
	if (IsModifiedClick() and IsModifiedClick("PICKUPACTION")) then
		PickupPetAction(self:GetID());
		return;
	elseif (button == "LeftButton" and (down or self.clickedUsingMouse)) then
		CastPetAction(self:GetID());
		self.clickedUsingMouse = false;
	end

	self:ApplyPressedStyle(down);
end

function GamepadActionBarPetButtonMixin:OnMouseDown()
	--[[
		Record that a mouse down occured on the button so the
		click function can interpret the click event properly.
	]]
	self.clickedUsingMouse = true;
end

function GamepadActionBarPetButtonMixin:OnDragStart()
	PetActionButtonMixin.PetActionButtonMixin_OnDragStart(self);

	--[[
		Reset the button's mouse click flag so that when the action is dragged off of this
		button it remains in the gamepad input handling state rather than the cursor state.
	]]
	self.clickedUsingMouse = false;
end
