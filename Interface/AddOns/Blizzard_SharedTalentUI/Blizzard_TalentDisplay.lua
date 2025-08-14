
-- Talent buttons are set up with 2 overlapping hierarchies to maximize reuse and reduce boilerplate.
--
-- The first hierarchy starts with TalentDisplayTemplate and covers the basic structure of the template:
-- textures, tooltip, etc. This does not include any dynamic states directly, such as availability
-- and purchased ranks. These can be set up through CalculateVisualState and ApplyVisualState. This also
-- doesn't not include any textures or fontstrings directly; those are covered by TalentButtonArtTemplate and
-- other visual templates. TalentDisplayTemplate can be used on its own for display purposes outside of the
-- usual usage directly on the talent frame (i.e. selection options).
--
-- The second hierarchy starts with TalentButtonBaseMixin which covers the basic structure of integration
-- into an actual talent frame with node information that includes some dynamic state. It is expected that
-- the actual behaviors of the buttons will be implemented by derived mixins like TalentButtonSpendMixin and
-- TalentButtonSelectMixin. These Mixins expect to be applied on top of a frame template that is derived
-- from TalentDisplayTemplate.


local SubTypeToColor = {
	[Enum.TraitDefinitionSubType.DragonflightRed] = DRAGONFLIGHT_RED_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBlue] = DRAGONFLIGHT_BLUE_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightGreen] = DRAGONFLIGHT_GREEN_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBronze] = DRAGONFLIGHT_BRONZE_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBlack] = DRAGONFLIGHT_BLACK_COLOR,
};


TalentDisplayMixin = CreateFromMixins(TalentDisplayAnimationStateControllerMixin);

function TalentDisplayMixin:OnEnter()
	local spellID = self:GetSpellID();
	local spell = (spellID ~= nil) and Spell:CreateFromSpellID(spellID) or nil;
	if spell and not spell:IsSpellEmpty() then
		self.spellLoadCancel = spell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.SetTooltipInternal, self));
	else
		self:SetTooltipInternal();
	end

	self:OnEnterVisuals();
end

function TalentDisplayMixin:OnLeave()
	GameTooltip_Hide();

	if self.updateMouseInfoTimer then
		self.updateMouseInfoTimer:Cancel();
		self.updateMouseInfoTimer = nil;
	end

	if self.spellLoadCancel then
		self.spellLoadCancel();
		self.spellLoadCancel = nil;
	end

	if self.overrideSpellLoadCancel then
		self.overrideSpellLoadCancel();
		self.overrideSpellLoadCancel = nil;
	end

	self:OnLeaveVisuals();
end

function TalentDisplayMixin:Init(talentFrame)
	self.talentFrame = talentFrame;

	self:InitAnimations(self.talentFrame:GetButtonAnimationStates());
end

function TalentDisplayMixin:SetLayoutIndex(layoutIndex)
	self.layoutIndex = layoutIndex;
end

function TalentDisplayMixin:OnRelease()
	--print("On release over here", self.previousTransmogSetID);
	-- We don't do a full reset for efficency. The next time the button is acquired it'll end up being updated.

	self.visualState = nil;
	self.spellLoadCancel = nil;
	self.matchType = nil;
	self.shouldGlow = nil;
	self.isGhosted = nil;

	if self.updateMouseInfoTimer then
		self.updateMouseInfoTimer:Cancel();
		self.updateMouseInfoTimer = nil;
	end

	self.layoutIndex = nil;

	self:ResetActiveVisuals();
end

function TalentDisplayMixin:ShouldShowTooltipInstructions()
	return not self:IsInspecting();
end

function TalentDisplayMixin:ShouldShowTooltipErrors()
	return not self:IsInspecting();
end

function TalentDisplayMixin:SetTooltipInternal(ignoreTooltipInfo)
	local tooltip = self:AcquireTooltip();
	self:AddTooltipTitle(tooltip);

	-- Used for debug purposes.
	EventRegistry:TriggerEvent("TalentDisplay.TooltipHook", self);

	if not ignoreTooltipInfo then
		self:AddTooltipInfo(tooltip);
	end
	self:AddTooltipDescription(tooltip, ignoreTooltipInfo);
	self:AddTooltipCost(tooltip);

	if self:ShouldShowTooltipInstructions() then
		self:AddTooltipInstructions(tooltip);
	end

	if self:ShouldShowTooltipErrors() then
		self:AddTooltipErrors(tooltip);
	end

	tooltip:Show();

	-- Used client issue submission tools
	EventRegistry:TriggerEvent("TalentDisplay.TooltipCreated", self, tooltip);
end

function TalentDisplayMixin:AcquireTooltip()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	if self.tooltipBackdropStyle then
		SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
	end
	return tooltip;
end

