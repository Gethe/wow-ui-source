
MinimapTrackingSimpleMixin = { };

function MinimapTrackingSimpleMixin:OnLoad()
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:UpdateState();
end

function MinimapTrackingSimpleMixin:OnEvent(event, ...)
	if ( event == "MINIMAP_UPDATE_TRACKING" ) then
		self:UpdateState();
	end
end

function MinimapTrackingSimpleMixin:OnMouseUp(button)
	if ( button == "RightButton" ) then
		CancelTrackingBuff();			
	end
end

function MinimapTrackingSimpleMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetTrackingSpell();
end

function MinimapTrackingSimpleMixin:OnLeave()
	GameTooltip:Hide();
end

function MinimapTrackingSimpleMixin:UpdateState()
	local icon = GetTrackingTexture();
	if ( icon ) then
		MiniMapTrackingIcon:SetTexture(icon);
		MiniMapTracking:Show();
	else
		MiniMapTracking:Hide();
	end
end
