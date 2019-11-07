UIPanelWindows["ObliterumForgeFrame"] = {area = "left", pushable = 3, showFailedFunc = C_TradeSkillUI.CloseObliterumForge, };

local OBLITERUM_UI_UNIT_EVENTS = {
	"UNIT_SPELLCAST_START", 
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_STOP",
};

ObliterumForgeMixin = {};

function ObliterumForgeMixin:OnLoad()
	self:SetPortraitToAsset("Interface\\Icons\\INV_Obliterum_Ash");
	self:SetTitle(OBLITERUM_FORGE_TITLE);

	self:RegisterEvent("OBLITERUM_FORGE_CLOSE");
	self:RegisterEvent("OBLITERUM_FORGE_PENDING_ITEM_CHANGED");
end

function ObliterumForgeMixin:OnEvent(event, ...)
	if event == "OBLITERUM_FORGE_PENDING_ITEM_CHANGED" then
		self:UpdateObliterateButtonState();
	elseif event == "UNIT_SPELLCAST_START" then
		local unitTag, lineID, spellID = ...;
		if spellID == C_TradeSkillUI.GetObliterateSpellID() then
			self.obliterateCastLineID = lineID;
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		local unitTag, spellName, rank, lineID, spellID = ...;
		if self.obliterateCastLineID and self.obliterateCastLineID == lineID then
			self.obliterateCastLineID = nil;
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unitTag, lineID, spellID = ...;
		if self.obliterateCastLineID and self.obliterateCastLineID == lineID then
			C_TradeSkillUI.ClearPendingObliterateItem();
		end
	elseif event == "OBLITERUM_FORGE_CLOSE" then
		HideUIPanel(self);
	end
end

function ObliterumForgeMixin:OnShow()
	self:UpdateObliterateButtonState();
	FrameUtil.RegisterFrameForUnitEvents(self, OBLITERUM_UI_UNIT_EVENTS, "player")
end

function ObliterumForgeMixin:OnHide()
	C_TradeSkillUI.CloseObliterumForge();

	FrameUtil.UnregisterFrameForEvents(self, OBLITERUM_UI_UNIT_EVENTS);

	self.obliterateCastLineID = nil;
end

function ObliterumForgeMixin:ObliterateItem()
	C_TradeSkillUI.ObliterateItem();
end

function ObliterumForgeMixin:UpdateObliterateButtonState()
	self.ObliterateButton:SetEnabled(C_TradeSkillUI.GetPendingObliterateItemID() ~= nil);
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
	local itemName, itemHyperLink, itemRarity, itemTexture, _;
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