local eventHandlers = {
	["CONFIRM_TALENT_WIPE"] = GameEvent.HandleConfirmTalentWipe,
	["CONFIRM_XP_LOSS"] = GameEvent.HandleConfirmXpLoss,
	["ENABLE_TAXI_BENCHMARK"] = GameEvent.HandleEnableTaxiBenchmark,
	["SPELL_CONFIRMATION_PROMPT"] = GameEvent.HandleSpellConfirmationPrompt,
	["SPELL_CONFIRMATION_TIMEOUT"] = GameEvent.HandleSpellConfirmationTimeout,
	["USE_GLYPH"] = GameEvent.HandleUseGlyph,
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
