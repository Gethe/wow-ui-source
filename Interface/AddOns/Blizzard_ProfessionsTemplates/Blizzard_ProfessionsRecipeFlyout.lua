local MaxColumns = 3;
local MaxRows = 6;
local MaxUnscrolledCount = MaxColumns * MaxRows;
local HideUnownedCvar = "professionsFlyoutHideUnowned";

ProfessionsItemFlyoutButtonMixin = {};

function ProfessionsItemFlyoutButtonMixin:Init(item)
	self:SetItem(item:GetItemID());

	-- FIXME - Allow initializer to be installed so we can have elective behavior in either crafting order or crafting UI.
	-- Temp disabled appearance
	local count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
	local disable = count <= 0;
	self:DesaturateHierarchy(disable and 1 or 0);
	self:SetItemButtonCount(count);
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
		self:InitializeContents(self.itemIDs);
	end);

	local view = CreateScrollBoxListGridView(MaxColumns);
	view:SetElementInitializer("ProfessionsItemFlyoutButtonTemplate", function(button, item)
		button:Init(item);

		button:SetScript("OnEnter", function()
			local optionalReagentIndex = index;
			GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT");
			GameTooltip:SetItemByID(item:GetItemID());

			local reagents = Professions.CreateCraftingReagentInfoBonusTbl(item:GetItemID());
			local bonusText = C_TradeSkillUI.GetCraftingReagentBonusText(self.recipeID, 1, reagents);

			for _, text in ipairs(bonusText) do
				GameTooltip_AddHighlightLine(GameTooltip, text, TooltipConstants.WrapText);
			end

			local count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
			if count <= 0 then
				GameTooltip_AddErrorLine(GameTooltip, OPTIONAL_REAGENT_NONE_AVAILABLE);
			end

			GameTooltip:Show();
		end);

		button:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);

		button:SetScript("OnClick", function()
			if not disable then
				self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.ItemSelected, self, item);
				CloseItemFlyout();
			end
		end);
	end);
	view:SetPadding(0,0,0,0,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsItemFlyoutMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
end

function ProfessionsItemFlyoutMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
	
	self:UnregisterEvents();

	self.owner = nil;
	self.recipeID = nil;
	self.itemIDs = nil;
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
			CloseItemFlyout();
		end
	end
end

function ProfessionsItemFlyoutMixin:ShouldHideUnownedItems()
	return GetCVarBool(HideUnownedCvar);
end

function ProfessionsItemFlyoutMixin:InitializeContents()
	local filteredItemIDs = {};
	if self:ShouldHideUnownedItems() then
		ItemUtil.IteratePlayerInventory(function(itemLocation)
			local item = Item:CreateFromItemLocation(itemLocation);
			if tContains(self.itemIDs, item:GetItemID()) then
				table.insert(filteredItemIDs, item:GetItemID());
			end
		end);
	else
		filteredItemIDs = self.itemIDs;
	end

	local count = #filteredItemIDs;
	self.HideUnownedCheckBox:SetShown(self.canShowCheckBox);

	if count > 0 then
		self.Text:Hide();
		
		local continuableContainer = ContinuableContainer:Create();
		local items = ItemUtil.TransformItemIDsToItems(filteredItemIDs);
		continuableContainer:AddContinuables(items);
		continuableContainer:ContinueOnLoad(function()
			local rows = math.min(MaxRows, math.ceil(count / MaxColumns));
			local columns = self.canShowCheckBox and MaxColumns or (math.max(1, math.min(MaxColumns, count)));

			local padding = 0;
			local elementHeight = 37;
			local height = (rows * elementHeight) + (math.max(0, rows - 1) * padding);
			local width = (columns * elementHeight) + (math.max(0, columns - 1) * padding);
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
			if self.canShowCheckBox then
				totalHeight = totalHeight + 25;
			end

			self.ScrollBar:SetShown(canShowScrollBar);

			local dataProvider = CreateDataProvider(items);
			self.ScrollBox:SetDataProvider(dataProvider);

			self:SetSize(totalWidth, totalHeight);
		end);
	else
		self.Text:Show();

		self.ScrollBox:ClearDataProvider();
		self.ScrollBar:SetShown(false);

		self:SetSize(250, 120);
	end
end

-- FIXME Visual states required for reagents already in transaction.
function ProfessionsItemFlyoutMixin:Init(owner, transaction, recipeID, itemIDs, cannotFilter)
	self.owner = owner;
	self.recipeID = recipeID;
	self.itemIDs = itemIDs;
	self.canShowCheckBox = not cannotFilter;

	self.HideUnownedCheckBox:SetChecked(self:ShouldHideUnownedItems());

	self:InitializeContents();
end