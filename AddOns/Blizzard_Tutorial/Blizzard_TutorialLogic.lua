local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;



-- ============================================================================================================
-- Helper Functions
-- ============================================================================================================
local TutorialHelper = {};

-- ------------------------------------------------------------------------------------------------------------
-- just a helper funciton for everytime you grab a localized string
local function formatStr(str)
	--return TutorialHelper:FormatAtlasString(str);
	return TutorialHelper:FormatString(str);
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetRace()
	local _, race = UnitRace("player");
	return race;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetClass()
	local _, class = UnitClass("player");
	return class;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:FormatString(str)
	-- Spell Names and Icons e.g. {$1234}
	str = string.gsub(str, "{%$(%d+)}", function(spellID)
			local name, _, icon = GetSpellInfo(spellID);
			return string.format("|cFF00FFFF%s|r |T%s:16|t", name, icon);
		end);

	-- Spell Keybindings e.g. {KB|1234}
	str = string.gsub(str, "{KB|(%d+)}", function(spellID)
			local bindingString;

			if (spellID) then
				local btn = self:GetActionButtonBySpellID(tonumber(spellID));
				if (btn) then
					bindingString = GetBindingKey("ACTIONBUTTON" .. btn.action);
				end
			end

			return string.format("[%s]", bindingString or "?");
		end);

	-- Atlas icons e.g. {Atlas|NPE_RightClick:16}
	str = string.gsub(str, "{Atlas|([%w_]+):?(%d*)}", function(atlasName, size)
				size = tonumber(size) or 0;
				return CreateAtlasMarkup(atlasName, size, size);
			end);

	return str;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetClassString(key)
	local classStr = _G[key .. "_" .. self:GetClass()];
	if (classStr and (classStr ~= nil)) then
		return classStr;
	end

	return _G[key];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetRacialData()
	return TutorialData[self:GetRace()];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetItemContainerFrame(container, slot)
	local frameIndex = (GetContainerNumSlots(container) + 1) - slot;
	return _G["ContainerFrame" .. (container + 1) .. "Item" .. frameIndex];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:CloseAllBags()
	for i = 0, 4 do
		if (IsBagOpen(i)) then
			ToggleBag(i);
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Takes a potential table of ID's keyed by player class and returns the appropriate one
-- if the set is not a table, the single item is returned
function TutorialHelper:FilterByClass(set)
	if (type(set) == "table") then
		return set[self:GetClass()];
	end

	return set;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetBundleByQuestID(questID)
	local data = self:GetRacialData().MultiQuestPickup;

	if (not data) then return nil; end

	-- a bundle is a table of quests that should be picked up together
	for bk, bundle in pairs(data) do
		-- quest raw is either a quest or a set of quests keyed by class
		for qk, questRaw in pairs(bundle) do
			local quest = self:FilterByClass(questRaw);
			-- see if this bundle contains the quest
			if (quest == questID) then
				return bundle;
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:IsQuestCompleteOrActive(questID)
	return C_QuestLog.IsQuestFlaggedCompleted(questID) or C_QuestLog.GetLogIndexForQuestID(questID) ~= nil;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:DoQuestsInBundleNeedPickup(questBundle)
	if (type(questBundle) ~= "table") then
		return nil;
	end

	for i, questRaw in ipairs(questBundle) do
		local questID = self:FilterByClass(questRaw);
		if (not self:IsQuestCompleteOrActive(questID)) then
			return true;
		end
	end

	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetActionButtonBySpellID(spellID)
	if (type(spellID) ~= "number") then return nil; end

	for i = 1, 12 do
		local btn = _G["ActionButton" .. i];
		local _, sID = GetActionInfo(btn.action);

		if (sID == spellID) then
			return btn;
		end
	end

	-- backup for stance bars
	for i = 1, 10 do
		local btn = _G["StanceButton" .. i];
		local icon, isActive, isCastable, sID = GetShapeshiftFormInfo(btn:GetID());

		if (sID == spellID) then
			return btn;
		end
	end

	return nil;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetGossipBindIndex()
	local GossipOptions = C_GossipInfo.GetOptions();
	for i, gossipOption in ipairs(GossipOptions) do
		if gossipOption.type == "binder" then
			return i;
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- returns the x and y offset from the gossip frames TOPRIGHT point
function TutorialHelper:GetFrameButtonEdgeOffset(frame, button)
	local posY = -100;
	local posX = 0;

	if (button) then
		posY = button:GetTop() - frame:GetTop() - (button:GetHeight() / 2);

		local fontString = button:GetFontString();
		if (fontString) then
			posX = -(frame:GetRight() - fontString:GetLeft() - fontString:GetStringWidth());
		else
			posX = -(frame:GetRight() - button:GetLeft() - button:GetWidth());
		end
	end

	return math.min(-50, posX), posY;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:FindItemInContainer(itemID)
	for containerIndex = 0, 4 do
		local slots = GetContainerNumSlots(containerIndex);
		if (slots > 0) then
			for slotIndex = 1, slots do
				local id = select(10, GetContainerItemInfo(containerIndex, slotIndex));
				if (id == itemID) then
					return containerIndex, slotIndex;
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetMapBinding()
	return GetBindingKey("TOGGLEWORLDMAP") or "";
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetCharacterBinding()
	return GetBindingKey("TOGGLECHARACTER0") or "";
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialHelper:GetBagBinding()
	return GetBindingKey("OPENALLBAGS") or "";
end






-- ============================================================================================================
-- Map Bridge
-- ============================================================================================================
local MapBridgeDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapBridgeDataProviderMixin:OnMapChanged(...) -- override
	if self.mapChangedCallback then
		self.mapChangedCallback(...);
	end
end

function MapBridgeDataProviderMixin:SetOnMapChangedCallback(mapChangedCallback)
	self.mapChangedCallback = mapChangedCallback;
end

function MapBridgeDataProviderMixin:New()
	local t = CreateFromMixins(MapBridgeDataProviderMixin);
	WorldMapFrame:AddDataProvider(t);
	return t;
end










-- ============================================================================================================
-- Tutorial Base
-- ============================================================================================================
local Class_TutorialBase = class("TutorialBase");
Class_TutorialBase.static.IsDebugging = false;
Class_TutorialBase.static.IsGlobalEnabled = true;

function Class_TutorialBase.static:GlobalEnable()
	self.static.IsGlobalEnabled = true;
end

function Class_TutorialBase.static:GlobalDisable()
	self.static.IsGlobalEnabled = false;

	-- Shutdown all tutorials
	for k, tutorial in pairs(Tutorials) do
		-- probably should have wrapped these in their own table...
		if (type(tutorial) == "table") then
			tutorial:Interrupt();
		end
	end
end

function Class_TutorialBase.static:MakeExclusive(t1, t2)
	t1:AddExclusiveTutorial(t2);
	t2:AddExclusiveTutorial(t1);
end

function Class_TutorialBase.static:Debug(value)
	self.static.IsDebugging = value;
end

function Class_TutorialBase.static:ColorDebugText(text)
	return string.format("|cFF00FFFF%s|r", tostring(text));
end

function Class_TutorialBase:DebugLog(funcName, extraText)
	if (Class_TutorialBase.static.IsDebugging) then

		print(string.format("%s - %s (%s)", Class_TutorialBase:ColorDebugText(self.class.name), funcName, (extraText or "")));
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:initialize(parent)
	self._childTutorials = {};
	self._exclusiveTutorials = {};

	self._screenTutorial = nil;
	self._pointerTutorials = {};

	self.Parent = parent;

	if (self.Parent) then
		self.Parent:_RegisterChild(self)
	end

	-- Default Values
	self.IsActive = false;
	self.IsEnabled = true;
	self.IsComplete = false;
	self.IsSuppressed = false;
	self.AllowCompleteWhileSuppressed = false;
	self.IsSuppressedComplete = false;
	self._MaxLevel = nil;
	self._MaxCount = nil;
	self._Count = 0;
	self._DelayFrame = nil;
	self._suppresses = {};

	if (self.OnInitialize) then
		self:OnInitialize()
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:_RegisterChild(child)
	table.insert(self._childTutorials, child);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:AddExclusiveTutorial(exclusiveTutorial)
	table.insert(self._exclusiveTutorials, exclusiveTutorial);
end

-- ------------------------------------------------------------------------------------------------------------
-- Screen Tutorials
-- Center top screen box that can't be moved
-- Frame is automatically closed when tutorial is shutdown
function Class_TutorialBase:ShowScreenTutorial(content, druation, position)
	self:DebugLog("ShowScreenTutorial");
	self._screenTutorial = NPE_TutorialMainFrame:Show(content, druation, position);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:HideScreenTutorial()
	if (not self._screenTutorial) then return; end

	self:DebugLog("HideScreenTutorial");
	NPE_TutorialMainFrame:Hide(self._screenTutorial);
	self._screenTutorial = nil;
end

-- ------------------------------------------------------------------------------------------------------------
-- Pointer Tutorials
-- Arrow frame that points at something on screen
-- Frame is automatically closed when tutorial is shutdown
-- This function clears any existing poitners before adding the new one
function Class_TutorialBase:ShowPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection)
	self:DebugLog("ShowPointerTutorial");

	self:HidePointerTutorials();
	return self:AddPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection);
end

