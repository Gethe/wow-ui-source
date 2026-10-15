GamepadItemPickupCursorMixin = {};

local cursorHandlers = {};

function cursorHandlers.item(self)
	local itemLocation = C_Cursor.GetCursorItem();
	if itemLocation then
		local icon = C_Item.GetItemIcon(itemLocation);
		self.ItemIcon:SetTexture(icon);
		return true;
	end
end

function cursorHandlers.pet(self, id)
	local info = id and C_StableInfo.GetStablePetInfo(id);
	if info then
		self.ItemIcon:SetTexture(info.icon);
		return true;
	end
end

function GamepadItemPickupCursorMixin:OnLoad()
	self:RegisterEvent("CURSOR_CHANGED");
end

function GamepadItemPickupCursorMixin:OnEvent(event, ...)
	if not InputUtil.IsGamepadUIEnabled() or event ~= "CURSOR_CHANGED" then
		return;
	end

	local cursorType, arg1 = GetCursorInfo();
	if not cursorType then
		self:Hide();
	end

	local handler = cursorHandlers[cursorType];
	self:SetShown(handler and handler(self, arg1));
end
