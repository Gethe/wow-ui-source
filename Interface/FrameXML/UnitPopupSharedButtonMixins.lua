UnitPopupButtonBaseMixin = { }; 
UnitPopupButtonBaseMixin.isSubsection = false; 
UnitPopupButtonBaseMixin.isUninteractable = false;
UnitPopupButtonBaseMixin.isSubsectionTitle = false; 
UnitPopupButtonBaseMixin.isSubsectionSeparator = false;
function UnitPopupButtonBaseMixin:IsDisabledInKioskMode()
	return nil; 
end

function UnitPopupButtonBaseMixin:IsEnabled()
	return true; 
end

function UnitPopupButtonBaseMixin:IsCheckable()
	return false; 
end

function UnitPopupButtonBaseMixin:GetColor()
	return nil; 
end

function UnitPopupButtonBaseMixin:IsIconOnly()
	return false; 
end

function UnitPopupButtonBaseMixin:GetTextureCoords()
	local number = nil; 
	local tCooordsTable = { 
		tCoordLeft = number, 
		tCoordRight = number,
		tCoordTop  = number,
		tCoordBottom = number,
		tSizeX = number,
		tSizeY = number,
		tFitDropDownSizeX = number,
	};
	return tCooordsTable;
end

function UnitPopupButtonBaseMixin:OnClick()
end

function UnitPopupButtonBaseMixin:GetGUID()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return UnitPopupSharedUtil.GetGUID(dropdownMenu);
end

function UnitPopupButtonBaseMixin:IsNested()
	return nil;
end		

function UnitPopupButtonBaseMixin:IsNotRadio()
	return nil;
end	

function UnitPopupButtonBaseMixin:IsTitle()
	return nil;
end	

function UnitPopupButtonBaseMixin:GetTooltipText()
	return nil;
end

function UnitPopupButtonBaseMixin:GetCustomFrame()
	return nil;
end		

function UnitPopupButtonBaseMixin:TooltipWhileDisabled()
	return nil;
end	

function UnitPopupButtonBaseMixin:NoTooltipWhileEnabled()
	return nil;
end	

function UnitPopupButtonBaseMixin:TooltipOnButton()
	return nil;
end	

function UnitPopupButtonBaseMixin:TooltipInstruction()
	return nil;
end

function UnitPopupButtonBaseMixin:CanShow()
	return true; 
end

function UnitPopupButtonBaseMixin:TooltipWarning()
	return nil;
end

function UnitPopupButtonBaseMixin:GetButtons()
	return nil; 
end

function UnitPopupButtonBaseMixin:IsChecked()
	return false; 
end

function UnitPopupButtonBaseMixin:HasArrow()
	return false; 
end

function UnitPopupButtonBaseMixin:GetText()
	return "";
end

function UnitPopupButtonBaseMixin:GetIcon()
	return nil;
end 

function UnitPopupButtonBaseMixin:GetInteractDistance()
	return nil;
end 

function UnitPopupButtonBaseMixin:IsDisabled()
	return false; 
end

function UnitPopupButtonBaseMixin:IsMenu()
	return false; 
end

function UnitPopupButtonBaseMixin:IsCloseCommand()
	return false;
end

UnitPopupCancelButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCancelButtonMixin:GetText()
	return CANCEL; 
end

function UnitPopupCancelButtonMixin:IsCloseCommand()
	return true; 
end 

UnitPopupCloseButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCloseButtonMixin:GetText()
	return CLOSE; 
end

function UnitPopupCloseButtonMixin:IsCloseCommand()
	return true; 
end 

UnitPopupTradeButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupTradeButtonMixin:GetText()
	return TRADE; 
end 

function UnitPopupTradeButtonMixin:GetInteractDistance()
	return 2; 
end

function UnitPopupTradeButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return UnitPopupSharedUtil.CanCooperate(dropdownMenu) and UnitPopupSharedUtil.IsPlayer(dropdownMenu); 
end		

function UnitPopupTradeButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	InitiateTrade(dropdownMenu.unit);
end

function UnitPopupTradeButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownMenu.unit) ) then
		return false;
	end
	return true; 
end 

UnitPopupInspectButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupInspectButtonMixin:GetText()
	return INSPECT; 
end 

function UnitPopupInspectButtonMixin:IsDisabledInKioskMode()
	return false; 
end

function UnitPopupInspectButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if (not dropdownMenu.unit or UnitCanAttack("player", dropdownMenu.unit) or not UnitPopupSharedUtil.IsPlayer()) then 
		return false; 
	end 
	return true; 
end		

function UnitPopupInspectButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	InspectUnit(dropdownMenu.unit);
end

function UnitPopupInspectButtonMixin:IsEnabled()
	return not UnitIsDeadOrGhost("player"); 
end

UnitPopupTargetButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupTargetButtonMixin:GetText()
	return TARGET; 
end 

function UnitPopupTargetButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return (not dropdownMenu.isMobile and not InCombatLockdown() and issecure());
end		

function UnitPopupTargetButtonMixin:OnClick()
	TargetUnit(UnitPopupSharedUtil.GetFullPlayerName(), true);
end

UnitPopupIgnoreButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupIgnoreButtonMixin:GetText()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return C_FriendList.IsOnIgnoredList(dropdownMenu.name) and IGNORE_REMOVE or IGNORE;
end 

function UnitPopupIgnoreButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( dropdownMenu.name == UnitNameUnmodified("player") or ( dropdownMenu.unit and not UnitPopupSharedUtil.IsPlayer(dropdownMenu)) ) then
		return false;
	end
	return true;
end	

function UnitPopupIgnoreButtonMixin:OnClick()
	C_FriendList.AddOrDelIgnore(UnitPopupSharedUtil.GetFullPlayerName());
end


UnitPopupPopoutChatButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPopoutChatButtonMixin:GetText()
	return MOVE_TO_WHISPER_WINDOW;
end 

function UnitPopupPopoutChatButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( (dropdownMenu.chatType ~= "WHISPER" and dropdownMenu.chatType ~= "BN_WHISPER") or dropdownMenu.chatTarget == UnitNameUnmodified("player") or FCFManager_GetNumDedicatedFrames(dropdownMenu.chatType, dropdownMenu.chatTarget) > 0 ) then
		return false;
	end
	return true;
end		

function UnitPopupPopoutChatButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	FCF_OpenTemporaryWindow(dropdownMenu.chatType, dropdownMenu.chatTarget, dropdownMenu.chatFrame, true);
end

UnitPopupDuelButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupDuelButtonMixin:GetText()
	return DUEL; 
end 

function UnitPopupDuelButtonMixin:GetInteractDistance()
	return 3; 
end

function UnitPopupDuelButtonMixin:IsDisabledInKioskMode()
	return false; 
end

function UnitPopupDuelButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( UnitCanAttack("player", dropdownMenu.unit) or not UnitPopupSharedUtil.IsPlayer()) then
		return false;
	end
	return true; 
end		

function UnitPopupDuelButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	StartDuel(dropdownMenu.unit, true);
end

function UnitPopupDuelButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownMenu.unit) ) then
		return false;
	end
	return true; 
end

UnitPopupPetBattleDuelButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPetBattleDuelButtonMixin:GetText()
	return PET_BATTLE_PVP_DUEL; 
end 

function UnitPopupPetBattleDuelButtonMixin:GetInteractDistance()
	return 5; 
end

function UnitPopupPetBattleDuelButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( not UnitCanPetBattle("player", dropdownMenu.unit) or not UnitPopupSharedUtil.IsPlayer()) then
		return false;
	end
	return true; 
end		

function UnitPopupPetBattleDuelButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	C_PetBattles.StartPVPDuel(unit, true);
end

function UnitPopupPetBattleDuelButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownMenu.unit) ) then
		return false;
	end
	return true; 
end

UnitPopupWhisperButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupWhisperButtonMixin:GetText()
	return WHISPER; 
end 

-- Overriden in UnitPopupButtons
function UnitPopupWhisperButtonMixin:CanShow()
end		

function UnitPopupWhisperButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local isBNetAccount = dropdownMenu.bnetIDAccount or (dropdownMenu.playerLocation and dropdownMenu.playerLocation:IsBattleNetGUID());
	if ( isBNetAccount  ) then
		ChatFrame_SendBNetTell(dropdownMenu.name);
	else
		ChatFrame_SendTell(UnitPopupSharedUtil.GetFullPlayerName(), dropdownMenu.chatFrame);
	end
end

function UnitPopupWhisperButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( dropdownMenu.unit and not UnitIsConnected(dropdownMenu.unit) ) then
		return false;
	end
	return true; 
end


UnitPopupInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupInviteButtonMixin:GetButtonName()
	return "INVITE";
end

function UnitPopupInviteButtonMixin:GetText()
	return PARTY_INVITE; 
end 

--This has unique functionality between classic & mainline and should be overridden in the project specific file.
function UnitPopupInviteButtonMixin:CanShow()
end		

function UnitPopupInviteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	UnitPopupSharedUtil:TryInvite(self:GetButtonName(), UnitPopupSharedUtil.GetFullPlayerName());
end

function UnitPopupInviteButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if UnitPopupSharedUtil.IsInGroupWithPlayer() then
		return false;
	end
	return true; 
end

UnitPopupSuggestInviteButtonMixin = CreateFromMixins(UnitPopupInviteButtonMixin);
function UnitPopupSuggestInviteButtonMixin:GetButtonName()
	return "SUGGEST_INVITE";
end

function UnitPopupSuggestInviteButtonMixin:GetText()
	return SUGGEST_INVITE; 
end

function UnitPopupSuggestInviteButtonMixin:CanShow()
	return UnitPopupInviteButtonMixin.CanShow(self);
end

UnitPopupRequestInviteButtonMixin = CreateFromMixins(UnitPopupInviteButtonMixin);
function UnitPopupRequestInviteButtonMixin:GetButtonName()
	return "REQUEST_INVITE";
end

function UnitPopupRequestInviteButtonMixin:GetText()
	return REQUEST_INVITE; 
end 

function UnitPopupRequestInviteButtonMixin:CanShow()
	return UnitPopupInviteButtonMixin.CanShow(self);
end

UnitPopupUninviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupUninviteButtonMixin:GetText()
	return PARTY_UNINVITE; 
end 

function UnitPopupUninviteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local _, instanceType = IsInInstance();

	if ( not IsInGroup() or not UnitPopupSharedUtil.IsPlayer(dropdownMenu) or not UnitIsGroupLeader("player") or (instanceType == "pvp") or (instanceType == "arena") or UnitPopupSharedUtil.HasLFGRestrictions() ) then
		return false;
	end
	return true; 
end	

function UnitPopupUninviteButtonMixin:IsEnabled()
	return self:CanShow(); 
end 

function UnitPopupUninviteButtonMixin:OnClick()
	UninviteUnit(UnitPopupSharedUtil.GetFullPlayerName(), nil, 1);
end

UnitPopupFriendsButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupFriendsButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return dropdownMenu.friendsList; 
end 

UnitPopupRemoveFriendButtonMixin = CreateFromMixins(UnitPopupFriendsButtonMixin);
function UnitPopupRemoveFriendButtonMixin:GetText()
	return REMOVE_FRIEND; 
end 

function UnitPopupRemoveFriendButtonMixin:OnClick()
	if(not C_FriendList.RemoveFriend(UnitPopupSharedUtil.GetFullPlayerName())) then
		UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
	end
end

