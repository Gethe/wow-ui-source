--[[
	Mixins for each of the categories (sub-tabs) in the SpellBook

	Each category contains one or more spell groups, each spell group contains a range of slot indices, and each slot index maps to a specific spellbook item.
	Which spell book item is in a specific slot index will change as spells/talents are learned and unlearned.
	These category mixins primarily track & maintain spell group index data, and corresponding specific spell book items are determined on demand for display.
]]

--------------------------- Base Mixin --------------------------------

BaseSpellBookCategoryMixin = {};

function BaseSpellBookCategoryMixin:Init(spellBookFrame)
	self.spellBookFrame = spellBookFrame;
	self:UpdateSpellGroups();
end

function BaseSpellBookCategoryMixin:SetTabID(tabID)
	self.tabID = tabID;
end

function BaseSpellBookCategoryMixin:GetTabID()
	return self.tabID;
end

function BaseSpellBookCategoryMixin:GetName()
	return self.displayName;
end

function BaseSpellBookCategoryMixin:GetSpellBank()
	return self.spellBank;
end

function BaseSpellBookCategoryMixin:GetCategoryEnum()
	return self.categoryEnum;
end

function BaseSpellBookCategoryMixin:GetSpellGroupForSlotIndex(slotIndex)
	for _, spellGroup in ipairs(self.spellGroups) do
		if spellGroup.spellBookItemSlotIndices and spellGroup.spellBookItemSlotIndices[slotIndex] then
			return spellGroup;
		end
	end
	return nil;
end

function BaseSpellBookCategoryMixin:ContainsSlot(slotIndex, spellBank)
	if not self.spellGroups then
		return false;
	end

	if self.spellBank ~= spellBank then
		return false;
	end

	local containingSpellGroup = self:GetSpellGroupForSlotIndex(slotIndex);
	return containingSpellGroup ~= nil;
end

-- Creates a data for use with a PagedContent frame
-- byDataGroup: [bool] - See Blizzard_PagedContentFrame.lua -> SetDataProvider for details on expected group data format
-- itemFilterFunc: [func<bool>(slotIndex, spellBank)] - OPTIONAL - filter function that returns true if the passed SpellBookItem should be included in the data
-- tableToAppendTo: [table] OPTIONAL - Existing table that data tables should be appended to (rather than a newly created table)
function BaseSpellBookCategoryMixin:GetSpellBookItemData(byDataGroup, itemFilterFunc, tableToAppendTo)
	if not self.spellGroups then
		return nil;
	end

	local returnData = tableToAppendTo or {};
	for _, spellGroup in ipairs(self.spellGroups) do
		local dataGroup = byDataGroup and { elements = {} } or nil;
		if byDataGroup and spellGroup.displayName then
			dataGroup.header = {
				templateKey = "HEADER",
				text = spellGroup.displayName,
				spellGroup = spellGroup,
			};
		end
		for _, slotIndex in pairs(spellGroup.orderedSpellBookItemSlotIndices) do
			if not itemFilterFunc or itemFilterFunc(slotIndex, self.spellBank) then
				local itemEntry = self:GetElementDataForItem(slotIndex, self.spellBank, spellGroup);

				if byDataGroup then
					table.insert(dataGroup.elements, itemEntry);
				else
					table.insert(returnData, itemEntry);
				end
			end
		end
		if byDataGroup then
			table.insert(returnData, dataGroup);
		end
	end

	return returnData;
end

function BaseSpellBookCategoryMixin:GetElementDataForItem(slotIndex, spellBank, spellGroup)
	if not spellGroup then
		spellGroup = self:GetSpellGroupForSlotIndex(slotIndex);
	end
	if not spellGroup then
		return nil;
	end

	return {
		templateKey = "SPELL",
		slotIndex = slotIndex,
		spellBank = spellBank,
		specID = spellGroup.specID,
		isOffSpec = spellGroup.isOffSpec or false,
		showActionBarStatus = spellGroup.showActionBarStatuses,
	};
end

