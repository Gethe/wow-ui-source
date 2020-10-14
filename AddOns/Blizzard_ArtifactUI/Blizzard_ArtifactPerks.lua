ArtifactPerksMixin = {}

local NUM_CURVED_LINE_SEGEMENTS = 20;
local CURVED_LINE_RADIUS_SCALAR = 0.98;
local CURVED_LINE_THICKNESS = 5;

-- Indexed by artifact tier.
local ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE = { [1] = .005, [2] = .00305 };
local ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE = .0019;

-------------------- Animation Constants Start --------------------
local ARTIFACT_TIER_2_REVEAL_START_DELAY = 0.5;

-- Numbers animate off the tier 1 infinite progression while your artifact power ticks up.
local ARTIFACT_TIER_2_REFUND_NUMBER_TICK_SPEED = 0.09;

-- The Tier 2 area flashes with a rune.
local ARTIFACT_TIER_2_RUNE_FLASH_DELAY = 1.0;

-- The Tier 2 constellation animates in.
local ARTIFACT_TIER_2_CONSTELLATION_DELAY = 1.05;
local ARTIFACT_TIER_2_FIRST_CURVED_LINE_DELAY = 0;
local ARTIFACT_TIER_2_SECOND_CURVED_LINE_DELAY = 0.4;
local ARTIFACT_TIER_2_THIRD_CURVED_LINE_DELAY = 0.7;
local ARTIFACT_TIER_2_CURVED_LINE_TICK_SPEED = 0.035;

-- The Tier 2 crest animates in with frame shake.
local ARTIFACT_TIER_2_CREST_DELAY = 1.55;
local ARTIFACT_TIER_2_SHAKE_DELAY = 0.345;
local ARTIFACT_TIER_2_SHAKE = { { x = 0, y = -30}, { x = 0, y = 30}, { x = 0, y = -30}, { x = 0, y = 30}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, };
local ARTIFACT_TIER_2_SHAKE_DURATION = 0.25;
local ARTIFACT_TIER_2_SHAKE_FREQUENCY = 0.001;

ARTIFACT_TIER_2_SOUND_REFUND_LOOP_START_DELAY = 0.3;
ARTIFACT_TIER_2_SOUND_REFUND_END_DELAY = 0.9;
ARTIFACT_TIER_2_SOUND_REFUND_LOOP_STOP_DELAY = 0.0;
ARTIFACT_TIER_2_SOUND_REFUND_LOOP_FADE_OUT_TIME = 500;

local TIER_2_FINAL_POWER_REVEAL_REVEAL_DELAY = 0.5;
local TIER_2_FINAL_POWER_REVEAL_SHAKE_DELAY = 0.345;
local TIER_2_FINAL_POWER_REVEAL_SHAKE = ARTIFACT_TIER_2_SHAKE;
local TIER_2_FINAL_POWER_REVEAL_SHAKE_DURATION = 0.22;
local TIER_2_FINAL_POWER_REVEAL_SHAKE_FREQUENCY = 0.001;

local TIER_2_GLOW_TIME = 3.2;

local TIER_2_FORGE_EFFECT_FADE_IN_DELAY = 0;
local TIER_2_BACKGROUND_FRONT_INTENSITY_IN_DELAY = 0;
local TIER_2_BACKGROUND_FRONT_INTENSITY_IN_EFFECT = 0;
local TIER_2_FORGE_EFFECT_FADE_OUT_DELAY = 0.5;
local TIER_2_BACKGROUND_FRONT_INTENSITY_OUT_DELAY = 0.5;

local TIER_2_SLAM_EFFECT_DELAY = 0.275;
local TIER_2_SLAM_EFFECT_HIDE_DELAY = 0.5;

local TIER2_FORGING_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(55, 382335);			--"SPELLS\\EASTERN_PLAGUELANDS_BEAM_EFFECT.M2";
local TIER2_SLAM_EFFECT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(57, 1369310);		--"SPELLS\\CFX_WARRIOR_THUNDERCLAP_CASTWORLD.M2"

-------------------- Animation Constants End --------------------

function ArtifactPerksMixin:OnLoad()	
	self.powerButtonPool = CreateFramePool("BUTTON", self, "ArtifactPowerButtonTemplate");
	self.callbackTimers = {};
end

function ArtifactPerksMixin:OnShow()	
	self.modelTransformElapsed = 0;
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function ArtifactPerksMixin:OnHide()
	self:UnregisterEvent("CURSOR_UPDATE");
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:CancelAllTimedAnimations();
	self:SkipTier2Animation();
end

function ArtifactPerksMixin:OnEvent(event, ...)
	if event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self:RefreshPowerTiers();
	end
end

function ArtifactPerksMixin:OnUIOpened()

	self:Refresh(true);
end

function ArtifactPerksMixin:OnAppearanceChanging()
	self.isAppearanceChanging = true;
end

function ArtifactPerksMixin:RefreshModel()
	local itemID, altItemID, _, _, _, _, _, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetArtifactInfo();
	local _, _, _, _, _, _, uiCameraID, altHandUICameraID, _, _, _, modelAlpha, modelDesaturation = C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID);

	self.Model.uiCameraID = uiCameraID;
	self.Model.desaturation = modelDesaturation;
	if itemAppearanceID then
		self.Model:SetItemAppearance(itemAppearanceID);
	else
		self.Model:SetItem(itemID, appearanceModID);
	end

	local backgroundFrontTargetAlpha = 1.0 - (modelAlpha or 1.0);
	self.Model.backgroundFrontTargetAlpha = backgroundFrontTargetAlpha;
	self.Model.ForgingEffectAnimIn.Fade:SetFromAlpha(backgroundFrontTargetAlpha);
	self.Model.ForgingEffectAnimIn.Fade:SetToAlpha(backgroundFrontTargetAlpha * TIER_2_BACKGROUND_FRONT_INTENSITY_IN_EFFECT);
	self.Model.ForgingEffectAnimOut.Fade:SetFromAlpha(backgroundFrontTargetAlpha * TIER_2_BACKGROUND_FRONT_INTENSITY_IN_EFFECT);
	self.Model.ForgingEffectAnimOut.Fade:SetToAlpha(backgroundFrontTargetAlpha);
	self.Model.BackgroundFront:SetAlpha(backgroundFrontTargetAlpha);

	local baseModelFrameLevel = 505;
	local baseAltModelFrameLevel = 500;
	if ( altOnTop ) then
		baseModelFrameLevel, baseAltModelFrameLevel = baseAltModelFrameLevel, baseModelFrameLevel;
	end

	self.Model:SetFrameLevel(baseModelFrameLevel);

	if altItemID and altHandUICameraID then
		self.AltModel.uiCameraID = altHandUICameraID;
		self.AltModel.desaturation = modelDesaturation;
		if altItemAppearanceID then
			self.AltModel:SetItemAppearance(altItemAppearanceID);
		else
			self.AltModel:SetItem(altItemID, appearanceModID);
		end

		self.AltModel:Show();
		self.AltModel:SetFrameLevel(baseAltModelFrameLevel);
	else
		self.AltModel:Hide();
	end
end

function ArtifactsModelTemplate_OnModelLoaded(self)
	local CUSTOM_ANIMATION_SEQUENCE = 213;
	local animationSequence = self:HasAnimation(CUSTOM_ANIMATION_SEQUENCE) and CUSTOM_ANIMATION_SEQUENCE or 0;

	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
	self:SetLight(true, false, 0, 0, 0, .7, 1.0, 1.0, 1.0);
	self:SetViewTranslation(-88, 0);

	self:SetAnimation(animationSequence, 0);

	if C_ArtifactUI.IsArtifactDisabled() then
		self:SetDesaturation(1);
		self:SetParticlesEnabled(false);
		self:SetPaused(true);
	else	
		if ( self.useShadowEffect ) then
			self:SetShadowEffect(1);
		else
			self:SetDesaturation(self.desaturation or .5);
		end
	end
