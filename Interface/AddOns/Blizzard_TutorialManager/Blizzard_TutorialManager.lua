TutorialManager = {};

TutorialManager.IsDebugging = false;
TutorialManager.NPE_AchievementID = 14287;
function TutorialManager:Initialize()
	self:Begin();
end

function TutorialManager:Begin()
	Class_TutorialBase:GlobalEnable();
	self.Tutorials = {};
	self.Watchers = {};
	self.IsActive = true;

	Dispatcher:RegisterEvent("CVAR_UPDATE", self);
end

function TutorialManager:Shutdown()
	TutorialRangeManager:Shutdown();
	TutorialQuestManager:Shutdown();
	Class_TutorialBase:GlobalDisable();

	for k, tutorial in pairs(self.Tutorials) do
		if (type(tutorial) == "table") then
			tutorial:Interrupt();
		end
	end

	for k, watcher in pairs(self.Watchers) do
		if (type(watcher) == "table") then
			watcher:Interrupt();
		end
	end

	self.Tutorials = {};
	self.Watchers = {};
	self.IsActive = false;
end

function TutorialManager:CVAR_UPDATE(cvar, value)
	if (cvar == "showTutorials" ) then
		if (value == "0") then
			-- player is trying to shut the NPE Tutorial off
			local _, _, _, completed = GetAchievementInfo(self.NPE_AchievementID);
			-- they can  ONLY do that if the achievement is completed
			if (completed) then
				self:Shutdown();
			end
		end
	end
end

function TutorialManager:DebugLog(debugString)
	if (self.IsDebugging) then
		print(debugString);
	end
end

function TutorialManager:GetIsActive()
	return self.IsActive;
end

-- TUTORIAL API
function TutorialManager:AddTutorial(tutorialInstance, optionalOverrideKey, args)
	if tutorialInstance and (tutorialInstance:Name() or optionalOverrideKey) then
		local key = optionalOverrideKey or tutorialInstance:Name();
		self.Tutorials[key] = tutorialInstance;
		if tutorialInstance.OnAdded then
			self:DebugLog("ADD TUTORIAL: "..key);
			tutorialInstance:OnAdded(args);
		end
	end
	return tutorialInstance;
end

function TutorialManager:RemoveTutorial(tutorialKey)
	self.Tutorials[tutorialKey] = nil;
	self:DebugLog("REMOVE TUTORIAL: "..tutorialKey);
end

function TutorialManager:GetTutorial(tutorialKey)
	return self.Tutorials[tutorialKey];
end

function TutorialManager:Queue(tutorialKey, ...)
	local tutorial = self:GetTutorial(tutorialKey);
	self:DebugLog("  QUEUE: "..tutorialKey);
	TutorialQueue:Add(tutorial, ...);
end

function TutorialManager:Finished(tutorialKey)
	local tutorial = self:GetTutorial(tutorialKey);
	self:DebugLog("  FINISH: "..tutorialKey);
	TutorialQueue:NotifyDone(tutorial);
end

function TutorialManager:ShutdownTutorial(tutorialKey)
	local tutorial = self:GetTutorial(tutorialKey);
	if tutorial then
		tutorial:Interrupt();
	end
	self:RemoveTutorial(tutorialKey);
end

-- WATCHER API
function TutorialManager:AddWatcher(tutorialInstance, autoStart, optionalOverrideKey, args)
	if tutorialInstance and (tutorialInstance:Name() or optionalOverrideKey) then
		local key = optionalOverrideKey or tutorialInstance:Name();
		self.Watchers[key] = tutorialInstance;
		self:DebugLog("ADD WATCHER: "..key);
		if tutorialInstance.OnAdded then
			tutorialInstance:OnAdded(args);
		end
		if autoStart then
			self:DebugLog("    AND START WATCHER: "..key);
			self:StartWatcher(key);
		end
	end
	return tutorialInstance;
end

function TutorialManager:RemoveWatcher(tutorialKey)
	self.Watchers[tutorialKey] = nil;
	self:DebugLog("REMOVE WATCHER: "..tutorialKey);
end

function TutorialManager:GetWatcher(tutorialKey)
	return self.Watchers[tutorialKey];
end

function TutorialManager:StartWatcher(tutorialKey)
	local watcher = self.Watchers[tutorialKey];
	if watcher then
		watcher:Begin();
		watcher:StartWatching();
	end
end

function TutorialManager:StopWatcher(tutorialKey, removeAfter)
	local watcher = self.Watchers[tutorialKey];
	if watcher then
		if watcher and watcher.StopWatching then
			watcher:StopWatching();
		end
		if removeAfter then
			watcher:Complete();
			self:RemoveWatcher(tutorialKey);
		end
	end
end

function TutorialManager:ShutdownWatcher(tutorialKey)
	self:StopWatcher(tutorialKey);
	local watcher = self:GetWatcher(tutorialKey);
	if watcher then
		watcher:Interrupt();
	end
	self:RemoveWatcher(tutorialKey);
end

TutorialManager:Initialize();

-- ============================================================================================================
-- DEBUG
-- ============================================================================================================
function DebugTutorials(value)
	Class_TutorialBase:Debug(value);
end

function TutorialManager:TutorialStatus()
	print("--------------START--------------")
	for k, v in pairs(self.Tutorials) do
		if (type(v) == "table") then
			print("Tutorial: "and v.IsActive and "+ ACTIVE" or "- INACTIVE", k);
		end
	end
	for k, v in pairs(self.Watchers) do
		if (type(v) == "table") then
			print("Watcher: "and v.IsActive and "+ ACTIVE" or "- INACTIVE", k);
		end
	end
	print("---------------END---------------")
end
DebugTutorials(false);


