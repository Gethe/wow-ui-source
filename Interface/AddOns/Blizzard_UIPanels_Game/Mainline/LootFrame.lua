local ScrollBoxElementHeight = 46;
local ScrollBoxPad = 6;
local ScrollBoxSpacing = 2;

local FrameEvents =
{
	"LOOT_SLOT_CLEARED",
	"LOOT_SLOT_CHANGED",
};

local function TrySmartNavSelectFirstElementBelow(scrollBox, slotIndex)
	local lastSlotIndex = scrollBox:GetDataProviderSize();
	for i = slotIndex + 1, lastSlotIndex do
		local elementData = scrollBox:FindElementData(i);
		scrollBox:ScrollToElementDataIndex(i, nil, nil, true);
		local potentialNextValidElement = scrollBox:FindFrame(elementData);
		if (potentialNextValidElement:IsShown() and potentialNextValidElement.Item) then
			SmartNavigation:SelectButton(potentialNextValidElement.Item);
			return true;
		end
	end

	return false;
end

local function TrySmartNavSelectFirstElementAbove(scrollBox, slotIndex)
	for i = slotIndex - 1, 1, -1 do
		local elementData = scrollBox:FindElementData(i);
		scrollBox:ScrollToElementDataIndex(i, nil, nil, true);
		local potentialNextValidElement = scrollBox:FindFrame(elementData);
		if (potentialNextValidElement:IsShown() and potentialNextValidElement.Item) then
			SmartNavigation:SelectButton(potentialNextValidElement.Item);
			return true;
		end
	end

	return false;
end

LootFrameMixin = {};

function LootFrame_EscapePressed()
	if LootFrame:IsShown() then
		LootFrame:Hide();
		return true;
	end

	return false;
end

-- Loot can be shown outside the UIPanel manager (for example loot-under-mouse),
-- so keep an explicit ESC handler after CloseAllWindows for the remaining cases.
RegisterGameMenuEscHandler(GameMenuEscPriority.AddOnPost2, LootFrame_EscapePressed);

function LootFrameMixin:OnLoad()
	ScrollingFlatPanelMixin.OnLoad(self);
	EditModeSystemMixin.OnSystemLoad(self);

	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_CLOSED");

	local view = CreateScrollBoxListLinearView(ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxSpacing);

	local function Initializer(frame, elementData)
		frame:Init();

		frame.Item:SetScript("OnClick", function(button, buttonName, down)
			if IsModifiedClick() then
				local link = GetLootSlotLink(frame:GetSlotIndex());
				HandleModifiedItemClick(link);
			else
				if self:IsContextMenuActive() then
					Menu.GetManager():CloseMenus();
					self.contextMenuActive = false;
					return;
				end

				-- Values required by GroupLoot and MasterLoot frames. If these frames are returned
				-- to service, it would be ideal to expose these values through an API.
				local itemLink = GetLootSlotLink(frame:GetSlotIndex());
				self.selectedLootFrame = frame;
				self.selectedSlot = frame:GetSlotIndex();
				self.selectedItemLink = itemLink;
				self.selectedQuality = frame:GetQuality();
				self.selectedItemName = frame.Text:GetText();
				self.selectedTexture = button.icon:GetTexture();

				StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");

				LootSlot(frame:GetSlotIndex());

				EventRegistry:TriggerEvent("LootFrame.ItemLooted");
			end
		end);
	end

	view:SetElementFactory(function(factory, elementData)
		local lootSlotType = GetLootSlotType(elementData.slotIndex);
		if (lootSlotType == Enum.LootSlotType.Item) or (lootSlotType == Enum.LootSlotType.Currency) then
			factory("LootFrameItemElementTemplate", Initializer);
		elseif lootSlotType == Enum.LootSlotType.Money then
			factory("LootFrameMoneyElementTemplate", Initializer);
		elseif lootSlotType == Enum.LootSlotType.None then
			factory("LootFrameBaseElementTemplate");
		end
	end);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:SetShadowsFrameLevel(self.ScrollBox.ScrollTarget:GetFrameLevel() + 15);
	self.ScrollBox:SetShadowsScale(0.2);
	self.ScrollBox:GetUpperShadowTexture():SetTexCoord(0, 1, 1, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPLEFT", 30, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPRIGHT", -30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMLEFT", 30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMRIGHT", -30, 0);

	self:RegisterForTransitions();
