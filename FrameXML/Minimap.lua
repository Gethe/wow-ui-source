MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;
MINIMAP_BOTTOM_EDGE_EXTENT = 192;	-- pixels from the top of the screen to the bottom edge of the minimap, needed for UIParentManageFramePositions

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;
HUNTER_TRACKING = 1;
TOWNSFOLK = 2;

GARRISON_ALERT_CONTEXT_BUILDING = 1;
GARRISON_ALERT_CONTEXT_MISSION = {
	[Enum.GarrisonFollowerType.FollowerType_6_0] = 2,
	[Enum.GarrisonFollowerType.FollowerType_6_2] = 4,
	[Enum.GarrisonFollowerType.FollowerType_7_0] = 5,
	[Enum.GarrisonFollowerType.FollowerType_8_0] = 6,

	-- TODO:: Replace with the correct flash.
	[Enum.GarrisonFollowerType.FollowerType_9_0] = 6,
};
GARRISON_ALERT_CONTEXT_INVASION = 3;

LFG_EYE_TEXTURES = { };
LFG_EYE_TEXTURES["default"] = { file = "Interface\\LFGFrame\\LFG-Eye", width = 512, height = 256, frames = 29, iconSize = 64, delay = 0.1 };
LFG_EYE_TEXTURES["raid"] = { file = "Interface\\LFGFrame\\LFR-Anim", width = 256, height = 256, frames = 16, iconSize = 64, delay = 0.05 };
LFG_EYE_TEXTURES["unknown"] = { file = "Interface\\LFGFrame\\WaitAnim", width = 128, height = 128, frames = 4, iconSize = 64, delay = 0.25 };

function Minimap_OnLoad(self)
	self.fadeOut = nil;
	self:RegisterEvent("MINIMAP_PING");
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
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
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 );
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1);
			end
		elseif ( pvpType == "hostile" ) then
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1);
			end
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
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if C_Minimap.ShouldUseHybridMinimap() then
			if not HybridMinimap then
				UIParentLoadAddOn("Blizzard_HybridMinimap");
			end
			HybridMinimap:Enable();
		else
			if HybridMinimap then
				HybridMinimap:Disable();
			end
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
	local senders = { GetLatestThreeSenders() };
	local headerText = #senders >= 1 and HAVE_MAIL_FROM or HAVE_MAIL;
	FormatUnreadMailTooltip(GameTooltip, headerText, senders);
	GameTooltip:Show();
end

function MiniMapTracking_Update()
	UIDropDownMenu_RefreshAll(MiniMapTrackingDropDown);
end

function MiniMapTracking_OnMouseDown(self)
	MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 8, -8);
	MiniMapTrackingIconOverlay:Show();
	MiniMapTrackingDropDown.point = "TOPRIGHT";
	MiniMapTrackingDropDown.relativePoint = "BOTTOMLEFT";
	ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 8, 5);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function MiniMapTracking_OnMouseUp(self)
	MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 6, -6);
	MiniMapTrackingIconOverlay:Hide();
end

function MiniMapTracking_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(TRACKING, 1, 1, 1);
	GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE, nil, nil, nil, true);
	GameTooltip:Show();
end

function MiniMapTracking_OnLeave(self)
	GameTooltip:Hide();
end

function MiniMapTrackingDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MiniMapTrackingDropDown_Initialize, "MENU");
	self.noResize = true;
end

function MiniMapTracking_SetTracking (self, id, unused, on)
	SetTracking(id, on);
	UIDropDownMenu_Refresh(MiniMapTrackingDropDown);
end

function MiniMapTrackingDropDownButton_IsActive(button)
	local name, texture, active, category = GetTrackingInfo(button.arg1);
	return active;
end

