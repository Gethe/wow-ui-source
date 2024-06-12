local craftCompleteSoundKits = {
	SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_QUALITY1,
	SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_QUALITY2,
	SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_QUALITY3,
	SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_QUALITY4,
	SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_QUALITY5,
};

local nextQualitySoundKits = {
	SOUNDKIT.UI_PROFESSION_CRAFTING_EXPECTED_QUALITY1,
	SOUNDKIT.UI_PROFESSION_CRAFTING_EXPECTED_QUALITY2,
	SOUNDKIT.UI_PROFESSION_CRAFTING_EXPECTED_QUALITY3,
	SOUNDKIT.UI_PROFESSION_CRAFTING_EXPECTED_QUALITY4,
	SOUNDKIT.UI_PROFESSION_CRAFTING_EXPECTED_QUALITY5,
};

local DetailsFrameEvents =
{
	"TRADE_SKILL_ITEM_CRAFTED_RESULT",
	"TRADE_SKILL_CRAFT_BEGIN",
};

CraftingQualityStatLine = EnumUtil.MakeEnum("Difficulty", "Skill", "Concentration");

local detailsPanelTitles =
{
	[Professions.ProfessionType.Crafting] = PROFESSIONS_CRAFTING_DETAILS_HEADER,
	[Professions.ProfessionType.Gathering] = PROFESSIONS_GATHERING_DETAILS_HEADER,
};

local statLineLabels =
{
	[Professions.ProfessionType.Crafting] =
	{
		[CraftingQualityStatLine.Difficulty] = PROFESSIONS_CRAFTING_STAT_DIFFICULTY,
		[CraftingQualityStatLine.Skill] = PROFESSIONS_CRAFTING_STAT_SKILL,
		[CraftingQualityStatLine.Concentration] = PROFESSIONS_CRAFTING_STAT_CONCENTRATION,
	},
	[Professions.ProfessionType.Gathering] =
	{
		[CraftingQualityStatLine.Difficulty] = PROFESSIONS_GATHERING_STAT_DIFFICULTY,
		[CraftingQualityStatLine.Skill] = PROFESSIONS_GATHERING_STAT_SKILL,
		[CraftingQualityStatLine.Concentration] = PROFESSIONS_CRAFTING_STAT_CONCENTRATION,
	},
};

local statLineDescriptions =
{
	[Professions.ProfessionType.Crafting] =
	{
		[CraftingQualityStatLine.Difficulty] = PROFESSIONS_CRAFTING_STAT_DIFFICULTY_DESCRIPTION,
		[CraftingQualityStatLine.Skill] = PROFESSIONS_CRAFTING_STAT_SKILL_DESCRIPTION,
		[CraftingQualityStatLine.Concentration] = PROFESSIONS_CRAFTING_STAT_CONCENTRATION_DESCRIPTION,
	},
	[Professions.ProfessionType.Gathering] =
	{
		[CraftingQualityStatLine.Difficulty] = PROFESSIONS_GATHERING_STAT_DIFFICULTY_DESCRIPTION,
		[CraftingQualityStatLine.Skill] = PROFESSIONS_GATHERING_STAT_SKILL_DESCRIPTION,
		[CraftingQualityStatLine.Concentration] = PROFESSIONS_CRAFTING_STAT_CONCENTRATION_DESCRIPTION,
	},
};

ProfessionsCrafterDetailsStatLineMixin = {};

function ProfessionsCrafterDetailsStatLineMixin:SetProfessionType(professionType)
	self.professionType = professionType;
	if professionType and self.statLineType ~= nil then
		self:SetLabel(statLineLabels[self.professionType][self.statLineType]);
	end
end

