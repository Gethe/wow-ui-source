MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;
MINIMAP_BOTTOM_EDGE_EXTENT = 192;	-- pixels from the top of the screen to the bottom edge of the minimap, needed for UIParentManageFramePositions

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;
HUNTER_TRACKING = 1;

LFG_EYE_TEXTURES = { };
LFG_EYE_TEXTURES["default"] = { file = "Interface\\LFGFrame\\LFG-Eye", width = 512, height = 256, frames = 29, iconSize = 64, delay = 0.1 };
LFG_EYE_TEXTURES["raid"] = { file = "Interface\\LFGFrame\\LFR-Anim", width = 256, height = 256, frames = 16, iconSize = 64, delay = 0.05 };
LFG_EYE_TEXTURES["unknown"] = { file = "Interface\\LFGFrame\\WaitAnim", width = 128, height = 128, frames = 4, iconSize = 64, delay = 0.25 };

MAX_BATTLEFIELD_QUEUES = 3;

function Minimap_OnLoad(self)
	self.fadeOut = nil;
	self:RegisterEvent("MINIMAP_PING");
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
end

function ToggleMinimap()
	if(Minimap:IsShown()) then
		PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE);
		Minimap:Hide();
	else
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN);
		Minimap:Show();
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
	elseif ( event == "MINIMAP_PING" ) then
		local arg1, arg2, arg3 = ...;
		Minimap_SetPing(arg2, arg3, 1);
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

function Minimap_SetPing(x, y, playSound)
	if ( playSound ) then
		PlaySound(SOUNDKIT.MAP_PING);
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

function MiniMapLFGFrame_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:SetFrameLevel(self:GetFrameLevel()+1)
end

function MiniMapLFGFrame_OnClick(self, button)
	if ( button == "RightButton" ) then
		MenuUtil.CreateContextMenu(MiniMapLFGFrame, function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_MINIMAP_LFG");

			local unlistButton = rootDescription:CreateButton(LFG_LIST_UNLIST, function()
				C_LFGList.RemoveListing();
			end);
			if not (C_LFGList.HasActiveEntryInfo() and LFGListUtil_IsAppEmpowered()) then
				unlistButton:SetEnabled(false);
			end
		end);
	else
		PVEFrame_ToggleFrame();
	end
end

function MiniMapLFGFrame_OnEvent(self)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		if ( C_LFGList.HasActiveEntryInfo() ) then
			self:Show();
		else
			self:Hide();
		end
	end
end

function MiniMapLFGFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if (activeEntryInfo) then
		local text = "";
		for i=1, #activeEntryInfo.activityIDs do
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityIDs[i]);
			if (activityInfo and activityInfo.fullName ~= "") then
				text = text .. activityInfo.fullName .. "\n"
			end
		end

		if (text ~= "") then
			GameTooltip:SetText(LFG_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			GameTooltip:AddLine(text);
			GameTooltip:Show();
		else
			GameTooltip:Hide();
		end
	end
end

function MiniMapLFGFrame_OnLeave(self)
	GameTooltip:Hide()
end

function EyeTemplate_OnUpdate(self, elapsed)
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	AnimateTexCoords(self.Texture, textureInfo.width, textureInfo.height, textureInfo.iconSize, textureInfo.iconSize, textureInfo.frames, elapsed, textureInfo.delay)
end

function EyeTemplate_StartAnimating(eye)
	eye:SetScript("OnUpdate", EyeTemplate_OnUpdate);
end

function EyeTemplate_StopAnimating(eye)
	eye:SetScript("OnUpdate", nil);
	if ( eye.Texture.frame ) then
		eye.Texture.frame = 1;	--To start the animation over.
	end
	local textureInfo = LFG_EYE_TEXTURES[eye.queueType or "default"];
	eye.Texture:SetTexCoord(0, textureInfo.iconSize / textureInfo.width, 0, textureInfo.iconSize / textureInfo.height);
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

function Minimap_UpdateRotationSetting()
	if ( GetCVar("rotateMinimap") == "1" ) then
		MinimapCompassTexture:Show();
		MinimapNorthTag:Hide();
	else
		MinimapCompassTexture:Hide();
		MinimapNorthTag:Show();
	end
end

function ToggleMiniMapRotation()
	local rotate = GetCVar("rotateMinimap");
	if ( rotate == "1" ) then
		rotate = "0";
	else
		rotate = "1";
	end
	SetCVar("rotateMinimap", rotate);
	Minimap_UpdateRotationSetting();
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

function MiniMapTracking_Update()
	local currentTexture = MiniMapTrackingIcon:GetTexture();
	local bestTexture = [[Interface\Minimap\Tracking\None]];
	local count = C_Minimap.GetNumTrackingTypes();
	for id = 1, count do
		local trackingInfo = C_Minimap.GetTrackingInfo(id);
		if trackingInfo and trackingInfo.active then
			if (trackingInfo.type == "spell") then
				if (currentTexture == trackingInfo.texture) then
					return;
				end
				MiniMapTrackingIcon:SetTexture(trackingInfo.texture);
				MiniMapTrackingShineFadeIn();
				return;
			else
				bestTexture = trackingInfo.texture;
			end
		end
	end
	MiniMapTrackingIcon:SetTexture(bestTexture);
	MiniMapTrackingShineFadeIn();
end

MiniMapTrackingButtonMixin = { };

function MiniMapTrackingButtonMixin:OnLoad()
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	MiniMapTracking_Update();
	MiniMapTrackingBackground:SetAlpha(0.6);
	
	local function IsSelected(trackingInfo)
		local info = C_Minimap.GetTrackingInfo(trackingInfo.index);
		return info and info.active;
	end

	local function SetSelected(trackingInfo)
		local selected = IsSelected(trackingInfo);
		C_Minimap.SetTracking(trackingInfo.index, not selected);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_MINIMAP_TRACKING");

		rootDescription:CreateButton(UNCHECK_ALL, function()
			C_Minimap.ClearAllTracking();
			return MenuResponse.Refresh;
		end);

		local hunterInfo = {};
		local regularInfo = {};
	
		for index = 1, C_Minimap.GetNumTrackingTypes() do
			local trackingInfo = C_Minimap.GetTrackingInfo(index);
			trackingInfo.index = index;

			local tbl = (trackingInfo.subType == HUNTER_TRACKING) and hunterInfo or regularInfo;
			table.insert(tbl, trackingInfo);
		end

		local function CreateCheckboxWithIcon(parentDescription, trackingInfo)
			local name = trackingInfo.name;
			trackingInfo.text = name;
	
			local texture = trackingInfo.texture;
			local desc = parentDescription:CreateCheckbox(
				name,
				IsSelected,
				SetSelected,
				trackingInfo);
	
			desc:AddInitializer(function(button, description, menu)
				local rightTexture = button:AttachTexture();
				rightTexture:SetSize(20, 20);
				rightTexture:SetPoint("RIGHT");
				rightTexture:SetTexture(texture);
		
				local fontString = button.fontString;
				fontString:SetPoint("RIGHT", rightTexture, "LEFT");
	
				if trackingInfo.type == "spell" then
					local uv0, uv1 = .0625, .9;
					rightTexture:SetTexCoord(uv0, uv1, uv0, uv1);
				end
					
				-- The size is explicitly provided because this requires a right-justified icon.
				local width, height = fontString:GetUnboundedStringWidth() + 60, 20;
				return width, height;
			end);
	
			return desc;
		end
	
		local hunterCount = #hunterInfo;
		if hunterCount > 0 then
			local hunterMenuDesc = rootDescription;
			if hunterCount > 1 then
				hunterMenuDesc = rootDescription:CreateButton(HUNTER_TRACKING_TEXT);
			end

			for index, info in ipairs(hunterInfo) do
				CreateCheckboxWithIcon(hunterMenuDesc, info);
			end
		end
	
		for index, info in ipairs(regularInfo) do
			CreateCheckboxWithIcon(rootDescription, info);
		end
	end);
