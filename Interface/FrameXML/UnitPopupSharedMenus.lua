UnitPopupTopLevelMenuMixin = { };
-- Override in your inherited class! 
function UnitPopupTopLevelMenuMixin:GetMenuButtons()
end 

function UnitPopupTopLevelMenuMixin:GetButtons()
	local menuButtonMixins = { }; 
	local buttonMixins = self:GetMenuButtons(); 
	for _, buttonMixin in ipairs(buttonMixins) do 
		if(buttonMixin.IsMenu()) then 
			local subMenuButtons = buttonMixin:GetMenuButtons(); 
			for _, subMenuButtonMixin in ipairs(subMenuButtons) do
				table.insert(menuButtonMixins, subMenuButtonMixin);
			end
		else 
			table.insert(menuButtonMixins, buttonMixin);
		end
	end
	return menuButtonMixins; 
end		


function UnitPopupTopLevelMenuMixin:IsMenu()
	return true; 
end

---------------------------- Sub Menus ----------------------------------------------
UnitPopupMenuFriendlyPlayer = CreateFromMixins(UnitPopupTopLevelMenuMixin);
function UnitPopupMenuFriendlyPlayer:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin,
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupInteractSubsectionTitle,
	}
end 

UnitPopupMenuFriendlyPlayerInteract = CreateFromMixins(UnitPopupTopLevelMenuMixin);
function UnitPopupMenuFriendlyPlayerInteract:GetMenuButtons()
	return {
		UnitPopupWhisperButtonMixin,
		UnitPopupInspectButtonMixin, 
		UnitPopupAchievementButtonMixin,
		UnitPopupTradeButtonMixin, 
		UnitPopupFollowButtonMixin,
		UnitPopupDuelButtonMixin,
		UnitPopupPetBattleDuelButtonMixin,
	}
end 

UnitPopupMenuFriendlyPlayerInviteOptions = CreateFromMixins(UnitPopupTopLevelMenuMixin)
function UnitPopupMenuFriendlyPlayerInviteOptions:GetMenuButtons()
	return {
		UnitPopupInviteButtonMixin,
		UnitPopupSuggestInviteButtonMixin,
		UnitPopupRequestInviteButtonMixin,
	}
end


---------------------------- Main Menus ----------------------------------------------
UnitPopupMenuSelf = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("SELF", UnitPopupMenuSelf);
function UnitPopupMenuSelf:GetMenuButtons()
end

