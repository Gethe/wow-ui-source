LOOTFRAME_NUMBUTTONS = 5;
MASTER_LOOT_THREHOLD = 4;

local LOOT_SLOT_NONE = 0;
local LOOT_SLOT_ITEM = 1;
local LOOT_SLOT_MONEY = 2;
local LOOT_SLOT_CURRENCY = 3;

local LOOTFRAME_BASEHEIGHT = 290;
local LOOTFRAME_BASEWIDTH = 220;

local LOOTFRAME_BUTTONHEIGHT = 46;
local LOOTFRAME_SCROLLBARWIDTH = 16;

local LOOTFRAME_PAD = 6;
local LOOTFRAME_SPACING = 2;

LootFrameMixin = {};

function LootFrameMixin:OnLoad()
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	self:RegisterEvent("LOOT_SLOT_CHANGED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST");

	local Pad = LOOTFRAME_PAD;
	local Spacing = LOOTFRAME_SPACING;
	local view = CreateScrollBoxListLinearView(Pad, Pad, Pad, Pad, Spacing);

	local function Initializer(button, elementData)
		LootButton_Update(button);
	end

	view:SetElementInitializer("LootButtonTemplate", Initializer);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:SetShadowsFrameLevel(self.ScrollBox.ScrollTarget:GetFrameLevel() + 15);
	self.ScrollBox:SetShadowsScale(0.2);
	self.ScrollBox:GetUpperShadowTexture():SetTexCoord(0, 1, 1, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPLEFT", 30, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPRIGHT", -30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMLEFT", 30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMRIGHT", -30, 0);
end

function LootFrameMixin:OnEvent(event, ...)
	if ( event == "LOOT_OPENED" ) then
		local autoLoot, isFromItem = ...;

		self.isAutoLoot = autoLoot;

		self:LootFrame_Show();
		if ( not self:IsShown()) then
			CloseLoot(not autoLoot);	-- The parameter tells code that we were unable to open the UI
		else
			if ( isFromItem ) then
				PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
			end
		end
	elseif ( event == "LOOT_SLOT_CLEARED" ) then
		local arg1 = ...;
		if ( not self:IsShown() ) then
			return;
		end

		local button = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetElementData().index == arg1;
		end);
		if button then
			if self.isAutoLoot then
				button.AutoLootAnim:Play();
			else
				button:Hide();
			end
		end
	elseif ( event == "LOOT_SLOT_CHANGED" ) then
		local arg1 = ...;

		if ( not self:IsShown() ) then
			return;
		end

		self:Update();
	elseif ( event == "LOOT_CLOSED" ) then
		self:Close();
	elseif ( event == "OPEN_MASTER_LOOT_LIST" ) then
		ToggleDropDownMenu(1, nil, GroupLootDropDown, self.selectedLootButton, 0, 0);
	elseif ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		MasterLooterFrame_UpdatePlayers();
	end
end

local LOOT_UPDATE_INTERVAL = 0.5;
function LootFrameMixin:OnUpdate(elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if ( self.timeSinceUpdate >= LOOT_UPDATE_INTERVAL ) then
		self:SetScript("OnUpdate", nil);
		self.timeSinceUpdate = nil;
		self:Update();
	end
end

function LootFrameMixin:Update(retainScrollPosition)
	local numLootItems = self.numLootItems;

	local dataProvider = CreateDataProviderByIndexCount(numLootItems);

	self.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition == nil and ScrollBoxConstants.RetainScrollPosition or retainScrollPosition);
end

function LootFrameMixin:Close()
	self.ShowAnim:Stop();
	self.HideAnim:Play(false);

	self.isShowingLoot = false;
end

function LootFrameMixin:LootFrame_Show()
	self.numLootItems = GetNumLootItems();

	if ( GetCVar("lootUnderMouse") == "1" ) then
		self:Show();
		-- position loot window under mouse cursor
		local x, y = GetCursorPosition();
		x = x / self:GetEffectiveScale();
		y = y / self:GetEffectiveScale();

		local posX = x - 175;
		local posY = y + 25;

		if (self.numLootItems > 0) then
			posX = x - 40;
			posY = y + 55;
			posY = posY + 40;
		end

		if( posY < 350 ) then
			posY = 350;
		end

		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
		self:GetCenter();
		self:Raise();
	else
		ShowUIPanel(self);

		-- Position according to edit mode data
		self:ApplySystemAnchor();
	end

	local showScrollBar = self.numLootItems > LOOTFRAME_NUMBUTTONS;
	if (showScrollBar) then
		self:SetHeight(LOOTFRAME_BASEHEIGHT);
		self:SetWidth(LOOTFRAME_BASEWIDTH + LOOTFRAME_SCROLLBARWIDTH);
	else
		local fitToHeight = LOOTFRAME_BASEHEIGHT - ((LOOTFRAME_BUTTONHEIGHT + LOOTFRAME_SPACING) * (LOOTFRAME_NUMBUTTONS - self.numLootItems));
		self:SetHeight(fitToHeight);
		self:SetWidth(LOOTFRAME_BASEWIDTH);
	end
	self.ScrollBar:SetShown(showScrollBar);
	self.ScrollBox:SetWidth(LOOTFRAME_BASEWIDTH - LOOTFRAME_PAD);

	self:Update(ScrollBoxConstants.DiscardScrollPosition);

	self.HideAnim:Stop();
	self.ShowAnim:Play(true);

	self.isShowingLoot = true;