-- ------------------------------------------------------------------------------------------------------------
-- Adds a pointer tutorial ontop of existing pointers
function Class_TutorialBase:AddPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection)
	self:DebugLog("AddPointerTutorial");
	local pointer = NPE_TutorialPointerFrame:Show(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection);
	table.insert(self._pointerTutorials, pointer);

	return pointer;
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:HidePointerTutorials()
	local count = #self._pointerTutorials;
	if (count == 0) then return; end

	self:DebugLog("HidePointerTutorials");

	for i = 1, count do
		NPE_TutorialPointerFrame:Hide(self._pointerTutorials[i]);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:_DoBegin(...)
	self:DebugLog("Begin")

	if (not Class_TutorialBase.IsGlobalEnabled) then
		self:DebugLog("Begin Failed, Tutorials globally disabled");
		return;
	end

	if (not self.IsEnabled) then
		self:DebugLog("Begin Failed, Tutorial disabled");
		return;
	end

	if (self._MaxLevel and (UnitLevel("player") > self._MaxLevel)) then
		self:DebugLog("Begin Failed, player beyond Max Level");
		return;
	end

	if (self._MaxCount and (self._Count >= self._MaxCount)) then
		self:DebugLog("Begin Failed, Tutorial beyond Max Count");
		return;
	end

	self._Count = self._Count + 1;

	-- Suppress any auto-suppressed tutorials
	for i, tutorial in ipairs(self._suppresses) do
		tutorial:Suppress();
	end

	-- Interrupt any active exclusive tutorials
	for i = 1, #self._exclusiveTutorials do
		self._exclusiveTutorials[i]:Interrupt(self);
	end

	self.IsActive = true;
	self.IsSuppressed = false;

	if (self._DelayFrame and self._DelayFrame:IsVisible()) then
		local args;

		-- there is no way to pass varargs through to a closure.
		-- However, this will only create a table if there is data to pass through.
		if (select("#", ...) > 0) then
			args = { ... };
		end

		Dispatcher:RegisterScript(self._DelayFrame, "OnHide", function()
				-- it's possible that this tutorial was turned off while waiting.
				if (not self.IsActive) then return; end

				if (args) then
					self:_DoOnBegin(unpack(args));
				else
					self:_DoOnBegin();
				end
			end, true);

	else
		self:_DoOnBegin(...);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:_DoOnBegin(...)
	if (self.OnBegin) then
		self:OnBegin(...)

		-- it's posisble for a tutorial to be completed or interrupted durring its OnBegin
		if (not self.IsActive) then
			self:DebugLog("OnBegin Complete - Shutting down", "no longer active")

			self:_Shutdown();
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:ForceBegin(...)
	self:_DoBegin(...);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Begin(...)
	if (self.IsActive) then
		self:DebugLog("Begin - Tutorial didn't begin because it's already active.")
		return;
	end

	self:_DoBegin(...);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:_Shutdown()
	self:DebugLog("_Shutdown");

	self.IsActive = false;

	-- Kill child tutorials
	for i = 1, #self._childTutorials do
		self._childTutorials[i]:Interrupt(self);
	end

	-- Unsuppress auto-suppressed tutorials
	for i, tutorial in ipairs(self._suppresses) do
		tutorial:Unsuppress();
	end

	-- Hide the screen tutorial
	self:HideScreenTutorial();

	-- Hide the pointer tutorial
	self:HidePointerTutorials();

	-- Unregister all Events, Functions and Scripts
	Dispatcher:UnregisterAll(self);

	if (self.OnShutdown) then
		self:OnShutdown()
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Complete(...)
	if (not self.IsActive) then return; end

	if (self.IsSuppressed) then
		if (not self.AllowCompleteWhileSuppressed) then
			self.IsSuppressedComplete = true;
			return;
		end
	end

	self:DebugLog("Complete");

	if (self.OnComplete) then
		self:OnComplete(...)
	end

	self.IsComplete = true;

	self:_Shutdown();
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Interrupt(interruptedBy)
	if (not self.IsActive) then return; end

	if (interruptedBy) then
		self:DebugLog("Interrupt", "interrupted by " .. Class_TutorialBase:ColorDebugText(interruptedBy.class.name));
	else
		self:DebugLog("Interrupted");
	end

	if (self.OnInterrupt) then
		self:OnInterrupt(interruptedBy)
	end
	self:_Shutdown();
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Enable()
	self.IsEnabled = true;
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Disable()
	self.IsEnabled = false;

	if (self.IsActive) then
		self:Interrupt();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Suppress(...)
	if ((not self.IsActive) or (self.IsSuppressed)) then return; end

	self:DebugLog("Suppress");

	self.IsSuppressed = true;

	if (self.OnSuppressed) then
		self:OnSuppressed(...)
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Unsuppress()
	if ((not self.IsActive) or (not self.IsSuppressed)) then return; end

	self:DebugLog("Unsuppress");

	self.IsSuppressed = false;

	if (self.OnUnsuppressed) then
		self:OnUnsuppressed()
	end

	if (self.IsSuppressedComplete) then
		self:Complete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:InterruptChildren()
	for i = 1, #self._childTutorials do
		self._childTutorials[i]:Interrupt(self);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:SuppressChildren(...)
	self:DebugLog("SuppressChildren");

	for i = 1, #self._childTutorials do
		self._childTutorials[i]:Suppress(...);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:UnsuppressChildren()
	self:DebugLog("UnsuppressChildren");

	for i = 1, #self._childTutorials do
		self._childTutorials[i]:Unsuppress();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:SetMaxLevel(level)
	self._MaxLevel = level;

	if (self._MaxLevel and self.IsActive and (UnitLevel("player") > self._MaxLevel)) then
		self:Interrupt(self);
		return;
	end

	Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:PLAYER_LEVEL_UP(newLevel)
	if (self._MaxLevel and (newLevel > self._MaxLevel)) then
		self:Interrupt(self);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:SetMaxCount(maxCount)
	self._MaxCount = maxCount;
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Suppresses(...)
	for i = 1, select("#", ...) do
		local tutorial = select(i, ...);

		if (instanceOf(Class_TutorialBase, tutorial)) then
			table.insert(self._suppresses, tutorial);
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:DelayWhileFrameVisible(frame)
	self._DelayFrame = frame;
end















-- ============================================================================================================
-- Sequence - Intro
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Interact with Quest giver
-- Active at start, prompts the player to click on the quest giver standing infront of them
-- Sequence: [Interact] - OpenMap - MapPointer - KeyboardMouse
-- ------------------------------------------------------------------------------------------------------------
local Class_Intro_Interact = class("Intro_Interact", Class_TutorialBase);

function Class_Intro_Interact:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_QUESTGIVER), nil, NPE_TutorialMainFrame.FramePositions.Low);
	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
end

function Class_Intro_Interact:QUEST_ACCEPTED()
	self:Complete();
end

function Class_Intro_Interact:OnComplete()
	Tutorials.Intro_OpenMap:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Open Map
-- Main screen prompt to ope the map
-- Sequence: Interact - [OpenMap] - MapPointer - KeyboardMouse
-- ------------------------------------------------------------------------------------------------------------
local Class_Intro_OpenMap = class("Intro_OpenMap", Class_TutorialBase);

function Class_Intro_OpenMap:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_Intro_OpenMap:OnBegin()
	Tutorials.QuestCompleteOpenMap:Interrupt(self);

	local key = TutorialHelper:GetMapBinding();
	self:ShowScreenTutorial(formatStr(string.format(NPE_OPENMAP, key)));
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", function() self:Complete(); end, true);
end

function Class_Intro_OpenMap:OnComplete()
	Tutorials.Intro_MapHighlights:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Map Pointers
-- This shows the map legend and the minimap legend
-- Sequence: Interact - OpenMap - [MapPointer] - KeyboardMouse
-- ------------------------------------------------------------------------------------------------------------
local Class_Intro_MapHighlights = class("Intro_MapHighlights", Class_TutorialBase);

function Class_Intro_MapHighlights:OnBegin()
	self.MapID = WorldMapFrame:GetMapID();

	self.Prompt = NPE_MAPCALLOUTBASE;
	local hasBlob = false;

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i);
		if QuestUtils_IsQuestWatched(questID) and GetQuestPOIBlobCount(questID) > 0 then
			hasBlob = true;
			break;
		end
	end

	if (hasBlob) then
		self.Prompt = self.Prompt .. NPE_MAPCALLOUTAREA;
	else
		self.Prompt = self.Prompt .. NPE_MAPCALLOUTPOINT;
	end

	self:Display();

	self.Timer = C_Timer.NewTimer(8, function()
			self:AddPointerTutorial(formatStr(NPE_CLOSEWORLDMAP), "UP", WorldMapFrameCloseButton, 0, 15);
		end);

	Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() self:Complete(); end, true);

	self.MapProvider = MapBridgeDataProviderMixin:New()
	self.MapProvider:SetOnMapChangedCallback(function()
			local mapID = self.MapProvider:GetMap():GetMapID();
			if (mapID ~= self.MapID) then
				self:Suppress();
			else
				self:Unsuppress();
			end
		end);
end

function Class_Intro_MapHighlights:Display()
	if (WorldMapFrame.isMaximized) then
		self.MapPointerTutorialID = self:AddPointerTutorial(formatStr(self.Prompt), "LEFT", WorldMapFrame.ScrollContainer, -200, 0, nil);
	else
		self.MapPointerTutorialID = self:AddPointerTutorial(formatStr(self.Prompt), "UP", WorldMapFrame.ScrollContainer, 0, 100, nil);
	end
end

function Class_Intro_MapHighlights:OnSuppressed()
	NPE_TutorialPointerFrame:Hide(self.MapPointerTutorialID);
end

function Class_Intro_MapHighlights:OnUnsuppressed()
	self:Display();
end

function Class_Intro_MapHighlights:OnComplete()
	Tutorials.Intro_KeyboardMouse:Begin();
end

function Class_Intro_MapHighlights:OnShutdown()
	if (self.Timer) then
		self.Timer:Cancel();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Keyboard Mouse help
-- This shows the map legend and the minimap legend
-- Sequence: Interact - OpenMap - MapPointer - [KeyboardMouse]
-- ------------------------------------------------------------------------------------------------------------
local Class_Intro_KeyboardMouse = class("Intro_KeyboardMouse", Class_TutorialBase);

function Class_Intro_KeyboardMouse:OnBegin()
	NPE_TutorialKeyboardMouseFrame:Show();
end

function Class_Intro_KeyboardMouse:OnSuppressed()
	NPE_TutorialKeyboardMouseFrame:Dim();
end

function Class_Intro_KeyboardMouse:OnUnsuppressed()
	NPE_TutorialKeyboardMouseFrame:UnDim();
end












-- ============================================================================================================
-- Sequence - First Mob
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Select First Mob Watcher
-- ------------------------------------------------------------------------------------------------------------
local Class_SelectMobWatcher = class("SelectMobWatcher", Class_TutorialBase);

function Class_SelectMobWatcher:OnBegin()
	-- Use a leash on the first unit if it's defined, otherwise, lease the player's current location
	local tutorialData = TutorialHelper:GetRacialData();
	if not tutorialData then
		return;
	end

	local unit = tutorialData.FirstKillQuestUnit;
	if (unit) then
		NPE_RangeManager:StartWatching( unit, NPE_RangeManager.Type.Unit, 20, function() self:Complete(); end);
	else
		-- Cache off the player's location
		self.x, self.y = UnitPosition("player");
		self.elapsed = 0;
		Dispatcher:RegisterEvent("OnUpdate", self);
	end
end

function Class_SelectMobWatcher:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed;
	if (self.elapsed > 0.25) then
		self.elapsed = 0;
		local x, y = UnitPosition("player");
		local squaredDistance = math.pow(self.x - x, 2) + math.pow(self.y - y, 2);

		if (squaredDistance >= 100) then
			self:Complete();
		end
	end
end

function Class_SelectMobWatcher:OnComplete(elapsed)
	Tutorials.TargetMob:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Target First Mob
-- Sequence: [Target Mob] - Action Bar Callout - Health Bar callout
-- ------------------------------------------------------------------------------------------------------------
local Class_TargetMob = class("TargetMob", Class_TutorialBase);

function Class_TargetMob:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_TARGETFIRSTMOB))

	ClearTarget();
	Dispatcher:RegisterEvent("UNIT_TARGET", self);
end

function Class_TargetMob:UNIT_TARGET(unitID)
	if ((unitID == "player") and UnitCanAttack("player", "playertarget")) then
		self:Complete();
	end
end

function Class_TargetMob:OnComplete()
	Tutorials.ActionBarCallout:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Callout Action Bar
-- Sequence: Target Mob - [Action Bar Callout] - Health Bar callout
-- ------------------------------------------------------------------------------------------------------------
local Class_ActionBarCallout = class("ActionBarCallout", Class_TutorialBase);

function Class_ActionBarCallout:OnBegin()
	self.SuccessfulCastCount = 0;
	self.isWarrior = TutorialHelper:GetClass() == "WARRIOR";

	local startingAbility = TutorialHelper:FilterByClass(TutorialData.StartingAbility);

	if (self.isWarrior) then
		startingAbility = 88163; -- Warriors start off with melee as their "first" ability.
	end

	if (self:HighlightPointer(startingAbility)) then
		if (self.isWarrior) then
			-- Warriors start with auto-attack to build rage, then call out their pointer
			Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", function()
					self:HidePointerTutorials();
					C_Timer.After(2, function() self:Warrior_AttemptPointer2(); end);
				end, true);
		else
			Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
		end
	end
end

function Class_ActionBarCallout:Warrior_AttemptPointer2()
	local requiredRage = 25; -- fallback value, something decentish
	local costTable = GetSpellPowerCost(TutorialData.StartingAbility.WARRIOR);
	for _, costInfo in pairs(costTable) do
		if (costInfo.type == Enum.PowerType.Rage) then
			requiredRage = costInfo.cost;
			break;
		end
	end

	-- Callout mortal strike if they have enough rage, otherwise wait
	if (UnitPower('player') >= requiredRage) then
		self:Warrior_InitiatePointer2();
	else
		local unitPowerID; -- this local must exist before the closure below is constructed
		unitPowerID = Dispatcher:RegisterEvent("UNIT_POWER_UPDATE", function()
				if (UnitPower('player') >= requiredRage) then
					self:Warrior_InitiatePointer2();
					Dispatcher:UnregisterEvent("UNIT_POWER_UPDATE", unitPowerID);
				end
			end);
	end
end

