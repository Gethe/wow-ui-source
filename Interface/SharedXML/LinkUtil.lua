function ExtractHyperlinkString(linkString)
	local preString, hyperlinkString, postString = linkString:match("^(.*)|H(.+)|h(.*)$");
	return preString ~= nil, preString, hyperlinkString, postString;
end

function ExtractLinkData(link)
	return string.match(link, "(.-):(.*)");
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
	local linkType, linkData = ExtractLinkData(link);
	if linkType:match("|Hachievement") then
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