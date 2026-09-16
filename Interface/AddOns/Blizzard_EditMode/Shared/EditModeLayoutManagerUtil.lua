EditModeLayoutManagerUtil = {};

function EditModeLayoutManagerUtil.GetNewLayoutText(disabled)
	if disabled then
		return HUD_EDIT_MODE_NEW_LAYOUT_DISABLED:format(CreateAtlasMarkup("editmode-new-layout-plus-disabled"));
	end
	return HUD_EDIT_MODE_NEW_LAYOUT:format(CreateAtlasMarkup("editmode-new-layout-plus"));
end

function EditModeLayoutManagerUtil.GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges, manager)
	local areLayoutsFullyMaxed = manager:AreLayoutsFullyMaxed();
	local hasActiveChanges = manager:HasActiveChanges();

	if disableOnMaxLayouts and areLayoutsFullyMaxed then
		return manager:GetMaxLayoutsErrorText();
	elseif disableOnActiveChanges and hasActiveChanges then
		return HUD_EDIT_MODE_UNSAVED_CHANGES;
	end
	return nil;
end

function EditModeLayoutManagerUtil.SetElementDescriptionEnabledState(elementDescription, disableOnMaxLayouts, disableOnActiveChanges, manager)
	local reason = EditModeLayoutManagerUtil.GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges, manager);
	local enabled = reason == nil;
	elementDescription:SetEnabled(enabled);

	if not enabled then
		elementDescription:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddErrorLine(tooltip, reason);
		end);
	end
end
