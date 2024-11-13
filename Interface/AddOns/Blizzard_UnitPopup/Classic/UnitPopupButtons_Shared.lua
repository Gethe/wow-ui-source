UnitPopupLootMethodButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupLootMethodButtonMixin:GetSelectedLootMixin()
	local lootMethod = GetLootMethod();
	for index, buttonMixin in ipairs(self:GetEntries()) do
		if buttonMixin and buttonMixin:GetLootMethod() == lootMethod then
			return buttonMixin;
		end
	end

	return nil;
end

function UnitPopupLootMethodButtonMixin:GetText(contextData)
	-- Display selected loot method name
	local selectedLootMixin = self:GetSelectedLootMixin();
	if selectedLootMixin then
		return selectedLootMixin:GetText(contextData);
	end
	
	return LOOT_METHOD;
end

function UnitPopupLootMethodButtonMixin:GetTooltipText(contextData)
	-- Display selected loot method tooltip
	local selectedLootMixin = self:GetSelectedLootMixin();
	if selectedLootMixin then
		return selectedLootMixin:GetTooltipText(contextData);
	end

	return nil;
end 

function UnitPopupLootMethodButtonMixin:CanShow(contextData)
	return IsInGroup();
end

function UnitPopupLootMethodButtonMixin:IsEnabled(contextData)
	return UnitIsGroupLeader("player");
end

-- Specifically providing loot tooltip for non-leader players so they can read the selected loot method rules
-- Meanwhile the group leader gets all the rule tooltips as part of the dropdown being enabled
function UnitPopupLootMethodButtonMixin:TooltipWhileDisabled()
	return true;
end
function UnitPopupLootMethodButtonMixin:NoTooltipWhileEnabled()
	return true;
end

function UnitPopupLootMethodButtonMixin:GetEntries()
	return {
		UnitPopupLootFreeForAllButtonMixin,
		UnitPopupLootRoundRobinButtonMixin,
		UnitPopupMasterLooterButtonMixin,
		UnitPopupGroupLootButtonMixin,
		UnitPopupNeedBeforeGreedButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

UnitPopupLootFreeForAllButtonMixin = CreateFromMixins(UnitPopupRadioButtonMixin);

function UnitPopupLootFreeForAllButtonMixin:GetText(contextData)
	return LOOT_FREE_FOR_ALL;
end

function UnitPopupLootFreeForAllButtonMixin:GetTooltipText(contextData)
	return NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL;
end 

function UnitPopupLootFreeForAllButtonMixin:GetLootMethod()
	return "freeforall";
end	

function UnitPopupLootFreeForAllButtonMixin:IsChecked(contextData)
	return GetLootMethod() == self:GetLootMethod();
end

function UnitPopupLootFreeForAllButtonMixin:CanShow(contextData)
	if not IsInGroup() then 
		return false; 
	end

	if not UnitIsGroupLeader("player") then
		return false; 
	end

	return true; 
end

function UnitPopupLootFreeForAllButtonMixin:OnClick(contextData)
	SetLootMethod(self:GetLootMethod());
end

UnitPopupLootRoundRobinButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);

function UnitPopupLootRoundRobinButtonMixin:GetText(contextData)
	return LOOT_ROUND_ROBIN;
end

function UnitPopupLootRoundRobinButtonMixin:GetTooltipText(contextData)
	return NEWBIE_TOOLTIP_UNIT_ROUND_ROBIN;
end 

function UnitPopupLootRoundRobinButtonMixin:GetLootMethod()
	return "roundrobin";
end		

UnitPopupMasterLooterButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);

function UnitPopupMasterLooterButtonMixin:GetText(contextData)
	return LOOT_MASTER_LOOTER;
end

function UnitPopupMasterLooterButtonMixin:GetTooltipText(contextData)
	return NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER;
end 

function UnitPopupMasterLooterButtonMixin:GetLootMethod()
	return "master";
end		

function UnitPopupMasterLooterButtonMixin:OnClick(contextData)
	SetLootMethod(self:GetLootMethod(), UnitPopupSharedUtil.GetFullPlayerName(contextData), 2);
end

UnitPopupGroupLootButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);

function UnitPopupGroupLootButtonMixin:GetText(contextData)
	return LOOT_GROUP_LOOT;
end

function UnitPopupGroupLootButtonMixin:GetTooltipText(contextData)
	return NEWBIE_TOOLTIP_UNIT_GROUP_LOOT;
