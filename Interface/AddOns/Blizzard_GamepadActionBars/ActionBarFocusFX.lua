local function IsInputIcon(object)
	return object and object.SetPressable and object.SetTextureState;
end

local function IsActionBarHighlightEnabled(alwaysShowHighlightAnims)
	if alwaysShowHighlightAnims then
		return true;
	end
	local shouldShowHighlight = CVarCallbackRegistry:GetCVarValueBool("GamepadShowActionBarHighlight");
	return shouldShowHighlight;
end

--[[
	Factory mixin for creating dynamic components used in focus animations.

	Action Bar focus FX requires several animated components. This class creates
	them on demand, rather than injecting them into or otherwise inflating / duplicating
	many widely used XML templates.
]]
local AnimStyleFactory = {
	StyleData = {
		GlowTop = {
			Offset = { X=0, Y=0 },
			Size = { X=62, Y=62 },
			-- TODO for post-BlizzCon: BlizzCon assets are Xbox only (PS will be broken).
			Atlas = {
				Generic = {
					[GAMEPAD_TRIGGER_LEFT] = "gamepad-actionbar-fx-triggerL-top",
					[GAMEPAD_TRIGGER_RIGHT] = "gamepad-actionbar-fx-triggerR-top",
				},
				Letters = {
					[GAMEPAD_TRIGGER_LEFT] = "gamepad-actionbar-fx-triggerL-top",
					[GAMEPAD_TRIGGER_RIGHT] = "gamepad-actionbar-fx-triggerR-top",
				},
				Shapes = {
					[GAMEPAD_TRIGGER_LEFT] = "gamepad-actionbar-fx-triggerL-top-ps",
					[GAMEPAD_TRIGGER_RIGHT] = "gamepad-actionbar-fx-triggerR-top-ps",
				},
				Reverse = {
					[GAMEPAD_TRIGGER_LEFT] = "gamepad-actionbar-fx-triggerL-top-switch",
					[GAMEPAD_TRIGGER_RIGHT] = "gamepad-actionbar-fx-triggerR-top-switch",
				},
			},
			FrameLevel = 6,
		},
		GlowBottom = {
			Offset = { X=0, Y=0 },
			Size = { X=88, Y=88 },
			Atlas = {
				[GAMEPAD_TRIGGER_LEFT] = "gamepad-actionbar-fx-trigger-behind",
				[GAMEPAD_TRIGGER_RIGHT] = "gamepad-actionbar-fx-trigger-behind",
			},
			FrameLevel = 1,
		},
	}
}

local function RefreshGlowTopTexture(glowTop)
	local inputIconParent = glowTop:GetParent();
	local activeInputDeviceIconSet = InputDeviceIconSetManager:GetActiveInputDeviceIconSet();
	local atlas = AnimStyleFactory.StyleData.GlowTop.Atlas[activeInputDeviceIconSet][inputIconParent.mappedButtonKey];
	glowTop.GlowTopTexture:SetAtlas(atlas);
end

-- Creates a frame of animated components that sit above core InputIconTexture components.
function AnimStyleFactory:CreateModifierGlowTop(inputIconParent)
	local activeInputDeviceIconSet = InputDeviceIconSetManager:GetActiveInputDeviceIconSet();
	local atlas = self.StyleData.GlowTop.Atlas[activeInputDeviceIconSet][inputIconParent.mappedButtonKey];
	if not atlas then
		return nil;
	end

	local glowTop = CreateFrame("Frame", nil, inputIconParent, "GamepadActionBarModifierGlowTop");
	glowTop.GlowTopTexture:SetAtlas(atlas);
	glowTop:SetPoint("CENTER", inputIconParent, "CENTER", self.StyleData.GlowTop.Offset.X, self.StyleData.GlowTop.Offset.Y);
	glowTop:SetSize(self.StyleData.GlowTop.Size.X, self.StyleData.GlowTop.Size.Y);
	glowTop:SetFrameLevel(self.StyleData.GlowTop.FrameLevel);
	glowTop:Hide();

	InputDeviceIconSetManager:RegisterActiveInputDeviceIconSetUpdatedCallback(RefreshGlowTopTexture, glowTop);

	return glowTop;
end

