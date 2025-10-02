---------------------------- Main Menus ----------------------------------------------
function UnitPopupMenuSelf:GetEntries()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin,
		UnitPopupSelfHighlightSelectButtonMixin,
		UnitPopupPvpFlagButtonMixin,
		UnitPopupLootSubsectionTitle,
		UnitPopupSelectLootSpecializationButtonMixin,
		UnitPopupInstanceSubsectionTitle,
		UnitPopupConvertToRaidButtonMixin,
		UnitPopupConvertToPartyButtonMixin,
		UnitPopupDungeonDifficultyButtonMixin,
		UnitPopupRaidDifficultyButtonMixin, 
		UnitPopupResetInstancesButtonMixin,
		UnitPopupResetChallengeModeButtonMixin, 
		UnitPopupGarrisonVisitButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupPartyInstanceLeaveButtonMixin,
		UnitPopupPartyLeaveButtonMixin,
		UnitPopupPartyInstanceAbandonButtonMixin,
	}
end

function UnitPopupMenuParty:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a submenu
		UnitPopupRafSummonButtonMixin,
		UnitPopupPromoteButtonMixin,
		UnitPopupPromoteGuideButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a submenu
        UnitPopupViewHousesButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupPvpReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
		UnitPopupUninviteButtonMixin,
	}
end

function UnitPopupMenuEnemyPlayer:GetEntries()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupInspectButtonMixin, 
		UnitPopupAchievementButtonMixin,
		UnitPopupDuelButtonMixin,
		UnitPopupPetBattleDuelButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
	}
end

function UnitPopupMenuRaidPlayer:GetEntries()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupRafSummonButtonMixin,
		UnitPopupSetRaidLeaderButtonMixin,
		UnitPopupSetRaidAssistButtonMixin, 
		UnitPopupSetRaidDemoteButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
        UnitPopupViewHousesButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupEnterEditModeMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupPvpReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
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
		UnitPopupRafSummonButtonMixin,
		UnitPopupBnetInviteButtonMixin,
		UnitPopupBnetSuggestInviteButtonMixin,
		UnitPopupBnetRequestInviteButtonMixin,
		UnitPopupWhisperButtonMixin,
        UnitPopupViewHousesButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupDeleteCommunityMessageButtonMixin,
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
		UnitPopupViewHousesButtonMixin,
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
        UnitPopupViewHousesButtonMixin,
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
		UnitPopupRafSummonButtonMixin, 
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
	}
end