end 

function UnitPopupGroupLootButtonMixin:GetLootMethod()
	return "group";
end		

UnitPopupNeedBeforeGreedButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);

function UnitPopupNeedBeforeGreedButtonMixin:GetText(contextData)
	return LOOT_NEED_BEFORE_GREED;
end

function UnitPopupNeedBeforeGreedButtonMixin:GetLootMethod()
	return "needbeforegreed";
end		

function UnitPopupNeedBeforeGreedButtonMixin:GetTooltipText(contextData)
	return NEWBIE_TOOLTIP_UNIT_NEED_BEFORE_GREED;
end 

UnitPopupLootThresholdButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupLootThresholdButtonMixin:GetText(contextData)
	return  _G["ITEM_QUALITY"..GetLootThreshold().."_DESC"];
end 

function UnitPopupLootThresholdButtonMixin:CanShow(contextData)
	return IsInGroup(); 
end 

function UnitPopupLootThresholdButtonMixin:GetEntries()
	if UnitIsGroupLeader("player") then
	return { 
		UnitPopupItemQuality2DescButtonMixin,
		UnitPopupItemQuality3DescButtonMixin,
		UnitPopupItemQuality4DescButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 
	return nil;
end

function UnitPopupLootPromoteButtonMixin:GetText(contextData)
	return LOOT_PROMOTE;
end 

function UnitPopupLootPromoteButtonMixin:CanShow(contextData)
	if not IsInGroup() then
		return false;
	end

	if not UnitIsGroupLeader("player") then
		return false;
	end

	local lootMethod, partyIndex, raidIndex = GetLootMethod();
	if lootMethod ~= "master" then
		return false;
	end

	local which = contextData.which;
	if (which == "RAID") or (which == "RAID_PLAYER") then
		if raidIndex and (contextData.unit == "raid"..raidIndex) then
			return false;
		end
	elseif which == "SELF" then
		if partyIndex and (partyIndex == 0) then
			return false;
			end
	else
		if partyIndex and (contextData.unit == "party"..partyIndex) then
			return false;
		end
	end

	return true; 
end 

function UnitPopupLootPromoteButtonMixin:IsEnabled(contextData)
	if not IsInGroup() then
		return false; 
	end

	if not UnitIsGroupLeader("player") then
		return false;
end 

	local lootMethod, partyIndex, raidIndex = GetLootMethod();
	if lootMethod ~= "master" then
		return false; 
	end

		local masterName = 0;
	if partyMaster and (partyMaster == 0) then
			masterName = "player";
	elseif partyMaster then
			masterName = "party"..partyMaster;
	elseif raidMaster then
			masterName = "raid"..raidMaster;
		end

	if contextData.unit and UnitIsUnit(contextData.unit, masterName) then
			return false; 
		end

	return true; 
end

function UnitPopupLootPromoteButtonMixin:OnClick(contextData)
	SetLootMethod("master", UnitPopupSharedUtil.GetFullPlayerName(contextData), 2);
end

-- Overrides
function UnitPopupRaidDifficulty1ButtonMixin:IsDisabled()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return true;
	end
	
	if IsInGroup() and not UnitIsGroupLeader("player") then
		return true;
	end

	local _, _, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	local toggleDifficultyID;
	if isDynamicInstance and CanChangePlayerDifficulty() then
		toggleDifficultyID = select(7, GetDifficultyInfo(instanceDifficultyID));
	end

	if IsInInstance() and (not toggleDifficultyID) then
		return true;
	end

	-- Commented out because it was returning nil - dead code
	--if toggleDifficultyID and CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID()) then
	--	return nil;
	--end

	return false;
	end

function UnitPopupRaidDifficulty1ButtonMixin:IsEnabled(contextData)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return false;
	end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return false;
end	

	local inInstance, instanceType = IsInInstance();
	if inInstance and instanceType ~= "raid" then
		return false;
	end

	local _, _, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	local toggleDifficultyID;
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		toggleDifficultyID = select(7, GetDifficultyInfo(instanceDifficultyID));
	end

	
	if IsInInstance() and (not toggleDifficultyID) then
		return false;
	end

	if toggleDifficultyID and not CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID()) then
		return false;
	end

	local isMythicDifficulty = self:GetDifficultyID() == DIFFICULTY_PRIMARYRAID_MYTHIC;
	if isMythicDifficulty and (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA]) then
			return false; 
		end 

	return true; 
