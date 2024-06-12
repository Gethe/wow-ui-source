function UnitPopupAchievementButtonMixin:GetText(contextData)
	return COMPARE_ACHIEVEMENTS; 
end 

function UnitPopupAchievementButtonMixin:GetInteractDistance()
	return 1; 
end

function UnitPopupAchievementButtonMixin:CanShow(contextData)
	local unit = contextData.unit;
	if not unit or UnitCanAttack("player", unit) then
		return false;
	end

	return UnitPopupSharedUtil.IsPlayer(contextData);
end		

function UnitPopupAchievementButtonMixin:OnClick(contextData)
	InspectAchievements(contextData.unit);
end

UnitPopupBnetAddFavoriteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupBnetAddFavoriteButtonMixin:GetText(contextData)
	return ADD_FAVORITE_STATUS; 
end 

function UnitPopupBnetAddFavoriteButtonMixin:OnClick(contextData)
	local bnetIDAccount = contextData.bnetIDAccount;
	if bnetIDAccount then
		BNSetFriendFavoriteFlag(bnetIDAccount, true);
	end
end

function UnitPopupBnetAddFavoriteButtonMixin:CanShow(contextData)
	return contextData.friendsList and not UnitPopupSharedUtil.IsPlayerFavorite(contextData);
end 

UnitPopupBnetRemoveFavoriteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupBnetRemoveFavoriteButtonMixin:GetText(contextData)
	return REMOVE_FAVORITE_STATUS; 
end 

function UnitPopupBnetRemoveFavoriteButtonMixin:OnClick(contextData)
	local bnetIDAccount = contextData.bnetIDAccount;
	if bnetIDAccount then
		BNSetFriendFavoriteFlag(bnetIDAccount, false);
	end
end

function UnitPopupBnetRemoveFavoriteButtonMixin:CanShow(contextData)
	return contextData.friendsList and UnitPopupSharedUtil.IsPlayerFavorite(contextData);
end 

UnitPopupDungeonDifficulty3ButtonMixin = CreateFromMixins(UnitPopupDungeonDifficulty1ButtonMixin);

function UnitPopupDungeonDifficulty3ButtonMixin:GetText(contextData)
	return PLAYER_DIFFICULTY6; 
end 

function UnitPopupDungeonDifficulty3ButtonMixin:GetDifficultyID()
	return 23;
end 

UnitPopupRafRemoveRecruitButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupRafRemoveRecruitButtonMixin:GetText(contextData)
	return RAF_REMOVE_RECRUIT; 
end 

function UnitPopupRafRemoveRecruitButtonMixin:CanShow(contextData)
	return contextData.isRafRecruit;
end	

function UnitPopupRafRemoveRecruitButtonMixin:OnClick(contextData)
	local text2 = nil;
	StaticPopup_Show("CONFIRM_RAF_REMOVE_RECRUIT", contextData.name, text2, contextData.wowAccountGUID);
end

UnitPopupGuildSettingButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupGuildSettingButtonMixin:GetText(contextData)
	return GUILD_CONTROL_BUTTON_TEXT;
end 

function UnitPopupGuildSettingButtonMixin:OnClick(contextData)
	if not GuildControlUI then
		UIParentLoadAddOn("Blizzard_GuildControlUI");
	end

	if not GuildControlUI:IsShown() then
		ShowUIPanel(GuildControlUI);
	end
end 

function UnitPopupGuildSettingButtonMixin:CanShow(contextData)
	return IsGuildLeader();
end

UnitPopupGuildRecruitmentSettingButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupGuildRecruitmentSettingButtonMixin:GetText(contextData)
	return GUILD_RECRUITMENT;
end 

function UnitPopupGuildRecruitmentSettingButtonMixin:OnClick(contextData)
	local clubInfo = contextData.clubInfo; 
	CommunitiesFrame.RecruitmentDialog.clubId = clubInfo.clubId;
	CommunitiesFrame.RecruitmentDialog.clubName = clubInfo.name;
	CommunitiesFrame.RecruitmentDialog.clubAvatarId = clubInfo.avatarId;
	CommunitiesFrame.RecruitmentDialog:UpdatedPostingInformationInit();
end 