function ProfessionsCrafterDetailsStatLineMixin:OnEnter()
	-- Overriden for bonus stat lines
	if self.statLineType ~= nil and self.professionType ~= nil and self.baseValue ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:ClearLines();
		local statString;
		if self.bonusValue then
			statString = PROFESSIONS_CRAFTING_STAT_QUANTITY_TT_FMT:format(self.baseValue + self.bonusValue, self.baseValue, self.bonusValue);
		else
			statString = PROFESSIONS_CRAFTING_STAT_NO_BONUS_TT_FMT:format(self.baseValue);
		end

		local label = statLineLabels[self.professionType][self.statLineType];
		GameTooltip_AddColoredDoubleLine(GameTooltip, label, statString, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddNormalLine(GameTooltip, statLineDescriptions[self.professionType][self.statLineType]);
		GameTooltip:Show();
	end
end

function ProfessionsCrafterDetailsStatLineMixin:OnLeave()
	GameTooltip_Hide();
end

function ProfessionsCrafterDetailsStatLineMixin:InitBonusStat(label, desc, value, pctValue, bonusPctValue)
	self:SetLabel(label);

	local displayValue = self.displayAsPct and pctValue or value;
	self:SetValue(displayValue);

	self:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local statString = self:GetStatFormat():format(math.ceil(displayValue));
		GameTooltip_AddColoredDoubleLine(GameTooltip, label, statString, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR);

		GameTooltip_AddNormalLine(GameTooltip, desc);
		if value > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_STAT_TT_FMT:format(label, value, bonusPctValue));
		end
		GameTooltip:Show();
	end);
end

function ProfessionsCrafterDetailsStatLineMixin:SetLabel(label)
	self.LeftLabel:SetText(label);
end

function ProfessionsCrafterDetailsStatLineMixin:GetStatFormat()
	return self.displayAsPct and "%d%%" or "%d";
end

function ProfessionsCrafterDetailsStatLineMixin:SetValue(baseValue, bonusValue)
	self.baseValue = baseValue;
	self.bonusValue = bonusValue;

	self.RightLabel:SetText(self:GetStatFormat():format(math.ceil(baseValue + (bonusValue or 0))));
end

function ProfessionsCrafterDetailsStatLineMixin:SetLabelColor(color)
	self.LeftLabel:SetTextColor(color:GetRGB());
	self.RightLabel:SetTextColor(color:GetRGB());
end

ProfessionsRecipeCrafterDetailsMixin = {};