function TalentDisplayMixin:UpdateEntryContentIDs(skipUpdate)
	self.entrySubTreeID = self.entryInfo and self.entryInfo.subTreeID or nil;
	self.definitionID = self.entryInfo and self.entryInfo.definitionID or nil;
	self:UpdateEntryContentInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateEntryContentInfo(skipUpdate)
	self.definitionInfo = self.definitionID and self:GetTalentFrame():GetAndCacheDefinitionInfo(self.definitionID) or nil;
	self.entrySubTreeInfo = self.entrySubTreeID and self:GetTalentFrame():GetAndCacheSubTreeInfo(self.entrySubTreeID) or nil;

	if not skipUpdate then
		self:FullUpdate();
	end

	self:UpdateMouseOverInfo();
end

function TalentDisplayMixin:SetEntryID(entryID, skipUpdate)
	self.entryID = entryID;
	self:UpdateEntryInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateEntryInfo(skipUpdate)
	local hasEntryID = (self.entryID ~= nil);
	self.entryInfo = hasEntryID and self:GetTalentFrame():GetAndCacheEntryInfo(self.entryID) or nil;

	self:UpdateEntryContentIDs(skipUpdate);
end

function TalentDisplayMixin:GetDefinitionID()
	return self.definitionID;
end

function TalentDisplayMixin:GetEntryID()
	return self.entryID;
end

-- The active Entry's SubTree ID, usually only used by SubTree Choice Node entries
function TalentDisplayMixin:GetEntrySubTreeID()
	return self.entrySubTreeID;
end

function TalentDisplayMixin:GetDefinitionInfo()
	return self.definitionInfo;
end

function TalentDisplayMixin:GetEntryInfo()
	return self.entryInfo;
end

-- The active Entry's subTreeInfo, usually only used by SubTree Choice Node entries
function TalentDisplayMixin:GetEntrySubTreeInfo()
	return self.entrySubTreeInfo;
end

function TalentDisplayMixin:GetSpellID()
	return (self.definitionInfo ~= nil) and self.definitionInfo.spellID or nil;
end

function TalentDisplayMixin:GetOverriddenSpellID()
	return (self.definitionInfo ~= nil) and self.definitionInfo.overriddenSpellID or nil;
end

function TalentDisplayMixin:GetOverrideIcon()
	return (self.definitionInfo ~= nil) and self.definitionInfo.overrideIcon or nil;
end

function TalentDisplayMixin:CalculateIconTexture()
	return TalentButtonUtil.CalculateIconTextureFromInfo(self.definitionInfo, self.entrySubTreeInfo);
end

function TalentDisplayMixin:UpdateIconTexture()
	if not self.Icon then
		return;
	end

	local texture, isAtlas = self:CalculateIconTexture();
	if isAtlas then
		self.Icon:SetAtlas(texture);
	else
		self.Icon:SetTexture(texture);
	end
end

function TalentDisplayMixin:GetActiveIcon()
	if not self.Icon then
		return nil;
	end

	return self.Icon:GetTexture() or self.Icon:GetAtlas();
end

function TalentDisplayMixin:UpdateVisualState()
	self:SetVisualState(self:CalculateVisualState());
	self:UpdateMouseOverInfo();
end

function TalentDisplayMixin:FullUpdate()
	self:UpdateVisualState();
	self:UpdateIconTexture();
	self:UpdateNonStateVisuals();
end

function TalentDisplayMixin:SetVisualState(visualState)
	if self.visualState == visualState then
		return;
	end

	self.visualState = visualState;

	self:ApplyVisualState(visualState);

	-- Using Alpha for visible/invisible state rather than Hide/Show due to multiple things relying on nodes still technically being "shown"
	-- Ex: Receiving update events, animations staying in sync, etc
	local previousAlpha = self:GetAlpha();
	local newAlpha = (visualState ~= TalentButtonUtil.BaseVisualState.Invisible) and 1.0 or 0.0;
	if not ApproximatelyEqual(previousAlpha, newAlpha) then
		self:SetAlpha(newAlpha);
	end
end

function TalentDisplayMixin:GetVisualState()
	return self.visualState;
end

function TalentDisplayMixin:GetName()
	local subTreeInfo = self:GetEntrySubTreeInfo();
	if subTreeInfo and subTreeInfo.name then
		return subTreeInfo.name;
	end

	local definitionInfo = self:GetDefinitionInfo();
	if definitionInfo then
		return definitionInfo and TalentUtil.GetTalentName(definitionInfo.overrideName, self:GetSpellID()) or "";
	end

	return "";
end

function TalentDisplayMixin:GetSubtext()
	local subTreeInfo = self:GetEntrySubTreeInfo();
	if subTreeInfo and subTreeInfo.description then
		return subTreeInfo.description;
	end

	local definitionInfo = self:GetDefinitionInfo();
	return definitionInfo and TalentUtil.GetTalentSubtext(definitionInfo.overrideSubtext, self:GetSpellID()) or nil;
end

function TalentDisplayMixin:GetDescription()
	local definitionInfo = self:GetDefinitionInfo();
	return definitionInfo and TalentUtil.GetTalentDescription(definitionInfo.overrideDescription, self:GetSpellID()) or "";
end

