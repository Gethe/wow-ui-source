---------------------------- Main Menus ----------------------------------------------
function UnitPopupMenuSelf:GetEntries()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin,
		UnitPopupSelfHighlightSelectButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupPartyInstanceLeaveButtonMixin,
		UnitPopupPartyLeaveButtonMixin,
	}
end

function UnitPopupMenuParty:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a submenu
		UnitPopupPromoteButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a submenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupUninviteButtonMixin,
	}
end

function UnitPopupMenuEnemyPlayer:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupAchievementButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
	}
end

function UnitPopupMenuRaidPlayer:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupSetRaidLeaderButtonMixin,
		UnitPopupSetRaidAssistButtonMixin, 
		UnitPopupSetRaidDemoteButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupSetRaidRemoveButtonMixin,
	}
end

function UnitPopupMenuBnFriend:GetEntries()
	return { 
		UnitPopupPopoutChatButtonMixin,
		UnitPopupBnetTargetButtonMixin,
		UnitPopupSetBNetNoteButtonMixin, 
		UnitPopupViewBnetFriendsButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupBnetInviteButtonMixin,
		UnitPopupBnetSuggestInviteButtonMixin,
		UnitPopupBnetRequestInviteButtonMixin,
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupBnetAddFavoriteButtonMixin,
		UnitPopupBnetRemoveFavoriteButtonMixin,
		UnitPopupRemoveBnetFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupReportChatButtonMixin,
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
		UnitPopupCopyCharacterNameButtonMixin,
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
		UnitPopupCopyCharacterNameButtonMixin,
	}
end

UnitPopupRafRecruit = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("RAF_RECRUIT", UnitPopupRafRecruit);
function UnitPopupRafRecruit:GetEntries()
	return {
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupInteractSubsectionTitle, 
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
	}
end

-- Override the shared menu definition to remove pet battle duel.
UnitPopupMenuFriendlyPlayerInteract = CreateFromMixins(UnitPopupTopLevelMenuMixin);
function UnitPopupMenuFriendlyPlayerInteract:GetEntries()
	return {
		UnitPopupWhisperButtonMixin,
		UnitPopupAchievementButtonMixin,
		UnitPopupTradeButtonMixin,
		UnitPopupFollowButtonMixin,
		UnitPopupDuelButtonMixin,
	}
end

-- Override the shared menu definition to remove open in pet journal and edit mode.
function UnitPopupMenuBattlePet:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupCancelButtonMixin,
	}
end

-- Override the shared menu definition to remove open in pet journal and edit mode.
function UnitPopupMenuOtherBattlePet:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupCancelButtonMixin,
	}
end
