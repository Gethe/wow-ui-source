local HIGHLIGHT_ROTATION_CORRECTION = 270;
local SEGMENT_COUNT = 8;
local SEGMENT_ANGLE = 360 / SEGMENT_COUNT;
local HIGHLIGHT_DISTANCE = 150;
local ATLAS_ICON_DISTANCE = 50;
local ICON_DISTANCE = 20;
local DEFAULT_PAGE_INDEX = 2;
local MAIN_MENU_PAGE_COUNT = 3;

------------------------------------------------------------
-- BasicSegmentHandler

local BasicSegmentHandler = {};

function BasicSegmentHandler.Create(options)
	assert(type(options) == "table");
	local self = options;
	setmetatable(self, { __index = BasicSegmentHandler});
	return self;
end

function BasicSegmentHandler:Attach(segment)
	if self.segment then
		self:Detach();
	end

	self.segment = segment;
	self:UpdateIcon();
end

function BasicSegmentHandler:Detach()
	if not self.segment then
		return;
	end

	if self.Deactivate then
		self:Deactivate();
	end

	self.segment = nil;
end

function BasicSegmentHandler:IsEnabled()
	return self.action and (not self.isEnabled or self.isEnabled());
end

function BasicSegmentHandler:IsDown()
	return self.isOpen and self.isOpen();
end

function BasicSegmentHandler:Trigger()
	local ret = false;

	if self:IsEnabled() then
		ret = self:action();
		if ret == nil then
			ret = true;
		end
	else
		local msgType = type(self.disabledMsg);
		local msg = RADIAL_ERROR_FALLBACK;
		if msgType == "string" then
			msg = self.disabledMsg;
		elseif msgType == "function" then
			msg = self:disabledMsg() or msg;
		end
		UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1, 1);
	end

	self:UpdateIcon();
	return ret;
end

function BasicSegmentHandler:GetLabel()
	return self.label;
end

function BasicSegmentHandler:UpdateIcon()
	if not self.segment then
		return;
	end

	local desaturate = false;

	if self.icons then
		assert(self.icons.up ~= nil);
		if not self:IsEnabled() then
			if self.icons.disabled then
				self:SetIcon(self.icons.disabled);
			else
				self:SetIcon(self.icons.up);
				desaturate = true;
			end
		elseif self:IsDown() then
			self:SetIcon(self.icons.down or self.icons.up);
		else
			self:SetIcon(self.icons.up);
		end
	else
		self:SetIcon(self.icon);
		desaturate = not self:IsEnabled();
	end

	local fontColor = self:IsEnabled() and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR;
	self.segment.IconLabel:SetTextColor(fontColor:GetRGB());
	self.segment.SegmentIcon:SetDesaturated(desaturate);
	self.segment.SegmentDisabled:SetShown(not self:IsEnabled());	
end

function BasicSegmentHandler:SetIcon(icon)
	local kind = type(icon);
	local width, height = 38, 38;
	local scale = 1.0;

	if kind == "string" then
		self.segment.SegmentIcon:SetAtlas(icon);
		width, height = 57, 57;

		-- If the atlas failed to load for whatever reason, its width/height is zero
		local atlasInfo = C_Texture.GetAtlasInfo(icon);
		if atlasInfo.width > 0 and atlasInfo.height > 0 then
			scale = math.min(width / atlasInfo.width, height / atlasInfo.height);
			width = atlasInfo.width;
			height = atlasInfo.height;
		end
	elseif kind == "function" then
		icon(self.segment.SegmentIcon);
	else
		self.segment.SegmentIcon:SetTexture(icon or 132311);
	end

	self.segment.SegmentIcon:SetScale(scale);
	self.segment.SegmentIcon:SetSize(width, height);

	local iconX, iconY = self.segment:GetIconOffset(kind);
	self.segment.SegmentIcon:ClearAllPoints();
	self.segment.SegmentIcon:SetPoint("CENTER", iconX, iconY);

	local labelX, labelY = self.segment:GetIconLabelAnchor();
	self.segment.IconLabel:ClearAllPoints();
	self.segment.IconLabel:SetPoint("CENTER", self.segment.SegmentIcon, "CENTER", labelX, labelY);
end

------------------------------------------------------------
--- MicroMenuButtonHandler

local MicroMenuButtonHandler = {};
setmetatable(MicroMenuButtonHandler, { __index = BasicSegmentHandler });

function MicroMenuButtonHandler.Create(button, options)
	assert(type(button) == "table");
	assert(type(options) == "table");
	local self = options;
	self.button = button;
	setmetatable(self, { __index = MicroMenuButtonHandler });
	return self;
end

function MicroMenuButtonHandler:action()
	self.button:Click("LeftButton");
end