function Class_ActionBarCallout:Warrior_InitiatePointer2()
	if (self:HighlightPointer(TutorialHelper:FilterByClass(TutorialData.StartingAbility), "NPE_ABILITYSECOND")) then
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	end
end

function Class_ActionBarCallout:HighlightPointer(spellID, textID)
	local btn = TutorialHelper:GetActionButtonBySpellID(spellID);
	if (btn) then
		-- Store off the spellID to check for usage later
		self.SpellID = spellID;

		-- Prompt the user to use the spell
		local name, _, icon = GetSpellInfo(spellID);
		local prompt = formatStr(TutorialHelper:GetClassString(textID or "NPE_ABILITYINITIAL"));
		local binding = GetBindingKey("ACTIONBUTTON" .. btn.action) or "?";
		local finalString = string.format(prompt, binding, name, icon);

		self:ShowPointerTutorial(finalString, "DOWN", btn);
		ActionButton_ShowOverlayGlow(btn);

		return spellID;
	end

	return false;
end

function Class_ActionBarCallout:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if (unit ~= "player") then return; end

	if (spellID == self.SpellID) then
		self.SuccessfulCastCount = self.SuccessfulCastCount + 1;
	end

	if (self.SuccessfulCastCount >= 4) then
		Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", function() self:Complete() end, true);
	end
end

function Class_ActionBarCallout:DisableActionButtonGlow()
	for i = 1, 12 do
		local btn = _G["ActionButton" .. i];
		if (btn) then
			ActionButton_HideOverlayGlow(btn);
		end
	end
end

function Class_ActionBarCallout:OnShutdown()
	self:DisableActionButtonGlow();
end

-- ------------------------------------------------------------------------------------------------------------
-- Heath Bar Callout
-- Sequence: Target Mob - Action Bar Callout - [Health Bar callout]
-- ------------------------------------------------------------------------------------------------------------
local Class_HealthBarCallout = class("HealthBarCallout", Class_TutorialBase);

function Class_HealthBarCallout:OnInitialize()
	self:SetMaxCount(1);
end

function Class_HealthBarCallout:OnBegin()
	local index, resourceIdentifier = UnitPowerType("player");
	local resourceText = _G[resourceIdentifier];

	local prompt = string.format(formatStr(NPE_HEALTHBAR), resourceText);

	C_Timer.After(2, function()
			self:ShowPointerTutorial(prompt, "UP", PlayerFrameManaBar, 0, 0);

			if (UnitAffectingCombat("player")) then
				Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", function()
						C_Timer.After(10, function() self:Complete(); end);
					end, true);
			else
				C_Timer.After(10, function() self:Complete(); end);
			end
		end);
end



















-- ============================================================================================================
-- Sequence - Equip First Item
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Equip First Item Watcher
-- Watches you inventory for item upgrades to kick off this sequence
-- ------------------------------------------------------------------------------------------------------------
local Class_EquipFirstItemWatcher = class("EquipFirstItemWatcher", Class_TutorialBase);

function Class_EquipFirstItemWatcher:OnInitialize()
	self.WeaponType = {
		TwoHand	= "TwoHand",
		Ranged	= "Ranged",
		Other	= "Other",
	}
end

function Class_EquipFirstItemWatcher:OnBegin()
	self.SuccessfulEquipCount = 0;
	Dispatcher:RegisterEvent("UNIT_INVENTORY_CHANGED", self);
end

function Class_EquipFirstItemWatcher:ItemSuccessfullyEquiped()
	self.SuccessfulEquipCount = self.SuccessfulEquipCount + 1;
end

function Class_EquipFirstItemWatcher:UNIT_INVENTORY_CHANGED()
	local upgrades = self:GetBestItemUpgrades();
	local slot, item = next(upgrades);

	-- Only show the equip tutorial 3 times
	if (item and (self.SuccessfulEquipCount < 3)) then
		Tutorials.ShowBags:ForceBegin(item);
	end
end

function Class_EquipFirstItemWatcher:STRUCT_ItemContainer(itemID, characterSlot, container, containerSlot)
	return
	{
		ItemID = itemID,
		Container = container,
		ContainerSlot = containerSlot,
		CharacterSlot = characterSlot,
	};
end

-- Find the best item a player can equip from their bags per equipment slot
-- @return A table keyed off equipement slot that contains a STRUCT_ItemContainer
function Class_EquipFirstItemWatcher:GetBestItemUpgrades()
	local potentialUpgrades = self:GetPotentialItemUpgrades();
	local upgrades = {};

	for equipmentSlot, items in pairs(potentialUpgrades) do
		local highest = nil;
		local highestIlvl = 0;

		for i = 1, #items do
			local ilvl = select(4, GetItemInfo(items[i].ItemID));
			if (ilvl > highestIlvl) then
				highest = items[i];
				highestIlvl = ilvl;
			end
		end

		if (highest) then
			upgrades[equipmentSlot] = highest;
		end
	end

	return upgrades;
end

function Class_EquipFirstItemWatcher:GetWeaponType(itemID)
	local loc = select(9, GetItemInfo(itemID));

	if ((loc == "INVTYPE_RANGED") or (loc == "INVTYPE_RANGEDRIGHT")) then
		return self.WeaponType.Ranged;
	elseif (loc == "INVTYPE_2HWEAPON") then
		return self.WeaponType.TwoHand;
	else
		return self.WeaponType.Other;
	end
end

-- Walk all the character item slots and create a list of items in the player's inventory
-- that can be equipped into those slots and is a higher ilvl
-- @return a table of all slots that have higher ilvl items in the player's pags. Each table is a list of STRUCT_ItemContainer
function Class_EquipFirstItemWatcher:GetPotentialItemUpgrades()
	local potentialUpgrades = {};

	local playerClass = select(2, UnitClass("player"));

	for i = 0, INVSLOT_LAST_EQUIPPED do
		local existingItemIlvl = 0;
		local existingItemWeaponType;

		local existingItemID = GetInventoryItemID("player", i);
		if (existingItemID ~= nil) then
			existingItemIlvl = select(4, GetItemInfo(existingItemID)) or 0;

			if (i == INVSLOT_MAINHAND) then
				existingItemWeaponType = self:GetWeaponType(existingItemID);
			end
		end

		local availableItems = {};
		GetInventoryItemsForSlot(i, availableItems);

		for packedLocation, itemID in pairs(availableItems) do
			local itemInfo = {GetItemInfo(itemID)};
			local ilvl = itemInfo[4];

			if (ilvl ~= nil) then
				if (ilvl > existingItemIlvl) then

					-- why can't I just have a continue statement?
					local match = true;

					-- if it's a main-hand, make sure it matches the current type, if there is one
					if (i == INVSLOT_MAINHAND) then
						local weaponType = self:GetWeaponType(itemID);
						match = (not existingItemWeaponType) or (existingItemWeaponType == weaponType);

						-- rouge's should only be recommended daggers
						if ( playerClass == "ROGUE" and (itemInfo[12] ~= ITEMSUBCLASSTYPES["DAGGER"].classID or itemInfo[13] ~= ITEMSUBCLASSTYPES["DAGGER"].subClassID) ) then
							match = false;
						end
					end

					-- if it's an off-hand, make sure the player doesn't have a 2h or rnaged weapon
					if (i == INVSLOT_OFFHAND) then
						local mainHandID = GetInventoryItemID("player", INVSLOT_MAINHAND);
						if (mainHandID) then
							local mainHandType = self:GetWeaponType(mainHandID);
							if ((mainHandType == self.WeaponType.TwoHand) or (mainHandType == self.WeaponType.Ranged)) then
								match = false;
							end
						end

						-- rouge's should only be recommended daggers
						if ( playerClass == "ROGUE" and (itemInfo[12] ~= ITEMSUBCLASSTYPES["DAGGER"].classID or itemInfo[13] ~= ITEMSUBCLASSTYPES["DAGGER"].subClassID) ) then
							match = false;
						end
					end

					if (match) then
						local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(packedLocation);

						if ((player == true) and (bags == true)) then
							if (potentialUpgrades[i] == nil) then
								potentialUpgrades[i] = {};
							end

							table.insert(potentialUpgrades[i], self:STRUCT_ItemContainer(itemID, i, bag, slot));
						end
					end
				end
			end
		end
	end

	return potentialUpgrades;
end

-- ------------------------------------------------------------------------------------------------------------
-- Show Bags
-- Called when the player recieves their first item upgrade
-- Sequence: [Show Bags] - Equip Item - Open Character Sheet - Highlight Equipped Item - Close Character Sheet
-- ------------------------------------------------------------------------------------------------------------
local Class_ShowBags = class("ShowBags", Class_TutorialBase);

function Class_ShowBags:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

-- @param data: type STRUCT_ItemContainer
function Class_ShowBags:OnBegin(data)
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	self.Data = data;

	-- If the player recieved a piece of gear from the previous quest turn in and that was followed by a
	-- breadcrum quest, then the Open Map prompt will be up which is more important than telling them
	-- to equip their item.  they'll get prompted for the item next time around.
	if (Tutorials.QuestCompleteOpenMap.IsActive) then
		self:Interrupt(Tutorials.QuestCompleteOpenMap);
		return;
	end

	-- Likeiwse, this tutorial takes a backseat to the multi-quest pickup prompt.
	if (Tutorials.AcceptMoreQuests.IsActive) then
		self:Interrupt(Tutorials.AcceptMoreQuests);
		return;
	end

	-- Verify the item is still there.  Edge-case where someone managed to open their bags and equip the item
	-- between the time the tutorial was activated and actually begins.  e.g. They turn in a quest that rewards
	-- them with an item, activating this tutorial.  The quest frame is still open to accept the next quest causing
	-- this to be delayed, and in while the quest frame is open, they equip the item.
	if (not GetContainerItemID(data.Container, data.ContainerSlot)) then
		self:Interrupt(self);
		return;
	end

	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();

	Dispatcher:RegisterFunction("ToggleBackpack", function() self:Complete() end, true);

	local key = TutorialHelper:GetBagBinding();
	self:ShowScreenTutorial(formatStr(string.format(NPE_OPENBAG, key)));
end

function Class_ShowBags:OnComplete()
	Tutorials.EquipItem:ForceBegin(self.Data);
end


-- ------------------------------------------------------------------------------------------------------------
-- Equip Item
-- Called when the player recieves their first item upgrade after they open their bags
-- Sequence: Show Bags - [Equip Item] - Open Character Sheet - Highlight Equipped Item - Close Character Sheet
-- ------------------------------------------------------------------------------------------------------------
local Class_EquipItem = class("EquipItem", Class_TutorialBase);

-- @param data: type STRUCT_ItemContainer
function Class_EquipItem:OnBegin(data)
	if (MerchantFrame:IsVisible()) then
		self:Interrupt(self);
		return;
	end

	self.ItemData = data;

	self:UpdatePointer();

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self)
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self)
	Dispatcher:RegisterEvent("MERCHANT_SHOW", function() self:Interrupt(self) end, true);
end

function Class_EquipItem:UpdatePointer()
	local itemFrame = TutorialHelper:GetItemContainerFrame(self.ItemData.Container, self.ItemData.ContainerSlot);
	if (itemFrame) then
		self:ShowPointerTutorial(formatStr(NPE_EQUIPITEM), "DOWN", itemFrame, 0, 0);
	end
end

function Class_EquipItem:PLAYER_EQUIPMENT_CHANGED()
	if (GetInventoryItemID("player", self.ItemData.CharacterSlot) == self.ItemData.ItemID) then
		self:Complete()
	end
end

function Class_EquipItem:BAG_UPDATE_DELAYED()
	if (self.IsActive) then
		local container, slot = TutorialHelper:FindItemInContainer(self.ItemData.ItemID);
		if (container and slot) then
			self.ItemData.Container, self.ItemData.ContainerSlot = container, slot;
			self:UpdatePointer();
		else
			self:Interrupt();
			Tutorials.ShowBags:Interrupt();
		end
	end
