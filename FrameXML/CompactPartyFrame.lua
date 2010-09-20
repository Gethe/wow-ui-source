function CompactPartyFrame_OnLoad(self)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	
	local unitFrame = _G[self:GetName().."Member1"];
	CompactUnitFrame_SetUnit(unitFrame, "player");
	CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUpdateAllEvent(unitFrame, "PARTY_MEMBERS_CHANGED");
	
	for i=2, MEMBERS_PER_RAID_GROUP do
		local unitFrame = _G[self:GetName().."Member"..i];
		CompactUnitFrame_SetUnit(unitFrame, "party"..(i-1));
		CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(unitFrame, "PARTY_MEMBERS_CHANGED");
	end
	
	self.movable = true;
	self.title:SetText(PARTY);
	CompactPartyFrame_UpdateShown(self);
	CompactPartyFrame_ResetPosition(self);
end

function CompactPartyFrame_OnEvent(self, event, ...)
	if ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		CompactPartyFrame_UpdateShown(self);
	end
end

function CompactPartyFrame_UpdateShown(self)
	if ( GetCVarBool("useCompactPartyFrames") and GetNumPartyMembers() > 0 and GetNumRaidMembers() == 0 ) then
		self:Show();
	else
		self:Hide();
	end
end

function CompactPartyFrame_ResetPosition(self)
	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", PartyMemberFrame1, "TOPLEFT", 0, 0);
end
