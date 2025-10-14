local _, addonTbl = ...;
local SecureCmdList = addonTbl.SecureCmdList;

local CastSequenceManager;
local CastSequenceTable = {};
local CastSequenceFreeList = {};

local function CreateCanonicalActions(entry, ...)
	entry.spells = {};
	entry.spellNames = {};
	entry.spellID = {};
	entry.items = {};
	local count = 0;
	for i=1, select("#", ...) do
		local action = strlower(strtrim((select(i, ...))));
		if ( action and action ~="" ) then
			count = count + 1;
			if ( C_Item.GetItemInfo(action) or select(3, SecureCmdItemParse(action)) ) then
				local spellName, spellID = C_Item.GetItemSpell(action);
				entry.items[count] = action;
				entry.spells[count] = strlower(spellName or "");
				entry.spellNames[count] = entry.spells[count];
				entry.spellID[count] = spellID;
			else
				entry.spells[count] = action;
				entry.spellNames[count] = gsub(action, "!*(.*)", "%1");
				entry.spellID[count] = C_Spell.GetSpellIDForSpellIdentifier(action);
			end
		end
	end
end

local function SetCastSequenceIndex(entry, index)
	entry.index = index;
	entry.pending = nil;
end

local function ResetCastSequence(sequence, entry)
	SetCastSequenceIndex(entry, 1);
	CastSequenceFreeList[sequence] = entry;
	CastSequenceTable[sequence] = nil;
end

