CompactRaidGroupTypeEnum = {
	Raid = Enum.EditModeUnitFrameSystemIndices.Raid,
	Party = Enum.EditModeUnitFrameSystemIndices.Party,
	Arena = Enum.EditModeUnitFrameSystemIndices.Arena,
};

function CompactRaidGroup_OnLoad(self)
	self.title:Disable();

	for _, memberUnitFrame in ipairs(self.memberUnitFrames) do
		memberUnitFrame.groupType = self.groupType;
	end

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	self.updateLayoutFunc = CompactRaidGroup_UpdateLayout;
end

function CompactRaidGroup_OnEvent(self, event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" ) then
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
		frame = CreateFrame("Frame", "CompactRaidGroup"..groupIndex, CompactRaidFrameContainer, "CompactRaidGroupTemplate");
		CompactRaidGroup_InitializeForGroup(frame, groupIndex);
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
		CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
	end
	CompactRaidGroup_UpdateUnits(frame);
	frame.title:SetFormattedText(GROUP_NUMBER, groupIndex);
end

function CompactRaidGroup_UpdateUnits(frame)
	if frame.groupType ~= CompactRaidGroupTypeEnum.Party and ShouldShowRaidFrames() then
		local groupIndex = frame:GetID();
		local frameIndex = 1;

		for i=1, GetNumGroupMembers() do
			local name, rank, subgroup = GetRaidRosterInfo(i);
			if ( subgroup == groupIndex and frameIndex <= MEMBERS_PER_RAID_GROUP ) then
				local unitToken;
				if IsInRaid() then
					unitToken = "raid"..i;
				else
					if i == 1 then
						unitToken = "player";
					else
						unitToken = "party"..(i - 1);
					end
				end

				CompactUnitFrame_SetUnit(_G[frame:GetName().."Member"..frameIndex], unitToken);
				frameIndex = frameIndex + 1;
			end
		end
		
		local forcedShown = EditModeManagerFrame:AreRaidFramesForcedShown();

		for i=frameIndex, MEMBERS_PER_RAID_GROUP do
			local unitToken = forcedShown and "player" or nil;
			local unitFrame = _G[frame:GetName().."Member"..i];
			CompactUnitFrame_SetUnit(unitFrame, unitToken);
		end
	end

	frame:updateLayoutFunc();
end

local function SetupBorderFrameAnchor(groupFrame, topUnitFrame, bottomUnitFrame)
	groupFrame.borderFrame:ClearAllPoints();
	groupFrame.borderFrame:SetPoint("TOPLEFT", topUnitFrame, "TOPLEFT", -3, 5);
	groupFrame.borderFrame:SetPoint("BOTTOMRIGHT", bottomUnitFrame, "BOTTOMRIGHT", 8, -5);
end

function CompactRaidGroup_UpdateLayout(frame)
	local totalHeight = frame.title:GetHeight();
	local totalWidth = 0;

	local useHorizontalGroups = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(frame.groupType);
	if useHorizontalGroups then
		frame.title:ClearAllPoints();
		frame.title:SetPoint("TOPLEFT");

		local firstUnitFrame = _G[frame:GetName().."Member1"];
		firstUnitFrame:ClearAllPoints();
		firstUnitFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -frame.title:GetHeight());
		totalWidth = totalWidth + firstUnitFrame:GetWidth();

		local lastShowingUnitFrame = firstUnitFrame;
		for i=2, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName().."Member"..i];
			unitFrame:ClearAllPoints();
			unitFrame:SetPoint("LEFT", _G[frame:GetName().."Member"..(i-1)], "RIGHT", 0, 0);

			if unitFrame:IsShown() or i <= frame.minUnitFrames then
				totalWidth = totalWidth + unitFrame:GetWidth();
				lastShowingUnitFrame = unitFrame;
			end
		end

		totalHeight = totalHeight + _G[frame:GetName().."Member1"]:GetHeight();

		if frame.borderFrame:IsShown() then
			totalWidth = totalWidth + 4;
			SetupBorderFrameAnchor(frame, firstUnitFrame, lastShowingUnitFrame);
		end
	else
		frame.title:ClearAllPoints();
		frame.title:SetPoint("TOP");

		local firstUnitFrame = _G[frame:GetName().."Member1"];
		firstUnitFrame:ClearAllPoints();
		firstUnitFrame:SetPoint("TOP", frame, "TOP", 0, -frame.title:GetHeight());
		totalHeight = totalHeight + firstUnitFrame:GetHeight();

		local lastShowingUnitFrame = firstUnitFrame;
		for i=2, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName().."Member"..i];
			unitFrame:ClearAllPoints();
			unitFrame:SetPoint("TOP", _G[frame:GetName().."Member"..(i-1)], "BOTTOM", 0, 0);

			if unitFrame:IsShown() or i <= frame.minUnitFrames then
				totalHeight = totalHeight + unitFrame:GetHeight();
				lastShowingUnitFrame = unitFrame;
			end
		end

		totalWidth = totalWidth + _G[frame:GetName().."Member1"]:GetWidth();

		if frame.borderFrame:IsShown() then
			totalWidth = totalWidth + 8;
			totalHeight = totalHeight + 2;
			SetupBorderFrameAnchor(frame, firstUnitFrame, lastShowingUnitFrame);
		end
	end

	frame:SetSize(totalWidth, totalHeight);
end

function CompactRaidGroup_UpdateBorder(frame)
	local displayBorder = EditModeManagerFrame:ShouldRaidFrameDisplayBorder(frame.groupType);
	frame.borderFrame:SetShown(displayBorder);
	frame:updateLayoutFunc();
end
