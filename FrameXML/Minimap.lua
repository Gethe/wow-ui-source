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

function Minimap_OnLoad(self)
	self.fadeOut = nil;
	Minimap:SetPlayerTextureHeight(40);
	Minimap:SetPlayerTextureWidth(40);
	self:RegisterEvent("MINIMAP_PING");
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("FOCUS_TARGET_CHANGED");
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

function Minimap_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" or event == "FOCUS_TARGET_CHANGED" ) then
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
		PlaySound("MapPing");
	end
end

function MiniMapBattlefieldFrame_OnUpdate (self, elapsed)
	if ( GameTooltip:IsOwned(self) ) then
		PVP_UpdateStatus(1);
		if ( self.tooltip ) then
			GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1);
		end
	end
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

function EyeTemplate_OnUpdate(self, elapsed)
	local textureInfo = LFG_EYE_TEXTURES[self.queueType];
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
	local textureInfo = LFG_EYE_TEXTURES[eye.queueType];
	eye.texture:SetTexCoord(0, textureInfo.iconSize / textureInfo.width, 0, textureInfo.iconSize / textureInfo.height);
end

function MiniMapLFG_Update()
	local mode, submode = GetLFGMode();
	if ( mode ) then
		local queueType;
		if ( mode == "queued" and not GetLFGQueueStats() ) then
			queueType = "unknown";
		else
			queueType = GetLFGModeType();
		end
		if ( queueType ~= MiniMapLFGFrame.eye.queueType ) then
			local eye = MiniMapLFGFrame.eye;
			if ( eye.queueType ) then
				eye.texture.frame = nil;			-- to clear saved animation settings
				EyeTemplate_StopAnimating(eye);
			end
			eye.texture:SetTexture(LFG_EYE_TEXTURES[queueType].file);
			eye.queueType = queueType;
			EyeTemplate_StopAnimating(eye);			-- to set icon to the first frame
			local frameLevel = MiniMapLFGFrame:GetFrameLevel();
			if ( eye:GetFrameLevel() >= frameLevel ) then
				eye:SetFrameLevel(frameLevel - 1);
			end
		end
		MiniMapLFGFrame:Show();
		if ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "suspended" ) then
			EyeTemplate_StartAnimating(MiniMapLFGFrame.eye);
		else
			EyeTemplate_StopAnimating(MiniMapLFGFrame.eye);
		end

		if ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(GetPartyLFGID());
			local numPlayers = max(GetNumPartyMembers() + 1, GetNumRaidMembers());
			if ( numPlayers < maxPlayers ) then
				MiniMapLFGFrame.groupSize:Show();
				MiniMapLFGFrame.groupSize:SetText(numPlayers);
			else
				MiniMapLFGFrame.groupSize:Hide();
			end
		else
			MiniMapLFGFrame.groupSize:Hide();
		end

	else
		MiniMapLFGFrame:Hide();
	end
end

function MiniMapLFGFrame_TeleportIn()
	LFGTeleport(false);
end

function MiniMapLFGFrame_TeleportOut()
	LFGTeleport(true);
end

function MiniMapLFGFrameDropDown_Update()
	local info = UIDropDownMenu_CreateInfo();
	
	local mode, submode = GetLFGMode();

	--This one can appear in addition to others, so we won't just check the mode.
	if ( IsPartyLFG() ) then
		local addButton = false;
		if ( IsInLFGDungeon() ) then
			info.text = TELEPORT_OUT_OF_DUNGEON;
			info.func = MiniMapLFGFrame_TeleportOut;
			addButton = true;
		elseif ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
			info.text = TELEPORT_TO_DUNGEON;
			info.func = MiniMapLFGFrame_TeleportIn;
			addButton = true;
		end
		if ( addButton ) then
			UIDropDownMenu_AddButton(info);
		end
	end
	
	if ( mode == "proposal" and submode == "unaccepted" ) then
		info.text = ENTER_DUNGEON;
		info.func = AcceptProposal;
		UIDropDownMenu_AddButton(info);
		
		info.text = LEAVE_QUEUE;
		info.func = RejectProposal;
		UIDropDownMenu_AddButton(info);
	elseif ( mode == "queued" or mode == "suspended" ) then
		info.text = LEAVE_QUEUE;
		info.func = LeaveLFG;
		info.disabled = (submode == "unempowered");
		UIDropDownMenu_AddButton(info);
	elseif ( mode == "listed" ) then
		if ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
			info.text = UNLIST_MY_GROUP;
		else
			info.text = UNLIST_ME;
		end
		info.func = LeaveLFG;
		info.disabled = (submode == "unempowered");
		UIDropDownMenu_AddButton(info);
	end