function ProfessionsRecipeCrafterDetailsMixin:OnLoad()
	self.statLinePool = CreateFramePool("FRAME", self.StatLines, "ProfessionsCrafterDetailsStatLineTemplate");

	self.CraftingChoicesContainer.FinishingReagentSlotContainer.Label:SetText(PROFESSIONS_CRAFTING_FINISHING_HEADER);

	self.QualityMeter.Center:SetScript("OnEnter", function(fill)
		if not self.operationInfo then
			return;
		end

		GameTooltip:SetOwner(fill, "ANCHOR_RIGHT");

		local atlasSize = 25;
		local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(self.QualityMeter.craftingQuality), atlasSize, atlasSize);
		local applyConcentration = self.transaction:IsApplyingConcentration();
		local hasNextQuality = self.operationInfo.upperSkillTreshold > self.operationInfo.lowerSkillThreshold;
		if hasNextQuality then
			atlasSize = 20;
			local nextAtlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(self.QualityMeter.craftingQuality + 1), atlasSize, atlasSize);
			if applyConcentration then
				GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_EXPECTED_QUALITY_WITH_CONCENTRATION:format(nextAtlasMarkup, nextAtlasMarkup));
			else
				GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_EXPECTED_QUALITY_WITH_NEXT_SKILL:format(atlasMarkup, self.operationInfo.upperSkillTreshold, nextAtlasMarkup));
			end
		else
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_EXPECTED_QUALITY:format(atlasMarkup));
		end
		GameTooltip:Show();
	end);

	self.QualityMeter.Center:SetScript("OnLeave", GameTooltip_Hide);

	local function OnCapEntered(cap, isRight)
		if not self:HasData() then
			return;
		end

		local qualityIndex = self.QualityMeter.craftingQuality + (isRight and 1 or 0);

		GameTooltip:SetOwner(cap, "ANCHOR_RIGHT");
		-- Enchanting recipe
		if self.recipeInfo.isEnchantingRecipe then
			local recipeLevel = nil;
			GameTooltip:SetRecipeResultItem(self.recipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl(), self.transaction:GetAllocationItemGUID(), recipeLevel, self.recipeInfo.qualityIDs[qualityIndex]);
		-- Generic tooltip (no specific item output)
		elseif not self.recipeInfo.hasSingleItemOutput then
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_CRAFTING_GENERIC_QUALITY_DESCRIPTION);
		-- Item ID per quality
		elseif self.recipeInfo.qualityItemIDs ~= nil then
			GameTooltip:SetItemByID(self.recipeInfo.qualityItemIDs[qualityIndex], self.recipeInfo.qualityIDs[qualityIndex]);
		-- Item modified by quality
		elseif self.recipeInfo.qualityIlvlBonuses ~= nil then
			GameTooltip_SetTitle(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUSES:format(self.itemName));
			for index, ilvlBonus in ipairs(self.recipeInfo.qualityIlvlBonuses) do
				local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(self.recipeInfo.recipeID, self.transaction:CreateOptionalCraftingReagentInfoTbl(), self.transaction:GetAllocationItemGUID(), self.recipeInfo.qualityIDs[index]);
				local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
				if item:IsItemDataCached() then
					local atlasSize = 25;
					local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(index), atlasSize, atlasSize);
					GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUS_INCR:format(atlasMarkup, item:GetCurrentItemLevel(), ilvlBonus));
				else
					local continuableContainer = ContinuableContainer:Create();
					continuableContainer:AddContinuable(item);
					continuableContainer:ContinueOnLoad(function()
						OnCapEntered(cap, isRight);
					end);
				end
			end
		end
		GameTooltip:Show();
	end

	self.QualityMeter.Left:SetScript("OnEnter", function(cap) OnCapEntered(cap, false); end);
	self.QualityMeter.Right:SetScript("OnEnter", function(cap) OnCapEntered(cap, true); end);

	self.QualityMeter.Left:SetScript("OnLeave", GameTooltip_Hide);
	self.QualityMeter.Right:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsRecipeCrafterDetailsMixin:SetMaximized()
	if self.ApplyLayout then
		self.ApplyLayout();
	end
end

function ProfessionsRecipeCrafterDetailsMixin:SetMinimized()
	if self.ApplyLayout then
		self.ApplyLayout();
	end
end

function ProfessionsRecipeCrafterDetailsMixin:SetQualityMeterAnimSpeedMultiplier(animSpeedMultiplier)
	self.animSpeedMultiplier = animSpeedMultiplier;
end

function ProfessionsRecipeCrafterDetailsMixin:CancelAllAnims()
	if self.animating then
		self.QualityMeter:CancelAllAnims(self.operationInfo);
		self.QualityMeter:SetQuality(self.operationInfo.quality, self.recipeInfo.maxQuality);
	end
end

function ProfessionsRecipeCrafterDetailsMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		if not self.operationInfo then
			return;
		end

		local resultData = ...;

		if resultData.craftingQuality and self.recipeInfo.recipeID == self.expectedRecipeID then
			self.QualityMeter:PlayResultAnimation(resultData, self.operationInfo, self.animSpeedMultiplier or 1);
		end
	elseif event == "TRADE_SKILL_CRAFT_BEGIN" then
		if not self.recipeInfo then
			return;
		end

		self.expectedRecipeID = self.recipeInfo.recipeID;
	end
end

function ProfessionsRecipeCrafterDetailsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DetailsFrameEvents);
end

function ProfessionsRecipeCrafterDetailsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DetailsFrameEvents);

	if not self:IsShown() then
		-- Details may have been set shown again while the OnHide script was deferred
		self:ClearData();
	end
end

function ProfessionsRecipeCrafterDetailsMixin:ClearData()
	self.transaction = nil;
	self.recipeInfo = nil;
	self.operationInfo = nil;
	self.craftingQuality = nil;
end

