
CharacterCreateDetaislListFrameMixin = CreateFromMixins(NarrationStaticNameMixin, NarrationStaticDescriptionMixin);

function CharacterCreateDetaislListFrameMixin:OnLoad()
	local view = CreateScrollBoxLinearView();
	view:SetPanExtent(50);
	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.content = self.ScrollBox.Content;
	self.buttonPool = CreateFramePool("FRAME", self.content, "CharacterCreateFrameRacialAbilityTemplate");
	self.headerPool = CreateFramePool("FRAME", self.content, "CharacterCreateHeaderFrameTemplate");
	self.labelPool = CreateFramePool("FRAME", self.content, "CharacterCreateLabelFrameTemplate");
	self.spacerPool = CreateFramePool("FRAME", self.content, "CharacterCreateSpaceFrameTemplate");

	self.ScrollBox:SetEdgeFadeLength(30);
end

local function AcquireHeader(labelPool, text, layoutIndex)
	local frame = labelPool:Acquire();
	frame.Label:SetText(text);
	frame.layoutIndex = layoutIndex;
	frame:Show();
	return frame;
end

local function AcquireLabel(labelPool, text, layoutIndex)
	local frame = labelPool:Acquire();
	frame.Label:SetText(text);
	frame.layoutIndex = layoutIndex;
	frame:Show();
	return frame;
end

local function AcquireIconFrame(buttonPool, icon, text, layoutIndex)
	local button = buttonPool:Acquire();
	button.Icon:SetTexture(icon);
	button.Text:SetText(text);
	button.layoutIndex = layoutIndex;
	button:Layout();
	button:Show();
	return button;
end

local function AcquireSpacer(spacerPool, layoutIndex)
	local frame = spacerPool:Acquire();
	frame.layoutIndex = layoutIndex;
	frame:Show();
	return frame;
end

function CharacterCreateDetaislListFrameMixin:SetupFactionDetails(raceData, selectedFaction)
	self.labelPool:ReleaseAll();
	self.headerPool:ReleaseAll();
	self.buttonPool:ReleaseAll();
	self.spacerPool:ReleaseAll();

	local factionName, factionLore, factionAtlas;
	local faction = raceData.factionInternalName;
	if faction == "Alliance" then
		factionName = FACTION_ALLIANCE;
		factionLore = CHOOSE_THE_ALLIANCE;
		factionAtlas = "charactercreate-icon-alliancebg";
	elseif faction == "Horde" then
		factionName = FACTION_HORDE;
		factionLore = CHOOSE_THE_HORDE;
		factionAtlas = "charactercreate-icon-hordebg";
	else
		-- Neutral race (e.g. Pandaren): use the currently tracked selectedFaction.
		if selectedFaction == "Alliance" then
			factionName = FACTION_ALLIANCE;
			factionLore = CHOOSE_THE_ALLIANCE;
			factionAtlas = "charactercreate-icon-alliancebg";
		else
			factionName = FACTION_HORDE;
			factionLore = CHOOSE_THE_HORDE;
			factionAtlas = "charactercreate-icon-hordebg";
		end
	end
	self:SetPortraitAtlasRaw(factionAtlas);
	self:SetNarrationName(FACTION);
	self:SetNarrationDescription(NarrationUtil.MakeNarrationString(factionName, factionLore));

	local layoutIndex = 1;

	AcquireSpacer(self.spacerPool, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Row: faction name
	AcquireHeader(self.headerPool, factionName, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Faction lore description below
	AcquireLabel(self.labelPool, factionLore, layoutIndex);
	layoutIndex = layoutIndex + 1;

	AcquireSpacer(self.spacerPool, layoutIndex);

	self.content:Layout();
	self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end

function CharacterCreateDetaislListFrameMixin:SetupRacialDetails(raceData)
	self.labelPool:ReleaseAll();
	self.headerPool:ReleaseAll();
	self.buttonPool:ReleaseAll();
	self.spacerPool:ReleaseAll();

	self:SetPortraitAtlasRaw(strlower(raceData.createScreenIconAtlas));
	self:SetNarrationName(RACE);

	local layoutIndex = 1;

	AcquireSpacer(self.spacerPool, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Row: race name
	AcquireHeader(self.headerPool, raceData.name, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Racial abilities
	AcquireLabel(self.labelPool, RACIAL_TRAITS_TOOLTIP, layoutIndex);
	layoutIndex = layoutIndex + 1;

	local racialAbilities = raceData.racialAbilities;
	for _, racialAbilityInfo in ipairs(racialAbilities) do
		AcquireIconFrame(self.buttonPool, racialAbilityInfo.icon, racialAbilityInfo.description, layoutIndex);
		layoutIndex = layoutIndex + 1;
	end

	local racialTraitsNarration = CharacterCreateNarrationUtil.GetRacialTraitsNarration(raceData);

	self:SetNarrationDescription(NarrationUtil.MakeNarrationString(raceData.name, racialTraitsNarration, raceData.loreDescription));

	-- Race lore description
	AcquireLabel(self.labelPool, raceData.loreDescription, layoutIndex);
	layoutIndex = layoutIndex + 1;

	AcquireSpacer(self.spacerPool, layoutIndex);

	self.content:Layout();
	self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end

function CharacterCreateDetaislListFrameMixin:SetupClassDetails(classData)
	self.labelPool:ReleaseAll();
	self.headerPool:ReleaseAll();
	self.buttonPool:ReleaseAll();
	self.spacerPool:ReleaseAll();

	self:SetPortraitToClassIcon(strlower(classData.fileName));
	self:SetNarrationName(CLASS);
	self:SetNarrationDescription(NarrationUtil.MakeNarrationString(classData.name, classData.description));

	local layoutIndex = 1;

	AcquireSpacer(self.spacerPool, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Row: class name
	AcquireHeader(self.headerPool, classData.name, layoutIndex);
	layoutIndex = layoutIndex + 1;

	-- Class description below
	AcquireLabel(self.labelPool, classData.description, layoutIndex);
	layoutIndex = layoutIndex + 1;

	AcquireSpacer(self.spacerPool, layoutIndex);

	self.content:Layout();
	self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end
