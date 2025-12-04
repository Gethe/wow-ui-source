local BasicDecorModeShownEvents =
{
	"HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_BASIC_MODE_PLACEMENT_FLAGS_UPDATED",
	"GLOBAL_MOUSE_UP",
	"UPDATE_BINDINGS",
	"HOUSING_DECOR_PLACE_FAILURE",
	"HOUSING_DECOR_PLACE_SUCCESS",
	"HOUSE_EXTERIOR_POSITION_SUCCESS",
	"HOUSING_DECOR_FREE_PLACE_STATUS_CHANGED",
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

	self.commitNewDecorOnMouseUp = true;

	local decorIsSelected = false;
	self:UpdateInstructions(decorIsSelected);
	
	EventRegistry:RegisterCallback("HousingMarketEvents.SetCartFrameShown", self.OnCartFrameSetShown, self);
end

function HouseEditorBasicDecorModeMixin:OnEvent(event, ...)
	if event == "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED" then
		local selected, targetType, isPreview = ...;
		if selected then
			self:OnTargetSelected();
			if targetType == Enum.HousingBasicModeTargetType.Decor then
				self:PlaySelectedSoundForDecorInfo(C_HousingBasicMode.GetSelectedDecorInfo(), isPreview);
			elseif targetType == Enum.HousingBasicModeTargetType.House then
				self:PlaySelectedSoundForHouse();
			end
		else
			self:OnTargetUnselected();
		end
	elseif event == "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering, targetType = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_HOVER_PLACED_DECOR);
			if targetType == Enum.HousingBasicModeTargetType.Decor then
				self:OnDecorHovered();
			end
		else
			GameTooltip:Hide();
		end
	elseif event == "HOUSING_BASIC_MODE_PLACEMENT_FLAGS_UPDATED" then
		local targetType, invalidPlacementInfo = ...;
		if invalidPlacementInfo.anyRestrictions then
			if targetType == Enum.HousingBasicModeTargetType.Decor then
				self:ShowInvalidPlacementDecorTooltip(invalidPlacementInfo);
			elseif targetType == Enum.HousingBasicModeTargetType.House then
				self:ShowInvalidPlacementHouseTooltip(invalidPlacementInfo);
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

		if (result == Enum.HousingResult.CollisionInvalid or result == Enum.HousingResult.PlacementTargetInvalid) and not C_CVar.GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.HousingInvalidCollision) then
			local helpTipInfo = {
				text = string.format(HOUSING_PLACEMENT_COLLISION_ERROR_HELPTIP, (GetBindingKey("HOUSING_TOGGLEDECORNUDGEMODE") or NPE_UNBOUND_KEYBIND)),
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				cvarBitfield = "closedInfoFramesAccountWide",
				bitfieldFlag = Enum.FrameTutorialAccount.HousingInvalidCollision,
				autoHideWhenTargetHides = true,
				acknowledgeOnHide = true,
			};

			HelpTip:Show(self.SubButtonBar.FreePlaceButton, helpTipInfo);
		end

		PlaySound(SOUNDKIT.HOUSING_INVALID_PLACEMENT);
	elseif event == "HOUSING_DECOR_PLACE_SUCCESS" then
		local _, size, _, isPreview = ...;
		self:PlayPlacedSoundForSize(size, isPreview);
	elseif event == "HOUSE_EXTERIOR_POSITION_SUCCESS" then
		self:PlayPlacementSoundForHouse();
	elseif event == "UPDATE_BINDINGS" then
		self.Instructions:UpdateAllControls();
	elseif event == "HOUSING_DECOR_FREE_PLACE_STATUS_CHANGED" then
		self.SubButtonBar.FreePlaceButton:UpdateState();
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

function HouseEditorBasicDecorModeMixin:OnCartFrameSetShown(cartShown)
	self.Instructions:SetShown(not cartShown);
end

function HouseEditorBasicDecorModeMixin:OnTargetSelected()
	local decorIsSelected = true;
	self:UpdateInstructions(decorIsSelected);

	self.DecorMoveOverlay:Show();
	self:GetParent():HideHouseStorage();
end

function HouseEditorBasicDecorModeMixin:OnTargetUnselected()
	local decorIsSelected = false;
	self:UpdateInstructions(decorIsSelected);
	self.Instructions:UpdateLayout();
	self.DecorMoveOverlay:Hide();
	self:GetParent():ShowHouseStorage();
