-- PVP Global Lua Constants


MAX_ARENA_TEAMS = 3;
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_ARENA_TEAM_MEMBERS_SHOWN = 6;
MAX_ARENA_TEAM_NAME_WIDTH = 310;


MAX_ARENA_TEAM_MEMBER_WIDTH = 320;
MAX_ARENA_TEAM_MEMBER_SCROLL_WIDTH = 300;

NUM_DISPLAYED_BATTLEGROUNDS = 5;

local PVPHONOR_TEXTURELIST = {};
PVPHONOR_TEXTURELIST[1] = "Interface\\PVPFrame\\PvpBg-AlteracValley";
PVPHONOR_TEXTURELIST[2] = "Interface\\PVPFrame\\PvpBg-WarsongGulch";
PVPHONOR_TEXTURELIST[3] = "Interface\\PVPFrame\\PvpBg-ArathiBasin";
PVPHONOR_TEXTURELIST[7] = "Interface\\PVPFrame\\PvpBg-EyeOfTheStorm";
PVPHONOR_TEXTURELIST[9] = "Interface\\PVPFrame\\PvpBg-StrandOfTheAncients";
PVPHONOR_TEXTURELIST[30] = "Interface\\PVPFrame\\PvpBg-IsleOfConquest";
PVPHONOR_TEXTURELIST[32] = "Interface\\PVPFrame\\PvpRandomBg";




---- NEW PVP FRAME FUNCTIONS
---- NEW PVP FRAME FUNCTIONS


function PVP_GetSelectedArenaTeam()
	if PVPFrame:IsVisible() and PVPTeamManagementFrame.selectedTeam then
		return PVPTeamManagementFrame.selectedTeam:GetID();
	end
	return nil;
end

function PVP_ArenaTeamFrame()
	return PVPTeamManagementFrame;
end


function PVPMicroButton_SetPushed()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 5, -31);
	PVPMicroButtonTexture:SetAlpha(0.5);
end

function PVPMicroButton_SetNormal()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 6, -30);
	PVPMicroButtonTexture:SetAlpha(1.0);
end


function TogglePVPFrame()
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
			ToggleFrame(PVPFrame);
	end
end


function PVPFrame_OnShow(self)
	PVPMicroButton_SetPushed();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	if (self.lastSelectedTab) then
		PVPFrame_TabClicked(self.lastSelectedTab);	
	end
end

function PVPFrame_OnHide()
	PVPMicroButton_SetNormal();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
end



function PVPFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 3)
	PVPFrame_TabClicked(PVPFrameTab1);				
	SetPortraitToTexture(PVPFramePortrait,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	PVPHonorFrameBgButton1:Click();	
	self:RegisterEvent("HONOR_CURRENCY_UPDATE");	
end

function PVPFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "HONOR_CURRENCY_UPDATE" ) then
		PVPFrame_UpdateCurrency(self);
	end
end



function PVPFrame_UpdateCurrency(self, value)
	local currency = 0;
	
	if value then
		currency = value
	else
		local index = self.lastSelectedTab:GetID()	
		if index == 1 then -- Honor Page	
			currency = GetHonorCurrency();
		elseif index == 2 then -- Conquest 
			currency = GetArenaCurrency();
		elseif index == 3 then -- Arena Management
			currency = GetArenaCurrency();
		end
	end
	-- if currency > 999 then
		-- PVPFrameTypeValue:SetFormattedText( "%d,%03d", floor(currency/1000),mod(currency, 1000));
	-- else
		PVPFrameTypeValue:SetText(currency);
	-- end
end



function PVPFrame_JoinClicked(self, isParty)
	local tabID =  PVPFrame.lastSelectedTab:GetID();
	if tabID == 1 then --Honor BGs
		JoinBattlefield(0, isParty);
	elseif tabID == 2 then
		if PVPConquestFrame.mode == "Arena" then
		--	JoinBattlefield(1, 1, 1);
		--else -- rated bg
		end
	elseif tabID == 3 then	
		StaticPopup_Show("ADD_TEAMMEMBER", nil, nil, PVPTeamManagementFrame.selectedTeam:GetID());
	end
end