function MicroMenuButtonHandler:Attach(segment)
	BasicSegmentHandler.Attach(self, segment);

	self.button:RegisterCallback("OnEnable", self.UpdateIcon, self);
	self.button:RegisterCallback("OnDisable", self.UpdateIcon, self);
	self.button:RegisterCallback("OnBeginPulse", self.OnBeginPulse, self);
	self.button:RegisterCallback("OnEndPulse", self.OnEndPulse, self);
	self.button:RegisterCallback("OnNewNotification", self.OnNewNotification, self);
	self.button:RegisterCallback("OnDismissedNotification", self.OnDismissedNotification, self);

	if self.button:HasNotification() then
		segment.NotificationOverlay:Show();
	end

	if self.button:IsPulsing() then
		self:OnBeginPulse(self.button);
	end
end

function MicroMenuButtonHandler:Detach()
	self.button:UnregisterCallback("OnEnable", self);
	self.button:UnregisterCallback("OnDisable", self);
	self.button:UnregisterCallback("OnBeginPulse", self);
	self.button:UnregisterCallback("OnEndPulse", self);
	self.button:UnregisterCallback("OnNewNotification", self);
	self.button:UnregisterCallback("OnDismissedNotification", self);

	self.segment.NotificationOverlay:Hide();
	self:OnEndPulse(self.button);

	BasicSegmentHandler.Detach(self);
end

function MicroMenuButtonHandler:IsEnabled()
	return self.button:IsEnabled();
end

function MicroMenuButtonHandler:disabledMsg()
	local msg = self.button.disabledTooltip;
	return type(msg) == "function" and msg() or msg;
end

function MicroMenuButtonHandler:OnNewNotification(button)
	if self.segment and button == self.button then
		self.segment.NotificationOverlay:Show();
	end
end

function MicroMenuButtonHandler:OnDismissedNotification(button)
	if self.segment and button == self.button then
		self.segment.NotificationOverlay:Hide();
	end
end

function MicroMenuButtonHandler:OnBeginPulse(button, duration)
	if self.segment and button == self.button then
		UIFrameFlash(self.segment.SegmentIcon, 1, 1, duration or -1, true, 0, 0, "microbutton");
	end
end

function MicroMenuButtonHandler:OnEndPulse(button)
	if self.segment and button == self.button then
		self.segment.SegmentIcon.showWhenDone = true;
		UIFrameFlashStop(self.segment.SegmentIcon);
	end
end

------------------------------------------------------------
--- Main menu button handler

local mainMenuMicroButtonHandler = MicroMenuButtonHandler.Create(MainMenuMicroButton, {
	label = RADIAL_LABEL_GAME_MENU,
	updateTimeout = 0,

	-- Frame only used to handle tooltip ownership and the OnUpdate hook
	frame = CreateFrame("FRAME"),

	-- Note: This doesn't have an isOpen since the GameMenuFrame is closed when the radial
	-- opens, so it would reflect as being down even if it isn't supposed to be.
	icons = {
		up = "gamepad-radial-icon-gamemenu",
		down = "gamepad-radial-icon-gamemenu-down",
		disabled = "gamepad-radial-icon-gamemenu-disabled",
	},
});

function mainMenuMicroButtonHandler:action()
	GameMenuFrame_Show();
end

function mainMenuMicroButtonHandler:Attach(segment)
	MicroMenuButtonHandler.Attach(self, segment);

	self.frame:SetScript("OnUpdate", GenerateClosure(self.OnUpdate, self));
end

function mainMenuMicroButtonHandler:Detach()
	self.frame:SetScript("OnUpdate", nil);

	MicroMenuButtonHandler.Detach(self);
end

function mainMenuMicroButtonHandler:Activate()
	GameTooltip:SetOwner(self.frame, "ANCHOR_NONE");
	self.updateTimeout = 0;
	self:OnUpdate(self.frame, 0);
	GameTooltip:Show();
end

function mainMenuMicroButtonHandler:Deactivate()
	if GameTooltip:GetOwner() == self.frame then
		GameTooltip:Hide();
	end
end

function mainMenuMicroButtonHandler:OnUpdate(_, elapsed)
	self.updateTimeout = self.updateTimeout - elapsed;
	if self.updateTimeout > 0 then
		return;
	end

	self.updateTimeout = 1;

	if GameTooltip:GetOwner() == self.frame then
		self.frame.tooltipText = RADIAL_LABEL_GAME_MENU;
		MainMenuBarPerformanceBarFrame_OnEnter(self.frame);
	end

	self:UpdateIcon();
end

