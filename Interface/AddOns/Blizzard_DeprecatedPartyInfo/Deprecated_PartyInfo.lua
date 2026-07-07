-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function ConfirmReadyCheck(isReady)
	if isReady == nil then
		isReady = false;
	end

	C_PartyInfo.ConfirmReadyCheck(isReady);
end

function DemoteAssistant(name, exactNameMatch)
	C_PartyInfo.DemoteAssistant(name, exactNameMatch);
end

function DoReadyCheck()
	C_PartyInfo.DoReadyCheck();
end

function PromoteToAssistant(name, exactNameMatch)
	C_PartyInfo.PromoteToAssistant(name, exactNameMatch);
end

function PromoteToLeader(name, exactNameMatch)
	C_PartyInfo.PromoteToLeader(name, exactNameMatch);
end

function SetEveryoneIsAssistant(isAssistant)
	return C_PartyInfo.SetEveryoneIsAssistant(isAssistant);
end

function UninviteUnit(unit, reason, exactNameMatch)
	C_PartyInfo.UninviteUnit(unit, reason, exactNameMatch);
end

function IsGUIDInGroup(guid, category)
	return C_PartyInfo.IsGUIDInGroup(guid, category);
end