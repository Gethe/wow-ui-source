
COMBATFEEDBACK_FADEINTIME = 0.2;
COMBATFEEDBACK_HOLDTIME = 0.7;
COMBATFEEDBACK_FADEOUTTIME = 0.3;

SCHOOL_MASK_NONE		= 0x00;
SCHOOL_MASK_PHYSICAL	= 0x01;
SCHOOL_MASK_HOLY		= 0x02;
SCHOOL_MASK_FIRE		= 0x04;
SCHOOL_MASK_NATURE		= 0x08;
SCHOOL_MASK_FROST		= 0x10;
SCHOOL_MASK_SHADOW		= 0x20;
SCHOOL_MASK_ARCANE		= 0x40;

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


function CombatFeedback_Initialize(self, feedbackText, fontHeight)
	self.feedbackText = feedbackText;
	self.feedbackFontHeight = fontHeight;
end

function CombatFeedback_OnCombatEvent(self, event, flags, amount, type)
	local feedbackText = self.feedbackText;
	local fontHeight = self.feedbackFontHeight;
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
			if ( type ~= SCHOOL_MASK_PHYSICAL ) then
				r = 1.0;
				g = 1.0;
				b = 0.0;
			end
			text = BreakUpLargeNumbers(amount);
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
		text = BreakUpLargeNumbers(amount);
		r = 0.0;
		g = 1.0;
		b = 0.0;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	elseif ( event == "ENERGIZE" ) then
		text = BreakUpLargeNumbers(amount);
		r = 0.41;
		g = 0.8;
		b = 0.94;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	else
		text = CombatFeedbackText[event];
	end

	self.feedbackStartTime = GetTime();

	feedbackText:SetTextHeight(fontHeight);
	feedbackText:SetText(text);
	feedbackText:SetTextColor(r, g, b);
	feedbackText:SetAlpha(0.0);
	feedbackText:Show();
end

function CombatFeedback_OnUpdate(self, elapsed)
	local feedbackText = self.feedbackText;
	if ( feedbackText:IsVisible() ) then
		local elapsedTime = GetTime() - self.feedbackStartTime;
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