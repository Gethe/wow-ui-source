CVarCallbackRegistry:SetCVarCachable("rotateMinimap");

MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;
MINIMAP_BOTTOM_EDGE_EXTENT = 192;	-- pixels from the top of the screen to the bottom edge of the minimap, needed for UIParentManageFramePositions

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;
HUNTER_TRACKING = 1;
TOWNSFOLK = 2;

MAX_BATTLEFIELD_QUEUES = 3;

local PlaySound = PlaySound;
local BATTLEFIELD_FRAME_FADE_TIME = 0.15;

local IS_GUILD_GROUP = false;

function Minimap_OnLoad(self)
	self.fadeOut = nil;
	self:RegisterEventCallback("MINIMAP_PING", function() PlaySound(SOUNDKIT.MAP_PING); end);
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");

	if MiniMap_ShouldShowWorldMapButton() then
		MiniMapWorldMapButton:Show();
	end
end

function ToggleMinimap()
	if(Minimap:IsShown()) then
		PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE);
		Minimap:Hide();
		if GameTimeFrame then
			GameTimeFrame:Hide();
		end
	else
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN);
		Minimap:Show();
		if GameTimeFrame then
			GameTimeFrame:Show();
		end
	end
	UpdateUIPanelPositions();
end

function Minimap_Update()
	MinimapZoneText:SetText(GetMinimapZoneText());

	local pvpType, isSubZonePvP, factionName = C_PvP.GetZonePVPInfo();
	if ( pvpType == "sanctuary" ) then
		MinimapZoneText:SetTextColor(0.41, 0.8, 0.94);
	elseif ( pvpType == "arena" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		MinimapZoneText:SetTextColor(0.1, 1.0, 0.1);
	elseif ( pvpType == "hostile" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "contested" ) then
		MinimapZoneText:SetTextColor(1.0, 0.7, 0.0);
	else
		MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	Minimap_SetTooltip( pvpType, factionName );
end

function Minimap_SetTooltip( pvpType, factionName )
	if ( GameTooltip:IsOwned(MinimapZoneTextButton) ) then
		GameTooltip:SetOwner(MinimapZoneTextButton, "ANCHOR_LEFT");
		GameTooltip:AddLine( GetMinimapZoneText() );
		if ( pvpType == "sanctuary" ) then
			GameTooltip:AddLine(SANCTUARY_TERRITORY);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY);
		elseif ( pvpType == "friendly" ) then
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName));
			end
		elseif ( pvpType == "hostile" ) then
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName));
			end
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine(CONTESTED_TERRITORY);
		elseif ( pvpType == "combat" ) then
			GameTooltip:AddLine(COMBAT_ZONE);
		end
		GameTooltip:Show();
	end
end

function Minimap_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self:UpdateBlips();
	elseif ( event == "MINIMAP_UPDATE_ZOOM" ) then
		MinimapZoomIn:Enable();
		MinimapZoomOut:Enable();
		local zoom = Minimap:GetZoom();
		if ( zoom == (Minimap:GetZoomLevels() - 1) ) then
			MinimapZoomIn:Disable();
		elseif ( zoom == 0 ) then
			MinimapZoomOut:Disable();
		end
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		Minimap_Update();
	end
end

function Minimap_ZoomInClick()
	MinimapZoomOut:Enable();
	PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN);
	Minimap:SetZoom(Minimap:GetZoom() + 1);
	if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
		MinimapZoomIn:Disable();
	end
end

function Minimap_ZoomOutClick()
	MinimapZoomIn:Enable();
	PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT);
	Minimap:SetZoom(Minimap:GetZoom() - 1);
	if(Minimap:GetZoom() == 0) then
		MinimapZoomOut:Disable();
	end
end

function Minimap_OnClick(self)
	local x, y = GetCursorPosition();
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local cx, cy = self:GetCenter();
	x = x - cx;
	y = y - cy;
	if ( sqrt(x * x + y * y) < (self:GetWidth() / 2) ) then
		Minimap:PingLocation(x, y);
	end
