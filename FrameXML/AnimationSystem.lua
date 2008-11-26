--[[	animTable = {	--Note that only consistent data should be in here. These tables are meant to be shared across "sessions" of animations. Put changing data in the frame.
	totalTime = number,		--Time to complete the animation in seconds.
	updateFunc = function,		--The function called to do the actual change. Takes self, elapsed fraction. Usually frame.SetPoint, frame.SetAlpha, ect.
	getPosFunc = function,		--The function returning the data being passed into updateFunc. For example. might return .18 if updateFunc is frame.SetAlpha.
--]]
local EmptyTable = {};	--To be used so as to have an easy comparison without ruining next()
local AnimatingFrames = {};
_G.AnimatingFrames = AnimatingFrames;	--People may want access to this

local AnimUpdateFrame = CreateFrame("Frame");

function SetUpAnimation(frame, animTable, postFunc, reverse)
	if ( type(animTable.updateFunc) == "string" ) then
		animTable.updateFunc = frame[animTable.updateFunc];
	end
	AnimatingFrames[frame] = animTable;
	
	frame.animElapsed = 0;
	frame.animReverse = reverse;	
	frame.animPostFunc = postFunc;
	frame.animating = true;
	
	animTable.updateFunc(frame, animTable.getPosFunc(frame, frame.animReverse and 1 or 0));
end

local function Animation_UpdateFrame(self, elapsed, animTable)
	self.animElapsed = self.animElapsed + elapsed;
	if ( self.animElapsed and (self.animElapsed < animTable.totalTime)) then	--Should be animating
		local elapsedFraction = self.animReverse and (1-self.animElapsed/animTable.totalTime) or (self.animElapsed/animTable.totalTime);
		animTable.updateFunc(self, animTable.getPosFunc(self, elapsedFraction));
	else	--Just finished animating
		animTable.updateFunc(self, animTable.getPosFunc(self, self.animReverse and 0 or 1));
		self.animating = false;
		
		AnimatingFrames[self] = EmptyTable;
		
		if ( self.animPostFunc ) then
			self.animPostFunc(self);
		end

	end
end

local function Animation_OnUpdate(self, elapsed)
	for frame, animTable in pairs(AnimatingFrames) do
		if ( animTable ~= EmptyTable ) then
			Animation_UpdateFrame(frame, elapsed, animTable);
		end
	end
end

AnimUpdateFrame:SetScript("OnUpdate", Animation_OnUpdate);