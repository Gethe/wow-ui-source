AUTOCOMPLETE_MAX_BUTTONS = 5;

AUTOCOMPLETE_FLAG_NONE =			0x00000000;
AUTOCOMPLETE_FLAG_IN_GROUP = 		0x00000001;
AUTOCOMPLETE_FLAG_IN_GUILD = 		0x00000002;
AUTOCOMPLETE_FLAG_FRIEND =			0x00000004;
AUTOCOMPLETE_FLAG_BNET =			0x00000008;
AUTOCOMPLETE_FLAG_INTERACTED_WITH = 0x00000010;
AUTOCOMPLETE_FLAG_ONLINE = 			0x00000020;
AUTO_COMPLETE_IN_AOI = 				0x00000040;
AUTO_COMPLETE_ACCOUNT_CHARACTER =	0x00000080;
AUTO_COMPLETE_NON_LOCAL_REALM =		0x00000100;
AUTOCOMPLETE_FLAG_ALL =				0xffffffff;

AUTOCOMPLETE_LIST_TEMPLATES = {
	ALL = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	ALL_OTHERS = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = AUTO_COMPLETE_ACCOUNT_CHARACTER,
	},
	ALL_OTHER_CHARS = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = bit.bor(AUTO_COMPLETE_ACCOUNT_CHARACTER,AUTOCOMPLETE_FLAG_BNET),
	},
	ALL_CHARS_LOCAL_REALM = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = bit.bor(AUTOCOMPLETE_FLAG_BNET, AUTO_COMPLETE_NON_LOCAL_REALM),
	},
	FRIENDLY_CHARS = {
		include = bit.bor(AUTOCOMPLETE_FLAG_IN_GUILD,AUTOCOMPLETE_FLAG_FRIEND,AUTO_COMPLETE_ACCOUNT_CHARACTER),
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	ONLINE = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	ONLINE_NOT_BNET = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = AUTOCOMPLETE_FLAG_BNET,
	},
	ONLINE_NOT_IN_GROUP = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = bit.bor(AUTOCOMPLETE_FLAG_IN_GROUP,AUTOCOMPLETE_FLAG_BNET),
	},
	ONLINE_NOT_IN_GUILD = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = bit.bor(AUTOCOMPLETE_FLAG_IN_GUILD,AUTOCOMPLETE_FLAG_BNET),
	},
	NOT_FRIEND = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = bit.bor(AUTOCOMPLETE_FLAG_FRIEND,AUTOCOMPLETE_FLAG_BNET,AUTO_COMPLETE_ACCOUNT_CHARACTER);
	},
	IN_GROUP = {
		include = AUTOCOMPLETE_FLAG_IN_GROUP,
		exclude = AUTOCOMPLETE_FLAG_BNET,
	},
	IN_GUILD = {
		include = AUTOCOMPLETE_FLAG_IN_GUILD,
		exclude = AUTOCOMPLETE_FLAG_BNET,
	},
	FRIEND = {
		include = AUTOCOMPLETE_FLAG_FRIEND,
		exclude = AUTOCOMPLETE_FLAG_BNET,
	},
	FRIEND_NOT_GUILD = {
		include = AUTOCOMPLETE_FLAG_FRIEND,
		exclude = bit.bor(AUTOCOMPLETE_FLAG_IN_GUILD,AUTOCOMPLETE_FLAG_BNET),
	},
	FRIEND_AND_GUILD = {
		include = bit.bor(AUTOCOMPLETE_FLAG_FRIEND, AUTOCOMPLETE_FLAG_IN_GUILD),
		exclude = AUTOCOMPLETE_FLAG_BNET,
	},
	KNOWN = {
		include = bit.bor(AUTOCOMPLETE_FLAG_IN_GROUP, AUTOCOMPLETE_FLAG_IN_GUILD, 
						AUTOCOMPLETE_FLAG_FRIEND, AUTOCOMPLETE_FLAG_INTERACTED_WITH),
		exclude = AUTOCOMPLETE_FLAG_BNET
	},
	KNOWN_NOT_GUILD = {
		include = bit.bor(AUTOCOMPLETE_FLAG_IN_GROUP, AUTOCOMPLETE_FLAG_FRIEND, AUTOCOMPLETE_FLAG_INTERACTED_WITH),
		exclude = bit.bor(AUTOCOMPLETE_FLAG_BNET, AUTOCOMPLETE_FLAG_IN_GUILD),
	},
	BNET_NOT_IN_PARTY = {
		include = AUTOCOMPLETE_FLAG_BNET,
		exclude = AUTOCOMPLETE_FLAG_IN_GROUP,
	},
}
		
