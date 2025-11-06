local ExpertDecorModeShownEvents =
{
	"HOUSING_DECOR_PRECISION_SUBMODE_CHANGED",
	"HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED",
	"HOUSING_DECOR_PRECISION_MANIPULATION_EVENT",
	"UPDATE_BINDINGS",
};

HouseEditorExpertDecorModeMixin = CreateFromMixins(BaseHouseEditorModeMixin);

function HouseEditorExpertDecorModeMixin:OnLoad()
	self.PlacedDecorListButton:SetListFrame(self.PlacedDecorList);
end

function HouseEditorExpertDecorModeMixin:TryHandleEscape()
	local decorPlacementInProgress = C_HousingExpertMode.IsDecorSelected();
	local housePlacementInProgress = C_HousingExpertMode.IsHouseExteriorSelected();
	if decorPlacementInProgress or housePlacementInProgress then
		C_HousingExpertMode.CancelActiveEditing();

		if decorPlacementInProgress then
			PlaySound(SOUNDKIT.HOUSING_PLACE_ITEM_CANCEL);
		else
			PlaySound(SOUNDKIT.HOUSING_PLACE_HOUSE_CANCEL);
		end

		return true;
	end
	return false;
end

function HouseEditorExpertDecorModeMixin:OnEvent(event, ...)
	if event == "HOUSING_DECOR_PRECISION_SUBMODE_CHANGED" then
		self:StopLoopingSound();
		local activeSubmode = ...;
		local forceUpdateState = false;
		self:UpdateActiveSubmode(activeSubmode, forceUpdateState);
	elseif event == "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED" then
		self.isManipulating = false;
		self:UpdateShownInstructions();
		local forceUpdateState = true;
		self:UpdateActiveSubmode(C_HousingExpertMode.GetPrecisionSubmode(), forceUpdateState);

		local anythingSelect, targetType = ...;
		if anythingSelect and targetType == Enum.HousingExpertModeTargetType.Decor then
			self:PlaySelectedSoundForDecorInfo(C_HousingExpertMode.GetSelectedDecorInfo());
		elseif anythingSelect and targetType == Enum.HousingExpertModeTargetType.House then
			self:PlaySelectedSoundForHouse();
		end
	elseif event == "HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering, targetType = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_HOVER_PLACED_DECOR);
			if targetType == Enum.HousingExpertModeTargetType.Decor then
				self:OnDecorHovered();
			end
		else
			GameTooltip:Hide();
		end
	elseif event == "HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED" then
		self.isManipulating = ...;
		self:UpdateShownInstructions();
	elseif event == "UPDATE_BINDINGS" then
		self:UpdateKeybinds();
	elseif event == "HOUSING_DECOR_PRECISION_MANIPULATION_EVENT" then
		local manipulatorEvent = ...;
		self:HandleManipulatorEvent(manipulatorEvent);
	end
end

function HouseEditorExpertDecorModeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ExpertDecorModeShownEvents);
	EventRegistry:TriggerEvent("HouseEditor.HouseStorageSetShown", false);
	local forceUpdateState = true;
	self:UpdateActiveSubmode(C_HousingExpertMode.GetPrecisionSubmode(), forceUpdateState);
	self.isManipulating = false;
	self:UpdateShownInstructions();
	self:UpdateKeybinds();
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorExpertDecorMode);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);

	self.PlacedDecorListButton:Show();
end

function HouseEditorExpertDecorModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ExpertDecorModeShownEvents);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorExpertDecorMode);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);
	self:StopLoopingSound();
	self.PlacedDecorListButton:Hide();
	self.PlacedDecorList:Hide();
end

