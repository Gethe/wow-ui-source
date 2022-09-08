
local QuestionMarkIconFileDataID = 134400;

local NumActiveIconDataProviders = 0;
local BaseIconFilenames = nil;

-- Builds the table BaseIconFilenames with known spells followed by all icons (could be repeats)
local function IconDataProvider_RefreshIconTextures()
	if BaseIconFilenames ~= nil then
		return;
	end

	BaseIconFilenames = {};
	GetLooseMacroIcons(BaseIconFilenames);
	GetLooseMacroItemIcons(BaseIconFilenames);
	GetMacroIcons(BaseIconFilenames);
	GetMacroItemIcons(BaseIconFilenames);
end

local function IconDataProvider_ClearIconTextures()
	BaseIconFilenames = nil;
	collectgarbage();
end

local function IconDataProvider_GetBaseIconTexture(index)
	local texture = BaseIconFilenames[index];
	local fileDataID = tonumber(texture);
	if fileDataID ~= nil then
		return fileDataID;
	else
		return [[INTERFACE\ICONS\]]..texture;
	end
end


IconDataProviderMixin = {};

IconDataProviderExtraType = {
	Spell = 1,
	Equipment = 2,
	None = 3,
};

local function FillOutExtraIconsMapWithSpells(extraIconsMap)
	for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells;
		for j = offset, tabEnd - 1 do
			local spellType, ID = GetSpellBookItemInfo(j, "player");
			if spellType ~= "FUTURESPELL" then
				local fileID = GetSpellBookItemTexture(j, "player");
				if fileID ~= nil then
					extraIconsMap[fileID] = true;
				end
			end

			if spellType == "FLYOUT" then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
				if isKnown and (numSlots > 0) then
					for k = 1, numSlots do
						local spellID, overrideSpellID, isSlotKnown = GetFlyoutSlotInfo(ID, k)
						if isSlotKnown then
							local fileID = GetSpellTexture(spellID);
							if fileID ~= nil then
								extraIconsMap[fileID] = true;
							end
						end
					end
				end
			end
		end
	end
end

local function FillOutExtraIconsMapWithTalents(extraIconsMap)
	local isInspect = false;
	for specIndex = 1, GetNumSpecGroups(isInspect) do
		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local icon = select(3, GetTalentInfo(tier, column, specIndex));
				if icon ~= nil then
					extraIconsMap[icon] = true;
				end
			end
		end
	end

	for pvpTalentSlot = 1, 3 do
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(pvpTalentSlot);
		if slotInfo ~= nil then
			for i, pvpTalentID in ipairs(slotInfo.availableTalentIDs) do
				local icon = select(3, GetPvpTalentInfoByID(pvpTalentID));
				if icon ~= nil then
					extraIconsMap[icon] = true;
				end
			end
		end
	end
end

local function FillOutExtraIconsMapWithEquipment(extraIconsMap)
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemTexture = GetInventoryItemTexture("player", i);
		if itemTexture ~= nil then
			extraIconsMap[itemTexture] = true;
		end
	end
end

function IconDataProviderMixin:Init(type, extraIconsOnly)
	self.extraIcons = {};

	if type == IconDataProviderExtraType.Spell then
		local extraIconsMap = {};
		FillOutExtraIconsMapWithSpells(extraIconsMap);
		FillOutExtraIconsMapWithTalents(extraIconsMap);
		self.extraIcons = GetKeysArray(extraIconsMap);
	elseif type == IconDataProviderExtraType.Equipment then
		local extraIconsMap = {};
		FillOutExtraIconsMapWithEquipment(extraIconsMap);
		self.extraIcons = GetKeysArray(extraIconsMap);
	end

	if not extraIconsOnly then
		NumActiveIconDataProviders = NumActiveIconDataProviders + 1;
		IconDataProvider_RefreshIconTextures();
	end
end

function IconDataProviderMixin:GetNumIcons()
	-- 1 to account for the ? icon.
	local numBaseIcons = BaseIconFilenames and #BaseIconFilenames or 0;
	return 1 + #self.extraIcons + numBaseIcons;
end

function IconDataProviderMixin:GetIconByIndex(index)
	if index == 1 then
		return [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]];
	end

	index = index - 1;

	local numExtraIcons = #self.extraIcons;
	if index <= numExtraIcons then
		return self.extraIcons[index];
	end

	local baseIndex = index - numExtraIcons;
	return IconDataProvider_GetBaseIconTexture(baseIndex);
end

function IconDataProviderMixin:GetIconForSaving(index)
	local icon = self:GetIconByIndex(index);
	if type(icon) == "string" then
		icon = string.gsub(icon, [[INTERFACE\ICONS\]], "");
	end

	return icon;
end

function IconDataProviderMixin:GetIndexOfIcon(icon)
	if icon == QuestionMarkIconFileDataID then
		return 1;
	end

	local numIcons = self:GetNumIcons();
	for i = 1, numIcons do
		if self:GetIconByIndex(i) == icon then
			return i;
		end
	end

	return nil;
end

function IconDataProviderMixin:Release()
	NumActiveIconDataProviders = NumActiveIconDataProviders - 1;

	if NumActiveIconDataProviders <= 0 then
		IconDataProvider_ClearIconTextures();
	end
end
