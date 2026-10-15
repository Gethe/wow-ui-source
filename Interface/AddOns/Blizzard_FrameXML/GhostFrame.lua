GhostFrameMixin = {}

function SetGhostFrameShown(shown)
	GhostFrame:SetShown(shown);
end

function GhostFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");

	if not CanPortGraveyard() then
		self:Hide();
	end

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
