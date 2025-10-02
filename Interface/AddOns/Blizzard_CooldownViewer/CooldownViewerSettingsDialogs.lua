CooldownViewerBaseDialogMixin = {}; -- implements API from CreateFromMixins(EditModeBaseDialogMixin);

function CooldownViewerBaseDialogMixin:GetManagerExitCallbackEventName()
	return "CooldownViewerSettings.OnHide";
end

function CooldownViewerBaseDialogMixin:GetOnCancelEvent()
	return nil;
end

function CooldownViewerBaseDialogMixin:GetDesiredLayoutType()
	return self:IsCharacterSpecificLayoutChecked() and Enum.CooldownLayoutType.Character or Enum.CooldownLayoutType.Account;
end
