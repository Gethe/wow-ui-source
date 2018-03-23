WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = -25;
WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = 0;
WORLDSTATEALWAYSUPFRAME_TIMETORUN = 60;
WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL = 5;

local inBattleground = false;

--
FILTERED_BG_CHAT_ADD_GLOBALS = { "ERR_RAID_MEMBER_ADDED_S", "ERR_BG_PLAYER_JOINED_SS" };
FILTERED_BG_CHAT_SUBTRACT_GLOBALS = { "ERR_RAID_MEMBER_REMOVED_S", "ERR_BG_PLAYER_LEFT_S" };

--Filtered at the end of BGs only
FILTERED_BG_CHAT_END_GLOBALS = { "LOOT_ITEM", "LOOT_ITEM_MULTIPLE", "CREATED_ITEM", "CREATED_ITEM_MULTIPLE", "ERR_RAID_MEMBER_REMOVED_S", "ERR_BG_PLAYER_LEFT_S" };

FILTERED_BG_CHAT_ADD = {};
FILTERED_BG_CHAT_SUBTRACT = {};
FILTERED_BG_CHAT_END = {};

ADDED_PLAYERS = {};
SUBTRACTED_PLAYERS = {};

function WorldStateAlwaysUpFrame_OnUpdate(self, elapsed)
	WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = WORLDSTATEALWAYSUPFRAME_TIMESINCELAST + elapsed;
	WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = WORLDSTATEALWAYSUPFRAME_TIMESINCESTART + elapsed;
	if ( WORLDSTATEALWAYSUPFRAME_TIMESINCELAST >= WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL ) then		
		local subtractedPlayers, playerString = 0;
		
		for i in next, SUBTRACTED_PLAYERS do 
			if ( not playerString ) then
				playerString = i;
			else
				playerString = playerString .. PLAYER_LIST_DELIMITER .. i;
			end
			
			subtractedPlayers = subtractedPlayers + 1;
		end

		local message, info;
		
		if ( subtractedPlayers > 0 ) then
			info = ChatTypeInfo["SYSTEM"];
			if ( subtractedPlayers > 1 and subtractedPlayers <= 3 ) then
				message = ERR_PLAYERLIST_LEFT_BATTLE;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, subtractedPlayers, playerString), info.r, info.g, info.b, info.id);
			elseif ( subtractedPlayers > 3 ) then
				message = ERR_PLAYERS_LEFT_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, subtractedPlayers), info.r, info.g, info.b, info.id);
			else
				message = ERR_PLAYER_LEFT_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, playerString), info.r, info.g, info.b, info.id);
			end

			for i in next, SUBTRACTED_PLAYERS do
				SUBTRACTED_PLAYERS[i] = nil;
			end
		end
		
		local addedPlayers, playerString = 0;
		for i in next, ADDED_PLAYERS do
			if ( not playerString ) then
				playerString = i;
			else
				playerString = playerString .. PLAYER_LIST_DELIMITER .. i;
			end
			
			addedPlayers = addedPlayers + 1;
		end
		
		
		if ( addedPlayers > 0 ) then
			info = ChatTypeInfo["SYSTEM"];
			if ( addedPlayers > 1 and addedPlayers <= 3 ) then
				message = ERR_PLAYERLIST_JOINED_BATTLE;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, addedPlayers, playerString), info.r, info.g, info.b, info.id);
			elseif ( addedPlayers > 3 ) then
				message = ERR_PLAYERS_JOINED_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, addedPlayers), info.r, info.g, info.b, info.id);
			else
				message = ERR_PLAYER_JOINED_BATTLE_D;
				DEFAULT_CHAT_FRAME:AddMessage(string.format(message, playerString), info.r, info.g, info.b, info.id);
			end

			for i in next, ADDED_PLAYERS do
				ADDED_PLAYERS[i] = nil;
			end
		end
		
		WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = 0;
	elseif ( WORLDSTATEALWAYSUPFRAME_TIMESINCESTART >= WORLDSTATEALWAYSUPFRAME_TIMETORUN ) then
		WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = WORLDSTATEALWAYSUPFRAME_DEFAULTINTERVAL;
		WorldStateAlwaysUpFrame_OnUpdate(self, 0);
		self:SetScript("OnUpdate", nil);
	end
end

function WorldStateAlwaysUpFrame_StartBGChatFilter (self)
	inBattleground = true;
	
	-- Reset the OnUpdate timer variables
	WORLDSTATEALWAYSUPFRAME_TIMESINCELAST = -25;
	WORLDSTATEALWAYSUPFRAME_TIMESINCESTART = 0;
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", WorldStateAlwaysUpFrame_FilterChatMsgSystem);
	
	self:SetScript("OnUpdate", WorldStateAlwaysUpFrame_OnUpdate);
end

function WorldStateAlwaysUpFrame_StopBGChatFilter (self)
	inBattleground = false;
	
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", WorldStateAlwaysUpFrame_FilterChatMsgSystem);
	
	for i in next, ADDED_PLAYERS do
		ADDED_PLAYERS[i] = nil;
	end
	
	for i in next, SUBTRACTED_PLAYERS do
		SUBTRACTED_PLAYERS[i] = nil;
	end
	
	self:SetScript("OnUpdate", nil);
end

function WorldStateAlwaysUpFrame_FilterChatMsgSystem (self, event, ...)
	local playerName;
	
	local message = ...;
	
	if ( GetBattlefieldWinner() ) then
		-- Filter out leaving messages when the battleground is over.
		for i, str in next, FILTERED_BG_CHAT_SUBTRACT do
			playerName = string.match(message, str);
			if ( playerName ) then
				return true;
			end
		end
	elseif ( WORLDSTATEALWAYSUPFRAME_TIMESINCESTART < WORLDSTATEALWAYSUPFRAME_TIMETORUN ) then
		-- Filter out leaving and joining messages when the battleground starts.
		for i, str in next, FILTERED_BG_CHAT_ADD do
			playerName = string.match(message, str);
			if ( playerName ) then
				-- Trim realm names
				playerName = string.match(playerName, "([^%-]+)%-?.*");
				ADDED_PLAYERS[playerName] = true;
				return true;
			end
		end
		
		for i, str in next, FILTERED_BG_CHAT_SUBTRACT do
			playerName = string.match(message, str);
			if ( playerName ) then
				playerName = string.match(playerName, "([^%-]+)%-?.*");
				SUBTRACTED_PLAYERS[playerName] = true;
				return true;
			end
		end
	end
	return false;
end