end

function ArtifactPerksMixin:RefreshBackground()
	local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
	if artifactArtInfo and artifactArtInfo.textureKit then
		self.textureKit = artifactArtInfo.textureKit;

		local bgAtlas = ("%s-BG"):format(artifactArtInfo.textureKit);
		self.BackgroundBack:SetAtlas(bgAtlas);
		local artifactDisabled = C_ArtifactUI.IsArtifactDisabled();
		self.BackgroundBack:SetDesaturated(artifactDisabled);
		self.Model.BackgroundFront:SetAtlas(bgAtlas);
		self.Model.BackgroundFront:SetDesaturated(artifactDisabled);
		self.Tier2ForgingScene.BackgroundMiddle:SetAtlas(bgAtlas);
		self.Tier2ForgingScene.BackgroundMiddle:Show();


		local crestAtlas = ("%s-BG-Rune"):format(artifactArtInfo.textureKit);
		self.CrestFrame.CrestRune1:SetAtlas(crestAtlas, true);
		self.CrestFrame.CrestRune1:SetDesaturated(artifactDisabled);
	else
		self.textureKit = nil;
	end
end

function ArtifactPerksMixin:OnUpdate(elapsed)
	self:TryRefresh();
end

function ArtifactPerksMixin:AreAllGoldMedalsPurchasedByTier(tier)
	return self.areAllGoldMedalsPurchasedByTier[tier] == nil or self.areAllGoldMedalsPurchasedByTier[tier];
end

function ArtifactPerksMixin:AreAllPowersPurchasedByTier(tier)
	return self.areAllPowersPurchasedByTier[tier] == nil or self.areAllPowersPurchasedByTier[tier];
end

function ArtifactPerksMixin:GetStartingPowerButtonByTier(tier)
	return self.startingPowerButtonsByTier[tier];
end

function ArtifactPerksMixin:GetFinalPowerButtonByTier(tier)
	return self.finalPowerButtonsByTier[tier];
end

function ArtifactPerksMixin:RefreshPowers(newItem)
	if newItem or not self.powerIDToPowerButton then
		self.powerButtonPool:ReleaseAll();
		self.powerIDToPowerButton = {};
	end

	local currentTier = C_ArtifactUI.GetArtifactTier();
	self.startingPowerButtonsByTier = {};
	self.finalPowerButtonsByTier = {};
	self.areAllPowersPurchasedByTier = {};
	self.areAllGoldMedalsPurchasedByTier = {};

	local powers = C_ArtifactUI.GetPowers();

	for i, powerID in ipairs(powers) do
		local powerButton = self.powerIDToPowerButton[powerID];

		if not powerButton then
			powerButton = self.powerButtonPool:Acquire();
			self.powerIDToPowerButton[powerID] = powerButton;

			powerButton:ClearOldData();
		end

		powerButton:SetupButton(powerID, self.BackgroundBack, self.textureKit);
		powerButton.links = {};
		powerButton.owner = self;

		if powerButton:IsStart() then
			self.startingPowerButtonsByTier[powerButton:GetTier()] = powerButton;
		elseif powerButton:IsFinal() then
			self.finalPowerButtonsByTier[powerButton:GetTier()] = powerButton;
		elseif not powerButton:IsCompletelyPurchased() then
			self.areAllPowersPurchasedByTier[powerButton:GetTier()] = false;
			if powerButton:IsGoldMedal() then
				self.areAllGoldMedalsPurchasedByTier[powerButton:GetTier()] = false;
			end
		end

		local meetsTier = currentTier >= powerButton:GetTier();
		powerButton:SetShown(meetsTier and (powerButton:GetTier() ~= 2 or not self.preppingTierTwoReveal));
		powerButton:SetLinksEnabled(meetsTier and not powerButton:IsFinal());
	end

	self:RefreshPowerTiers();
	self:RefreshDependencies(powers);
	self:RefreshRelics();
end

function ArtifactPerksMixin:RefreshFinalPowerForTier(tier, isUnlocked)
	local finalTierButton = self:GetFinalPowerButtonByTier(tier);
	if finalTierButton then
		if isUnlocked then
			if self.wasFinalPowerButtonUnlockedByTier[tier] == false then
				self.wasFinalPowerButtonUnlockedByTier[tier] = true;
				if tier == 1 then
					finalTierButton:PlayUnlockAnimation();
				elseif tier == 2 then
					self:CancelAllTimedAnimations();
					finalTierButton:Hide();
					self:StartWithDelay(TIER_2_FINAL_POWER_REVEAL_REVEAL_DELAY, function ()
						finalTierButton:Show();
						finalTierButton:PlayUnlockAnimation();
						finalTierButton.Tier2FinalPowerSparks:Play();
						self:StartWithDelay(TIER_2_FINAL_POWER_REVEAL_SHAKE_DELAY, function ()
							ScriptAnimationUtil.ShakeFrame(self:GetParent(), TIER_2_FINAL_POWER_REVEAL_SHAKE, TIER_2_FINAL_POWER_REVEAL_SHAKE_DURATION, TIER_2_FINAL_POWER_REVEAL_SHAKE_FREQUENCY);
						end);
					end);
				end
			end
		else
			finalTierButton:Hide();
			self.wasFinalPowerButtonUnlockedByTier[tier] = false;
		end
	end
end

function ArtifactPerksMixin:RefreshPowerTiers()
	self:RefreshFinalPowerForTier(1, self:AreAllGoldMedalsPurchasedByTier(1));
	self:RefreshFinalPowerForTier(2, self:AreAllPowersPurchasedByTier(2));

	if C_ArtifactUI.GetArtifactTier() >= 2 or C_ArtifactUI.IsMaxedByRulesOrEffect() then
		local finalTier2Button = self:GetFinalPowerButtonByTier(2);
		if finalTier2Button then
			self.CrestFrame:ClearAllPoints();
			self.CrestFrame:SetPoint("CENTER", finalTier2Button, "CENTER");
			self.CrestFrame:Show();
			
			local forceUpdate = true;

			self.Tier2ForgingScene:Show();
			local forgingEffect = StaticModelInfo.SetupModelScene(self.Tier2ForgingScene, TIER2_FORGING_MODEL_SCENE_INFO, forceUpdate);
			if ( forgingEffect ) then
				forgingEffect:SetAlpha(0.0);
			end

			StaticModelInfo.SetupModelScene(self.Tier2SlamEffectModelScene, TIER2_SLAM_EFFECT_MODEL_SCENE_INFO, forceUpdate);
		else
			self.CrestFrame:Hide();
			self.Tier2SlamEffectModelScene:Hide();
		end
	else
		self.CrestFrame:Hide();
		self.Tier2SlamEffectModelScene:Hide();
	end
end

function ArtifactPerksMixin:GetOrCreateDependencyLine(lineIndex)
	local lineContainer = self.DependencyLines and self.DependencyLines[lineIndex];
	if lineContainer then
		lineContainer:Show();
		return lineContainer;
	end

	lineContainer = CreateFrame("FRAME", nil, self, "ArtifactDependencyLineTemplate");

	return lineContainer;
end

