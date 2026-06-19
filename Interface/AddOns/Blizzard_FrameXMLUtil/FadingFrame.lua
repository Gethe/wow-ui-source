
function FadingFrame_SetFadeInTime(fadingFrame, time)
	fadingFrame.fadeInTime = time;
end

function FadingFrame_SetHoldTime(fadingFrame, time)
	fadingFrame.holdTime = time;
end

function FadingFrame_SetFadeOutTime(fadingFrame, time)
	fadingFrame.fadeOutTime = time;
end

function FadingFrame_OnLoad(fadingFrame)
	assert(fadingFrame);
	fadingFrame.fadeInTime = 0;
	fadingFrame.holdTime = 0;
	fadingFrame.fadeOutTime = 0;
	fadingFrame:Hide();
end

function FadingFrame_Show(fadingFrame)
	assert(fadingFrame);
	fadingFrame.startTime = GetTime();
	fadingFrame:Show();
end

function FadingFrame_OnUpdate(fadingFrame)
	assert(fadingFrame);
	local elapsed = GetTime() - fadingFrame.startTime;
	local fadeInTime = fadingFrame.fadeInTime;
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime);
		fadingFrame:SetAlpha(alpha);
		return;
	end
	local holdTime = fadingFrame.holdTime;
	if ( elapsed < (fadeInTime + holdTime) ) then
		fadingFrame:SetAlpha(1.0);
		return;
	end
	local fadeOutTime = fadingFrame.fadeOutTime;
	if ( elapsed < (fadeInTime + holdTime + fadeOutTime) ) then
		local alpha = 1.0 - ((elapsed - holdTime - fadeInTime) / fadeOutTime);
		fadingFrame:SetAlpha(alpha);
		return;
	end
	fadingFrame:Hide();
end

function FadingFrame_GetRemainingTime(fadingFrame)
	local elapsed = GetTime() - fadingFrame.startTime;
	return (fadingFrame.holdTime + fadingFrame.fadeInTime + fadingFrame.fadeOutTime - elapsed);
end

function FadingFrame_SetTextScaling(fadingFrame, minHeight, maxHeight, scaleUpTime, scaleDownTime)
	fadingFrame.textScalingMinHeight = minHeight;
	fadingFrame.textScalingMaxHeight = maxHeight;
	fadingFrame.textScalingUpTime = scaleUpTime;
	fadingFrame.textScalingDownTime = scaleDownTime;
end

function FadingFrame_GetTextScalingMinHeight(fadingFrame)
	return fadingFrame.textScalingMinHeight;
end

function FadingFrame_StartTextScaling(fadingFrame)
	fadingFrame.textScalingTime = 0;
end

function FadingFrame_StopTextScaling(fadingFrame)
	fadingFrame.textScalingTime = nil;
end

function FadingFrame_CopyTextScalingTime(sourceFadingFrame, targetFadingFrame)
	targetFadingFrame.textScalingTime = sourceFadingFrame.textScalingTime;
end

function FadingFrame_UpdateTextScaling(fadingFrame, elapsedTime)
	if not fadingFrame.textScalingTime then
		return;
	end

	fadingFrame.textScalingTime = fadingFrame.textScalingTime + elapsedTime;

	local minHeight = fadingFrame.textScalingMinHeight;
	local maxHeight = fadingFrame.textScalingMaxHeight;

	if fadingFrame.textScalingTime <= fadingFrame.textScalingUpTime then
		fadingFrame:SetTextHeight(math.floor(minHeight + ((maxHeight - minHeight) * fadingFrame.textScalingTime / fadingFrame.textScalingUpTime)));
	elseif fadingFrame.textScalingTime <= fadingFrame.textScalingDownTime then
		fadingFrame:SetTextHeight(math.floor(maxHeight - ((maxHeight - minHeight) * (fadingFrame.textScalingTime - fadingFrame.textScalingUpTime) / (fadingFrame.textScalingDownTime - fadingFrame.textScalingUpTime))));
	else
		fadingFrame:SetTextHeight(minHeight);
		fadingFrame.textScalingTime = nil;
	end
end

-- Initializes a fading text slot with text scaling animation. This shared
-- animation style originated with the RaidWarning system.
-- You will need to use both FadingFrame_Show and FadingFrame_StartTextScaling
-- You will also need both FadingFrame_UpdateTextScaling and FadingFrame_OnUpdate.
function FadingFrame_InitSlot(fadingFrame, fadeInTime, fadeOutTime, minHeight, maxHeight, scaleUpTime, scaleDownTime)
	FadingFrame_OnLoad(fadingFrame);
	FadingFrame_SetFadeInTime(fadingFrame, fadeInTime);
	FadingFrame_SetHoldTime(fadingFrame, fadeInTime);
	FadingFrame_SetFadeOutTime(fadingFrame, fadeOutTime);
	FadingFrame_SetTextScaling(fadingFrame, minHeight, maxHeight, scaleUpTime, scaleDownTime);
end

-- Copies fade timing only. Use FadingFrame_CopyTextScalingTime separately if needed.
function FadingFrame_CopyTimes(sourceFadingFrame, targetFadingFrame)
	targetFadingFrame.fadeInTime = sourceFadingFrame.fadeInTime;
	targetFadingFrame.holdTime = sourceFadingFrame.holdTime;
	targetFadingFrame.fadeOutTime = sourceFadingFrame.fadeOutTime;
	targetFadingFrame.startTime = sourceFadingFrame.startTime;
end
