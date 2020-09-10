local ArdenwealdGardeningSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
ArdenwealdGardeningSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.None, true, true);

function ArdenwealdGardeningSecondsFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

function ArdenwealdGardeningSecondsFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

ArdenwealdGardening = {}

function ArdenwealdGardening.Create(parent)
	return CreateFrame("Frame", nil, parent, "ArdenwealdGardeningPanelTemplate");
end

ArdenwealdGardeningButtonMixin = {}

function ArdenwealdGardeningButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	GameTooltip_SetTitle(GameTooltip, GARDENWEALD_STATUS_HEADER);

	local data = C_ArdenwealdGardening.GetGardenData();
	local hasActive = data.active > 0;
	if hasActive then
		local time = ArdenwealdGardeningSecondsFormatter:Format(data.remainingSeconds);
		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_ACTIVE_COUNT:format(data.active, time));
	end

	if data.ready > 0 then
		if hasActive then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
		end
		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_READY_COUNT:format(data.ready));
	elseif not hasActive then
		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_DORMANT);
	end

	GameTooltip:Show();

	self.Highlight:Show();
	self.Icon2:Show();
end

function ArdenwealdGardeningButtonMixin:OnLeave()
	GameTooltip_Hide();

	self.Highlight:Hide();
	self.Icon2:Hide();
end