function PVPFrame_TabClicked(self)
	local index = self:GetID()	
	PanelTemplates_SetTab(self:GetParent(), index);
	self:GetParent().lastSelectedTab = self;
	PVPFrameRightButton:Hide();
	PVPFrame.panel1:Hide();	
	PVPFrame.panel2:Hide();	
	PVPFrame.panel3:Hide();	
	PVPFrameTitleText:SetText(self:GetText());	
	PVPFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_BUTTON_OFFSET);		
	PVPFrame.topInset:Hide();
	local currency = 0;
	
	if index == 1 then -- Honor Page	
		PVPFrame.panel1:Show();
		PVPFrameRightButton:Show();
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameLeftButton:Enable();
		local factionGroup = UnitFactionGroup("player");
		PVPFrameTypeLable:SetText(HONOR);
		PVPFrameTypeLable:SetPoint("TOPRIGHT", -180, -38);
		PVPFrameConquestBar:Hide();
		PVPFrameTypeIcon:SetTexCoord(0.0, 0.58, 0, 0.58);
		PVPFrameTypeIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		currency = GetHonorCurrency();
	elseif index == 2 then -- Conquest 
		PVPFrame.panel2:Show();	
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameLeftButton:Enable();
		PVPFrameTypeLable:SetText(PVP_CONQUEST);
		PVPFrameTypeLable:SetPoint("TOPRIGHT", -195, -38);
		PVPFrameConquestBar:Show();
		PVPFrameTypeIcon:SetTexCoord(0.0, 1.0, 0, 1.0);
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
		currency = GetArenaCurrency();
	elseif index == 3 then -- Arena Management
		PVPFrameLeftButton:SetText(ADDMEMBER_TEAM);
		PVPFrameLeftButton:Disable();
		PVPFrame.panel3:Show();	
		PVPFrameTypeLable:SetText(PVP_CONQUEST);
		PVPFrameTypeLable:SetPoint("TOPRIGHT", -195, -38);
		PVPFrameConquestBar:Show();		
		PVPFrame.topInset:Show();
		PVPFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, -281);
		PVPFrameTypeIcon:SetTexCoord(0.0, 1.0, 0, 1.0);
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
		currency = GetArenaCurrency();
	end
	
	PVPFrame_UpdateCurrency(self, currency);
end



-- Honor Frame functions (the new BG page)
-- Honor Frame functions (the new BG page)

function PVPHonor_UpdateBattlegrounds()
	local frame;
	local localizedName, canEnter, isHoliday;
	local tempString, BGindex, isBig;
	
	local offset = FauxScrollFrame_GetOffset(PVPHonorFrameTypeScrollFrame);
	local currentFrameNum = -offset + 1;
	local numBGs = 0;
	
	for i=1,GetNumBattlegroundTypes() do
		frame = _G["PVPHonorFrameBgButton"..currentFrameNum];
		
		localizedName, canEnter, isHoliday = GetBattlegroundInfo(i);
		tempString = localizedName;
		if ( localizedName and canEnter ) then
			if ( frame ) then
				frame.BGindex = i;
				frame.localizedName = localizedName;
				if ( not PVPHonorFrame.selectedBG ) then
					PVPHonorFrame.selectedBG = i;
				end
				frame:Enable();
				if ( isHoliday ) then
					tempString = tempString.." ("..BATTLEGROUND_HOLIDAY..")";
				end
			
				frame.title:SetText(tempString);
				frame:Show();
				if ( i == PVPHonorFrame.selectedBG ) then
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
		frame = _G["PVPHonorFrameBgButton"..i];
		if ( isBig ) then
			frame:SetWidth(315);
		else
			frame:SetWidth(295);
		end
	end
	
	for i=currentFrameNum,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["PVPHonorFrameBgButton"..i];
		frame:Hide();
	end
	
	PVPHonor_UpdateQueueStatus();
	
	PVPHonorFrame_UpdateGroupAvailable();
	FauxScrollFrame_Update(PVPHonorFrameTypeScrollFrame, numBGs, NUM_DISPLAYED_BATTLEGROUNDS, 16);
end