function ArtifactPerksMixin:GetOrCreateCurvedDependencyLine(lineIndex)
	local lineContainer = self.CurvedDependencyLines and self.CurvedDependencyLines[lineIndex];
	if lineContainer then
		lineContainer:Show();
		return lineContainer;
	end

	lineContainer = CreateFrame("FRAME", nil, self, "ArtifactCurvedDependencyLineTemplate");
	return lineContainer;
end

function ArtifactPerksMixin:HideUnusedWidgets(widgetTable, numUsed, customHideFunc)
	if widgetTable then
		for i = numUsed + 1, #widgetTable do
			widgetTable[i]:Hide();
			if customHideFunc then
				customHideFunc(widgetTable[i]);
			end
		end
	end
end

function ArtifactPerksMixin:TryRefresh()
	if self.perksDirty then
		local artifactItemID = C_ArtifactUI.GetArtifactItemID();
		if not artifactItemID or not C_Item.IsItemDataCachedByID(artifactItemID) then
			return;
		end

		if self.newItem then
			self.numRevealsPlaying = nil;
			self:HideAllLines();
			self:RefreshBackground();
		end

		if self.newItem or self.isAppearanceChanging then
			self:RefreshModel();
		end

		self.queuePlayingReveal = false;
		local hasBoughtAnyPowers = ArtifactUI_HasPurchasedAnything();
		if self.newItem then
			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
			self.wasFinalPowerButtonUnlockedByTier = {};
		elseif self.hasBoughtAnyPowers ~= hasBoughtAnyPowers then
			self:HideAllLines();

			self.hasBoughtAnyPowers = hasBoughtAnyPowers;
			if hasBoughtAnyPowers then
				self.queuePlayingReveal = true;
			end
		end

		local finalTier2WasUnlocked = self.wasFinalPowerButtonUnlockedByTier[2];
		self:RefreshPowers(self.newItem);

		self.TitleContainer:SetPointsRemaining(C_ArtifactUI.GetPointsRemaining());

		self.perksDirty = false;
		self.newItem = nil;
		self.isAppearanceChanging = nil;
		
		if not self.numArtifactTraitsRefunded and (C_ArtifactUI.GetArtifactTier() == 2 or C_ArtifactUI.IsMaxedByRulesOrEffect())then
			if self.preppingTierTwoReveal then
				self:HideTier2();
			else
				self:ShowTier2();
			end
			self.CrestFrame.CrestRune1:SetAlpha(1.0);
			self.Model.BackgroundFront:SetAlpha(self.Model.backgroundFrontTargetAlpha);
			if C_ArtifactUI.IsMaxedByRulesOrEffect() then
				local finalTier1Button = self:GetFinalPowerButtonByTier(1);
				if finalTier1Button then
					finalTier1Button:Show();
				end
				
				local finalTier2Button = self:GetFinalPowerButtonByTier(2);
				if finalTier2Button then
					finalTier2Button:Show();
				end
			end
		end
		
		if self.queuePlayingReveal then
			self:PlayReveal(1);
		elseif self.numArtifactTraitsRefunded then
			self:AnimateTraitRefund(self.numArtifactTraitsRefunded);
			self.numArtifactTraitsRefunded = nil;
		elseif not finalTier2WasUnlocked and self.wasFinalPowerButtonUnlockedByTier[2] then
			self:AnimateInCurvedLine(4);
		else
			if C_ArtifactUI:IsAtForge() and self:ShouldShowTierGlow() then 
				-- We may need to change self.tierGlowSeen to take into account the tier you've seen
				-- rather than just the artifact ID since you could tier up twice without reloading the UI (in theory?).
				self:ShowTierGlow();
				self:StartWithDelay(TIER_2_GLOW_TIME, function() self:HideTierGlow(); end);
			end
		end
	end
end

function ArtifactPerksMixin:HasPurchasedAnythingInCurrentTier()
	if C_ArtifactUI.IsMaxedByRulesOrEffect() then
		return true;
	end
	
	local tier = C_ArtifactUI.GetArtifactTier();
	if tier == 1 then
		return C_ArtifactUI.GetTotalPurchasedRanks() > 0;
	end

	for powerID, powerButton in pairs(self.powerIDToPowerButton) do
		if powerButton:HasRanksFromCurrentTier() then
			return true;
		end
	end
	
	return false;
end

function ArtifactPerksMixin:ShouldShowTierGlow()
	if self:HasPurchasedAnythingInCurrentTier() then
		return false;
	end
	
	local artifactItemID = C_ArtifactUI.GetArtifactInfo();
	return artifactItemID and (not self.tierGlowSeen or self.tierGlowSeen ~= artifactItemID);
end

