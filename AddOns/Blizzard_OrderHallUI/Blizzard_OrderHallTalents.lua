
local TalentUnavailableReasons = {};
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING] = ORDER_HALL_TALENT_UNAVAILABLE_ANOTHER_IS_RESEARCHING;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_NOT_ENOUGH_RESOURCES] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_RESOURCES;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_NOT_ENOUGH_GOLD] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_GOLD;
TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_TIER_UNAVAILABLE] = ORDER_HALL_TALENT_UNAVAILABLE_TIER_UNAVAILABLE;

function OrderHallTalentFrame_ToggleFrame()
	if (not OrderHallTalentFrame:IsShown()) then
		ShowUIPanel(OrderHallTalentFrame);
	else
		HideUIPanel(OrderHallTalentFrame);
	end
end

local function OnTalentButtonReleased(pool, button)
	FramePool_HideAndClearAnchors(pool, button);
	button:OnReleased()
end

local CHOICE_BACKGROUND_OFFSET_Y = 10;
local BACKGROUND_WITH_INSET_OFFSET_Y = 0;
local BACKGROUND_NO_INSET_OFFSET_Y = 44;

local BORDER_ATLAS_NONE = nil;
local BORDER_ATLAS_UNAVAILABLE = "orderhalltalents-spellborder";
local BORDER_ATLAS_AVAILABLE = "orderhalltalents-spellborder-green";
local BORDER_ATLAS_SELECTED = "orderhalltalents-spellborder-yellow";

local TalentTreeLayoutOptions = { };

TalentTreeLayoutOptions[Enum.GarrTalentTreeType.Tiers] = {
	buttonInfo = {
		[Enum.GarrTalentType.Standard] = { size = 39, spacingX = 59, spacingY = 19 },
	},	
	spacingTop = 86,
	spacingBottom = 33,
	spacingHorizontal = 0,
	minimumWidth = 336,
	canHaveBackButton = true,
	singleCost = false,
	researchSoundStandard = SOUNDKIT.UI_ORDERHALL_TALENT_SELECT,
	researchSoundMajor = SOUNDKIT.UI_ORDERHALL_TALENT_SELECT,
};

TalentTreeLayoutOptions[Enum.GarrTalentTreeType.Classic] = {
	buttonInfo = {
		[Enum.GarrTalentType.Standard] = { size = 39, spacingX = 21, spacingY = 37 },
		[Enum.GarrTalentType.Major] = { size = 46, spacingX = 21, spacingY = 37 },
	},
	spacingTop = 110,
	spacingBottom = 36,
	spacingHorizontal = 144,
	minimumWidth = 336,
	canHaveBackButton = false,
	singleCost = true,
	researchSoundStandard = SOUNDKIT.UI_ORDERHALL_TITAN_MINOR_TALENT_SELECT,
	researchSoundMajor = SOUNDKIT.UI_ORDERHALL_TITAN_MAJOR_TALENT_SELECT,
};

local function GetResearchSoundForTalentType(talentType)
	local garrTalentTreeID = C_Garrison.GetCurrentGarrTalentTreeID();
	if garrTalentTreeID then
		local talentTreeType = C_Garrison.GetGarrisonTalentTreeType(garrTalentTreeID);
		local layoutOptions = TalentTreeLayoutOptions[talentTreeType];
		if layoutOptions then
			if talentType == Enum.GarrTalentType.Major then
				return layoutOptions.researchSoundMajor;
			else
				return layoutOptions.researchSoundStandard;
			end
		end
	end
	return SOUNDKIT.UI_ORDERHALL_TALENT_SELECT;
end

