TutorialQueue = {};

function TutorialQueue:Initialize()
	self:Reset();
end

function TutorialQueue:Reset()
	self.queue = CreateFromMixins(DoublyLinkedListMixin);
	self.currentTutorial = nil;
end

function TutorialQueue:Add(tutorialInstance, ...)
	local args = {...};
	if tutorialInstance:CanBegin(args) then
		TutorialManager:DebugLog("    QUEUE ADD: "..tutorialInstance.class.name);
		local value = {};
		value.tutorial = tutorialInstance;
		value.args = args;
		self.queue:PushFront(value);
	end
	self:CheckQueue();
end

function TutorialQueue:NotifyDone(callingTutorial)
	if self.currentTutorial and self.currentTutorial == callingTutorial then
		TutorialManager:DebugLog("    QUEUE COMPLETE: "..self.currentTutorial.class.name);
		self.currentTutorial:Complete();
		self.currentTutorial.inProgress = false;
		self.currentTutorial = nil;
	end
	self:CheckQueue();
end

function TutorialQueue:CheckQueue()
	if self.currentTutorial then
		return;
	end

	local value = self.queue:PopBack();
	if value and value.tutorial and not value.tutorial.IsActive then
		self.currentTutorial = value.tutorial;
		self.currentTutorial.inProgress = true;
		TutorialManager:DebugLog("    QUEUE START: "..self.currentTutorial.class.name);
		self.currentTutorial:Begin(value.args);
	end
end

-- ============================================================================================================
-- DEBUG
-- ============================================================================================================
function TutorialQueue:Status()
	TutorialManager:DebugLog("--------------START--------------")
	for index, value in self.queue:EnumerateNodes() do
	   TutorialManager:DebugLog(index..": "..value.tutorial:Status());
	end
	TutorialManager:DebugLog("---------------END---------------")
end
