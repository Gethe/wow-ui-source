
local States = EnumUtil.MakeEnum("Ready", "Begin", "Update", "End");

local ObjectUpdaterMixin = {};
function ObjectUpdaterMixin:Init(data, updateFunc, isCompleteFunc, finishFunc)
	self.data = data;
	self:SetUpdateFunction(updateFunc);
	self:SetIsCompleteFunction(isCompleteFunc);
	self:SetFinishFunction(finishFunc);
	self.state = States.Begin;
	self.ticker = C_Timer.NewTicker(0.01, GenerateClosure(self.Advance, self));
end

function ObjectUpdaterMixin:SetUpdateFunction(updateFunc)
	self.updateFunc = updateFunc;
end

function ObjectUpdaterMixin:SetIsCompleteFunction(isCompleteFunc)
	self.isCompleteFunc = isCompleteFunc;
end

function ObjectUpdaterMixin:SetFinishFunction(finishFunc)
	self.finishFunc = finishFunc;
end

function ObjectUpdaterMixin:Cancel()
	self.ticker:Cancel();
	self.state = States.Ready;
end

function ObjectUpdaterMixin:Finished()
	self:Cancel();
	if self.finishFunc then
		self.finishFunc(self.data);	
	end
end

function ObjectUpdaterMixin:Advance()
	if self.state == States.Begin then
		if self.isCompleteFunc(self.data) then
			self.state = States.End;
		else
			self.state = States.Update;
		end
	elseif self.state == States.Update then
		self.updateFunc(self.data);
		if self.isCompleteFunc(self.data) then
			self.state = States.End;
		end
	elseif self.state == States.End then
		self:Finished();		
		return;
	end
end

function CreateObjectUpdater(data, updateFunc, isCompleteFunc, finishFunc)
	return CreateAndInitFromMixin(ObjectUpdaterMixin, data, updateFunc, isCompleteFunc, finishFunc);
end