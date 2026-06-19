
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
	self.Header.Title:SetText(layoutInfo.Title or "");
	self.Header:SetSize(layoutInfo.HeaderSize.Width, layoutInfo.HeaderSize.Height);
	self.Header.TitleDivider:SetAtlas(layoutInfo.TitleDividerAtlas, true);
	self.Header.TitleDivider:SetShown(layoutInfo.TitleDividerShown);
	self.Inset:SetShown(layoutInfo.ShowInset);
	self.Header:SetPoint("TOP", layoutInfo.HeaderOffset.x, layoutInfo.HeaderOffset.y);
	self.Currency:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", layoutInfo.CurrencyOffset.x, layoutInfo.CurrencyOffset.y);
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

	-- Show currency costs and held currency amounts by default unless overridden to be hidden by layout info.
	local showCurrencyDisplay = not layoutInfo.HideCurrencyDisplay;
	local currencyDisplayCallback = showCurrencyDisplay and TalentFrameUtil.GenerateTreeCurrencyDisplayCallback() or nil;
	self:SetTreeCurrencyDisplayTextCallback(currencyDisplayCallback);

	SetUIPanelAttribute(GenericTraitFrame, "area", layoutInfo.PanelArea);
end

function GenericTraitFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnShow");

	self:UpdateTreeCurrencyInfo();
	self:ShowGenericTraitFrameTutorial();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnHide");

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

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	local treeID = self.traitTreeID;
	local layout = GenericTraitUtil.GetFrameLayoutInfo(treeID);
	self:ApplyLayout(layout);

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

function GenericTraitFrameCurrencyFrameMixin:Setup(currencyInfo, displayText)
	displayText = displayText or "";
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);

	self.UnspentPointsCount:SetText(currencyText);
	self:UpdateWidgetSet();

	if currencyInfo and currencyInfo.traitCurrencyID then
		local tutorialInfo = GenericTraitUtil.GetCurrencyTutorialInfo(currencyInfo.traitCurrencyID);
		if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial);
		end
	end
end

function GenericTraitFrameCurrencyFrameMixin:OnEnter()
	if not self.uiWidgetSetID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddWidgetSet(GameTooltip, self.uiWidgetSetID);
	GameTooltip:Show();
end
