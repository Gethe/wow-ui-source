local BaseHouseEditorModesBarShownEvents = {
	"UPDATE_BINDINGS",
};

BaseHouseEditorModesBarMixin = {};

function BaseHouseEditorModesBarMixin:OnEvent(event, ...)
	if event == "UPDATE_BINDINGS" then
		self:UpdateButtonBindings();
	end
end

function BaseHouseEditorModesBarMixin:OnShow()
	self:UpdateButtonStates();
	FrameUtil.RegisterFrameForEvents(self, BaseHouseEditorModesBarShownEvents);
end

function BaseHouseEditorModesBarMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BaseHouseEditorModesBarShownEvents);
end

function BaseHouseEditorModesBarMixin:UpdateButtonStates()
	for _, button in ipairs(self.Buttons) do
		if button:IsShown() then
			button:UpdateState();
		end
	end
	self:Layout();
end

function BaseHouseEditorModesBarMixin:UpdateButtonBindings()
	for _, button in ipairs(self.Buttons) do
		button:UpdateKeybind();
	end
end


local HouseEditorModesBarShownEvents = {
	"HOUSE_EDITOR_AVAILABILITY_CHANGED",
	"HOUSE_EDITOR_MODE_CHANGED",
	"HOUSE_INFO_UPDATED",
};

HouseEditorModesBarMixin = CreateFromMixins(BaseHouseEditorModesBarMixin);
function HouseEditorModesBarMixin:OnEvent(event, ...)
	BaseHouseEditorModesBarMixin.OnEvent(self, event, ...);
	if event == "HOUSE_INFO_UPDATED" or event == "HOUSE_EDITOR_MODE_CHANGED" or event == "HOUSE_EDITOR_AVAILABILITY_CHANGED" then
		self:UpdateButtonStates();
	end
end

function HouseEditorModesBarMixin:OnShow()
	local isInsideHouse = C_Housing.IsInsideHouse();
	self.LayoutModeButton:SetShown(isInsideHouse);
	self.ExteriorCustomizationModeButton:SetShown(not isInsideHouse);
	
	BaseHouseEditorModesBarMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, HouseEditorModesBarShownEvents);
end

function HouseEditorModesBarMixin:OnHide()
	BaseHouseEditorModesBarMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, HouseEditorModesBarShownEvents);
end

HouseEditorSubmodesBarMixin = CreateFromMixins(BaseHouseEditorModesBarMixin);


-- Inherits BaseHousingModeButtonMixin
BaseHouseEditorModeButtonMixin = {};

function BaseHouseEditorModeButtonMixin:IsActive()
	return C_HouseEditor.IsHouseEditorModeActive(self.editorMode);
end

function BaseHouseEditorModeButtonMixin:GetDefaultTexture()
	return self.iconDefault, true;
end

function BaseHouseEditorModeButtonMixin:GetIconForState(state)
	-- Overrides BaseHousingActionButtonMixin
	local iconName = self.iconDefault;
	local isAtlas = true;

	if state.isEnabled then
		if state.isPressed then
			iconName = self.iconPressed;
		elseif state.isActive then
			iconName = self.iconActive;
		end
	end

	return iconName, isAtlas;
end

function BaseHouseEditorModeButtonMixin:GetIconColorForState(state)
	-- Overrides BaseHousingActionButtonMixin
	return state.isEnabled and WHITE_FONT_COLOR or DARKGRAY_COLOR;
end

HouseEditorModeButtonMixin = CreateFromMixins(BaseHouseEditorModeButtonMixin);

function HouseEditorModeButtonMixin:CheckEnabled()
	-- TODO: Remove temp NYI handler once all modes have been implemented
	if self.notYetImplemented then
		return false, self.modeName.." Not Yet Implemented";
	end

	if not HousingTutorialUtil.IsModeValidForTutorial(self.editorMode) and not HousingTutorialUtil.HousingQuestTutorialComplete() then
		return false, HOUSE_EDITOR_MODE_UNAVAILABLE_ERROR_FMT:format(self.modeName, ERR_HOUSING_RESULT_NOT_IN_TUTORIAL);
	end

	if not self:IsShown() then
		return false;
	end

	local disabledTooltip = nil;
	local availabilityResult = C_HouseEditor.GetHouseEditorModeAvailability(self.editorMode);
	local canActivate = availabilityResult == Enum.HousingResult.Success;
	if not canActivate then
		local errorText = HousingResultToErrorText[availabilityResult];
		if errorText then
			disabledTooltip = HOUSE_EDITOR_MODE_UNAVAILABLE_ERROR_FMT:format(self.modeName, errorText);
		else
			disabledTooltip = HOUSE_EDITOR_MODE_UNAVAILABLE_FMT:format(self.modeName);
		end
	end
	return canActivate, disabledTooltip;
end

function HouseEditorModeButtonMixin:EnterMode()
	C_HouseEditor.ActivateHouseEditorMode(self.editorMode);
end

function HouseEditorModeButtonMixin:LeaveMode()
	-- These are not toggled off
	return;
end

function HouseEditorModeButtonMixin:PlayEnterSound()
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_MENU_BUTTON);
end

function HouseEditorModeButtonMixin:UpdateCustomVisuals(state)
	if not self.shouldPlayActivateAnim then
		return;
	end

	if state.isActive and not self.activateVisualPlayed then
		self.ModeSwitchFlipbookTexture:Show();
		self.ModeSwitchFlipbookAnim:Play();
	end

	if not state.isActive then
		self.ModeSwitchFlipbookAnim:Stop();
		self.ModeSwitchFlipbookTexture:Hide();

		self.activateVisualPlayed = false;
	else
		self.activateVisualPlayed = true;
	end
end

HouseEditorSubmodeButtonMixin = CreateFromMixins(BaseHouseEditorModeButtonMixin);

function HouseEditorSubmodeButtonMixin:CheckEnabled()
	return true;
end

function HouseEditorSubmodeButtonMixin:UpdateCustomVisuals(state)
	if self.glowMaskKey then
		self.ActiveGlow:SetShown(state.isActive);

		local atlas = string.format("decor-ability-%s-mask", self.glowMaskKey);
		self.ActiveGlowMask:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		self.ActiveGlowMask:SetShown(state.isActive);

		if state.isActive then
			self.ActiveGlowAnim:PlaySynced();
		else
			self.ActiveGlowAnim:Stop();
		end
	end
end

function HouseEditorSubmodeButtonMixin:PlayEnterSound()
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_SUB_MENU_BUTTON_TOGGLE);
end


-- TODO: Remove this once all submode buttons have been updated or removed
HouseEditorOLDSubmodeButtonMixin = CreateFromMixins(BaseHouseEditorModeButtonMixin);

function HouseEditorOLDSubmodeButtonMixin:CheckEnabled()
	return true;
end

function HouseEditorOLDSubmodeButtonMixin:GetDefaultTexture()
	if self.iconTexture then
		return self.iconTexture, false;
	end
	if self.iconAtlas then
		return self.iconAtlas, true;
	end
end

function HouseEditorOLDSubmodeButtonMixin:GetIconColorForState(state)
	return BaseHousingActionButtonMixin.GetIconColorForState(self, state);
end

function HouseEditorOLDSubmodeButtonMixin:PlayEnterSound()
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_SUB_MENU_BUTTON_TOGGLE);
end
