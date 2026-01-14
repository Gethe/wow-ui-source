function ChatFrameUtil.InsertLink(text)
	if ( not text ) then
		return false;
	end

	local activeWindow = ChatFrameUtil.GetActiveWindow();
	if ( activeWindow ) then
		activeWindow:Insert(text);
		return true;
	end
	if ( BrowseName and BrowseName:IsVisible() ) then
		local item;
		if ( strfind(text, "battlepet:") ) then
			local petName = strmatch(text, "%[(.+)%]");
			item = petName;
		elseif ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			BrowseName:SetText('"'..item..'"');
			return true;
		end
	end
	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		local cursorPosition = MacroFrameText:GetCursorPosition();
		if (cursorPosition == 0 or strsub(MacroFrameText:GetText(), cursorPosition, cursorPosition) == "\n" ) then
			if ( item ) then
				if ( C_Item.GetItemSpell(text) ) then
					MacroFrameText:Insert(SLASH_USE1.." "..item.."\n");
				else
					MacroFrameText:Insert(SLASH_EQUIP1.." "..item.."\n");
				end
			else
				MacroFrameText:Insert(SLASH_CAST1.." "..text.."\n");
			end
		else
			MacroFrameText:Insert(item or text);
		end
		return true;
	end
	if ( CommunitiesFrame and CommunitiesFrame.ChatEditBox:HasFocus() ) then
		CommunitiesFrame.ChatEditBox:Insert(text);
		return true;
	end
	if ( not IsUsingLegacyAuctionClient() and AuctionHouseFrame and AuctionHouseFrame:IsVisible() ) then
		local item;
		if ( strfind(text, "battlepet:") ) then
			local petName = strmatch(text, "%[(.+)%]");
			item = petName;
		elseif ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			if ( AuctionHouseFrame:SetSearchText(item) ) then
				return true;
			end
		end
	end

	return false;
end

function ChatFrameUtil.DisplayLevelUp(chatFrame, level, ...)
	-- Level up
	local info = ChatTypeInfo["SYSTEM"];
	-- Blank arg is numNewPvpTalentSlots (always 0 in Classic).
	local arg2, arg3, arg4, _, arg5, arg6, arg7, arg8, arg9 = ...;

	local string
	if (LevelUpDisplay) then
		string = LEVEL_UP:format(level, level);
	else
		string = LEVEL_UP:format(level);
	end
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);

	if ( arg3 > 0 ) then
		string = LEVEL_UP_HEALTH_MANA:format(arg2, arg3);
	else
		string = LEVEL_UP_HEALTH:format(arg2);
	end
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);

	if ( arg4 > 0 ) then
		string = format(GetText("LEVEL_UP_CHAR_POINTS", nil, arg4), arg4);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end

	if ( arg5 > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT1_NAME, arg5);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( arg6 > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT2_NAME, arg6);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( arg7 > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT3_NAME, arg7);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( arg8 > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT4_NAME, arg8);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( arg9 > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT5_NAME, arg9);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
end

function ChatFrameUtil.GetChannelShortcutName(index)
	local _, name = GetChannelName(index);
	name = strtrim(name:match("([^%-]+)"));
	return name;
end

function ChatFrameUtil.GetNewcomerChatTarget(chatFrame)
	-- Classic doesn't have newcomer chat.
end
