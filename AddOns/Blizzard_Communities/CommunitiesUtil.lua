
CommunitiesUtil = {};

function CommunitiesUtil.GetMemberRGB(memberInfo)
	if memberInfo.classID then
		local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
		if classInfo then
			local classColor = RAID_CLASS_COLORS[classInfo.classFile];
			return classColor.r, classColor.g, classColor.b;
		end
	end
	
	return BATTLENET_FONT_COLOR:GetRGB();
end

function CommunitiesUtil.SortClubs(clubs)
	table.sort(clubs, function(lhsClub, rhsClub)
		if lhsClub.clubType == Enum.ClubType.Guild or rhsClub.clubType == Enum.ClubType.Guild then
			return lhsClub.clubType == Enum.ClubType.Guild;
		elseif lhsClub.favoriteTimeStamp ~= nil and rhsClub.favoriteTimeStamp ~= nil then
			return lhsClub.favoriteTimeStamp < rhsClub.favoriteTimeStamp;
		elseif lhsClub.favoriteTimeStamp ~= nil or rhsClub.favoriteTimeStamp ~= nil then
			return lhsClub.favoriteTimeStamp ~= nil;
		elseif lhsClub.joinTime ~= nil and rhsClub.joinTime ~= nil then
			return lhsClub.joinTime > rhsClub.joinTime;
		else
			return lhsClub.joinTime ~= nil;
		end
	end);
end

local PRESENCE_SORT_ORDER = {
	[Enum.ClubMemberPresence.Online] = 1,
	[Enum.ClubMemberPresence.Away] = 2,
	[Enum.ClubMemberPresence.Busy] = 3,
	[Enum.ClubMemberPresence.Offline] = 4,
	[Enum.ClubMemberPresence.Unknown] = 5,
};

local function CompareMembers(lhsMemberInfo, rhsMemberInfo)
	if lhsMemberInfo.presence == rhsMemberInfo.presence then
		return lhsMemberInfo.memberId < rhsMemberInfo.memberId;
	else
		return PRESENCE_SORT_ORDER[lhsMemberInfo.presence] < PRESENCE_SORT_ORDER[rhsMemberInfo.presence];
	end
end

function CommunitiesUtil.SortMemberInfo(memberInfoArray)
	table.sort(memberInfoArray, CompareMembers);
	return memberInfoArray;
end

function CommunitiesUtil.GetMemberInfo(clubId, streamId)
	local memberIds = clubId and C_Club.GetClubMembers(clubId, streamId) or {};

	local memberInfoArray = {};

	for _, memberId in ipairs(memberIds) do
		table.insert(memberInfoArray, C_Club.GetMemberInfo(clubId, memberId));
	end

	return memberInfoArray;
end

-- Leave streamId as nil if you want all members in the club
function CommunitiesUtil.GetAndSortMemberInfo(clubId, streamId)
	return CommunitiesUtil.SortMemberInfo(CommunitiesUtil.GetMemberInfo(clubId, streamId));
end

function CommunitiesUtil.SortMemberInfoWithOverride(memberInfoArray, overrideCompare)
	table.sort(memberInfoArray, function (lhsMemberInfo, rhsMemberInfo)
		local overrideCompareResult = overrideCompare(lhsMemberInfo, rhsMemberInfo);
		if overrideCompareResult == nil then
			return CompareMembers(lhsMemberInfo, rhsMemberInfo);
		else
			return overrideCompareResult;
		end
	end);
end

function CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()
	return CommunitiesUtil.DoesOtherCommunityHaveUnreadMessages(nil);
end

function CommunitiesUtil.DoesOtherCommunityHaveUnreadMessages(ignoreClubId)
	local clubs = C_Club.GetSubscribedClubs();
	for i, club in ipairs(clubs) do
		if club.clubId ~= ignoreClubId then
			if CommunitiesUtil.DoesCommunityHaveUnreadMessages(club.clubId) then
				return true;
			end
		end
	end
end

function CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubId)
	return CommunitiesUtil.DoesCommunityHaveOtherUnreadMessages(clubId, nil);
end

function CommunitiesUtil.DoesCommunityHaveOtherUnreadMessages(clubId, ignoreStreamId)
	for i, stream in ipairs(C_Club.GetStreams(clubId)) do
		if stream.streamId ~= ignoreStreamId then
			if CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, stream.streamId) then
				return true;
			end
		end
	end
end

function CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, streamId)
	return C_Club.GetStreamViewMarker(clubId, streamId) ~= nil;
end
