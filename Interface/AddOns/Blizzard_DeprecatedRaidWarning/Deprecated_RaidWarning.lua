-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

RaidNotice_AddMessage = function(_noticeFrame, textString, colorInfo, displayTime)
	RaidWarningUtil.AddMessage(textString, colorInfo, displayTime);
end;

RaidNotice_Clear = function(noticeFrame)
	noticeFrame:ClearMessages();
end;

RaidNotice_UpdateSlot = function(slotFrame, timings, elapsedTime, hasFading)
	if not slotFrame.textScalingMinHeight then
		local minHeight = timings["RAID_NOTICE_MIN_HEIGHT"] or timings.minHeight;
		local maxHeight = timings["RAID_NOTICE_MAX_HEIGHT"] or timings.maxHeight;
		local scaleUp = timings["RAID_NOTICE_SCALE_UP_TIME"] or timings.scaleUpTime;
		local scaleDown = timings["RAID_NOTICE_SCALE_DOWN_TIME"] or timings.scaleDownTime;
		FadingFrame_SetTextScaling(slotFrame, minHeight, maxHeight, scaleUp, scaleDown);
	end
	FadingFrame_UpdateTextScaling(slotFrame, elapsedTime);
	if hasFading then
		FadingFrame_OnUpdate(slotFrame);
	end
end;

RaidNotice_FadeInit = function(slotFrame)
	FadingFrame_OnLoad(slotFrame);
	FadingFrame_SetFadeInTime(slotFrame, 0.2);
	FadingFrame_SetHoldTime(slotFrame, 0.2);
	FadingFrame_SetFadeOutTime(slotFrame, 3.0);
end;
