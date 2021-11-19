function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	
	local unitFrame = _G[self:GetName().."Member1"];
	CompactUnitFrame_SetUnit(unitFrame, "player");
	CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
	
	for i=1, MEMBERS_PER_RAID_GROUP do
		if ( i > 1 ) then	--Player has to be done separately.
			local unitFrame = _G[self:GetName().."Member"..i];
			CompactUnitFrame_SetUnit(unitFrame, "party"..(i-1));
			CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
			CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
		end
	end
	
	self.title:SetText(PARTY);
	self.title:Disable();
end

function CompactPartyFrame_Generate()
	local frame = CompactPartyFrame;
	local didCreate = false;
	if ( not frame ) then
		frame = CreateFrame("Frame", "CompactPartyFrame", UIParent, "CompactPartyFrameTemplate");
		CompactRaidGroup_UpdateBorder(frame);
		didCreate = true;
	end
	return frame, didCreate;
end
