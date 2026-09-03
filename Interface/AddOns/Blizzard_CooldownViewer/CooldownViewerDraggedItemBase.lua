CooldownViewerDraggedItemBaseMixin = {};

local draggedItemInstance;

function CooldownViewerDraggedItemBaseMixin:OnUpdate()
	local topLevel = GetAppropriateTopLevelParent();
	local x, y = InputUtil.GetCursorPosition(topLevel);
	self:SetPoint("TOPLEFT", topLevel, "BOTTOMLEFT", x, y);
end

function CooldownViewerDraggedItemBaseMixin:SetToCursor(iconFileID)
	self.Icon:SetTexture(iconFileID);
	self:Show();
end

function CooldownViewerDraggedItem_Pickup(iconFileID)
	if not draggedItemInstance then
		draggedItemInstance = CreateFrame("Frame", nil, GetAppropriateTopLevelParent(), "CooldownViewerDraggedItemBaseTemplate");
	end

	draggedItemInstance:SetToCursor(iconFileID);
end

function CooldownViewerDraggedItem_Clear()
	if draggedItemInstance then
		draggedItemInstance:StopMovingOrSizing();
		draggedItemInstance:Hide();
	end
end

function CooldownViewerDraggedItem_SetIsLegalTarget(isLegal)
	if draggedItemInstance then
		if isLegal then
			draggedItemInstance.Icon:SetVertexColor(1, 1, 1);
		else
			draggedItemInstance.Icon:SetVertexColor(ERROR_COLOR:GetRGB());
		end
	end
end
