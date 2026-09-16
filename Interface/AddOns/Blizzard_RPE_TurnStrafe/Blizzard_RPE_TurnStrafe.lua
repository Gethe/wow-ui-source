StaticPopupDialogs["RPE_TURNSTRAFE_CHANGED"] = {
	text = RPE_TURNSTRAFE_CHANGED,
	button1 = RPE_TURNSTRAFE_REVIEW,
	button2 = CLOSE,
	OnAccept = function(dialog, data)
		local keybindsCategory = SettingsPanel:GetCategory(Settings.KEYBINDINGS_CATEGORY_ID);
		local keybindsLayout = SettingsPanel:GetLayout(keybindsCategory);
		for _, initializer in keybindsLayout:EnumerateInitializers() do
			if initializer.data.name == BINDING_HEADER_MOVEMENT then
				initializer.data.expanded = true;
				Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, BINDING_HEADER_MOVEMENT);
				return;
			end
		end
	end,
	whileDead = 1,
};

RPETurnStrafeStyleMixin = CreateFromMixins(GameDialogBaseMixin);

function RPETurnStrafeStyleMixin:OnLoad()
	GameDialogBaseMixin.OnLoad(self);

	self.CloseButton:Show();
	self.CloseButton:SetScript("OnClick", function()
		StaticPopupSpecial_Hide(self);
	end);

	self.LegacyFrame.Title:SetText(RPE_TURNSTRAFE_LEGACY);
	self.LegacyFrame.SubTitle:SetText(RPE_TURNSTRAFE_LEGACY_DESC);
	self.LegacyFrame.ActivateButton:SetScript("OnClick", function()
		self:SetActiveStyle(Enum.TurnStrafeStyle.Legacy);
	end);

	self.ModernFrame.Title:SetText(RPE_TURNSTRAFE_MODERN);
	self.ModernFrame.SubTitle:SetText(RPE_TURNSTRAFE_MODERN_DESC);
	self.ModernFrame.ActivateButton:SetScript("OnClick", function()
		self:SetActiveStyle(Enum.TurnStrafeStyle.Modern);
	end);

	local isCharacterSet = GetCurrentBindingSet() == Enum.BindingSet.Character;
	if isCharacterSet then
		self.SubTitle:SetText(RPE_TURNSTRAFE_AFFECT_CHARACTER);
	else
		self.SubTitle:SetText(RPE_TURNSTRAFE_AFFECT_ACCOUNT);
	end

	-- In case the subtitle wraps in other locales
	self:SetHeight(248 + self.SubTitle:GetHeight());

	self:Refresh();
end

function RPETurnStrafeStyleMixin:OnShow()
	self:RegisterEvent("UPDATE_BINDINGS");
end

function RPETurnStrafeStyleMixin:OnHide()
	self:UnregisterEvent("UPDATE_BINDINGS");
end

function RPETurnStrafeStyleMixin:OnEvent()
	self:Refresh();
end

function RPETurnStrafeStyleMixin:SetActiveStyle(style)
	C_KeyBindings.SetTurnStrafeStyle(style);
	SaveBindings(GetCurrentBindingSet());
end

function RPETurnStrafeStyleMixin:Refresh()
	local style = C_KeyBindings.GetTurnStrafeStyle();
	if style == Enum.TurnStrafeStyle.Modern then
		self.LegacyFrame.ActiveLabel:Hide();
		self.LegacyFrame.ActivateButton:Show();
		self.ModernFrame.ActiveLabel:Show();
		self.ModernFrame.ActivateButton:Hide();
	elseif style == Enum.TurnStrafeStyle.Legacy then
		self.ModernFrame.ActiveLabel:Hide();
		self.ModernFrame.ActivateButton:Show();
		self.LegacyFrame.ActiveLabel:Show();
		self.LegacyFrame.ActivateButton:Hide();
	else
		StaticPopupSpecial_Hide(self);
	end	
end

do
	local function OnNotify()
		EventRegistry:UnregisterFrameEventAndCallback("NOTIFY_TURN_STRAFE_CHANGE", RPETurnStrafeStyleMixin);

		local style = C_KeyBindings.GetTurnStrafeStyle();
		if style == Enum.TurnStrafeStyle.Custom then
			StaticPopup_Show("RPE_TURNSTRAFE_CHANGED");
		else
			local frame = CreateFrame("FRAME", nil, UIParent, "RPETurnStrafeStyleFrameTemplate");
			StaticPopupSpecial_Show(frame);
		end
	end

	local function UpdateBindings()
		EventRegistry:RegisterFrameEventAndCallback("NOTIFY_TURN_STRAFE_CHANGE", OnNotify, RPETurnStrafeStyleMixin);
		C_KeyBindings.UpdateTurnStrafeBindingsForCharacter();
	end

	EventUtil.ContinueAfterAllEvents(UpdateBindings, "PLAYER_ENTERING_WORLD", "VARIABLES_LOADED", "BINDINGS_LOADED");
end
