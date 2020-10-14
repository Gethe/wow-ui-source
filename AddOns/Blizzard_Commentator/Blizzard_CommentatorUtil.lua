FunctionThrottleMixin = {}

function FunctionThrottleMixin:Init(threshold, func, owner)
	self.elapsed = 0;
	self.threshold = threshold;
	self.func = GenerateClosure(func, owner);
end

function FunctionThrottleMixin:Update(dt, ...)
	self.elapsed = self.elapsed + dt;
	if self.elapsed >= self.threshold then
		self.elapsed = 0;
		self.func(...);
		return true;
	end
	return false;
end

CommentatorUtil = {}

function CommentatorUtil.GetOppositeTeamIndex(teamIndex)
	return teamIndex == 1 and 2 or 1;
end