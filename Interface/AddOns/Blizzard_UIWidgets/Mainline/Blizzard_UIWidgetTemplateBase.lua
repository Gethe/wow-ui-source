UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:SetMouse(disableMouse)
	local useMouse = (self.tooltip and self.tooltip ~= "" and not disableMouse) or false;
	self:EnableMouse(useMouse);
	self:SetMouseClickEnabled(false);
end

function UIWidgetTemplateTooltipFrameMixin:OnLoad()
end

function UIWidgetTemplateTooltipFrameMixin:UpdateMouseEnabled()
	self:SetMouse(self.disableTooltip);
end

function UIWidgetTemplateTooltipFrameMixin:Setup(widgetContainer)
	self.disableTooltip = widgetContainer.disableWidgetTooltips;
	self:UpdateMouseEnabled();
	self:SetMouseClickEnabled(false);
	self:SetTooltipLocation(nil);

	if self.mouseOver then
		self:OnEnter();
	end
end

function UIWidgetTemplateTooltipFrameMixin:SetTooltip(tooltip, color)
	self.tooltip = tooltip;
	self.tooltipContainsHyperLink = false;
	self.preString = nil;
	self.hyperLinkString = nil;
	self.postString = nil;
	self.tooltipColor = color;

	if tooltip then
		self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(tooltip);
	end
	self:UpdateMouseEnabled();
end

local tooltipLocToAnchor = {
	[Enum.UIWidgetTooltipLocation.BottomLeft]	= "ANCHOR_BOTTOMLEFT",
	[Enum.UIWidgetTooltipLocation.Left]			= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.TopLeft]		= "ANCHOR_LEFT",
	[Enum.UIWidgetTooltipLocation.Top]			= "ANCHOR_TOP",
	[Enum.UIWidgetTooltipLocation.TopRight]		= "ANCHOR_RIGHT",
	[Enum.UIWidgetTooltipLocation.Right]		= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.BottomRight]	= "ANCHOR_BOTTOMRIGHT",
	[Enum.UIWidgetTooltipLocation.Bottom]		= "ANCHOR_BOTTOM",
};

function UIWidgetTemplateTooltipFrameMixin:SetTooltipLocation(tooltipLoc)
	self.tooltipLoc = tooltipLoc;
	self.tooltipAnchor = tooltipLocToAnchor[tooltipLoc] or self.defaultTooltipAnchor;
end

function UIWidgetTemplateTooltipFrameMixin:SetTooltipOwner()
	if self.tooltipAnchor == "ANCHOR_NONE" then
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor);
		EmbeddedItemTooltip:ClearAllPoints();
		if self.tooltipLoc == Enum.UIWidgetTooltipLocation.Left then
			EmbeddedItemTooltip:SetPoint("RIGHT", self, "LEFT", self.tooltipXOffset, self.tooltipYOffset);
		elseif self.tooltipLoc == Enum.UIWidgetTooltipLocation.Right then
			EmbeddedItemTooltip:SetPoint("LEFT", self, "RIGHT", self.tooltipXOffset, self.tooltipYOffset);
		end
	else
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	if self.tooltip and self.tooltip ~= "" then
		self:SetTooltipOwner();

		if self.tooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(EmbeddedItemTooltip, self.tooltipBackdropStyle);
		end

		if self.tooltipContainsHyperLink then
			local clearTooltip = true;
			if self.preString and self.preString:len() > 0 then
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, self.preString, true);
				clearTooltip = false;
			end

			GameTooltip_ShowHyperlink(EmbeddedItemTooltip, self.hyperLinkString, 0, 0, clearTooltip);

			if self.postString and self.postString:len() > 0 then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true);
			end

			self.UpdateTooltip = self.OnEnter;

			EmbeddedItemTooltip:Show();
		else
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip);
			if header then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			if nonHeader then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end

			self.UpdateTooltip = nil;

			EmbeddedItemTooltip:SetShown(header ~= nil);
		end
	end
	self.mouseOver = true;
end

function UIWidgetTemplateTooltipFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.mouseOver = false;
	self.UpdateTooltip = nil;
end

local function GetTextColorForEnabledState(enabledState, overrideNormalFontColor)
	if enabledState == Enum.WidgetEnabledState.Disabled then
		return DISABLED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Red then
		return RED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.White then
		return HIGHLIGHT_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Green then
		return GREEN_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Artifact then
		return ARTIFACT_GOLD_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Black then
		return BLACK_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.BrightBlue then
		return BRIGHTBLUE_FONT_COLOR;
	else
		return overrideNormalFontColor or NORMAL_FONT_COLOR;
	end
end

UIWidgetBaseEnabledFrameMixin = {}

function UIWidgetBaseEnabledFrameMixin:SetOverrideNormalFontColor(overrideNormalFontColor)
	self.overrideNormalFontColor = overrideNormalFontColor;
	self:UpdateFontColors();
end

function UIWidgetBaseEnabledFrameMixin:ClearOverrideNormalFontColor()
	self.overrideNormalFontColor = nil;
	self:UpdateFontColors();
end

function UIWidgetBaseEnabledFrameMixin:UpdateFontColors()
	if self.SetTextColor then
		self:SetTextColor(GetTextColorForEnabledState(self.enabledState, self.overrideNormalFontColor):GetRGB());
	end

	if self.ColoredStrings then
		for _, fontString in ipairs(self.ColoredStrings) do
			fontString:SetTextColor(GetTextColorForEnabledState(self.enabledState, self.overrideNormalFontColor):GetRGB());
		end
	end
end

function UIWidgetBaseEnabledFrameMixin:SetEnabledState(enabledState)
	self.enabledState = enabledState;
	self:UpdateFontColors();
end

UIWidgetBaseTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseTemplateMixin:ShouldApplyEffectsToSubFrames()
	return false;
end

function UIWidgetBaseTemplateMixin:ClearEffects()
	local frames = {self:GetChildren()};
	table.insert(frames, self);
	for _, frame in ipairs(frames) do
		if frame.effectController then
			frame.effectController:CancelEffect();
			frame.effectController = nil;
		end
	end
end

function UIWidgetBaseTemplateMixin:ApplyEffectToFrame(widgetInfo, widgetContainer, frame)
	if frame.effectController then
		frame.effectController:CancelEffect();
		frame.effectController = nil;
	end
	if widgetInfo.scriptedAnimationEffectID and widgetInfo.modelSceneLayer ~= Enum.UIWidgetModelSceneLayer.None then
		if widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Front then
			frame.effectController = widgetContainer.FrontModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		elseif widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Back then
			frame.effectController = widgetContainer.BackModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		end
	end
end

function UIWidgetBaseTemplateMixin:ApplyEffects(widgetInfo)
	local applyFrames = self:ShouldApplyEffectsToSubFrames() and {self:GetChildren()} or {self};
	for _, frame in ipairs(applyFrames) do
		self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, frame);
	end
end

function UIWidgetBaseTemplateMixin:OnLoad()
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
end

function UIWidgetBaseTemplateMixin:GetWidgetWidth()
	return self:GetWidth() * self:GetScale();
end

function UIWidgetBaseTemplateMixin:GetWidgetHeight()
	return self:GetHeight() * self:GetScale();
end

function UIWidgetBaseTemplateMixin:InAnimFinished()
end

function UIWidgetBaseTemplateMixin:OutAnimFinished()
	self.widgetContainer:RemoveWidget(self.widgetID);
end

function UIWidgetBaseTemplateMixin:GetInAnim()
	if self.inAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeInAnim;
	end
end

function UIWidgetBaseTemplateMixin:GetOutAnim()
	if self.outAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeOutAnim;
	end
end

function UIWidgetBaseTemplateMixin:ResetAnimState()
	self.FadeInAnim:Stop();
	self.FadeOutAnim:Stop();
	self:SetAlpha(1);
end

function UIWidgetBaseTemplateMixin:AnimIn()
	if not self:IsShown() then
		self:ResetAnimState();

		self:Show();

		local inAnim = self:GetInAnim();
		if inAnim then
			inAnim:Play();
		else
			self:InAnimFinished();
		end
	end
end

-- Animates the widget out. Once that is done the widget is removed from the widget container and actually released
function UIWidgetBaseTemplateMixin:AnimOut()
	if self:IsShown() then
		self:ResetAnimState();

		local outAnim = self:GetOutAnim();
		if outAnim then
			outAnim:Play();
		else
			self:OutAnimFinished();
		end
	end
end

