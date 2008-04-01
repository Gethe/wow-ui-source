
COMBATFEEDBACK_FLASHFRAMES = {};

COMBATFEEDBACK_FADEINTIME = 0.2;
COMBATFEEDBACK_HOLDTIME = 0.7;
COMBATFEEDBACK_FADEOUTTIME = 0.3;

CombatFeedbackText = { };
CombatFeedbackText["INTERRUPT"]	= INTERRUPT;
CombatFeedbackText["MISS"]		= MISS;
CombatFeedbackText["RESIST"]	= RESIST;
CombatFeedbackText["DODGE"]		= DODGE;
CombatFeedbackText["PARRY"]		= PARRY;
CombatFeedbackText["BLOCK"]		= BLOCK;
CombatFeedbackText["EVADE"]		= EVADE;
CombatFeedbackText["IMMUNE"]	= IMMUNE;
CombatFeedbackText["DEFLECT"]	= DEFLECT;
CombatFeedbackText["ABSORB"]	= ABSORB;
CombatFeedbackText["REFLECT"]	= REFLECT;

function CombatFeedback_Initialize(feedbackText, fontHeight)
	this.feedbackText = feedbackText;
	this.feedbackFontHeight = fontHeight;
end

function CombatFeedback_OnCombatEvent(event, flags, amount, type)
	local feedbackText = this.feedbackText;
	local fontHeight = this.feedbackFontHeight;
	local text = "";
	local r = 1.0;
	local g = 1.0;
	local b = 1.0;

	if( event == "IMMUNE" ) then
		fontHeight = fontHeight * 0.5;
		text = CombatFeedbackText[event];
	elseif ( event == "WOUND" ) then
		if ( amount ~= 0 ) then
			if ( flags == "CRITICAL" or flags == "CRUSHING" ) then
				fontHeight = fontHeight * 1.5;
			elseif ( flags == "GLANCING" ) then
				fontHeight = fontHeight * 0.75;
			end
			if ( type > 0 ) then
				r = 1.0;
				g = 1.0;
				b = 0.0;
			end
			text = amount;

			if ( tonumber(SHOW_FULLSCREEN_STATUS) ~= 0 ) then
				CombatFeedback_UIFrameFlash(LowHealthFrame, 0.5, 0.5, 1);
			end
		elseif ( flags == "ABSORB" ) then
			fontHeight = fontHeight * 0.75;
			text = CombatFeedbackText["ABSORB"];
		elseif ( flags == "BLOCK" ) then
			fontHeight = fontHeight * 0.75;
			text = CombatFeedbackText["BLOCK"];
		elseif ( flags == "RESIST" ) then
			fontHeight = fontHeight * 0.75;
			text = CombatFeedbackText["RESIST"];
		else
			text = CombatFeedbackText["MISS"];
		end
	elseif ( event == "BLOCK" ) then
		fontHeight = fontHeight * 0.75;
		text = CombatFeedbackText[event];
	elseif ( event == "HEAL" ) then
		text = amount;
		r = 0.0;
		g = 1.0;
		b = 0.0;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	elseif ( event == "ENERGIZE" ) then
		text = amount;
		r = 0.41;
		g = 0.8;
		b = 0.94;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	else
		text = CombatFeedbackText[event];
	end

	this.feedbackStartTime = GetTime();

	feedbackText:SetTextHeight(fontHeight);
	feedbackText:SetText(text);
	feedbackText:SetTextColor(r, g, b);
	feedbackText:SetAlpha(0.0);
	feedbackText:Show();
end

function CombatFeedback_OnUpdate(elapsed)
	local feedbackText = this.feedbackText;
	if ( feedbackText:IsVisible() ) then
		local elapsedTime = GetTime() - this.feedbackStartTime;
		local fadeInTime = COMBATFEEDBACK_FADEINTIME;
		if ( elapsedTime < fadeInTime ) then
			local alpha = (elapsedTime / fadeInTime);
			feedbackText:SetAlpha(alpha);
			return;
		end
		local holdTime = COMBATFEEDBACK_HOLDTIME;
		if ( elapsedTime < (fadeInTime + holdTime) ) then
			feedbackText:SetAlpha(1.0);
			return;
		end
		local fadeOutTime = COMBATFEEDBACK_FADEOUTTIME;
		if ( elapsedTime < (fadeInTime + holdTime + fadeOutTime) ) then
			local alpha = 1.0 - ((elapsedTime - holdTime - fadeInTime) / fadeOutTime);
			feedbackText:SetAlpha(alpha);
			return;
		end
		feedbackText:Hide();
	end
