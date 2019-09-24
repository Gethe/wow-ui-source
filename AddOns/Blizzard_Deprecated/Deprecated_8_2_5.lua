-- These are functions that were deprecated in 8.2.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Old Recruit A Friend system removal
do
	-- Use C_RecruitAFriend.IsEnabled instead.
	C_RecruitAFriend.IsSendingEnabled = C_RecruitAFriend.IsEnabled;

	-- Use C_RecruitAFriend.IsEnabled instead.
	C_RecruitAFriend.CheckEmailEnabled = C_RecruitAFriend.IsEnabled;

	-- No longer supported
	C_RecruitAFriend.SendRecruit = function(email, message, name)
	end

	-- No longer supported
	SendSoRByText = function()
		return false;
	end

	-- No longer supported
	CanSendSoRByText = function()
		return false;
	end

	-- No longer supported
	GetNumSoRRemaining = function()
		return 0;
	end

	-- No longer supported
	GuildRosterSendSoR = function()
		return false;
	end
end

-- Newbie tooltips haven't been supported for a long time, so GameTooltip_AddNewbieTip has been removed
do
	-- Use GameTooltip:SetOwner and GameTooltip_SetTitle instead
	function GameTooltip_AddNewbieTip(frame, normalText, r, g, b, newbieText, noNormalText)
		if not noNormalText then
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, normalText);
		end
	end
end

-- IsQuestFlaggedCompleted was moved to C_QuestLog, functionality remains identical
do
	IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
end

-- Converting BNet friend API over to returning a single table that contains all info needed instead of multiple calls which return a million values
do
	local function getDeprecatedAccountInfo(accountInfo)
		if accountInfo then
			local wowProjectID = accountInfo.gameAccountInfo.wowProjectID or 0;
			local clientProgram = accountInfo.gameAccountInfo.clientProgram ~= "" and accountInfo.gameAccountInfo.clientProgram or nil;

			return	accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.isBattleTagFriend,
					accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, clientProgram,
					accountInfo.gameAccountInfo.isOnline, accountInfo.lastOnlineTime, accountInfo.isAFK, accountInfo.isDND, accountInfo.customMessage, accountInfo.note, accountInfo.isFriend,
					accountInfo.customMessageTime, wowProjectID, accountInfo.rafLinkType == Enum.RafLinkType.Recruit, accountInfo.gameAccountInfo.canSummon, accountInfo.isFavorite, accountInfo.gameAccountInfo.isWowMobile;
		end
	end

	-- Use C_BattleNet.GetFriendAccountInfo instead.
	BNGetFriendInfo = function(friendIndex)
		local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
		return getDeprecatedAccountInfo(accountInfo);
	end

	-- Use C_BattleNet.GetAccountInfoByID instead.
	BNGetFriendInfoByID = function(id)
		local accountInfo = C_BattleNet.GetAccountInfoByID(id);
		return getDeprecatedAccountInfo(accountInfo);
	end

	local function getDeprecatedGameAccountInfo(gameAccountInfo, accountInfo)
		if gameAccountInfo and accountInfo then
			local wowProjectID = gameAccountInfo.wowProjectID or 0;
			local characterName = gameAccountInfo.characterName or "";
			local realmName = gameAccountInfo.realmName or "";
			local realmID = gameAccountInfo.realmID or 0;
			local factionName = gameAccountInfo.factionName or "";
			local raceName = gameAccountInfo.raceName or "";
			local className = gameAccountInfo.className or "";
			local areaName = gameAccountInfo.areaName or "";
			local characterLevel = gameAccountInfo.characterLevel or "";
			local richPresence = gameAccountInfo.richPresence or "";
			local gameAccountID = gameAccountInfo.gameAccountID or 0;
			local playerGuid = gameAccountInfo.playerGuid or 0;

			return	gameAccountInfo.hasFocus, characterName, gameAccountInfo.clientProgram,
					realmName, realmID, factionName, raceName, className, "", areaName, characterLevel,
					richPresence, accountInfo.customMessage, accountInfo.customMessageTime,
					gameAccountInfo.isOnline, gameAccountID, accountInfo.bnetAccountID, gameAccountInfo.isGameAFK, gameAccountInfo.isGameBusy,
					playerGuid, wowProjectID, gameAccountInfo.isWowMobile;
		end
	end

	-- Use C_BattleNet.GetFriendGameAccountInfo (and GetFriendAccountInfo if you need the customMessage or bnetAccountID) instead.
	BNGetFriendGameAccountInfo = function(friendIndex, accountIndex)
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex);
		local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
		return getDeprecatedGameAccountInfo(gameAccountInfo, accountInfo);
	end

		-- Use C_BattleNet.GetGameAccountInfoByID (and GetAccountInfoByID if you need the customMessage or bnetAccountID) instead.
	BNGetGameAccountInfo = function(id, accountIndex)
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByID(id, accountIndex);
		local accountInfo = C_BattleNet.GetAccountInfoByID(id);
		return getDeprecatedGameAccountInfo(gameAccountInfo, accountInfo);
	end

	-- Use C_BattleNet.GetGameAccountInfoByGUID (and GetAccountInfoByGUID if you need the customMessage or bnetAccountID) instead.
	BNGetGameAccountInfoByGUID = function(guid)
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByGUID(guid);
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(guid);
		return getDeprecatedGameAccountInfo(gameAccountInfo, accountInfo);
	end

	-- Use C_BattleNet.GetFriendNumGameAccounts instead.
	BNGetNumFriendGameAccounts = function(friendIndex)
		return C_BattleNet.GetFriendNumGameAccounts(friendIndex);
	end
