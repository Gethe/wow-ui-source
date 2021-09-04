
local OptionalReagentTutorialStage = {
	Slot = 1,
	List = 2,
	Icon = 3,
	Create = 4,
};


TradeSkillDetailsMixin = {};

local TradeSkillDetailsEvents = {
	"NEW_RECIPE_LEARNED",
};

function TradeSkillDetailsMixin:OnLoad()
	self.CreateMultipleInputBox:SetMinMaxValues(1, 999);

	self.Contents.RequirementText:SetWidth(236 - self.Contents.RequirementLabel:GetWidth());

	self:RegisterEvent("UPDATE_TRADESKILL_RECAST");
	self:RegisterEvent("PLAYTIME_CHANGED");

	self.GlowClipFrame.ModifiedCraftingGlow:SetPoint("CENTER", self.Contents.ResultIcon, "CENTER");
	self.GlowClipFrame.ModifiedCraftingGlowSpin:SetPoint("CENTER", self.Contents.ResultIcon, "CENTER");
	self.GlowClipFrame.ModifiedCraftingGlowSpinAnim:Play();
end

function TradeSkillDetailsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TradeSkillDetailsEvents);

	self:GetParent():RegisterCallback(TradeSkillUIMixin.Event.OptionalReagentListClosed, self.OnOptionalReagentListClosed, self);
end

function TradeSkillDetailsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TradeSkillDetailsEvents);

	self:GetParent():UnregisterCallback(TradeSkillUIMixin.Event.OptionalReagentListClosed, self);
	self:CancelSpellLoadCallback();
	self:ClearOptionalReagents();
end

function TradeSkillDetailsMixin:OnUpdate()
	if self.pendingRefresh then
		self:RefreshDisplay();
		self.pendingRefresh = false;
	end
end

function TradeSkillDetailsMixin:OnEvent(event, ...)
	if event == "UPDATE_TRADESKILL_RECAST" then
		self.CreateMultipleInputBox:SetValue(C_TradeSkillUI.GetRecipeRepeatCount());
	elseif event == "PLAYTIME_CHANGED" then
		if self:IsVisible() then
			self:RefreshButtons();
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		-- The refresh below will re-register as needed.
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		self:Refresh();
	elseif event == "NEW_RECIPE_LEARNED" then
		local recipeID, recipeLevel, baseRecipeID = ...;
		if self.selectedRecipeID == baseRecipeID then
			self:SetSelectedRecipeLevel(recipeLevel);
		end
	end
end

function TradeSkillDetailsMixin:OnOptionalReagentListClosed()
	self:Refresh();
end

function TradeSkillDetailsMixin:OnDataSourceChanged()
	self:SetPendingCreationAmount(1);
	self.GuildFrame:Clear();
end

function TradeSkillDetailsMixin:CancelSpellLoadCallback()
	if self.spellDataLoadedCancelFunc then
		self.spellDataLoadedCancelFunc();
		self.spellDataLoadedCancelFunc = nil;
	end
end

function TradeSkillDetailsMixin:SetSelectedRecipeID(recipeID)
	if self.selectedRecipeID ~= recipeID then
		self:CancelSpellLoadCallback();

		local skipRefresh = true;
		self:SetSelectedRecipeLevel(nil, skipRefresh);
		
		self.selectedRecipeID = recipeID;
		self.craftable = false;
		self.optionalReagents = {};
		self.createVerbOverride = nil;
		self.GuildFrame:Clear();
		self:RefreshButtons();
		self:SetPendingCreationAmount(1);
		self:Refresh();
	end
end

function TradeSkillDetailsMixin:Refresh()
	self.pendingRefresh = true;
end

function TradeSkillDetailsMixin:Clear()
	self.Contents:Hide();
	self.craftable = false;
	self.currentRank = nil;
	self.createVerbOverride = nil;
	self:RefreshButtons();
end

function TradeSkillDetailsMixin:AddContentWidget(widget)
	self.activeContentWidgets[#self.activeContentWidgets + 1] = widget;
end

function TradeSkillDetailsMixin:CalculateContentHeight()
	local height = 0;
	local contentTop = self.Contents:GetTop();
	for i, widget in ipairs(self.activeContentWidgets) do
		local bottom = widget:GetBottom();
		if bottom then
			height = math.max(height, contentTop - bottom);
		end
	end

	return height;
end

local function SetUpReagentButton(reagentButton, reagentName, reagentTexture, requiredReagentCount, playerReagentCount, isOptional, bonusText, optionalReagentQuality)
	reagentName = reagentName or "";
	reagentTexture = reagentTexture or "";

	reagentButton.Icon:SetTexture(reagentTexture);

	if isOptional then
		reagentButton:SetReagentText(bonusText);
		reagentButton:SetReagentQuality(optionalReagentQuality);
	else
		reagentButton.Name:SetText(reagentName);
	end

	local craftable = true;
	if playerReagentCount < requiredReagentCount then
		reagentButton.Icon:SetVertexColor(0.5, 0.5, 0.5);
		reagentButton.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		craftable = false;
	else
		reagentButton.Icon:SetVertexColor(1.0, 1.0, 1.0);
		reagentButton.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end

	if isOptional and requiredReagentCount == 1 then
		reagentButton.Count:SetText(playerReagentCount);
	else
		SetItemButtonReagentCount(reagentButton, requiredReagentCount, playerReagentCount);
	end

	return craftable;
end

function TradeSkillDetailsMixin:CanShowTutorial()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_OPTIONAL_REAGENT_CRAFTING) then 
		return false;
	end

	local numOptionalReagents = #self.optionalReagentSlots;
	if numOptionalReagents == 0 then
		return false;
	end

	for i = 1, numOptionalReagents do
		if not self.Contents.OptionalReagents[i]:IsLocked() then
			return true;
		end
	end

	return false;
end

