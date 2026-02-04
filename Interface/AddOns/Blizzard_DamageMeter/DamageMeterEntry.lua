DamageMeterEntryMixin = {};

function DamageMeterEntryMixin:GetIcon()
	return self.Icon.Icon;
end

function DamageMeterEntryMixin:GetStatusBar()
	return self.StatusBar;
end

function DamageMeterEntryMixin:GetStatusBarTexture()
	return self:GetStatusBar():GetStatusBarTexture();
end

function DamageMeterEntryMixin:GetName()
	return self:GetStatusBar().Name;
end

function DamageMeterEntryMixin:GetValue()
	return self:GetStatusBar().Value;
end

function DamageMeterEntryMixin:GetBackground()
	return self:GetStatusBar().Background;
end

function DamageMeterEntryMixin:GetBackgroundEdge()
	return self:GetStatusBar().BackgroundEdge;
end

function DamageMeterEntryMixin:GetBackgroundRegions()
	return self:GetStatusBar().BackgroundRegions;
end

function DamageMeterEntryMixin:GetIconAtlasElement()
	-- Override as necessary.
end

function DamageMeterEntryMixin:GetIconTexture()
	-- Override as necessary.
end

function DamageMeterEntryMixin:UpdateIcon()
	local atlasElement = self:GetIconAtlasElement();
	if atlasElement then
		if atlasElement ~= self.iconAtlasElement then
			self.iconAtlasElement = atlasElement;
			self.iconTexture = nil;
			self:GetIcon():SetAtlas(atlasElement);
		end
	else
		local texture = self:GetIconTexture();
		if texture ~= self.iconTexture then
			self.iconTexture = texture;
			self.iconAtlasElement = nil;
			self:GetIcon():SetTexture(texture);
		end
	end
end

function DamageMeterEntryMixin:GetClassificationAtlasElement()
	-- Using same logic as NamePlateClassificationFrameMixin
	if self.classification == "elite" or self.classification == "worldboss" then
		return "nameplates-icon-elite-gold";
	elseif self.classification == "rare" then
		return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star";
	elseif self.classification == "rareelite" then
		return "nameplates-icon-elite-silver";
	end

	return nil;
end

function DamageMeterEntryMixin:GetNameText()
	-- Override as necessary.
end

function DamageMeterEntryMixin:UpdateName()
	local text = self:GetNameText();
	if text ~= self.nameText then
		self.nameText = text;
		self:GetName():SetText(text);
	end
end

function DamageMeterEntryMixin:ShowsValuePerSecondAsPrimary()
	return self.showsValuePerSecondAsPrimary == true;
end

local function GetEntryValueText(value, parentheticalValue, percentageValue)
	if percentageValue then
		return DAMAGE_METER_ENTRY_FORMAT_COMPLETE:format(AbbreviateLargeNumbers(value), AbbreviateLargeNumbers(parentheticalValue), Round(percentageValue * 100));
	elseif parentheticalValue then
		return DAMAGE_METER_ENTRY_FORMAT_COMPACT:format(AbbreviateLargeNumbers(value), AbbreviateLargeNumbers(parentheticalValue));
	else
		return DAMAGE_METER_ENTRY_FORMAT_MINIMAL:format(AbbreviateLargeNumbers(value));
	end
end

local function GetMainValue(entry)
	if entry.valuePerSecond and entry:ShowsValuePerSecondAsPrimary() then
		return entry.valuePerSecond;
	end

	if entry.value then
		return entry.value;
	end

	return 0;
end

local function GetParentheticalValue(entry)
	if entry.value and entry:ShowsValuePerSecondAsPrimary() then
		return entry.value;
	end

	if entry.valuePerSecond then
		return entry.valuePerSecond;
	end

	return 0;
end

local function GetPercentageValue(entry)
	if entry.value and entry.sessionTotalValue and entry.sessionTotalValue > 0 then
		return entry.value / entry.sessionTotalValue;
	end

	return 0;
end

