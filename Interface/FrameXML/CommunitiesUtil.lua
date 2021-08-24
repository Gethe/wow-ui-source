CommunitiesUtil = {};

function CommunitiesUtil.GetMemberRGB(memberInfo)
	--[[
	if memberInfo.classID then
		local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
		if classInfo then
			local classColor = RAID_CLASS_COLORS[classInfo.classFile];
			return classColor.r, classColor.g, classColor.b;
		end
	end
	--]]

	return BATTLENET_FONT_COLOR:GetRGB();
end

function CommunitiesUtil.SortClubs(clubs)
	table.sort(clubs, function(lhsClub, rhsClub)
		if lhsClub.favoriteTimeStamp ~= nil and rhsClub.favoriteTimeStamp ~= nil then
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

local STREAM_TYPE_SORT_ORDER = {
	[Enum.ClubStreamType.General] = 1,
	[Enum.ClubStreamType.Other] = 2,
};

local function CompareStreams(lhsStream, rhsStream)
	if lhsStream.streamType ~= rhsStream.streamType then
		return STREAM_TYPE_SORT_ORDER[lhsStream.streamType] < STREAM_TYPE_SORT_ORDER[rhsStream.streamType];
	else
		return lhsStream.creationTime < rhsStream.creationTime;
	end
end

function CommunitiesUtil.SortStreams(streams)
	table.sort(streams, CompareStreams);
end

local PRESENCE_SORT_ORDER = {
	[Enum.ClubMemberPresence.Online] = 1,
	[Enum.ClubMemberPresence.Away] = 2,
	[Enum.ClubMemberPresence.Busy] = 3,
	[Enum.ClubMemberPresence.Offline] = 4,
	[Enum.ClubMemberPresence.Unknown] = 5,
};

local function CompareMembers(lhsMemberInfo, rhsMemberInfo)
	if lhsMemberInfo.presence ~= rhsMemberInfo.presence then
		return PRESENCE_SORT_ORDER[lhsMemberInfo.presence] < PRESENCE_SORT_ORDER[rhsMemberInfo.presence];
	elseif lhsMemberInfo.level and rhsMemberInfo.level and lhsMemberInfo.level ~= rhsMemberInfo.level then
		return lhsMemberInfo.level > rhsMemberInfo.level;
	elseif lhsMemberInfo.guildRankOrder and rhsMemberInfo.guildRankOrder and lhsMemberInfo.guildRankOrder ~= rhsMemberInfo.guildRankOrder then
		return lhsMemberInfo.guildRankOrder < rhsMemberInfo.guildRankOrder;
	elseif lhsMemberInfo.role ~= rhsMemberInfo.role then
		return lhsMemberInfo.role < rhsMemberInfo.role;
	elseif lhsMemberInfo.name and rhsMemberInfo.name then
		return lhsMemberInfo.name < rhsMemberInfo.name;
	else
		return lhsMemberInfo.memberId < rhsMemberInfo.memberId;
	end
end

local function GenerateCompareMemberLambda(clubId)
	local clubInfo = clubId and C_Club.GetClubInfo(clubId);
	if clubInfo then
		local function CompareBNetMembers(lhsMemberInfo, rhsMemberInfo)
			if lhsMemberInfo.presence ~= rhsMemberInfo.presence then
				return PRESENCE_SORT_ORDER[lhsMemberInfo.presence] < PRESENCE_SORT_ORDER[rhsMemberInfo.presence];
			elseif lhsMemberInfo.role ~= rhsMemberInfo.role then
				return lhsMemberInfo.role < rhsMemberInfo.role;
			else
				local nameComparison = C_Club.CompareBattleNetDisplayName(clubId, lhsMemberInfo.memberId, rhsMemberInfo.memberId);
				if nameComparison ~= 0 then
					return nameComparison < 0;
				else
					return lhsMemberInfo.memberId < rhsMemberInfo.memberId;
				end
			end
		end

		return CompareBNetMembers;
	else
		return CompareMembers;
	end
end

function CommunitiesUtil.SortMemberInfo(clubId, memberInfoArray)
	table.sort(memberInfoArray, GenerateCompareMemberLambda(clubId));
	return memberInfoArray;
end

function CommunitiesUtil.GetMemberIdsSortedByName(clubId, streamId)
	return clubId and C_Club.GetClubMembers(clubId, streamId) or {};
end

function CommunitiesUtil.GetMemberInfo(clubId, memberIds)
	local memberInfoArray = {};

	for _, memberId in ipairs(memberIds) do
		local memberInfo = C_Club.GetMemberInfo(clubId, memberId);
		if memberInfo then
			table.insert(memberInfoArray, memberInfo);
		end
	end

	return memberInfoArray;
end

function CommunitiesUtil.GetMemberInfoLookup(memberInfoArray)
	local memberInfoLookup = {};

	for _, memberInfo in ipairs(memberInfoArray) do
		memberInfoLookup[memberInfo.memberId] = memberInfo;
	end

	return memberInfoLookup;
end

function CommunitiesUtil.GetOnlineMembers(memberInfoArray)
	local onlineMemberInfoArray = {};
	for _, memberInfo in ipairs(memberInfoArray) do
		local couldBeOffline = memberInfo.presence == Enum.ClubMemberPresence.Offline or memberInfo.presence == Enum.ClubMemberPresence.Unknown;
		if not couldBeOffline then
			table.insert(onlineMemberInfoArray, memberInfo);
		end
	end

	return onlineMemberInfoArray;
end

function CommunitiesUtil.SortMembersByList(memberInfoLookup, memberIds)
	local memberInfoArray = {};

	for _, memberId in ipairs(memberIds) do
		local memberInfo = memberInfoLookup[memberId];
		if memberInfo then
			table.insert(memberInfoArray, memberInfo);
		end
	end

	return memberInfoArray;
end

-- Leave streamId as nil if you want all members in the club
function CommunitiesUtil.GetAndSortMemberInfo(clubId, streamId, filterOffline)
	local memberIdArray = CommunitiesUtil.GetMemberIdsSortedByName(clubId, streamId);
	local memberInfoArray = CommunitiesUtil.GetMemberInfo(clubId, memberIdArray);
	if filterOffline then
		memberInfoArray = CommunitiesUtil.GetOnlineMembers(memberInfoArray);
	end
	memberInfoArray = CommunitiesUtil.SortMemberInfo(clubId, memberInfoArray);
	return memberInfoArray;
end

function CommunitiesUtil.SortMemberInfoWithOverride(clubId, memberInfoArray, overrideCompare)
	local baseCompare = GenerateCompareMemberLambda(clubId);
	table.sort(memberInfoArray, function (lhsMemberInfo, rhsMemberInfo)
		local overrideCompareResult = overrideCompare(lhsMemberInfo, rhsMemberInfo);
		if overrideCompareResult == nil then
			return baseCompare(lhsMemberInfo, rhsMemberInfo);
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
	local streamToNotificationSetting = CommunitiesUtil.GetStreamNotificationSettingsLookup(clubId);
	for i, stream in ipairs(C_Club.GetStreams(clubId)) do
		-- TODO:: Support mention-based notifications once we have support for mentions.
		if stream.streamId ~= ignoreStreamId and streamToNotificationSetting[stream.streamId] == Enum.ClubStreamNotificationFilter.All then
			if CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, stream.streamId) then
				return true;
			end
		end
	end
end

function CommunitiesUtil.GetStreamNotificationSettingsLookup(clubId)
	local streamNotificationSettings = C_Club.GetClubStreamNotificationSettings(clubId);
	local streamToNotificationSetting = {};
	for i, streamNotificationSetting in ipairs(streamNotificationSettings) do
		streamToNotificationSetting[streamNotificationSetting.streamId] = streamNotificationSetting.filter;
	end

	return streamToNotificationSetting;
end

function CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, streamId)
	return C_Club.GetStreamViewMarker(clubId, streamId) ~= nil;
