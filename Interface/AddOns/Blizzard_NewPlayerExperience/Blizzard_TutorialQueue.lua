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
	if tutorialInstance:CanStart(args) then
		--print("QUEUED: "..tutorialInstance.class.name);
		local value = {};
		value.tutorial = tutorialInstance;
		value.args = args;
		self.queue:PushFront(value);
	end
	self:CheckQueue();
end

function TutorialQueue:NotifyDone(callingTutorial)
	if self.currentTutorial and self.currentTutorial == callingTutorial then
		--print("FINISH: "..self.currentTutorial.class.name);
		self.currentTutorial:Finish();
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
	if value and value.tutorial and value.tutorial.IsActive then
		self.currentTutorial = value.tutorial;
		self.currentTutorial.inProgress = true;
		--print("START: "..self.currentTutorial.class.name);
		self.currentTutorial:Start(value.args);
	end
end

-- ============================================================================================================
-- DEBUG
-- ============================================================================================================
function TutorialQueue:Status()
	print("--------------START--------------")
	for index, value in self.queue:EnumerateNodes() do
	   print(index..": "..value.tutorial:Status());
	end
	print("---------------END---------------")
end