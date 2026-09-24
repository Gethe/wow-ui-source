local CHALLENGES_PAGE_IDX = 2;

LegacySystemFrameMixin = {};

function LegacySystemFrameMixin:OnLoad()
	self:SetPortraitAtlasRaw("Legacy-up-c60");
	local portrait = self:GetPortrait();
	portrait:SetSize(45, 62);
	portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, 10);


	EventRegistry:RegisterCallback("Legacy.SelectPage", function(_, id)
		self:SelectPage(id);
		self:UpdateSmartNavFocus(id);
	 end, self);

	self:RegisterForTransitions();

	 self:SelectPage(1);
end

function LegacySystemFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();

	if InputUtil.IsGamepadUIEnabled() then
		local LegacyTreeTalentPanel = self.TreePage.LegacyTreeTraitPanel;
		LegacyTreeTalentPanel:RegisterCallback("TalentButtonReleased", function(_, button, forReinstantiation)
			self:TalentButtonReleased_TreePage(button, forReinstantiation);
		end, self);

		LegacyTreeTalentPanel:RegisterCallback("TalentButtonAcquired", function(_, button, forReinstantiation)
			self:TalentButtonAcquired_TreePage(button);
		end, self);

		EventRegistry:RegisterCallback("TalentFrameBase.ButtonsUpdated", function(_, treeId)
			self:TalentButtonsUpdated_TreePage();
		end, self);

		EventRegistry:RegisterCallback("Legacy.RefreshChallenges", function(_)
			self:OnChallengeRefresh();
		end, self);

		SmartNavigation:RegisterCallback("SelectedButtonUpdated", function()
			self:SmartNavSelectedButtonUpdated();
		end, self);
	end
end

function LegacySystemFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	if InputUtil.IsGamepadUIEnabled() then
		local LegacyTreeTalentPanel = self.TreePage.LegacyTreeTraitPanel;
		LegacyTreeTalentPanel:UnregisterCallback("TalentButtonReleased", self);
		LegacyTreeTalentPanel:UnregisterCallback("TalentButtonAcquired", self);

		EventRegistry:UnregisterCallback("TalentFrameBase.ButtonsUpdated", self);
		EventRegistry:UnregisterCallback("Legacy.RefreshChallenges", self);

		SmartNavigation:UnregisterCallback("SelectedButtonUpdated", self);
	end
end

function LegacySystemFrameMixin:SelectPage(id)
	self.currentPage = id;

	for i, page in ipairs(self.Pages) do
		page:SetShown(i == id);
	end

	for _, tab in ipairs(self.Tabs) do
		tab:SetChecked(tab:GetID() == id);
	end
end

function LegacySystemFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end

local function UpdateSmartNavFocus_RewardTrack(legacy, page)
	SmartNavigation:SelectButton(nil);

	local elements = page.LegacyRewardProgressFrame:GetElements();
	SmartNavigation:SelectButton(elements[1]);
end

