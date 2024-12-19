BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";

function GameLimitedMode_IsActive()
	return IsTrialAccount() or IsVeteranTrialAccount();
end

function GameLimitedMode_IsBankedXPActive()
	return GameLimitedMode_IsActive() or GetExpansionTrialInfo();
end

function GameLimitedMode_GetLevelLimit()
	if GetExpansionTrialInfo() then
		local level = GetMaxLevelForExpansionLevel(math.max(GetClampedCurrentExpansionLevel() - 1, 0) );
		return level;
	elseif GameLimitedMode_IsActive() then
		local level = GetRestrictedAccountData();
		return level;
	end

	local level = GetMaxLevelForPlayerExpansion();
	return level;
end

function GetClampedCurrentExpansionLevel()
	return math.min(GetClientDisplayExpansionLevel(), math.max(GetAccountExpansionLevel(), GetExpansionLevel()));
end

function IsValidEmailAddress(address)
	if address then
		local matchStart, matchEnd = string.find(address, ".+@.+%...+");
		return matchStart and matchEnd;
	end

	return false;
end

--Name can be a realID or plain battletag with no 4 digit number (e.g. Murky McGrill or LichKing).
function BNet_GetBNetIDAccount(name)
	return GetAutoCompletePresenceID(name);
end

function BNet_GetBNetAccountName(accountInfo)
	if not accountInfo then
		return;
	end

	local name = accountInfo.accountName;
	if name == "" then
		name = BNet_GetTruncatedBattleTag(accountInfo.battleTag);
	end

	return name;
end

--Name must be a character name from your friends list.
function BNet_GetBNetIDAccountFromCharacterName(name)
	local _, numBNetOnline = BNGetNumFriends();
	for i = 1, numBNetOnline do
		local accountInfo = C_BattleNet.GetFriendAccountInfo(i);
		if accountInfo and accountInfo.gameAccountInfo.characterName and (strcmputf8i(name, accountInfo.gameAccountInfo.characterName) == 0) then
			return accountInfo.bnetAccountID;
		end
	end
end

function BNet_GetTruncatedBattleTag(battleTag)
	if battleTag then
		local symbol = string.find(battleTag, "#");
		if ( symbol ) then
			return string.sub(battleTag, 1, symbol - 1);
		else
			return battleTag;
		end
	else
		return "";
	end
end

-- if we don't have a character name or it's for a game that doesn't have toons like Heroes, use the battletag
function BNet_GetValidatedCharacterName(characterName, battleTag, client, clientTextureSize)
	if (not characterName) or (characterName == "") or (client == BNET_CLIENT_HEROES) then
		return BNet_GetTruncatedBattleTag(battleTag);
	end
	return characterName;
end

function BNet_GetValidatedCharacterNameWithClientEmbeddedAtlas(characterName, battleTag, client, texWidth, texHeight, texXOffset, texYOffset)
	return BNet_GetClientEmbeddedAtlas(client, texWidth, texHeight, texXOffset, texYOffset)..BNet_GetValidatedCharacterName(characterName, battleTag, client);
end

function BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(characterName, battleTag, texture, fileWidth, fileHeight, texWidth, texHeight, texXOffset, texYOffset)
	local width = texWidth or 0;
	local height = texHeight or width;
	local xOffset = texXOffset or 0;
	local yOffset = texYOffset or 0;
	
	return CreateTextureMarkup(texture, fileWidth, fileHeight, width, height, 0, 1, 0, 1, xOffset, yOffset).." "..BNet_GetValidatedCharacterName(characterName, battleTag, client);
end