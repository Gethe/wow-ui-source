
POIButtonOwnerMixin = {};


local function HideAndClearAnchorsWithReset(pool, frame)
	Pool_HideAndClearAnchors(pool, frame);
	frame:Reset();
end

function POIButtonOwnerMixin:Init(onCreateFunc, useHighlightManager)
	self.buttonPool = CreateFramePool("Button", self, "POIButtonTemplate", HideAndClearAnchorsWithReset);
	self.poiOnCreateFunc = onCreateFunc;
	self.useHighlightManager = useHighlightManager;
end

function POIButtonOwnerMixin:ResetUsage()
	self.buttonPool:ReleaseAll();
	self.poiSelectedButton = nil;
end

function POIButtonOwnerMixin:FindButtonByQuestID(questID)
	for poiButton in self.buttonPool:EnumerateActive() do
		if poiButton:GetQuestID() == questID then
			return poiButton;
		end
	end

	return nil;
end

function POIButtonOwnerMixin:FindButtonByTrackable(trackableType, trackableID)
	for poiButton in self.buttonPool:EnumerateActive() do
		local buttonTrackableType, buttonTrackableID = poiButton:GetTrackable();
		if (buttonTrackableType == trackableType) and (buttonTrackableID == trackableID) then
			return poiButton;
		end
	end

	return nil;
end

function POIButtonOwnerMixin:SelectButton(poiButton)
	self:ClearSelection();
	self.poiSelectedButton = poiButton;
	poiButton:SetSelected(true);
	poiButton:UpdateButtonStyle();
end

function POIButtonOwnerMixin:SelectSuperTrackedButton()
	local questID = C_SuperTrack.GetSuperTrackedQuestID();
	local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent();
	if questID then
		self:SelectButtonByQuestID(questID);
	elseif trackableType and trackableID then
		self:SelectButtonByTrackable(trackableType, trackableID);
	else
		self:ClearSelection();
	end
end

function POIButtonOwnerMixin:SelectButtonByQuestID(questID)
	local poiButton = questID and self:FindButtonByQuestID(questID) or nil;
	if poiButton then
		self:SelectButton(poiButton);
	else
		self:ClearSelection();
	end
end

function POIButtonOwnerMixin:SelectButtonByTrackable(trackableType, trackableID)
	local poiButton = trackableType and self:FindButtonByTrackable(trackableType, trackableID) or nil;
	if poiButton then
		self:SelectButton(poiButton);
	else
		self:ClearSelection();
	end
end

function POIButtonOwnerMixin:ClearSelection()
	local poiButton = self.poiSelectedButton;
	if poiButton then
		self.poiSelectedButton = nil;
		poiButton:SetSelected(false);
		poiButton:UpdateButtonStyle();
	end
end

function POIButtonOwnerMixin:HideAllButtons()
	self.buttonPool:ReleaseAll();
end

function POIButtonOwnerMixin:CallOnCreateFunction(poiButton)
	if self.poiOnCreateFunc then
		self.poiOnCreateFunc(poiButton);
	end
end

function POIButtonOwnerMixin:GetButtonForStyleInternal(style)
	local poiButton, isNewButton = self.buttonPool:Acquire();
	poiButton:SetStyle(style);

	if isNewButton then
		self:CallOnCreateFunction(poiButton);
	end

	return poiButton;
end

function POIButtonOwnerMixin:PostInitButtonInternal(poiButton)
	poiButton:UpdateSelected();
	poiButton:Show();
	return poiButton;
end

function POIButtonOwnerMixin:GetButtonForQuestInternal(questID, style)
	local poiButton = self:GetButtonForStyleInternal(style);

	poiButton:SetEnabled(style ~= POIButtonUtil.Style.QuestDisabled);
	poiButton:SetQuestID(questID);
	poiButton:EvaluateManagedHighlight();
	return poiButton;
end

function POIButtonOwnerMixin:GetButtonForQuest(questID, style)
	if not GetCVarBool("questPOI") then
		return nil;
	end

	if C_QuestLog.IsQuestCalling(questID) then
		return nil;
	end

	local poiButton = self:GetButtonForQuestInternal(questID, style);
	return self:PostInitButtonInternal(poiButton);
end

function POIButtonOwnerMixin:GetButtonForTrackable(trackableType, trackableID)
	local poiButton = self:GetButtonForStyleInternal(POIButtonUtil.Style.ContentTracking);
	poiButton:SetTrackable(trackableType, trackableID);
	return self:PostInitButtonInternal(poiButton);
end

function POIButtonOwnerMixin:GetButtonForAreaPOI(areaPOIID)
	local poiButton = self:GetButtonForStyleInternal(POIButtonUtil.Style.AreaPOI);
	poiButton:SetAreaPOIID(areaPOIID);
	return self:PostInitButtonInternal(poiButton);
end
