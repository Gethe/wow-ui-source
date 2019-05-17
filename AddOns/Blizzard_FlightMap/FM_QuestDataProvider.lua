FlightMap_QuestDataProviderMixin = CreateFromMixins(QuestDataProviderMixin);

function FlightMap_QuestDataProviderMixin:GetPinTemplate() -- override
	return "FlightMap_QuestPinTemplate";
end

function FlightMap_QuestDataProviderMixin:ShouldShowQuest(questID, mapType, doesMapShowTaskObjectives) -- override
	return not QuestUtils_IsQuestWorldQuest(questID);
end

function FlightMap_QuestDataProviderMixin:AddQuest(...) -- override
	local pin = QuestDataProviderMixin.AddQuest(self, ...);
	if pin.isSuperTracked or pin.style == "normal" then
		pin:SetAlphaLimits(1.0, 1.0, 1.0);
	else
		pin:SetAlphaLimits(2.0, 0.0, 1.0);
	end

	return pin;
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