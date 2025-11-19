
-- A simple limit to avoid infinite loops
local MAX_DISPLAYED_CURRENCIES = 10;
local CURRENCY_DISPLAY_ICON_SIZE = 24;

TalentFrameCurrencyDisplayMixin = {};

function TalentFrameCurrencyDisplayMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	BaseLayoutMixin.OnShow(self);
end

function TalentFrameCurrencyDisplayMixin:SetTalentFrame(talentFrame)
	self:UnregisterAllEventMethods();

	self.talentFrame = talentFrame;
	self:AddDynamicEventMethod(talentFrame, "TreeCurrencyInfoUpdated", self.OnTreeCurrencyInfoUpdated);
end

function TalentFrameCurrencyDisplayMixin:OnTreeCurrencyInfoUpdated()
	self:Update();
end

function TalentFrameCurrencyDisplayMixin:Update()
	if not self.talentFrame then
		self.Text:SetText("");
		return;
	end

	local text = "";
	for i = 1, MAX_DISPLAYED_CURRENCIES do
		local currencyText = self.talentFrame:GetTreeCurrencyTextByIndex(i, CURRENCY_DISPLAY_ICON_SIZE, CURRENCY_DISPLAY_ICON_SIZE);
		if currencyText then
			if i > 1 then
				text = " " .. text;
			end
			text = currencyText .. text;
		else
			break;
		end
	end

	self.Text:SetText(text);
	self:MarkDirty();
end

TalentFrameGateMixin = {};

function TalentFrameGateMixin:Init(talentFrame, anchorButton, condInfo)
	self.talentFrame = talentFrame;
	self.anchorButton = anchorButton;
	self.condInfo = condInfo;

	local spentAmountRequired = condInfo.spentAmountRequired;
	self.GateText:SetShown(spentAmountRequired ~= nil);
	if spentAmountRequired then
		self.GateText:SetText(spentAmountRequired);
	end
end

function TalentFrameGateMixin:OnEnter()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_LEFT", 4, -4);

	local condInfo = self:GetTalentFrame():GetAndCacheCondInfo(self.condInfo.condID);
	GameTooltip_AddErrorLine(tooltip, TALENT_FRAME_GATE_TOOLTIP_FORMAT:format(condInfo.spentAmountRequired));
	tooltip:Show();
end

function TalentFrameGateMixin:OnLeave()
	GameTooltip_Hide();
end

function TalentFrameGateMixin:GetAnchorButton()
	return self.anchorButton;
end

function TalentFrameGateMixin:GetTalentFrame()
	return self.talentFrame;
end

TraitsCommitControlsContainerMixin = {};

-- If no frame is specified we'll use the direct parent
function TraitsCommitControlsContainerMixin:Init()
	self:InitByFrame(self:GetParent());
end

-- Making the frame an init parameter to avoid constraints on frame hierarchies
function TraitsCommitControlsContainerMixin:InitByFrame(traitFrame)
	self.traitFrame = traitFrame;

	local function CommitConfig()
		if not self.traitFrame:CommitConfig() then
			UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
			self.traitFrame:MarkTreeDirty();
		end

		self:UpdateConfigButtonsState();

		self.traitFrame:TriggerEvent(TalentFrameBaseMixin.Event.ConfigCommitted, self.traitFrame.GetConfigID and self.traitFrame:GetConfigID() or 0);
	end
	self.CommitButton:SetScript("OnClick", function() CommitConfig(); end);

	local function RollbackConfig()
		TalentFrameBaseMixin.RollbackConfig(self.traitFrame);

		self:UpdateConfigButtonsState();
		self.traitFrame:UpdateTreeCurrencyInfo();
	end
	self.UndoButton:SetScript("OnClick", function() RollbackConfig(); end);

	-- Parent Frame must specify the reset popup functionality to have a reset button
	if self:ShouldShowResetButton() then
		local function TryResetConfig()
			StaticPopup_ShowCustomGenericConfirmation(self.resetPopupData);
		end
		self.ResetButton:SetScript("OnClick", function() TryResetConfig(); end);

		EventRegistry:RegisterCallback("TalentFrameBase.ButtonsUpdated", self.UpdateConfigButtonsState, self);
	end
end

function TraitsCommitControlsContainerMixin:OnShow()
	self:UpdateConfigButtonsState();
end