function PVPHonor_UpdateInfo(BGindex)
	if ( type(BGindex) ~= "number" ) then
		BGindex = PVPHonorFrame.selectedBG;
	end
	
	local BGname, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(BGindex);

	
	if(PVPHONOR_TEXTURELIST[BattleGroundID]) then
		PVPHonorFrameBGTex:SetTexture(PVPHONOR_TEXTURELIST[BattleGroundID]);
	end
	
	if ( isRandom or isHoliday ) then
		PVPHonor_UpdateRandomInfo();
		PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Show();
		PVPHonorFrameInfoScrollFrameChildFrameDescription:Hide();
	else
		local mapName, mapDescription, maxGroup = GetBattlefieldInfo();
		if ( mapDescription ~= PVPHonorFrameInfoScrollFrameChildFrameDescription:GetText() ) then
			PVPHonorFrameInfoScrollFrameChildFrameDescription:SetText(mapDescription);
			PVPHonorFrameInfoScrollFrame:SetVerticalScroll(0);
		end
		
		PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Hide();
		PVPHonorFrameInfoScrollFrameChildFrameDescription:Show();
	end

end

function PVPHonor_GetSelectedBattlegroundInfo()
	return GetBattlegroundInfo(PVPHonorFrame.selectedBG);
end

function PVPHonor_UpdateRandomInfo()
	PVPQueue_UpdateRandomInfo(PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo, PVPHonor_GetSelectedBattlegroundInfo);
end

function PVPHonor_UpdateQueueStatus()
	local queueStatus, queueMapName, queueInstanceID, frame;
	for i=1, NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["PVPHonorFrameBgButton"..i];
		frame.status:Hide();
	end
	local factionTexture = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player");
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
		if ( queueStatus ~= "none" ) then
			for j=1, NUM_DISPLAYED_BATTLEGROUNDS do
				local frame = _G["PVPHonorFrameBgButton"..j];
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

function PVPHonorFrame_ResetInfo()	
	RequestBattlegroundInstanceInfo(PVPHonorFrame.selectedBG);
	
	PVPHonor_UpdateInfo();
end

function PVPHonorButton_OnClick(self)
	local offset = FauxScrollFrame_GetOffset(PVPHonorFrameTypeScrollFrame);
	local id = self:GetID() + offset;

	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		if ( id == i + offset ) then
			_G["PVPHonorFrameBgButton"..i]:LockHighlight();
		else
			_G["PVPHonorFrameBgButton"..i]:UnlockHighlight();
		end
	end
	
	if ( self.BGindex == PVPHonorFrame.selectedBG ) then
		return;
	end
	
	PVPHonorFrame.selectedBG = self.BGindex;
	
	PVPHonorFrame_ResetInfo();
	
	PVPHonorFrame_UpdateJoinButton();
end

function PVPHonorFrame_UpdateJoinButton()
	local mapName, mapDescription, maxGroup = GetBattlefieldInfo();	
	if ( maxGroup and maxGroup == 5 ) then
		PVPFrameRightButton:SetText(JOIN_AS_PARTY);
	else
		PVPFrameRightButton:SetText(JOIN_AS_GROUP);		
	end
end

function PVPHonorFrameJoinButton_OnClick(self)
	local joinAsGroup;
	if ( self == PVPHonorFrameGroupJoinButton ) then
		joinAsGroup = true;
	end
	
	JoinBattlefield(0, joinAsGroup);
end