function TradeSkillDetailsMixin:SetTutorialStage(stageComplete)
	if not self:CanShowTutorial() then
		self.tutorialStage = nil;
		return;
	end

	if not self.tutorialStage then
		if self.Contents.OptionalReagent1:IsShown() then
			self.tutorialStage = OptionalReagentTutorialStage.Slot;
		end
	elseif self.tutorialStage == stageComplete then
		self.tutorialStage = self.tutorialStage + 1;
		if self.tutorialStage > OptionalReagentTutorialStage.Create then
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_OPTIONAL_REAGENT_CRAFTING, true);
			self.tutorialStage = nil;
		end
	end

	if self.tutorialStage and (self.tutorialStage > OptionalReagentTutorialStage.List) and (#self:GetOptionalReagentsArray() == 0) then
		self.tutorialStage = self:GetParent():IsOptionalReagentListShown() and OptionalReagentTutorialStage.List or OptionalReagentTutorialStage.Slot;
	end

	if self.tutorialStage == OptionalReagentTutorialStage.List and not self:GetParent():IsOptionalReagentListShown() then
		self.tutorialStage = OptionalReagentTutorialStage.Slot;
	end
end

function TradeSkillDetailsMixin:CheckOptionalReagentTutorial(stageComplete)
	HelpTip:HideAll(self);

	if not self.recipeLearned then
		return;
	end

	self:SetTutorialStage(stageComplete);

	-- Show/hide a synchronized glowing animations.
	local progress = nil;
	local shouldGlow = not self.hasShownSlotTutorial and (self.tutorialStage == OptionalReagentTutorialStage.Slot);
	for i, reagentButton in ipairs(self.Contents.OptionalReagents) do
		local isOpen = not reagentButton:IsLocked() and (self:GetOptionalReagent(reagentButton.optionalReagentIndex) == nil);
		if shouldGlow and isOpen then
			if not progress then
				progress = reagentButton:GetGlowingProgress();
			end

			reagentButton:SetGlowing(true, progress);
		else
			reagentButton:SetGlowing(false);
		end
	end

	if self.tutorialStage == OptionalReagentTutorialStage.Slot then
		-- Only show the slot tutorial once per session.
		if not self.hasShownSlotTutorial then
			local helpTipInfo = {
				text = OPTIONAL_REAGENT_TUTORIAL_SLOT,
				buttonStyle = HelpTip.ButtonStyle.None,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				alignment = HelpTip.Alignment.CENTER,
				offsetX = -6,
				offsetY = 2,
			};

			HelpTip:Show(self, helpTipInfo, self.Contents.OptionalReagent1);
		end
	elseif self.tutorialStage == OptionalReagentTutorialStage.List then
		local firstLine = self:GetParent():GetOptionalReagentListTutorialLine();
		if not firstLine:IsShown() then
			return;
		end

		self.hasShownSlotTutorial = true;

		local helpTipInfo = {
			text = OPTIONAL_REAGENT_TUTORIAL_LIST,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.CENTER,
			offsetX = 0,
			offsetY = 0,
		};

		HelpTip:Show(self, helpTipInfo, firstLine);
	elseif self.tutorialStage == OptionalReagentTutorialStage.Icon then
		local function HelpTipHiddenCallback(acknowledged)
			if acknowledged then
				self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Icon);
			end
		end

		local helpTipInfo = {
			text = OPTIONAL_REAGENT_TUTORIAL_ITEM,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.CENTER,
			offsetX = -6,
			offsetY = 2,
			onHideCallback = HelpTipHiddenCallback,
		};

		HelpTip:Show(self, helpTipInfo, self.Contents.ResultIcon);
	elseif self.tutorialStage == OptionalReagentTutorialStage.Create then
		local function HelpTipHiddenCallback(acknowledged)
			if acknowledged then
				self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Create);
			end
		end

		local helpTipInfo = {
			text = OPTIONAL_REAGENT_TUTORIAL_COUNT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			alignment = HelpTip.Alignment.TOP,
			offsetX = 0,
			offsetY = 0,
			onHideCallback = HelpTipHiddenCallback,
		};

		HelpTip:Show(self, helpTipInfo, self.CreateMultipleInputBox);
	end
end

function TradeSkillDetailsMixin:SetSelectedRecipeLevel(recipeLevel, skipRefresh)
	self.selectedRecipeLevel = recipeLevel;

	if not skipRefresh then
		self:RefreshDisplay();
	end
end

function TradeSkillDetailsMixin:GetSelectedRecipeLevel()
	return self.selectedRecipeLevel;
end