function HouseEditorExpertDecorModeMixin:HandleManipulatorEvent(manipulatorEvent)
	local currentSubmode = C_HousingExpertMode.GetPrecisionSubmode();
	local isTranslateOrRotate = currentSubmode == Enum.HousingPrecisionSubmode.Translate or currentSubmode == Enum.HousingPrecisionSubmode.Rotate; 

	--these are only for translate and rotate per sound design
	--(scale has mouse down and mouse up but has to be handled separately anyway)
	if isTranslateOrRotate then 
		if manipulatorEvent == Enum.TransformManipulatorEvent.Hover then
			if not self.antiHoverSpamTimer and not self:IsLoopingSound() then --dont play the hover sound if you rehover while dragging
				PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_HOVER);
				self.antiHoverSpamTimer = true;

				--this is necessary because there are overlapping parts to the
				--3d models that cause it to play "double" and not sound good.
				--for instance, the overlapping rotation models, or the "head" of the translate arrows
				--revisit this when we have final art because it may no longer be an issue.
				C_Timer.After(0.25, function()
					self.antiHoverSpamTimer = false;
				end);
			end
		elseif manipulatorEvent == Enum.TransformManipulatorEvent.Start then
			PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYDOWN);
			self:StartLoopingSound();
		elseif manipulatorEvent == Enum.TransformManipulatorEvent.Complete or manipulatorEvent == Enum.TransformManipulatorEvent.Cancel	then
			PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYUP);
			self:StopLoopingSound();
		end
	end
end

function HouseEditorExpertDecorModeMixin:IsLoopingSound()
	return not not self.loopingSoundEffectHandle;
end

function HouseEditorExpertDecorModeMixin:StartLoopingSound()
	self.loopingSoundEffectHandle = select(2, PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_WHILE_HOLDING_AXIS));
end

function HouseEditorExpertDecorModeMixin:StopLoopingSound()
	if self:IsLoopingSound() then
		StopSound(self.loopingSoundEffectHandle);
		self.loopingSoundEffectHandle = nil;
	end
end

function HouseEditorExpertDecorModeMixin:UpdateKeybinds()
	self.Instructions:UpdateAllControls();
end

function HouseEditorExpertDecorModeMixin:UpdateActiveSubmode(activeSubmode, forceUpdateState)
	for _, submodeButton in ipairs(self.SubmodeBar.Buttons) do
		if submodeButton.submode then
			submodeButton:SetActive(submodeButton.submode == activeSubmode, forceUpdateState);
		end
	end

	self.SubmodeBar.ResetButton:UpdateState();

	self.activeSubmode = activeSubmode;
	self:UpdateShownInstructions();
end

function HouseEditorExpertDecorModeMixin:UpdateShownInstructions()
	local isTargetSelected = C_HousingExpertMode.IsDecorSelected() or C_HousingExpertMode.IsHouseExteriorSelected();
	local isManipulating = self.isManipulating;
	local subMode = C_HousingExpertMode.GetPrecisionSubmode();

	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not isTargetSelected and not isManipulating);
	self:SetInstructionShown(self.Instructions.SelectedInstructions, isTargetSelected and not isManipulating);
	self:SetInstructionShown(self.Instructions.ManipulatingInstructions, isManipulating);
	self:SetInstructionShown(self.Instructions.SelectedOrManipulatingInstructions, isTargetSelected or isManipulating);

	local showMoveInstructions = isTargetSelected and not isManipulating and subMode == Enum.HousingPrecisionSubmode.Translate;
	self:SetInstructionShown(self.Instructions.SelectedAndMoveSubmodeInstructions, showMoveInstructions);

	local showRotateInstructions = isTargetSelected and not isManipulating and subMode == Enum.HousingPrecisionSubmode.Rotate;
	self:SetInstructionShown(self.Instructions.SelectedAndRotateSubmodeInstructions, showRotateInstructions);

	local showScaleInstructions = isTargetSelected and not isManipulating and subMode == Enum.HousingPrecisionSubmode.Scale;
	self:SetInstructionShown(self.Instructions.SelectedAndScaleSubmodeInstructions, showScaleInstructions);

	if self.Instructions.RemoveInstruction then
		local shouldShowRemove = false;
		if C_HousingExpertMode.IsDecorSelected() then
			local info = C_HousingExpertMode.GetSelectedDecorInfo();
			shouldShowRemove = not info or info.canBeRemoved;
		end
		self.Instructions.RemoveInstruction:SetShown(shouldShowRemove);
	end

	self.Instructions:UpdateLayout();
