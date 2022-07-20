CraftingQualityStatLine = EnumUtil.MakeEnum("Difficulty", "Skill");

local statLineLabels =
{
	[CraftingQualityStatLine.Difficulty] = PROFESSIONS_CRAFTING_STAT_DIFFICULTY,
	[CraftingQualityStatLine.Skill] = PROFESSIONS_CRAFTING_STAT_SKILL,
};

local statLineDescriptions =
{
	[CraftingQualityStatLine.Difficulty] = PROFESSIONS_CRAFTING_STAT_DIFFICULTY_DESCRIPTION,
	[CraftingQualityStatLine.Skill] = PROFESSIONS_CRAFTING_STAT_SKILL_DESCRIPTION,
};

ProfessionsCrafterDetailsStatLineMixin = {};

function ProfessionsCrafterDetailsStatLineMixin:OnLoad()
	if self.statLineType ~= nil then
		self:SetLabel(statLineLabels[self.statLineType]);
	end
end

function ProfessionsCrafterDetailsStatLineMixin:OnEnter()
	-- Overriden for bonus stat lines
	if self.statLineType ~= nil and self.baseValue ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:ClearLines();
		GameTooltip_AddColoredDoubleLine(GameTooltip, statLineLabels[self.statLineType], 
													  PROFESSIONS_CRAFTING_STAT_QUANTITY_TT_FMT:format(self.baseValue + self.bonusValue, self.baseValue, self.bonusValue),
													  HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddNormalLine(GameTooltip, statLineDescriptions[self.statLineType]);
		GameTooltip:Show();
	end
end

function ProfessionsCrafterDetailsStatLineMixin:OnLeave()
	GameTooltip_Hide();
end

function ProfessionsCrafterDetailsStatLineMixin:InitBonusStat(label, desc, value, pctValue, bonusPctValue)
	self:SetLabel(label);
	self:SetValue(self.displayAsPct and pctValue or value);

	self:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, label);
		GameTooltip_AddNormalLine(GameTooltip, desc);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_STAT_TT_FMT:format(label, value, bonusPctValue));
		GameTooltip:Show();
	end);
end

function ProfessionsCrafterDetailsStatLineMixin:SetLabel(label)
	self.LeftLabel:SetText(label);
end

function ProfessionsCrafterDetailsStatLineMixin:SetValue(baseValue, bonusValue)
	self.baseValue = baseValue;
	self.bonusValue = bonusValue;

	local fmt = self.displayAsPct and "%d%%" or "%d";
	self.RightLabel:SetText(fmt:format(math.ceil(baseValue + (bonusValue or 0))));
end

ProfessionsRecipeCrafterDetailsMixin = {};

function ProfessionsRecipeCrafterDetailsMixin:OnLoad()
	self.statLinePool = CreateFramePool("FRAME", self, "ProfessionsCrafterDetailsStatLineTemplate");

	self.Label:SetText(PROFESSIONS_CRAFTING_DETAILS_HEADER);
	self.FinishingReagentSlotContainer.Label:SetText(PROFESSIONS_CRAFTING_FINISHING_HEADER);

	self.QualityMeter.Center.Fill:SetScript("OnEnter", function(fill)
		GameTooltip:SetOwner(fill, "ANCHOR_RIGHT");

		local atlasSize = 25;
		local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(self.QualityMeter.qualityInteger), atlasSize, atlasSize);
		GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_EXPECTED_QUALITY:format(atlasMarkup));
		GameTooltip:Show();
	end);

	self.QualityMeter.Center.Fill:SetScript("OnLeave", GameTooltip_Hide);

	local function OnCapEntered(cap, isRight)
		local qualityIndex = self.QualityMeter.qualityInteger + (isRight and 1 or 0);

		GameTooltip:SetOwner(cap, "ANCHOR_RIGHT");
		-- Generic tooltip (no specific item output)
		if not self.recipeInfo.hasSingleItemOutput then
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_CRAFTING_GENERIC_QUALITY_DESCRIPTION);
		-- Item ID per quality
		elseif self.recipeInfo.qualityItemIDs ~= nil then
			GameTooltip:SetItemByIDWithQuality(self.recipeInfo.qualityItemIDs[qualityIndex], self.recipeInfo.qualityIDs[qualityIndex]);
		-- Item modified by quality
		elseif self.recipeInfo.qualityIlvlBonuses ~= nil then
			GameTooltip_SetTitle(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUSES:format(self.itemName));
			local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(self.recipeInfo.recipeID, self.transaction:CreateOptionalCraftingReagentInfoTbl());
			if outputItemInfo.hyperlink then
				local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
				if item:IsItemDataCached() then
					for index, ilvlBonus in ipairs(self.recipeInfo.qualityIlvlBonuses) do
						local atlasSize = 25;
						local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(index), atlasSize, atlasSize);
						GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUS_INCR:format(atlasMarkup, item:GetCurrentItemLevel() + ilvlBonus, ilvlBonus));
					end
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

	self:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
