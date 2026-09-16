GlueMenuFrameMixin = {};

function GlueMenuFrameMixin:OnLoad()
	MainMenuFrameMixin.OnLoad(self);

	self.buttons = {};

	self:RegisterForTransitions();
end

function GlueMenuFrameMixin:OnShow()
	self:InitButtons();
	BaseLayoutMixin.OnShow(self);

	NarrationUtil.NarrateCurrentScreen(NARRATION_CONTEXT_GAME_MENU);

	GlueParent_AddModalFrame(self);

	if InputUtil.IsGamepadUIEnabled() then
		self.gamepadFooter:ShowAndActivateBindings();
	end
end

function GlueMenuFrameMixin:OnHide()
	GlueParent_RemoveModalFrame(self);

	if InputUtil.IsGamepadUIEnabled() then
		self:ResetGamepadButtons();
		self.gamepadFooter:HideAndDeactivateBindings();
	end
end

function GlueMenuFrameMixin:InitButtons()
	self.buttons = {};
	self.closeButton = nil;

	if (GlueParent_GetCurrentScreen() == "charselect") or (GlueParent_GetCurrentScreen() == "wowhack") then
		self:InitCharacterSelectButtons();
	else
		self:InitAccountLoginButtons();
	end

	self:SetupGamepadButtons();
end

function GlueMenuFrameMixin:SetupGamepadButtons()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if #self.buttons <= 1 then
		return;
	end

	SmartNavigation_AddBidirectionalJumpNavigationOverride(self.buttons[1], SMART_NAV_INPUT_DIRECTION.UP,
														   self.buttons[#self.buttons], SMART_NAV_INPUT_DIRECTION.DOWN);
end

function GlueMenuFrameMixin:AddButton(...)
	local button = MainMenuFrameMixin.AddButton(self, ...);
	table.insert(self.buttons, button);
	return button;
end

function GlueMenuFrameMixin:AddCloseButton(...)
	if InputUtil.IsGamepadUIEnabled() then
		return nil;
	end
	return MainMenuFrameMixin.AddCloseButton(self, ...);
end

function GlueMenuFrameMixin:GenerateMenuCallback(callback)
	return function()
		self:Hide();
		callback();
	end;
end

function GlueMenuFrameMixin:InitAccountLoginButtons()
	self:Reset();

	self:AddButton(GAMEMENU_OPTIONS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowOptionsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));

	self:AddSection();

	self:AddButton(CREDITS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCreditsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(CINEMATICS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCinematicsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(MANAGE_ACCOUNT, self:GenerateMenuCallback(GenerateFlatClosure(AccountLogin_ManageAccount, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(COMMUNITY_SITE, self:GenerateMenuCallback(GenerateFlatClosure(AccountLogin_LaunchCommunitySite, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(EXIT_GAME, GenerateFlatClosure(QuitGame));

	self.closeButton = self:AddCloseButton();
end

function GlueMenuFrameMixin:InitCharacterSelectButtons()
	self:Reset();

	self:AddButton(GAMEMENU_OPTIONS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowOptionsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));

	local isStoreDisabled = not CharacterSelectUtil.ShouldStoreBeEnabled();
	self:AddButton(BLIZZARD_STORE, self:GenerateMenuCallback(GenerateFlatClosure(ToggleStoreUI, GlueMenuFrameUtil.GlueMenuContextKey)), isStoreDisabled);

	self:AddSection();

	if C_AddOns.GetNumAddOns() > 0 then
		local function ShowAddOnList()
			self:Hide();
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			AddonList:Show();
		end

		self:AddButton(ADDONS, ShowAddOnList);
	end

	self:AddButton(CREDITS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCreditsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(CINEMATICS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCinematicsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(EXIT_GAME, GenerateFlatClosure(QuitGame));

	self.closeButton = self:AddCloseButton();
end

function GlueMenuFrameMixin:SmartNavigationCloseHandler()
	self:CloseMenu();
	return true;
end

function GlueMenuFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function GlueMenuFrameMixin:SetupGamepad()
	local selectPromptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, ACTION_LABEL_SELECT);

	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "GlueMenuFooter");
	self.gamepadFooter:AddPromptedBinding(selectPromptedBinding);
	self.gamepadFooter:AddStandardBackPrompt(CLOSE);
	self.gamepadFooter:SetAnchorOffsets(6, 0);

	self.gamepadFooter:Finalize();
end

function GlueMenuFrameMixin:UninitializeGamepad()
	self:ResetGamepadButtons();
end

function GlueMenuFrameMixin:ResetGamepadButtons()
	for _,v in ipairs(self.buttons) do
		SmartNavigation_ClearJumpNavigationOverrides(v);
	end
end