end

function HouseEditorExpertDecorModeMixin:SetInstructionShown(instructionSet, shouldShow)
	if instructionSet then
		for _, instruction in ipairs(instructionSet) do
			instruction:SetShown(shouldShow);
		end
	end
end

function HouseEditorExpertDecorModeMixin:ShowDecorInstanceTooltip(decorInstanceInfo)
	if decorInstanceInfo.isLocked or not decorInstanceInfo.canBeRemoved then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_SetTitle(GameTooltip, decorInstanceInfo.name);
		if decorInstanceInfo.isLocked then
			GameTooltip_AddErrorLine(GameTooltip, ERR_HOUSING_DECOR_LOCKED);
		else
			GameTooltip_AddErrorLine(GameTooltip, HOUSING_DECOR_CANNOT_REMOVE);
		end

		GameTooltip:Show();
		return GameTooltip;
	end
end

function HouseEditorExpertDecorModeMixin:PlaySelectedSoundForSize(size)
	self:PlaySoundForSize(size,
		SOUNDKIT.HOUSING_EXPERTMODE_ITEM_SELECT,
		SOUNDKIT.HOUSING_EXPERTMODE_ITEM_SELECT,
		SOUNDKIT.HOUSING_EXPERTMODE_ITEM_SELECT
	);
end

function HouseEditorExpertDecorModeMixin:PlaySelectedHouseSoundForSize(size)
	self:PlaySoundForHouseSize(size,
		SOUNDKIT.HOUSING_EXPERTMODE_HOUSE_SELECT,
		SOUNDKIT.HOUSING_EXPERTMODE_HOUSE_SELECT,
		SOUNDKIT.HOUSING_EXPERTMODE_HOUSE_SELECT
	);
end

-- Inherits HouseEditorSubmodeButtonMixin
ExpertDecorSubmodeButtonMixin = {};

function ExpertDecorSubmodeButtonMixin:SetActive(active, forceUpdateState)
	if self.isActive == active and not forceUpdateState then
		return;
	end

	self.isActive = active;
	self:UpdateState();
end

function ExpertDecorSubmodeButtonMixin:CheckEnabled()
	local restriction = C_HousingExpertMode.GetPrecisionSubmodeRestriction(self.submode);
	if restriction == Enum.HousingExpertSubmodeRestriction.None then
		return true;
	end

	return false, HousingExpertSubmodeRestrictionStrings[restriction];
end

function ExpertDecorSubmodeButtonMixin:IsActive()
	return self.isActive;
end

function ExpertDecorSubmodeButtonMixin:EnterMode()
	C_HousingExpertMode.SetPrecisionSubmode(self.submode);
end

function ExpertDecorSubmodeButtonMixin:LeaveMode()
	-- These are not toggled off
	return;
end

function ExpertDecorSubmodeButtonMixin:PlayEnterSound()
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_SUB_MENU_BUTTON_TOGGLE);
end

-- Inherits HouseEditorSubmodeButtonMixin
ExpertDecorResetButtonMixin = {};

function ExpertDecorResetButtonMixin:CheckEnabled()
	local activeSubmode = C_HousingExpertMode.GetPrecisionSubmode();
	-- Translation submode does not currently allow resetting
	if activeSubmode == Enum.HousingPrecisionSubmode.Translate then
		return false;
	end

	return C_HousingExpertMode.IsDecorSelected() or C_HousingExpertMode.IsHouseExteriorSelected();
end

function ExpertDecorResetButtonMixin:IsActive()
	return false;
end

function ExpertDecorResetButtonMixin:OnClick()
	local activeSubmodeOnly = not IsShiftKeyDown();
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_RESET_CHANGES);
	C_HousingExpertMode.ResetPrecisionChanges(activeSubmodeOnly);
end
