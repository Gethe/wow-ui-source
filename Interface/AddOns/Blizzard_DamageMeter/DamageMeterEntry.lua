local DAMAGE_METER_DEFAULT_STATUSBAR_COLOR = CreateColor(1, 0.84, 0.52);

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

function DamageMeterEntryMixin:GetIconAtlasElement()
	-- Override as necessary.
end

function DamageMeterEntryMixin:GetIconTexture()
	-- Override as necessary.
end

function DamageMeterEntryMixin:UpdateIcon()
	if self.iconUsesAtlas then
		local atlasElement = self:GetIconAtlasElement();
		self:GetIcon():SetAtlas(atlasElement);
	else
		local texture = self:GetIconTexture();
		self:GetIcon():SetTexture(texture);
	end
end

function DamageMeterEntryMixin:GetNameText()
	-- Override as necessary.
end

function DamageMeterEntryMixin:UpdateName()
	local text = self:GetNameText();
	self:GetName():SetText(text);
end

function DamageMeterEntryMixin:GetValueText()
	if not self.value then
		return 0;
	end

	return AbbreviateLargeNumbers(self.value);
end

function DamageMeterEntryMixin:UpdateValue()
	local text = self:GetValueText();
	self:GetValue():SetText(text);
end

function DamageMeterEntryMixin:UpdateStatusBar()
	self:GetStatusBar():SetMinMaxValues(0, self.maxValue or 0);
	self:GetStatusBar():SetValue(self.value or 0);
end

function DamageMeterEntryMixin:GetDefaultStatusBarColor()
	return DAMAGE_METER_DEFAULT_STATUSBAR_COLOR;
end

function DamageMeterEntryMixin:GetStatusBarColor()
	local r, g, b = self:GetStatusBarTexture():GetVertexColor();
	return CreateColor(r, g, b);
end

function DamageMeterEntryMixin:SetStatusBarColor(color)
	return self:GetStatusBarTexture():SetVertexColor(color:GetRGB());
end

function DamageMeterEntryMixin:SetUseClassColor(useClassColor)
	local color;

	if self.unitToken and useClassColor == true then
		local _className, classFilename, _classID = UnitClass(self.unitToken);

		if classFilename then
			color = C_ClassColor.GetClassColor(classFilename);
		end
	end

	if color == nil then
		color = self:GetDefaultStatusBarColor();
	end

	self:SetStatusBarColor(color);
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

function DamageMeterEntryMixin:Init(source)
	self.unitToken = source.unitToken;
	self.value = source.totalAmount;
	self.maxValue = source.maxAmount;

	self:UpdateIcon();
	self:UpdateName();
	self:UpdateValue();
	self:UpdateStatusBar();
end

DamageMeterSourceEntryMixin = {}

function DamageMeterSourceEntryMixin:Init(combatSource)
	DamageMeterEntryMixin.Init(self, combatSource);
end

function DamageMeterSourceEntryMixin:GetIconAtlasElement()
	if not self.unitToken then
		return nil;
	end

	local _className, classFilename, _classID = UnitClass(self.unitToken);
	if classFilename then
		return GetClassAtlas(classFilename);
	end

	return nil;
end

function DamageMeterSourceEntryMixin:GetNameText()
	if not self.unitToken then
		return nil;
	end

	return UnitName(self.unitToken);
end

DamageMeterSpellEntryMixin = {}

function DamageMeterSpellEntryMixin:Init(combatSpell)
	self.spellID = combatSpell.spellID;

	DamageMeterEntryMixin.Init(self, combatSpell);
end

function DamageMeterSpellEntryMixin:GetIconTexture()
	if not self.spellID then
		return nil;
	end

	return C_Spell.GetSpellTexture(self.spellID);
end

function DamageMeterSpellEntryMixin:GetNameText()
	if not self.spellID then
		return nil;
	end

	return C_Spell.GetSpellName(self.spellID);
end
