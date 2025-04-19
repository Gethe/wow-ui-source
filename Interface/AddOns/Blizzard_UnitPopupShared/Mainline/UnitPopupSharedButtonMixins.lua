UnitPopupGlueInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGlueInviteButtonMixin:GetButtonName()
	return "GLUE_INVITE";
end

function UnitPopupGlueInviteButtonMixin:GetText()
	return PARTY_INVITE;
end

function UnitPopupGlueInviteButtonMixin:CanShow()
	return true
end

function UnitPopupGlueInviteButtonMixin:OnClick(contextData)
	if contextData.bnetIDAccount then
		C_WoWLabsMatchmaking.SendPartyInvite(contextData.bnetIDAccount)
	end
end

function UnitPopupGlueInviteButtonMixin:IsEnabled()
	return not C_WoWLabsMatchmaking.IsPartyFull();
end

UnitPopupGlueLeavePartyButton = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGlueLeavePartyButton:GetText()
	return GLUE_LEAVE_PARTY; 
end

function UnitPopupGlueLeavePartyButton:CanShow(contextData)
	return C_WoWLabsMatchmaking.IsPlayer(UnitPopupSharedUtil.GetGUID(contextData)) and not C_WoWLabsMatchmaking.IsAloneInWoWLabsParty();
end 

function UnitPopupGlueLeavePartyButton:OnClick()
	C_WoWLabsMatchmaking.LeaveParty();
end 

UnitPopupGlueRemovePartyButton = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGlueRemovePartyButton:GetText()
	return GLUE_REMOVE_FROM_PARTY; 
end

function UnitPopupGlueRemovePartyButton:CanShow(contextData)
	return C_WoWLabsMatchmaking.IsPartyLeader() and not C_WoWLabsMatchmaking.IsPlayer(UnitPopupSharedUtil.GetGUID(contextData));
end

function UnitPopupGlueRemovePartyButton:OnClick(contextData)
	C_WoWLabsMatchmaking.RemovePlayerFromParty(UnitPopupSharedUtil.GetGUID(contextData));
end