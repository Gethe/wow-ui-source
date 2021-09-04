NEWS_MOTD = -1;				-- pseudo category
NEWS_GUILD_ACHIEVEMENT = 0;
NEWS_PLAYER_ACHIEVEMENT = 1;
NEWS_DUNGEON_ENCOUNTER = 2;
NEWS_ITEM_LOOTED = 3;
NEWS_ITEM_CRAFTED = 4;
NEWS_ITEM_PURCHASED = 5;
NEWS_GUILD_LEVEL = 6;
NEWS_GUILD_CREATE = 7;
NEWS_LEGENDARY_LOOTED = 8;
NEWS_GUILD_EVENT = 9;

GUILD_EVENT_TEXTURES = {
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};

local icon_table = {
	motd = { width = 16, height = 11, texture = "Interface\\GuildFrame\\GuildExtra", texcoords={0.56640625, 0.59765625, 0.86718750, 0.95312500}},
	[CALENDAR_EVENTTYPE_PVP] = { width = 14, height = 14, texture = "Interface\\Calendar\\UI-Calendar-Event-PVP", texcoords={0, 1, 0, 1}},
	[CALENDAR_EVENTTYPE_MEETING] = { width = 14, height = 14, texture = "Interface\\Calendar\\MeetingIcon", texcoords={0, 1, 0, 1}},
	[CALENDAR_EVENTTYPE_OTHER] = { width = 14, height = 14, texture = "Interface\\Calendar\\UI-Calendar-Event-Other", texcoords={0, 1, 0, 1}},
	event = { width = 14, height = 14, texcoords={0, 1, 0, 1}},
	news = { width = 13, height = 11, texture = "Interface\\GuildFrame\\GuildFrame", texcoords={0.41406250, 0.42675781, 0.96875000, 0.99023438}},
}

function GuildNewsButton_SetIcon( button, icon_type, override_texture )
	if button.icon.type ~= icon_type then
		button.icon.type = icon_type;
		local icon = icon_table[icon_type]
		if icon then
			button.icon:SetSize(icon.width, icon.height);
			button.icon:SetTexture( icon.texture or override_texture );
			button.icon:SetTexCoord(icon.texcoords[1], icon.texcoords[2], icon.texcoords[3], icon.texcoords[4]);
		end
	end
	button.icon:Show();
end

function GuildNewsButton_SetText( button, text_color, text, ...)
	button.text:SetFormattedText(text, ...);
	button.text:SetTextColor(text_color.r, text_color.g, text_color.b);
end

function GuildNewsButton_SetMOTD( button, text )
	button.text:SetPoint("LEFT", 24, 0);
	GuildNewsButton_SetIcon(button,"motd");
	GuildNewsButton_SetText(button, HIGHLIGHT_FONT_COLOR, GUILD_NEWS_MOTD, text);
	button.index = nil;
	button.newsType = NEWS_MOTD;
end

local guildDifficultyTexture = "Interface\\GuildFrame\\GuildDifficulty"

function GuildNewsButton_SetNews( button, news_id )
	local newsInfo = C_GuildInfo.GetGuildNewsInfo(news_id);
	if newsInfo then
		button.newsInfo = newsInfo;
		if newsInfo.isHeader then
			button.text:SetPoint("LEFT", 14, 0);
			GuildNewsButton_SetText( button, NORMAL_FONT_COLOR, GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[newsInfo.weekday + 1], newsInfo.day + 1, newsInfo.month + 1);
			button.header:Show();
			button:Disable();
		else
			local text1, text2;

			button.text:SetPoint("LEFT", 24, 0);
			if newsInfo.isSticky then
				GuildNewsButton_SetIcon(button, "news");
			else
				button.dash:Show();
			end
			text1 = newsInfo.whoText or UNKNOWN;
			button.index = news_id;
			button.newsType = newsInfo.newsType;
			button.id = newsInfo.newsDataID;
			-- Bug 356148: For NEWS_ITEM types, data2 has the item upgrade ID
			button.data2 = newsInfo.data[2];
			if newsInfo.whatText then
				if newsInfo.newsType == NEWS_ITEM_LOOTED or newsInfo.newsType == NEWS_ITEM_CRAFTED or newsInfo.newsType == NEWS_ITEM_PURCHASED or newsInfo.newsType == NEWS_LEGENDARY_LOOTED then
					-- item link is already filled out from GetGuildNewsInfo
					text2 = newsInfo.whatText;
				elseif newsInfo.newsType == NEWS_PLAYER_ACHIEVEMENT then
					text2 = ACHIEVEMENT_COLOR_CODE.."["..newsInfo.whatText.."]|r";
				elseif newsInfo.newsType == NEWS_GUILD_ACHIEVEMENT then
					text1 = ACHIEVEMENT_COLOR_CODE.."["..newsInfo.whatText.."]|r";	-- only using achievement name
				elseif newsInfo.newsType == NEWS_DUNGEON_ENCOUNTER then
					local difficulty = newsInfo.data[3];
					local displayHeroic, displayMythic = select(5, GetDifficultyInfo(difficulty));
					local formatString;
					if displayHeroic then
						formatString = GUILD_NEWS_DUNGEON_ENCOUNTER_HEROIC;
					elseif displayMythic then
						formatString = GUILD_NEWS_DUNGEON_ENCOUNTER_MYTHIC;
					else
						formatString = GUILD_NEWS_DUNGEON_ENCOUNTER_NORMAL;
					end
					text2 = formatString:format(newsInfo.whatText);
				end
			elseif newsInfo.newsType ~= NEWS_GUILD_CREATE then
				-- no right-click menu or tooltip for unresolved news items
				button.index = nil;
				button.newsType = nil;
				text2 = UNKNOWN;
			end
		
			GuildNewsButton_SetText( button, HIGHLIGHT_FONT_COLOR, _G["GUILD_NEWS_FORMAT"..newsInfo.newsType], text1, text2);
		end
	end

	button.isEvent = false;
end
