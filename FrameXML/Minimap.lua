MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;
MINIMAP_BOTTOM_EDGE_EXTENT = 192;	-- pixels from the top of the screen to the bottom edge of the minimap, needed for UIParentManageFramePositions

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;
HUNTER_TRACKING = 1;
TOWNSFOLK = 2;

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

	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
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

function EyeTemplate_OnUpdate(self, elapsed)
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	AnimateTexCoords(self.texture, textureInfo.width, textureInfo.height, textureInfo.iconSize, textureInfo.iconSize, textureInfo.frames, elapsed, textureInfo.delay)
end

function EyeTemplate_StartAnimating(eye)
	eye:SetScript("OnUpdate", EyeTemplate_OnUpdate);
end

function EyeTemplate_StopAnimating(eye)
	eye:SetScript("OnUpdate", nil);
	if ( eye.texture.frame ) then
		eye.texture.frame = 1;	--To start the animation over.
	end
	local textureInfo = LFG_EYE_TEXTURES[eye.queueType or "default"];
	eye.texture:SetTexCoord(0, textureInfo.iconSize / textureInfo.width, 0, textureInfo.iconSize / textureInfo.height);
end

function MinimapButton_OnMouseDown(self, button)
	if ( self.isDown ) then
		return;
	end
	local button = _G[self:GetName().."Icon"];
	local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint();
	button:SetPoint(point, relativeTo, relativePoint, offsetX+1, offsetY-1);
	self.isDown = 1;
end
function MinimapButton_OnMouseUp(self)
	if ( not self.isDown ) then
		return;
	end
	local button = _G[self:GetName().."Icon"];
	local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint();
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
	local count = GetNumTrackingTypes();
	for id = 1, count do
		local texture, active, category  = select(2, GetTrackingInfo(id));
		if active then
			if (category == "spell") then 
				if (currentTexture == texture) then
					return;
				end
				MiniMapTrackingIcon:SetTexture(texture);
				MiniMapTrackingShineFadeIn();
				return;
			else
				bestTexture = texture;
			end
		end
	end
	MiniMapTrackingIcon:SetTexture(bestTexture);
	MiniMapTrackingShineFadeIn();
end

function MiniMapTrackingDropDown_OnLoad(self)
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	UIDropDownMenu_Initialize(MiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU");
end

function MiniMapTrackingDropDown_OnEvent(self, event, ...)
	if ( event == "MINIMAP_UPDATE_TRACKING" ) then
		UIDropDownMenu_RefreshAll(MiniMapTrackingDropDown);
	end
end

function MiniMapTracking_SetTracking(self, id, unused, on)
	SetTracking(id, on);
	HideDropDownMenu(2);
end

function MiniMapTrackingDropDownButton_IsActive(button)
	local name, texture, active, category = GetTrackingInfo(button.arg1);
	return active;
end

function MiniMapTrackingDropDown_IsNoTrackingActive()
	local name, texture, active, category;
	local count = GetNumTrackingTypes();
	for id = 1, count do
		name, texture, active, category  = GetTrackingInfo(id);
		if (active) then
			return false;
		end
	end
	return true;
end

function MiniMapTrackingDropDown_Initialize(self, level)
	local name, texture, active, category, nested, numTracking;
	local count = GetNumTrackingTypes();
	local _, class = UnitClass("player");

	if (level == 1) then
		numTracking = 0; -- make sure there are at least two options in dropdown
		for id = 1, count do
			name, texture, active, category, nested = GetTrackingInfo(id);
			if (category == "spell") then
				numTracking = numTracking + 1;
			end
		end
			
		if (numTracking > 1) then
			info.text = TRACKING;
			info.func =  nil;
			info.notCheckable = true;
			info.keepShownOnClick = false;
			info.hasArrow = true;
			info.icon = nil;
			info.value = HUNTER_TRACKING;
			UIDropDownMenu_AddButton(info, level)
		end
	end

	for id = 1, count do
		name, texture, active, category, nested = GetTrackingInfo(id);
		info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.checked = MiniMapTrackingDropDownButton_IsActive;
		info.func = MiniMapTracking_SetTracking;
		info.classicChecks = true;
		info.icon = texture;
		info.arg1 = id;
		info.keepShownOnClick = true;
		if ( category == "spell" ) then
			info.tCoordLeft = 0.0625;
			info.tCoordRight = 0.9;
			info.tCoordTop = 0.0625;
			info.tCoordBottom = 0.9;
		else
			info.tCoordLeft = 0;
			info.tCoordRight = 1;
			info.tCoordTop = 0;
			info.tCoordBottom = 1;
		end

		if ((level == 1 and category ~= "spell") or 
			(numTracking == 1 and category == "spell")) then -- this is a tracking ability, but you only have one
			UIDropDownMenu_AddButton(info, level);
		elseif (level == 2 and category == "spell") then
			UIDropDownMenu_AddButton(info, level);
		end
	end
	
	if (level == 1) then -- the NONE button
		info = UIDropDownMenu_CreateInfo();
		info.text = MINIMAP_TRACKING_NONE;
		info.checked = MiniMapTrackingDropDown_IsNoTrackingActive;
		info.func = ClearAllTracking;
		info.classicChecks = true;
		info.icon = nil;
		info.arg1 = nil;
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		UIDropDownMenu_AddButton(info, level);
	end
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
local wrappedFuncs = {};
local function wrapFunc(func) --Lets us directly set .func = on dropdown entries.
	if ( not wrappedFuncs[func] ) then
		wrappedFuncs[func] = function(button, ...) func(...) end;
	end
	return wrappedFuncs[func];
end


function MiniMapBattlefieldDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MiniMapBattlefieldDropDown_Initialize, "MENU");
end

