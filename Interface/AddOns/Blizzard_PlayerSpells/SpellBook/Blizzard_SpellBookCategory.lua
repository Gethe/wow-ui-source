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

function BaseSpellBookCategoryMixin:ContainsSlot(slotIndex, spellBank)
	if not self.spellGroups then
		return false;
	end

	if self.spellBank ~= spellBank then
		return false;
	end

	for _, spellGroup in ipairs(self.spellGroups) do
		if slotIndex > spellGroup.slotIndexOffset and slotIndex <= (spellGroup.slotIndexOffset + spellGroup.numSpellBookItems) then
			return true;
		end
	end

	return false;
end

-- Creates a data provider for use with a PagedContent frame
-- See Blizzard_PagedContentFrame.lua -> SetDataProvider for details on expected group data format
function BaseSpellBookCategoryMixin:CreateDataProvider()
	if not self.spellGroups then
		return nil;
	end

	local kioskModeEnabled = Kiosk.IsEnabled();

	local dataGroups = {};
	for _, spellGroup in ipairs(self.spellGroups) do
		local dataGroup = { elements = {} };
		if spellGroup.displayName then
			dataGroup.header = {
				templateKey = "HEADER",
				text = spellGroup.displayName,
				spellGroup = spellGroup,
			};
		end
		for i = 1, spellGroup.numSpellBookItems do
			local slotIndex = spellGroup.slotIndexOffset + i;

			if self:CanShowIndex(slotIndex, kioskModeEnabled) then
				table.insert(dataGroup.elements, {
					templateKey = "SPELL",
					slotIndex = slotIndex,
					spellGroup = spellGroup,
					spellBank = self.spellBank,
				});
			end
			
		end
		table.insert(dataGroups, dataGroup);
	end

	return CreateDataProvider(dataGroups);
end

function BaseSpellBookCategoryMixin:CanShowIndex(slotIndex, kioskModeEnabled)
	if not kioskModeEnabled then
		return true;
	end
	
	-- If in Kiosk mode, filter out any future spells
	local spellBookItemType = C_SpellBook.GetSpellBookItemType(slotIndex, self.spellBank);
	if not spellBookItemType or spellBookItemType == Enum.SpellBookItemType.FutureSpell then
		return false;
	end
	return true;
end

-- Returns true if any of the groups or index ranges within them changed between the old and new collection of groups
function BaseSpellBookCategoryMixin:DidSpellGroupsChange(oldSpellGroups, newSpellGroups)
	if oldSpellGroups == nil and newSpellGroups == nil then
		return false;
	elseif oldSpellGroups == nil or newSpellGroups == nil then
		return true;
	end

	return not tCompare(oldSpellGroups, newSpellGroups, 2);
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
	local oldSpellGroups = self.spellGroups;

	self.spellGroups = {};

	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.Class);
	local classSpellsGroup = {
		displayName = skillLineInfo.name,
		slotIndexOffset = skillLineInfo.itemIndexOffset,
		numSpellBookItems = skillLineInfo.numSpellBookItems,
		skillLineIndex = Enum.SpellBookSkillLineIndex.Class,
		showActionBarstatuses = true,
	};
	table.insert(self.spellGroups, classSpellsGroup);

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
				showActionBarstatuses = skillLineInfo.offSpecID == nil,
			};
			table.insert(self.spellGroups, specSpellsGroup);
		end
		
	end

	return self:DidSpellGroupsChange(oldSpellGroups, self.spellGroups);
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
	local oldSpellGroups = self.spellGroups;

	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.General);
	self.spellGroups = {
		{
			slotIndexOffset = skillLineInfo.itemIndexOffset,
			numSpellBookItems = skillLineInfo.numSpellBookItems,
			showActionBarstatuses = false,
		}
	};

	return self:DidSpellGroupsChange(oldSpellGroups, self.spellGroups);
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
	local oldSpellGroups = self.spellGroups;

	local numPetSpells = C_SpellBook.HasPetSpells() or 0;
	self.spellGroups = {
		{
			slotIndexOffset = 0,
			numSpellBookItems = numPetSpells,
			showActionBarstatuses = true,
		}
	};

	return self:DidSpellGroupsChange(oldSpellGroups, self.spellGroups);
end

function SpellBookPetCategoryMixin:IsAvailable()
	return C_SpellBook.HasPetSpells() and PetHasSpellbook();
end

function SpellBookPetCategoryMixin:ContainsSkillLine(skillLineIndex)
	return false;
end