end

function MiniMapLFGFrame_OnClick(self, button)
	local mode, submode = GetLFGMode();
	if ( button == "RightButton" or mode == "lfgparty" or mode == "abandonedInDungeon") then
		--Display dropdown
		PlaySound("igMainMenuOpen");
		--Weird hack so that the popup isn't under the queued status window (bug 184001)
		local yOffset;
		if ( mode == "queued" ) then
			MiniMapLFGFrameDropDown.point = "BOTTOMRIGHT";
			MiniMapLFGFrameDropDown.relativePoint = "TOPLEFT";
			yOffset = 0;
		else
			MiniMapLFGFrameDropDown.point = nil;
			MiniMapLFGFrameDropDown.relativePoint = nil;
			yOffset = -5;
		end
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, "MiniMapLFGFrame", 0, yOffset);
	elseif ( mode == "proposal" ) then
		if ( not LFGDungeonReadyPopup:IsShown() ) then
			PlaySound("igCharacterInfoTab");
			StaticPopupSpecial_Show(LFGDungeonReadyPopup);
		end
	elseif ( mode == "queued" or mode == "rolecheck" or mode == "suspended" ) then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount, isRaidFinder = GetLFGInfoServer();
		if ( isRaidFinder ) then
			ToggleRaidFrame(1);
		else
			ToggleLFDParentFrame();
		end
	elseif ( mode == "listed" ) then
		ToggleFriendsFrame(4);
	end
end

