
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
	None = 1,
	Spellbook = 2,
	Equipment = 3,
	Transmog = 4
};

function IconDataProviderMixin:FillOutExtraIconsMapWithSpells(extraIconsMap)
	-- Overridden by game families.
end

function IconDataProviderMixin:FillOutExtraIconsMapWithTalents(extraIconsMap)
	-- Overridden by game families.
end

function IconDataProviderMixin:FillOutExtraIconsMapWithEquipment(extraIconsMap)
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemTexture = GetInventoryItemTexture("player", i);
		if itemTexture ~= nil then
			extraIconsMap[itemTexture] = true;
		end
	end
end

function IconDataProviderMixin:FillOutExtraIconsMapWithTransmog(extraIconsMap)
	-- Only populate if transmog frame is open. Reference the currently viewed outfit.
	if TransmogFrame and TransmogFrame:IsShown() then
		local outfitIcons = TransmogFrame:GetViewedOutfitIcons();
		for _index, outfitIcon in ipairs(outfitIcons) do
			extraIconsMap[outfitIcon] = true;
		end
	end
end

function IconDataProviderMixin:Init(type, extraIconsOnly, requestedIconTypes)
	self.extraIcons = {};
	self.extraIconType = type;
	self.requestedIconTypes = requestedIconTypes or IconDataProvider_GetAllIconTypes(); -- Default to all icon types.

	if type == IconDataProviderExtraType.Spellbook then
		local extraIconsMap = {};
		self:FillOutExtraIconsMapWithSpells(extraIconsMap);
		self:FillOutExtraIconsMapWithTalents(extraIconsMap);
		self.extraIcons = GetKeysArray(extraIconsMap);
	elseif type == IconDataProviderExtraType.Equipment then
		local extraIconsMap = {};
		self:FillOutExtraIconsMapWithEquipment(extraIconsMap);
		self.extraIcons = GetKeysArray(extraIconsMap);
	elseif type == IconDataProviderExtraType.Transmog then
		local extraIconsMap = {};
		self:FillOutExtraIconsMapWithTransmog(extraIconsMap);
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

function IconDataProviderMixin:GetRandomIcon()
	local numIcons = self:GetNumIcons();
	local avoidQuestionMarkIndex = 2;
	return self:GetIconByIndex(math.random(avoidQuestionMarkIndex, numIcons));
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
	local showExtraIcons = false;

	if self.extraIconType == IconDataProviderExtraType.Spellbook then
		showExtraIcons = tContains(self.requestedIconTypes, IconDataProviderIconType.Spell);
	elseif self.extraIconType == IconDataProviderExtraType.Equipment then
		showExtraIcons = tContains(self.requestedIconTypes, IconDataProviderIconType.Item);
	elseif self.extraIconType == IconDataProviderExtraType.Transmog then
		showExtraIcons = tContains(self.requestedIconTypes, IconDataProviderIconType.Item);
	end

	return showExtraIcons;
end

function IconDataProviderMixin:Release()
	NumActiveIconDataProviders = NumActiveIconDataProviders - 1;

	if NumActiveIconDataProviders <= 0 then
		IconDataProvider_ClearIconTextures();
	end
end