function mainMenuMicroButtonHandler:UpdateIcon()
	if not self.segment then
		return;
	end

	local status = GetFileStreamingStatus();
	if status == 0 then
		status = GetBackgroundLoadingStatus() ~= 0 and 1 or 0;
	end

	local atlas = "gamepad-radial-icon-gamemenu";

	if status == 0 then
		if not self:IsEnabled() then
			atlas = atlas .. "-disabled";
		elseif self:IsDown() then
			atlas = atlas .. "-down";
		end
	else
		local mapping = {
			[1] = "StreamDLGreen",
			[2] = "StreamDLYellow",
			[3] = "StreamDLRed",
		};

		atlas = "UI-HUD-MicroMenu-" .. (mapping[status] or mapping[1]);

		if not self:IsEnabled() then
			atlas = atlas .. "-Disabled";
		elseif self:IsDown() then
			atlas = atlas .. "-Mouseover";
		else
			atlas = atlas .. "-Up";
		end
	end

	self:SetIcon(atlas);
	local fontColor = self:IsEnabled() and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR;
	self.segment.IconLabel:SetTextColor(fontColor:GetRGB());
	self.segment.SegmentIcon:SetDesaturated(false);
	self.segment.SegmentDisabled:SetShown(not self:IsEnabled());	
end

------------------------------------------------------------
--- BasicContextOptionHandler

local BasicContextOptionHandler = {};

function BasicContextOptionHandler.Create(options)
	local self = options or {};
	setmetatable(self, { __index = BasicContextOptionHandler });
	return self;
end

function BasicContextOptionHandler:GetLabel()
	return self.label or "[Missing action label]";
end

function BasicContextOptionHandler:Attach(indicator)
	if self.indicator then
		self:Detach();
	end

	self.indicator = indicator;
	self.indicator:Show();
	self.indicator.Label:SetText(self:GetLabel());
end

function BasicContextOptionHandler:Detach()
	if not self.indicator then
		return;
	end

	self.indicator:Hide();
	self.indicator = nil;
end

function BasicContextOptionHandler:Trigger()
	self:action();
end

function BasicContextOptionHandler:CloseRadial()
	self.indicator.radial:Hide();
end

------------------------------------------------------------
--- Group finder button handler

local lfdMicroButtonHandler = MicroMenuButtonHandler.Create(LFDMicroButton, {
	label = RADIAL_LABEL_GROUP_FINDER,

	icons = {
		up = "gamepad-radial-icon-groupfinder",
		down = "gamepad-radial-icon-groupfinder-down",
		disabled = "gamepad-radial-icon-groupfinder-disabled",
	},

	contextOptions = {
		icon = "gamepad-radial-icon-groupfinder",
		[GAMEPAD_DPAD_BOTTOM] = BasicContextOptionHandler.Create({
			label = RADIAL_LABEL_LFD_CONTEXT_MENU,
			action = function(self) QueueStatusButton:ShowContextMenu(); self:CloseRadial(); end,
		}),
	},
});

function lfdMicroButtonHandler:isOpen()
	return LFGParentFrame:IsShown();
end

function lfdMicroButtonHandler:Activate()
	-- This appears to be the simplest way to determine if we're queued or not
	if not QueueStatusButton:IsShown() then
		return;
	end

	QueueStatusFrame:ClearAllPoints();
	GameTooltip_SetDefaultAnchor(QueueStatusFrame, self.segment);
	QueueStatusFrame:Show();

	self.segment.radial.ContextActionSelector:SetMenuOptions(self.contextOptions);
end

function lfdMicroButtonHandler:Deactivate()
	QueueStatusFrame:Hide();
	self.segment.radial.ContextActionSelector:SetMenuOptions();
end

------------------------------------------------------------
--- Emote context option

local emoteContextOptionHandler = BasicContextOptionHandler.Create({
	label = RADIAL_LABEL_TARGET_EMOTES,

	page = {
		header = RADIAL_LABEL_TARGET_EMOTES,
		buttons = {
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_DANCE,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Dance"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_POINT,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Point"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_WAVE,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Wave"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_KNEEL,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Kneel"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_TRAIN,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Train"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_CHICKEN,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Chicken"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_ANGRY,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Angry"); end,
			}),
			BasicSegmentHandler.Create({
				label = RADIAL_LABEL_CHEER,
				icon = 3750314,
				action = function() C_ChatInfo.PerformEmote("Cheer"); end,
			}),
		},
	},
});

function emoteContextOptionHandler:action()
	self.indicator.radial:ActivateRadial(self.page);
end

------------------------------------------------------------
---------------------- Gamepad Radial ----------------------
------------------------------------------------------------
GamepadRadialMixin = {};