end

function Class_EquipItem:OnComplete()
	Tutorials.EquipFirstItemWatcher:ItemSuccessfullyEquiped();
	Tutorials.OpenCharacterSheet:ForceBegin(self.ItemData);
end

function Class_EquipItem:OnShutdown()
	self.ItemData = nil;
end


-- ------------------------------------------------------------------------------------------------------------
-- Open Character Sheet
-- Called when the player recieves their first item upgrade after they open their bags
-- Sequence: Show Bags - Equip Item - [Open Character Sheet] - Highlight Equipped Item - Close Character Sheet
-- ------------------------------------------------------------------------------------------------------------
local Class_OpenCharacterSheet = class("OpenCharacterSheet", Class_TutorialBase);

-- @param data: type STRUCT_ItemContainer
function Class_OpenCharacterSheet:OnBegin(data)
	local key = TutorialHelper:GetCharacterBinding();
	self:ShowScreenTutorial(formatStr(string.format(NPE_OPENCHARACTERSHEET, key)));

	if (CharacterFrame:IsVisible()) then
		self:Complete(data);
	else
		Dispatcher:RegisterScript(CharacterFrame, "OnShow", function() self:Complete(data) end, true);
	end
end

-- @param data: type STRUCT_ItemContainer
function Class_OpenCharacterSheet:OnComplete(data)
	Tutorials.HighlightEquippedItem:ForceBegin(data);
	Tutorials.CloseCharacterSheet:Begin(data);
end


-- ------------------------------------------------------------------------------------------------------------
-- Highlight Equipped Item
-- Called when the player recieves their first item upgrade after they open their bags
-- Sequence: Show Bags - Equip Item - Open Character Sheet - [Highlight Equipped Item] - Close Character Sheet
-- ------------------------------------------------------------------------------------------------------------
local Class_HighlightEquippedItem = class("HighlightEquippedItem", Class_TutorialBase);

-- @param data: type STRUCT_ItemContainer
function Class_HighlightEquippedItem:OnBegin(data)
	local Slot = {
		[1]	 = "CharacterHeadSlot",
		[2]	 = "CharacterNeckSlot",
		[3]	 = "CharacterShoulderSlot",
		[4]	 = "CharacterShirtSlot",
		[5]	 = "CharacterChestSlot",
		[6]	 = "CharacterWaistSlot",
		[7]	 = "CharacterLegsSlot",
		[8]	 = "CharacterFeetSlot",
		[9]	 = "CharacterWristSlot",
		[10] = "CharacterHandsSlot",
		[11] = "CharacterFinger0Slot",
		[12] = "CharacterFinger0Slot",
		[13] = "CharacterTrinket0Slot",
		[14] = "CharacterTrinket1Slot",
		[15] = "CharacterBackSlot",
		[16] = "CharacterMainHandSlot",
		[17] = "CharacterSecondaryHandSlot",
	}

	local equippedItemFrame = _G[Slot[data.CharacterSlot]];

	self:ShowPointerTutorial(formatStr(NPE_EQUIPPEDITEM), "LEFT", equippedItemFrame);
	Dispatcher:RegisterScript(CharacterFrame, "OnHide", function() self:Complete() end, true)
end

-- ------------------------------------------------------------------------------------------------------------
-- Close Character Sheet
-- Prompts the player to close the character sheet if they haven't already done so
-- Sequence: Show Bags - Equip Item - Open Character Sheet - Highlight Equipped Item - [Close Character Sheet]
-- ------------------------------------------------------------------------------------------------------------
local Class_CloseCharacterSheet = class("CloseCharacterSheet", Class_TutorialBase);

function Class_CloseCharacterSheet:OnBegin()
	Dispatcher:RegisterScript(CharacterFrame, "OnHide", function() self:Complete() end, true);

	self.Timer = C_Timer.NewTimer(20, function()
			self:ShowPointerTutorial(formatStr(NPE_CLOSECHARACTERSHEET), "LEFT", CharacterFrameCloseButton, -10);
		end);
end

function Class_CloseCharacterSheet:OnShutdown()
	self.Timer:Cancel();
end


















-- ============================================================================================================
-- LOOTING
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Loot Corpse Watcher
-- Keeps track of when a player as a mob they can kill
-- Every time the player enters combat, this starts watching the combat log.  When a UNIT_DIED event is heard
-- this checks to see if the player can loot that corpse.
--
-- The player is promted 3 times in a row to loot the corpse as well as the loot pane being called out the first time
-- If the player closes the loot window without actually looting the corpse, the prompts say up.
--
-- Once the player has successfully looted 3 times, this continues to track.
--		- If the player opens a loot window and then closes it without looting, they are re-prompted to loot the
--		  corpse and the pointer is re-invoked
--		- If they don't loot the corpse and get into combat two more times, they are prompted to loot again but
--		  the pointer is not re-invoked
-- ------------------------------------------------------------------------------------------------------------
local Class_LootCorpseWatcher = class("LootCorpseWatcher", Class_TutorialBase);

function Class_LootCorpseWatcher:OnInitialize()
	self.LootCount = 0;
	self.RePromptLootCount = 0;
	self.PendingLoot = false;
	self._QuestMobs = {}; -- will hold the UnitID for the mob to watch for
end

function Class_LootCorpseWatcher:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self);
end

function Class_LootCorpseWatcher:WatchQuestMob(unitID)
	if (type(unitID) == "table") then
		for i, id in ipairs(unitID) do
			self._QuestMobs[id] = false;
		end
	else
		self._QuestMobs[unitID] = false;
	end
end

function Class_LootCorpseWatcher:LootSuccessful(unitID)
	-- Handle quest mobs
	if (self._QuestMobs[unitID] ~= nil) then
		self._QuestMobs[unitID] = true;
	end

	self.LootCount = self.LootCount + 1;
	self.PendingLoot = false;
	self.RePromptLootCount = 0;

	Dispatcher:UnregisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:UnregisterEvent("CHAT_MSG_MONEY", self);
end

function Class_LootCorpseWatcher:CHAT_MSG_LOOT(...)
	self:LootSuccessful();
end

function Class_LootCorpseWatcher:CHAT_MSG_MONEY(...)
	self:LootSuccessful();
end

-- Entering Combat
function Class_LootCorpseWatcher:PLAYER_REGEN_DISABLED(...)
	self:SuppressChildren();
	Dispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
end

-- Leaving Combat
function Class_LootCorpseWatcher:PLAYER_REGEN_ENABLED(...)
	self:UnsuppressChildren();
	Dispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self);
end

-- Watch for units dying while in combat.  if that happened, check the unit to see if the
-- player can loot it and if so, prompt the player to loot
function Class_LootCorpseWatcher:COMBAT_LOG_EVENT_UNFILTERED(timestamp, logEvent)
	local eventData = {CombatLogGetCurrentEventInfo()};
	local logEvent = eventData[2];
	local unitGUID = eventData[8];
	if ((logEvent == "UNIT_DIED") or (logEvent == "UNIT_DESTROYED")) then
		-- Wait for mirror data
		C_Timer.After(1, function()
				if CanLootUnit(unitGUID) then
					self:UnitLootable(unitGUID);
				end
			end);
	end
end