function ArtifactPerksMixin:ShowTierGlow()
	local tier = C_ArtifactUI.GetArtifactTier();
	local buttonsToHighlight = {};
	local shouldShowGlow = false;
	for powerID, powerButton in pairs(self.powerIDToPowerButton) do
		if (powerButton:GetTier() < tier and powerButton:HasBonusMaxRanksFromTier()) or powerButton == self:GetStartingPowerButtonByTier(tier) then
			if powerButton:CouldSpendPoints() then
				buttonsToHighlight[#buttonsToHighlight + 1] = powerButton;
				shouldShowGlow = true;
			end
		end
	end
	
	if shouldShowGlow then
		self.tierGlowSeen = C_ArtifactUI.GetArtifactInfo();
		for i, button in ipairs(buttonsToHighlight) do
			button.FirstPointWaitingAnimation:Play();
		end
	end
end

function ArtifactPerksMixin:HideTierGlow()
	for powerID, powerButton in pairs(self.powerIDToPowerButton) do
		powerButton.FirstPointWaitingAnimation:Stop();
	end
end

function ArtifactPerksMixin:Refresh(newItem)
	self.perksDirty = true;
	self.newItem = self.newItem or newItem;
end

ArtifactLineMixin = CreateFromMixins(PowerDependencyLineMixin)

function ArtifactLineMixin:IsDeprecated()
	return C_ArtifactUI.IsArtifactDisabled();
end

local function OnUnusedLineHidden(lineContainer)
	lineContainer:OnReleased();
end

function ArtifactPerksMixin:GenerateCurvedLine(startButton, endButton, state, artifactArtInfo)
	local finalTier2Power = self:GetFinalPowerButtonByTier(2);
	if not finalTier2Power then
		return nil;
	end

	local spline = CreateCatmullRomSpline(2);

	local finalPosition = CreateVector2D(finalTier2Power:GetCenter());
	local startPosition = CreateVector2D(startButton:GetCenter());
	local endPosition = CreateVector2D(endButton:GetCenter());

	local angleOffset = math.atan2(finalPosition.y - startPosition.y, startPosition.x - finalPosition.x);

	local totalAngle = Vector2D_CalculateAngleBetween(endPosition.x - finalPosition.x, endPosition.y - finalPosition.y, startPosition.x - finalPosition.x, startPosition.y - finalPosition.y);
	if totalAngle <= 0 then
		return;
	end

	local lengthToEdge = Vector2D_GetLength(Vector2D_Subtract(finalPosition.x, finalPosition.y, endPosition.x, endPosition.y));
	lengthToEdge = lengthToEdge * CURVED_LINE_RADIUS_SCALAR;
	-- Catmullrom splines are not quadratic so they cannot perfectly fit a circle, add enough points so that the sampling will produce something close enough to a circle
	-- Keeping this as a spline for now in case we need to connect something non-circular
	local NUM_SLICES = 10;
	local anglePerSlice = totalAngle / (NUM_SLICES - 1);
	for slice = 1, NUM_SLICES do
		local angle = (slice - 1) * anglePerSlice;
		local x = math.cos(angle + angleOffset) * lengthToEdge;
		local y = math.sin(angle + angleOffset) * lengthToEdge;
		spline:AddPoint(x, y);
	end

	local artifactDisabled = C_ArtifactUI.IsArtifactDisabled();
	local previousEndPoint;
	local previousLineContainer;
	for i = 1, NUM_CURVED_LINE_SEGEMENTS do
		self.numUsedCurvedLines = self.numUsedCurvedLines + 1;
		local lineContainer = self:GetOrCreateCurvedDependencyLine(self.numUsedCurvedLines);
		if artifactDisabled then
			lineContainer:SetConnectedColor(DISABLED_FONT_COLOR);
			lineContainer:SetDisconnectedColor(DISABLED_FONT_COLOR);
		else
			lineContainer:SetConnectedColor(artifactArtInfo.barConnectedColor);
			lineContainer:SetDisconnectedColor(artifactArtInfo.barDisconnectedColor);
		end
		lineContainer:SetEndPoints(finalTier2Power);
		lineContainer:SetScrollAnimationProgressOffset((i - 1) / NUM_CURVED_LINE_SEGEMENTS);
		lineContainer:SetState(state);

		local fromPoint = previousEndPoint or CreateVector2D(spline:CalculatePointOnGlobalCurve(0.0));
		local toPoint = CreateVector2D(spline:CalculatePointOnGlobalCurve(i / NUM_CURVED_LINE_SEGEMENTS));

		local delta = toPoint:Clone();
		delta:Subtract(fromPoint);

		local length = delta:GetLength();
		lineContainer:CalculateTiling(length);

		local thickness = CreateVector2D(-delta.y, delta.x);
		thickness:DivideBy(length);

		thickness:ScaleBy(CURVED_LINE_THICKNESS);

		if previousLineContainer then
			-- We're in the middle or the last piece, connect the start of this to the end of the last

			-- Making these meet by dividing the tangent (miter) would look better, but seems good enough for this scale
			previousLineContainer:SetVertexOffset(UPPER_LEFT_VERTEX, fromPoint.x + thickness.x + 1, -1 - (fromPoint.y + thickness.y));
			previousLineContainer:SetVertexOffset(LOWER_LEFT_VERTEX, fromPoint.x - thickness.x + 1, 1 - (fromPoint.y - thickness.y));

			lineContainer:SetVertexOffset(UPPER_RIGHT_VERTEX, fromPoint.x + thickness.x - 1, -1 - (fromPoint.y + thickness.y));
			lineContainer:SetVertexOffset(LOWER_RIGHT_VERTEX, fromPoint.x - thickness.x - 1, 1 - (fromPoint.y - thickness.y));

			if i == NUM_CURVED_LINE_SEGEMENTS then
				-- Last piece, just go ahead and just connect the line to the end now
				lineContainer:SetVertexOffset(UPPER_LEFT_VERTEX, toPoint.x + thickness.x + 1, -1 - (toPoint.y + thickness.y));
				lineContainer:SetVertexOffset(LOWER_LEFT_VERTEX, toPoint.x - thickness.x + 1, 1 - (toPoint.y - thickness.y));
			end
		else
			-- First piece, just connect the start
			lineContainer:SetVertexOffset(UPPER_RIGHT_VERTEX, fromPoint.x + thickness.x - 1, -1 - (fromPoint.y + thickness.y));
			lineContainer:SetVertexOffset(LOWER_RIGHT_VERTEX, fromPoint.x - thickness.x - 1, 1 - (fromPoint.y - thickness.y));
		end

		previousLineContainer = lineContainer;
		previousEndPoint = toPoint;
	end
	
	return previousLineContainer;
end

function ArtifactPerksMixin:RefreshDependencies(powers)
	self.numUsedLines = 0;
	self.numUsedCurvedLines = 0;

	if ArtifactUI_CanViewArtifact() then
		local artifactDisabled = C_ArtifactUI.IsArtifactDisabled();
		local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
		local lastTier2Power = nil;

		for i, fromPowerID in ipairs(powers) do
			local fromButton = self.powerIDToPowerButton[fromPowerID];
			local fromLinks = C_ArtifactUI.GetPowerLinks(fromPowerID);
			if fromLinks then
				for j, toPowerID in ipairs(fromLinks) do
					local toButton = self.powerIDToPowerButton[toPowerID];
					if self:GetFinalPowerButtonByTier(2) == toButton then
						lastTier2Power = fromButton;
					end
					if not fromButton.links[toPowerID] and fromButton:AreLinksEnabled() then
						if toButton and not toButton.links[fromPowerID] and toButton:AreLinksEnabled() then
							if (not fromButton:GetLinearIndex() or not toButton:GetLinearIndex()) or fromButton:GetLinearIndex() < toButton:GetLinearIndex() then
								local state;
								if self.hasBoughtAnyPowers or ((toButton:IsStart() or toButton:ArePrereqsMet()) and (fromButton:IsStart() or fromButton:ArePrereqsMet())) then
									local hasSpentAny = fromButton.hasSpentAny and toButton.hasSpentAny;
									if hasSpentAny or (fromButton:IsActiveForLinks() and (toButton.hasEnoughPower or toButton:IsCompletelyPurchased())) or (toButton:IsActiveForLinks() and (fromButton.hasEnoughPower or fromButton:IsCompletelyPurchased())) then
										if (fromButton:IsActiveForLinks() and toButton.hasSpentAny) or (toButton:IsActiveForLinks() and fromButton.hasSpentAny) then
											state = PowerDependencyLineMixin.LINE_STATE_CONNECTED;
										else
											state = PowerDependencyLineMixin.LINE_STATE_DISCONNECTED;
										end
									else
										state = PowerDependencyLineMixin.LINE_STATE_LOCKED;
									end
								end

								if fromButton:GetTier() == 2 and toButton:GetTier() == 2 then
									local lineContainer = self:GenerateCurvedLine(fromButton, toButton, state, artifactArtInfo);
									fromButton.links[toPowerID] = lineContainer;
									toButton.links[fromPowerID] = lineContainer;
								else
									self.numUsedLines = self.numUsedLines + 1;
									local lineContainer = self:GetOrCreateDependencyLine(self.numUsedLines);
									if artifactDisabled then
										lineContainer:SetConnectedColor(DISABLED_FONT_COLOR);
										lineContainer:SetDisconnectedColor(DISABLED_FONT_COLOR);
									else
										lineContainer:SetConnectedColor(artifactArtInfo.barConnectedColor);
										lineContainer:SetDisconnectedColor(artifactArtInfo.barDisconnectedColor);
									end
									local fromCenter = CreateVector2D(fromButton:GetCenter());
									fromCenter:ScaleBy(fromButton:GetEffectiveScale());

									local toCenter = CreateVector2D(toButton:GetCenter());
									toCenter:ScaleBy(toButton:GetEffectiveScale());

									toCenter:Subtract(fromCenter);

									lineContainer:CalculateTiling(toCenter:GetLength());

									lineContainer:SetEndPoints(fromButton, toButton);
									lineContainer:SetScrollAnimationProgressOffset(0);
				
									lineContainer:SetState(state);
									fromButton.links[toPowerID] = lineContainer;
									toButton.links[fromPowerID] = lineContainer;
								end
							end
						end
					end
				end
			end
		end

		-- Artificially link the starting and last power if they're both purchased to complete the circle
		if lastTier2Power and lastTier2Power:IsCompletelyPurchased() and lastTier2Power:HasSpentAny() then
			local startingTier2Power = self:GetStartingPowerButtonByTier(2);
			if startingTier2Power and startingTier2Power:IsCompletelyPurchased() and not startingTier2Power.links[lastTier2Power:GetPowerID()] then
				local lineContainer = self:GenerateCurvedLine(lastTier2Power, startingTier2Power, PowerDependencyLineMixin.LINE_STATE_CONNECTED, artifactArtInfo);

				lastTier2Power.links[startingTier2Power:GetPowerID()] = lineContainer;
				startingTier2Power.links[lastTier2Power:GetPowerID()] = lineContainer;
			end
		end
	end

	self:HideUnusedWidgets(self.DependencyLines, self.numUsedLines, OnUnusedLineHidden);
	self:HideUnusedWidgets(self.CurvedDependencyLines, self.numUsedCurvedLines, OnUnusedLineHidden);
end

local function RelicRefreshHelper(self, relicSlotIndex, powersAffected, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		powersAffected[powerID] = true;
		self:AddRelicToPower(powerID, relicSlotIndex);
	end
end

function ArtifactPerksMixin:RefreshRelics()
	local powersAffected = {};
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		RelicRefreshHelper(self, relicSlotIndex, powersAffected, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
	end

	for powerID, button in pairs(self.powerIDToPowerButton) do
		if not powersAffected[powerID] then
			button:RemoveRelicType();
		end
	end
end

function ArtifactPerksMixin:AddRelicToPower(powerID, relicSlotIndex)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		local relicType = C_ArtifactUI.GetRelicSlotType(relicSlotIndex);
		local relicName, relicIcon, _, relicLink = C_ArtifactUI.GetRelicInfo(relicSlotIndex);
		button:ApplyRelicType(relicType, relicLink, self.newItem);
	end
end

local function RelicHighlightHelper(self, highlightEnabled, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled);
	end
end

local function RelicMouseOverHighlightHelper(self, highlightEnabled, tempRelicType, tempRelicLink, ...)
	for i = 1, select("#", ...) do
		local powerID = select(i, ...);
		self:SetRelicPowerHighlightEnabled(powerID, highlightEnabled, tempRelicType, tempRelicLink);
	end
end

function ArtifactPerksMixin:OnRelicSlotMouseEnter(relicSlotIndex)
	RelicHighlightHelper(self, true, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));
end

function ArtifactPerksMixin:OnRelicSlotMouseLeave(relicSlotIndex)
	RelicHighlightHelper(self, false, C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex));

	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:ClearAllRelicPowerHighlights()
	local powers = C_ArtifactUI.GetPowers();
	RelicHighlightHelper(self, false, unpack(powers));
end

function ArtifactPerksMixin:ShowHighlightForRelicItemID(itemID, itemLink)
	self:ClearAllRelicPowerHighlights();

	local couldFitInAnySlot = false;
	for relicSlotIndex = 1, C_ArtifactUI.GetNumRelicSlots() do
		if C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex) then
			couldFitInAnySlot = true;
			break;
		end
	end

	if couldFitInAnySlot then
		local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfoByItemID(itemID);
		RelicMouseOverHighlightHelper(self, true, relicType, relicLink, C_ArtifactUI.GetPowersAffectedByRelicItemLink(itemLink));
	end