local numberDisplayTypeFormatters =
{
	[Enum.DamageMeterNumbers.Minimal] = function(entry) return GetEntryValueText(GetMainValue(entry)); end,
	[Enum.DamageMeterNumbers.Compact] = function(entry) return GetEntryValueText(GetMainValue(entry), GetParentheticalValue(entry)); end,
	[Enum.DamageMeterNumbers.Complete] = function(entry) return GetEntryValueText(GetMainValue(entry), GetParentheticalValue(entry), GetPercentageValue(entry)); end,
}

function DamageMeterEntryMixin:GetValueText()
	return numberDisplayTypeFormatters[self:GetNumberDisplayType()](self);
end

function DamageMeterEntryMixin:UpdateValue()
	local text = self:GetValueText();
	self:GetValue():SetText(text);
end

function DamageMeterEntryMixin:GetMaxStatusValue()
	return self.maxValue or 0;
end

function DamageMeterEntryMixin:GetStatusValue()
	return self.value or 0;
end

function DamageMeterEntryMixin:UpdateStatusBar()
	self:GetStatusBar():SetMinMaxValues(0, self:GetMaxStatusValue());
	self:GetStatusBar():SetValue(self:GetStatusValue());
end

function DamageMeterEntryMixin:SetupSharedStyleAnchors()
	self:GetStatusBar():ClearAllPoints();
	self:GetName():ClearAllPoints();
	self:GetValue():ClearAllPoints();
end

function DamageMeterEntryMixin:GetIconAttachmentAnchor()
	local point = "LEFT";
	local relativeTo = self;
	local relativePoint = "LEFT";
	local x = 0;
	local y = 0;

	if self:ShouldShowBarIcons() then
		local style = self:GetStyle();

		relativeTo = self:GetIcon();
		relativePoint = "RIGHT";

		if style == Enum.DamageMeterStyle.Bordered or style == Enum.DamageMeterStyle.Thin then
			x = 5;
		end
	end

	return point, relativeTo, relativePoint, x, y;
end

function DamageMeterEntryMixin:GetBackgroundAtlasForStyle(style)
	if style == Enum.DamageMeterStyle.Bordered then
		return "UI-HUD-CoolDownManager-Bar-BG";
	else
		return "ui-damagemeters-bar-shadowbg";
	end
end

function DamageMeterEntryMixin:GetBackgroundInsetsForStyle(style)
	-- Returns are left, top, right, bottom anchor point offsets.

	if style == Enum.DamageMeterStyle.Bordered then
		return -2, 2, 6, -7;
	else
		return -2, 2, 2, -2;
	end
end

function DamageMeterEntryMixin:GetBackgroundEdgeVisibilityForStyle(style)
	if style == Enum.DamageMeterStyle.Bordered then
		return false;
	else
		return true;
	end
end

function DamageMeterEntryMixin:SetupSharedStyleIconVisibility()
	self:GetIcon():SetShown(self:ShouldShowBarIcons());
end

function DamageMeterEntryMixin:SetupSharedStyleBackground()
	local style = self:GetStyle();
	local left, top, right, bottom = self:GetBackgroundInsetsForStyle(style);

	local background = self:GetBackground();
	local backgroundEdge = self:GetBackgroundEdge();

	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", left, top);
	background:SetPoint("BOTTOMRIGHT", right, bottom);
	background:SetAtlas(self:GetBackgroundAtlasForStyle(style));

	backgroundEdge:SetShown(self:GetBackgroundEdgeVisibilityForStyle(style));
end

function DamageMeterEntryMixin:SetupDefaultStyle()
	self:SetupSharedStyleAnchors();
	self:SetupSharedStyleBackground();
	self:SetupSharedStyleIconVisibility();

	local name = self:GetName();
	local statusBar = self:GetStatusBar();
	local value = self:GetValue();

	statusBar:SetPoint(self:GetIconAttachmentAnchor());
	statusBar:SetPoint("TOP", 0, -1);
	statusBar:SetPoint("BOTTOMRIGHT", -4, 1);

	name:SetPoint("LEFT", 5, 0);
	name:SetPoint("RIGHT", self:GetValue(), "LEFT", -25, 0);

	value:SetPoint("RIGHT", -8, 0);
end

function DamageMeterEntryMixin:SetupBorderedStyle()
	self:SetupDefaultStyle();
end

function DamageMeterEntryMixin:SetupFullBackgroundStyle()
	self:SetupDefaultStyle();
