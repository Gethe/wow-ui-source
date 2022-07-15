KeybindListener = CreateFrame("Button");

function KeybindListener:OnKeyDown(key)
	self:ProcessInput(key);
end

function KeybindListener:OnGamePadButtonDown(key)
	self:ProcessInput(key);
end

function KeybindListener:OnClick(key)
end

function KeybindListener:OnMouseWheel(delta)
	self:OnKeyDown(delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN");
end

function KeybindListener:OnForwardMouseWheel(delta)
	if self:IsListening() then
		self:OnMouseWheel(delta);
		return true;
	end
	return false;
end

function KeybindListener:SetListening(listen)
	if listen then
		self:SetScript("OnKeyDown", self.OnKeyDown);
		self:SetScript("OnGamePadButtonDown", self.OnGamePadButtonDown);
		self:SetScript("OnClick", self.OnClick);
		self:SetScript("OnMouseWheel", self.OnMouseWheel);
	else
		self:SetScript("OnKeyDown", nil);
		self:SetScript("OnGamePadButtonDown", nil);
		self:SetScript("OnClick", nil);
		self:SetScript("OnMouseWheel", nil);
	end
end

function KeybindListener:StartListening(action, slotIndex)
	self.pending = { action = action, slotIndex = slotIndex };
	self:SetListening(true);

	EventRegistry:TriggerEvent("KeybindListener.StartedListening", action, slotIndex);
end

function KeybindListener:StopListening()
	if not self:IsListening() then
		return;
	end

	local oldAction, oldSlotIndex = nil;
	if self.pending then
		oldAction = self.pending.action;
		oldSlotIndex = self.pending.slotIndex;
	end
	self.pending = nil;
	self:SetListening(false);

	EventRegistry:TriggerEvent("KeybindListener.StoppedListening", oldAction, oldSlotIndex);
end

function KeybindListener:IsListening()
	return self.pending ~= nil;
end

local function ClearBindingsForKeys(...)
	for i = 1, select("#", ...) do
		local key = select(i, ...);
		if key then
			SetBinding(key, nil);
		end
	end
end

function KeybindListener:ProcessInput(input)
	local pending = self.pending;
	if not pending then
		return false;
	end

	local currentAction = GetBindingFromClick(input);
	if currentAction == "SCREENSHOT" then
		RunBinding("SCREENSHOT");
		return false;
	end

	local action = pending.action;
	if input == "ESCAPE" and currentAction == "TOGGLEGAMEMENU" then
		self:StopListening();
		return false;
	end

	local key = GetConvertedKeyOrButton(input);
	if IsKeyPressIgnoredForBinding(key) then
		return false;
	end

	self:StopListening();

	-- Unbind the current action
	local slotIndex = pending.slotIndex;
	local key1, key2 = GetBindingKey(action);
	ClearBindingsForKeys(key1, key2);

	local newKey = CreateKeyChordStringUsingMetaKeyState(key);
	local unbindUnconflicted, unbindSlotIndex, unbindAction = self:UnbindKey(newKey, action);
	local rebindSuccess = self:RebindKeysInOrder(newKey, slotIndex, action, key1, key2);

	if not unbindUnconflicted then
		EventRegistry:TriggerEvent("KeybindListener.UnbindFailed", action, unbindAction, unbindSlotIndex);
	elseif not rebindSuccess then
		EventRegistry:TriggerEvent("KeybindListener.RebindFailed", action);
	else
		EventRegistry:TriggerEvent("KeybindListener.RebindSuccess", action);
	end

	return true;
end

function KeybindListener:UnbindKey(newKey, action)
	local conflicted, conflictedSlotIndex;
	local oldAction = GetBindingAction(newKey);
	if oldAction ~= "" and oldAction ~= action then
		local key1, key2 = GetBindingKey(oldAction);
		if key1 == newKey and key2 then
			conflicted = true;
			conflictedSlotIndex = 1;
		elseif (not key1 or key1 == newKey) and (not key2 or key2 == newKey) then
			conflicted = true;
			conflictedSlotIndex = 2;
		end
	end
	SetBinding(newKey, nil);

	return not conflicted, conflictedSlotIndex, oldAction;
end

function KeybindListener:Commit()
	SaveBindings(GetCurrentBindingSet());
end

function KeybindListener:ClearActionPrimaryBinding()
	if not self:IsListening() then
		return;
	end

	local action = self.pending.action;
	local key1, key2 = GetBindingKey(action);
	if key1 then
		SetBinding(key1, nil);
	end

	if key2 then
		SetBinding(key2, action);
	end
end

function KeybindListener:SetBinding(newKey, action, oldKey)
	local failed = nil;
	if not SetBinding(newKey, action) then
		if oldKey then
			SetBinding(oldKey, action);
		end
		failed = true;
	end
	return not failed;
end

function KeybindListener:RebindKeysInOrder(key, slotIndex, action, ...)
	local failed = nil;
	for i = 1, select("#", ...) do
		local currentKey = select(i, ...);
		local keyToBind = (i == slotIndex) and key or currentKey;
		if keyToBind then
			if not self:SetBinding(keyToBind, action, currentKey) then
				failed = true;
			end
		end
	end
	return not failed;
end

function KeybindListener:ResetBindingsToDefault()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:StopListening();

	LoadBindings(Enum.BindingSet.Default);
	SaveBindings(GetCurrentBindingSet());
end

local customKeybindings = {};

function SaveAllCustomBindings(shouldSave)
	for customBindingType in pairs(customKeybindings) do
		CustomBindingManager:OnDismissed(customBindingType, shouldSave);
	end
end

function DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys)
	if IsMacClient() then
		local hasNonMetaKey = false;
		for i, key in ipairs(keys) do
			if not IsMetaKey(key) then
				hasNonMetaKey = true;
				break;
			end
		end
		if hasNonMetaKey then
			if not MacOptions_IsInputMonitoringEnabled() then
				ShowAppropriateDialog("MAC_OPEN_INPUT_MONITORING");
				return true;
			end
		end
	end
	return false;
