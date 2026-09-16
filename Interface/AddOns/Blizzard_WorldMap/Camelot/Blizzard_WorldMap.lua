
function WorldMapMixin:AdjustOverlayFrames()
	if self.WorldMapTrackingOptionsButton then
		self.WorldMapTrackingOptionsButton:ClearAllPoints();
		self.WorldMapTrackingOptionsButton:SetPoint("LEFT", self.NavBar, "RIGHT", 10, -2);
	end

	if self.WorldMapTrackingPinButton then
		self.WorldMapTrackingPinButton:ClearAllPoints();
		self.WorldMapTrackingPinButton:SetPoint("TOPLEFT", self:GetCanvasContainer(), "TOPLEFT", 3, 0);
	end
end

function WorldMapNavBarMixin:GetTopMostUIMapType()
	return Enum.UIMapType.World;
end