UnitPopupSetNoteButtonMixin = CreateFromMixins(UnitPopupFriendsButtonMixin);
function UnitPopupSetNoteButtonMixin:GetText()
	return SET_NOTE; 
end 

function UnitPopupSetNoteButtonMixin:OnClick()
	local fullName = UnitPopupSharedUtil.GetFullPlayerName(); 
	FriendsFrame.NotesID = fullName;
	StaticPopup_Show("SET_FRIENDNOTE", fullName);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

UnitPopupRemoveBnetFriendButtonMixin = CreateFromMixins(UnitPopupRemoveFriendButtonMixin);
function UnitPopupRemoveBnetFriendButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdownMenu.accountInfo then
		local promptText;
		if dropdownMenu.accountInfo.isBattleTagFriend then
			promptText = string.format(BATTLETAG_REMOVE_FRIEND_CONFIRMATION, dropdownMenu.accountInfo.accountName);
		else
			promptText = string.format(REMOVE_FRIEND_CONFIRMATION, dropdownMenu.accountInfo.accountName);
		end
		StaticPopup_Show("CONFIRM_REMOVE_FRIEND", promptText, nil, dropdownMenu.accountInfo.bnetAccountID);
	end
end

UnitPopupSetBNetNoteButtonMixin = CreateFromMixins(UnitPopupSetNoteButtonMixin);
function UnitPopupSetBNetNoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	FriendsFrame.NotesID = dropdownMenu.bnetIDAccount;
	StaticPopup_Show("SET_BNFRIENDNOTE", UnitPopupSharedUtil.GetFullPlayerName());
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

UnitPopupViewBnetFriendsButtonMixin = CreateFromMixins(UnitPopupFriendsButtonMixin);
function UnitPopupViewBnetFriendsButtonMixin:GetText()
	return VIEW_FRIENDS_OF_FRIENDS; 
end 

function UnitPopupViewBnetFriendsButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	FriendsFriendsFrame_Show(dropdownMenu.bnetIDAccount);
end

UnitPopupBnetInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupBnetInviteButtonMixin:GetButtonName()
	return "BN_INVITE";
end

function UnitPopupBnetInviteButtonMixin:GetText()
	return PARTY_INVITE; 
end 

--Implementation differs from classic & mainline.. Implemented in UnitPopupButtons (Project Specific File)
function UnitPopupBnetInviteButtonMixin:CanShow()
end		

function UnitPopupBnetInviteButtonMixin:OnClick()
	UnitPopupSharedUtil.TryBNInvite()
end

function UnitPopupBnetInviteButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if not dropdownMenu.bnetIDAccount or not CanGroupWithAccount(dropdownMenu.bnetIDAccount) or UnitPopupSharedUtil.IsInGroupWithPlayer(dropdownMenu) then
		return false;
	end
	return true; 
end

UnitPopupBnetSuggestInviteButtonMixin = CreateFromMixins(UnitPopupBnetInviteButtonMixin);
function UnitPopupBnetSuggestInviteButtonMixin:GetButtonName()
	return "BN_SUGGEST_INVITE";
end

function UnitPopupBnetSuggestInviteButtonMixin:GetText()
	return SUGGEST_INVITE; 
end

function UnitPopupBnetSuggestInviteButtonMixin:CanShow()
	return UnitPopupBnetInviteButtonMixin.CanShow(self);
end

UnitPopupBnetRequestInviteButtonMixin = CreateFromMixins(UnitPopupBnetInviteButtonMixin);
function UnitPopupBnetRequestInviteButtonMixin:GetButtonName()
	return "BN_REQUEST_INVITE";
end

function UnitPopupBnetRequestInviteButtonMixin:GetText()
	return REQUEST_INVITE; 
end 

function UnitPopupBnetRequestInviteButtonMixin:CanShow()
	return UnitPopupBnetInviteButtonMixin.CanShow(self);
end

UnitPopupBnetTargetButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupBnetTargetButtonMixin:GetText()
	return TARGET; 
end 

function UnitPopupBnetTargetButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( dropdownMenu.isMobile or not  UnitPopupSharedUtil.IsBNetFriend(dropdownMenu) or InCombatLockdown() or not issecure() ) then
		return false; 
	end
	return true; 
end

--This has unique functionality between classic & mainline and should be overridden in UnitPopupButtons
function UnitPopupBnetTargetButtonMixin:IsEnabled()
end 

function UnitPopupBnetTargetButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo.characterName then
		TargetUnit(dropdownMenu.accountInfo.gameAccountInfo.characterName);
	end
end

UnitPopupVoteToKickButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoteToKickButtonMixin:GetText()
	return VOTE_TO_KICK; 
end 

function UnitPopupVoteToKickButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local _, instanceType = IsInInstance();
	if ( not IsInGroup() or not UnitPopupSharedUtil.IsPlayer(dropdownMenu) or (instanceType == "pvp") or (instanceType == "arena") or (not UnitPopupSharedUtil.HasLFGRestrictions()) or IsInActiveWorldPVP() ) then
		return false;
	end
	return true; 
end

--This has unique functionality between classic & mainline and should be overridden in UnitPopupButtons
function UnitPopupVoteToKickButtonMixin:IsEnabled()
end 

function UnitPopupVoteToKickButtonMixin:OnClick()
	UninviteUnit(UnitPopupSharedUtil.GetFullPlayerName(), nil, 1);
end

UnitPopupPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPromoteButtonMixin:GetText()
	return PARTY_PROMOTE; 
end 

function UnitPopupPromoteButtonMixin:CanShow()
	if ( not IsInGroup() or not UnitIsGroupLeader("player") or not UnitPopupSharedUtil.IsPlayer() or UnitPopupSharedUtil.HasLFGRestrictions()) then
		return false;
	end
	return true;
end

function UnitPopupPromoteButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( not IsInGroup() or not UnitIsGroupLeader("player") or (dropdownMenu.unit and not UnitIsConnected(dropdownMenu.unit))) then
		return false;
	end
	return true;
end 

function UnitPopupPromoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	PromoteToLeader(dropdownMenu.unit, 1);
end

UnitPopupPromoteGuideButtonMixin = CreateFromMixins(UnitPopupPromoteButtonMixin);
function UnitPopupPromoteGuideButtonMixin:GetText()
	return PROMOTE_GUIDE; 
end 

function UnitPopupPromoteGuideButtonMixin:CanShow()
	if ( not IsInGroup() or not UnitIsGroupLeader("player") or not UnitPopupSharedUtil.IsPlayer() or not UnitPopupSharedUtil.HasLFGRestrictions()) then
		return false;
	end
	return true;
end

UnitPopupGuildPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGuildPromoteButtonMixin:GetText()
	return GUILD_PROMOTE; 
end 

function UnitPopupGuildPromoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not IsGuildLeader() or dropdownMenu.name == UnitNameUnmodified("player") ) then
		return false;
	end
	return true;
end

function UnitPopupGuildPromoteButtonMixin:OnClick()
	local fullName = UnitPopupSharedUtil.GetFullPlayerName(); 
	local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", fullName);
	dialog.data = fullName;
end

--Shown through Communities Guild Roster right click
UnitPopupGuildLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGuildLeaveButtonMixin:GetText()
	return GUILD_LEAVE; 
end 

function UnitPopupGuildLeaveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( dropdownMenu.name ~= UnitNameUnmodified("player") ) then
		return false;
	end
	return true;
end

function UnitPopupGuildLeaveButtonMixin:OnClick()
	local guildName = GetGuildInfo("player");
	StaticPopup_Show("CONFIRM_GUILD_LEAVE", guildName);
end

--This is shown from the Communities List (List of guilds and communities)
UnitPopupGuildGuildsLeaveButtonMixin = CreateFromMixins(UnitPopupGuildLeaveButtonMixin);
function UnitPopupGuildGuildsLeaveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo == nil or dropdownMenu.clubMemberInfo == nil or not dropdownMenu.clubMemberInfo.isSelf or IsGuildLeader() then
		return false; 
	end
	return true; 
end

UnitPopupPartyLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPartyLeaveButtonMixin:GetText()
	return PARTY_LEAVE; 
end 

function UnitPopupPartyLeaveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local _, instanceType = IsInInstance();
	if ( not IsInGroup() or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or (instanceType == "pvp") or (instanceType == "arena") ) then
		return false;
	end
	return true;
end

function UnitPopupPartyLeaveButtonMixin:IsEnabled()
	return IsInGroup();
end

function UnitPopupPartyLeaveButtonMixin:OnClick()
	C_PartyInfo.LeaveParty();
end

UnitPopupPartyInstanceLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPartyInstanceLeaveButtonMixin:GetText()
	return INSTANCE_PARTY_LEAVE; 
end 

-- Overload in UnitPopupButtons
function UnitPopupPartyInstanceLeaveButtonMixin:CanShow()
end

function UnitPopupPartyInstanceLeaveButtonMixin:IsEnabled()
	return IsInGroup();
end

function UnitPopupPartyInstanceLeaveButtonMixin:OnClick()
	ConfirmOrLeaveLFGParty();
end

UnitPopupFollowButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupFollowButtonMixin:GetText()
	return FOLLOW; 
end 

function UnitPopupFollowButtonMixin:GetInteractDistance()
	return 4; 
end 

function UnitPopupFollowButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return UnitPopupSharedUtil.CanCooperate() and UnitPopupSharedUtil.IsPlayer()
end

function UnitPopupFollowButtonMixin:IsEnabled()
	return not UnitIsDead("player");
end

function UnitPopupFollowButtonMixin:OnClick()
	FollowUnit(UnitPopupSharedUtil.GetFullPlayerName(), true);
end

UnitPopupPetDismissButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPetDismissButtonMixin:GetText()
	return PET_DISMISS; 
end 

function UnitPopupPetDismissButtonMixin:CanShow()
	if( ( PetCanBeAbandoned() and not IsSpellKnown(HUNTER_DISMISS_PET) ) or not PetCanBeDismissed() ) then
		return false;
	end
	return true; 
end

function UnitPopupPetDismissButtonMixin:OnClick()
	if ( PetCanBeAbandoned() ) then
		CastSpellByID(HUNTER_DISMISS_PET);
	else
		PetDismiss();
	end
end

UnitPopupPetAbandonButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPetAbandonButtonMixin:GetText()
	return PET_ABANDON; 
end 

function UnitPopupPetAbandonButtonMixin:CanShow()
	if( not PetCanBeAbandoned() or not PetHasActionBar() ) then
		return false;
	end
	return true; 
end

function UnitPopupPetAbandonButtonMixin:OnClick()
	StaticPopup_Show("ABANDON_PET");
end


UnitPopupPetRenameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPetRenameButtonMixin:GetText()
	return PET_RENAME; 
end 

function UnitPopupPetRenameButtonMixin:CanShow()
	if( not PetCanBeAbandoned() or not PetCanBeRenamed() ) then
		return false;
	end
	return true; 
end

function UnitPopupPetRenameButtonMixin:OnClick()
	StaticPopup_Show("RENAME_PET");
end

UnitPopupPetShowInJournalButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPetShowInJournalButtonMixin:GetText()
	return PET_SHOW_IN_JOURNAL; 
end 

function UnitPopupPetShowInJournalButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if (not CollectionsJournal) then
		CollectionsJournal_LoadUI();
	end
	if (not CollectionsJournal:IsShown()) then
		ShowUIPanel(CollectionsJournal);
	end
	CollectionsJournal_SetTab(CollectionsJournal, 2);
	PetJournal_SelectSpecies(PetJournal, UnitBattlePetSpeciesID(dropdownMenu.unit));
end

UnitPopupResetInstancesButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupResetInstancesButtonMixin:GetText()
	return RESET_INSTANCES; 
end 

function UnitPopupResetInstancesButtonMixin:OnClick()
	StaticPopup_Show("CONFIRM_RESET_INSTANCES");
end

function UnitPopupResetInstancesButtonMixin:CanShow()
	local inInstance = IsInInstance();
	if ( ( IsInGroup() and not UnitIsGroupLeader("player")) or inInstance) then
		return false;
	end
	return true;
end 

function UnitPopupResetInstancesButtonMixin:IsEnabled()
	local inInstance = IsInInstance();
	if ((IsInGroup() and not UnitIsGroupLeader("player")) or inInstance or UnitPopupSharedUtil.HasLFGRestrictions()) then
		return false;
	end
	return true;
end

UnitPopupResetChallengeModeButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupResetChallengeModeButtonMixin:GetText()
	return RESET_CHALLENGE_MODE; 
end 

function UnitPopupResetChallengeModeButtonMixin:OnClick()
	StaticPopup_Show("CONFIRM_RESET_CHALLENGE_MODE");
end

function UnitPopupResetChallengeModeButtonMixin:CanShow()
	local inInstance = IsInInstance();
	if (not inInstance or not C_ChallengeMode.IsChallengeModeActive() or (IsInGroup() and not UnitIsGroupLeader("player"))) then
		return false;
	end
	return true;
end 

function UnitPopupResetChallengeModeButtonMixin:IsEnabled()
	local _, _, energized = C_ChallengeMode.GetActiveKeystoneInfo();
	if (energized) then
		return false;
	end
	return true; 
end

UnitPopupConvertToRaidButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupConvertToRaidButtonMixin:GetText()
	return CONVERT_TO_RAID; 
end 

--Overriden in UnitPopupButtons
function UnitPopupConvertToRaidButtonMixin:OnClick()
end

function UnitPopupConvertToRaidButtonMixin:CanShow()
	if ( not IsInGroup() or IsInRaid() or not UnitIsGroupLeader("player") or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return false;
	end
	return true;
end 

UnitPopupConvertToPartyButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupConvertToPartyButtonMixin:GetText()
	return CONVERT_TO_PARTY; 
end 

--Overriden in UnitPopupButtons
function UnitPopupConvertToPartyButtonMixin:OnClick()
end

function UnitPopupConvertToPartyButtonMixin:CanShow()
	if ( not IsInRaid() or not UnitIsGroupLeader("player") or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return false;
	end
	return true;
end 

function UnitPopupConvertToPartyButtonMixin:IsEnabled()
	if ( GetNumGroupMembers() > MEMBERS_PER_RAID_GROUP ) then
		return false; 
	end
	return true; 
end

UnitPopupReportButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupReportButtonMixin:CanShow()
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local isValidPlayerLocation = UnitPopupSharedUtil:IsValidPlayerLocation(playerLocation);
	return isValidPlayerLocation and C_ReportSystem.CanReportPlayer(playerLocation);
end

UnitPopupReportGroupMemberButtonMixin = CreateFromMixins(UnitPopupReportButtonMixin);
function UnitPopupReportGroupMemberButtonMixin:GetText()
	return REPORT_GROUP_MEMBER; 
end 

function UnitPopupReportGroupMemberButtonMixin:GetReportType()
	return Enum.ReportType.GroupMember;
end

function UnitPopupReportGroupMemberButtonMixin:OnClick()
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local reportInfo = ReportInfo:CreateReportInfoFromType(self:GetReportType())
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	ReportFrame:InitiateReport(reportInfo, UnitPopupSharedUtil.GetFullPlayerName(), playerLocation, dropdownMenu.bnetIDAccount ~= nil);
end

function UnitPopupReportGroupMemberButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return UnitPopupReportButtonMixin.CanShow(self);
end 

UnitPopupReportPvpScoreboardButtonMixin = CreateFromMixins(UnitPopupReportGroupMemberButtonMixin);
function UnitPopupReportPvpScoreboardButtonMixin:GetText()
	return REPORT_PVP_SCOREBOARD;
end 

function UnitPopupReportPvpScoreboardButtonMixin:GetReportType()
	return Enum.ReportType.PvPScoreboard;
end

UnitPopupReportInWorldButtonMixin = CreateFromMixins(UnitPopupReportGroupMemberButtonMixin);
function UnitPopupReportInWorldButtonMixin:GetText()
	return REPORT_IN_WORLD_PLAYER;
end 

function UnitPopupReportInWorldButtonMixin:GetReportType()
	return Enum.ReportType.InWorld;
end

UnitPopupReportFriendButtonMixin = CreateFromMixins(UnitPopupReportGroupMemberButtonMixin);
function UnitPopupReportFriendButtonMixin:GetText()
	return REPORT_IN_WORLD_PLAYER; 
end 

function UnitPopupReportFriendButtonMixin:GetReportType()
	return Enum.ReportType.Friend;
end


function UnitPopupReportFriendButtonMixin:CanShow()
	if (not UnitPopupReportButtonMixin.CanShow(self)) then 
		return false; 
	end 
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	return not playerLocation:IsChatLineID() and not playerLocation:IsCommunityData(); 
end

UnitPopupReportClubMemberButtonMixin = CreateFromMixins(UnitPopupReportGroupMemberButtonMixin);
function UnitPopupReportClubMemberButtonMixin:GetText()
	return REPORT_CLUB_MEMBER; 
end 

function UnitPopupReportClubMemberButtonMixin:GetReportType()
	return Enum.ReportType.ClubMember;
end

UnitPopupReportChatButtonMixin = CreateFromMixins(UnitPopupReportGroupMemberButtonMixin);
function UnitPopupReportChatButtonMixin:GetText()
	return REPORT_CHAT; 
end 

function UnitPopupReportChatButtonMixin:CanShow()
	if (not UnitPopupReportButtonMixin.CanShow(self)) then 
		return false; 
	end 
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	return playerLocation:IsChatLineID() or playerLocation:IsCommunityData(); 
end

function UnitPopupReportChatButtonMixin:GetReportType()
	return Enum.ReportType.Chat;
end

UnitPopupReportPetButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupReportPetButtonMixin:GetText()
	return REPORT_PET_NAME; 
end 

function UnitPopupReportPetButtonMixin:GetReportType()
	return Enum.ReportType.Pet;
end

function UnitPopupReportPetButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local guid = UnitPopupSharedUtil.GetGUID();
	local reportInfo = ReportInfo:CreatePetReportInfo(self:GetReportType(), guid)
	ReportFrame:InitiateReport(reportInfo, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupReportBattlePetButtonMixin = CreateFromMixins(UnitPopupReportPetButtonMixin);
function UnitPopupReportBattlePetButtonMixin:GetReportType()
	return Enum.ReportType.BattlePet;
end

UnitPopupCopyCharacterNameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCopyCharacterNameButtonMixin:GetText()
	return COPY_CHARACTER_NAME; 
end 

function UnitPopupCopyCharacterNameButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	CopyToClipboard(dropdownMenu.name);
end 

function UnitPopupCopyCharacterNameButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local isLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer();
	if (isLocalPlayer or (playerLocation and playerLocation:IsBattleNetGUID())) then
		return false;	
	end
	return true;
end

UnitPopupDungeonDifficultyButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupDungeonDifficultyButtonMixin:GetText()
	return DUNGEON_DIFFICULTY;
end 

function UnitPopupDungeonDifficultyButtonMixin:IsNested()
	return true; 
end 

-- Overload in UnitPopupButtons
function UnitPopupDungeonDifficultyButtonMixin:GetButtons()
end 

UnitPopupDungeonDifficulty1ButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupDungeonDifficulty1ButtonMixin:GetText()
	return PLAYER_DIFFICULTY1; 
end 

function UnitPopupDungeonDifficulty1ButtonMixin:OnClick()
	SetDungeonDifficultyID(self:GetDifficultyID());
end

function UnitPopupDungeonDifficulty1ButtonMixin:IsCheckable()
	return true; 
end 

function UnitPopupDungeonDifficulty1ButtonMixin:GetDifficultyID()
	return 1;
end 

function UnitPopupDungeonDifficulty1ButtonMixin:IsChecked()
	local dungeonDifficultyID = GetDungeonDifficultyID();
	if ( dungeonDifficultyID == self:GetDifficultyID() ) then
		return true;
	end
	return false; 
end

function UnitPopupDungeonDifficulty1ButtonMixin:IsDisabled()
	local inInstance = IsInInstance();
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or inInstance ) then
		return true;
	end
	return false;
end	

function UnitPopupDungeonDifficulty1ButtonMixin:IsEnabled()
	local inInstance, instanceType = IsInInstance();
	if(inInstance and instanceType == "raid") then
		return false; 
	end 
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or inInstance or UnitPopupSharedUtil.HasLFGRestrictions()) then
		return false; 
	end
	return true;
end

UnitPopupDungeonDifficulty2ButtonMixin = CreateFromMixins(UnitPopupDungeonDifficulty1ButtonMixin);
function UnitPopupDungeonDifficulty2ButtonMixin:GetText()
	return PLAYER_DIFFICULTY2; 
end 

function UnitPopupDungeonDifficulty2ButtonMixin:GetDifficultyID()
	return 2;
end

---------------------- Raid Difficulty Buttons ----------------------------------------
UnitPopupRaidDifficultyButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRaidDifficultyButtonMixin:GetText()
	return RAID_DIFFICULTY;
end 

function UnitPopupRaidDifficultyButtonMixin:IsNested()
	return true; 
end 

function UnitPopupRaidDifficultyButtonMixin:GetButtons()
	return { 
		UnitPopupRaidDifficulty1ButtonMixin, 
		UnitPopupRaidDifficulty2ButtonMixin,
		UnitPopupRaidDifficulty3ButtonMixin,
		UnitPopupLegacyRaidSubsectionTitle,
		UnitPopupLegacyRaidDifficulty1ButtonMixin, 
		UnitPopupLegacyRaidDifficulty2ButtonMixin,
	}
end 

UnitPopupRaidDifficulty1ButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRaidDifficulty1ButtonMixin:GetText()
	return PLAYER_DIFFICULTY1; 
end 

function UnitPopupRaidDifficulty1ButtonMixin:OnClick()
	local raidDifficultyID = self:GetDifficultyID();
	SetRaidDifficulties(true, raidDifficultyID);
end

function UnitPopupRaidDifficulty1ButtonMixin:IsCheckable()
	return true; 
end 

function UnitPopupRaidDifficulty1ButtonMixin:GetDifficultyID()
	return 14;
end 

UnitPopupRaidDifficulty2ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);
function UnitPopupRaidDifficulty2ButtonMixin:GetText()
	return PLAYER_DIFFICULTY2; 
end 

function UnitPopupRaidDifficulty2ButtonMixin:GetDifficultyID()
	return 15;
end 

function UnitPopupRaidDifficulty2ButtonMixin:IsEnabled()
	return UnitPopupRaidDifficulty1ButtonMixin.IsEnabled(self);
end 

function UnitPopupRaidDifficulty2ButtonMixin:IsDisabled()
	return UnitPopupRaidDifficulty1ButtonMixin.IsDisabled(self);
end 

function UnitPopupRaidDifficulty2ButtonMixin:IsChecked()
	return UnitPopupRaidDifficulty1ButtonMixin.IsChecked(self);
end 

UnitPopupRaidDifficulty3ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);
function UnitPopupRaidDifficulty3ButtonMixin:GetText()
	return PLAYER_DIFFICULTY6; 