end

function CreateVoicePushToTalkBindingHandler()
	local handler = CustomBindingHandler:CreateHandler(Enum.CustomBindingType.VoicePushToTalk);

	handler:SetOnBindingModeActivatedCallback(function(isActive)
		if isActive then
			local slotIndex = 1;
			SettingsPanel:OnKeybindStartedListening("TOGGLE_VOICE_PUSH_TO_TALK", slotIndex);
		end
	end);

	handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
		if completedSuccessfully then
			SettingsPanel:OnKeybindRebindSuccess("TOGGLE_VOICE_PUSH_TO_TALK");
		else
			SettingsPanel:ClearOutputText();
		end

		local requiredDialog = false;
		if completedSuccessfully and keys then
			requiredDialog = DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys);
		end

		if not requiredDialog then
			SaveAllCustomBindings(true);
		else
			-- FIXME save on mac ua response
		end
	end);

	return handler;
end

local function GetOrCreateCustomKeybindingButton(customBindingType)
	if not customBindingType then
		return nil;
	end

	local button = customKeybindings[customBindingType];
	if not button then
		if customBindingType == Enum.CustomBindingType.VoicePushToTalk then
			local handler = CreateVoicePushToTalkBindingHandler();
			button = CustomBindingManager:RegisterHandlerAndCreateButton(handler, "CustomBindingButtonTemplate", KeyBindingFrame);
		end

		customKeybindings[customBindingType] = button;
	end

	return button;
end

KeyBindingFrameBindingTemplateMixin = {};

local KeyBindingFrameBindingTemplateEvents = {
	"UPDATE_BINDINGS",
};

function KeyBindingFrameBindingTemplateMixin:OnLoad()
	self.cbrHandles = Settings.CreateCallbackHandleContainer();
end

function KeyBindingFrameBindingTemplateMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, KeyBindingFrameBindingTemplateEvents);
end

function KeyBindingFrameBindingTemplateMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, KeyBindingFrameBindingTemplateEvents);
end

function KeyBindingFrameBindingTemplateMixin:OnEvent()
	if event == "UPDATE_BINDINGS" then
		self:RenewBindings();
	end
end

function KeyBindingFrameBindingTemplateMixin:UpdateBindingState(initializer)
	local bindingIndex = initializer.data.bindingIndex;
	local action, category, binding1, binding2 = GetBinding(bindingIndex);

	for index, button in ipairs(self.Buttons) do
		button:SetSelected(initializer.selectedIndex == index);
	end

	if self.CustomButton then
		binding1, binding2 = nil, nil;
		BindingButtonTemplate_SetupBindingButton(nil, self.CustomButton);
	end

	BindingButtonTemplate_SetupBindingButton(binding1, self.Button1);
	BindingButtonTemplate_SetupBindingButton(binding2, self.Button2);

end

