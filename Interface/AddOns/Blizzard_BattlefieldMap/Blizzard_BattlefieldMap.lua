
BATTLEFIELD_TAB_SHOW_DELAY = 0.2;
BATTLEFIELD_TAB_FADE_TIME = 0.15;
BATTLEFIELD_TAB_DEFAULT_ALPHA = 0.75;
BATTLEFIELD_MAP_PARTY_MEMBER_SIZE = 8;
BATTLEFIELD_MAP_RAID_MEMBER_SIZE = 8;
BATTLEFIELD_MAP_PLAYER_SIZE = 12;
BATTLEFIELD_MAP_POI_SCALE = 0.6;
BATTLEFIELD_MAP_WIDTH = 305;  -- +5 pixels for border

local defaultOptions = {
	opacity = 0.7,
	locked = true,
	showPlayers = true,
};

BattlefieldMapTabMixin = {};

function BattlefieldMapTabMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("PLAYER_LOGOUT");
	self:SetAlpha(0);
end

function BattlefieldMapTabMixin:OnEvent(event)
	if event == "PLAYER_LOGOUT" then
		if self:IsUserPlaced() then
			if not BattlefieldMapOptions.position then
				BattlefieldMapOptions.position = {};
			end
			BattlefieldMapOptions.position.x, BattlefieldMapOptions.position.y = self:GetCenter();
			self:SetUserPlaced(false);
		else
			BattlefieldMapOptions.position = nil;
		end
	end
end

function BattlefieldMapTabMixin:OnShow()
	PanelTemplates_TabResize(self, 0);
end

