function GetPartyInviteString(isXRealm, isXShard)
	if isXRealm then
		return INVITATION_XREALM;
	elseif isXShard then
		return INVITATION_XSHARD;
	else
		return INVITATION;
	end
end
