local GUILD_ROSTER_MAX_COLUMNS = 5;
local GUILD_ROSTER_MAX_STRINGS = 4;
local GUILD_ROSTER_BAR_MAX = 237;
local GUILD_ROSTER_BUTTON_OFFSET = 2;
local GUILD_ROSTER_BUTTON_HEIGHT = 20;
local currentGuildView;

local GUILD_ROSTER_COLUMNS = {
	playerStatus = { "level", "class", "wideName", "zone" },
	guildStatus = { "name", "rank", "note", "online" },
	contribution = { "level", "class", "wideName", "contribution" },
	pve = { "level", "class", "name", "valor", "hero" },
	pvp = { "level", "class", "name", "honor", "conquest" },
	achievement = { "level", "class", "wideName", "achievement" },
};

local GUILD_ROSTER_COLUMN_DATA = {
	level = { width = 32, text = LEVEL_ABBR, stringJustify="CENTER" },
	class = { width = 32, text = "Cls", hasIcon = true },
	name = { width = 81, text = "Name", stringJustify="LEFT" },
	wideName = { width = 101, text = "Name", sortType = "name", stringJustify="LEFT" },
	rank = { width = 76, text = "Rank", stringJustify="LEFT" },
	note = { width = 76, text = "Note", stringJustify="LEFT" },
	online = { width = 74, text = "Last Online", stringJustify="LEFT" },
	valor = { width = 82, text = "Valor", stringJustify="RIGHT" },
	hero = { width = 82, text = "Hero", stringJustify="RIGHT" },
	honor = { width = 82, text = "Honor", stringJustify="RIGHT" },
	conquest = { width = 82, text = "Conquest", stringJustify="RIGHT" },
	contribution = { width = 142, text = "Contribution", stringJustify="RIGHT", hasBar = true },
	zone = { width = 142, text = "Zone", stringJustify="LEFT" },
	achievement = { width = 142, text = "Achievement", stringJustify="RIGHT" },
};

