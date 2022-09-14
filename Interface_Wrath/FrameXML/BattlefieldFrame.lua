NUM_DISPLAYED_BATTLEGROUNDS = 5;

local PVPBATTLEGROUND_TEXTURELIST = {};
PVPBATTLEGROUND_TEXTURELIST[1] = "Interface\\PVPFrame\\PvpBg-AlteracValley";
PVPBATTLEGROUND_TEXTURELIST[2] = "Interface\\PVPFrame\\PvpBg-WarsongGulch";
PVPBATTLEGROUND_TEXTURELIST[3] = "Interface\\PVPFrame\\PvpBg-ArathiBasin";
PVPBATTLEGROUND_TEXTURELIST[7] = "Interface\\PVPFrame\\PvpBg-EyeOfTheStorm";
PVPBATTLEGROUND_TEXTURELIST[9] = "Interface\\PVPFrame\\PvpBg-StrandOfTheAncients";
PVPBATTLEGROUND_TEXTURELIST[30] = "Interface\\PVPFrame\\PvpBg-IsleOfConquest";
PVPBATTLEGROUND_TEXTURELIST[32] = "Interface\\PVPFrame\\PvpRandomBg";

BATTLEFIELD_SHUTDOWN_TIMER = 0;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
PREVIOUS_BATTLEFIELD_MOD = 0;
BATTLEFIELD_TIMER_DELAY = 3;
CURRENT_BATTLEFIELD_QUEUES = {};
PREVIOUS_BATTLEFIELD_QUEUES = {};
BATTLEFIELD_FRAME_FADE_TIME = 0.15

function BattlefieldFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	RequestPVPRewards();

	BattlefieldFrame.timerDelay = 0;
end

