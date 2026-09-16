-- Mainline QueueStatusFrame Overrides

function QueueStatusButtonMixin:UpdateDefaultAnchor()
	-- In Modern, the QueueStatusButton is anchored to the MicroMenu.
	if (self:IsInDefaultPosition()) then
		-- Position button so that it is facing towards the center of the screen to avoid it going offscreen
		local microMenuPosition = FrameUtil.GetScreenQuadrant(MicroMenuContainer);
		local isMenuHorizontal = MicroMenu.isHorizontal;
		local point, relativeTo, relativePoint, offsetX, offsetY;

		self:ClearAllPoints();
		if MicroMenu:GetParent() == MicroMenuContainer then
			-- Micro menu is in default container. Anchor to the micro menu
			relativeTo = MicroMenu;

			if isMenuHorizontal then
				if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
					point, relativePoint, offsetX, offsetY = "BOTTOMLEFT", "BOTTOMRIGHT", 15, 12;
				elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
					point, relativePoint, offsetX, offsetY = "BOTTOMRIGHT", "BOTTOMLEFT", -15, 12;
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
					point, relativePoint, offsetX, offsetY = "TOPLEFT", "TOPRIGHT", 15, -12;
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopRight then
					point, relativePoint, offsetX, offsetY = "TOPRIGHT", "TOPLEFT", -15, -12;
				end
			else
				if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
					point, relativePoint, offsetX, offsetY = "BOTTOMLEFT", "TOPLEFT", 0, 18;
				elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
					point, relativePoint, offsetX, offsetY = "BOTTOMRIGHT", "TOPRIGHT", 0, 18;
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
					point, relativePoint, offsetX, offsetY = "TOPLEFT", "BOTTOMLEFT", 0, -18;
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopRight then
					point, relativePoint, offsetX, offsetY = "TOPRIGHT", "BOTTOMRIGHT", 0, -18;
				end
			end
		else
			-- Micro menu isn't in it's normal container so don't anchor to it and instead anchor relative to the container
			relativeTo = MicroMenuContainer;
			offsetX, offsetY = 0, 0;

			if isMenuHorizontal then
				if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
					point, relativePoint = "BOTTOMRIGHT", "BOTTOMRIGHT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
					point, relativePoint = "BOTTOMLEFT", "BOTTOMLEFT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
					point, relativePoint = "TOPRIGHT", "TOPRIGHT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopRight then
					point, relativePoint = "TOPLEFT", "TOPLEFT";
				end
			else
				if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
					point, relativePoint = "TOPLEFT", "TOPLEFT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
					point, relativePoint = "TOPRIGHT", "TOPRIGHT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
					point, relativePoint = "BOTTOMLEFT", "BOTTOMLEFT";
				elseif microMenuPosition == FrameUtilQuadrantEnum.TopRight then
					point, relativePoint = "BOTTOMRIGHT", "BOTTOMRIGHT";
				end
			end
		end

		-- Make sure to account for scale since it can be changed via edit mode
		local scale = self:GetScale();
		offsetX = offsetX / scale;
		offsetY = offsetY / scale;

		self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);

		-- QueueStatusFrame (the mouseover tooltip) changes anchors based on our position.
		QueueStatusFrame:UpdatePosition(microMenuPosition, isMenuHorizontal);
	else
		-- If we aren't in the default position (anchored to the MicroMenu),
		-- then still update the QueueStatusFrame anchor, based on our own location.
		local position = FrameUtil.GetScreenQuadrant(self);
		QueueStatusFrame:UpdatePosition(position, true);
	end
end
