local function GetCurrentTier(talents)
	local currentTier = 0;
	for i, talentInfo in ipairs(talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
			currentTier = currentTier + 1;
		end
	end
	return currentTier;
end

local function GetCovenantID()
	return CovenantSanctumFrame:GetCovenantID();
end

local function GetCovenantData()
	return CovenantSanctumFrame:GetCovenantData();
end

local function GetCovenantTextureKit()
	local data = CovenantSanctumFrame:GetCovenantData();
	return data.textureKit;
end

local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false);

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
	["Glow"] = "CovenantSanctum-Icon-Glow-%s",
}
local reservoirTextureKitRegions = {
	["Background"] = "CovenantSanctum-Resevoir-Empty-%s",
};
local reservoirClippedElementsTextureKitRegions = {
	["FillBackground"] = "CovenantSanctum-Resevoir-Full-%s",
	["InnerGlow"] = "CovenantSanctum-Reservoir-Idle-%s-Glow",
	["VerticalStrands"] = "!CovenantSanctum-Reservoir-Idle-%s-Strands",
	["GlassCover"] = "CovenantSanctum-Reservoir-Idle-%s-Glass",
	["LowSpeck1"] = "CovenantSanctum-Reservoir-Idle-%s-Speck",
	["LowSpeck2"] = "CovenantSanctum-Reservoir-Idle-%s-Speck2",
};
local reservoirFullElementsTextureKitRegions = {
	["Spark"] = "CovenantSanctum-Reservoir-Spark-%s",
	["SparkGlow"] = "CovenantSanctum-Reservoir-Spark-Glow-%s",
	["Glow"] = "CovenantSanctum-Resevoir-Glow-%s",
	["StaticGlow"] = "CovenantSanctum-Resevoir-Glow-%s",
	["HighSpeck1"] = "CovenantSanctum-Reservoir-Idle-%s-Speck",
	["HighSpeck2"] = "CovenantSanctum-Reservoir-Idle-%s-Speck2",
};
local upgradeTextureKitRegions = {
	["Border"] = "CovenantSanctum-Upgrade-Border-%s",
	["IconBorder"] = "CovenantSanctum-Upgrade-Icon-Border-%s",
	["IntroBoxBackground"] = "CovenantSanctum-Text-Border-%s",
}
local bagsGlowTextureKitRegions = {
	["Glow"] = "CovenantSanctum-Bag-Glow-%s",
}

StaticPopupDialogs["CONFIRM_SANCTUM_UPGRADE"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		self.data.owner:Upgrade();
		local covenantData = GetCovenantData();
		PlaySound(covenantData.beginResearchSoundKitID);
	end,
	OnShow = function(self, data)
		if data then
			local costString = GetGarrisonTalentCostString(data.talent);
			self.text:SetText(SANCTUM_UPGRADE_CONFIRMATION:format(data.talent.name, data.talent.tier + 1, costString));
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,

}

local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(GetCovenantTextureKit(), frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local EFFECT_MISSILE = 1;
local EFFECT_IMPACT = 2;
local EFFECT_ANIMA_FULL = 3;
local EFFECT_RESEARCH = 4;

local covenantSanctumEffectList = {
	[Enum.CovenantType.Venthyr] = { 103, 107, 111, 115 },
	[Enum.CovenantType.Kyrian] = { 104, 108, 112, 116 },
	[Enum.CovenantType.NightFae] = { 105, 109, 113, 117 },
	[Enum.CovenantType.Necrolord] = { 106, 110, 114, 118 },
}

local function GetEffectID(index)
	local effectList = covenantSanctumEffectList[GetCovenantID()];
	return effectList and effectList[index];
end

local reservoirAnimSettings = {
	[Enum.CovenantType.Venthyr] = 	{ strand = { vert = true, horiz = true, alpha = 0.5, rate = 0.05, mode = "BLEND" }, glow = { fromAlpha = 0, toAlpha = 0.7,	rotate = false }, spirals = false, pulse = false, lowSpecks = false, highSpecks = false },
	[Enum.CovenantType.Kyrian] = 	{ strand = { vert = true, horiz = false, alpha = 0.3, rate = 0.04, mode = "ADD", reverseDir = true }, glow = { fromAlpha = 0, toAlpha = 0.7, rotate = false }, spirals = false, pulse = false, lowSpecks = false, highSpecks = true },
	[Enum.CovenantType.NightFae] = 	{ strand = nil, glow = { fromAlpha = 0, toAlpha = 1, rotate = true }, spirals = true, pulse = false, lowSpecks = false, highSpecks = true },
	[Enum.CovenantType.Necrolord] = { strand = nil, glow = nil, spirals = false, pulse = true, lowSpecks = true, highSpecks = false },
}

local covenantSanctumFeatureDescription = {
	[Enum.GarrTalentFeatureType.AnimaDiversion] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.TravelPortals] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.Adventures] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_ADVENTURES_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_ADVENTURES_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_ADVENTURES_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_ADVENTURES_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.SanctumUnique] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_UNIQUE_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_UNIQUE_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_UNIQUE_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_UNIQUE_NECROLORD,
	},
};