function PVPHonorFrame_OnLoad(self)
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("NPC_PVPQUEUE_ANYWHERE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	
	PVPHonorFrame_UpdateVisible();	
	PVPHonorFrameBgButton1:Click();
end

function PVPHonorFrame_OnEvent(self, event, ...)
	if ( event == "PVPQUEUE_ANYWHERE_SHOW" or event == "NPC_PVPQUEUE_ANYWHERE") then
		self.currentData = true;
		PVPHonor_UpdateBattlegrounds();
		if ( self.selectedBG ) then
			PVPHonor_UpdateInfo();
		end
		if ( event == "NPC_PVPQUEUE_ANYWHERE" ) then
			--ShowUIPanel(PVPParentFrame);
			--PVPFrame_SetJustBG(true);
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPHonor_UpdateQueueStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		
		FauxScrollFrame_SetOffset(PVPHonorFrameTypeScrollFrame, 0);
		FauxScrollFrame_OnVerticalScroll(PVPHonorFrameTypeScrollFrame, 0, 16, PVPHonor_UpdateBattlegrounds); --We may be changing brackets, so we don't want someone to see an outdated version of the data.
		if ( self.selectedBG ) then
			PVPHonorFrame_ResetInfo();
			PVPHonorFrame_UpdateJoinButton();
		end
		PVPHonorFrame_UpdateVisible();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		PVPHonorFrame_UpdateGroupAvailable();
	end
end

function PVPHonorFrame_OnShow(self)	
	SortBGList();
	PVPHonor_UpdateBattlegrounds();
	RequestBattlegroundInstanceInfo(self.selectedBG or 1);
end

function PVPHonorFrame_OnHide(self)
	CloseBattlefield();
end

function PVPHonorFrame_UpdateVisible()
	-- for i=1, GetNumBattlegroundTypes() do
		-- local _, canEnter = GetBattlegroundInfo(i);
		-- if ( canEnter ) then
			-- if ( not PVPFrame_IsJustBG() ) then
				-- PVPParentFrameTab1:Show();
				-- PVPParentFrameTab2:Show();
			-- end
			-- return;
		-- end
	-- end
	-- PVPParentFrameTab1:Click();
	-- PVPParentFrameTab1:Hide();
	-- PVPParentFrameTab2:Hide();
end

function PVPHonorFrame_UpdateGroupAvailable()
	if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
		-- If this is true then can join as a group
		PVPFrameRightButton:Enable();
	else
		PVPFrameRightButton:Disable();
	end
end



-----------------------------------
---- PVPConquestFrame fUNCTIONS ---
-----------------------------------

function PVPConquestFrame_OnLoad(self)
	
	self.arenaButton.title:SetText(ARENA);
	self.ratedbgButton.title:SetText(PVP_RATED_BATTLEGROUND);		
	self.arenaButton:SetWidth(321);
	self.ratedbgButton:SetWidth(321);
	
	
	local factionGroup = UnitFactionGroup("player");
	self.infoButton.factionIcon = _G["PVPConquestFrameInfoButtonInfoIcon"..factionGroup];
	self.infoButton.factionIcon:Show();
end



function PVPConquestFrame_OnShow(self)
	if not self.clickedButton then
		self.clickedButton = self.arenaButton;
	end
	self.clickedButton:Click();
end

function PVPConquestFrame_ButtonClicked(button)
	if button:GetID() == 1 then --Arena
		PVPConquestFrame.mode = "Arena";
		button:LockHighlight();
		PVPConquestFrame.ratedbgButton:UnlockHighlight();
	else -- Rated BG	
		PVPConquestFrame.mode = "Arena";
		button:LockHighlight();
		PVPConquestFrame.arenaButton:UnlockHighlight();
	end
end


--  PVPTeamManagementFrame
--  PVPTeamManagementFrame

function PVPTeamManagementFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	
		for i=1, MAX_ARENA_TEAM_MEMBERS_SHOWN do
			button = _G["PVPTeamManagementFrameTeamMemberButton"..i];
			if mod(i, 2) == 0 then 
				button.BG:Show();
			else		
				button.BG:Hide();
			end
		end
end



function PVPTeamManagementFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "ARENA_TEAM_UPDATE"  or  event == "PLAYER_ENTERING_WORLD" ) then
		PVPTeamManagementFrame_UpdateTeams(self)
	elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
		PVPTeamManagementFrame_UpdateTeamInfo(self, self.selectedTeam);
	end
end



function PVPTeamManagementFrame_ToggleSeasonal(self)
	local parent  = self:GetParent();
	parent.seasonStats = not parent.seasonStats;	
	PVPTeamManagementFrame_UpdateTeamInfo(parent, parent.selectedTeam);
end

