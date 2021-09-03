BarberShopMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function BarberShopMixin:OnLoad()
	self:RegisterEvent("BARBER_SHOP_RESULT");
	self:RegisterEvent("BARBER_SHOP_COST_UPDATE");
	self:RegisterEvent("BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE");
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");

	CharCustomizeFrame:AttachToParentFrame(self);

	self.sexButtonPool = CreateFramePool("CHECKBUTTON", self.Sexes, "CharCustomizeSexButtonTemplate");
end

function BarberShopMixin:OnEvent(event, ...)
	if event == "BARBER_SHOP_RESULT" then
		local success = ...;
		if success then
			PlaySound(SOUNDKIT.BARBERSHOP_HAIRCUT);
		end
	elseif event == "BARBER_SHOP_COST_UPDATE" then
		self:UpdatePrice();
	elseif event == "BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE" then
		self:UpdateCharCustomizationFrame();
	elseif event == "BARBER_SHOP_APPEARANCE_APPLIED" then
		self:Cancel();
	elseif event == "BARBER_SHOP_CAMERA_VALUES_UPDATED" then
		self:ResetCharacterRotation();
		CharCustomizeFrame:UpdateCameraMode();
		self:UnregisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
	end
end

function BarberShopMixin:OnShow()
	self.oldErrorFramePointInfo = {UIErrorsFrame:GetPoint()};

	UIErrorsFrame:SetParent(self);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:ClearAllPoints();
	UIErrorsFrame:SetPoint("TOP", self.Sexes, "BOTTOM", 0, 0);

	ActionStatus:SetParent(self);

	self:UpdateSex();

	local reset = true;
	self:UpdateCharCustomizationFrame(reset);

	PlaySound(SOUNDKIT.BARBERSHOP_SIT);
end

function BarberShopMixin:UpdateSex()
	self.sexButtonPool:ReleaseAll();

	local currentCharacterData = C_BarberShop.GetCurrentCharacterData();
	if currentCharacterData then
		CharCustomizeFrame:SetSelectedData(currentCharacterData.raceData, currentCharacterData.sex, C_BarberShop.IsViewingAlteredForm());

		local sexes = {Enum.Unitsex.Male, Enum.Unitsex.Female};
		for index, sexID in ipairs(sexes) do
			local button = self.sexButtonPool:Acquire();
			button:SetSex(sexID, currentCharacterData.sex, index);
			button:Show();
		end
	end

	self.Sexes:MarkDirty();
	self.Sexes:Show();
end

function BarberShopMixin:OnHide()
	UIErrorsFrame:SetParent(UIParent);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:ClearAllPoints();
	UIErrorsFrame:SetPoint(unpack(self.oldErrorFramePointInfo));

	ActionStatus:SetParent(UIParent);

	self:UnregisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
end

function BarberShopMixin:OnKeyDown(key)
	local keybind = GetBindingFromClick(key);
	if key == "ESCAPE" then
		C_BarberShop.Cancel();
	elseif keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" or keybind == "SCREENSHOT" then
		RunBinding(keybind);
	end
end

function BarberShopMixin:Cancel()
	HideUIPanel(self);
	C_BarberShop.Cancel();
end

function BarberShopMixin:Reset()
	C_BarberShop.ResetCustomizationChoices();
	local currentCharacterData = C_BarberShop.GetCurrentCharacterData();
	self:SetCharacterSex(currentCharacterData.sex)
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:ApplyChanges()
	C_BarberShop.ApplyCustomizationChoices();
end

function BarberShopMixin:UpdatePrice()
	local currentCost = C_BarberShop.GetCurrentCost();
	local copperCost = currentCost % 100;
	if copperCost > 0 then
		-- Round any copper cost up to the next silver
		currentCost = currentCost - copperCost + 100;
	end

	self.PriceFrame:SetAmount(currentCost);

	local hasAnyChanges = C_BarberShop.HasAnyChanges();
	self.AcceptButton:SetEnabled(hasAnyChanges);
	self.ResetButton:SetEnabled(hasAnyChanges);
end

function BarberShopMixin:UpdateCharCustomizationFrame(alsoReset)
	local customizationCategoryData = C_BarberShop.GetAvailableCustomizations();
	if not customizationCategoryData then
		-- This means we are calling GetAvailableCustomizations when there is no character component set up. Do nothing
		return;
	end

	if alsoReset then
		CharCustomizeFrame:Reset();
	end

	CharCustomizeFrame:SetCustomizations(customizationCategoryData);

	self:UpdatePrice();
end

function BarberShopMixin:SetCustomizationChoice(optionID, choiceID)
	C_BarberShop.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:ResetCustomizationPreview(clearSavedChoices)
	C_BarberShop.ClearPreviewChoices(clearSavedChoices);
end

function BarberShopMixin:PreviewCustomizationChoice(optionID, choiceID)
	-- It is important that we DON'T call UpdateCharCustomizationFrame here because we want to keep the current selections
	C_BarberShop.PreviewCustomizationChoice(optionID, choiceID);
end

function BarberShopMixin:MarkCustomizationChoiceAsSeen(choiceID)
	C_BarberShop.MarkCustomizationChoiceAsSeen(choiceID);
end

function BarberShopMixin:SaveSeenChoices()
	C_BarberShop.SaveSeenChoices();
end

function BarberShopMixin:GetCurrentCameraZoom()
	return C_BarberShop.GetCurrentCameraZoom();
end

function BarberShopMixin:SetCameraZoomLevel(zoomLevel, keepCustomZoom)
	C_BarberShop.SetCameraZoomLevel(zoomLevel, keepCustomZoom);
end

function BarberShopMixin:ZoomCamera(zoomAmount)
	C_BarberShop.ZoomCamera(zoomAmount);
end

function BarberShopMixin:RotateCharacter(rotationAmount)
	C_BarberShop.RotateCamera(rotationAmount);
end

function BarberShopMixin:ResetCharacterRotation()
	C_BarberShop.ResetCameraRotation();
end

function BarberShopMixin:SetViewingAlteredForm(viewingAlteredForm, resetCategory)
	self:RegisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
	C_BarberShop.SetViewingAlteredForm(viewingAlteredForm);
	self:UpdateCharCustomizationFrame(resetCategory);
end

function BarberShopMixin:SetViewingShapeshiftForm(formID)
	self:RegisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
	C_BarberShop.SetViewingShapeshiftForm(formID);
	self.Sexes:SetShown(formID == nil);
end

function BarberShopMixin:SetModelDressState(dressedState)
	C_BarberShop.SetModelDressState(dressedState);
end

function BarberShopMixin:SetCameraDistanceOffset(offset)
	C_BarberShop.SetCameraDistanceOffset(offset);
end

function BarberShopMixin:RandomizeAppearance()
	C_BarberShop.RandomizeCustomizationChoices();
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:SetCharacterSex(sexID)
	-- We need to reset the zoom and rotation, but only AFTER the model has completed loading and we have the new custom rotation values
	self:RegisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");

	C_BarberShop.SetSelectedSex(sexID);
	self:UpdateSex();
end

BarberShopButtonMixin = {};

function BarberShopButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if self.barberShopOnClickMethod then
		BarberShopFrame[self.barberShopOnClickMethod](BarberShopFrame);
	elseif self.barberShopFunction then
		C_BarberShop[self.barberShopFunction]();
	end
end
