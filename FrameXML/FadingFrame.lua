
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