function PVPTeamManagementFrame_UpdateTeamInfo(self, flagbutton)
	if not  flagbutton  then 
		if self.selectedTeam then
			flagbutton = self.selectedTeam;
		else 
			self.invalidTeam:Hide();
			return;
		end
	end
	flagbutton.Glow:Show();	
	flagbutton.GlowHeader:Show();
	flagbutton.NormalHeader:Hide();
	flagbutton.title:SetFontObject("GameFontNormalSmall");
	
	self.selectedTeam = flagbutton;
	local teamIndex = flagbutton:GetID()
	ArenaTeamRoster(teamIndex);
	
	if  IsArenaTeamCaptain(teamIndex) then	
		PVPFrameLeftButton:Enable();
	else	
		PVPFrameLeftButton:Disable();
	end
	
	-- Pull Values
	teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, 
	seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(teamIndex);

	self.TeamData:Show()
	local TeamDataName = self.TeamData:GetName();

	if ( self.seasonStats ) then
		_G[TeamDataName.."TypeLabel"]:SetText(ARENA_THIS_SEASON);
		played = seasonTeamPlayed;
		wins = seasonTeamWins;
		playerPlayed = seasonPlayerPlayed;
		PvP_WeeklyText:SetText(ARENA_SEASON_STATS);
	else
		_G[TeamDataName.."TypeLabel"]:SetText(ARENA_THIS_WEEK);
		played = teamPlayed;
		wins = teamWins;
		playerPlayed = playerPlayed;
		PvP_WeeklyText:SetText(ARENA_WEEKLY_STATS);
	end

	loss = played - wins;
	-- Populate Data
	_G[TeamDataName.."Name"]:SetText(_G["ARENA_"..teamSize.."V"..teamSize].."  "..teamName);
	_G[TeamDataName.."Rating"]:SetText(teamRating);
	_G[TeamDataName.."Games"]:SetText(played);
	_G[TeamDataName.."Wins"]:SetText(wins);
	_G[TeamDataName.."Loss"]:SetText(loss);	
	 _G[TeamDataName.."Played"]:SetText(playerPlayed);
	 
	 
	--Show teammates at teamIndex
	local numMembers = GetNumArenaTeamMembers(teamIndex, 1);
	local scrollTeammates =  numMembers > MAX_ARENA_TEAM_MEMBERS_SHOWN;
	local TeammateButtonName = self:GetName().."TeamMemberButton";
	local scrollOffset =  FauxScrollFrame_GetOffset(self.teamMemberScrollFrame);
	
	
	
	if ( teamSize > numMembers ) then
		self.invalidTeam:Show();
		if IsArenaTeamCaptain(teamIndex) then
			self.invalidTeam.text:SetText(ARENA_CAPTAIN_INVALID_TEAM);
		else
			self.invalidTeam.text:SetText(ARENA_NOT_CAPTAIN_INVALID_TEAM);
		end		
	else
		self.invalidTeam:Hide();
	end
	
	local nameText, classText, playedText, winLossWin, winLossLoss, ratingText;
	-- Display Team Member Specific Info
	local playedValue, winValue, lossValue;
	for i=1, MAX_ARENA_TEAM_MEMBERS_SHOWN, 1 do
		button = _G[TeammateButtonName..i];		
		if  scrollTeammates then
			button:SetWidth(MAX_ARENA_TEAM_MEMBER_SCROLL_WIDTH);
		else
			button:SetWidth(MAX_ARENA_TEAM_MEMBER_WIDTH);		
		end	
		
		
		if ( i > numMembers ) then
			--button:Hide();
			button:Disable();
			_G[TeammateButtonName..i.."NameText"]:SetText("");
			--classText = _G[TeammateButtonName..i.."ClassText"];  ADD class color and Icon
			_G[TeammateButtonName..i.."PlayedText"]:SetText("");
			_G[TeammateButtonName..i.."WinLossText"]:SetText("");
			_G[TeammateButtonName..i.."RatingText"]:SetText("");
			_G[TeammateButtonName..i.."ClassIcon"]:Hide();
			_G[TeammateButtonName..i.."CaptainIcon"]:Hide();
		else
			button:Enable();
			button.playerIndex = i+scrollOffset;
			-- Get Data
			name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = GetArenaTeamRosterInfo(teamIndex, i+scrollOffset);
			loss = played - win;
			seasonLoss = seasonPlayed - seasonWin;

			-- Populate Data into the display, season or this week
			if ( self.seasonStats ) then
				playedValue = seasonPlayed;
				winValue = seasonWin;
				lossValue = seasonLoss;
				teamPlayed = seasonTeamPlayed;
			else
				playedValue = played;
				winValue = win;
				lossValue = loss;
				teamPlayed = teamPlayed;
			end			
			
			nameText = _G[TeammateButtonName..i.."NameText"];
			--classText = _G[TeammateButtonName..i.."ClassText"];  ADD class color and Icon
			playedText = _G[TeammateButtonName..i.."PlayedText"]
			winLossText = _G[TeammateButtonName..i.."WinLossText"];
			ratingText = _G[TeammateButtonName..i.."RatingText"];			
			if class then
				_G[TeammateButtonName..i.."ClassIcon"]:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
				_G[TeammateButtonName..i.."ClassIcon"]:Show();
			else
				_G[TeammateButtonName..i.."ClassIcon"]:Hide();
			end
			if  rank > 0 then
				_G[TeammateButtonName..i.."CaptainIcon"]:Hide();
			else
				_G[TeammateButtonName..i.."CaptainIcon"]:Show();
			end
			
			nameText:SetText(name);
			--classText:SetText(class);
			playedText:SetText(playedValue);
			winLossText:SetText(winValue.."-"..lossValue);
			ratingText:SetText(rating);
		
			-- Color Entries based on Online status
			local r, g, b;
			if ( online ) then
				if ( rank > 0 ) then
					r = 1.0;	g = 1.0;	b = 1.0;
				else
					r = 1.0;	g = 0.82;	b = 0.0;
				end
			else
				r = 0.5;	g = 0.5;	b = 0.5;
			end

			nameText:SetTextColor(r, g, b);
			playedText:SetTextColor(r, g, b);
			winLossText:SetTextColor(r, g, b);
			ratingText:SetTextColor(r, g, b);

			button:Show();

			-- Highlight the correct who
			if ( GetArenaTeamRosterSelection(teamIndex) == i ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		end		
	end	 
	
	FauxScrollFrame_Update(self.teamMemberScrollFrame, numMembers, MAX_ARENA_TEAM_MEMBERS_SHOWN, 18);
end


function PVPTeamManagementFrame_TeamInfo_OnScroll()
	PVPTeamManagementFrame_UpdateTeamInfo(PVPTeamManagementFrame, PVPTeamManagementFrame.selectedTeam);
end


function PVPTeamManagementFrame_FlagClicked(self)
	local index = self:GetID();
	if index < 0 then   -- Player clicked a flag that is not associated with a current team
		-- Try to make a new Arena Team.
			local teamSize = abs(index);
			PVPBannerFrame.teamSize = teamSize;
			ShowUIPanel(PVPBannerFrame);
			PVPBannerFrameTitleText:SetText(_G["ARENA_"..teamSize.."V"..teamSize]);
	else
		if  self:GetParent().selectedTeam then
			self:GetParent().selectedTeam.Glow:Hide();		
			self:GetParent().selectedTeam.GlowHeader:Hide();
			self:GetParent().selectedTeam.NormalHeader:Show();			
			self:GetParent().selectedTeam.title:SetFontObject("GameFontHighlightSmall");	
			HideUIPanel(PVPBannerFrame);
		end
		PVPTeamManagementFrame_UpdateTeamInfo(self:GetParent(), self);	
		FauxScrollFrame_SetOffset(self:GetParent().teamMemberScrollFrame, 0);
	end
end


function PVPTeamManagementFrame_UpdateTeams(self)
		
		self.defaultTeam = nil;
		local bannerName = "";
		local flagsList = {};
		flagsList[2] = false;
		flagsList[3] = false;
		flagsList[5] = false;	
		
		local teamName, teamSize, teamRating, emblem, border;
		local background = {}; 
		local emblemColor = {} ;
		local borderColor = {}; 		

		for i=1, MAX_ARENA_TEAMS do
			--the ammount of parameter this returns is absurd
			teamName, teamSize, teamRating, _,  _,  _, _, _, _, _, _, 
			background.r, background.g, background.b, 
			emblem, emblemColor.r, emblemColor.g, emblemColor.b, 
			border, borderColor.r, borderColor.g, borderColor.b 												= GetArenaTeam(i);			

			if teamName then
				flagsList[teamSize] = true;			
				bannerName = self["flag"..teamSize]:GetName();
				_G[bannerName]:Enable();
				_G[bannerName]:SetID(i);
				_G[bannerName.."Banner"]:SetVertexColor(background.r, background.g, background.b);
				_G[bannerName.."Emblem"]:Show();
				_G[bannerName.."Emblem"]:SetVertexColor( emblemColor.r, emblemColor.g, emblemColor.b);
				_G[bannerName.."Emblem"]:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
				_G[bannerName.."Border"]:Show();
				_G[bannerName.."Border"]:SetVertexColor( borderColor.r, borderColor.g, borderColor.b );				
				_G[bannerName.."Border"]:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..border);
				_G[bannerName.."Title"]:SetText(_G["ARENA_"..teamSize.."V"..teamSize].."\n"..RATING..":  "..teamRating);
				_G[bannerName.."Title"]:SetFontObject("GameFontHighlightSmall");
				
				if not self.defaultTeam then
					self.defaultTeam =  _G[bannerName];	
				end
			end
		end	
	
		for size, value in pairs(flagsList) do 
			if  not value then 
				local bannerName = self["flag"..size]:GetName();
				_G[bannerName]:SetID(-size);
				_G[bannerName.."Banner"]:SetVertexColor(1, 1, 1);
				_G[bannerName.."Emblem"]:Hide();
				_G[bannerName.."Border"]:Hide();
				_G[bannerName.."Title"]:SetText(_G["ARENA_"..size.."V"..size]);
				_G[bannerName.."Title"]:SetFontObject("GameFontHighlight");
				_G[bannerName.."HeaderSelected"]:Hide();
				_G[bannerName.."Header"]:Show();
				_G[bannerName.."GlowBG"]:Hide();
				if  self.selectedTeam == self["flag"..size] then
					self.selectedTeam = nil;
				end
			end
		end

		self.noTeams:Hide();
		if  self.selectedTeam then 
			PVPTeamManagementFrame_UpdateTeamInfo(self, self.selectedTeam)
		elseif  self.defaultTeam then 
			PVPTeamManagementFrame_UpdateTeamInfo(self, self.defaultTeam)
		else
			--We have not arena teams
			self.noTeams:Show();
			self.noTeams:SetFrameLevel(self:GetFrameLevel() +3);			
			FauxScrollFrame_Update(self.teamMemberScrollFrame, 0, MAX_ARENA_TEAM_MEMBERS_SHOWN, 18);
		end	
