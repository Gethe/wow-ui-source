
local DEBUG_CURRENCIES = { 1751, 1754, 1767 };
local DEBUG_ANIMA_CURRENCY = 1794;

local function DEBUG_GetCurrencies()
	return DEBUG_CURRENCIES;
end

local DEBUG_ANIMA = 0;
local DEBUG_MAX_ANIMA = 5000;

local function DEBUG_GetAnimaValue()
	return DEBUG_ANIMA;
end

local function DEBUG_GetMaxAnimaValue()
	return DEBUG_MAX_ANIMA;
end

local function DEBUG_DepositAnima()
	if DEBUG_ANIMA == DEBUG_MAX_ANIMA then
		DEBUG_ANIMA = 0;
	elseif DEBUG_ANIMA == 0 then
		DEBUG_ANIMA = math.floor(DEBUG_MAX_ANIMA * 0.01);
	else
		DEBUG_ANIMA = DEBUG_ANIMA + random(500, 1500);
		if DEBUG_ANIMA > DEBUG_MAX_ANIMA then
			DEBUG_ANIMA = DEBUG_MAX_ANIMA;
		end
	end
	CovenantSanctumFrame.UpgradesTab:OnEvent("CURRENCY_DISPLAY_UPDATE");
end

DEBUG_ANIMA_CURRENCY = 1794;

local function GetCurrentTier(talents)
	local currentTier = 1;
	for i, talentInfo in ipairs(talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
			currentTier = currentTier + 1;
		end
	end
	return currentTier;
end

--=============================================================================================

local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Background-%s",
}
local listTextureKitRegions = {
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
	["Divider"] = "CovenantSanctum-Divider-%s",
};
local featureBorderTextureKitRegions = {
	["Border"] = "CovenantSanctum-Icon-Border-%s",
}
local uniqueFeatureBorderTextureKitRegions = {
	["Border"] = "CovenantSanctum-BigIcon-Border-%s",
}
local reservoirTextureKitRegions = {
	["RankBorder"] = "CovenantSanctum-Resevoir-RankBorder-%s",
	["Background"] = "CovenantSanctum-Resevoir-Empty-%s",
	["FillBackground"] = "CovenantSanctum-Resevoir-Full-%s",
}
local upgradeTextureKitRegions = {
	["Border"] = "CovenantSanctum-Upgrade-Border-%s",
}

local g_sanctumTextureKit;
local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(g_sanctumTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

CovenantSanctumUpgradesTabMixin = {};

local CovenantSanctumUpgradesEvents = {
	"CURRENCY_DISPLAY_UPDATE",
	"GARRISON_TALENT_UPDATE",
    "GARRISON_TALENT_COMPLETE",
	"SPELL_TEXT_UPDATE",
};

function CovenantSanctumUpgradesTabMixin:OnLoad()
	self:SetUpCurrencies();
end

function CovenantSanctumUpgradesTabMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantSanctumUpgradesEvents);

	self:SetUpTextureKits();
	self:SetUpUpgrades();

	if self:GetSelectedTree() then
		self:Refresh();
	else
		self:SetSelectedTree(self.ReservoirUpgrade.treeID);
	end
end

function CovenantSanctumUpgradesTabMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumUpgradesEvents);
	self.selectedTreeID = nil;
end

function CovenantSanctumUpgradesTabMixin:OnEvent(event, ...)
	if event == "GARRISON_TALENT_UPDATE" then
		self:Refresh();
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		self.ReservoirUpgrade:UpdateAnima();
		self:UpdateCurrencies();
	end
end

function CovenantSanctumUpgradesTabMixin:Refresh()
	for i, frame in ipairs(self.Upgrades) do
		frame:Refresh();
	end
	self.TalentsList:Refresh();
end

function CovenantSanctumUpgradesTabMixin:SetSelectedTree(treeID)
	if self.selectedTreeID ~= treeID then
		self.selectedTreeID = treeID;
		self:Refresh();
	end
end

function CovenantSanctumUpgradesTabMixin:GetSelectedTree()
	return self.selectedTreeID;
end

function CovenantSanctumUpgradesTabMixin:DepositAnima()
	DEBUG_DepositAnima();
end

function CovenantSanctumUpgradesTabMixin:SetUpCurrencies()
	local tooltipAnchor = "ANCHOR_RIGHT";

	local animaFrame = self.AnimaCurrency;
	animaFrame:SetTooltipAnchor(tooltipAnchor);
	animaFrame:SetCurrencyFromID(DEBUG_ANIMA_CURRENCY);
	animaFrame:Show();

	local initFunction = function(currencyFrame)
		currencyFrame:SetWidth(50);
	end
	local currencies = DEBUG_GetCurrencies();
	local stride = #currencies;
	local paddingX = 10;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, stride, paddingX);
	local initAnchor = nil;
	self.CurrencyDisplayGroup:SetCurrencies(currencies, initFunction, initAnchor, layout, tooltipAnchor);
end