UnitPopupMenuPet = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("PET", UnitPopupMenuPet);
function UnitPopupMenuPet:GetMenuButtons()
	return { 
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupPetRenameButtonMixin,
		UnitPopupPetDismissButtonMixin,
		UnitPopupPetAbandonButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

UnitPopupMenuOtherPet = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("OTHERPET", UnitPopupMenuOtherPet);
function UnitPopupMenuOtherPet:GetMenuButtons()
	return { 
		UnitPopupRaidTargetButtonMixin,
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportPetButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

UnitPopupMenuBattlePet = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("BATTLEPET", UnitPopupMenuBattlePet);
function UnitPopupMenuBattlePet:GetMenuButtons()
	return { 
		UnitPopupPetShowInJournalButtonMixin, 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

UnitPopupMenuOtherBattlePet = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("OTHERBATTLEPET", UnitPopupMenuOtherBattlePet);
function UnitPopupMenuOtherBattlePet:GetMenuButtons()
	return { 
		UnitPopupPetShowInJournalButtonMixin, 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportBattlePetButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 


-- Fill out in UnitPopupMenus
UnitPopupMenuParty = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("PARTY", UnitPopupMenuParty);
function UnitPopupMenuParty:GetMenuButtons()
end

-- Fill out in UnitPopupMenus
UnitPopupMenuPlayer = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("PLAYER", UnitPopupMenuPlayer);
function UnitPopupMenuPlayer:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupRafSummonButtonMixin,
		UnitPopupRafGrantLevelButtonMixin,
		UnitPopupMenuFriendlyPlayerInviteOptions, -- This is a subMenu
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

-- Fill out in UnitPopupMenus
UnitPopupMenuEnemyPlayer = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("ENEMY_PLAYER", UnitPopupMenuEnemyPlayer);
function UnitPopupMenuEnemyPlayer:GetMenuButtons()
end

-- Fill out in UnitPopupMenus
UnitPopupMenuRaidPlayer = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("RAID_PLAYER", UnitPopupMenuRaidPlayer);
function UnitPopupMenuRaidPlayer:GetMenuButtons()

end

-- Fill out in UnitPopupMenus
UnitPopupMenuRaid = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("RAID", UnitPopupMenuRaid);
function UnitPopupMenuRaid:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupSetRaidLeaderButtonMixin,
		UnitPopupSetRaidAssistButtonMixin, 
		UnitPopupSetRaidMainTankButtonMixin,
		UnitPopupSetRaidMainAssistButtonMixin,
		UnitPopupSetRaidDemoteButtonMixin,
		UnitPopupLootPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
		UnitPopupSetRaidRemoveButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

-- Fill out in UnitPopupMenus
UnitPopupMenuFriend = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("FRIEND", UnitPopupMenuFriend);
function UnitPopupMenuFriend:GetMenuButtons()
	return { 
		UnitPopupPopoutChatButtonMixin,
		UnitPopupTargetButtonMixin,
		UnitPopupSetNoteButtonMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupRafSummonButtonMixin,
		UnitPopupMenuFriendlyPlayerInviteOptions, --SubMenu
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupDeleteCommunityMessageButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupRemoveFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupReportChatButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

-- Fill out in UnitPopupMenus
UnitPopupMenuFriendOffline = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("FRIEND_OFFLINE", UnitPopupMenuFriendOffline);
function UnitPopupMenuFriendOffline:GetMenuButtons()
	return { 
		UnitPopupSetNoteButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupIgnoreButtonMixin,
		UnitPopupRemoveFriendButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end  

-- Fill out in UnitPopupMenus
UnitPopupMenuBnFriend = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("BN_FRIEND", UnitPopupMenuBnFriend);
function UnitPopupMenuBnFriend:GetMenuButtons()
end 

-- Fill out in UnitPopupMenus
UnitPopupMenuBnFriendOffline = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("BN_FRIEND_OFFLINE", UnitPopupMenuBnFriendOffline);
function UnitPopupMenuBnFriendOffline:GetMenuButtons()
end

UnitPopupMenuGuild = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("GUILD", UnitPopupMenuGuild);
function UnitPopupMenuGuild:GetMenuButtons()
	return { 
		UnitPopupTargetButtonMixin, 
		UnitPopupAddGuildBtagFriendButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupMenuFriendlyPlayerInviteOptions, --submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupGuildPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupGuildLeaveButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

UnitPopupMenuGuildOffline = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("GUILD_OFFLINE", UnitPopupMenuGuildOffline);
function UnitPopupMenuGuildOffline:GetMenuButtons()
	return { 
		UnitPopupAddGuildBtagFriendButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupGuildPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupIgnoreButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupGuildLeaveButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

UnitPopupMenuChatRoster = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("CHAT_ROSTER", UnitPopupMenuChatRoster);
function UnitPopupMenuChatRoster:GetMenuButtons()
	return {
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupSubsectionSeperatorMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupTargetButtonMixin,
		UnitPopupWhisperButtonMixin,
		UnitPopupChatOwnerButtonMixin,
		UnitPopupChatPromoteButtonMixin,
		UnitPopupChatDemoteButtonMixin,
		UnitPopupSubsectionSeperatorMixin,
		UnitPopupOtherSubsectionTitle, 
		UnitPopupReportChatButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupVoiceChatSettingsButtonMixin,
		UnitPopupCloseButtonMixin,
	}
end

UnitPopupMenuVehicle = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("VEHICLE", UnitPopupMenuVehicle);
function UnitPopupMenuVehicle:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVehicleLeaveButtonMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupMenuTarget = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("TARGET", UnitPopupMenuTarget);
function UnitPopupMenuTarget:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin, 
		UnitPopupAddFriendButtonMixin, 
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupOtherSubsectionTitle, 
		UnitPopupVoiceChatButtonMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupMenuArenaEnemy = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("ARENAENEMY", UnitPopupMenuArenaEnemy);
function UnitPopupMenuArenaEnemy:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle, 
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupMenuFocus = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("FOCUS", UnitPopupMenuFocus);
function UnitPopupMenuFocus:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin,
		UnitPopupClearFocusButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupLargeFocusButtonMixin,
		UnitPopupMoveFocusButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupMenuBoss = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("BOSS", UnitPopupMenuBoss);
function UnitPopupMenuBoss:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin,
		UnitPopupSetFocusButtonMixin, 
		UnitPopupOtherSubsectionTitle, 
		UnitPopupCancelButtonMixin, 
	}
end

-- Fill out in UnitPopupMenus
UnitPopupMenuCommunitiesWowMember = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("COMMUNITIES_WOW_MEMBER", UnitPopupMenuCommunitiesWowMember);
function UnitPopupMenuCommunitiesWowMember:GetMenuButtons()
end

-- Fill out in UnitPopupMenus
UnitPopupMenuCommunitiesGuildMember = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("COMMUNITIES_GUILD_MEMBER", UnitPopupMenuCommunitiesGuildMember);
function UnitPopupMenuCommunitiesGuildMember:GetMenuButtons()
end

UnitPopupMenuCommunitiesMember = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("COMMUNITIES_MEMBER", UnitPopupMenuCommunitiesMember);
function UnitPopupMenuCommunitiesMember:GetMenuButtons()
	return {
		UnitPopupCommunitiesBtagFriendButtonMixin,
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupCommunitiesLeaveButtonMixin,
		UnitPopupCommunitiesKickFriendButtonMixin,
		UnitPopupCommunitiesMemberNoteButtonMixin,
		UnitPopupCommunitiesRoleButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportClubMemberButtonMixin,
	}
end

UnitPopupMenuCommunitiesCommunity = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("COMMUNITIES_COMMUNITY", UnitPopupMenuCommunitiesCommunity);
function UnitPopupMenuCommunitiesCommunity:GetMenuButtons()
	return {
		UnitPopupClearCommunityNotificationButtonMixin,
		UnitPopupCommunityInviteButtonMixin, 
		UnitPopupCommunitiesSettingButtonMixin, 
		UnitPopupCommunityNotificationButtonMixin, 
		UnitPopupCommunitiesFavoriteButtonMixin,
		UnitPopupCommunitiesLeaveButtonMixin,
	}
end

UnitPopupMenuRaidTargetIcon = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("RAID_TARGET_ICON", UnitPopupMenuRaidTargetIcon);
function UnitPopupMenuRaidTargetIcon:GetMenuButtons()
	return { 
		UnitPopupRaidTargetButtonMixin,
	}
end

UnitPopupMenuWorldStateScore = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("WORLD_STATE_SCORE", UnitPopupMenuWorldStateScore);
function UnitPopupMenuWorldStateScore:GetMenuButtons()
	return {
		UnitPopupReportPvpScoreboardButtonMixin, 
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupMenuPvpScoreboard = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("PVP_SCOREBOARD", UnitPopupMenuPvpScoreboard);
function UnitPopupMenuPvpScoreboard:GetMenuButtons()
	return {
		UnitPopupReportPvpScoreboardButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end