-- ============================================================================================================
-- Tutorial Base
-- ============================================================================================================
Class_TutorialBase = class("TutorialBase");
Class_TutorialBase.static.IsDebugging = false;
Class_TutorialBase.static.IsGlobalEnabled = true;

function Class_TutorialBase.static:GlobalEnable()
	self.static.IsGlobalEnabled = true;
end

function Class_TutorialBase.static:GlobalDisable()
	self.static.IsGlobalEnabled = false;
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

function Class_TutorialBase:Name()
	return self.class.name;
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
function Class_TutorialBase:ShowScreenTutorial(content, druation, position, showMovieName, loopMovie, resolution)
	self:DebugLog("ShowScreenTutorial");
	self._screenTutorial = TutorialMainFrame_Frame:ShowTutorial(content, druation, position, showMovieName, loopMovie, resolution);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:HideScreenTutorial()
	if (not self._screenTutorial) then return; end

	self:DebugLog("HideScreenTutorial");
	TutorialMainFrame_Frame:HideTutorial(self._screenTutorial);
	self._screenTutorial = nil;
end

function Class_TutorialBase:ShowMouseKeyboardTutorial()
	self:DebugLog("ShowMouseKeyboardTutorial");
	self._screenTutorial = TutorialKeyboardMouseFrame_Frame:ShowTutorial();
end

function Class_TutorialBase:HideMouseKeyboardTutorial()
	self:DebugLog("HideMouseKeyboardTutorial");
	self._screenTutorial = TutorialKeyboardMouseFrame_Frame:HideTutorial();
end

function Class_TutorialBase:ShowSingleKeyTutorial(content, druation, position, showMovieName, loopMovie, resolution)
	self:DebugLog("ShowSingleKeyTutorial");
	self._screenTutorial = TutorialSingleKey_Frame:ShowTutorial(content, druation, position, showMovieName, loopMovie, resolution);
end

function Class_TutorialBase:HideSingleKeyTutorial()
	self:DebugLog("HideSingleKeyTutorial");
	self._screenTutorial = TutorialSingleKey_Frame:HideTutorial();
end

function Class_TutorialBase:ShowWalkTutorial()
	self:DebugLog("ShowWalkTutorial");
	self._screenTutorial = TutorialWalk_Frame:ShowTutorial();
end

function Class_TutorialBase:HideWalkTutorial()
	self:DebugLog("HideWalkTutorial");
	self._screenTutorial = TutorialWalk_Frame:HideTutorial();
end

-- ------------------------------------------------------------------------------------------------------------
-- Pointer Tutorials
-- Arrow frame that points at something on screen
-- Frame is automatically closed when tutorial is shutdown
-- This function clears any existing poitners before adding the new one
function Class_TutorialBase:ShowPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
	self:DebugLog("ShowPointerTutorial");

	self:HidePointerTutorials();
	return self:AddPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution);
end

-- ------------------------------------------------------------------------------------------------------------
-- Adds a pointer tutorial ontop of existing pointers
function Class_TutorialBase:AddPointerTutorial(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
	self:DebugLog("AddPointerTutorial");
	local pointer = TutorialPointerFrame:Show(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution);	
	table.insert(self._pointerTutorials, pointer);

	return pointer;
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:HidePointerTutorial(pointerTutorialID)
	local count = #self._pointerTutorials;
	if (count == 0) then return; end

	self:DebugLog("HidePointerTutorial");
	TutorialPointerFrame:Hide(pointerTutorialID);
end

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:HidePointerTutorials()
	local count = #self._pointerTutorials;
	if (count == 0) then return; end

	self:DebugLog("HidePointerTutorials");

	for i = 1, count do
		TutorialPointerFrame:Hide(self._pointerTutorials[i]);
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
function Class_TutorialBase:Interrupt(interruptedBy, forceInterrupt)
	if forceInterrupt or self.IsActive then
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

function Class_TutorialBase:SetExclusiveClass(class)
	self.playerClass = TutorialHelper:GetClass();
	if (class and (class == self.playerCLass == class)) then
		self:Interrupt(self);
		return;
	end
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

-- ------------------------------------------------------------------------------------------------------------
function Class_TutorialBase:Status()
	return self.class.name;
end