CovenantSanctumUpgradesTabMixin = {};

local CovenantSanctumUpgradesEvents = {
	"CURRENCY_DISPLAY_UPDATE",
	"GARRISON_TALENT_UPDATE",
    "GARRISON_TALENT_COMPLETE",
	"SPELL_TEXT_UPDATE",
	"GARRISON_TALENT_RESEARCH_STARTED",
	"BAG_UPDATE",
};

function CovenantSanctumUpgradesTabMixin:OnLoad()
	-- attach bags glow
	self.BagsGlowFrame:SetParent(MicroButtonAndBagsBar);
	self.BagsGlowFrame:SetAllPoints(MicroButtonAndBagsBar);
	self.BagsGlowFrame:SetFrameLevel(MainMenuBarBackpackButton:GetFrameLevel() + 1);

	self:SetUpCurrencies();

	self.researchModelScenePool = CreateFramePool("MODELSCENE", self, "ScriptAnimatedModelSceneTemplate");
end

function CovenantSanctumUpgradesTabMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantSanctumUpgradesEvents);

	self:SetUpTextureKits();
	self:SetUpUpgrades();

	if self:GetSelectedTree() then
		self:Refresh();
	else
		self:SetSelectedTree(self.TravelUpgrade.treeID);
	end

	self.ReservoirUpgrade:UpdateAnima();
	self:UpdateCurrencies();
	self:CheckTutorials();
end

function CovenantSanctumUpgradesTabMixin:OnHide()
	StaticPopup_Hide("CONFIRM_SANCTUM_UPGRADE");

	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumUpgradesEvents);
	self.selectedTreeID = nil;
	if self.animaGainEffect then
		self.animaGainEffect:CancelEffect();
	end
	for i, frame in ipairs(self.Upgrades) do
		if frame.researchEffect then
			frame.researchEffect:CancelEffect();
			frame.GlowAnim:Stop();
			frame.Glow:SetAlpha(0);
		end
	end
	self.ReservoirUpgrade:CancelAnimaGainEffect();
end

function CovenantSanctumUpgradesTabMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		local currencyID, total = ...;
		local animaCurrencyID = C_CovenantSanctumUI.GetAnimaInfo();
		if currencyID == animaCurrencyID and total > self.ReservoirUpgrade:GetAnimaAmount() then
			self:OnAnimaGained();
		else
			self:OnCurrencyUpdate();
		end
	elseif event == "GARRISON_TALENT_RESEARCH_STARTED" then
		local garrTypeID, talentTreeID, talentID = ...;
		self:OnResearchStarted(talentTreeID);
	elseif event == "BAG_UPDATE" then
		self:UpdateDepositButton();
	else
		self:Refresh();
	end
end

function CovenantSanctumUpgradesTabMixin:OnResearchStarted(talentTreeID)
	for i, frame in ipairs(self.Upgrades) do
		if frame.treeID == talentTreeID then
			local effectID = GetEffectID(EFFECT_RESEARCH);
			if effectID then
				local modelScene = self.researchModelScenePool:Acquire();
				modelScene:SetPoint("CENTER", frame);
				modelScene:SetSize(500, 500);
				modelScene:SetFrameLevel(frame:GetFrameLevel() + 100);
				modelScene:Show();
				local target, onEffectFinish = nil, nil;
				local onEffectResolution = function()
					frame.researchEffect = nil;
					self.researchModelScenePool:Release(modelScene);
				end;
				frame.researchEffect = modelScene:AddEffect(effectID, frame, target, onEffectFinish, onEffectResolution);
				frame.GlowAnim:Play();
			end
			break;
		end
	end
end

function CovenantSanctumUpgradesTabMixin:OnAnimaGained()
	local playMissile = MainMenuBarBackpackButton:IsVisible();
	local effectID = playMissile and GetEffectID(EFFECT_MISSILE) or GetEffectID(EFFECT_IMPACT);
	if not effectID then
		self:OnCurrencyUpdate();
		return;
	end
	local onEffectFinish = playMissile and GenerateClosure(self.OnAnimaGainEffectMissileFinished, self) or nil;
	local onEffectResolution = GenerateClosure(self.OnAnimaGainEffectImpactFinished, self);
	local source = CharacterBag1Slot;	-- middle bag
	self.animaGainEffect = GlobalFXDialogModelScene:AddEffect(effectID, source, self.ReservoirUpgrade, onEffectFinish, onEffectResolution);
	if playMissile then
		self.BagsGlowFrame.Glow:SetAlpha(1);
	else
		self:OnCurrencyUpdate();
		self.ReservoirUpgrade:StartAnimaGainEffect();
	end
end

function CovenantSanctumUpgradesTabMixin:OnAnimaGainEffectMissileFinished(effectCount, cancelled)
	if cancelled then
		self.BagsGlowFrame.Anim:Stop();
		self.BagsGlowFrame.Glow:SetAlpha(0);
	else
		self:OnCurrencyUpdate();
		self.BagsGlowFrame.Anim:Play();
		self.ReservoirUpgrade:StartAnimaGainEffect();
	end
end

function CovenantSanctumUpgradesTabMixin:OnAnimaGainEffectImpactFinished(...)
	self.animaGainEffect = nil;