local widgetScales =
{
	[Enum.UIWidgetScale.OneHundred]	= 1,
	[Enum.UIWidgetScale.Ninty] = 0.9,
	[Enum.UIWidgetScale.Eighty] = 0.8,
	[Enum.UIWidgetScale.Seventy] = 0.7,
	[Enum.UIWidgetScale.Sixty] = 0.6,
	[Enum.UIWidgetScale.Fifty] = 0.5,
	[Enum.UIWidgetScale.OneHundredTen] = 1.1,
	[Enum.UIWidgetScale.OneHundredTwenty] = 1.2,
	[Enum.UIWidgetScale.OneHundredThirty] = 1.3,
	[Enum.UIWidgetScale.OneHundredForty] = 1.4,
	[Enum.UIWidgetScale.OneHundredFifty] = 1.5,
	[Enum.UIWidgetScale.OneHundredSixty] = 1.6,
	[Enum.UIWidgetScale.OneHundredSeventy] = 1.7,
	[Enum.UIWidgetScale.OneHundredEighty] = 1.8,
	[Enum.UIWidgetScale.OneHundredNinety] = 1.9,
	[Enum.UIWidgetScale.TwoHundred] = 2,
}

local function GetWidgetScale(widgetScale)
	return widgetScales[widgetScale] and widgetScales[widgetScale] or widgetScales[Enum.UIWidgetScale.OneHundred];
end

-- Override with any custom behaviour that you need to perform when this widget is updated. Make sure you still call the base though because it handles animations
function UIWidgetBaseTemplateMixin:Setup(widgetInfo, widgetContainer)
	self:SetScale(GetWidgetScale(widgetInfo.widgetScale));
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self:SetTooltipLocation(widgetInfo.tooltipLoc);
	self.widgetContainer = widgetContainer;
	self.orderIndex = widgetInfo.orderIndex;
	self.layoutDirection = widgetInfo.layoutDirection;
	self:AnimIn();
end

-- Override with any custom behaviour that you need to perform when this widget is destroyed (e.g. release pools)
function UIWidgetBaseTemplateMixin:OnReset()
	self:Hide();
	self:ClearAllPoints();
	self:ClearEffects();
end

UIWidgetBaseResourceTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

function UIWidgetBaseResourceTemplateMixin:Setup(widgetContainer, resourceInfo)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.Text:SetText(resourceInfo.text);

	self:SetTooltip(resourceInfo.tooltip);
	self.Icon:SetTexture(resourceInfo.iconFileID);

	self:SetWidth(self.Icon:GetWidth() + self.Text:GetWidth() + 2);
	self:SetHeight(self.Icon:GetHeight());
end

UIWidgetBaseCurrencyTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

function UIWidgetBaseCurrencyTemplateMixin:Setup(widgetContainer, currencyInfo, enabledState, tooltipEnabledState, hideIcon, customFont, overrideFontColor)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self:SetOverrideNormalFontColor(overrideFontColor);

	local function SetUpFontString(fontString, text)
		if customFont then
			fontString:SetText(text);
			fontString:SetFontObject(customFont);
		else
			local hAlignType = Enum.WidgetTextHorizontalAlignmentType.Left;
			fontString:Setup(text, currencyInfo.textFontType, currencyInfo.textSizeType, enabledState, hAlignType);
		end
	end

	SetUpFontString(self.Text, currencyInfo.text);

	self:SetTooltip(currencyInfo.tooltip, GetTextColorForEnabledState(tooltipEnabledState or enabledState));
	self.Icon:SetTexture(currencyInfo.iconFileID);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	self:SetEnabledState(enabledState);

	local totalWidth = self.Icon:GetWidth() + self.Text:GetWidth() + 5;

	if currencyInfo.leadingText ~= "" then
		SetUpFontString(self.LeadingText, currencyInfo.leadingText);

		self.LeadingText:Show();
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", self.LeadingText:GetWidth() + 5, 0);
		totalWidth = totalWidth + self.LeadingText:GetWidth() + 5;
	else
		self.LeadingText:Hide();
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	end

	if hideIcon then
		self.Icon:Hide();
		self.Text:SetPoint("LEFT", self.Icon, "LEFT", 0, 0);
	else
		self.Icon:Show();
		self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 5, 0);
	end

	self:SetWidth(totalWidth);
	self:SetHeight(self.Icon:GetHeight());
end

local iconSizes =
{
	[Enum.WidgetIconSizeType.Small]	= 24,
	[Enum.WidgetIconSizeType.Medium] = 30,
	[Enum.WidgetIconSizeType.Large]	= 36,
	[Enum.WidgetIconSizeType.Standard] = 28,
}

local function GetWidgetIconSize(iconSizeType)
	return iconSizes[iconSizeType];
end

UIWidgetBaseSpellTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

local spellTextureKitRegionInfo = {
	["Border"] = {formatString = "%s-frame", setVisibility = true, useAtlasSize = true},
	["AmountBorder"] = {formatString = "%s-amount", setVisibility = true, useAtlasSize = true},
}

local spellBorderColorFromTintValue = {
	[Enum.SpellDisplayBorderColor.Black] = BLACK_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.White] = WHITE_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.Red] = RED_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.Yellow] = YELLOW_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.Orange] = ORANGE_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.Purple] = EPIC_PURPLE_COLOR,
	[Enum.SpellDisplayBorderColor.Green] = GREEN_FONT_COLOR,
	[Enum.SpellDisplayBorderColor.Blue] = RARE_BLUE_COLOR,
}

local spellBorderFromColorValue = { 
	[Enum.SpellDisplayBorderColor.White] = "wowlabs-in-world-item-common",
	[Enum.SpellDisplayBorderColor.Orange] = "wowlabs-in-world-item-legendary",
	[Enum.SpellDisplayBorderColor.Purple] = "wowlabs-in-world-item-epic",
	[Enum.SpellDisplayBorderColor.Green] = "wowlabs-in-world-item-uncommon",
	[Enum.SpellDisplayBorderColor.Blue] = "wowlabs-in-world-item-rare",
}

local worldLootObjectTypeIconMap = {
	[Enum.InventoryType.IndexEquipablespellOffensiveType] = "plunderstorm-icon-offensive",
	[Enum.InventoryType.IndexEquipablespellUtilityType] = "plunderstorm-icon-utility",
	[Enum.InventoryType.IndexNonEquipType] = "plunderstorm-icon-item",
};

local function GetWorldLootObjectTypeAtlas(worldLootobjectInfo)
	if worldLootobjectInfo.atMaxQuality then
		return "plunderstorm-icon-fullyupgraded";
	elseif worldLootobjectInfo.isUpgrade then
		return "plunderstorm-icon-upgrade";
	else
		return worldLootObjectTypeIconMap[worldLootobjectInfo.inventoryType];
	end
end

function UIWidgetBaseSpellTemplateMixin:OnEvent(event, ...)
	if event == "WORLD_LOOT_OBJECT_INFO_UPDATED" then
		self:UpdateTypeIcon();
	elseif event == "PLAYER_EQUIPED_SPELLS_CHANGED" then
		-- We know the info will be updated but the exact timing is not predictable.
		self.updateTimeRemaining = 1;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

-- Registered dynamically.
function UIWidgetBaseSpellTemplateMixin:OnUpdate(dt)
	-- This needs to be explicit and not use ShouldContinueOnUpdate to allow proper overrides.
	if self.updateTimeRemaining and (self.updateTimeRemaining >= 0) then
		self.updateTimeRemaining = self.updateTimeRemaining - dt;
		self:UpdateTypeIcon();
	end

	if not self:ShouldContinueOnUpdate() then
		self:SetScript("OnUpdate", nil);
	end
end

function UIWidgetBaseSpellTemplateMixin:ShouldContinueOnUpdate()
	return self.updateTimeRemaining and (self.updateTimeRemaining > 0);
end