end

UseTest1 = true;

function ProfessionsRecipeCrafterDetailsMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		local resultData = ...;
		self:HandleCritAnimation(resultData);
	end
end

function ProfessionsRecipeCrafterDetailsMixin:QuickFinishAnimation()
	self.QualityMeter.Center.Fill.Test1.Anim:Play();
	self.QualityMeter.Center.Fill.Flare.Anim:Play();
end

function ProfessionsRecipeCrafterDetailsMixin:HandleCritAnimation(resultData)
	self.QualityMeter.Center.Fill.Test2:SetAlpha(1);
	self.QualityMeter.Center.Fill.Flare2:SetAlpha(0);
	self.QualityMeter.Center.Test2b:SetAlpha(0);

	local startingWidth = self.QualityMeter.Center.Fill:GetWidth();
	local unitsPerSecond = 375;

	local sequence = CreateInterpolationSequence();
	do
		-- Resize primary fill left to right
		local v1, v2 = 0, 1;
		local t = math.min(1, startingWidth / unitsPerSecond);
		sequence:Add(v1, v2, t, InterpolatorUtil.InterpolateLinear, function(value)
			self.QualityMeter.Center.Fill.Test2:SetWidth(startingWidth * value);
		end);
	end

	if resultData.isCrit then
		do
			-- Resize secondary fill left ro right.
			local skillRange = self.operationInfo.upperSkillTreshold - self.operationInfo.lowerSkillThreshold;
			if skillRange == 0 then
				return;
			end
			local finalSkillPct = math.min((self.operationInfo.baseSkill + self.operationInfo.bonusSkill + resultData.critBonusSkill - self.operationInfo.lowerSkillThreshold) / skillRange, 1.0);
			local finalWidth = self.QualityMeter.Center:GetWidth() * finalSkillPct;
			local extraCritWidth = finalWidth - startingWidth;
			local modifier = .12;
			local v1, v2 = 0, 1;
			local t = (extraCritWidth / unitsPerSecond) / modifier;
			sequence:Add(v1, v2, t, InterpolatorUtil.InterpolateEaseOut, function(value)
				self.QualityMeter.Center.Fill.Test2:SetWidth(startingWidth + (value * extraCritWidth));
				self.QualityMeter.Center.Test2b:SetAlpha(value * .6);
				self.QualityMeter.Center.Fill.Flare2:SetAlpha(value * .6);
				self.QualityMeter.Center.Test2b:Show();
			end);
		end

		do
			-- Fade out
			local v1, v2 = 1, 0;
			local t = .25;
			sequence:Add(v1, v2, t, InterpolatorUtil.InterpolateLinear, function(value)
				self.QualityMeter.Center.Fill.Test2:SetAlpha(value);
				self.QualityMeter.Center.Fill.Flare2:SetAlpha(value);
				self.QualityMeter.Center.Test2b:SetAlpha(value * .6);
			end);
		end
	else
		do
			-- Fade out
			local v1, v2 = 1, 0;
			local t = .25;
			sequence:Add(v1, v2, t, InterpolatorUtil.InterpolateLinear, function(value)
				self.QualityMeter.Center.Fill.Test2:SetAlpha(value);
			end);
		end
	end

	sequence:Play();
end

function ProfessionsRecipeCrafterDetailsMixin:SetTransaction(transaction)
	self.transaction = transaction;
end