end

function CommunitiesUtil.CanKickClubMember(clubPrivileges, memberInfo)
	return tContains(clubPrivileges.kickableRoleIds, memberInfo.role);
end

function CommunitiesUtil.ClearAllUnreadNotifications(clubId)
	local streams = C_Club.GetStreams(clubId);
	for i, stream in ipairs(streams) do
		C_Club.AdvanceStreamViewMarker(clubId, stream.streamId);
	end
end

function CommunitiesUtil.OpenInviteDialog(clubId, streamId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return;
	end

	local privileges = C_Club.GetClubPrivileges(clubId);
	if privileges.canCreateTicket then
		StaticPopup_Show("INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK", nil, nil, { clubId = clubId, streamId = streamId, });
	else
		StaticPopup_Show("INVITE_COMMUNITY_MEMBER", nil, nil, { clubId = clubId, streamId = streamId, });
	end
end

function CommunitiesUtil.IsInCommunity()
	return next(C_Club.GetSubscribedClubs()) ~= nil;
end

function CommunitiesUtil.HasCommunityInvite()
	return next(C_Club.GetInvitationsForSelf()) ~= nil;
end

function CommunitiesUtil.FindCommunityAndStreamByName(communityName, streamName)
	local communityID, streamID;
	if communityName then
		communityName = string.lower(communityName);
		local clubs = C_Club.GetSubscribedClubs();
		if clubs then
			for _, club in ipairs(clubs) do
				if string.lower(club.name) == communityName then
					communityID = club.clubId;
					break;
				end
			end

			if communityID then
				local streams = C_Club.GetStreams(communityID);
				if streams then
					if streamName then
						streamName = string.lower(streamName);
						for _, stream in ipairs(streams) do
							if streamName == string.lower(stream.name) then
								streamID = stream.streamId;
								break;
							end
						end
					else
						for _, stream in ipairs(streams) do
							if stream.streamType == Enum.ClubStreamType.General then
								streamID = stream.streamId;
								break;
							end
						end
					end
				end
			end
		end
	end
	return communityID, streamID;
end

function CommunitiesUtil.FindGuildStreamByType(clubStreamType)
	if clubStreamType ~= Enum.ClubStreamType.Guild and clubStreamType ~= Enum.ClubStreamType.Officer then
		return;
	end

	local communityID, streamID;
	communityID = C_Club.GetGuildClubId();
	if communityID then
		local streams = C_Club.GetStreams(communityID);
		if streams then
			for _, stream in ipairs(streams) do
				if stream.streamType == clubStreamType then
					streamID = stream.streamId;
					break;
				end
			end
		end
	end
	return communityID, streamID;
end