end

-- Function to start a frame flashing
function CombatFeedback_UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, flashInHoldTime, flashOutHoldTime)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while COMBATFEEDBACK_FLASHFRAMES[index] do
			if ( COMBATFEEDBACK_FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end

		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing
		frame.flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone;
		-- Internal duration timer
		frame.flashDurationTimer = 0;
		-- Internal timer
		frame.flashTimer = 0;
		-- Initial flash mode
		frame.flashMode = "IN";
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;

		frame:SetAlpha(0.0);
		frame:Show();
		
		tinsert(COMBATFEEDBACK_FLASHFRAMES, frame);
	end
end

-- Called every frame to update flashing frames
function CombatFeedback_UIFrameFlashUpdate(elapsed)
	local frame;
	local index = 1;
	while COMBATFEEDBACK_FLASHFRAMES[index] do
		frame = COMBATFEEDBACK_FLASHFRAMES[index];
		frame.flashDurationTimer = frame.flashDurationTimer + elapsed;
		-- If flashDuration is exceeded
		if ( (frame.flashDurationTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			CombatFeedback_UIFrameFlashRemoveFrame(frame);
			frame:SetAlpha(1.0);
			frame.flashDurationTimer = nil;
			frame:Hide();
		else
			if ( frame.flashMode == "IN" ) then
				local alpha = frame.flashTimer / frame.fadeInTime;
				frame:SetAlpha(alpha);

				if ( frame.flashTimer >= frame.fadeInTime ) then
					if ( frame.flashInHoldTime and frame.flashInHoldTime > 0 ) then
						frame.flashMode = "IN_HOLD";
					else
						frame.flashMode = "OUT";
					end
					frame.flashTimer = 0;
				else
					frame.flashTimer = frame.flashTimer + elapsed;
				end
			elseif ( frame.flashMode == "IN_HOLD" ) then
				frame:SetAlpha(1.0);

				if ( frame.flashTimer >= frame.flashInHoldTime ) then
					frame.flashMode = "OUT";
					frame.flashTimer = 0;
				else
					frame.flashTimer = frame.flashTimer + elapsed;
				end
			elseif ( frame.flashMode == "OUT" ) then
				local alpha = 1.0 - frame.flashTimer / frame.fadeOutTime;
				frame:SetAlpha(alpha);

				if ( frame.flashTimer >= frame.fadeOutTime ) then
					if ( frame.flashOutHoldTime and frame.flashOutHoldTime > 0 ) then
						frame.flashMode = "OUT_HOLD";
					else
						frame.flashMode = "IN";
					end
					frame.flashTimer = 0;
				else
					frame.flashTimer = frame.flashTimer + elapsed;
				end
				frame:SetAlpha(alpha);
			elseif ( frame.flashMode == "OUT_HOLD" ) then
				frame:SetAlpha(0.0);

				frame.flashTimer = frame.flashTimer + elpased;
				if ( frame.flashTimer >= frame.flashOutHoldTime ) then
					frame.flashMode = "IN";
					frame.flashTimer = 0;
				else
					frame.flashTimer = frame.flashTimer + elapsed;
				end
			end
		end

		if ( not GetUIPanel("fullscreen") ) then
			-- this feature is only supposed to be seen when the screen is covered
			-- also, alpha is set to 0 so the frame can still call its OnUpdate functions
			frame:SetAlpha(0.0);
		end

		index = index + 1;
	end
end

function CombatFeedback_UIFrameFlashRemoveFrame(frame)
	tDeleteItem(COMBATFEEDBACK_FLASHFRAMES, frame);
end
