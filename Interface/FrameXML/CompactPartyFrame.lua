local function ShouldShowCompactPartyFrame()
	return ShouldShowPartyFrames() and EditModeManagerFrame:UseRaidStylePartyFrames();
end

function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	self.updateLayoutFunc = CompactPartyFrame_UpdateLayout;
	self.isParty = true;

	for i = 1, MEMBERS_PER_RAID_GROUP do
		local memberUnitFrame = _G["CompactPartyFrameMember"..i];
		memberUnitFrame.isParty = true;
	end

	CompactPartyFrame_RefreshMembers();

	self.title:SetText(PARTY);
	self.title:Disable();
end

function CompactPartyFrame_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...)
	CompactRaidGroup_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...);
end

function CompactPartyFrame_UpdateLayout(self)
	CompactRaidGroup_UpdateLayout(self);
end

function CompactPartyFrame_UpdateVisibility()
	if not CompactPartyFrame then
		return;
	end

	CompactPartyFrame:SetShown(ShouldShowCompactPartyFrame());
	PartyFrame:UpdatePaddingAndLayout();
end

function CompactPartyFrame_RefreshMembers()
	if not CompactPartyFrame then
		return;
	end

	-- Add player units
	local units = {};
	if IsInRaid() then
		for i = 1, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "raid"..i);
		end
	else
		table.insert(units, "player");

		for i = 2, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "party"..(i-1));
		end
	end
	table.sort(units, CompactPartyFrame.flowSortFunc);

	for index, realPartyMemberToken in ipairs(units) do
		local unitFrame = _G["CompactPartyFrameMember"..index];

		local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(realPartyMemberToken);
		local unitToken = usePlayerOverride and "player" or realPartyMemberToken;

		CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUnit(unitFrame, unitToken);
		CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
	end

	CompactPartyFrame:updateLayoutFunc();
	PartyFrame:UpdatePaddingAndLayout();
end

function CompactPartyFrame_SetFlowSortFunction(flowSortFunc)
	if not CompactPartyFrame then
		return;
	end
	CompactPartyFrame.flowSortFunc = flowSortFunc;
	CompactPartyFrame_RefreshMembers();
end

function CompactPartyFrame_Generate()
	local frame = CompactPartyFrame;
	local didCreate = false;
	if not frame then
		frame = CreateFrame("Frame", "CompactPartyFrame", PartyFrame, "CompactPartyFrameTemplate");
		frame.flowSortFunc = CRFSort_Group;
		CompactRaidGroup_UpdateBorder(frame);
		PartyFrame:UpdatePaddingAndLayout();
		frame:RegisterEvent("GROUP_ROSTER_UPDATE");
		didCreate = true;
	end
	return frame, didCreate;
end
