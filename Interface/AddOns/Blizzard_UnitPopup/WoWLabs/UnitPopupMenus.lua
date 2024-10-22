---------------------------- Main Menus ----------------------------------------------
function UnitPopupMenuSelf:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuPlayer:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuVehicle:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVehicleLeaveButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuTarget:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupAddFriendButtonMixin, 
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVoiceChatButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuFocus:GetEntries()
	return {
		UnitPopupClearFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end


function UnitPopupMenuParty:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a submenu
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuEnemyPlayer:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuRaidPlayer:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuBnFriend:GetEntries()
	return { 
		UnitPopupPopoutChatButtonMixin,
		UnitPopupBnetTargetButtonMixin,
		UnitPopupSetBNetNoteButtonMixin, 
		UnitPopupViewBnetFriendsButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupRafSummonButtonMixin,
		UnitPopupBnetInviteButtonMixin,
		UnitPopupBnetSuggestInviteButtonMixin,
		UnitPopupBnetRequestInviteButtonMixin,
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupDeleteCommunityMessageButtonMixin,
		UnitPopupBnetAddFavoriteButtonMixin,
		UnitPopupBnetRemoveFavoriteButtonMixin,
		UnitPopupRemoveBnetFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupReportChatButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupMenuBnFriendOffline:GetEntries()
	return { 
		UnitPopupSetBNetNoteButtonMixin, 
		UnitPopupViewBnetFriendsButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupBnetAddFavoriteButtonMixin,
		UnitPopupBnetRemoveFavoriteButtonMixin,
		UnitPopupRemoveBnetFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuCommunitiesWowMember:GetEntries()
	return {
		UnitPopupTargetButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupCommunitiesLeaveButtonMixin,
		UnitPopupCommunitiesKickFriendButtonMixin,
		UnitPopupCommunitiesMemberNoteButtonMixin,
		UnitPopupCommunitiesRoleButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportClubMemberButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuCommunitiesGuildMember:GetEntries()
	return {
		UnitPopupTargetButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupGuildPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupGuildLeaveButtonMixin,
		UnitPopupReportClubMemberButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupRafRecruit = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("RAF_RECRUIT", UnitPopupRafRecruit);
function UnitPopupRafRecruit:GetEntries()
	return {
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupInteractSubsectionTitle, 
		UnitPopupRafSummonButtonMixin, 
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupRafRemoveRecruitButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuFriendlyPlayer:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupInteractSubsectionTitle,
	}
end 

function UnitPopupMenuFriendlyPlayerInteract:GetEntries()
	return {
		UnitPopupWhisperButtonMixin,
	}
end 

-- No party invites inside a Plunderstorm match.
function UnitPopupMenuFriendlyPlayerInviteOptions:GetEntries()
	return {
	}
end

function UnitPopupMenuBattlePet:GetEntries()
	return { 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupMenuOtherBattlePet:GetEntries()
	return { 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupAddFriendMenuButtonMixin:GetButtons()
	return {
		UnitPopupAddBtagFriendButtonMixin,
	}
end