-- Returns true if any of the groups or index ranges within them changed between the old and new collection of groups
function BaseSpellBookCategoryMixin:DidSpellGroupsChange(oldSpellGroups, newSpellGroups, compareSpellIndicies)
	if oldSpellGroups == nil and newSpellGroups == nil then
		return false;
	elseif oldSpellGroups == nil or newSpellGroups == nil then
		return true;
	end

	local compareDepth = compareSpellIndicies and 3 or 2;
	local anyNonIndicesChanges = not tCompare(oldSpellGroups, newSpellGroups, compareDepth);

	return anyNonIndicesChanges;
end

-- Use to populate spell groups with contiguous spell book item indices based on a defined offset and count
function BaseSpellBookCategoryMixin:PopulateSpellGroupsIndiciesByRange()
	if not self.spellGroups then
		return;
	end

	for _, spellGroup in ipairs(self.spellGroups) do
		if spellGroup.numSpellBookItems and spellGroup.slotIndexOffset then
			spellGroup.spellBookItemSlotIndices = {}; -- Used for constant-time lookup of what indices the group contains
			spellGroup.orderedSpellBookItemSlotIndices = {}; -- Used for iterating over the indices in consistent order
			for i = 1, spellGroup.numSpellBookItems do
				local slotIndex = spellGroup.slotIndexOffset + i;
				spellGroup.spellBookItemSlotIndices[slotIndex] = true;
				spellGroup.orderedSpellBookItemSlotIndices[i] = slotIndex;
			end
		end
	end
end

-- Updates all spell groups within the category; Returns true if any groups or index ranges within them changed
function BaseSpellBookCategoryMixin:UpdateSpellGroups()
	-- Required
	assert(false);
end

-- Returns true if the category of spells is currently available to the player
function BaseSpellBookCategoryMixin:IsAvailable()
	-- Required
	assert(false);
end

-- Returns true if any of the category's spell groups contains spells belonging to the specified skill line
-- See Enum.SpellBookSkillLineIndex for example common skill lines
function BaseSpellBookCategoryMixin:ContainsSkillLine(skillLineIndex)
	-- Required
	assert(false);
end


--------------------------- Class and Specializations --------------------------------

SpellBookClassCategoryMixin = CreateFromMixins(BaseSpellBookCategoryMixin);

function SpellBookClassCategoryMixin:Init(spellBookFrame)
	self.displayName = PlayerUtil.GetClassName();
	self.spellBank = Enum.SpellBookSpellBank.Player;
	self.categoryEnum = PlayerSpellsUtil.SpellBookCategories.Class;

	BaseSpellBookCategoryMixin.Init(self, spellBookFrame);
end

function SpellBookClassCategoryMixin:UpdateSpellGroups()
	local newSpellGroups = {};

	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.Class);
	local classSpellsGroup = {
		displayName = skillLineInfo.name,
		slotIndexOffset = skillLineInfo.itemIndexOffset,
		numSpellBookItems = skillLineInfo.numSpellBookItems,
		skillLineIndex = Enum.SpellBookSkillLineIndex.Class,
		showActionBarStatuses = true,
		spellBookItemSlotIndices = {},
		orderedSpellBookItemSlotIndices = {},
	};
	table.insert(newSpellGroups, classSpellsGroup);

	local numSpecializations = GetNumSpecializations(false, false);
	local numAvailableSkillLines = C_SpellBook.GetNumSpellBookSkillLines();
	local firstSpecIndex = Enum.SpellBookSkillLineIndex.MainSpec;
	local maxSpecIndex = firstSpecIndex + numSpecializations;
	maxSpecIndex = math.min(numAvailableSkillLines, maxSpecIndex);

	for skillLineIndex = firstSpecIndex, maxSpecIndex do
		skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex);
		if skillLineInfo and not skillLineInfo.shouldHide then
			local specSpellsGroup = {
				displayName = skillLineInfo.name,
				slotIndexOffset = skillLineInfo.itemIndexOffset,
				numSpellBookItems = skillLineInfo.numSpellBookItems,
				isOffSpec = skillLineInfo.offSpecID ~= nil,
				specID = skillLineInfo.specID,
				skillLineIndex = skillLineIndex,
				showActionBarStatuses = skillLineInfo.offSpecID == nil,
				spellBookItemSlotIndices = {},
				orderedSpellBookItemSlotIndices = {},
			};
			table.insert(newSpellGroups, specSpellsGroup);
		end
	end

	local compareSpellIndicies = false;
	local anyChanges = self:DidSpellGroupsChange(self.spellGroups, newSpellGroups, compareSpellIndicies);

	if anyChanges then
		self.spellGroups = newSpellGroups;
		self:PopulateSpellGroupsIndiciesByRange();
	end

	return anyChanges;
