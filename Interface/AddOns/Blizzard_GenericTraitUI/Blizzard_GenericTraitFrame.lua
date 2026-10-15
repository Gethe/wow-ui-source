
UIPanelWindows["GenericTraitFrame"] = {
	area = "left",
	checkFit = 1,
	checkFitExtraWidth = 40,
	checkFitExtraHeight = 40,
};

GenericTraitFrameMixin = {};

local GenericTraitFrameEvents = {
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

function GenericTraitFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);
end

function GenericTraitFrameMixin:ApplyLayout(layoutInfo)
	self:SetSize(layoutInfo.FrameSize.Width, layoutInfo.FrameSize.Height);
	self.Background:SetAtlas(layoutInfo.BackgroundAtlas);
	self.FrameTitleContainer.FrameTitle:SetText(layoutInfo.FrameTitle or "");
	self.Header.Title:SetText(layoutInfo.Title or "");
	self.Header:SetSize(layoutInfo.HeaderSize.Width, layoutInfo.HeaderSize.Height);
	self.Header.TitleDivider:SetAtlas(layoutInfo.TitleDividerAtlas, true);
	self.Header.TitleDivider:SetShown(layoutInfo.TitleDividerShown);
	self.Inset:SetShown(layoutInfo.ShowInset);
	self.Header:SetPoint("TOP", layoutInfo.HeaderOffset.x, layoutInfo.HeaderOffset.y);
	self.Currency:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", layoutInfo.CurrencyOffset.x, layoutInfo.CurrencyOffset.y);
	self.Currency.UnspentPointsCount:SetPoint("RIGHT", self.Currency, "RIGHT", layoutInfo.CurrencyTextOffset.x, layoutInfo.CurrencyTextOffset.y);

	local font = layoutInfo.CurrencyTextOverrides.Font or GameFontNormal;
	self.Currency.UnspentPointsCount:SetFontObject(font);

	self.Currency:SetOverrideFontColor(layoutInfo.CurrencyTextOverrides.Color);
	self.Currency:SetTooltipOptions(not not layoutInfo.UseCurrencyTooltip);

	self.Currency.CurrencyBackground:SetAtlas(layoutInfo.CurrencyBackgroundAtlas, true);

	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layoutInfo.CloseButtonOffset.x, layoutInfo.CloseButtonOffset.y);

	local useNewNineSlice = not layoutInfo.UseOldNineSlice;

	self.NineSlice:SetShown(layoutInfo.NineSliceTextureKit ~= nil and not useNewNineSlice);
	self.BorderOverlay:SetShown(useNewNineSlice);

	if useNewNineSlice then
		self.BorderOverlay:SetAtlas(layoutInfo.NineSliceFormatString:format(layoutInfo.NineSliceTextureKit));
	else
		self.NineSlice.DetailTop:SetAtlas(layoutInfo.DetailTopAtlas, true);
		if layoutInfo.NineSliceLayoutName then
			local layout = NineSliceUtil.GetLayout(layoutInfo.NineSliceLayoutName);
			if layout then
				NineSliceUtil.ApplyLayout(self.NineSlice, layout);
			end
		elseif layoutInfo.NineSliceTextureKit then
			NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, layoutInfo.NineSliceTextureKit);
		end
	end

	self.basePanOffsetX = layoutInfo.PanOffset.x;
	self.basePanOffsetY = layoutInfo.PanOffset.y;

	self.buttonPurchaseFXIDs = layoutInfo.ButtonPurchaseFXIDs;
	self.suppressSubTreeConfirmation = layoutInfo.SuppressSubTreeConfirmation;
	self:SetCardTemplateCallback(layoutInfo.CardTemplateCallback or nil);
	self.OnEnterDisplayCallback = layoutInfo.OnEnterDisplayCallback;
	self.OnLeaveDisplayCallback = layoutInfo.OnLeaveDisplayCallback;
	self.OnShowCallback = layoutInfo.OnShowCallback;
	self.OnHideCallback = layoutInfo.OnHideCallback;
	self.hideUndiscoveredNodes = not not layoutInfo.HideUndiscoveredNodes;

	-- Show currency costs and held currency amounts by default unless overridden to be hidden by layout info.
	local showCurrencyDisplay = not layoutInfo.HideCurrencyDisplay;
	local currencyDisplayCallback = showCurrencyDisplay and TalentFrameUtil.GenerateTreeCurrencyDisplayCallback(layoutInfo.CurrencyTextOverrides.IconWidth, layoutInfo.CurrencyTextOverrides.IconHeight) or nil;
	self:SetTreeCurrencyDisplayTextCallback(currencyDisplayCallback);

	SetUIPanelAttribute(GenericTraitFrame, "area", layoutInfo.PanelArea);
end

function GenericTraitFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnShow");

	if self.OnShowCallback then
		self.OnShowCallback(self);
	end

	if CanAutoSetGamePadCursorControl(true) then
		SetGamePadCursorControl(true);
	end

	self:UpdateTreeCurrencyInfo();
	self:ShowGenericTraitFrameTutorial();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnHide");

	if self.OnHideCallback then
		self.OnHideCallback(self);
	end

	if CanAutoSetGamePadCursorControl(false) then
		SetGamePadCursorControl(false);
	end

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);
end

function GenericTraitFrameMixin:OnEvent(event, ...)
	TalentFrameBaseMixin.OnEvent(self, event, ...);

	if event == "TRAIT_SYSTEM_NPC_CLOSED" then
		HideUIPanel(self);
	end
