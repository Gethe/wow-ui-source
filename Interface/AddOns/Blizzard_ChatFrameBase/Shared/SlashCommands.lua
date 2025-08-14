local _, addonTbl = ...;
local SecureCmdList = addonTbl.SecureCmdList;

local forceinsecure = forceinsecure;

SecureCmdList["STARTATTACK"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target  or target == "target" ) then
			target = action;
		end
		StartAttack(target);
	end
end

SecureCmdList["STOPATTACK"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopAttack();
	end
end

-- We want to prefer spells for /cast and items for /use but we can use either
SecureCmdList["CAST"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		local spellExists = C_Spell.DoesSpellExist(action)
		local name, bag, slot = SecureCmdItemParse(action);
		if ( spellExists ) then
			CastSpellByName(action, target);
		elseif ( slot or C_Item.GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		end
	end
end

SecureCmdList["USE"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		local name, bag, slot = SecureCmdItemParse(action);
		if ( slot or C_Item.GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		else
			CastSpellByName(action, target);
		end
	end
end

SecureCmdList["STOPCASTING"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellStopCasting();
	end
end

SecureCmdList["STOPSPELLTARGET"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellStopTargeting();
	end
end

SecureCmdList["CANCELAURA"] = function(msg)
	local spell = SecureCmdOptionParse(msg);

	local spellID = tonumber(spell);

	if spellID then
		C_Spell.CancelSpellByID(spellID);
	elseif spell then
		CancelSpellByName(spell);
	end
end

SecureCmdList["CANCELFORM"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		CancelShapeshiftForm();
	end
end

SecureCmdList["EQUIP"] = function(msg)
	local item = SecureCmdOptionParse(msg);
	if ( item ) then
		local parsedItem = SecureCmdItemParse(item);
		C_Item.EquipItemByName(parsedItem);
	end
end

SecureCmdList["EQUIP_TO_SLOT"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		local slot, item = strmatch(action, "^(%d+)%s+(.*)");
		if ( item ) then
			if ( PaperDoll_IsEquippedSlot(slot) ) then
				local parsedItem = SecureCmdItemParse(item);
				C_Item.EquipItemByName(parsedItem, slot);
			else
				-- user specified a bad slot number (slot that you can't equip an item to)
				ChatFrame_DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED));
			end
		elseif ( slot ) then
			-- user specified a slot but not an item
			ChatFrame_DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED));
		end
	end
end

SecureCmdList["CHANGEACTIONBAR"] = function(msg)
	local page = SecureCmdOptionParse(msg);
	if ( page and page ~= "" ) then
		page = tonumber(page);
		if (page and page >= 1 and page <= NUM_ACTIONBAR_PAGES) then
			ChangeActionBarPage(page);
		else
			ChatFrame_DisplayUsageError(format(ERROR_SLASH_CHANGEACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
		end
	end
end

SecureCmdList["SWAPACTIONBAR"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		local a, b = strmatch(action, "(%d+)%s+(%d+)");
		if ( a and b ) then
			a = tonumber(a);
			b = tonumber(b);
			if ( ( a and a >= 1 and a <= NUM_ACTIONBAR_PAGES ) and ( b and b >= 1 and b <= NUM_ACTIONBAR_PAGES ) ) then
				if ( GetActionBarPage() == a ) then
					ChangeActionBarPage(b);
				else
					ChangeActionBarPage(a);
				end
			else
				ChatFrame_DisplayUsageError(format(ERROR_SLASH_SWAPACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
			end
		end
	end
end

SecureCmdList["TARGET"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target);
	end
end

SecureCmdList["TARGET_EXACT"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target, true);
	end
end

SecureCmdList["TARGET_NEAREST_ENEMY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemy(ValueToBoolean(action, false));
	end
end

SecureCmdList["TARGET_NEAREST_ENEMY_PLAYER"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemyPlayer(ValueToBoolean(action, false));
	end
end

SecureCmdList["TARGET_NEAREST_FRIEND"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriend(ValueToBoolean(action, false));
	end
end

SecureCmdList["TARGET_NEAREST_FRIEND_PLAYER"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriendPlayer(ValueToBoolean(action, false));
	end
end

SecureCmdList["TARGET_NEAREST_PARTY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestPartyMember(ValueToBoolean(action, false));
	end
end

SecureCmdList["TARGET_NEAREST_RAID"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestRaidMember(ValueToBoolean(action, false));
	end
end

SecureCmdList["CLEARTARGET"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearTarget();
	end
end

SecureCmdList["TARGET_LAST_TARGET"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		TargetLastTarget();
	end
end

SecureCmdList["TARGET_LAST_ENEMY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastEnemy(action);
	end
end

SecureCmdList["TARGET_LAST_FRIEND"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastFriend(action);
	end
end

SecureCmdList["ASSIST"] = function(msg)
	if ( msg == "" ) then
		AssistUnit();
	else
		local action, target = SecureCmdOptionParse(msg);
		if ( action ) then
			if ( not target ) then
				target = action;
			end
			AssistUnit(target);
		end
	end
end

SecureCmdList["FOCUS"] = function(msg)
	if ( msg == "" ) then
		FocusUnit();
	else
		local action, target = SecureCmdOptionParse(msg);
		if ( action ) then
			if ( not target or target == "focus" ) then
				target = action;
			end
			FocusUnit(target);
		end
	end
end

SecureCmdList["CLEARFOCUS"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearFocus();
	end
end

SecureCmdList["MAINTANKON"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		SetPartyAssignment("MAINTANK", target);
	end
end

SecureCmdList["MAINTANKOFF"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		ClearPartyAssignment("MAINTANK", target);
	end
end

SecureCmdList["MAINASSISTON"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		SetPartyAssignment("MAINASSIST", target);
	end
end

SecureCmdList["MAINASSISTOFF"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		ClearPartyAssignment("MAINASSIST", target);
	end
end

SecureCmdList["DUEL"] = function(msg)
	StartDuel(msg)
end

SecureCmdList["DUEL_CANCEL"] = function(msg)
	ForfeitDuel()
end

SecureCmdList["PET_ATTACK"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "pettarget" ) then
			target = action;
		end
		PetAttack(target);
	end
end

SecureCmdList["PET_FOLLOW"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetFollow();
	end
end

SecureCmdList["PET_MOVE_TO"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		PetMoveTo(target);
	end
end

SecureCmdList["PET_STAY"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetWait();
	end
end

SecureCmdList["PET_PASSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetPassiveMode();
	end
end

SecureCmdList["PET_DEFENSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveMode();
	end
end

SecureCmdList["PET_DEFENSIVEASSIST"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveAssistMode();
	end
end

SecureCmdList["PET_AGGRESSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetAggressiveMode();
	end
end

SecureCmdList["STOPMACRO"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopMacro();
	end
end

SecureCmdList["CANCELQUEUEDSPELL"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellCancelQueuedSpell();
	end
end

SecureCmdList["CLICK"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action and action ~= "" ) then
		local name, mouseButton, down = strmatch(action, "([^%s]+)%s+([^%s]+)%s*(.*)");
		if ( not name ) then
			name = action;
		end
		if ( not mouseButton ) then
			mouseButton = "LeftButton";
		end
		down = StringToBoolean(down or "", false);

		local button = GetClickFrame(name);
		if ( button and button:IsObjectType("Button") and not button:IsForbidden() ) then
			button:Click(mouseButton, down);
		end
	end
end

SecureCmdList["PET_DISMISS"] = function(msg)
	if ( PetCanBeAbandoned() ) then
		CastSpellByID(Constants.SpellBookSpellIDs.SPELL_ID_DISMISS_PET);
	else
		PetDismiss();
	end
end

SecureCmdList["LOGOUT"] = function(msg)
	Logout();
end

SecureCmdList["QUIT"] = function(msg)
	if (Kiosk.IsEnabled()) then
		return;
	end
	Quit();
end

SecureCmdList["GUILD_UNINVITE"] = function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Uninvite(msg);
end

SecureCmdList["GUILD_PROMOTE"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Promote(msg);
end

SecureCmdList["GUILD_DEMOTE"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Demote(msg);
end

SecureCmdList["GUILD_LEADER"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.SetLeader(msg);
end

SecureCmdList["GUILD_LEAVE"] = function(msg)
	C_GuildInfo.Leave();
end

SecureCmdList["GUILD_DISBAND"] = function(msg)
	if ( IsGuildLeader() ) then
		StaticPopup_Show("CONFIRM_GUILD_DISBAND");
	end
end

SecureCmdList["EQUIP_SET"] = function(msg)
	local set = SecureCmdOptionParse(msg);
	if ( set and set ~= "" ) then
		C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(set));
	end
end

SecureCmdList["WORLD_MARKER"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local marker, target = SecureCmdOptionParse(msg);
	if ( tonumber(marker) ) then
		PlaceRaidMarker(tonumber(marker), target);
	end
end

SecureCmdList["CLEAR_WORLD_MARKER"] = function(msg)
	local marker = SecureCmdOptionParse(msg);
	if ( tonumber(marker) ) then
		ClearRaidMarker(tonumber(marker));
	elseif ( type(marker) == "string" and strtrim(strlower(marker)) == strlower(ALL) ) then
		ClearRaidMarker(nil);	--Clear all world markers.
	end
end


SlashCmdList["CONSOLE"] = function(msg)
	forceinsecure();
	ConsoleExec(msg);
end

SlashCmdList["CHATLOG"] = function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingChat() ) then
		LoggingChat(false);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingChat(true);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["COMBATLOG"] = function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingCombat() ) then
		LoggingCombat(false);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingCombat(true);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["UNINVITE"] = function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true);
	end
	if(msg == nil) then
		ChatFrame_DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	UninviteUnit(msg);
end

SlashCmdList["PROMOTE"] = function(msg)
	PromoteToLeader(msg);
end

SlashCmdList["REPLY"] = function(msg, editBox)
	local lastTell = ChatEdit_GetLastTellTarget();
	if ( lastTell ) then
		msg = SubstituteChatMessageBeforeSend(msg);
		C_ChatInfo.SendChatMessage(msg, "WHISPER", editBox.languageID, lastTell);
	else
		-- error message
	end
end

SlashCmdList["HELP"] = function(msg)
	ChatFrame_DisplayHelpText(DEFAULT_CHAT_FRAME);
end

SlashCmdList["MACROHELP"] = function(msg)
	ChatFrame_DisplayMacroHelpText(DEFAULT_CHAT_FRAME);
end

SlashCmdList["TIME"] = function(msg)
	ChatFrame_DisplayGameTime(DEFAULT_CHAT_FRAME);
end

SlashCmdList["PLAYED"] = function(msg)
	RequestTimePlayed();
end

SlashCmdList["FOLLOW"] = function(msg)
	FollowUnit(msg);
end

SlashCmdList["TRADE"] = function(msg)
	InitiateTrade("target");
end

SlashCmdList["INSPECT"] = function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	InspectUnit("target");
end

SlashCmdList["JOIN"] = 	function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if(name == "") then
		local joinhelp = CHAT_JOIN_HELP;
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(joinhelp, info.r, info.g, info.b, info.id);
	else
		local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			local info = ChatTypeInfo["CHANNEL"];
			DEFAULT_CHAT_FRAME:AddMessage(CHAT_INVALID_NAME_NOTICE, info.r, info.g, info.b, info.id);
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	end
end

SlashCmdList["LEAVE"] = function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		LeaveChannelByName(name);
	end
end

SlashCmdList["LIST_CHANNEL"] = function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		ListChannelByName(name);
	else
		ListChannels();
	end
end

SlashCmdList["CHAT_HELP"] =
	function(msg)
		ChatFrame_DisplayChatHelp(DEFAULT_CHAT_FRAME)
	end

SlashCmdList["CHAT_PASSWORD"] =
	function(msg)
		local name = gsub(msg, "%s*([^%s]+).*", "%1");
		local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		SetChannelPassword(name, password);
	end

SlashCmdList["CHAT_OWNER"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local newOwner = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if ( not channel or not newOwner ) then
			return;
		end
		local newOwnerLen = strlen(newOwner);
		if ( newOwnerLen > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel ~= "" ) then
			if ( newOwnerLen > 0 ) then
				SetChannelOwner(channel, newOwner);
			else
				DisplayChannelOwner(channel);
			end
		end
	end

SlashCmdList["CHAT_MODERATOR"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		ChannelModerator(channel, player);
	end

SlashCmdList["CHAT_UNMODERATOR"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelUnmoderator(channel, player);
		end
	end

SlashCmdList["CHAT_CINVITE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end

		if ( channel and player ) then
			if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			ChannelInvite(channel, player);
		end
	end

SlashCmdList["CHAT_KICK"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelKick(channel, player);
		end
	end

SlashCmdList["CHAT_BAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelBan(channel, player);
		end
	end

SlashCmdList["CHAT_UNBAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelUnban(channel, player);
		end
	end

SlashCmdList["CHAT_ANNOUNCE"] =
	function(msg)
		local channel = strmatch(msg, "%s*([^%s]+)");
		if ( channel ) then
			ChannelToggleAnnouncements(channel);
		end
	end

SlashCmdList["GUILD_INVITE"] = function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true);
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Invite(msg);
end

SlashCmdList["GUILD_MOTD"] = function(msg)
	C_GuildInfo.SetMOTD(msg)
end

SlashCmdList["GUILD_INFO"] = function(msg)
	GuildInfo();
end

SlashCmdList["CHAT_DND"] = function(msg)
	C_ChatInfo.SendChatMessage(msg, "DND");
end

SlashCmdList["WHO"] = function(msg)
	local inGameWhoListDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.IngameWhoListDisabled);
	if (Kiosk.IsEnabled() or inGameWhoListDisabled) then
		return;
	end
	if ( msg == "" ) then
		msg = WhoFrame_GetDefaultWhoCommand();
		ShowWhoPanel();
	end
	WhoFrameEditBox:SetText(msg);
	C_FriendList.SendWho(msg, Enum.SocialWhoOrigin.Chat);
end

SlashCmdList["CHANNEL"] = function(msg, editBox)
	msg = SubstituteChatMessageBeforeSend(msg);
	C_ChatInfo.SendChatMessage(msg, "CHANNEL", editBox.languageID, ChatEdit_GetChannelTarget(editBox));
end
SlashCmdList["FRIENDS"] = function(msg)
	local inGameFriendsListDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.IngameFriendsListDisabled);
	if inGameFriendsListDisabled then
		return;
	end

	if msg == "" and UnitIsPlayer("target") then
		msg = GetUnitName("target", true)
	end
	if not msg or msg == "" then
		ToggleFriendsPanel();
	else
		local player, note = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if player then
			C_FriendList.AddOrRemoveFriend(player, note);
		end
	end
end

SlashCmdList["REMOVEFRIEND"] = function(msg)
	C_FriendList.RemoveFriend(msg);
end

SlashCmdList["IGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		local bNetIDAccount = BNet_GetBNetIDAccount(msg);
		if ( bNetIDAccount ) then
			if ( BNIsFriend(bNetIDAccount) ) then
				SendSystemMessage(ERR_CANNOT_IGNORE_BN_FRIEND);
			else
				BNSetBlocked(bNetIDAccount, not BNIsBlocked(bNetIDAccount));
			end
		else
			C_FriendList.AddOrDelIgnore(msg);
		end
	else
		ToggleIgnorePanel();
	end
end

SlashCmdList["UNIGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		C_FriendList.DelIgnore(msg);
	else
		ToggleIgnorePanel();
	end
end

SlashCmdList["SCRIPT"] = function(msg)
	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if ( not C_AddOns.GetScriptsDisallowedForBeta() and not userScriptsDisabled ) then
		if ( not AreDangerousScriptsAllowed() ) then
			StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
			return;
		end
		RunScript(msg);
	end
end

SlashCmdList["RANDOM"] = function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)(.*)", "%2", 1);
	local rest = gsub(msg, "(%s*)(%d+)(.*)", "%3", 1);
	local num2 = "";
	local numSubs;
	if ( rest ~= "" ) then
		num2, numSubs = gsub(msg, "(%s*)(%d+)([-%s]+)(%d+)(.*)", "%4", 1);
		if ( numSubs == 0 ) then
			num2 = "";
		end
	end
	if ( num1 == "" and num2 == "" ) then
		RandomRoll("1", "100");
	elseif ( num2 == "" ) then
		RandomRoll("1", num1);
	else
		RandomRoll(num1, num2);
	end
end

SlashCmdList["MACRO"] = function(msg)
	ShowMacroFrame();
end

SlashCmdList["PVP"] = function(msg)
	C_PvP.TogglePVP();
end

SlashCmdList["READYCHECK"] = function(msg)
	if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
		DoReadyCheck();
	end
end

SlashCmdList["BENCHMARK"] = function(msg)
	SetTaxiBenchmarkMode(ValueToBoolean(msg), true);
end

SlashCmdList["DISMOUNT"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		Dismount();
	end
end
SlashCmdList["RESETCHAT"] = function(msg)
	FCF_ResetAllWindows();
end

SlashCmdList["ENABLE_ADDONS"] = function(msg)
	C_AddOns.EnableAllAddOns(msg);
	ReloadUI();
end

SlashCmdList["DISABLE_ADDONS"] = function(msg)
	C_AddOns.DisableAllAddOns(msg);
	ReloadUI();
end

SlashCmdList["STOPWATCH"] = function(msg)
	if ( not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") ) then
		UIParentLoadAddOn("Blizzard_TimeManager");
	end
	if ( StopwatchFrame ) then
		local text = strmatch(msg, "%s*([^%s]+)%s*");
		if ( text ) then
			text = strlower(text);

			-- in any of the following cases, the stopwatch will be shown
			StopwatchFrame:Show();

			-- try to match a command
			local function MatchCommand(param, text)
				local i, compare;
				i = 1;
				repeat
					compare = _G[param..i];
					if ( compare and compare == text ) then
						return true;
					end
					i = i + 1;
				until ( not compare );
				return false;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_PLAY", text) ) then
				Stopwatch_Play();
				return;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_PAUSE", text) ) then
				Stopwatch_Pause();
				return;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_STOP", text) ) then
				Stopwatch_Clear();
				return;
			end
			-- try to match a countdown
			local hour, minute, second = strmatch(msg, "(%d+):(%d+):(%d+)");
			if ( not hour ) then
				minute, second = strmatch(msg, "(%d+):(%d+)");
				if ( not minute ) then
					second = strmatch(msg, "(%d+)");
				end
			end
			Stopwatch_StartCountdown(tonumber(hour), tonumber(minute), tonumber(second));
		else
			Stopwatch_Toggle();
		end
	end
end

SlashCmdList["ACHIEVEMENTUI"] = function(msg)
	ToggleAchievementFrame();
end

-- easier method to turn on/off errors for macros
SlashCmdList["UI_ERRORS_OFF"] = function(msg)
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "0");
end

SlashCmdList["UI_ERRORS_ON"] = function(msg)
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "1");
end

SlashCmdList["EVENTTRACE"] = function(msg)
	UIParentLoadAddOn("Blizzard_EventTrace");
	EventTrace:ProcessChatCommand(msg);
end

if IsGMClient() then
	SLASH_TEXELVIS1 = "/texelvis";
	SLASH_TEXELVIS2 = "/tvis";
	SlashCmdList["TEXELVIS"] = function(msg)
		UIParentLoadAddOn("Blizzard_DebugTools");
		TexelSnappingVisualizer:Show();
	end
end

SlashCmdList["TABLEINSPECT"] = function(msg)
	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if ( Kiosk.IsEnabled() or C_AddOns.GetScriptsDisallowedForBeta() or userScriptsDisabled ) then
		return;
	end
	if ( not AreDangerousScriptsAllowed() ) then
		StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
		return;
	end
	forceinsecure();
	UIParentLoadAddOn("Blizzard_DebugTools");

	local focusedTable = nil;
	if msg ~= "" and msg ~= " " then
		local focusedFunction = loadstring(("return %s"):format(msg));
		focusedTable = focusedFunction and focusedFunction();
	end

	if focusedTable and type(focusedTable) == "table" then
		DisplayTableInspectorWindow(focusedTable);
	else
		local highlightFrame = FrameStackTooltip:SetFrameStack();
		if highlightFrame then
			DisplayTableInspectorWindow(highlightFrame);
		else
			DisplayTableInspectorWindow(UIParent);
		end
	end
end

SlashCmdList["DUMP"] = function(msg)
	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if (not Kiosk.IsEnabled() and not C_AddOns.GetScriptsDisallowedForBeta() and not userScriptsDisabled) then
		if ( not AreDangerousScriptsAllowed() ) then
			StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
			return;
		end
		UIParentLoadAddOn("Blizzard_DebugTools");
		DevTools_DumpCommand(msg);
	end
end

SlashCmdList["RELOAD"] = function(msg)
	ReloadUI();
end

SlashCmdList["WARGAME"] = function(msg)
	-- Parameters are (playername, area, isTournamentMode). Since the player name can be multiple words,
	-- we pass in theses parameters as a whitespace delimited string and let the C side tokenize it
	StartWarGameByName(msg);
end

SlashCmdList["TARGET_MARKER"] = function(msg)
	local marker, target = SecureCmdOptionParse(msg);
	if ( not target ) then
		target = "target";
	end
	if ( tonumber(marker) ) then
		SetRaidTarget(target, tonumber(marker));	--Using /tm 0 will clear the target marker.
	end
end

SlashCmdList["OPEN_LOOT_HISTORY"] = function(msg)
	ToggleLootHistoryFrame();
end

SlashCmdList["RAIDFINDER"] = function(msg)
	if C_LFGInfo.IsLFREnabled() then
		PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame);
	end
end

SlashCmdList["API"] = function(msg)
	APIDocumentation_LoadUI();
	APIDocumentation:HandleSlashCommand(msg);
end

SlashCmdList["COMMENTATOR_OVERRIDE"] = function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local originalName, overrideName = msg:match("^(%S-)%s+(.+)");
	if not originalName or not overrideName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOROVERRIDE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOROVERRIDE_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	originalName = originalName:sub(1, 1):upper() .. originalName:sub(2, -1);

	DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOROVERRIDE_SUCCESS):format(originalName, overrideName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);

	C_Commentator.AddPlayerOverrideName(originalName, overrideName);

	-- Also add character name without the realm if we got CharacterName-Realm.
	-- Prepend possible realm separators with % so they are matched literally
	local realmSeparateMatchList = string.gsub(REALM_SEPARATORS, ".", "%%%1");
	local characterName = string.match(originalName, "(..-)["..realmSeparateMatchList.."].");
	if characterName and characterName ~= originalName then
		DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOROVERRIDE_SUCCESS):format(characterName, overrideName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		C_Commentator.AddPlayerOverrideName(characterName, overrideName);
	end
end

SlashCmdList["COMMENTATOR_NAMETEAM"] = function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local teamIndex, teamName = msg:match("^(%d+) (.+)");
	teamIndex = tonumber(teamIndex);

	if not teamIndex or not teamName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_NAMETEAM, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_NAMETEAM_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	if not C_Commentator.IsSpectating() then
		DEFAULT_CHAT_FRAME:AddMessage(CONTEXT_ERROR_SLASH_COMMENTATOR_NAMETEAM, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	else
		DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOR_NAMETEAM_SUCCESS):format(teamIndex, teamName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	end

	C_Commentator.AssignPlayersToTeamInCurrentInstance(teamIndex, teamName);
end

SlashCmdList["COMMENTATOR_ASSIGNPLAYER"] = function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local playerName, teamName = msg:match("^(%S-)%s+(.+)");
	if not playerName or not teamName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_ASSIGNPLAYER, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_ASSIGNPLAYER_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOR_ASSIGNPLAYER_SUCCESS):format(playerName, teamName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	C_Commentator.AssignPlayerToTeam(playerName, teamName);
end

SlashCmdList["RESET_COMMENTATOR_SETTINGS"] = function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	C_Commentator.ResetSettings();
end

SlashCmdList["VOICECHAT"] = function(msg)
	if msg == "" then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(VOICE_COMMAND_SYNTAX, info.r, info.g, info.b, info.id);
		return;
	end
	local name = msg;
	local lowerName = string.lower(name);

	if lowerName == string.lower(VOICE_LEAVE_COMMAND) then
		local channelID = C_VoiceChat.GetActiveChannelID();
		if channelID then
			C_VoiceChat.DeactivateChannel(channelID);
		end
		return;
	end

	local channelType;
	local communityID;
	local streamID;
	if lowerName == string.lower(PARTY) then
		channelType = Enum.ChatChannelType.PrivateParty;
	elseif lowerName == string.lower(INSTANCE) then
		channelType = Enum.ChatChannelType.PublicParty;
	elseif lowerName == string.lower(GUILD) then
		communityID, streamID = CommunitiesUtil.FindGuildStreamByType(Enum.ClubStreamType.Guild);
	elseif lowerName == string.lower(OFFICER) then
		communityID, streamID = CommunitiesUtil.FindGuildStreamByType(Enum.ClubStreamType.Officer);
	else
		local communityName, streamName = string.split(":", name);
		communityID, streamID = CommunitiesUtil.FindCommunityAndStreamByName(communityName, streamName);
	end

	if channelType then
		if channelType ~= C_VoiceChat.GetActiveChannelType() then
			local activate = true;
			ChannelFrame:TryJoinVoiceChannelByType(channelType, activate);
		end
	elseif communityID and streamID then
		local activeChannelID = C_VoiceChat.GetActiveChannelID();
		local communityStreamChannel = C_VoiceChat.GetChannelForCommunityStream(communityID, streamID);
		local communityStreamChannelID = communityStreamChannel and communityStreamChannel.channelID;
		if not activeChannelID or activeChannelID ~= communityStreamChannelID then
			ChannelFrame:TryJoinCommunityStreamChannel(communityID, streamID);
		end
	end
end

SlashCmdList["TEXTTOSPEECH"] = function(msg)
	if TextToSpeechCommands:EvaluateTextToSpeechCommand(msg) then
		TextToSpeechFrame_Update(TextToSpeechFrame);
	else
		TextToSpeechCommands:SpeakConfirmation(TEXTTOSPEECH_COMMAND_SYNTAX_ERROR);
		TextToSpeechCommands:ShowHelp(msg)
	end
end

SlashCmdList["COUNTDOWN"] = function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)", "%2");
	local number = tonumber(num1);
	if(number and number <= MAX_COUNTDOWN_SECONDS) then
		C_PartyInfo.DoCountdown(number);
	end
end