function UIWidgetBaseSpellTemplateMixin:Setup(widgetContainer, spellInfo, enabledState, width, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	SetupTextureKitsFromRegionInfo(textureKit, self, spellTextureKitRegionInfo);
	local hasAmountBorderTexture = self.AmountBorder:IsShown();
	local hasBorderTexture = self.Border:IsShown();

	self.StackCount:ClearAllPoints();
	if hasAmountBorderTexture then
		self.StackCount:SetPoint("CENTER", self.AmountBorder);
	else
		self.StackCount:SetPoint("BOTTOMRIGHT", self.Icon, -2, 2);
	end

	local spellData = C_Spell.GetSpellInfo(spellInfo.spellID);
	self.Icon:SetTexture(spellData.iconID);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	local iconSize = GetWidgetIconSize(spellInfo.iconSizeType);
	self.Icon:SetSize(iconSize, iconSize);

	self.Border:ClearAllPoints(); 
	self.Border:SetPoint("TOPLEFT", self.Icon, 0, 0); 
	self.Border:SetPoint("BOTTOMRIGHT", self.Icon, 0, 0); 

	self:UpdateTypeIcon();

	local isBuff = spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Buff; 
	if spellInfo.borderColor ~= Enum.SpellDisplayBorderColor.None then
		local parent = self:GetParent();
		local attachedUnit = parent and parent.attachedUnit;
		if attachedUnit and isBuff and C_WorldLootObject.IsWorldLootObject(attachedUnit) and spellBorderFromColorValue[spellInfo.borderColor] then
			local borderTexture = spellBorderFromColorValue[spellInfo.borderColor];
			local offsetX = 4; 
			local offsetY = 4; 
			self.Border:SetAtlas(borderTexture, true);
			self.Border:SetPoint("TOPLEFT", self.Icon, -offsetX, offsetY); 
			self.Border:SetPoint("BOTTOMRIGHT", self.Icon, offsetX, -offsetY); 
			hasBorderTexture = true; 
		else
			if not hasBorderTexture then
				if isBuff then
					self.Border:SetAtlas("dressingroom-itemborder-small-white", false);
					hasBorderTexture = true;
				elseif spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Circular then
					local offsetX, offsetY = 0, 0; 
					if(textureKit == "itembelt-frame") then
						offsetX = 4; 
						offsetY = 4; 
					end 

					self.Border:SetAtlas(textureKit or "Artifacts-PerkRing-Final", false);
					self.Border:ClearAllPoints(); 
					self.Border:SetPoint("TOPLEFT", self.Icon, -offsetX, offsetY); 
					self.Border:SetPoint("BOTTOMRIGHT", self.Icon, offsetX, -offsetY); 
					hasBorderTexture = true;
				end
			end
		end
	end

	if not hasBorderTexture then
		self.Border:SetAtlas("UI-Frame-IconBorder", false);
	end

	local iconWidth = self.Icon:GetWidth();
	local textWidth = 0;
	if width > iconWidth then
		textWidth = width - iconWidth;
	end

	self.Text:SetWidth(textWidth);
	self.Text:SetHeight(0);

	local textShown = ( spellInfo.textShownState == Enum.SpellDisplayTextShownStateType.Shown );
	self.Text:SetShown(textShown);

	if textShown then
		local text = (spellInfo.text == "") and spellData.name or spellInfo.text;
		self.Text:Setup(text, spellInfo.textFontType, spellInfo.textSizeType, enabledState, spellInfo.hAlignType);

		if textWidth == 0 then
			textWidth = self.Text:GetWidth();
		end
		iconWidth = iconWidth + 5;

		if self.Text:GetHeight() < self.Icon:GetHeight() then
			self.Text:SetHeight(self.Icon:GetHeight());
		end
	end

	if spellInfo.stackDisplay > 0 then
		self.StackCount:Show();
		self.StackCount:SetText(spellInfo.stackDisplay);
	else
		self.StackCount:Hide();
		self.AmountBorder:Hide();
	end

	local showBorder = (spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Buff) or ((spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Circular) and hasBorderTexture);

	if spellInfo.tint ~= Enum.SpellDisplayTint.None then
		if spellInfo.tint == Enum.SpellDisplayTint.Red then
			self.Icon:SetVertexColor(1, 0, 0);
			if showBorder then
				self.Border:SetVertexColor(1, 0, 0);
			end
		end
	else
		local color = spellBorderColorFromTintValue[spellInfo.borderColor];
		self.Icon:SetVertexColor(1, 1, 1);
		if showBorder and color then
			self.Border:SetVertexColor(color:GetRGB());
		elseif showBorder and not color then
			self.Border:SetVertexColor(1, 1, 1);
		end
	end

	self.Border:SetShown(showBorder);
	self.DebuffBorder:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Debuff);
	self.IconMask:SetShown(spellInfo.iconDisplayType ~= Enum.SpellDisplayIconDisplayType.Circular);
	self.CircleMask:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Circular);

	local widgetHeight = math.max(self.Icon:GetHeight(), self.Text:GetHeight());
	self:SetEnabledState(enabledState);
	self.spellID = spellInfo.spellID;
	self:SetTooltip(spellInfo.tooltip);

	self:SetWidth(math.max(iconWidth + textWidth, 1));
	self:SetHeight(math.max(widgetHeight, 1));
end

function UIWidgetBaseSpellTemplateMixin:UpdateTypeIcon()
	if self.TypeIcon then
		self.TypeIcon:Hide();
	end

	local parent = self:GetParent();
	local attachedUnit = parent and parent.attachedUnit;
	local isWorldLootObject = attachedUnit and C_WorldLootObject.IsWorldLootObject(attachedUnit);
	local worldLootObjectInfo = attachedUnit and C_WorldLootObject.GetWorldLootObjectInfo(attachedUnit);
	if isWorldLootObject and worldLootObjectInfo then
		self:RegisterEvent("WORLD_LOOT_OBJECT_INFO_UPDATED");

		-- If this is an equippable spell we need to update when inventory changes.
		if worldLootObjectInfo.inventoryType ~= Enum.InventoryType.IndexNonEquipType then
			self:RegisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
		else
			self:UnregisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
		end

		local iconAtlas = GetWorldLootObjectTypeAtlas(worldLootObjectInfo);
		if iconAtlas then
			self.TypeIcon = self:CreateTexture(nil, "OVERLAY");
			self.TypeIcon:SetDrawLayer("OVERLAY", 3);
			self.TypeIcon:SetPoint("CENTER", self, "TOPLEFT", 5, -5);
			self.TypeIcon:SetAtlas(iconAtlas, TextureKitConstants.UseAtlasSize);
			self.TypeIcon:SetScale(.5);
		end

		self:DesaturateHierarchy(worldLootObjectInfo.atMaxQuality and 1 or 0);
	else
		self:UnregisterEvent("WORLD_LOOT_OBJECT_INFO_UPDATED");
		self:UnregisterEvent("PLAYER_EQUIPED_SPELLS_CHANGED");
	end
end

function UIWidgetBaseSpellTemplateMixin:OnEnter()
	local parent = self:GetParent(); 
	local shouldUseSpellOrLootObjectTooltip = not self.tooltip or self.tooltip == "";
	if shouldUseSpellOrLootObjectTooltip then 
		local attachedUnit = parent and parent.attachedUnit;
		local displayingWorldLootObjectTooltip = false;

		if attachedUnit then
			self:SetTooltipOwner();
			displayingWorldLootObjectTooltip = EmbeddedItemTooltip:SetWorldLootObject(attachedUnit);
		end

		-- If the tooltip does not successfully set the loot object, set it by spell id
		if not displayingWorldLootObjectTooltip then
			-- MUST have SetTooltipOwner above both calls because if SetWorldLootObject is called & fails, the previously set owner will be cleared
			self:SetTooltipOwner();
			EmbeddedItemTooltip:SetSpellByID(self.spellID, false, true);
		end

		EmbeddedItemTooltip:Show();
	else
		UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	end
end

function UIWidgetBaseSpellTemplateMixin:SetMouse(disableMouse)
	local useMouse = ((self.tooltip and self.tooltip ~= "") or self.spellID) and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

UIWidgetBaseStatusBarPartitionTemplateMixin = {};

local partitionTextureKitString = "%s-BorderTick";
local partitionFullTextureKitString = "%s-BorderTick-Full";
local partitionFlashTextureKitString = "%s-BorderTick-Flash";

function UIWidgetBaseStatusBarPartitionTemplateMixin:Setup(partitionValue, textureKit)
	self.value = partitionValue;
	self.textureKit = textureKit;
	self.emptyAtlasName = partitionTextureKitString:format(textureKit);
	self.fullAtlasName = partitionFullTextureKitString:format(textureKit);
	self.hasFullAtlas = (C_Texture.GetAtlasInfo(self.fullAtlasName) ~= nil);

	local flashAtlasName = partitionFlashTextureKitString:format(textureKit);
	local useAtlasSize = true;
	local setVisibility = true;
	self.FlashOverlay:SetAtlas(flashAtlasName, useAtlasSize, setVisibility);
end