local SPACING_BETWEEN_LINES = 11;
function TradeSkillDetailsMixin:RefreshDisplay()
	self.activeContentWidgets = {};

	local selectedRecipeLevel = self:GetSelectedRecipeLevel();
	local recipeInfo = self.selectedRecipeID and C_TradeSkillUI.GetRecipeInfo(self.selectedRecipeID, selectedRecipeLevel);
	if recipeInfo then
		local categoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID);
		while not categoryInfo.skillLineCurrentLevel and categoryInfo.parentCategoryID do
			categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryInfo.parentCategoryID);
		end

		local categorySkillRank = categoryInfo.skillLineCurrentLevel or 0;

		local hasRecipeLeveling = recipeInfo.unlockedRecipeLevel;
		local hasMaxRecipeLevel = hasRecipeLeveling and (recipeInfo.currentRecipeExperience == nil);
		if hasRecipeLeveling and (selectedRecipeLevel == nil) then
			selectedRecipeLevel = recipeInfo.unlockedRecipeLevel;
			
			local skipRefresh = true;
			self:SetSelectedRecipeLevel(selectedRecipeLevel, skipRefresh);
		end

		self.recipeLearned = recipeInfo.learned;

		if recipeInfo.learned then
			self.Background:SetAtlas("tradeskill-background-recipe");
		else
			self.Background:SetAtlas("tradeskill-background-recipe-unlearned");
		end
		
		if ( recipeInfo.alternateVerb and recipeInfo.alternateVerb ~= "") then
			self.createVerbOverride = recipeInfo.alternateVerb;
		end

		self.Contents.RecipeName:SetText(recipeInfo.name);
		local recipeLink = C_TradeSkillUI.GetRecipeItemLink(self.selectedRecipeID);
		if ( recipeInfo.productQuality ) then
			self.Contents.RecipeName:SetTextColor(GetItemQualityColor(recipeInfo.productQuality));
		else
			self.Contents.RecipeName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end

		SetItemButtonQuality(self.Contents.ResultIcon, recipeInfo.productQuality, recipeLink);
		self:AddContentWidget(self.Contents.RecipeName);

		self.Contents.ResultIcon:SetNormalTexture(recipeInfo.icon);
		self:AddContentWidget(self.Contents.ResultIcon);

		local minMade, maxMade = C_TradeSkillUI.GetRecipeNumItemsProduced(self.selectedRecipeID);
		if maxMade > 1 then
			if minMade == maxMade then
				self.Contents.ResultIcon.Count:SetText(minMade);
			else
				self.Contents.ResultIcon.Count:SetFormattedText("%d-%d", minMade, maxMade);
			end
			if self.Contents.ResultIcon.Count:GetWidth() > 39 then
				self.Contents.ResultIcon.Count:SetFormattedText("~%d", math.floor(Lerp(minMade, maxMade, .5)));
			end
		else
			self.Contents.ResultIcon.Count:SetText("");
		end
		self:AddContentWidget(self.Contents.ResultIcon);

		TradeSkillFrame_GenerateRankLinks(recipeInfo);
		local totalRanks, currentRank = TradeSkillFrame_CalculateRankInfoFromRankLinks(recipeInfo);
		self.currentRank = currentRank;

		self.Contents.StarsFrame:Hide();
		self.Contents.RecipeLevel:Hide();
		self.Contents.RecipeLevelSelector:Hide();

		if totalRanks > 1 then
			self.Contents.StarsFrame:Show();
			for i, starFrame in ipairs(self.Contents.StarsFrame.Stars) do
				starFrame.EarnedStar:SetShown(i <= currentRank);
				if (i > currentRank and (not self.flashingStar or self.flashingStarRecipeID ~= self.selectedRecipeID) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRADESKILL_RANK_STAR)) then
					if (self.flashingStar) then
						self.flashingStar.FlashStar:Hide();
						self.flashingStar.Pulse:Stop();
					end
					starFrame.FlashStar:Show();
					starFrame.Pulse:Play();
					self.flashingStar = starFrame;
					self.flashingStarRecipeID = self.selectedRecipeID;
				elseif (i == #self.Contents.StarsFrame.Stars and currentRank == #self.Contents.StarsFrame.Stars and self.flashingStar) then
					self.flashingStar.FlashStar:Hide();
					self.flashingStar.Pulse:Stop();
					self.flashingStar = nil;
					self.flashingStarRecipeID = nil;
				end
			end
			self:AddContentWidget(self.Contents.StarsFrame);
			self.Contents.StarsFrame:Show();
		elseif hasRecipeLeveling then
			local recipeLevelBar = self.Contents.RecipeLevel;
			recipeLevelBar:SetExperience(recipeInfo.currentRecipeExperience, recipeInfo.nextLevelRecipeExperience, recipeInfo.unlockedRecipeLevel);
			self:AddContentWidget(recipeLevelBar);
			recipeLevelBar:Show();

			local function RecipeLevelDropDown_Initialize()
				for i = 1, recipeInfo.unlockedRecipeLevel do
					local info = UIDropDownMenu_CreateInfo();
					info.text = TRADESKILL_RECIPE_LEVEL_DROPDOWN_OPTION_FORMAT:format(i);
					info.func = function()
						self:SetSelectedRecipeLevel(i);
					end

					info.checked = (i == selectedRecipeLevel);
					UIDropDownMenu_AddButton(info);
				end
			end

			UIDropDownMenu_Initialize(self.Contents.RecipeLevelDropDown, RecipeLevelDropDown_Initialize, "MENU");

			self:AddContentWidget(self.Contents.RecipeLevelSelector);

			self.Contents.RecipeLevelSelector:SetText(TRADESKILL_RECIPE_LEVEL_DROPDOWN_BUTTON_FORMAT:format(selectedRecipeLevel));
			self.Contents.RecipeLevelSelector:Show();
		end

		self.Contents.Description:SetText("");
		self.Contents.RequirementLabel:SetPoint("TOPLEFT", self.Contents.Description, "BOTTOMLEFT", 0, 0);
		local baseSpell = Spell:CreateFromSpellID(TradeSkillFrame_GetBaseRecipeID(self.selectedRecipeID));
		self.spellDataLoadedCancelFunc = baseSpell:ContinueWithCancelOnSpellLoad(function()
			local recipeDescription = C_TradeSkillUI.GetRecipeDescription(baseSpell:GetSpellID());
			if recipeDescription and #recipeDescription > 0 then
				self.Contents.Description:SetText(recipeDescription);
				self.Contents.RequirementLabel:SetPoint("TOPLEFT", self.Contents.Description, "BOTTOMLEFT", 0, -18);
			end
			self.spellDataLoadedCancelFunc = nil;
		end);
		self:AddContentWidget(self.Contents.Description);

		local craftable = recipeInfo.learned and recipeInfo.craftable;

		local requiredToolsString = BuildColoredListString(C_TradeSkillUI.GetRecipeTools(self.selectedRecipeID));
		if requiredToolsString then
			self.Contents.RequirementLabel:Show();
			self.Contents.RequirementText:SetText(requiredToolsString);
			self.Contents.ExperienceLabel:SetPoint("TOP", self.Contents.RequirementText, "BOTTOM", 0, 0);
			self:AddContentWidget(self.Contents.RequirementLabel);
			self:AddContentWidget(self.Contents.RequirementText);
		else
			self.Contents.RequirementLabel:Hide();
			self.Contents.RequirementText:SetText("");
			self.Contents.ExperienceLabel:SetPoint("TOP", self.Contents.RequirementText, "TOP", 0, 0);
		end

		local earnedExperience = recipeInfo.earnedExperience;
		local showEarnedExperience = (earnedExperience ~= nil) and not hasMaxRecipeLevel;
		if showEarnedExperience then
			self.Contents.ExperienceLabel:Show();
			self.Contents.ExperienceText:SetText(earnedExperience);
			self:AddContentWidget(self.Contents.ExperienceLabel);
			self:AddContentWidget(self.Contents.ExperienceText);
		else
			self.Contents.ExperienceLabel:Hide();
			self.Contents.ExperienceText:SetText("");
		end

		if showEarnedExperience then
			self.Contents.RecipeCooldown:SetPoint("TOP", self.Contents.ExperienceText, "BOTTOM", 0, -SPACING_BETWEEN_LINES);
		elseif requiredToolsString then
			self.Contents.RecipeCooldown:SetPoint("TOP", self.Contents.RequirementText, "BOTTOM", 0, -SPACING_BETWEEN_LINES);
		else
			self.Contents.RecipeCooldown:SetPoint("TOP", self.Contents.RequirementText, "BOTTOM", 0, 0);
		end

		local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(self.selectedRecipeID);
		self.Contents.ReagentLabel:SetPoint("TOPLEFT", self.Contents.RecipeCooldown, "BOTTOMLEFT", 0, -SPACING_BETWEEN_LINES);
		if maxCharges > 0 and (charges > 0 or not cooldown) then
			self.Contents.RecipeCooldown:SetFormattedText(TRADESKILL_CHARGES_REMAINING, charges, maxCharges);
			self.Contents.RecipeCooldown:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			self:AddContentWidget(self.Contents.RecipeCooldown);
		elseif recipeInfo.disabled then
			self.Contents.RecipeCooldown:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			self.Contents.RecipeCooldown:SetText(recipeInfo.disabledReason);
			self:AddContentWidget(self.Contents.RecipeCooldown);
			craftable = false;
		else
			self.Contents.RecipeCooldown:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			if not cooldown then
				self.Contents.RecipeCooldown:SetText("");
				self.Contents.ReagentLabel:SetPoint("TOPLEFT", self.Contents.RecipeCooldown, "BOTTOMLEFT", 0, 0);
			elseif not isDayCooldown then
				self.Contents.RecipeCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown));
				self:AddContentWidget(self.Contents.RecipeCooldown);
				craftable = false;
			elseif cooldown > 60 * 60 * 24  then	--Cooldown is greater than 1 day.
				self.Contents.RecipeCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown, true, false, 1, true));
				self:AddContentWidget(self.Contents.RecipeCooldown);
				craftable = false;
			else
				self.Contents.RecipeCooldown:SetText(COOLDOWN_EXPIRES_AT_MIDNIGHT);
				self:AddContentWidget(self.Contents.RecipeCooldown);
				craftable = false;
			end
		end

		local numReagents = C_TradeSkillUI.GetRecipeNumReagents(self.selectedRecipeID, selectedRecipeLevel);

		if numReagents > 0 then
			self.Contents.ReagentLabel:Show();
			self:AddContentWidget(self.Contents.ReagentLabel);
		else
			self.Contents.ReagentLabel:Hide();
		end

		for reagentIndex = 1, numReagents do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = C_TradeSkillUI.GetRecipeReagentInfo(self.selectedRecipeID, reagentIndex, selectedRecipeLevel);
			local reagentButton = self.Contents.Reagents[reagentIndex];

			reagentButton:Show();
			self:AddContentWidget(reagentButton);

			local hasReagentsToCraft = SetUpReagentButton(reagentButton, reagentName, reagentTexture, reagentCount, playerReagentCount);
			if not hasReagentsToCraft then
				craftable = false;
			end
		end

		for reagentIndex = numReagents + 1, #self.Contents.Reagents do
			local reagentButton = self.Contents.Reagents[reagentIndex];
			reagentButton:Hide();
		end

		local optionalReagentSlots = C_TradeSkillUI.GetOptionalReagentInfo(self.selectedRecipeID);
		self.optionalReagentSlots = optionalReagentSlots;
		local numOptionalReagentSlots = #optionalReagentSlots;
		local hasOptionalReagentSlots = numOptionalReagentSlots > 0;
		
		self.Contents.OptionalReagentLabel:SetShown(hasOptionalReagentSlots);
		self.Contents.OptionalReagentInfo:SetShown(hasOptionalReagentSlots);
		if hasOptionalReagentSlots then
			if numReagents > 0 then
				self.Contents.OptionalReagentLabel:SetPoint("TOP", self.Contents.Reagents[numReagents], "BOTTOM", 0, -15)
			else
				self.Contents.OptionalReagentLabel:SetPoint("TOP", self.Contents.ReagentLabel, "TOP");
			end

			self:AddContentWidget(self.Contents.OptionalReagentLabel);
		end

		local selectedOptionalReagentIndex = self:GetParent():GetSelectedOptionalReagentIndex();
		for optionalReagentIndex, slot in ipairs(optionalReagentSlots) do
			local reagentName, bonusText, reagentQuality, reagentTexture, reagentCount, playerReagentCount = self:GetOptionalReagent(optionalReagentIndex);
			local reagentButton = self.Contents.OptionalReagents[optionalReagentIndex];

			reagentButton:Show();
			self:AddContentWidget(reagentButton);

			local hasReagent = reagentName ~= nil;
			if playerReagentCount == 0 then
				self:SetOptionalReagent(optionalReagentIndex, nil);
				hasReagent = false;
			end

			local requiredSkillRank = slot.requiredSkillRank;
			local hasRequiredSkillRank = categorySkillRank >= requiredSkillRank;
			local hasLockedReason = (slot.lockedReason ~= nil);
			if hasLockedReason then
				reagentButton:SetLocked(true, slot.lockedReason);
			else
				reagentButton:SetLocked(not hasRequiredSkillRank, OPTIONAL_REAGENT_TOOLTIP_SLOT_LOCKED_FORMAT:format(requiredSkillRank));
			end

			if hasReagent then
				local isOptional = true;
				local hasReagentsToCraft = SetUpReagentButton(reagentButton, reagentName, reagentTexture, reagentCount, playerReagentCount, isOptional, bonusText, reagentQuality);
				if not hasReagentsToCraft then
					craftable = false;
				end
			else
				local isLocked = hasLockedReason or not hasRequiredSkillRank;
				reagentButton.Icon:SetAtlas(isLocked and "tradeskills-icon-locked" or "tradeskills-icon-add", TextureKitConstants.UseAtlasSize);
				reagentButton.Icon:SetVertexColor(1.0, 1.0, 1.0);
				reagentButton.Count:SetText("");
				reagentButton:SetReagentText(slot.slotText or OPTIONAL_REAGENT_POSTFIX);
				reagentButton:SetReagentColor(isLocked and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR);
			end

			reagentButton.SelectedTexture:SetShown(optionalReagentIndex == selectedOptionalReagentIndex);
		end

		for optionalReagentIndex = numOptionalReagentSlots + 1, #self.Contents.OptionalReagents do
			local reagentButton = self.Contents.OptionalReagents[optionalReagentIndex];
			reagentButton:Hide();
		end

		local optionalReagents = self:GetOptionalReagentsArray();
		if #optionalReagents == 0 then
			self.GlowClipFrame.ModifiedCraftingGlow:SetAlpha(0);
			self.GlowClipFrame.ModifiedCraftingGlowSpin:SetAlpha(0);
			self.Contents.ResultIcon.ModifiedCraftingGlowBorder:SetAlpha(0);
			self.Contents.ResultIcon.ResultBorder:SetAlpha(1);
		end

		self:CheckOptionalReagentTutorial();

		self.Contents.NextRankText:Hide();
		local sourceText, sourceTextIsForNextRank;
		if not recipeInfo.learned then
			sourceText = C_TradeSkillUI.GetRecipeSourceText(self.selectedRecipeID);
		elseif recipeInfo.nextRecipeID then
			sourceText = C_TradeSkillUI.GetRecipeSourceText(recipeInfo.nextRecipeID);
			if sourceText then
				sourceTextIsForNextRank = true;
				-- replace the color at the beginning of the sourceText
				sourceText = string.gsub(sourceText, "^|c%x%x%x%x%x%x", "|cC79C6E");
				-- replace color after a newline
				sourceText = string.gsub(sourceText, "|n|c%x%x%x%x%x%x", "|n|cC79C6E");
			end
		end

		if sourceText then
			self:AddContentWidget(self.Contents.SourceText);
			self.Contents.SourceText:SetText(sourceText);

			if ( sourceTextIsForNextRank ) then
				self:AddContentWidget(self.Contents.NextRankText);
				self.Contents.NextRankText:Show();
				if hasOptionalReagentSlots then
					self.Contents.NextRankText:SetPoint("TOP", self.Contents.OptionalReagents[numOptionalReagentSlots], "BOTTOM", 0, -15)
				elseif numReagents > 0 then
					self.Contents.NextRankText:SetPoint("TOP", self.Contents.Reagents[numReagents], "BOTTOM", 0, -15)
				else
					self.Contents.NextRankText:SetPoint("TOP", self.Contents.ReagentLabel, "TOP");
				end
				self.Contents.SourceText:SetPoint("TOP", self.Contents.NextRankText, "BOTTOM", 0, 0);
			else
				if hasOptionalReagentSlots then
					self.Contents.SourceText:SetPoint("TOP", self.Contents.OptionalReagents[numOptionalReagentSlots], "BOTTOM", 0, -15)
				elseif numReagents > 0 then
					self.Contents.SourceText:SetPoint("TOP", self.Contents.Reagents[numReagents], "BOTTOM", 0, -15);
				else
					self.Contents.SourceText:SetPoint("TOP", self.Contents.ReagentLabel, "TOP");
				end
			end
			self.Contents.SourceText:Show();
		else
			self.Contents.SourceText:SetText("");
			self.Contents.SourceText:Hide();
		end

		self.Contents:SetHeight(self:CalculateContentHeight());
		self.Contents:Show();
		self.craftable = craftable;
		self:RefreshButtons();
	else
		self:Clear();
	end
