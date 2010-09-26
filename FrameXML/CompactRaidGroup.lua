function CompactRaidGroup_OnLoad(self)
	self.title:Disable();
	
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
end

function CompactRaidGroup_OnEvent(self, event, ...)
	if ( event == "RAID_ROSTER_UPDATE" ) then
		CompactRaidGroup_UpdateUnits(self);
	end
end

function CompactRaidGroup_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...)
	if ( updateSpecifier == "normal" or updateSpecifier == "all" ) then
		for i=1, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName().."Member"..i];
			func(unitFrame, ...);
		end
	elseif ( updateSpecifier == "group" ) then
		func(frame, ...);
	end
end

function CompactRaidGroup_GenerateForGroup(groupIndex)
	local didCreate = false;
	local frame = _G["CompactRaidGroup"..groupIndex]
	if (  not frame ) then
		frame = CreateFrame("Frame", "CompactRaidGroup"..groupIndex, UIParent, "CompactRaidGroupTemplate");
		CompactRaidGroup_InitializeForGroup(frame, groupIndex);
		--CompactRaidGroup_UpdateLayout(frame);	--Update border calls UpdateLayout.
		CompactRaidGroup_UpdateBorder(frame);
		didCreate = true;
	end
	return frame, didCreate;
end

function CompactRaidGroup_InitializeForGroup(frame, groupIndex)
	frame:SetID(groupIndex);
	for i=1, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G[frame:GetName().."Member"..i];
		CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(unitFrame, "RAID_ROSTER_UPDATE");
	end
	CompactRaidGroup_UpdateUnits(frame);
	frame.title:SetFormattedText(GROUP_NUMBER, groupIndex);
end

function CompactRaidGroup_UpdateUnits(frame)
	local groupIndex = frame:GetID();
	local frameIndex = 1;
	for i=1, GetNumRaidMembers() do
		local name, rank, subgroup = GetRaidRosterInfo(i);
		if ( subgroup == groupIndex ) then
			CompactUnitFrame_SetUnit(_G[frame:GetName().."Member"..frameIndex], "raid"..i);
			frameIndex = frameIndex + 1;
		end
	end
	
	for i=frameIndex, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G[frame:GetName().."Member"..frameIndex];
		CompactUnitFrame_SetUnit(unitFrame, nil);
	end
end

function CompactRaidGroup_UpdateLayout(frame)
	local totalHeight = frame.title:GetHeight();
	totalHeight = totalHeight + _G[frame:GetName().."Member1"]:GetHeight() * MEMBERS_PER_RAID_GROUP;
	
	local totalWidth = _G[frame:GetName().."Member1"]:GetWidth();
	if ( frame.borderFrame:IsShown() ) then
		totalWidth = totalWidth + 12;
		totalHeight = totalHeight + 4;
	end
	
	frame:SetSize(totalWidth, totalHeight);
end

function CompactRaidGroup_UpdateBorder(frame)
	local showBorder = GetCVarBool("raidOptionShowBorders");
	
	if ( showBorder ) then
		frame.borderFrame:Show();
	else
		frame.borderFrame:Hide();
	end
	CompactRaidGroup_UpdateLayout(frame);
end

function CompactRaidGroup_StartMoving(frame)
	--Move the frame right onto the cursor.
	local cursorX, cursorY = GetCursorPosition();
	frame:ClearAllPoints();
	frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / UIParent:GetScale(), cursorY / UIParent:GetScale() + 10);
	
	frame:StartMoving();
	MOVING_COMPACT_RAID_FRAME = frame;
end

function CompactRaidGroup_StopMoving(frame)
	frame:StopMovingOrSizing();
	if ( MOVING_COMPACT_RAID_FRAME == frame ) then
		MOVING_COMPACT_RAID_FRAME = nil;
	end
end

function CompactRaidGroup_StopAllMoving()
	if ( MOVING_COMPACT_RAID_FRAME ) then
		CompactRaidGroup_StopMoving(MOVING_COMPACT_RAID_FRAME)
	end
end