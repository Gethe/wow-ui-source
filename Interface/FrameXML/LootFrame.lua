local ScrollBoxElementHeight = 46;
local ScrollBoxPad = 6;
local ScrollBoxSpacing = 2;

local FrameEvents =
{
	"LOOT_SLOT_CLEARED",
	"LOOT_SLOT_CHANGED",
};

LootFrameMixin = {};

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
				-- Values required by GroupLoot and MasterLoot frames. If these frames are returned
				-- to service, it would be ideal to expose these values through an API.
				self.selectedLootFrame = frame;
				self.selectedSlot = frame:GetSlotIndex();
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
		self:Close();
	end
end

function LootFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, FrameEvents);
end

function LootFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, FrameEvents);

	self.ScrollBox:ClearDataProvider();

	CloseLoot();

	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");

	EventRegistry:TriggerEvent("LootFrame.Hide");
end

function LootFrameMixin:Open()
	local dataProvider = CreateDataProvider();
	for slotIndex = 1, GetNumLootItems() do
		local texture, item, quantity, currencyID, itemQuality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);

		if not itemQuality then
			print("NO QUALITY LOOT "..tostring(item)..", currencyID"..tostring(currencyID)..", quantity"..tostring(quantity)..", slotIndex"..tostring(slotIndex)..", isCoin"..tostring(isCoin));
		end

		if currencyID then 
			item, texture, quantity, itemQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, itemQuality);

			if not itemQuality then
				print("NO QUALITY CURRENCY "..tostring(item)..", currencyID"..tostring(currencyID)..", quantity"..tostring(quantity)..", slotIndex"..tostring(slotIndex)..", isCoin"..tostring(isCoin));
			end
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

	if GetCVarBool("lootUnderMouse") then
		-- ShowUIPanel is not called here because we don't
		-- want the repositioning behavior that occurs.
		if CanAutoSetGamePadCursorControl(true) then
			SetGamePadCursorControl(true);
		end
		self:Show();

		local x, y = GetCursorPosition();
		x = x / (self:GetEffectiveScale()) - 30;
		y = math.max((y / self:GetEffectiveScale()) + 50, 350);
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x, y);
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
end

function LootFrameElementMixin:Init()
	local slotIndex = self:GetSlotIndex();
	local texture, item, quantity, currencyID, itemQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(slotIndex);
	if currencyID then 
		item, texture, quantity, itemQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, itemQuality);
	end

	local quality = itemQuality or Enum.ItemQuality.Common;
	local color = ITEM_QUALITY_COLORS[quality].color;

	self.Text:SetText(item);
	self.Text:SetVertexColor(color:GetRGB());
	self.NameFrame:SetVertexColor(color:GetRGB());

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
	SetItemButtonQuality(self.Item, quality, link);
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
	GameTooltip:Hide();

	ResetCursor();

	self.HighlightNameFrame:Hide();
end

LootFrameItemElementMixin = CreateFromMixins(LootFrameElementMixin);

function LootFrameItemElementMixin:Init()
	LootFrameElementMixin.Init(self);

	local elementData = self:GetElementData();
	self.QualityText:SetText(_G[string.format("ITEM_QUALITY%s_DESC", elementData.quality)]);
end

function LootFrameItemElementMixin:OnEnter()
	LootFrameElementMixin.OnEnter(self);

	local lootSlotType = self:GetItemSlotType();
	if lootSlotType == Enum.LootSlotType.Currency then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootCurrency(self:GetSlotIndex());

		CursorUpdate(self);
	elseif lootSlotType == Enum.LootSlotType.Item then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(self:GetSlotIndex());

		CursorUpdate(self);
	end
end