end

function CovenantSanctumUpgradesTabMixin:OnCurrencyUpdate()
	self:UpdateCurrencies();
	self:Refresh();
end

function CovenantSanctumUpgradesTabMixin:Refresh()
	for i, frame in ipairs(self.Upgrades) do
		frame:Refresh();
	end
	self.TalentsList:Refresh();
	self:UpdateDepositButton();
end

function CovenantSanctumUpgradesTabMixin:HasAnyTalents()
	for i, frame in ipairs(self.Upgrades) do
		if frame:GetTier() > 0 then
			return true;
		end
	end
	return false;
end

function CovenantSanctumUpgradesTabMixin:UpdateDepositButton()
	self.DepositButton:SetEnabled(C_CovenantSanctumUI.CanDepositAnima());
end

function CovenantSanctumUpgradesTabMixin:SetSelectedTree(treeID)
	if self.selectedTreeID ~= treeID then
		self.selectedTreeID = treeID;
		self:Refresh();
		StaticPopup_Hide("CONFIRM_SANCTUM_UPGRADE");
	end
end

function CovenantSanctumUpgradesTabMixin:GetSelectedTree()
	return self.selectedTreeID;
end

function CovenantSanctumUpgradesTabMixin:GetSelectedTreeDescriptionText()
	for i, frame in ipairs(self.Upgrades) do
		if frame.treeID == self.selectedTreeID then
			return frame:GetDescriptionText();
		end
	end
	return nil;
end

function CovenantSanctumUpgradesTabMixin:DepositAnima()
	HelpTip:Acknowledge(self, COVENANT_SANCTUM_TUTORIAL4);
	C_CovenantSanctumUI.DepositAnima();
end

function CovenantSanctumUpgradesTabMixin:SetUpCurrencies()
	local tooltipAnchor = "ANCHOR_RIGHT";

	local initFunction = function(currencyFrame)
		currencyFrame:SetWidth(50);
	end
	local currencies = C_CovenantSanctumUI.GetSoulCurrencies();
	-- sort them by ID - just happens to be in the order desired
	table.sort(currencies);
	-- add Anima to the front
	local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo()
	tinsert(currencies, 1, animaCurrencyID);

	local stride = #currencies;
	local paddingX = 7;
	local paddingY = nil;
	local fixedWidth = 62;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, stride, paddingX, paddingY, fixedWidth);
	local initAnchor = nil;
	local abbreviateCost = false;
	local reverseOrder = true;
	self.CurrencyDisplayGroup:SetCurrencies(currencies, initFunction, initAnchor, layout, tooltipAnchor, abbreviateCost, reverseOrder);

	self.currencyOrder = currencies;
end

function CovenantSanctumUpgradesTabMixin:SetUpUpgrades()
	local features = C_CovenantSanctumUI.GetFeatures();
	for i, featureInfo in ipairs(features) do
		if featureInfo.featureType == Enum.GarrTalentFeatureType.ReservoirUpgrades then
			self.ReservoirUpgrade.treeID = featureInfo.garrTalentTreeID;
			self.ReservoirUpgrade.featureType = featureInfo.featureType;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.AnimaDiversion then
			self.DiversionUpgrade.treeID = featureInfo.garrTalentTreeID;
			self.DiversionUpgrade.featureType = featureInfo.featureType;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.TravelPortals then
			self.TravelUpgrade.treeID = featureInfo.garrTalentTreeID;
			self.TravelUpgrade.featureType = featureInfo.featureType;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.Adventures then
			self.AdventureUpgrade.treeID = featureInfo.garrTalentTreeID;
			self.AdventureUpgrade.featureType = featureInfo.featureType;
		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.SanctumUnique then
			self.UniqueUpgrade.treeID = featureInfo.garrTalentTreeID;
			self.UniqueUpgrade.featureType = featureInfo.featureType;
		end
	end
end

function CovenantSanctumUpgradesTabMixin:SetUpTextureKits()
	local covenantID = GetCovenantID();
	if self.covenantID ~= covenantID then
		self.covenantID = covenantID;

		SetupTextureKit(self, mainTextureKitRegions);
		SetupTextureKit(self.TalentsList, listTextureKitRegions);
		SetupTextureKit(self.BagsGlowFrame, bagsGlowTextureKitRegions);

		for i, frame in ipairs(self.Upgrades) do
			frame:SetUpTextureKit();
		end
	end
end

function CovenantSanctumUpgradesTabMixin:UpdateCurrencies()
	self.CurrencyDisplayGroup:Refresh();
end

function CovenantSanctumUpgradesTabMixin:GetSortedResearchCurrencyCosts(currencyCosts)
	local outputTable = { };
	for i, orderValue in ipairs(self.currencyOrder) do
		for j, cost in ipairs(currencyCosts) do
			if cost.currencyType == orderValue then
				tinsert(outputTable, cost)
				break;
			end
		end
	end
	return outputTable;
end

