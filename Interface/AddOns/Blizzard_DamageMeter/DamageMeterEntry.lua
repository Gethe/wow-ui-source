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

function DamageMeterEntryMixin:UpdateStyle()
	local style = self:GetStyle();
	local showBarIcons = self:ShouldShowBarIcons();

	self:GetStatusBar():ClearAllPoints();
	self:GetName():ClearAllPoints();
	self:GetValue():ClearAllPoints();

	-- At present in all layouts the positioning of the bar relative to the
	-- icon is a fixed deal - if shown, the icon is to the left of the bar.

	do
		self:GetIcon():SetShown(showBarIcons);

		if showBarIcons then
			self:GetStatusBar():SetPoint("LEFT", self:GetIcon(), "RIGHT", 5, 0);
		else
			self:GetStatusBar():SetPoint("LEFT", 5, 0);
		end
	end

	-- Keeping individual components split up for now to make this logic
	-- easier to split up if later required.

	if style == Enum.DamageMeterStyle.Default then
		self:GetStatusBar():SetPoint("TOP")
		self:GetStatusBar():SetPoint("BOTTOMRIGHT");
	elseif style == Enum.DamageMeterStyle.Thin then
		self:GetStatusBar():SetHeight(10);
		self:GetStatusBar():SetPoint("BOTTOMRIGHT");
	end

	if style == Enum.DamageMeterStyle.Default then
		self:GetName():SetPoint("LEFT", 5, 0);
		self:GetName():SetPoint("RIGHT", self:GetValue(), "LEFT", -25, 0);
	elseif style == Enum.DamageMeterStyle.Thin then
		self:GetName():SetPoint("TOP", self, "TOP", 0, 0);
		if showBarIcons then
			self:GetName():SetPoint("LEFT", self:GetIcon(), "RIGHT", 5, 0);
		else
			self:GetName():SetPoint("LEFT", self, "LEFT", 5, 0);
		end
		self:GetName():SetPoint("RIGHT", self:GetValue(), "LEFT", -25, 0);
		self:GetName():SetPoint("BOTTOM", self:GetStatusBar(), "TOP", 0, 0);
	end

	if style == Enum.DamageMeterStyle.Default then
		self:GetValue():SetPoint("RIGHT", -8, 0);
	elseif style == Enum.DamageMeterStyle.Thin then
		self:GetValue():SetPoint("TOP", self, "TOP", 0, 0);
		self:GetValue():SetPoint("RIGHT", -8, 0);
		self:GetValue():SetPoint("BOTTOM", self:GetStatusBar(), "TOP", 0, 0);
	end
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

	if self.classFilename and useClassColor == true then
		color = C_ClassColor.GetClassColor(self.classFilename);
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
	-- DMTODO: Need to discuss what bar height should do in the thin style.
	if self:GetStyle() == Enum.DamageMeterStyle.Default then
		self:SetHeight(barHeight);
	end
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
	self:UpdateStyle();
end

function DamageMeterEntryMixin:Init(source)
	self.value = source.totalAmount;
	self.maxValue = source.maxAmount;
	self.classFilename = source.classFilename;

	self:UpdateIcon();
	self:UpdateName();
	self:UpdateValue();
	self:UpdateStatusBar();
	self:UpdateStyle();
end

DamageMeterSourceEntryMixin = {}

function DamageMeterSourceEntryMixin:Init(combatSource)
	self.sourceName = combatSource.name;

	DamageMeterEntryMixin.Init(self, combatSource);
end

function DamageMeterSourceEntryMixin:GetIconAtlasElement()
	if not self.classFilename then
		return nil;
	end

	return GetClassAtlas(self.classFilename);
end

function DamageMeterSourceEntryMixin:GetNameText()
	return self.sourceName;
end

DamageMeterSpellEntryMixin = {}

function DamageMeterSpellEntryMixin:Init(combatSpell)
	self.spellID = combatSpell.spellID;

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
