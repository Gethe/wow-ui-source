local accessIDs = {};
local nextAccessID = 1;

local accessIDToType = {};
local accessIDToTarget = {};

function ChatHistory_GetAccessID(chatType, chatTarget)
	if ( not accessIDs[ChatHistory_GetToken(chatType, chatTarget)] ) then
		accessIDs[ChatHistory_GetToken(chatType, chatTarget)] = nextAccessID;
		accessIDToType[nextAccessID] = chatType;
		accessIDToTarget[nextAccessID] = chatTarget;
		nextAccessID = nextAccessID + 1;
	end
	return accessIDs[ChatHistory_GetToken(chatType, chatTarget)];
end

function ChatHistory_GetChatType(accessID)
	return accessIDToType[accessID], accessIDToTarget[accessID];
end

--Private functions
function ChatHistory_GetToken(chatType, chatTarget)
	return strlower(chatType)..";;"..(chatTarget and strlower(chatTarget) or "");
end