function CovenantSanctumUpgradesTabMixin:CheckTutorials()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_COVENANT_RESERVOIR_DEPOSIT) and C_CovenantSanctumUI.CanDepositAnima() then
		local helpTipInfo = {
			text = COVENANT_SANCTUM_TUTORIAL4,
			buttonStyle = HelpTip.ButtonStyle.None,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_COVENANT_RESERVOIR_DEPOSIT,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			onAcknowledgeCallback = GenerateClosure(self.CheckTutorials, self),
		};
		HelpTip:Show(self, helpTipInfo, self.DepositButton);
	elseif not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_COVENANT_RESERVOIR_FEATURES) and self:HasAnySoulCurrencies() then
		local helpTipInfo = {
			text = COVENANT_SANCTUM_TUTORIAL5,
			buttonStyle = HelpTip.ButtonStyle.None,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_COVENANT_RESERVOIR_FEATURES,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 59,
			offsetY = 179,
		};
		HelpTip:Show(self, helpTipInfo);
	end
end

function CovenantSanctumUpgradesTabMixin:HasAnySoulCurrencies()
	local currencies = C_CovenantSanctumUI.GetSoulCurrencies();
	for i, currencyID in ipairs(currencies) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		if currencyInfo.quantity > 0 then
			return true;
		end
	end
	return false;
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

	local inIntroMode = not self:GetParent():HasAnyTalents();

	local lastTalentFrame = nil;
	for i, talentInfo in ipairs(treeInfo.talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
			self.upgradeTalentID = talentInfo.id;
		end

		local talentFrame = self.talentPool:Acquire();
		talentInfo.researchCurrencyCosts = self:GetParent():GetSortedResearchCurrencyCosts(talentInfo.researchCurrencyCosts);
		talentFrame:Set(talentInfo, inIntroMode);

		if lastTalentFrame then
			talentFrame:SetPoint("TOP", lastTalentFrame, "BOTTOM", 0, -1);
		else
			talentFrame:SetPoint("TOP", -4, -131);
		end

		talentFrame:Show();
		lastTalentFrame = talentFrame;

		if i == 1 and inIntroMode then
			break;
		end
	end

	self.Title:SetText(treeInfo.title);
	local currentTier = GetCurrentTier(treeInfo.talents);
	if currentTier == 0 then
		self.Tier:SetText(COVENANT_SANCTUM_TIER_INACTIVE);
	else
		self.Tier:SetFormattedText(COVENANT_SANCTUM_TIER, currentTier);
	end
	self.UpgradeButton:SetEnabled(self.upgradeTalentID ~= nil);

	if inIntroMode then
		self.UpgradeButton:SetText(COVENANT_SANCTUM_ACTIVATE);
		self.IntroBox:SetTalent(treeInfo.talents[1].id);
	else
		self.UpgradeButton:SetText(COVENANT_SANCTUM_UNLOCK_UPGRADE);
		self.IntroBox:Hide();
	end
end

function CovenantSanctumUpgradeTalentListMixin:Upgrade()
	if self.upgradeTalentID then
		PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_UNLOCK_UPGRADE);
		C_Garrison.ResearchTalent(self.upgradeTalentID, 1);
	end
end

function CovenantSanctumUpgradeTalentListMixin:FindTalentButton(talentID)
	for talentFrame in self.talentPool:EnumerateActive() do
		if talentFrame.talentID == talentID then
			return talentFrame;
		end
	end
	return nil;
end

--=============================================================================================
CovenantSanctumIntroBoxMixin = { };

function CovenantSanctumIntroBoxMixin:SetTalent(talentID)
	self.talentID = talentID;

	local list = self:GetParent();
	local panel = list:GetParent();
	self.Description:SetText(panel:GetSelectedTreeDescriptionText());

	local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.IntroBoxBackground, GetCovenantTextureKit());
	self.Background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	self:SetStatusText();

	self:Show();
end

function CovenantSanctumIntroBoxMixin:SetStatusText()
	local talent = C_Garrison.GetTalentInfo(self.talentID);
	if talent.isBeingResearched then
		self:SetScript("OnUpdate", self.UpdateResearchTime);
		self.StatusText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self:UpdateResearchTime();
	else
		self:SetScript("OnUpdate", nil);
		if talent.talentAvailability == Enum.GarrisonTalentAvailability.Available then
			self.StatusText:SetText(COVENANT_SANCTUM_CLICK_ACTIVATE);
			self.StatusText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		else
			self.StatusText:SetText(nil);
		end
	end
end

function CovenantSanctumIntroBoxMixin:UpdateResearchTime()
	local talent = C_Garrison.GetTalentInfo(self.talentID);
	local text = string.format(COVENANT_SANCTUM_TIME_REMAINING, timeFormatter:Format(talent.timeRemaining));
	self.StatusText:SetText(text);
end

--=============================================================================================
CovenantSanctumUpgradeTalentMixin = { };

function CovenantSanctumUpgradeTalentMixin:OnLoad()
	self.Name:SetFontObjectsToTry("SystemFont_Shadow_Med2", "GameFontHighlight");
end