end

function HouseEditorBasicDecorModeMixin:UpdateInstructions(decorIsSelected)
	self:SetInstructionShown(self.Instructions.SelectedInstructions, decorIsSelected);
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not decorIsSelected);

	if decorIsSelected then
		if self.Instructions.RemoveInstruction then
			local shouldShowRemove = false;
			if C_HousingBasicMode.IsDecorSelected() then
				local info = C_HousingBasicMode.GetSelectedDecorInfo();
				shouldShowRemove = not info or info.canBeRemoved;
			end
		
			self.Instructions.RemoveInstruction:SetShown(shouldShowRemove);
		end
	end

	self.Instructions:UpdateLayout();

end

function HouseEditorBasicDecorModeMixin:SetInstructionShown(instructionSet, shouldShow)
	for _, instruction in ipairs(instructionSet) do
		instruction:SetShown(shouldShow);
	end
end

function HouseEditorBasicDecorModeMixin:TryHandleEscape()
	local decorPlacementInProgress = C_HousingBasicMode.IsPlacingNewDecor() or C_HousingBasicMode.IsDecorSelected();
	local housePlacementInProgress = C_HousingBasicMode.IsHouseExteriorSelected();
	if decorPlacementInProgress or housePlacementInProgress then
		C_HousingBasicMode.CancelActiveEditing();

		if decorPlacementInProgress then
			PlaySound(SOUNDKIT.HOUSING_PLACE_ITEM_CANCEL);
		else
			PlaySound(SOUNDKIT.HOUSING_PLACE_HOUSE_CANCEL);
		end

		return true;
	end
	return false;
end

function HouseEditorBasicDecorModeMixin:ShowDecorInstanceTooltip(decorInstanceInfo)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	GameTooltip_SetTitle(GameTooltip, decorInstanceInfo.name);

	if decorInstanceInfo.isLocked then
		GameTooltip_AddErrorLine(GameTooltip, ERR_HOUSING_DECOR_LOCKED);
 	elseif not decorInstanceInfo.canBeRemoved then	
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_DECOR_CANNOT_REMOVE);
	end

	GameTooltip:Show();
	return GameTooltip;
end

function HouseEditorBasicDecorModeMixin:ShowInvalidPlacementDecorTooltip(invalidPlacementInfo)
	if invalidPlacementInfo.invalidCollision or invalidPlacementInfo.invalidTarget then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, HOUSING_PLACEMENT_COLLISION_ERROR_TITLE, ERROR_COLOR);

		local toggleCollisionBinding = GetBindingKey("HOUSING_TOGGLEDECORNUDGEMODE") or NPE_UNBOUND_KEYBIND;
		GameTooltip_AddHighlightLine(GameTooltip, string.format(HOUSING_PLACEMENT_COLLISION_ERROR_SUBTITLE, toggleCollisionBinding));

		GameTooltip:Show();
		return GameTooltip;
	end
end

function HouseEditorBasicDecorModeMixin:ShowInvalidPlacementHouseTooltip(invalidPlacementInfo)
	if invalidPlacementInfo.invalidCollision or invalidPlacementInfo.invalidTarget then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, HOUSING_PLACEMENT_COLLISION_ERROR_TITLE, ERROR_COLOR);

		local toggleCollisionBinding = GetBindingKey("HOUSING_TOGGLEDECORNUDGEMODE") or NPE_UNBOUND_KEYBIND;
		GameTooltip_AddHighlightLine(GameTooltip, string.format(HOUSING_PLACEMENT_COLLISION_ERROR_SUBTITLE, toggleCollisionBinding));

		GameTooltip:Show();
		return GameTooltip;
	elseif invalidPlacementInfo.notInRoom then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, HOUSING_PLACEMENT_OUTSIDE_PLOT_ERROR_TITLE, ERROR_COLOR);

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
HouseEditorFreePlaceButtonMixin = {};

function HouseEditorFreePlaceButtonMixin:IsActive()
	return C_HousingBasicMode.IsFreePlaceEnabled();
end

function HouseEditorFreePlaceButtonMixin:EnterMode()
	C_HousingBasicMode.SetFreePlaceEnabled(true);
end

function HouseEditorFreePlaceButtonMixin:LeaveMode()
	C_HousingBasicMode.SetFreePlaceEnabled(false);
end