end

function ArtifactPerksMixin:HideHighlightForRelicItemID(itemID, itemLink)
	RelicMouseOverHighlightHelper(self, false, nil, nil, C_ArtifactUI.GetPowersAffectedByRelicItemLink(itemLink));
end

function ArtifactPerksMixin:RefreshCursorHighlights()
	local type, itemID, itemLink = GetCursorInfo();
	if type == "item" and IsArtifactRelicItem(itemID) then
		self:HideHighlightForRelicItemID(itemID, itemLink);
	end
end

function ArtifactPerksMixin:OnCursorUpdate()
	self:RefreshCursorHighlights();
end

function ArtifactPerksMixin:SetRelicPowerHighlightEnabled(powerID, highlight, tempRelicType, tempRelicLink)
	local button = self.powerIDToPowerButton[powerID];
	if button then
		if highlight and tempRelicType and tempRelicLink then
			button:ApplyTemporaryRelicType(tempRelicType, tempRelicLink);
		else
			button:RemoveTemporaryRelicType();
		end
		button:SetRelicHighlightEnabled(highlight);
	end
end

function ArtifactPerksMixin:HideAllLines()
	self:HideUnusedWidgets(self.DependencyLines, 0, OnUnusedLineHidden);
end

local function QueueReveal(self, powerButton, distance, tier)
	-- The very first power for tier 1 doesn't need to animate in since it is already visible.
	local noAnimation = powerButton:GetTier() == 1 and powerButton:IsStart();
	if noAnimation or powerButton:QueueRevealAnimation(distance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE[tier]) then
		for linkedPowerID, linkedLineContainer in pairs(powerButton.links) do
			local linkedPowerButton = self.powerIDToPowerButton[linkedPowerID];
			
			if linkedPowerButton.hasSpentAny then
				QueueReveal(self, linkedPowerButton, distance, tier);
			else 
				local distanceToLink = RegionUtil.CalculateDistanceBetween(powerButton, linkedPowerButton);
				local totalDistance = distance + distanceToLink;

				QueueReveal(self, linkedPowerButton, totalDistance, tier);

				local delay = powerButton:IsStart() and .1 or totalDistance * ARTIFACT_REVEAL_DELAY_SECS_PER_DISTANCE[tier];
				if not linkedLineContainer:IsRevealing() or delay < linkedLineContainer:GetRevealDelay() then
					linkedLineContainer:BeginReveal(delay, distanceToLink * ARTIFACT_REVEAL_LINE_DURATION_SECS_PER_DISTANCE);
				end
			end
		end
	end
end

local function OnRevealFinished(powerButton)
	powerButton.owner:OnRevealAnimationFinished(powerButton);
end

function ArtifactPerksMixin:HideTier2()
	for powerID, button in pairs(self.powerIDToPowerButton) do
		if button:GetTier() == 2 then
			button:Hide();
		end
	end
	
	self.CrestFrame.CrestRune1:Hide();

	if self.CurvedDependencyLines then
		for i = 1, self.numUsedCurvedLines do
			local lineContainer = self.CurvedDependencyLines[i];
			lineContainer.FadeAnim:Stop();
			lineContainer:Hide();
		end
	end

	self.Tier2SlamEffectModelScene:Hide();
end

function ArtifactPerksMixin:ShowTier2()
	for powerID, button in pairs(self.powerIDToPowerButton) do
		if button:GetTier() == 2 and button ~= self:GetFinalPowerButtonByTier(2) then
			button:Show();
		end
	end
	
	if self.CurvedDependencyLines then
		for i = 1, self.numUsedCurvedLines do
			local lineContainer = self.CurvedDependencyLines[i];
			lineContainer:Show();
		end
	end

	self.CrestFrame.CrestRune1:Show();
end

function ArtifactPerksMixin:SkipTier2Animation()
	if self.preppingTierTwoReveal then
		self.preppingTierTwoReveal = nil;
		self.perksDirty = true;
	end

	self:CancelAllTimedAnimations();
	
	if C_ArtifactUI.GetArtifactTier() == 2 then
		self.CrestFrame.CrestRune1:SetAlpha(1.0);
		
		if self.CurvedDependencyLines then
			for i = 1, self.numUsedCurvedLines do
				local lineContainer = self.CurvedDependencyLines[i];
				lineContainer:PlayLineFadeAnim(lineContainer.animType);
			end
		end
		
		self.CrestFrame.RuneAnim:Stop();
		self.CrestFrame.IntroCrestAnim:Stop();
	end
