UIPanelWindows["AzeriteRespecFrame"] = {area = "left", pushable = 3, showFailedFunc = C_AzeriteEmpoweredItem.CloseAzeriteEmpoweredItemRespec, };

AzeriteRespecMixin = {};

function AzeriteRespecMixin:OnLoad()
	self:SetPortraitToAsset("Interface\\Icons\\inv_enchant_voidsphere");
	self.TitleText:SetText(AZERITE_RESPEC_TITLE);
	self.CornerBL:SetPoint("BOTTOMLEFT", -1, 24);
	self.CornerBR:SetPoint("BOTTOMRIGHT", 0, 24);
	self.CornerTL:SetPoint("TOPLEFT", -2, -18);
	self.CornerTR:SetPoint("TOPRIGHT", 0, -18);

	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("RESPEC_AZERITE_EMPOWERED_ITEM_CLOSED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");
end

function AzeriteRespecMixin:OnEvent(event, ...)
	if event == "RESPEC_AZERITE_EMPOWERED_ITEM_CLOSED" then
		HideUIPanel(self);
	elseif(event == "PLAYER_MONEY") or (event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED") then
		self:UpdateMoney();
		if (event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED") then
			local itemLocation = ...;
			if self:GetRespecItemLocation() and self:GetRespecItemLocation():IsEqualTo(itemLocation) then
				self:SetRespecItem(nil);
			end
		end
	end
end

function AzeriteRespecMixin:OnShow()
	PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE_ETHEREALWINDOW_OPEN)
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_RESPEC) then
		local helpTipInfo = {
			text = AZERITE_RESPEC_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_AZERITE_RESPEC,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -10,
		};
		HelpTip:Show(self, helpTipInfo, self.ItemSlot);
	end
	self:UpdateMoney();
end

function AzeriteRespecMixin:OnHide()
	PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE_ETHEREALWINDOW_CLOSE)
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_RESPEC");
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE");
	C_AzeriteEmpoweredItem.CloseAzeriteEmpoweredItemRespec();
	self:SetRespecItem(nil);
end

function AzeriteRespecMixin:UpdateMoney()
	self.respecCost = C_AzeriteEmpoweredItem.GetAzeriteEmpoweredItemRespecCost();
	MoneyFrame_Update(self.ButtonFrame.MoneyFrame:GetName(), self.respecCost, false);
	if GetMoney() < (self.respecCost) then
		SetMoneyFrameColor(self.ButtonFrame.MoneyFrame:GetName(), "red");
	else
		SetMoneyFrameColor(self.ButtonFrame.MoneyFrame:GetName(), "white");
	end
	self:UpdateAzeriteRespecButtonState();
end

function AzeriteRespecMixin:GetRespecItemLocation()
	return self.respecItemLocation;
end

local SHOW_EXPENSIVE_WARNING_THRESHOLD = 1000 * COPPER_PER_SILVER * SILVER_PER_GOLD;
function AzeriteRespecMixin:AzeriteRespecItem()
	local item = Item:CreateFromItemLocation(self.respecItemLocation);
	local data = {empoweredItemLocation = self.respecItemLocation, respecCost = self.respecCost};
	if self.respecCost >= SHOW_EXPENSIVE_WARNING_THRESHOLD then
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE", item:GetItemLink(), nil, data);
	else
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_RESPEC", item:GetItemLink(), nil, data);
	end
end

function AzeriteRespecMixin:UpdateAzeriteRespecButtonState()
	self.ButtonFrame.AzeriteRespecButton:SetEnabled(self.respecItemLocation ~= nil and GetMoney() > self.respecCost);
end

function AzeriteRespecMixin:SetRespecItem(itemLocation)

	if itemLocation and not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
		UIErrorsFrame:AddExternalErrorMessage(ITEM_IS_NOT_AZERITE_EMPOWERED);
		return;
	end

	local azeriteitem = itemLocation and AzeriteEmpoweredItemDataSource:CreateFromItemLocation(itemLocation);
	if azeriteitem and not AzeriteUtil.HasSelectedAnyAzeritePower(azeriteitem) then
		UIErrorsFrame:AddExternalErrorMessage(AZERITE_EMPOWERED_REFORGE_NO_CHOICES_TO_UNDO);
		return;
	end

	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	if self.respecItemLocation then
		local oldItem = Item:CreateFromItemLocation(self.respecItemLocation);
		oldItem:UnlockItem();
	end

	self.respecItemLocation = itemLocation;
	if (itemLocation) then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_RESPEC) then
			HelpTip:Hide(self, AZERITE_RESPEC_TUTORIAL_TEXT);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_RESPEC, true);
		end

		local item = Item:CreateFromItemLocation(self.respecItemLocation);
		item:LockItem();
	end
	self.ItemSlot:RefreshIcon();
	self.ItemSlot:RefreshTooltip();
	self:UpdateAzeriteRespecButtonState();
end

AzeriteRespecItemSlotMixin = {};

function AzeriteRespecItemSlotMixin:OnLoad()
	self:RegisterForClicks("RightButtonDown", "LeftButtonDown");
	self:RegisterForDrag("LeftButton");
end

function AzeriteRespecItemSlotMixin:RefreshIcon()
	self.Icon:Hide();
	self.GlowOverlay:Hide();
	if self:GetParent():GetRespecItemLocation() then
		local item = Item:CreateFromItemLocation(self:GetParent():GetRespecItemLocation());
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			self.Icon:SetTexture(item:GetItemIcon());
			self.Icon:Show();
			self.GlowOverlay:Show();
		end);
	end
end

function AzeriteRespecItemSlotMixin:RefreshTooltip()
	if GetMouseFocus() == self then
		self:OnMouseEnter();
	else
		self:OnMouseLeave();
	end
end

function AzeriteRespecItemSlotMixin:OnClick(button)
	if button == "RightButton" then
		self:GetParent():SetRespecItem(nil);
	else
		self:GetParent():SetRespecItem(C_Cursor.GetCursorItem());
	end
	ClearCursor();
end

function AzeriteRespecItemSlotMixin:OnDragStart()
	self:GetParent():SetRespecItem(nil);
end

function AzeriteRespecItemSlotMixin:OnReceiveDrag()
	self:GetParent():SetRespecItem(C_Cursor.GetCursorItem());
	ClearCursor();
end

function AzeriteRespecItemSlotMixin:OnMouseEnter()
	if self:GetParent():GetRespecItemLocation() then
		if self:GetParent():GetRespecItemLocation():IsEquipmentSlot() then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetInventoryItem("player", self:GetParent():GetRespecItemLocation():GetEquipmentSlot());
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetBagItem(self:GetParent():GetRespecItemLocation():GetBagAndSlot());
		end
	else
		GameTooltip_Hide();
	end
end

function AzeriteRespecItemSlotMixin:OnMouseLeave()
	GameTooltip_Hide();
end

AzeriteRespecButtonMixin = {};

function AzeriteRespecButtonMixin:OnMouseEnter()
	if (not self:IsEnabled()) and GetMoney() < self:GetParent():GetParent().respecCost then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:SetText(NOT_ENOUGH_GOLD_FOR_AZERITE_RESPEC);
	else
		GameTooltip_Hide();
	end
end

function AzeriteRespecButtonMixin:OnMouseLeave()
	GameTooltip_Hide();
end