function CovenantSanctumUpgradeTalentMixin:Set(talentInfo, inIntroMode)
	self.Name:SetText(talentInfo.name);
	self.Icon:SetTexture(talentInfo.icon);

	self.talentID = talentInfo.id;
	local disabled = false;
	local abbreviateCost = false;
	local showingCost = false;

	local nameColor = HIGHLIGHT_FONT_COLOR;
	local textColor = HIGHLIGHT_FONT_COLOR;
	local tierColor = nil;
	if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
		self.InfoText:SetText(COVENANT_SANCTUM_UPGRADE_ACTIVE);
		textColor = NORMAL_FONT_COLOR;
		tierColor = NORMAL_FONT_COLOR;
	elseif talentInfo.isBeingResearched then
		self.InfoText:SetText(COVENANT_SANCTUM_UPGRADE_ACTIVATING);
		textColor = RED_FONT_COLOR;
	elseif talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
		local costString = GetGarrisonTalentCostString(talentInfo, abbreviateCost);
		self.InfoText:SetText(costString or "");
		showingCost = not not costString;
		nameColor = GREEN_FONT_COLOR;
		tierColor = GREEN_FONT_COLOR;
	else
		disabled = true;
		local isMet, failureString = C_Garrison.IsTalentConditionMet(talentInfo.id);
		if isMet then
			local costString = GetGarrisonTalentCostString(talentInfo, abbreviateCost);
			self.InfoText:SetText(costString);
			showingCost = not not costString;
		else
			self.InfoText:SetText(failureString or "");
		end
		nameColor = DISABLED_FONT_COLOR;
		tierColor = DISABLED_FONT_COLOR;
	end
	self.Name:SetTextColor(nameColor:GetRGB());
	self.InfoText:SetTextColor(textColor:GetRGB());
	if tierColor and not inIntroMode then
		self.TierBorder:Show();
		self.Tier:SetText(talentInfo.tier + 1);
		self.Tier:SetTextColor(tierColor:GetRGB());
	else
		self.TierBorder:Hide();
		self.Tier:SetText(nil);
	end

	local spaceOutLines = false;
	if showingCost then
		if self.Name:GetNumLines() > 1 and self.Name:GetFontObject() == SystemFont_Shadow_Med2 then
			spaceOutLines = true;
		end
	end
	if spaceOutLines then
		self.Name:SetPoint("TOPLEFT", 58, -5);
		self.InfoText:SetPoint("LEFT", self, "BOTTOMLEFT", 58, 13);
	else
		self.Name:SetPoint("TOPLEFT", 58, -6);
		self.InfoText:SetPoint("LEFT", self, "BOTTOMLEFT", 58, 14);
	end

	self.Icon:SetDesaturated(disabled);
	if disabled then
		self.IconBorder:SetAtlas("CovenantSanctum-Upgrade-Icon-Border-Disabled", TextureKitConstants.UseAtlasSize);
	else
		local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.IconBorder, GetCovenantTextureKit());
		self.IconBorder:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end

	if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
		self.Border:SetAtlas("CovenantSanctum-Upgrade-Border-Available");
	else
		local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.Border, GetCovenantTextureKit());
		self.Border:SetAtlas(atlas);
	end

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
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughResources] = COVENANT_SANCTUM_NOT_ENOUGH_RESOURCES;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughGold] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_GOLD;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableTierUnavailable] = ORDER_HALL_TALENT_UNAVAILABLE_TIER_UNAVAILABLE;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent] = COVENANT_SANCTUM_TALENT_REQUIRES_PREVIOUS_TIER;

function CovenantSanctumUpgradeTalentMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:RefreshTooltip();
end

function CovenantSanctumUpgradeTalentMixin:RefreshTooltip()
	local talent			= C_Garrison.GetTalentInfo(self.talentID);
	local garrTalentTreeID	= C_CovenantSanctumUI.GetCurrentTalentTreeID();
	local talentTreeType	= C_Garrison.GetGarrisonTalentTreeType(garrTalentTreeID);

	GameTooltip:ClearLines();
	self.UpdateTooltip = nil;

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
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..timeFormatter:Format(talent.timeRemaining), 1, 1, 1);
		self.UpdateTooltip = CovenantSanctumUpgradeTalentMixin.RefreshTooltip;
	elseif (talentTreeType == Enum.GarrTalentTreeType.Tiers and not talent.selected) or (talentTreeType == Enum.GarrTalentTreeType.Classic and not talent.researched) then
		GameTooltip:AddLine(" ");

		if (talent.researchDuration and talent.researchDuration > 0) then
			GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..timeFormatter:Format(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
			self.UpdateTooltip = CovenantSanctumUpgradeTalentMixin.RefreshTooltip;
		end

		local costString = GetGarrisonTalentCostString(talent);
		if costString then
			GameTooltip:AddLine(costString, 1, 1, 1);
		end

		if talent.talentAvailability == Enum.GarrisonTalentAvailability.Available or (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching) then
			GameTooltip_AddInstructionLine(GameTooltip, COVENANT_SANCTUM_TALENT_RESEARCH);
		else
			if (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailablePlayerCondition and talent.playerConditionReason) then
				GameTooltip:AddLine(talent.playerConditionReason, 1, 0, 0);
			elseif (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent) then
				local prereqTalentButton = self:GetParent():FindTalentButton(talent.prerequisiteTalentID);
				local preReqTalent = prereqTalentButton and prereqTalentButton.talent;
				if (preReqTalent) then
					GameTooltip:AddLine(TOOLTIP_TALENT_PREREQ:format(preReqTalent.talentMaxRank, preReqTalent.name), 1, 0, 0);
				else
					GameTooltip:AddLine(TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent], 1, 0, 0);
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
		self.tier = GetCurrentTier(treeInfo.talents);
		if self.tier == 0 then
			self.Tier:SetText(nil);
			self.TierBorder:Hide();
		else
			self.Tier:SetText(self.tier);
			self.TierBorder:Show();
		end
		self.Icon:SetTexture(treeInfo.talents[1].icon);
		self.SelectedTexture:SetShown(self:IsSelected());
		-- check for cooldown or available talent
		local startTime, researchDuration, researchTalentID;
		local readyToResearch = false;
		for i, talentInfo in ipairs(treeInfo.talents) do
			if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
				startTime = talentInfo.startTime;
				researchDuration = talentInfo.researchDuration;
				researchTalentID = talentInfo.id;
				break;
			elseif talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
				readyToResearch = true;
				break;
			end
		end
		if startTime and researchDuration then
			self.Cooldown:SetCooldownUNIX(startTime, researchDuration);
			self.Cooldown:Show();
			self.Icon:SetVertexColor(0.25, 0.25, 0.25);
		else
			self.Cooldown:Hide();
			self.Icon:SetVertexColor(1, 1, 1);
		end
		self.researchTalentID = researchTalentID;
		self.UpgradeArrow:SetShown(readyToResearch);
	end