end

function ArtifactPerksMixin:TraitRefundSetup(numTraitsRefunded)
	local amountBeforeRefund = C_ArtifactUI.GetPointsRemaining() - C_ArtifactUI.GetTotalPowerCost(C_ArtifactUI.GetTotalPurchasedRanks() + 1, numTraitsRefunded, 1);
	self.TitleContainer.PointsRemainingLabel:SetAnimatedValue(amountBeforeRefund);
	self.TitleContainer.PointsRemainingLabel:SnapToTarget();
	self:HideTier2();
	if self:GetFinalPowerButtonByTier(1) then self:GetFinalPowerButtonByTier(1).Rank:SetText(1 + numTraitsRefunded); end
	
	local startingSound = SOUNDKIT.UI_72_ARTIFACT_FORGE_FINAL_TRAIT_REFUND_START;
	local loopingSound = SOUNDKIT.UI_72_ARTIFACT_FORGE_FINAL_TRAIT_REFUND_LOOP;

	local endingSound = nil;
	local loopStartDelay = ARTIFACT_TIER_2_SOUND_REFUND_LOOP_START_DELAY;
	local loopEndDelay = ARTIFACT_TIER_2_SOUND_REFUND_LOOP_STOP_DELAY;
	local loopFadeTime = ARTIFACT_TIER_2_SOUND_REFUND_LOOP_FADE_OUT_TIME;
	self.traitRefundSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function ArtifactPerksMixin:OnTraitsRefunded(numArtifactTraitsRefunded, refundedTier)
	self.numArtifactTraitsRefunded = numArtifactTraitsRefunded;
	self.perksDirty = true;
end

function ArtifactPerksMixin:StartWithDelay(delay, callback, iterations)
	if not iterations then iterations = 1; end
	self.callbackTimers[#self.callbackTimers + 1] = C_Timer.NewTicker(delay, callback, iterations);
end

function ArtifactPerksMixin:CancelAllTimedAnimations()
	for i, timer in ipairs(self.callbackTimers) do
		timer:Cancel();
	end
	
	self.callbackTimers = {};
	
	if self.traitRefundSoundEmitter then
		self.traitRefundSoundEmitter:CancelLoopingSound();
	end
end

function ArtifactPerksMixin:AnimateTraitRefund(numTraitsRefunded)
	self:CancelAllTimedAnimations();
	self.CrestFrame.RunePulse:Stop();

	local forgingEffect = self.Tier2ForgingScene:GetActorByTag("effect");
	if ( forgingEffect ) then
		forgingEffect:SetAlpha(0.0);
		self:StartWithDelay(TIER_2_FORGE_EFFECT_FADE_IN_DELAY, function ()
			self.Tier2ForgingScene.ForgingEffectAnimIn:Play();
		end);
	end

	self:StartWithDelay(TIER_2_BACKGROUND_FRONT_INTENSITY_IN_DELAY, function ()
		self.Model.ForgingEffectAnimIn:Play();
	end);

	local button = self:GetFinalPowerButtonByTier(1);
	if not button or numTraitsRefunded == 0 then
		self:PrepTierTwoReveal(ARTIFACT_TIER_2_REVEAL_START_DELAY);
		
		return;
	end

	self:TraitRefundSetup(numTraitsRefunded);
	self:StartWithDelay(ARTIFACT_TIER_2_REVEAL_START_DELAY, function ()
		self.traitRefundSoundEmitter:StartLoopingSound();
		
		-- This is the time it takes to animate the floating numbers.
		self.TitleContainer.PointsRemainingLabel:SetAnimatedDurationTimeSec(0.6 + ARTIFACT_TIER_2_REFUND_NUMBER_TICK_SPEED * numTraitsRefunded);
		self.TitleContainer.PointsRemainingLabel:SetAnimatedValue(C_ArtifactUI.GetPointsRemaining());
		
		local targetX = ArtifactFrame.PerksTab:GetWidth() / 2;
		local targetY = ArtifactFrame.PerksTab.TitleContainer:GetHeight();
		local point, parent, relativePoint, sourceX, sourceY = button:GetPoint();
		sourceY = -sourceY;
		sourceY = sourceY;
		sourceX = sourceX + (button:GetWidth() / 2);
		
		local currentRank = numTraitsRefunded + 1;
		self:StartWithDelay(ARTIFACT_TIER_2_REFUND_NUMBER_TICK_SPEED, function ()
			if ( currentRank <= 1 ) then return; end
			local numberIndex = 2 + (numTraitsRefunded - currentRank);
			if not button.FloatingNumbers or not button.FloatingNumbers[numberIndex] then
				CreateFrame("Frame", nil, button, "ArtifactFloatingRankStringTemplate");
			end
			
			local animatedNumber = button.FloatingNumbers[numberIndex];
			animatedNumber:SetPoint(point, parent, relativePoint, sourceX, -sourceY);
			animatedNumber.Rune:SetAtlas(button:GenerateRune(), true);
			animatedNumber.MoveAndFade.Move:SetOffset(targetX - sourceX, sourceY - targetY);
			animatedNumber.MoveAndFade.Rotation:SetDegrees(math.random(-180, 180));
			animatedNumber.MoveAndFade.RuneMove:SetOffset(targetX - sourceX, sourceY - targetY);
			animatedNumber.MoveAndFade.RuneRotation:SetDegrees(math.random(-180, 180));
			animatedNumber.MoveAndFade:Play();
			animatedNumber:Show();
			currentRank = currentRank - 1;
			button.Rank:SetText(currentRank);
			if ( currentRank <= 1 ) then
				self:StartWithDelay(ARTIFACT_TIER_2_SOUND_REFUND_END_DELAY, function ()
					self.traitRefundSoundEmitter:FinishLoopingSound();
				end);

				self:PrepTierTwoReveal(ARTIFACT_TIER_2_RUNE_FLASH_DELAY);
			end
		end, numTraitsRefunded);
	end);
end

function ArtifactPerksMixin:PrepTierTwoReveal(delay)
	self:HideTier2();
	self.preppingTierTwoReveal = true;
	self:StartWithDelay(delay, function ()
		self:AnimateInTierTwoReveal();
	end);
end

function ArtifactPerksMixin:AnimateInTierTwoReveal()
	self.TitleContainer.PointsRemainingLabel:SnapToTarget();
	PlaySound(SOUNDKIT.UI_72_ARTIFACT_FORGE_ACTIVATE_FINAL_TIER);

	self.CrestFrame.IntroCrestAnim:Play();
	self:StartWithDelay(ARTIFACT_TIER_2_CONSTELLATION_DELAY, function ()
		self:AnimateInTierTwoPowers();
	end);
end

function ArtifactPerksMixin:AnimateInTierTwoPowers()
	-- Show all the tier 2 components and set up their alpha to be animated in.
	self.preppingTierTwoReveal = nil;
	self:ShowTier2();
	self.CrestFrame.CrestRune1:SetAlpha(0.0);
	
	for i = 1, self.numUsedCurvedLines do
		local lineContainer = self.CurvedDependencyLines[i];
		lineContainer.Fill:SetVertexColor(lineContainer.connectedColor:GetRGB());
		lineContainer:SetAlpha(0.0);
	end
	
	self:PlayReveal(2);
	
	self:StartWithDelay(ARTIFACT_TIER_2_FIRST_CURVED_LINE_DELAY, function ()
		self:AnimateInCurvedLine(3);
	end);
	
	self:StartWithDelay(ARTIFACT_TIER_2_SECOND_CURVED_LINE_DELAY, function ()
		self:AnimateInCurvedLine(1);
	end);
	
	self:StartWithDelay(ARTIFACT_TIER_2_THIRD_CURVED_LINE_DELAY, function ()
		self:AnimateInCurvedLine(2);
	end);
	
	self:StartWithDelay(ARTIFACT_TIER_2_CREST_DELAY, function ()
		self:AnimateInCrest();
	end);
end

local MAX_CURVED_LINE_FADE_DELAY = ARTIFACT_TIER_2_CURVED_LINE_TICK_SPEED * (NUM_CURVED_LINE_SEGEMENTS / 2 - 0.5);
function ArtifactPerksMixin:AnimateInCurvedLine(curvedLineIndex)
	if curvedLineIndex * NUM_CURVED_LINE_SEGEMENTS > self.numUsedCurvedLines then
		return;
	end
	
	local baseIndex = (curvedLineIndex - 1) * NUM_CURVED_LINE_SEGEMENTS;
	for i = 1, NUM_CURVED_LINE_SEGEMENTS do
		local lineContainer = self.CurvedDependencyLines[baseIndex + i];
		lineContainer:SetAlpha(0.0);

		local delay = ARTIFACT_TIER_2_CURVED_LINE_TICK_SPEED * math.abs(NUM_CURVED_LINE_SEGEMENTS / 2 - (i - 0.5));
		lineContainer.Tier2FadeInAnim.Background:SetStartDelay(delay);
		lineContainer.Tier2FadeInAnim.Background:SetEndDelay(MAX_CURVED_LINE_FADE_DELAY - delay);
		lineContainer.Tier2FadeInAnim.Fill:SetStartDelay(delay);
		lineContainer.Tier2FadeInAnim.Fill:SetEndDelay(MAX_CURVED_LINE_FADE_DELAY - delay);
		lineContainer.Tier2FadeInAnim:Play();
	end
end

function ArtifactPerksMixin:PlayReveal(tier)
	if self:GetStartingPowerButtonByTier(tier) and not self.numRevealsPlaying then
		self.numRevealsPlaying = 0;

		QueueReveal(self, self:GetStartingPowerButtonByTier(tier), 0, tier);

		for powerID, powerButton in pairs(self.powerIDToPowerButton) do
			if powerButton:GetTier() == tier and powerButton:IsShown() and powerButton:PlayRevealAnimation(OnRevealFinished) then
				self.numRevealsPlaying = self.numRevealsPlaying + 1;
			end
		end

		if tier == 1 then
			PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_FIRST_TRAIT);
		end
	end
