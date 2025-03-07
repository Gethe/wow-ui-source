GlueCollectionsMixin = {};

function GlueCollectionsMixin:OnShow()
	-- Currently warband scenes are the only collection type at glues.
	self:SetTitle(WARBAND_SCENES);
	self:SetPortraitAtlasRaw("campcollection-icon-camp");
	self.GlueWarbandSceneJournal:Show();
	EventRegistry:TriggerEvent("GlueCollections.OnShow");
end

function GlueCollectionsMixin:OnHide()
	EventRegistry:TriggerEvent("GlueCollections.OnHide");
end

function GlueCollectionsMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self.CloseButton:Click();
	end
end