function Class_LootCorpseWatcher:UnitLootable(unitGUID)

	local unitID = tonumber(string.match(unitGUID, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
	for id, hasKilled in pairs(self._QuestMobs) do
		if ((unitID == id) and (not hasKilled)) then
			Tutorials.LootCorpse:ForceBegin(unitID);
			return;
		end
	end

	-- if the player hasn't looted their last mob increment the reprompt threshold
	if (self.PendingLoot) then
		self.RePromptLootCount = self.RePromptLootCount + 1;
	end

	self.PendingLoot = true;

	if ((self.LootCount < 3) or (self.RePromptLootCount >= 2)) then
		Tutorials.LootCorpse:Begin();
	else
		-- These are so we can silently watch for people missing looting without a prompt.
		-- If they are prompted, the prompt tutorial (LootCorpse) manages this.
		Dispatcher:RegisterEvent("CHAT_MSG_LOOT", self);
		Dispatcher:RegisterEvent("CHAT_MSG_MONEY", self);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Loot corpse
-- Prompt the user to loot a coprpse.  Is only successful when the player closes the window and the unit is no
-- longer lootable.  If the window is closed and is still lootable, the pointer is re-invoked
-- ------------------------------------------------------------------------------------------------------------
local Class_LootCorpse = class("LootCorpse", Class_TutorialBase);

function Class_LootCorpse:OnInitialize()
	self.ShowPointer = true;
	self.QuestMobCount = 0;
end

function Class_LootCorpse:OnBegin(questMobID)
	if (Tutorials.QuestCompleteOpenMap.IsActive) then
		self:Interrupt(Tutorials.QuestCompleteOpenMap);
		return;
	end

	if (questMobID) then
		if (self.QuestMobCount >= 2) then
			self:Interrupt(self);
			return;
		end
		self.QuestMobID = questMobID;
	else
		self.QuestMobID = nil;
	end

	self:Display();

	Dispatcher:RegisterEvent("LOOT_CLOSED", self);
	Dispatcher:RegisterEvent("CHAT_MSG_LOOT", self);
	Dispatcher:RegisterEvent("CHAT_MSG_MONEY", self);

	if (self.ShowPointer) then
		Tutorials.LootPointer:Begin();
	end
end

function Class_LootCorpse:CHAT_MSG_LOOT(...)
	self:Complete();
end

function Class_LootCorpse:CHAT_MSG_MONEY(...)
	self:Complete();
end

function Class_LootCorpse:LOOT_CLOSED(...)
	Tutorials.LootPointer:Begin();
end

function Class_LootCorpse:OnSuppressed()
	self:HideScreenTutorial();
end

function Class_LootCorpse:OnUnsuppressed()
	self:Display();
end

function Class_LootCorpse:Display()
	local prompt = formatStr(NPE_LOOTCORPSE);

	if (self.QuestMobID) then
		prompt = formatStr(NPE_LOOTCORPSEQUEST);
	end

	self:ShowScreenTutorial(prompt);
end

function Class_LootCorpse:OnComplete()
	Tutorials.LootPointer:Complete();

	if (self.QuestMobID) then
		self.QuestMobCount = self.QuestMobCount + 1;
	end

	Tutorials.LootCorpseWatcher:LootSuccessful(self.QuestMobID);
	self.ShowPointer = false;
end

-- ------------------------------------------------------------------------------------------------------------
-- Loot Pointer
-- Prompts how to use the loot window the first time
-- This is managed and completed by LootCorpse
-- ------------------------------------------------------------------------------------------------------------
local Class_LootPointer = class("LootPointer", Class_TutorialBase);

function Class_LootPointer:OnBegin()
	Dispatcher:RegisterEvent("LOOT_OPENED", self);
end

function Class_LootPointer:LOOT_OPENED()
	local btn = LootButton1;
	if (btn) then
		self:ShowPointerTutorial(formatStr(NPE_CLICKLOOT), "RIGHT", btn);
	end
end




















-- ============================================================================================================
-- Player Death
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
local Class_Death_Watcher = class("Death_Watcher", Class_TutorialBase);

function Class_Death_Watcher:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
end

function Class_Death_Watcher:PLAYER_DEAD()
	Tutorials.Death_ReleaseCorpse:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: [Relesase Corpse] - Map Prompt - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
local Class_Death_ReleaseCorpse = class("Death_ReleaseCorpse", Class_TutorialBase);

function Class_Death_ReleaseCorpse:OnBegin()
	self:ShowPointerTutorial(formatStr(NPE_RELEASESPIRIT), "LEFT", StaticPopup1);
	Dispatcher:RegisterEvent("PLAYER_ALIVE", self);
end

-- PLAYER_ALIVE gets called when the player releases, not when they get back to their corpse
function Class_Death_ReleaseCorpse:PLAYER_ALIVE()
	self:Complete();
end

function Class_Death_ReleaseCorpse:OnComplete()
	if (UnitIsGhost("player")) then
		Tutorials.Death_MapPrompt:Begin();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - [Map Prompt] - Resurrect Prompt
-- ------------------------------------------------------------------------------------------------------------
local Class_Death_MapPrompt = class("Death_MapPrompt", Class_TutorialBase);

function Class_Death_MapPrompt:OnBegin()
	local key = TutorialHelper:GetMapBinding();
	self:ShowScreenTutorial(formatStr(string.format(NPE_FINDCORPSE, key)));
	Dispatcher:RegisterEvent("CORPSE_IN_RANGE", self);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_MapPrompt:PLAYER_UNGHOST()
	self:Interrupt(self);
end

function Class_Death_MapPrompt:CORPSE_IN_RANGE()
	self:Complete();
end

function Class_Death_MapPrompt:OnComplete()
	Tutorials.Death_ResurrectPrompt:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Sequence: Relesase Corpse - Map Prompt - [Resurrect Prompt]
-- ------------------------------------------------------------------------------------------------------------
local Class_Death_ResurrectPrompt = class("Death_ResurrectPrompt", Class_TutorialBase);

function Class_Death_ResurrectPrompt:OnBegin()
	self:ShowPointerTutorial(formatStr(NPE_RESURRECT), "UP", StaticPopup1);
	Dispatcher:RegisterEvent("PLAYER_UNGHOST", self);
end

function Class_Death_ResurrectPrompt:PLAYER_UNGHOST()
	self:Complete();
end




















-- -- ============================================================================================================
-- -- QUESTS
-- -- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Quest Complete - Open Map
-- Propmpt the player to open the map when they complete a quest
-- ------------------------------------------------------------------------------------------------------------
local Class_QuestCompleteOpenMap = class("QuestCompleteOpenMap", Class_TutorialBase);

function Class_QuestCompleteOpenMap:OnInitialize()
	self:SetMaxLevel(3);
	self:DelayWhileFrameVisible(QuestFrame);
end

-- @param questData: Class QuestData (QuestManager.lua)
function Class_QuestCompleteOpenMap:OnBegin(questData)
	-- Use hearthstone on quest start will cause this appear at the same time
	if (Tutorials.UseHearthstone.IsActive) then
		self:Interrupt(Tutorials.UseHearthstone);
	end

	self.QuestData = questData;

	-- Kill the loot corpse tutorial if it's up.
	Tutorials.LootCorpse:Interrupt(self);

	local key = TutorialHelper:GetMapBinding();

	local prompt = formatStr(string.format(NPE_QUESTCOMPLETE, key));

	-- If the quest took less than one second to complete, it was most likely a breadcurmb quest.
	if (questData:GetActiveTime() < 1) then
		prompt = formatStr(string.format(NPE_QUESTCOMPLETEBREADCRUMB, key));
	end

	self:ShowScreenTutorial(prompt);
	Dispatcher:RegisterScript(WorldMapFrame, "OnShow", self);
end

-- This is not inlined because it needs to be unregistered if the tutorial gets interrupted.
function Class_QuestCompleteOpenMap:OnShow()
	self:Complete(self.QuestData);
end

function Class_QuestCompleteOpenMap:OnComplete(questData)
	Tutorials.ShowMapQuestTurnIn:Begin(questData);
end

-- ------------------------------------------------------------------------------------------------------------
-- Show Map Quest Turn In
-- When the user clicks on a spell in the presentation frame
-- Open their spellbook and point to the item
-- ------------------------------------------------------------------------------------------------------------
local Class_ShowMapQuestTurnIn = class("ShowMapQuestTurnIn", Class_TutorialBase);

-- @param questData: Class QuestData (QuestManager.lua)
function Class_ShowMapQuestTurnIn:OnBegin(questData)
	-- This should no longer ever happen, but it's a good safety check anyway.
	if (not questData) then
		self:Interrupt(self);
		return;
	end

	self.QuestData = questData;
	self.MapProvider = MapBridgeDataProviderMixin:New();

	self.MapProvider:SetOnMapChangedCallback(function()
			self:Display();
		end);

	self:Display();
	Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() self:Complete(); end, true);
end

function Class_ShowMapQuestTurnIn:Display()
	-- Make sure we're on the correct map
	local currentMap = self.MapProvider:GetMap():GetMapID();
	local desiredMap = self.QuestData:GetTurnInMapID();

	local poiButton;

	-- Get the PoI Pin from the map map
	if (currentMap == desiredMap) then
		for pin in self.MapProvider:GetMap():EnumeratePinsByTemplate("QuestPinTemplate") do
			if (pin.questID == self.QuestData.QuestID) then
				poiButton = pin;
			end
		end
	end

	if (poiButton) then
		local direction = "LEFT";
		local _, posX, posY = QuestPOIGetIconInfo(self.QuestData.QuestID);
		if (posX and (posX > 0.5)) then -- sometimes QuestPOIGetIconInfo returns nil;
			direction = "RIGHT";
		end

		self:ShowPointerTutorial(formatStr(NPE_QUESTCOMPELTELOCATION), direction, poiButton);
		Tutorials.SelectQuestDifferentZone:Complete();
	else
		Tutorials.SelectQuestDifferentZone:ForceBegin(self.QuestData);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Select quest for different zone
-- If the player is prompted to open the map to find the quest turn-in and it's not on the current map
-- prompt the player to click on the quest to select the correct map.
-- ------------------------------------------------------------------------------------------------------------
local Class_SelectQuestDifferentZone = class("SelectQuestDifferentZone", Class_TutorialBase);
function Class_SelectQuestDifferentZone:OnBegin(questData)
	self.QuestData = questData;

	-- Have to delay by one frame because the quest log doesn't update before this code runs which causes the frame pool to be out of sync
	C_Timer.After(0, function() self:Display(); end);
end

function Class_SelectQuestDifferentZone:Display()
	Dispatcher:RegisterScript(WorldMapFrame, "OnHide", function() self:Complete(); end, true);

	if (QuestMapFrame.DetailsFrame:IsVisible()) then
		return;
	end

	local found;
	if (self.QuestData) then
		-- Find the correct quest to point at
		for frame, v in QuestScrollFrame.titleFramePool:EnumerateActive() do
			if (frame.questID == self.QuestData.QuestID) then
				found = true;
				self:ShowPointerTutorial(formatStr(NPE_TURNINNOTONMAP), "LEFT", frame, 0, 0, "RIGHT");
				break;
			end
		end
	end

	if (not found) then
		self:ShowPointerTutorial(formatStr(NPE_TURNINNOTONMAP_QUESTFRAMENOTFOUND), "LEFT", QuestScrollFrame, -20, 0, "RIGHT");
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Accept more quests
-- Invoked after accepting certain quests that have other nearby* quest givers
-- *the data for this is all hard-coded
-- ------------------------------------------------------------------------------------------------------------
local Class_AcceptMoreQuests = class("AcceptMoreQuests", Class_TutorialBase);

function Class_AcceptMoreQuests:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_AcceptMoreQuests:OnBegin(questBundle)
	if (type(questBundle) ~= "table") then
		self:DebugLog("OnBegin failed, no questBundle passed");
		self:Interrupt(self);
		return;
	end

	self.Bundle = questBundle;
	self:ShowScreenTutorial(formatStr(NPE_MOREQUESTS), nil, NPE_TutorialMainFrame.FramePositions.Low)
end

function Class_AcceptMoreQuests:QuestAccepted(questID)
	if (not TutorialHelper:DoQuestsInBundleNeedPickup(self.Bundle)) then
		self:Complete();
	end
end


-- ------------------------------------------------------------------------------------------------------------
-- Accept Quest Watcher
-- Watches for a new quest window to pop up that is ready to be accepted
-- ------------------------------------------------------------------------------------------------------------
local Class_AcceptQuestWatcher = class("AcceptQuestWatcher", Class_TutorialBase);

function Class_AcceptQuestWatcher:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_AcceptQuestWatcher:OnBegin()
	Dispatcher:RegisterScript(QuestFrameAcceptButton, "OnShow", self);
end

function Class_AcceptQuestWatcher:OnShow()
	Tutorials.AcceptQuest:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Accept Quest
-- Always prompts the player to accept a quest when the window is up
-- ------------------------------------------------------------------------------------------------------------
local Class_AcceptQuest = class("AcceptQuest", Class_TutorialBase);

function Class_AcceptQuest:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_AcceptQuest:OnBegin()
	self:ShowPointerTutorial(formatStr(NPE_ACCEPTQUEST), "UP", QuestFrameAcceptButton, 0, 10, nil, "LEFT");
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:Complete(); end, true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Turn in Quest Watcher
-- Watches for a quest turn in window
-- ------------------------------------------------------------------------------------------------------------
local Class_TurnInQuestWatcher = class("TurnInQuestWatcher", Class_TutorialBase);

function Class_TurnInQuestWatcher:OnBegin()
	Dispatcher:RegisterEvent("QUEST_COMPLETE", self);
end

function Class_TurnInQuestWatcher:QUEST_COMPLETE()
	Tutorials.TurnInQuest:Begin();

	local areAllItemsUsable = true;

	-- Figure out if all the items are usable
	local questID = GetQuestID();
	C_QuestLog.SetSelectedQuest(questID);
	for i = 1, GetNumQuestLogChoices(questID) do
		local isUsable = select(5, GetQuestLogChoiceInfo(i));
		if (not isUsable) then
			areAllItemsUsable = false;
			break;
		end
	end

	if (GetNumQuestChoices() > 1) then
		-- Wait one frame to make sure the reward buttons have been positioned
		C_Timer.After(0.01, function() Tutorials.QuestRewardChoice:Begin(areAllItemsUsable); end);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Turn in Quest
-- Always prompts the player to turn in a quest when available
-- ------------------------------------------------------------------------------------------------------------
local Class_TurnInQuest = class("TurnInQuest", Class_TutorialBase);

function Class_TurnInQuest:OnInitialize()
	self:SetMaxLevel(4);
end

function Class_TurnInQuest:OnBegin()
	self:ShowPointerTutorial(formatStr(NPE_TURNINQUEST), "UP", QuestFrameCompleteQuestButton, 0, 10);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:Complete() end, true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Quest Reward Choice
-- Prompts the player to click on a reward item to select one
-- ------------------------------------------------------------------------------------------------------------
local Class_QuestRewardChoice = class("QuestRewardChoice", Class_TutorialBase);

function Class_QuestRewardChoice:OnBegin(areAllItemsUsable)
	local prompt = formatStr(NPE_QUESTREWARDCHOICE);

	if (not areAllItemsUsable) then
		prompt = formatStr(NPE_QUESTREWARDCHOCIEREDITEMS) .. prompt;
	end

	local yOffset;

	local button = QuestInfoRewardsFrameQuestInfoItem1;
	if (button) then
		_, yOffset = TutorialHelper:GetFrameButtonEdgeOffset(QuestFrame, button);
	end

	if (yOffset) then
		self:ShowPointerTutorial(prompt, "LEFT", QuestFrame, -15, yOffset, "TOPRIGHT");
	else
		self:ShowPointerTutorial(prompt, "LEFT", QuestFrame, -15, 0);
	end

	Dispatcher:RegisterEvent("QUEST_TURNED_IN", function() self:Complete() end, true);
	Dispatcher:RegisterScript(QuestFrame, "OnHide", function() self:Interrupt(self) end, true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Use Quest Item
-- When the player gets a quest that has them use an item, this points to the item in the super tracker when
-- they get near a unit.  Initiated by UseQuestItemWatcher
-- ------------------------------------------------------------------------------------------------------------
local Class_UseQuestItem = class("UseQuestItem", Class_TutorialBase);

function Class_UseQuestItem:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

-- @param data: the table from RacialData.lua that contains all the information about the quest, target, item and spell
function Class_UseQuestItem:OnBegin(data)
	self.Data = data;

	local module = QUEST_TRACKER_MODULE:GetBlock(data.QuestID)
	if (module and module.itemButton) then
		self:ShowPointerTutorial(formatStr(NPE_USEQUESTITEM), "UP", module.itemButton);

		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
	end
end

function Class_UseQuestItem:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, spellRank, spellLineID, spellID)
	if (unit ~= "player") then return; end

	if (self.Data.SpellID == spellID) then
		self:Complete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Use Quest Object
-- When the player gets a quest that has them use an object in the world, this prompts them when they get near
-- ------------------------------------------------------------------------------------------------------------
local Class_UseQuestObject = class("UseQuestObject", Class_TutorialBase);

function Class_UseQuestObject:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_QUESTOBJECT));
	C_Timer.After(10, function() self:Complete() end);