local function UpdateSmartNavFocus_Challenge(legacy, page)
	SmartNavigation:SelectButton(nil);
	SmartNavigation:SelectFirstButton();

	SmartNavigation:SetScrollFrameForFrame(legacy, page.CategoryList.ScrollBox);
	GamepadScrollBarHint:SetOwner(page.CategoryList.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();
end

local function UpdateSmartNavFocus_Tree(legacy, page)
	SmartNavigation:SelectButton(nil);

	local treeButtons = page.LegacyTreeSelectionPanel.treeButtons;
	for i, button in ipairs(treeButtons) do
		if button:GetChecked() then
			SmartNavigation:SelectButton(button);
			break;
		end
	end
end

function LegacySystemFrameMixin:SmartNavSelectedButtonUpdated()
	if not self:IsShown() then
		return;
	end

	if self.currentPage ~= CHALLENGES_PAGE_IDX then
		return;
	end

	self.footers[self.currentPage]:Refresh();
	local button = SmartNavigation:GetCurrentButton();
	if button then
		if (button.buttonContext == "ButtonContext_LegacyChallenge") then
			SmartNavigation:SetScrollFrameForFrame(self, self.ChallengesPage.DetailPane.ScrollBox);
			GamepadScrollBarHint:SetOwner(self.ChallengesPage.DetailPane.ScrollBar.Track.Thumb, "CENTER");
		else
			SmartNavigation:SetScrollFrameForFrame(self, self.ChallengesPage.CategoryList.ScrollBox);
			GamepadScrollBarHint:SetOwner(self.ChallengesPage.CategoryList.ScrollBar.Track.Thumb, "CENTER");
		end
		GamepadScrollBarHint:Show();
	end
end

function LegacySystemFrameMixin:OnChallengeRefresh()
	if not self:IsShown() then
		return;
	end

	if self.currentPage ~= CHALLENGES_PAGE_IDX then
		return;
	end

	if SmartNavigation:GetCurrentButton() then
		return;
	end

	SmartNavigation:SelectFirstButton();
end

function LegacySystemFrameMixin:SetupGamepadRewardTrackFooter(navigateElements, toggleTooltips)
	local rewardTrackFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "LegacySystemFooter_RewardTrack");
	rewardTrackFooter:SetAnchorOffsets(0, -5);
	rewardTrackFooter:AddPromptedBinding(toggleTooltips);
	rewardTrackFooter:AddPromptedBinding(navigateElements);
	rewardTrackFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	rewardTrackFooter:Finalize();

	return rewardTrackFooter;
end

function LegacySystemFrameMixin:SetupGamepadChallengeFooter(navigateElements, toggleTooltips)
	local function FocusSearchBox()
		local searchBox = self.ChallengesPage.CategoryList.SearchBox;
		if searchBox.GamepadFocusIcon:IsShown() then
			SmartNavigation:SelectButton(searchBox);
			searchBox:SetFocus();
		end
	end
	local function ShouldShowFocusSearchBox()
		local button = SmartNavigation:GetCurrentButton();
		return button ~= self.ChallengesPage.CategoryList.SearchBox;
	end

	local focusSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, FocusSearchBox, nil);
	focusSearchBox:SetCustomPromptFrame(self.ChallengesPage.CategoryList.SearchBox.GamepadFocusIcon);
	focusSearchBox:AddCondition(ShouldShowFocusSearchBox);
	focusSearchBox:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local function OpenFilter()
		local filter = self.ChallengesPage.CategoryList.FilterDropdown;
		filter:MouseDown();
		filter:MouseUp();
	end

	local filterDropdown = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, OpenFilter, nil);
	filterDropdown:SetCustomPromptFrame(self.ChallengesPage.CategoryList.FilterDropdown.GamepadFocusIcon);

	local function LinkInChat()
		local button = SmartNavigation:GetCurrentButton();
		local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK);
		if activeChatFrame and activeChatFrame:IsShown() then
			activeChatFrame:SetGamepadFocus();
		end
		button:LinkInChat();
	end
	local function CanLinkInChat()
		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return nil;
		end
		if button.buttonContext ~= "ButtonContext_LegacyChallenge" then
			return nil;
		end
		return button:IsShown();
	end

	local linkInChat = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, LinkInChat, SOCIAL_SHARE_TEXT);
	linkInChat:AddCondition(CanLinkInChat);
	linkInChat:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local challengeFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "LegacySystemFooter_Challenge");
	challengeFooter:SetAnchorOffsets(0, -5);
	challengeFooter:AddStandardSelectPrompt();
	challengeFooter:AddPromptedBinding(linkInChat);
	challengeFooter:AddPromptedBinding(toggleTooltips);
	challengeFooter:AddPromptedBinding(navigateElements);
	challengeFooter:AddPromptedBinding(filterDropdown);
	challengeFooter:AddPromptedBinding(focusSearchBox);
	challengeFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	challengeFooter:Finalize();

	return challengeFooter;
end