function ProfessionsRecipeCrafterDetailsMixin:SetData(transaction, recipeInfo, hasFinishingSlots, hasConcentration)
	self.transaction = transaction;
	self.recipeInfo = recipeInfo;
	self.operationInfo = nil;
	self.craftingQuality = nil;

	self:SetOutputItemName(recipeInfo.name);
	self.CraftingChoicesContainer:SetShown(hasFinishingSlots or hasConcentration);
	self.CraftingChoicesContainer.FinishingReagentSlotContainer:SetShown(hasFinishingSlots);
	self.CraftingChoicesContainer.ConcentrateContainer:SetShown(hasConcentration and recipeInfo.supportsQualities);
	self.CraftingChoicesContainer.ConcentrateContainer.ConcentrateToggleButton:SetTransaction(transaction);
	self.CraftingChoicesContainer.shouldShow = hasFinishingSlots or hasConcentration;
end

function ProfessionsRecipeCrafterDetailsMixin:HasData()
	return self.recipeInfo and self.transaction;
end

function ProfessionsRecipeCrafterDetailsMixin:SetStats(operationInfo, supportsQualities, isGatheringRecipe)
	if self.recipeInfo == nil or operationInfo == nil then
		return;
	end

	local nextCraftingQuality = operationInfo.craftingQuality;
	if self.craftingQuality ~= nil then
		if nextCraftingQuality > self.craftingQuality then
			local soundKit = nextQualitySoundKits[nextCraftingQuality];
			if soundKit then
				PlaySound(soundKit);
			end
		elseif nextCraftingQuality < self.craftingQuality then
			PlaySound(SOUNDKIT.UI_PROFESSION_CRAFTING_PREVIOUS_QUALITY);
		end
	end
	self.craftingQuality = nextCraftingQuality;
	self.operationInfo = operationInfo;

	self.ApplyLayout = function()
		if self.recipeInfo == nil then
			return;
		end

		self.statLinePool:ReleaseAll();
		
		if ProfessionsUtil.IsCraftingMinimized() then
			self.BackgroundTop:Hide();
			self.BackgroundBottom:Hide();
			self.BackgroundMiddle:Hide();
			self.BackgroundMinimized:Show();

			self.Label:Hide();
			self.Line:Hide();
			self.StatLines.DifficultyStatLine:Hide();
			self.StatLines.SkillStatLine:Hide();
			self.StatLines.ConcentrationStatLine:Hide();
			self.CraftingChoicesContainer:Hide();

			self.QualityMeter.layoutIndex = 1;
			self.QualityMeter.topPadding = 17;
			self.minimumHeight = 125;
			self.maximumHeight = 125;
		else
			self.BackgroundTop:Show();
			self.BackgroundBottom:Show();
			self.BackgroundMiddle:Show();
			self.BackgroundMinimized:Hide();

			local professionType = isGatheringRecipe and Professions.ProfessionType.Gathering or Professions.ProfessionType.Crafting;
			self.Label:SetText(detailsPanelTitles[professionType]);
			self.Label:Show();
			self.Line:Show();

			if self.CraftingChoicesContainer.shouldShow then
				self.CraftingChoicesContainer:Show();
			end

			local hasConcentration = operationInfo.concentrationCurrencyID and operationInfo.concentrationCurrencyID ~= 0;
			self.CraftingChoicesContainer.ConcentrateContainer.ConcentrateToggleButton:SetOperationInfo(operationInfo);
			self.CraftingChoicesContainer.ConcentrateContainer.ConcentrateToggleButton:SetRecipeInfo(self.recipeInfo);

			self.StatLines.DifficultyStatLine:SetShown(supportsQualities or isGatheringRecipe);
			self.StatLines.DifficultyStatLine:SetProfessionType(professionType);
			self.StatLines.SkillStatLine:SetShown(supportsQualities or isGatheringRecipe);
			self.StatLines.SkillStatLine:SetProfessionType(professionType);
			if supportsQualities or isGatheringRecipe then
				self.StatLines.DifficultyStatLine:SetValue(isGatheringRecipe and operationInfo.maxDifficulty or operationInfo.baseDifficulty, operationInfo.bonusDifficulty);
				self.StatLines.SkillStatLine:SetValue(operationInfo.baseSkill, operationInfo.bonusSkill);
			end
			self.StatLines.ConcentrationStatLine:SetShown(hasConcentration and supportsQualities);
			self.StatLines.ConcentrationStatLine:SetProfessionType(professionType);

			local applyConcentration = hasConcentration and self.transaction:IsApplyingConcentration();
			if hasConcentration then
				self.StatLines.ConcentrationStatLine:SetValue(operationInfo.concentrationCost);
				self.StatLines.ConcentrationStatLine:SetLabelColor(applyConcentration and YELLOW_FONT_COLOR or DISABLED_FONT_COLOR);
			end
			
			local nextStatLineIndex = 4;
			for _, bonusStat in ipairs(operationInfo.bonusStats) do
				local statLine = self.statLinePool:Acquire();
				statLine:InitBonusStat(bonusStat.bonusStatName, bonusStat.ratingDescription, bonusStat.bonusStatValue, bonusStat.ratingPct, bonusStat.bonusRatingPct);
				statLine.layoutIndex = nextStatLineIndex;
				statLine:Show();

				if bonusStat.bonusStatValue == Enum.BonusStatIndex.ProfessionIngenuity then
					statLine:SetLabelColor(applyConcentration and YELLOW_FONT_COLOR or DISABLED_FONT_COLOR);
				end

				nextStatLineIndex = nextStatLineIndex + 1;
			end

			self.QualityMeter.layoutIndex = 4;
			self.QualityMeter.topPadding = -4;
			self.minimumHeight = 199;
			self.maximumHeight = nil;
		end

		self.StatLines:Layout();

		self.QualityMeter:SetShown(supportsQualities);
		self.Spacer:SetShown(not supportsQualities);
		if supportsQualities then
			self.QualityMeter:SetQuality(operationInfo.quality, self.recipeInfo.maxQuality);
		end

		self:Layout();
	end;

	self.ApplyLayout();