-- Creates a frame of animated components that sit below core InputIconTexture components.
function AnimStyleFactory:CreateModifierGlowBottom(inputIconParent)
	local atlas = self.StyleData.GlowBottom.Atlas[inputIconParent.mappedButtonKey];
	if not atlas then
		return nil;
	end
	local glowBottom = CreateFrame("Frame", nil, inputIconParent, "GamepadActionBarModifierGlowBottom");
	glowBottom.GlowBottomTexture:SetAtlas(atlas);
	glowBottom:SetPoint("CENTER", inputIconParent, "CENTER", self.StyleData.GlowBottom.Offset.X, self.StyleData.GlowBottom.Offset.Y);
	glowBottom:SetSize(self.StyleData.GlowBottom.Size.X, self.StyleData.GlowBottom.Size.Y);
	glowBottom:SetFrameLevel(self.StyleData.GlowBottom.FrameLevel);
	glowBottom:Hide();
	return glowBottom;
end

--[[
	Base mixin class that offers simple lifecycle methods for batching animated components.

	Controls setup, play, stop, and cleanup of animated components. "InitAnimations()" is the 
	primary mechanism through which child classes will identify elements to play and pause
	when the sequence is played / paused.
]]
local GamepadActionBarSequenceMixin = {};

function GamepadActionBarSequenceMixin:GetSequenceDebugName()
	return "n/a";
end

-- Debug helper for printing legible debug lines
function GamepadActionBarSequenceMixin:DebugPrint(logStr)
	local barStr = (self.actionBar and self.actionBar:GetName()) or "n/a";
	barStr = string.gsub(barStr, "GamepadMainActionBarFramePageUnit", "");
	local printStr = "[" .. (self:GetSequenceDebugName()) .. "][" .. barStr .. "]"
	print(printStr .. " " .. logStr);
end

function GamepadActionBarSequenceMixin:Init(actionBar)
	self.actionBar = actionBar;
	self.isPlaying = false;
	self.isLooping = false;
	self.animTimer = nil;

	if actionBar.pagingUnitOwner then
		self:InitAnimations();
	end
end

--[[
	Iterates over all relevant modifier icons, and acts upon them.

	There are two complexities here:
	1. ActionBars have a property "modifierIcon" which is conditionally non-nil,
	depending on whether this action bar is owned by a given paging unit.
	2. That "modifierIcon" may actually represent an input prompt that, itself,
	contains multiple modifier icons.

	This is primarily used to find animations (by name) on InputIconTexture objects.
]]
function GamepadActionBarSequenceMixin:ForEachModifierIcon(func)
	if not self.actionBar.modifierIcon then
		return;
	end

	if IsInputIcon(self.actionBar.modifierIcon) then
		func(self.actionBar.modifierIcon);
	elseif self.actionBar.modifierIcon.InputIcons then
		for _, inputIcon in pairs(self.actionBar.modifierIcon.InputIcons) do
			if IsInputIcon(inputIcon) then
				func(inputIcon);
			end
		end
	end
end

--[[
	Iterates over all action bar slot objects found on an action bar.

	Separates the action by slot type (square / left and circle / right). Primarily
	used to find animations (by name) on ActionBarButton objects.
]]
function GamepadActionBarSequenceMixin:ForEachActionBarSlot(squareSlotFunc, circleSlotFunc)
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		squareSlotFunc(self.actionBar.Left[actionButton]);
		circleSlotFunc(self.actionBar.Right[actionButton]);
	end
end

function GamepadActionBarSequenceMixin:InitAnimations()
	assert(not self.animationsData, "Already initialized animations.");
	self.animationsData = {};
end

--[[
	When animated components are moved around or reparented to new
	action bars, our animation components must be re-initialized.
]]
function GamepadActionBarSequenceMixin:Reinitialize()
	if self:IsPlaying() then
		self:Stop(false);
	end
	self.animationsData = nil;
	self:InitAnimations();
end

function GamepadActionBarSequenceMixin:Start()
	assert(not self:IsPlaying(), "Attempted to Start a sequence that was already playing.");
	self.isPlaying = true;

	local animDuration = 0.0;
	for _, animationData in ipairs(self.animationsData or {}) do
		if not animationData.Condition or animationData.Condition() then
			animDuration = math.max(animDuration, animationData.Animation:GetDuration());
			if animationData.OnStart then
				animationData.OnStart();
			end
			animationData.Animation:Play();
		end
	end

	if animDuration > 0 then
		self.animTimer = C_Timer.NewTimer(animDuration, GenerateClosure(self.Stop, self, true));
	else
		self:Stop();
	end