end

function CovenantSanctumUpgradeBaseMixin:GetTier()
	return self.tier or 0;
end

function CovenantSanctumUpgradeBaseMixin:GetDescriptionText()
	local covenantID = GetCovenantID();
	if self.featureType and covenantSanctumFeatureDescription[self.featureType] and covenantSanctumFeatureDescription[self.featureType][covenantID] then
		return covenantSanctumFeatureDescription[self.featureType][covenantID];
	end
	return "";
end

function CovenantSanctumUpgradeBaseMixin:OnMouseDown()
	local parent = self:GetParent();
	if parent:GetSelectedTree() ~= self.treeID then
		HelpTip:Acknowledge(parent, COVENANT_SANCTUM_TUTORIAL5);
		parent:SetSelectedTree(self.treeID);

		local covenantData = GetCovenantData();
		PlaySound(covenantData.upgradeTabSelectSoundKitID);
	end
end

function CovenantSanctumUpgradeBaseMixin:OnEnter()
	self.HighlightTexture:Show();
	self:RefreshTooltip();
end

function CovenantSanctumUpgradeBaseMixin:RefreshTooltip()
	local treeInfo = C_Garrison.GetTalentTreeInfo(self.treeID);
	if treeInfo then
		local timeRemaining;
		for i, talentInfo in ipairs(treeInfo.talents) do
			if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
				timeRemaining = talentInfo.timeRemaining;
				break;
			end
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -7);
		GameTooltip_SetTitle(GameTooltip, treeInfo.title);
		GameTooltip_AddNormalLine(GameTooltip, self:GetDescriptionText());
		if timeRemaining and timeRemaining > 0 then
			self.UpdateTooltip = self.RefreshTooltip;
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			local text = string.format(COVENANT_SANCTUM_TIME_REMAINING, timeFormatter:Format(timeRemaining));
			GameTooltip_AddHighlightLine(GameTooltip, text);
		else
			self.UpdateTooltip = nil;
		end
		GameTooltip:Show();
	end
end

function CovenantSanctumUpgradeBaseMixin:OnLeave()
	self.HighlightTexture:Hide();
	GameTooltip:Hide();
end

function CovenantSanctumUpgradeBaseMixin:IsSelected()
	return self:GetParent():GetSelectedTree() == self.treeID;
end

function CovenantSanctumUpgradeBaseMixin:SetUpTextureKit()
	SetupTextureKit(self, featureBorderTextureKitRegions);
end

--=============================================================================================
CovenantSanctumUpgradeTreeMixin = CreateFromMixins(CovenantSanctumUpgradeBaseMixin);

--=============================================================================================
CovenantSanctumUpgradeReservoirMixin = CreateFromMixins(CovenantSanctumUpgradeBaseMixin);

local ORB_INSIDE_HEIGHT = 182;

function CovenantSanctumUpgradeReservoirMixin:OnHide()
	local isFull = false;
	self:UpdateFullSound(isFull);
	StaticPopup_Hide("CONFIRM_SANCTUM_UPGRADE");
end

function CovenantSanctumUpgradeReservoirMixin:OnEnter()
	self.isMousedOver = true;
end

function CovenantSanctumUpgradeReservoirMixin:OnLeave()
	self.isMousedOver  = false;
	if self.showingTooltip then
		self.showingTooltip = false;
		GameTooltip:Hide();
	end
end