end

function ProfessionsRecipeCrafterDetailsMixin:SetOutputItemName(itemName)
	self.itemName = itemName;
end

function ProfessionsRecipeCrafterDetailsMixin:Reset()
	self.QualityMeter:Reset();
end

function ProfessionsRecipeCrafterDetailsMixin:GetProjectedQuality()
	local quality = self.craftingQuality;

	-- When applying concentration project that the craft is guaranteed to reach the next quality.
	if self.transaction and self.operationInfo then
		local applyConcentration = self.transaction:IsApplyingConcentration();
		if applyConcentration then
			quality = math.ceil(self.operationInfo.quality);
		end
	end

	return quality;
end

ProfessionsQualityMeterMixin = {};

function ProfessionsQualityMeterMixin:OnLoad()
	self:Reset();

	self.interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);

	self.InteriorMask:SetSize((372/2), (52/2));
	self.Center.Fill.BarMask:SetHeight(27);
	self.Center.Fill.BarHighlightMask:SetHeight(27);

	self.anims = {};
	table.insert(self.anims, self.Left.AppearIcon.Anim);
	table.insert(self.anims, self.Left.AppearIcon.ScaleUp);
	table.insert(self.anims, self.Left.DissolveIcon.Anim);
	table.insert(self.anims, self.Right.AppearIcon.Anim);
	table.insert(self.anims, self.Right.AppearIcon.ScaleUp);
	table.insert(self.anims, self.Right.AppearIcon.ScaleUpQuick);
	table.insert(self.anims, self.Right.DissolveIcon.Anim);
	table.insert(self.anims, self.Marker.TransitionIn);
	table.insert(self.anims, self.Marker.TransitionOut);
	table.insert(self.anims, self.Marker.TransitionOutLate);
	table.insert(self.anims, self.DividerGlow.TransitionIn);
	table.insert(self.anims, self.DividerGlow.TransitionOut);
	table.insert(self.anims, self.Flare.FlareTransitionIn);
	table.insert(self.anims, self.Flare.FxTransitionOut);
	table.insert(self.anims, self.Center.Fill.TransitionOutLate);
	table.insert(self.anims, self.Center.Fill.TransitionOut);
