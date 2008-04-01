
COMBATFEEDBACK_FADEINTIME = 0.2;
COMBATFEEDBACK_HOLDTIME = 0.7;
COMBATFEEDBACK_FADEOUTTIME = 0.3;

CombatFeedbackText = { };
CombatFeedbackText["MISS"]		= TEXT(MISS);
CombatFeedbackText["EVADE"]		= TEXT(EVADE);
CombatFeedbackText["DODGE"]		= TEXT(DODGE);
CombatFeedbackText["PARRY"]		= TEXT(PARRY);
CombatFeedbackText["BLOCK"]		= TEXT(BLOCK);
CombatFeedbackText["STUN"]		= TEXT(STUN);
CombatFeedbackText["INTERRUPT"]	= TEXT(INTERRUPT);
CombatFeedbackText["IMMUNE"]	= TEXT(IMMUNE);
CombatFeedbackText["RESIST"]	= TEXT(RESIST);


SpellMissFeedbackText = { };
SpellMissFeedbackText["NONE"]			= nil;
SpellMissFeedbackText["PHYSICAL"]		= TEXT(SPELLMISSED_MISS);
SpellMissFeedbackText["RESIST"]			= TEXT(SPELLMISSED_RESIST);
SpellMissFeedbackText["IMMUNE"]			= TEXT(SPELLMISSED_IMMUNE);
SpellMissFeedbackText["EVADED"]			= TEXT(SPELLMISSED_EVADE);
SpellMissFeedbackText["DODGED"]			= TEXT(SPELLMISSED_DODGE);
SpellMissFeedbackText["BLOCKED"]		= TEXT(SPELLMISSED_BLOCK);
SpellMissFeedbackText["TEMPIMMUNE"]		= TEXT(SPELLMISSED_IMMUNE);

function CombatFeedback_Initialize(feedbackText, fontHeight)
	this.feedbackText = feedbackText;
	this.feedbackFontHeight = fontHeight;
end

function CombatFeedback_OnSpellMissEvent(event) 
	local feedbackText = this.feedbackText;
	local fontHeight = this.feedbackFontHeight;
	local r = 1.0;
	local g = 1.0;
	local b = 1.0;

	local text = SpellMissFeedbackText[event];
	if ( text == nil ) then
		return;
	end

	if ( event == "IMMUNE" or event == "TEMPIMMUNE" ) then
		fontHeight = fontHeight * 0.5;
	end

	this.feedbackStartTime = GetTime();
	feedbackText:SetTextHeight(fontHeight);
	feedbackText:SetText(text);
	feedbackText:SetTextColor(r, g, b);
	feedbackText:SetAlpha(0.0);
	feedbackText:Show();
end

function CombatFeedback_OnCombatEvent(event, flags, amount, type)
	local feedbackText = this.feedbackText;
	local fontHeight = this.feedbackFontHeight;
	local text = "";
	local r = 1.0;
	local g = 1.0;
	local b = 1.0;

	if( event == "IMMUNE" ) then
		text = CombatFeedbackText["IMMUNE"];
		fontHeight = fontHeight * 0.5;
	elseif ( event == "WOUND" ) then
		if ( flags == "ABSORB" )then
			fontHeight = fontHeight * 0.75;
			text = TEXT(ABSORB);
		elseif ( amount ~= 0 ) then
			if ( flags == "CRITICAL" or flags == "GLANCING" or flags == "CRUSHING" ) then
				fontHeight = fontHeight * 1.5;
			end
			if ( amount < 0 ) then
				r = 0.0;
				g = 1.0;
				b = 0.0;
			elseif ( type > 0 ) then
				r = 1.0;
				g = 1.0;
				b = 0.0;
			end
			text = amount;
		else
			text = CombatFeedbackText["MISS"];
		end
	elseif ( event == "BLOCK" ) then
		fontHeight = fontHeight * 0.75;
		text = TEXT(BLOCK);
	elseif ( event == "HEAL" ) then
		text = amount;
		r = 0.0;
		g = 1.0;
		b = 0.0;
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
