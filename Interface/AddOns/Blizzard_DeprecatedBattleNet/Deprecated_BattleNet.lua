-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

BNSendGameData = function(gameAccountID, prefix, data)
	-- New API additionally returns a result code similar to SendAddonMessage.
	C_BattleNet.SendGameData(gameAccountID, prefix, data);
end

BNSendWhisper = function(bnetAccountID, text)
	C_BattleNet.SendWhisper(bnetAccountID, text);
end

BNSetCustomMessage = function(text)
	C_BattleNet.SetCustomMessage(text);
end