end

function TradeSkillDetailsMixin:RefreshButtons()
	if C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillLinked() then
		self.CreateButton:Hide();
		self.CreateAllButton:Hide();
		self.CreateMultipleInputBox:Hide();
		if C_TradeSkillUI.IsTradeSkillGuild() then
			self.ViewGuildCraftersButton:Show();
			local recipeInfo = self.selectedRecipeID and C_TradeSkillUI.GetRecipeInfo(self.selectedRecipeID);
			if recipeInfo and recipeInfo.learned then
				self.ViewGuildCraftersButton:Enable();
			else
				self.ViewGuildCraftersButton:Disable();
			end
		else
			self.ViewGuildCraftersButton:Hide();
		end
	else
		self.CreateButton:Show();
		self.ViewGuildCraftersButton:Hide();

		if self.createVerbOverride then
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
		else
			self.CreateAllButton:Show();
			self.CreateMultipleInputBox:Show();
		end

		self.CreateButton:SetText(self.createVerbOverride or CREATE_PROFESSION);
		local isInPartialPlayTime = PartialPlayTime();
		local isInNoPlayTime = NoPlayTime();

		local effectivelyCraftable = not isInPartialPlayTime and not isInNoPlayTime and self.craftable;

		if isInPartialPlayTime then
			local reasonText = PLAYTIME_TIRED_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltip = reasonText;
			self.CreateAllButton.tooltip = reasonText
		elseif isInNoPlayTime then
			local reasonText = PLAYTIME_UNHEALTHY_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltip = reasonText;
			self.CreateAllButton.tooltip = reasonText
		else
			self.CreateButton.tooltip = nil;
			self.CreateAllButton.tooltip = nil;
		end
	
		self.CreateButton:SetEnabled(effectivelyCraftable);
		self.CreateAllButton:SetEnabled(effectivelyCraftable);
		self.CreateMultipleInputBox:SetEnabled(effectivelyCraftable);
	end
