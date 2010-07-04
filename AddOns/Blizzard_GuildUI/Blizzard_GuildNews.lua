
function GuildNewsFrame_OnLoad()
	GuildFrame_RegisterPanel("GuildNewsFrame");
	GuildNewsMessageFrame:SetInsertMode("top");
	GuildNewsMessageFrame:SetSpacing(3);
	
	_SetupFakeNews();
	_LoadFakeNews();
end

function GuildNewsScrollBar_Update()
	local scrollBar = GuildNewsMessageFrameScrollBar;
	local displayedLines = GuildNewsMessageFrame:GetNumLinesDisplayed();
	displayedLines = 19;
	local totalLines = GuildNewsMessageFrame:GetNumMessages();
	
	local offset = totalLines - displayedLines;
	for i = 0, 19 do
		GuildNewsMessageFrame:SetScrollOffset(offset);
		if ( GuildNewsMessageFrame:AtTop() ) then
			break;
		end
		offset = offset + 1;
	end	
	
	scrollBar:SetMinMaxValues(0, offset);
	scrollBar:SetValue(0);
	_G[scrollBar:GetName().."ThumbTexture"]:Show();	
end

function GuildNewsScrollBar_OnValueChanged(self, value)
	GuildNewsMessageFrame:SetScrollOffset(value);
end

--================================================================================================
local _GuildNames = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whisky", "Xray", "Yankee", "Zulu" }
_GuildNews = { };

function _LoadFakeNews()
	for i = 1, #_GuildNews do
		if ( _GuildNews[i].isHeader ) then
			GuildNewsMessageFrame:AddMessage(_GuildNews[i].text, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		else
			--GuildNewsMessageFrame:AddMessage(_GuildNews[i].text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			GuildNewsMessageFrame:AddMessage(_GuildNews[i].text, 0.9, 0.9, 0.9);
		end
	end
end

function _SetupFakeNews()
	local isSticky = true;
	local text;
	for i = 1, 200 do
		local guildMember = { };
		local header = true;
		if ( i == 60 ) then
			text = "Wednesday 5/25"
		elseif ( i == 120 ) then
			text = "Tuesday 5/24"
		elseif ( i == 180 ) then
			text = "Monday 5/23"
		else
			header = nil;
			if  ( math.random(2) == 2 ) then	-- link
				text = i.."- ".._GuildNames[math.random(26)].." has looted \124cff0070dd\124Hitem:8190:0:0:0:0:0:0:111794285:20\124h[Hanzo Sword]\124h\124r"
			else
				text = i.."- ".._GuildNames[math.random(26)].." has done something"
			end
			if ( math.random(10) == 10 ) then			-- double line
				text = text.." and then promptly forgot all about it"
			end		
		end
		guildMember["text"] = text;		
		guildMember["isHeader"] = header;
		guildMember["isSticky"] = isSticky;
		table.insert(_GuildNews, guildMember);
		if ( math.random(5) == 5 ) then
			isSticky = false;
		end
	end
end