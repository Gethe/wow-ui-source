HouseEditorFrameMixin = {};

function HouseEditorFrame_GetFrame()
	return HouseEditorFrame;
end

function HouseEditorFrame_IsShown()
	return HouseEditorFrame and HouseEditorFrame:IsShown();
end

local HouseEditorFrameLifetimeEvents =
{
	"HOUSE_EDITOR_MODE_CHANGED",
};

local HouseEditorFrameShownEvents =
{
	"HOUSING_DECOR_SELECT_RESPONSE",
};

function HouseEditorFrameMixin:OnLoad()
	self:RegisterEvent("SIMPLE_CHECKOUT_CLOSED");

	self.StoragePanel:SetExpandButton(self.StorageButton);
	self.activeModeFrame = nil;
	self.modeFramesByMode = {
		[Enum.HouseEditorMode.BasicDecor] = self.BasicDecorModeFrame,
		[Enum.HouseEditorMode.Layout] = self.LayoutModeFrame,
		[Enum.HouseEditorMode.Customize] = self.CustomizeModeFrame,
		[Enum.HouseEditorMode.ExpertDecor] = self.ExpertDecorModeFrame,
		[Enum.HouseEditorMode.Cleanup] = self.CleanupModeFrame,
		[Enum.HouseEditorMode.ExteriorCustomization] = self.ExteriorCustomizationModeFrame,
	};

	FrameUtil.RegisterFrameForEvents(self, HouseEditorFrameLifetimeEvents);
	EventRegistry:RegisterCallback("HouseEditor.HouseStorageSetShown", self.HouseStorageSetShown, self);
	
end

function HouseEditorFrameMixin:ShowAfterCheckout()
	self:SetAlpha(1);
end

function HouseEditorFrameMixin:HideForCheckout()
	self:SetAlpha(0);
end

function HouseEditorFrameMixin:OnEvent(event, ...)
	if event == "HOUSE_EDITOR_MODE_CHANGED" then
		local newMode = ...;
		self:OnActiveModeChanged(newMode);
	elseif event == "HOUSING_DECOR_SELECT_RESPONSE" then
		local result = ...;
		self:OnDecorSelectResponse(result);
	elseif event =="SIMPLE_CHECKOUT_CLOSED" then
		self:ShowAfterCheckout();
		EventRegistry:TriggerEvent("HouseEditor.SimpleCheckoutClosed");
	end
end

function HouseEditorFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HouseEditorFrameShownEvents);

	-- We're a panel with area "full" which hides UIParent, so ensure "utility" frames (like UIErrors, StaticPopups, etc) update to use us as top parent
	SetAlternateTopLevelParent(self);

	-- Manually bring over other specific UIParent frames were want to show
	FrameUtil.SetParentMaintainRenderLayering(GameTooltip, self);
	FCF_SetFullScreenFrame(self, ERR_HOUSE_EDITOR_MUST_LEAVE);

	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditor);
	PlaySound(SOUNDKIT.HOUSING_ENTER_DECORATE_MODE);

	local houseEditorActive = true;
	EventRegistry:TriggerEvent("HouseEditor.StateUpdated", houseEditorActive);
end

function HouseEditorFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseEditorFrameShownEvents);

	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditor);

	if C_HouseEditor.IsHouseEditorActive() then
		C_HouseEditor.LeaveHouseEditor();

		if self.activeModeFrame then
			self.activeModeFrame:Hide();
			self.activeModeFrame = nil;
		end
	end

	-- Reset the registered top level parent for util frames
	ClearAlternateTopLevelParent();

	-- Put back all the other UI Parent frames
	FrameUtil.SetParentMaintainRenderLayering(GameTooltip, UIParent);
	FCF_ClearFullScreenFrame();
	PlaySound(SOUNDKIT.HOUSING_EXIT_DECORATE_MODE);

	local houseEditorActive = false;
	EventRegistry:TriggerEvent("HouseEditor.StateUpdated", houseEditorActive);
end

function HouseEditorFrameMixin:GetActiveModeFrame()
	return self.activeModeFrame;
end

function HouseEditorFrameMixin:OnActiveModeChanged(newMode)
	if self.activeModeFrame then
		-- Already active
		if self.activeModeFrame:GetModeType() == newMode then
			return;
		end

		self.activeModeFrame:Hide();
		self.activeModeFrame = nil;
	end

	if self.modeFramesByMode[newMode] then
		if not self:IsShown() then
			ShowUIPanel(self);
		end

		self.activeModeFrame = self.modeFramesByMode[newMode];
		self.activeModeFrame:Show();
	else
		HideUIPanel(self);
	end
end

function HouseEditorFrameMixin:HandleEscape()
	if not StaticPopup_EscapePressed() then
		if not self.activeModeFrame or not self.activeModeFrame:TryHandleEscape() then
			HousingFramesUtil.LeaveHouseEditor()
		end
	end
end

function HouseEditorFrameMixin:OnDecorSelectResponse(result)
	if result ~= Enum.HousingResult.Success then
		UIErrorsFrame:AddExternalErrorMessage(ERR_HOUSING_DECOR_SELECT_FAILED);
	end
end

function HouseEditorFrameMixin:ShowHouseStorage()
	self.StoragePanel:UpdateCollapseState();
end

function HouseEditorFrameMixin:HideHouseStorage()
	self.StoragePanel:Hide();
	self.StorageButton:Hide();
end

function HouseEditorFrameMixin:HouseStorageSetShown(shown)
	if shown then
		self:ShowHouseStorage();
	else
		self:HideHouseStorage();
	end
end

function HouseEditorFrameMixin:ExpandHouseStorage()
	self.StoragePanel:SetCollapsed(false);
end
