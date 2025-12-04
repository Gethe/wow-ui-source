local CustomizeModeShownEvents = {
	"HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_DECOR_CUSTOMIZATION_CHANGED",
	"HOUSING_DECOR_DYE_FAILURE",
	"DYE_COLOR_UPDATED",
	"DYE_COLOR_CATEGORY_UPDATED",
	"HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGED",
	"UPDATE_BINDINGS",
};

HouseEditorCustomizeModeMixin = CreateFromMixins(BaseHouseEditorModeMixin);

function HouseEditorCustomizeModeMixin:OnEvent(event, ...)
	if event == "HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED" then
		local hasTarget, targetType = ...;
		if hasTarget  then
			self:OnTargetSelected();
			if targetType == Enum.HousingCustomizeModeTargetType.Decor then
				self:ShowSelectedDecorInfo();
			elseif targetType == Enum.HousingCustomizeModeTargetType.RoomComponent then
				self:ShowSelectedRoomComponentInfo();
			end

			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_SELECT);
		else
			self:OnTargetUnselected();
			self:HideSelectedDecorInfo();
			self:HideSelectedRoomComponentInfo();
		end
	elseif event == "HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering, targetType = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_HOVER_PLACED_DECOR);
			if targetType == Enum.HousingCustomizeModeTargetType.Decor then
				self:OnDecorHovered();
			elseif targetType == Enum.HousingCustomizeModeTargetType.RoomComponent then
				self:OnRoomComponentHovered();
			elseif targetType == Enum.HousingCustomizeModeTargetType.ExteriorHouse then
				self:ShowHouseTooltip();
			end
		else
			GameTooltip:Hide();
		end
	elseif event == "HOUSING_DECOR_CUSTOMIZATION_CHANGED" then
		local changedGUID = ...;
		if self.DecorCustomizationsPane.decorGUID == changedGUID then
			self:UpdateSelectedDecorInfo();
		end
	elseif event == "DYE_COLOR_UPDATED" or event == "DYE_COLOR_CATEGORY_UPDATED" then
		if C_HousingCustomizeMode.IsDecorSelected() then
			self:ShowSelectedDecorInfo();
		end
	elseif event == "HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGED" then
		local roomGUID, componentID = ...;
		local componentPane = self.RoomComponentCustomizationsPane;
		if componentPane.roomGUID == roomGUID and componentPane.componentID == componentID then
			local info = C_HousingCustomizeMode.GetSelectedRoomComponentInfo();
			componentPane:SetRoomComponentInfo(info);
		end
	elseif event == "HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGE_FAILED" then
		local roomGUID, componentID, result = ...;
		local componentPane = self.RoomComponentCustomizationsPane;
		if componentPane.roomGUID == roomGUID and componentPane.componentID == componentID then
			local errStr = HousingResultToErrorText[result];
			if errStr then
				UIErrorsFrame:AddExternalErrorMessage(errStr);
			end
		end
	elseif event == "HOUSING_DECOR_DYE_FAILURE" then
		UIErrorsFrame:AddExternalErrorMessage(HOUSING_DECOR_MISSING_DYE_ERROR_TEXT);
	elseif event == "UPDATE_BINDINGS" then
		self.Instructions:UpdateAllControls();
	end
end

function HouseEditorCustomizeModeMixin:OnTargetSelected()
	local isSelected = true;
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not isSelected);
	self.Instructions:UpdateLayout();
end

function HouseEditorCustomizeModeMixin:OnTargetUnselected()
	local isSelected = false;
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not isSelected);
	self.Instructions:UpdateLayout();
end

function HouseEditorCustomizeModeMixin:UpdateSelectedDecorInfo()
	local info = C_HousingCustomizeMode.GetSelectedDecorInfo();
	if info and info.canBeCustomized then
		self.DecorCustomizationsPane:UpdateDecorInfo(info);
	else
		self:HideSelectedDecorInfo();
	end
end

function HouseEditorCustomizeModeMixin:ShowSelectedDecorInfo()
	local info = C_HousingCustomizeMode.GetSelectedDecorInfo();
	if info and info.canBeCustomized then
		self:HideSelectedRoomComponentInfo();

		if self.DecorCustomizationsPane:IsShown() then
			self.DecorCustomizationsPane:ClearDecorInfo();
		end

		self.DecorCustomizationsPane:SetDecorInfo(info);
		self.DecorCustomizationsPane:Show();
	else
		self:HideSelectedDecorInfo();
	end