end

-- ------------------------------------------------------------------------------------------------------------
-- NPC Interact Quest
-- When the player gets a quest that has them interact with an NPC, this prompts them when they get near
-- ------------------------------------------------------------------------------------------------------------
local Class_NPCInteractQuest = class("NPCInteractQuest", Class_TutorialBase);

function Class_NPCInteractQuest:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_NPCINTERACT));
	C_Timer.After(10, function() self:Complete() end);
end

-- ------------------------------------------------------------------------------------------------------------
-- Loot From Object
-- When the player gets near an object that they need to loot to get a quest item (such as a chest or barrel)
-- this calls it out
-- ------------------------------------------------------------------------------------------------------------
local Class_LootFromObject = class("LootFromObject", Class_TutorialBase);

function Class_LootFromObject:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_OBJECTLOOT), 20);
	Dispatcher:RegisterEvent("CHAT_MSG_LOOT", function() self:Complete() end, true);
end




















-- ============================================================================================================
-- ABILITY USAGE
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Ability Use Watcher
-- Keeps track of you using your abilities and warns you when you're not doing it right.
-- ------------------------------------------------------------------------------------------------------------
local Class_AbilityUse_Watcher = class("AbilityUse_Watcher", Class_TutorialBase);

function Class_AbilityUse_Watcher:OnBegin()
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", self);
	Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self); -- Entering combat
	Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", self); -- Leaving combat
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

	self.CombatTimeWithNoAbility = 0;
end

function Class_AbilityUse_Watcher:UNIT_SPELLCAST_INTERRUPTED(unit, spellName, spellRank, spellLine, spellID)
	if ((unit == "player") and IsPlayerMoving()) then
		Tutorials.AbilityUse_SpellInterrupted:Begin();
	end
end

function Class_AbilityUse_Watcher:OnUpdate(elapsed)
	self.CombatTimeWithNoAbility = self.CombatTimeWithNoAbility + elapsed;

	if (self.CombatTimeWithNoAbility >= 20) then
		Tutorials.AbilityUse_AbilityReminder:Begin();
		Dispatcher:UnregisterEvent("OnUpdate", self);
	end
end

-- Entering combat
function Class_AbilityUse_Watcher:PLAYER_REGEN_DISABLED()
	Dispatcher:RegisterEvent("OnUpdate", self);
end

-- Leaving combat
function Class_AbilityUse_Watcher:PLAYER_REGEN_ENABLED()
	Dispatcher:UnregisterEvent("OnUpdate", self);
end

function Class_AbilityUse_Watcher:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if (unit == "player") then
		local desiredSpellID = TutorialHelper:FilterByClass(TutorialData.StartingAbility);
		if (spellID == desiredSpellID) then
			-- Anytime the player uses the correct ability, clear out the timer.
			self.CombatTimeWithNoAbility = 0;
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Spell Interrupted
-- Keeps track of you using your abilities and warns you when you're not doing it right.
-- ------------------------------------------------------------------------------------------------------------
local Class_AbilityUse_SpellInterrupted = class("AbilityUse_SpellInterrupted", Class_TutorialBase);

function Class_AbilityUse_SpellInterrupted:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_MOVEMENTCANCELSSPELL), 5);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_START", function() self:Complete() end, true);
end

-- ------------------------------------------------------------------------------------------------------------
-- Ability Reminder
-- Keeps track of you using your abilities and warns you when you're not doing it right.
-- ------------------------------------------------------------------------------------------------------------
local Class_AbilityUse_AbilityReminder = class("AbilityUse_AbilityReminder", Class_TutorialBase);

function Class_AbilityUse_AbilityReminder:OnInitialize()
	self:SetMaxLevel(3);
end

function Class_AbilityUse_AbilityReminder:OnBegin()
	if (Tutorials.ActionBarCallout.IsActive) then
		self:Interrupt(Tutorials.ActionBarCallout);
		return;
	end

	self.SpellID = TutorialHelper:FilterByClass(TutorialData.StartingAbility);
	local btn = TutorialHelper:GetActionButtonBySpellID(self.SpellID);
	if (btn) then
		local name, _, icon = GetSpellInfo(self.SpellID);
		local prompt = formatStr(TutorialHelper:GetClassString("NPE_ABILITYREMINDER"));
		self:ShowPointerTutorial(string.format(prompt, name, icon), "DOWN", btn);

		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);

		-- Tutorial completes 7 seconds after exiting combat.
		if (UnitAffectingCombat("player")) then
			Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", function()
					C_Timer.After(7, function() self:Complete(); end);
				end, true);
		else
			C_Timer.After(7, function() self:Complete(); end);
		end
	else
		-- This should never happen unless the player managed to remove the ability from their aciton bar.
		self:Interrupt(self);
	end
end

function Class_AbilityUse_AbilityReminder:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if ((unit == "player") and (spellID == self.SpellID)) then
		self:Complete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Level 3 ability
-- ------------------------------------------------------------------------------------------------------------
local Class_Level3Ability = class("Level3Ability", Class_TutorialBase);

function Class_Level3Ability:OnBegin()
	Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
end

function Class_Level3Ability:PLAYER_LEVEL_UP(newLevel)
	if (newLevel == 3) then
		Dispatcher:UnregisterEvent("PLAYER_LEVEL_UP", self);
		Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", self);
	end
end

function Class_Level3Ability:PLAYER_REGEN_DISABLED()
	local spellID = TutorialHelper:FilterByClass(TutorialData.Level3Ability);
	local btn = TutorialHelper:GetActionButtonBySpellID(spellID);
	if (btn) then
		local prompt = formatStr(TutorialHelper:GetClassString("NPE_ABILITYLEVEL3"));
		self:ShowPointerTutorial(prompt, "DOWN", btn);

		if (UnitAffectingCombat("player")) then
			Dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED", function()
					C_Timer.After(10, function() self:Complete(); end);
				end, true);
		else
			C_Timer.After(10, function() self:Complete(); end);
		end
	end
end




















-- ============================================================================================================
-- GOSSIP
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Gossip Watcher
-- Watches the gossip frame for things the player should be clicking on
-- ------------------------------------------------------------------------------------------------------------
local Class_GossipWatcher = class("GossipWatcher", Class_TutorialBase);

function Class_GossipWatcher:OnBegin()
	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
end

function Class_GossipWatcher:GOSSIP_SHOW()
	local numActiveQuests = C_GossipInfo.GetNumActiveQuests(); -- (?) quests ready to turn in
	local numAvailabelQuests = C_GossipInfo.GetNumAvailableQuests(); -- (!) quests available to pick up
	local shouldBind = TutorialHelper:GetGossipBindIndex() and (GetBindLocation() ~= GetMinimapZoneText());

	if ((numActiveQuests + numAvailabelQuests) > 0) then
		-- highest priority are quests
		Tutorials.GossipQuestPointer:Begin();

		-- if there is a quest to turn in but this is the innkeeper, then queue up the bind screen prompt
		if (shouldBind) then
			Dispatcher:RegisterEvent("GOSSIP_CLOSED", function()
					-- yay hacks...
					-- The gossipBindPrompt is actually delayed by the questFrame,
					-- but the questFrame isn't actually visible at the moemnt GOSSIP_CLOSED happens,
					-- so delaying it by a second solves this edge case.
					C_Timer.After(1, function()
							Tutorials.GossipBindPrompt:Begin();
						end);
				end, true);
		end
	elseif (shouldBind) then
		-- second highest pirority is the bind prompt
		Tutorials.GossipBindPointer:Begin();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Gossip Pointer
-- Point to the correct quest line to click on when there are quests to turn in or accept
-- ------------------------------------------------------------------------------------------------------------
local Class_GossipQuestPointer = class("GossipQuestPointer", Class_TutorialBase);

function Class_GossipQuestPointer:OnBegin()
	Tutorials.GossipBindPrompt:Interrupt(self);

	Dispatcher:RegisterEvent("GOSSIP_CLOSED", function() self:Complete() end, true);

	local numActiveQuests = C_GossipInfo.GetNumActiveQuests(); -- (?) quests ready to turn in
	local numAvailabelQuests = C_GossipInfo.GetNumAvailableQuests(); -- (!) quests available to pick up

	local questText;
	local pointerText;

	local gossipQuests = C_GossipInfo.GetActiveQuests();
	if ((numActiveQuests > 0) and (gossipQuests[1].isComplete)) then
		questText = gossipQuests[1].title;
		pointerText = formatStr(NPE_GOSSIPQUESTACTIVE);
	elseif (numAvailabelQuests > 0) then
		questText =	gossipQuests[1].title;
		pointerText	 = formatStr(NPE_GOSSIPQUESTAVAILABLE);
	end

	local button;

	-- Try to find the actual gossip button
	if (questText) then
		for i=1, GossipFrame_GetTitleButtonCount() do
			local btn = GossipFrame_GetTitleButton(i);
			if (btn) then
				local text = btn:GetText();
				if (text and string.match(text, questText)) then
					button = btn;
					break;
				end
			end
		end

		if (button) then
			local x, y = TutorialHelper:GetFrameButtonEdgeOffset(GossipFrame, button);
			self:ShowPointerTutorial(pointerText, "LEFT", GossipFrame, x, y, "TOPRIGHT");
		end
	end

end

-- ------------------------------------------------------------------------------------------------------------
-- Gossip Bind Pointer
-- Points out the heartstone bind option
-- ------------------------------------------------------------------------------------------------------------
local Class_GossipBindPrompt = class("GossipBindPrompt", Class_TutorialBase);

function Class_GossipBindPrompt:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_GossipBindPrompt:OnBegin()
	self:ShowScreenTutorial(formatStr(NPE_BINDPROMPT));
end

-- ------------------------------------------------------------------------------------------------------------
-- Gossip Bind Pointer
-- Points out the heartstone bind option
-- ------------------------------------------------------------------------------------------------------------
local Class_GossipBindPointer = class("GossipBindPointer", Class_TutorialBase);

function Class_GossipBindPointer:OnBegin()
	Tutorials.GossipBindPrompt:Complete();

	-- TODO: Change this to the new PLAYER_BIND_CHANGED when it's available
	Dispatcher:RegisterEvent("GOSSIP_CLOSED", function() self:Complete() end, true);

	local bindButtonIndex = TutorialHelper:GetGossipBindIndex();

	if (bindButtonIndex) then
		-- offset the index by the first gossip button
		for i=1, GossipFrame_GetTitleButtonCount() do
			local btn = GossipFrame_GetTitleButton(i);
			if btn and btn.type == "Gossip" then
				bindButtonIndex = bindButtonIndex + (i - 1);
				break;
			end
		end

		local button = GossipFrame_GetTitleButton(bindButtonIndex);

		if button then
			local x, y = TutorialHelper:GetFrameButtonEdgeOffset(GossipFrame, button);

			self:ShowPointerTutorial(formatStr(NPE_BINDPOINTER), "LEFT", GossipFrame, x, y, "TOPRIGHT");
		else
			self:Interrupt(self);
		end
	end
end

function Class_GossipBindPointer:OnComplete()
	NewPlayerExperience:RegisterComplete();
end