end

function LootFrameMixin:OnHideAnimFinished()
	ScrollingFlatPanelMixin.OnHideAnimFinished(self);

	StaticPopup_Hide("LOOT_BIND");
end

function LootFrameMixin:CalculateElementsHeight()
	return ScrollUtil.CalculateScrollBoxElementExtent(self.ScrollBox:GetDataProviderSize(), ScrollBoxElementHeight, ScrollBoxSpacing);
end

function LootFrameMixin:OnEvent(event, ...)
	if event == "LOOT_OPENED" then
		local isAutoLoot, acquiredFromItem = ...;
		self.isAutoLoot = isAutoLoot;
		self.acquiredFromItem = acquiredFromItem;

		self:Open();

		if self:IsShown() then
			if acquiredFromItem then
				PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
			elseif IsFishingLoot() then
				PlaySound(SOUNDKIT.FISHING_REEL_IN);
			elseif self.ScrollBox:GetDataProvider():IsEmpty() then
				PlaySound(SOUNDKIT.LOOT_WINDOW_OPEN_EMPTY);
			end
		else
			local showUnopenableError = not self.isAutoLoot;
			CloseLoot(showUnopenableError);
		end

		self:RegisterEvent("UI_ERROR_MESSAGE");
	elseif event == "LOOT_SLOT_CLEARED" then
		local slotIndex = ...;
		local frame = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetSlotIndex() == slotIndex;
		end);

		if frame then
			if self.isAutoLoot and frame.SlideOutRightAnim then
				frame.SlideOutRightAnim:Play();
			else
				frame:Hide();
			end

			if (InputUtil.IsGamepadUIEnabled()) then
				--[[
					Smart Nav is focused on the frame's item subframe rather than the 
					overall container frame in order to display the tooltip. We only need
					to move the smart nav cursor if the cursor is on the button that was cleared.
				]]
				local smartNavFocusedButton = SmartNavigation:GetCurrentButton();
				if (smartNavFocusedButton ~= frame.Item) then
					return;
				end

				if (not TrySmartNavSelectFirstElementBelow(self.ScrollBox, slotIndex)) then
					TrySmartNavSelectFirstElementAbove(self.ScrollBox, slotIndex);
				end
			end
		end
	elseif event == "LOOT_SLOT_CHANGED" then
		local slotIndex = ...;
		local frame = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetSlotIndex() == slotIndex;
		end);

		if frame then
			frame:Init();
		end
	elseif event == "LOOT_CLOSED" then
		self:UnregisterEvent("UI_ERROR_MESSAGE");
		self:Close();
	elseif event == "UI_ERROR_MESSAGE" then
		local _, errorMessage = ...;
		if (errorMessage == ERR_INV_FULL) then
			self:UnregisterEvent("UI_ERROR_MESSAGE");

			if (InputUtil.IsGamepadUIEnabled() and self.isAutoLoot) then
				self:FocusGamepadFromAutoLoot();
			end
		end
	end
end

function LootFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, FrameEvents);
	if (self.acquiredFromItem) then
		GamepadMode.FrameControlsManager:DisableReturnToPlayerControl(self);
	else
		GamepadMode.FrameControlsManager:ReturnToPlayerControl(self);
	end
	GamepadMode.FrameControlsManager:FrameShown(self, true);
end

function LootFrameMixin:IsContextMenuActive()
	return self.contextMenuActive == true;
end

function LootFrameMixin:OnHide()
	GamepadMode.FrameControlsManager:FrameHidden(self);
	FrameUtil.UnregisterFrameForEvents(self, FrameEvents);

	self.ScrollBox:RemoveDataProvider();

	CloseLoot();

	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");

	EventRegistry:TriggerEvent("LootFrame.Hide");