end

function TradeSkillDetailsMixin:ViewGuildCrafters()
	local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID = C_TradeSkillUI.GetTradeSkillLine();
	local effectiveSkillLineID = parentSkillLineID or tradeSkillID;
	if effectiveSkillLineID and self.selectedRecipeID then
		self.GuildFrame:ShowGuildRecipe(effectiveSkillLineID, self.selectedRecipeID, self:GetSelectedRecipeLevel());
	end
end

function TradeSkillDetailsMixin:CreateAll()
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.selectedRecipeID);
	C_TradeSkillUI.CraftRecipe(self.selectedRecipeID, recipeInfo.numAvailable, self:GetOptionalReagentsArray(), self:GetSelectedRecipeLevel());
	self.CreateMultipleInputBox:ClearFocus();
	self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Create);
end

function TradeSkillDetailsMixin:Create()
	C_TradeSkillUI.CraftRecipe(self.selectedRecipeID, self.CreateMultipleInputBox:GetValue(), self:GetOptionalReagentsArray(), self:GetSelectedRecipeLevel());
	self.CreateMultipleInputBox:ClearFocus();
	self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Create);
end


function TradeSkillDetailsMixin:SetPendingCreationAmount(amount)
	self.CreateMultipleInputBox:SetValue(amount);