end

function GamepadActionBarSequenceMixin:IsPlaying()
	return self.isPlaying or self.isLooping;
end

function GamepadActionBarSequenceMixin:Stop(continueLooping)
	assert(self:IsPlaying(), "Attempted to Stop a sequence that was not playing.");
	if self.animTimer then
		self.animTimer:Cancel();
	end

	for _, animationData in ipairs(self.animationsData or {}) do
		if not animationData.Animation:GetLooping() or not continueLooping then
			animationData.Animation:Stop();
		end

		if animationData.OnStop then
			animationData.OnStop(continueLooping);
		end
	end

	self.animTimer = nil;
	self.isPlaying = false;
	self.isLooping = continueLooping;
end

-- Base / abstract class for "collapse" animation sequences.
local GamepadActionBarSequenceCollapseMixin = CreateFromMixins(GamepadActionBarSequenceMixin);

function GamepadActionBarSequenceCollapseMixin:GetSequenceDebugName()
	return "CollapseSequenceStandard";
end

function GamepadActionBarSequenceCollapseMixin:InitAnimations(alwaysShowHighlightAnims)
	GamepadActionBarSequenceMixin.InitAnimations(self);

	local showHighlightClosure = GenerateFlatClosure(IsActionBarHighlightEnabled, alwaysShowHighlightAnims);

	self:ForEachModifierIcon(function(inputIcon)
		if not inputIcon.animatedGlowBottom then
			inputIcon.animatedGlowBottom = AnimStyleFactory:CreateModifierGlowBottom(inputIcon);
		end

		if inputIcon.animatedGlowBottom then
			table.insert(self.animationsData, {
				Animation = inputIcon.animatedGlowBottom.FocusEndAnim,
				Condition = showHighlightClosure,
				OnStart = GenerateClosure(inputIcon.animatedGlowBottom.Show, inputIcon.animatedGlowBottom),
				OnStop = GenerateClosure(inputIcon.animatedGlowBottom.Hide, inputIcon.animatedGlowBottom),
			});
		end
	end);
end

-- Collapse animation sequence specifically used by the primary gameplay action bars.
local GamepadActionBarSequenceGameplayCollapseMixin = CreateFromMixins(GamepadActionBarSequenceCollapseMixin);
function GamepadActionBarSequenceGameplayCollapseMixin:GetSequenceDebugName()
	return "CollapseSequenceGameplay";
end

function GamepadActionBarSequenceGameplayCollapseMixin:Start()
	GamepadActionBarSequenceCollapseMixin.Start(self);
end

-- Collapse animation sequence specifically by edit mode action bars during spell assignment.
local GamepadActionBarSequenceEditModeCollapseMixin = CreateFromMixins(GamepadActionBarSequenceCollapseMixin);

function GamepadActionBarSequenceEditModeCollapseMixin:GetSequenceDebugName()
	return "CollapseSequenceEditMode";
end

function GamepadActionBarSequenceEditModeCollapseMixin:Start()
	self.actionBar.EditModeFocusBackground.AnimEditBgRight:Hide();
	self.actionBar.EditModeFocusBackground.AnimEditBgLeft:Hide();
	self.actionBar.EditModeFocusBackground.EditBackgroundFocus:Hide();
	GamepadActionBarSequenceCollapseMixin.Start(self);
end

function GamepadActionBarSequenceEditModeCollapseMixin:InitAnimations()
	GamepadActionBarSequenceCollapseMixin.InitAnimations(self, true);
end

-- Base / abstract class for "expand" animation sequences.
local GamepadActionBarSequenceExpandMixin = CreateFromMixins(GamepadActionBarSequenceMixin);

function GamepadActionBarSequenceExpandMixin:GetSequenceDebugName()
	return "ExpandSequence";
end