function UnitPopupGuildRecruitmentSettingButtonMixin:CanShow(contextData)
	local clubInfo = contextData.clubInfo;
	if not clubInfo then
		return false;
	end

	if not C_ClubFinder.IsEnabled()  then
		return false;
	end

	if C_ClubFinder.GetClubFinderDisableReason() ~= nil then
			return false;
		end

	if C_ClubFinder.IsPostingBanned(clubInfo.clubId) then
		return false;
	end
	
	return IsGuildLeader() or C_GuildInfo.IsGuildOfficer();
end

UnitPopupGuildInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupGuildInviteButtonMixin:GetText(contextData)
	return COMMUNITIES_LIST_DROP_DOWN_INVITE;
end 

function UnitPopupGuildInviteButtonMixin:OnClick(contextData)
	local clubId = contextData.clubInfo.clubId;
	local streams = C_Club.GetStreams(clubId);
	local defaultStreamId = streams[1];
	for i, stream in ipairs(streams) do
		local streamType = stream.streamType;
		if streamType == Enum.ClubStreamType.General or streamType == Enum.ClubStreamType.Guild then
			defaultStreamId = stream.streamId;
			break;
		end
	end

	if defaultStreamId then
		CommunitiesUtil.OpenInviteDialog(clubId, defaultStreamId);
	end
end 

function UnitPopupGuildInviteButtonMixin:CanShow()
	return CanGuildInvite();
end 

-- Overrides
function UnitPopupRaidDifficulty1ButtonMixin:IsChecked(contextData)
	local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance then
		if IsLegacyDifficulty(difficultyID) then
			local validNormalSize = difficultyID == DifficultyUtil.ID.Raid10Normal or difficultyID == DifficultyUtil.ID.Raid25Normal;
			if validNormalSize and self:GetDifficultyID() == DifficultyUtil.ID.PrimaryRaidNormal then
				return true;
			end
			
			local validHeroicSize = difficultyID == DifficultyUtil.ID.Raid10Heroic or difficultyID == DifficultyUtil.ID.Raid25Heroic;
			if validHeroicSize and self:GetDifficultyID() == DifficultyUtil.ID.PrimaryRaidHeroic then
				return true;
			end
		elseif difficultyID == self:GetDifficultyID() then
			return true;
		end
	elseif GetRaidDifficultyID() == self:GetDifficultyID() then
			return true;
		end
	return false; 
	end

function UnitPopupRaidDifficulty1ButtonMixin:IsDisabled(contextData)
	if IsInInstance() then
		return true;
end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return true; 
	end
	
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return true;
	end

	local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance and CanChangePlayerDifficulty() then
		local toggleDifficultyID = select(7, GetDifficultyInfo(difficultyID));
		if toggleDifficultyID then
		return CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID());
	end
	end
	
	return false;
end	

function UnitPopupRaidDifficulty1ButtonMixin:IsEnabled(contextData)
	if IsInInstance() then
		return false;
	end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return false;
	end

	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return false;
	end

	local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance and CanChangePlayerDifficulty() then
		local toggleDifficultyID = select(7, GetDifficultyInfo(difficultyID));
		if toggleDifficultyID then
		return CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID());
	end
end

	return true; 
end

function UnitPopupInviteButtonMixin:CanShow(contextData)
	if UnitPopupSharedUtil.GetIsLocalPlayer(contextData) then
		return false;
	end
	
	if UnitPopupSharedUtil.IsPlayerOffline(contextData)then
		return false;
	end

	local unit = contextData.unit;
	if contextData.unit then
		if not UnitPopupSharedUtil.CanCooperate(contextData) then
			return false;
		end
		
		if UnitIsUnit("player", unit) then
			return false;
		end
	elseif contextData.fromRosterFrame then
		if UnitInRaid(contextData.name) ~= nil then
			return false;
		end
	elseif contextData.isMobile then
		return false;
	end

	local displayedInvite;
	if unit and (not IsInGroup()) and UnitInAnyGroup(unit, LE_PARTY_CATEGORY_HOME) then
		--Handle the case where we don't have SocialQueue data about this unit (e.g. because it's a random person)
		--in the world. In this case, we want to display REQUEST_INVITE if they're in a group.
		displayedInvite = "REQUEST_INVITE";
	else
		displayedInvite = GetDisplayedInviteType(UnitPopupSharedUtil.GetGUID(contextData));
	end

	return self:GetInviteName() == displayedInvite;