end

function LootFrameMixin:OnShow()
	if( self.numLootItems == 0 ) then
		PlaySound(SOUNDKIT.LOOT_WINDOW_OPEN_EMPTY);
	elseif( IsFishingLoot() ) then
		PlaySound(SOUNDKIT.FISHING_REEL_IN);
	end
end

function LootFrameMixin:OnHide()
	CloseLoot();
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();
end

function LootFrameMixin:UpdateShownState()
	if self.isInEditMode then
		self.ShowAnim:Stop();
		self.HideAnim:Stop();
		self:SetAlpha(1);
		self:SetHeight(LOOTFRAME_BASEHEIGHT);
	end

	self:SetShown(self.isInEditMode or self.isShowingLoot);
end

function LootButton_Update(button)
	local numLootItems = LootFrame.numLootItems;
	local self = LootFrame;

	local slot = button:GetElementData().index;
	if ( not LootSlotHasItem(slot) ) then
		if not self.isAutoLoot then
			button:Hide();
		end
		return;
	end

	local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);

	if ( currencyID ) then 
		item, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality);
	end

	local slotType = GetLootSlotType(slot);
	local isMoney = slotType == LOOT_SLOT_MONEY;

	local text = isMoney and button.MoneyText or button.Text;
	local hiddenText = isMoney and button.Text or button.MoneyText;
	hiddenText:SetText("");
	button.QualityText:SetShown(not isMoney);
	button.QualityFrame:SetShown(not isMoney);
	if ( texture ) then
		local color = ITEM_QUALITY_COLORS[quality];
		SetItemButtonQuality(button.Item, quality, GetLootSlotLink(slot));
		button.Item.icon:SetTexture(texture);
		text:SetText(item);
		button.QualityText:SetText(_G["ITEM_QUALITY"..quality.."_DESC"]);
		button.NameFrame:SetVertexColor(color.r, color.g, color.b);
		if( locked ) then
			SetItemButtonTextureVertexColor(button.Item, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(button.Item, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
		end

		local questTexture = button.IconQuestTexture;
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();
		else
			questTexture:Hide();
		end

		text:SetVertexColor(color.r, color.g, color.b);
		local countString = button.Item.Count;
		if ( quantity > 1 ) then
			countString:SetText(quantity);
			countString:Show();
		else
			countString:Hide();
		end
		button.slot = slot;
		button.quality = quality;
		button.Item:Enable();
	else
		text:SetText("");
		button.QualityText:SetText("");
		button.Item.icon:SetTexture(nil);
		SetItemButtonNormalTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
		LootFrame:SetScript("OnUpdate", LootFrame.OnUpdate);
		button.Item:Disable();
	end
	button.AutoLootAnim:Stop();
	button.ShownAnim:Play();
	button:Show();
end

function LootButton_OnClick(self, button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();

	LootFrame.selectedLootButton = self:GetName();
	LootFrame.selectedSlot = self.slot;
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = self.Text:GetText();
	LootFrame.selectedTexture = self.Item.icon:GetTexture();
	LootSlot(self.slot);
end

function LootItem_OnEnter(self)
	local slot = self:GetElementData().index;
	local slotType = GetLootSlotType(slot);
	if ( slotType == LOOT_SLOT_ITEM ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(slot);
		CursorUpdate(self);
	end
	if ( slotType == LOOT_SLOT_CURRENCY ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootCurrency(slot);
		CursorUpdate(self);
	end
	self.HighlightNameFrame:Show();
end

function LootItem_OnLeave(self)
	self.HighlightNameFrame:Hide();
end

function LootItem_OnMouseDown(self)
	self.PushedNameFrame:Show();
end

function LootItem_OnMouseUp(self)
	self.PushedNameFrame:Hide();
end