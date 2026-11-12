function GetPartyInviteString(isXRealm, isXShard)
	if isXRealm then
		return INVITATION_XREALM;
	else
		return INVITATION;
	end
end
