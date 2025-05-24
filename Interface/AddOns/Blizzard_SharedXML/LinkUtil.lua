
LinkUtil = {};

function LinkUtil.FormatLink(linkType, linkDisplayText, ...)
	local linkFormatTable = { ("|H%s"):format(linkType), ... };
	local returnLink = table.concat(linkFormatTable, ":");
	if linkDisplayText then
		return returnLink .. ("|h%s|h"):format(linkDisplayText);
	else
		return returnLink .. "|h";
	end
end

function LinkUtil.SplitLinkData(linkData)
	return string.match(linkData, "(.-):(.*)");
end

function LinkUtil.SplitLink(link) -- returns linkText and displayText
	return link:match("^|H(.+)|h(.*)|h$");
end

function LinkUtil.SplitLinkOptions(linkOptions)
	return string.split(":", linkOptions);
end

-- Extract the first link from the text given, ignoring leading and trailing characters.
-- returns linkType, linkOptions, displayText
function LinkUtil.ExtractLink(text)
	-- linkType: |H([^:]*): matches everything that's not a colon, up to the first colon.
	-- linkOptions: ([^|]*)|h matches everything that's not a |, up to the first |h.
	-- displayText: (.*)|h matches everything up to the second |h.
	-- Ex: |cffffffff|Htype:a:b:c:d|htext|h|r becomes type, a:b:c:d, text
	return string.match(text, [[|H([^:]*):([^|]*)|h(.*)|h]]);
end

function LinkUtil.ExtractNydusLink(text)
	-- Extracts ex. "urlIndex:24" from strings like "|HurlIndex:24|h"
	return string.match(text, [[|H([^|]*)|h]]);
end

function LinkUtil.IsLinkType(link, matchLinkType)
	local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link);
	return linkType == matchLinkType;
end


function ExtractHyperlinkString(linkString)
	local preString, hyperlinkString, postString = linkString:match("^(.*)|H(.+)|h(.*)$");
	return preString ~= nil, preString, hyperlinkString, postString;
end

function ExtractQuestRewardID(linkString)
	return linkString:match("^questreward:(%d+)$");
end

function GetItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end

function GetAchievementInfoFromHyperlink(link)
	local linkType, linkData = LinkUtil.SplitLinkData(link);
	if linkType and linkType:match("|Hachievement") then
		local achievementID, _, complete = strsplit(":", linkData);
		return tonumber(achievementID), complete == "1";
	end
end

function GetURLIndexAndLoadURL(self, link)
	local linkType, index = string.split(":", link);
	if ( linkType == "urlIndex" ) then
		LoadURLIndex(tonumber(index));
		return true;
	else
		return false;
	end
end

function GetURLIndexAndLoadURLWithSound(self, link)
	if ( GetURLIndexAndLoadURL(self, link) ) then 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function GetPlayerLink(characterName, linkDisplayText, lineID, chatType, chatTarget)
	-- Use simplified link if possible
	if lineID or chatType or chatTarget then
		return LinkUtil.FormatLink("player", linkDisplayText, characterName, lineID or 0, chatType or 0, chatTarget or "");
	else
		return LinkUtil.FormatLink("player", linkDisplayText, characterName);
	end
end