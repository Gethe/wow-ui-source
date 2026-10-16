GamepadSecureBaseDialogMixin = {};

local GlobalOnLoad;
local GlobalOnShow;
local GlobalOnHide;
local GlobalFocusGamepad;
local GlobalUnfocusGamepad;

function GamepadSecureBaseDialogMixin:GamepadSecureBaseDialog_OnLoad()
	securecallfunction(GlobalOnLoad, self);
end

function GamepadSecureBaseDialogMixin:GamepadSecureBaseDialog_OnShow()
	securecallfunction(GlobalOnShow, self);
end

function GamepadSecureBaseDialogMixin:GamepadSecureBaseDialog_OnHide()
	securecallfunction(GlobalOnHide, self);
end

function GamepadSecureBaseDialogMixin:FocusGamepad()
	securecallfunction(GlobalFocusGamepad, self);
end

function GamepadSecureBaseDialogMixin:UnfocusGamepad()
	securecallfunction(GlobalUnfocusGamepad, self);
end

SwapToGlobalEnvironment();

local function WaitForGlobalAddOn(callback)
	local _, loaded = C_AddOns.IsAddOnLoaded("Blizzard_GamepadSharedUtility");
	if loaded then
		-- If the addon is already loaded, ContinueOnAddOnLoaded is synchrononus. The game client
		-- believes we're still in the secure environment, so calls back into FrameXML will use
		-- the secure environment instead of the global environment. Deferring the call works
		-- around that.
		RunNextFrame(callback);
	else
		EventUtil.ContinueOnAddOnLoaded("Blizzard_GamepadSharedUtility", callback);
	end
end

GlobalOnLoad = function(self)
	local function SetupGamepad()
		self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self);
		self.gamepadFooter:AddStandardSelectPrompt();
		self.gamepadFooter:AddStandardBackPrompt();
		self.gamepadFooter:Finalize();
	end

	local function InitGamepad()
		if self.CloseButton then
			self.CloseButton:Hide();
		end
	end

	local function UninitGamepad()
		if self.CloseButton then
			self.CloseButton:Show();
		end
	end

	WaitForGlobalAddOn(function()
		InputUtil.RegisterForInterfaceTransitions(self);
		InputUtil.RegisterGamepadSetup(self, SetupGamepad);
		InputUtil.RegisterGamepadInit(self, InitGamepad);
		InputUtil.RegisterGamepadUninit(self, UninitGamepad);
	end);
end;

GlobalOnShow = function(self)
	WaitForGlobalAddOn(function()
		if InputUtil.IsGamepadUIEnabled() then
			GamepadMode.FrameControlsManager:FrameShown(self);
		end
	end);
end;

GlobalOnHide = function(self)
	WaitForGlobalAddOn(function()
		if InputUtil.IsGamepadUIEnabled() then
			GamepadMode.FrameControlsManager:FrameHidden(self);
		end
	end);
end;

GlobalFocusGamepad = function(self)
	if self.gamepadFooter then
		self.gamepadFooter:ShowAndActivateBindings();
	end
end;

GlobalUnfocusGamepad = function(self)
	if self.gamepadFooter then
		self.gamepadFooter:HideAndDeactivateBindings();
	end
end
