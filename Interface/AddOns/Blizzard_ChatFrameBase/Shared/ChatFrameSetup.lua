local _, addonTbl = ...;

local function AddListProxyTable(list)
	setmetatable(list, { __index = {} });
end

-- Proxy tables for the hash_* tables used by the slash commands registry
-- need wrapping with a metatable that caches registered commands.

AddListProxyTable(addonTbl.SecureCmdList);
AddListProxyTable(_G.SlashCmdList);
AddListProxyTable(_G.ChatTypeInfo);

-- Pre-cache all slash commands and emotes into the internal hash tables.

ChatFrameUtil.ImportAllListsToHash();
ChatFrameUtil.ImportEmoteTokensToHash();

-- Route all '/dump' output to the chat frame.

DevTools_AddMessageHandler(function(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end);

-- Create an inverted mapping of event => chat type groups for use by the
-- TTS infrastructure.

ChatTypeGroupInverted = {};

for group, values in pairs(ChatTypeGroup) do
	for _, value in pairs(values) do
		ChatTypeGroupInverted[value] = group;
	end
end