function UIWidgetBaseStatusBarPartitionTemplateMixin:UpdateForBarValue(barValue)
	local useAtlasSize = true;

	if not self.hasFullAtlas or barValue < self.value then
		self.Tex:SetAtlas(self.emptyAtlasName, useAtlasSize);

		if self.wasFull then
			self.FlashAnim:Stop();
			self.FlashOverlay:SetAlpha(0);
		end

		self.wasFull = false;
	else
		self.Tex:SetAtlas(self.fullAtlasName, useAtlasSize);

		if self.wasFull == false then
			self.FlashAnim:Play();
		end

		self.wasFull = true;
	end

	self:SetSize(self.Tex:GetWidth(), self.Tex:GetHeight());
end

UIWidgetBaseStatusBarTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseStatusBarTemplateMixin:SanitizeAndSetStatusBarValues(barInfo)
	self.value = barInfo.barValue;
	self.barMin = barInfo.barMin;
	self.barMax = barInfo.barMax;

	if self.barMin > 0 and self.barMin == self.barMax and self.value == self.barMax then
		-- If all 3 values are the same and greater than 0, show the bar as full
		self.barMin, self.barMax, self.value = 0, 1, 1;
	end

	self.value = Clamp(self.value, self.barMin, self.barMax);
	self.range = barInfo.barMax - barInfo.barMin;
end

local widgetOpacityPercentage =
{
	[Enum.WidgetOpacityType.OneHundred]	= 1,
	[Enum.WidgetOpacityType.Ninety]		= 0.9,
	[Enum.WidgetOpacityType.Eighty]		= 0.8,
	[Enum.WidgetOpacityType.Seventy]	= 0.7,
	[Enum.WidgetOpacityType.Sixty]		= 0.6,
	[Enum.WidgetOpacityType.Fifty]		= 0.5,
	[Enum.WidgetOpacityType.Forty]		= 0.4,
	[Enum.WidgetOpacityType.Thirty]		= 0.3,
	[Enum.WidgetOpacityType.Twenty]		= 0.2,
	[Enum.WidgetOpacityType.Ten]		= 0.1,
	[Enum.WidgetOpacityType.Zero]		= 0,
};

local function GetWidgetOpacityPercentage(widgetOpacityType)
	return widgetOpacityType and widgetOpacityPercentage[widgetOpacityType] or 1;
end

function UIWidgetBaseStatusBarTemplateMixin:Setup(widgetContainer, barInfo)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	self:SanitizeAndSetStatusBarValues(barInfo);
	self:SetMinMaxValues(self.barMin, self.barMax);
	self:InitPartitions(barInfo.partitionValues, barInfo.frameTextureKit);

	self.barValueTextType = barInfo.barValueTextType;
	self.barTextEnabledState = barInfo.barTextEnabledState;
	self.barTextFontType = barInfo.barTextFontType;
	self.barTextSizeType = barInfo.barTextSizeType;
	self.barTextHasStyleSettings = self.barTextEnabledState and self.barTextFontType and self.barTextSizeType;

	self.barMinFillAlpha = GetWidgetOpacityPercentage(barInfo.fillMinOpacity);
	self.barMaxFillAlpha = GetWidgetOpacityPercentage(barInfo.fillMaxOpacity);

	self.overrideBarText = barInfo.overrideBarText;
	self.overrideBarTextShownType = barInfo.overrideBarTextShownType;

	self:SetTooltip(barInfo.tooltip);

	self.Label:SetShown(barInfo.barValueTextType ~= Enum.StatusBarValueTextType.Hidden);

	local fillMotionType = barInfo.fillMotionType or Enum.UIWidgetMotionType.Instant;
	if (fillMotionType == Enum.UIWidgetMotionType.Instant) or not self.displayedValue then
		self.displayedValue = self.value;
		self:DisplayBarValue();
		self:SetScript("OnUpdate", nil);
	else
		self:SetScript("OnUpdate", self.UpdateBar);
	end
end

function UIWidgetBaseStatusBarTemplateMixin:UpdateBar(elapsed)
	if self.value ~= self.displayedValue then
		self.displayedValue = GetSmoothProgressChange(self.value, self.displayedValue, self.range, elapsed);
	end

	self:DisplayBarValue();

	if self.value == self.displayedValue then
		self:SetScript("OnUpdate", nil);
	end
end

function UIWidgetBaseStatusBarTemplateMixin:DisplayBarValue()
	self:SetValue(self.displayedValue);
	self:SetBarText(math.ceil(self.displayedValue));
	self:UpdatePartitions(self.displayedValue);

	if self.Spark then
		local showSpark = self.displayedValue > self.barMin and self.displayedValue < self.barMax;
		self.Spark:SetShown(showSpark);
	end

	local statusBarTexture = self:GetStatusBarTexture();
	if statusBarTexture then
	local currentAlpha = Lerp(self.barMinFillAlpha, self.barMaxFillAlpha, ClampedPercentageBetween(self.displayedValue, self.barMin, self.barMax));
		statusBarTexture:SetAlpha(currentAlpha);
	end
end

function UIWidgetBaseStatusBarTemplateMixin:SetBarText(barValue)
	local maxTimeCount = self:GetMaxTimeCount();

	if maxTimeCount then
		self.barText = SecondsToTime(barValue, false, true, maxTimeCount, true);
	elseif self.barValueTextType == Enum.StatusBarValueTextType.Value then
		self.barText = barValue;
	elseif self.barValueTextType == Enum.StatusBarValueTextType.ValueOverMax then
		self.barText = FormatFraction(barValue, self.barMax);
	elseif self.barValueTextType == Enum.StatusBarValueTextType.ValueOverMaxNormalized then
		self.barText = FormatFraction(barValue - self.barMin, self.barMax - self.barMin);
	elseif self.barValueTextType == Enum.StatusBarValueTextType.Percentage then
		local barPercent = PercentageBetween(barValue, self.barMin, self.barMax);
		self.barText = FormatPercentage(barPercent, true);
	else
		self.barText = "";
	end

	self:UpdateLabel();
end

function UIWidgetBaseStatusBarTemplateMixin:GetMaxTimeCount()
	if self.barValueTextType == Enum.StatusBarValueTextType.Time then
		return 2;
	elseif self.barValueTextType == Enum.StatusBarValueTextType.TimeShowOneLevelOnly then
		return 1;
	end
end

function UIWidgetBaseStatusBarTemplateMixin:OnEnter()
	UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	self:UpdateLabel();
end

function UIWidgetBaseStatusBarTemplateMixin:OnLeave()
	UIWidgetTemplateTooltipFrameMixin.OnLeave(self);
	self:UpdateLabel();
end

function UIWidgetBaseStatusBarTemplateMixin:UpdateLabel()
	local showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.Always);
	if not showOverrideBarText then
		if self.mouseOver then
			showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.OnlyOnMouseover);
		else
			showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.OnlyNotOnMouseover);
		end
	end

	local shownText = showOverrideBarText and self.overrideBarText or self.barText;

	if self.barTextHasStyleSettings then
		self.Label:Setup(shownText, self.barTextFontType, self.barTextSizeType, self.barTextEnabledState);
	else
		self.Label:SetText(shownText);
	end
end

function UIWidgetBaseStatusBarTemplateMixin:SetMouse(disableMouse)
	local useMouse = (((self.tooltip and self.tooltip ~= "") or (self.overrideBarText and self.overrideBarText ~= "") or (self.barText and self.barText ~= "")) and not disableMouse) or false;
	self:EnableMouse(useMouse);
	self:SetMouseClickEnabled(false);
end