end

function Minimap_ZoomIn()
	MinimapZoomIn:Click();
end

function Minimap_ZoomOut()
	MinimapZoomOut:Click();
end

MinimapClusterMixin = { };

function MinimapClusterMixin:OnLoad()
	Minimap.timer = 0;
	Minimap_Update();
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	-- Cache minimap piece points so we can reset them if needed
	local function CacheFramePoints(frame)
		frame.defaultFramePoints = {};
		for i = 1, frame:GetNumPoints() do
			local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(i);
			frame.defaultFramePoints[i] = { point = point, relativeTo = relativeTo, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY };
		end
	end
	CacheFramePoints(self.MinimapContainer);
	CacheFramePoints(self.BorderTop);
	
	GuildInstanceDifficulty:SetFrameLevel(self:GetFrameLevel() + 10);
	MiniMapChallengeMode:SetFrameLevel(self:GetFrameLevel() + 10);

	CVarCallbackRegistry:RegisterCallback("rotateMinimap", self.OnUpdateRotationSetting, self);
	self:OnUpdateRotationSetting();
end

function MinimapClusterMixin:OnEvent(event, ...)
	Minimap_Update();
end

function MinimapClusterMixin:SetEditModeScale(scale)
	self.MinimapContainer:SetScale(scale);
	if (self.scaleMinimapHeader) then
		local headerScale = max(scale, 1.0);
		self.BorderTop:SetScale(headerScale);
		self.ZoneTextButton:SetScale(headerScale);
		self.ToggleButton:SetScale(headerScale);
	end
end

local function ResetFramePoints(frame, accountForFrameScale)
	local scale = accountForFrameScale and frame:GetScale() or 1;

	frame:ClearAllPoints();
	for i, value in ipairs(frame.defaultFramePoints) do
		frame:SetPoint(value.point, value.relativeTo, value.relativePoint, value.offsetX / scale, value.offsetY / scale);
	end
end

function MinimapClusterMixin:SetHeaderUnderneath(headerUnderneath)
	if (headerUnderneath) then
		-- Since minimap container can be scaled, account for it's scale when setting offsets
		self.MinimapContainer:ClearAllPoints();
		self.MinimapContainer:SetPoint("TOP", self, "TOP", 0, 0);

		self.BorderTop:ClearAllPoints();
		self.BorderTop:SetPoint("TOP", self.MinimapContainer, "BOTTOM", 0, -6);
	else
		local accountForFrameScaleYes = true;
		ResetFramePoints(self.BorderTop, accountForFrameScaleYes);
		ResetFramePoints(self.MinimapContainer, accountForFrameScaleYes);
	end
end

function MinimapClusterMixin:SetRotateMinimap(rotateMinimap)
	SetCVar("rotateMinimap", rotateMinimap);
end

function MinimapClusterMixin:OnUpdateRotationSetting()
	if ( CVarCallbackRegistry:GetCVarValueBool("rotateMinimap") ) then
		MinimapCompassTexture:Show();
		MinimapNorthTag:Hide();
	else
		MinimapCompassTexture:Hide();
		MinimapNorthTag:Show();
	end
end

function ToggleMiniMapRotation()
	SetCVar("rotateMinimap", CVarCallbackRegistry:GetCVarValueBool("rotateMinimap") and "0" or "1");
end

function MinimapButton_OnMouseDown(self, mouseButton)
	if ( self.isDown ) then
		return;
	end
	local button = _G[self:GetName().."Icon"];
	local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint(1);
	button:SetPoint(point, relativeTo, relativePoint, offsetX+1, offsetY-1);
	self.isDown = 1;
end
function MinimapButton_OnMouseUp(self)
	if ( not self.isDown ) then
		return;
	end
	local button = _G[self:GetName().."Icon"];
	local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint(1);
	button:SetPoint(point, relativeTo, relativePoint, offsetX-1, offsetY+1);
	self.isDown = nil;
end