function GamepadRadialMixin:OnLoad()
	for _, segment in ipairs(self.SegmentList) do
		segment.radial = self;
		self:PositionDisabledHighlight(segment);
	end

	-- Create binding set.
	self.inputBindings = GamepadMode.CreateBindingGroup("RadialBindings");
	self.inputBindings:AddFunctionBinding(GAMEPAD_SHOULDER_LEFT, GenerateClosure(self.PreviousPage, self));
	self.inputBindings:AddFunctionBinding(GAMEPAD_SHOULDER_RIGHT, GenerateClosure(self.NextPage, self));
	self.inputBindings:AddFunctionBinding(GAMEPAD_DPAD_TOP, GenerateClosure(self.ContextActionSelector.OnButton, self.ContextActionSelector, GAMEPAD_DPAD_TOP), GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.inputBindings:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.ContextActionSelector.OnButton, self.ContextActionSelector, GAMEPAD_DPAD_RIGHT), GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.inputBindings:AddFunctionBinding(GAMEPAD_DPAD_BOTTOM, GenerateClosure(self.ContextActionSelector.OnButton, self.ContextActionSelector, GAMEPAD_DPAD_BOTTOM), GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.inputBindings:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.ContextActionSelector.OnButton, self.ContextActionSelector, GAMEPAD_DPAD_LEFT), GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.inputBindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.ActivateMainMenuOrExit, self));
	self.inputBindings:AddFunctionBinding(GAMEPAD_STICK_RIGHT_PRESS, GenerateClosure(self.CancelSelection, self));

	self.inputBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.ProcessInput, self));

	self.ContextActionSelector:Init(self);
	self:InitializeRadialData();

	-- Adjust highlight and justify text for the left/right indicators.
	self.ContextActionSelector.IndicatorRight.Label:SetJustifyH("LEFT");
	self.ContextActionSelector.IndicatorRight.Highlight:SetPoint("CENTER", -45, 0);

	self.ContextActionSelector.IndicatorLeft.Label:SetJustifyH("RIGHT")
	self.ContextActionSelector.IndicatorLeft.Highlight:SetPoint("CENTER", 45, 0);
end

function GamepadRadialMixin:OnShow()
	self.isCancelled = false;
	self.currentIndex = 0;
	self.lastDistanceSq = 0;

	-- Not using `parentArray` in the XML as the order matters
	self.pageIndicators = {
		self.PageIndicatorLeft,
		self.PageIndicatorCenter,
		self.PageIndicatorRight,
	};

	GamepadMode.ActivateBindingGroup(self.inputBindings);
	self:ActivateRadial(DEFAULT_PAGE_INDEX);
	self.SegmentHighlight:Hide();

	-- Handle main menu frame state management.
	GamepadHudMode:SetShown(false);
	GroupTargeting:StopTargeting();

	local currentFrame = GamepadMode.FrameControlsManager:GetActiveFrame();
	while currentFrame and currentFrame.dismissOnUnfocus do
		if (currentFrame.SmartNavigationCloseHandler) then
			currentFrame:SmartNavigationCloseHandler();
		else
			HideUIPanel(currentFrame); -- Hide subframes that should close when the main menu is shown.
		end
		currentFrame = GamepadMode.FrameControlsManager:GetActiveFrame();
	end
	GamepadMode.FrameControlsManager:UnsuspendAllFrames();

	if GameMenuFrame:IsShown() then
		HideUIPanel(GameMenuFrame);
	end

	if (GamepadMode.FrameControlsManager:GetShownFrameCount() >= 1) then
		GamepadMode.FrameControlsManager:SetUIFocusState(false);
	end

	EventRegistry:TriggerEvent("Gamepad.ShowMainMenu");
end

function GamepadRadialMixin:OnHide()
	for index, segment in ipairs(self.SegmentList) do
		segment:SetHandler(nil);
	end

	GamepadMode.DeactivateBindingGroup(self.inputBindings);

	EventRegistry:TriggerEvent("Gamepad.HideMainMenu");

	-- If we are hiding the radial because the user picked to show the GamepadHudMode, ensure we keep
	-- the hude mode as the main focus and not some other frame like a popup.
	-- On hud mode exit a suitable frame will be chosen to be the new focus target.
	if (GamepadMode.FrameControlsManager:GetShownFrameCount() >= 1) and (not GamepadHudMode:IsShown()) then
		GamepadMode.FrameControlsManager:SetUIFocusState(true);
	end
end