StaticPopupDialogs["ORDER_HALL_TALENT_RESEARCH"] = {
	text = "%s";
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		local soundKitID = GetResearchSoundForTalentType(self.data.talentType);
		PlaySound(soundKitID, nil, SOUNDKIT_ALLOW_DUPLICATES);
		C_Garrison.ResearchTalent(self.data.id, self.data.rank);
		if (not self.data.hasTime) then
			self.data.button:GetParent():SetResearchingTalentID(self.data.id);
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

OrderHallTalentFrameMixin = { }

do
	NineSliceUtil.AddLayout("BFAOrderTalentHorde", {
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "talenttree-horde-corner", x = -7, y = 7, },
		TopRightCorner =	{ atlas = "talenttree-horde-corner", x = 7, y = 7, },
		BottomLeftCorner =	{ atlas = "talenttree-horde-corner", x = -7, y = -7, },
		BottomRightCorner =	{ atlas = "talenttree-horde-corner", x = 7, y = -7, },
		TopEdge = { atlas = "_talenttree-horde-tiletop", },
		BottomEdge = { atlas = "_talenttree-horde-tilebottom", mirrorLayout = false, },
		LeftEdge = { atlas = "!talenttree-horde-tileleft", },
		RightEdge = { atlas = "!talenttree-horde-tileright", mirrorLayout = false, },
	});

	NineSliceUtil.AddLayout("BFAOrderTalentAlliance", {
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "talenttree-alliance-corner", x = -7, y = 7, },
		TopRightCorner =	{ atlas = "talenttree-alliance-corner", x = 7, y = 7, },
		BottomLeftCorner =	{ atlas = "talenttree-alliance-corner", x = -7, y = -7, },
		BottomRightCorner =	{ atlas = "talenttree-alliance-corner", x = 7, y = -7, },
		TopEdge = { atlas = "_talenttree-alliance-tiletop", },
		BottomEdge = { atlas = "_talenttree-alliance-tilebottom", mirrorLayout = false, },
		LeftEdge = { atlas = "!talentree-alliance-tileleft", },
		RightEdge = { atlas = "!talentree-alliance-tileright", mirrorLayout = false, },
	});

	local bfaTalentFrameStyleData =
	{
		Horde =
		{
			portraitOffsetX = -27,
			portraitOffsetY = 31,
			closeButtonBorder = "talenttree-horde-exit",
			nineSliceLayout = "BFAOrderTalentHorde",
			Background = "talenttree-horde-background",
			Portrait = "talenttree-horde-cornerlogo",
			CurrencyBG = "talenttree-horde-currencybg",
		},

		Alliance =
		{
			portraitOffsetX = -22,
			portraitOffsetY = 11,
			closeButtonBorder = "talenttree-alliance-exit",
			nineSliceLayout = "BFAOrderTalentAlliance",
			Background = "talenttree-alliance-background",
			Portrait = "talenttree-alliance-cornerlogo",
			CurrencyBG = "talenttree-alliance-currencybg",
		},
	};

	local function SetupBorder(self, styleData)
		NineSliceUtil.ApplyLayoutByName(self.NineSlice, styleData.nineSliceLayout);

		self.OverlayElements.CornerLogo:SetAtlas(styleData.Portrait, true);
		self.OverlayElements.CornerLogo:SetPoint("TOPLEFT", self, "TOPLEFT", styleData.portraitOffsetX, styleData.portraitOffsetY);

		self.Background:SetAtlas(styleData.Background, true);

		self.CurrencyBG:SetAtlas(styleData.CurrencyBG, true);
		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, styleData.closeButtonBorder, -1, 1);
		self.CloseButton:SetFrameLevel(510);
	end

	function OrderHallTalentFrameMixin:SetUseThemedTextures(isThemed)
		self:UpdateThemedFrameVisibility(isThemed);
		self.Currency:ClearAllPoints();

		local layoutName;

		if isThemed then
			self.Currency:SetPoint("CENTER", self.CurrencyBG, "CENTER", 0, -1);
			self.Currency.Icon:SetSize(17, 16);
			self.Background:SetPoint("TOPLEFT", self.Inset, 0, BACKGROUND_NO_INSET_OFFSET_Y);

			local factionGroup = UnitFactionGroup("player");
			SetupBorder(self, bfaTalentFrameStyleData[factionGroup]);
		else
			self.Currency:SetPoint("TOPRIGHT", self, "TOPRIGHT", -12, -29);
			self.Currency.Icon:SetSize(27, 26);
			self.Background:SetPoint("TOPLEFT", self.Inset, 0, BACKGROUND_WITH_INSET_OFFSET_Y);

			NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PortraitFrameTemplate");
		end
	end
end

function OrderHallTalentFrameMixin:UpdateThemedFrameVisibility(isThemed)
	-- Default/base elements
	local isBase = not isThemed;
	self.TopTileStreaks:SetShown(isBase);
	self.TitleBg:SetShown(isBase);
	self.Bg:SetShown(isBase);
	self.Inset:SetShown(isBase);
	self:SetPortraitShown(isBase);

	-- Custom themed elements
	self.OverlayElements.CornerLogo:SetShown(isThemed);
	self.CurrencyBG:SetShown(isThemed);
	UIPanelCloseButton_SetBorderShown(self.CloseButton, isThemed);
end

