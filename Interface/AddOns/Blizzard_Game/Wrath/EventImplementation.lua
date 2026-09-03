function GameEvent.HandleUseGlyph(_dispatcher, _event)
	if SHOW_INSCRIPTION_LEVEL and UnitLevel("player") >= SHOW_INSCRIPTION_LEVEL then
		OpenGlyphFrame();
	end
end

function GameEvent.HandleConfirmTalentWipe(_dispatcher, _event, ...)
	local talentTab, pointCost = ...;
	HideGossipFrame();
	local dialog = ConfirmTalentWipeDialog_Show(talentTab, pointCost);
	if dialog then
		OpenTalentFrameForTalentWipe();
	end
end

function GameEvent.HandleConfirmXpLoss(_dispatcher, _event)
	local resSicknessTime = GetResSicknessDuration();
	if resSicknessTime then
		if UnitLevel("player") < Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL then
			StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", resSicknessTime, nil, resSicknessTime);
		else
			StaticPopup_Show("XP_LOSS", resSicknessTime, nil, resSicknessTime);
		end
	else
		if UnitLevel("player") <= Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL then
			StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", nil, nil, 1);
		else
			StaticPopup_Show("XP_LOSS_NO_SICKNESS", nil, nil, 1);
		end
	end
	HideGossipFrame();
end

function GameEvent.HandleSpellConfirmationPrompt(_dispatcher, _event, ...)
	local spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID = ...;
	if confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT then
		StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", text, duration, spellID);
	elseif confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING then
		StaticPopup_Show("SPELL_CONFIRMATION_WARNING", text, nil, spellID);
	elseif confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then
		BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID);
	end
end

function GameEvent.HandleSpellConfirmationTimeout(_dispatcher, _event, ...)
	local spellID, confirmType = ...;
	if confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT then
		StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT", spellID);
	elseif confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING then
		StaticPopup_Hide("SPELL_CONFIRMATION_WARNING", spellID);
	elseif confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then
		BonusRollFrame_CloseBonusRoll();
	end
end

function GameEvent.HandleEnableTaxiBenchmark(_dispatcher, _event)
	if not FramerateText:IsShown() then
		ToggleFramerate(true);
	end
end

function GameEvent.HandlePlayerControlGained(_dispatcher, _event)
end
