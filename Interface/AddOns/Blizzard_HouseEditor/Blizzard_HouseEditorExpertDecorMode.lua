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

function HouseEditorExpertDecorModeMixin:TryHandleEscape()
	if C_HousingExpertMode.IsDecorSelected() or C_HousingExpertMode.IsHouseExteriorSelected() then
		C_HousingExpertMode.CancelActiveEditing();
		return true;
	end
	return false;
end

function HouseEditorExpertDecorModeMixin:OnEvent(event, ...)
	if event == "HOUSING_DECOR_PRECISION_SUBMODE_CHANGED" then
		local activeSubmode = ...;
		self:StopLoopingSound();
		self:UpdateSubmodeButtons(activeSubmode);
	elseif event == "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED" then
		local isManipulating = false;
		self:UpdateShownInstructions(isManipulating);
		self.SubmodeBar.ResetButton:UpdateState();

		local anythingSelect, targetType = ...;
		if anythingSelect and targetType == Enum.HousingExpertModeTargetType.Decor then
			self:PlaySelectedSoundForDecorInfo(C_HousingExpertMode.GetSelectedDecorInfo());
		elseif anythingSelect and targetType == Enum.HousingExpertModeTargetType.House then
			self:PlaySelectedSoundForHouse();
		end
	elseif event == "HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering, targetType = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_ITEM_HOVER);
			if targetType == Enum.HousingExpertModeTargetType.Decor then
				self:OnDecorHovered();
			end
		else
			GameTooltip:Hide();
		end
	elseif event == "HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED" then
		local isManipulating = ...;
		self:UpdateShownInstructions(isManipulating);
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
	self:UpdateSubmodeButtons(C_HousingExpertMode.GetPrecisionSubmode());
	local isManipulating = false;
	self:UpdateShownInstructions(isManipulating);
	self:UpdateKeybinds();
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorExpertDecorMode);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);
end

function HouseEditorExpertDecorModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ExpertDecorModeShownEvents);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorExpertDecorMode);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorBasicAndExpertDecorMode);
	self:StopLoopingSound();
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
		elseif manipulatorEvent == Enum.TransformManipulatorEvent.Complete or
				manipulatorEvent == Enum.TransformManipulatorEvent.Cancel
		then
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

function HouseEditorExpertDecorModeMixin:UpdateSubmodeButtons(activeSubmode)
	for _, submodeButton in ipairs(self.SubmodeBar.Buttons) do
		if submodeButton.submode then
			submodeButton:SetActive(submodeButton.submode == activeSubmode);
		end
	end

	self.SubmodeBar.ResetButton:UpdateState();
end

function HouseEditorExpertDecorModeMixin:UpdateShownInstructions(isManipulating)
	local isTargetSelected = C_HousingExpertMode.IsDecorSelected() or C_HousingExpertMode.IsHouseExteriorSelected();
	self:SetInstructionShown(self.Instructions.UnselectedInstructions, not isTargetSelected and not isManipulating);
	self:SetInstructionShown(self.Instructions.SelectedInstructions, isTargetSelected and not isManipulating);
	self:SetInstructionShown(self.Instructions.ManipulatingInstructions, isManipulating);
	self:SetInstructionShown(self.Instructions.SelectedOrManipulatingInstructions, isTargetSelected or isManipulating);

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


-- Inherits HouseEditorSubmodeButtonMixin
ExpertDecorSubmodeButtonMixin = {};

function ExpertDecorSubmodeButtonMixin:SetActive(active)
	if self.isActive == active then
		return;
	end

	self.isActive = active;
	self:UpdateState();
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