function GuildRosterFrame_OnLoad()
	GuildFrame_RegisterPanel("GuildRosterFrame");
	GuildRosterContainer.update = GuildRoster_Update;
	HybridScrollFrame_CreateButtons(GuildRosterContainer, "GuildRosterButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -GUILD_ROSTER_BUTTON_OFFSET, "TOP", "BOTTOM");
	
	_SetupFakeGuild(26);
	GuildRoster_SetView("playerStatus");
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
	GuildRoster_Update();
end

function GuildRoster_Update()
	local scrollFrame = GuildRosterContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index, class;
	local topContribution = _GuildGetHighestContribution();

	for i = 1, numButtons do
		button = buttons[i];		
		index = offset + i;
		if ( _GuildMembers[index] ) then
			class = _GuildMembers[index].class;
			if ( currentGuildView == "playerStatus" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].level, _GuildMembers[index].online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].zone, _GuildMembers[index].online)
			elseif ( currentGuildView == "guildStatus" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].rankName, _GuildMembers[index].online)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].note, _GuildMembers[index].online)
				GuildRosterButton_SetStringText(button.string4, "[PH]", _GuildMembers[index].online)
			elseif ( currentGuildView == "contribution" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].level, _GuildMembers[index].online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].contribution, _GuildMembers[index].online)
				if ( _GuildMembers[index].contribution == 0 ) then
					button.barTexture:Hide();				
				else
					button.barTexture:SetWidth(_GuildMembers[index].contribution / topContribution * GUILD_ROSTER_BAR_MAX);
					button.barTexture:Show();
				end
				GuildRosterButton_SetStringText(button.barLabel, "#".._GuildMembers[index].contributionRank, _GuildMembers[index].online)
			elseif ( currentGuildView == "pve" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].level, _GuildMembers[index].online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].valor, _GuildMembers[index].online)			
				GuildRosterButton_SetStringText(button.string4, _GuildMembers[index].hero, _GuildMembers[index].online)
			elseif ( currentGuildView == "pvp" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].level, _GuildMembers[index].online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].honor, _GuildMembers[index].online)
				GuildRosterButton_SetStringText(button.string4, _GuildMembers[index].conquest, _GuildMembers[index].online)	
			elseif ( currentGuildView == "achievement" ) then
				GuildRosterButton_SetStringText(button.string1, _GuildMembers[index].level, _GuildMembers[index].online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
				GuildRosterButton_SetStringText(button.string2, _GuildMembers[index].name, _GuildMembers[index].online, class)
				GuildRosterButton_SetStringText(button.string3, _GuildMembers[index].achievement, _GuildMembers[index].online)
			end
			button:Show();
			if ( mod(index, 2) == 0 ) then
				button.stripe:Hide();
			else
				button.stripe:Show();
			end			
		else
			button:Hide();
		end
	end
	local totalHeight = #_GuildMembers * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildRosterButton_SetStringText(buttonString, text, isOnline, class)
	buttonString:SetText(text);
	if ( isOnline ) then
		if ( class ) then
			local classColor = RAID_CLASS_COLORS[class];
			buttonString:SetTextColor(classColor.r, classColor.g, classColor.b);
		else
			buttonString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		buttonString:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function GuildRoster_SetView(view)
	local numColumns = #GUILD_ROSTER_COLUMNS[view];
	local stringsInfo = { };
	local stringOffset = 0;
	local haveIcon, haveBar;
	
	-- set up columns
	for columnIndex = 1, GUILD_ROSTER_MAX_COLUMNS do
		local columnButton = _G["GuildRosterColumnButton"..columnIndex];
		local columnType = GUILD_ROSTER_COLUMNS[view][columnIndex];
		if ( columnType ) then
			local columnData = GUILD_ROSTER_COLUMN_DATA[columnType];			
			columnButton:SetText(columnData.text);
			WhoFrameColumn_SetWidth(columnButton, columnData.width);
			columnButton:Show();
			-- by default the sort type should be the same as the column type
			if ( columnData.sortType ) then
				columnButton.sortType = columnData.sortType;
			else
				columnButton.sortType = columnType;
			end
			if ( columnData.hasIcon ) then
				haveIcon = true;
			else	
				-- store string data for processing
				columnData["stringOffset"] = stringOffset;
				table.insert(stringsInfo, columnData);
			end
			stringOffset = stringOffset + columnData.width - 2;
			haveBar = haveBar or columnData.hasBar;
		else
			columnButton:Hide();
		end
	end	
	
	-- process the button strings
	local buttons = GuildRosterContainer.buttons;	
	local button, fontString;
	for buttonIndex = 1, #buttons do
		button = buttons[buttonIndex];
		for stringIndex = 1, GUILD_ROSTER_MAX_STRINGS do
			fontString = button["string"..stringIndex];
			local stringData = stringsInfo[stringIndex];
			if ( stringData ) then
				-- want strings a little inside the columns, 6 pixels from the left and 8 from the right
				fontString:SetPoint("LEFT", stringData.stringOffset + 6, 0);
				fontString:SetWidth(stringData.width - 14);
				fontString:SetJustifyH(stringData.stringJustify);				
				fontString:Show();				
			else
				fontString:Hide();
			end
		end
		if ( haveIcon ) then
			button.icon:Show();
		else
			button.icon:Hide();
		end
		if ( haveBar ) then
			button.barLabel:Show();
			-- button.barTexture:Show(); -- shown status determined in GuildRoster_Update 
		else
			button.barLabel:Hide();
			button.barTexture:Hide();		
		end
	end
	
	currentGuildView = view;
end

function GuildRosterViewDropdown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRosterViewDropdown_Initialize);
	UIDropDownMenu_SetWidth(GuildRosterViewDropdown, 150);
end

function GuildRosterViewDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = GuildRosterViewDropdown_OnClick;
	
	info.text = "Player Status";
	info.value = "playerStatus";
	UIDropDownMenu_AddButton(info);
	info.text = "Guild Status";
	info.value = "guildStatus";
	UIDropDownMenu_AddButton(info);	
	info.text = "Contribution (Lifetime)";
	info.value = "contribution";
	UIDropDownMenu_AddButton(info);
	info.text = "PvE Points (Lifetime)";
	info.value = "pve";
	UIDropDownMenu_AddButton(info);
	info.text = "PvP Points (Lifetime)";
	info.value = "pvp";
	UIDropDownMenu_AddButton(info);
	info.text = "Achievements";
	info.value = "achievement";
	UIDropDownMenu_AddButton(info);	
	
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
end

function GuildRosterViewDropdown_OnClick(self)
	GuildRoster_SetView(self.value);
	GuildRoster_Update();
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
end

--================================================================================================
local _GuildClass = { "WARRIOR", "SHAMAN", "PALADIN", "ROGUE", "DEATHKNIGHT", "PRIEST", "WARLOCK", "DRUID", "HUNTER", "MAGE" }
local _GuildNote = { "A random note", "Something", "Nothing", "" }
local _GuildRank = { "Initiate", "Member", "Veteran", "Officer", "Grand Poobah" }
local _GuildNames = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whisky", "Xray", "Yankee", "Zulu" }
local _GuildZones = { "Ashenvale", "Durotar", "Feralas", "Loch Modan", "Winterspring" }
_GuildMembers = { };
local _highestContribution = 0;

local _GuildSortType;
local _GuildSortAsc;
function _SortFakeGuild(sortType)
	local targetIndex;
	if ( sortType == _GuildSortType ) then
		_GuildSortAsc = not _GuildSortAsc;
	end
	for i = 1, #_GuildMembers - 1 do
		targetIndex = i;
		for j = i + 1, #_GuildMembers do
			if ( _GuildSortAsc ) then
				if ( _GuildMembers[targetIndex][sortType] > _GuildMembers[j][sortType] ) then
					targetIndex = j;
				end
			else
				if ( _GuildMembers[targetIndex][sortType] < _GuildMembers[j][sortType] ) then
					targetIndex = j;
				end				
			end
		end
		if ( targetIndex ~= i ) then
			_GuildMembers[i], _GuildMembers[targetIndex] = _GuildMembers[targetIndex], _GuildMembers[i];
		end
	end
	_GuildSortType = sortType;
end

function _SetupFakeGuild(numMembers)	
	local rank;
	local haveGM;
	for i = 1, numMembers do
		local guildMember = { };
		guildMember["name"] = _GuildNames[i];
		rank = math.random(5);
		if ( rank == 5 ) then
			if ( haveGM ) then
				rank = math.random(4);
			else
				haveGM = true;
			end
		end
		guildMember["rank"] = rank;
		guildMember["rankName"] = _GuildRank[rank];
		guildMember["note"] = _GuildNote[math.random(#_GuildNote)];
		guildMember["class"] = _GuildClass[math.random(#_GuildClass)];
		guildMember["level"] = math.random(80);		
		guildMember["honor"] = math.random(10000);
		guildMember["conquest"] = math.random(10000);
		guildMember["achievement"] = math.random(10000);
		guildMember["valor"] = math.random(10000);
		guildMember["hero"] = math.random(10000);
		guildMember["contribution"] = math.random(10000);
		guildMember["zone"] = _GuildZones[math.random(#_GuildZones)];
		if ( math.random(2) == 2 ) then
			guildMember["online"] = true;
		end
		table.insert(_GuildMembers, guildMember);
	end
	-- rank contributions
	_GuildMembers[2]["contribution"] = 0;
	_SortFakeGuild("contribution");
	_highestContribution = _GuildMembers[1]["contribution"];
	for i = 1, numMembers do
		_GuildMembers[i]["contributionRank"] = i;
	end
end

function _GuildGetHighestContribution()
	return _highestContribution;
end