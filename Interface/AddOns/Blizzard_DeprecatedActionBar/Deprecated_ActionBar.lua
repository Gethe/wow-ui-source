-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function GetActionAutocast(actionID)
	return C_ActionBar.GetActionAutocast(actionID);
end

function GetActionText(actionID)
	return C_ActionBar.GetActionText(actionID);
end

function GetActionTexture(actionID)
	return C_ActionBar.GetActionTexture(actionID);
end

function GetActionCount(actionID)
	return C_ActionBar.GetActionUseCount(actionID);
end

function GetActionCooldown(actionID)
	local cooldownInfo = C_ActionBar.GetActionCooldown(actionID);
	return cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled, cooldownInfo.modRate;
end

function GetActionCharges(actionID)
	local chargeInfo = C_ActionBar.GetActionCharges(actionID);
	return chargeInfo.currentCharges, chargeInfo.maxCharges, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate;
end

function GetActionLossOfControlCooldown(actionID)
	return C_ActionBar.GetActionLossOfControlCooldown(actionID);
end

function HasAction(actionID)
	return C_ActionBar.HasAction(actionID);
end

function IsAttackAction(actionID)
	return C_ActionBar.IsAttackAction(actionID);
end

function IsCurrentAction(actionID)
	return C_ActionBar.IsCurrentAction(actionID);
end

function IsAutoRepeatAction(actionID)
	return C_ActionBar.IsAutoRepeatAction(actionID);
end

function IsUsableAction(actionID)
	return C_ActionBar.IsUsableAction(actionID);
end

function IsConsumableAction(actionID)
	return C_ActionBar.IsConsumableAction(actionID);
end

function IsStackableAction(actionID)
	return C_ActionBar.IsStackableAction(actionID);
end

function IsItemAction(actionID)
	return C_ActionBar.IsItemAction(actionID);
end

function IsEquippedAction(actionID)
	return C_ActionBar.IsEquippedAction(actionID);
end

function ActionHasRange(actionID)
	return C_ActionBar.HasRangeRequirements(actionID);
end

function IsActionInRange(actionID)
	return C_ActionBar.IsActionInRange(actionID);
end

function SetActionUIButton(checkboxFrame, actionID, cooldownFrame)
	C_ActionBar.RegisterActionUIButton(checkboxFrame, actionID, cooldownFrame);
end

function GetBonusBarIndex()
	return C_ActionBar.GetBonusBarIndex();
end

function GetBonusBarOffset()
	return C_ActionBar.GetBonusBarOffset();
end

function GetExtraBarIndex()
	return C_ActionBar.GetExtraBarIndex();
end

function GetMultiCastBarIndex()
	return C_ActionBar.GetMultiCastBarIndex();
end

function GetOverrideBarIndex()
	return C_ActionBar.GetOverrideBarIndex();
end

function GetOverrideBarSkin()
	return C_ActionBar.GetOverrideBarSkin();
end

function GetTempShapeshiftBarIndex()
	return C_ActionBar.GetTempShapeshiftBarIndex();
end

function GetVehicleBarIndex()
	return C_ActionBar.GetVehicleBarIndex();
end

function HasBonusActionBar()
	return C_ActionBar.HasBonusActionBar();
end

function HasExtraActionBar()
	return C_ActionBar.HasExtraActionBar();
end

function HasOverrideActionBar()
	return C_ActionBar.HasOverrideActionBar();
end

function HasTempShapeshiftActionBar()
	return C_ActionBar.HasTempShapeshiftActionBar();
end

function HasVehicleActionBar()
	return C_ActionBar.HasVehicleActionBar();
end

function IsPossessBarVisible()
	return C_ActionBar.IsPossessBarVisible();
end

function ChangeActionBarPage(pageIndex)
	return C_ActionBar.SetActionBarPage(pageIndex);
end

function GetActionBarPage()
	return C_ActionBar.GetActionBarPage();
end
