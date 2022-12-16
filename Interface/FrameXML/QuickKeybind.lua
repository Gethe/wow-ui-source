-- All funcions here need a fully qualified name for event handler inheritance to work properly.
QuickKeybindButtonTemplateMixin = {};

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnShow(button, down)
	EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", self.UpdateMouseWheelHandler, self);
	EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", self.UpdateMouseWheelHandler, self);

	self:UpdateMouseWheelHandler();
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnHide(button, down)
	EventRegistry:UnregisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", self.UpdateMouseWheelHandler);
	EventRegistry:UnregisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", self.UpdateMouseWheelHandler);
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnClick(button, down)
	if ( KeybindFrames_InQuickKeybindMode() and button ~= "LeftButton" and button ~= "RightButton") then
		QuickKeybindFrame:OnKeyDown(button);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnEnter()
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:SetSelected(self.commandName, self);
		self:QuickKeybindButtonSetTooltip();
		self.oldUpdateScript = self:GetScript("OnUpdate");
		self:SetScript("OnUpdate", self.QuickKeybindButtonOnUpdate);
		self.changedUpdateScript = true;
		self.QuickKeybindHighlightTexture:SetAlpha(1);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnLeave()
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:SetSelected(nil, nil);
		local idleAlpha = 0.5;
		self.QuickKeybindHighlightTexture:SetAlpha(idleAlpha);
	end
	QuickKeybindTooltip:Hide();
	if ( self.changedUpdateScript ) then
		self:SetScript("OnUpdate", self.oldUpdateScript);
		self.changedUpdateScript = nil;
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnMouseWheel(delta)
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:OnMouseWheel(delta);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonSetTooltip(anchorToGameTooltip)
	if ( self.commandName and KeybindFrames_InQuickKeybindMode() ) then
		local parent = self:GetParent();
		if ( anchorToGameTooltip ) then
			QuickKeybindTooltip:SetOwner(GameTooltip, "ANCHOR_TOP", 0, 10);
		elseif ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			QuickKeybindTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			QuickKeybindTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
		GameTooltip_AddHighlightLine(QuickKeybindTooltip, GetBindingName(self.commandName));
		local key1 = GetBindingKeyForAction(self.commandName);
		if ( key1 ) then
			GameTooltip_AddInstructionLine(QuickKeybindTooltip, key1);
			GameTooltip_AddNormalLine(QuickKeybindTooltip, ESCAPE_TO_UNBIND);
		else
			GameTooltip_AddErrorLine(QuickKeybindTooltip, NOT_BOUND);
			GameTooltip_AddNormalLine(QuickKeybindTooltip, PRESS_KEY_TO_BIND);
		end
		QuickKeybindTooltip:Show();
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnUpdate(elapsed)
	local parent = self:GetParent();
	local tooltipBuffer = 10;
	if ( parent == MultiBarRight or parent == MultiBarLeft ) then
		if ( QuickKeybindTooltip:IsShown() and GameTooltip:IsShown() and QuickKeybindTooltip:GetBottom() < GameTooltip:GetTop() + tooltipBuffer ) then
			local anchorToGameTooltip = true;
			self:QuickKeybindButtonSetTooltip(anchorToGameTooltip);
		end
	end
end

function QuickKeybindButtonTemplateMixin:UpdateMouseWheelHandler()
	local quickKeybindEnabled = KeybindFrames_InQuickKeybindMode();
	if quickKeybindEnabled and (self:GetScript("OnMouseWheel") == nil) then
		self:SetScript("OnMouseWheel", self.QuickKeybindButtonOnMouseWheel);
	elseif not quickKeybindEnabled and (self:GetScript("OnMouseWheel") == self.QuickKeybindButtonOnMouseWheel) then
		self:SetScript("OnMouseWheel", nil);
	end
end

function QuickKeybindButtonTemplateMixin:DoModeChange(isInQuickbindMode)
	self.QuickKeybindHighlightTexture:SetShown(isInQuickbindMode);

	if isInQuickbindMode then
		local atlas = self.quickKeybindHighlightAtlas or "UI-HUD-ActionBar-IconFrame-Mouseover";
		self.QuickKeybindHighlightTexture:SetAtlas(atlas);
	end
end

QuickKeybindFrameMixin = {};

function QuickKeybindFrameMixin:OnLoad()
	self.CancelButton:SetText(CANCEL);
	self.CancelButton:SetScript("OnClick", function(button, buttonName, down)
		self:CancelBinding();
	end);

	self.OkayButton:SetText(OKAY);
	self.OkayButton:SetScript("OnClick", function(button, buttonName, down)
		KeybindListener:Commit();

		HideUIPanel(self);
	end);

	self.DefaultsButton:SetText(RESET_TO_DEFAULT);
	self.DefaultsButton:SetScript("OnClick", function(button, buttonName, down)
		StaticPopup_Show("CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS");
	end);

	self.UseCharacterBindingsButton.Text:SetText(HIGHLIGHT_FONT_COLOR_CODE..CHARACTER_SPECIFIC_KEYBINDINGS..FONT_COLOR_CODE_CLOSE);
	self.UseCharacterBindingsButton:SetScript("OnClick", function(button, buttonName, down)
		-- Button may be re-checked if the binding has been intercepted by a dialog. See OnCharacterBindingsChanged
		-- where the check box will be updated once the backing value is actually updated.
		Settings.TryChangeBindingSet(button);
	end);

	Settings.SetOnValueChangedCallback("PROXY_CHARACTER_SPECIFIC_BINDINGS", self.OnCharacterBindingsChanged, self);

	EventRegistry:RegisterCallback("KeybindListener.UnbindFailed", self.OnKeybindUnbindFailed, self);
	EventRegistry:RegisterCallback("KeybindListener.RebindFailed", self.OnKeybindRebindFailed, self);
	EventRegistry:RegisterCallback("KeybindListener.RebindSuccess", self.OnKeybindRebindSuccess, self);
