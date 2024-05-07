
POIButtonHighlightManager = {};

function POIButtonHighlightManager:SetHighlight(questID)
	if not questID or self.questID == questID then
		return;
	end
	if self.questID then
		self:ClearHighlight();
	end
	self.questID = questID;
	EventRegistry:TriggerEvent("SetHighlightedQuestPOI", questID);
end

function POIButtonHighlightManager:ClearHighlight()
	if not self.questID then
		return;
	end
	local oldID = self.questID;
	self.questID = nil;
	EventRegistry:TriggerEvent("ClearHighlightedQuestPOI", oldID);
end

function POIButtonHighlightManager:HasHighlight()
	return self.questID ~= nil;
end

function POIButtonHighlightManager:GetQuestID()
	return self.questID;
end