function CovenantSanctumUpgradesTabMixin:SetUpUpgrades()
	local features = C_CovenantSanctumUI.GetFeatures();
	for i, featureInfo in ipairs(features) do
		if featureInfo.featureType == Enum.GarrTalentFeatureType.ReservoirUpgrades then
			self.ReservoirUpgrade.treeID = featureInfo.garrTalentTreeID;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.AnimaDiversion then
			self.DiversionUpgrade.treeID = featureInfo.garrTalentTreeID;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.TravelPortals then
			self.TravelUpgrade.treeID = featureInfo.garrTalentTreeID;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.Adventures then
			self.AdventureUpgrade.treeID = featureInfo.garrTalentTreeID;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.SanctumUnique then
			self.UniqueUpgrade.treeID = featureInfo.garrTalentTreeID;
		end
	end
end

function CovenantSanctumUpgradesTabMixin:SetUpTextureKits()
	local treeID = C_Garrison.GetCurrentGarrTalentTreeID();
	local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);

	if g_sanctumTextureKit ~= treeInfo.textureKit then
		g_sanctumTextureKit = treeInfo.textureKit;

		SetupTextureKit(self, mainTextureKitRegions);
		SetupTextureKit(self.TalentsList, listTextureKitRegions);

		for i, frame in ipairs(self.Upgrades) do
			frame:SetUpTextureKit();
		end
	end
end

function CovenantSanctumUpgradesTabMixin:UpdateCurrencies()
	self.AnimaCurrency:Refresh();
	self.CurrencyDisplayGroup:Refresh();
end

--=============================================================================================
CovenantSanctumUpgradeTalentListMixin = { };

function CovenantSanctumUpgradeTalentListMixin:OnLoad()
	self.talentPool = CreateFramePool("FRAME", self, "CovenantSanctumUpgradeTalentTemplate");
end

local function SortTalents(talentA, talentB)
	return talentA.tier < talentB.tier;
end

function CovenantSanctumUpgradeTalentListMixin:Refresh()
	self.talentPool:ReleaseAll();

	local treeID = self:GetParent():GetSelectedTree();
	local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
	table.sort(treeInfo.talents, SortTalents);

	self.upgradeTalentID = nil;

	local lastTalentFrame = nil;
	for i, talentInfo in ipairs(treeInfo.talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
			self.upgradeTalentID = talentInfo.id;
		end

		local talentFrame = self.talentPool:Acquire();
		talentFrame:Set(talentInfo);

		if lastTalentFrame then
			talentFrame:SetPoint("TOP", lastTalentFrame, "BOTTOM", 0, -1);
		else
			talentFrame:SetPoint("TOP", -4, -131);
		end

		talentFrame:Show();
		lastTalentFrame = talentFrame;
	end

	self.Title:SetText(treeInfo.title);
	local currentTier = GetCurrentTier(treeInfo.talents);
	self.Tier:SetText("Tier "..currentTier);
	self.UpgradeButton:SetEnabled(self.upgradeTalentID ~= nil);
end

function CovenantSanctumUpgradeTalentListMixin:Upgrade()
	if self.upgradeTalentID then
		C_Garrison.ResearchTalent(self.upgradeTalentID, 1);
	end
end

--=============================================================================================
CovenantSanctumUpgradeTalentMixin = { };

function CovenantSanctumUpgradeTalentMixin:Set(talentInfo)
	self.Name:SetText(talentInfo.name);
	self.Icon:SetTexture(talentInfo.icon);

	self.info = talentInfo;
	local disabled = false;

	if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
		self.UpgradeArrow:Hide();
		self.InfoText:SetText(NORMAL_FONT_COLOR_CODE.."Known".."|r");
	elseif talentInfo.isBeingResearched then
		self.UpgradeArrow:Hide();
		self.InfoText:SetText(RED_FONT_COLOR_CODE.."Researching".."|r");
	elseif talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
		self.UpgradeArrow:Show();
		local costString = GetGarrisonTalentCostString(talentInfo);
		self.InfoText:SetText(costString or "");
	else
		disabled = true;
		self.UpgradeArrow:Hide();
		local isMet, failureString = C_Garrison.IsTalentConditionMet(talentInfo.id);
		if isMet then
			local costString = GetGarrisonTalentCostString(talentInfo);
			self.InfoText:SetText(costString);
		else
			self.InfoText:SetText(failureString or "");
		end
	end

	if disabled then
		local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.Border, g_sanctumTextureKit);
		self.Border:SetAtlas(atlas);
	else
		self.Border:SetAtlas("CovenantSanctum_Upgrade_Border_Available");
	end
	self.Icon:SetDesaturated(disabled);

	if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
		self.Cooldown:SetCooldownUNIX(talentInfo.startTime, talentInfo.researchDuration);
		self.Cooldown:Show();
		self.Icon:SetVertexColor(0.25, 0.25, 0.25)
	else
		self.Cooldown:Hide();
		self.Icon:SetVertexColor(1, 1, 1);
	end
end