end

function ArtifactPerksMixin:AnimateInCrest()
	local forgingEffect = self.Tier2ForgingScene:GetActorByTag("effect");
	if ( forgingEffect ) then
		self:StartWithDelay(TIER_2_FORGE_EFFECT_FADE_OUT_DELAY, function ()
			self.Tier2ForgingScene.ForgingEffectAnimOut:Play();
		end);
	end
	
	self:StartWithDelay(TIER_2_BACKGROUND_FRONT_INTENSITY_OUT_DELAY, function ()
		self.Model.ForgingEffectAnimOut:Play();
	end);

	self.CrestFrame.RuneAnim:Play();
	self:StartWithDelay(ARTIFACT_TIER_2_SHAKE_DELAY, function ()
		ScriptAnimationUtil.ShakeFrame(self:GetParent(), ARTIFACT_TIER_2_SHAKE, ARTIFACT_TIER_2_SHAKE_DURATION, ARTIFACT_TIER_2_SHAKE_FREQUENCY);
	end);
	
	self:StartWithDelay(TIER_2_SLAM_EFFECT_DELAY, function ()
		self.Tier2SlamEffectModelScene:Show();
		self.CrestFrame.CracksAnim:Play();
		self:StartWithDelay(TIER_2_SLAM_EFFECT_HIDE_DELAY, function ()
			self.Tier2SlamEffectModelScene:Hide();
		end);
	end);
end

function ArtifactPerksMixin:OnRevealAnimationFinished(powerButton)
	if self.numRevealsPlaying then
		self.numRevealsPlaying = self.numRevealsPlaying - 1;
		if self.numRevealsPlaying == 0 then
			self.numRevealsPlaying = nil;
			for powerID, powerButton in pairs(self.powerIDToPowerButton) do
				powerButton:SetLocked(false);
			end
		end
	end
end

------------------------------------------------------------------
--   ArtifactTitleTemplate
------------------------------------------------------------------


ArtifactTitleTemplateMixin = {}

function ArtifactTitleTemplateMixin:RefreshTitle()
	self.PointsRemainingLabel:SnapToTarget();
	local disabledFrame = self:GetParent().DisabledFrame;

	local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
	if C_ArtifactUI.IsArtifactDisabled() then
		disabledFrame:Show();
		disabledFrame.ArtifactName:SetText(artifactArtInfo.titleName);
		disabledFrame.ArtifactName:SetVertexColor(0.588, 0.557, 0.463);

		if artifactArtInfo.textureKit then
			local headerAtlas = ("%s-Header"):format(artifactArtInfo.textureKit);
			disabledFrame.Background:SetAtlas(headerAtlas, true);
			disabledFrame.Background:SetDesaturated(true);
			disabledFrame.Background:Show();
		else
			disabledFrame.Background:Hide();
		end

		self.ArtifactName:Hide();
		self.ArtifactPower:Hide();
		self.Background:Hide();
	else
		self.ArtifactName:Show();
		self.ArtifactName:SetText(artifactArtInfo.titleName);
		self.ArtifactName:SetVertexColor(artifactArtInfo.titleColor:GetRGB());
		self.ArtifactPower:Show();

		if artifactArtInfo.textureKit then
			local headerAtlas = ("%s-Header"):format(artifactArtInfo.textureKit);
			self.Background:SetAtlas(headerAtlas, true);
			self.Background:Show();
		else
			self.Background:Hide();
		end
		
		disabledFrame:Hide();
	end
end

function ArtifactTitleTemplateMixin:OnShow()
	self:RefreshTitle();
	self:EvaluateRelics();

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("CURSOR_UPDATE");
	
	if C_ArtifactUI.IsArtifactDisabled() then
		self:SetScript("OnUpdate", nil);
		self.PointsRemainingLabel:Hide();
	else
		self:SetScript("OnUpdate", self.OnUpdate);
		self.PointsRemainingLabel:Show();
	end
end

function ArtifactTitleTemplateMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_UPDATE");
	self:UnregisterEvent("CURSOR_UPDATE");
	StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
end

function ArtifactTitleTemplateMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		local newItem = ...;
		if newItem then
			self:RefreshTitle();
		end
		self:EvaluateRelics();
		self:RefreshRelicTooltips();
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorUpdate();
	end
end

function ArtifactTitleTemplateMixin:OnCursorUpdate()
	if not CursorHasItem() then
		StaticPopup_Hide("CONFIRM_RELIC_REPLACE");
	end

	self:RefreshCursorRelicHighlights();
end

function ArtifactTitleTemplateMixin:RefreshCursorRelicHighlights()
	local type, itemID, itemLink = GetCursorInfo();
	self:RefreshRelicHighlights(itemID, itemLink);
end

function ArtifactTitleTemplateMixin:RefreshRelicHighlights(itemID, itemLink)
	for relicSlotIndex in ipairs(self.RelicSlots) do
		self:SetRelicSlotHighlighted(relicSlotIndex, itemID and C_ArtifactUI.CanApplyRelicItemIDToSlot(itemID, relicSlotIndex));
	end