function CovenantSanctumUpgradeReservoirMixin:OnUpdate(elapsed)
	if self.strandRate then
		local changeBack = self.strandRate * elapsed;

		self.horizProgress = (self.horizProgress or 0) + changeBack;
		if self.horizProgress >= 1 then
			self.horizProgress = self.horizProgress - 1;
		end
		self.vertProgress = (self.vertProgress or 0) - changeBack;
		if self.vertProgress <= 0 then
			self.vertProgress = 1 - self.vertProgress;
		end

		local vertStart = self.vertProgress;
		local horizStart = self.horizProgress;
		if self.reverseDir then
			vertStart = 1 - vertStart;
			horizStart = 1 - horizStart;
		end

		self.ClippedElements.VerticalStrands:SetTexCoord(0, 1, vertStart, vertStart + 1);
		self.ClippedElements.HorizontalStrands:SetTexCoord(horizStart, horizStart + 1, 0, 1);
	end

	if self.isMousedOver then
		local cx, cy = GetCursorPosition();
		local mx, my = self:GetCenter();
		local scale = self:GetEffectiveScale();
		local distance = CalculateDistance(cx, cy, mx * scale, my * scale);
		local tooltipMaxDistance = (ORB_INSIDE_HEIGHT / 2) * scale;
		if distance < tooltipMaxDistance then
			if not self.showingTooltip then
				self.showingTooltip = true;
				local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo();
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -30, -30);
				GameTooltip:SetCurrencyByID(animaCurrencyID);
			end
		elseif self.showingTooltip then
			self.showingTooltip = false;
			GameTooltip:Hide();
		end
	end
end

function CovenantSanctumUpgradeReservoirMixin:SetUpTextureKit()
	SetupTextureKit(self, reservoirTextureKitRegions);
	SetupTextureKit(self.ClippedElements, reservoirClippedElementsTextureKitRegions);
	SetupTextureKit(self.FullElements, reservoirFullElementsTextureKitRegions);

	self:SetUpAnimations();
end