end

function DamageMeterEntryMixin:SetupThinStyle()
	self:SetupSharedStyleAnchors();
	self:SetupSharedStyleBackground();
	self:SetupSharedStyleIconVisibility();

	local name = self:GetName();
	local statusBar = self:GetStatusBar();
	local value = self:GetValue();

	statusBar:SetPoint(self:GetIconAttachmentAnchor());
	statusBar:SetPoint("TOP", name, "BOTTOM", 0, 0);
	statusBar:SetPoint("BOTTOMRIGHT", 0, 1);

	name:SetPoint("TOP", self, "TOP", 0, 0);
	name:SetPoint(self:GetIconAttachmentAnchor());
	name:SetPoint("RIGHT", value, "LEFT", -25, 0);

	value:SetPoint("TOP", self, "TOP", 0, 0);
	value:SetPoint("RIGHT", self, "RIGHT", -8, 0);
end

function DamageMeterEntryMixin:UpdateStyle()
	local style = self:GetStyle();

	if style == Enum.DamageMeterStyle.Default then
		self:SetupDefaultStyle();
	elseif style == Enum.DamageMeterStyle.Bordered then
		self:SetupBorderedStyle();
	elseif style == Enum.DamageMeterStyle.FullBackground then
		self:SetupFullBackgroundStyle();
	elseif style == Enum.DamageMeterStyle.Thin then
		self:SetupThinStyle();
	else
		assertsafe(false, "unhandled damage meter style: %s", style);
	end
end

function DamageMeterEntryMixin:GetDefaultStatusBarColor()
	return DAMAGE_METER_STATUS_BAR_DEFAULT_COLOR;
end

function DamageMeterEntryMixin:GetCreatureStatusBarColor()
	return DAMAGE_METER_STATUS_BAR_CREATURE_COLOR;
end

function DamageMeterEntryMixin:GetStatusBarColor()
	local r, g, b = self:GetStatusBarTexture():GetVertexColor();
	return CreateColor(r, g, b);
end

function DamageMeterEntryMixin:SetStatusBarColor(color)
	if color ~= self.statusBarColor then
		self.statusBarColor = color;
		self:GetStatusBarTexture():SetVertexColor(color:GetRGB());
	end
end

function DamageMeterEntryMixin:GetDesiredBarColor()
	if self.isClassColorDesired then
		if self:IsCreature() then
			return self:GetCreatureStatusBarColor();
		end

		local classFilename = self.classFilename or self.unitClassFilename;
		if classFilename then
			return RAID_CLASS_COLORS[classFilename] or self:GetDefaultStatusBarColor();
		end
	end

	return self:GetDefaultStatusBarColor();
end

function DamageMeterEntryMixin:SetUseClassColor(useClassColor)
	self.isClassColorDesired = useClassColor;
	self:UpdateStatusBarColor();
end

function DamageMeterEntryMixin:UpdateStatusBarColor()
	self:SetStatusBarColor(self:GetDesiredBarColor());
end

function DamageMeterEntryMixin:GetBarHeight()
	return self:GetHeight();
end

function DamageMeterEntryMixin:SetBarHeight(barHeight)
	self:SetHeight(barHeight);
end

function DamageMeterEntryMixin:GetTextScale()
	-- We assume that all fontstrings are re-scaled equally. If this one day
	-- changes, SetTextScale should instead store the size as a field that can
	-- be returned here.

	return self:GetName():GetTextScale();
end

function DamageMeterEntryMixin:SetTextScale(textScale)
	self:GetName():SetTextScale(textScale);
	self:GetValue():SetTextScale(textScale);
end

function DamageMeterEntryMixin:ShouldShowBarIcons()
	return self.showBarIcons;
end

function DamageMeterEntryMixin:SetShowBarIcons(showBarIcons)
	self.showBarIcons = (showBarIcons == true);
	self:UpdateStyle();
end

function DamageMeterEntryMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterEntryMixin:SetStyle(style)
	self.style = style;
	self:UpdateBackground();
	self:UpdateStyle();
end

function DamageMeterEntryMixin:GetNumberDisplayType()
	return self.numberDisplayType or Enum.DamageMeterNumbers.Minimal;
