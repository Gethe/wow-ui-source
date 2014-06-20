--REMOVE ME EVENTUALLY
LFGLIST_NAME = "Premade Groups"
FIND_A_GROUP = "Find a Group"
START_A_GROUP = "Start a Group"
LFG_LIST_SELECT_A_CATEGORY = "Make a selection.";
LFG_LIST_ENTER_NAME = "Enter a name for the group";
LFG_LIST_ITEM_LEVEL_REQ = "Minimum Item Level";
LFG_LIST_ITEM_LEVEL_INSTR_SHORT = "Item Level";
LFG_LIST_ILVL_ABOVE_YOURS = "You can't require an item level higher than your own."
LFG_LIST_VOICE_CHAT = "Voice Chat";
LFG_LIST_VOICE_CHAT_INSTR = "Voice chat program";
LFG_LIST_ITEM_LEVEL_CURRENT = "Item Level: |cffffffff%d|r";
DESCRIPTION_OF_YOUR_GROUP = "Description of your group";
LIST_GROUP = "List Group";
REQUIREMENTS = "Requirements";
LFG_LIST_CREATING_ENTRY = "Zug zug...";
DESCRIPTION = "Description";
EDIT = "Edit";
DONE_EDITING = "Done Editing";
LFG_LIST_CATEGORY_FORMAT = "%s - %s%s%s";
LFG_LIST_LEGACY = "Legacy";
SIGN_UP = "Sign Up";
SEARCHING = "Searching..."
LFG_LIST_COMMENT_FORMAT = "\"%s\"";
LFG_LIST_TOOLTIP_ILVL = "Item Level Required: |cffffffff%d|r";
LFG_LIST_TOOLTIP_AGE = "Created: |cffffffff%s ago|r";
LFG_LIST_TOOLTIP_MEMBERS = "Members: |cffffffff%d (%d/%d/%d)|r";
LFG_LIST_TOOLTIP_VOICE_CHAT = "Voice Chat: |cffffffff\"%s\"|r";
LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP = "Friends in this group:";
LFG_LIST_SEARCH_AGAIN = "Search Again"
LFG_LIST_NO_RESULTS_FOUND = "You are not eligible for any groups matching your search terms.";
LFG_LIST_SEARCH_FAILED = "Search Failed. Please wait a moment and try again."
LFG_LIST_PENDING = "Pending |cff40bf40-|r"
LFG_LIST_APP_CANCELLED = "|cffff0000Cancelled|r";
QUEUED_STATUS_SIGNED_UP = "Signed Up";
CANCEL_SIGN_UP = "Cancel Sign Up";
LFG_LIST_NOTE_TO_LEADER = "Optional note to the group leader";
LFG_LIST_REFRESH = "Refresh";
LFG_LIST_INVITE_GROUP = "Invite\nGroup (%d)";
LFG_LIST_APP_DECLINED = "Declined";
LFG_LIST_APP_TIMED_OUT = "Expired";
LFG_LIST_APP_INVITED = "Invited";
LFG_LIST_APP_INVITE_ACCEPTED = "Joined";
LFG_LIST_APP_INVITE_DECLINED = "Declined Invite";

LFG_LIST_MUST_HAVE_NAME = "You must enter a name for your group."
LFG_LIST_MUST_SELECT_ROLE = "You must select at least one role for which you have a specialization."

LFG_LIST_INVITED_TO_GROUP = "You have been invited to a group:";
LFG_LIST_ENTRY_DELISTED = "This group is no longer looking for additional members."

--[[
function C_LFGList.GetSearchResults()
	return 100, { 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
end

function C_LFGList.GetSearchResultInfo(id)
	local activities = C_LFGList.GetAvailableActivities();
	local activity = activities[((id-1) % #activities) + 1];
	return id, activity, string.format("This is entry %d", id), ((id % 5) == 0) and "No comment" or "", ((id % 3) ~= 0) and "Voice chat "..id or "", id % 3,  (id + 1) % 3, id % 7, (id - 1) * 10, id % 2, false, id, (id + 12) % 25, (25 - id - ((id + 12) % 25));
end

function C_LFGList.GetApplicationInfo(id)
	return id, id < 4 and "applied" or "none", nil, id * 33;
end

function C_LFGList.GetSearchResultFriends(id)
	local ret = {};
	for i=1, id do
		ret[i] = "Friend "..(id + i - 1);
	end
	return ret, ret, ret;
end

function C_LFGList.GetApplications()
	return { 1, 2, 3 };
end
--]]

--[[
function C_LFGList.GetApplicants()
	return { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
end

function C_LFGList.GetApplicantInfo(id)
	return id, "applied", nil, math.max((id % 6)-2,1), id >= 23, "This is comment "..id;
end

function C_LFGList.GetApplicantMemberInfo(id, idx)
	local tank = (id + idx) % 5 == 0;
	local healer = (id + idx) % 3 == 0;
	local damager = (id + idx) % 2 == 0 or (not tank and not healer);
	return string.format("Person %d.%d",id,idx), CLASS_SORT_ORDER[((id + idx) % #CLASS_SORT_ORDER) + 1], "Class "..idx, (idx+2)*10, id * 10 + idx, tank, healer, damager, tank and "TANK" or (healer and "HEALER" or "DAMAGER");
end
--]]
