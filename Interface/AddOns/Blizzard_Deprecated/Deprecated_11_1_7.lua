-- These are functions that were deprecated in 11.1.7 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function ActionButton_ShowOverlayGlow(button)
	ActionButtonSpellAlertManager:ShowAlert(button);
end

function ActionButton_HideOverlayGlow(button)
	ActionButtonSpellAlertManager:HideAlert(button);
end