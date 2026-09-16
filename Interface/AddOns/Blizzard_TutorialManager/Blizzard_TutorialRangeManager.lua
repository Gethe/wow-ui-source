-- ------------------------------------------------------------------------------------------------------------
-- Watch Data
-- ------------------------------------------------------------------------------------------------------------
local WatchData = class("WatchData");

function WatchData:initialize(itemOrList, watchType, range, callback, mode, quest)
	self.List = {};

	if (type(itemOrList) == "table") then
		for i, id in ipairs(itemOrList) do
			self.List[id] = false;
		end
	else
		self.List[itemOrList] = false;
	end

	self.Range = range;
	self.Type = watchType;
	self.Callback = callback;
	self.Mode = mode or TutorialRangeManager.Mode.Any;
	self.Quest = quest;
	self.IsComplete = false;
end

-- ------------------------------------------------------------------------------------------------------------
function WatchData:_GetFunc()
	if (self.Type == TutorialRangeManager.Type.Unit) then
		return ClosestUnitPosition;
	elseif (self.Type == TutorialRangeManager.Type.Object) then
		return ClosestGameObjectPosition;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function WatchData:_CheckIsComplete()
	local hasTrue = false;
	local hasFalse = false;

	for id, v in pairs(self.List) do
		if (v) then
			hasTrue = true;
		else
			hasFalse = true;
		end
	end

	if (self.Mode == TutorialRangeManager.Mode.Any) then
		return hasTrue;
	else
		return not hasFalse;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function WatchData:Check()
	if (self.Quest and C_QuestLog.IsQuestFlaggedCompleted(self.Quest)) then
		self.IsComplete = true;
		return;
	elseif (self.Quest and C_QuestLog.GetLogIndexForQuestID(self.Quest) == nil) then
		self.IsComplete = true;
		return;
	end

	local func = self:_GetFunc();
	for id, value in pairs(self.List) do
		if (self.List[id] == false) then
			local x, y, distance = func(id);

			if (distance and (distance <= self.Range)) then
				self.List[id] = true;
				self.Callback();
			end
		end
	end

	self.IsComplete = self:_CheckIsComplete();
end


-- ------------------------------------------------------------------------------------------------------------
-- Range Manager
-- ------------------------------------------------------------------------------------------------------------
TutorialRangeManager = {};

TutorialRangeManager.Type = {
	Unit = "Unit",
	Object = "Object",
}

TutorialRangeManager.Mode = {
	Any = "Any",
	All = "All",
}


-- ------------------------------------------------------------------------------------------------------------
function TutorialRangeManager:Initialize()
	self.WatchList = {};
	self.Ticker = nil;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialRangeManager:_Check()
	for i = #self.WatchList, 1, -1 do
		local watchData = self.WatchList[i];

		watchData:Check();
		if (watchData.IsComplete) then
			table.remove(self.WatchList, i);
		end
	end

	self:_Update();
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialRangeManager:_Update()
	if (next(self.WatchList)) then
		if (not self.Ticker) then
			self.Ticker = C_Timer.NewTicker(1, function() self:_Check() end);
		end
	else
		if (self.Ticker) then
			self.Ticker:Cancel();
			self.Ticker = nil;
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialRangeManager:StartWatching(itemOrList, watchType, range, completeCallback, mode, quest)
	local watchData = WatchData:new(itemOrList, watchType, range, completeCallback, mode, quest);

	table.insert(self.WatchList, watchData);

	self:_Update();
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialRangeManager:Shutdown()
	self.WatchList = {};
	self:_Update();
end