function TalentDisplayMixin:AddTooltipTitle(tooltip)
	GameTooltip_SetTitle(tooltip, self:GetName());
end

function TalentDisplayMixin:AddTooltipInfo(tooltip)
	local spellID = self:GetSpellID();
	if spellID then
		local overrideSpellID = C_Spell.GetOverrideSpell(spellID);
		if overrideSpellID ~= spellID then
			local overrideSpell = Spell:CreateFromSpellID(overrideSpellID);
			if overrideSpell and not overrideSpell:IsSpellDataCached() then
				self.overrideSpellLoadCancel = overrideSpell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.SetTooltipInternal, self));
			elseif strcmputf8i(self:GetName(), overrideSpell:GetSpellName()) ~= 0 then
				GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_REPLACED_BY_FORMAT:format(overrideSpell:GetSpellName()), SPELL_LINK_COLOR);
			end
		end
	end
end

function TalentDisplayMixin:AddTooltipDescription(tooltip, tooltipInfoIgnored)
	local blankLineAdded = tooltipInfoIgnored or false;
	if self:ShouldShowSubText() then
		local talentSubtext = self:GetSubtext();
		if talentSubtext and (talentSubtext ~= "") then
			blankLineAdded = true;
			GameTooltip_AddBlankLineToTooltip(tooltip);

			local color = self.definitionInfo and self.definitionInfo.subType and SubTypeToColor[self.definitionInfo.subType];
			GameTooltip_AddColoredLine(tooltip, talentSubtext, color or DISABLED_FONT_COLOR);
		end
	end

	if self.nodeInfo then
		local activeEntry = self.nodeInfo.activeEntry;
		if activeEntry then
			if not blankLineAdded then
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			tooltip:AppendInfo("GetTraitEntry", activeEntry.entryID, activeEntry.rank);
		end

		local nextEntry = self.nodeInfo.nextEntry;
		if nextEntry and self.nodeInfo.ranksPurchased > 0 then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
			tooltip:AppendInfo("GetTraitEntry", nextEntry.entryID, nextEntry.rank);
		end
	elseif self.entryID then
		-- If this tooltip isn't coming from a node, we can't know what rank to show other than 1.
		local rank = 1;
		tooltip:AppendInfo("GetTraitEntry", self.entryID, rank);
	end
end

function TalentDisplayMixin:AddTooltipErrors(tooltip)
	local talentFrame = self:GetTalentFrame();

	local shouldAddSpacer = true;
	talentFrame:AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer);

	local isLocked, errorMessage = talentFrame:IsLocked();
	if isLocked and errorMessage then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, errorMessage);
	end
end

function TalentDisplayMixin:SetSearchMatchType(matchType)
	self.matchType = matchType;
	self:UpdateSearchIcon();
end

function TalentDisplayMixin:GetSearchMatchType()
	return self.matchType;
end

function TalentDisplayMixin:SetGlowing(shouldGlow)
	self.shouldGlow = shouldGlow;
	self:UpdateGlow();
end

function TalentDisplayMixin:GetTalentFrame()
	return self.talentFrame;
end

function TalentDisplayMixin:IsInspecting()
	return self:GetTalentFrame():IsInspecting();
end

function TalentDisplayMixin:UpdateMouseOverInfo()
	if self:IsMouseMotionFocus() then
		-- Multiple update steps can end up calling UpdateMouseOverInfo in the same frame, so ensure we only actually do it once at the end of all those updates
		if not self.updateMouseInfoTimer then
			self.updateMouseInfoTimer = C_Timer.NewTimer(0, function()
				self.updateMouseInfoTimer = nil;
				if self:IsMouseMotionFocus() then
					self:OnEnter();
				end
			end)
		end
	end
end

function TalentDisplayMixin:SetAndApplySize(width, height)
	-- Override in your derived mixin.
	self:SetSize(width, height);
end

function TalentDisplayMixin:CalculateVisualState()
	-- Implement in your derived mixin.
	return TalentButtonUtil.BaseVisualState.Normal;
end

function TalentDisplayMixin:ShouldShowSubText()
	return (self.definitionInfo and self.definitionInfo.subType and SubTypeToColor[self.definitionInfo.subType]) or (self.entrySubTreeInfo and self.entrySubTreeInfo.description and self.entrySubTreeInfo ~= "");
end

function TalentDisplayMixin:AddTooltipCost(tooltip)
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:AddTooltipInstructions(tooltip)
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:ApplyVisualState(visualState)
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:UpdateNonStateVisuals()
	-- Implement in your derived mixin.
	-- Should include updating visuals that are not dependent on the current VisualState.
end

function TalentDisplayMixin:ResetActiveVisuals()
	-- Implement in your derived mixin.
	-- Should include disabling active dynamic visuals like animations, FX, etc.
end

function TalentDisplayMixin:UpdateSearchIcon()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:UpdateGlow()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:OnEnterVisuals()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:OnLeaveVisuals()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:UpdateColorBlindVisuals(isColorBlindModeActive)
	-- Implement in your derived mixin.
end
