local CleanupModeShownEvents = {
	"HOUSING_CLEANUP_MODE_TARGET_SELECTED",
	"HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_DECOR_REMOVED",
};

HouseEditorCleanupModeMixin = CreateFromMixins(BaseHouseEditorModeMixin);

function HouseEditorCleanupModeMixin:OnEvent(event, ...)
	if event == "HOUSING_CLEANUP_MODE_TARGET_SELECTED" then
		C_HousingDecor.RemoveSelectedDecor();
	elseif event == "HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED" then
		local isHovering = ...;
		if isHovering then
			PlaySound(SOUNDKIT.HOUSING_HOVER_PLACED_DECOR);
			self:OnDecorHovered();
		else
			GameTooltip:Hide();
		end
	elseif event == "HOUSING_DECOR_REMOVED" then
		PlaySound(SOUNDKIT.HOUSING_ERASE_OBJECT);
	end
end

function HouseEditorCleanupModeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CleanupModeShownEvents);
	EventRegistry:TriggerEvent("HouseEditor.HouseStorageSetShown", false);
	C_KeyBindings.ActivateBindingContext(Enum.BindingContext.HousingEditorCleanupMode);

	self.Instructions:UpdateLayout();
end

function HouseEditorCleanupModeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CleanupModeShownEvents);
	C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.HousingEditorCleanupMode);
end

function HouseEditorCleanupModeMixin:TryHandleEscape()
	return false;
end
