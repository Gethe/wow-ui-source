function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	self.isParty = true;

	for i=1, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G["CompactPartyFrameMember"..i];
		unitFrame.isParty = true;
	end
	
	CompactPartyFrame_RefreshMembers();
	
	self.title:SetText(PARTY);
	self.title:Disable();
end

function CompactPartyFrame_UpdateVisibility()
	if not CompactPartyFrame then
		return;
	end
	
	local isInArena = IsActiveBattlefieldArena();
	local groupFramesShown = (IsInGroup() and (isInArena or not IsInRaid())) or EditModeManagerFrame:ArePartyFramesForcedShown();
	local showCompactPartyFrame = groupFramesShown and EditModeManagerFrame:UseRaidStylePartyFrames();
	CompactPartyFrame:SetShown(showCompactPartyFrame);
	PartyFrame:UpdatePaddingAndLayout();
end

function CompactPartyFrame_RefreshMembers()
	if not CompactPartyFrame then
		return;
	end

	local units = {};

	if IsInRaid() then
		for i=1, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "raid"..i);
		end
	else
		table.insert(units, "player");

		for i=2, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "party"..(i-1));
		end
	end

	table.sort(units, CompactPartyFrame.flowSortFunc);

	for index, realPartyMemberToken in ipairs(units) do
		local unitFrame = _G["CompactPartyFrameMember"..index];

		local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(realPartyMemberToken);
		local unitToken = usePlayerOverride and "player" or realPartyMemberToken;

		CompactUnitFrame_SetUnit(unitFrame, unitToken);
		CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
	end

	CompactRaidGroup_UpdateBorder(CompactPartyFrame);
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
