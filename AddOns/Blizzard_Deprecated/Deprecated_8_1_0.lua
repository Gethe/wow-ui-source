
-- These are functions that were deprecated in 8.1.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Summons API update

do 
	-- Use C_SummonInfo.GetSummonConfirmTimeLeft() instead.
	GetSummonConfirmTimeLeft = C_SummonInfo.GetSummonConfirmTimeLeft;

	-- Use C_SummonInfo.GetSummonConfirmSummoner() instead.
	GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner;

	-- Use C_SummonInfo.GetSummonConfirmAreaName() instead.
	GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName;

	-- Use C_SummonInfo.ConfirmSummon() instead.
	ConfirmSummon = C_SummonInfo.ConfirmSummon;

	-- Use C_SummonInfo.CancelSummon() instead.
	CancelSummon = C_SummonInfo.CancelSummon;
	
	-- Use C_DateAndTime.GetCurrentCalendarTime() instead.
	C_Calendar.GetDate = C_DateAndTime.GetCurrentCalendarTime;
	
	local function ConvertToOldStyleDate(calendarTime)
		calendarTime.weekDay = calendarTime.weekday;
		calendarTime.day = calendarTime.monthDay;
		calendarTime.minute = nil;
		calendarTime.hour = nil;
		calendarTime.monthDay = nil;
		calendarTime.weekday = nil;
		return calendarTime;
	end
	
	-- Use C_DateAndTime.GetCalendarTimeFromEpoch() instead.
	C_DateAndTime.GetDateFromEpoch = function(epoch)
		local currentCalendarTime = C_DateAndTime.GetCalendarTimeFromEpoch(epoch);
		return ConvertToOldStyleDate(currentCalendarTime);
	end
	
	-- Use C_DateAndTime.GetCurrentCalendarTime() instead.
	C_DateAndTime.GetTodaysDate = function()
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		return ConvertToOldStyleDate(currentCalendarTime);
	end
	
	-- Use C_DateAndTime.GetCurrentCalendarTime() and C_DateAndTime.AdjustTimeByDays instead.
	C_DateAndTime.GetYesterdaysDate = function()
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		currentCalendarTime = C_DateAndTime.AdjustTimeByDays(currentCalendarTime, -1);
		return ConvertToOldStyleDate(currentCalendarTime);
	end
	
end

-- Friend list API update

do
	-- Use C_FriendList.GetNumFriends and C_FriendList.GetNumOnlineFriends instead
	function GetNumFriends()
		return C_FriendList.GetNumFriends(),
			C_FriendList.GetNumOnlineFriends();
	end

	-- Use C_FriendList.GetFriendInfo or C_FriendList.GetFriendInfoByIndex instead
	function GetFriendInfo(friend)
		local info;
		if type(friend) == "number" then
			info = C_FriendList.GetFriendInfoByIndex(friend);
		elseif type(friend) == "string" then
			info = C_FriendList.GetFriendInfo(friend);
		end

		if info then
			return info.name,
				info.level,
				info.className,
				info.area,
				info.connected,
				info.dnd ? CHAT_FLAG_DND : info.afk ? CHAT_FLAG_AFK : "",
				info.notes,
				info.referAFriend,
				info.guid;
		end
	end

	-- Use C_FriendList.SetSelectedFriend instead
	SetSelectedFriend = C_FriendList.SetSelectedFriend;

	-- Use C_FriendList.GetSelectedFriend instead
	GetSelectedFriend = C_FriendList.GetSelectedFriend;

	-- Use C_FriendList.AddOrRemoveFriend instead
	AddOrRemoveFriend = C_FriendList.AddOrRemoveFriend;

	-- Use C_FriendList.AddFriend instead
	AddFriend = C_FriendList.AddFriend;

	-- Use C_FriendList.RemoveFriend or C_FriendList.RemoveFriendByIndex instead
	function RemoveFriend(friend)
		if type(friend) == "number" then
			C_FriendList.RemoveFriendByIndex(friend);
		elseif type(friend) == "string" then
			C_FriendList.RemoveFriend(friend);
		end
	end

	-- Use C_FriendList.ShowFriends instead
	ShowFriends = C_FriendList.ShowFriends;

	-- Use C_FriendList.SetFriendNotes or C_FriendList.SetFriendNotesByIndex instead
	function SetFriendNotes(friend, notes)
		if type(friend) == "number" then
			C_FriendList.SetFriendNotesByIndex(friend, notes);
		elseif type(friend) == "string" then
			C_FriendList.SetFriendNotes(friend, notes);
		end
	end

	-- Use C_FriendList.IsFriend instead. No longer accepts unit tokens.
	IsCharacterFriend = C_FriendList.IsFriend;

	-- Use C_FriendList.GetNumIngores instead
	GetNumIngores = C_FriendList.GetNumIngores;

	-- Use C_FriendList.GetIgnoreName instead
	GetIgnoreName = C_FriendList.GetIgnoreName;

	-- Use C_FriendList.SetSelectedIgnore instead
	SetSelectedIgnore = C_FriendList.SetSelectedIgnore;

	-- Use C_FriendList.GetSelectedIgnore instead
	GetSelectedIgnore = C_FriendList.GetSelectedIgnore;

	-- Use C_FriendList.AddOrDelIgnore instead
	AddOrDelIgnore = C_FriendList.AddOrDelIgnore;

	-- Use C_FriendList.AddIgnore instead
	AddIgnore = C_FriendList.AddIgnore;

	-- Use C_FriendList.DelIgnore or C_FriendList.DelIgnoreByIndex instead
	function DelIgnore(friend)
		if type(friend) == "number" then
			C_FriendList.DelIgnoreByIndex(friend);
		elseif type(friend) == "string" then
			C_FriendList.DelIgnore(friend);
		end
	end

	-- Use C_FriendList.IsIgnored or the new C_FriendList.IsIgnoredByGuid instead. 
	IsIgnored = C_FriendList.IsIgnored;

	-- Use C_FriendList.SendWho instead
	SendWho = C_FriendList.SendWho;

	-- Use C_FriendList.GetNumWhoResults instead
	GetNumWhoResults = C_FriendList.GetNumWhoResults;

	-- Use C_FriendList.GetWhoInfo instead
	function GetWhoInfo(index)
		local info = C_FriendList.GetWhoInfo(index);
		return info.fullName,
			info.fullGuildName,
			info.level,
			info.raceStr,
			info.classStr,
			info.area,
			info.filename,
			info.gender;
	end

	-- Use C_FriendList.SetWhoToUi instead
	SetWhoToUI = C_FriendList.SetWhoToUi;

	-- Use C_FriendList.SortWho instead
	SortWho = C_FriendList.SortWho;
end