end

function GenericTraitFrameMixin:SetConfigIDBySystemID(systemID)
	TalentFrameBaseMixin.SetConfigIDBySystemID(self, systemID);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetSystemID", systemID, self:GetConfigID());
end

function GenericTraitFrameMixin:SetTreeID(traitTreeID)
	self.traitTreeID = traitTreeID;

	-- Apply the new tree's layout (pan offset, size, etc.) before SetConfigID below can trigger
	-- LoadTalentTree/LoadTalentTreeInternal while the frame is already visible. Otherwise buttons
	-- for the new tree would be positioned using the previous tree's basePanOffset, leaving the
	-- tree looking off-center.
	local layout = GenericTraitUtil.GetFrameLayoutInfo(traitTreeID);
	self:ApplyLayout(layout);

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetTreeID", traitTreeID, configID);
end

function GenericTraitFrameMixin:GetButtonPurchaseFXIDs()
	return self.buttonPurchaseFXIDs;
end

function GenericTraitFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local showCurrency = currencyInfo ~= nil;
	if showCurrency then
		local displayText = self.getDisplayTextFromTreeCurrency and self.getDisplayTextFromTreeCurrency(currencyInfo);
		if displayText then
			self.Currency:Setup(currencyInfo, displayText);
		else
			showCurrency = false;
		end
	end
	self.Currency:SetShown(showCurrency);
end

function GenericTraitFrameMixin:ShouldNodeBeVisible(nodeInfo)
	-- Overrides TalentFrameBaseMixin.

	if not self.hideUndiscoveredNodes then
		return true;
	end

	local isLearned = (nodeInfo.ranksPurchased or 0) > 0 or (nodeInfo.ranksIncreased or 0) > 0;
	return isLearned or nodeInfo.meetsEdgeRequirements;
end

function GenericTraitFrameMixin:OnButtonUpdateNodeInfo(nodeID)
	TalentFrameBaseMixin.OnButtonUpdateNodeInfo(self, nodeID);

	-- An edge is only created from its start button, so only buttons with an edge into this node need refreshing.
	-- The button itself already marks its own outgoing edges dirty.
	if self.hideUndiscoveredNodes then
		for talentButton in self:EnumerateAllTalentButtons() do
			local nodeInfo = talentButton:GetNodeInfo();
			if nodeInfo and nodeInfo.visibleEdges then
				for _i, edgeVisualInfo in ipairs(nodeInfo.visibleEdges) do
					if edgeVisualInfo.targetNode == nodeID then
						self:MarkEdgesDirty(talentButton);
						break;
					end
				end
			end
		end
	end
end

function GenericTraitFrameMixin:ShouldInstantiateInvisibleButtons()
	-- Overrides TalentFrameBaseMixin.

	-- It's important to instantiate invisible buttons that could change visibility.
	-- Since the GenericTraitFrame covers a lot of trees we should assume that something might change visibility.
	return true;
end

function GenericTraitFrameMixin:ShowGenericTraitFrameTutorial()
	local treeID = self:GetTalentTreeID();
	if not treeID then
		return;
	end

	local nodeIDs = C_Traits.GetTreeNodes(treeID);

	local firstButton = self:GetTalentButtonByNodeID(nodeIDs[1]);
	local tutorialInfo = GenericTraitUtil.GetFrameTutorialInfo(treeID);
	if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
		HelpTip:Show(self, tutorialInfo.tutorial, firstButton);
	end
end

GenericTraitFrameCurrencyFrameMixin = {};

function GenericTraitFrameCurrencyFrameMixin:UpdateWidgetSet()
	local configID = self:GetParent():GetConfigID();
	self.uiWidgetSetID = configID and C_Traits.GetTraitSystemWidgetSetID(configID) or nil;
end

function GenericTraitFrameCurrencyFrameMixin:SetOverrideFontColor(overrideFontColor)
	self.overrideFontColor = overrideFontColor;
end

function GenericTraitFrameCurrencyFrameMixin:SetTooltipOptions(useCurrencyTooltip)
	self.useCurrencyTooltip = useCurrencyTooltip;
end

function GenericTraitFrameCurrencyFrameMixin:Setup(currencyInfo, displayText)
	displayText = displayText or "";
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local fontColor = self.overrideFontColor or WHITE_FONT_COLOR;
	local currencyText = fontColor:WrapTextInColorCode(currencyCostText);

	self.UnspentPointsCount:SetText(currencyText);
	self.traitCurrencyID = currencyInfo and currencyInfo.traitCurrencyID;
	self:UpdateWidgetSet();

	if currencyInfo and currencyInfo.traitCurrencyID then
		local tutorialInfo = GenericTraitUtil.GetCurrencyTutorialInfo(currencyInfo.traitCurrencyID);
		if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial);
		end
	end
end

function GenericTraitFrameCurrencyFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.uiWidgetSetID then
		GameTooltip_AddWidgetSet(GameTooltip, self.uiWidgetSetID);
	elseif self.useCurrencyTooltip and self.traitCurrencyID then
		local currencyTypesID = select(3, C_Traits.GetTraitCurrencyInfo(self.traitCurrencyID));
		if not currencyTypesID then
			return;
		end

		GameTooltip:SetCurrencyByID(currencyTypesID);
	else
		return;
	end

	GameTooltip:Show();
end
