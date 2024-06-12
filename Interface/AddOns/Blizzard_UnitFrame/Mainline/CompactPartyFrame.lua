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

CompactPartyFrameMixin = {};

function CompactPartyFrameMixin:OnLoad()
	self.applyFunc = self.ApplyFunctionToAllFrames;
	self.updateLayoutFunc = self.UpdateLayout;

	for _, memberUnitFrame in ipairs(self.memberUnitFrames) do
		memberUnitFrame.groupType = self.groupType;
	end

	for _, petUnitFrame in ipairs(self.petUnitFrames) do
		petUnitFrame.groupType = self.groupType;
	end

	self:RefreshMembers();

	self.title:SetText(self.titleText);
	self.title:Disable();
end

function CompactPartyFrameMixin:OnEvent()
	self:RefreshMembers();
end

function CompactPartyFrameMixin:ApplyFunctionToAllFrames(updateSpecifier, func, ...)
	CompactRaidGroup_ApplyFunctionToAllFrames(self, updateSpecifier, func, ...);

	if updateSpecifier == "mini" or updateSpecifier == "all" then
		for _, petUnitFrame in ipairs(self.petUnitFrames) do
			func(petUnitFrame, ...);
		end
	end
end

function CompactPartyFrameMixin:SetFlowSortFunction(flowSortFunc)
	self.flowSortFunc = flowSortFunc;
	self:RefreshMembers();
end

function CompactPartyFrameMixin:UpdateLayout()
	CompactRaidGroup_UpdateLayout(self);

	local petFramesAnchorRelativeTo;
	local width, height = self:GetSize();
	local isHorizontal = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(self.groupType);
	local isFirstShownPetFrame = true;

	for _, petUnitFrame in ipairs(self.petUnitFrames) do
		-- Update pet frame anchor
		if not petFramesAnchorRelativeTo then
			-- If we don't have a relativeTo anchor then
			-- A. Anchor to border frame if it's showing
			-- B. If horizontal, anchor to the BOTTOMLEFT of the first showing unit frame
			-- C. If Vertical, Anchor to the bottom of the last showing unit frame
			if self.borderFrame:IsShown() then
				petFramesAnchorRelativeTo = self.borderFrame;
			else
				if isHorizontal then
					-- Find first showing memberUnitFrame
					for _, memberUnitFrame in ipairs(self.memberUnitFrames) do
						if memberUnitFrame:IsShown() then
							petFramesAnchorRelativeTo = memberUnitFrame;
							break;
						end
					end
				else
					-- Find last showing memberUnitFrame
					for i = #self.memberUnitFrames, 1, -1 do
						local memberUnitFrame = self.memberUnitFrames[i];
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

			-- Account for padding from border frame when pet frames anchor to it
			if isFirstShownPetFrame and self.borderFrame:IsShown() then
				height = height + (isHorizontal and 8 or 5);
			end

			petFramesAnchorRelativeTo = petUnitFrame
			isFirstShownPetFrame = false;
		end
	end

	self:SetSize(width, height);
end

function CompactPartyFrameMixin:ShouldShow()
	return ShouldShowPartyFrames() and EditModeManagerFrame:UseRaidStylePartyFrames();
end

-- Override this in overriding mixins
function CompactPartyFrameMixin:UpdateVisibility()
	self:SetShown(self:ShouldShow());
	PartyFrame:UpdatePaddingAndLayout();
end

-- Override this in overriding mixins
function CompactPartyFrameMixin:RefreshMembers()
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
	table.sort(units, self.flowSortFunc);

	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(units[i]);
		local unitToken = usePlayerOverride and "player" or units[i];

		CompactUnitFrame_SetUpFrame(memberUnitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUnit(memberUnitFrame, unitToken);
		CompactUnitFrame_SetUpdateAllEvent(memberUnitFrame, "GROUP_ROSTER_UPDATE");
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
		table.sort(units, self.flowSortFunc);
	end

	for i, petUnitFrame in ipairs(self.petUnitFrames) do
		CompactUnitFrame_SetUpFrame(petUnitFrame, DefaultCompactMiniFrameSetup);
		CompactUnitFrame_SetUnit(petUnitFrame, units[i]);
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "GROUP_ROSTER_UPDATE");
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "UNIT_PET");
	end

	self:updateLayoutFunc();
	PartyFrame:UpdatePaddingAndLayout();
end