end 

function UnitPopupRaidDifficulty3ButtonMixin:GetDifficultyID()
	return 16;
end 

function UnitPopupRaidDifficulty3ButtonMixin:IsEnabled()
	return UnitPopupRaidDifficulty1ButtonMixin.IsEnabled(self);
end 

function UnitPopupRaidDifficulty3ButtonMixin:IsDisabled()
	return UnitPopupRaidDifficulty1ButtonMixin.IsDisabled(self);
end 

function UnitPopupRaidDifficulty3ButtonMixin:IsChecked()
	return UnitPopupRaidDifficulty1ButtonMixin.IsChecked(self);
end 

UnitPopupLegacyRaidDifficulty1ButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLegacyRaidDifficulty1ButtonMixin:GetText()
	return RAID_DIFFICULTY1; 
end 

function UnitPopupLegacyRaidDifficulty1ButtonMixin:OnClick()
	local raidDifficultyID = self:GetDifficultyID();
	SetRaidDifficulties(false, raidDifficultyID);
end

function UnitPopupLegacyRaidDifficulty1ButtonMixin:IsCheckable()
	return true; 
end 

function UnitPopupLegacyRaidDifficulty1ButtonMixin:GetDifficultyID()
	return 3;
end 

function UnitPopupLegacyRaidDifficulty1ButtonMixin:IsChecked()
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance ) then
		if ( NormalizeLegacyDifficultyID(instanceDifficultyID) == self:GetDifficultyID() ) then
			return true;
		end
	else
		local raidDifficultyID = GetLegacyRaidDifficultyID();
		if ( NormalizeLegacyDifficultyID(raidDifficultyID) == self:GetDifficultyID() ) then
			return true;
		end
	end
	return false; 
end

function UnitPopupLegacyRaidDifficulty1ButtonMixin:IsDisabled()
	local inInstance, instanceType = IsInInstance();
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or inInstance  or GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic ) then
		return true;
	end
	
	local toggleDifficultyID;
	local _, instanceType, instanceDifficultyID,  _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if ( toggleDifficultyID and not GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic and CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID()) ) then
		return false;
	end

	return false; 
end	

function UnitPopupLegacyRaidDifficulty1ButtonMixin:IsEnabled()
	local inInstance, instanceType = IsInInstance();
	local isPublicParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE); 
	if( isPublicParty or (inInstance and instanceType ~= "raid") ) then
		return false;
	end
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or isPublicParty or inInstance or GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic) then
		return false;
	end

	local toggleDifficultyID;
	local _, _, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if (toggleDifficultyID) then
		return false; 
	end
	return true; 
end

function UnitPopupLegacyRaidDifficulty1ButtonMixin:IsClickable()
	local toggleDifficultyID;
	local _, _, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if(toggleDifficultyID) then 
		if (IsLegacyDifficulty(toggleDifficultyID)) then
			return not CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID());
		end
	end
	return true; 
end 

UnitPopupLegacyRaidDifficulty2ButtonMixin = CreateFromMixins(UnitPopupLegacyRaidDifficulty1ButtonMixin);
function UnitPopupLegacyRaidDifficulty2ButtonMixin:GetText()
	return RAID_DIFFICULTY2; 
end 

function UnitPopupLegacyRaidDifficulty2ButtonMixin:GetDifficultyID()
	return 4;
end 


UnitPopupPvpFlagButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPvpFlagButtonMixin:GetText()
	return PVP_FLAG; 
end 

function UnitPopupPvpFlagButtonMixin:IsNested()
	return 1;
end

function UnitPopupPvpFlagButtonMixin:IsEnabled()
	return true; 
end

function UnitPopupPvpFlagButtonMixin:TooltipTitle()
	return nil;
end 

function UnitPopupPvpFlagButtonMixin:TooltipInstruction()
	return nil;
end 

function UnitPopupPvpFlagButtonMixin:TooltipWarning()
	return nil;
end	

function UnitPopupPvpFlagButtonMixin:HasArrow()
	return true; 
end 

function UnitPopupPvpFlagButtonMixin:GetButtons()
	return { 
		UnitPopupPvpEnableButtonMixin, 
		UnitPopupPvpDisableButtonMixin,
	}
end 

UnitPopupPvpEnableButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPvpEnableButtonMixin:GetText()
	return ENABLE; 
end 

function UnitPopupPvpEnableButtonMixin:IsCheckable()
	return true; 
end

function UnitPopupPvpEnableButtonMixin:IsEnabled()
	return UnitPopupPvpFlagButtonMixin.IsEnabled(self); 
end

function UnitPopupPvpEnableButtonMixin:IsChecked()
	return GetPVPDesired();
end	

function UnitPopupPvpEnableButtonMixin:OnClick()
	SetPVP(1);
end

UnitPopupPvpDisableButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPvpDisableButtonMixin:GetText()
	return DISABLE; 
end 

function UnitPopupPvpDisableButtonMixin:IsCheckable()
	return true; 
end

function UnitPopupPvpDisableButtonMixin:IsEnabled()
	return UnitPopupPvpFlagButtonMixin.IsEnabled(self); 
end

function UnitPopupPvpDisableButtonMixin:IsChecked()
	return not GetPVPDesired();
end	

function UnitPopupPvpDisableButtonMixin:OnClick()
	SetPVP(nil);
end

UnitPopupSelectLootSpecializationButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSelectLootSpecializationButtonMixin:GetText()
	return SELECT_LOOT_SPECIALIZATION; 
end 

function UnitPopupSelectLootSpecializationButtonMixin:IsNested()
	return true;
end

function UnitPopupSelectLootSpecializationButtonMixin:GetTooltipText()
	return SELECT_LOOT_SPECIALIZATION_TOOLTIP;
end

function UnitPopupSelectLootSpecializationButtonMixin:CanShow()
	return GetSpecialization()
end

function UnitPopupSelectLootSpecializationButtonMixin:GetButtons()
	return { 
		UnitPopupLootSpecializationDefaultButtonMixin,
		UnitPopupLootSpecialization1ButtonMixin, 
		UnitPopupLootSpecialization2ButtonMixin,
		UnitPopupLootSpecialization3ButtonMixin,
		UnitPopupLootSpecialization4ButtonMixin,
	}
end 


UnitPopupLootSpecializationDefaultButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLootSpecializationDefaultButtonMixin:GetText()
	local specIndex = GetSpecialization();
	local sex = UnitSex("player");
	local text; 
	if ( specIndex) then
		local specID, specName = GetSpecializationInfo(specIndex, nil, nil, nil, sex);
		if ( specName ) then
			text = format(LOOT_SPECIALIZATION_DEFAULT, specName);
		end
	end
	return text; 
end

function UnitPopupLootSpecializationDefaultButtonMixin:IsCheckable()
	return true; 
end

function UnitPopupLootSpecializationDefaultButtonMixin:IsChecked()
	return GetLootSpecialization() == self:GetSpecID();
end 

function UnitPopupLootSpecializationDefaultButtonMixin:GetSpecID()
	return 0;
end		

function UnitPopupLootSpecializationDefaultButtonMixin:OnClick()
	SetLootSpecialization(self:GetSpecID());
end

UnitPopupLootSpecialization1ButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLootSpecialization1ButtonMixin:GetText()
	local specIndex = self:GetSpecIndex();
	local sex = UnitSex("player");
	local text = ""; 
	if ( specIndex) then
		local specID, specName = GetSpecializationInfo(specIndex, nil, nil, nil, sex);
		if ( specName ) then
			text = specName;
		end
	end
	return text; 
end

function UnitPopupLootSpecialization1ButtonMixin:GetSpecIndex()
	return 1; 
end

function UnitPopupLootSpecialization1ButtonMixin:GetSpecID()
	local sex = UnitSex("player");
	local specID = GetSpecializationInfo(self:GetSpecIndex(), nil, nil, nil, sex);
	if(specID) then 
		return specID
	end
	return -1;
end

function UnitPopupLootSpecialization1ButtonMixin:IsCheckable()
	return true; 
end

function UnitPopupLootSpecialization1ButtonMixin:IsChecked()
	return GetLootSpecialization() == self:GetSpecID();
end 

function UnitPopupLootSpecialization1ButtonMixin:CanShow()
	local specID = self:GetSpecID();
	return specID > -1; 
end

function UnitPopupLootSpecialization1ButtonMixin:OnClick()
	SetLootSpecialization(self:GetSpecID());
end

UnitPopupLootSpecialization2ButtonMixin = CreateFromMixins(UnitPopupLootSpecialization1ButtonMixin);
function UnitPopupLootSpecialization2ButtonMixin:GetSpecIndex()
	return 2; 
end

UnitPopupLootSpecialization3ButtonMixin = CreateFromMixins(UnitPopupLootSpecialization1ButtonMixin);
function UnitPopupLootSpecialization3ButtonMixin:GetSpecIndex()
	return 3; 
end

UnitPopupLootSpecialization4ButtonMixin = CreateFromMixins(UnitPopupLootSpecialization1ButtonMixin);
function UnitPopupLootSpecialization4ButtonMixin:GetSpecIndex()
	return 4; 
end

UnitPopupSetRaidLeaderButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidLeaderButtonMixin:GetText()
	return SET_RAID_LEADER; 
end 

function UnitPopupSetRaidLeaderButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not UnitIsGroupLeader("player") or not UnitPopupSharedUtil.IsPlayer() or UnitIsGroupLeader(dropdownMenu.unit) or not dropdownMenu.name ) then
		return false; 
	end
	return true;
end	

function UnitPopupSetRaidLeaderButtonMixin:OnClick()
	PromoteToLeader(UnitPopupSharedUtil.GetFullPlayerName(), true)
end

UnitPopupSetRaidAssistButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidAssistButtonMixin:GetText()
	return SET_RAID_ASSISTANT; 
end 

function UnitPopupSetRaidAssistButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isLeader = UnitIsGroupLeader("player");
	if ( not isLeader or not UnitPopupSharedUtil.IsPlayer() or IsEveryoneAssistant() ) then
		return false;
	elseif ( isLeader ) then
		if ( UnitIsGroupAssistant(dropdownMenu.unit) ) then
			return false; 
		end
	end

	return true;
end	

function UnitPopupSetRaidAssistButtonMixin:OnClick()
	PromoteToAssistant(UnitPopupSharedUtil.GetFullPlayerName(), true)
end

UnitPopupSetRaidMainTankButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidMainTankButtonMixin:GetText()
	return SET_MAIN_TANK; 
end 

function UnitPopupSetRaidMainTankButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");

	 if ( not issecure() or (not isLeader and not isAssistant) or not UnitPopupSharedUtil.IsPlayer() or GetPartyAssignment("MAINTANK", dropdownMenu.unit) ) then
		return false; 
	end

	return true;
end	

function UnitPopupSetRaidMainTankButtonMixin:OnClick()
	SetPartyAssignment("MAINTANK", UnitPopupSharedUtil.GetFullPlayerName(), true);
end

UnitPopupSetRaidMainAssistButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidMainAssistButtonMixin:GetText()
	return SET_MAIN_ASSIST; 
end 

function UnitPopupSetRaidMainAssistButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");

	 if ( not issecure() or (not isLeader and not isAssistant) or not UnitPopupSharedUtil.IsPlayer() or GetPartyAssignment("MAINASSIST", dropdownMenu.unit) ) then
		return false; 
	end

	return true;
end	

function UnitPopupSetRaidMainAssistButtonMixin:OnClick()
	SetPartyAssignment("MAINASSIST", UnitPopupSharedUtil.GetFullPlayerName(), true);
