StatusTrayManager = {};

function StatusTrayManager.UpdateLayout()
	local yOffset = 0;
	local xOffset = -230;

	local statusFrames = {};
	if AddGMChatStatusFrameToStatusFrames then
		AddGMChatStatusFrameToStatusFrames(statusFrames);
	end
	if AddTicketStatusFrameToStatusFrames then
		AddTicketStatusFrameToStatusFrames(statusFrames);
	end
	if AddBehavioralMessagingTrayToStatusFrames then
		AddBehavioralMessagingTrayToStatusFrames(statusFrames);
	end
	if AddWowSurveyStatusFrameToStatusFrames then
		AddWowSurveyStatusFrameToStatusFrames(statusFrames);
	end

	local buffOffset = 0;
	for i, frame in ipairs(statusFrames) do
		frame:ClearAllPoints();
		if i == 1 then
			frame:SetPoint("TOPRIGHT", xOffset, yOffset);
		else
			frame:SetPoint("TOPRIGHT", statusFrames[i - 1], "TOPLEFT");
		end

		buffOffset = math.max(buffOffset, frame:GetHeight());
	end

	return buffOffset;
end

function StatusTrayManager.UpdateTrayAndBuffFrameLayout()
	local buffOffset = StatusTrayManager.UpdateLayout();
	if BuffFrame:IsInDefaultPosition() then
		local anchor = EditModeManagerFrame:GetDefaultAnchor(BuffFrame);
		BuffFrame:ClearAllPoints();
		BuffFrame:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.offsetX, anchor.offsetY - buffOffset);
	end
end