function LegacySystemFrameMixin:SetupGamepadTreeFooter(navigateElements, toggleTooltips)
	local function CanAddPoint()
		local button = SmartNavigation:GetCurrentButton();
		return button and button:CanPurchaseRank();
	end
	local function AddPoint()
		local button = SmartNavigation:GetCurrentButton();
		if button:CanPurchaseRank() then
			button:PurchaseRank();
		end
	end

	local addPoint = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, AddPoint, GAMEPAD_TALENT_ADD_POINT);
	addPoint:AddButtonContext("ButtonContext_LegacyTreeTalent");
	addPoint:AddCondition(CanAddPoint);

	local function UndoChanges()
		self.TreePage.LegacyTreeTraitPanel.UndoButton:Click();
	end
	local function ShouldShowUndo()
		local LegacyTreeTalentPanel = self.TreePage.LegacyTreeTraitPanel;
		return LegacyTreeTalentPanel:HasAnyConfigChanges() and not LegacyTreeTalentPanel.isConfigReadyToApply;
	end

	local function ResetChanges()
		self.TreePage.LegacyTreeTraitPanel.ResetButton:Click();
	end
	local function ShouldShowReset()
		local resetButton = self.TreePage.LegacyTreeTraitPanel.ResetButton;
		return resetButton:IsShown() and resetButton:IsEnabled();
	end

	local function CanRemovePoint()
		local button = SmartNavigation:GetCurrentButton();
		return button and button:CanRefundRank();
	end
	local function RemovePoint()
		local button = SmartNavigation:GetCurrentButton();
		button:RefundRank();
	end
	local function RemovePointVis()
		local element = SmartNavigation:GetCurrentButton();
		if not (element and element.buttonContext and element.buttonContext == "ButtonContext_LegacyTreeTalent") then
			return PromptedBindingMixin.VISIBILITY_TYPE.NEVER;
		end
		return PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS;
	end
	local function CannotUndoOrReset()
		return not (ShouldShowUndo() or ShouldShowReset());
	end

	local removePoint = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "LegacyTree_RemovePoint_PromptedBinding");
	removePoint:AddFooterBinding({
		label = GAMEPAD_TALENT_REMOVE_POINT,
		buttonContexts = "ButtonContext_LegacyTreeTalent",
		visibilityType = RemovePointVis,
		conditions = { CanRemovePoint, CannotUndoOrReset },
	})
	removePoint:AddFooterFunction({
		buttonUpDown = GAMEPAD_BUTTON_ANY_UP,
		bindingFunctions = RemovePoint,
	})

	local undoChanges = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "LegacyTree_UndoChanges_PromptedBinding");
	undoChanges:AddFooterBinding({
		label = GAMEPAD_TALENT_REMOVE_POINT,
		buttonContexts = "ButtonContext_LegacyTreeTalent",
		visibilityType = RemovePointVis,
		conditions = { CanRemovePoint, ShouldShowUndo },
	})
	local undoChangesHoldBinding = undoChanges:AddCustomPromptBinding({
		frame = self.TreePage.LegacyTreeTraitPanel.GamepadUndoButton,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		conditions = ShouldShowUndo,
	})
	undoChanges:AddCustomPromptHoldFunction(undoChangesHoldBinding, {
		holdTime = 0.5,
		onTap = RemovePoint,
		onHeld = UndoChanges,
	})

	local function ResetChangesOnShowPassed()
		self.TreePage.LegacyTreeTraitPanel.ResetButton:ClearAllPoints();
		self.TreePage.LegacyTreeTraitPanel.ResetButton:SetPoint("LEFT", self.TreePage.LegacyTreeTraitPanel.GamepadResetButton, "RIGHT");
	end
	local function ResetChangesOnShowFailed()
		self.TreePage.LegacyTreeTraitPanel.ResetButton:ClearAllPoints();
		self.TreePage.LegacyTreeTraitPanel.ResetButton:SetPoint("LEFT", self.TreePage.LegacyTreeTraitPanel.ApplyButton, "RIGHT", 14, 0);
	end

	local resetChanges = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "LegacyTree_ResetChanges_PromptedBinding");
	resetChanges:AddFooterBinding({
		label = GAMEPAD_TALENT_REMOVE_POINT,
		buttonContexts = "ButtonContext_LegacyTreeTalent",
		visibilityType = RemovePointVis,
		conditions = { CanRemovePoint, ShouldShowReset },
	})
	local resetChangesHoldBinding = resetChanges:AddCustomPromptBinding({
		frame = self.TreePage.LegacyTreeTraitPanel.GamepadResetButton,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		conditions = ShouldShowReset,
		onShowPassed = ResetChangesOnShowPassed,
		onShowFailed = ResetChangesOnShowFailed,
	})
	resetChanges:AddCustomPromptHoldFunction(resetChangesHoldBinding, {
		holdTime = 0.5,
		onTap = RemovePoint,
		onHeld = ResetChanges,
	})

	local function Select()
		local element = SmartNavigation:GetCurrentButton();
		if element then
			element:MouseDown();
			element:MouseUp();
		end
	end
	local function ElementNotTalentButton()
		local element = SmartNavigation:GetCurrentButton();
		return not (element and element.buttonContext and element.buttonContext == "ButtonContext_LegacyTreeTalent");
	end

	local selectBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, Select, ACTION_LABEL_SELECT);
	selectBinding:AddCondition(ElementNotTalentButton);
	selectBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local function FocusSearchBox()
		local searchBox = self.TreePage.LegacyTreeTraitPanel.SearchBox;
		if searchBox.GamepadFocusIcon:IsShown() then
			SmartNavigation:SelectButton(searchBox);
			searchBox:SetFocus();
		end
	end
	local function ShouldShowFocusSearchBox()
		local button = SmartNavigation:GetCurrentButton();
		return button ~= self.TreePage.LegacyTreeTraitPanel.SearchBox;
	end

	local focusSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, FocusSearchBox, nil);
	focusSearchBox:SetCustomPromptFrame(self.TreePage.LegacyTreeTraitPanel.SearchBox.GamepadFocusIcon);
	focusSearchBox:AddCondition(ShouldShowFocusSearchBox);
	focusSearchBox:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local function CanApplyChanges()
		return self.TreePage.LegacyTreeTraitPanel.ApplyButton:IsEnabled();
	end
	local function ApplyChanges()
		self.TreePage.LegacyTreeTraitPanel.ApplyButton:Click();
	end

	local applyChanges = GamepadSharedUtility.CreateTapOrHoldPromptedBinding(GAMEPAD_FACE_LEFT, 0.5, nil, ApplyChanges, GAMEPAD_TALENT_APPLY);
	applyChanges:AddCondition(CanApplyChanges);
	applyChanges:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	local applyChangesIcon = GamepadMode.AddGamepadIconToButton(self.TreePage.LegacyTreeTraitPanel.ApplyButton, GAMEPAD_FACE_LEFT, { buttonHeightScale = (1.3), });
	GamepadMode.SetGamepadIconShown(applyChangesIcon, true);

	local treeFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "LegacySystemFooter_Tree");
	treeFooter:SetAnchorOffsets(0, -5);
	treeFooter:AddPromptedBinding(removePoint);
	treeFooter:AddPromptedBinding(undoChanges);
	treeFooter:AddPromptedBinding(resetChanges);
	treeFooter:AddPromptedBinding(applyChanges);
	treeFooter:AddPromptedBinding(addPoint);
	treeFooter:AddPromptedBinding(selectBinding);
	treeFooter:AddPromptedBinding(toggleTooltips);
	treeFooter:AddPromptedBinding(navigateElements);
	treeFooter:AddPromptedBinding(focusSearchBox);
	treeFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	treeFooter:Finalize();

	return treeFooter;
