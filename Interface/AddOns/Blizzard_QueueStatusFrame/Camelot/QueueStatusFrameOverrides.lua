-- Camelot QueueStatusFrame Overrides

local QUEUE_STATUS_MINIMAP_INSET_ID = "CamelotQueueStatusButton";
local QUEUE_STATUS_MINIMAP_INSET_DISTANCE_SCALAR = 0.8;

-- Camelot uses the Vanilla-style group finder instead of the Mainline PVEFrame-based system.
-- LFGListUtil_OpenBestWindow (called by the base implementation) is not available here.
function QueueStatusButtonMixin:ShowLFGFrame(toggle)
	if toggle then
		LFGVanilla_ToggleFrame();
	else
		LFGVanilla_ShowFrame();
	end
end

function QueueStatusButtonMixin:UpdateDefaultAnchor()
	local isCircularInset = true;

	-- In Camelot, the QueueStatusButton is anchored to the edge of the Minimap.
	-- If the Minimap scale changes, calculate where the default position should
	-- be based on the scale.
	if (self:IsInDefaultPosition()) then
		local minimapScale = MinimapCluster:GetEditModeScale();

		local defaultAnchorInfo = EditModePresetLayoutManager:GetDefaultSystemAnchorInfo(self.system, self.systemIndex);
		local scaledX = defaultAnchorInfo.offsetX * minimapScale / self:GetScale();
		local scaledY = defaultAnchorInfo.offsetY * minimapScale / self:GetScale();

		self:ClearAllPoints();
		self:SetPoint(defaultAnchorInfo.point, defaultAnchorInfo.relativeTo, defaultAnchorInfo.relativePoint, scaledX, scaledY);

		-- When using the default Minimap anchor, QueueStatusFrame (the mouseover tooltip)
		-- should always act like we're in the TopRight quadrant.
		QueueStatusFrame:UpdatePosition(FrameUtilQuadrantEnum.TopRight, true);
	else
		-- If we aren't in the default position (anchored to the Minimap),
		-- then still update the QueueStatusFrame anchor, based on our own location.
		local position = FrameUtil.GetScreenQuadrant(self);
		QueueStatusFrame:UpdatePosition(position, true);
	end

	if self:IsInDefaultPosition() then
		MinimapUtil.UpdateInsetForFrame(
			self,
			QUEUE_STATUS_MINIMAP_INSET_ID,
			QUEUE_STATUS_MINIMAP_INSET_DISTANCE_SCALAR,
			isCircularInset
		);
	else
		C_Minimap.ClearMinimapInsetInfo(QUEUE_STATUS_MINIMAP_INSET_ID);
	end
end

local QueueStatusButtonMixin_OnShow = QueueStatusButtonMixin.OnShow;
function QueueStatusButtonMixin:OnShow()
	local isCircularInset = true;

	QueueStatusButtonMixin_OnShow(self);
	if self:IsInDefaultPosition() then
		MinimapUtil.UpdateInsetForFrame(
			self,
			QUEUE_STATUS_MINIMAP_INSET_ID,
			QUEUE_STATUS_MINIMAP_INSET_DISTANCE_SCALAR,
			isCircularInset
		);
	else
		C_Minimap.ClearMinimapInsetInfo(QUEUE_STATUS_MINIMAP_INSET_ID);
	end
end

local QueueStatusButtonMixin_OnHide = QueueStatusButtonMixin.OnHide;
function QueueStatusButtonMixin:OnHide()
	QueueStatusButtonMixin_OnHide(self);
	C_Minimap.ClearMinimapInsetInfo(QUEUE_STATUS_MINIMAP_INSET_ID);
end

function QueueStatusDropdown_AddLFGListButtons(description, queueStatusButton)
	description:CreateButton(LFG_LIST_VIEW_GROUP, function()
		queueStatusButton:ShowLFGFrame();
	end);

	local button = description:CreateButton(UNLIST_MY_GROUP, function()
		C_LFGList.RemoveListing();
		LFGBrowse_DoSearch();
	end);

	if IsInGroup() and not UnitIsGroupLeader("player") then
		button:SetEnabled(false);
	end
end