end

function MiniMapTrackingButtonMixin:OnEvent(event, arg1)
	if event == "MINIMAP_UPDATE_TRACKING" then
		MiniMapTracking_Update();
	end
end

function MiniMapTrackingButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(TRACKING, 1, 1, 1);
	GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE, nil, nil, nil, true);
	GameTooltip:Show();
end

function MiniMapTrackingButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function MiniMapTrackingShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = MiniMapTrackingShineFadeOut;
	UIFrameFade(MiniMapTrackingShine, fadeInfo);
end

function MiniMapTrackingShineFadeOut()
	UIFrameFadeOut(MiniMapTrackingShine, 0.5);
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

function BattlefieldFrame_UpdateStatus(tooltipOnly)
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

	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, isRankedArena, _, _, bgtype = GetBattlefieldStatus(i);
		if ( mapName ) then
			if (  instanceID ~= 0 ) then
				mapName = mapName.." "..instanceID;
			end
			if ( teamSize ~= 0 ) then
				if ( isRankedArena ) then
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
				tooltip = format(BATTLEFIELD_IN_QUEUE, mapName, waitTime, SecondsToTime(timeInQueue));

				if ( not tooltipOnly ) then
					if ( not IsAlreadyInQueue(mapName) ) then
						PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
						UIFrameFadeIn(MiniMapBattlefieldFrame, CHAT_FRAME_FADE_TIME);
						BattlegroundShineFadeIn();
					end
					tinsert(CURRENT_BATTLEFIELD_QUEUES, mapName);
				end
				showRightClickText = 1;
			elseif ( status == "confirm" ) then
				-- Have been accepted show enter battleground dialog
				tooltip = format(BATTLEFIELD_QUEUE_CONFIRM, mapName, SecondsToTime(GetBattlefieldPortExpiration(i)));
				if ( not tooltipOnly ) then
					MiniMapBattlefieldFrame:Show();
				end
				showRightClickText = 1;
			elseif ( status == "active" ) then
				-- In the battleground
				if ( teamSize ~= 0 ) then
					tooltip = mapName;
				else
					tooltip = format(BATTLEFIELD_IN_BATTLEFIELD, mapName);
				end

				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
				BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
				PREVIOUS_BATTLEFIELD_MOD = 0;
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
			end
		end
	end
	-- See if should add right click message
	if ( MiniMapBattlefieldFrame.tooltip and showRightClickText ) then
		MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n"..RIGHT_CLICK_MESSAGE;
	end

	if ( not tooltipOnly ) then
		if ( numberQueues == 0 ) then
			-- Clear everything out
			MiniMapBattlefieldFrame:Hide();
		else
			MiniMapBattlefieldFrame:Show();
		end

		-- Set minimap icon here since it bugs out on login
		if ( UnitFactionGroup("player") ) then
			MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
		end
	end

	MiniMapBattlefieldFrame_isArena();
end

function MiniMapBattlefieldFrame_isArena()
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