end

function LegacySystemFrameMixin:SetupGamepad()
	local toggleTooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, nil, PROMPT_TOGGLE_TOOLTIPS);

	local navigateElements = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD, nil, FRAME_ACTION_NAVIGATE);

	local rewardTrackFooter = self:SetupGamepadRewardTrackFooter(navigateElements, toggleTooltips);
	local challengeFooter = self:SetupGamepadChallengeFooter(navigateElements, toggleTooltips);
	local treeFooter = self:SetupGamepadTreeFooter(navigateElements, toggleTooltips);

	self.footers = {};
	table.insert(self.footers, rewardTrackFooter);
	table.insert(self.footers, challengeFooter);
	table.insert(self.footers, treeFooter);

	self.smartNavFocusHandlers = {};
	table.insert(self.smartNavFocusHandlers, UpdateSmartNavFocus_RewardTrack);
	table.insert(self.smartNavFocusHandlers, UpdateSmartNavFocus_Challenge);
	table.insert(self.smartNavFocusHandlers, UpdateSmartNavFocus_Tree);

	self.TabIndicators:SetUpTabs(self.Tabs);
end

function LegacySystemFrameMixin:InitializeGamepad()
	LegacySystemFrameCloseButton:Hide();

	self.ChallengesPage.CategoryList.SearchBox:ClearAllPoints();
	self.ChallengesPage.CategoryList.SearchBox:SetPoint("TOPLEFT", self.ChallengesPage.CategoryList, "TOPLEFT", 42, -8);
	self.ChallengesPage.CategoryList.SearchBox:SetPoint("RIGHT", self.ChallengesPage.CategoryList.FilterDropdown.GamepadFocusIcon, "LEFT", -2, 0);

	SmartNavigation_AddJumpNavigationOverride(self.ChallengesPage.CategoryList.SearchBox, SMART_NAV_INPUT_DIRECTION.DOWN, function()
		local panelInfo = SmartNavigation:GetPanelInfo(self, true);
		if not panelInfo then
			return true;
		end
		local button = SmartNavigation:FindTopLeftButton(panelInfo);
		if not button then
			return true;
		end
		return button;
	end);

	self.TreePage.LegacyTreeTraitPanel.UndoButton:ClearAllPoints();
	self.TreePage.LegacyTreeTraitPanel.UndoButton:SetPoint("LEFT", self.TreePage.LegacyTreeTraitPanel.GamepadUndoButton, "RIGHT");