function GamepadRadialMixin:InitializeRadialData()
	local function ToggleCharacterAndOpenBags()
		if not PaperDollFrame.hidden and not IsBagOpen(Enum.BagIndex.Backpack) then
			ToggleBackpack();
		end
		ToggleCharacter("PaperDollFrame");
	end

	local function IsFrameShown(frame)
		return frame and frame:IsShown();
	end

	local function OpenChat()
		local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK);
		if activeChatFrame and activeChatFrame:IsShown() then
			activeChatFrame:SetGamepadFocus();
		end
	end

	-- Set up radial options.
	-- Actions tend to be wrapped in local functions to minimize load order problems, without requiring this addon to depend on the world
	-- Do not overwrite table keys. Use a unique key when adding entries so that user saved data is preserved.
	-- If removing a key, leave it in the table but set to `nil` as a marker to not use that name in the future.
	self.segmentOptions = {
		bags = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_BAGS,
			action = function() ToggleAllBags(); end,
			isOpen = function() return IsBagOpen(Enum.BagIndex.Backpack); end,
			icons = {
				up = "gamepad-radial-icon-bags",
				down = "gamepad-radial-icon-bags-down",
				disabled = "gamepad-radial-icon-bags-disabled",
			},
		}),

		buffs = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_BUFFS,
			isEnabled = function() return BuffFrame:HasActiveAura(); end,
			action = function() if IsFrameShown(BuffFrame) then GamepadMode.FrameControlsManager:FrameShown(BuffFrame); end end,
			disabledMsg = RADIAL_ERROR_NO_AURAS,
			icons = {
				up = "gamepad-radial-icon-viewbuffs",
				down = "gamepad-radial-icon-viewbuffs-down",
				disabled = "gamepad-radial-icon-viewbuffs-disabled",
			},
		}),

		calendar = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_CALENDAR,
			action = function() ToggleCalendar(); end,
			icons = {
				up = "gamepad-radial-icon-calendar",
				down = "gamepad-radial-icon-calendar-down",
				disabled = "gamepad-radial-icon-calendar-disabled",
			},
		}),

		character = MicroMenuButtonHandler.Create(CharacterMicroButton, {
			label = RADIAL_LABEL_CHARACTER,
			action = ToggleCharacterAndOpenBags,
			icons = {
				up = "gamepad-radial-icon-character",
				down = "gamepad-radial-icon-character-down",
				disabled = "gamepad-radial-icon-character-disabled",
			},
		}),

		chat = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_CHAT,
			action = OpenChat,
			icons = {
				up = "gamepad-radial-icon-chat",
				down = "gamepad-radial-icon-chat-down",
				disabled = "gamepad-radial-icon-chat-disabled",
			},
		}),

		collections = MicroMenuButtonHandler.Create(CollectionsMicroButton, {
			label = RADIAL_LABEL_COLLECTIONS,
			isOpen = function() return IsFrameShown(CollectionsJournal); end,
			icons = {
				up = "gamepad-radial-icon-collections",
				down = "gamepad-radial-icon-collections-down",
				disabled = "gamepad-radial-icon-collections-disabled",
			},
		}),

		guild = MicroMenuButtonHandler.Create(GuildMicroButton, {
			label = RADIAL_LABEL_GUILD,
			isOpen = function() return IsFrameShown(CommunitiesFrame); end,
			icons = {
				up = "gamepad-radial-icon-communities",
				down = "gamepad-radial-icon-communities-down",
				disabled = "gamepad-radial-icon-communities-disabled",
			},
		}),

		legacy = MicroMenuButtonHandler.Create(LegacyMicroButton, {
			label = RADIAL_LABEL_LEGACY,
			isOpen = function() return IsFrameShown(LegacySystemFrame); end,
			icons = {
				up = "gamepad-radial-icon-legacy",
				down = "gamepad-radial-icon-legacy-down",
				disabled = "gamepad-radial-icon-legacy-disabled",
			},
		}),

		lfd = lfdMicroButtonHandler,

		map = MicroMenuButtonHandler.Create(QuestLogMicroButton, {
			label = RADIAL_LABEL_QUEST_MAPS,
			isOpen = function() return IsFrameShown(WorldMapFrame); end,
			icons = {
				up = "gamepad-radial-icon-quests",
				down = "gamepad-radial-icon-quests-down",
				disabled = "gamepad-radial-icon-quests-disabled",
			},
		}),

		menu = mainMenuMicroButtonHandler,

		professions = MicroMenuButtonHandler.Create(ProfessionMicroButton, {
			label = RADIAL_LABEL_PROFESSIONS,
			isOpen = function() return IsFrameShown(ProfessionsFrame); end,
			icons = {
				up = "gamepad-radial-icon-professions",
				down = "gamepad-radial-icon-professions-down",
				disabled = "gamepad-radial-icon-professions-disabled",
			},
		}),

		pvp = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_PVP,
			action = C_PvP.TogglePVP,
			icons = {
				up = "Crosshair_PVP_128",
				down = "Crosshair_PVP_128",
				disabled = "Crosshair_UnablePVP_128",
			},
		}),

		social = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_SOCIAL,
			isEnabled = function() return not Kiosk.IsEnabled(); end,
			action = function() ToggleFriendsFrame(FRIEND_TAB_FRIENDS); end,
			isOpen = function() return IsFrameShown(FriendsFrame) and PanelTemplates_GetSelectedTab(FriendsFrame); end,
			icons = {
				up = "gamepad-radial-icon-social",
				down = "gamepad-radial-icon-social-down",
				disabled = "gamepad-radial-icon-social-disabled",
			},
		}),

		spellbook = MicroMenuButtonHandler.Create(SpellbookMicroButton, {
			label = RADIAL_LABEL_SPELLBOOK,
			isOpen = function() return IsFrameShown(PlayerSpellsFrame) and IsFrameShown(PlayerSpellsFrame.SpellBookFrame); end,
			icons = {
				up = "gamepad-radial-icon-spellbook",
				down = "gamepad-radial-icon-spellbook-down",
				disabled = "gamepad-radial-icon-spellbook-disabled",
			},
		}),

		store = MicroMenuButtonHandler.Create(StoreMicroButton, {
			label = RADIAL_LABEL_SHOP,
			icons = {
				up = "gamepad-radial-icon-shop",
				down = "gamepad-radial-icon-shop-down",
				disabled = "gamepad-radial-icon-shop-disabled",
			},
		}),

		talents = MicroMenuButtonHandler.Create(TalentMicroButton, {
			label = RADIAL_LABEL_TALENTS,
			isOpen = function() return IsFrameShown(PlayerSpellsFrame) and IsFrameShown(PlayerSpellsFrame.TalentsFrame); end,
			icons = {
				up = "gamepad-radial-icon-talents",
				down = "gamepad-radial-icon-talents-down",
				disabled = "gamepad-radial-icon-talents-disabled",
			},
		}),

		time = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_CLOCK,
			action = function() TimeManager_Toggle(); end,
			isOpen = function() return IsFrameShown(TimeManagerFrame); end,
			icons = {
				up = "gamepad-radial-icon-stopwatch",
				down = "gamepad-radial-icon-stopwatch-down",
				disabled = "gamepad-radial-icon-stopwatch-disabled",
			},
		}),

		tracking = BasicSegmentHandler.Create({
			label = RADIAL_LABEL_TRACKING,
			action = function() MinimapCluster.Tracking.Button:OpenMenu(); end,
			
			icons = {
				up = "gamepad-radial-icon-minimapsettings",
				down = "gamepad-radial-icon-minimapsettings-down",
				disabled = "gamepad-radial-icon-minimapsettings-disabled",
			},
		}),
	};

	-- Entries go counter-clockwise, starting with east
	self.mainMenuPages = {
		-- Left page
		{
			buttons = {
				"lfd",
				"legacy",
				"store",
				"guild",
				"social",
				"buffs",
				"tracking",
				"collections",
			},
		},

		-- Center page
		{
			buttons = {
				"bags",
				"professions",
				"character",
				"talents",
				"map",
				"chat",
				"menu",
				"spellbook",
			},
		},

		-- Right page
		{
			buttons = {
				"time",
				"calendar",
				nil,
				nil,
				"pvp",
				nil,
				nil,
				nil,
			},
		},
	};