end

function DamageMeterEntryMixin:SetNumberDisplayType(numberDisplayType)
	self.numberDisplayType = numberDisplayType;
	self:UpdateValue();
end

function DamageMeterEntryMixin:GetBackgroundAlpha()
	return self.backgroundAlpha or 1;
end

function DamageMeterEntryMixin:SetBackgroundAlpha(alpha)
	self.backgroundAlpha = alpha;
	self:UpdateBackground();
end

function DamageMeterEntryMixin:GetBackgroundRegionAlpha()
	--[[
	-- Previous behavior
	local style = self:GetStyle();

	if style == Enum.DamageMeterStyle.FullBackground then
		-- The full background style uses a background asset on the parent
		-- frame instead.
		return 0;
	elseif style == Enum.DamageMeterStyle.Bordered then
		-- Art for the bordered style reuses an asset that doesn't permit
		-- customization of background transparency.
		return 1;
	else
		return self:GetBackgroundAlpha();
	end
	--]]

	return 1; -- Only controlled by container frame opacity now.
end

function DamageMeterEntryMixin:UpdateBackground()
	local alpha = self:GetBackgroundRegionAlpha();

	for _, region in ipairs(self:GetBackgroundRegions()) do
		region:SetAlpha(alpha);
	end
end

function DamageMeterEntryMixin:Init(source)
	self.value = source.totalAmount;
	self.valuePerSecond = source.amountPerSecond;
	self.maxValue = source.maxAmount;
	self.sessionTotalValue = source.sessionTotalAmount;
	self.index = source.index;
	self.showsValuePerSecondAsPrimary = source.showsValuePerSecondAsPrimary;

	self:UpdateIcon();
	self:UpdateName();
	self:UpdateValue();
	self:UpdateStatusBar();
	self:UpdateStatusBarColor();
end

function DamageMeterEntryMixin:IsCreature()
	return false;
end

DamageMeterSourceEntryMixin = {}

function DamageMeterSourceEntryMixin:Init(combatSource)
	self.sourceName = combatSource.name;
	self.isLocalPlayer = combatSource.isLocalPlayer;
	self.classFilename = combatSource.classFilename;
	self.specIconID = combatSource.specIconID;
	self.deathRecapID = combatSource.deathRecapID;
	self.deathTimeSeconds = combatSource.deathTimeSeconds;
	self.isCreature = combatSource.sourceCreatureID ~= nil;
	self.classification = combatSource.classification;

	DamageMeterEntryMixin.Init(self, combatSource);
end

function DamageMeterSourceEntryMixin:IsCreature()
	return self.isCreature;
end

function DamageMeterSourceEntryMixin:GetIconAtlasElement()
	-- If spec is set it takes precedence over class.
	if self.specIconID and self.specIconID ~= 0 then
		return nil;
	end

	if not self.classFilename then
		return nil;
	end

	return GetClassAtlas(self.classFilename);
end

function DamageMeterEntryMixin:GetIconTexture()
	return self.specIconID;
end

function DamageMeterEntryMixin:GetFormattedSourceNameText()
	-- Insert the classification image if its provided.
	local classificationAtlasElement = self:GetClassificationAtlasElement();
	if classificationAtlasElement then
		local atlasMarkup = CreateAtlasMarkup(classificationAtlasElement);
		return string.format("%s %s", atlasMarkup, self.sourceName);
	end

	return self.sourceName;
end

function DamageMeterSourceEntryMixin:GetNameText()
	if self.deathRecapID and self.deathRecapID ~= 0 then
		return self.sourceName;
	end

	local formattedSourceName = self:GetFormattedSourceNameText();
	return DAMAGE_METER_SOURCE_NAME:format(self.index, formattedSourceName);
end

function DamageMeterSourceEntryMixin:GetMaxStatusValue()
	if self.deathRecapID and self.deathRecapID ~= 0 then
		return 1;
	end

	return DamageMeterEntryMixin.GetMaxStatusValue(self);
end

function DamageMeterSourceEntryMixin:GetStatusValue()
	if self.deathRecapID and self.deathRecapID ~= 0 then
		return 1;
	end

	return DamageMeterEntryMixin.GetStatusValue(self);
