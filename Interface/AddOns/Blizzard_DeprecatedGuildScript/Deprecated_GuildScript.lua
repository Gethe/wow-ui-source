-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	GuildInvite = C_GuildInfo.Invite;
	GuildUninvite = C_GuildInfo.Uninvite;
	GuildPromote = C_GuildInfo.Promote;
	GuildDemote = C_GuildInfo.Demote;
	GuildSetLeader = C_GuildInfo.SetLeader;
	GuildSetMOTD = C_GuildInfo.SetMOTD;
	GuildLeave = C_GuildInfo.Leave;
	GuildDisband = C_GuildInfo.Disband;
end