AUTOCOMPLETE_LIST = {};
local AUTOCOMPLETE_LIST = AUTOCOMPLETE_LIST;
	AUTOCOMPLETE_LIST.ALL				= AUTOCOMPLETE_LIST_TEMPLATES.ALL;
	AUTOCOMPLETE_LIST.WHISPER			= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_BNET;
	AUTOCOMPLETE_LIST.SMART_WHISPER		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE;
	AUTOCOMPLETE_LIST.WHISPER_EXTRACT	= AUTOCOMPLETE_LIST_TEMPLATES.ALL_OTHER_CHARS;
	AUTOCOMPLETE_LIST.SMART_WHISPER_EXTRACT=AUTOCOMPLETE_LIST_TEMPLATES.ALL_OTHERS;
	AUTOCOMPLETE_LIST.INVITE			= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_IN_GROUP;
	AUTOCOMPLETE_LIST.UNINVITE			= AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP;
	AUTOCOMPLETE_LIST.PROMOTE			= AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP;
	AUTOCOMPLETE_LIST.TEAM_INVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_BNET;
	AUTOCOMPLETE_LIST.GUILD_INVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_UNINVITE	= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_PROMOTE		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_DEMOTE		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_LEADER		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.ADDFRIEND			= AUTOCOMPLETE_LIST_TEMPLATES.NOT_FRIEND;
	AUTOCOMPLETE_LIST.FRIENDS			= AUTOCOMPLETE_LIST_TEMPLATES.NOT_FRIEND;
	AUTOCOMPLETE_LIST.REMOVEFRIEND		= AUTOCOMPLETE_LIST_TEMPLATES.FRIEND;
	AUTOCOMPLETE_LIST.CHANINVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_BNET;
	AUTOCOMPLETE_LIST.MAIL				= AUTOCOMPLETE_LIST_TEMPLATES.ALL_CHARS_LOCAL_REALM;
	AUTOCOMPLETE_LIST.CALENDARGUILDEVENT= AUTOCOMPLETE_LIST_TEMPLATES.KNOWN_NOT_GUILD;
	AUTOCOMPLETE_LIST.CALENDAREVENT		= AUTOCOMPLETE_LIST_TEMPLATES.KNOWN;
	AUTOCOMPLETE_LIST.IGNORE			= AUTOCOMPLETE_LIST_TEMPLATES.NOT_FRIEND;
	AUTOCOMPLETE_LIST.LOOT_MASTER		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP;
	-- If we want this, need to resolve K-String shenanigans and then update ChatEditAutoComplete.
	-- AUTOCOMPLETE_LIST.WARGAME			= AUTOCOMPLETE_LIST_TEMPLATES.BNET_NOT_IN_PARTY;
	AUTOCOMPLETE_LIST.COMMUNITY			= AUTOCOMPLETE_LIST_TEMPLATES.ALL_OTHER_CHARS;

AUTOCOMPLETE_COLOR_KEYS = 
{
[LE_AUTOCOMPLETE_PRIORITY_OTHER]  		= {key=NORMAL_FONT_COLOR_CODE, text="" },
[LE_AUTOCOMPLETE_PRIORITY_INTERACTED] 	= {key="WHISPER", text=AUTOCOMPLETE_LABEL_INTERACTED },
[LE_AUTOCOMPLETE_PRIORITY_IN_GROUP] 	= {key="PARTY", text=AUTOCOMPLETE_LABEL_GROUP },
[LE_AUTOCOMPLETE_PRIORITY_GUILD]		= {key="GUILD", text=AUTOCOMPLETE_LABEL_GUILD },
[LE_AUTOCOMPLETE_PRIORITY_FRIEND] 		= {key="BN_WHISPER", text=AUTOCOMPLETE_LABEL_FRIEND },
[LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER] = {key=NORMAL_FONT_COLOR_CODE, text="" },
[LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER_SAME_REALM] = {key=NORMAL_FONT_COLOR_CODE, text=""},
}
	