function MinimapMailFrameUpdate()
	local sender1,sender2,sender3 = GetLatestThreeSenders();
	local toolText;

	if( sender1 or sender2 or sender3 ) then
		toolText = HAVE_MAIL_FROM;
	else
		toolText = HAVE_MAIL;
	end

	if( sender1 ) then
		toolText = toolText.."\n"..sender1;
	end
	if( sender2 ) then
		toolText = toolText.."\n"..sender2;
	end
	if( sender3 ) then
		toolText = toolText.."\n"..sender3;
	end
	GameTooltip:SetText(toolText);
end

-- ============================================ BATTLEFIELDS ===============================================================================
function MiniMapBattlefieldFrame_OnClick(self, button)
	-- Hide tooltip
	GameTooltip:Hide();
	if ( button == "RightButton" ) then
		MiniMapBattlefieldFrame_ShowContextMenu(self);
	elseif ( self.status == "active") then
		if ( IsShiftKeyDown() ) then
			ToggleBattlefieldMap();
		else
			ToggleWorldStateScoreFrame();
		end
    end
end

function MiniMapBattlefieldFrame_ShowContextMenu(owner)
	MenuUtil.CreateContextMenu(owner, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_MINIMAP_BATTLEFIELD");

		local numShown = 0;

		for i=1, MAX_BATTLEFIELD_QUEUES do
			local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, isRankedArena, _, _, _, _, _, asGroup = GetBattlefieldStatus(i);
			if ( status ~= "none" ) then
				numShown = numShown + 1;
				if ( numShown > 1 ) then
					rootDescription:CreateSpacer();
				end
			end

			if ( status == "queued" or status == "confirm" ) then
				local text;
				if ( teamSize ~= 0 ) then
					if ( isRankedArena ) then
						text = ARENA_RATED_MATCH.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
					else
						text = ARENA_CASUAL.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
					end
				else
					text = mapName;
				end
				rootDescription:CreateTitle(text);

				if ( status == "queued" ) then
					local button = rootDescription:CreateButton(LEAVE_QUEUE, function()
						AcceptBattlefieldPort(i);
					end);

					if asGroup and not UnitIsGroupLeader("player") then
						button:SetEnabled(false);
					end
				elseif ( status == "confirm" ) then
					rootDescription:CreateButton(ENTER_BATTLE, function()
						AcceptBattlefieldPort(i, 1);
					end);

					if ( teamSize == 0 ) then
						rootDescription:CreateButton(LEAVE_QUEUE, function()
							AcceptBattlefieldPort(i);
						end);
					end
				end
			elseif ( status == "active" ) then
				local titleText;
				if ( teamSize ~= 0 ) then
					titleText = mapName.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					titleText = mapName;
				end
				rootDescription:CreateTitle(titleText);

				local text = IsActiveBattlefieldArena() and LEAVE_ARENA or LEAVE_BATTLEGROUND;
				rootDescription:CreateButton(text, function()
					LeaveBattlefield();
				end);
			end
		end
	end);
end

