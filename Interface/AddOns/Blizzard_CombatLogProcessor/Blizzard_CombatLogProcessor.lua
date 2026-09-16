local _ENV = GetCurrentEnvironment();

CombatLogProcessor = {};

function CombatLogProcessor:OnLoad()
	self.filterSettings = nil;
	self.refilterTicker = nil;

	local function OnCombatLogEvent()
		self:ProcessCurrentCombatEvent();
	end

	local function OnRefilterEntries()
		self:RefilterEntries();
	end

	local function OnApplyFilterSettings(filterSettings)
		self:SetFilterSettings(filterSettings);
	end

	Event.RegisterCallback("COMBAT_LOG_EVENT", OnCombatLogEvent);
	Event.RegisterCallback("COMBAT_LOG_REFILTER_ENTRIES", OnRefilterEntries);
	Event.RegisterCallback("COMBAT_LOG_APPLY_FILTER_SETTINGS", OnApplyFilterSettings);
end

function CombatLogProcessor:GetFilterSettings()
	return self.filterSettings;
end

function CombatLogProcessor:SetFilterSettings(filterSettings)
	self.filterSettings = filterSettings;
	self:ApplyFilterSettings(filterSettings);
end

function CombatLogProcessor:StartRefiltering()
	if self:IsRefiltering() then
		return;
	end

	local messageIndex = 0;

	local function OnTickerTick()
		-- Cycle through combat log entries front-to-back until we find one
		-- that can be shown in the combat log frame.

		local isEntryValid = (C_CombatLogSecure.GetCurrentEntryInfo() ~= nil);
		while isEntryValid do
			messageIndex = messageIndex + 1;

			if C_CombatLogSecure.ShouldShowCurrentEntry() then
				self:ProcessCurrentEntry();
				C_CombatLogSecure.SeekToPreviousEntry();
				break;
			else
				isEntryValid = (C_CombatLogSecure.SeekToPreviousEntry() ~= nil);
			end
		end

		local messageCount = C_CombatLogSecure.GetEntryCount();
		local messageLimit = C_CombatLog.GetMessageLimit();
		local messageProgressLimit = math.min(messageCount, messageLimit);

		if messageProgressLimit > 0 then
			local progress = Saturate(messageIndex / messageProgressLimit);
			CombatLogOutbound.SignalRefilterUpdate(progress);
		else
			CombatLogOutbound.SignalRefilterUpdate(1);
		end

		-- Refiltering finishes if we've advanced the buffer beyond all
		-- available messages, or if we've hit the (user-configurable) message
		-- limit.

		if not isEntryValid or messageIndex >= messageLimit then
			self:StopRefiltering();
		end
	end

	self.refilterTicker = C_Timer.NewTicker(0, OnTickerTick);
	C_CombatLogSecure.SeekToNewestEntry();
	CombatLogOutbound.SignalRefilterStarted();
end

function CombatLogProcessor:StopRefiltering()
	if not self:IsRefiltering() then
		return;
	end

	self.refilterTicker:Cancel();
	self.refilterTicker = nil;
	CombatLogOutbound.SignalRefilterFinished();
end

function CombatLogProcessor:IsRefiltering()
	return self.refilterTicker ~= nil;
end

function CombatLogProcessor:RefilterEntries()
	self:StopRefiltering();
	self:StartRefiltering();
end

function CombatLogProcessor:ProcessCurrentCombatEvent()
	local filterSettings = self:GetFilterSettings();
	local text, r, g, b = self:GenerateMessage(filterSettings, C_CombatLogSecure.GetCurrentEventInfo());

	if text then
		C_CombatLogSecure.CreateCombatLogMessage(text, r, g, b, Enum.CombatLogMessageOrder.Newest);
	end
end

function CombatLogProcessor:ProcessCurrentEntry()
	local filterSettings = self:GetFilterSettings();
	local text, r, g, b = self:GenerateMessage(filterSettings, C_CombatLogSecure.GetCurrentEntryInfo());

	if text then
		C_CombatLogSecure.CreateCombatLogMessage(text, r, g, b, Enum.CombatLogMessageOrder.Oldest);
	end
end