end

function ArtifactTitleTemplateMixin:SetRelicSlotHighlighted(relicSlotIndex, highlighted)
	local relicSlot = self.RelicSlots[relicSlotIndex];
	if relicSlot:IsShown() then
		if highlighted then
			relicSlot:LockHighlight();
			relicSlot.CanSlotAnim:Play();
			relicSlot.HighlightTexture:Show();
		else
			relicSlot:UnlockHighlight();
			relicSlot.CanSlotAnim:Stop();
			relicSlot.HighlightTexture:Hide();
		end
	end
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseEnter(relicSlot)
	if relicSlot.lockedReason then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(LOCKED_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			if relicSlot.lockedReason == "" then
				GameTooltip:AddLine(LOCKED_RELIC_TOOLTIP_BODY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			else
				GameTooltip:AddLine(relicSlot.lockedReason, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
		end
	elseif relicSlot.relicLink then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		GameTooltip:SetSocketedRelic(relicSlot.relicSlotIndex);
		GameTooltip:Show();
	elseif relicSlot.relicType then
		GameTooltip:SetOwner(relicSlot, "ANCHOR_BOTTOMRIGHT", 0, 10);
		local slotName = _G["RELIC_SLOT_TYPE_" .. relicSlot.relicType:upper()];
		if slotName then
			GameTooltip:SetText(EMPTY_RELIC_TOOLTIP_TITLE:format(slotName), 1, 1, 1);
			GameTooltip:AddLine(EMPTY_RELIC_TOOLTIP_BODY:format(slotName), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			GameTooltip:Show();
		end
	end
	self:GetParent():OnRelicSlotMouseEnter(relicSlot.relicSlotIndex);
end

function ArtifactTitleTemplateMixin:OnRelicSlotMouseLeave(relicSlot)
	GameTooltip_Hide();
	self:GetParent():OnRelicSlotMouseLeave(relicSlot.relicSlotIndex);
end

StaticPopupDialogs["CONFIRM_RELIC_REPLACE"] = {
	text = CONFIRM_ACCEPT_RELIC,
	button1 = ACCEPT,
	button2 = CANCEL,

	OnAccept = function(self, data)
		data.titleContainer:ApplyCursorRelicToSlot(data.relicSlotIndex);
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,

	showAlert = true,
	timeout = 0,
	exclusive = true,
	hideOnEscape = true,
};

function ArtifactTitleTemplateMixin:ApplyCursorRelicToSlot(relicSlotIndex)
	C_ArtifactUI.ApplyCursorRelicToSlot(relicSlotIndex);
	self.RelicSlots[relicSlotIndex].GlowAnim:Play();
	PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_RELIC_PLACE);
end

function ArtifactTitleTemplateMixin:OnRelicSlotClicked(relicSlot)
	for i = 1, #self.RelicSlots do
		if self.RelicSlots[i] == relicSlot then
			if C_ArtifactUI.CanApplyCursorRelicToSlot(i) then
				local itemName = C_ArtifactUI.GetRelicInfo(i);
				if itemName then
					StaticPopup_Show("CONFIRM_RELIC_REPLACE", nil, nil, { titleContainer = self, relicSlotIndex = i });
				else
					self:ApplyCursorRelicToSlot(i);
				end
				return true;
			else
				local _, itemID = GetCursorInfo();
				if itemID and IsArtifactRelicItem(itemID) then
					UIErrorsFrame:AddMessage(RELIC_SLOT_INVALID, 1.0, 0.1, 0.1, 1.0);
					return true;
				else
					if IsModifiedClick() then
						local _, _, _, itemLink = C_ArtifactUI.GetRelicInfo(i);
						return HandleModifiedItemClick(itemLink);
					end
				end
			end
			break;
		end
	end
	return false;
end

function ArtifactTitleTemplateMixin:RefreshRelicTooltips()
	for i = 1, #self.RelicSlots do
		if GameTooltip:IsOwned(self.RelicSlots[i]) then
			self.RelicSlots[i]:GetScript("OnEnter")(self.RelicSlots[i]);
			break;
		end
	end
end

function ArtifactTitleTemplateMixin:EvaluateRelics()
	local numRelicSlots = ArtifactUI_CanViewArtifact() and C_ArtifactUI.GetNumRelicSlots() or 0;

	self:SetExpandedState(numRelicSlots > 0);

	for i = 1, numRelicSlots do
		local relicSlot = self.RelicSlots[i];

		local relicType = C_ArtifactUI.GetRelicSlotType(i);

		local relicAtlasName = ("Relic-%s-Slot"):format(relicType);
		relicSlot:GetNormalTexture():SetAtlas(relicAtlasName, true);
		relicSlot:GetHighlightTexture():SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder1:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder2:SetAtlas(relicAtlasName, true);
		relicSlot.GlowBorder3:SetAtlas(relicAtlasName, true);
		local lockedReason = C_ArtifactUI.GetRelicLockedReason(i);
		if lockedReason then
			relicSlot:GetNormalTexture():SetAlpha(.5);
			relicSlot:Disable();
			relicSlot.LockedIcon:Show();
			relicSlot.Icon:SetMask(nil);
			relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
			relicSlot.Glass:Hide();
			relicSlot.relicLink = nil;
		else
			local relicName, relicIcon, relicType, relicLink = C_ArtifactUI.GetRelicInfo(i);

			relicSlot:GetNormalTexture():SetAlpha(1);
			relicSlot:Enable();
			relicSlot.LockedIcon:Hide();
			if relicIcon then
				relicSlot.Icon:SetSize(34, 34);
				relicSlot.Icon:SetMask(nil);
				relicSlot.Icon:SetTexCoord(0, 1, 0, 1); -- Masks may overwrite our tex coords (even ones set by an atlas), force it back to using the full item icon texture
				relicSlot.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				relicSlot.Icon:SetTexture(relicIcon);
				relicSlot.Glass:Show();
			else
				relicSlot.Icon:SetMask(nil);
				relicSlot.Icon:SetAtlas("Relic-SlotBG", true);
				relicSlot.Glass:Hide();
			end
			relicSlot.relicLink = relicLink;
		end

		
		relicSlot.relicType = relicType;
		relicSlot.relicSlotIndex = i;
		relicSlot.lockedReason = lockedReason;
		
		relicSlot:ClearAllPoints();
		local PADDING = 0;
		if i == 1 then
			local offsetX = -(numRelicSlots - 1) * (relicSlot:GetWidth() + PADDING) * .5;
			relicSlot:SetPoint("CENTER", self, "CENTER", offsetX, -6);
		else
			relicSlot:SetPoint("LEFT", self.RelicSlots[i - 1], "RIGHT", PADDING, 0);
		end

		relicSlot:Show();
	end

	for i = numRelicSlots + 1, #self.RelicSlots do
		self.RelicSlots[i]:Hide();
	end
end

function ArtifactTitleTemplateMixin:SetPointsRemaining(value)
	if not C_ArtifactUI.IsArtifactDisabled() then
		self.PointsRemainingLabel:SetAnimatedValue(value);
	end
end

function ArtifactTitleTemplateMixin:OnUpdate(elapsed)
	self.PointsRemainingLabel:UpdateAnimatedValue(elapsed);
end

function ArtifactTitleTemplateMixin:SetExpandedState(expanded)
	if self.expanded ~= expanded then
		self.expanded = expanded;

		self:SetHeight(self.expanded and 140 or 90);
	end
end