function BattlefieldFrame_UpdateStatus(tooltipOnly, mapIndex)
	local numberQueues = 0;
	local waitTime, timeInQueue;
	local tooltip;
	local showRightClickText;
	BATTLEFIELD_SHUTDOWN_TIMER = 0;

	-- Reset tooltip
	MiniMapBattlefieldFrame.tooltip = nil;
	MiniMapBattlefieldFrame.waitTime = {};
	MiniMapBattlefieldFrame.status = nil;
	
	-- Copy current queues into previous queues
	if ( not tooltipOnly ) then
		PREVIOUS_BATTLEFIELD_QUEUES = {};
		for index, value in ipairs(CURRENT_BATTLEFIELD_QUEUES) do
			tinsert(PREVIOUS_BATTLEFIELD_QUEUES, value);
		end
		CURRENT_BATTLEFIELD_QUEUES = {};
	end
	
	local maxBattlefieldID = GetMaxBattlefieldID and GetMaxBattlefieldID() or MAX_BATTLEFIELD_QUEUES;
	for i=1, maxBattlefieldID do
		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch, eligibleInQueue, waitingOnOtherActivity = GetBattlefieldStatus(i);
		if ( mapName ) then
			if (  instanceID ~= 0 ) then
				mapName = mapName.." "..instanceID;
			end
			if ( teamSize ~= 0 ) then
				if ( registeredMatch ) then
					mapName = ARENA_RATED_MATCH.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					mapName = ARENA_CASUAL.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				end
			end
		end
		tooltip = nil;

		if ( status ~= "none" ) then
			numberQueues = numberQueues+1;
			if ( status == "queued" ) then
				-- Update queue info show button on minimap
				waitTime = GetBattlefieldEstimatedWaitTime(i);
				timeInQueue = GetBattlefieldTimeWaited(i)/1000;
				if ( waitTime == 0 ) then
					waitTime = QUEUE_TIME_UNAVAILABLE;
				elseif ( waitTime < 60000 ) then 
					waitTime = LESS_THAN_ONE_MINUTE;
				else
					waitTime = SecondsToTime(waitTime/1000, 1);
				end
				MiniMapBattlefieldFrame.waitTime[i] = waitTime;
				if( registeredMatch and teamSize == 0 ) then
					tooltip = format(BATTLEFIELD_IN_QUEUE_RATED, mapName, waitTime, SecondsToTime(timeInQueue));
				else
					tooltip = format(BATTLEFIELD_IN_QUEUE, mapName, waitTime, SecondsToTime(timeInQueue));
				end
				
				if ( not tooltipOnly ) then
					if ( not IsAlreadyInQueue(mapName) ) then
						UIFrameFadeIn(MiniMapBattlefieldFrame, BATTLEFIELD_FRAME_FADE_TIME);
						BattlegroundShineFadeIn();
						PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
					end
					tinsert(CURRENT_BATTLEFIELD_QUEUES, mapName);
				end
				showRightClickText = 1;
			elseif ( status == "confirm" ) then
				-- Have been accepted show enter battleground dialog
				local seconds = SecondsToTime(GetBattlefieldPortExpiration(i));
				if ( seconds ~= "" ) then
					tooltip = format(BATTLEFIELD_QUEUE_CONFIRM, mapName, seconds);
				else
					tooltip = format(BATTLEFIELD_QUEUE_PENDING_REMOVAL, mapName);
				end
				if ( (i==mapIndex) and (not tooltipOnly) ) then
					-- Battlefield confirm entry popup handled by PVPHelper
					MiniMapBattlefieldFrame:Show();
				end
				showRightClickText = 1;
				if PVPTimerFrame then
					PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
					PVPTimerFrame.updating = true;
				end
			elseif ( status == "active" ) then
				-- In the battleground
				if ( teamSize ~= 0 ) then
					tooltip = mapName;
				else
					tooltip = format(BATTLEFIELD_IN_BATTLEFIELD, mapName);
				end
				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
				if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 and PVPTimerFrame and not PVPTimerFrame.updating ) then
					PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
					PVPTimerFrame.updating = true;
					BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
					PREVIOUS_BATTLEFIELD_MOD = 0;
				end
				MiniMapBattlefieldFrame.status = status;
			elseif ( status == "error" ) then
				-- Should never happen haha
			end
			if ( tooltip ) then
				if ( MiniMapBattlefieldFrame.tooltip ) then
					MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n\n"..tooltip;
				else
					MiniMapBattlefieldFrame.tooltip = tooltip;
				end
				
				if ( eligibleInQueue ~= nil and not eligibleInQueue and status ~= "active" and status ~= "confirm" ) then
					if ( waitingOnOtherActivity ) then
						MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n\n"..PVP_SUSPENDED_QUEUE_STATUS;
					else
						MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n\n"..PVP_INVALID_QUEUE_STATUS;
					end
				end
			end
		end
	end
	
	-- See if should add right click message
	if ( MiniMapBattlefieldFrame.tooltip and showRightClickText ) then
		MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n"..RIGHT_CLICK_MESSAGE;
	end
	
	if ( not tooltipOnly ) then
		local separateButtons = MiniMap_BattleGroundQueueSeparateButton();
		
		if separateButtons then
			-- Separate buttons mode: Show battlefield frame when there are queues
			if ( numberQueues == 0 ) then
				-- Clear everything out
				MiniMapBattlefieldFrame:Hide();
			else
				MiniMapBattlefieldFrame:Show();
			end

			-- Set minimap icon here since it bugs out on login (Classic specific)
			if ( UnitFactionGroup("player") ) then
				MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
			end
			
			MiniMapBattlefieldFrame_UpdateArena();
		else
			-- Combined button mode: Always hide battlefield frame, LFG frame shows for all queues
			MiniMapBattlefieldFrame:Hide();
		end
	end
	
	if PVPFrame then
		PVPFrame.numQueues = numberQueues;
	end