end

function LegacySystemFrameMixin:TalentButtonReleased_TreePage(button, forReinstantiation)
	if forReinstantiation then
		return;
	end

	local parent = self.TreePage.LegacyTreeTraitPanel.ButtonsParent;
	if button:GetParent() ~= parent then
		return;
	end

	SmartNavigation_ClearJumpNavigationOverrides(button);
end

function LegacySystemFrameMixin:TalentButtonAcquired_TreePage(button)
	local parent = self.TreePage.LegacyTreeTraitPanel.ButtonsParent;
	if button:GetParent() ~= parent then
		return;
	end

	if not button.buttonContext then
		button.buttonContext = "ButtonContext_LegacyTreeTalent";
	end
end

function LegacySystemFrameMixin:TalentButtonsUpdated_TreePage()
	local tree = self.TreePage.LegacyTreeTraitPanel;

	local sortedButtons = tree:GetButtonsInOrder(function(button0, button1)
		local nodeInfo0 = button0:GetNodeInfo();
		local nodeInfo1 = button1:GetNodeInfo();
		if nodeInfo0.posX == nodeInfo1.posX then
			return nodeInfo0.posY > nodeInfo1.posY;
		end
		return nodeInfo0.posX < nodeInfo1.posX;
	end);

	local function GetCheckedSelectionButton()
		local treeButtons = LegacySystemFrame.TreePage.LegacyTreeSelectionPanel.treeButtons;
		for i, button in ipairs(treeButtons) do
			if button:GetChecked() then
				return button;
			end
		end
	end

	do
		local leftTopMostButton = nil;
		local leftMostX = nil;
		for i, button in ipairs(sortedButtons) do
			SmartNavigation_ClearJumpNavigationOverrides(button);

			local nodeInfo = button:GetNodeInfo();
			if leftMostX == nil then
				leftMostX = nodeInfo.posX;
			end

			if nodeInfo.posX <= leftMostX then
				if leftTopMostButton == nil then
					leftTopMostButton = button;
				else
					local ltmbNodeInfo = leftTopMostButton:GetNodeInfo();
					if nodeInfo.posY < ltmbNodeInfo.posY then
						leftTopMostButton = button;
					end
				end
			end
		end

		for i, button in ipairs(self.TreePage.LegacyTreeSelectionPanel.treeButtons) do
			SmartNavigation_AddJumpNavigationOverride(button, SMART_NAV_INPUT_DIRECTION.RIGHT, leftTopMostButton);
		end
	end

	-- Ensure everything in a col can jump up/down
	do
		local firstButtonInCol = nil;
		for i, button in ipairs(sortedButtons) do
			local nodeInfo = button:GetNodeInfo();
			if firstButtonInCol ~= nil and (nodeInfo.posX == firstButtonInCol:GetNodeInfo().posX) then
				SmartNavigation_AddBidirectionalJumpNavigationOverride(firstButtonInCol, SMART_NAV_INPUT_DIRECTION.UP, button);
			end
			firstButtonInCol = button;
		end
	end

	-- Ensure everything in a row can jump left/right
	table.sort(sortedButtons, function(button0, button1)
		local nodeInfo0 = button0:GetNodeInfo();
		local nodeInfo1 = button1:GetNodeInfo();
		if nodeInfo0.posY == nodeInfo1.posY then
			return nodeInfo0.posX < nodeInfo1.posX;
		end
		return nodeInfo0.posY < nodeInfo1.posY;
	end);

	do
		local firstButtonInRow = nil;
		for i, button in ipairs(sortedButtons) do
			local nodeInfo = button:GetNodeInfo();
			if firstButtonInRow ~= nil and (nodeInfo.posY == firstButtonInRow:GetNodeInfo().posY) then
				SmartNavigation_AddBidirectionalJumpNavigationOverride(firstButtonInRow, SMART_NAV_INPUT_DIRECTION.RIGHT, button);
			end
			firstButtonInRow = button;
		end
	end

	do
		local topRightMostButton = nil;
		for i, button in ipairs(sortedButtons) do
			local nodeInfo = button:GetNodeInfo();
			if topRightMostButton == nil then
				topRightMostButton = button;
			elseif nodeInfo.posY ~= topRightMostButton:GetNodeInfo().posY then
				local searchBox = self.TreePage.LegacyTreeTraitPanel.SearchBox;
				SmartNavigation_AddJumpNavigationOverride(searchBox, SMART_NAV_INPUT_DIRECTION.DOWN, topRightMostButton);
				SmartNavigation_AddJumpNavigationOverride(searchBox, SMART_NAV_INPUT_DIRECTION.LEFT, topRightMostButton);
				break;
			else
				topRightMostButton = button;
			end
		end
	end

	do
		local curY = nil;
		for i, button in ipairs(sortedButtons) do
			local nodeInfo = button:GetNodeInfo();
			if (curY == nil) or (nodeInfo.posY ~= curY) then
				curY = nodeInfo.posY;
				SmartNavigation_AddJumpNavigationOverride(button, SMART_NAV_INPUT_DIRECTION.LEFT, GetCheckedSelectionButton);
			end
		end
	end
end

function LegacySystemFrameMixin:FocusGamepad()
	self.TabIndicators:Show();

	self.TabIndicators:SetCurrentIndex(self.currentPage);
	self.TabIndicators:UpdateTabIndicators();

	self:UpdateSmartNavFocus(self.currentPage);
end

function LegacySystemFrameMixin:UnfocusGamepad()
	for i, footer in ipairs(self.footers) do
		footer:HideAndDeactivateBindings();
	end
	self.TabIndicators:Hide();
end

function LegacySystemFrameMixin:UpdateSmartNavFocus(pageId)
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	for i, footer in ipairs(self.footers) do
		if i == pageId then
			footer:ShowAndActivateBindings();
		else
			footer:HideAndDeactivateBindings();
		end
	end

	SmartNavigation:ClearLastTarget(self);
	SmartNavigation:SetScrollFrameForFrame(self, nil);

	self.smartNavFocusHandlers[pageId](self, self.Pages[pageId]);
end

LegacySystemFrameTabMixin = CreateFromMixins(SidePanelTabButtonMixin);

function LegacySystemFrameTabMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self.Icon:SetTexture(self.iconTexture);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			EventRegistry:TriggerEvent("Legacy.SelectPage", tab:GetID());
		end
	end);
end
