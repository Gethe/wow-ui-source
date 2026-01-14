local accessIDs = {};
local nextAccessID = 1;

local accessIDToType = {};
local accessIDToTarget = {};
local accessIDToChanSender = {};

function ChatHistory_GetAccessID(chatType, chatTarget, chanSender)
	if ( not accessIDs[ChatHistory_GetToken(chatType, chatTarget, chanSender)] ) then
		accessIDs[ChatHistory_GetToken(chatType, chatTarget, chanSender)] = nextAccessID;
		accessIDToType[nextAccessID] = chatType;
		accessIDToTarget[nextAccessID] = chatTarget;
		accessIDToChanSender[nextAccessID] = chanSender;
		nextAccessID = nextAccessID + 1;
	end
	return accessIDs[ChatHistory_GetToken(chatType, chatTarget, chanSender)];
end

function ChatHistory_GetChatType(accessID)
	return accessIDToType[accessID], accessIDToTarget[accessID], accessIDToChanSender[accessID];
end

function ChatHistory_GetAllAccessIDsByChanSender(chanSender)
	local results = {};	--Yes, GC. But shouldn't be called too frequently.
	for accessID, sender in pairs(accessIDToChanSender) do
		if ( strlower(sender) == strlower(chanSender) ) then
			results[#results + 1] = accessID;
		end
	end
	return results;
end

--Private functions
function ChatHistory_GetToken(chatType, chatTarget, chanSender)
	return strlower(chatType)..";;"..(chatTarget and strlower(chatTarget) or "")..";;"..(chanSender and strlower(chanSender) or "");
end