end

UnitPopupSetRaidDemoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidDemoteButtonMixin:GetText()
	return DEMOTE; 
end 

function UnitPopupSetRaidDemoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");


	if ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or not UnitPopupSharedUtil.IsPlayer() ) then
		return false; 
	elseif ( not GetPartyAssignment("MAINTANK", dropdownMenu.unit) and not GetPartyAssignment("MAINASSIST", dropdownMenu.unit) ) then
		if ( not isLeader  and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
			return false;
		elseif ( isLeader or isAssistant ) then
			if ( UnitIsGroupLeader(dropdownMenu.unit) or not UnitIsGroupAssistant(dropdownMenu.unit) or IsEveryoneAssistant()) then
				return false; 
			end
		end
	end

	return true;
end	

function UnitPopupSetRaidDemoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local fullname = UnitPopupSharedUtil.GetFullPlayerName(); 
	local isLeader = UnitIsGroupLeader("player");
	if ( isLeader and UnitIsGroupAssistant(dropdownMenu.unit) ) then
		DemoteAssistant(UnitPopupSharedUtil.GetFullPlayerName(), true);
	end
	if ( GetPartyAssignment("MAINTANK", fullname, true) ) then
		ClearPartyAssignment("MAINTANK", fullname, true);
	elseif ( GetPartyAssignment("MAINASSIST", fullname, true) ) then
		ClearPartyAssignment("MAINASSIST", fullname, true);
	end
end

UnitPopupSetRaidRemoveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRaidRemoveButtonMixin:GetText()
	return REMOVE; 
end 

function UnitPopupSetRaidRemoveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");


	if (UnitPopupSharedUtil.HasLFGRestrictions() or not UnitPopupSharedUtil.IsPlayer() ) then
		return false; 
	elseif ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or (instanceType == "pvp") or (instanceType == "arena") ) then
		return false; 
	elseif ( not isLeader and (isAssistant and (UnitIsGroupAssistant(dropdownMenu.unit) or UnitIsGroupLeader(dropdownMenu.unit)))) then
		return false; 
	elseif ( isLeader and UnitIsUnit(dropdownMenu.unit, "player") ) then
		return false; 
	end

	return true;
end

function UnitPopupSetRaidRemoveButtonMixin:OnClick()
	UninviteUnit(UnitPopupSharedUtil.GetFullPlayerName(), nil, 1);
end

UnitPopupPvpReportAfkButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPvpReportAfkButtonMixin:GetText()
	return REPORT_PLAYER; 
end 

--Override in UnitPopupButtons
function UnitPopupPvpReportAfkButtonMixin:CanShow()
	
end	

function UnitPopupPvpReportAfkButtonMixin:OnClick()
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.PvP);
	ReportFrame:InitiateReport(reportInfo, UnitPopupSharedUtil.GetFullPlayerName(), playerLocation);
end

UnitPopupRafSummonButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRafSummonButtonMixin:GetText()
	local start, duration = GetSummonFriendCooldown();
	local remaining = start + duration - GetTime();
	if ( remaining > 0 ) then
		return format(RAF_SUMMON_WITH_COOLDOWN, SecondsToTime(remaining, true));
	end
	return RAF_SUMMON; 
end 

--Override in UnitPopupButtons
function UnitPopupRafSummonButtonMixin:CanShow()
end	

function UnitPopupRafSummonButtonMixin:IsEnabled()
	return UnitPopupSharedUtil.GetGUID() and true or false; 
end

--Override in UnitPopupButtons
function UnitPopupRafSummonButtonMixin:OnClick()
end

UnitPopupVehicleLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVehicleLeaveButtonMixin:GetText()
	return VEHICLE_LEAVE; 
end 

function UnitPopupVehicleLeaveButtonMixin:CanShow()
	return CanExitVehicle();
end	

function UnitPopupVehicleLeaveButtonMixin:OnClick()
	VehicleExit();
end

UnitPopupSetFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetFocusButtonMixin:GetText()
	return SET_FOCUS; 
end 

function UnitPopupSetFocusButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	FocusUnit(dropdownMenu.unit);
end

UnitPopupClearFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupClearFocusButtonMixin:GetText()
	return CLEAR_FOCUS; 
end 

function UnitPopupClearFocusButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	ClearFocus(dropdownMenu.unit);
end

UnitPopupLargeFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLargeFocusButtonMixin:GetText()
	return FULL_SIZE_FOCUS_FRAME_TEXT; 
end 

function UnitPopupLargeFocusButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu == FocusFrameDropDown;
end	

function UnitPopupLargeFocusButtonMixin:OnClick()
	local setting = GetCVarBool("fullSizeFocusFrame");
	setting = not setting;
	SetCVar("fullSizeFocusFrame", setting and "1" or "0" )
	FocusFrame_SetSmallSize(not setting, true);
end

function UnitPopupLargeFocusButtonMixin:IsCheckable()
	return true; 
end	

function UnitPopupLargeFocusButtonMixin:IsChecked()
	return GetCVarBool("fullSizeFocusFrame"); 
end	

function UnitPopupLargeFocusButtonMixin:IsNotRadio()
	return true; 
end		
UnitPopupLockFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLockFocusButtonMixin:GetText()
	return LOCK_FOCUS_FRAME; 
end 

function UnitPopupLockFocusButtonMixin:CanShow()
	return not FocusFrame_IsLocked()
end	

function UnitPopupLockFocusButtonMixin:OnClick()
	FocusFrame_SetLock(true);
end

UnitPopupUnlockFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupUnlockFocusButtonMixin:GetText()
	return UNLOCK_FOCUS_FRAME; 
end 

function UnitPopupUnlockFocusButtonMixin:CanShow()
	return FocusFrame_IsLocked()
end	

function UnitPopupUnlockFocusButtonMixin:OnClick()
	FocusFrame_SetLock(false);
end

UnitPopupMoveFocusButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupMoveFocusButtonMixin:GetText()
	return MOVE_FRAME; 

end 

function UnitPopupMoveFocusButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu == FocusFrameDropDown;
end	

function UnitPopupMoveFocusButtonMixin:IsNested()
	return true;	
end

function UnitPopupMoveFocusButtonMixin:GetButtons()
	return {
		UnitPopupUnlockFocusButtonMixin, 
		UnitPopupLockFocusButtonMixin,
		UnitPopupFocusFrameBuffsOnTopButtonMixin,
	}
end	

UnitPopupFocusFrameBuffsOnTopButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupFocusFrameBuffsOnTopButtonMixin:GetText()
	return BUFFS_ON_TOP; 
end 

function UnitPopupFocusFrameBuffsOnTopButtonMixin:IsCheckable()
	return true; 
end	

function UnitPopupFocusFrameBuffsOnTopButtonMixin:IsChecked()
	return FOCUS_FRAME_BUFFS_ON_TOP;
end

function UnitPopupFocusFrameBuffsOnTopButtonMixin:OnClick()
	FOCUS_FRAME_BUFFS_ON_TOP = not FOCUS_FRAME_BUFFS_ON_TOP;
	FocusFrame_UpdateBuffsOnTop();
end

UnitPopupMovePlayerFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupMovePlayerFrameButtonMixin:GetText()
	return MOVE_FRAME; 
end 

function UnitPopupMovePlayerFrameButtonMixin:IsNested()
	return true; 
end

function UnitPopupMovePlayerFrameButtonMixin:GetButtons()
	return { 
		UnitPopupUnlockPlayerFrameButtonMixin,
		UnitPopupLockPlayerFrameButtonMixin,
		UnitPopupResetPlayerFrameButtonMixin,
		UnitPopupPlayerFrameShowCastBarButtonMixin,
	}
end

function UnitPopupMovePlayerFrameButtonMixin:CanShow()
	return UnitPopupSharedUtil.GetCurrentDropdownMenu() == PlayerFrameDropDown;
end

UnitPopupLockPlayerFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLockPlayerFrameButtonMixin:GetText()
	return LOCK_FRAME; 
end 

function UnitPopupLockPlayerFrameButtonMixin:CanShow()
	return PLAYER_FRAME_UNLOCKED
end

function UnitPopupLockPlayerFrameButtonMixin:OnClick()
	PlayerFrame_SetLocked(true);
end

UnitPopupUnlockPlayerFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupUnlockPlayerFrameButtonMixin:GetText()
	return UNLOCK_FRAME; 
end 

function UnitPopupUnlockPlayerFrameButtonMixin:CanShow()
	return not PLAYER_FRAME_UNLOCKED
end

function UnitPopupUnlockPlayerFrameButtonMixin:OnClick()
	PlayerFrame_SetLocked(false);
end

UnitPopupResetPlayerFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupResetPlayerFrameButtonMixin:GetText()
	return RESET_POSITION; 
end 

function UnitPopupResetPlayerFrameButtonMixin:OnClick()
	PlayerFrame_ResetUserPlacedPosition();
end

UnitPopupPlayerFrameShowCastBarButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupPlayerFrameShowCastBarButtonMixin:GetText()
	return PLAYER_FRAME_SHOW_CASTBARS; 
end 

function UnitPopupPlayerFrameShowCastBarButtonMixin:IsCheckable()
	return true;
end

function UnitPopupPlayerFrameShowCastBarButtonMixin:IsNotRadio()
	return true;
end

function UnitPopupPlayerFrameShowCastBarButtonMixin:IsChecked()
	return PLAYER_FRAME_CASTBARS_SHOWN;
end 

function UnitPopupPlayerFrameShowCastBarButtonMixin:OnClick()
	PLAYER_FRAME_CASTBARS_SHOWN = not PLAYER_FRAME_CASTBARS_SHOWN;
	if ( PLAYER_FRAME_CASTBARS_SHOWN ) then
		PlayerFrame_AttachCastBar();
	else
		PlayerFrame_DetachCastBar();
	end
end

UnitPopupMoveTargetFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupMoveTargetFrameButtonMixin:GetText()
	return MOVE_FRAME; 
end 

function UnitPopupMoveTargetFrameButtonMixin:IsNested()
	return true; 
end

function UnitPopupMoveTargetFrameButtonMixin:CanShow()
	return UnitPopupSharedUtil.GetCurrentDropdownMenu() == TargetFrameDropDown;
end

function UnitPopupMoveTargetFrameButtonMixin:GetButtons()
	return { 
		UnitPopupUnlockTargetFrameButtonMixin,
		UnitPopupLockTargetFrameButtonMixin,
		UnitPopupResetTargetFrameButtonMixin,
		UnitPopupTargetFrameBuffsOnTopButtonMixin,
	}
end

UnitPopupLockTargetFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupLockTargetFrameButtonMixin:GetText()
	return LOCK_FRAME; 
end 

function UnitPopupLockTargetFrameButtonMixin:CanShow()
	return TARGET_FRAME_UNLOCKED
end

function UnitPopupLockTargetFrameButtonMixin:OnClick()
	TargetFrame_SetLocked(true);
end

UnitPopupUnlockTargetFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupUnlockTargetFrameButtonMixin:GetText()
	return UNLOCK_FRAME; 
end 

function UnitPopupUnlockTargetFrameButtonMixin:CanShow()
	return not TARGET_FRAME_UNLOCKED
end

function UnitPopupUnlockTargetFrameButtonMixin:OnClick()
	TargetFrame_SetLocked(false);
end

UnitPopupTargetFrameBuffsOnTopButtonMixin = CreateFromMixins(UnitPopupFocusFrameBuffsOnTopButtonMixin);
function UnitPopupTargetFrameBuffsOnTopButtonMixin:IsChecked()
	return TARGET_FRAME_BUFFS_ON_TOP;