-- ------------------------------------------------------------------------------------------------------------
-- Interact Then Gossip A
-- for quests where you need to talk to an NPC, then click on a gossip item
-- ------------------------------------------------------------------------------------------------------------
local Class_InteractThenGossipA = class("InteractThenGossipA", Class_TutorialBase);

function Class_InteractThenGossipA:OnBegin(data)
	self:ShowScreenTutorial(formatStr(NPE_NPCINTERACT));
	Dispatcher:RegisterEvent("GOSSIP_SHOW", function()
			local btn = GossipFrame_GetTitleButton(1);
			if (btn and btn:IsVisible()) then
				self:Complete();
			end
		end);
end

function Class_InteractThenGossipA:OnComplete()
	Tutorials.InteractThenGossipB:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
-- Interact Then Gossip B
-- for quests where you need to talk to an NPC, then click on a gossip item
-- ------------------------------------------------------------------------------------------------------------
local Class_InteractThenGossipB = class("InteractThenGossipB", Class_TutorialBase);

function Class_InteractThenGossipB:OnBegin()
	self:PointAtButton();

	Dispatcher:RegisterEvent("GOSSIP_SHOW", self);
	Dispatcher:RegisterEvent("GOSSIP_CLOSED", function() self:Complete() end, true);
end

function Class_InteractThenGossipB:GOSSIP_SHOW()
	self:PointAtButton();
end

function Class_InteractThenGossipB:PointAtButton()
	local btn = GossipFrame_GetTitleButton(1);
	if btn and btn:IsVisible() then
		local x, y = TutorialHelper:GetFrameButtonEdgeOffset(GossipFrame, btn);
		self:ShowPointerTutorial(formatStr(NPE_NPCGOSSIP), "LEFT", GossipFrame, x, y, "TOPRIGHT");
	end
end




















-- ============================================================================================================
-- MISC
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Highlight Item
-- When the user clicks on an item upgrade in the presentation frame
-- Open their bags and point to the item until mouseover
-- ------------------------------------------------------------------------------------------------------------
local Class_HighlightItem = class("HighlightItem", Class_TutorialBase);

-- @param data: type STRUCT_ItemContainer
function Class_HighlightItem:OnBegin(data)

	-- Reopen all the bags to guarentee container order
	TutorialHelper:CloseAllBags();
	ToggleAllBags();

	self.itemFrame = TutorialHelper:GetItemContainerFrame(data.Container, data.ContainerSlot);
	if (self.itemFrame) then
		self:ShowPointerTutorial(formatStr(NPE_EQUIPITEM), "DOWN", self.itemFrame, 0, 15);

		Dispatcher:RegisterFunction("ContainerFrameItemButton_OnEnter", self);
		Dispatcher:RegisterFunction("ContainerFrame_Update", self, true);
	end
end

function Class_HighlightItem:ContainerFrameItemButton_OnEnter(frame)
	if (frame == self.itemFrame) then
		self:Complete();
	end
end

function Class_HighlightItem:ContainerFrame_Update()
	self:Interrupt();
end

-- ------------------------------------------------------------------------------------------------------------
-- Taxi
-- Displayed the first time the player opens the taxi map
-- ------------------------------------------------------------------------------------------------------------
local Class_Taxi = class("Taxi", Class_TutorialBase);

function Class_Taxi:OnBegin()
	Dispatcher:RegisterEvent("TAXIMAP_OPENED", self);
	Dispatcher:RegisterEvent("TAXIMAP_CLOSED", self);
end

function Class_Taxi:TAXIMAP_OPENED(uiMapSystem)
	local frame = FlightMapFrame.ScrollContainer;
	if uiMapSystem == Enum.UIMapSystem.Taxi then
		frame = TaxiRouteMap;
	end
	self:ShowPointerTutorial(formatStr(NPE_TAXICALLOUT), "LEFT", frame, -10, 0);
end

function Class_Taxi:TAXIMAP_CLOSED()
	self:Complete();
end

-- ------------------------------------------------------------------------------------------------------------
-- Use Hearthstone
-- Prompts the player to use their hearthstone
-- ------------------------------------------------------------------------------------------------------------
local Class_UseHearthstone = class("UseHearthstone", Class_TutorialBase);

function Class_UseHearthstone:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_UseHearthstone:OnBegin()
	Tutorials.EquipItem:Interrupt(self);

	self:ShowScreenTutorial(formatStr(NPE_USEHEARTHSTONE), 60);
	Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self);
end

function Class_UseHearthstone:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
	if ((unitID == "player") and (spellID == 8690)) then
		self:Complete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Chat Frame
-- Prompts the player if they open the chat frame.  also auto closes it if it sits open for a while
-- ------------------------------------------------------------------------------------------------------------
local Class_ChatFrame = class("ChatFrame", Class_TutorialBase);

function Class_ChatFrame:OnInitialize()
	self.ShowCount = 0;
end

function Class_ChatFrame:OnBegin(editBox)
	if (editBox) then
		self.EditBox = editBox;
		self.ShowCount = self.ShowCount + 1;

		if (self.ShowCount == 1) then
			self:ShowPointerTutorial(formatStr(NPE_CHATFRAME), "LEFT", editBox);
		end

		self.Elapsed = 0;
		Dispatcher:RegisterEvent("OnUpdate", self);
		Dispatcher:RegisterFunction("ChatEdit_DeactivateChat", function() self:Complete() end, true);
	end
end

function Class_ChatFrame:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed;

	if (self.Elapsed > 30) then
		if (self.EditBox) then
			ChatEdit_DeactivateChat(self.EditBox);
		end
		self:Interrupt(self);
	end
end

function Class_ChatFrame:OnShutdown()
	self.EditBox = nil;
end




















-- ============================================================================================================
-- CUSTOM
-- These are one-off per-race custom tutorials
-- ============================================================================================================

-- ------------------------------------------------------------------------------------------------------------
-- Draenei - Gift of the Naaru
-- Quest 9283: Rescue the Survivors!
-- ------------------------------------------------------------------------------------------------------------
local Class_Dranei_9283 = class("Dranei_9283", Class_TutorialBase);

function Class_Dranei_9283:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_Dranei_9283:OnBegin()
	local spells = { 59545, 59543, 59548, 121093, 59542, 59544, 59547, 28880 }

	local btn;
	for i = 1, #spells do
		local spellID = spells[i];
		btn = TutorialHelper:GetActionButtonBySpellID(spellID);
		if (btn) then
			self.SpellID = spellID;
			break;
		end
	end

	if (btn) then
		self:ShowPointerTutorial(formatStr(NPE_DRAENEIGIFTOFTHENARARU), "DOWN", btn);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self)
	end

end

function Class_Dranei_9283:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	 if ((unit == "player") and (spellID == self.SpellID)) then
	 	self:Complete();
	 end
end

-- ------------------------------------------------------------------------------------------------------------
-- Blood Elf - Arcane Torrent
-- Quest 8346: Thirst Unending!
-- ------------------------------------------------------------------------------------------------------------
local Class_BloodElf_8346 = class("BloodElf_8346", Class_TutorialBase);

function Class_BloodElf_8346:OnInitialize()
	self:DelayWhileFrameVisible(QuestFrame);
end

function Class_BloodElf_8346:OnBegin()
	local spells = { 129597, 25046, 80483, 155145, 28730, 69179, 50613 }

	local btn;
	for i = 1, #spells do
		local spellID = spells[i];
		btn = TutorialHelper:GetActionButtonBySpellID(spellID);
		if (btn) then
			self.SpellID = spellID;
			break;
		end
	end

	if (btn) then
		self:ShowPointerTutorial(formatStr(NPE_BLOODELFARCANETORRENT), "DOWN", btn);
		Dispatcher:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self)
	end

end

function Class_BloodElf_8346:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	 if ((unit == "player") and (spellID == self.SpellID)) then
	 	self:Complete();
	 end
end




















-- ============================================================================================================
-- TUTORIALS
-- ============================================================================================================
Tutorials = {};

-- ------------------------------------------------------------------------------------------------------------
-- Global / Initial tutorials
function Tutorials:Begin()
	Class_TutorialBase:GlobalEnable()

	-- Certain tutorials kick off when quests are accepted
	NPE_QuestManager:RegisterForCallbacks(self);
	-- NPE_QuestManager:SimulateEvents(self);

	-- --------------------------------------------------------------------
	-- Turn on specific tutorials
	local level = UnitLevel("player");

	local tutorialData = TutorialHelper:GetRacialData();
	if tutorialData then
		-- First Quest
		local startingQuest = TutorialHelper:FilterByClass(tutorialData.StartingQuest);
		if (not TutorialHelper:IsQuestCompleteOrActive(startingQuest)) then
			Tutorials.Intro_Interact:Begin();
		else -- things that have to happen if the into is skipped
			NPE_TutorialKeyboardMouseFrame:ShowHelpFrame()
		end
	end

	-- Callout what button to click on to accept a quest
 	Tutorials.AcceptQuestWatcher:Begin();

	-- Looting
	Tutorials.LootCorpseWatcher:Begin()
	if (level > 1) then
		-- if the player is returning after level 1, then start this tutorial off
		-- in the state where they are only reminded if they don't loot a corpse
		Tutorials.LootCorpseWatcher.LootCount = 3;
	end

	-- Player Death
	Tutorials.Death_Watcher:Begin()

	-- Quest Turn in
	Tutorials.TurnInQuestWatcher:Begin();

	-- Ability Use
	Tutorials.AbilityUse_Watcher:Begin();

	-- Taxi
	Tutorials.Taxi:Begin();

	-- Item Upgrades
	-- if the player comes back after level 4, don't prompt them on loot anymore
	if (level < 5) then
		Tutorials.EquipFirstItemWatcher:Begin();
	end

	-- Gossip
	Tutorials.GossipWatcher:Begin();

	-- Chat frame
	-- We don't want this active right off the bat.
	C_Timer.After(5, function()
			Dispatcher:RegisterFunction("ChatEdit_ActivateChat", function(editBox) Tutorials.ChatFrame:Begin(editBox) end);
		end);

	-- Level 3 ability
	if (level < 3) then
		Tutorials.Level3Ability:Begin();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Tutorials:Shutdown()
	Dispatcher:UnregisterAll(self);
	NPE_QuestManager:UnregisterForCallbacks(self);
	Class_TutorialBase:GlobalDisable();
end