end

function UnitPopupAddGuildBtagFriendButtonMixin:CanShow(contextData)
	local isLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer(contextData);
	local hasBattleTag = UnitPopupSharedUtil.HasBattleTag();
	local isAPlayer = UnitPopupSharedUtil.IsPlayer(contextData);
	return UnitPopupSharedUtil.CanAddBNetFriend(contextData, isLocalPlayer, hasBattleTag, isAPlayer);
end

function UnitPopupBnetInviteButtonMixin:CanShow(contextData)
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount = BNGetFriendInfoByID(contextData.bnetIDAccount);
	if not bnetIDGameAccount then
		return false;
	end

		local guid = select(20, BNGetGameAccountInfo(bnetIDGameAccount));
		local inviteType = GetDisplayedInviteType(guid);
	if self:GetInviteName() ~= "BN_"..inviteType then
			return false; 
	end
	
	if not contextData.bnetIDAccount or not BNFeaturesEnabledAndConnected() then
			return false; 
	end

	if UnitPopupSharedUtil.IsInGroupWithPlayer(contextData) then
			return false; 
		end

	return true; 
end	

function UnitPopupCommunitiesLeaveButtonMixin:GetText(contextData)
	return COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY; 
end

function UnitPopupWhisperButtonMixin:CanShow(contextData)
	local whisperIsLocalPlayer =  UnitPopupSharedUtil.GetIsLocalPlayer(contextData);
	if not whisperIsLocalPlayer then
		local playerName, playerServer = UnitName("player");
		whisperIsLocalPlayer = (contextData.name == playerName and contextData.server == playerServer);
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

	if contextData.unit and (not UnitPopupSharedUtil.CanCooperate(contextData) or not UnitPopupSharedUtil.IsPlayer(contextData)) then
	return false; 
end

	return true; 
end	

function UnitPopupPetBattleDuelButtonMixin:CanShow(contextData)
	return false; 
end

function UnitPopupPvpReportAfkButtonMixin:CanShow(contextData)
	if not UnitInBattleground("player") or GetCVar("enablePVPNotifyAFK") == "0" then
		return false; 
	end

	if contextData.unit then
		if UnitIsUnit(contextData.unit, "player") then
			return false; 
		end
		
		if not UnitInBattleground(contextData.unit) and not IsInActiveWorldPVP(contextData.unit) then
			return false; 
		end
	elseif contextData.name then
		if contextData.name == UnitName("player") then
			return false; 
		end

		if not UnitInBattleground(contextData.name) then
			return false; 
		end
	end

	return true;
end	

function UnitPopupRafSummonButtonMixin:CanShow(contextData)
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

function UnitPopupVoteToKickButtonMixin:CanShow(contextData)
	if not IsInGroup() or not C_LFGInfo.IsGroupFinderEnabled() then
		return false;
end

	if not UnitPopupSharedUtil.IsPlayer(contextData) then
		return false;
		end

	if not UnitPopupSharedUtil.HasLFGRestrictions() then
		return false;
	end

	if IsInActiveWorldPVP() then
		return false;
end 

	local instanceType = select(2, IsInInstance());
	if instanceType == "pvp" or instanceType == "arena" then
		return false;
	end

	return true;
end

function UnitPopupVoteToKickButtonMixin:IsEnabled(contextData)
	if not C_LFGInfo.IsGroupFinderEnabled() then
		return false;
	end

	if not IsInGroup() then
		return false;
	end

	if not HasLFGRestrictions() then
		return false;
	end

	return true; 
end

function UnitPopupDungeonDifficultyButtonMixin:GetEntries()
	return { 
		UnitPopupDungeonDifficulty1ButtonMixin, 
		UnitPopupDungeonDifficulty2ButtonMixin,
	}
end 

function UnitPopupPartyInstanceLeaveButtonMixin:CanShow(contextData)
	return false; 
end

function UnitPopupConvertToRaidButtonMixin:OnClick(contextData)
	ConvertToRaid();
end

function UnitPopupConvertToPartyButtonMixin:OnClick(contextData)
	ConvertToParty();
end

function UnitPopupPartyLeaveButtonMixin:OnClick(contextData)
	LeaveParty();
end

function UnitPopupRaidTargetButtonMixin:CanShow(contextData)
	return not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player");
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

