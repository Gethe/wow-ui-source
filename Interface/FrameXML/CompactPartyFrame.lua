function CompactPartyFrame_OnLoad(self)
	self.applyFunc = CompactRaidGroup_ApplyFunctionToAllFrames;
	self.updateLayoutFunc = CompactPartyFrame_UpdateLayout;
	self.isParty = true;

	for i = 1, MEMBERS_PER_RAID_GROUP do
		local memberUnitFrame = _G["CompactPartyFrameMember"..i];
		memberUnitFrame.isParty = true;
	end

	for _, petUnitFrame in ipairs(self.petUnitFrames) do
		petUnitFrame.isParty = true;
	end

	CompactPartyFrame_RefreshMembers();

	self.title:SetText(PARTY);
	self.title:Disable();
end

function CompactPartyFrame_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...)
	CompactRaidGroup_ApplyFunctionToAllFrames(frame, updateSpecifier, func, ...);

	if updateSpecifier == "normal" or updateSpecifier == "all" then
		for _, petUnitFrame in ipairs(CompactPartyFrame.petUnitFrames) do
			func(petUnitFrame, ...);
		end
	end
end

function CompactPartyFrame_UpdateLayout(self)
	CompactRaidGroup_UpdateLayout(self);

	local petFramesAnchorRelativeTo;
	local width, height = self:GetSize();
	local isHorizontal = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(self.isParty);
	local isFirstShownPetFrame = true;

	for _, petUnitFrame in ipairs(CompactPartyFrame.petUnitFrames) do
		-- Update pet frame anchor
		if not petFramesAnchorRelativeTo then
			-- If we don't have a relativeTo anchor then
			-- A. Anchor to border frame if it's showing
			-- B. If horizontal, anchor to the BOTTOMLEFT of the first showing unit frame
			-- C. If Vertical, Anchor to the bottom of the last showing unit frame
			if CompactPartyFrame.borderFrame:IsShown() then
				petFramesAnchorRelativeTo = CompactPartyFrame.borderFrame;
			else
				if isHorizontal then
					-- Find first showing memberUnitFrame
					for i = 1, MEMBERS_PER_RAID_GROUP do
						local memberUnitFrame = _G["CompactPartyFrameMember"..i];
						if memberUnitFrame:IsShown() then
							petFramesAnchorRelativeTo = memberUnitFrame;
							break;
						end
					end
				else
					-- Find last showing memberUnitFrame
					for i = MEMBERS_PER_RAID_GROUP, 1, -1 do
						local memberUnitFrame = _G["CompactPartyFrameMember"..i];
						if memberUnitFrame:IsShown() then
							petFramesAnchorRelativeTo = memberUnitFrame;
							break;
						end
					end
				end

				-- Last resort
				if not petFramesAnchorRelativeTo then
					petFramesAnchorRelativeTo = self;
				end
			end
		end

		petUnitFrame:ClearAllPoints();
		if isHorizontal then
			if isFirstShownPetFrame then
				petUnitFrame:SetPoint("TOPLEFT", petFramesAnchorRelativeTo, "BOTTOMLEFT");
			else
				petUnitFrame:SetPoint("LEFT", petFramesAnchorRelativeTo, "RIGHT");
			end
		else
			petUnitFrame:SetPoint("TOP", petFramesAnchorRelativeTo, "BOTTOM");
		end

		-- Update frame size to account for pet frames
		if petUnitFrame:IsShown() then
			if isHorizontal then
				if isFirstShownPetFrame then
					-- In horizontal we place pet frame horizontally underneath the member unit frames.
					-- So we only need to add the pet frame height once since all pet frames after the first
					-- anchor horizontally to the other pet frames.
					height = height + petUnitFrame:GetHeight();
				end
			else
				width = math.max(width, petUnitFrame:GetWidth());
				height = height + petUnitFrame:GetHeight();
			end

			petFramesAnchorRelativeTo = petUnitFrame
			isFirstShownPetFrame = false;
		end
	end

	-- Account for padding from border frame when pet frames anchor to it
	if CompactPartyFrame.borderFrame:IsShown() then
		height = height + (isHorizontal and 8 or 5);
	end

	self:SetSize(width, height);
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

	-- Add pet units if we're set to display pets
	-- Pets should always appear at the bottom under the real players
	units = {};
	if CompactRaidFrameContainer.displayPets then
		if IsInRaid() then
			for i = 1, MEMBERS_PER_RAID_GROUP do
				table.insert(units, "raidpet"..i);
			end
		else
			--Add the player's pet.
			if UnitExists("pet") then
				table.insert(units, "pet");
			end
			for i = 1, GetNumSubgroupMembers() do
				table.insert(units, "partypet"..i);
			end
		end
		table.sort(units, CompactPartyFrame.flowSortFunc);
	end

	for i, petUnitFrame in ipairs(CompactPartyFrame.petUnitFrames) do
		CompactUnitFrame_SetUpFrame(petUnitFrame, DefaultCompactMiniFrameSetup);
		CompactUnitFrame_SetUnit(petUnitFrame, units[i]);
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "GROUP_ROSTER_UPDATE");
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "UNIT_PET");
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