end

function HouseEditorCustomizeModeMixin:HideSelectedDecorInfo()
	if self.DecorCustomizationsPane:IsShown() then
		self.DecorCustomizationsPane:ClearDecorInfo();
		self.DecorCustomizationsPane:Hide();
	end
end

function HouseEditorCustomizeModeMixin:SetInstructionShown(instructionSet, shouldShow)
	for _, instruction in ipairs(instructionSet) do
		instruction:SetShown(shouldShow);
	end
end

function HouseEditorCustomizeModeMixin:OnShow()
	self.Instructions:UpdateAllVisuals();
	local hasSelection = C_HousingCustomizeMode.IsDecorSelected() or C_HousingCustomizeMode.IsRoomComponentSelected();
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not hasSelection);
	self.Instructions:UpdateLayout();

	FrameUtil.RegisterFrameForEvents(self, CustomizeModeShownEvents);
	EventRegistry:TriggerEvent("HouseEditor.HouseStorageSetShown", false);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorCustomizeMode);

	if C_HousingCustomizeMode.IsDecorSelected() then
		self:ShowSelectedDecorInfo();
	elseif C_HousingCustomizeMode.IsRoomComponentSelected() then
		self:ShowSelectedRoomComponentInfo();
	end

	self.Instructions:UpdateLayout();
end

function HouseEditorCustomizeModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CustomizeModeShownEvents);
	self:HideSelectedDecorInfo();
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorCustomizeMode);
end

function HouseEditorCustomizeModeMixin:TryHandleEscape()
	if C_HousingCustomizeMode.IsDecorSelected() or C_HousingCustomizeMode.IsRoomComponentSelected() then
		C_HousingCustomizeMode.CancelActiveEditing();
		return true;
	end
	return false;
end

function HouseEditorCustomizeModeMixin:ShowDecorInstanceTooltip(decorInstanceInfo)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, decorInstanceInfo.name);
	if decorInstanceInfo.isLocked then
		GameTooltip_AddErrorLine(GameTooltip, ERR_HOUSING_DECOR_LOCKED);
 	elseif decorInstanceInfo.canBeCustomized then	
		GameTooltip_AddNormalLine(GameTooltip, HOUSING_CUSTOMIZE_DECOR_HOVER_TOOLTIP);
	else
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_CUSTOMIZE_DECOR_UNAVAILABLE_HOVER_TOOLTIP);
	end
	GameTooltip:Show();
	return GameTooltip;
end

function HouseEditorCustomizeModeMixin:ShowHouseTooltip()
	-- TODO: Error tooltip can go here in the future, existing string references decor (and the house is not decor).
end

function HouseEditorCustomizeModeMixin:ShowRoomComponentTooltip(componentInfo)
	local supportedComponentName = self.RoomComponentCustomizationsPane:TryGetRoomComponentTooltipLabel(componentInfo);
	if not supportedComponentName then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, supportedComponentName);
	if componentInfo.canBeCustomized then	
		GameTooltip_AddNormalLine(GameTooltip, HOUSING_CUSTOMIZE_DECOR_HOVER_TOOLTIP);
	else
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_CUSTOMIZE_DECOR_UNAVAILABLE_HOVER_TOOLTIP);
	end
	GameTooltip:Show();
	return GameTooltip;
end

function HouseEditorCustomizeModeMixin:ShowSelectedRoomComponentInfo()
	local info = C_HousingCustomizeMode.GetSelectedRoomComponentInfo();
	if info and info.canBeCustomized and self.RoomComponentCustomizationsPane:SupportsRoomComponent(info) then
		self:HideSelectedDecorInfo();

		if self.RoomComponentCustomizationsPane:IsShown() then
			self.RoomComponentCustomizationsPane:ClearRoomComponentInfo();
		end

		self.RoomComponentCustomizationsPane:SetRoomComponentInfo(info);
		self.RoomComponentCustomizationsPane:Show();
	else
		self:HideSelectedRoomComponentInfo();
	end
end

function HouseEditorCustomizeModeMixin:HideSelectedRoomComponentInfo()
	if self.RoomComponentCustomizationsPane:IsShown() then
		self.RoomComponentCustomizationsPane:ClearRoomComponentInfo();
		self.RoomComponentCustomizationsPane:Hide();
	end
end 
