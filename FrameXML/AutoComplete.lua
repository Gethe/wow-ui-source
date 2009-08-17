AUTOCOMPLETE_MAX_BUTTONS = 5;

AUTOCOMPLETE_FLAG_NONE =			0x00000000;
AUTOCOMPLETE_FLAG_IN_GROUP = 		0x00000001;
AUTOCOMPLETE_FLAG_IN_GUILD = 		0x00000002;
AUTOCOMPLETE_FLAG_FRIEND =			0x00000004;
AUTOCOMPLETE_FLAG_INTERACTED_WITH = 0x00000010;
AUTOCOMPLETE_FLAG_ONLINE = 			0x00000020;
AUTOCOMPLETE_FLAG_ALL =				0xffffffff;

AUTOCOMPLETE_LIST_TEMPLATES = {
	ALL = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	ONLINE = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	ONLINE_NOT_IN_GROUP = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = AUTOCOMPLETE_FLAG_IN_GROUP,
	},
	ONLINE_NOT_IN_GUILD = {
		include = AUTOCOMPLETE_FLAG_ONLINE,
		exclude = AUTOCOMPLETE_FLAG_IN_GUILD,
	},
	NOT_FRIEND = {
		include = AUTOCOMPLETE_FLAG_ALL,
		exclude = AUTOCOMPLETE_FLAG_FRIEND,
	},
	IN_GROUP = {
		include = AUTOCOMPLETE_FLAG_IN_GROUP,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	IN_GUILD = {
		include = AUTOCOMPLETE_FLAG_IN_GUILD,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	FRIEND = {
		include = AUTOCOMPLETE_FLAG_FRIEND,
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
	FRIEND_NOT_GUILD = {
		include = AUTOCOMPLETE_FLAG_FRIEND,
		exclude = AUTOCOMPLETE_FLAG_IN_GUILD,
	},
	FRIEND_AND_GUILD = {
		include = bit.bor(AUTOCOMPLETE_FLAG_FRIEND, AUTOCOMPLETE_FLAG_IN_GUILD),
		exclude = AUTOCOMPLETE_FLAG_NONE,
	},
}
		
AUTOCOMPLETE_LIST = {};
local AUTOCOMPLETE_LIST = AUTOCOMPLETE_LIST;
	AUTOCOMPLETE_LIST.ALL				= AUTOCOMPLETE_LIST_TEMPLATES.ALL;
	AUTOCOMPLETE_LIST.WHISPER			= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE;
	AUTOCOMPLETE_LIST.INVITE			= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_IN_GROUP;
	AUTOCOMPLETE_LIST.UNINVITE			= AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP;
	AUTOCOMPLETE_LIST.PROMOTE			= AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP;
	AUTOCOMPLETE_LIST.TEAM_INVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE;
	AUTOCOMPLETE_LIST.GUILD_INVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE_NOT_IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_UNINVITE	= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_PROMOTE		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_DEMOTE		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.GUILD_LEADER		= AUTOCOMPLETE_LIST_TEMPLATES.IN_GUILD;
	AUTOCOMPLETE_LIST.ADDFRIEND			= AUTOCOMPLETE_LIST_TEMPLATES.NOT_FRIEND;
	AUTOCOMPLETE_LIST.REMOVEFRIEND		= AUTOCOMPLETE_LIST_TEMPLATES.FRIEND;
	AUTOCOMPLETE_LIST.CHANINVITE		= AUTOCOMPLETE_LIST_TEMPLATES.ONLINE;
	AUTOCOMPLETE_LIST.MAIL				= AUTOCOMPLETE_LIST_TEMPLATES.ALL;
	AUTOCOMPLETE_LIST.CALENDARGUILDEVENT= AUTOCOMPLETE_LIST_TEMPLATES.FRIEND_NOT_GUILD;
	AUTOCOMPLETE_LIST.CALENDAREVENT		= AUTOCOMPLETE_LIST_TEMPLATES.FRIEND_AND_GUILD;

AUTOCOMPLETE_SIMPLE_REGEX = "(.+)";
AUTOCOMPLETE_SIMPLE_FORMAT_REGEX = "%1$s";

AUTOCOMPLETE_DEFAULT_Y_OFFSET = 3;
function AutoComplete_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	
	self.maxHeight = AUTOCOMPLETE_MAX_BUTTONS * AutoCompleteButton1:GetHeight();
end

function AutoComplete_Update(parent, text, cursorPosition)
	local self = AutoCompleteBox;
	local attachPoint;
	if ( not parent.autoCompleteParams ) then
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
		end
		
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
		AutoComplete_UpdateResults(self,
			GetAutoCompleteResults(text, parent.autoCompleteParams.include, parent.autoCompleteParams.exclude, AUTOCOMPLETE_MAX_BUTTONS+1, cursorPosition));
	else
		AutoComplete_HideIfAttachedTo(parent);
	end
end

function AutoComplete_HideIfAttachedTo(parent)
	local self = AutoCompleteBox;
	if ( self.parent == parent ) then
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

function AutoComplete_UpdateResults(self, ...)
	local totalReturns = select("#", ...);
	local numReturns = min(totalReturns, AUTOCOMPLETE_MAX_BUTTONS);
	local maxWidth = 120;
	for i=1, numReturns do
		local button = _G["AutoCompleteButton"..i]
		button:SetText(select(i, ...));
		maxWidth = max(maxWidth, button:GetFontString():GetWidth()+30);
		button:Enable();
		button:Show();
	end
	for i = numReturns+1, AUTOCOMPLETE_MAX_BUTTONS do
		_G["AutoCompleteButton"..i]:Hide();
	end
	if ( numReturns > 0 ) then
		self:SetHeight(numReturns*AutoCompleteButton1:GetHeight()+20);
		self:SetWidth(maxWidth);
		if ( not self:IsShown() ) then
			AutoComplete_SetSelectedIndex(self, 0);
		end
		self:Show();
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

function AutoCompleteEditBox_OnTabPressed(editBox)
	local autoComplete = AutoCompleteBox;
	if ( autoComplete:IsShown() and autoComplete.parent == editBox ) then
		local selectedIndex = AutoComplete_GetSelectedIndex(autoComplete);
		local numReturns = AutoComplete_GetNumResults(autoComplete);
		if ( IsShiftKeyDown() ) then
			local nextNum = mod(selectedIndex - 1, numReturns);
			if ( nextNum == 0 ) then
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
		AutoComplete_Update(self, self:GetText(), self:GetUTF8CursorPosition());
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
	
	--The following is used to replace "/whisper ar message here" with "/whisper Arenai message here"
	local newText = string.gsub(editBoxText, editBox.autoCompleteRegex or AUTOCOMPLETE_SIMPLE_REGEX,
		string.format(editBox.autoCompleteFormatRegex or AUTOCOMPLETE_SIMPLE_FORMAT_REGEX, gsub(self:GetText(), " ", ""),
			string.match(editBoxText, editBox.autoCompleteRegex or AUTOCOMPLETE_SIMPLE_REGEX)),
			1)
	editBox:SetText(newText);
	autoComplete:Hide();
end
