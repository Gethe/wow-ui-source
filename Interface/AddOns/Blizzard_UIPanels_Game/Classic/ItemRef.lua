function SetItemRef(link, text, button, frame)
	local contextData = { button = button, frame = frame };
	local response = LinkUtil.ProcessLink(link, text, contextData);

	if response == LinkProcessorResponse.Handled then
		return;
	end

	-- Links that are unhandled or request a fallthrough to default logic
	-- should be routed through the ItemRef tooltip.

	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end

function GetFixedLink(text, quality)
	local startLink = strfind(text, "|H");
	if ( not strfind(text, "|c") ) then
		if ( quality ) then
			return (gsub(text, "(|H.+|h.+|h)", ITEM_QUALITY_COLORS[quality].hex.."%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 6) == "quest" ) then
			--We'll always color it yellow. We really need to fix this for Cata. (It will appear the correct color in the chat log)
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "achievement" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 7) == "talent" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff4e96f7%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 6) == "trade" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 8) == "enchant" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 13) == "instancelock" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff8000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 8) == "journal" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff66bbff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 14) == "battlePetAbil" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff4e96f7%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 10) == "battlepet" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd200%1|r", 1)); -- s_defaultColorString (yellow)
		elseif ( strsub(text, startLink + 2, startLink + 12) == "garrmission" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 17) == "transmogillusion" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 19) == "transmogappearance" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "transmogset" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		end
	end
	--Nothing to change.
	return text;
end

function GetBattlePetAbilityHyperlink(abilityID, maxHealth, power, speed)
	local id, name = C_PetBattles.GetAbilityInfoByID(abilityID);
	if not name then
		GMError("Attempt to link ability when we don't have record.");
		return "";
	end

	return ("|cff4e96f7%s|r"):format(LinkUtil.FormatLink(LinkTypes.BattlePetAbility, name, abilityID, maxHealth or 100, power or 0, speed or 0));
end

function GetPlayerLink(characterName, linkDisplayText, lineID, chatType, chatTarget)
	-- Use simplified link if possible
	if lineID or chatType or chatTarget then
		return LinkUtil.FormatLink(LinkTypes.Player, linkDisplayText, characterName, lineID or 0, chatType or 0, chatTarget or "");
	else
		return LinkUtil.FormatLink(LinkTypes.Player, linkDisplayText, characterName);
	end
end

function GetGMLink(gmName, linkDisplayText, lineID)
	if lineID then
		return LinkUtil.FormatLink(LinkTypes.PlayerGM, linkDisplayText, gmName, lineID or 0);
	else
		return LinkUtil.FormatLink(LinkTypes.PlayerGM, linkDisplayText, gmName);
	end
end

local function SanitizeCommunityData(clubId, streamId, epoch, position)
	if type(clubId) == "number" then
		clubId = ("%.f"):format(clubId);
	end
	if type(streamId) == "number" then
		streamId = ("%.f"):format(streamId);
	end
	epoch = ("%.f"):format(epoch);
	position = ("%.f"):format(position);

	return clubId, streamId, epoch, position;
end

function GetBNPlayerCommunityLink(playerName, linkDisplayText, bnetIDAccount, clubId, streamId, epoch, position)
	clubId, streamId, epoch, position = SanitizeCommunityData(clubId, streamId, epoch, position);
	return LinkUtil.FormatLink(LinkTypes.BNPlayerCommunity, linkDisplayText, playerName, bnetIDAccount, clubId, streamId, epoch, position);
end

function GetPlayerCommunityLink(playerName, linkDisplayText, clubId, streamId, epoch, position)
	clubId, streamId, epoch, position = SanitizeCommunityData(clubId, streamId, epoch, position);
	return LinkUtil.FormatLink(LinkTypes.PlayerCommunity, linkDisplayText, playerName, clubId, streamId, epoch, position);
end

function GetClubTicketLink(ticketId, clubName, clubType)
	local link = LinkUtil.FormatLink(LinkTypes.ClubTicket, CLUB_INVITE_HYPERLINK_TEXT:format(clubName), ticketId);
	if clubType == Enum.ClubType.BattleNet then
		return BATTLENET_FONT_COLOR:WrapTextInColorCode(link);
	else 
		return NORMAL_FONT_COLOR:WrapTextInColorCode(link);
	end
end

function SplitLink(link)
	return link:match("^|H(.+)|h(.*)|h$");
end