end

function ProfessionsQualityMeterMixin:CancelAllAnims(operationInfo)
	if self.anims then
		for index, anim in ipairs(self.anims) do
			anim:Stop();
		end
	end

	if self.sequencer then
		self.sequencer:Cancel();
	end

	if operationInfo then
		self:SetBarAtlas(operationInfo.craftingQuality);
	end

	if self.animating then
		self.Center.Fill.BarMask:SetWidth(0);
		self.Center.Fill.Bar:SetShown(false);

		self.Center.Fill.BarHighlightMask:SetWidth(0);
		self.Center.Fill.BarHighlight:SetShown(false);

		self.Marker.TransitionIn:Restart();
		self.DividerGlow:SetPoint("CENTER", self.Marker);
		self.DividerGlow.TransitionIn:Restart();

		self.Left.AppearIcon:Show();
		self.Left.AppearIcon.Anim:Restart();
		self.Right.AppearIcon.Anim:Restart();
	end

	self.animating = false;
end

function ProfessionsQualityMeterMixin:SetOnAnimationsFinished(func)
	self.onAnimationsFinished = func;
end

function ProfessionsQualityMeterMixin:SetQuality(quality, maxQuality)
	if self.animating then
		self.pendingQuality = quality;
		self.pendingMaxQuality = maxQuality;
		return;
	end

	local oldCraftingQuality = self.craftingQuality;
	self.craftingQuality = math.floor(quality);

	local tierIconOffsets =
	{
		[1] = 2,
		[2] = 3,
		[3] = 3,
		[4] = 2,
		[5] = 3,
	};
	
	self.Left.AppearIcon:SetAtlas(("GemAppear_T%d_Flipbook"):format(self.craftingQuality));
	self.Left.DissolveIcon:SetAtlas(("GemDissolve_T%d_Flipbook"):format(self.craftingQuality));
	self.Left:ClearAllPoints();
	self.Left:SetPoint("RIGHT", self.Center, "LEFT", -tierIconOffsets[self.craftingQuality], 0);
	
	self.atMaxTier = self.craftingQuality >= maxQuality;
	self.Right:SetShown(not self.atMaxTier);
	if not self.atMaxTier then
		self.Right.AppearIcon:SetAtlas(("GemAppear_T%d_Flipbook"):format(self.craftingQuality + 1));
		self.Right:ClearAllPoints();
		self.Right:SetPoint("LEFT", self.Center, "RIGHT", tierIconOffsets[self.craftingQuality + 1], 0);
	end
	
	if oldCraftingQuality ~= self.craftingQuality then
		self.Left.AppearIcon.Anim:Restart();
		self.Right.AppearIcon.Anim:Restart();
	end

	local backgroundAtlas;
	if quality == maxQuality then
		backgroundAtlas = ("Professions-QualityBar-BarBGx2-Tier%dCap"):format(maxQuality);
	else
		backgroundAtlas = ("Professions-QualityBar-BarBGx2-Tier%d"):format(self.craftingQuality);
	end
	
	self.Center.Background:SetAtlas(backgroundAtlas);
	self.Center.Background:SetSize((372/2), (52/2));

	local qualityRemainder = math.fmod(quality, 1);
	local swapAssetThreshold = 0.05;
	if qualityRemainder <= swapAssetThreshold then
		self.Marker.Marker:SetAtlas("Professions-QualityBar-marker-left", TextureKitConstants.UseAtlasSize);
	elseif qualityRemainder >= 1 - swapAssetThreshold then
		self.Marker.Marker:SetAtlas("Professions-QualityBar-marker-right", TextureKitConstants.UseAtlasSize);
	else
		self.Marker.Marker:SetAtlas("Professions-QualityBar-marker", TextureKitConstants.UseAtlasSize);
	end

	local markerX = qualityRemainder * (374.25/2);
	if not self.atMaxTier then
		self.Marker:ClearAllPoints();
		self.Marker:SetPoint("CENTER", self.Center.Fill, "TOPLEFT", markerX, -13);
		self.Marker:Show();
		self.DividerGlow:Show();
		self.DividerGlow:SetPoint("CENTER", self.Marker);
	else
		self.Marker:ClearAllPoints();
		self.Marker:SetPoint("CENTER", self.Center.Fill, "TOPRIGHT", 0, 0);
		self.Marker:Hide();
		self.DividerGlow:ClearAllPoints();
		self.DividerGlow:Hide();
	end
