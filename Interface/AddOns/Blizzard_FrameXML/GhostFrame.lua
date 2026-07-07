GhostFrameMixin = {}

function GhostFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
end

function GhostFrameMixin:OnEvent(event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if addonName == "Blizzard_UIWidgets" then
			self:ClearAllPoints();
			self:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -4);
		end
	end
end