function OrderHallTalentFrameMixin:OnLoad()
	self.buttonPool = CreateFramePool("BUTTON", self, "GarrisonTalentButtonTemplate", OnTalentButtonReleased);
	self.prerequisiteArrowPool = CreateFramePool("FRAME", self, "GarrisonTalentPrerequisiteArrowTemplate");	
	self.talentRankPool = CreateFramePool("FRAME", self, "TalentRankDisplayTemplate");
	self.choiceTexturePool = CreateTexturePool(self, "BACKGROUND", 1, "GarrisonTalentChoiceTemplate");
	self.arrowTexturePool = CreateTexturePool(self, "BACKGROUND", 2, "GarrisonTalentArrowTemplate");
	self.researchingTalentID = 0;
end

function OrderHallTalentFrameMixin:SetGarrisonType(garrType, garrTalentTreeID)
	self.garrisonType = garrType;
	self.garrTalentTreeID = garrTalentTreeID;

	-- Setup Currencies
	local garrTypeCurrency, _ = C_Garrison.GetCurrencyTypes(garrType);
	local garrTalentTreeCurrency = C_Garrison.GetGarrisonTalentTreeCurrencyTypes(garrTalentTreeID);

	-- It's possible for the Garrison Talent Tree to specify a currency different from the Garrison Type. (Chromie/MOTHER Research Archive, etc)
	if (garrTalentTreeCurrency) then
		self.currency = garrTalentTreeCurrency;
	else 
		self.currency = garrTypeCurrency;
	end
end

function OrderHallTalentFrameMixin:OnShow()
	self:RefreshAllData();
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
    self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_TALENT_NPC_CLOSED");
	self:RegisterEvent("SPELL_TEXT_UPDATE");
	PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_WINDOW_OPEN);
end

function OrderHallTalentFrameMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
    self:UnregisterEvent("GARRISON_TALENT_COMPLETE");
	self:UnregisterEvent("GARRISON_TALENT_NPC_CLOSED");
	self:UnregisterEvent("SPELL_TEXT_UPDATE");

	self:ReleaseAllPools();
	StaticPopup_Hide("ORDER_HALL_TALENT_RESEARCH");
	C_Garrison.CloseTalentNPC();
	PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_WINDOW_CLOSE);
end