end

function ProfessionsQualityMeterMixin:SetBarAtlas(quality)
	local barAtlas = ("Quality-BarFill-Flipbook-T%d-x2"):format(quality);
	self.Center.Fill.Bar:SetAtlas(barAtlas);
	self.Center.Fill.Bar:SetSize((374.25/2), (54/2));

	local highlightAtlas = ("Professions-QualityBar-Highlight-T%d"):format(quality);
	self.Center.Fill.BarHighlight:SetAtlas(highlightAtlas, TextureKitConstants.UseAtlasSize);
	self.Center.Fill.BarHighlight:SetSize((372/2), (52/2));
end

function ProfessionsQualityMeterMixin:PlayResultAnimation(resultData, operationInfo, animSpeedMultiplier)
	self.animating = true;

	if self.sequencer then
		self.sequencer:Cancel();
	end
	
	self.Left.AppearIcon.Anim:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Left.AppearIcon.ScaleUp:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Left.DissolveIcon.Anim:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Right.AppearIcon.Anim:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Right.AppearIcon.ScaleUp:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Right.AppearIcon.ScaleUpQuick:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Right.DissolveIcon.Anim:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Marker.TransitionIn:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Marker.TransitionOut:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Marker.TransitionOutLate:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.DividerGlow.TransitionIn:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.DividerGlow.TransitionOut:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Flare.FlareTransitionIn:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Flare.FxTransitionOut:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Center.Fill.TransitionOutLate:SetAnimationSpeedMultiplier(animSpeedMultiplier);
	self.Center.Fill.TransitionOut:SetAnimationSpeedMultiplier(animSpeedMultiplier);

	PlaySound(SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_START);

	self:SetBarAtlas(operationInfo.craftingQuality);

	self.Center.Fill.Bar.Flipbook:Play();
	self.Center.Fill.Bar:SetAlpha(1);
	self.Center.Fill.BarHighlight:SetAlpha(1);

	do
		self.Center.Fill.BarHighlightMask:ClearAllPoints();
		local p, r, rp, x, y = self.Marker:GetPointByName("CENTER");
		self.Center.Fill.BarHighlightMask:SetPoint("LEFT", self.Marker, "CENTER");
	end

	local function GetFillToPct(resultData, operationInfo)
		if resultData.craftingQuality > operationInfo.craftingQuality then
			return 1.0;
		end

		return resultData.qualityProgress;
	end

	local promotedTier = resultData.craftingQuality > operationInfo.craftingQuality;

	-- The fill is driven through an interpolator, not XML animation. Once the
	-- interpolation finishes, we'll call a sequence of XML animations to handle
	-- the more complicated weaving of element animations.
	self.sequencer = CreateSequencer();
	do
		local fillToPct = self.atMaxTier and 1 or GetFillToPct(resultData, operationInfo);
		local fillToWidth = fillToPct * (374.25/2);

		local function InterpolateBar(value)
			local maskWidth = fillToWidth * value;
			self.Center.Fill.BarMask:SetWidth(maskWidth);
			-- Mask with 0 extent causes the mask to be ignored. Show the bar
			-- highlight if we still need it.
			self.Center.Fill.Bar:SetShown(maskWidth > 0);

			local p, r, rp, x, y = self.Marker:GetPointByName("CENTER");
			local barHighlightMaskWidth = math.max(0, maskWidth - x);
			self.Center.Fill.BarHighlightMask:SetWidth(barHighlightMaskWidth);
			-- Mask with 0 extent causes the mask to be ignored. Show the bar
			-- highlight if we still need it.
			self.Center.Fill.BarHighlight:SetShown(barHighlightMaskWidth > 0);

			-- The divider follows the fill progress, with a minimum position
			-- where the marker is.
			local dividerX = math.max(0, maskWidth - x);
			self.DividerGlow:SetPoint("CENTER", self.Marker, "CENTER", dividerX, 0);
		end

		if self.atMaxTier then
			local time = .25;
			self.sequencer:AddInterpolated(1, 1, time, InterpolatorUtil.InterpolateEaseOut, InterpolateBar);
		else
			local unitsPerSecond = 200;
			local time = (fillToWidth / unitsPerSecond) / animSpeedMultiplier;
			self.sequencer:AddInterpolated(0, 1, time, InterpolatorUtil.InterpolateEaseOut, InterpolateBar);
		end
	end

	local function PlayBeginAnimation()
		-- The stats may now have changed, so anything being animated in
		-- should represent the new state, not the old state.
		self.Marker.TransitionIn:Restart();
		self.DividerGlow:SetPoint("CENTER", self.Marker);
		self.DividerGlow.TransitionIn:Restart();

		if promotedTier then
			self.Left.DissolveIcon:Hide();
			self.Left.AppearIcon:Show();
			self.Left.AppearIcon.Anim:Restart();
		end

		self.animating = false;

		if self.pendingQuality then
			local pendingQuality, pendingMaxQuality = self.pendingQuality, self.pendingMaxQuality;
			self.pendingQuality = nil;
			self.pendingMaxQuality = nil;
			self:SetQuality(pendingQuality, pendingMaxQuality);
		end

		if self.onAnimationsFinished then
			self.onAnimationsFinished();
		end
	end
	
	local function OnFxFinished()
		self.flareEffect = nil;
	end

	local function PlayEndAnimation()
		local craftingQuality = resultData.craftingQuality;
		local soundKit = craftingQuality and craftCompleteSoundKits[craftingQuality];
		if soundKit then
			PlaySound(soundKit);
		end

		if not self.atMaxTier then
			self.Flare.FlareTransitionIn:Restart();
			self.DividerGlow.TransitionOut:Restart();

			if resultData.isCrit then
				local modifier = Clamp(tonumber(GetCVar("ShakeStrengthUI")) or 0, 0, 1);
				local magnitude = 10 * modifier;
				if magnitude > 0 then
					ScriptAnimationUtil.ShakeFrameRandom(self, magnitude, .25, .05);
				end

				local effectID = 146;
				local source = self.Flare.Fx;
				self.flareEffect = GlobalFXDialogModelScene:AddEffect(effectID, source, nil, OnFxFinished);

				self.Flare.FxTransitionOut:Restart();
			end
		end

		if promotedTier then
			self.Left.AppearIcon:Hide();
			self.Left.DissolveIcon:Show();
			self.Left.DissolveIcon.Anim:Restart();

			local quick = animSpeedMultiplier > 1;
			if quick then
				self.Right.AppearIcon.ScaleUpQuick:Restart();
			else
				self.Right.AppearIcon.ScaleUp:Restart();
			end

			self:SetBarAtlas(resultData.craftingQuality);

			if quick then
				self.Marker.TransitionOut:Restart();
			else
				self.Marker.TransitionOutLate:Restart();
			end

			if quick then
				self.Center.Fill.TransitionOut:Restart();
				self.Center.Fill.TransitionOut:SetScript("OnFinished", PlayBeginAnimation);
			else
				self.Center.Fill.TransitionOutLate:Restart();
				self.Center.Fill.TransitionOutLate:SetScript("OnFinished", PlayBeginAnimation);
			end
		else
			self.Marker.TransitionOut:Restart();
			self.Center.Fill.TransitionOut:Restart();
			self.Center.Fill.TransitionOut:SetScript("OnFinished", PlayBeginAnimation);
		end
	end

	self.sequencer:Add(PlayEndAnimation);
	self.sequencer:Play();
end

function ProfessionsQualityMeterMixin:Reset()
end