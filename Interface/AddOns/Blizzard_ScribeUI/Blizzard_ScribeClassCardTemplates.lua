
ScribeClassCardMixin = {};

function ScribeClassCardMixin:Init(classID)
	self.classID = classID;
	self.classInfo = self:GetClassInfoFromClassID(classID);

	self.PreviewHoverController:SetOnSetControllerEnabled(function(_enabled)
		if self:IsSelected() then
			self.ClassInfoOverlay:Hide();
		elseif not self:IsMouseOver() then
			self.ClassInfoOverlay:Show();
		end
	end);

	self.PreviewHoverController:AddAffectedFrame(self.ClassInfoOverlay);

	self:UpdateText();
	self:UpdateTextures();

	self.ActivateClassButton:SetScript("OnClick", function()
		local locked = true;
		EventRegistry:TriggerEvent("ScribeFrame.SetUILocked", locked, self.classID);
		C_ScribeUI.SetCurrClassID(self.classID);
	end)

	self.TalentTree:Init(self.classID, self.classInfo.traitTreeID);

	self.initialized = true;
end

function ScribeClassCardMixin:OnShow()
	if self.initialized then
		self:UpdateStatusBar();
		self:UpdateActivateClassButtonEnabled();
	else
		self:Hide();
	end
end

function ScribeClassCardMixin:GetClassID()
	return self.classID;
end

function ScribeClassCardMixin:GetClassInfo()
	return self.classInfo;
end

function ScribeClassCardMixin:GetClassInfoFromClassID(classID)
	return C_ScribeUI.GetClassInfoFromClassID(classID);
end

function ScribeClassCardMixin:UpdateText()
	self.BGHeader.BGClassName:SetText(self.classInfo.className);

	self.ClassInfoOverlay.ClassName:SetText(self.classInfo.className);
	self.ClassInfoOverlay.ClassDesc:SetText(self.classInfo.classDescription);
end

function ScribeClassCardMixin:UpdateStatusBar()
	local treeNodes = self.TalentTree:GetTreeNodes();
	local configID = self.TalentTree:GetConfigID()
	local totalRanks = 0;
	local totalActiveRanks = 0;
	if treeNodes and configID then
		for _i, nodeID in ipairs(treeNodes) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
			if nodeInfo then
				totalRanks = totalRanks + nodeInfo.maxRanks;
				totalActiveRanks = totalActiveRanks + nodeInfo.activeRank;
			end
		end
	end

	self.ClassInfoOverlay.ProgressBar:SetStatusBarColor(0.63, 0.09, 0.09);
	self.ClassInfoOverlay.ProgressBar:SetMinMaxValues(0, totalRanks);
	self.ClassInfoOverlay.ProgressBar:SetValue(totalActiveRanks);

	self.ClassInfoOverlay.ProgressBar.Label:SetText(string.format(SCRIBE_PROGRESS_BAR_FORMAT, totalActiveRanks, totalRanks));

	self.ClassInfoOverlay.ProgressBar.Spark:SetPoint("CENTER", self.ClassInfoOverlay.ProgressBar.BarTexture, "RIGHT", 0, 0);
end

function ScribeClassCardMixin:UpdateTextures()
	self.Background:SetAtlas(self.classInfo.classTextureAtlasName, TextureKitConstants.UseAtlasSize);
	self.Background:Show();

	self.ClassInfoOverlay.Texture:SetAtlas(self.classInfo.classTextureAtlasName .. "-Weapon", TextureKitConstants.UseAtlasSize);
	self.ClassInfoOverlay.Texture:Show();
end

function ScribeClassCardMixin:SetSelected(selected)
	self.selected = selected;
	self.PreviewHoverController:SetControllerEnabled(not selected);
	self.TalentTree:SetDisplayOnly(self.displayOnly or not selected);

	self:UpdateActivateClassButtonShown();
	self:UpdateLockedText();
end

function ScribeClassCardMixin:SetUILocked(locked)
	self.isUILocked = locked;
	self.TalentTree:SetUILocked(locked);

	self:UpdateActivateClassButtonEnabled();
	if not locked then
		self:UpdateLockedText();
	end
end

function ScribeClassCardMixin:SetDisplayOnly(displayOnly)
	self.displayOnly = displayOnly;
	self.TalentTree:SetDisplayOnly(displayOnly or not self.selected);

	-- These calls need to occur after the TalentTree sets display only
	-- This is because they depend on that value to update properly
	self:UpdateActivateClassButtonShown();
	self:UpdateActivateClassButtonEnabled();
	self:UpdateLockedText();
end

function ScribeClassCardMixin:UpdateActivateClassButtonShown()
	self.ActivateClassButton:SetShown(not self.displayOnly and not self.selected);
end