end

function QuickKeybindFrameMixin:OnCharacterBindingsChanged(setting, value)
	self.UseCharacterBindingsButton:SetChecked(value);
end

function QuickKeybindFrameMixin:OnShow()
	local isCharacterSet = GetCurrentBindingSet() == Enum.BindingSet.Character;
	self.UseCharacterBindingsButton:SetChecked(isCharacterSet);

	self:ClearOutputText();

	self.mouseOverButton = nil;

	self.previousBagBarEnabled = MainMenuBarBagManager:AreBagButtonsEnabled();
	MainMenuBarBagManager:SetBagButtonsEnabled(true);
	ActionButtonUtil.ShowAllActionButtonGrids();
	ActionButtonUtil.ShowAllQuickKeybindButtonHighlights();
	local showQuickKeybindEffects = true;
	-- ACTION BARS TODO: Re-enable these effects with proper art
	--MainMenuBar:SetQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	--MultiActionBar_SetAllQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	ExtraActionBar_ForceShowIfNeeded();
end

function QuickKeybindFrameMixin:OnHide()
	EventRegistry:TriggerEvent("QuickKeybindFrame.QuickKeybindModeDisabled");

	if EditModeManagerFrame:IsEditModeActive() then
		ShowUIPanel(EditModeManagerFrame);
	elseif not GameMenuFrame:IsShown() then
		SettingsPanel:Open();
	end

	MainMenuBarBagManager:SetBagButtonsEnabled(self.previousBagBarEnabled);
	ActionButtonUtil.HideAllActionButtonGrids();
	ActionButtonUtil.HideAllQuickKeybindButtonHighlights();

	local showQuickKeybindEffects = false;
	-- ACTION BARS TODO: Re-enable these effects with proper art
	--MainMenuBar:SetQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	--MultiActionBar_SetAllQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	ExtraActionBar_CancelForceShow();
end

function QuickKeybindFrameMixin:CancelBinding()
	LoadBindings(GetCurrentBindingSet());
	KeybindListener:StopListening();
	HideUIPanel(self);
end

function QuickKeybindFrameMixin:SetSelected(command, actionButton)
	self.mouseOverButton = actionButton;

	if command == nil then
		KeybindListener:StopListening();
	else
		local slotIndex = 1;
		KeybindListener:StartListening(command, slotIndex);
	end
end

function QuickKeybindFrameMixin:OnKeyDown(input)
	local listening = KeybindListener:IsListening();

	local gmkey1, gmkey2 = GetBindingKey("TOGGLEGAMEMENU");
	if (input == gmkey1 or input == gmkey1) and not listening then
		self:CancelBinding();
	elseif input == "ESCAPE" and listening then
		KeybindListener:ClearActionPrimaryBinding();
	else
		KeybindListener:OnKeyDown(input);
	end

	if self.mouseOverButton then
		self.mouseOverButton:QuickKeybindButtonSetTooltip();

		local slotIndex = 1;
		KeybindListener:StartListening(self.mouseOverButton.commandName, slotIndex);
	end
end

function QuickKeybindFrameMixin:OnMouseWheel(delta)
	KeybindListener:OnMouseWheel(delta);

	if self.mouseOverButton then
		self.mouseOverButton:QuickKeybindButtonSetTooltip();
		-- Reselect hovered button
		local slotIndex = 1;
		KeybindListener:StartListening(self.mouseOverButton.commandName, slotIndex);
	end
end

function QuickKeybindFrameMixin:SetOutputText(text)
	self.OutputText:SetText(text);
end

function QuickKeybindFrameMixin:ClearOutputText()
	self.OutputText:SetText(nil);
end

function QuickKeybindFrameMixin:OnKeybindUnbindFailed(action, unbindAction, unbindSlotIndex)
	local errorFormat = unbindSlotIndex == 1 and PRIMARY_KEY_UNBOUND_ERROR or KEY_UNBOUND_ERROR;
	self:SetOutputText(errorFormat:format(GetBindingName(unbindAction)));
end

function QuickKeybindFrameMixin:OnKeybindRebindFailed(action)
	self:SetOutputText(KEYBINDINGFRAME_MOUSEWHEEL_ERROR);
end

function QuickKeybindFrameMixin:OnKeybindRebindSuccess(action)
	self:SetOutputText(KEY_BOUND);
end

function QuickKeybindFrameMixin:OnDragStart()
	self:StartMoving();
end

function QuickKeybindFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end