end

function MiniMapBattlefieldFrame_UpdateArena()
	-- Set minimap icon here since it bugs out on login
	local _, _, _, _, _, _, isRankedArena  = GetBattlefieldStatus(1);
	if (isRankedArena) then
		MiniMapBattlefieldIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
		MiniMapBattlefieldIcon:SetWidth(19);
		MiniMapBattlefieldIcon:SetHeight(19);
		MiniMapBattlefieldIcon:SetPoint("CENTER", "MiniMapBattlefieldFrame", "CENTER", -1, 2);
	elseif ( UnitFactionGroup("player") ) then
		MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
		MiniMapBattlefieldIcon:SetTexCoord(0, 1, 0, 1);
		MiniMapBattlefieldIcon:SetWidth(32);
		MiniMapBattlefieldIcon:SetHeight(32);
		MiniMapBattlefieldIcon:SetPoint("CENTER", "MiniMapBattlefieldFrame", "CENTER", -1, 0);
	end
end

-- ============================================ INSTANCE DIFFICULTY ===============================================================================
function MiniMapInstanceDifficulty_OnEvent(self, event, ...)
	if not MiniMap_ShouldShowDifficulty() then
		return;
	end

	if ( event == "GUILD_PARTY_STATE_UPDATED" ) then
		local isGuildGroup = ...;
		if not MiniMap_ShouldShowGuildDifficulty() then
			isGuildGroup = false;
		end
		if ( isGuildGroup ~= IS_GUILD_GROUP ) then
			IS_GUILD_GROUP = isGuildGroup;
			MiniMapInstanceDifficulty_Update();
		end
	elseif ( event == "PLAYER_DIFFICULTY_CHANGED" ) then
		MiniMapInstanceDifficulty_Update();
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		RequestGuildPartyState();
		MiniMapInstanceDifficulty_Update();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		local tabard = GuildInstanceDifficulty;
		SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background, tabard.border);
		if ( IsInGuild() ) then
			RequestGuildPartyState();
		else
			IS_GUILD_GROUP = false;
			MiniMapInstanceDifficulty_Update();
		end
	else
		RequestGuildPartyState();
	end
end

