AzeriteEmpoweredItemUIMixin = {};

function AzeriteEmpoweredItemUIMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "left", pushable = 0, showFailedFunc = function() self:OnShowFailed(); end, };

	self.tierPool = CreateFramePool("FRAME", self, "AzeriteEmpoweredItemTierTemplate");
	self.powerPool = CreateFramePool("BUTTON", self, "AzeriteEmpoweredItemPowerTemplate");
end

function AzeriteEmpoweredItemUIMixin:OnUpdate(elapsed)
	if self.dirty then
		self.dirty = nil;
		self:Refresh();
	end
end

function AzeriteEmpoweredItemUIMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function AzeriteEmpoweredItemUIMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	self:Clear();
end

function AzeriteEmpoweredItemUIMixin:OnEvent(event, ...)
	if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel = ...;
		self:MarkDirty();
	elseif event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" then
		local item = ...;
		self:MarkDirty();
	end
end

function AzeriteEmpoweredItemUIMixin:OnShowFailed()
	self:Clear();
end

function AzeriteEmpoweredItemUIMixin:IsItemValid()
	return self.empoweredItem and not self.empoweredItem:IsItemEmpty();
end

function AzeriteEmpoweredItemUIMixin:Clear()
	
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_BIND");

	if self.empoweredItem then
		self.empoweredItem:UnlockItem();
	end
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
	self.empoweredItemLocation = nil;
	self.empoweredItem = nil;

	self.tierPool:ReleaseAll();
	self.powerPool:ReleaseAll();

	self:MarkDirty();

	self:UnregisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:UnregisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");
end

function AzeriteEmpoweredItemUIMixin:SetToItemAtLocation(itemLocation)
	self:Clear();

	self.empoweredItemLocation = itemLocation;
	self.empoweredItem = Item:CreateFromItemLocation(self.empoweredItemLocation);
	if not self:IsItemValid() then
		HideUIPanel(self);
		return;
	end

	self.empoweredItem:LockItem();

	self.TitleText:SetText("");

	self.itemDataLoadedCancelFunc = self.empoweredItem:ContinueWithCancelOnItemLoad(function()
		SetPortraitToTexture(self.portrait, self.empoweredItem:GetItemIcon());
		self.TitleText:SetText(self.empoweredItem:GetItemName());
	end);

	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");

	self:MarkDirty();
end

function AzeriteEmpoweredItemUIMixin:MarkDirty()
	self.dirty = true;
end

function AzeriteEmpoweredItemUIMixin:Refresh()
	if not self:IsItemValid() then
		HideUIPanel(self);
		return;
	end

	self.tierPool:ReleaseAll();
	self.powerPool:ReleaseAll();

	self:RebuildTiers();
end

function AzeriteEmpoweredItemUIMixin:RebuildTiers()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if not azeriteItemLocation then
		HideUIPanel(self);
		return;
	end

	local azeriteItemPowerLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);

	local allTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation);
	local previousTier = nil;
	for tierIndex, tierInfo in ipairs(allTierInfo) do
		local tierFrame = self.tierPool:Acquire();
		tierFrame:Setup(self.empoweredItemLocation, tierInfo, azeriteItemPowerLevel, previousTier, self.powerPool);

		local SPACING = 2;
		tierFrame:SetPoint("TOP", self, "TOP", 0, -(tierFrame:GetHeight() + SPACING) * (tierIndex - 1) - 35);
		tierFrame:Show();

		previousTier = tierFrame;
	end
end