end

function UnitPopupTargetFrameBuffsOnTopButtonMixin:OnClick()
	TARGET_FRAME_BUFFS_ON_TOP = not TARGET_FRAME_BUFFS_ON_TOP;
	TargetFrame_UpdateBuffsOnTop();
end

UnitPopupResetTargetFrameButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupResetTargetFrameButtonMixin:GetText()
	return RESET_POSITION; 
end 

function UnitPopupResetTargetFrameButtonMixin:OnClick()
	TargetFrame_ResetUserPlacedPosition();
end

UnitPopupAddFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAddFriendButtonMixin:GetText()
	return ADD_FRIEND; 
end 

function UnitPopupAddFriendButtonMixin:IsDisabledInKioskMode()
	return true; 
end

function UnitPopupAddFriendButtonMixin:OnClick()
	C_FriendList.AddFriend(UnitPopupSharedUtil.GetFullPlayerName());
end

function UnitPopupAddFriendButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( UnitPopupSharedUtil.HasBattleTag() or not UnitPopupSharedUtil.CanCooperate() or not UnitPopupSharedUtil.IsPlayer() or not UnitPopupSharedUtil.IsSameServerFromSelf() or C_FriendList.GetFriendInfo(UnitNameUnmodified(dropdownMenu.unit)) ) then
		return false
	end
	return true; 
end

UnitPopupAddFriendMenuButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAddFriendMenuButtonMixin:GetText()
	return ADD_FRIEND; 
end 

function UnitPopupAddFriendMenuButtonMixin:IsDisabledInKioskMode()
	return true; 
end

function UnitPopupAddFriendMenuButtonMixin:IsNested()
	return true; 
end

--Implementation differs from classic & mainline.. Implemented in UnitPopupButtons (Project Specific File)
function UnitPopupAddFriendMenuButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
	if (  UnitPopupSharedUtil.GetIsLocalPlayer() or not UnitPopupSharedUtil.HasBattleTag() or (not UnitPopupSharedUtil.IsPlayer() and not hasClubInfo and not dropdownMenu.isRafRecruit) ) then
		return false;
	end
	return true; 
end

function UnitPopupAddFriendMenuButtonMixin:GetButtons()
	return { 
		UnitPopupAddBtagFriendButtonMixin, 
		UnitPopupAddCharacterFriendButtonMixin,
	}
end 

UnitPopupAddCharacterFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAddCharacterFriendButtonMixin:GetText()
	return ADD_CHARACTER_FRIEND; 
end 

function UnitPopupAddCharacterFriendButtonMixin:IsDisabledInKioskMode()
	return true; 
end

function UnitPopupAddCharacterFriendButtonMixin:OnClick()
	C_FriendList.AddFriend(UnitPopupSharedUtil.GetFullPlayerName());
end

function UnitPopupAddCharacterFriendButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isSameServer = UnitPopupSharedUtil.IsSameServerFromSelf(); 
	if ( dropdownMenu.unit ~= nil ) then
		if ( not UnitCanCooperate("player", dropdownMenu.unit) ) then
			return false; 
		else
			-- disable if player is from another realm or already on friends list
			if ( not UnitIsSameServer(dropdownMenu.unit) or C_FriendList.GetFriendInfo(UnitNameUnmodified(dropdownMenu.unit)) ) then
				return false; 
			end
		end
	elseif dropdownMenu.clubMemberInfo then
		if not isSameServer or C_FriendList.GetFriendInfo(dropdownMenu.clubMemberInfo.name) then
			return false; 
		end
	elseif not isSameServer or not dropdownMenu.accountInfo or not dropdownMenu.accountInfo.gameAccountInfo.characterName or C_FriendList.GetFriendInfo(dropdownMenu.accountInfo.gameAccountInfo.characterName) then
		return false; 
	end
	return true; 
end

UnitPopupAddBtagFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAddBtagFriendButtonMixin:GetText()
	return SEND_BATTLETAG_REQUEST; 
end 

function UnitPopupAddBtagFriendButtonMixin:IsDisabledInKioskMode()
	return true; 
end

function UnitPopupAddBtagFriendButtonMixin:OnClick()
	local _, battleTag = BNGetInfo();
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not battleTag ) then
		StaticPopupSpecial_Show(CreateBattleTagFrame);
	elseif ( dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil ) then
		C_Club.SendBattleTagFriendRequest(dropdownMenu.clubInfo.clubId, dropdownMenu.clubMemberInfo.memberId);
	elseif dropdownMenu.accountInfo then
		BNSendFriendInvite(dropdownMenu.accountInfo.battleTag);
	else
		BNCheckBattleTagInviteToUnit(dropdownMenu.unit);
	end
	CloseDropDownMenus();
end

function UnitPopupAddBtagFriendButtonMixin:IsEnabled()
	if ( not UnitPopupSharedUtil:CanAddBNetFriend(UnitPopupSharedUtil.GetIsLocalPlayer(), UnitPopupSharedUtil.HasBattleTag(), UnitPopupSharedUtil.IsPlayer()) or not BNFeaturesEnabledAndConnected()) then
		return false; 
	end
	return true; 
end

UnitPopupAddGuildBtagFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAddGuildBtagFriendButtonMixin:GetText()
	return SEND_BATTLETAG_REQUEST; 
end 

function UnitPopupAddGuildBtagFriendButtonMixin:IsDisabledInKioskMode()
	return true; 
end

function UnitPopupAddGuildBtagFriendButtonMixin:OnClick()
	local _, battleTag = BNGetInfo();
	if ( not battleTag ) then
		StaticPopupSpecial_Show(CreateBattleTagFrame);
	else
		BNCheckBattleTagInviteToGuildMember(UnitPopupSharedUtil.GetFullPlayerName());
	end
	CloseDropDownMenus();
end

function UnitPopupAddGuildBtagFriendButtonMixin:IsEnabled()
	if ( not BNFeaturesEnabledAndConnected() ) then
		return false;
	end
	return true; 
end

--Implementation differs from classic & mainline.. Implemented in UnitPopupButtons (Project Specific File)
function UnitPopupAddGuildBtagFriendButtonMixin:CanShow()
end

UnitPopupRaidTargetButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRaidTargetButtonMixin:GetText()
	return RAID_TARGET_ICON; 
end 

function UnitPopupRaidTargetButtonMixin:IsNested()
	return true; 
end

function UnitPopupRaidTargetButtonMixin:GetButtons()
	return { 
		UnitPopupRaidTarget8ButtonMixin,
		UnitPopupRaidTarget7ButtonMixin,
		UnitPopupRaidTarget6ButtonMixin,
		UnitPopupRaidTarget5ButtonMixin, 
		UnitPopupRaidTarget4ButtonMixin,
		UnitPopupRaidTarget3ButtonMixin,
		UnitPopupRaidTarget2ButtonMixin,
		UnitPopupRaidTarget1ButtonMixin,
		UnitPopupRaidTargetNoneButtonMixin,
	}
end 

UnitPopupRaidTarget1ButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRaidTarget1ButtonMixin:GetText()
	return RAID_TARGET_1; 
end 

function UnitPopupRaidTarget1ButtonMixin:IsCheckable()
	return true; 
end

function UnitPopupRaidTarget1ButtonMixin:GetIcon()
	return "Interface\\TargetingFrame\\UI-RaidTargetingIcons"; 
end

function UnitPopupRaidTarget1ButtonMixin:GetRaidTargetIndex()
	return 1; 
end

function UnitPopupRaidTarget1ButtonMixin:IsChecked()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local activeRaidTargetIndex = GetRaidTargetIndex(dropdownMenu.unit);
	return activeRaidTargetIndex == self:GetRaidTargetIndex() 

end

function UnitPopupRaidTarget1ButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	SetRaidTargetIcon(dropdownMenu.unit, self:GetRaidTargetIndex());
end

function UnitPopupRaidTarget1ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0, 
		tCoordRight = 0.25,
		tCoordTop  = 0,
		tCoordBottom = 0.25,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget1ButtonMixin:GetColor()
	return {r = 1.0, g = 0.92, b = 0}; 
end

UnitPopupRaidTarget2ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget2ButtonMixin:GetText()
	return RAID_TARGET_2; 
end 

function UnitPopupRaidTarget2ButtonMixin:GetRaidTargetIndex()
	return 2; 
end

function UnitPopupRaidTarget2ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.25, 
		tCoordRight = 0.5,
		tCoordTop  = 0,
		tCoordBottom = 0.25,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget2ButtonMixin:GetColor()
	return {r = 0.98, g = 0.57, b = 0}; 
end

UnitPopupRaidTarget3ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget3ButtonMixin:GetText()
	return RAID_TARGET_3; 
end 

function UnitPopupRaidTarget3ButtonMixin:GetRaidTargetIndex()
	return 3; 
end

function UnitPopupRaidTarget3ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.5, 
		tCoordRight = 0.75,
		tCoordTop  = 0,
		tCoordBottom = 0.25,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget3ButtonMixin:GetColor()
	return {r = 0.83, g = 0.22, b = 0.9}; 
end

UnitPopupRaidTarget4ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget4ButtonMixin:GetText()
	return RAID_TARGET_4; 
end 

function UnitPopupRaidTarget4ButtonMixin:GetRaidTargetIndex()
	return 4; 
end

function UnitPopupRaidTarget4ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.75, 
		tCoordRight = 1,
		tCoordTop  = 0,
		tCoordBottom = 0.25,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget4ButtonMixin:GetColor()
	return {r = 0.04, g = 0.95, b = 0}; 
end	

UnitPopupRaidTarget5ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget5ButtonMixin:GetText()
	return RAID_TARGET_5; 
end 

function UnitPopupRaidTarget5ButtonMixin:GetRaidTargetIndex()
	return 5; 
end

function UnitPopupRaidTarget5ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0, 
		tCoordRight = .25,
		tCoordTop  = 0.25,
		tCoordBottom = 0.5,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget5ButtonMixin:GetColor()
	return {r = 0.7, g = 0.82, b = 0.875}; 
end

UnitPopupRaidTarget6ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget6ButtonMixin:GetText()
	return RAID_TARGET_6; 
end 

function UnitPopupRaidTarget6ButtonMixin:GetRaidTargetIndex()
	return 6; 
end

function UnitPopupRaidTarget6ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.25, 
		tCoordRight = .5,
		tCoordTop  = 0.25,
		tCoordBottom = 0.5,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget6ButtonMixin:GetColor()
	return {r = 0, g = 0.71, b = 1}; 
end

UnitPopupRaidTarget7ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget7ButtonMixin:GetText()
	return RAID_TARGET_7; 
end 

function UnitPopupRaidTarget7ButtonMixin:GetRaidTargetIndex()
	return 7; 
end

function UnitPopupRaidTarget7ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.5, 
		tCoordRight = .75,
		tCoordTop  = 0.25,
		tCoordBottom = 0.5,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget7ButtonMixin:GetColor()
	return {r = 1.0, g = 0.24, b = 0.168}; 
end	

UnitPopupRaidTarget8ButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTarget8ButtonMixin:GetText()
	return RAID_TARGET_8; 
end 

function UnitPopupRaidTarget8ButtonMixin:GetRaidTargetIndex()
	return 8; 
end

function UnitPopupRaidTarget8ButtonMixin:GetTextureCoords()
	local tCooordsTable = { 
		tCoordLeft = 0.75, 
		tCoordRight = 1,
		tCoordTop  = 0.25,
		tCoordBottom = 0.5,
	};
	return tCooordsTable;
end 