function UIWidgetBaseStatusBarTemplateMixin:InitPartitions(partitionValues, textureKit)
	if self.partitionPool then
		self.partitionPool:ReleaseAll();
	elseif partitionValues then
		self.partitionPool = CreateFramePool("Frame", self, "UIWidgetBaseStatusBarPartitionTemplate");
	end

	if not partitionValues or (#partitionValues == 0) then
		return;
	end

	local paritionAtlasName = partitionTextureKitString:format(textureKit);
	local partitionAtlasInfo =  C_Texture.GetAtlasInfo(paritionAtlasName);

	if not partitionAtlasInfo then
		return;
	end

	local barWidth = self:GetWidth();

	for _, partitionValue in ipairs(partitionValues) do
		partitionValue = Clamp(partitionValue, self.barMin, self.barMax);

		local partitionFrame = self.partitionPool:Acquire();
		partitionFrame:Setup(partitionValue, textureKit);

		local partitionPercent = ClampedPercentageBetween(partitionValue, self.barMin, self.barMax);
		local xOffset = barWidth * partitionPercent;

		partitionFrame:SetPoint("CENTER", self:GetStatusBarTexture(), "LEFT", xOffset, 0);
		partitionFrame:Show();
	end
end

function UIWidgetBaseStatusBarTemplateMixin:UpdatePartitions(barValue)
	if self.partitionPool then
		for partitionFrame in self.partitionPool:EnumerateActive() do
			partitionFrame:UpdateForBarValue(barValue);
		end
	end
end

function UIWidgetBaseStatusBarTemplateMixin:OnReset()
	if self.partitionPool then
		self.partitionPool:ReleaseAll();
	end

	self.displayedValue = nil;
end

UIWidgetBaseStateIconTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseStateIconTemplateMixin:Setup(widgetContainer, textureKit, textureKitFormatter, captureIconInfo)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	if captureIconInfo.iconState == Enum.IconState.ShowState1 then
		SetupTextureKitOnFrame(textureKit, self.Icon, "%s-"..textureKitFormatter.."-state1", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		self:SetTooltip(captureIconInfo.state1Tooltip);
	elseif captureIconInfo.iconState == Enum.IconState.ShowState2 then
		SetupTextureKitOnFrame(textureKit, self.Icon, "%s-"..textureKitFormatter.."-state2", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		self:SetTooltip(captureIconInfo.state2Tooltip);
	else
		self.Icon:Hide();
	end

	local iconShown = self.Icon:IsShown();

	self:SetWidth(self.Icon:GetWidth());
	self:SetHeight(self.Icon:GetHeight());

	self:SetShown(iconShown);
	return iconShown;
end

UIWidgetBaseTextureAndTextTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local textFontSizes =
{
	[Enum.UIWidgetTextureAndTextSizeType.Small]	= "GameFontNormal",
	[Enum.UIWidgetTextureAndTextSizeType.Medium]	= "GameFontNormalLarge",
	[Enum.UIWidgetTextureAndTextSizeType.Large]	= "GameFontNormalHuge2",
	[Enum.UIWidgetTextureAndTextSizeType.Huge]	= "GameFontNormalHuge4",
	[Enum.UIWidgetTextureAndTextSizeType.Standard]	= "GameFontNormalMed3",
	[Enum.UIWidgetTextureAndTextSizeType.Medium2]	= "SystemFont_Shadow_Huge1_Outline",
};

local function GetTextSizeFont(textSizeType)
	return textFontSizes[textSizeType] and textFontSizes[textSizeType] or textFontSizes[Enum.UIWidgetTextureAndTextSizeType.Medium];
end

function UIWidgetBaseTextureAndTextTemplateMixin:OnLoad()
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
end

function UIWidgetBaseTextureAndTextTemplateMixin:Setup(widgetContainer, text, tooltip, frameTextureKit, textureKit, textSizeType, layoutIndex)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self.layoutIndex = layoutIndex;

	local bgTextureKitFmt = "%s";
	local fgTextureKitFmt = "%s";

	if layoutIndex then
		if frameTextureKit and C_Texture.GetAtlasInfo(GetFinalNameFromTextureKit("%s_"..layoutIndex, frameTextureKit)) then
			bgTextureKitFmt = "%s_"..layoutIndex;
		end

		if textureKit and C_Texture.GetAtlasInfo(GetFinalNameFromTextureKit("%s_"..layoutIndex, textureKit)) then
			fgTextureKitFmt = "%s_"..layoutIndex;
		end
	end

	self.Text:SetFontObject(GetTextSizeFont(textSizeType));

	self.Text:SetText(text);
	self:SetTooltip(tooltip);
	SetupTextureKitOnFrame(frameTextureKit, self.Background, bgTextureKitFmt, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(textureKit, self.Foreground, fgTextureKitFmt, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end

UIWidgetBaseControlZoneTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseControlZoneTemplateMixin:OnLoad()
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
	self.Progress:SetFrameLevel(self.UncapturedSection:GetFrameLevel() + 1);
end

local zoneFormatString = "%s-%s-%s";
local cappedFormatString = "%s-%s-%s-cap";
local swipeTextureFormatString = "Interface\\Widgets\\%s-%s-fill";
local edgeTextureFormatString = "Interface\\UnitPowerBarAlt\\%s-spark%s";

local textureKitRegionInfo = {
	["Zone"] = {useAtlasSize = true, setVisibility = true},	-- formatString is filled on before passing to SetupTextureKitsFromRegionInfo (based on whether the zone is capped or not)
	["DangerGlowBackground"] = {formatString = "%s-fallingglow-bg", useAtlasSize = true},
	["DangerGlowOverlay"] = {formatString = "%s-fallingglow", useAtlasSize = true},
	["CapturedGlow"] = {formatString = "%s-fullglow", useAtlasSize = true},
	["CapturedGlowStar"] = {formatString = "%s-starglow", useAtlasSize = true},
}

local PLAY_ANIM = true;
local STOP_ANIM = false;

function UIWidgetBaseControlZoneTemplateMixin:PlayOrStopCapturedAnimation(play)
	if play then
		self.CapturedGlowStar:Show();
		self.CapturedGlow:Show();
		self.CapturedGlowAnim:Play();
	else
		self.CapturedGlowAnim:Stop();
		self.CapturedGlow:Hide();
		self.CapturedGlowStar:Hide();
	end
end

function UIWidgetBaseControlZoneTemplateMixin:PlayOrStopDangerAnimation(play)
	if play then
		self.DangerGlowBackground:Show();
		self.DangerGlowOverlay:Show();
		self.DangerGlowAnim:Play();
	else
		self.DangerGlowAnim:Stop();
		self.DangerGlowBackground:Hide();
		self.DangerGlowOverlay:Hide();
	end
end

function UIWidgetBaseControlZoneTemplateMixin:UpdateAnimations(zoneInfo, zoneIsGood, lastVals, dangerFlashType)
	local isActive = (zoneInfo.activeState == Enum.ZoneControlActiveState.Active);
	local isCaptured = (zoneInfo.current >= zoneInfo.capturePoint);
	local wasCaptured = not lastVals or (lastVals.current >= lastVals.capturePoint);

	if not isActive then
		-- The zone is inactive...turn off all animations
		self:PlayOrStopCapturedAnimation(STOP_ANIM);
		self:PlayOrStopDangerAnimation(STOP_ANIM);
	else
		if zoneIsGood and isCaptured and not wasCaptured then
			-- This is a good zone that just got captured...play the captured animation
			self:PlayOrStopCapturedAnimation(PLAY_ANIM);
		end

		local zoneStateUsesDangerAnim;
		if zoneIsGood then
			zoneStateUsesDangerAnim = (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnGoodStates) or (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBoth);
		else
			zoneStateUsesDangerAnim = (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBadStates) or (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBoth);
		end

		if not zoneStateUsesDangerAnim then
			-- This zone doesn't use the danger animation...kill it and return
			self:PlayOrStopDangerAnimation(STOP_ANIM);
			return;
		end

		local playDangerAnim, stopDangerAnim;
		if zoneIsGood then
			playDangerAnim = lastVals and zoneInfo.current < lastVals.current;
			stopDangerAnim = not lastVals or zoneInfo.current > lastVals.current;
		else
			playDangerAnim = lastVals and zoneInfo.current > lastVals.current;
			stopDangerAnim = not lastVals or zoneInfo.current < lastVals.current;
		end

		if playDangerAnim then
			self:PlayOrStopDangerAnimation(PLAY_ANIM);
		elseif stopDangerAnim then
			self:PlayOrStopDangerAnimation(STOP_ANIM);
		end
	end
end

function UIWidgetBaseControlZoneTemplateMixin:Setup(widgetContainer, zoneIndex, zoneMode, leadingEdgeType, dangerFlashType, zoneInfo, lastVals, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	if not textureKit then
		self:Hide();
		return;
	end

	local currentVal = Clamp(zoneInfo.current, zoneInfo.min, zoneInfo.max);

	local stateString = "state"..(zoneInfo.state + 1);
	local zoneString = "zone"..zoneIndex;

	local isActive = (zoneInfo.activeState == Enum.ZoneControlActiveState.Active);
	if isActive then
		self.Zone:SetDesaturated(false);
	else
		currentVal = 0;
		self.Zone:SetDesaturated(true);
	end

	if currentVal >= zoneInfo.capturePoint then
		textureKitRegionInfo.Zone.formatString = cappedFormatString;
	else
		textureKitRegionInfo.Zone.formatString = zoneFormatString;
	end

	SetupTextureKitsFromRegionInfo({textureKit, stateString, zoneString}, self, textureKitRegionInfo);

	local swipeTextureName = swipeTextureFormatString:format(unpack({textureKit, stateString}));
	self.Progress:SetSwipeTexture(swipeTextureName);

	local percentageFull;
	local capturePercentage;
	local reverse;
	if zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillClockwise then
		percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		capturePercentage = ClampedPercentageBetween(zoneInfo.capturePoint, zoneInfo.min, zoneInfo.max);
		reverse = true;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillCounterClockwise then
		percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		capturePercentage = 1 - ClampedPercentageBetween(zoneInfo.capturePoint, zoneInfo.min, zoneInfo.max);
		reverse = false;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.DoubleFillClockwise then
		if currentVal >= zoneInfo.capturePoint then
			percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.capturePoint, zoneInfo.max);
		else
			percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.capturePoint);
		end
		reverse = true;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.DoubleFillCounterClockwise then
		if currentVal >= zoneInfo.capturePoint then
			percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.capturePoint, zoneInfo.max);
		else
			percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.capturePoint);
		end
		reverse = false;
	end

	local reverseUncapturedSection = reverse;

	if percentageFull == 1 then
		-- A cooldown at full duration actually draws nothing when what we want is a full bar...to achieve that, flip reverse and set the percentage to 0
		percentageFull = 0;
		reverse = not reverse;
	end

	local edgeColorString = zoneInfo.state == Enum.ZoneControlState.State1 and "blue" or "yellow";
	local edgeTextureName = edgeTextureFormatString:format(unpack({textureKit, edgeColorString}));

	if percentageFull == 0  or leadingEdgeType == Enum.ZoneControlLeadingEdgeType.NoLeadingEdge then
		self.Progress:SetEdgeTexture("", 1, 1, 1, 0);
	else
		self.Progress:SetEdgeTexture(edgeTextureName);
	end

	local zoneIsGood;
	if zoneMode == Enum.ZoneControlMode.BothStatesAreGood then
		zoneIsGood = true;
	elseif zoneMode == Enum.ZoneControlMode.State1IsGood then
		zoneIsGood = (zoneInfo.state == Enum.ZoneControlState.State1);
	elseif zoneMode == Enum.ZoneControlMode.State2IsGood then
		zoneIsGood = (zoneInfo.state == Enum.ZoneControlState.State2);
	else
		zoneIsGood = false;
	end

	local showUncapturedSection = isActive and zoneIsGood and capturePercentage and (zoneInfo.capturePoint > 1);
	self.UncapturedSection:SetShown(showUncapturedSection);
	if showUncapturedSection then
		self.UncapturedSection:SetReverse(reverseUncapturedSection);
		CooldownFrame_SetDisplayAsPercentage(self.UncapturedSection, capturePercentage);
	end

	self.Progress:SetReverse(reverse);
	CooldownFrame_SetDisplayAsPercentage(self.Progress, percentageFull);

	-- Set current to the clamped value
	zoneInfo.current = currentVal;

	-- And update the animations
	self:UpdateAnimations(zoneInfo, zoneIsGood, lastVals, dangerFlashType);

	self:SetTooltip(zoneInfo.tooltip);

	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end

UIWidgetBaseScenarioHeaderTemplateMixin = {};

local scenarioHeaderTextureKitRegions = {
	["Frame"] = "%s-frame",
	["DecorationBottomLeft"] = "%s-decoration",
}

local scenarioHeaderTextureKitInfo =
{
	["jailerstower-scenario"] = {fontObject = GameFontNormalLarge, fontMinLineHeight = 16, fontColor = WHITE_FONT_COLOR, textAnchorOffsets = {xOffset = 33, yOffset = -8}},
	["jailerstower-scenario-nodeaths"] = {fontObject = GameFontNormalLarge, fontMinLineHeight = 16, fontColor = WHITE_FONT_COLOR, textAnchorOffsets = {xOffset = 33, yOffset = -8}},
	["EmberCourtScenario-Tracker"] = {fontObject = GameFontNormalMed3, fontMinLineHeight = 10, headerTextHeight = 20},
	["dragonflight-scenario"] = {fontObject = GameFontNormalMed3, fontMinLineHeight = 10, headerTextHeight = 20},
	["plunderstorm-scenariotracker-active"] = {fontObject = SystemFont_Shadow_Large, fontMinLineHeight = 16, headerTextHeight = 20, headerTextWidth = 300, textAnchorOffsets = {xOffset = 40, yOffset = -25}},
	["plunderstorm-scenariotracker-waiting"] = {fontObject = SystemFont_Shadow_Large, fontMinLineHeight = 16, headerTextHeight = 20, headerTextWidth = 300, textAnchorOffsets = {xOffset = 40, yOffset = -25}},
}

local scenarioHeaderDefaultFontObject = Game18Font;
local scenarioHeaderDefaultFontColor = SCENARIO_STAGE_COLOR;
local scenarioHeaderDefaultFontMinLineHeight = 12;
local scenarioHeaderDefaultTextAnchorOffsets = {xOffset = 15, yOffset = -8};
local scenarioHeaderDefaultDecorationAnchorOffsets = {xOffset = -11, yOffset = -7};
local scenarioHeaderDefaultHeaderTextHeight = 36;
local scenarioHeaderDefaultHeaderTextWidth = 172;
local scenarioHeaderStageChangeWaitTime = 1.5;

-- This returns true if we are waiting for the stage header to slide out
function UIWidgetBaseScenarioHeaderTemplateMixin:Setup(widgetInfo, widgetContainer)
	self:EnableMouse(false);

	if self.WaitTimer then
		self.latestWidgetInfo = widgetInfo;
		return true;
	end

	local _, currentScenarioStage = C_Scenario.GetInfo();
	if self.lastScenarioStage and self.lastScenarioStage ~= currentScenarioStage then
		-- This widget was already showing and the scenario stage changed since the last time Setup was called
		-- If we update everything now we will be showing the next stage's info
		-- So instead we want to set a timer to give the current stage's header time to slide out

		if self.WaitTimer then
			self.WaitTimer:Cancel();
		end

		self.latestWidgetInfo = widgetInfo;
		self.WaitTimer = C_Timer.NewTimer(scenarioHeaderStageChangeWaitTime, GenerateClosure(self.OnWaitTimerDone, self));
		return true;
	end

	self.lastScenarioStage = currentScenarioStage;

	local textureKitInfo = scenarioHeaderTextureKitInfo[widgetInfo.frameTextureKit];

	local fontObject = textureKitInfo and textureKitInfo.fontObject or scenarioHeaderDefaultFontObject;
	self.HeaderText:SetFontObject(fontObject);

	local minLineHeight = textureKitInfo and textureKitInfo.fontMinLineHeight or scenarioHeaderDefaultFontMinLineHeightLineHeight;
	self.HeaderText.minLineHeight = minLineHeight;

	local fontColor = textureKitInfo and textureKitInfo.fontColor or scenarioHeaderDefaultFontColor;
	self.HeaderText:SetTextColor(fontColor:GetRGB());

	local headerTextHeight = textureKitInfo and textureKitInfo.headerTextHeight or scenarioHeaderDefaultHeaderTextHeight;
	self.HeaderText:SetHeight(headerTextHeight);

	local headerTextWidth = textureKitInfo and textureKitInfo.headerTextWidth or scenarioHeaderDefaultHeaderTextWidth;
	self.HeaderText:SetWidth(headerTextWidth);

	self.HeaderText:SetText(widgetInfo.headerText);

	local textAnchorOffsets = textureKitInfo and textureKitInfo.textAnchorOffsets or scenarioHeaderDefaultTextAnchorOffsets;
	self.HeaderText:SetPoint("TOPLEFT", self, "TOPLEFT", textAnchorOffsets.xOffset, textAnchorOffsets.yOffset);

	local decorationAnchorOffset = textureKitInfo and textureKitInfo.decorationOffset or scenarioHeaderDefaultDecorationAnchorOffsets;
	self.DecorationBottomLeft:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", decorationAnchorOffset.xOffset, decorationAnchorOffset.yOffset);

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, scenarioHeaderTextureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	self:SetWidth(self.Frame:GetWidth());
	self:SetHeight(self.Frame:GetHeight());
end

function UIWidgetBaseScenarioHeaderTemplateMixin:OnWaitTimerDone()
	self.WaitTimer = nil;

	local _, currentScenarioStage = C_Scenario.GetInfo();
	self.lastScenarioStage = currentScenarioStage;

	self:Setup(self.latestWidgetInfo, self.widgetContainer);
	self.latestWidgetInfo = nil;
end

function UIWidgetBaseScenarioHeaderTemplateMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);

	if self.WaitTimer then
		self.WaitTimer:Cancel();
		self.WaitTimer = nil;
	end

	self.lastScenarioStage = nil;
	self.latestWidgetInfo = nil;
end

UIWidgetBaseCircularStatusBarTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local circularBarSwipeTextureFormatString = "Interface\\UnitPowerBarAlt\\%s-fill";

function UIWidgetBaseCircularStatusBarTemplateMixin:Setup(widgetContainer, barMin, barMax, barValue, deadZonePercentage, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	barValue = Clamp(barValue, barMin, barMax);

	local currentPercent = ClampedPercentageBetween(barValue, barMin, barMax);

	if deadZonePercentage then
		deadZonePercentage = deadZonePercentage / 2;

		local range = barMax - barMin;
		local newMin = range * deadZonePercentage;
		local newMax = range * (1 - deadZonePercentage);
		local newRange = newMax - newMin;
		local newValue = newMin + newRange * currentPercent;

		currentPercent = newValue / range;
	end

	local swipeTextureName = circularBarSwipeTextureFormatString:format(textureKit);
	self.Progress:SetSwipeTexture(swipeTextureName);

	CooldownFrame_SetDisplayAsPercentage(self.Progress, 1 - currentPercent);
end

UIWidgetBaseTextMixin = CreateFromMixins(UIWidgetBaseEnabledFrameMixin);

local normalFonts =
{
	[Enum.UIWidgetTextSizeType.Small10Pt]	= "SystemFont_Small",
	[Enum.UIWidgetTextSizeType.Small11Pt]	= "SystemFont_Small2",
	[Enum.UIWidgetTextSizeType.Small12Pt]	= "SystemFont_Med1",
	[Enum.UIWidgetTextSizeType.Standard14Pt]= "SystemFont_Med3",
	[Enum.UIWidgetTextSizeType.Medium16Pt]	= "SystemFont_Large",
	[Enum.UIWidgetTextSizeType.Medium18Pt]	= "SystemFont_Large2",
	[Enum.UIWidgetTextSizeType.Large20Pt]	= "SystemFont_Huge1",
	[Enum.UIWidgetTextSizeType.Large24Pt]	= "SystemFont_Huge2",
	[Enum.UIWidgetTextSizeType.Huge27Pt]	= "SystemFont_Huge4",
}

local shadowFonts =
{
	[Enum.UIWidgetTextSizeType.Small10Pt]	= "SystemFont_Shadow_Small",
	[Enum.UIWidgetTextSizeType.Small11Pt]	= "SystemFont_Shadow_Small2",
	[Enum.UIWidgetTextSizeType.Small12Pt]	= "SystemFont_Shadow_Med1",
	[Enum.UIWidgetTextSizeType.Standard14Pt]= "SystemFont_Shadow_Med3",
	[Enum.UIWidgetTextSizeType.Medium16Pt]	= "SystemFont_Shadow_Large",
	[Enum.UIWidgetTextSizeType.Medium18Pt]	= "SystemFont_Shadow_Large2",
	[Enum.UIWidgetTextSizeType.Large20Pt]	= "SystemFont_Shadow_Huge1",
	[Enum.UIWidgetTextSizeType.Large24Pt]	= "SystemFont_Shadow_Huge2",
	[Enum.UIWidgetTextSizeType.Huge27Pt]	= "SystemFont_Shadow_Huge4",
}

local outlineFonts =
{
	[Enum.UIWidgetTextSizeType.Small10Pt]	= "SystemFont_Shadow_Small_Outline",
	[Enum.UIWidgetTextSizeType.Small11Pt]	= "SystemFont_Shadow_Small2_Outline",
	[Enum.UIWidgetTextSizeType.Small12Pt]	= "SystemFont_Shadow_Med1_Outline",
	[Enum.UIWidgetTextSizeType.Standard14Pt]= "SystemFont_Shadow_Med3_Outline",
	[Enum.UIWidgetTextSizeType.Medium16Pt]	= "SystemFont_Shadow_Large_Outline",
	[Enum.UIWidgetTextSizeType.Medium18Pt]	= "SystemFont_Shadow_Large2_Outline",
	[Enum.UIWidgetTextSizeType.Large20Pt]	= "SystemFont_Shadow_Huge1_Outline",
	[Enum.UIWidgetTextSizeType.Large24Pt]	= "SystemFont_Shadow_Huge2_Outline",
	[Enum.UIWidgetTextSizeType.Huge27Pt]	= "SystemFont_Shadow_Huge4_Outline",
}

local fontTypes =
{
	[Enum.UIWidgetFontType.Normal]	= normalFonts,
	[Enum.UIWidgetFontType.Shadow]	= shadowFonts,
	[Enum.UIWidgetFontType.Outline]	= outlineFonts,
}

local function GetTextFont(fontType, textSizeType)
	return fontTypes[fontType][textSizeType];
end

local function GetJustifyH(hAlignType)
	if hAlignType == Enum.WidgetTextHorizontalAlignmentType.Left then
		return "LEFT";
	elseif hAlignType == Enum.WidgetTextHorizontalAlignmentType.Right then
		return "RIGHT";
	else
		return "CENTER";
	end
end

function UIWidgetBaseTextMixin:Setup(text, fontType, textSizeType, enabledState, hAlignType)
	self:SetFontObject(GetTextFont(fontType, textSizeType));
	self:SetJustifyH(GetJustifyH(hAlignType))
	self:SetText(text);

	if enabledState then
		self:SetEnabledState(enabledState);
	end
end


UIWidgetBaseItemTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local stackCountTextFontSizes =
{
	[Enum.WidgetIconSizeType.Small]	= "NumberFontNormalSmall",
	[Enum.WidgetIconSizeType.Medium]	= "NumberFontNormal",
	[Enum.WidgetIconSizeType.Large]	= "NumberFontNormal",
	[Enum.WidgetIconSizeType.Standard]	= "NumberFontNormalSmall",
}

local function GetItemCountTextSizeFont(iconSizeType)
	return stackCountTextFontSizes[iconSizeType];
end

local earnedCheckSizes =
{
	[Enum.WidgetIconSizeType.Small]	= 12,
	[Enum.WidgetIconSizeType.Medium] = 15,
	[Enum.WidgetIconSizeType.Large]	= 18,
	[Enum.WidgetIconSizeType.Standard] = 14,
}

local function GetEarnedCheckSize(iconSizeType)
	return earnedCheckSizes[iconSizeType];
end

local baseItemEmbeddedTooltipCount = 0;

function UIWidgetBaseItemTemplateMixin:ShowEmbeddedTooltip(itemID)
	if not self.Tooltip then
		baseItemEmbeddedTooltipCount = baseItemEmbeddedTooltipCount + 1;
		self.Tooltip = CreateFrame("GameTooltip", "UIWidgetBaseItemEmbeddedTooltip"..baseItemEmbeddedTooltipCount, self, "UIWidgetBaseItemEmbeddedTooltipTemplate");
	else
		self.Tooltip:SetScript("OnTooltipCleared", nil);
	end

	local function setEmbeddedTooltip()
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetPadding(-10, -10, -10, -10);
		self.Tooltip:SetItemByID(itemID);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 10, 0);
	end

	setEmbeddedTooltip();
	self.Tooltip:SetScript("OnTooltipCleared", setEmbeddedTooltip);
	self.Tooltip:Show();
end

function UIWidgetBaseItemTemplateMixin:HideEmbeddedTooltip()
	if self.Tooltip then
		self.Tooltip:SetScript("OnTooltipCleared", nil);
		self.Tooltip:Hide();
	end
end

function UIWidgetBaseItemTemplateMixin:Setup(widgetContainer, itemInfo, widgetSizeSetting)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	local iconSize = GetWidgetIconSize(itemInfo.iconSizeType);
	self.Icon:SetSize(iconSize, iconSize);
	self.IconBorder:SetSize(iconSize, iconSize);
	self.IconOverlay:SetSize(iconSize, iconSize);
	self.IconOverlay2:SetSize(iconSize, iconSize);

	local earnedCheckSize = GetEarnedCheckSize(itemInfo.iconSizeType);
	self.EarnedCheck:SetSize(earnedCheckSize, earnedCheckSize);

	self.Count:SetFontObject(GetItemCountTextSizeFont(itemInfo.iconSizeType));

	local itemName, _, quality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemInfo.itemID);
	self.Icon:SetTexture(itemTexture);
	SetItemButtonQuality(self, quality, itemInfo.itemID);
	SetItemButtonCount(self, itemInfo.stackCount or 1);

	local qualityColor = ITEM_QUALITY_COLORS[quality];
	self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);

	self.EarnedCheck:SetShown(itemInfo.showAsEarned);

	local LEFT_ALIGN = Enum.WidgetTextHorizontalAlignmentType.Left;

	local widgetWidth, widgetHeight;
	if itemInfo.textDisplayStyle == Enum.ItemDisplayTextDisplayStyle.WorldQuestReward then
		self.ItemName:Hide()
		self.InfoText:Hide();
		self.NameFrame:Hide();

		self:ShowEmbeddedTooltip(itemInfo.itemID);

		widgetWidth = iconSize + self.Tooltip:GetWidth() + 10;
		widgetHeight = math.max(iconSize, self.Tooltip:GetHeight());
	elseif itemInfo.textDisplayStyle == Enum.ItemDisplayTextDisplayStyle.PlayerChoiceReward then
		self:HideEmbeddedTooltip();
		self.InfoText:Hide();

		local minNameFrameWidth = 100;
		local maxNameFrameWidth = 209;

		local desiredNameFrameWidth = (widgetSizeSetting > 0) and (widgetSizeSetting - (iconSize + 2)) or maxNameFrameWidth;
		local nameFrameWidth = Clamp(desiredNameFrameWidth, minNameFrameWidth, maxNameFrameWidth);
		self.NameFrame:SetSize(nameFrameWidth, iconSize);
		self.NameFrame:Show();

		self.ItemName:ClearAllPoints();
		self.ItemName:SetPoint("TOPLEFT", self.NameFrame, "TOPLEFT", 4, -2);
		self.ItemName:SetPoint("BOTTOMRIGHT", self.NameFrame, "BOTTOMRIGHT", -4, 2);
		self.ItemName:Setup(itemInfo.overrideItemName or itemName, itemInfo.itemNameTextFontType, itemInfo.itemNameTextSizeType, nil, LEFT_ALIGN);
		self.ItemName:Show();

		widgetWidth = iconSize + nameFrameWidth + 2;
		widgetHeight = iconSize;
	elseif itemInfo.textDisplayStyle == Enum.ItemDisplayTextDisplayStyle.ItemNameOnlyCentered then
		self:HideEmbeddedTooltip();
		self.NameFrame:Hide();
		self.InfoText:Hide();

		local desiredItemNameWidth = (widgetSizeSetting > 0) and (widgetSizeSetting - (iconSize + 10)) or 0;
		local itemNameWidth = math.max(desiredItemNameWidth, 0);

		self.ItemName:ClearAllPoints();
		self.ItemName:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 10, 0);
		self.ItemName:SetSize(itemNameWidth, iconSize);
		self.ItemName:Setup(itemInfo.overrideItemName or itemName, itemInfo.itemNameTextFontType, itemInfo.itemNameTextSizeType, nil, LEFT_ALIGN);
		self.ItemName:Show();

		widgetWidth = iconSize + self.ItemName:GetWidth() + 10;
		widgetHeight = iconSize;
	else
		self:HideEmbeddedTooltip();
		self.NameFrame:Hide();

		local desiredTextWidth = (widgetSizeSetting > 0) and (widgetSizeSetting - (iconSize + 10)) or 0;
		local textWidth = math.max(desiredTextWidth, 0);

		self.ItemName:ClearAllPoints();
		self.ItemName:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 10, 0);
		self.ItemName:SetSize(textWidth, 0);
		self.ItemName:Setup(itemInfo.overrideItemName or itemName, itemInfo.itemNameTextFontType, itemInfo.itemNameTextSizeType, nil, LEFT_ALIGN);
		self.ItemName:Show();

		if itemInfo.infoText then
			self.InfoText:SetSize(textWidth, 0);
			self.InfoText:Setup(itemInfo.infoText, itemInfo.infoTextFontType, itemInfo.infoTextSizeType, itemInfo.infoTextEnabledState, LEFT_ALIGN);
			self.InfoText:Show();

			widgetWidth = iconSize + self.InfoText:GetWidth() + 10;
			widgetHeight = math.max(iconSize, self.ItemName:GetHeight() + self.InfoText:GetHeight() + 2);
		else
			self.InfoText:Hide();
			widgetWidth = iconSize + self.ItemName:GetWidth() + 10;
			widgetHeight = math.max(iconSize, self.ItemName:GetHeight());
		end
	end

	self.itemID = itemInfo.itemID;
	self.tooltipEnabled = itemInfo.tooltipEnabled;
	self:SetTooltip(itemInfo.overrideTooltip);

	self:SetWidth(widgetWidth);
	self:SetHeight(widgetHeight);