function CombatLogProcessor:ApplyFilterSettings(filterSettings)
	C_CombatLogSecure.ClearEventFilters();

	-- Loop over all associated filters
	local eventList;
	for k,v in pairs(filterSettings.filters) do
		local eList

		-- Only use the first filter's eventList because for some reason each filter that the player can see actually
		-- has two filters, one for source flags and one for dest flags (??), even though only the eventList for the source
		-- flags is updated properly
		eventList = filterSettings.filters[1].eventList;
		if eventList then
			for k2, v2 in pairs(eventList) do
				-- The true comparison is because check boxes whose parent is unchecked will be non-false but not "true"
				if v2 == true then
					eList = eList and (eList .. "," .. k2) or k2
				end
			end
		end

		local sourceFlags;
		local destFlags;

		if v.sourceFlags then
			sourceFlags = 0;
			for k2, v2 in pairs(v.sourceFlags) do
				if type(k2) == "string" then
					sourceFlags = k2;  -- GUID
					break;
				elseif v2 then
					sourceFlags = bit.bor(sourceFlags, k2);
				end
			end
		end

		if v.destFlags then
			destFlags = 0;
			for k2, v2 in pairs(v.destFlags) do
				if type(k2) == "string" then
					destFlags = k2;  -- GUID
					break;
				elseif v2 then
					destFlags = bit.bor(destFlags, k2);
				end
			end
		end

		if type(sourceFlags) == "string" and destFlags == 0 then
			destFlags = nil;
		end

		if type(destFlags) == "string" and sourceFlags == 0 then
			sourceFlags = nil;
		end

		-- This is a HACK!!!  Need filters to be able to accept empty or zero sourceFlags or destFlags
		if sourceFlags == 0 or destFlags == 0 then
			C_CombatLogSecure.AddEventFilter("", COMBATLOG_FILTER_MINE, nil);
		else
			C_CombatLogSecure.AddEventFilter(eList, sourceFlags, destFlags);
		end
	end
end

local EventTemplateFormats = {
	["SPELL_AURA_BROKEN_SPELL"] = TEXT_MODE_A_STRING_3,
	["SPELL_CAST_START"] = TEXT_MODE_A_STRING_2,
	["SPELL_CAST_SUCCESS"] = TEXT_MODE_A_STRING_2,
	["SPELL_EMPOWER_START"] = TEXT_MODE_A_STRING_2,
	["SPELL_EMPOWER_END"] = TEXT_MODE_A_STRING_2
};

local DefaultCombatLogLineColor = CreateColor(1, 1, 1, 1);

