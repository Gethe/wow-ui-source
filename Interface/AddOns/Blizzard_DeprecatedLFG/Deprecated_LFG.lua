-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	C_LFGInfo.IsPremadeGroupEnabled = C_LFGList.IsPremadeGroupFinderEnabled;
	C_LFGList.GetSearchResultMemberInfo = function(...)
		local info = C_LFGList.GetSearchResultPlayerInfo(...);
		if (info) then
			return info.assignedRole, info.classFilename, info.className, info.specName, info.isLeader;
		end
	end
end