local TalentUnavailableReasons = {};
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching] = ORDER_HALL_TALENT_UNAVAILABLE_ANOTHER_IS_RESEARCHING;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughResources] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_RESOURCES;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughGold] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_GOLD;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableTierUnavailable] = ORDER_HALL_TALENT_UNAVAILABLE_TIER_UNAVAILABLE;

function CovenantSanctumUpgradeTalentMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local talent			= self.info;
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
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..SecondsToTime(talent.timeRemaining), 1, 1, 1);
	elseif (talentTreeType == Enum.GarrTalentTreeType.Tiers and not talent.selected) or (talentTreeType == Enum.GarrTalentTreeType.Classic and not talent.researched) then
		GameTooltip:AddLine(" ");

		if (talent.researchDuration and talent.researchDuration > 0) then
			GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..SecondsToTime(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
		end

		local costString = GetGarrisonTalentCostString(talent);
		if costString then
			GameTooltip:AddLine(costString, 1, 1, 1);
		end

		if talent.talentAvailability == Enum.GarrisonTalentAvailability.Available or (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching) then
			GameTooltip:AddLine(ORDER_HALL_TALENT_RESEARCH, 0, 1, 0);
		else
			if (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailablePlayerCondition and talent.playerConditionReason) then
				GameTooltip:AddLine(talent.playerConditionReason, 1, 0, 0);
			elseif (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent) then
				local prereqTalentButton = self:GetParent():FindTalentButton(talent.prerequisiteTalentID);
				local preReqTalent = prereqTalentButton and prereqTalentButton.talent;
				if (preReqTalent) then
					GameTooltip:AddLine(TOOLTIP_TALENT_PREREQ:format(preReqTalent.talentMaxRank, preReqTalent.name), 1, 0, 0);
				else
					GameTooltip:AddLine(Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent, 1, 0, 0);
				end
			elseif (TalentUnavailableReasons[talent.talentAvailability]) then
				GameTooltip:AddLine(TalentUnavailableReasons[talent.talentAvailability], 1, 0, 0);
			end
		end
	end
	GameTooltip:Show();
end

--=============================================================================================
CovenantSanctumUpgradeBaseMixin = { };

function CovenantSanctumUpgradeBaseMixin:Refresh()
	local treeInfo = C_Garrison.GetTalentTreeInfo(self.treeID);
	if treeInfo then
		local currentTier = GetCurrentTier(treeInfo.talents);
		self.Tier:SetText(currentTier);
		self.Icon:SetTexture(treeInfo.talents[1].icon);
		self.SelectedTexture:SetShown(self:IsSelected());
	end
end

function CovenantSanctumUpgradeBaseMixin:OnMouseDown()
	self:GetParent():SetSelectedTree(self.treeID);
end

function CovenantSanctumUpgradeBaseMixin:OnEnter()
	self.HighlightTexture:Show();
end

function CovenantSanctumUpgradeBaseMixin:OnLeave()
	self.HighlightTexture:Hide();
end

function CovenantSanctumUpgradeBaseMixin:IsSelected()
	return self:GetParent():GetSelectedTree() == self.treeID;
end

function CovenantSanctumUpgradeBaseMixin:SetUpTextureKit()
	if self.uniqueUpgrade then
		SetupTextureKit(self, uniqueFeatureBorderTextureKitRegions);
	else
		SetupTextureKit(self, featureBorderTextureKitRegions);
	end
end

--=============================================================================================
CovenantSanctumUpgradeTreeMixin = CreateFromMixins(CovenantSanctumUpgradeBaseMixin);

--=============================================================================================
CovenantSanctumUpgradeReservoirMixin = CreateFromMixins(CovenantSanctumUpgradeBaseMixin);

function CovenantSanctumUpgradeReservoirMixin:SetUpTextureKit()
	SetupTextureKit(self, reservoirTextureKitRegions);
end

function CovenantSanctumUpgradeReservoirMixin:Refresh()
	local treeInfo = C_Garrison.GetTalentTreeInfo(self.treeID);
	if treeInfo then
		local currentTier = GetCurrentTier(treeInfo.talents);
		self.Tier:SetText(currentTier);
		self.SelectedTexture:SetShown(self:IsSelected());
		
		self:UpdateAnima();
	end
end

function CovenantSanctumUpgradeReservoirMixin:UpdateAnima()
	local usableHeight = 164;  -- orb portion of the artwork
	local value = DEBUG_GetAnimaValue();
	if value == 0 then
		self.FillBackground:Hide();
	else
		self.FillBackground:Show();
		local totalHeight = self.Background:GetHeight();
		local maxValue = DEBUG_GetMaxAnimaValue();
		if value == maxValue then
			self.FillBackground:SetHeight(totalHeight);
			self.FillBackground:SetTexCoord(0, 1, 0, 1);
		else
			local base = (totalHeight - usableHeight) / 2;
			local percent = value / maxValue;
			local height = base + usableHeight * percent;
			self.FillBackground:SetHeight(height);
			local coordTop = 1 - height / totalHeight;
			self.FillBackground:SetTexCoord(0, 1, coordTop, 1);
		end
	end
end