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
	[Enum.CalendarEventType.PvP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};

local icon_table = {
	motd = { width = 16, height = 11, texture = "Interface\\GuildFrame\\GuildExtra", texcoords={0.56640625, 0.59765625, 0.86718750, 0.95312500}},
	[Enum.CalendarEventType.PvP] = { width = 14, height = 14, texture = "Interface\\Calendar\\UI-Calendar-Event-PVP", texcoords={0, 1, 0, 1}},
	[Enum.CalendarEventType.Meeting] = { width = 14, height = 14, texture = "Interface\\Calendar\\MeetingIcon", texcoords={0, 1, 0, 1}},
	[Enum.CalendarEventType.Other] = { width = 14, height = 14, texture = "Interface\\Calendar\\UI-Calendar-Event-Other", texcoords={0, 1, 0, 1}},
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

function SetLargeGuildTabardTextures(unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	-- texure dimensions are 1024x1024, icon dimensions are 64x64
	local emblemSize, columns, offset;
	if ( emblemTexture ) then
		emblemSize = 64 / 1024;
		columns = 16
		offset = 0;
		emblemTexture:SetTexture("Interface\\GuildFrame\\GuildEmblemsLG_01");
	end
	local hasEmblem = SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData);
	emblemTexture:SetWidth(hasEmblem and (emblemTexture:GetHeight() * (7 / 8)) or emblemTexture:GetHeight());
end

function SetSmallGuildTabardTextures(unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	-- texure dimensions are 256x256, icon dimensions are 16x16, centered in 18x18 cells
	local emblemSize, columns, offset;
	if ( emblemTexture ) then
		emblemSize = 18 / 256;
		columns = 14;
		offset = 1 / 256;
		emblemTexture:SetTexture("Interface\\GuildFrame\\GuildEmblems_01");
	end
	SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData);
end

function SetDoubleGuildTabardTextures(unit, leftEmblemTexture, rightEmblemTexture, backgroundTexture, borderTexture, tabardData)
	if ( leftEmblemTexture and rightEmblemTexture ) then
		SetGuildTabardTextures(nil, nil, nil, unit, leftEmblemTexture, backgroundTexture, borderTexture, tabardData);
		rightEmblemTexture:SetTexture(leftEmblemTexture:GetTexture());
		rightEmblemTexture:SetVertexColor(leftEmblemTexture:GetVertexColor());
	end
end

function SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	local backgroundColor, borderColor, emblemColor, emblemFileID, emblemIndex;
	tabardData = tabardData or C_GuildInfo.GetGuildTabardInfo(unit);
	if(tabardData) then
		backgroundColor = tabardData.backgroundColor;
		borderColor = tabardData.borderColor;
		emblemColor = tabardData.emblemColor;
		emblemFileID = tabardData.emblemFileID;
		emblemIndex = tabardData.emblemStyle;
	end
	if (emblemFileID) then
		if (backgroundTexture) then
			backgroundTexture:SetVertexColor(backgroundColor:GetRGB());
		end
		if (borderTexture) then
			borderTexture:SetVertexColor(borderColor:GetRGB());
		end
		if (emblemSize) then
			if (emblemIndex) then
				local xCoord = mod(emblemIndex, columns) * emblemSize;
				local yCoord = floor(emblemIndex / columns) * emblemSize;
				emblemTexture:SetTexCoord(xCoord + offset, xCoord + emblemSize - offset, yCoord + offset, yCoord + emblemSize - offset);
			end
			emblemTexture:SetVertexColor(emblemColor:GetRGB());
		elseif (emblemTexture) then
			emblemTexture:SetTexture(emblemFileID);
			emblemTexture:SetVertexColor(emblemColor:GetRGB());
		end

		return true;
	else
		-- tabard lacks design
		if (backgroundTexture) then
			backgroundTexture:SetVertexColor(0.2245, 0.2088, 0.1794);
		end
		if (borderTexture) then
			borderTexture:SetVertexColor(0.2, 0.2, 0.2);
		end
		if (emblemTexture) then
			if (emblemSize) then
				if (emblemSize == 18 / 256) then
					emblemTexture:SetTexture("Interface\\GuildFrame\\GuildLogo-NoLogoSm");
				else
					emblemTexture:SetTexture("Interface\\GuildFrame\\GuildLogo-NoLogo");
				end
				emblemTexture:SetTexCoord(0, 1, 0, 1);
				emblemTexture:SetVertexColor(1, 1, 1, 1);
			else
				emblemTexture:SetTexture("");
			end
		end

		return false;
	end
end
