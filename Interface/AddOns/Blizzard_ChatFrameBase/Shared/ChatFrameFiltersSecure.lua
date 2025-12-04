local _, addonTbl = ...;

-- This function is required to always execute securely because chat message
-- event filters are stored in lazily-created arrays (one per chat event) and
-- we need to ensure that the first registration of a filter doesn't taint
-- all other filters -or- spread taint back to the chat frame.
addonTbl.CreateSecureFiltersArray = CreateSecureDelegate(function()
	return SecureTypes.CreateSecureArray();
end);