end

function LootFrameMixin:Open()
	local dataProvider = CreateDataProvider();
	for slotIndex = 1, GetNumLootItems() do
		local texture, item, quantity, currencyID, itemQuality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);

		if currencyID then
			item, texture, quantity, itemQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, itemQuality);
		end

		local quality = itemQuality or Enum.ItemQuality.Common;

		local group = isCoin and 1 or 0;
		dataProvider:Insert({slotIndex = slotIndex, group = group, quality = quality});
	end

	--dataProvider:SetSortComparator(function(a, b)
	--	if a.group ~= b.group then
	--		return a.group > b.group;
	--	end
	--
	--	if a.quality ~= b.quality then
	--		return a.quality > b.quality;
	--	end
	--
	--	return a.slotIndex < b.slotIndex;
	--end);
	--
	self.ScrollBox:SetDataProvider(dataProvider);

	if GetCVarBool("lootUnderMouse") or InputUtil.IsGamepadUIEnabled() then
		-- ShowUIPanel is not called here because we don't
		-- want the repositioning behavior that occurs.
		if CanAutoSetGamePadCursorControl(true) then
			SetGamePadCursorControl(true);
		end

		local x, y = GetCursorPosition();
		x = x / (self:GetEffectiveScale()) - 30;
		y = math.max((y / self:GetEffectiveScale()) + 50, 350);
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x, y);

		self:Show();
		self:Raise();
	else
		ShowUIPanel(self);

		-- Position according to edit mode data
		self:ApplySystemAnchor();
	end

	-- Avoid interfering with the visibility managed above.
	local skipShow = true;
	ScrollingFlatPanelMixin.Open(self, skipShow);
end

function LootFrameMixin:UpdateShownState()
	if self.isInEditMode then
		self:StopAllAnimations();
		self:SetAlpha(1);
		self:SetHeight(self:GetPanelMaxHeight());
		self:Show();
	else
		self:SetShown(self.isOpen);
	end
end

function LootFrameMixin:FocusGamepadFromAutoLoot()
	self.isAutoLoot = false;
	GamepadMode.FrameControlsManager:FocusFrame(self);


	-- Loop through the available loot elements and place the smart cursor on the first item that is available for manual looting.
	local scrollBox = self.ScrollBox;
	local lastPotentialSlotIndex = scrollBox:GetDataProviderSize();
	for i = 1, lastPotentialSlotIndex do
		local elementData = scrollBox:FindElementData(i);
		scrollBox:ScrollToElementDataIndex(i, nil, nil, true);
		local potentialNextValidElement = scrollBox:FindFrame(elementData);

		local potentialElementFrameIsPlayingAutoLootingAnim = false;
		if (potentialNextValidElement.SlideOutRightAnim and potentialNextValidElement.SlideOutRightAnim:IsPlaying()) then
			potentialElementFrameIsPlayingAutoLootingAnim = true; -- This item element is being autolooted.

			-- Force the element animation to stop and call its on finish script so that as we scroll, the animation doesn't interfere with reused element frames.
			potentialNextValidElement.SlideOutRightAnim:Stop();
			potentialNextValidElement.SlideOutRightAnim:OnAnimFinished();
		end

		if (potentialNextValidElement:IsShown() and potentialNextValidElement.Item and (not potentialElementFrameIsPlayingAutoLootingAnim)) then
			SmartNavigation:SelectButton(potentialNextValidElement.Item);
			--[[
				There may not have been any visible buttons in the scrollbox to focus on during the initial focus frame call above, 
				which is needed so that SelectButton doesn't cause any issues when smart nav doesn't have an activeInfo table, so the cursor 
				may have been hidden at this point.
			]]
			SmartNavigation:ShowCursor(true);
			return;
		end
	end

	-- No item could be focused.
	self:Hide();
end

function LootFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function LootFrameMixin:SetupGamepad()
	-- Ensures that the last button focused on the loot frame isn't lost when smart nav removes panel info.
	SmartNavigation:SetSmartNavPanelInfoAddedCallback(self, GenerateClosure(self.OnSmartNavPanelInfoAdded, self));
	SmartNavigation:SetSmartNavPanelInfoRemovedCallback(self, GenerateClosure(self.OnSmartNavPanelInfoRemoved, self));

	local lootPromptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, FRAME_ACTION_LOOT);

	local AutoLoot = function() C_LootFrame.TryAutoLoot(); end;
	local lootAllPromptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, AutoLoot, FRAME_ACTION_LOOT_ALL);

	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "LootFrameFooter");
	self.gamepadFooter:AddPromptedBinding(lootPromptedBinding);
	self.gamepadFooter:AddPromptedBinding(lootAllPromptedBinding);
	self.gamepadFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	self.gamepadFooter:SetAnchorOffsets(3, 0);

	self.gamepadFooter:Finalize();
end

function LootFrameMixin:InitializeGamepad()
	self.ClosePanelButton:Hide();
end

function LootFrameMixin:UninitializeGamepad()
	self.ClosePanelButton:Show();
end

function LootFrameMixin:FocusGamepad()
	self.gamepadFooter:ShowAndActivateBindings();

	-- Check if the last button is still valid. If it is, leave it alone. Otherwise change it to another button and scroll.
	local lastButton;
	local panelInfo = SmartNavigation:GetPanelInfo(self, true);
	if (panelInfo) then
		lastButton = SmartNavigation:GetLastButtonForPanelInfo(panelInfo);
	end

	if (lastButton) then	-- Should only not exist if the loot panel is opened from a closed state.
		local lastSelectedLootElement = lastButton:GetParent();
		local lastSelectedSlotIndex = lastSelectedLootElement:GetSlotIndex();

		-- Is the last selected slot still valid for smart nav to focus on?
		local lastSelectedElementData = self.ScrollBox:FindElementData(lastSelectedSlotIndex);
		self.ScrollBox:ScrollToElementDataIndex(lastSelectedSlotIndex, nil, nil, true);
		local lastSelectedElementFrame = self.ScrollBox:FindFrame(lastSelectedElementData);
		if (lastSelectedElementFrame:IsShown() and lastSelectedElementFrame.Item) then
			return; -- The last button specified is valid and should be focused by smart nav when navigation is enabled.
		end

		-- Update the last button to return focus to the first valid element below the one that is no longer valid.
		local lastPotentialSlotIndex = self.ScrollBox:GetDataProviderSize();
		for i = lastSelectedSlotIndex + 1, lastPotentialSlotIndex do
			local elementData = self.ScrollBox:FindElementData(i);
			self.ScrollBox:ScrollToElementDataIndex(i, nil, nil, true);
			local potentialNextValidElement = self.ScrollBox:FindFrame(elementData);
			if (potentialNextValidElement:IsShown() and potentialNextValidElement.Item) then
				SmartNavigation:SetLastButtonForPanelInfo(panelInfo, potentialNextValidElement.Item);
				return;
			end
		end

		-- No elements below were valid, so return focus to the first valid element above the one that is no longer valid.
		for i = lastSelectedSlotIndex - 1, 1, -1 do
			local elementData = self.ScrollBox:FindElementData(i);
			self.ScrollBox:ScrollToElementDataIndex(i, nil, nil, true);
			local potentialNextValidElement = self.ScrollBox:FindFrame(elementData);
			if (potentialNextValidElement:IsShown() and potentialNextValidElement.Item) then
				SmartNavigation:SetLastButtonForPanelInfo(panelInfo, potentialNextValidElement.Item);
				return;
			end
		end
	end
end

function LootFrameMixin:UnfocusGamepad()
	self.gamepadFooter:HideAndDeactivateBindings();
end

function LootFrameMixin:SmartNavigationCloseHandler()
	self.ClosePanelButton:Click();
end