function ScribeClassCardMixin:UpdateActivateClassButtonEnabled()
	local isLocked, lockedMessage = self.TalentTree:IsLocked();
	self.ActivateClassButton:SetDisabledTooltip(lockedMessage, "ANCHOR_RIGHT");
	-- Non-selected trees are display-only, but their class activation button remains usable.
	self.ActivateClassButton:SetEnabled(self:IsActivatable());
end

function ScribeClassCardMixin:UpdateLockedText()
	local isLocked, lockedMessage = self.TalentTree:IsLocked();
	local showLockedText = self.selected and isLocked and lockedMessage ~= nil;
	if showLockedText then
		self.TalentLockedText:SetText(lockedMessage);
	end
	self.TalentLockedText:SetShown(showLockedText);
end

function ScribeClassCardMixin:IsActivatable()
	return not self.displayOnly and not self.isUILocked;
end

function ScribeClassCardMixin:IsDisplayOnly()
	return self.displayOnly;
end

function ScribeClassCardMixin:IsSelected()
	return self.selected;
end

ScribeClassTalentFrameMixin = {};

local SCRIBE_CLASS_TALENT_FRAME_EVENTS = {
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
	"TRY_PURCHASE_TO_NODE_PARTIAL_SUCCESS",
};

function ScribeClassTalentFrameMixin:OnLoad()
	self:SetTreeCurrencyDisplayTextCallback(TalentFrameUtil.GenerateTreeCurrencyDisplayCallback(24, 24));

	self:SetButtonOverlayTemplateCallback(function(_talentButton)
		return "SpellTypeIconOverlayTemplate";
	end);

	TalentFrameBaseMixin.OnLoad(self);
end

function ScribeClassTalentFrameMixin:Init(classID, traitTreeID)
	self.classID = classID;
	self.traitTreeID = traitTreeID;

	self:UpdateTraitTree();
end

function ScribeClassTalentFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, SCRIBE_CLASS_TALENT_FRAME_EVENTS);

	self:UpdateTreeCurrencyInfo();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);

	local shown = true;
	EventRegistry:TriggerEvent("ScribeClassTalentFrame.VisibilityUpdated", shown, self.classID);
end

function ScribeClassTalentFrameMixin:OnHide()
	-- We need this to occur before calling the base to clean up some functionality
	local shown = false;
	EventRegistry:TriggerEvent("ScribeClassTalentFrame.VisibilityUpdated", shown, self.classID);

	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, SCRIBE_CLASS_TALENT_FRAME_EVENTS);

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);
end

function ScribeClassTalentFrameMixin:SetDisplayOnly(displayOnly)
	self.isDisplayOnly = displayOnly;
	self:UpdateTraitTree();
	self:UpdateDisplayOnly();
end

function ScribeClassTalentFrameMixin:SetUILocked(locked)
	self.isUILocked = locked;
	self:UpdateDisplayOnly();
end

function ScribeClassTalentFrameMixin:UpdateDisplayOnly()
	if not self:IsActivatable() then
		self.AttemptConfigOperation = TalentFrameDisplayOnlyMixin.AttemptConfigOperation;
	else
		self.AttemptConfigOperation = AutoCommitTraitFrameMixin.AttemptConfigOperation;
	end
end

function ScribeClassTalentFrameMixin:UpdateTraitTree()
	if not self.traitTreeID then
		return;
	end

	local configID = C_Traits.GetConfigIDByTreeID(self.traitTreeID);
	local forceUpdate = true;
	self:SetConfigID(configID, forceUpdate);
end

function ScribeClassTalentFrameMixin:SetConfigID(configID, forceUpdate)
	-- Overrides TalentFrameBaseMixin:SetConfigID and should match implementation
	if not forceUpdate and (configID == self:GetConfigID()) then
		return;
	end

	local configInfo = configID and C_Traits.GetConfigInfo(configID) or nil;
	if not configInfo then
		return;
	end

	self.configurationInfo = configInfo;

	local forceTreeUpdate = true;
	self:SetTalentTreeID(self.traitTreeID, forceTreeUpdate);
end

function ScribeClassTalentFrameMixin:SetTalentTreeID(treeID, forceUpdate)
	TalentFrameBaseMixin.SetTalentTreeID(self, treeID, forceUpdate);

	EventRegistry:TriggerEvent("ScribeClassTalentFrame.SetTreeID", treeID, self:GetConfigID());
end

function ScribeClassTalentFrameMixin:IsLocked()
	if self.isUILocked then
		return true;
	end

	local func = self.isDisplayOnly and TalentFrameDisplayOnlyMixin.IsLocked or AutoCommitTraitFrameMixin.IsLocked;
	local locked, message = func(self);
	if locked and self.isDisplayOnly then
		-- If the Class Card itself is display only, it means that we're looking at it from a non-modifiable state
		local classCard = self:GetParent();
		message = classCard:IsDisplayOnly() and SCRIBE_TALE_IN_PROGRESS_WARNING;
	end

	return locked, message;
end

function ScribeClassTalentFrameMixin:IsActivatable()
	return not self.isDisplayOnly and not self.isUILocked;
end
