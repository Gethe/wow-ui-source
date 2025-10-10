local BasicDecorModeShownEvents =
{
	"HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
	"GLOBAL_MOUSE_UP",
	"UPDATE_BINDINGS",
	"HOUSING_DECOR_PLACE_FAILURE",
	"HOUSING_DECOR_PLACE_SUCCESS",
	"HOUSE_EXTERIOR_POSITION_SUCCESS",
	"HOUSING_DECOR_NUDGE_STATUS_CHANGED",
	"HOUSING_DECOR_GRID_VISIBILITY_STATUS_CHANGED",
	"HOUSING_DECOR_GRID_SNAP_STATUS_CHANGED",
	"HOUSING_DECOR_REMOVED",
	"HOUSING_DECOR_GRID_SNAP_OCCURRED",
};

HouseEditorBasicDecorModeMixin = CreateFromMixins(BaseHouseEditorModeMixin);

function HouseEditorBasicDecorModeMixin:OnLoad()
	self.DecorMoveOverlay:SetScript("OnMouseUp", function()
		if C_HousingBasicMode.IsPlacingNewDecor() then
			C_HousingBasicMode.FinishPlacingNewDecor();
		elseif C_HousingBasicMode.IsDecorSelected() then
			C_HousingBasicMode.CommitDecorMovement();
		elseif C_HousingBasicMode.IsHouseExteriorSelected() then
			C_HousingBasicMode.CommitHouseExteriorPosition();
		end
	end);

	self.DecorMoveOverlay:SetScript("OnMouseWheel", function(_, direction)
		if C_HousingBasicMode.IsDecorSelected() then
			C_HousingBasicMode.RotateDecor(direction);
		elseif C_HousingBasicMode.IsHouseExteriorSelected() then
			C_HousingBasicMode.RotateHouseExterior(direction);
		end
		PlaySound(SOUNDKIT.HOUSING_ROTATE_ITEM);
	end);

	self.commitNewDecorOnMouseUp = true;

	self:SetInstructionShown(self.Instructions.SelectedInstructions, false);
end

function HouseEditorBasicDecorModeMixin:OnEvent(event, ...)
	if event == "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED" then
		local selected, targetType = ...;
		if selected then
			self:OnTargetSelected();
			if targetType == Enum.HousingBasicModeTargetType.Decor then
				self:PlaySelectedSoundForDecorInfo(C_HousingBasicMode.GetSelectedDecorInfo());
			elseif targetType == Enum.HousingBasicModeTargetType.House then
				self:PlaySelectedSoundForHouse();
			end
		else
			self:OnTargetUnselected();
		end
	elseif event == "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering, targetType = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_ITEM_HOVER);
			if targetType == Enum.HousingBasicModeTargetType.Decor then
				self:OnDecorHovered();
			end
		else
			GameTooltip:Hide();
		end
	elseif event == "GLOBAL_MOUSE_UP" then
		local button = ...;
		if button == "LeftButton" and C_HousingBasicMode.IsPlacingNewDecor() then
			if self.commitNewDecorOnMouseUp then
				C_HousingBasicMode.FinishPlacingNewDecor();
			else
				self.commitNewDecorOnMouseUp = true;
			end
		end
	elseif event == "HOUSING_DECOR_PLACE_FAILURE" then
		local result = ...;
		local errStr = HousingResultToErrorText[result];
		if errStr then
			UIErrorsFrame:AddExternalErrorMessage(errStr);
		end
		PlaySound(SOUNDKIT.HOUSING_INVALID_PLACEMENT);
	elseif event == "HOUSING_DECOR_PLACE_SUCCESS" then
		local size = ...;
		self:PlayPlacedSoundForSize(size);
	elseif event == "HOUSE_EXTERIOR_POSITION_SUCCESS" then
		self:PlayPlacementSoundForHouse();
	elseif event == "UPDATE_BINDINGS" then
		self.Instructions:UpdateAllControls();
	elseif event == "HOUSING_DECOR_NUDGE_STATUS_CHANGED" then
		self.SubButtonBar.NudgeButton:UpdateState();
	elseif event == "HOUSING_DECOR_GRID_SNAP_STATUS_CHANGED" then
		self.SubButtonBar.SnapButton:UpdateState();
	elseif event == "HOUSING_DECOR_REMOVED" then
		PlaySound(SOUNDKIT.HOUSING_ERASE_OBJECT);
	elseif event == "HOUSING_DECOR_GRID_SNAP_OCCURRED" then
		PlaySound(SOUNDKIT.HOUSING_DRAG_ITEM_OVER_GRID);
	end