function LootFrameMixin:OnSmartNavPanelInfoAdded(panelInfo)
	SmartNavigation:SetLastButtonForPanelInfo(panelInfo, self.smartNavLastButtonFocused);
	self.smartNavLastButtonFocused = nil;
end

function LootFrameMixin:OnSmartNavPanelInfoRemoved(panelInfo)
	-- We only care about updating the last button if the loot frame is still visible.
	if (self:IsShown()) then
		self.smartNavLastButtonFocused = SmartNavigation:GetLastButtonForPanelInfo(panelInfo);
	end
end

LootFrameBaseElementMixin = {};

function LootFrameBaseElementMixin:GetSlotIndex()
	local elementData = self:GetElementData();
	return elementData.slotIndex;
end

function LootFrameBaseElementMixin:GetQuality()
	local elementData = self:GetElementData();
	return elementData.quality;
end

function LootFrameBaseElementMixin:GetItemSlotType()
	return GetLootSlotType(self:GetSlotIndex());
end

function LootFrameBaseElementMixin:Init()
end

LootFrameElementMixin = CreateFromMixins(LootFrameBaseElementMixin);

function LootFrameElementMixin:OnLoad()
	self.Item:SetScript("OnEnter", GenerateClosure(self.OnEnter, self));
	self.Item:SetScript("OnLeave", GenerateClosure(self.OnLeave, self));

	self.Item:SetScript("OnMouseDown", function(button)
		self.PushedNameFrame:Show();
	end);

	self.Item:SetScript("OnMouseUp", function(button)
		self.PushedNameFrame:Hide();
	end);

	self.Item:SetScript("OnUpdate", function(button)
		if GameTooltip:IsOwned(self) then
			self:OnEnter();
		end

		CursorOnUpdate(self);
	end);

	self:SetupCustomSmartNavJumps();
end

function LootFrameElementMixin:Init()
	local slotIndex = self:GetSlotIndex();
	local texture, item, quantity, currencyID, itemQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(slotIndex);
	if currencyID then
		item, texture, quantity, itemQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, itemQuality);
	end

	self.Text:SetText(item);

	local quality = itemQuality or Enum.ItemQuality.Common;
	local colorData = nil;
	if self.ignoreColorOverrides then
		colorData = ColorManager.GetDefaultColorDataForItemQuality(quality);
	else
		colorData = ColorManager.GetColorDataForItemQuality(quality);
	end

	if colorData then
		self.Text:SetVertexColor(colorData.color:GetRGB());
		self.NameFrame:SetVertexColor(colorData.color:GetRGB());
	end

	if questID and not isActive then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
		self.IconQuestTexture:Show();
	elseif questID or isQuestItem then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
		self.IconQuestTexture:Show();
		else
		self.IconQuestTexture:Hide();
		end

	if locked then
		SetItemButtonTextureVertexColor(self.Item, 0.9, 0, 0);
		SetItemButtonNormalTextureVertexColor(self.Item, 0.9, 0, 0);
	else
		SetItemButtonTextureVertexColor(self.Item, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self.Item, 1.0, 1.0, 1.0);
	end

	local link = GetLootSlotLink(slotIndex);
	local suppressOverlays = false;
	local isBound = false;
	SetItemButtonQuality(self.Item, quality, link, suppressOverlays, isBound, self.ignoreColorOverrides);
	self.Item.icon:SetTexture(texture);

	if quantity > 1 then
		self.Item.Count:SetText(quantity);
		self.Item.Count:Show();
		else
		self.Item.Count:Hide();
	end

	self.Item:Enable();

	self.SlideOutRightAnim:Stop();
	self.ShowAnim:Play();
end

function LootFrameElementMixin:OnEnter()
	self.HighlightNameFrame:Show();
end

function LootFrameElementMixin:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide();
	end

	ResetCursor();

	self.HighlightNameFrame:Hide();
end

function LootFrameElementMixin:SmartNavReselect(scrollBox, slotIndex)
	local elementData = scrollBox:FindElementData(slotIndex);
	scrollBox:ScrollToElementDataIndex(slotIndex, nil, nil, true);
	local currentElement = scrollBox:FindFrame(elementData);
	if (currentElement) then
		SmartNavigation:SelectButton(currentElement.Item);
	end
