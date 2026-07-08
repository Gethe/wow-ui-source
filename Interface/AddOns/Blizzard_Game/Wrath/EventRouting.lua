local eventHandlers = {
	["CONFIRM_TALENT_WIPE"] = function(...) GameEvent.HandleConfirmTalentWipe(...) end,
	["CONFIRM_XP_LOSS"] = function(...) GameEvent.HandleConfirmXpLoss(...) end,
	["ENABLE_TAXI_BENCHMARK"] = function(...) GameEvent.HandleEnableTaxiBenchmark(...) end,
	["SPELL_CONFIRMATION_PROMPT"] = function(...) GameEvent.HandleSpellConfirmationPrompt(...) end,
	["SPELL_CONFIRMATION_TIMEOUT"] = function(...) GameEvent.HandleSpellConfirmationTimeout(...) end,
	["USE_GLYPH"] = function(...) GameEvent.HandleUseGlyph(...) end,
};

function GameEvent.RegisterWrathEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
	GameEvent.RegisterTBCEvents();
	GameEvent.RegisterWrathEvents();
end
