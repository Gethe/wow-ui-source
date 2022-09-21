local MaxColumns = 3;
local MaxRows = 6;
local MaxUnscrolledCount = MaxColumns * MaxRows;
local HideUnownedCvar = "professionsFlyoutHideUnowned";

ProfessionsItemFlyoutButtonMixin = {};

function ProfessionsItemFlyoutButtonMixin:Init(elementData, onElementEnabledImplementation)
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

	local count;
	if itemLocation and elementData.onlyCountStack then
		count = C_Item.GetStackCount(itemLocation);
	else
		count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
	end

	local stackable = C_Item.GetItemMaxStackSizeByID(item:GetItemID()) > 1;
	self:SetItemButtonCount(stackable and count or 1);
	
	local enabled = count > 0;
	if onElementEnabledImplementation then
		enabled = onElementEnabledImplementation(self, elementData);
	end
	self.enabled = enabled;
	self:DesaturateHierarchy(enabled and 0 or 1);
end

ProfessionsItemFlyoutMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsItemFlyoutMixin:GenerateCallbackEvents(
{
    "ItemSelected",
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
		SetCVar(HideUnownedCvar, checked);
		self:InitializeContents();
		PlaySound(SOUNDKIT.UI_PROFESSION_HIDE_UNOWNED_REAGENTS_CHECKBOX);
	end);

	local view = CreateScrollBoxListGridView(MaxColumns);
	local padding = 3;
	local spacing = 3;
	view:SetPadding(padding, padding, padding, padding, spacing, spacing);
	view:SetElementInitializer("ProfessionsItemFlyoutButtonTemplate", function(button, elementData)
		button:Init(elementData, self.OnElementEnabledImplementation);

		button:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
			self.OnElementEnterImplementation(elementData, GameTooltip);
			GameTooltip:Show();
		end);

		button:SetScript("OnLeave", GameTooltip_Hide);

		button:SetScript("OnClick", function()
			if button.enabled then
				self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.ItemSelected, self, elementData);
				CloseProfessionsItemFlyout();
			end
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsItemFlyoutMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
end

function ProfessionsItemFlyoutMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
	
	self:UnregisterEvents();

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

function ProfessionsItemFlyoutMixin:ShouldHideUnownedItems()
	return GetCVarBool(HideUnownedCvar);
end

function ProfessionsItemFlyoutMixin:InitializeContents()
	local filterOwned = self.canFilter and self:ShouldHideUnownedItems();
	local elements = self:GetElementsImplementation(filterOwned);
	self.HideUnownedCheckBox:SetShown(self.canFilter);

	local count = #elements.items;
	if count > 0 then
		self.Text:Hide();
		
		local continuableContainer = ContinuableContainer:Create();
		continuableContainer:AddContinuables(elements.items);
		continuableContainer:ContinueOnLoad(function()
			local rows = math.min(MaxRows, math.ceil(count / MaxColumns));
			local columns = self.canFilter and MaxColumns or (math.max(1, math.min(MaxColumns, count)));

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
			if self.canFilter then
				totalHeight = totalHeight + 25;
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
				};
				dataProvider:Insert(elementData);
			end
			self.ScrollBox:SetDataProvider(dataProvider);

			self:SetSize(totalWidth, totalHeight);
		end);
	else
		self.Text:Show();

		self.ScrollBox:ClearDataProvider();
		self.ScrollBar:SetShown(false);

		self:SetSize(250, 120);
	end

	PlaySound(SOUNDKIT.UI_PROFESSION_FILTER_MENU_OPEN_CLOSE);
end

function ProfessionsItemFlyoutMixin:Init(owner, transaction, cannotFilter)
	self.owner = owner;
	self.canFilter = not cannotFilter;
	-- FIXME Visual states required for reagents already in transaction.
	--self.transaction = transaction;

	self.HideUnownedCheckBox:SetChecked(self:ShouldHideUnownedItems());

	self:InitializeContents();
end