function MiniMapLFGFrame_OnEnter(self)
	local mode, submode = GetLFGMode();
	local queueType = GetLFGModeType();
	if ( mode == "queued" ) then
		LFGSearchStatus:Show();
	elseif ( mode == "proposal" ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( queueType == "raid" ) then
			GameTooltip:SetText(RAID_FINDER);
		else
			GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		end
		GameTooltip:AddLine(DUNGEON_GROUP_FOUND_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(CLICK_HERE_FOR_MORE_INFO, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:Show();
	elseif ( mode == "rolecheck" ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( queueType == "raid" ) then
			GameTooltip:SetText(RAID_FINDER);
		else
			GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		end
		GameTooltip:AddLine(ROLE_CHECK_IN_PROGRESS_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:Show();
	elseif ( mode == "listed" ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( queueType == "raid" ) then
			GameTooltip:SetText(LOOKING_FOR_RAID);
		else
			GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		end
		GameTooltip:AddLine(YOU_ARE_LISTED_IN_LFR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		GameTooltip:Show();
	elseif ( mode == "lfgparty" ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( queueType == "raid" ) then
			GameTooltip:SetText(RAID_FINDER);
		else
			GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		end
		GameTooltip:AddLine(YOU_ARE_IN_DUNGEON_GROUP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);

		local dungeonID = GetPartyLFGID();
		local numEncounters, numCompleted = GetLFGDungeonNumEncounters(dungeonID);
		if ( numCompleted > 0 ) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(ERR_LOOT_GONE);
			for i=1, numEncounters do
				local bossName, texture, isKilled = GetLFGDungeonEncounterInfo(dungeonID, i);
				if ( isKilled ) then
					GameTooltip:AddLine(bossName, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				end
			end
		end
		GameTooltip:Show();
	elseif ( mode == "suspended" ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		if ( queueType == "raid" ) then
			GameTooltip:SetText(RAID_FINDER);
		else
			GameTooltip:SetText(LOOKING_FOR_DUNGEON);
		end
		GameTooltip:AddLine(IN_LFG_QUEUE_BUT_SUSPENDED, nil, nil, nil, 1);
		GameTooltip:Show();
	end
end

function MiniMapLFGFrame_OnLeave(self)
	GameTooltip:Hide();
	LFGSearchStatus:Hide();
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
	UIDropDownMenu_RefreshAll(MiniMapTrackingDropDown);
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
				info.value = 1;
				UIDropDownMenu_AddButton(info, level)
			end
		end
		
		info.text = TOWNSFOLK_TRACKING_TEXT;
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;
		info.value = 2;
		UIDropDownMenu_AddButton(info, level)
	end

	for id=1, count do
		name, texture, active, category, nested  = GetTrackingInfo(id);
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
						
local selectedRaidDifficulty;
local allowedRaidDifficulty;
local IS_GUILD_GROUP;

function MiniMapInstanceDifficulty_OnEvent(self, event, ...)
	if ( event == "GUILD_PARTY_STATE_UPDATED" ) then
		local isGuildGroup = ...;
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
			IS_GUILD_GROUP = nil;
			MiniMapInstanceDifficulty_Update();
		end
	else
		RequestGuildPartyState();
	end
end

function MiniMapInstanceDifficulty_Update()
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo();
	if ( IS_GUILD_GROUP or ((instanceType == "party" or instanceType == "raid") and not (difficulty == 1 and maxPlayers == 5)) ) then
		local isHeroic = false;
		if ( instanceType == "party" and difficulty == 2 ) then
			isHeroic = true;
		elseif ( instanceType == "raid" ) then
			if ( isDynamicInstance ) then
				selectedRaidDifficulty = difficulty;
				--if ( selectedRaidDifficulty > 1 ) then
				--	isHeroic = true;
				--end
				-- if modified difficulty is normal then you are allowed to select heroic, and vice-versa
				if ( selectedRaidDifficulty == 1 ) then
					allowedRaidDifficulty = 3;
				elseif ( selectedRaidDifficulty == 2 ) then
					allowedRaidDifficulty = 4;
				elseif ( selectedRaidDifficulty == 3 ) then
					allowedRaidDifficulty = 1;
				elseif ( selectedRaidDifficulty == 4 ) then
					allowedRaidDifficulty = 2;
				end
				allowedRaidDifficulty = "RAID_DIFFICULTY"..allowedRaidDifficulty;
			end
			if ( difficulty > 2 ) then
				isHeroic = true;
			end
		end
		if ( IS_GUILD_GROUP ) then
			if ( maxPlayers == 0 ) then
				GuildInstanceDifficultyText:SetText("");
				GuildInstanceDifficultyDarkBackground:SetAlpha(0);
				GuildInstanceDifficulty.emblem:SetPoint("TOPLEFT", 12, -16);
			else
				GuildInstanceDifficultyText:SetText(maxPlayers);
				GuildInstanceDifficultyDarkBackground:SetAlpha(0.7);
				GuildInstanceDifficulty.emblem:SetPoint("TOPLEFT", 12, -10);
			end
			GuildInstanceDifficultyText:ClearAllPoints();
			if ( isHeroic ) then
				if ( maxPlayers > 10 ) then
					GuildInstanceDifficultyHeroicTexture:SetPoint("BOTTOMLEFT", 8, 7);
					GuildInstanceDifficultyText:SetPoint("BOTTOMLEFT", 20, 8);
				else
					GuildInstanceDifficultyHeroicTexture:SetPoint("BOTTOMLEFT", 11, 7);
					GuildInstanceDifficultyText:SetPoint("BOTTOMLEFT", 23, 8);
				end
				GuildInstanceDifficultyHeroicTexture:Show();
			else
				GuildInstanceDifficultyHeroicTexture:Hide();
				GuildInstanceDifficultyText:SetPoint("BOTTOM", 2, 8);
			end
			MiniMapInstanceDifficulty:Hide();
			SetSmallGuildTabardTextures("player", GuildInstanceDifficulty.emblem, GuildInstanceDifficulty.background, GuildInstanceDifficulty.border);
			GuildInstanceDifficulty:Show();
		else
			MiniMapInstanceDifficultyText:SetText(maxPlayers);
			-- the 1 looks a little off when text is centered
			local xOffset = 0;
			if ( maxPlayers >= 10 and maxPlayers <= 19 ) then
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
		end
	else
		MiniMapInstanceDifficulty:Hide();
		GuildInstanceDifficulty:Hide();
	end
end

function _GetPlayerDifficultyMenuOptions()
	return selectedRaidDifficulty, allowedRaidDifficulty;
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