end

function TradeSkillDetailsMixin:OnResultMouseEnter(resultButton)
	if self.selectedRecipeID then
		GameTooltip:SetOwner(resultButton, "ANCHOR_RIGHT");
		GameTooltip:SetRecipeResultItem(self.selectedRecipeID, self:GetOptionalReagentsArray(), self:GetSelectedRecipeLevel());
		CursorUpdate(resultButton);
		self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Icon)
	end
	
	resultButton.UpdateTooltip = resultButton.UpdateTooltip or function(owner) self:OnResultMouseEnter(owner); end;
end

function TradeSkillDetailsMixin:OnResultClicked(resultButton)
	HandleModifiedItemClick(C_TradeSkillUI.GetRecipeItemLink(self.selectedRecipeID));
end

function TradeSkillDetailsMixin:OnReagentMouseEnter(reagentButton)
	GameTooltip:SetOwner(reagentButton, "ANCHOR_TOPLEFT");
	GameTooltip:SetRecipeReagentItem(self.selectedRecipeID, reagentButton.reagentIndex);
	CursorUpdate(reagentButton);
end

function TradeSkillDetailsMixin:OnReagentClicked(reagentButton)
	local clickHandled = HandleModifiedItemClick(C_TradeSkillUI.GetRecipeReagentItemLink(self.selectedRecipeID, reagentButton.reagentIndex));
	if not clickHandled then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		TradeSkillFrame.SearchBox:SetText(reagentButton.Name:GetText());
	end
end

function TradeSkillDetailsMixin:OnOptionalReagentMouseEnter(reagentButton)
	GameTooltip:SetOwner(reagentButton, "ANCHOR_TOPLEFT");

	if reagentButton:IsLocked() then
		GameTooltip_SetTitle(GameTooltip, EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE);

		local lockedReason = reagentButton:GetLockedTooltip();
		GameTooltip_AddErrorLine(GameTooltip, lockedReason);
	else
		local reagentName, bonusText, reagentQuality, reagentTexture, reagentCount, playerReagentCount, itemID = self:GetOptionalReagent(reagentButton.optionalReagentIndex);
		if reagentName then
			local itemQualityColor = ITEM_QUALITY_COLORS[reagentQuality];
			GameTooltip_SetTitle(GameTooltip, reagentName, itemQualityColor.color);

			GameTooltip_AddHighlightLine(GameTooltip, bonusText);
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddInstructionLine(GameTooltip, OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_REMOVE);
		else
			GameTooltip_SetTitle(GameTooltip, EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE);
			GameTooltip_AddInstructionLine(GameTooltip, OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_ADD);
		end
	end

	GameTooltip:Show();

	CursorUpdate(reagentButton);
end

function TradeSkillDetailsMixin:OnOptionalReagentClicked(reagentButton, button)
	local itemID = select(7, self:GetOptionalReagent(reagentButton.optionalReagentIndex));
	if itemID then
		local itemName, itemLink = GetItemInfo(itemID);
		if HandleModifiedItemClick(itemLink) then
			return;
		end
	end

	if button == "LeftButton" then
		PlaySound(SOUNDKIT.UI_9_0_CRAFTING_CLICK_OPTIONAL_REAGENT_SLOT);
		self:GetParent():OpenOptionalReagentSelection(self.selectedRecipeID, reagentButton.optionalReagentIndex);
		self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.Slot);
		self:Refresh();
	elseif button == "RightButton" then
		PlaySound(SOUNDKIT.UI_9_0_CRAFTING_RIGHT_CLICK_REMOVE_REAGENT);
		self:SetOptionalReagent(reagentButton.optionalReagentIndex, nil);
		self:OnOptionalReagentMouseEnter(reagentButton);
	end
end

function TradeSkillDetailsMixin:GetOptionalReagentsArray()
	return self.optionalReagents;
end

