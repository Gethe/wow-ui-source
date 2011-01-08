function CompactPartyFrame_OnLoad(self)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_PET");
	
	self.applyFunc = CompactPartyFrame_ApplyFunctionToAllFrames;
	
	local unitFrame = _G[self:GetName().."Member1"];
	CompactUnitFrame_SetUnit(unitFrame, "player");
	CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUpdateAllEvent(unitFrame, "PARTY_MEMBERS_CHANGED");
	
	for i=1, MEMBERS_PER_RAID_GROUP do
		if ( i > 1 ) then	--Player has to be done separately.
			local unitFrame = _G[self:GetName().."Member"..i];
			CompactUnitFrame_SetUnit(unitFrame, "party"..(i-1));
			CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
			CompactUnitFrame_SetUpdateAllEvent(unitFrame, "PARTY_MEMBERS_CHANGED");
		end
		
		local petFrame = _G[self:GetName().."Pet"..i];
		CompactUnitFrame_SetUpFrame(petFrame, DefaultCompactMiniFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(petFrame, "PARTY_MEMBERS_CHANGED");
	end
	
	self.movable = true;
	self.title:SetText(PARTY);
	CompactPartyFrame_UpdateShown(self);
	CompactPartyFrame_ResetPosition(self);
end

function CompactPartyFrame_OnEvent(self, event, ...)
	if ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		CompactPartyFrame_UpdateShown(self);
	elseif ( event == "UNIT_PET" ) then
		local unit = ...;
		if ( unit == "player" ) then
			CompactUnitFrame_UpdateAll(_G[self:GetName().."Pet1"]);
		else
			local unitID = strmatch(unit, "party(%d+)");
			if ( unitID ) then
				local petFrame = _G[self:GetName().."Pet"..(tonumber(unitID) + 1)];
				CompactUnitFrame_UpdateAll(petFrame);
			end
		end
	end
end

function CompactPartyFrame_EnablePets(self)
	local petFrame = _G[self:GetName().."Pet1"];
	CompactUnitFrame_SetUnit(petFrame, "pet");
	
	for i=2, MEMBERS_PER_RAID_GROUP do
		local petFrame = _G[self:GetName().."Pet"..i];
		CompactUnitFrame_SetUnit(petFrame, "partypet"..(i-1));
	end
end

function CompactPartyFrame_DisablePets(self)	
	for i=1, MEMBERS_PER_RAID_GROUP do
		local petFrame = _G[self:GetName().."Pet"..i];
		CompactUnitFrame_SetUnit(petFrame, nil);
	end
end

function CompactPartyFrame_UpdateShown(self)
	if ( GetNumPartyMembers() > 0 and GetDisplayedAllyFrames() == "compact-party" ) then
		self:Show();
	else
		self:Hide();
	end
end

function CompactPartyFrame_ResetPosition(self)
	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", PartyMemberFrame1, "TOPLEFT", 0, 0);
end

function CompactPartyFrame_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...)
	if ( updateSpecifier == "normal" or updateSpecifier == "all" ) then
		for i=1, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName().."Member"..i];
			func(unitFrame, ...);
		end
	end
	if ( updateSpecifier == "mini" or updateSpecifier == "all" ) then
		for i=1, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName().."Pet"..i];
			func(unitFrame, ...);
		end
	end
	
	if ( updateSpecifier == "group" ) then
		func(frame, ...);
	end
end