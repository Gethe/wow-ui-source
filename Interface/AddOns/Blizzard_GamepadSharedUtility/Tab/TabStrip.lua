-- Gamepad only horizontal tab strip that replaces a frame's vertical side tabs (SidePanelTabButtonMixin or LargeSideTabButtonTemplate).
-- Usage: Inherit GamepadTabStripTemplate in XML (hidden), call ReplaceSideTabs(sideTabs) in the frame's SetupGamepad,
-- and call SetGamepadFocused(focused) from FocusGamepad/UnfocusGamepad to show or hide the LB/RB indicators.
GamepadTabStripMixin = {};

-- Replaces a frame's vertical side tabs; selecting a strip tab runs the side tab's own mouse-up handler.
function GamepadTabStripMixin:ReplaceSideTabs(sideTabs)
	self.tabIDToSideTab = {};
	for _, sideTab in ipairs(sideTabs) do
		local tabID = self:AddIconTab(sideTab.activeAtlas, sideTab.tooltipText);
		self.tabIDToSideTab[tabID] = sideTab;

		hooksecurefunc(sideTab, "SetChecked", function(_, checked)
			if checked then
				self:SetTabVisuallySelected(tabID);
			end
		end);

		sideTab:Hide();
	end

	self:SetTabSelectedCallback(function(tabID)
		self.tabIDToSideTab[tabID]:OnMouseUp("LeftButton", true);
		return true;
	end);

	self.TabIndicators:SetUpTabSystem(self);
	self:Show();
end

function GamepadTabStripMixin:SetGamepadFocused(focused)
	self.TabIndicators:SetShown(focused);
end