function MiniMapTrackingDropDown_IsNoTrackingActive()
	local name, texture, active, category;
	local count = GetNumTrackingTypes();
	for id=1, count do
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
	local info;
	local _, class = UnitClass("player");

	if (level == 1) then
		info = UIDropDownMenu_CreateInfo();
		info.text=MINIMAP_TRACKING_NONE;
		info.checked = MiniMapTrackingDropDown_IsNoTrackingActive;
		info.func = ClearAllTracking;
		info.icon = nil;
		info.arg1 = nil;
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		UIDropDownMenu_AddButton(info, level);

		if (class == "HUNTER") then --only show hunter dropdown for hunters
			numTracking = 0;
			-- make sure there are at least two options in dropdown
			for id=1, count do
				name, texture, active, category, nested = GetTrackingInfo(id);
				if (nested == HUNTER_TRACKING and category == "spell") then
					numTracking = numTracking + 1;
				end
			end
			if (numTracking > 1) then
				info.text = HUNTER_TRACKING_TEXT;
				info.func =  nil;
				info.notCheckable = true;
				info.keepShownOnClick = false;
				info.hasArrow = true;
				info.value = HUNTER_TRACKING;
				UIDropDownMenu_AddButton(info, level)
			end
		end

		info.text = TOWNSFOLK_TRACKING_TEXT;
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;
		info.value = TOWNSFOLK;
		UIDropDownMenu_AddButton(info, level)
	end

	for id=1, count do
		name, texture, active, category, nested = GetTrackingInfo(id);
		info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.checked = MiniMapTrackingDropDownButton_IsActive;
		info.func = MiniMapTracking_SetTracking;
		info.icon = texture;
		info.arg1 = id;
		info.isNotRadio = true;
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
		if (level == 1 and
			(nested < 0 or -- this tracking shouldn't be nested
			(nested == HUNTER_TRACKING and class ~= "HUNTER") or
			(numTracking == 1 and category == "spell"))) then -- this is a hunter tracking ability, but you only have one
			UIDropDownMenu_AddButton(info, level);
		elseif (level == 2 and (nested == TOWNSFOLK or (nested == HUNTER_TRACKING and class == "HUNTER")) and nested == UIDROPDOWNMENU_MENU_VALUE) then
			UIDropDownMenu_AddButton(info, level);
		end
	end

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

--
-- Dungeon Difficulty
--

local IS_GUILD_GROUP;

function MiniMapInstanceDifficulty_OnEvent(self, event, ...)
	if ( event == "GUILD_PARTY_STATE_UPDATED" ) then
		local isGuildGroup = ...;
		if ( isGuildGroup ~= IS_GUILD_GROUP ) then
			IS_GUILD_GROUP = isGuildGroup;
			MiniMapInstanceDifficulty_Update();
		end
	elseif ( event == "PLAYER_DIFFICULTY_CHANGED") then
		MiniMapInstanceDifficulty_Update();
	elseif ( event == "UPDATE_INSTANCE_INFO" or event == "INSTANCE_GROUP_SIZE_CHANGED" ) then
		RequestGuildPartyState();
		MiniMapInstanceDifficulty_Update();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		local tabard = GuildInstanceDifficulty;
		SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background, tabard.border);
		if ( IsInGuild() ) then
			RequestGuildPartyState();
		else
			IS_GUILD_GROUP = nil;
			MiniMapInstanceDifficulty_Update();
		end
	else
		RequestGuildPartyState();
	end
end

function MiniMapInstanceDifficulty_Update()
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize = GetInstanceInfo();
	local _, _, isHeroic, isChallengeMode, displayHeroic, displayMythic = GetDifficultyInfo(difficulty);

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
		if ( isHeroic or isChallengeMode or displayMythic or displayHeroic ) then
			local symbolTexture;
			if ( isChallengeMode ) then
				symbolTexture = GuildInstanceDifficultyChallengeModeTexture;
				GuildInstanceDifficultyHeroicTexture:Hide();
				GuildInstanceDifficultyMythicTexture:Hide();
			elseif ( displayMythic ) then
				symbolTexture = GuildInstanceDifficultyMythicTexture;
				GuildInstanceDifficultyHeroicTexture:Hide();
				GuildInstanceDifficultyChallengeModeTexture:Hide();
			else
				symbolTexture = GuildInstanceDifficultyHeroicTexture;
				GuildInstanceDifficultyChallengeModeTexture:Hide();
				GuildInstanceDifficultyMythicTexture:Hide();
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
			GuildInstanceDifficultyMythicTexture:Hide();
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
	elseif ( instanceType == "raid" or isHeroic or displayMythic or displayHeroic ) then
		MiniMapInstanceDifficultyText:SetText(instanceGroupSize);
		-- the 1 looks a little off when text is centered
		local xOffset = 0;
		if ( instanceGroupSize >= 10 and instanceGroupSize <= 19 ) then
			xOffset = -1;
		end
		if ( displayMythic ) then
			MiniMapInstanceDifficultyTexture:SetTexCoord(0.25, 0.5, 0.0703125, 0.4296875);
			MiniMapInstanceDifficultyText:SetPoint("CENTER", xOffset, -9);
		elseif ( isHeroic or displayHeroic ) then
			MiniMapInstanceDifficultyTexture:SetTexCoord(0, 0.25, 0.0703125, 0.4296875);
			MiniMapInstanceDifficultyText:SetPoint("CENTER", xOffset, -9);
		else
			MiniMapInstanceDifficultyTexture:SetTexCoord(0, 0.25, 0.5703125, 0.9296875);
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