end

function UnitPopupAddGuildBtagFriendButtonMixin:CanShow(contextData)
	local isLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer(contextData);
	local hasBattleTag = UnitPopupSharedUtil.HasBattleTag();
	local isAPlayer = UnitPopupSharedUtil.IsPlayer(contextData);
	return UnitPopupSharedUtil.CanAddBNetFriend(contextData, isLocalPlayer, hasBattleTag, isAPlayer);
end	

function UnitPopupBnetInviteButtonMixin:CanShow(contextData)
	if contextData.isMobile then
		return false; 
	end

	local accountInfo = contextData.accountInfo;
	if not accountInfo then
		return false;
end

	local playerGuid = accountInfo.gameAccountInfo.playerGuid;
	if not playerGuid then
		return false; 
	end

	local inviteName = "BN_"..GetDisplayedInviteType(playerGuid);
	if self:GetInviteName() ~= inviteName then
			return false; 
	end

	if not contextData.bnetIDAccount then
			return false; 
		end

	return BNFeaturesEnabledAndConnected(); 
	end

function UnitPopupCommunitiesLeaveButtonMixin:GetText(contextData)
	local isCharacterClub = contextData.clubInfo.clubType == Enum.ClubType.Character;
	return isCharacterClub and COMMUNITIES_LIST_DROP_DOWN_LEAVE_CHARACTER_COMMUNITY or COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY;
end	

function UnitPopupWhisperButtonMixin:CanShow(contextData)
	if contextData.isMobile then
		return false;
end

	local whisperIsLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer(contextData);
	if not whisperIsLocalPlayer then
		local playerName, playerServer = UnitNameUnmodified("player");
		whisperIsLocalPlayer = (contextData.name == playerName) and (contextData.server == playerServer);
	end

	if whisperIsLocalPlayer then
		return false;
	end
	
	if contextData.bnetIDAccount then
		if not UnitPopupSharedUtil.IsBNetFriend(contextData) then
			return false;
		end
	elseif UnitPopupSharedUtil.IsPlayerOffline(contextData) then
		return false;
	end

	if contextData.unit then
		if not UnitPopupSharedUtil.CanCooperate(contextData) then
		return false;
	end

		if not UnitPopupSharedUtil.IsPlayer(contextData) then
		return false;
	end
	end

	return true; 
end	

function UnitPopupPvpReportAfkButtonMixin:CanShow(contextData)
	if C_PvP.IsRatedMap() then
		return false;
	end

	if not IsInActiveWorldPVP() and (not UnitInBattleground("player") or GetCVar("enablePVPNotifyAFK") == "0") then
		return false; 
	end

	local unit = contextData.unit;
	if unit then
		if UnitIsUnit(unit, "player") then
			return false; 
		end
		
		if not UnitInBattleground(unit) and not IsInActiveWorldPVP(unit) then
			return false; 
		end
	else
		local name = contextData.name;
		if name then
			if name == UnitNameUnmodified("player") then
			return false; 
			end
			
			if not UnitInBattleground(name) and not IsInActiveWorldPVP(name) then
			return false; 
		end
	end
	end

	return true;
end	

function UnitPopupRafSummonButtonMixin:CanShow(contextData)
	if contextData.isMobile then
		return false;
	end

	local guid = UnitPopupSharedUtil.GetGUID(contextData);
	return guid and C_RecruitAFriend.IsRecruitAFriendLinked(guid);
end	

function UnitPopupRafSummonButtonMixin:OnClick(contextData)
	local guid = UnitPopupSharedUtil.GetGUID(contextData);
	local fullName = UnitPopupSharedUtil.GetFullPlayerName(contextData);
	C_RecruitAFriend.SummonFriend(guid, fullName);
end

function UnitPopupBnetTargetButtonMixin:IsEnabled(contextData)
	if not contextData.bnetIDAccount then
		return false; 
	end

	local accountInfo = contextData.accountInfo;
	if not accountInfo then 
			return false; 
		end
	
	local gameAccountInfo = accountInfo.gameAccountInfo;
	if gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW or gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
		return false;
	end

	return true; 
end 

function UnitPopupVoteToKickButtonMixin:IsEnabled(contextData)
	return IsInGroup() and HasLFGRestrictions();