-- ------------------------------------------------------------------------------------------------------------
function Tutorials:Quest_Accepted(questData)
	local tutorialData = TutorialHelper:GetRacialData();
	if not tutorialData then
		return;
	end
	local questID = questData.QuestID;

	-- -----------------------------------------------
	-- First kill quest
	local firstKillQuest = tutorialData.FirstKillQuest or tutorialData.StartingQuest;

	if (questID == TutorialHelper:FilterByClass(firstKillQuest)) then
		Tutorials.SelectMobWatcher:Begin();

		-- if they have a FirstKillQuest that is not the StartingQuest, re-prompt the map
		if (tutorialData.FirstKillQuest) then
			Tutorials.Intro_OpenMap:Begin();
		end
	end

	-- -----------------------------------------------
	-- Use Quest Object
		if (tutorialData.UseQuestObject) then
		for i, data in ipairs(tutorialData.UseQuestObject) do
			if (TutorialHelper:FilterByClass(data.QuestID) == questID) then

				local watchType = NPE_RangeManager.Type.Unit;
				if (data.ObjectID) then
					watchType = NPE_RangeManager.Type.Object;
				end

				NPE_RangeManager:StartWatching(
					data.UnitID or data.ObjectID,
					watchType,
					data.Range,
					function() Tutorials.UseQuestObject:Begin(data) end,
					data.Mode or NPE_RangeManager.Mode.Any,
					questID);
			end
		end
	end

	-- -----------------------------------------------
	-- Use Quest Item
	if (tutorialData.UseQuestItem) then
		for i, data in ipairs(tutorialData.UseQuestItem) do
			if (TutorialHelper:FilterByClass(data.QuestID) == questID) then

				local watchType = NPE_RangeManager.Type.Unit;
				if (data.ObjectID) then
					watchType = NPE_RangeManager.Type.Object;
				end

				NPE_RangeManager:StartWatching(
					data.UnitID or data.ObjectID,
					watchType,
					data.Range,
					function() Tutorials.UseQuestItem:Begin(data) end,
					data.Mode or NPE_RangeManager.Mode.Any,
					questID);
			end
		end
	end

	-- -----------------------------------------------
	-- Loot From Object
	if (tutorialData.LootFromObjectQuest) then
		for i, data in ipairs(tutorialData.LootFromObjectQuest) do
			if (TutorialHelper:FilterByClass(data.QuestID) == questID) then

				local watchType = NPE_RangeManager.Type.Unit;
				if (data.ObjectID) then
					watchType = NPE_RangeManager.Type.Object;
				end

				NPE_RangeManager:StartWatching(
					data.UnitID or data.ObjectID,
					watchType,
					data.Range,
					function() Tutorials.LootFromObject:Begin(data) end,
					data.Mode or NPE_RangeManager.Mode.All,
					questID);
			end
		end
	end

	-- -----------------------------------------------
	-- NPC Interact
	if (tutorialData.NPCInteractQuest) then
		for i, data in ipairs(tutorialData.NPCInteractQuest) do
			if (TutorialHelper:FilterByClass(data.QuestID) == questID) then

				local watchType = NPE_RangeManager.Type.Unit;
				if (data.ObjectID) then
					watchType = NPE_RangeManager.Type.Object;
				end

				NPE_RangeManager:StartWatching(
					data.UnitID or data.ObjectID,
					watchType,
					data.Range,
					function() Tutorials.NPCInteractQuest:Begin(data) end,
					data.Mode or NPE_RangeManager.Mode.Any,
					questID);
			end
		end
	end

	-- -----------------------------------------------
	-- NPC Interact then Gossip
	if (tutorialData.InteractThenGossipQuest) then
		for i, data in ipairs(tutorialData.InteractThenGossipQuest) do
			if (TutorialHelper:FilterByClass(data.QuestID) == questID) then
				NPE_RangeManager:StartWatching(
					data.UnitID,
					NPE_RangeManager.Type.Unit,
					data.Range,
					function() Tutorials.InteractThenGossipA:Begin(data); end,
					data.Mode or NPE_RangeManager.Mode.All,
					questID);
			end
		end
	end

	-- -----------------------------------------------
	-- Loot quest mob

	-- Single quest
	if ((tutorialData.LootQuest) and (tutorialData.LootQuest.QuestID == questID)) then
		Tutorials.LootCorpseWatcher:WatchQuestMob(tutorialData.LootQuest.UnitID);
	-- Multiple quests
	elseif (tutorialData.LootQuests) then
		for i, data in ipairs(tutorialData.LootQuests) do
			if (data.QuestID == questID) then
				Tutorials.LootCorpseWatcher:WatchQuestMob(data.UnitID);
			end
		end
	end

	-- -----------------------------------------------
	-- Bundled quests
	local bundle = TutorialHelper:GetBundleByQuestID(questID);
	if (bundle) then
		if (not Tutorials.AcceptMoreQuests.IsActive) then
			if (TutorialHelper:DoQuestsInBundleNeedPickup(bundle)) then
				Tutorials.AcceptMoreQuests:Begin(bundle);
			end
		else
			Tutorials.AcceptMoreQuests:QuestAccepted(questID);
		end
	end

	-- -----------------------------------------------
	-- Custom quests
	if (tutorialData.Custom_QuestAccept and tutorialData.Custom_QuestAccept[questID]) then
		local tutorial = Tutorials[TutorialHelper:GetRace() .. "_" .. questID];
		if (tutorial) then
			tutorial:Begin();
		end
	end

	-- -----------------------------------------------
	-- Hearthstone
	local hearthstoneData = tutorialData.UseHearthstoneQuest;
	if (hearthstoneData and tutorialData.UseHearthstoneOnQuestStart) then
		if (type(hearthstoneData) == "table") then
			error("ERROR - UseHearthstoneOnQuestStart does not support a list of quests");
		else
			if (hearthstoneData == questID) then
				Tutorials.UseHearthstone:Begin();
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Tutorials:Quest_ObjectivesComplete(questData)
	local questID = questData.QuestID;
	local tutorialData = TutorialHelper:GetRacialData();
	if not tutorialData then
		return;
	end

	-- -----------------------------------------------
	-- All active quests complete
	local allQuestsReadyForTurnIn = true;

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i);
		-- Only check valid non-account quests.
		if questID and not C_QuestLog.IsAccountQuest(questID) and not C_QuestLog.ReadyForTurnIn(questID) then
			allQuestsReadyForTurnIn = false;
			break;
		end
	end

	if (allQuestsReadyForTurnIn) then
		local hearthstoneData = tutorialData.UseHearthstoneQuest;
		local shouldUseHearthstone = false;

		if (hearthstoneData and (not tutorialData.UseHearthstoneOnQuestStart)) then
			if (type(hearthstoneData) == "table") then
				for i, v in ipairs(hearthstoneData) do
					if (v == questID) then
						shouldUseHearthstone = true;
						break;
					end
				end
			else
				shouldUseHearthstone = hearthstoneData == questID;
			end
		end

		if (shouldUseHearthstone) then
			C_Timer.After(5, function()
					Tutorials.UseHearthstone:Begin();
				end);
		else
			Tutorials.QuestCompleteOpenMap:Begin(questData);
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Tutorials:Quest_TurnedIn(questData)
	local tutorialData = TutorialHelper:GetRacialData();
	if not tutorialData then
		return;
	end

	-- -----------------------------------------------
	-- close the Open Map prompt if it's still up when they complete a quest
	Tutorials.QuestCompleteOpenMap:Interrupt();

	-- -----------------------------------------------
	-- HP/MP callout
	local firstKillQuest = tutorialData.FirstKillQuest or tutorialData.StartingQuest;
	if (questData.QuestID == firstKillQuest) then
		Dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED", function() Tutorials.HealthBarCallout:Begin(); end, true);
	end
end

-- ------------------------------------------------------------------------------------------------------------

-- UI intro
Tutorials.Intro_Interact				= Class_Intro_Interact:new();
Tutorials.Intro_OpenMap					= Class_Intro_OpenMap:new();
Tutorials.Intro_MapHighlights			= Class_Intro_MapHighlights:new();
Tutorials.Intro_KeyboardMouse			= Class_Intro_KeyboardMouse:new();

-- First Mob
Tutorials.SelectMobWatcher				= Class_SelectMobWatcher:new();
Tutorials.TargetMob						= Class_TargetMob:new();
Tutorials.ActionBarCallout				= Class_ActionBarCallout:new();
Tutorials.HealthBarCallout				= Class_HealthBarCallout:new();

-- Equip first item chain
Tutorials.EquipFirstItemWatcher			= Class_EquipFirstItemWatcher:new();
Tutorials.ShowBags						= Class_ShowBags:new(Tutorials.EquipFirstItemWatcher);
Tutorials.EquipItem						= Class_EquipItem:new(Tutorials.EquipFirstItemWatcher);
Tutorials.OpenCharacterSheet			= Class_OpenCharacterSheet:new(Tutorials.EquipFirstItemWatcher);
Tutorials.HighlightEquippedItem 		= Class_HighlightEquippedItem:new(Tutorials.EquipFirstItemWatcher);
Tutorials.CloseCharacterSheet 			= Class_CloseCharacterSheet:new(Tutorials.EquipFirstItemWatcher);

-- Looting
Tutorials.LootCorpseWatcher				= Class_LootCorpseWatcher:new();
Tutorials.LootCorpse					= Class_LootCorpse:new(Tutorials.LootCorpseWatcher);
Tutorials.LootPointer					= Class_LootPointer:new(Tutorials.LootCorpseWatcher);

-- Death
Tutorials.Death_Watcher					= Class_Death_Watcher:new();
Tutorials.Death_ReleaseCorpse			= Class_Death_ReleaseCorpse:new(Tutorials.Death_Watcher);
Tutorials.Death_MapPrompt				= Class_Death_MapPrompt:new(Tutorials.Death_Watcher);
Tutorials.Death_ResurrectPrompt			= Class_Death_ResurrectPrompt:new(Tutorials.Death_Watcher);

-- Quests
Tutorials.QuestCompleteOpenMap			= Class_QuestCompleteOpenMap:new();
Tutorials.ShowMapQuestTurnIn			= Class_ShowMapQuestTurnIn:new();
Tutorials.SelectQuestDifferentZone		= Class_SelectQuestDifferentZone:new();
Tutorials.AcceptMoreQuests				= Class_AcceptMoreQuests:new();
Tutorials.AcceptQuestWatcher			= Class_AcceptQuestWatcher:new();
Tutorials.AcceptQuest					= Class_AcceptQuest:new(Tutorials.AcceptQuestWatcher);
Tutorials.TurnInQuestWatcher			= Class_TurnInQuestWatcher:new();
Tutorials.TurnInQuest					= Class_TurnInQuest:new(Tutorials.TurnInQuestWatcher);
Tutorials.QuestRewardChoice				= Class_QuestRewardChoice:new(Tutorials.TurnInQuestWatcher);
Tutorials.UseQuestItem					= Class_UseQuestItem:new();
Tutorials.UseQuestObject				= Class_UseQuestObject:new();
Tutorials.NPCInteractQuest				= Class_NPCInteractQuest:new();
Tutorials.LootFromObject				= Class_LootFromObject:new();

-- Ability use
Tutorials.AbilityUse_Watcher			= Class_AbilityUse_Watcher:new();
Tutorials.AbilityUse_SpellInterrupted	= Class_AbilityUse_SpellInterrupted:new();
Tutorials.AbilityUse_AbilityReminder	= Class_AbilityUse_AbilityReminder:new();
Tutorials.Level3Ability					= Class_Level3Ability:new();

-- Gossip
Tutorials.GossipWatcher					= Class_GossipWatcher:new();
Tutorials.GossipQuestPointer			= Class_GossipQuestPointer:new(Tutorials.GossipWatcher);
Tutorials.GossipBindPrompt				= Class_GossipBindPrompt:new(Tutorials.GossipWatcher);
Tutorials.GossipBindPointer				= Class_GossipBindPointer:new(Tutorials.GossipWatcher);
Tutorials.InteractThenGossipA			= Class_InteractThenGossipA:new();
Tutorials.InteractThenGossipB			= Class_InteractThenGossipB:new();

-- Misc
Tutorials.HighlightItem					= Class_HighlightItem:new();
Tutorials.Taxi							= Class_Taxi:new();
Tutorials.UseHearthstone				= Class_UseHearthstone:new();
Tutorials.ChatFrame						= Class_ChatFrame:new();

-- Custom
Tutorials.Draenei_9283					= Class_Dranei_9283:new();
Tutorials.BloodElf_8346					= Class_BloodElf_8346:new();

-- Exclusivity
Class_TutorialBase:MakeExclusive(Tutorials.HighlightItem, Tutorials.EquipItem);

-- Auto suppression
Tutorials.Intro_OpenMap:Suppresses(Tutorials.SelectMobWatcher);
Tutorials.AbilityUse_AbilityReminder:Suppresses(Tutorials.Intro_KeyboardMouse);
Tutorials.ActionBarCallout:Suppresses(Tutorials.Intro_KeyboardMouse);

-- ============================================================================================================
-- DEBUG
-- ============================================================================================================

function DebugTutorials(value)
	Class_TutorialBase:Debug(value);
end

function TutorialStatus()
	print("---------------------------------------")
	for k, v in pairs(Tutorials) do
		if (type(v) == "table") then
			print(v.IsActive and "+ ACTIVE" or "- INACTIVE", k);
		end
	end
end