function KeyBindingFrameBindingTemplateMixin:Init(initializer)
	self.initializer = initializer;

	local bindingIndex = initializer.data.bindingIndex;
	local action, category, binding1, binding2 = GetBinding(bindingIndex);

	local labelIndent = (initializer.data.search and 37) or 37;
	self.Label:SetPoint("LEFT", labelIndent, 0);
	self.Label:SetText(GetBindingName(action));
	
	self.CustomButton = GetOrCreateCustomKeybindingButton(C_KeyBindings.GetCustomBindingType(bindingIndex));
	if self.CustomButton then
		CustomBindingManager:SetHandlerRegistered(self.CustomButton, true);

		self.CustomButton:SetParent(self);
		self.CustomButton:ClearAllPoints();
		self.CustomButton:SetAllPoints(self.Button1);
		self.CustomButton:Show();

		self.CustomButton.selectedHighlight:SetWidth(self.Button1:GetWidth());
	end

	self.Button1:SetParent(self);
	self.Button2:SetParent(self);
	self.Button1:SetShown(not self.CustomButton);
	self.Button2:SetEnabled(not self.CustomButton);
	
	for index, button in ipairs(self.Buttons) do
		button:SetScript("OnClick", function(button, buttonName, down)
			if buttonName == "LeftButton" or buttonName == "RightButton" then
				local oldSelected = initializer.selectedIndex == index;
				KeybindListener:StopListening();

				if not oldSelected then
					initializer.selectedIndex = index;
					button:SetSelected(true);
					KeybindListener:StartListening(action, index);
				end
			else
				KeybindListener:ProcessInput(buttonName);
				return;
			end
		end);
	end

	self.cbrHandles:RegisterCallback(EventRegistry, "Settings.ReparentBindingsToInputBlocker", self.ReparentBindingsToInputBlocker, self);
	self.cbrHandles:RegisterCallback(EventRegistry, "Settings.UnparentBindingsToInputBlocker", self.UnparentBindingsToInputBlocker, self);
	self.cbrHandles:RegisterCallback(EventRegistry, "Settings.UpdateKeybinds", self.RenewBindings, self);

	self:UpdateBindingState(initializer);
end

function KeyBindingFrameBindingTemplateMixin:ReparentBindingsToInputBlocker(inputBlocker)
	if self:IsShown() then
		if self.Button1:IsShown() then
			self.Button1:SetParent(inputBlocker);
		end
		if self.Button2:IsShown() then
			self.Button2:SetParent(inputBlocker);
		end
		if self.CustomButton and self.CustomButton:IsShown() then
			self.CustomButton:SetParent(inputBlocker);
		end
	end
end

function KeyBindingFrameBindingTemplateMixin:UnparentBindingsToInputBlocker(inputBlocker)
	self.Button1:SetParent(self);
	self.Button2:SetParent(self);
	if self.CustomButton then
		self.CustomButton:SetParent(self);
	end
end

function KeyBindingFrameBindingTemplateMixin:Release()
	if self.CustomButton then
		CustomBindingManager:SetHandlerRegistered(self.CustomButton, false);

		self.CustomButton:SetParent(nil);
		self.CustomButton:ClearAllPoints();
		self.CustomButton:Hide();
		self.CustomButton = nil;
	end

	self.Button1:SetParent(self);
	self.Button2:SetParent(self);

	self.cbrHandles:Unregister();
end

function KeyBindingFrameBindingTemplateMixin:RenewBindings()
	self:ClearSelections();
	self:UpdateBindingState(self.initializer);
end

function KeyBindingFrameBindingTemplateMixin:ClearSelections()
	self.initializer.selectedIndex = nil;

	for index, button in ipairs(self.Buttons) do
		button:SetSelected(false);
	end
end

function CreateKeybindingEntryInitializer(bindingIndex, search)
	local data = {bindingIndex = bindingIndex, search = search};
	local initializer = Settings.CreateElementInitializer("KeyBindingFrameBindingTemplate", data);
	local oldMatchesSearchTags = initializer.MatchesSearchTags;

	initializer.GetBindingText = function(self, bindingIndex, actionIndex)
		local action, category, binding1, binding2 = GetBinding(bindingIndex);
		if actionIndex == 1 then
			return GetBindingText(binding1);
		else
			return GetBindingText(binding2);
		end
		assert(false);
	end;

	initializer.MatchesSearchTags = function(self, words)
		if oldMatchesSearchTags(self, words) then
			return true;
		end
	
		local bindingIndex = self.data.bindingIndex;
		for actionIndex = 1, 2 do
			for _, word in ipairs(words) do
				local bindingText = self:GetBindingText(bindingIndex, actionIndex);
				if string.find(bindingText, word, nil, true) then
					return true;
				end
			end
		end
		return false;
	end;
	return initializer;
end

KeyBindingButtonMixin = {};

function KeyBindingButtonMixin:SetSelected(selected)
	self.SelectedHighlight:SetShown(selected);
	self:GetHighlightTexture():SetAlpha(selected and 0 or 1);
end

function KeyBindingButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
end