end

function GamepadRadialMixin:FillSegmentData()
	local page = self.currentPage;

	for index, segment in ipairs(self.SegmentList) do
		local handler = page.buttons[index];

		if type(handler) == "string" then
			handler = self.segmentOptions[handler];
		end

		segment:SetHandler(handler);
		segment:Deactivate();
	end
end

function GamepadRadialMixin:SetPagingIconVisibility(isPagingActive)
	for _, indicator in ipairs(self.pageIndicators) do
		indicator:SetShown(isPagingActive);
	end

	self.PageLeftInputPrompt:SetShown(isPagingActive);
	self.PageRightInputPrompt:SetShown(isPagingActive);
	self.PageIndicatorBackground:SetShown(isPagingActive);
end

function GamepadRadialMixin:NextPage()
	local current = self.currentMainMenuPageIndex;

	if current then
		local next = (current == MAIN_MENU_PAGE_COUNT) and 1 or (current + 1);
		self:ActivateRadial(next);
	end
end

function GamepadRadialMixin:PreviousPage()
	local current = self.currentMainMenuPageIndex;

	if current then
		local prev = (current == 1) and MAIN_MENU_PAGE_COUNT or (current - 1);
		self:ActivateRadial(prev);
	end
end

function GamepadRadialMixin:ActivateRadial(radial)
	if type(radial) == "number" then
		if radial <= 0 or radial > MAIN_MENU_PAGE_COUNT then
			return;
		end

		self.currentMainMenuPageIndex = radial;
		radial = self.mainMenuPages[radial];
	else
		self.currentMainMenuPageIndex = tIndexOf(self.mainMenuPages, radial);
	end

	if self.currentMainMenuPageIndex then
		for i, indicator in ipairs(self.pageIndicators) do
			local isActive = i == self.currentMainMenuPageIndex;
			indicator:SetAtlas("gamepad-radialgamemenu-cursorbg-" .. (isActive and "neutral" or "inactive"));
		end

		self:SetPagingIconVisibility(true);
	else
		self:SetPagingIconVisibility(false);
	end

	self.HeaderText:SetText(radial.header or FRAME_LABEL_MAIN_MENU);

	self.currentPage = radial;
	self:FillSegmentData();

	if self:IsSelecting() then
		-- Refresh the selection so it has the correct active state
		self:BeginSelection(self.currentIndex);
	end

	-- Adjust any label strings with target formatting.
	for index, segment in ipairs(self.SegmentList) do
		local updateLabel = segment.label;
		if (segment.label and string.find(segment.label, "%s") ~= nil) then
			local targetName = UnitName("target") or UnitName("softenemy") or UnitName("softfriend") or RADIAL_LABEL_NO_TARGET;
			updateLabel = string.format(segment.label, targetName);
		end
		segment.TextContainerLabel:SetText(updateLabel);
	end