function CombatLogProcessor:GenerateMessage(filterSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	-- [environmentalDamageType]
	-- [spellName, spellRank, spellSchool]
	-- [damage, school, [resisted, blocked, absorbed, crit, glancing, crushing]]

	-- Upvalue this, we're gonna use it a lot
	local settings = filterSettings.settings;

	local lineColor = DefaultCombatLogLineColor;
	local sourceColor, destColor = nil, nil;

	local braceColor = "FFFFFFFF";
	local abilityColor = "FFFFFF00";

	-- Processing variables
	local textMode = TEXT_MODE_A;
	local timestampEnabled = settings.timestamp;
	local hideBuffs = settings.hideBuffs;
	local hideDebuffs = settings.hideDebuffs;
	local sourceEnabled = true;
	local falseSource = false;
	local destEnabled = true;
	local valueEnabled = true;
	local valueTypeEnabled = true;
	local resultEnabled = true;
	local powerTypeEnabled = true;
	local extraSpellEnabled = false;
	local valueIsItem = false;
	local withPoints = false;
	local forceDestPossessive = false;

	-- Get the initial string
	local schoolString;
	local resultStr = nil;

	local formatString = TEXT_MODE_A_STRING_1;
	if ( EventTemplateFormats[event] ) then
		formatString = EventTemplateFormats[event];
	end

	-- Replacements to do:
	-- * Src, Dest, Action, Spell, Amount, Result

	-- Spell standard order
	local spellId, spellName, spellSchool = nil, nil, nil;
	local extraSpellId, extraSpellName, extraSpellSchool = nil, nil, nil;

	-- For Melee/Ranged swings and enchants
	local nameIsNotSpell;
	local extraNameIsNotSpell = false;

	-- Damage standard order
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, overhealing = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
	-- Miss argument order
	local missType, isOffHand, amountMissed;
	-- Aura arguments
	local auraType; -- BUFF or DEBUFF
	-- Energize Arguments
	local overEnergize = nil;

	-- Enchant arguments
	local itemId, itemName;

	-- Special Spell values
	local valueType = 1;  -- 1 = School, 2 = Power Type
	local extraAmount; -- Used for Drains and Leeches
	local powerType; -- Used for energizes, drains and leeches
	local alternatePowerType; -- Used for energizes, drains and leeches
	local environmentalType; -- Used for environmental damage
	local message; -- Used for server spell messages
	local originalEvent = event; -- Used for spell links
	local remainingPoints;	--Used for absorbs with the correct flag set (like Power Word: Shield)

	--Extra data for PARTY_KILL, SPELL_INSTAKILL and UNIT_DIED
	local unconsciousOnDeath = 0;

	-- Generic disabling stuff
	if ( not sourceName or C_CombatLog.DoesObjectMatchFilter(sourceFlags, Enum.CombatLogObject.None) ) then
		sourceEnabled = false;
	end
	if ( not destName or C_CombatLog.DoesObjectMatchFilter(destFlags, Enum.CombatLogObject.None) ) then
		destEnabled = false;
	end

	local subVal = string.sub(event, 1, 5)

	-- Swings
	if ( subVal == "SWING" ) then
		spellName = ACTION_SWING;
		nameIsNotSpell = true;
	end

	-- Break out the arguments into variable
	if ( event == "SWING_DAMAGE" ) then
		-- Damage standard
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...;

		-- Parse the result string
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false;
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end

	elseif ( event == "SWING_MISSED" ) then
		spellName = ACTION_SWING;

		-- Miss type
		missType, isOffHand, amountMissed, critical = ...;

		-- Result String
		if ( missType == "ABSORB" ) then
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
		elseif( missType == "RESIST" or missType == "BLOCK" ) then
			resultStr = string.format(_ENV["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);
		else
			resultStr = _ENV["ACTION_SWING_MISSED_"..missType];
		end

		-- Miss Type
		if ( settings.fullText and missType ) then
			event = string.format("%s_%s", event, missType);
		end

		-- Disable appropriate sections
		nameIsNotSpell = true;
		valueEnabled = false;
		resultEnabled = true;

	elseif ( subVal == "SPELL" ) then	-- Spell standard arguments
		spellId, spellName, spellSchool = ...;

		if ( event == "SPELL_DAMAGE" or event == "SPELL_BUILDING_DAMAGE") then
			-- Damage standard
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

			-- Parse the result string
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			if ( overkill > 0 ) then
				amount = amount - overkill;
			end
		elseif ( event == "SPELL_MISSED" ) then
			-- Miss type
			missType,  isOffHand, amountMissed, critical = select(4, ...);

			resultEnabled = true;
			-- Result String
			if ( missType == "ABSORB" ) then
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
			elseif( missType == "RESIST" or missType == "BLOCK" ) then
				if ( amountMissed ~= 0 ) then
					resultStr = string.format(_ENV["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);
				else
					resultEnabled = false;
				end
			else
				resultStr = _ENV["ACTION_SWING_MISSED_"..missType];
			end

			-- Miss Event
			if ( missType ) then
				event = string.format("%s_%s", event, missType);
			end

			-- Disable appropriate sections
			valueEnabled = false;
		elseif ( event == "SPELL_HEAL" or event == "SPELL_BUILDING_HEAL") then
			-- Did the heal crit?
			amount, overhealing, absorbed, critical = select(4, ...);

			-- Parse the result string
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Temporary Spell School Hack
			school = spellSchool;

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;

			amount = amount - overhealing;
		elseif ( event == "SPELL_ENERGIZE" ) then
			-- Set value type to be a power type
			valueType = 2;

			-- Did the heal crit?
			amount, overEnergize, powerType, alternatePowerType = select(4, ...);

			-- Parse the result string
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;
		elseif ( string.sub(event, 1, 14) == "SPELL_PERIODIC" ) then

			if ( event == "SPELL_PERIODIC_MISSED" ) then
				-- Miss type
				missType, isOffHand, amountMissed, critical = select(4, ...);

				-- Result String
				if ( missType == "ABSORB" ) then
					resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
				else
					resultStr = _ENV["ACTION_SPELL_PERIODIC_MISSED_"..missType];
				end

				-- Miss Event
				if ( settings.fullText and missType ) then
					event = string.format("%s_%s", event, missType);
				end

				-- Disable appropriate sections
				valueEnabled = false;
				resultEnabled = true;
			elseif ( event == "SPELL_PERIODIC_DAMAGE" ) then
				-- Damage standard
				amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

				-- Parse the result string
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end

				if ( overkill > 0 ) then
					amount = amount - overkill;
				end
			elseif ( event == "SPELL_PERIODIC_HEAL" ) then
				-- Did the heal crit?
				amount, overhealing, absorbed, critical = select(4, ...);

				-- Parse the result string
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Temporary Spell School Hack
				school = spellSchool;

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;

				amount = amount - overhealing;
			elseif ( event == "SPELL_PERIODIC_DRAIN" ) then
				-- Special attacks
				amount, powerType, extraAmount, alternatePowerType = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				--resultStr = _ENV[textModeString .. "RESULT"];
				--resultStr = string.gsub(resultStr,"$resultString", _ENV["ACTION_"..event.."_RESULT"]);

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
			elseif ( event == "SPELL_PERIODIC_LEECH" ) then
				-- Special attacks
				amount, powerType, extraAmount, alternatePowerType = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				resultStr = string.format(_ENV["ACTION_SPELL_PERIODIC_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType), nil, extraAmount) --"($extraAmount $powerType Gained)"

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
			elseif ( event == "SPELL_PERIODIC_ENERGIZE" ) then
				-- Set value type to be a power type
				valueType = 2;

				-- Did the heal crit?
				amount, overEnergize, powerType, alternatePowerType = select(4, ...);

				-- Parse the result string
				--resultStr = _ENV[textModeString .. "RESULT"];
				--resultStr = string.gsub(resultStr,"$resultString", _ENV["ACTION_"..event.."_RESULT"]);
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;
			end
		elseif ( event == "SPELL_CAST_START" ) then	-- Spellcast
			if ( not destName ) then
				destEnabled = false;
			end
			if ( not sourceName ) then
				sourceName = COMBATLOG_UNKNOWN_UNIT;
				sourceEnabled = true;
				falseSource = true;
			end

			-- Disable appropriate types
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CAST_SUCCESS" ) then
			if ( not destName ) then
				destEnabled = false;
			end
			if ( not sourceName ) then
				sourceName = COMBATLOG_UNKNOWN_UNIT;
				sourceEnabled = true;
				falseSource = true;
			end

			-- Disable appropriate types
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CAST_FAILED" ) then
			if ( not destName ) then
				destEnabled = false;
			end
			-- Miss reason
			missType = select(4, ...);

			-- Result String
			resultStr = string.format("(%s)", missType);
			--resultStr = string.gsub(_ENV[textModeString .. "RESULT"],"$resultString", missType);

			-- Disable appropriate sections
			valueEnabled = false;
			destEnabled = false;

			if ( not resultStr ) then
				resultEnabled = false;
			end
		elseif ( event == "SPELL_DRAIN" ) then		-- Special Spell effects
			-- Special attacks
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
		elseif ( event == "SPELL_LEECH" ) then
			-- Special attacks
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Result String
			resultStr = string.format(_ENV["ACTION_SPELL_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType), nil, extraAmount)

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
		elseif ( event == "SPELL_INTERRUPT" ) then
			-- Spell interrupted
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_EXTRA_ATTACKS" ) then
			-- Special attacks
			amount = select(4, ...);

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_SUMMON" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_RESURRECT" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CREATE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_INSTAKILL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;

			unconsciousOnDeath = select(5, ...);
		elseif ( event == "SPELL_DURABILITY_DAMAGE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_DURABILITY_DAMAGE_ALL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_DISPEL_FAILED" ) then
			-- Extra Spell standard
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_DISPEL" or event == "SPELL_STOLEN" ) then
			-- Extra Spell standard, Aura standard
			extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...);

			-- Event Type
			event = string.format("%s_%s", event, auraType);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				valueEnabled = true;
			else
				valueEnabled = false;
			end

			-- Disable appropriate sections
			resultEnabled = false;
		elseif ( event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL") then

			-- Extra Spell standard, Aura standard
			if(event == "SPELL_AURA_BROKEN") then
				auraType = select(4, ...);
			else
				extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...);
			end

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			-- Event Type
			event = string.format("%s_%s", event, auraType);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				valueEnabled = true;
			else
				forceDestPossessive = true;
				valueEnabled = false;
			end

			resultEnabled = false;
		elseif ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_REFRESH") then		-- Aura Events
			-- Aura standard
			auraType, remainingPoints = select(4, ...);

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			formatString = TEXT_MODE_A_STRING_1;

			-- Event Type
			event = string.format("%s_%s", event, auraType);

			if ( remainingPoints and settings.fullText ) then
				withPoints = true;
			end

			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" ) then
			-- Aura standard
			auraType, amount = select(4, ...);

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			-- Event Type
			event = string.format("%s_%s", event, auraType);


			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_EMPOWER_START" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_EMPOWER_END" or event == "SPELL_EMPOWER_INTERRUPT" ) then
			amount = select(4, ...);
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		end
	elseif ( subVal == "RANGE" ) then
		--spellName = ACTION_RANGED;
		--nameIsNotSpell = true;

		-- Shots are spells, technically
		spellId, spellName, spellSchool = ...;
		if ( event == "RANGE_DAMAGE" ) then
			-- Damage standard
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

			-- Parse the result string
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize);

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			nameIsNotSpell = true;

			if ( overkill > 0 ) then
				amount = amount - overkill;
			end
		elseif ( event == "RANGE_MISSED" ) then
			spellName = ACTION_RANGED;

			-- Miss type
			missType, isOffHand, amountMissed, critical = select(4,...);

			-- Result String
			if ( missType == "ABSORB" ) then
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
			elseif( missType == "RESIST" or missType == "BLOCK" ) then
				resultStr = string.format(_ENV["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);

			else
				resultStr = _ENV["ACTION_RANGE_MISSED_"..missType];
			end

			-- Miss Type
			if ( settings.fullText and missType ) then
				event = string.format("%s_%s", event, missType);
			end

			-- Disable appropriate sections
			nameIsNotSpell = true;
			valueEnabled = false;
			resultEnabled = true;
		end
	elseif ( event == "DAMAGE_SHIELD" ) then	-- Damage Shields
		-- Spell standard, Damage standard
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		-- Disable appropriate sections
		if ( not resultStr ) then
			resultEnabled = false
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	elseif ( event == "DAMAGE_SHIELD_MISSED" ) then
		-- Spell standard, Miss type
		spellId, spellName, spellSchool, missType = ...;

		-- Result String
		resultStr = _ENV["ACTION_DAMAGE_SHIELD_MISSED_"..missType];

		-- Miss Event
		if ( settings.fullText and missType ) then
			event = string.format("%s_%s", event, missType);
		end

		-- Disable appropriate sections
		valueEnabled = false;
		if ( not resultStr ) then
			resultEnabled = false;
		end
	elseif ( event == "PARTY_KILL" ) then	-- Unique Events
		-- Disable appropriate sections
		resultEnabled = false;
		valueEnabled = false;

		unconsciousOnDeath = select(5, ...);
	elseif ( event == "ENCHANT_APPLIED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		resultEnabled = false;
	elseif ( event == "ENCHANT_REMOVED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		resultEnabled = false;
		sourceEnabled = false;

	elseif ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" ) then
		local recapID;
		recapID, unconsciousOnDeath = ...;
		-- handle death recaps
		if ( destGUID == UnitGUID("player") ) then
			lineColor = COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_MINE];
			return C_DeathRecap.GetRecapLink(recapID), lineColor.r, lineColor.g, lineColor.b;
		end

		-- Swap Source with Dest
		sourceName = destName;
		sourceGUID = destGUID;
		sourceFlags = destFlags;

		-- Disable appropriate sections
		resultEnabled = false;
		sourceEnabled = true;
		destEnabled = false;
		valueEnabled = false;

	elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
		--Environmental Type, Damage standard
		environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		environmentalType = string.upper(environmentalType);

		-- Miss Event
		spellName = _ENV["ACTION_ENVIRONMENTAL_DAMAGE_"..environmentalType];
		spellSchool = school;
		nameIsNotSpell = true;

		-- Parse the result string
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		-- Environmental Event
		if ( settings.fullText and environmentalType ) then
			event = "ENVIRONMENTAL_DAMAGE_"..environmentalType;
		end

		if ( not resultStr ) then
			resultEnabled = false;
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	elseif ( event == "DAMAGE_SPLIT" ) then
		-- Spell Standard Arguments, Damage standard
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	end

	-- Throw away all of the assembled strings and just grab a premade one
	if ( settings.fullText ) then
		local formatStringEvent;
		if (withPoints) then
			formatStringEvent = string.format("ACTION_%s_WITH_POINTS_FULL_TEXT", event);
		else
			formatStringEvent = string.format("ACTION_%s_FULL_TEXT", event);
		end

		-- Get the base string
		if ( _ENV[formatStringEvent] ) then
			formatString = _ENV[formatStringEvent];
		end

		-- Set any special cases
		if ( not sourceEnabled ) then
			formatStringEvent = formatStringEvent.."_NO_SOURCE";
		end
		if ( not destEnabled ) then
			formatStringEvent = formatStringEvent.."_NO_DEST";
		end


		if (event=="DAMAGE_SPLIT" and resultStr) then
			if (amount == 0) then
				formatStringEvent = "ACTION_DAMAGE_SPLIT_ABSORBED_FULL_TEXT";
			else
				formatStringEvent = "ACTION_DAMAGE_SPLIT_RESULT_FULL_TEXT";
			end
		end

		-- Get the special cased string
		if ( _ENV[formatStringEvent] ) then
			formatString = _ENV[formatStringEvent];
		end

		sourceEnabled = true;
		destEnabled = true;
		valueEnabled = true;
	end

	-- Actor name construction.
	--
	local sourceNameStr = "";
	local destNameStr = "";
	local sourceIcon = "";
	local destIcon = "";
	local spellNameStr = spellName;
	local extraSpellNameStr = extraSpellName;
	local itemNameStr = itemName;
	local actionEvent = "ACTION_"..event;

	--This is to get PARTY_KILL COMBAT_LOG_EVENTs on UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "PARTY_KILL" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_PARTY_KILL_UNCONSCIOUS";

			if ( settings.fullText ) then
				formatString = _ENV["ACTION_PARTY_KILL_UNCONSCIOUS_FULL_TEXT"];
			end
		end
	end

	--This is to get SPELL_INSTAKILL COMBAT_LOG_EVENTs on UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "SPELL_INSTAKILL" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_SPELL_INSTAKILL_UNCONSCIOUS";

			if ( settings.fullText ) then
				if ( not sourceEnabled ) then
					formatString = _ENV["ACTION_SPELL_INSTAKILL_UNCONSCIOUS_FULL_TEXT_NO_SOURCE"];
				else
					formatString = _ENV["ACTION_SPELL_INSTAKILL_UNCONSCIOUS_FULL_TEXT"];
				end
			end
		end
	end

	--This is to get the UNIT_DIED COMBAT_LOG_EVENTs for UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "UNIT_DIED" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_UNIT_BECCOMES_UNCONSCIOUS";

			if ( settings.fullText ) then
				formatString = _ENV["ACTION_UNIT_BECOMES_UNCONSCIOUS_FULL_TEXT"];
			end
		end
	end

	local actionStr = _ENV[actionEvent];
	local timestampStr = timestamp;
	local powerTypeString = "";

	-- If this ever succeeds, the event string is missing.
	--
	if ( not actionStr ) then
		actionStr = event;
	end

	-- Initialize the strings now
	sourceNameStr, destNameStr = sourceName, destName;

	-- Special changes for localization when not in full text mode
	if ( not settings.fullText and COMBAT_LOG_UNIT_YOU_ENABLED == "1" ) then
		-- Replace your name with "You";
		if ( sourceName and C_CombatLog.DoesObjectMatchFilter(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE;
		end
		if ( destName and C_CombatLog.DoesObjectMatchFilter(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST;
		end
		-- Apply the possessive form to the source
		if ( sourceName and spellName and _ENV[actionEvent.."_POSSESSIVE"] == "1" ) then
			if ( sourceName and C_CombatLog.DoesObjectMatchFilter(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE_POSSESSIVE;
			end
		end
		-- Apply the possessive form to the source
		if ( destName and ( extraSpellName or itemName ) ) then
			if ( destName and C_CombatLog.DoesObjectMatchFilter(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST_POSSESSIVE;
			end
		end

	-- If its full text mode
	else
		-- Apply the possessive form to the source
		if ( sourceName and spellName and _ENV[actionEvent.."_POSSESSIVE"] == "1" ) then
			sourceNameStr = string.format(TEXT_MODE_A_STRING_POSSESSIVE, sourceNameStr);
		end

		-- Apply the possessive form to the dest if the dest has a spell
		if ( ( extraSpellName or forceDestPossessive  or itemName ) and destName ) then
			destNameStr = string.format(TEXT_MODE_A_STRING_POSSESSIVE, destNameStr);
		end
	end

	-- Unit Icons
	if ( settings.unitIcons ) then
		if ( sourceName ) then
			sourceIcon = CombatLogUtil.GetUnitIcon(sourceRaidFlags, "source");
		end
		if ( destName ) then
			destIcon = CombatLogUtil.GetUnitIcon(destRaidFlags, "dest");
		end
	end

	-- Get the source color
	if ( sourceName ) then
		sourceColor	= CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
	end

	-- Get the dest color
	if ( destName ) then
		destColor	= CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
	end

	-- Whole line coloring
	if ( settings.lineColoring ) then
		if ( settings.lineColorPriority == 3 or ( not sourceName and not destName) ) then
			lineColor = CombatLogUtil.GetColorByEventType( event, filterSettings );
		else
			if ( ( settings.lineColorPriority == 1 and sourceName ) or not destName ) then
				lineColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			elseif ( ( settings.lineColorPriority == 2 and destName ) ) then
				lineColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
			else
				lineColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			end
		end
	end

	-- Power Type
	if ( powerType ) then
		powerTypeString =  CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType);
		if powerTypeString == BALANCE_NEGATIVE_ENERGY then
			amount = abs(amount);
		end
	end

	-- Only replace if there's an amount
	if ( amount ) then
		local amountColor;

		-- Color amount numbers
		if ( settings.amountColoring ) then
			-- To make white swings white
			if ( settings.noMeleeSwingColoring and school == Enum.Damageclass.MaskPhysical and not spellId )  then
				-- Do nothing
			elseif ( settings.amountActorColoring ) then
				if ( sourceName ) then
					amountColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					amountColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.amountSchoolColoring ) then
				amountColor = CombatLogUtil.GetColorBySchool(school, filterSettings);
			else
				amountColor = filterSettings.colors.defaults.damage;
			end

		end
		-- Highlighting
		if ( settings.amountHighlighting ) then
			local colorArray;
			if ( not amountColor ) then
				colorArray = lineColor;
			else
				colorArray = amountColor;
			end
			amountColor  = CombatLogUtil.HighlightColor (colorArray);
		end

		amount = BreakUpLargeNumbers(amount);
		if ( amountColor ) then
			amount = CombatLogUtil.WrapTextInColor(amount, amountColor);
		end

		schoolString = CombatLogUtil.GetSpellSchoolString(school);
		local schoolNameColor = nil;
		-- Color school names
		if ( settings.schoolNameColoring ) then
			if ( settings.noMeleeSwingColoring and school == Enum.Damageclass.MaskPhysical and not spellId )  then
			elseif ( settings.schoolNameActorColoring ) then
					if ( sourceName ) then
						schoolNameColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
					elseif ( destName ) then
						schoolNameColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
					end
			else
				schoolNameColor = CombatLogUtil.GetColorBySchool( school, filterSettings );
			end
		end
		-- Highlighting
		if ( settings.schoolNameHighlighting ) then
			local colorArray;
			if ( not schoolNameColor ) then
				colorArray = lineColor;
			else
				colorArray = schoolNameColor;
			end
			schoolNameColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( schoolNameColor ) then
			schoolString = CombatLogUtil.WrapTextInColor(schoolString, schoolNameColor);
		end

	end

	-- Color source names
	if ( settings.unitColoring ) then
		if ( sourceName and settings.sourceColoring ) then
			sourceNameStr = CombatLogUtil.WrapTextInColor(sourceNameStr, sourceColor);
		end
		if ( destName and settings.destColoring ) then
			destNameStr = CombatLogUtil.WrapTextInColor(destNameStr, destColor);
		end
	end

	-- If there's an action (always)
	if ( actionStr ) then
		local actionColor = nil;
		-- Color ability names
		if ( settings.actionColoring ) then

			if ( settings.actionActorColoring ) then
				if ( sourceName ) then
					actionColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					actionColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.actionSchoolColoring and spellSchool ) then
				actionColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
			else
				actionColor = CombatLogUtil.GetColorByEventType(event, filterSettings);
			end
		-- Special option to only color "Miss" if there's no damage
		elseif ( settings.missColoring ) then

			if ( event ~= "SWING_DAMAGE" and
				event ~= "RANGE_DAMAGE" and
				event ~= "SPELL_DAMAGE" and
				event ~= "SPELL_PERIODIC_DAMAGE" ) then

				if ( settings.actionActorColoring ) then
					actionColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( settings.actionSchoolColoring ) then
					actionColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
				else
					actionColor = CombatLogUtil.GetColorByEventType(event, filterSettings);
				end

			end
		end

		-- Highlighting
		if ( settings.actionHighlighting ) then
			local colorArray;
			if ( not actionColor ) then
				colorArray = lineColor;
			else
				colorArray = actionColor;
			end
			actionColor = CombatLogUtil.HighlightColor (colorArray);
		end

		if ( actionColor ) then
			actionStr = CombatLogUtil.WrapTextInColor(actionStr, actionColor);
		end

	end
	-- If there's a spell name
	if ( spellName ) then
		local spellAbilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then
			if ( settings.abilityActorColoring ) then
				spellAbilityColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			elseif ( settings.abilitySchoolColoring ) then
				spellAbilityColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
			else
				if ( spellSchool ) then
					spellAbilityColor = filterSettings.colors.defaults.spell;
				end
			end
		end

		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not spellAbilityColor ) then
				colorArray = lineColor;
			else
				colorArray = spellAbilityColor;
			end
			spellAbilityColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( spellAbilityColor ) then
			if ( itemId ) then
				spellNameStr = spellName;
			else
				spellNameStr = CombatLogUtil.WrapTextInColor(spellName, spellAbilityColor);
			end
		end
	end

	-- If there's a spell name
	if ( extraSpellName ) then
		local extraAbilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then

			if ( settings.abilitySchoolColoring ) then
				extraAbilityColor = CombatLogUtil.GetColorBySchool( extraSpellSchool, filterSettings );
			else
				if ( extraSpellSchool ) then
					extraAbilityColor = CombatLogUtil.GetColorBySchool( Enum.Damageclass.MaskHoly, filterSettings );
				else
					extraAbilityColor = CombatLogUtil.GetColorBySchool( nil, filterSettings );
				end
			end
		end
		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not extraAbilityColor ) then
				colorArray = lineColor;
			else
				colorArray = extraAbilityColor;
			end
			extraAbilityColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( extraAbilityColor ) then
			extraSpellNameStr = CombatLogUtil.WrapTextInColor(extraSpellName, extraAbilityColor);
		end
	end

	-- Whole line highlighting
	if ( settings.lineHighlighting ) then
		if ( filterSettings.colors.highlightedEvents[event] ) then
			lineColor = CombatLogUtil.HighlightColor (lineColor);
		end
	end

	-- Build braces
	if ( settings.braces ) then
		-- Unit specific braces
		if ( settings.unitBraces ) then
			if ( sourceName and settings.sourceBraces ) then
				sourceNameStr = string.format(TEXT_MODE_A_STRING_BRACE_UNIT, braceColor, sourceNameStr, braceColor);
			end

			if ( destName and settings.destBraces ) then
				destNameStr = string.format(TEXT_MODE_A_STRING_BRACE_UNIT, braceColor, destNameStr, braceColor);
			end
		end

		-- Spell name braces
		if ( spellName and settings.spellBraces ) then
			if ( not itemId ) then
				spellNameStr = string.format(TEXT_MODE_A_STRING_BRACE_SPELL, braceColor, spellNameStr, braceColor);
			end
		end
		if ( extraSpellName and settings.spellBraces ) then
			extraSpellNameStr = string.format(TEXT_MODE_A_STRING_BRACE_SPELL, braceColor, extraSpellNameStr, braceColor);
		end

		-- Build item braces
		if ( itemName and settings.itemBraces ) then
			itemNameStr = string.format(TEXT_MODE_A_STRING_BRACE_ITEM, braceColor, itemNameStr, braceColor);
		end
	end

	local sourceString = "";
	local spellString = "";
	local actionString = "";
	local destString = "";
	local valueString = "";
	local resultString = "";
	local remainingPointsString = "";

	if ( sourceEnabled and sourceName and falseSource ) then
		sourceString = sourceName;
	elseif ( sourceEnabled and sourceName ) then
		sourceString = string.format(TEXT_MODE_A_STRING_SOURCE_UNIT, sourceIcon, sourceGUID, sourceName, sourceNameStr);
	end

	if ( spellName ) then
		if ( nameIsNotSpell ) then
			spellString = string.format(TEXT_MODE_A_STRING_ACTION, originalEvent, spellNameStr);
		else
			spellString = string.format(TEXT_MODE_A_STRING_SPELL, spellId, 0, originalEvent, spellNameStr, spellId);
		end
	end

	if ( actionString ) then
		actionString = string.format(TEXT_MODE_A_STRING_ACTION, originalEvent, actionStr);
	end

	if ( destEnabled and destName ) then
		destString = string.format(TEXT_MODE_A_STRING_DEST_UNIT, destIcon, destGUID, destName, destNameStr);
	end

	if ( valueEnabled ) then
		if ( extraSpellEnabled and extraSpellNameStr ) then
			if ( extraNameIsNotSpell ) then
				valueString = extraSpellNameStr;
			else
				valueString = string.format(TEXT_MODE_A_STRING_SPELL_EXTRA, extraSpellId, 0, originalEvent, extraSpellNameStr, spellId);
			end
		elseif ( valueIsItem and itemNameStr ) then
			valueString = string.format(TEXT_MODE_A_STRING_ITEM, itemId, itemNameStr);
		elseif ( amount ) then
			if ( valueTypeEnabled ) then
				if ( valueType == 1 and schoolString ) then
					valueString = string.format(TEXT_MODE_A_STRING_VALUE_SCHOOL, amount, schoolString);
				elseif ( valueType == 2 and powerTypeString ) then
					valueString = string.format(TEXT_MODE_A_STRING_VALUE_TYPE, amount, powerTypeString);
				end
			end
			if ( valueString == "" ) then
				valueString = amount;
			end
		end
	end

	if ( resultEnabled and resultStr ) then
		resultString = resultStr;
	end

	if ( not schoolString ) then
		schoolString = "";
	end
	if ( not powerTypeString ) then
		powerTypeString = "";
	end
	if ( not amount ) then
		amount = "";
	end

	if ( not extraAmount) then
		extraAmount = "";
	end

	if ( sourceString == "" and not hideCaster ) then
		sourceString = UNKNOWN;
	end

	if ( destEnabled and destString == "" ) then
		destString = UNKNOWN;
	end

	if ( remainingPoints ) then
		remainingPointsString = string.format(TEXT_MODE_A_STRING_REMAINING_POINTS, BreakUpLargeNumbers(remainingPoints));
	end

	local finalString = string.format(formatString, sourceString, spellString, actionString, destString, valueString, resultString, schoolString, powerTypeString, amount, extraAmount, remainingPointsString);

	finalString = string.gsub(finalString, " [ ]+", " " ); -- extra white spaces
	finalString = string.gsub(finalString, " ([.,])", "%1" ); -- spaces before periods or comma
	finalString = string.gsub(finalString, "^([ .,]+)", "" ); -- spaces, period or comma at the beginning of a line

	if ( timestampEnabled and timestamp ) then
		-- Replace the timestamp
		finalString = string.format(TEXT_MODE_A_STRING_TIMESTAMP, date(TEXT_MODE_A_TIMESTAMP, timestamp), finalString);
	end

	-- NOTE: be sure to pass back nil for the color id or the color id may override the r, g, b values for this message line
	return finalString, lineColor.r, lineColor.g, lineColor.b;
end

CombatLogProcessor:OnLoad();
