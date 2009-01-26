--[[	animTable = {	--Note that only consistent data should be in here. These tables are meant to be shared across "sessions" of animations. Put changing data in the frame.
	totalTime = number,		--Time to complete the animation in seconds.
	updateFunc = function,		--The function called to do the actual change. Takes self, elapsed fraction. Usually frame.SetPoint, frame.SetAlpha, ect.
	getPosFunc = function,		--The function returning the data being passed into updateFunc. For example. might return .18 if updateFunc is frame.SetAlpha.
--]]
local AnimatingFrames = {};

local AnimUpdateFrame = CreateFrame("Frame");

local function Animation_UpdateFrame(self, animElapsed, animTable)
	local totalTime = animTable.totalTime
	if ( animElapsed and (animElapsed < totalTime)) then	--Should be animating
		local elapsedFraction = self.animReverse and (1-animElapsed/totalTime) or (animElapsed/totalTime);
		animTable.updateFunc(self, animTable.getPosFunc(self, elapsedFraction));
	else	--Just finished animating
		animTable.updateFunc(self, animTable.getPosFunc(self, self.animReverse and 0 or 1));
		self.animating = false;
		
		AnimatingFrames[self][animTable.updateFunc] = 0;	--We use 0 instead of nil'ing out because we don't want to mess with 'next' (used in pairs)
		
		if ( self.animPostFunc ) then
			self.animPostFunc(self);
		end

	end
end

local totalElapsed = 0;
local function Animation_OnUpdate(self, elapsed)
	totalElapsed = totalElapsed + elapsed;
	local isAnyFrameAnimating = false;
	for frame, frameTable in pairs(AnimatingFrames) do
		for frameTable, animTable in pairs(frameTable) do
			if ( animTable ~= 0 ) then
				Animation_UpdateFrame(frame, totalElapsed - frame.animStartTime, animTable);
				isAnyFrameAnimating = true;
			end
		end
	end
	if ( not isAnyFrameAnimating ) then
		table.wipe(AnimatingFrames);
		AnimUpdateFrame:SetScript("OnUpdate", nil);
	end
end

function SetUpAnimation(frame, animTable, postFunc, reverse)
	if ( type(animTable.updateFunc) == "string" ) then
		animTable.updateFunc = frame[animTable.updateFunc];
	end
	if ( not AnimatingFrames[frame] ) then
		AnimatingFrames[frame] = {};
	end
	
	AnimatingFrames[frame][animTable.updateFunc] = animTable;
	
	frame.animStartTime = totalElapsed;
	frame.animReverse = reverse;	
	frame.animPostFunc = postFunc;
	frame.animating = true;
	
	animTable.updateFunc(frame, animTable.getPosFunc(frame, frame.animReverse and 1 or 0));
	
	AnimUpdateFrame:SetScript("OnUpdate", Animation_OnUpdate);
end