function MiniMapInstanceDifficulty_OnEnter(self)
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize, lfgID = GetInstanceInfo();
	local isLFR = select(8, GetDifficultyInfo(difficulty))
	if (isLFR and lfgID) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
		local name = GetLFGDungeonInfo(lfgID);
		GameTooltip:SetText(RAID_FINDER, 1, 1, 1);
		GameTooltip:AddLine(name);
		GameTooltip:Show();
	end
end

function GuildInstanceDifficulty_OnEnter(self)
	local guildName = GetGuildInfo("player");
	local _, instanceType, _, _, maxPlayers = GetInstanceInfo();
	local _, numGuildPresent, numGuildRequired, xpMultiplier = InGuildParty();
	-- hack alert
	if ( instanceType == "arena" ) then
		maxPlayers = numGuildRequired;
	end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
	GameTooltip:SetText(GUILD_GROUP, 1, 1, 1);
	if ( xpMultiplier < 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP, numGuildRequired, maxPlayers, guildName, xpMultiplier * 100), nil, nil, nil, true);
	elseif ( xpMultiplier > 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP, guildName, xpMultiplier * 100), nil, nil, nil, true);
	else
		if ( instanceType == "party" and maxPlayers == 5 ) then
			numGuildRequired = 4;
		end
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE, numGuildRequired, maxPlayers, guildName), nil, nil, nil, true);
	end
	GameTooltip:Show();
end


function GarrisonLandingPageMinimapButton_OnLoad(self)
	self.pulseLocks = {};
	self:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
	self:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	self:RegisterEvent("GARRISON_ARCHITECT_OPENED");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:RegisterEvent("GARRISON_SHIPYARD_NPC_OPENED");
	self:RegisterEvent("GARRISON_INVASION_AVAILABLE");
	self:RegisterEvent("GARRISON_INVASION_UNAVAILABLE");
	self:RegisterEvent("SHIPMENT_UPDATE");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function GarrisonLandingPageMinimapButton_OnEvent(self, event, ...)
	if (event == "GARRISON_HIDE_LANDING_PAGE") then
		self:Hide();
	elseif (event == "GARRISON_SHOW_LANDING_PAGE") then
		GarrisonLandingPageMinimapButton_UpdateIcon(self);
		self:Show();
	elseif ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		local buildingName, garrisonType = ...;
		if ( garrisonType == C_Garrison.GetLandingPageGarrisonType() ) then
			GarrisonMinimapBuilding_ShowPulse(self);
		end
	elseif ( event == "GARRISON_BUILDING_ACTIVATED" or event == "GARRISON_ARCHITECT_OPENED") then
		GarrisonMinimap_HidePulse(self, GARRISON_ALERT_CONTEXT_BUILDING);
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		local followerType = ...;
		if ( DoesFollowerMatchCurrentGarrisonType(followerType) ) then
			GarrisonMinimapMission_ShowPulse(self, followerType);
		end
	elseif ( event == "GARRISON_MISSION_NPC_OPENED" ) then
		local followerType = ...;
		GarrisonMinimap_HidePulse(self, GARRISON_ALERT_CONTEXT_MISSION[followerType]);
	elseif ( event == "GARRISON_SHIPYARD_NPC_OPENED" ) then
		GarrisonMinimap_HidePulse(self, GARRISON_ALERT_CONTEXT_MISSION[Enum.GarrisonFollowerType.FollowerType_6_2]);
	elseif (event == "GARRISON_INVASION_AVAILABLE") then
		if ( C_Garrison.GetLandingPageGarrisonType() == Enum.GarrisonType.Type_6_0 ) then
			GarrisonMinimapInvasion_ShowPulse(self);
		end
	elseif (event == "GARRISON_INVASION_UNAVAILABLE") then
		GarrisonMinimap_HidePulse(self, GARRISON_ALERT_CONTEXT_INVASION);
	elseif (event == "SHIPMENT_UPDATE") then
		local shipmentStarted, isTroop = ...;
		if (shipmentStarted) then
			GarrisonMinimapShipmentCreated_ShowPulse(self, isTroop);
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self.isInitialLogin = ...;
		if self.isInitialLogin then
			EventRegistry:RegisterCallback("CovenantCallings.CallingsUpdated", GarrisonMinimap_OnCallingsUpdated, self);
			CovenantCalling_CheckCallings();
		end
	end