function GamepadActionBarSequenceExpandMixin:InitAnimations(alwaysShowHighlightAnims)
	GamepadActionBarSequenceMixin.InitAnimations(self);

	local showHighlightClosure = GenerateFlatClosure(IsActionBarHighlightEnabled, alwaysShowHighlightAnims);

	self:ForEachModifierIcon(function(inputIcon)
		if not inputIcon.animatedGlowTop then
			inputIcon.animatedGlowTop = AnimStyleFactory:CreateModifierGlowTop(inputIcon);
		end

		if inputIcon.animatedGlowTop then
			table.insert(self.animationsData, {
				Animation = inputIcon.animatedGlowTop.FocusStartAnim,
				Condition = showHighlightClosure,
				OnStart = GenerateClosure(inputIcon.animatedGlowTop.Show, inputIcon.animatedGlowTop),
				OnStop = GenerateClosure(inputIcon.animatedGlowTop.Hide, inputIcon.animatedGlowTop),
			});
		end

		if not inputIcon.animatedGlowBottom then
			inputIcon.animatedGlowBottom = AnimStyleFactory:CreateModifierGlowBottom(inputIcon);
		end

		if inputIcon.animatedGlowBottom then
			table.insert(self.animationsData, {
				Animation = inputIcon.animatedGlowBottom.FocusStartAnim,
				Condition = showHighlightClosure,
				OnStart = GenerateClosure(inputIcon.animatedGlowBottom.Show, inputIcon.animatedGlowBottom),
				OnStop = function(continueLooping)
					if not continueLooping then
						inputIcon.animatedGlowBottom:Hide();
					end
				end
			});
		end
	end);
end

-- Expand animation sequence specifically used by the primary gameplay action bars.
local GamepadActionBarSequenceGameplayExpandMixin = CreateFromMixins(GamepadActionBarSequenceExpandMixin);
function GamepadActionBarSequenceGameplayExpandMixin:GetSequenceDebugName()
	return "ExpandSequenceGameplay";
end

function GamepadActionBarSequenceGameplayExpandMixin:Start()
	GamepadActionBarSequenceExpandMixin.Start(self);
end

function GamepadActionBarSequenceGameplayExpandMixin:InitAnimations()
	GamepadActionBarSequenceExpandMixin.InitAnimations(self);
	self:ForEachActionBarSlot(
		function(squareSlot)
			table.insert(self.animationsData, {
				Animation = squareSlot.GameplayModeSquareFocusStartAnim;
				Condition = IsActionBarHighlightEnabled,
				OnStart = nil,
				OnStop = nil,
			});
		end,
		function(circleSlot)
			table.insert(self.animationsData, {
				Animation = circleSlot.GameplayModeCircleFocusStartAnim;
				Condition = IsActionBarHighlightEnabled,
				OnStart = nil,
				OnStop = nil,
			});
		end
	);
end

-- Expand animation sequence specifically by edit mode action bars during spell assignment.
local GamepadActionBarSequenceEditModeExpandMixin = CreateFromMixins(GamepadActionBarSequenceExpandMixin);

function GamepadActionBarSequenceEditModeExpandMixin:GetSequenceDebugName()
	return "ExpandSequenceEditMode";
end

