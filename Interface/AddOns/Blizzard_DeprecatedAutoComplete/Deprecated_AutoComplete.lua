-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

AUTOCOMPLETE_FLAG_IN_GROUP = assertsafe(Enum.AutoCompleteEntryFlag.InGroup);
AUTOCOMPLETE_FLAG_IN_GUILD = assertsafe(Enum.AutoCompleteEntryFlag.InGuild);
AUTOCOMPLETE_FLAG_FRIEND = assertsafe(Enum.AutoCompleteEntryFlag.Friend);
AUTOCOMPLETE_FLAG_BNET = assertsafe(Enum.AutoCompleteEntryFlag.Bnet);
AUTOCOMPLETE_FLAG_INTERACTED_WITH = assertsafe(Enum.AutoCompleteEntryFlag.InteractedWith);
AUTOCOMPLETE_FLAG_ONLINE = assertsafe(Enum.AutoCompleteEntryFlag.Online);
AUTO_COMPLETE_IN_AOI = assertsafe(Enum.AutoCompleteEntryFlag.InAOI);
AUTO_COMPLETE_ACCOUNT_CHARACTER = assertsafe(Enum.AutoCompleteEntryFlag.AccountCharacter);
AUTO_COMPLETE_RECENT_PLAYER = assertsafe(Enum.AutoCompleteEntryFlag.RecentPlayer);

LE_AUTOCOMPLETE_PRIORITY_OTHER = assertsafe(Enum.AutoCompletePriority.Other);
LE_AUTOCOMPLETE_PRIORITY_INTERACTED = assertsafe(Enum.AutoCompletePriority.Interacted);
LE_AUTOCOMPLETE_PRIORITY_IN_GROUP = assertsafe(Enum.AutoCompletePriority.InGroup);
LE_AUTOCOMPLETE_PRIORITY_GUILD = assertsafe(Enum.AutoCompletePriority.Guild);
LE_AUTOCOMPLETE_PRIORITY_FRIEND = assertsafe(Enum.AutoCompletePriority.Friend);
LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER = assertsafe(Enum.AutoCompletePriority.AccountCharacter);
LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER_SAME_REALM = assertsafe(Enum.AutoCompletePriority.AccountCharacterSameRealm);

function GetAutoCompletePresenceID(name)
	return C_AutoComplete.GetAutoCompletePresenceID(name);
end

function GetAutoCompleteResults(name, numResults, cursorPosition, allowFullMatch, includeFlags, excludeFlags)
	-- Pre-conversion API coerced any 'allowFullMatch' value to a boolean. Post-conversion applies stricter type checks.
	allowFullMatch = not not allowFullMatch;
	return C_AutoComplete.GetAutoCompleteResults(name, numResults, cursorPosition, allowFullMatch, includeFlags, excludeFlags);
end

function GetAutoCompleteRealms()
	return C_AutoComplete.GetAutoCompleteRealms();
end

function IsRecognizedName(name, includeFlags, excludeFlags)
	return C_AutoComplete.IsRecognizedName(name, includeFlags, excludeFlags);
end