end

function HouseEditorBasicDecorModeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, BasicDecorModeShownEvents);

	self.Instructions:UpdateAllVisuals();

	if C_HousingBasicMode.IsDecorSelected() or C_HousingBasicMode.IsHouseExteriorSelected() then
		self:OnTargetSelected();
	else
		self:OnTargetUnselected();
	end

	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorBasicDecorMode);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);
end

function HouseEditorBasicDecorModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BasicDecorModeShownEvents);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorBasicDecorMode);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);
end

function HouseEditorBasicDecorModeMixin:OnTargetSelected()
	self:SetInstructionShown(self.Instructions.SelectedInstructions, true);

	if self.Instructions.RemoveInstruction then
		local shouldShowRemove = false;
		if C_HousingBasicMode.IsDecorSelected() then
			local info = C_HousingBasicMode.GetSelectedDecorInfo();
			shouldShowRemove = not info or info.canBeRemoved;
		end
		
		self.Instructions.RemoveInstruction:SetShown(shouldShowRemove);
	end

	self.Instructions:UpdateLayout();
	self.DecorMoveOverlay:Show();
	self:GetParent():HideHouseStorage();
end

function HouseEditorBasicDecorModeMixin:OnTargetUnselected()
	self:SetInstructionShown(self.Instructions.SelectedInstructions, false);
	self.Instructions:UpdateLayout();
	self.DecorMoveOverlay:Hide();
	self:GetParent():ShowHouseStorage();
end

function HouseEditorBasicDecorModeMixin:SetInstructionShown(instructionSet, shouldShow)
	for _, instruction in ipairs(instructionSet) do
		instruction:SetShown(shouldShow);
	end
end

function HouseEditorBasicDecorModeMixin:TryHandleEscape()
	if C_HousingBasicMode.IsPlacingNewDecor() or C_HousingBasicMode.IsDecorSelected() or C_HousingBasicMode.IsHouseExteriorSelected() then
		C_HousingBasicMode.CancelActiveEditing();
		return true;
	end
	return false;
end

function HouseEditorBasicDecorModeMixin:ShowDecorInstanceTooltip(decorInstanceInfo)
	if decorInstanceInfo.isLocked then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, decorInstanceInfo.name);
		GameTooltip_AddErrorLine(GameTooltip, ERR_HOUSING_DECOR_LOCKED);

		GameTooltip:Show();
		return GameTooltip;
 	elseif not decorInstanceInfo.canBeRemoved then	
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, decorInstanceInfo.name);
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_DECOR_CANNOT_REMOVE);

		GameTooltip:Show();
		return GameTooltip;
	end
end

-- Iherits HouseEditorSubmodeButtonMixin
HouseEditorSnapButtonMixin = {};

function HouseEditorSnapButtonMixin:IsActive()
	return C_HousingBasicMode.IsGridSnapEnabled();
end

function HouseEditorSnapButtonMixin:EnterMode()
	C_HousingBasicMode.SetGridSnapEnabled(true);
end

function HouseEditorSnapButtonMixin:LeaveMode()
	C_HousingBasicMode.SetGridSnapEnabled(false);
end

-- Iherits HouseEditorSubmodeButtonMixin
HouseEditorGridVisibilityButtonMixin = {};

function HouseEditorGridVisibilityButtonMixin:IsActive()
	return C_HousingBasicMode.IsGridVisible();
end

function HouseEditorGridVisibilityButtonMixin:EnterMode()
	C_HousingBasicMode.SetGridVisible(true);
end

function HouseEditorGridVisibilityButtonMixin:LeaveMode()
	C_HousingBasicMode.SetGridVisible(false);
end

-- Iherits HouseEditorSubmodeButtonMixin
HouseEditorNudgeButtonMixin = {};

function HouseEditorNudgeButtonMixin:IsActive()
	return C_HousingBasicMode.IsNudgeEnabled();
end

function HouseEditorNudgeButtonMixin:EnterMode()
	C_HousingBasicMode.SetNudgeEnabled(true);
end

function HouseEditorNudgeButtonMixin:LeaveMode()
	C_HousingBasicMode.SetNudgeEnabled(false);
end