function GamepadActionBarSequenceEditModeExpandMixin:InitAnimations()
	GamepadActionBarSequenceExpandMixin.InitAnimations(self, true);

	local SlotIsNotPermabound = function(slot)
		return not (slot.PermaboundOverlay and slot.PermaboundOverlay:IsShown());
	end

	self:ForEachActionBarSlot(
		function(squareSlot)
			table.insert(self.animationsData, {
				Animation = squareSlot.EditModeSquareFocusStartAnim,
				Condition = GenerateClosure(SlotIsNotPermabound, squareSlot),
				OnStart = GenerateClosure(squareSlot.SquareGlowFocus.Show, squareSlot.SquareGlowFocus),
				OnStop = GenerateClosure(squareSlot.SquareGlowFocus.Hide, squareSlot.SquareGlowFocus),
			});
		end,
		function(circleSlot)
			table.insert(self.animationsData, {
				Animation = circleSlot.EditModeCircleFocusStartAnim,
				Condition = GenerateClosure(SlotIsNotPermabound, circleSlot),
				OnStart = GenerateClosure(circleSlot.CircleGlowFocus.Show, circleSlot.CircleGlowFocus),
				OnStop = GenerateClosure(circleSlot.CircleGlowFocus.Hide, circleSlot.CircleGlowFocus),
			});
		end
	);

	table.insert(self.animationsData, {
		Animation = self.actionBar.EditModeFocusBackground.EditFocusLeftStart,
		Condition = function()
			local isLeftPermabound, _ = self.actionBar:GetPermaboundState();
			return not isLeftPermabound;
		end,
		OnStart = function()
			self.actionBar.EditModeFocusBackground.AnimEditDustLeft:Show();
			self.actionBar.EditModeFocusBackground.AnimEditBgLeft:Show();
		end,
		OnStop = function(continueLooping)
			self.actionBar.EditModeFocusBackground.AnimEditDustLeft:Hide();
		end,
	});

	table.insert(self.animationsData, {
		Animation = self.actionBar.EditModeFocusBackground.EditFocusRightStart,
		Condition = function()
			local _, isRightPermabound = self.actionBar:GetPermaboundState();
			return not isRightPermabound;
		end,
		OnStart = function()
			self.actionBar.EditModeFocusBackground.AnimEditDustRight:Show();
			self.actionBar.EditModeFocusBackground.AnimEditBgRight:Show();
		end,
		OnStop = function(continueLooping)
			self.actionBar.EditModeFocusBackground.AnimEditDustRight:Hide();
		end,
	});

	table.insert(self.animationsData, {
		Animation = self.actionBar.EditModeFocusBackground.EditFocusAllStart,
		Condition = function()
			local isLeftPermabound, isRightPermabound = self.actionBar:GetPermaboundState();
			return not isLeftPermabound and not isRightPermabound;
		end,
		OnStart = function()
			self.actionBar.EditModeFocusBackground.FocusParticles1:Show();
			self.actionBar.EditModeFocusBackground.FocusParticles2:Show();
			self.actionBar.EditModeFocusBackground.FocusParticles3:Show();
		end,
		OnStop = function(continueLooping)
			if not continueLooping then
				self.actionBar.EditModeFocusBackground.FocusParticles1:Hide();
				self.actionBar.EditModeFocusBackground.FocusParticles2:Hide();
				self.actionBar.EditModeFocusBackground.FocusParticles3:Hide();
			end
		end,
	})

	table.insert(self.animationsData, {
		Animation = self.actionBar.Left.EditModeFocusParticlesSingle.FocusStartAnim,
		Condition = function()
			local isLeftPermabound, isRightPermabound = self.actionBar:GetPermaboundState();
			return not isLeftPermabound and isRightPermabound;
		end,
		OnStart = function()
			self.actionBar.Left.EditModeFocusParticlesSingle:Show();
			self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles1:Show();
			self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles2:Show();
			self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles3:Show();
		end,
		OnStop = function(continueLooping)
			if not continueLooping then
				self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles1:Hide();
				self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles2:Hide();
				self.actionBar.Left.EditModeFocusParticlesSingle.FocusParticles3:Hide();
				self.actionBar.Left.EditModeFocusParticlesSingle:Hide();
			end
		end,
	})

	table.insert(self.animationsData, {
		Animation = self.actionBar.Right.EditModeFocusParticlesSingle.FocusStartAnim,
		Condition = function()
			local isLeftPermabound, isRightPermabound = self.actionBar:GetPermaboundState();
			return isLeftPermabound and not isRightPermabound;
		end,
		OnStart = function()
			self.actionBar.Right.EditModeFocusParticlesSingle:Show();
			self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles1:Show();
			self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles2:Show();
			self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles3:Show();
		end,
		OnStop = function(continueLooping)
			if not continueLooping then
				self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles1:Hide();
				self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles2:Hide();
				self.actionBar.Right.EditModeFocusParticlesSingle.FocusParticles3:Hide();
				self.actionBar.Right.EditModeFocusParticlesSingle:Hide();
			end
		end,
	})
end

function GamepadActionBarSequenceEditModeExpandMixin:Start()
	self.actionBar.EditModeFocusBackground.EditBackgroundFocus:Show();
	GamepadActionBarSequenceExpandMixin.Start(self);
end

local GamepadActionBarFocusFX = {
	GamepadActionBarSequenceGameplayCollapseMixin = GamepadActionBarSequenceGameplayCollapseMixin,
	GamepadActionBarSequenceEditModeCollapseMixin = GamepadActionBarSequenceEditModeCollapseMixin,
	GamepadActionBarSequenceGameplayExpandMixin = GamepadActionBarSequenceGameplayExpandMixin,
	GamepadActionBarSequenceEditModeExpandMixin = GamepadActionBarSequenceEditModeExpandMixin,
};

return GamepadActionBarFocusFX;