function MiniMapInstanceDifficulty_Update()
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize = GetInstanceInfo();
	local _, _, isHeroic, isChallengeMode = GetDifficultyInfo(difficulty);

	if ( IS_GUILD_GROUP ) then
		if ( instanceGroupSize == 0 ) then
			GuildInstanceDifficultyText:SetText("");
			GuildInstanceDifficultyDarkBackground:SetAlpha(0);
			GuildInstanceDifficulty.emblem:SetPoint("TOPLEFT", 12, -16);
		else
			GuildInstanceDifficultyText:SetText(instanceGroupSize);
			GuildInstanceDifficultyDarkBackground:SetAlpha(0.7);
			GuildInstanceDifficulty.emblem:SetPoint("TOPLEFT", 12, -10);
		end
		GuildInstanceDifficultyText:ClearAllPoints();
		if ( isHeroic or isChallengeMode ) then
			local symbolTexture;
			if ( isChallengeMode ) then
				symbolTexture = GuildInstanceDifficultyChallengeModeTexture;
				GuildInstanceDifficultyHeroicTexture:Hide();
			else
				symbolTexture = GuildInstanceDifficultyHeroicTexture;
				GuildInstanceDifficultyChallengeModeTexture:Hide();
			end
			-- the 1 looks a little off when text is centered
			if ( instanceGroupSize < 10 ) then
				symbolTexture:SetPoint("BOTTOMLEFT", 11, 7);
				GuildInstanceDifficultyText:SetPoint("BOTTOMLEFT", 23, 8);
			elseif ( instanceGroupSize > 19 ) then
				symbolTexture:SetPoint("BOTTOMLEFT", 8, 7);
				GuildInstanceDifficultyText:SetPoint("BOTTOMLEFT", 20, 8);
			else
				symbolTexture:SetPoint("BOTTOMLEFT", 8, 7);
				GuildInstanceDifficultyText:SetPoint("BOTTOMLEFT", 19, 8);
			end
			symbolTexture:Show();
		else
			GuildInstanceDifficultyHeroicTexture:Hide();
			GuildInstanceDifficultyChallengeModeTexture:Hide();
			GuildInstanceDifficultyText:SetPoint("BOTTOM", 2, 8);
		end
		MiniMapInstanceDifficulty:Hide();
		SetSmallGuildTabardTextures("player", GuildInstanceDifficulty.emblem, GuildInstanceDifficulty.background, GuildInstanceDifficulty.border);
		GuildInstanceDifficulty:Show();
		MiniMapChallengeMode:Hide();
	elseif ( isChallengeMode ) then
		MiniMapChallengeMode:Show();
		MiniMapInstanceDifficulty:Hide();
		GuildInstanceDifficulty:Hide();
	elseif ( instanceType == "raid" or isHeroic ) then
		MiniMapInstanceDifficultyText:SetText(instanceGroupSize);
		-- the 1 looks a little off when text is centered
		local xOffset = 0;
		if ( instanceGroupSize >= 10 and instanceGroupSize <= 19 ) then
			xOffset = -1;
		end
		if ( isHeroic ) then
			MiniMapInstanceDifficultyTexture:SetTexCoord(0, 0.25, 0.0703125, 0.4140625);
			MiniMapInstanceDifficultyText:SetPoint("CENTER", xOffset, -9);
		else
			MiniMapInstanceDifficultyTexture:SetTexCoord(0, 0.25, 0.5703125, 0.9140625);
			MiniMapInstanceDifficultyText:SetPoint("CENTER", xOffset, 5);
		end
		MiniMapInstanceDifficulty:Show();
		GuildInstanceDifficulty:Hide();
		MiniMapChallengeMode:Hide();
	else
		MiniMapInstanceDifficulty:Hide();
		GuildInstanceDifficulty:Hide();
		MiniMapChallengeMode:Hide();
	end
end

function GuildInstanceDifficulty_OnEnter(self)
	local guildName = GetGuildInfo("player") or "";
	local _, instanceType, _, _, maxPlayers = GetInstanceInfo();
	local _, numGuildPresent, numGuildRequired, xpMultiplier = InGuildParty();
	-- hack alert
	if ( instanceType == "arena" ) then
		maxPlayers = numGuildRequired;
	end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
	GameTooltip:SetText(GUILD_GROUP, 1, 1, 1);
	if ( xpMultiplier < 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP, numGuildRequired, maxPlayers, guildName, xpMultiplier * 100), nil, nil, nil, 1);
	elseif ( xpMultiplier > 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP, guildName, xpMultiplier * 100), nil, nil, nil, 1);
	else
		if ( instanceType == "party" and maxPlayers == 5 ) then
			numGuildRequired = 4;
		end
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE, numGuildRequired, maxPlayers, guildName), nil, nil, nil, 1);
	end
	GameTooltip:Show();
end