end


function PVPTeamManagementFrame_OnShow(self)
	PVPTeamManagementFrame_UpdateTeams(self)
end





















function PVPTeamManagementFrame_DropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "TEAM", nil, PVPTeamManagementFrameTeamDropDown.name);
end

function PVPTeamManagementFrame_ShowDropdown(name, online)
	HideDropDownMenu(1);
	
	if ( not IsArenaTeamCaptain(PVPTeamManagementFrame.selectedTeam:GetID()) ) then
		if ( online ) then
			PVPTeamManagementFrameTeamDropDown.initialize = PVPTeamManagementFrame_DropDown_Initialize;
			PVPTeamManagementFrameTeamDropDown.displayMode = "MENU";
			PVPTeamManagementFrameTeamDropDown.name = name;
			PVPTeamManagementFrameTeamDropDown.online = online;
			ToggleDropDownMenu(1, nil, PVPTeamManagementFrameTeamDropDown, "cursor");
		end
	else
		PVPTeamManagementFrameTeamDropDown.initialize = PVPTeamManagementFrame_DropDown_Initialize;
		PVPTeamManagementFrameTeamDropDown.displayMode = "MENU";
		PVPTeamManagementFrameTeamDropDown.name = name;
		PVPTeamManagementFrameTeamDropDown.online = online;
		ToggleDropDownMenu(1, nil, PVPTeamManagementFrameTeamDropDown, "cursor");
	end
end