end

function LootFrameElementMixin:OnSmartNavUp(scrollBox)
	local slotIndex = self:GetSlotIndex();

	if (TrySmartNavSelectFirstElementAbove(scrollBox, slotIndex)) then
		return; -- An element above this one was focused by smart nav.
	end

	-- If we couldn't focus an element above, keep focus on this button.
	self:SmartNavReselect(scrollBox, slotIndex);
end

function LootFrameElementMixin:OnSmartNavDown(scrollBox)
	local slotIndex = self:GetSlotIndex();

	if (TrySmartNavSelectFirstElementBelow(scrollBox, slotIndex)) then
		return; -- An element below this one was focused by smart nav.
	end

	-- If we couldn't focus an element below, keep focus on this button.
	self:SmartNavReselect(scrollBox, slotIndex);
end

function LootFrameElementMixin:SetupCustomSmartNavJumps()
	local itemIcon = self.Item;
	local scrollBox = LootFrame.ScrollBox;

	--[[
		The following lines provide a workaround for smart navigation scrolling in the loot frame
		which is necessary due to the potential for frame-length gaps between lootable items in the
		Loot frame's scrollBox.

		If the only valid items for smart nav to jump to are invisible because they are above or below
		the current scrollbox view, smart nav's navigation logic will treat them as invalid when attempting
		to use traditional navigation methods.

		By marking the frame as a non-collapsing scrollbox element and specifying custom jump navigation overrides
		we can get around Smart Nav's button validation logic and through the outgoing directional navigation callbacks
		which are run when the jump navigation occurs, we can set the proper button for smart nav to land on after we
		handle the additional logic to make sure it is displayed in the scrollBox view.
	]]
	SmartNavigation_AddJumpNavigationOverride(itemIcon, SMART_NAV_INPUT_DIRECTION.UP, itemIcon);
	SmartNavigation_AddJumpNavigationOverride(itemIcon, SMART_NAV_INPUT_DIRECTION.DOWN, itemIcon);
	SmartNavigation_MarkFrameNonCollapsingScrollBoxElement(itemIcon);
	SmartNavigation_RegisterOutgoingDirNavCallback(itemIcon, SMART_NAV_INPUT_DIRECTION.UP, GenerateClosure(self.OnSmartNavUp, self, scrollBox));
	SmartNavigation_RegisterOutgoingDirNavCallback(itemIcon, SMART_NAV_INPUT_DIRECTION.DOWN, GenerateClosure(self.OnSmartNavDown, self, scrollBox));
end

LootFrameElementSlideOutRightAnimMixin = {};

function LootFrameElementSlideOutRightAnimMixin:OnAnimFinished()
	local lootFrameElement = self:GetParent();
	lootFrameElement:Hide();	-- Keeps consistency with what happens to the non-autolooted loot elements when they are looted.
end

LootFrameItemElementMixin = CreateFromMixins(LootFrameElementMixin);

function LootFrameItemElementMixin:Init()
	LootFrameElementMixin.Init(self);

	local elementData = self:GetElementData();
	self.QualityText:SetText(_G[string.format("ITEM_QUALITY%s_DESC", elementData.quality)]);
end

function LootFrameItemElementMixin:OnEnter()
	LootFrameElementMixin.OnEnter(self);
	if LootFrame:IsContextMenuActive() then
		return;
	end

	local lootSlotType = self:GetItemSlotType();
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("LEFT", self, "RIGHT");

	if lootSlotType == Enum.LootSlotType.Currency then
		GameTooltip:SetLootCurrency(self:GetSlotIndex());
		CursorUpdate(self);
	elseif lootSlotType == Enum.LootSlotType.Item then
		GameTooltip_SuppressAutomaticCompareItem(GameTooltip);
		GameTooltip:SetLootItem(self:GetSlotIndex());
		CursorUpdate(self);
	end
end
