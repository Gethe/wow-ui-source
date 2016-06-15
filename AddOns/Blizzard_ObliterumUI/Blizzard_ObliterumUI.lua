UIPanelWindows["ObliterumForgeFrame"] = {area = "left", pushable = 3, showFailedFunc = C_TradeSkillUI.CloseObliterumForge, };

ObliterumForgeMixin = {};

function ObliterumForgeMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\INV_Obliterum_Ash");
	self.TitleText:SetText(OBLITERUM_FORGE_TITLE);
	
	self:RegisterEvent("OBLITERUM_FORGE_CLOSE");
	self:RegisterEvent("OBLITERUM_FORGE_PENDING_ITEM_CHANGED");
	self:RegisterEvent("OBLITERUM_FORGE_REAGENTS_UPDATED");
end

function ObliterumForgeMixin:OnEvent(event, ...)
	if event == "OBLITERUM_FORGE_REAGENTS_UPDATED" then
		self:UpdateReagent();
	elseif event == "BAG_UPDATE" then
		self:UpdateReagent();
	elseif event == "OBLITERUM_FORGE_PENDING_ITEM_CHANGED" then
		self:UpdateObliterateButtonState();
	elseif event == "UNIT_SPELLCAST_START" then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if spellID == C_TradeSkillUI.GetObliterateSpellID() then
			self.obliterateCastLineID = lineID;
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if self.obliterateCastLineID and self.obliterateCastLineID == lineID then
			self.obliterateCastLineID = nil;
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if self.obliterateCastLineID and self.obliterateCastLineID == lineID then
			C_TradeSkillUI.ClearPendingObliterateItem();
		end
	elseif event == "OBLITERUM_FORGE_CLOSE" then
		HideUIPanel(self);
	end
end

function ObliterumForgeMixin:OnShow()
	self:UpdateObliterateButtonState();
	self:UpdateReagent();

	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
	self:RegisterEvent("BAG_UPDATE");
end

function ObliterumForgeMixin:OnHide()
	C_TradeSkillUI.CloseObliterumForge();

	self:UnregisterEvent("UNIT_SPELLCAST_START");
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self:UnregisterEvent("UNIT_SPELLCAST_STOP");
	self:UnregisterEvent("BAG_UPDATE");

	self.obliterateCastLineID = nil;
end

function ObliterumForgeMixin:ObliterateItem()
	C_TradeSkillUI.ObliterateItem();
end

function ObliterumForgeMixin:UpdateObliterateButtonState()
	self.ObliterateButton:SetEnabled(C_TradeSkillUI.GetPendingObliterateItemID() ~= nil); 
end

function ObliterumForgeMixin:UpdateReagent()
	local name, texture, required, numInInventory = C_TradeSkillUI.GetObliterateReagentInfo();
	if name then
		self.ReagentFrame.ReagentName:SetText(name);

		local numInInventoryAbbreviated = AbbreviateNumbers(numInInventory);
		self.ReagentFrame.ReagentCount:SetText(numInInventoryAbbreviated);
		if required > numInInventory then
			self.ReagentFrame.ReagentCount:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			self.ReagentFrame.ReagentCount:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end

		self.ReagentFrame.ReagentIcon:SetTexture(texture);

		self.ReagentFrame:Show();
	else
		self.ReagentFrame:Hide();
	end
end

ObliterumForgeItemSlotMixin = {};

function ObliterumForgeItemSlotMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown");
	self:RegisterForDrag("LeftButton");

	self:RegisterEvent("OBLITERUM_FORGE_PENDING_ITEM_CHANGED");
end

function ObliterumForgeItemSlotMixin:OnEvent(event, ...)
	if event == "OBLITERUM_FORGE_PENDING_ITEM_CHANGED" then
		self:RefreshIcon();

		if GameTooltip:GetOwner() == self then
			self:OnMouseEnter();
		end
	elseif (event == "GET_ITEM_INFO_RECEIVED") then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		self:RefreshIcon();
	end
end

function ObliterumForgeItemSlotMixin:RefreshIcon()
	local itemLink = C_TradeSkillUI.GetPendingObliterateItemLink();
	local itemName, itemHyperLink, itemRarity, itemTexture;
	if itemLink then
		itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	else
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	end
	if itemName then
		self.Icon:SetTexture(itemTexture);

		self.Icon:Show();
		self.Corners:Show();
		self.GlowCorners:Show();
	else
		self:ClearSlot();
	end
end

function ObliterumForgeItemSlotMixin:ClearSlot()
	self.Icon:Hide();
	self.Corners:Hide();
	self.GlowCorners:Hide();
end

function ObliterumForgeItemSlotMixin:OnClick()
	C_TradeSkillUI.ClearPendingObliterateItem();
	C_TradeSkillUI.DropPendingObliterateItemFromCursor();
end

function ObliterumForgeItemSlotMixin:OnDragStart()
	self:OnClick();
end

function ObliterumForgeItemSlotMixin:OnReceiveDrag()
	self:OnClick();
end

function ObliterumForgeItemSlotMixin:OnMouseEnter()
	local itemLink = C_TradeSkillUI.GetPendingObliterateItemLink();
	if itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(itemLink);
	else
		GameTooltip_Hide();
	end
end

function ObliterumForgeItemSlotMixin:OnMouseLeave()
	GameTooltip_Hide();
end