function CovenantSanctumUpgradeReservoirMixin:SetUpAnimations()
	local clippedFrame = self.ClippedElements;
	local fullFrame = self.FullElements;
	local textureKit = GetCovenantTextureKit();
	local animSettings = reservoirAnimSettings[GetCovenantID()];

	-- specks
	local highSpecks = animSettings.highSpecks;
	fullFrame.HighSpeck1:SetShown(highSpecks);
	fullFrame.HighSpeck2:SetShown(highSpecks);
	fullFrame.HighSpeck1.Anim:SetPlaying(highSpecks);
	fullFrame.HighSpeck2.Anim:SetPlaying(highSpecks);
	local lowSpecks = animSettings.lowSpecks;
	clippedFrame.LowSpeck1:SetShown(lowSpecks);
	clippedFrame.LowSpeck2:SetShown(lowSpecks);
	clippedFrame.LowSpeck1.Anim:SetPlaying(lowSpecks);
	clippedFrame.LowSpeck2.Anim:SetPlaying(lowSpecks);

	-- spirals
	if animSettings.spirals then
		SetupTextureKitOnFrame(textureKit, clippedFrame.Spiral1, "CovenantSanctum-Reservoir-Idle-%s-Spiral1", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		SetupTextureKitOnFrame(textureKit, clippedFrame.Spiral2, "CovenantSanctum-Reservoir-Idle-%s-Spiral2", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		SetupTextureKitOnFrame(textureKit, clippedFrame.Spiral3, "CovenantSanctum-Reservoir-Idle-%s-Spiral3", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	end
	clippedFrame.Spiral1:SetShown(animSettings.spirals);
	clippedFrame.Spiral2:SetShown(animSettings.spirals);
	clippedFrame.Spiral3:SetShown(animSettings.spirals);
	clippedFrame.SpiralsAnim:SetPlaying(animSettings.spirals);

	-- pulse
	if animSettings.pulse then
		SetupTextureKitOnFrame(textureKit, clippedFrame.Pulse, "CovenantSanctum-Reservoir-Idle-%s-Pulse", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		clippedFrame.Pulse:SetAlpha(0);
		clippedFrame.PulseAlphaAnim:Restart();
		clippedFrame.PulseRotateAnim:Restart();
		clippedFrame.Pulse:Show();

		SetupTextureKitOnFrame(textureKit, clippedFrame.Pulse2, "CovenantSanctum-Reservoir-Idle-%s-Veins", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		clippedFrame.Pulse2:SetAlpha(0);
		clippedFrame.Pulse2AlphaAnim:Restart();
		clippedFrame.Pulse2RotateAnim:Restart();
		clippedFrame.Pulse2:Show();
	else
		clippedFrame.Pulse:Hide();
	end

	-- strands
	local strandSettings = animSettings.strand;
	if strandSettings then
		if strandSettings.vert then
			SetupTextureKitOnFrame(textureKit, clippedFrame.VerticalStrands, "!CovenantSanctum-Reservoir-Idle-%s-Strands", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
			clippedFrame.VerticalStrands:SetAlpha(strandSettings.alpha);
			clippedFrame.VerticalStrands:SetBlendMode(strandSettings.mode);
		end
		if strandSettings.horiz then
			SetupTextureKitOnFrame(textureKit, clippedFrame.HorizontalStrands, "_CovenantSanctum-Reservoir-Idle-%s-Strands2", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
			clippedFrame.HorizontalStrands:SetAlpha(strandSettings.alpha);
			clippedFrame.HorizontalStrands:SetBlendMode(strandSettings.mode);
		end		
		clippedFrame.VerticalStrands:SetShown(strandSettings.vert);
		clippedFrame.HorizontalStrands:SetShown(strandSettings.horiz);
		-- store for lookups in OnUpdate
		self.strandRate = strandSettings.rate;
		self.reverseDir = strandSettings.reverseDir;
	else
		clippedFrame.VerticalStrands:Hide();
		clippedFrame.HorizontalStrands:Hide();
		self.strandRate = nil;
		self.reverseDir = nil;
	end

	-- inner glow
	local glowSettings = animSettings.glow;
	if glowSettings then
		-- reverse from-to for steps 2 & 4
		local fromAlpha = glowSettings.fromAlpha;
		local toAlpha = glowSettings.toAlpha;
		local alphaAnim = clippedFrame.InnerGlow.AlphaAnim;
		alphaAnim.Step1:SetFromAlpha(fromAlpha);
		alphaAnim.Step1:SetToAlpha(toAlpha);
		alphaAnim.Step2:SetFromAlpha(toAlpha);
		alphaAnim.Step2:SetToAlpha(fromAlpha);
		alphaAnim.Step3:SetFromAlpha(fromAlpha);
		alphaAnim.Step3:SetToAlpha(toAlpha);
		alphaAnim.Step4:SetFromAlpha(toAlpha);
		alphaAnim.Step4:SetToAlpha(fromAlpha);
		alphaAnim:Play();
		if glowSettings.rotate then
			clippedFrame.InnerGlow.RotateAnim:Play();
		else
			clippedFrame.InnerGlow.RotateAnim:Stop();
		end
	else
		clippedFrame.InnerGlow.AlphaAnim:Stop();
		clippedFrame.InnerGlow.RotateAnim:Stop();
	end

	-- restart shared elements
	clippedFrame.FillBackground.Anim:Restart();
end

function CovenantSanctumUpgradeReservoirMixin:Refresh()
	self:UpdateAnima();
end

function CovenantSanctumUpgradeReservoirMixin:UpdateAnima()
	local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo();
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(animaCurrencyID);
	local value = currencyInfo and currencyInfo.quantity or 0;
	self.value = value;

	local isFull = false;
	if value == 0 then
		self.ClippedElements:Hide();
		self.FullElements.Spark:Hide();
	else
		self.ClippedElements:Show();
		local totalHeight = 336;
		if value >= maxDisplayableValue then
			self.ClippedElements:SetHeight(totalHeight);
			self.FullElements.Spark:Hide();
			isFull = true;
		else
			local base = (totalHeight - ORB_INSIDE_HEIGHT) / 2;
			local percent = value / maxDisplayableValue;
			local height = base + ORB_INSIDE_HEIGHT * percent;
			self.ClippedElements:SetHeight(height);
			self.FullElements.Spark:Show();
		end
	end

	self.FullElements.StaticGlow:SetShown(isFull);
	local modelScene = self.ModelScene;
	modelScene:SetShown(isFull);
	if isFull then
		local effectID = GetEffectID(EFFECT_ANIMA_FULL);
		if modelScene.effect and modelScene.effect:GetInitialEffectID() ~= effectID then
			-- player switched covenants
			modelScene.effect:CancelEffect();
			modelScene.effect = nil;
		end
		if not modelScene.effect then
			modelScene.effect = modelScene:AddEffect(effectID, self);
		end
	end

	self:UpdateFullSound(isFull);
end

function CovenantSanctumUpgradeReservoirMixin:UpdateFullSound(isFull)
	local covenantData = GetCovenantData();
	if isFull and not self.fullAnimaSoundHandle then
		self.fullAnimaSoundHandle = select(2, PlaySound(covenantData.reservoirFullSoundKitID));
	elseif not isFull and self.fullAnimaSoundHandle then
		StopSound(self.fullAnimaSoundHandle);
		self.fullAnimaSoundHandle = nil;
	end
end


function CovenantSanctumUpgradeReservoirMixin:GetAnimaAmount()
	return self.value;
end

function CovenantSanctumUpgradeReservoirMixin:StartAnimaGainEffect()
	self.FullElements.GlowAnim:Play();
	self.FullElements.SparkGlowAnim:Play();
end

function CovenantSanctumUpgradeReservoirMixin:CancelAnimaGainEffect()
	self.FullElements.SparkGlowAnim:Stop();
	self.FullElements.SparkGlow:SetAlpha(0);
	self.FullElements.GlowAnim:Stop();
	self.FullElements.Glow:SetAlpha(0);
end

CovenantSanctumUpgradeButtonMixin = {};

function CovenantSanctumUpgradeButtonMixin:OnClick(button)
	local talent = C_Garrison.GetTalentInfo(self:GetParent().upgradeTalentID);
	if(talent) then 
		StaticPopup_Show("CONFIRM_SANCTUM_UPGRADE", nil, nil, {owner = self:GetParent(), talent = talent}); 
	end 
end