
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
