BarberShopMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function BarberShopMixin:OnLoad()
	self:RegisterEvent("BARBER_SHOP_RESULT");
	self:RegisterEvent("BARBER_SHOP_COST_UPDATE");
	self:RegisterEvent("BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE");
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");

	CharCustomizeFrame:AttachToParentFrame(self);

	self.sexButtonPool = CreateFramePool("CHECKBUTTON", self.BodyTypes, "CharCustomizeBodyTypeButtonTemplate");
end

function BarberShopMixin:OnEvent(event, ...)
	if event == "BARBER_SHOP_RESULT" then
		local success = ...;
		if success then
			if (C_BarberShop.GetCustomizationScope() == Enum.CustomizationScope.DragonCompanion) then
				PlaySound(SOUNDKIT.BARBERSHOP_DRAGONRIDING_ACCEPT);
			else
				PlaySound(SOUNDKIT.BARBERSHOP_DEFAULT_ACCEPT);
			end
		end
	elseif event == "BARBER_SHOP_COST_UPDATE" then
		self:UpdateButtons();
	elseif event == "BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE" then
		self:UpdateCharCustomizationFrame();
	elseif event == "BARBER_SHOP_APPEARANCE_APPLIED" then
		if (CollectionsJournal and C_BarberShop.GetCustomizationScope() == Enum.CustomizationScope.DragonCompanion) then
			MountJournal_SetPendingDragonMountChanges(true);
		end
		self:Cancel();
	elseif event == "BARBER_SHOP_CAMERA_VALUES_UPDATED" then
		self:ResetCharacterRotation();
		CharCustomizeFrame:UpdateCameraMode();
		self:UnregisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
	end
end

function BarberShopMixin:OnShow()
	self.oldErrorFramePointInfo = {UIErrorsFrame:GetPoint(1)};

	UIErrorsFrame:SetParent(self);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:ClearAllPoints();
	UIErrorsFrame:SetPoint("TOP", self.BodyTypes, "BOTTOM", 0, 0);

	ActionStatus:SetParent(self);

	self:UpdateSex();

	local reset = true;
	self:UpdateCharCustomizationFrame(reset);

	if (C_BarberShop.GetCustomizationScope() == Enum.CustomizationScope.DragonCompanion) then
		PlaySound(SOUNDKIT.BARBERSHOP_DRAGONRIDING_OPEN);
	else
		PlaySound(SOUNDKIT.BARBERSHOP_DEFAULT_OPEN);
	end
end

function BarberShopMixin:UpdateSex()
	self.sexButtonPool:ReleaseAll();

	local currentCharacterData = C_BarberShop.GetCurrentCharacterData();
	if currentCharacterData then
		CharCustomizeFrame:SetSelectedData(currentCharacterData, currentCharacterData.sex, C_BarberShop.IsViewingAlteredForm());

		local sexes = {Enum.UnitSex.Male, Enum.UnitSex.Female};
		for index, sexID in ipairs(sexes) do
			local button = self.sexButtonPool:Acquire();
			button:SetBodyType(sexID, currentCharacterData.sex, index);
			button:Show();
		end
	end

	if C_BarberShop.GetViewingChrModel() then
		self.BodyTypes:Hide();
	else
		self.BodyTypes:MarkDirty();
		self.BodyTypes:Show();
	end
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
	local force = false;
	C_BarberShop.ResetCustomizationChoices(force);
	local currentCharacterData = C_BarberShop.GetCurrentCharacterData();
	self:SetCharacterSex(currentCharacterData.sex)
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:ApplyChanges()
	C_BarberShop.ApplyCustomizationChoices();
end

function BarberShopMixin:UpdateButtons()
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

	self:UpdateButtons();
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

function BarberShopMixin:MarkCustomizationOptionAsSeen(optionID)
	C_BarberShop.MarkCustomizationOptionAsSeen(optionID);
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
	self.BodyTypes:SetShown(formID == nil);
end

function BarberShopMixin:SetViewingChrModel(chrModelID)
	self:RegisterEvent("BARBER_SHOP_CAMERA_VALUES_UPDATED");
	C_BarberShop.SetViewingChrModel(chrModelID);
	self.BodyTypes:SetShown(chrModelID == nil);
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
