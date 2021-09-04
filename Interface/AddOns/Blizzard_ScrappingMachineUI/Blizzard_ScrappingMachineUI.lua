UIPanelWindows["ScrappingMachineFrame"] = {area = "center", pushable = 3, showFailedFunc = C_ScrappingMachineUI.CloseScrappingMachine, };
ScrappingMachineMixin = {};

function ScrappingMachineMixin:SetupScrapButtonPool()
	self.ItemSlots.scrapButtons:ReleaseAll();

	local width, height = 53, 53;
	local columnNum, rowNum = 3, 3;
	local slotCount = 0;

	for i = 1, columnNum do
		for j = 1, rowNum do
			local button = self.ItemSlots.scrapButtons:Acquire();
			button.SlotNumber = slotCount;
			slotCount = slotCount + 1;
			button:SetPoint("TOPLEFT", self.ItemSlots, "TOPLEFT", ((j - 1) * (width - j) + 2), -((i - 1) * (height - i) + 2));
			button:Show();
		end
	end
end

function ScrappingMachineMixin:ClearAllScrapButtons()
	for button in self.ItemSlots.scrapButtons:EnumerateActive() do
		if(button) then
			button:ClearSlot();
		end
	end
end

function ScrappingMachineMixin:ScrapItems()
	C_ScrappingMachineUI.ScrapItems();
end

function ScrappingMachineMixin:UpdateScrapButtonState()
	self.ScrapButton:SetEnabled(C_ScrappingMachineUI.HasScrappableItems());
end

function ScrappingMachineMixin:OnLoad()
	self.ItemSlots.scrapButtons = CreateFramePool("BUTTON", self.ItemSlots, "ScrappingMachineItemSlot");
	self:SetupScrapButtonPool();

	UIPanelWindows[self:GetName()] = {area = "left", pushable = 3, showFailedFunc = C_ScrappingMachineUI.CloseScrappingMachine, };

	if ("Horde" == UnitFactionGroup("player")) then
		self.Background:SetAtlas("scrappingmachine-background-goblin", false);
	else
		self.Background:SetAtlas("scrappingmachine-background-gnomish", false);
	end

	self:SetPortraitToAsset("Interface\\Icons\\inv_gizmo_03");
	self:SetTitle(SCRAPPING_MACHINE_TITLE);
end

function ScrappingMachineMixin:OnShow()
	PlaySound(SOUNDKIT.UI_80_SCRAPPING_WINDOW_OPEN);
	self:UpdateScrapButtonState();
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("SCRAPPING_MACHINE_CLOSE");
	self:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED");
	self:RegisterEvent("SCRAPPING_MACHINE_SCRAPPING_FINISHED");
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
	self.TitleText:SetText(C_ScrappingMachineUI.GetScrappingMachineName());
	
	OpenAllBags(self);
	
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function ScrappingMachineMixin:OnEvent(event, ...)
	if (event == "BAG_UPDATE") then
		C_ScrappingMachineUI.ValidateScrappingList();
	elseif (event == "SCRAPPING_MACHINE_PENDING_ITEM_CHANGED") then
		self:UpdateScrapButtonState();
	elseif (event == "UNIT_SPELLCAST_START") then
		local unitTag, lineID, spellID = ...;
		if spellID == C_ScrappingMachineUI.GetScrapSpellID() then
			self.scrapCastLineID = lineID;
		end
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
		local unitTag, lineID, spellID = ...;
		if self.scrapCastLineID and self.scrapCastLineID == lineID then
			self.scrapCastLineID = nil;
			C_ScrappingMachineUI.ValidateScrappingList();
		end
	elseif (event == "SCRAPPING_MACHINE_CLOSE") then
		HideUIPanel(self);
	elseif (event == "SCRAPPING_MACHINE_SCRAPPING_FINISHED") then
		C_ScrappingMachineUI.RemoveAllScrapItems();
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unitTag, lineID, spellID = ...;
		if self.scrapCastLineID and self.scrapCastLineID == lineID then
			C_ScrappingMachineUI.RemoveCurrentScrappingItem();
		end
	end
end

function ScrappingMachineMixin:CloseScrappingMachine()
	self.scrapCastLineID = nil;
	self:ClearAllScrapButtons();
	C_ScrappingMachineUI.CloseScrappingMachine();
end

function ScrappingMachineMixin:OnHide()
	self:UnregisterEvent("UNIT_SPELLCAST_START");
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("SCRAPPING_MACHINE_CLOSE");
	self:UnregisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED");
	self:UnregisterEvent("SCRAPPING_MACHINE_SCRAPPING_FINISHED");
	PlaySound(SOUNDKIT.UI_80_SCRAPPING_WINDOW_CLOSE);
	self:CloseScrappingMachine();
	
	CloseAllBags(self);
	
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

ScrappingMachineItemSlotMixin = {};

function ScrappingMachineItemSlotMixin:RefreshIcon()
	self.itemLocation = C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(self.SlotNumber);
	if (not self.itemLocation) then
		self:ClearSlot();
		return;
	end

	self.item = Item:CreateFromItemLocation(self.itemLocation);
	if (self.item:IsItemEmpty()) then
		self:ClearSlot();
		return;
	end

	self.itemDataLoadedCancelFunc = self.item:ContinueWithCancelOnItemLoad(function()
		local itemName = self.item:GetItemName();
		local itemRarity = self.item:GetItemQuality();
		local itemTexture = self.item:GetItemIcon();
		self.itemLink = self.item:GetItemLink();
		if (itemName) then
			self.Icon:SetTexture(itemTexture);
			SetItemButtonQuality(self, itemRarity, self.itemLink);
			self.Icon:Show();
		end
	end);
end

function ScrappingMachineItemSlotMixin:ClearSlot()
	self.Icon:Hide();
	self.IconBorder:Hide();
	self.IconOverlay:Hide();
	self.itemLink = nil;
end

function ScrappingMachineItemSlotMixin:Clear()
	self.itemLocation = nil;
	self.item = nil;
	if (self.itemDataLoadedCancelFunc) then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
	self.itemName = nil;
	self.itemRarity = nil;
	self.itemTexture = nil;
	self.itemLink = nil;
end

function ScrappingMachineItemSlotMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED");
end

function ScrappingMachineItemSlotMixin:OnEvent(event, ...)
	if (event == "SCRAPPING_MACHINE_PENDING_ITEM_CHANGED") then
		self:RefreshIcon();
	end
	if (GameTooltip:GetOwner() == self) then
		self:OnMouseEnter();
	end
end

function ScrappingMachineItemSlotMixin:OnClick(button)
	self:Clear();
	C_ScrappingMachineUI.RemoveItemToScrap(self.SlotNumber);
	C_ScrappingMachineUI.DropPendingScrapItemFromCursor(self.SlotNumber);
end

function ScrappingMachineItemSlotMixin:OnDragStart()
	self:OnClick();
end

function ScrappingMachineItemSlotMixin:OnReceiveDrag()
	self:OnClick();
end

function ScrappingMachineItemSlotMixin:OnMouseEnter()
	if (self.itemLink) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(self.itemLink);
	else
		GameTooltip_Hide();
	end
end

function ScrappingMachineItemSlotMixin:OnMouseLeave()
	GameTooltip_Hide();
end