function MiniMapBattlefieldDropDown_Initialize()
	local info;
	local numShown = 0;
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, isRankedArena, _, _, _, _, _, asGroup = GetBattlefieldStatus(i);
		-- Inserts a spacer if it's not the first option... to make it look nice.
		if ( status ~= "none" ) then
			numShown = numShown + 1;
			if ( numShown > 1 ) then
				info = UIDropDownMenu_CreateInfo();
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		end

		if ( status == "queued" or status == "confirm" ) then
			-- Add a spacer if there were dropdown items before this

			info = UIDropDownMenu_CreateInfo();
			if ( teamSize ~= 0 ) then
				if ( isRankedArena ) then
					info.text = ARENA_RATED_MATCH.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					info.text = ARENA_CASUAL.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				end
			else
				info.text = mapName;
			end
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);		

			if ( status == "queued" ) then
				-- FIXME: r855580
				--if ( teamSize == 0 ) then
				--	info = UIDropDownMenu_CreateInfo();
				--	info.text = CHANGE_INSTANCE;
				--	info.func = wrapFunc(ShowBattlefieldList);
				--	info.arg1 = i;
				--	info.notCheckable = 1;
				--	UIDropDownMenu_AddButton(info);
				--end

				info = UIDropDownMenu_CreateInfo();
				info.text = LEAVE_QUEUE;
				info.func = wrapFunc(AcceptBattlefieldPort);
				info.arg1 = i;
				info.arg2 = nil;
				info.disabled = asGroup and not UnitIsGroupLeader("player");
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			elseif ( status == "confirm" ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = ENTER_BATTLE;
				info.func = wrapFunc(AcceptBattlefieldPort);
				info.arg1 = i;
				info.arg2 = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);

				if ( teamSize == 0 ) then
					info = UIDropDownMenu_CreateInfo();
					info.text = LEAVE_QUEUE;
					info.func = wrapFunc(AcceptBattlefieldPort);
					info.arg1 = i;
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				end
			end
		elseif ( status == "active" ) then
				info = UIDropDownMenu_CreateInfo();
				if ( teamSize ~= 0 ) then
					info.text = mapName.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					info.text = mapName;
				end
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);

				info = UIDropDownMenu_CreateInfo();
				if ( IsActiveBattlefieldArena() ) then
					info.text = LEAVE_ARENA;
				else
					info.text = LEAVE_BATTLEGROUND;				
				end
				info.func = LeaveBattlefield;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end		
	end
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

		if ( not tooltipOnly and (status ~= "confirm") ) then
			StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY", i);
		end

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

					if (bgtype == "WARGAME") then
						local dialog = StaticPopup_Show("CONFIRM_WARGAME_ENTRY", mapName, nil, i);
					else
						local dialog = StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
					end

					if ( dialog ) then
						dialog.data = i;
					end
					PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE);
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