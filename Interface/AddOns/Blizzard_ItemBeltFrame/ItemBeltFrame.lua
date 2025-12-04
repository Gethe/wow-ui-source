
ItemBeltButtonMixin = {};

function ItemBeltButtonMixin:UpdateHotkey()
	-- Overrides HUDInventoryButtonMixin.

	if C_SpectatingUI.IsSpectating() then
		local hotkey = self.HotKey;
		hotkey:SetText(RANGE_INDICATOR);
		hotkey:Hide();
	else
		HUDInventoryButtonMixin.UpdateHotkey(self);
	end
end

function ItemBeltButtonMixin:UpdateSpectateState()
	local isSpectating = C_SpectatingUI.IsSpectating();
	self:SetEnabled(not isSpectating);
	self:UpdateHotkey();
end

ItemBeltFrameMixin = {};

local ITEM_BELT_FRAME_EVENTS = {
	"WOW_LABS_BACKPACK_SIZE_CHANGED",
	"SPECTATE_BEGIN",
	"SPECTATE_END",
};

function ItemBeltFrameMixin:OnShow()
	HUDInventoryBarMixin.OnShow(self)

	FrameUtil.RegisterFrameForEvents(self, ITEM_BELT_FRAME_EVENTS);

	self:UpdateSpectateState();
end

function ItemBeltFrameMixin:OnHide()
	HUDInventoryBarMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, ITEM_BELT_FRAME_EVENTS);
end

function ItemBeltFrameMixin:OnEvent(event, ...)
	HUDInventoryBarMixin.OnEvent(self, event, ...);

	if event == "WOW_LABS_BACKPACK_SIZE_CHANGED" then
		local newBackpackSize = ...;
		self:SetNumItemButtons(newBackpackSize);
	elseif event == "SPECTATE_BEGIN" or event == "SPECTATE_END" then
		self:UpdateSpectateState();
	end
end

function ItemBeltFrameMixin:UpdateSpectateState()
	for itemButton in self.itemButtonPool:EnumerateActive() do
		itemButton:UpdateSpectateState();
	end
end
