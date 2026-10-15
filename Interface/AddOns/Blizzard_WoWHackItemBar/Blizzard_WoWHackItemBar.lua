local CURSOR_TYPES_THAT_RAISE_ITEM_BAR = tInvert({ "spell", "petaction", "flyout", "outfit" });

WoWHackItemButtonMixin = {};

function WoWHackItemButtonMixin:OnLoad()
	HUDInventoryButtonMixin.OnLoad(self);
	self.BG:SetAtlas("talebound-hud-actionbar-iconframe-bg");
	self.BG:SetSize(47, 47);
end

WoWHackItemBarMixin = {};

function WoWHackItemBarMixin:OnLoad()
	HUDInventoryMixin.OnLoad(self);
	self:RegisterEvent("ACTIONBAR_SHOWGRID");
	self:RegisterEvent("ACTIONBAR_HIDEGRID");
end

function WoWHackItemBarMixin:OnEvent(event)
	if event == "ACTIONBAR_SHOWGRID" then
		local cursorType = GetCursorInfo();
		local shouldRaise = cursorType and CURSOR_TYPES_THAT_RAISE_ITEM_BAR[cursorType] ~= nil;
		self:SetFrameStrata(shouldRaise and "TOOLTIP" or "MEDIUM");
	elseif event == "ACTIONBAR_HIDEGRID" then
		self:SetFrameStrata("MEDIUM");
	else
		HUDInventoryMixin.OnEvent(self, event);
	end
end

function WoWHackItemBarMixin:UseItemButton(index, keyState)
	for itemButton in self.itemButtonPool:EnumerateActive() do
		if itemButton.layoutIndex == index then
			if keyState == "down" then
				if itemButton:GetButtonState() == "NORMAL" then
					itemButton:SetButtonState("PUSHED");
				end
				itemButton:HandleClick();
			elseif keyState == "up" then
				if itemButton:GetButtonState() == "PUSHED" then
					itemButton:SetButtonState("NORMAL");
				end
			else
				itemButton:HandleClick();
			end
			return;
		end
	end
end