function OrderHallTalentFrameMixin:OnEvent(event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE" or event == "GARRISON_TALENT_UPDATE" or event == "GARRISON_TALENT_COMPLETE") then
		self:RefreshAllData();
	elseif (event == "GARRISON_TALENT_NPC_CLOSED") then
		self.CloseButton:Click();
	elseif event == "SPELL_TEXT_UPDATE" then
		self:RefreshAllData();
	end
end

function OrderHallTalentFrameMixin:EscapePressed()
	if (self:IsVisible()) then
		self.CloseButton:Click();
		return true;
	end

	return false;
end

function OrderHallTalentFrameMixin:OnUpdate()
	if (self.triedRefreshing and not self.refreshing) then
		self:RefreshAllData();
	end
end

function OrderHallTalentFrameMixin:ReleaseAllPools()
	self.buttonPool:ReleaseAll();
	self.talentRankPool:ReleaseAll();
	self.choiceTexturePool:ReleaseAll();
	self.arrowTexturePool:ReleaseAll();
	self.prerequisiteArrowPool:ReleaseAll();
end

function OrderHallTalentFrameMixin:RefreshCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(self.currency);
	amount = BreakUpLargeNumbers(amount);
	self.Currency.Text:SetText(amount);
	self.Currency.Icon:SetTexture(currencyTexture);
	self.Currency:MarkDirty();
	TalentUnavailableReasons[LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_NOT_ENOUGH_RESOURCES] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_RESOURCES_MULTI_RESOURCE:format(currencyName);
end

local function SortTree(talentA, talentB)
	if talentA.tier ~= talentB.tier then
		return talentA.tier < talentB.tier;
	end
	-- want to process dependencies last on a tier
	local hasPrereqA = (talentA.prerequisiteTalentID ~= nil);
	local hasPrereqB = (talentB.prerequisiteTalentID ~= nil);
	if hasPrereqA ~= hasPrereqB then
		return not hasPrereqA;
	end	
	if talentA.uiOrder ~= talentB.uiOrder then
		return talentA.uiOrder < talentB.uiOrder;
	end
	return talentA.id < talentB.id;
end

function OrderHallTalentFrameMixin:RefreshAllData()
	if (self.refreshing) then
		if (not self.triedRefreshing) then
			self.triedRefreshing = true;
			self:SetScript("OnUpdate", self.OnUpdate);
		end
		return;
	end

	self.refreshing = true;
	self.triedRefreshing = false;
	self:SetScript("OnUpdate", nil);

	self:ReleaseAllPools();

	self:RefreshCurrency();
	local garrTalentTreeID = C_Garrison.GetCurrentGarrTalentTreeID();
	if (garrTalentTreeID == nil or garrTalentTreeID == 0) then
		local playerClass = select(3, UnitClass("player"));
		local treeIDs = C_Garrison.GetTalentTreeIDsByClassID(self.garrisonType, playerClass);
		if (treeIDs and #treeIDs > 0) then
			garrTalentTreeID = treeIDs[1];
		end
	end

	local uiTextureKit, classAgnostic, tree, titleText, isThemed = C_Garrison.GetTalentTreeInfoForID(garrTalentTreeID);
	if not tree or #tree == 0 then
		self.refreshing = false;
		return;
	end

	table.sort(tree, SortTree);

	local talentTreeType = C_Garrison.GetGarrisonTalentTreeType(garrTalentTreeID);
	local layoutOptions = TalentTreeLayoutOptions[talentTreeType];

	local showSingleCost = false;
	if layoutOptions.singleCost then
		self.SingleCost:Show();
		if tree[1].researchCurrency > 0 then
			local currencyName, currencyAmount, currencyTexture = GetCurrencyInfo(tree[1].researchCurrency);
			self.SingleCost:SetFormattedText(RESEARCH_CURRENCY_COST, tree[1].researchCost, currencyTexture);
			showSingleCost = true;
		elseif tree[1].researchGoldCost > 0 then
			self.SingleCost:SetFormattedText(RESEARCH_COST, tree[1].researchGoldCost);
			showSingleCost = true;
		end
	end
	self.SingleCost:SetShown(showSingleCost);

	self:SetUseThemedTextures(isThemed);

	if (isThemed) then
		self.TitleText:Hide();
		self.BackButton:Hide();
	elseif (classAgnostic and not isThemed and layoutOptions.canHaveBackButton) then
		self.TitleText:SetText(UnitName("npc"));
		self.TitleText:Show();
		self.BackButton:Show();
	elseif (titleText and titleText ~= "") then
		self.TitleText:SetText(titleText);
		self.TitleText:Show();
		self.BackButton:Hide();
	else
		self.TitleText:SetText(ORDER_HALL_TALENT_TITLE);
		self.TitleText:Show();
		self.BackButton:Hide();
	end

	if (uiTextureKit) then
		self.Background:SetAtlas(uiTextureKit.."-background");
		local atlas = uiTextureKit.."-logo";
		if (C_Texture.GetAtlasInfo(atlas)) then
			self:SetPortraitAtlasRaw(atlas);
		else
			self:SetPortraitToUnit("npc");
		end
	else
		local _, className, classID = UnitClass("player");

		self.Background:SetAtlas("orderhalltalents-background-"..className);
		if (not classAgnostic) then
			self:SetPortraitToAsset("INTERFACE\\ICONS\\crest_"..className);
		else
			self:SetPortraitToUnit("npc");
		end
	end

	local friendshipFactionID = C_Garrison.GetCurrentGarrTalentTreeFriendshipFactionID();
	if (friendshipFactionID and friendshipFactionID > 0) then
		NPCFriendshipStatusBar_Update(self, friendshipFactionID);
		self.Currency:Hide();
		self.CurrencyHitTest:Hide();
		NPCFriendshipStatusBar:ClearAllPoints();
		NPCFriendshipStatusBar:SetPoint("TOPLEFT", 76, -39);
	else
		if NPCFriendshipStatusBar:GetParent() == self then
			NPCFriendshipStatusBar:Hide();
		end
		self.Currency:Show();
		self.CurrencyHitTest:Show();
	end

	-- ticks: these are the roman numerals on the left side of each tier
	local maxTierIndex = tree[#tree].tier + 1;
	for i = 1, #self.FrameTick do
		local shown = not classAgnostic and i <= maxTierIndex;
		self.FrameTick[i]:SetShown(shown);
	end

    local completeTalent = C_Garrison.GetCompleteTalent(self.garrisonType);
	local researchingTalentID = self:GetResearchingTalentID();
	local researchingTalentTier = 0;

	local currentTier = nil;
	local currentTierTotalTalentCount, currentTierBaseTalentCount, currentTierDependentTalentCount, currentTierResearchableTalentCount, currentTierTalentIndex, currentTierWidth, currentTierHeight;
	local contentOffsetY = layoutOptions.spacingTop;
	local maxContentWidth = 0;
	
	local function EvaluateCurrentTier(startingIndex)
		currentTierTotalTalentCount = 0;
		currentTierDependentTalentCount = 0;
		currentTierResearchableTalentCount = 0;
		currentTierTalentIndex = 0;
		currentTierWidth = 0;
		currentTierHeight = 0;
		
		for i = startingIndex, #tree do
			local talent = tree[i];
			if talent.tier ~= currentTier then
				break;
			end
			currentTierTotalTalentCount = currentTierTotalTalentCount + 1;
			if talent.prerequisiteTalentID then
				currentTierDependentTalentCount = currentTierDependentTalentCount + 1;
			end
			-- research stuff
			if talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE then
				currentTierResearchableTalentCount = currentTierResearchableTalentCount + 1;
			end
			talent.hasInstantResearch = talent.researchDuration == 0;
			if talent.id == researchingTalentID and talent.hasInstantResearch then
				if not talent.selected then
					talent.selected = true;
				end
				researchingTalentTier = talent.tier;
			end
		end
		currentTierBaseTalentCount = currentTierTotalTalentCount - currentTierDependentTalentCount;
	end

	-- position talent buttons
	for talentIndex, talent in ipairs(tree) do
		local buttonInfo = layoutOptions.buttonInfo[talent.type];

		if talent.tier ~= currentTier then
			maxContentWidth = math.max(maxContentWidth, currentTierWidth or 0);
			if currentTier then
				contentOffsetY = contentOffsetY + (currentTierHeight or 0) + buttonInfo.spacingY;
			end
			currentTier = talent.tier;
			EvaluateCurrentTier(talentIndex);
		end
		currentTierTalentIndex = currentTierTalentIndex + 1;
		currentTierWidth = currentTierWidth + buttonInfo.size;
		currentTierHeight = math.max(currentTierHeight, buttonInfo.size);
		if currentTierTalentIndex > 1 then
			currentTierWidth = currentTierWidth + buttonInfo.spacingX;	-- need a solve if a row has mixed talent types
		end

		local talentFrame = self.buttonPool:Acquire();
		talentFrame:SetSize(buttonInfo.size, buttonInfo.size);
		talentFrame.Icon:SetTexture(talent.icon);

		talentFrame.talent = talent;

		if (talent.isBeingResearched and not talent.hasInstantResearch) then
			talentFrame.Cooldown:SetCooldownUNIX(talent.researchStartTime, talent.researchDuration);
			talentFrame.Cooldown:Show();
			talentFrame.AlphaIconOverlay:Show();
			talentFrame.AlphaIconOverlay:SetAlpha(0.7);
			talentFrame.CooldownTimerBackground:Show();
			if (not talentFrame.timer) then
				talentFrame.timer = C_Timer.NewTicker(1, function() talentFrame:Refresh(); end);
			end
		end
		local selectionAvailableInstantResearch = true;
		if (researchingTalentID ~= 0 and researchingTalentTier == talent.tier and researchingTalentID ~= talent.id) then
			selectionAvailableInstantResearch = false;
		end

		-- Clear "Research Talent" status if the talent is not isBeingResearched
		if (talent.id == researchingTalentID and not talent.isBeingResearched) then
			self:ClearResearchingTalentID();
		end

		local isAvailable = talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE;
		local isZeroRank = talent.talentRank == 0;

		local borderAtlas = BORDER_ATLAS_NONE;
		if (talent.isBeingResearched) then
			borderAtlas = BORDER_ATLAS_SELECTED;
		elseif (talentTreeType == Enum.GarrTalentTreeType.Tiers and talent.selected and selectionAvailableInstantResearch) then
			borderAtlas = BORDER_ATLAS_SELECTED;
		elseif (talentTreeType == Enum.GarrTalentTreeType.Classic and talent.researched) then
			borderAtlas = BORDER_ATLAS_SELECTED;
		else
			-- We check for LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ALREADY_HAVE to avoid a bug with
			-- the Chromie UI (talents would flash grey when you switched to another talent in the same row).
			local canDisplayAsAvailable = talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING or talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ALREADY_HAVE;
			local shouldDisplayAsAvailable = canDisplayAsAvailable and talent.hasInstantResearch;
			-- Show as available: this is a new tier which you don't have any talents from or and old tier that you could change.
			-- Note: For instant talents, to support the Chromie UI, we display as available even when another talent is researching (Jeff wants it this way).
			if (isAvailable or shouldDisplayAsAvailable) then
				if ( currentTierResearchableTalentCount < currentTierTotalTalentCount and talentTreeType == Enum.GarrTalentTreeType.Tiers ) then
					talentFrame.AlphaIconOverlay:Show();
					talentFrame.AlphaIconOverlay:SetAlpha(0.5);
				else
					borderAtlas = BORDER_ATLAS_AVAILABLE;
				end

			-- Show as unavailable: You have not unlocked this tier yet or you have unlocked it but another research is already in progress.
			else
				borderAtlas = BORDER_ATLAS_UNAVAILABLE;
				talentFrame.Icon:SetDesaturated(isZeroRank);
			end
		end
		talentFrame:SetBorder(borderAtlas);
		talentFrame.MajorGlow:SetShown(borderAtlas == BORDER_ATLAS_AVAILABLE and talent.type == Enum.GarrTalentType.Major);

		-- Show the current talent rank if the talent had multiple ranks
		if talent.talentMaxRank > 1 then
			local talentRankFrame = self.talentRankPool:Acquire();
			talentRankFrame:SetPoint("BOTTOMRIGHT", talentFrame, 15, -12);
			talentRankFrame:SetFrameLevel(10);
			talentRankFrame:SetValues(talent.talentRank, talent.talentMaxRank, isZeroRank, isAvailable);
			talentRankFrame:Show();
		end

		if talent.prerequisiteTalentID then
			local prereqTalentButton = self:FindTalentButton(talent.prerequisiteTalentID);
			if prereqTalentButton then
				if prereqTalentButton.talent.uiOrder < talent.uiOrder then
					talentFrame:SetPoint("LEFT", prereqTalentButton, "RIGHT", buttonInfo.spacingX, 0);
				else
					talentFrame:SetPoint("RIGHT", prereqTalentButton, "LEFT", -buttonInfo.spacingX, 0);
				end
				self:AddPrerequisiteArrow(talentFrame, prereqTalentButton);
			end
		else
			local middleTalentIndex = math.ceil(currentTierBaseTalentCount / 2);
			-- there should only be a talent in the center spot if the count is odd
			if mod(currentTierBaseTalentCount, 2) == 0 then
				middleTalentIndex = middleTalentIndex + 0.5;
			end
			local offsetX = currentTierTalentIndex - middleTalentIndex;
			offsetX = offsetX * (buttonInfo.size + buttonInfo.spacingX);
			talentFrame:SetPoint("TOP", offsetX, -contentOffsetY);
		end

		talentFrame:Show();

		-- arrows for rows with 2 talents of tiered trees
		if talentTreeType == Enum.GarrTalentTreeType.Tiers and currentTierTalentIndex == 2 then
			local choiceBackground = self.choiceTexturePool:Acquire();
			if (currentTierResearchableTalentCount == 2) then
				choiceBackground:SetAtlas("orderhalltalents-choice-background-on", true);
				choiceBackground:SetDesaturated(false);
				local pulsingArrows = self.arrowTexturePool:Acquire();
				pulsingArrows:SetPoint("CENTER", choiceBackground);
				pulsingArrows.Pulse:Play();
				pulsingArrows:Show();
			elseif (currentTierResearchableTalentCount == 1) then
				choiceBackground:SetAtlas("orderhalltalents-choice-background", true);
				choiceBackground:SetDesaturated(false);
			else
				choiceBackground:SetAtlas("orderhalltalents-choice-background", true);
				choiceBackground:SetDesaturated(true);
			end
			choiceBackground:SetPoint("TOP", 0, - contentOffsetY + CHOICE_BACKGROUND_OFFSET_Y);
			choiceBackground:Show();
		end

        if (talent.id == completeTalent) then
            if (talent.selected and not talent.hasInstantResearch) then
				PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_READY_CHECK);
				talentFrame.TalentDoneAnim:Play();
			end
            C_Garrison.ClearCompleteTalent(self.garrisonType);
        end
	end

	-- size window
	local frameWidth = math.max(layoutOptions.minimumWidth, maxContentWidth + layoutOptions.spacingHorizontal);
	local frameHeight = contentOffsetY + currentTierHeight + layoutOptions.spacingBottom;	-- add currentTierHeight to account for the last tier
	self:SetSize(frameWidth, frameHeight);

	self.refreshing = false;
end

function OrderHallTalentFrameMixin:FindTalentButton(talentID)
	for talentFrame in self.buttonPool:EnumerateActive() do
		if talentFrame.talent.id == talentID then
			return talentFrame;
		end
	end
	return nil;
end

function OrderHallTalentFrameMixin:AddPrerequisiteArrow(talentButton, prerequisiteTalentButton)
	local arrowFrame = self.prerequisiteArrowPool:Acquire();
	if talentButton.talent.uiOrder > prerequisiteTalentButton.talent.uiOrder then
		arrowFrame:SetPoint("LEFT", prerequisiteTalentButton, "RIGHT", 1, 0);
		arrowFrame.Arrow:SetTexCoord(1, 0, 0, 1);
	else
		arrowFrame:SetPoint("RIGHT", prerequisiteTalentButton, "LEFT", -1, 0);
		arrowFrame.Arrow:SetTexCoord(0, 1, 0, 1);
	end
	if talentButton.talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE or talentButton.talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ALREADY_HAVE then
		arrowFrame.Arrow:SetDesaturated(false);
		arrowFrame.Arrow:SetVertexColor(1, 1, 1);
	else
		arrowFrame.Arrow:SetDesaturated(true);
		arrowFrame.Arrow:SetVertexColor(0.6, 0.6, 0.6);
	end
	arrowFrame:Show();
	talentButton:SetFrameLevel(2);
	arrowFrame:SetFrameLevel(3);
	prerequisiteTalentButton:SetFrameLevel(4);
end

function OrderHallTalentFrameMixin:SetResearchingTalentID(talentID)
	local oldResearchTalentID = self.researchingTalentID;
	self.researchingTalentID = talentID;
	if (oldResearchTalentID ~= talentID) then
		self:RefreshAllData();
	end
end

function OrderHallTalentFrameMixin:ClearResearchingTalentID()
	self.researchingTalentID = 0;
end

function OrderHallTalentFrameMixin:GetResearchingTalentID()
	return self.researchingTalentID;
end

GarrisonTalentButtonMixin = { }

function GarrisonTalentButtonMixin:SetBorder(borderAtlas)
	if borderAtlas then
		if self.talent.type == Enum.GarrTalentType.Major then
			borderAtlas = borderAtlas.."-large";
		end
		local useAtlasSize = true;
		self.Border:SetAtlas(borderAtlas, useAtlasSize);
		self.Border:Show();
	else
		self.Border:Hide();
	end
end

function GarrisonTalentButtonMixin:OnEnter()
	local researchingTalentID = self:GetParent():GetResearchingTalentID();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local talent			= self.talent;
	local garrTalentTreeID	= C_Garrison.GetCurrentGarrTalentTreeID();
	local talentTreeType	= C_Garrison.GetGarrisonTalentTreeType(garrTalentTreeID);

	-- Multi-Rank Talents
	if talent.talentMaxRank > 1 then
		local talentRank = math.max(0, talent.talentRank);

		GameTooltip:AddLine(talent.name, 1, 1, 1);
		GameTooltip_AddColoredLine(GameTooltip, TOOLTIP_TALENT_RANK:format(talentRank, talent.talentMaxRank), HIGHLIGHT_FONT_COLOR);
		GameTooltip:AddLine(talent.description, nil, nil, nil, true);

		-- Next Rank (show research description)
		if talent.talentRank > 0 and talent.talentRank < talent.talentMaxRank then
			GameTooltip:AddLine(" ");
			GameTooltip_AddColoredLine(GameTooltip, TOOLTIP_TALENT_NEXT_RANK, HIGHLIGHT_FONT_COLOR);
			GameTooltip:AddLine(talent.researchDescription, nil, nil, nil, true);
		end
	else 
		GameTooltip:AddLine(talent.name, 1, 1, 1);
		GameTooltip:AddLine(talent.description, nil, nil, nil, true);
	end

	if talent.isBeingResearched and not talent.hasInstantResearch then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..SecondsToTime(talent.researchTimeRemaining), 1, 1, 1);
	elseif (talentTreeType == Enum.GarrTalentTreeType.Tiers and not talent.selected) or (talentTreeType == Enum.GarrTalentTreeType.Classic and not talent.researched) then
		GameTooltip:AddLine(" ");

		if (talent.researchDuration and talent.researchDuration > 0) then
			GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..SecondsToTime(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
		end

		if ((talent.researchCost and talent.researchCost > 0 and talent.researchCurrency) or (talent.researchGoldCost and talent.researchGoldCost > 0)) then
			local str = NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE;
			if (talent.researchCost > 0 and talent.researchCurrency) then
				local _, _, currencyTexture = GetCurrencyInfo(talent.researchCurrency);
				str = str.." "..BreakUpLargeNumbers(talent.researchCost).."|T"..currencyTexture..":0:0:2:0|t";
			end
			if (talent.researchGoldCost ~= 0) then
				str = str.." "..talent.researchGoldCost.."|TINTERFACE\\MONEYFRAME\\UI-MoneyIcons.blp:16:16:2:0:64:16:0:16:0:16|t";
			end
			GameTooltip:AddLine(str, 1, 1, 1);
		end

		if talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE or ((researchingTalentID and researchingTalentID ~= 0) and talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_ANOTHER_IS_RESEARCHING) then
			GameTooltip:AddLine(ORDER_HALL_TALENT_RESEARCH, 0, 1, 0);
			self.Highlight:Show();
		else
			if (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_PLAYER_CONDITION and talent.playerConditionReason) then
				GameTooltip:AddLine(talent.playerConditionReason, 1, 0, 0);
			elseif (talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_UNAVAILABLE_REQUIRES_PREREQUISITE_TALENT) then
				local prereqTalentButton = self:GetParent():FindTalentButton(talent.prerequisiteTalentID);
				local preReqTalent = prereqTalentButton and prereqTalentButton.talent;
				if (preReqTalent) then
					GameTooltip:AddLine(TOOLTIP_TALENT_PREREQ:format(preReqTalent.talentMaxRank, preReqTalent.name), 1, 0, 0);
				else
					GameTooltip:AddLine(ORDER_HALL_TALENT_UNAVAILABLE_REQUIRES_PREREQUISITE_TALENT, 1, 0, 0);
				end
			elseif (TalentUnavailableReasons[talent.talentAvailability]) then
				GameTooltip:AddLine(TalentUnavailableReasons[talent.talentAvailability], 1, 0, 0);
			end
			self.Highlight:Hide();
		end
	end
	self.tooltip = GameTooltip;
	GameTooltip:Show();
end

function GarrisonTalentButtonMixin:OnLeave()
	GameTooltip_Hide();
	self.Highlight:Hide();
	self.tooltip = nil;
end

function GarrisonTalentButtonMixin:OnClick()
	local researchingTalentID = self:GetParent():GetResearchingTalentID();
	if (researchingTalentID and researchingTalentID ~= 0 and researchingTalentID ~= self.talent.id) then
		UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_RIGHT_NOW, RED_FONT_COLOR:GetRGBA());
		--return;
	end
	if (self.talent.talentAvailability == LE_GARRISON_TALENT_AVAILABILITY_AVAILABLE) then
		local _, _, currencyTexture = GetCurrencyInfo(self:GetParent().currency);

		local hasCost = self.talent.researchCost and self.talent.researchCost > 0;
		local hasTime = self.talent.researchDuration and self.talent.researchDuration > 0;

		if (hasCost or hasTime) then
			local str;
			if (hasCost and hasTime) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION, self.talent.name, BreakUpLargeNumbers(self.talent.researchCost), currencyTexture, SecondsToTime(self.talent.researchDuration, false, true));
			elseif (hasCost) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION_NO_TIME, self.talent.name, BreakUpLargeNumbers(self.talent.researchCost), currencyTexture);
			elseif (hasTime) then
				str = string.format(ORDER_HALL_RESEARCH_CONFIRMATION_NO_COST, self.talent.name, SecondsToTime(self.talent.researchDuration, false, true));
			end
			StaticPopup_Show("ORDER_HALL_TALENT_RESEARCH", str, nil, { id = self.talent.id, rank = self.talent.talentRank + 1,  hasTime = hasTime,  button = self, talentType = self.talent.type });
		else
			local soundKitID = GetResearchSoundForTalentType(self.talent.type);
			PlaySound(soundKitID, nil, SOUNDKIT_ALLOW_DUPLICATES);
			C_Garrison.ResearchTalent(self.talent.id, self.talent.talentRank + 1);
			self:GetParent():SetResearchingTalentID(self.talent.id);
		end
	end
end

function GarrisonTalentButtonMixin:OnReleased()
	self.Cooldown:SetCooldownDuration(0);
	self.Cooldown:Hide();
	self.Border:Show();
	self.AlphaIconOverlay:Hide();
	self.CooldownTimerBackground:Hide();
	self.Icon:SetDesaturated(false);
	self.talent = nil;
	self.tooltip = nil;
	if (self.timer) then
		self.timer:Cancel();
		self.timer = nil;
	end
	self.TalentDoneAnim:Stop();
end

function GarrisonTalentButtonMixin:Refresh()
	if (self.talent and self.talent.id) then
	    self.talent = C_Garrison.GetTalent(self.talent.id);
	    if (self.tooltip) then
		    self:OnEnter();
	    end
	end
end