function TraitsCommitControlsContainerMixin:UpdateConfigButtonsState(treeID)
	-- Check to make sure the updates are coming from the tree associated with this button
	local parentTreeID = self.traitFrame:GetTalentTreeID();
	if treeID and parentTreeID ~= treeID then
		return;
	end

	local hasAnyChanges = self.traitFrame:HasAnyConfigChanges();
	self.CommitButton:SetEnabled(hasAnyChanges);
	self.UndoButton:SetShown(hasAnyChanges and self.CommitButton:IsShown());

	if self:ShouldShowResetButton() then
		local hasAnyPurchasedRanks = self.traitFrame:HasAnyPurchasedRanks();
		self.ResetButton:SetShown(not hasAnyChanges and hasAnyPurchasedRanks);
		self.ResetButton:SetEnabledState(self.traitFrame:HasValidConfig() and hasAnyPurchasedRanks and not hasAnyChanges);
	end

	if hasAnyChanges then
		GlowEmitterFactory:Show(self.CommitButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	else
		GlowEmitterFactory:Hide(self.CommitButton);
	end
end

function TraitsCommitControlsContainerMixin:SetResetPopupData(popupData)
	self.resetPopupData = popupData;
end

function TraitsCommitControlsContainerMixin:ShouldShowResetButton()
	return self.resetPopupData ~= nil;
end

TalentSubTreeHeaderMixin = {};

function TalentSubTreeHeaderMixin:OnLoad()
	self:AddDynamicEventMethod(EventRegistry, "TalentFrameBase.ButtonsUpdated", self.OnButtonsUpdated);
end

function TalentSubTreeHeaderMixin:OnShow()
	BaseLayoutMixin.OnShow(self);
	CallbackRegistrantMixin.OnShow(self);
end

function TalentSubTreeHeaderMixin:SetTalentFrame(talentFrame)
	self.talentFrame = talentFrame;
end

function TalentSubTreeHeaderMixin:OnButtonsUpdated(treeID)
	if self.talentFrame and (self.talentFrame:GetTalentTreeID() == treeID) then
		self:Update();
	end
end

function TalentSubTreeHeaderMixin:Update()
	local _subTreeID, subTreeName, subTreeInfo = self.talentFrame:GetSubTreeInfo();
	self.Text:SetText(subTreeName or "");
	self.Info:SetText(subTreeInfo or "");
end

TalentFrameHeaderMixin = {};

function TalentFrameHeaderMixin:SetHeaderText(text)
	self.Text:SetText(text);
end

TalentTreeSelectableButtonMixin = {};

function SelectableButtonMixin:SetTreeID(treeID)
	self.treeID = treeID;
	self:Update();
end

function SelectableButtonMixin:GetTreeID()
	return self.treeID;
end

function TalentTreeSelectableButtonMixin:Update()
	-- Implement in your derived mixin.
end

function TalentTreeSelectableButtonMixin:SetSelectedState(isSelected)
	-- Override in your derived mixin.
	SelectableButtonMixin.SetSelectedState(self, isSelected);
end

TalentFrameTreeSelectorMixin = {};

function TalentFrameTreeSelectorMixin:OnLoad()
	assert(self.buttonTemplate, "TalentFrameTreeSelectorMixin requires a buttonTemplate to be set as a key-value.");
	self.treeButtons = {};
	self.buttonGroup = CreateRadioButtonGroup();
	self:AddDynamicEventMethod(self.buttonGroup, ButtonGroupBaseMixin.Event.Selected, self.OnButtonSelected);
end

function TalentFrameTreeSelectorMixin:OnButtonSelected(button, _buttonIndex)
	self.treeSelectedCallback(button:GetTreeID());
end

function TalentFrameTreeSelectorMixin:SetTreeSelectedCallback(callback)
	self.treeSelectedCallback = callback;
end

function TalentFrameTreeSelectorMixin:SetTreeIDs(treeIDs, selectedTreeID)
	for i, treeID in ipairs(treeIDs) do
		local treeButton = self.treeButtons[i];
		if not treeButton then
			treeButton =  CreateFrame("Button", nil, self, self.buttonTemplate);
			treeButton.layoutIndex = i;
			self.treeButtons[i] = treeButton;
			self.buttonGroup:AddButton(treeButton);
		end

		treeButton:SetTreeID(treeID);
		treeButton:SetSelectedState(treeID == selectedTreeID)
	end

	for i = #treeIDs + 1, #self.treeButtons do
		self.treeButtons[i]:Hide();
	end
end

TalentFrameTreeSelectorHorizontalMixin = {};

function TalentFrameTreeSelectorHorizontalMixin:OnShow()
	BaseLayoutMixin.OnShow(self);
	CallbackRegistrantMixin.OnShow(self);
end

TalentFrameStarGridMixin = {};

function TalentFrameStarGridMixin:OnLoad()
	self.starPool = CreateTexturePool(self, "ARTWORK");
end

function TalentFrameStarGridMixin:SetStars(numFilled, totalStars)
	self.starPool:ReleaseAll();

	for i = 1, totalStars do
		local star, isNew = self.starPool:Acquire();
		if isNew then
			star:SetSize(20, 18);
		end

		star.layoutIndex = i;

		if i <= numFilled then
			star:SetAtlas("auctionhouse-icon-favorite", TextureKitConstants.IgnoreAtlasSize);
		else
			star:SetAtlas("auctionhouse-icon-favorite-off", TextureKitConstants.IgnoreAtlasSize);
		end

		star:Show();
	end

	self:Layout();
end