function BattlefieldMapTabMixin:OnClick(button)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);

	-- If Rightclick bring up the options menu
	if button == "RightButton" then
		local function InitializeOptionsDropDown(self)
			self:GetParent():InitializeOptionsDropDown();
		end
		UIDropDownMenu_Initialize(self.OptionsDropDown, InitializeOptionsDropDown, "MENU");
		ToggleDropDownMenu(1, nil, self.OptionsDropDown, self, 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is not locked then allow the frame to be dragged or dropped
	if self:GetButtonState() == "PUSHED" then
		self:StopMovingOrSizing();
	else
		-- If locked don't allow any movement
		if BattlefieldMapOptions.locked then
			return;
		else
			self:StartMoving();
		end
	end
	ValidateFramePosition(self);
end

function BattlefieldMapTabMixin:OnDragStart()
	if not BattlefieldMapOptions.locked then
		BattlefieldMapFrame:StartMoving();
	end
end

function BattlefieldMapTabMixin:OnDragStop()
	BattlefieldMapFrame:StopMovingOrSizing();
	ValidateFramePosition(self);
end

function BattlefieldMapTabMixin:InitializeOptionsDropDown()
	local checked;
	local info = UIDropDownMenu_CreateInfo();

	-- Show battlefield players
	info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
	info.func = function()
		BattlefieldMapOptions.showPlayers = not BattlefieldMapOptions.showPlayers;
		BattlefieldMapFrame:UpdateUnitsVisibility();
	end;
	info.checked = BattlefieldMapOptions.showPlayers;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	-- Battlefield minimap lock
	info.text = LOCK_BATTLEFIELDMINIMAP;
	info.func = function()
		BattlefieldMapOptions.locked = not BattlefieldMapOptions.locked;
	end;
	info.checked = BattlefieldMapOptions.locked;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	-- Opacity
	info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
	info.func = function()
		self:ShowOpacity();
	end;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function BattlefieldMapTabMixin:ShowOpacity()
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPRIGHT", BattlefieldMapFrame, "TOPLEFT", 0, 7);
	OpacityFrame.opacityFunc = function()
		local opacity = OpacityFrameSlider:GetValue();
		BattlefieldMapOptions.opacity = opacity;
		BattlefieldMapFrame:RefreshAlpha();
	end;
	OpacityFrame:Show();
	OpacityFrameSlider:SetValue(BattlefieldMapOptions.opacity);
end

BattlefieldMapMixin = {};

function BattlefieldMapMixin:Toggle()
	if self:IsShown() then
		SetCVar("showBattlefieldMinimap", "0");
		self:Hide();
	else
		SetCVar("showBattlefieldMinimap", "1");
		self:Show();
	end
end

function BattlefieldMapMixin:OnLoad()
	MapCanvasMixin.OnLoad(self);

	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:SetShouldNavigateOnClick(false);
	self:SetShouldZoomInstantly(true);
	self:SetGlobalPinScale(BATTLEFIELD_MAP_POI_SCALE);

	self:AddStandardDataProviders();

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("NEW_WMO_CHUNK");
end

function BattlefieldMapMixin:OnShow()
	local mapID = MapUtil.GetDisplayableMapForPlayer();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
	BattlefieldMapTab:Show();
end

function BattlefieldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
	BattlefieldMapTab:Hide();
	CloseDropDownMenus();
end

function BattlefieldMapMixin:OnEvent(event, ...)
	MapCanvasMixin.OnEvent(self, event, ...);

	if event == "ADDON_LOADED" then
		local addonName = ...;
		if addonName == "Blizzard_BattlefieldMap" then
			if not BattlefieldMapOptions then
				BattlefieldMapOptions = defaultOptions;
			end

			BattlefieldMapTab:ClearAllPoints();
			if ( BattlefieldMapOptions.position ) then
				BattlefieldMapTab:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", BattlefieldMapOptions.position.x, BattlefieldMapOptions.position.y);
				BattlefieldMapTab:SetUserPlaced(true);
			else
				UIParent_ManageFramePositions();
			end
			self:RefreshAlpha();
			self:UpdateUnitsVisibility();
			self:UnregisterEvent("ADDON_LOADED");
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "NEW_WMO_CHUNK" then
		if GetCVar("showBattlefieldMinimap") == "1" then
			local mapID = MapUtil.GetDisplayableMapForPlayer();
			self:SetMapID(mapID);
			self:Show();
		end
	end
end

function BattlefieldMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(MapExplorationDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BattlefieldFlagDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VehicleDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(EncounterJournalDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FogOfWarDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DeathMapDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VignetteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GossipDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightPointDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(PetTamerDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DigSiteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DungeonEntranceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapLinkDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(SelectableGraveyardDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(AreaPOIDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestSessionDataProviderMixin));

	self.groupMembersDataProvider = CreateFromMixins(GroupMembersDataProviderMixin);
	self.groupMembersDataProvider:SetUnitPinSize("player", BATTLEFIELD_MAP_PLAYER_SIZE);
	self.groupMembersDataProvider:SetUnitPinSize("party", BATTLEFIELD_MAP_PARTY_MEMBER_SIZE);
	self.groupMembersDataProvider:SetUnitPinSize("raid", BATTLEFIELD_MAP_RAID_MEMBER_SIZE);
	self:AddDataProvider(self.groupMembersDataProvider);

	if IsGMClient() then
		self:AddDataProvider(CreateFromMixins(WorldMap_DebugDataProviderMixin));
	end

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DIG_SITE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PET_TAMER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GOSSIP");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_LINK");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
end

function BattlefieldMapMixin:RefreshAlpha()
	local alpha = 1.0 - BattlefieldMapOptions.opacity;
	self:SetGlobalAlpha(alpha);
	self.BorderFrame:SetAlpha(alpha);
end

function BattlefieldMapMixin:UpdateUnitsVisibility()
	if BattlefieldMapOptions.showPlayers then
		self.groupMembersDataProvider:SetUnitPinSize("party", BATTLEFIELD_MAP_PARTY_MEMBER_SIZE);
		self.groupMembersDataProvider:SetUnitPinSize("raid", BATTLEFIELD_MAP_RAID_MEMBER_SIZE);
		if not self.vehicleDataProvider then
			self.vehicleDataProvider = CreateFromMixins(VehicleDataProviderMixin);
			self:AddDataProvider(self.vehicleDataProvider);
		end
	else
		self.groupMembersDataProvider:SetUnitPinSize("party", 0);
		self.groupMembersDataProvider:SetUnitPinSize("raid", 0);
		if self.vehicleDataProvider then
			self:RemoveDataProvider(self.vehicleDataProvider);
			self.vehicleDataProvider = nil;
		end
	end
end

function BattlefieldMapMixin:OnUpdate(elapsed)
	MapCanvasMixin.OnUpdate(self, elapsed);

	-- tick mouse hover time for tab
	if ( self.hover ) then
		local xPos, yPos = GetCursorPosition();
		if ( (self.oldX == xPos and self.oldy == yPos) ) then
			self.hoverTime = self.hoverTime + elapsed;
		else
			self.hoverTime = 0;
			self.oldX = xPos;
			self.oldy = yPos;
		end
	end

	-- Fadein tab if mouse is over
	if ( self:IsMouseOver(45, -10, -5, 5) ) then
		-- If mouse is hovering don't show the tab until the elapsed time reaches the tab show delay
		if ( self.hover ) then
			if ( self.hoverTime > BATTLEFIELD_TAB_SHOW_DELAY ) then
				-- If the battlefieldtab's alpha is less than the current default, then fade it in
				if ( not self.hasBeenFaded and (self.oldAlpha and self.oldAlpha < BATTLEFIELD_TAB_DEFAULT_ALPHA) ) then
					UIFrameFadeIn(BattlefieldMapTab, BATTLEFIELD_TAB_FADE_TIME, self.oldAlpha, BATTLEFIELD_TAB_DEFAULT_ALPHA);
					-- Set the fact that the chatFrame has been faded so we don't try to fade it again
					self.hasBeenFaded = 1;
				end
			end
		else
			-- Start hovering counter
			self.hover = 1;
			self.hoverTime = 0;
			self.hasBeenFaded = nil;
			CURSOR_OLD_X, CURSOR_OLD_Y = GetCursorPosition();
			-- Remember the oldAlpha so we can return to it later
			if ( not self.oldAlpha ) then
				self.oldAlpha = BattlefieldMapTab:GetAlpha();
			end
		end
	else
		-- If the tab's alpha was less than the current default, then fade it back out to the oldAlpha
		if ( self.hasBeenFaded and self.oldAlpha and self.oldAlpha < BATTLEFIELD_TAB_DEFAULT_ALPHA ) then
			UIFrameFadeOut(BattlefieldMapTab, BATTLEFIELD_TAB_FADE_TIME, BATTLEFIELD_TAB_DEFAULT_ALPHA, self.oldAlpha);
			self.hover = nil;
			self.hasBeenFaded = nil;
		end
		self.hoverTime = 0;
	end
end