end

function GamepadRadialMixin:ActivateMainMenuOrExit()
	-- Return from custom radial to the main menu or close the radial from main.
	if self.currentMainMenuPageIndex then
		self:Hide();
	else
		self:ActivateRadial(DEFAULT_PAGE_INDEX);
	end
end

function GamepadRadialMixin:PositionDisabledHighlight(segment)
	local highlightRadians, xPos, yPos = segment:GetSegmentRotationAndOffset();
	segment.SegmentDisabled:ClearAllPoints();
	segment.SegmentDisabled:SetPoint("CENTER", self.Background, xPos, yPos);
	segment.SegmentDisabled:SetRotation(highlightRadians);
end

function GamepadRadialMixin:IsSelecting()
	return self.currentIndex ~= 0;
end

function GamepadRadialMixin:BeginSelection(segmentIndex)
	local segment = self.SegmentList[segmentIndex];

	if not self:IsSelecting() then
		self.SegmentHighlight:Show();
	end

	if self.currentIndex ~= segmentIndex then
		if self.currentIndex ~= 0 then
			self.SegmentList[self.currentIndex]:Deactivate();
		end

		self.currentIndex = segmentIndex;

		local highlightRadians, xPos, yPos = segment:GetSegmentRotationAndOffset();
		self.SegmentHighlight:ClearAllPoints();
		self.SegmentHighlight:SetPoint("CENTER", self.Background, xPos, yPos);
		self.SegmentHighlight:SetRotation(highlightRadians);
		self.SegmentHighlight:SetDesaturated(not segment:IsEnabled());
		self.SegmentHighlight:Show();
	end

	-- Always activate the segment, to be able to use this to restore selection state when
	-- rebuilding the wheel.
	segment:Activate();
end

function GamepadRadialMixin:EndSelection()
	if not self:IsSelecting() then
		return;
	end

	self.SegmentList[self.currentIndex]:Deactivate();
	self.currentIndex = 0;
	self.SegmentHighlight:Hide();
end

function GamepadRadialMixin:CancelSelection()
	self.isCancelled = true
	self:EndSelection();
end

function GamepadRadialMixin:ProcessInput(x, y)
	local deadzoneSq = 0.04;	-- Drop below this to activate
	local thresholdSq = 0.25;	-- Push above this to begin selection
	local distanceSq = Square(x) + Square(y);
	self.lastDistanceSq = distanceSq;

	if self.isCancelled then
		-- Don't resume selection until the stick is recentered
		if distanceSq > deadzoneSq then
			return;
		end

		self.isCancelled = false;
	end

	if distanceSq < deadzoneSq and self:IsSelecting() then
		local segment = self.SegmentList[self.currentIndex];

		if segment:Trigger() then
			self:Hide();
		end

		self:EndSelection();
	else
		local buttonIndex = self.currentIndex;

		if distanceSq > thresholdSq then
			local degrees = math.deg(math.atan2(y,x));

			if degrees < -SEGMENT_ANGLE / 2 then
				degrees = 360 + degrees;
			end

			buttonIndex = math.floor(((degrees + SEGMENT_ANGLE) / SEGMENT_ANGLE) + 0.5);
		end

		if buttonIndex ~= self.currentIndex then
			self:BeginSelection(buttonIndex);
		end
	end
end

local function GamepadSendChat(chatText)
	local chatChannel = "SAY";
	local numInstanceGroupMembers = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE);
	local numHomeGroupMembers = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
	if numInstanceGroupMembers > 0 then
		if numInstanceGroupMembers <= 5 then
			chatChannel = "INSTANCE_CHAT";
		else
			chatChannel = "RAID";
		end
	elseif numHomeGroupMembers > 0 then
		if numHomeGroupMembers <= 5 then
			chatChannel = "PARTY";
		else
			chatChannel = "RAID";
		end
	end

	GamepadRadial:Hide();
	C_ChatInfo.SendChatMessage(chatText, chatChannel);
end

function GamepadRadialMixin:SendRadialChat(chatText)
	local targetName = UnitName("target") or UnitName("softenemy") or UnitName("softfriend") or RADIAL_LABEL_NO_TARGET;
	local finalText = string.format(chatText, targetName);
	GamepadSendChat(finalText);
end

------------------------------------------------------------
---------------------- Radial Segment ----------------------
------------------------------------------------------------
GamepadRadialSegmentMixin = {};

