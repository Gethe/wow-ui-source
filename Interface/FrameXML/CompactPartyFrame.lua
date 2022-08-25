function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	
	local unitFrame = _G[self:GetName().."Member1"];
	CompactUnitFrame_SetUnit(unitFrame, "player");
	CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
	
	CompactPartyFrame_RefreshMembers();
	
	self.title:SetText(PARTY);
	self.title:Disable();
end

function CompactPartyFrame_RefreshMembers()
	if not CompactPartyFrame then
		return;
	end

	for i=2, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G["CompactPartyFrameMember"..i];

		local realPartyMemberToken = "party"..(i-1);
		local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(realPartyMemberToken);
		local unitToken = usePlayerOverride and "player" or realPartyMemberToken;

		CompactUnitFrame_SetUnit(unitFrame, unitToken);
		if not usePlayerOverride then
			CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
			CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
		end
	end

	CompactRaidGroup_UpdateBorder(CompactPartyFrame);
end

function CompactPartyFrame_Generate()
	local frame = CompactPartyFrame;
	local didCreate = false;
	if not frame then
		frame = CreateFrame("Frame", "CompactPartyFrame", UIParent, "CompactPartyFrameTemplate");
		CompactRaidGroup_UpdateBorder(frame);
		frame:RegisterEvent("GROUP_ROSTER_UPDATE");
		didCreate = true;
	end
	return frame, didCreate;
end
