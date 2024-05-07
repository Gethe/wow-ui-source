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

function UnitPopupGlueInviteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu()
	if dropdownMenu and dropdownMenu.bnetIDAccount then
		local success = C_WoWLabsMatchmaking.SendPartyInvite(dropdownMenu.bnetIDAccount)
	end
end

function UnitPopupGlueInviteButtonMixin:IsEnabled()
	return not C_WoWLabsMatchmaking.IsPartyFull();
end

UnitPopupGlueLeavePartyButton = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGlueLeavePartyButton:GetText()
	return GLUE_LEAVE_PARTY; 
end

function UnitPopupGlueLeavePartyButton:CanShow()
	return C_WoWLabsMatchmaking.IsPlayer(self:GetGUID()) and not C_WoWLabsMatchmaking.IsAloneInWoWLabsParty();
end 

function UnitPopupGlueLeavePartyButton:OnClick()
	C_WoWLabsMatchmaking.LeaveParty();
end 

UnitPopupGlueRemovePartyButton = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGlueRemovePartyButton:GetText()
	return GLUE_REMOVE_FROM_PARTY; 
end

function UnitPopupGlueRemovePartyButton:CanShow()
	return C_WoWLabsMatchmaking.IsPartyLeader() and not C_WoWLabsMatchmaking.IsPlayer(self:GetGUID())
end

function UnitPopupGlueRemovePartyButton:OnClick()
	C_WoWLabsMatchmaking.RemovePlayerFromParty(self:GetGUID()); 
end