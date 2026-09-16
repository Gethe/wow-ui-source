GamepadItemPickupCursorMixin = {};

function GamepadItemPickupCursorMixin:OnLoad()
	self:RegisterEvent("CURSOR_CHANGED");
end

function GamepadItemPickupCursorMixin:OnEvent(event, ...)
	if InputUtil.IsGamepadUIEnabled() then
		if event == "CURSOR_CHANGED" then
			local itemLocation = C_Cursor.GetCursorItem();
			if itemLocation then
				local icon = C_Item.GetItemIcon(itemLocation);
				self.ItemIcon:SetTexture(icon);
				self:ClearAllPoints();
				self:SetPoint("BOTTOMLEFT", SmartNavigation, "BOTTOMRIGHT", 5, 0);
				self:Show();
			else
				self:Hide();
			end
		end
	end
end