function TradeSkillDetailsMixin:SetOptionalReagent(optionalReagentIndex, option)
	local count = 1; -- Count is always 1 for optional profession reagents.

	local previousNumOptionalReagents = #self.optionalReagents;

	if option == nil then
		for i = 1, #self.optionalReagents do
			if self.optionalReagents[i].slot == optionalReagentIndex then
				table.remove(self.optionalReagents, i);
				break;
			end
		end
	else
		local currentSlotInfo = self:FindOptionalReagent(optionalReagentIndex);
		local currentItemInfo, currentItemInfoArrayIndex = self:FindOptionalReagentByItemID(option.itemID);
		if currentSlotInfo then
			currentSlotInfo.itemID = option.itemID;
			currentSlotInfo.count = count;

			if currentItemInfo and currentItemInfo ~= currentSlotInfo then
				table.remove(self.optionalReagents, currentItemInfoArrayIndex);
			end
		elseif currentItemInfo then
			currentItemInfo.count = count;
			currentItemInfo.slot = optionalReagentIndex;
		else
			table.insert(self.optionalReagents, { itemID = option.itemID, count = count, slot = optionalReagentIndex, });
		end
	end

	local glowActive = self.GlowClipFrame.ModifiedCraftingGlow:GetAlpha() ~= 0;
	if previousNumOptionalReagents == 1 and #self.optionalReagents == 0 and glowActive then
		self.GlowClipFrame.ModifiedCraftingGlowOutAnim:Play();
	elseif previousNumOptionalReagents == 0 and #self.optionalReagents > 0 and not glowActive then
		self.GlowClipFrame.ModifiedCraftingGlowInAnim:Play();
	end
	
	self:GetParent():TriggerEvent(TradeSkillUIMixin.Event.OptionalReagentUpdated, optionalReagentIndex);
	self:CheckOptionalReagentTutorial(OptionalReagentTutorialStage.List);
	self:Refresh();
end

function TradeSkillDetailsMixin:ClearOptionalReagents()
	self.optionalReagents = {};
	self:Refresh();
end

function TradeSkillDetailsMixin:FindOptionalReagent(optionalReagentIndex)
	local optionalReagentsArray = self:GetOptionalReagentsArray();
	for i = 1, #optionalReagentsArray do
		local info = optionalReagentsArray[i];
		if info.slot == optionalReagentIndex then
			return info, i;
		end
	end

	return nil;
end

function TradeSkillDetailsMixin:FindOptionalReagentByItemID(itemID)
	local optionalReagentsArray = self:GetOptionalReagentsArray();
	for i = 1, #optionalReagentsArray do
		local info = optionalReagentsArray[i];
		if info.itemID == itemID then
			return info, i;
		end
	end

	return nil;
end

function TradeSkillDetailsMixin:HasOptionalReagent(itemID)
	return self:FindOptionalReagentByItemID(itemID) ~= nil;
end

function TradeSkillDetailsMixin:GetOptionalReagent(optionalReagentIndex)
	local info = self:FindOptionalReagent(optionalReagentIndex);
	if not info then
		return nil;
	end

	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(info.itemID);
	if itemName then
		local itemCount = ItemUtil.GetOptionalReagentCount(info.itemID);
		local bonusText = self:GetOptionalReagentBonusText(info.itemID, optionalReagentIndex);
		return itemName, bonusText, itemQuality, itemIcon, info.count, itemCount, info.itemID;
	else
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		return RETRIEVING_ITEM_INFO, nil, nil, "Interface\\Icons\\INV_Misc_QuestionMark", 0, 0, info.itemID;
	end
end

function TradeSkillDetailsMixin:GetOptionalReagentsPreview(itemID, slot)
	local optionalReagents = self:GetOptionalReagentsArray();

	-- Get the current state of the optional reagent list.
	local info, optionalReagentIndex = self:FindOptionalReagentByItemID(itemID);
	local currentSlotInfo = self:FindOptionalReagent(slot);

	-- 1) If we're just moving this reagent to another empty slot or it is already in this slot, we can
	-- use the active optional reagent list as a preview.
	if info and (not currentSlotInfo or currentSlotInfo.itemID == itemID) then
		return optionalReagents, optionalReagentIndex;
	end

	-- We need to modify the table to preview the potential state, so make a copy to avoid changing the underlying data.
	optionalReagents = CopyTable(optionalReagents);

	-- 2) The reagent is already slotted, but it's moving to a non-empty slot.
	if info then
		-- Remove the existing reagent in the slot.
		for i, optionalReagent in ipairs(optionalReagents) do
			if optionalReagent.slot == slot then
				table.remove(optionalReagents, i);
				break;
			end
		end

		return optionalReagents, optionalReagentIndex;
	end

	-- 3) If this reagent isn't slotted, and there is an reagent in the slot, replace it.
	for i, optionalReagent in ipairs(optionalReagents) do
		if optionalReagent.slot == slot then
			optionalReagent.itemID = itemID;
			optionalReagent.count = 1;
			optionalReagentIndex = i;
			return optionalReagents, i;
		end
	end

	-- 4) If this reagent isn't slotted, and there's not an item in the slot, fill the slot with the item.
	table.insert(optionalReagents, { itemID = itemID, count = 1, slot = slot, });
	return optionalReagents, #optionalReagents;
end

function TradeSkillDetailsMixin:GetOptionalReagentBonusText(itemID, slot)
	local optionalReagents, optionalReagentIndex = self:GetOptionalReagentsPreview(itemID, slot);
	return C_TradeSkillUI.GetOptionalReagentBonusText(self.selectedRecipeID, optionalReagentIndex, optionalReagents);
end

function TradeSkillDetailsMixin:IsRecipeLearned()
	return self.recipeLearned;
end

