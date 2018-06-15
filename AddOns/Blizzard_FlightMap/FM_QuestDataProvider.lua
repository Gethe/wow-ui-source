FlightMap_QuestDataProviderMixin = CreateFromMixins(QuestDataProviderMixin);

function FlightMap_QuestDataProviderMixin:GetPinTemplate()
	return "FlightMap_QuestPinTemplate";
end

function FlightMap_QuestDataProviderMixin:ShouldShowQuest(questID, mapType)
	return true;
end

function FlightMap_QuestDataProviderMixin:AddQuest(...)
	local pin = QuestDataProviderMixin.AddQuest(self, ...);
	if pin.isSuperTracked or pin.style == "normal" then
		pin:SetAlphaLimits(nil, 0.0, 1.0);
		pin:SetAlpha(1);
	else
		pin:SetAlphaLimits(2.0, 0.0, 1.0);
	end
end

FlightMap_QuestPinMixin = { };

function FlightMap_QuestPinMixin:OnLoad()
	QuestPinMixin.OnLoad(self);

	self:SetAlphaLimits(2.0, 0.0, 1.0);
	self:SetScalingLimits(1, 0.4125, 0.425);

	-- Flight points can nudge quest pins.
	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end