AUTOCOMPLETE_SIMPLE_REGEX = "(.+)";
AUTOCOMPLETE_SIMPLE_FORMAT_REGEX = "%1$s";

AUTOCOMPLETE_DEFAULT_Y_OFFSET = 3;
function AutoComplete_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	
	self.maxHeight = AUTOCOMPLETE_MAX_BUTTONS * AutoCompleteButton1:GetHeight();
	
	AutoCompleteInstructions:SetText("|cffbbbbbb"..PRESS_TAB.."|r");
	C_Timer.After(5, function()
		if ( IsInGuild() ) then
			GuildRoster();
		end
	end);
end

function AutoComplete_Update(parent, text, cursorPosition)
	local self = AutoCompleteBox;
	local attachPoint;
	if ( not parent.autoCompleteSource or not parent.autoCompleteParams ) then
		return;
	end
	if ( not text or text == "" ) then
		AutoComplete_HideIfAttachedTo(parent);
		return;
	end
	if ( cursorPosition <= strlen(text) ) then
		self:SetParent(parent);
		if(self.parent ~= parent) then
			AutoComplete_SetSelectedIndex(self, 0);
			self.parentArrows = parent:GetAltArrowKeyMode();
		end
		parent:SetAltArrowKeyMode(false);
		
		if ( parent:GetBottom() - self.maxHeight <= (AUTOCOMPLETE_DEFAULT_Y_OFFSET + 10) ) then	--10 is a magic number from the offset of AutoCompleteButton1.
			attachPoint = "ABOVE";
		else
			attachPoint = "BELOW";
		end
		if ( (self.parent ~= parent) or (self.attachPoint ~= attachPoint) ) then
			if ( attachPoint == "ABOVE" ) then
				self:ClearAllPoints();
				self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", parent.autoCompleteXOffset or 0, parent.autoCompleteYOffset or -AUTOCOMPLETE_DEFAULT_Y_OFFSET);
			elseif ( attachPoint == "BELOW" ) then
				self:ClearAllPoints();
				self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", parent.autoCompleteXOffset or 0, parent.autoCompleteYOffset or AUTOCOMPLETE_DEFAULT_Y_OFFSET);
			end
			self.attachPoint = attachPoint;
		end
		
		self.parent = parent;
		--We ask for one more result than we need so that we know whether or not results are continued
		local allowFullMatch = true;
		local possibilities = parent.autoCompleteSource(text, AUTOCOMPLETE_MAX_BUTTONS+1, cursorPosition, allowFullMatch, unpack(parent.autoCompleteParams));

		if (not possibilities) then
			possibilities = {};
		end
		
		-- We only want to show an exact match in the autocomplete dropdown if there are multiple results.
		if (#possibilities == 1 and text == possibilities[1].name) then
			possibilities[1] = nil;
		end
		
		local realmStart = text:find("-", 1, true); 
		if (realmStart) then
			local realms = GetAutoCompleteRealms();
			local realm, subStart, subEnd;
			realmStart = text:sub(realmStart + 1) --get text after hyphen
			local index = #possibilities + 1;
			for i=1, #realms do
				realm = realms[i];
				subStart, subEnd = realm:lower():find(realmStart:lower(), 1, true) 
				if (subStart and subStart == 1) then
					if (subEnd > 0) then
						--if they started typing a known realm name, just append the rest of it
						realm = realm:sub(subEnd + 1); 
					end
					local entry = text..realm;
					if (not tContains(possibilities, entry)) then
						possibilities[index] = {name=entry, priority=LE_AUTOCOMPLETE_PRIORITY_OTHER};
					end
					index = index + 1
				end;
			end
		end
		AutoComplete_UpdateResults(self, possibilities, parent.autoCompleteContext);
	else
		AutoComplete_HideIfAttachedTo(parent);
	end
end

function AutoComplete_HideIfAttachedTo(parent)
	local self = AutoCompleteBox;
	if ( self.parent == parent ) then
		if( self.parentArrows ) then
			parent:SetAltArrowKeyMode(self.parentArrows);
			self.parentArrows = nil;
		end
		self.parent = nil;
		self:Hide();
	end
end

function AutoComplete_SetSelectedIndex(self, index)
	self.selectedIndex = index;
	for i=1, AUTOCOMPLETE_MAX_BUTTONS do
		_G["AutoCompleteButton"..i]:UnlockHighlight();
	end
	if ( index ~= 0 ) then
		_G["AutoCompleteButton"..index]:LockHighlight();
	end
end

function AutoComplete_GetSelectedIndex(self)
	return self.selectedIndex;
end

function AutoComplete_GetNumResults(self)
	return self.numResults;
end

function AutoComplete_UpdateResults(self, results, context)
	local totalReturns = #results;
	local numReturns = min(totalReturns, AUTOCOMPLETE_MAX_BUTTONS);
	local maxWidth = 120;
	for i=1, numReturns do
		local button = _G["AutoCompleteButton"..i]
		button.nameInfo = results[i];
		local displayName = Ambiguate(results[i].name, context or "all");
		local displayText;
		local displayInfo = AUTOCOMPLETE_COLOR_KEYS[results[i].priority]
		if ( ENABLE_COLORBLIND_MODE == "1" ) then
			displayText = displayName.." "..displayInfo.text;
		else
			local colorCode;
			if (ChatTypeInfo[displayInfo.key]) then
				colorCode = RGBTableToColorCode(ChatTypeInfo[displayInfo.key])
			else
				colorCode = displayInfo.key;
			end
			displayText = colorCode..displayName..FONT_COLOR_CODE_CLOSE
		end
		button:SetText(displayText);
		maxWidth = max(maxWidth, button:GetFontString():GetWidth()+30);
		button:Enable();
		button:Show();
	end
	for i = numReturns+1, AUTOCOMPLETE_MAX_BUTTONS do
		_G["AutoCompleteButton"..i]:Hide();
	end
	
	if ( numReturns > 0 ) then
		maxWidth = max(maxWidth, AutoCompleteInstructions:GetStringWidth()+30);
		self:SetHeight(numReturns*AutoCompleteButton1:GetHeight()+35);
		self:SetWidth(maxWidth);
		self:Show();
		AutoComplete_SetSelectedIndex(self, 1);
	else
		self:Hide();
	end
		
	if ( totalReturns > AUTOCOMPLETE_MAX_BUTTONS )  then
		local button = _G["AutoCompleteButton"..AUTOCOMPLETE_MAX_BUTTONS];
		button:SetText(CONTINUED);
		button:Disable();
		self.numResults = numReturns - 1;
	else 
		self.numResults = numReturns;
	end
end

function AutoComplete_IncrementSelection(editBox, up)
	local autoComplete = AutoCompleteBox;
	if ( autoComplete:IsShown() and autoComplete.parent == editBox ) then
		local selectedIndex = AutoComplete_GetSelectedIndex(autoComplete);
		local numReturns = AutoComplete_GetNumResults(autoComplete);
		if ( up ) then
			local nextNum = mod(selectedIndex - 1, numReturns);
			if ( nextNum <= 0 ) then
				nextNum = numReturns;
			end
			AutoComplete_SetSelectedIndex(autoComplete, nextNum);
		else
			local nextNum = mod(selectedIndex + 1, numReturns);
			if ( nextNum == 0 ) then
				nextNum = numReturns;
			end
			AutoComplete_SetSelectedIndex(autoComplete, nextNum)
		end
		return true;
	end
	return false;
end

function AutoCompleteEditBox_SetAutoCompleteSource(self, source, ...)
	self.autoCompleteSource = source;
	self.autoCompleteParams = { ... };
end

function AutoCompleteEditBox_SetCustomAutoCompleteFunction(self, customAutoCompleteFunction)
	self.customAutoCompleteFunction = customAutoCompleteFunction;
end

function AutoCompleteEditBox_OnTabPressed(editBox)
	return AutoComplete_IncrementSelection(editBox, IsShiftKeyDown())
end

function AutoCompleteEditBox_OnArrowPressed(self, key)
	if ( key == "UP" ) then
		return AutoComplete_IncrementSelection(self, true);
	elseif ( key == "DOWN" ) then
		return AutoComplete_IncrementSelection(self, false);
	end
end

function AutoCompleteEditBox_OnEnterPressed(self)
	local autoComplete = AutoCompleteBox;
	if ( autoComplete:IsShown() and (autoComplete.parent == self) and (AutoComplete_GetSelectedIndex(autoComplete) ~= 0) ) then
		AutoCompleteButton_OnClick(_G["AutoCompleteButton"..AutoComplete_GetSelectedIndex(autoComplete)]);
		return true;
	end
	return false;
end

function AutoCompleteEditBox_OnTextChanged(self, userInput)
    if ( userInput ) then
		if self.disallowAutoComplete then
			AutoComplete_HideIfAttachedTo(self);
		else
			AutoComplete_Update(self, self:GetText(), self:GetUTF8CursorPosition());
		end
    end
    if(self:GetText() == "") then
        AutoComplete_HideIfAttachedTo(self);
    end
end

function AutoCompleteEditBox_OnKeyDown(self, key)
	if ( key == "BACKSPACE" or key == "DELETE" ) then
		self.disallowAutoComplete = true;
	end
end

function AutoCompleteEditBox_OnKeyUp(self, key)
	if ( key == "BACKSPACE" or key == "DELETE" ) then
		self.disallowAutoComplete = false;
	end
end

function AutoCompleteEditBox_AddHighlightedText(editBox, text)
	if ( not editBox.autoCompleteSource or not editBox.autoCompleteParams ) then
		return;
	end
	local editBoxText = editBox:GetText();
	local utf8Position = editBox:GetUTF8CursorPosition();
	local allowFullMatch = true;
	local nameInfo = editBox.autoCompleteSource(text, 1, utf8Position, allowFullMatch, unpack(editBox.autoCompleteParams))[1]; --just want first name
	if ( nameInfo and nameInfo.name ) then
		--We're going to be setting the text programatically which will clear the userInput flag on the editBox. So we want to manually update the dropdown before we change the text.
		AutoComplete_Update(editBox, editBoxText, utf8Position);
		local name = Ambiguate(nameInfo.name, editBox.autoCompleteContext or "all");
		local newText = string.gsub(editBoxText, AUTOCOMPLETE_SIMPLE_REGEX,
							string.format(AUTOCOMPLETE_SIMPLE_FORMAT_REGEX, name,
								string.match(editBoxText, AUTOCOMPLETE_SIMPLE_REGEX)),
								1);
		editBox:SetText(newText);
		editBox:HighlightText(strlen(editBoxText), strlen(newText));	--This won't work if there is more after the name, but we aren't enabling this for normal chat (yet). Please fix me when we do.
		editBox:SetCursorPosition(strlen(editBoxText));
	end
end

function AutoCompleteEditBox_OnChar(self)
	if (self.addHighlightedText and self:GetUTF8CursorPosition() == strlenutf8(self:GetText())) then
		AutoCompleteEditBox_AddHighlightedText(self, self:GetText());
	end
end

function AutoCompleteEditBox_OnEditFocusLost(self)
	AutoComplete_HideIfAttachedTo(self);
end

function AutoCompleteEditBox_OnEscapePressed(self)
	local autoComplete = AutoCompleteBox;
	if ( autoComplete:IsShown() and autoComplete.parent == self ) then
		AutoComplete_HideIfAttachedTo(self);
		return true;
	end
	return false;
end	

function AutoCompleteButton_OnClick(self)
	local autoComplete = self:GetParent();
	local editBox = autoComplete.parent;
	local editBoxText = editBox:GetText();
	local name = Ambiguate(self.nameInfo.name, "none");
	local newText;
	
	if (editBox.command) then
		newText = editBox.command.." "..name;
	else
		newText = name;
	end
	
	if ( editBox.addSpaceToAutoComplete ) then
		newText = newText.." ";
	end
	
	autoComplete:Hide();
	
	if ( editBox.customAutoCompleteFunction ~= nil and editBox.customAutoCompleteFunction(editBox, newText, self.nameInfo) ) then
		return;
	end
	
	editBox:SetText(newText);
	--When we change the text, we move to the end, so we'll be consistent and move to the end if we don't change it as well.
	editBox:SetCursorPosition(strlen(newText));
end