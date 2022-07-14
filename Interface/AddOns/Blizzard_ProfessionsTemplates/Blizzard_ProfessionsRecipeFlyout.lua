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

	self.itemButtonPool = CreateFramePool("ITEMBUTTON", self);
end

function ProfessionsItemFlyoutMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsItemFlyoutEvents);
end

function ProfessionsItemFlyoutMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsItemFlyoutEvents);

	self:UnregisterEvents();
	self.owner = nil;
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

-- FIXME implement the visual states for reagents occupied in other slots through transaction object
function ProfessionsItemFlyoutMixin:Init(owner, transaction, recipeID, itemIDs)
	self.owner = owner;

	local continuableContainer = ContinuableContainer:Create();
	local items = ItemUtil.TransformItemIDsToItems(itemIDs);
	continuableContainer:AddContinuables(items);

	self.itemButtonPool:ReleaseAll();
	local itemButtons = {};
	local function OnItemsLoaded()
		for index, item in ipairs(items) do
			local itemButton = self.itemButtonPool:Acquire();
			itemButton:SetItem(item:GetItemID());
			itemButton:Show();

			-- FIXME - Allow initializer to be installed so we can have elective behavior in either crafting order or crafting UI.
			-- Temp disabled appearance
			local count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
			local disable = count <= 0;
			itemButton:DesaturateHierarchy(disable and 1 or 0);
			itemButton:SetItemButtonCount(count);

			itemButton:SetScript("OnEnter", function()
				local optionalReagentIndex = index;
				GameTooltip:SetOwner(itemButton, "ANCHOR_TOPLEFT");
				local colorData = item:GetItemQualityColor();
				GameTooltip_SetTitle(GameTooltip, item:GetItemName(), colorData.color);

				local reagents = Professions.CreateCraftingReagentInfoBonusTbl(item:GetItemID());
				local bonusText = C_TradeSkillUI.GetCraftingReagentBonusText(recipeID, 1, reagents);

				for _, str in ipairs(bonusText) do
					GameTooltip_AddHighlightLine(GameTooltip, str, TooltipConstants.WrapText);
				end

				local count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
				if count <= 0 then
					GameTooltip_AddErrorLine(GameTooltip, OPTIONAL_REAGENT_NONE_AVAILABLE);
				end

				GameTooltip:Show();
			end);

			itemButton:SetScript("OnLeave", function()
				GameTooltip:Hide();
			end);

			itemButton:SetScript("OnClick", function()
				if not disable then
					self:TriggerEvent(ProfessionsItemFlyoutMixin.Event.ItemSelected, self, item);
					CloseItemFlyout();
				end
			end);

			table.insert(itemButtons, itemButton);
		end

		local stride = 3;
		local spacing = 5;
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, spacing, spacing);
		AnchorUtil.GridLayout(itemButtons, CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, 0), layout);
	
		self:Layout();
	end
	continuableContainer:ContinueOnLoad(OnItemsLoaded);
end