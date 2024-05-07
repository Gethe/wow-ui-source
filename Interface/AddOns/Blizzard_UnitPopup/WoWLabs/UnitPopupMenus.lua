---------------------------- Main Menus ----------------------------------------------
function UnitPopupMenuSelf:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuPlayer:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuVehicle:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVehicleLeaveButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuTarget:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupAddFriendButtonMixin, 
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVoiceChatButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuFocus:GetMenuButtons()
	return {
		UnitPopupClearFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end


function UnitPopupMenuParty:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a submenu
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuEnemyPlayer:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuRaidPlayer:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuBnFriend:GetMenuButtons()
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

function UnitPopupMenuBnFriendOffline:GetMenuButtons()
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

function UnitPopupMenuCommunitiesWowMember:GetMenuButtons()
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

function UnitPopupMenuCommunitiesGuildMember:GetMenuButtons()
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

UnitPopupGuildGuilds = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("GUILDS_GUILD", UnitPopupGuildGuilds);
function UnitPopupGuildGuilds:GetMenuButtons()
	return {
		UnitPopupClearCommunityNotificationButtonMixin,
		UnitPopupGuildInviteButtonMixin, 
		UnitPopupGuildSettingButtonMixin, 
		UnitPopupGuildRecruitmentSettingButtonMixin, 
		UnitPopupCommunityNotificationButtonMixin,
		UnitPopupGuildGuildsLeaveButtonMixin,
	}
end

UnitPopupRafRecruit = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("RAF_RECRUIT", UnitPopupRafRecruit);
function UnitPopupRafRecruit:GetMenuButtons()
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

function UnitPopupMenuFriendlyPlayer:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupInteractSubsectionTitle,
	}
end 

function UnitPopupMenuFriendlyPlayerInteract:GetMenuButtons()
	return {
		UnitPopupWhisperButtonMixin,
	}
end 

-- No party invites inside a Plunderstorm match.
function UnitPopupMenuFriendlyPlayerInviteOptions:GetMenuButtons()
	return {
	}
end

function UnitPopupMenuBattlePet:GetMenuButtons()
	return { 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupMenuOtherBattlePet:GetMenuButtons()
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