function TradeSkillDetailsMixin:OnStarsMouseEnter(starsFrame)
	if (self.flashingStar) then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRADESKILL_RANK_STAR, true);
		self.flashingStar.FlashStar:Hide();
		self.flashingStar.Pulse:Stop();
	end
	GameTooltip:SetOwner(starsFrame, "ANCHOR_TOPLEFT");
	GameTooltip:SetRecipeRankInfo(self.selectedRecipeID, self.currentRank);
end

TradeSkillGuildListingMixin = {};

function TradeSkillGuildListingMixin:OnLoad()
	HybridScrollFrame_CreateButtons(self.Container.ScrollFrame, "TradeSkillGuildCrafterButtonTemplate", 0, 0);
	self.Container.ScrollFrame.update = function() self:Refresh() end;

	self:RegisterEvent("GUILD_RECIPE_KNOWN_BY_MEMBERS");
end

function TradeSkillGuildListingMixin:OnEvent(event, ...)
	if event == "GUILD_RECIPE_KNOWN_BY_MEMBERS" then
		if self:IsVisible() and self.waitingOnData then
			local skillLineID, recipeID, numMembers = GetGuildRecipeInfoPostQuery();
			if self.skillLineID == skillLineID and self.recipeID == recipeID then
				self.waitingOnData = false;
				self:Refresh();
			end
		end
	end
end

function TradeSkillGuildListingMixin:Clear()
	self.skillLineID = nil;
	self.recipeID = nil;
	self.waitingOnData = false;
	self:Hide();
end

function TradeSkillGuildListingMixin:ShowGuildRecipe(skillLineID, recipeID, recipeLevel)
	local updatedRecipeID = C_GuildInfo.QueryGuildMembersForRecipe(skillLineID, recipeID, recipeLevel);
	if not updatedRecipeID then
		return;
	else
		self.skillLineID = skillLineID;
		self.recipeID = updatedRecipeID;
		self.waitingOnData = true;
	end
	
	self:Refresh();

	self:Show();
end

function TradeSkillGuildListingMixin:Refresh()
	if self.waitingOnData then
		self.Container.Spinner:Show();

		for i, craftersButton in ipairs(self.Container.ScrollFrame.buttons) do
			craftersButton:Hide();
		end
		HybridScrollFrame_Update(self.Container.ScrollFrame, 0, 160);
	else
		self.Container.Spinner:Hide();

		local skillLineID, recipeID, numMembers = GetGuildRecipeInfoPostQuery();

		local offset = HybridScrollFrame_GetOffset(self.Container.ScrollFrame);

		for i, craftersButton in ipairs(self.Container.ScrollFrame.buttons) do
			local dataIndex = offset + i;
			if dataIndex > numMembers then
				craftersButton:Hide();
			else
				local displayName, fullName, classFileName, online = GetGuildRecipeMember(dataIndex);
				craftersButton:SetText(displayName);
				if online then
					craftersButton:Enable();
					craftersButton.fullName = fullName;
					if RAID_CLASS_COLORS[classFileName] then
						local classColor = RAID_CLASS_COLORS[classFileName];
						craftersButton.Text:SetTextColor(classColor.r, classColor.g, classColor.b);
					else
						craftersButton.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
				else
					craftersButton:Disable();
					craftersButton.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					craftersButton.fullName = nil;
				end
				craftersButton:Show();
			end
		end

		HybridScrollFrame_Update(self.Container.ScrollFrame, 16 * numMembers, 160);
	end
end


TradeSkillRecipeLevelBarMixin = {};

function TradeSkillRecipeLevelBarMixin:OnLoad()
	self.Rank:Hide();
	self:SetStatusBarColor(TRADESKILL_EXPERIENCE_COLOR:GetRGB());
end

function TradeSkillRecipeLevelBarMixin:OnEnter()
	self.Rank:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if self:IsMaxLevel() then
		GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, NORMAL_FONT_COLOR);
		GameTooltip_AddColoredLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK_EXPLANATION, GREEN_FONT_COLOR);
	else
		local experiencePercent = math.floor((self.currentExperience / self.maxExperience) * 100);
		GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_RANK_FORMAT:format(self.currentLevel), NORMAL_FONT_COLOR);
		GameTooltip_AddHighlightLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_EXPERIENCE_FORMAT:format(self.currentExperience, self.maxExperience, experiencePercent));
		GameTooltip_AddColoredLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_LEVELING_FORMAT:format(self.currentLevel + 1), GREEN_FONT_COLOR);
	end

	GameTooltip:Show();
end

function TradeSkillRecipeLevelBarMixin:OnLeave()
	self.Rank:Hide();

	GameTooltip_Hide();
end

function TradeSkillRecipeLevelBarMixin:SetExperience(currentExperience, maxExperience, currentLevel)
	self.currentExperience = currentExperience;
	self.maxExperience = maxExperience;
	self.currentLevel = currentLevel;

	if self:IsMaxLevel() then
		self:SetMinMaxValues(0, 1);
		self:SetValue(1);
		self.Rank:SetText(TRADESKILL_RECIPE_LEVEL_MAXIMUM);
	else
		self:SetMinMaxValues(0, maxExperience);
		self:SetValue(currentExperience);
		self.Rank:SetFormattedText(GENERIC_FRACTION_STRING, currentExperience, maxExperience);
	end
end

function TradeSkillRecipeLevelBarMixin:IsMaxLevel()
	return self.currentExperience == nil;
end


TradeSkillRecipeLevelSelectorMixin = {};

function TradeSkillRecipeLevelSelectorMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_TITLE);
	GameTooltip_AddNormalLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_INFO);
	GameTooltip:Show();
end

function TradeSkillRecipeLevelSelectorMixin:OnLeave()
	GameTooltip_Hide();
end

function TradeSkillRecipeLevelSelectorMixin:OnMouseDown()
	UIMenuButtonStretchMixin.OnMouseDown(self, button);
	ToggleDropDownMenu(1, nil, self:GetParent().RecipeLevelDropDown, self, 110, 15);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end