end

function UIWidgetBaseItemTemplateMixin:OnEnter()
	if not self.tooltip then
		self:SetTooltipOwner();
		EmbeddedItemTooltip:SetItemByID(self.itemID);
		EmbeddedItemTooltip:Show();
	else
		UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	end
end

function UIWidgetBaseItemTemplateMixin:SetMouse(disableMouse)
	local useMouse = self.tooltipEnabled and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

function UIWidgetBaseItemTemplateMixin:OnReset()
	self:HideEmbeddedTooltip();
end

UIWidgetBaseIconTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local iconTextureKitRegions = {
	Glow = "%s-spell-glow",
	Frame = "%s-spell-frame",
};

local iconFrameSizes =
{
	[Enum.WidgetIconSizeType.Small]	= 44,
	[Enum.WidgetIconSizeType.Medium] = 58,
	[Enum.WidgetIconSizeType.Large]	= 70,
	[Enum.WidgetIconSizeType.Standard] = 54,
}

local function GetWidgetIconFrameSize(iconSizeType)
	return iconFrameSizes[iconSizeType];
end

function UIWidgetBaseIconTemplateMixin:Setup(widgetContainer, textureKit, iconInfo, shouldGlow, glowAnimType)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	SetupTextureKitOnRegions(textureKit, self, iconTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local hasGlowTexture = self.Glow:IsShown();
	if hasGlowTexture and shouldGlow then
		if glowAnimType == Enum.WidgetGlowAnimType.Pulse then
			self.GlowPulseAnim:Play();
		else
			self.GlowPulseAnim:Stop();
			self.Glow:SetAlpha(1);
		end
		self.Glow:Show();
	else
		self.GlowPulseAnim:Stop();
		self.Glow:Hide();
	end

	local iconSize = GetWidgetIconSize(iconInfo.sizeType);
	self.Icon:SetSize(iconSize, iconSize);

	local iconFrameSize = GetWidgetIconFrameSize(iconInfo.sizeType);
	self.Frame:SetSize(iconFrameSize, iconFrameSize);
	self.Glow:SetSize(iconFrameSize, iconFrameSize);

	if iconInfo.sourceType == Enum.WidgetIconSourceType.Spell then
		local iconTexture =	C_Spell.GetSpellTexture(iconInfo.sourceID);
		if iconTexture then
			self.Icon:SetTexture(iconTexture);
			self:Show();
		else
			self:Hide();
		end
	else
		self:Hide();
		if iconInfo.sourceID > 0 then
			local item = Item:CreateFromItemID(iconInfo.sourceID);

			self.continuableContainer = ContinuableContainer:Create();
			self.continuableContainer:AddContinuable(item);

			self.continuableContainer:ContinueOnLoad(function()
				local iconTexture = select(10, C_Item.GetItemInfo(iconInfo.sourceID));
				self.Icon:SetTexture(iconTexture);
				self:Show();
			end);
		end
	end
	self.iconInfo = iconInfo;

	self:SetTooltip(iconInfo.tooltip);
	self:SetTooltipLocation(iconInfo.tooltipLoc);

	self:SetSize(self.Icon:GetSize());
end

function UIWidgetBaseIconTemplateMixin:SetMouse(disableMouse)
	local useMouse = (self.tooltip ~= " ") and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

function UIWidgetBaseIconTemplateMixin:OnEnter()
	if self.tooltip == "" then
		self:SetTooltipOwner();
		if self.iconInfo.sourceType == Enum.WidgetIconSourceType.Spell then
			EmbeddedItemTooltip:SetSpellByID(self.iconInfo.sourceID);
		else
			EmbeddedItemTooltip:SetItemByID(self.iconInfo.sourceID);
		end
		EmbeddedItemTooltip:Show();
	else
		UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	end
end

function UIWidgetBaseIconTemplateMixin:StopAnims()
	self.GlowPulseAnim:Stop();
	self.Glow:Hide();
end