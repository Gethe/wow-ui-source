function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	self.isParty = true;

	local unitFrame = _G[self:GetName().."Member1"];
	CompactUnitFrame_SetUnit(unitFrame, "player");
	CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");

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
	
	local groupFramesShown = (IsInGroup() and not IsInRaid()) or EditModeManagerFrame:ArePartyFramesForcedShown();
	local showCompactPartyFrame = groupFramesShown and EditModeManagerFrame:UseRaidStylePartyFrames();
	CompactPartyFrame:SetShown(showCompactPartyFrame);
	PartyFrame:UpdatePaddingAndLayout();
end

function CompactPartyFrame_RefreshMembers()
	if not CompactPartyFrame then
		return;
	end

	for i=2, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G["CompactPartyFrameMember"..i];

		local realPartyMemberToken;
		if IsInRaid() then
			realPartyMemberToken = "raid"..i;
		else
			realPartyMemberToken = "party"..(i-1);
		end
		local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(realPartyMemberToken);
		local unitToken = usePlayerOverride and "player" or realPartyMemberToken;

		CompactUnitFrame_SetUnit(unitFrame, unitToken);
		if not usePlayerOverride then
			CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
			CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
		end
	end

	CompactRaidGroup_UpdateBorder(CompactPartyFrame);
	PartyFrame:UpdatePaddingAndLayout();
end

function CompactPartyFrame_Generate()
	local frame = CompactPartyFrame;
	local didCreate = false;
	if not frame then
		frame = CreateFrame("Frame", "CompactPartyFrame", PartyFrame, "CompactPartyFrameTemplate");
		CompactRaidGroup_UpdateBorder(frame);
		PartyFrame:UpdatePaddingAndLayout();
		frame:RegisterEvent("GROUP_ROSTER_UPDATE");
		didCreate = true;
	end
	return frame, didCreate;
end