function UnitPopupRaidTarget8ButtonMixin:GetColor()
	return {r = 0.98, g = 0.98, b = 0.98}; 
end

UnitPopupRaidTargetNoneButtonMixin = CreateFromMixins(UnitPopupRaidTarget1ButtonMixin);
function UnitPopupRaidTargetNoneButtonMixin:GetText()
	return RAID_TARGET_NONE; 
end 

function UnitPopupRaidTargetNoneButtonMixin:GetRaidTargetIndex()
	return 0; 
end

function UnitPopupRaidTargetNoneButtonMixin:GetTextureCoords()
	return UnitPopupButtonBaseMixin.GetTextureCoords();
end 

function UnitPopupRaidTargetNoneButtonMixin:GetIcon()
	return UnitPopupButtonBaseMixin.GetIcon();
end 

function UnitPopupRaidTargetNoneButtonMixin:GetColor()
	return nil; 
end

UnitPopupChatPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupChatPromoteButtonMixin:GetText()
	return MAKE_MODERATOR; 
end 

function UnitPopupChatPromoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 

	if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
		return false; 
	else
		if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.moderator or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
			return false
		end
	end
	return true; 
end

function UnitPopupChatPromoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	ChannelModerator(dropdownMenu.channelName, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupChatDemoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupChatDemoteButtonMixin:GetText()
	return REMOVE_MODERATOR; 
end 

function UnitPopupChatDemoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 

	if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
		return false; 
	else
		if ( not IsDisplayChannelOwner() or dropdownMenu.owner or not dropdownMenu.moderator or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
			return false
		end
	end
	return true; 
end

function UnitPopupChatDemoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	ChannelUnmoderator(dropdownMenu.channelName, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupChatOwnerButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupChatOwnerButtonMixin:GetText()
	return CHAT_OWNER; 
end 

function UnitPopupChatOwnerButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 

	if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
		return false; 
	else
		if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
			return false
		end
	end
	return true; 
end

function UnitPopupChatOwnerButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	SetChannelOwner(dropdownMenu.channelName, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupChatKickButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupChatKickButtonMixin:GetText()
	return CHAT_KICK; 
end 

function UnitPopupChatKickButtonMixin:CanShow()
	return false; 
end

function UnitPopupChatKickButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	ChannelKick(dropdownMenu.channelName, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupChatBanButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupChatBanButtonMixin:GetText()
	return CHAT_BAN; 
end 

function UnitPopupChatBanButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	ChannelBan(dropdownMenu.channelName, UnitPopupSharedUtil.GetFullPlayerName());
end

UnitPopupGarrisonVisitButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGarrisonVisitButtonMixin:GetText()
	return (C_Garrison.IsUsingPartyGarrison() and GARRISON_RETURN) or GARRISON_VISIT_LEADER;
end 

--This function is overriden on mainline
function UnitPopupGarrisonVisitButtonMixin:CanShow()
	return C_Garrison.IsVisitGarrisonAvailable();
end

function UnitPopupGarrisonVisitButtonMixin:OnClick()
	C_Garrison.SetUsingPartyGarrison( not C_Garrison.IsUsingPartyGarrison());
end

UnitPopupVoiceChatButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoiceChatButtonMixin:GetText()
	return VOICE_CHAT; 
end 

function UnitPopupVoiceChatButtonMixin:IsNested()
	return true; 
end 

function UnitPopupVoiceChatButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local isValidPlayerLocation = UnitPopupSharedUtil:IsValidPlayerLocation(playerLocation);

	if not C_VoiceChat.CanPlayerUseVoiceChat() then
		return false; 
	elseif not (UnitPopupSharedUtil.GetIsLocalPlayer() or (isValidPlayerLocation and C_VoiceChat.IsPlayerUsingVoice(playerLocation))) then
		return false;
	end
	return true; 
end

function UnitPopupVoiceChatButtonMixin:GetButtons()
	return {
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
	}
end

UnitPopupVoiceChatMicrophoneVolumeButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoiceChatMicrophoneVolumeButtonMixin:GetCustomFrame()
	return UnitPopupVoiceMicrophoneVolume; 
end 

function UnitPopupVoiceChatMicrophoneVolumeButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if not C_VoiceChat.CanPlayerUseVoiceChat() or not UnitPopupSharedUtil.GetIsLocalPlayer() then
		return false;
	end
	return true; 
end

UnitPopupVoiceChatSpeakerVolumeButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoiceChatSpeakerVolumeButtonMixin:GetCustomFrame()
	return UnitPopupVoiceSpeakerVolume; 
end 

function UnitPopupVoiceChatSpeakerVolumeButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if not C_VoiceChat.CanPlayerUseVoiceChat() or not UnitPopupSharedUtil.GetIsLocalPlayer() then
		return false;
	end
	return true; 
end

UnitPopupVoiceChatUserVolumeButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoiceChatUserVolumeButtonMixin:GetCustomFrame()
	return UnitPopupVoiceUserVolume; 
end 

function UnitPopupVoiceChatUserVolumeButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	local isValidPlayerLocation = UnitPopupSharedUtil:IsValidPlayerLocation(playerLocation);
	if not C_VoiceChat.CanPlayerUseVoiceChat() or UnitPopupSharedUtil.GetIsLocalPlayer() or not isValidPlayerLocation or not C_VoiceChat.IsPlayerUsingVoice(playerLocation) then
		return false;
	end
	return true; 
end

UnitPopupVoiceChatSettingsButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupVoiceChatSettingsButtonMixin:GetText()
	return VOICE_CHAT_SETTINGS; 
end 

function UnitPopupVoiceChatSettingsButtonMixin:CanShow()
	if not C_VoiceChat.CanPlayerUseVoiceChat() or not UnitPopupSharedUtil.GetIsLocalPlayer()  then
		return false;
	end
	return true; 
end

function UnitPopupVoiceChatSettingsButtonMixin:OnClick()
	ChannelFrame:ToggleVoiceSettings();
end

UnitPopupCommunitiesLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
--Implementation differs from classic & mainline.. Implemented in UnitPopupButtons (Project Specific File)
function UnitPopupCommunitiesLeaveButtonMixin:GetText()
end 

function UnitPopupCommunitiesLeaveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo == nil or dropdownMenu.clubMemberInfo == nil or not dropdownMenu.clubMemberInfo.isSelf then
		return false;
	end
	return true; 
end

function UnitPopupCommunitiesLeaveButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if (#C_Club.GetClubMembers(dropdownMenu.clubInfo.clubId) == 1) then
		StaticPopup_Show("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", nil, nil, dropdownMenu.clubInfo);
	elseif (dropdownMenu.clubMemberInfo.isSelf and dropdownMenu.clubMemberInfo.role == Enum.ClubRoleIdentifier.Owner) then
		UIErrorsFrame:AddMessage(COMMUNITIES_LIST_TRANSFER_OWNERSHIP_FIRST, RED_FONT_COLOR:GetRGBA());
	else
		StaticPopup_Show("CONFIRM_LEAVE_COMMUNITY", nil, nil, dropdownMenu.clubInfo);
	end
end

UnitPopupCommunitiesBtagFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesBtagFriendButtonMixin:GetText()
	return COMMUNITY_MEMBER_LIST_DROP_DOWN_BATTLETAG_FRIEND;
end 

function UnitPopupCommunitiesBtagFriendButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local haveBattleTag = UnitPopupSharedUtil.HasBattleTag();
	local isLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer();
	local isPlayer = UnitPopupSharedUtil.IsPlayer();
	if not haveBattleTag
		or not UnitPopupSharedUtil:CanAddBNetFriend(isLocalPlayer, haveBattleTag, isPlayer)
		or dropdownMenu.clubInfo == nil
		or dropdownMenu.clubMemberInfo == nil
		or dropdownMenu.clubMemberInfo.isSelf then
		return false; 
	end
	return true; 
end

function UnitPopupCommunitiesBtagFriendButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	C_Club.SendBattleTagFriendRequest(dropdownMenu.clubInfo.clubId, dropdownMenu.clubMemberInfo.memberId);
end

UnitPopupCommunitiesKickFriendButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesKickFriendButtonMixin:GetText()
	return COMMUNITY_MEMBER_LIST_DROP_DOWN_REMOVE;
end 

function UnitPopupCommunitiesKickFriendButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo == nil
		or dropdownMenu.clubMemberInfo == nil
		or dropdownMenu.clubMemberInfo.isSelf
		or not CommunitiesUtil.CanKickClubMember(dropdownMenu.clubPrivileges, dropdownMenu.clubMemberInfo) then
		return false;
	end
	return true; 
end

function UnitPopupCommunitiesKickFriendButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	StaticPopup_Show("CONFIRM_REMOVE_COMMUNITY_MEMBER", nil, nil, { clubType = dropdownMenu.clubInfo.clubType, name = dropdownMenu.clubMemberInfo.name, clubId = dropdownMenu.clubInfo.clubId, memberId = dropdownMenu.clubMemberInfo.memberId });
end

UnitPopupCommunitiesMemberNoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesMemberNoteButtonMixin:GetText()
	return COMMUNITY_MEMBER_LIST_DROP_DOWN_SET_NOTE;
end 

function UnitPopupCommunitiesMemberNoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo == nil
		or dropdownMenu.clubMemberInfo == nil
		or (dropdownMenu.clubMemberInfo.isSelf and not dropdownMenu.clubPrivileges.canSetOwnMemberNote)
		or (not dropdownMenu.clubMemberInfo.isSelf and not dropdownMenu.clubPrivileges.canSetOtherMemberNote) then
		return false;
	end
	return true; 
end

function UnitPopupCommunitiesMemberNoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	StaticPopup_Show("SET_COMMUNITY_MEMBER_NOTE", dropdownMenu.clubMemberInfo.name, nil, { clubId = dropdownMenu.clubInfo.clubId, memberId = dropdownMenu.clubMemberInfo.memberId });
end

UnitPopupCommunitiesRoleButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesRoleButtonMixin:GetText()
	return COMMUNITY_MEMBER_LIST_DROP_DOWN_ROLES;
end 

function UnitPopupCommunitiesRoleButtonMixin:IsNested()
	 return true; 
end 

function UnitPopupCommunitiesRoleButtonMixin:GetButtons()
	return { 
		UnitPopupCommunitiesRoleOwnerButtonMixin, 
		UnitPopupCommunitiesRoleLeaderButtonMixin,
		UnitPopupCommunitiesRoleModeratorButtonMixin,
		UnitPopupCommunitiesRoleMemberButtonMixin,
	}
end

function UnitPopupCommunitiesRoleButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if not dropdownMenu.clubAssignableRoles or #dropdownMenu.clubAssignableRoles == 0 then
		return false; 
	end
	return true; 
end

UnitPopupCommunitiesRoleMemberButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesRoleMemberButtonMixin:GetText()
	return COMMUNITY_MEMBER_ROLE_NAME_MEMBER;
end 

function UnitPopupCommunitiesRoleMemberButtonMixin:IsCheckable()
	 return true; 
end 

function UnitPopupCommunitiesRoleMemberButtonMixin:GetRoleIdentifier()
	return Enum.ClubRoleIdentifier.Member;
end 

function UnitPopupCommunitiesRoleMemberButtonMixin:IsChecked()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu.clubMemberInfo.role == self:GetRoleIdentifier();
end 

function UnitPopupCommunitiesRoleMemberButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	C_Club.AssignMemberRole(dropdownMenu.clubInfo.clubId, dropdownMenu.clubMemberInfo.memberId, self:GetRoleIdentifier());
end

function UnitPopupCommunitiesRoleMemberButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if not dropdownMenu.clubAssignableRoles or not tContains(dropdownMenu.clubAssignableRoles, self:GetRoleIdentifier()) then
		return false;
	end
	return true; 
end

UnitPopupCommunitiesRoleModeratorButtonMixin = CreateFromMixins(UnitPopupCommunitiesRoleMemberButtonMixin);
function UnitPopupCommunitiesRoleModeratorButtonMixin:GetText()
	return COMMUNITY_MEMBER_ROLE_NAME_MODERATOR;
end 

function UnitPopupCommunitiesRoleModeratorButtonMixin:GetRoleIdentifier()
	return Enum.ClubRoleIdentifier.Moderator;
end 

UnitPopupCommunitiesRoleLeaderButtonMixin = CreateFromMixins(UnitPopupCommunitiesRoleMemberButtonMixin);
function UnitPopupCommunitiesRoleLeaderButtonMixin:GetText()
	return COMMUNITY_MEMBER_ROLE_NAME_LEADER;
end 

function UnitPopupCommunitiesRoleLeaderButtonMixin:GetRoleIdentifier()
	return Enum.ClubRoleIdentifier.Leader;
end

UnitPopupCommunitiesRoleOwnerButtonMixin = CreateFromMixins(UnitPopupCommunitiesRoleMemberButtonMixin);
function UnitPopupCommunitiesRoleOwnerButtonMixin:GetText()
	return COMMUNITY_MEMBER_ROLE_NAME_OWNER;
end 

function UnitPopupCommunitiesRoleOwnerButtonMixin:GetRoleIdentifier()
	return Enum.ClubRoleIdentifier.Owner;
end 

UnitPopupCommunitiesFavoriteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesFavoriteButtonMixin:GetText()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu.clubInfo.favoriteTimeStamp and COMMUNITIES_LIST_DROP_DOWN_UNFAVORITE or COMMUNITIES_LIST_DROP_DOWN_FAVORITE;
end 

function UnitPopupCommunitiesFavoriteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	CommunitiesFrame.CommunitiesList:SetFavorite(dropdownMenu.clubInfo.clubId, dropdownMenu.clubInfo.favoriteTimeStamp == nil);
end 

UnitPopupCommunitiesSettingButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunitiesSettingButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_COMMUNITIES_SETTINGS;
end 

function UnitPopupCommunitiesSettingButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	OpenCommunitiesSettingsDialog(dropdownMenu.clubInfo.clubId);
end 

function UnitPopupCommunitiesSettingButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo then
		local privileges = C_Club.GetClubPrivileges(dropdownMenu.clubInfo.clubId);
		local hasCommunitySettingsPrivilege = privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast;
		if not hasCommunitySettingsPrivilege then
			return false
		end
	else
		return false;
	end
end

UnitPopupCommunityNotificationButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunityNotificationButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_COMMUNITIES_NOTIFICATION_SETTINGS;
end 

function UnitPopupCommunityNotificationButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	CommunitiesFrame:ShowNotificationSettingsDialog(dropdownMenu.clubInfo.clubId);
end

UnitPopupClearCommunityNotificationButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupClearCommunityNotificationButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_CLEAR_UNREAD_NOTIFICATIONS;
end 

function UnitPopupClearCommunityNotificationButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	CommunitiesUtil.ClearAllUnreadNotifications(dropdownMenu.clubInfo.clubId);
end 

UnitPopupCommunityInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupCommunityInviteButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_INVITE;
end 

function UnitPopupCommunityInviteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local streams = C_Club.GetStreams(dropdownMenu.clubInfo.clubId);
	local defaultStreamId = #streams > 0 and streams[1] or nil;
	for i, stream in ipairs(streams) do
		if stream.streamType == Enum.ClubStreamType.General or stream.streamType == Enum.ClubStreamType.Guild then
			defaultStreamId = stream.streamId;
			break;
		end
	end

	if defaultStreamId then
		CommunitiesUtil.OpenInviteDialog(dropdownMenu.clubInfo.clubId, defaultStreamId);
	end
end 

function UnitPopupCommunityInviteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo then
		local privileges = C_Club.GetClubPrivileges(dropdownMenu.clubInfo.clubId);
		if not privileges.canSendInvitation then
			return false; 
		end
	else
		return false; 
	end
	return true;
end

UnitPopupDeleteCommunityMessageButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupDeleteCommunityMessageButtonMixin:GetText()
	return COMMUNITY_MESSAGE_DROP_DOWN_DELETE;
end 

function UnitPopupDeleteCommunityMessageButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	C_Club.DestroyMessage(dropdownMenu.communityClubID, dropdownMenu.communityStreamID, { epoch = dropdownMenu.communityEpoch, position = dropdownMenu.communityPosition });
end 

function UnitPopupDeleteCommunityMessageButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local clubId = dropdownMenu.communityClubID;
	local streamId = dropdownMenu.communityStreamID;
	if clubId and streamId and dropdownMenu.communityEpoch and dropdownMenu.communityPosition then
		local messageId = { epoch = dropdownMenu.communityEpoch, position = dropdownMenu.communityPosition };
		local function CanDestroyMessage(clubId, streamId, messageId)
			local messageInfo = C_Club.GetMessageInfo(clubId, streamId, messageId);
			if not messageInfo or messageInfo.destroyed then
				return false;
			end

			local privileges = C_Club.GetClubPrivileges(clubId);
			if not messageInfo.author.isSelf and not privileges.canDestroyOtherMessage then
				return false;
			elseif messageInfo.author.isSelf and not privileges.canDestroyOwnMessage then
				return false;
			end

			return true;
		end

		if not CanDestroyMessage(clubId, streamId, messageId) then
			return false
		end
	else
		return false;
	end
	return true;
end

UnitPopupItemQuality2DescButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin); 
function UnitPopupItemQuality2DescButtonMixin:GetText()
	return ITEM_QUALITY2_DESC; 
end 

function UnitPopupItemQuality2DescButtonMixin:IsCheckable()
	return true;
end

function UnitPopupItemQuality2DescButtonMixin:GetColor()
	local itemQualityColor = ITEM_QUALITY_COLORS[self:GetID()];
	if(itemQualityColor) then 
		return itemQualityColor.color
	end 
	return nil;
end

function UnitPopupItemQuality2DescButtonMixin:GetID()
	return 2; 
end

function UnitPopupItemQuality2DescButtonMixin:OnClick()
	local id = self:GetID();
	SetLootThreshold(id);
end

function UnitPopupItemQuality2DescButtonMixin:IsChecked()
	return GetLootThreshold() == self:GetID(); 
end 

UnitPopupItemQuality3DescButtonMixin = CreateFromMixins(UnitPopupItemQuality2DescButtonMixin); 
function UnitPopupItemQuality2DescButtonMixin:GetText()
	return ITEM_QUALITY3_DESC; 
end 

function UnitPopupItemQuality2DescButtonMixin:GetID()
	return 3; 
end

UnitPopupItemQuality4DescButtonMixin = CreateFromMixins(UnitPopupItemQuality2DescButtonMixin); 
function UnitPopupItemQuality2DescButtonMixin:GetText()
	return ITEM_QUALITY4_DESC; 
end 

function UnitPopupItemQuality2DescButtonMixin:GetID()
	return 4; 
end

UnitPopupOptOutLootTitleMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
--Override if needed in UnitPopupButtons
function UnitPopupOptOutLootTitleMixin:GetText()
	return GetOptOutOfLoot() and OPT_OUT_LOOT_TITLE:format(YES) or OPT_OUT_LOOT_TITLE:format(NO);
end 

function UnitPopupOptOutLootTitleMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_OPT_OUT_LOOT; 
end 

function UnitPopupOptOutLootTitleMixin:IsNested()
	return true; 
end 

function UnitPopupOptOutLootTitleMixin:GetButtons()
	return { 
		UnitPopupOptOutLootEnableMixin,
		UnitPopupOptOutLootDisableMixin
	}
end

UnitPopupOptOutLootEnableMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupOptOutLootEnableMixin:GetText()
	return YES;
end 

function UnitPopupOptOutLootEnableMixin:IsCheckable()
	return true;
end 

function UnitPopupOptOutLootEnableMixin:IsChecked()
	return GetOptOutOfLoot(); 
end	

function UnitPopupOptOutLootEnableMixin:OnClick()
	SetOptOutOfLoot(1);
	CloseDropDownMenus()
end

UnitPopupOptOutLootDisableMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupOptOutLootDisableMixin:GetText()
	return NO;
end 

function UnitPopupOptOutLootDisableMixin:IsCheckable()
	return true;
end 

function UnitPopupOptOutLootDisableMixin:IsChecked()
	return not GetOptOutOfLoot(); 
end	

function UnitPopupOptOutLootDisableMixin:OnClick()
	SetOptOutOfLoot(nil);
	CloseDropDownMenus()
end	

--Override in UnitPopupButtons
UnitPopupAchievementButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupAchievementButtonMixin:GetText()
end 

function UnitPopupAchievementButtonMixin:GetInteractDistance()
end

function UnitPopupAchievementButtonMixin:CanShow()
	return false; 
end		

function UnitPopupAchievementButtonMixin:OnClick()
end

UnitPopupRafGrantLevelButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRafGrantLevelButtonMixin:GetText()
end 

function UnitPopupRafGrantLevelButtonMixin:CanShow()
	return false; 
end

function UnitPopupRafGrantLevelButtonMixin:IsEnabled()
end

function UnitPopupRafGrantLevelButtonMixin:OnClick()
end 

UnitPopupLootPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)
function UnitPopupLootPromoteButtonMixin:CanShow()
	return false; 
end
UnitPopupSubsectionTitleMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
UnitPopupSubsectionTitleMixin.isSubsection = true; 
UnitPopupSubsectionTitleMixin.isUninteractable = true;
UnitPopupSubsectionTitleMixin.isSubsectionTitle = true; 
UnitPopupSubsectionTitleMixin.isSubsectionSeparator = true;
function UnitPopupSubsectionTitleMixin:GetText()
	return "";
end

function UnitPopupSubsectionTitleMixin:IsTitle()
	return true; 
end 

UnitPopupSubsectionSeperatorMixin = CreateFromMixins(UnitPopupSubsectionTitleMixin);
UnitPopupSubsectionSeperatorMixin.isSubsectionTitle = false; 
function UnitPopupSubsectionTitleMixin:IsSubsectionTitle()
	return false; 
end

UnitPopupLootSubsectionTitle = CreateFromMixins(UnitPopupSubsectionTitleMixin);
function UnitPopupLootSubsectionTitle:GetText()
	return UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT;
end

UnitPopupInstanceSubsectionTitle = CreateFromMixins(UnitPopupSubsectionTitleMixin);
function UnitPopupInstanceSubsectionTitle:GetText()
	return UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INSTANCE;
end

UnitPopupOtherSubsectionTitle = CreateFromMixins(UnitPopupSubsectionTitleMixin);
function UnitPopupOtherSubsectionTitle:GetText()
	return UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER;
end

UnitPopupInteractSubsectionTitle = CreateFromMixins(UnitPopupSubsectionTitleMixin);
function UnitPopupInteractSubsectionTitle:GetText()
	return UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT;
end

UnitPopupLegacyRaidSubsectionTitle = CreateFromMixins(UnitPopupSubsectionTitleMixin);
function UnitPopupLegacyRaidSubsectionTitle:GetText()
	return UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LEGACY_RAID;
end