end

-- Format death time as "3m 22s"
local deathTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
deathTimeFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, false);
deathTimeFormatter:SetDesiredUnitCount(2);
deathTimeFormatter:SetMinInterval(SecondsFormatter.Interval.Seconds);

function DamageMeterSourceEntryMixin:GetValueText()
	if self.deathRecapID and self.deathRecapID ~= 0 then
		-- no timestamps for overall session
		if self.deathTimeSeconds == -1 then
			return "";
		end

		local totalSeconds = self.deathTimeSeconds or 0;
		return deathTimeFormatter:Format(totalSeconds);
	end

	return DamageMeterEntryMixin.GetValueText(self);
end

DamageMeterSpellEntryMixin = {};

function DamageMeterSpellEntryMixin:Init(combatSpell)
	self.spellID = combatSpell.spellID;
	self.creatureName = combatSpell.creatureName;
	self.unitName = combatSpell.combatSpellDetails.unitName;
	self.classification = combatSpell.combatSpellDetails.classification;
	self.unitClassFilename = combatSpell.combatSpellDetails.unitClassFilename;
	self.isPet = combatSpell.combatSpellDetails.isPet;
	self.isMob = combatSpell.combatSpellDetails.isMob;
	self.classFilename = combatSpell.classFilename;
	self.specIconID = combatSpell.combatSpellDetails.specIconID;

	DamageMeterEntryMixin.Init(self, combatSpell);

	self:GetIcon():SetScript("OnEnter", function()
		if self.spellID then
			local tooltip = GetAppropriateTooltip();
			GameTooltip_SetDefaultAnchor(tooltip, self:GetIcon());

			local isPet = false;
			tooltip:SetSpellByID(self.spellID, isPet);

			tooltip:Show();
		end
	end);

	self:GetIcon():SetScript("OnLeave", function()
		GetAppropriateTooltip():Hide();
	end);
end

function DamageMeterSpellEntryMixin:IsCreature()
	return not self.isPet and self.isMob;
end

function DamageMeterSpellEntryMixin:GetSpellID()
	return self.spellID;
end

function DamageMeterSpellEntryMixin:GetIconTexture()
	if self.specIconID and self.specIconID ~= 0 then
		return self.specIconID;
	end

	if not self.spellID then
		return nil;
	end

	return C_Spell.GetSpellTexture(self.spellID);
end

function DamageMeterSpellEntryMixin:GetUnitNameText()
	-- Color the text by class color if its provided.
	if self.unitClassFilename and #self.unitClassFilename > 0 then
		local classColor = RAID_CLASS_COLORS[self.unitClassFilename];
		if classColor then
			return classColor:WrapTextInColorCode(self.unitName);
		end
	end

	return self.unitName;
end

function DamageMeterSpellEntryMixin:GetFormattedUnitNameText()
	local unitNameText = self:GetUnitNameText();

	-- Insert the classification image if its provided.
	local classificationAtlasElement = self:GetClassificationAtlasElement();
	if classificationAtlasElement then
		local atlasMarkup = CreateAtlasMarkup(classificationAtlasElement);
		return string.format("%s %s", atlasMarkup, unitNameText);
	end

	return unitNameText;
end

function DamageMeterSpellEntryMixin:GetNameText()
	if not self.spellID then
		return nil;
	end

	local spellName = C_Spell.GetSpellName(self.spellID);

	-- Special formatting for pets.
	if self.creatureName and #self.creatureName > 0 then
		return DAMAGE_METER_SPELL_ENTRY_CREATURE:format(spellName, self.creatureName);
	end

	-- Special formatting for when another unit is the subject and the player is the object (e.g. damage taken)
	if self.unitName and #self.unitName > 0 then
		local formattedUnitName = self:GetFormattedUnitNameText();
		if spellName and #spellName > 0 then
			return DAMAGE_METER_SPELL_ENTRY_UNIT:format(spellName, formattedUnitName);
		end

		return formattedUnitName;
	end

	return spellName;
end

function DamageMeterSpellEntryMixin:GetNumberDisplayType()
	return Enum.DamageMeterNumbers.Complete;
end