end

-- CompactUnitFrame.lua changes
do
	function CompactUnitFrame_UtilIsBossAura(unit, index, filter, checkAsBuff)
		-- make sure you are using the correct index here!	allAurasIndex ~= debuffIndex
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura;
		if (checkAsBuff) then
			name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitBuff(unit, index, filter);
		else
			name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);
		end
		return isBossAura;
	end

	function CompactUnitFrame_UtilIsPriorityDebuff(unit, index, filter)
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);

		local _, classFilename = UnitClass("player");
		if ( classFilename == "PALADIN" ) then
			if ( spellId == 25771 ) then	--Forbearance
				return true;
			end
		end

		return false;
	end

	function CompactUnitFrame_UtilShouldDisplayDebuff(unit, index, filter)
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);

		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
		if ( hasCustom ) then
			return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
		else
			return true;
		end
	end

	function CompactUnitFrame_UpdateBuffs(frame, forHookingOnly)
		if forHookingOnly then
			return;
		end
		if ( not frame.buffFrames or not frame.optionTable.displayBuffs ) then
			CompactUnitFrame_HideAllBuffs(frame);
			return;
		end

		local index = 1;
		local frameNum = 1;
		local filter = nil;
		while ( frameNum <= frame.maxBuffs ) do
			local buffName = UnitBuff(frame.displayedUnit, index, filter);
			if ( buffName ) then
				if ( CompactUnitFrame_UtilShouldDisplayBuff(frame.displayedUnit, index, filter) and not CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, true) ) then
					local buffFrame = frame.buffFrames[frameNum];
					CompactUnitFrame_UtilSetBuff(buffFrame, frame.displayedUnit, index, filter);
					frameNum = frameNum + 1;
				end
			else
				break;
			end
			index = index + 1;
		end
		for i=frameNum, frame.maxBuffs do
			local buffFrame = frame.buffFrames[i];
			buffFrame:Hide();
		end
	end

	function CompactUnitFrame_UpdateDebuffs(frame, forHookingOnly)
		if forHookingOnly then
			return;
		end

		if ( not frame.debuffFrames or not frame.optionTable.displayDebuffs ) then
			CompactUnitFrame_HideAllDebuffs(frame);
			return;
		end

		local index = 1;
		local frameNum = 1;
		local filter = nil;
		local maxDebuffs = frame.maxDebuffs;
		--Show both Boss buffs & debuffs in the debuff location
		--First, we go through all the debuffs looking for any boss flagged ones.
		while ( frameNum <= maxDebuffs ) do
			local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
			if ( debuffName ) then
				if ( CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, false) ) then
					local debuffFrame = frame.debuffFrames[frameNum];
					CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, true, false);
					frameNum = frameNum + 1;
					--Boss debuffs are about twice as big as normal debuffs, so display one less.
					local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize
					maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
				end
			else
				break;
			end
			index = index + 1;
		end
		--Then we go through all the buffs looking for any boss flagged ones.
		index = 1;
		while ( frameNum <= maxDebuffs ) do
			local debuffName = UnitBuff(frame.displayedUnit, index, filter);
			if ( debuffName ) then
				if ( CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, true) ) then
					local debuffFrame = frame.debuffFrames[frameNum];
					CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, true, true);
					frameNum = frameNum + 1;
					--Boss debuffs are about twice as big as normal debuffs, so display one less.
					local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize
					maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
				end
			else
				break;
			end
			index = index + 1;
		end

		--Now we go through the debuffs with a priority (e.g. Weakened Soul and Forbearance)
		index = 1;
		while ( frameNum <= maxDebuffs ) do
			local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
			if ( debuffName ) then
				if ( CompactUnitFrame_UtilIsPriorityDebuff(frame.displayedUnit, index, filter) ) then
					local debuffFrame = frame.debuffFrames[frameNum];
					CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, false, false);
					frameNum = frameNum + 1;
				end
			else
				break;
			end
			index = index + 1;
		end

		if ( frame.optionTable.displayOnlyDispellableDebuffs ) then
			filter = "RAID";
		end

		index = 1;
		--Now, we display all normal debuffs.
		if ( frame.optionTable.displayNonBossDebuffs ) then
		while ( frameNum <= maxDebuffs ) do
			local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
			if ( debuffName ) then
				if ( CompactUnitFrame_UtilShouldDisplayDebuff(frame.displayedUnit, index, filter) and not CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, false) and
					not CompactUnitFrame_UtilIsPriorityDebuff(frame.displayedUnit, index, filter)) then
					local debuffFrame = frame.debuffFrames[frameNum];
					CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, false, false);
					frameNum = frameNum + 1;
				end
			else
				break;
			end
			index = index + 1;
		end
		end

		for i=frameNum, frame.maxDebuffs do
			local debuffFrame = frame.debuffFrames[i];
			debuffFrame:Hide();
		end
	end

	local dispellableDebuffTypes = { Magic = true, Curse = true, Disease = true, Poison = true};
	function CompactUnitFrame_UpdateDispellableDebuffs(frame, forHookingOnly)
		if forHookingOnly then
			return;
		end

		if ( not frame.dispelDebuffFrames or not frame.optionTable.displayDispelDebuffs ) then
			CompactUnitFrame_HideAllDispelDebuffs(frame);
			return;
		end

		--Clear what we currently have.
		for debuffType, display in pairs(dispellableDebuffTypes) do
			if ( display ) then
				frame["hasDispel"..debuffType] = false;
			end
		end

		local index = 1;
		local frameNum = 1;
		local filter = "RAID";	--Only dispellable debuffs.
		while ( frameNum <= frame.maxDispelDebuffs ) do
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(frame.displayedUnit, index, filter);
			if ( dispellableDebuffTypes[debuffType] and not frame["hasDispel"..debuffType] ) then
				frame["hasDispel"..debuffType] = true;
				local dispellDebuffFrame = frame.dispelDebuffFrames[frameNum];
				CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
				frameNum = frameNum + 1;
			elseif ( not name ) then
				break;
			end
			index = index + 1;
		end
		for i=frameNum, frame.maxDispelDebuffs do
			local dispellDebuffFrame = frame.dispelDebuffFrames[i];
			dispellDebuffFrame:Hide();
		end
	end

	function CompactUnitFrame_UpdateAuras_BackwardsCompat(frame)
		local forHookingOnly = true;
		CompactUnitFrame_UpdateBuffs(frame, forHookingOnly);
		CompactUnitFrame_UpdateDebuffs(frame, forHookingOnly);
		CompactUnitFrame_UpdateDispellableDebuffs(frame, forHookingOnly);
	end