end

function SpellBookClassCategoryMixin:IsAvailable()
	-- Category is always available
	return true;
end

function SpellBookClassCategoryMixin:ContainsSkillLine(skillLineIndex)
	if not self.spellGroups then
		return false;
	end

	for _, spellGroup in ipairs(self.spellGroups) do
		if spellGroup.skillLineIndex == skillLineIndex then
			return true;
		end
	end
end


--------------------------- General --------------------------------

SpellBookGeneralCategoryMixin = CreateFromMixins(BaseSpellBookCategoryMixin);

function SpellBookGeneralCategoryMixin:Init(spellBookFrame)
	self.displayName = GENERAL_SPELLS;
	self.spellBank = Enum.SpellBookSpellBank.Player;
	self.categoryEnum = PlayerSpellsUtil.SpellBookCategories.General;

	BaseSpellBookCategoryMixin.Init(self, spellBookFrame);
end

function SpellBookGeneralCategoryMixin:UpdateSpellGroups()
	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.General);
	local newSpellGroups = {
		{
			slotIndexOffset = skillLineInfo.itemIndexOffset,
			numSpellBookItems = skillLineInfo.numSpellBookItems,
			showActionBarStatuses = true,
			spellBookItemSlotIndices = {},
			orderedSpellBookItemSlotIndices = {},
		}
	};

	local compareSpellIndicies = false;
	local anyChanges = self:DidSpellGroupsChange(self.spellGroups, newSpellGroups, compareSpellIndicies);

	if anyChanges then
		self.spellGroups = newSpellGroups;
		self:PopulateSpellGroupsIndiciesByRange();
	end

	return anyChanges;
end

function SpellBookGeneralCategoryMixin:IsAvailable()
	-- Category is always available
	return true;
end

function SpellBookGeneralCategoryMixin:ContainsSkillLine(skillLineIndex)
	if not self.spellGroups then
		return false;
	end

	return skillLineIndex == Enum.SpellBookSkillLineIndex.General;
end


--------------------------- Pet --------------------------------

SpellBookPetCategoryMixin = CreateFromMixins(BaseSpellBookCategoryMixin);

function SpellBookPetCategoryMixin:Init(spellBookFrame)
	self.displayName = PET;
	self.spellBank = Enum.SpellBookSpellBank.Pet;
	self.categoryEnum = PlayerSpellsUtil.SpellBookCategories.Pet;

	BaseSpellBookCategoryMixin.Init(self, spellBookFrame);
end

function SpellBookPetCategoryMixin:UpdateSpellGroups()
	local numPetSpells = C_SpellBook.HasPetSpells() or 0;
	local newSpellGroups = {
		{
			slotIndexOffset = 0,
			numSpellBookItems = numPetSpells,
			showActionBarStatuses = true,
			spellBookItemSlotIndices = {},
			orderedSpellBookItemSlotIndices = {},
		}
	};

	local compareSpellIndicies = false;
	local anyChanges = self:DidSpellGroupsChange(self.spellGroups, newSpellGroups, compareSpellIndicies);

	if anyChanges then
		self.spellGroups = newSpellGroups;
		self:PopulateSpellGroupsIndiciesByRange();
	end

	return anyChanges;
end

function SpellBookPetCategoryMixin:IsAvailable()
	return C_SpellBook.HasPetSpells() and PetHasSpellbook();
end

function SpellBookPetCategoryMixin:ContainsSkillLine(skillLineIndex)
	return false;
end