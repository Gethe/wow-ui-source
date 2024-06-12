
-- These are functions are deprecated, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	-- Return value is now a result enum instead of a bool
	local newRegisterAddonMessagePrefixFunc = C_ChatInfo.RegisterAddonMessagePrefix;
	function C_ChatInfo.RegisterAddonMessagePrefix(...)
		local result = newRegisterAddonMessagePrefixFunc(...);
		return (result == Enum.SendAddonMessageResult.Success), result;
	end

	-- Return value is now a result enum instead of a bool
	local newSendAddonMessageFunc = C_ChatInfo.SendAddonMessage;
	function C_ChatInfo.SendAddonMessage(...)
		local result = newSendAddonMessageFunc(...);
		return (result == Enum.SendAddonMessageResult.Success), result;
	end

	-- Return value is now a result enum instead of a bool
	local newSendAddonMessageLoggedFunc = C_ChatInfo.SendAddonMessageLogged;
	function C_ChatInfo.SendAddonMessageLogged(...)
		local result = newSendAddonMessageLoggedFunc(...);
		return (result == Enum.RegisterAddonMessagePrefixResult.Success), result;
	end

	InviteUnit = C_PartyInfo.InviteUnit;
end
