MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;

function MinimapPing_OnLoad(self)
	-- self:SetFrameLevel(self:GetFrameLevel() + 1);
	self.fadeOut = nil;
	Minimap:SetPlayerTextureHeight(40);
	Minimap:SetPlayerTextureWidth(40);
	self:RegisterEvent("MINIMAP_PING");
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
end

function ToggleMinimap()
	if(Minimap:IsShown()) then
		PlaySound("igMiniMapClose");
		Minimap:Hide();
	else
		PlaySound("igMiniMapOpen");
		Minimap:Show();
	end
	UpdateUIPanelPositions();
end

function Minimap_OnShow (self)
	MinimapToggleButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up");
	MinimapToggleButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down");
	MinimapToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Disabled");
end

function Minimap_OnHide (self)
	MinimapToggleButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up");
	MinimapToggleButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down");
	MinimapToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Disabled");
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
		local zoneName = GetZoneText();
		local subzoneName = GetSubZoneText();
		if ( subzoneName == zoneName ) then
			subzoneName = "";	
		end
		GameTooltip:AddLine( zoneName, 1.0, 1.0, 1.0 );
		if ( pvpType == "sanctuary" ) then
			GameTooltip:AddLine( subzoneName, 0.41, 0.8, 0.94 );	
			GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1);
		elseif ( pvpType == "friendly" ) then
			GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 );	
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1);
		elseif ( pvpType == "hostile" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1);
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.7, 0.0 );	
			GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0);
		elseif ( pvpType == "combat" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(COMBAT_ZONE, 1.0, 0.1, 0.1);
		else
			GameTooltip:AddLine( subzoneName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );	
		end
		GameTooltip:Show();
	end
end

function MinimapPing_OnEvent(self, event, ...)
	if ( event == "MINIMAP_PING" ) then
		local arg1, arg2, arg3 = ...;
		Minimap_SetPing(arg2, arg3, 1);
		self.timer = MINIMAPPING_TIMER;
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

function MinimapPing_OnUpdate(self, elapsed)
	local timer = self.timer or 0;
	if ( timer > 0 ) then
		timer = timer - elapsed;
		if ( not self.fadeOut and timer <= MINIMAPPING_FADE_TIMER ) then
			MinimapPing_FadeOut();
		end
		local percentage = timer - floor(timer)
		MinimapPingSpinner:SetRotation(percentage * math.pi/2);
		-- We want about 7 expansions per ping to match the old animation. 
		percentage = mod(timer, MINIMAPPING_TIMER/7);
		MinimapPingExpander:SetHeight(MINIMAP_EXPANDER_MAXSIZE * (1 - percentage));
		MinimapPingExpander:SetWidth(MINIMAP_EXPANDER_MAXSIZE * (1 - percentage));

		self.timer = timer;
	end
	if ( self.fadeOut ) then
		local fadeOutTimer = self.fadeOutTimer - elapsed;

		if ( fadeOutTimer > 0 ) then
			MinimapPing:SetAlpha(fadeOutTimer/MINIMAPPING_FADE_TIMER);
		else
			MinimapPing.fadeOut = nil;
			MinimapPing:Hide();
		end
		self.fadeOutTimer = fadeOutTimer;
	end
end

function Minimap_SetPing(x, y, playSound)
	x = x * Minimap:GetWidth();
	y = y * Minimap:GetHeight();
	
	if ( sqrt(x * x + y * y) < (Minimap:GetWidth() / 2) ) then
		MinimapPing:SetPoint("CENTER", "Minimap", "CENTER", x, y);
		MinimapPing:SetAlpha(1);
		MinimapPing:Show();
		if ( playSound ) then
			PlaySound("MapPing");
		end
	else
		MinimapPing:Hide();
	end
end

function MiniMapBattlefieldFrame_OnUpdate (self, elapsed)
	if ( GameTooltip:IsOwned(self) ) then
		BattlefieldFrame_UpdateStatus(1);
		if ( self.tooltip ) then
			GameTooltip:SetText(self.tooltip);
		end
	end
end

function MinimapPing_FadeOut()
	MinimapPing.fadeOut = 1;
	MinimapPing.fadeOutTimer = MINIMAPPING_FADE_TIMER;
end

function Minimap_ZoomInClick()
	MinimapZoomOut:Enable();
	PlaySound("igMiniMapZoomIn");
	Minimap:SetZoom(Minimap:GetZoom() + 1);
	if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
		MinimapZoomIn:Disable();
	end
end

function Minimap_ZoomOutClick()
	MinimapZoomIn:Enable();
	PlaySound("igMiniMapZoomOut");
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
--[[
function MiniMapLFGFrame_GetMode()
	local proposalExists, typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers = GetLFGProposal();
	local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer();
	local roleCheckInProgress, slots, members = GetLFGRoleUpdate();
	
	if ( proposalExists and not hasResponded ) then
		return "proposal", "unaccepted";
	elseif ( proposalExists ) then
		return "proposal", "accepted";
	elseif ( queued ) then
		if ( inParty and not IsPartyLeader() ) then
			return "queued", "unempowered";
		else
			return "queued", "empowered";
		end
	elseif ( roleCheckInProgress ) then
		return "rolecheck";
	elseif ( IsPartyLFG() and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
		return "lfgparty";
	end
end

function MiniMapLFGFrameDropDown_Update()
	local info = UIDropDownMenu_CreateInfo();
	
	local mode, submode = MiniMapLFGFrame_GetMode();

	--This one can appear in addition to others, so we won't just check the mode.
	if ( IsPartyLFG() and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) ) then
		info.text = TELEPORT_TO_DUNGEON;
		info.func = LFGTeleport;
		UIDropDownMenu_AddButton(info);
	end
	
	if ( mode == "proposal" and submode == "unaccepted" ) then
		info.text = ENTER_DUNGEON;
		info.func = AcceptProposal;
		UIDropDownMenu_AddButton(info);
		
		info.text = LEAVE_QUEUE;
		info.func = RejectProposal;
		UIDropDownMenu_AddButton(info);
	elseif ( mode == "queued" ) then
		info.text = LEAVE_QUEUE;
		info.func = LeaveLFG;
		info.disabled = (submode == "unempowered");
		UIDropDownMenu_AddButton(info);
	end
end

function MiniMapLFGFrame_OnClick(self, button)
	if ( button == "RightButton" ) then
		--Display dropdown
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, "MiniMapLFGFrame", 0, -5);
	else
		local mode, submode = MiniMapLFGFrame_GetMode();
		if ( mode == "proposal" ) then
			StaticPopupSpecial_Show(LFDDungeonReadyPopup);
		else
			ToggleLFDParentFrame();
		end
	end
end

function MiniMapLFGFrame_OnEnter(self)
	local mode, submode = MiniMapLFGFrame_GetMode();
	if ( mode == "queued" ) then
		LFDSearchStatus:Show();
	elseif ( mode == "proposal" ) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		GameTooltip:AddLine(DUNGEON_GROUP_FOUND_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(CLICK_HERE_FOR_MORE_INFO, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:Show();
	elseif ( mode == "rolecheck" ) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		GameTooltip:AddLine(ROLE_CHECK_IN_PROGRESS_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:Show();
	end
end

function MiniMapLFGFrame_OnLeave(self)
	GameTooltip:Hide();
	LFDSearchStatus:Hide();
end
]]

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
	local texture = GetTrackingTexture();
	if ( MiniMapTrackingIcon:GetTexture() ~= texture ) then
		MiniMapTrackingIcon:SetTexture(texture);
		MiniMapTrackingShineFadeIn();
	end
end

function MiniMapTrackingDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MiniMapTrackingDropDown_Initialize, "MENU");
end

function MiniMapTracking_SetTracking (self, id)
	SetTracking(id);
end

function MiniMapTrackingDropDown_Initialize()
	local name, texture, active, category;
	local anyActive, checked;
	local count = GetNumTrackingTypes();
	local info;
	for id=1, count do
		name, texture, active, category  = GetTrackingInfo(id);

		info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.checked = active;
		info.func = MiniMapTracking_SetTracking;
		info.icon = texture;
		info.arg1 = id;
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
		UIDropDownMenu_AddButton(info);
		if ( active ) then
			anyActive = active;
		end
	end
	
	if ( anyActive ) then
		checked = nil;
	else
		checked = 1;
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = NONE;
	info.checked = checked;
	info.func = MiniMapTracking_SetTracking;
	info.arg1 = nil;
	UIDropDownMenu_AddButton(info);

end

function MiniMapTrackingShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = MiniMapTrackingShineFadeOut;
	UIFrameFade(MiniMapTrackingButtonShine, fadeInfo);
end

function MiniMapTrackingShineFadeOut()
	UIFrameFadeOut(MiniMapTrackingButtonShine, 0.5);
end
