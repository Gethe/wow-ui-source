
local QuestionMarkIconFileDataID = 134400;

local NumActiveIconDataProviders = 0;
local BaseIconFilenames = nil;

-- Builds the table BaseIconFilenames with known spells followed by all icons (could be repeats)
local function IconDataProvider_RefreshIconTextures()
	if BaseIconFilenames ~= nil then
		return;
	end

	BaseIconFilenames = {};
	BaseIconFilenames[IconDataProviderIconType.Spell] = {};
	BaseIconFilenames[IconDataProviderIconType.Item] = {};
	GetLooseMacroIcons(BaseIconFilenames[IconDataProviderIconType.Spell]);
	GetLooseMacroItemIcons(BaseIconFilenames[IconDataProviderIconType.Item]);
	GetMacroIcons(BaseIconFilenames[IconDataProviderIconType.Spell]);
	GetMacroItemIcons(BaseIconFilenames[IconDataProviderIconType.Item]);
end

local function IconDataProvider_ClearIconTextures()
	BaseIconFilenames = nil;
	collectgarbage();
end

local function IconDataProvider_GetBaseIconTexture(iconType, index)
	local texture = BaseIconFilenames[iconType][index];
	local fileDataID = tonumber(texture);
	if fileDataID ~= nil then
		return fileDataID;
	else
		return [[INTERFACE\ICONS\]]..texture;
	end
end

function IconDataProvider_GetAllIconTypes()
	local iconTypeValues = GetValuesArray(IconDataProviderIconType);
	table.sort(iconTypeValues);
	return iconTypeValues;
end

IconDataProviderMixin = {};

IconDataProviderIconType = EnumUtil.MakeEnum(
	"Spell",
	"Item"
);

IconDataProviderExtraType = {
	Spellbook = 1,
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

function IconDataProviderMixin:Init(type, extraIconsOnly, requestedIconTypes)
	self.extraIcons = {};
	self.extraIconType = type;
	self.requestedIconTypes = requestedIconTypes or IconDataProvider_GetAllIconTypes(); -- Default to all icon types.

	if type == IconDataProviderExtraType.Spellbook then
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

function IconDataProviderMixin:SetIconTypes(iconTypes)
	self.requestedIconTypes = iconTypes or IconDataProvider_GetAllIconTypes();
end

function IconDataProviderMixin:GetNumIcons()
	-- 1 to account for the ? icon.
	local numIcons = 1;
	if (self:ShouldShowExtraIcons()) then
		numIcons = numIcons + #self.extraIcons;
	end
	if (BaseIconFilenames) then
		for _, v in pairs(self.requestedIconTypes) do
			numIcons = numIcons + #BaseIconFilenames[v];
		end
	end
	return numIcons;
end

function IconDataProviderMixin:GetIconByIndex(index)
	if index == 1 then
		return [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]];
	end

	index = index - 1;

	local numExtraIcons = self:ShouldShowExtraIcons() and #self.extraIcons or 0;
	if index <= numExtraIcons then
		return self.extraIcons[index];
	end

	local baseIndex = index - numExtraIcons;
	local lookupIconType = nil;
	-- Each icon type's table is indexed from 1, so loop through the tables to find which icon type we index to.
	for _, v in pairs(self.requestedIconTypes) do
		local numIconsForType = #BaseIconFilenames[v];
		if (baseIndex <= numIconsForType) then
			lookupIconType = v;
			break;
		end
		baseIndex = baseIndex - numIconsForType;
	end

	if (lookupIconType) then
		return IconDataProvider_GetBaseIconTexture(lookupIconType, baseIndex);
	else
		return nil;
	end
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

function IconDataProviderMixin:ShouldShowExtraIcons()
	return (self.extraIconType == IconDataProviderExtraType.Spellbook and tContains(self.requestedIconTypes, IconDataProviderIconType.Spell)) or (self.extraIconType == IconDataProviderExtraType.Equipment and tContains(self.requestedIconTypes, IconDataProviderIconType.Item))
end

function IconDataProviderMixin:Release()
	NumActiveIconDataProviders = NumActiveIconDataProviders - 1;

	if NumActiveIconDataProviders <= 0 then
		IconDataProvider_ClearIconTextures();
	end
end