end

-- BuffFrame.lua changes
do
	function AuraButton_Update_BackwardsCompat(buff, unit, index, filter)
		local name, _;
		name, texture, count, debuffType, duration, expirationTime, _, _, _, _, _, _, _, _, timeMod = UnitAura(unit, index, filter);

		if not name then
			-- No buff so hide it if it exists
			if ( buff ) then
				buff:Hide();
				buff.duration:Hide();
			end
			return;
		end
		return texture, count, debuffType, duration, expirationTime, timeMod;
	end
end

-- Party changes
do
	LeaveParty = C_PartyInfo.LeaveParty;
	ConvertToRaid = C_PartyInfo.ConvertToRaid;
	ConvertToParty = C_PartyInfo.ConvertToParty;
	CanGroupInvite = C_PartyInfo.CanInvite;
	InviteToGroup = C_PartyInfo.InviteUnit;
	InviteUnit = C_PartyInfo.InviteUnit;
	RequestInviteFromUnit = C_PartyInfo.RequestInviteFromUnit;

	function RealPartyIsFull()
		if ( (GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME) < MAX_PARTY_MEMBERS) or (IsInRaid(LE_PARTY_CATEGORY_HOME) and (GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) < MAX_RAID_MEMBERS)) ) then
			return false;
		else
			return true;
		end
	end
end

-- PVP Scoreboard changes
-- Use GetMatchPVPStatIDs replaced with GetMatchPVPStatColumns. These are being ordered
-- for backward compatibility.
do
	C_PvP.GetMatchPVPStatIDs = function()
		local statColumns = C_PvP.GetMatchPVPStatColumns();
		table.sort(statColumns, function(lhs,rhs)
			return lhs.orderIndex < rhs.orderIndex;
		end);

		local pvpStatIDs = {};
		for index = 1, #statColumns do
			tinsert(pvpStatIDs, statColumns[index].pvpStatID)
		end

		return pvpStatIDs;
	end
end