function BattlefieldFrame_OnEvent(self, event, ...)
	if ( event == "BATTLEFIELDS_SHOW") then
		self.currentData = true;
		if ( not IsBattlefieldArena() ) then
			ShowUIPanel(BattlefieldFrame);
			BattlefieldFrame_UpdatePanelInfo();
		end
	elseif ( event == "BATTLEFIELDS_CLOSED") then
		HideUIPanel(BattlefieldFrame);
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPBattleground_UpdateQueueStatus();
		BattlefieldFrame_UpdateStatus(false);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestPVPRewards();
		FauxScrollFrame_SetOffset(BattlefieldFrameTypeScrollFrame, 0);
		FauxScrollFrame_OnVerticalScroll(BattlefieldFrameTypeScrollFrame, 0, 16, PVPBattleground_UpdateBattlegrounds); --We may be changing brackets, so we don't want someone to see an outdated version of the data.
		if ( self.selectedBG ) then
			PVPBattleground_ResetInfo();
			PVPBattleground_UpdateJoinButton(self.selectedBG);
		end
	elseif ( event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		BattlefieldFrame_UpdateGroupAvailable();
	end
end

function BattlefieldTimerFrame_OnUpdate(self, elapsed)
	local keepUpdating = false;
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		keepUpdating = true;
		BattlefieldIconText:Hide();
	else
		local lowestExpiration = 0;
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local expiration = GetBattlefieldPortExpiration(i);
			if ( expiration > 0 ) then
				if( expiration < lowestExpiration or lowestExpiration == 0 ) then
					lowestExpiration = expiration;
				end
	
				keepUpdating = true;
			end
		end

		if( lowestExpiration > 0 and lowestExpiration <= 10 ) then
			BattlefieldIconText:SetText(lowestExpiration);
			BattlefieldIconText:Show();
		else
			BattlefieldIconText:Hide();
		end
	end
	
	if ( not keepUpdating ) then
		BattlefieldTimerFrame:SetScript("OnUpdate", nil);
		return;
	end
	
	local frame = BattlefieldFrame

	BATTLEFIELD_SHUTDOWN_TIMER = BATTLEFIELD_SHUTDOWN_TIMER - elapsed;
	-- Set the time for the score frame
	WorldStateScoreFrameTimer:SetFormattedText(SecondsToTimeAbbrev(BATTLEFIELD_SHUTDOWN_TIMER));
	-- Check if I should send a message only once every 3 seconds (BATTLEFIELD_TIMER_DELAY)
	BattlefieldFrame.timerDelay = BattlefieldFrame.timerDelay + elapsed;
	if ( BattlefieldFrame.timerDelay < BATTLEFIELD_TIMER_DELAY ) then
		return;
	else
		BattlefieldFrame.timerDelay = 0
	end
	
	local threshold = BATTLEFIELD_TIMER_THRESHOLDS[BATTLEFIELD_TIMER_THRESHOLD_INDEX];
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		if ( BATTLEFIELD_SHUTDOWN_TIMER < threshold and BATTLEFIELD_TIMER_THRESHOLD_INDEX ~= getn(BATTLEFIELD_TIMER_THRESHOLDS) ) then
			-- If timer past current threshold advance to the next one
			BATTLEFIELD_TIMER_THRESHOLD_INDEX = BATTLEFIELD_TIMER_THRESHOLD_INDEX + 1;
		else
			-- See if time should be posted
			local currentMod = floor(BATTLEFIELD_SHUTDOWN_TIMER/threshold);
			if ( PREVIOUS_BATTLEFIELD_MOD ~= currentMod ) then
				-- Print message
				local info = ChatTypeInfo["SYSTEM"];
				local string;
				if ( GetBattlefieldWinner() ) then
					local isArena = IsActiveBattlefieldArena();
					if ( isArena ) then
						string = format(ARENA_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					else
						string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					end
				else
					string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
				end
				DEFAULT_CHAT_FRAME:AddMessage(string, info.r, info.g, info.b, info.id);
				PREVIOUS_BATTLEFIELD_MOD = currentMod;
				
			end
		end
	else
		BATTLEFIELD_SHUTDOWN_TIMER = 0;
	end
end

function BattlefieldFrame_UpdatePanelInfo()
	if(not IsBattlefieldArena()) then
		RequestPVPRewards();
		PVPBattleground_ResetInfo();
		BattlefieldFrame_UpdateStatus(false);
	end
end

function GetRandomBGHonorCurrencyBonuses()
	local honorWin,_,_, currencyRewardsWin = C_PvP.GetRandomBGRewards();
	local honorLoss,_,_, currencyRewardsLoss = C_PvP.GetRandomBGLossRewards();
	local conquestWin, conquestLoss = 0, 0;

	if(currencyRewardsWin) then
		for i, reward in ipairs(currencyRewardsWin) do
			if reward.id == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID then
				conquestWin = reward.quantity;
			end
		end
	end

	if(currencyRewardsLoss) then
		for i, reward in ipairs(currencyRewardsLoss) do
			if reward.id == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID then
				conquestLoss = reward.quantity;
			end
		end
	end

	return true, honorWin, conquestWin, honorLoss, conquestLoss;
end

function GetHolidayBGHonorCurrencyBonuses()
	local honorWin,_,_, currencyRewardsWin = C_PvP.GetRandomBGRewards();
	local honorLoss,_,_, currencyRewardsLoss = C_PvP.GetRandomBGLossRewards();
	local conquestWin, conquestLoss = 0, 0;

	if(currencyRewardsWin) then
		for i, reward in ipairs(currencyRewardsWin) do
			if reward.id == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID then
				conquestWin = reward.quantity;
			end
		end
	end

	if(currencyRewardsLoss) then
		for i, reward in ipairs(currencyRewardsLoss) do
			if reward.id == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID then
				conquestLoss = reward.quantity;
			end
		end
	end

	return true, honorWin, conquestWin, honorLoss, conquestLoss;
end

function PVPQueue_UpdateRandomInfo(base, infoFunc)
	local BGname, canEnter, isHoliday, isRandom = infoFunc();
	
	local hasWin, lossHonor, winHonor, winArena, lossArena;
	
	if ( isRandom ) then
		hasWin, winHonor, winArena, lossHonor, lossArena = GetRandomBGHonorCurrencyBonuses();
		base.title:SetText(RANDOM_BATTLEGROUND);
		base.description:SetText(RANDOM_BATTLEGROUND_EXPLANATION);
	else
		base.title:SetText(BATTLEGROUND_HOLIDAY);
		base.description:SetText(BATTLEGROUND_HOLIDAY_EXPLANATION);
		hasWin, winHonor, winArena, lossHonor, lossArena = GetHolidayBGHonorCurrencyBonuses();
	end
	
	if (winHonor ~= 0) then
		base.winReward.honorSymbol:Show();
		base.winReward.honorAmount:Show();
		base.winReward.honorAmount:SetText(winHonor);
	else
		base.winReward.honorSymbol:Hide();
		base.winReward.honorAmount:Hide();
	end
	
	if (winArena ~= 0) then
		base.winReward.arenaSymbol:Show();
		base.winReward.arenaAmount:Show();
		base.winReward.arenaAmount:SetText(winArena);
	else
		base.winReward.arenaSymbol:Hide();
		base.winReward.arenaAmount:Hide();
	end
	
	if (lossHonor ~= 0) then
		base.lossReward.honorSymbol:Show();
		base.lossReward.honorAmount:Show();
		base.lossReward.honorAmount:SetText(lossHonor);
	else
		base.lossReward.honorSymbol:Hide();
		base.lossReward.honorAmount:Hide();
	end
	
	if (lossArena ~= 0) then
		base.lossReward.arenaSymbol:Show();
		base.lossReward.arenaAmount:Show();
		base.lossReward.arenaAmount:SetText(lossArena);
	else
		base.lossReward.arenaSymbol:Hide();
		base.lossReward.arenaAmount:Hide();
	end
		
	local englishFaction = UnitFactionGroup("player");
	base.winReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVP-Currency-"..englishFaction);
	base.lossReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVP-Currency-"..englishFaction);
end

function BattlegroundShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = BattlegroundShineFadeOut;
	UIFrameFade(BattlegroundShine, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function BattlegroundShineFadeOut()
	UIFrameFadeOut(BattlegroundShine, 0.5);
end

function IsAlreadyInQueue(mapName)
	local inQueue = nil;
	for index,value in ipairs(PREVIOUS_BATTLEFIELD_QUEUES) do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end

--Code copied from BattlefieldFrame below
function BattlefieldFrame_OnShow(self)
	if ( IsInInstance() ) then
		WintergraspTimer:Hide();
	else
		WintergraspTimer:Show();
	end
	
	SortBGList();
	
	BattlefieldFrame_UpdatePanelInfo();
	PVPBattleground_UpdateBattlegrounds(self, true);
	RequestBattlegroundInstanceInfo(self.selectedBG or 1);
end

function BattlefieldFrame_OnHide(self)
	ClearBattlemaster();
	UpdateMicroButtons();
end

function BattlefieldFrameCloseButton_OnClick(self)
	if ( PVPParentFrame ) then 
		HideUIPanel(PVPParentFrame)
	end
	UpdateMicroButtons();
end

function PVPBattleground_UpdateBattlegrounds(self, initializeSelectedBG)
	local frame;
	local localizedName, canEnter, isHoliday;
	local tempString, BGindex, isBig;
	
	local offset = FauxScrollFrame_GetOffset(BattlefieldFrameTypeScrollFrame);
	local currentFrameNum = -offset + 1;
	local numBGs = 0;
	
	for i=1,GetNumBattlegroundTypes() do
		frame = _G["BattlegroundType"..currentFrameNum];
		
		localizedName, canEnter, isHoliday = GetBattlegroundInfo(i);
		tempString = localizedName;
		if ( localizedName and canEnter ) then
			if ( frame ) then
				frame.BGindex = i;
				frame.localizedName = localizedName;

				if ( initializeSelectedBG and not BattlefieldFrame.selectedBG ) then
					BattlefieldFrame.selectedBG = i;
					PVPBattleground_ResetInfo();
					PVPBattleground_UpdateJoinButton(BattlefieldFrame.selectedBG);
				end
				
				frame:Enable();
				if ( isHoliday ) then
					tempString = tempString.." ("..BATTLEGROUND_HOLIDAY..")";
				end
			
				frame.title:SetText(tempString);
				frame:Show();
				if ( i == BattlefieldFrame.selectedBG ) then
					frame:LockHighlight();
				else
					frame:UnlockHighlight();
				end
			end
			currentFrameNum = currentFrameNum + 1;
			numBGs = numBGs + 1;
		end
	end
	
	if ( currentFrameNum <= NUM_DISPLAYED_BATTLEGROUNDS ) then
		isBig = true;	--Espand the highlight to cover where the scroll bar usually is.
	end
	
	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["BattlegroundType"..i];
		if ( isBig ) then
			frame:SetWidth(315);
		else
			frame:SetWidth(295);
		end
	end
	
	for i=currentFrameNum,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["BattlegroundType"..i];
		frame:Hide();
	end
	
	PVPBattleground_UpdateQueueStatus();
	
	BattlefieldFrame_UpdateGroupAvailable();
	FauxScrollFrame_Update(BattlefieldFrameTypeScrollFrame, numBGs, NUM_DISPLAYED_BATTLEGROUNDS, 16);
end

function PVPBattleground_UpdateInfo(BGindex)
	if ( type(BGindex) ~= "number" ) then
		BGindex = BattlefieldFrame.selectedBG;
	end
	
	local BGname, canEnter, isHoliday, isRandom, BattleGroundID, mapDescription = GetBattlegroundInfo(BGindex);

	
	if(PVPBATTLEGROUND_TEXTURELIST[BattleGroundID]) then
		BattlefieldFrameBGTex:SetTexture(PVPBATTLEGROUND_TEXTURELIST[BattleGroundID]);
	else
		BattlefieldFrameBGTex:SetTexture(PVPBATTLEGROUND_TEXTURELIST[32]);
	end
	
	if ( isRandom or isHoliday ) then
		PVPBattleground_UpdateRandomInfo();
		BattlefieldFrameInfoScrollFrameChildFrameRewardsInfo:Show();
		BattlefieldFrameInfoScrollFrameChildFrameDescription:Hide();
	else
		if ( mapDescription ~= BattlefieldFrameInfoScrollFrameChildFrameDescription:GetText() ) then
			BattlefieldFrameInfoScrollFrameChildFrameDescription:SetText(mapDescription);
			BattlefieldFrameInfoScrollFrame:SetVerticalScroll(0);
		end
		
		BattlefieldFrameInfoScrollFrameChildFrameRewardsInfo:Hide();
		BattlefieldFrameInfoScrollFrameChildFrameDescription:Show();
	end

end

function PVPBattleground_GetSelectedBattlegroundInfo()
	return GetBattlegroundInfo(BattlefieldFrame.selectedBG);
end

function PVPBattleground_UpdateRandomInfo()
	PVPQueue_UpdateRandomInfo(BattlefieldFrameInfoScrollFrameChildFrameRewardsInfo, PVPBattleground_GetSelectedBattlegroundInfo);
end

function PVPBattleground_UpdateQueueStatus()
	local queueStatus, queueMapName, queueInstanceID, frame;
	for i=1, NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["BattlegroundType"..i];
		frame.status:Hide();
	end
	local factionTexture = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player");
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
		if ( queueStatus ~= "none" ) then
			for j=1, NUM_DISPLAYED_BATTLEGROUNDS do
				local frame = _G["BattlegroundType"..j];
				if ( frame.localizedName == queueMapName ) then
					if ( queueStatus == "queued" ) then
						frame.status.texture:SetTexture(factionTexture);
						frame.status.texture:SetTexCoord(0.0, 1.0, 0.0, 1.0);
						frame.status.tooltip = BATTLEFIELD_QUEUE_STATUS;
						frame.status:Show();
					elseif ( queueStatus == "confirm" ) then
						frame.status.texture:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
						frame.status.texture:SetTexCoord(0.45, 0.95, 0.0, 0.5);
						frame.status.tooltip = BATTLEFIELD_CONFIRM_STATUS;
						frame.status:Show();
					end
				end
			end
		end
	end
end

function PVPBattleground_ResetInfo()	
	if ( BattlefieldFrame.selectedBG == nil ) then 
		BattlefieldFrame.selectedBG = 1; 
	end
	RequestBattlegroundInstanceInfo(BattlefieldFrame.selectedBG);
	
	PVPBattleground_UpdateInfo();
end

function PVPBattlegroundButton_OnClick(self)
	local offset = FauxScrollFrame_GetOffset(BattlefieldFrameTypeScrollFrame);
	local id = self:GetID() + offset;
	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		if ( id == i + offset ) then
			_G["BattlegroundType"..i]:LockHighlight();
		else
			_G["BattlegroundType"..i]:UnlockHighlight();
		end
	end
	
	if ( self.BGindex == BattlefieldFrame.selectedBG ) then
		return;
	end
	
	BattlefieldFrame.selectedBG = self.BGindex;
	
	PVPBattleground_ResetInfo();
	PVPBattleground_UpdateJoinButton(self.BGindex);
end

function PVPBattleground_UpdateJoinButton(BGindex)
	local mapName, mapDescription, maxGroup = GetBattlefieldInstanceInfo(BGindex);
	
	if ( maxGroup and maxGroup == 5 ) then
		BattlefieldFrameGroupJoinButton:SetText(JOIN_AS_PARTY);
	else
		BattlefieldFrameGroupJoinButton:SetText(JOIN_AS_GROUP);		
	end
end

function BattlefieldFrameJoinButton_OnClick(self)
	local joinAsGroup;
	if ( self == BattlefieldFrameGroupJoinButton ) then
		joinAsGroup = true;
	end
	
	JoinBattlefield(0, joinAsGroup);
end

function BattlefieldFrame_UpdateGroupAvailable()
	if ( GetNumGroupMembers() > 0 and UnitIsGroupLeader("player") ) then
		-- If this is true then can join as a group
		BattlefieldFrameGroupJoinButton:Enable();
	else
		BattlefieldFrameGroupJoinButton:Disable();
	end
end

function WintergraspTimer_OnLoad(self)
	self.canQueue = false;
	self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CANNOT_QUEUE;
	self.texture:SetTexCoord(0.0, 1.0, 0.0, 0.5);
end

function WintergraspTimer_OnUpdate(self, elapsed)
	local nextBattleTime = GetWintergraspWaitTime();
	if ( nextBattleTime and nextBattleTime > 60 ) then
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, SecondsToTime(nextBattleTime, true));
	elseif ( nextBattleTime and nextBattleTime > 0 ) then
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, SecondsToTime(nextBattleTime, false));
	else
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, WINTERGRASP_IN_PROGRESS);
	end

	local canQueue = CanQueueForWintergrasp();
	if ( self.canQueue ~= canQueue ) then
		-- simple safeguard so we're not doing a bunch of unnecessary work for each OnUpdate
		if ( canQueue ) then
			self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CAN_QUEUE;
			self.texture:SetTexCoord(0.0, 1.0, 0.5, 1.0);
		else
			self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CANNOT_QUEUE;
			self.texture:SetTexCoord(0.0, 1.0, 0.0, 0.5);
		end
		self.canQueue = canQueue;
	end
end