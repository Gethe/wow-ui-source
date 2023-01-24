ProfessionsCustomerOrdersMode = EnumUtil.MakeEnum("Browse", "Orders");

local ProfessionOrderFrameTitles =
{
    [ProfessionsCustomerOrdersMode.Browse] = PLACE_CRAFTING_ORDERS,
    [ProfessionsCustomerOrdersMode.Orders] = MY_ORDERS,
};


ProfessionsCustomerOrdersFrameTabMixin = {};

function ProfessionsCustomerOrdersFrameTabMixin:OnClick()
    CallMethodOnNearestAncestor(self, "SelectMode", self.mode);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function ProfessionsCustomerOrdersFrameTabMixin:OnShow()
    local absoluteSize = nil;
    local MIN_TAB_WIDTH = 70;
    local TAB_PADDING = 20;
	PanelTemplates_TabResize(self, TAB_PADDING, absoluteSize, MIN_TAB_WIDTH);
end

ProfessionsCustomerOrdersMixin = {};

local ProfessionsCustomerOrdersEvents =
{
    "PLAYER_MONEY",
};

function ProfessionsCustomerOrdersMixin:OnLoad()
    PanelTemplates_SetNumTabs(self, #self.Tabs);

    self.modeToTabIdx = {};
    for idx, tab in ipairs(self.Tabs) do
        self.modeToTabIdx[tab.mode] = idx;
    end

	local function OnBackButtonClicked(button, buttonName, down)
		self:ShowCurrentPage();
	end

	self.Form.BackButton:SetScript("OnClick", OnBackButtonClicked);

	local function OpenOrderForm(order)
		self.Form:Init(order);
		self.Form:Show();

		self.currentPage:Hide();

		self:SetTabsShown(true);
	end

	local function OnOrderSelected(o, order)
		OpenOrderForm(order);
	end

	EventRegistry:RegisterCallback("ProfessionsCustomerOrders.OrderSelected", OnOrderSelected, self);

	local function OnRecipeSelected(o, itemID, spellID, skillLineAbilityID, unusableBOP)
		local isRecraft = false;
		OpenOrderForm(Professions.CreateNewOrderInfo(itemID, spellID, skillLineAbilityID, isRecraft, unusableBOP));
	end

	EventRegistry:RegisterCallback("ProfessionsCustomerOrders.RecipeSelected", OnRecipeSelected, self);

	local function OnRecraftCategorySelected()
		local isRecraft = true;
		local unusableBOP = false;
		OpenOrderForm(Professions.CreateNewOrderInfo(nilItemID, nilSpellID, nilSkillLineAbilityID, isRecraft, unusableBOP));
	end

	EventRegistry:RegisterCallback("ProfessionsCustomerOrders.RecraftCategorySelected", OnRecraftCategorySelected, self);

	local function ListOrder(o, order)
		self:ShowCurrentPage();
	end

	EventRegistry:RegisterCallback("Professions.OrderListed", ListOrder, self);
end

function ProfessionsCustomerOrdersMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrdersEvents);

    self:UpdateMoneyFrame();
    self:SetPortraitToUnit("npc");
    self:SelectMode(ProfessionsCustomerOrdersMode.Browse);

    self.BrowseOrders:Init();

    PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);

	self:ShowCurrentPage();
	C_CraftingOrders.OpenCustomerCraftingOrders();
end

function ProfessionsCustomerOrdersMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCustomerOrdersEvents);

    C_CraftingOrders.CloseCustomerCraftingOrders();
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Professions);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.ProfessionsCustomerOrders);
end

function ProfessionsCustomerOrdersMixin:ShowCurrentPage()
	self.Form:Hide();

	self.currentPage:Show();

	self:SetTabsShown(true);
end

function ProfessionsCustomerOrdersMixin:OnEvent(event, ...)
    if event == "PLAYER_MONEY" then
		self:UpdateMoneyFrame();
    end
end

function ProfessionsCustomerOrdersMixin:UpdateMoneyFrame()
	self.MoneyFrameBorder.MoneyFrame:SetAmount(GetMoney());
end

function ProfessionsCustomerOrdersMixin:SelectMode(mode)
    local title = ProfessionOrderFrameTitles[mode] or "";
	self:SetTitle(title);
	self.Form:Hide();

    for _, page in ipairs(self.Pages) do
        local showPage = (page.mode == mode);
        page:SetShown(showPage);

		if showPage then
			self.currentPage = page;
		end
    end

    local tabIdx = self.modeToTabIdx[mode];
    PanelTemplates_SetTab(self, tabIdx);
end

function ProfessionsCustomerOrdersMixin:SetTabsShown(shown)
	for key, tabIdx in pairs(self.modeToTabIdx) do
		if shown then
			PanelTemplates_ShowTab(self, tabIdx);
		else
			PanelTemplates_HideTab(self, tabIdx);
		end
	end
end
