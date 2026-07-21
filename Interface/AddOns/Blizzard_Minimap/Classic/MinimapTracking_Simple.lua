
MinimapTrackingSimpleMixin = { };

function MinimapTrackingSimpleMixin:OnLoad()
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
end

function MinimapTrackingSimpleMixin:OnEvent(event, ...)
	if ( event == "MINIMAP_UPDATE_TRACKING" ) then
		local icon = GetTrackingTexture();
		if ( icon ) then
			MiniMapTrackingIcon:SetTexture(icon);
			MiniMapTracking:Show();
		else
			MiniMapTracking:Hide();
		end
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