end

local function GetMinimapAtlases_GarrisonType8_0(faction)
	if faction == "Horde" then
		return "bfa-landingbutton-horde-up", "bfa-landingbutton-horde-down", "bfa-landingbutton-horde-diamondhighlight", "bfa-landingbutton-horde-diamondglow";
	else
		return "bfa-landingbutton-alliance-up", "bfa-landingbutton-alliance-down", "bfa-landingbutton-alliance-shieldhighlight", "bfa-landingbutton-alliance-shieldglow";
	end
end

local garrisonTypeAnchors = {
	["default"] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", 32, -118),
	[Enum.GarrisonType.Type_9_0] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", 32, -106),
}

local function GetGarrisonTypeAnchor(garrisonType)
	return garrisonTypeAnchors[garrisonType or "default"] or garrisonTypeAnchors["default"];
end

local function ApplyGarrisonTypeAnchor(self, garrisonType)
	local anchor = GetGarrisonTypeAnchor(garrisonType);
	local clearAllPoints = true;
	anchor:SetPoint(self, clearAllPoints);
end

local garrisonType9_0AtlasFormats = {
	"shadowlands-landingbutton-%s-up",
	"shadowlands-landingbutton-%s-down",
	"shadowlands-landingbutton-%s-highlight",
	"shadowlands-landingbutton-%s-glow",
};

local function GetMinimapAtlases_GarrisonType9_0(covenantData)
	local kit = covenantData and covenantData.textureKit or "kyrian";
	if kit then
		local t = garrisonType9_0AtlasFormats;
		return t[1]:format(kit), t[2]:format(kit), t[3]:format(kit), t[4]:format(kit);
	end
end

local function SetLandingPageIconFromAtlases(self, up, down, highlight, glow)
	local info = C_Texture.GetAtlasInfo(up);
	self:SetSize(info and info.width or 0, info and info.height or 0);
	self:GetNormalTexture():SetAtlas(up, true);
	self:GetPushedTexture():SetAtlas(down, true);
	self:GetHighlightTexture():SetAtlas(highlight, true);
	self.LoopingGlow:SetAtlas(glow, true);
end

function GarrisonLandingPageMinimapButton_UpdateIcon(self)
	local garrisonType = C_Garrison.GetLandingPageGarrisonType();
	self.garrisonType = garrisonType;

	ApplyGarrisonTypeAnchor(self, garrisonType);

	if (garrisonType == Enum.GarrisonType.Type_6_0) then
		self.faction = UnitFactionGroup("player");
		if ( self.faction == "Horde" ) then
			self:GetNormalTexture():SetAtlas("GarrLanding-MinimapIcon-Horde-Up", true);
			self:GetPushedTexture():SetAtlas("GarrLanding-MinimapIcon-Horde-Down", true);
		else
			self:GetNormalTexture():SetAtlas("GarrLanding-MinimapIcon-Alliance-Up", true);
			self:GetPushedTexture():SetAtlas("GarrLanding-MinimapIcon-Alliance-Down", true);
		end
		self.title = GARRISON_LANDING_PAGE_TITLE;
		self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_7_0) then
		local _, className = UnitClass("player");
		self:GetNormalTexture():SetAtlas("legionmission-landingbutton-"..className.."-up", true);
		self:GetPushedTexture():SetAtlas("legionmission-landingbutton-"..className.."-down", true);
		self.title = ORDER_HALL_LANDING_PAGE_TITLE;
		self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_8_0) then
		self.faction = UnitFactionGroup("player");
		SetLandingPageIconFromAtlases(self, GetMinimapAtlases_GarrisonType8_0(self.faction));
		self.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE;
		self.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_9_0) then
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
		if covenantData then
			SetLandingPageIconFromAtlases(self, GetMinimapAtlases_GarrisonType9_0(covenantData));
		end

		self.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
		self.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP;
	end
end

function GarrisonLandingPageMinimapButton_OnClick(self, button)
	GarrisonLandingPage_Toggle();
	GarrisonMinimap_HideHelpTip(self);