end

function UnitPopupDungeonDifficultyButtonMixin:GetEntries()
	return { 
		UnitPopupDungeonDifficulty1ButtonMixin, 
		UnitPopupDungeonDifficulty2ButtonMixin,
		UnitPopupDungeonDifficulty3ButtonMixin,
	}
end 

function UnitPopupPartyInstanceLeaveButtonMixin:CanShow(contextData)
	if not IsInGroup() then
		return false;
	end

	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return false;
	end
	
	if IsPartyWorldPVP() then
		return false;
end

	local instanceType = select(2, IsInInstance());
	if instanceType == "pvp" or instanceType == "arena" then
		return false;
	end
	
	local partyLFGSlot = GetPartyLFGID();
	local partyLFGCategory = UnitPopupSharedUtil.GetLFGCategoryForLFGSlot(partyLFGSlot);
	return partyLFGCategory ~= LE_LFG_CATEGORY_WORLDPVP;
end

function UnitPopupPvpFlagButtonMixin:IsEnabled(contextData)
	return not UnitPopupSharedUtil.IsInWarModeState(); 
end

function UnitPopupPvpFlagButtonMixin:TooltipTitle()
	return UnitPopupSharedUtil.IsInWarModeState() and PVP_LABEL_WAR_MODE or nil;
end 

function UnitPopupPvpFlagButtonMixin:TooltipInstruction()
	return UnitPopupSharedUtil.IsInWarModeState() and PVP_WAR_MODE_ENABLED or nil;
end 

function UnitPopupPvpFlagButtonMixin:TooltipWarning()
	if UnitPopupSharedUtil.IsInWarModeState()then
		local asHorde = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0];
		return asHorde and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
	end
		return nil;
	end 

function UnitPopupConvertToRaidButtonMixin:OnClick(contextData)
	C_PartyInfo.ConvertToRaid();
end

function UnitPopupConvertToPartyButtonMixin:OnClick(contextData)
	C_PartyInfo.ConvertToParty();
end

function UnitPopupPartyLeaveButtonMixin:OnClick(contextData)
	C_PartyInfo.LeaveParty();
end

function UnitPopupGarrisonVisitButtonMixin:CanShow(contextData)
	return C_Garrison.IsVisitGarrisonAvailable() and (not C_PartyInfo.IsCrossFactionParty());
end

-- UnitPopupEnterEditModeMixin is used instead
function UnitPopupMovePlayerFrameButtonMixin:CanShow(contextData)
	return false;
end

-- UnitPopupEnterEditModeMixin is used instead
function UnitPopupMoveTargetFrameButtonMixin:CanShow(contextData)
	return false;
end

-- UnitPopupEnterEditModeMixin is used instead
function UnitPopupMoveFocusButtonMixin:CanShow(contextData)
	return false;
end

-- UnitPopupEnterEditModeMixin is used instead
function UnitPopupLargeFocusButtonMixin:CanShow(contextData)
	return false;
end

function UnitPopupPlayerFrameShowCastBarButtonMixin:CanShow(contextData)
	return false;
end

function UnitPopupEnterEditModeMixin:GetText(contextData)
	return HUD_EDIT_MODE_MENU;
end

function UnitPopupEnterEditModeMixin:CanShow(contextData)
	return true; 
end

function UnitPopupEnterEditModeMixin:IsEnabled(contextData)
	return EditModeManagerFrame:CanEnterEditMode();
end

function UnitPopupEnterEditModeMixin:OnClick(contextData)
	ShowUIPanel(EditModeManagerFrame);
end

function UnitPopupSelectRoleButtonMixin:CanShow(contextData)
	if not CanShowSetRoleButton() then
		return false;
	end

	if C_Scenario.IsInScenario() then
		return false;
	end

	if not IsInGroup() then
		return false; 
	end

	if HasLFGRestrictions() then
		return false;
end

	return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or UnitIsUnit(contextData.unit, "player");
end

function UnitPopupPetAbandonButtonMixin:GetText()
	return RELEASE_PET_BUTTON_LABEL;
end

function UnitPopupPetAbandonButtonMixin:OnClick(contextData)
	StaticPopup_Show("RELEASE_PET");
end

function UnitPopupPetRenameButtonMixin:CanShow(contextData)
	return PetCanBeAbandoned();
end