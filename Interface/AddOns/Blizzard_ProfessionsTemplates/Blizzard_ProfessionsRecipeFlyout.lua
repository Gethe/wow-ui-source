local MaxColumns = 3;
local MaxRows = 6;
local MaxUnscrolledCount = MaxColumns * MaxRows;
local HideUnavailableCvar = "professionsFlyoutHideUnowned";

ProfessionsItemFlyoutButtonMixin = {};

function ProfessionsItemFlyoutButtonMixin:Init(elementData, onElementEnabledImplementation, onElementValidImplementation)
	local item = elementData.item;
	local itemLocation = elementData.itemLocation;
	if not itemLocation then
		itemLocation = item:GetItemLocation();
	end

	if not itemLocation and elementData.itemGUID then
		itemLocation = C_Item.GetItemLocation(elementData.itemGUID);
	end

	if itemLocation then
		self:SetItemLocation(itemLocation);
	else
		self:SetItem(item:GetItemID());
	end
	
	-- Stackable items would all normally be accumulated, however in the case of salvage targets, the stacks
	-- cannot be combined because the craft API requires a specific item guid target, and that prevents us from
	-- merging multiple item stacks together to fulfill the reagent count requirement.
	local count = 0;
	local forceAccumulateInventory = elementData.forceAccumulateInventory;
	local accumulateInventory = forceAccumulateInventory or not itemLocation or (item:IsStackable() and not elementData.onlyCountStack);
	if accumulateInventory then
		count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
	elseif itemLocation then
		count = C_Item.GetStackCount(itemLocation);
	end

	local showCount = forceAccumulateInventory or C_Item.GetItemMaxStackSizeByID(item:GetItemID()) > 1;
	self:SetItemButtonCount(showCount and count or 1);
	
	local valid = (onElementValidImplementation == nil) or onElementValidImplementation(self, elementData);
	local enabled = valid and count > 0;
	if onElementEnabledImplementation then
		enabled = onElementEnabledImplementation(self, elementData, count);
	end

	if valid then
		SetItemButtonTextureVertexColor(self, 1, 1, 1);
		SetItemButtonNormalTextureVertexColor(self, 1, 1, 1);
	else
		SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
		SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
	end

	self.enabled = enabled;
	self:DesaturateHierarchy(enabled and 0 or 1);
end

ProfessionsItemFlyoutMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsItemFlyoutMixin:GenerateCallbackEvents(
{
    "UndoClicked",
    "ItemSelected",
    "ShiftClicked",
});

local ProfessionsItemFlyoutEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function ProfessionsItemFlyoutMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.Text:SetText(PROFESSIONS_PICKER_NO_AVAILABLE_REAGENTS);
	self.HideUnownedCheckBox.text:SetText(PROFESSIONS_HIDE_UNOWNED_REAGENTS);
	self.HideUnownedCheckBox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		SetCVar(HideUnavailableCvar, checked);
		self:InitializeContents();
		PlaySound(SOUNDKIT.UI_PROFESSION_HIDE_UNOWNED_REAGENTS_CHECKBOX);
	end);

	local view = CreateScrollBoxListGridView(MaxColumns);
	local padding = 3;
	local spacing = 3;
	view:SetPadding(padding, padding, padding, padding, spacing, spacing);
	view:SetElementInitializer("ProfessionsItemFlyoutButtonTemplate", function(button, elementData)
		button:Init(elementData, self.OnElementEnabledImplementation, self.GetElementValidImplementation);

		button:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
			self.OnElementEnterImplementation(elementData, GameTooltip);
			GameTooltip:Show();
		end);

		button:SetScript("OnLeave", GameTooltip_Hide);

		button:SetScript("OnClick", function()
			if IsShiftKeyDown() then
				self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.ShiftClicked, self, elementData);
			else
				if button.enabled then
					self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.ItemSelected, self, elementData);
					CloseProfessionsItemFlyout();
				end
			end
		end);
	end);

	self.UndoItem:SetScript("OnClick", function(button, buttonName, down)
		if not IsShiftKeyDown() then
			self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.UndoClicked, self);
			CloseProfessionsItemFlyout();
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsItemFlyoutMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
end

function ProfessionsItemFlyoutMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
	
	self:UnregisterEvents();
	self:ClearHandlers();

	self.owner = nil;
	--[[
		NOTE: OnHide triggers when the frame is no longer visible, not when it is no longer shown.
		This frame may become non-visible because its parent gets hidden, but it may itself still be shown.
		Setting a nil parent when shown, even if not visible, causes the frame to become visisble.
		This Hide call sets the frame to be explicitly hidden, and therefore not become visible when we nil out the parent.
	]]
	self:Hide();
	self:SetParent(nil);
end

function ProfessionsItemFlyoutMixin:ClearHandlers()
	self.GetElementsImplementation = nil;
	self.OnElementEnterImplementation = nil;
	self.OnElementEnabledImplementation = nil;
	self.GetElementValidImplementation = nil;
	self.GetUndoElementImplementation = nil;
end

function ProfessionsItemFlyoutMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		if not isRightButton and DoesAncestryInclude(self.owner, mouseFocus) then
			return;
		end

		if isRightButton or (not DoesAncestryInclude(self, mouseFocus) and mouseFocus ~= self) then
			CloseProfessionsItemFlyout();
		end
	end
end

function ProfessionsItemFlyoutMixin:InitializeContents()
	local cannotModifyHideUnavailable, alwaysShowUnavailable = false, false;
	if self.transaction then
		local recipeID = self.transaction:GetRecipeID();
		cannotModifyHideUnavailable, alwaysShowUnavailable = C_TradeSkillUI.GetHideUnownedFlags(recipeID);
	end
	
	local canShowCheckBox = self.canModifyFilter and not cannotModifyHideUnavailable;
	self.HideUnownedCheckBox:SetShown(canShowCheckBox);

	local hideUnavailableCvar = GetCVarBool(HideUnavailableCvar);
	if canShowCheckBox then
		self.HideUnownedCheckBox:SetChecked(hideUnavailableCvar);
	end

	local undoElement = nil;
	if self.GetUndoElementImplementation then
		undoElement = self.GetUndoElementImplementation();
	end
	local hasUndoElement = undoElement ~= nil;
	self.UndoItem:SetShown(hasUndoElement);
	self.UndoButton:SetShown(hasUndoElement);

	local hideUnavailable;
	if cannotModifyHideUnavailable then
		-- Determined in data, supercedes player preference.
		hideUnavailable = not alwaysShowUnavailable;
	else
		local alwaysHide = not self.canModifyFilter;
		local preferHide = canShowCheckBox and hideUnavailableCvar;
		hideUnavailable = alwaysHide or preferHide;
	end

	local elements = self:GetElementsImplementation(hideUnavailable);
	local count = #elements.items;
	if count > 0 then
		self.Text:Hide();
		
		local continuableContainer = ContinuableContainer:Create();

		if undoElement then
			continuableContainer:AddContinuable(undoElement);
		end

		continuableContainer:AddContinuables(elements.items);
		continuableContainer:ContinueOnLoad(function()
			local rows = math.min(MaxRows, math.ceil(count / MaxColumns));
			local columns = self.canModifyFilter and MaxColumns or (math.max(1, math.min(MaxColumns, count)));

			local padding = self.ScrollBox:GetPadding();
			local vSpacing = padding:GetVerticalSpacing();
			local hSpacing = padding:GetHorizontalSpacing();
			local elementHeight = 37;
			local height = (rows * elementHeight) + (math.max(0, rows - 1) * vSpacing) + (padding.top + padding.bottom);
			local width = (columns * elementHeight) + (math.max(0, columns - 1) * hSpacing)+ (padding.left + padding.right);
			self.ScrollBox:SetSize(width, height);

			local scrollBoxAnchorOffset = 15;
			local adjustment = 2 * scrollBoxAnchorOffset;
			local totalWidth = width + adjustment;
			local canShowScrollBar = count > MaxUnscrolledCount;
			if canShowScrollBar then
				local scrollBarPadding = 8;
				totalWidth = totalWidth + self.ScrollBar:GetWidth() + scrollBarPadding;
			end

			local totalHeight = height + adjustment;
			if canShowCheckBox then
				totalHeight = totalHeight + 25;
			end

			if hasUndoElement then
				self.UndoItem:SetItem(undoElement:GetItemID());
				totalHeight = totalHeight + 50;
			end

			self.ScrollBar:SetShown(canShowScrollBar);

			local dataProvider = CreateDataProvider();
			for index, item in ipairs(elements.items) do
				-- Expected that some of these fields will be missing depending on the implementation
				-- of the GetElementsImplementation function. "item" is required. 
				local elementData = {
					item = item,
					itemGUID = elements.itemGUIDs and elements.itemGUIDs[index] or nil,
					itemLocation = elements.itemLocation and elements.itemLocation[index] or nil,
					onlyCountStack = elements.onlyCountStack,
					forceAccumulateInventory = elements.forceAccumulateInventory,
				};
				dataProvider:Insert(elementData);
			end
			self.ScrollBox:SetDataProvider(dataProvider);

			self.ScrollBox:ClearAllPoints();
			self.ScrollBox:SetPoint("TOPLEFT", 15, hasUndoElement and -65 or -15);

			self:SetSize(totalWidth, totalHeight);
		end);
	else
		self.Text:Show();

		self.ScrollBox:RemoveDataProvider();
		self.ScrollBar:SetShown(false);

		self:SetSize(250, 120);
	end

	PlaySound(SOUNDKIT.UI_PROFESSION_FILTER_MENU_OPEN_CLOSE);
end

function ProfessionsItemFlyoutMixin:Init(owner, transaction, canModifyFilter)
	if canModifyFilter == nil then
		canModifyFilter = true;
	end

	self.owner = owner;
	self.canModifyFilter = canModifyFilter;
	self.transaction = transaction;
	-- FIXME Visual states required for reagents already in transaction.

	self:InitializeContents();
end