function ProfessionsRecipeCrafterDetailsMixin:SetStats(operationInfo, supportsQualities)
	if self.recipeInfo == nil or operationInfo == nil then
		return;
	end

	self.operationInfo = operationInfo;

	self.statLinePool:ReleaseAll();

	self.QualityMeter.Center.Fill2:SetValue(0);
	self.QualityMeter.Center.Fill.Flare2:SetAlpha(0);

	self.QualityMeter:SetShown(supportsQualities);
	self.DifficultyStatLine:SetShown(supportsQualities);
	self.SkillStatLine:SetShown(supportsQualities);
	if supportsQualities then
		self.QualityMeter:SetQuality(operationInfo.quality, self.recipeInfo.maxQuality);
		self.DifficultyStatLine:SetValue(operationInfo.baseDifficulty, operationInfo.bonusDifficulty);
		self.SkillStatLine:SetValue(operationInfo.baseSkill, operationInfo.bonusSkill);
	end

	local nextBonusStatParent = supportsQualities and self.SkillStatLine or self.Line;
	local nextBonusStatYOfs = supportsQualities and 0 or -25;
	for _, bonusStat in ipairs(operationInfo.bonusStats) do
		local statLine = self.statLinePool:Acquire();
		statLine:InitBonusStat(bonusStat.bonusStatName, bonusStat.ratingDescription, bonusStat.bonusStatValue, bonusStat.ratingPct, bonusStat.bonusRatingPct);

		statLine:SetPoint("TOPLEFT", nextBonusStatParent, "BOTTOMLEFT", 0, nextBonusStatYOfs);
		statLine:SetPoint("TOPRIGHT", nextBonusStatParent, "BOTTOMRIGHT", 0, nextBonusStatYOfs);
		statLine:Show();

		nextBonusStatParent = statLine;
		nextBonusStatYOfs = 0;
	end
end

function ProfessionsRecipeCrafterDetailsMixin:SetOutputItemName(itemName)
	self.itemName = itemName;
end

function ProfessionsRecipeCrafterDetailsMixin:Reset()
	self.QualityMeter:Reset();
end

function ProfessionsRecipeCrafterDetailsMixin:SetRecipeInfo(recipeInfo)
	self.recipeInfo = recipeInfo;
end

ProfessionsQualityMeterMixin = {};

function ProfessionsQualityMeterMixin:OnLoad()
	self:Reset();

	self.interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
end

local function GetColorRGBA(quality)
	if quality == 1 then
		return .616, .357, .231, 1;
	elseif quality == 2 then
		return .592, .608, .627, 1;
	elseif quality == 3 then
		return .886, .761, .004, 1;
	elseif quality == 4 then
		return .086, .867, .675, 1;
	elseif quality == 5 then
		return 1, .761, .071, 1;
	end
	assert(false);
end

function ProfessionsQualityMeterMixin:SetQuality(quality, maxQuality)
	self.qualityInteger = math.floor(quality);
	self.Left.Icon:SetAtlas(Professions.GetIconForQuality(self.qualityInteger), TextureKitConstants.UseAtlasSize);
	local notAtMax = self.qualityInteger < maxQuality;
	self.Right:SetShown(notAtMax);
	if notAtMax then
		self.Right.Icon:SetAtlas(Professions.GetIconForQuality(self.qualityInteger + 1), TextureKitConstants.UseAtlasSize);
	end

	self.partialQuality = math.fmod(quality, 1);
	local hasPartial = self.partialQuality ~= 0;
	local centerWidth = self.Center:GetWidth();
	self.Center.Fill:SetShown(hasPartial);
	if hasPartial then
		self.Center.Fill:SetWidth(math.fmod(quality, 1) * centerWidth);
		self.Center.Fill.Background:SetColorTexture(GetColorRGBA(self.qualityInteger));
	end

	self.Border.Marker:ClearAllPoints();
	self.Border.Marker:SetPoint("CENTER", self.Center.Fill, "LEFT", math.floor(centerWidth * self.partialQuality), 0);
end

function ProfessionsQualityMeterMixin:Reset()
	self.Center.Fill2:SetMinMaxValues(0, 1);
	self.Center.Fill2:SetValue(0);
end