end

function GarrisonLandingPage_Toggle()
	if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
		HideUIPanel(GarrisonLandingPage);
	else
		ShowGarrisonLandingPage(C_Garrison.GetLandingPageGarrisonType());
	end
end

function GarrisonMinimap_SetPulseLock(self, lock, enabled)
	self.pulseLocks[lock] = enabled;
end

-- We play an animation on the garrison minimap icon for a number of reasons, but only want to turn the
-- animation off if the user handles all actions related to that alert. For example if we play the animation
-- because a building can be activated and then another because a garrison invasion has occurred,  we want to
-- turn off the animation after they handle both the building and invasion, but not if they handle only one.
-- We always stop the pulse when they click on the landing page icon.

function GarrisonMinimap_HidePulse(self, lock)
	GarrisonMinimap_SetPulseLock(self, lock, false);
	local enabled = false;
	for k, v in pairs(self.pulseLocks) do
		if ( v ) then
			enabled = true;
			break;
		end
	end

	-- If there are no other reasons to show the pulse, hide it
	if (not enabled) then
		GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Stop();
	end
end

function GarrisonMinimap_ClearPulse()
	local self = GarrisonLandingPageMinimapButton;
	for k, v in pairs(self.pulseLocks) do
		self.pulseLocks[k] = false;
	end
	self.MinimapLoopPulseAnim:Stop();
end

function GarrisonMinimapBuilding_ShowPulse(self)
	GarrisonMinimap_SetPulseLock(self, GARRISON_ALERT_CONTEXT_BUILDING, true);
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimapMission_ShowPulse(self, followerType)
	GarrisonMinimap_SetPulseLock(self, GARRISON_ALERT_CONTEXT_MISSION[followerType], true);
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimap_Justify(text)
	--Center justify if we're on more than one line
	if ( text:GetNumLines() > 1 ) then
		text:SetJustifyH("CENTER");
	else
		text:SetJustifyH("RIGHT");
	end
end

function GarrisonMinimapInvasion_ShowPulse(self)
	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_INVASION_ALERT);
	self.AlertText:SetText(GARRISON_LANDING_INVASION_ALERT);
	GarrisonMinimap_Justify(self.AlertText);
	GarrisonMinimap_SetPulseLock(self, GARRISON_ALERT_CONTEXT_INVASION, true);
	self.MinimapAlertAnim:Play();
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimapShipmentCreated_ShowPulse(self, isTroop)
    local text;
    if (isTroop) then
        text = GARRISON_LANDING_RECRUITMENT_STARTED_ALERT;
    else
        text = GARRISON_LANDING_SHIPMENT_STARTED_ALERT;
    end

	self.AlertText:SetText(text);
	GarrisonMinimap_Justify(self.AlertText);
	self.MinimapAlertAnim:Play();
end

function GarrisonMinimap_ShowCovenantCallingsNotification(self)
	self.AlertText:SetText(COVENANT_CALLINGS_AVAILABLE);
	GarrisonMinimap_Justify(self.AlertText);
	self.MinimapAlertAnim:Play();
	self.MinimapLoopPulseAnim:Play();

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS) then
		GarrisonMinimap_SetQueuedHelpTip(self, {
			text = FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 0,
			useParentStrata = true,
		});
	end
end

function GarrisonMinimap_OnCallingsUpdated(self, callings, completedCount, availableCount)
	if self.isInitialLogin then
		if availableCount > 0 then
			GarrisonMinimap_ShowCovenantCallingsNotification(self);
		end

		self.isInitialLogin = false;
	end
end

function GarrisonMinimap_SetQueuedHelpTip(self, tipInfo)
	self.queuedHelpTip = tipInfo;
end

function GarrisonMinimap_CheckQueuedHelpTip(self)
	if self.queuedHelpTip then
		local tip = self.queuedHelpTip;
		self.queuedHelpTip = nil;
		HelpTip:Show(self, tip);
	end
end

function GarrisonMinimap_ClearQueuedHelpTip(self)
	if self.queuedHelpTip and self.queuedHelpTip.text == FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS then
		self.queuedHelpTip = nil;
	end
end

function GarrisonMinimap_HideHelpTip(self)
	if self.garrisonType == Enum.GarrisonType.Type_9_0 then
		HelpTip:Acknowledge(self, FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS);
		GarrisonMinimap_ClearQueuedHelpTip(self, FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS);
	end
end