function GamepadRadialSegmentMixin:Activate()
	if self.handler and self.handler.Activate then
		self.handler:Activate();
	end
end

function GamepadRadialSegmentMixin:Deactivate()
	if self.handler and self.handler.Deactivate then
		self.handler:Deactivate();
	end
end

function GamepadRadialSegmentMixin:Trigger()
	return self.handler and self.handler:Trigger() or false;
end

function GamepadRadialSegmentMixin:GetLabel()
	return self.handler and self.handler:GetLabel() or "";
end

function GamepadRadialSegmentMixin:IsEnabled()
	return self.handler and self.handler:IsEnabled();
end

function GamepadRadialSegmentMixin:IsEmpty()
	return self.handler == nil;
end

function GamepadRadialSegmentMixin:SetHandler(handler)
	if self.handler then
		self.handler:Detach();
	end

	self.handler = handler;

	-- If there's no handler, this is an empty segment
	if not self.handler then
		self:Hide();
		return;
	end

	self.handler:Attach(self);
	self.IconLabel:SetText(handler:GetLabel());
	self:Show();
end

function GamepadRadialSegmentMixin:GetSegmentRotationAndOffset()
	local segmentIndex = self:GetID();
	local highlightDegrees = (segmentIndex - 1) * SEGMENT_ANGLE;
	local highlightRadians = math.rad(highlightDegrees - HIGHLIGHT_ROTATION_CORRECTION);
	local xPos = HIGHLIGHT_DISTANCE * math.cos(math.rad(highlightDegrees));
	local yPos = HIGHLIGHT_DISTANCE * math.sin(math.rad(highlightDegrees));

	return highlightRadians, xPos, yPos;
end

function GamepadRadialSegmentMixin:GetIconOffset(kind)
	local distance =  kind == "string" and ATLAS_ICON_DISTANCE or ICON_DISTANCE;

	local segmentIndex = self:GetID();
	local degrees = (segmentIndex - 1) * SEGMENT_ANGLE;
	local xPos = -distance * math.cos(math.rad(degrees));
	local yPos = -distance * math.sin(math.rad(degrees));

	return xPos, yPos;
end

local textAnchorData =
{
	[1] = { 60,   0 },	-- east
	[2] = { 30,   45 },	-- northeast
	[3] = { 0,    60 },	-- north
	[4] = { -30,  45 },	-- northwest
	[5] = { -60,   0 },	-- west
	[6] = { -30, -45 },	-- southwest
	[7] = { 0,   -60 },	-- south
	[8] = { 30,  -45 },	-- southeast
};

function GamepadRadialSegmentMixin:GetIconLabelAnchor()
	local segmentIndex = self:GetID();
	return unpack(textAnchorData[segmentIndex]);
end

------------------------------------------------------------
--- GamepadRadialContextMenuMixin

GamepadRadialContextMenuMixin = {};

function GamepadRadialContextMenuMixin:Init(radial)
	self.isDown = {};
	self.radial = radial;

	self.defaultOptions = {
		[GAMEPAD_DPAD_TOP] = emoteContextOptionHandler,
		[GAMEPAD_DPAD_BOTTOM] = BasicContextOptionHandler.Create({
			label = RADIAL_LABEL_TOGGLE_SIT,
			action = ToggleSit,
		}),
	};

	self.indicators = {
		[GAMEPAD_DPAD_TOP] = self.IndicatorTop,
		[GAMEPAD_DPAD_RIGHT] = self.IndicatorRight,
		[GAMEPAD_DPAD_BOTTOM] = self.IndicatorBottom,
		[GAMEPAD_DPAD_LEFT] = self.IndicatorLeft,
	};

	for _, indicator in pairs(self.indicators) do
		indicator.radial = radial;
		indicator.contextMenu = self;
	end

	self:SetMenuOptions(self.defaultOptions);
end

function GamepadRadialContextMenuMixin:SetMenuOptions(options)
	if self.options == options then
		return;
	end

	if self.options then
		for key, handler in pairs(self.options) do
			if self.indicators[key] then
				handler:Detach();
			end
		end
	end

	self.options = options or self.defaultOptions;

	for button, indicator in pairs(self.indicators) do
		local handler = self.options[button];
		if handler then
			handler:Attach(indicator);
		end
	end

	if self.options.icon then
		self.ContextIcon:SetAtlas(self.options.icon);
		self.ContextIcon:Show();
	else
		self.ContextIcon:Hide();
	end
end

function GamepadRadialContextMenuMixin:OnButton(button, isDown)
	-- Ignore button releases for buttons we never observed the down for
	if not isDown and not self.isDown[button] then
		return;
	end

	self.isDown[button] = isDown;

	local handler = self.options[button];
	if handler then
		local indicator = self.indicators[button];
		indicator.Highlight:SetShown(isDown);
		if not isDown then
			handler:Trigger();
		end
	end
end
