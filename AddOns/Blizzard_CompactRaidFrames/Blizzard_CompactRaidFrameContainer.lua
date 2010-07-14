MAX_RAID_GROUPS = 8;

--Widget Handlers
function CompactRaidFrameContainer_OnLoad(self)
	FlowContainer_Initialize(self);	--Congrats! We are now a certified FlowContainer.
	
	self.units = {--[["raid1", "raid2", "raid3", ..., "raid40"]]};
	for i=1, MAX_RAID_MEMBERS do
		tinsert(self.units, "raid"..i);
	end
	
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	
	self.unusedUnitFrames = {};
	self.unitFrameUnusedFunc = function(frame) --Have to make a wrapper to access self
													CompactUnitFrame_SetUnit(frame, nil);
													tinsert(self.unusedUnitFrames, frame)
												end;
												
	CompactRaidFrameContainer_SetFlowFilterFunction(self, function(token) return UnitExists(token) end)
end

function CompactRaidFrameContainer_OnEvent(self, event, ...)
	if ( event == "RAID_ROSTER_UPDATE" ) then
		CompactRaidFrameContainer_TryUpdate(self);
	end
end

function CompactRaidFrameContainer_OnSizeChanged(self)
	FlowContainer_DoLayout(self);
end

--Externally used functions
function CompactRaidFrameContainer_SetGroupMode(self, groupMode)
	self.groupMode = groupMode;
	CompactRaidFrameContainer_TryUpdate(self);
end

function CompactRaidFrameContainer_SetFlowFilterFunction(self, flowFilterFunc)
	--Usage: flowFilterFunc is called as flowFilterFunc("unittoken") and should return whether this frame should be displayed or not.
	self.flowFilterFunc = flowFilterFunc;
	CompactRaidFrameContainer_TryUpdate(self);
end

function CompactRaidFrameContainer_SetFlowSortFunction(self, flowSortFunc)
	--Usage: Takes two tokens, should work as a Lua sort function.
	--The ordering must be well-defined, even across units that will be filtered out
	self.flowSortFunc = flowSortFunc;
	CompactRaidFrameContainer_TryUpdate(self);
end

--Internally used functions
function CompactRaidFrameContainer_TryUpdate(self)
	if ( CompactRaidFrameContainer_ReadyToUpdate(self) ) then
		CompactRaidFrameContainer_LayoutFrames(self);
	end
end

function CompactRaidFrameContainer_ReadyToUpdate(self)
	if ( not self.groupMode ) then
		return false;
	end
	if ( self.groupMode == "flush" and not (self.flowFilterFunc and self.flowSortFunc) ) then
		return false;
	end
	return true;
end

function CompactRaidFrameContainer_LayoutFrames(self)
	--First, hide everything we currently use.
	for i=1, #self.flowFrames do
		self.flowFrames[i]:unusedFunc();
	end
	FlowContainer_RemoveAllObjects(self);
	
	if ( self.groupMode == "discrete" ) then
		CompactRaidFrameContainer_AddGroups(self);
	elseif ( self.groupMode == "flush" ) then
		CompactRaidFrameContainer_AddPlayers(self);
	else
		error("Unknown group mode");
	end
	if ( self.displayPets ) then
		CompactRaidFrameContainer_AddPets(self);
	end
end

do
	local usedGroups = {}; --Enclosure to make sure usedGroups isn't used anywhere else.
	function CompactRaidFrameContainer_AddGroups(self)
		RaidUtil_GetUsedGroups(usedGroups);
		
		FlowContainer_PauseUpdates(self);	--We don't want to update it every time we add an item.
		
		local numGroups = 0;
		for groupNum, isUsed in ipairs(usedGroups) do
			if ( isUsed ) then
				numGroups = numGroups + 1;
				local groupFrame = CompactRaidGroup_GenerateForGroup(groupNum);
				groupFrame.unusedFunc = groupFrame.Hide;
				FlowContainer_AddObject(self, groupFrame);
				groupFrame:Show();
			end
		end
		FlowContainer_SetOrientation(self, "vertical")
		FlowContainer_ResumeUpdates(self);
	end
end


function CompactRaidFrameContainer_AddPlayers(self)
	--First, sort the players we're going to use
	assert(self.flowSortFunc);	--No sort function defined! Call CompactRaidFrameContainer_SetFlowSortFunction.
	assert(self.flowFilterFunc);	--No filter function defined! Call CompactRaidFrameContainer_SetFlowFilterFunction.
	
	table.sort(self.units, self.flowSortFunc);
	
	FlowContainer_PauseUpdates(self);	--We don't want to update it every time we add an item.
	
	for i=1, #self.units do
		local unit = self.units[i];
		if ( self.flowFilterFunc(unit) ) then
			local frame = CompactRaidFrameContainer_GetUnusedUnitFrame(self);
			CompactUnitFrame_SetUnit(frame, unit);
			FlowContainer_AddObject(self, frame);
		end
	end
	
	FlowContainer_SetOrientation(self, "vertical")
	FlowContainer_ResumeUpdates(self);
end

function CompactRaidFrameContainer_AddPets(self)
	--TODO
end

--Utility Functions
function CompactRaidFrameContainer_GetUnusedUnitFrame(self)
	if ( #self.unusedUnitFrames > 0 ) then
		return tremove(self.unusedUnitFrames, #self.unusedUnitFrames);
	else
		return CompactRaidFrameContainer_CreateUnitFrame(self);
	end
end

function CompactRaidFrameContainer_CreateUnitFrame(self)
	local frame = CreateFrame("Button", nil, self, "CompactUnitFrameTemplate");
	CompactUnitFrame_SetUpFrame(frame, DefaultCompactUnitFrameSetup);
	frame.unusedFunc = self.unitFrameUnusedFunc;
	return frame;
end

function RaidUtil_GetUsedGroups(tab)	--Fills out the table with which groups have people.
	for i=1, MAX_RAID_GROUPS do
		tab[i] = false;
	end
	for i=1, GetNumRaidMembers() do
		local name, rank, subgroup = GetRaidRosterInfo(i);
		tab[subgroup] = true;
	end
	return tab;
end