local function SetNextCastSequence(sequence, entry)
	if ( entry.index == #entry.spells ) then
		ResetCastSequence(sequence, entry);
	else
		SetCastSequenceIndex(entry, entry.index + 1);
	end
end

local function CastSequenceManager_OnEvent(self, event, ...)

	-- Reset all sequences when the player dies
	if ( event == "PLAYER_DEAD" ) then
		for sequence, entry in pairs(CastSequenceTable) do
			ResetCastSequence(sequence, entry);
		end
		return;
	end

	-- Increment sequences for spells which succeed.
	if ( event == "UNIT_SPELLCAST_SENT" or
		 event == "UNIT_SPELLCAST_SUCCEEDED" or
		 event == "UNIT_SPELLCAST_INTERRUPTED" or
		 event == "UNIT_SPELLCAST_FAILED" or
		 event == "UNIT_SPELLCAST_FAILED_QUIET" ) then
		local unit, castID, spellID;

		if event == "UNIT_SPELLCAST_SENT" then
			local target;
			unit, target, castID, spellID = ...;
		else
			unit, castID, spellID = ...;
		end

		if ( unit == "player" or unit == "pet" ) then
			local overrideSpellID = FindSpellOverrideByID(spellID);
			local baseSpellID     = FindBaseSpellByID(spellID);
			for sequence, entry in pairs(CastSequenceTable) do
				local entrySpellID = entry.spellID[entry.index];
				if ( entrySpellID == overrideSpellID or entrySpellID == baseSpellID ) then
					if ( event == "UNIT_SPELLCAST_SENT" ) then
						entry.pending = castID;
					elseif ( entry.pending == castID ) then
						entry.pending = nil;
						if ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
							SetNextCastSequence(sequence, entry);
						end
					end
				end
			end
		end
		return;
	end

	-- Handle reset events
	local reset = "";
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		reset = "target";
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		reset = "combat";
	end
	for sequence, entry in pairs(CastSequenceTable) do
		if ( strfind(entry.reset, reset, 1, true) ) then
			ResetCastSequence(sequence, entry);
		end
	end
end

local function CastSequenceManager_OnUpdate(self, elapsed)
	elapsed = self.elapsed + elapsed;
	if ( elapsed < 1 ) then
		self.elapsed = elapsed;
		return;
	end
	for sequence, entry in pairs(CastSequenceTable) do
		if ( entry.timeout ) then
			if ( elapsed >= entry.timeout ) then
				ResetCastSequence(sequence, entry);
			else
				entry.timeout = entry.timeout - elapsed;
			end
		end
	end
	self.elapsed = 0;
end

local function ExecuteCastSequence(sequence, target)
	if ( not CastSequenceManager ) then
		CastSequenceManager = CreateFrame("Frame");
		CastSequenceManager.elapsed = 0;
		CastSequenceManager:RegisterEvent("PLAYER_DEAD");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_SENT");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_FAILED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
		CastSequenceManager:RegisterEvent("PLAYER_TARGET_CHANGED");
		CastSequenceManager:RegisterEvent("PLAYER_REGEN_ENABLED");
		CastSequenceManager:SetScript("OnEvent", CastSequenceManager_OnEvent);
		CastSequenceManager:SetScript("OnUpdate", CastSequenceManager_OnUpdate);
	end

	local entry = CastSequenceTable[sequence];
	if ( not entry ) then
		entry = CastSequenceFreeList[sequence];
		if ( not entry ) then
			local reset, spells = strmatch(sequence, "^reset=([^%s]+)%s*(.*)");
			if ( not reset ) then
				spells = sequence;
			end
			entry = {};
			CreateCanonicalActions(entry, strsplit(",", spells));
			entry.reset = strlower(reset or "");
		end
		CastSequenceTable[sequence] = entry;
		entry.index = 1;
	end

	-- Don't do anything if this entry is still pending
	if ( entry.pending ) then
		return;
	end

	-- See if modified click restarts the sequence
	if ( (IsShiftKeyDown() and strfind(entry.reset, "shift", 1, true)) or
		 (IsControlKeyDown() and strfind(entry.reset, "ctrl", 1, true)) or
		 (IsAltKeyDown() and strfind(entry.reset, "alt", 1, true)) ) then
		SetCastSequenceIndex(entry, 1);
	end

	-- Reset the timeout each time the sequence is used
	local timeout = strmatch(entry.reset, "(%d+)");
	if ( timeout ) then
		entry.timeout = CastSequenceManager.elapsed + tonumber(timeout);
	end

	-- Execute the sequence!
	local item, spell = entry.items[entry.index], entry.spells[entry.index];
	if ( item ) then
		local name, bag, slot = SecureCmdItemParse(item);
		if ( slot ) then
			local spellID;
			if ( name ) then
				local spellName;
				spellName, spellID = C_Item.GetItemSpell(name);
				spell = strlower(spellName or "");
			else
				spell = "";
			end
			entry.spellNames[entry.index] = spell;
			entry.spellID[entry.index] = spellID;
		end
		if ( C_Item.IsEquippableItem(name) and not C_Item.IsEquippedItem(name) ) then
			C_Item.EquipItemByName(name);
		else
			SecureCmdUseItem(name, bag, slot, target);
		end
	else
		CastSpellByName(spell, target);
	end
end

function QueryCastSequence(sequence)
	local index = 1;
	local item, spell;
	local entry = CastSequenceTable[sequence];
	if ( entry ) then
		if ( (IsShiftKeyDown() and strfind(entry.reset, "shift", 1, true)) or
			 (IsControlKeyDown() and strfind(entry.reset, "ctrl", 1, true)) or
			 (IsAltKeyDown() and strfind(entry.reset, "alt", 1, true)) ) then
			index = 1;
		else
			index = entry.index;
		end
		item, spell = entry.items[index], entry.spells[index];
	else
		entry = CastSequenceFreeList[sequence];
		if ( entry ) then
			item, spell = entry.items[index], entry.spells[index];
		else
			local reset, spells = strmatch(sequence, "^reset=([^%s]+)%s*(.*)");
			if ( not reset ) then
				spells = sequence;
			end
			local action = strlower(strtrim((strsplit(",", spells))));
			if ( select(3, SecureCmdItemParse(action)) or C_Item.GetItemInfo(action) ) then
				item, spell = action, strlower(C_Item.GetItemSpell(action) or "");
			else
				item, spell = nil, action;
			end
		end
	end
	if ( item ) then
		local name, bag, slot = SecureCmdItemParse(item);
		if ( slot ) then
			if ( name ) then
				spell = strlower(C_Item.GetItemSpell(name) or "");
			else
				spell = "";
			end
		end
	end
	return index, item, spell;
end

SecureCmdList["CASTSEQUENCE"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local sequence, target = SecureCmdOptionParse(msg);
	if ( sequence and sequence ~= "" ) then
		ExecuteCastSequence(sequence, target);
	end
end
