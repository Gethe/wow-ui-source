
POIButtonOwnerMixin = {};

function POIButtonOwnerMixin:Init(onCreateFunc, useHighlightManager)
	self.buttonPool = CreateFramePool("Button", self, "POIButtonTemplate", FramePool_HideAndClearAnchorsWithReset);
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
	if self.poiSelectedButton then
		self:ClearSelection();
	end

	self.poiSelectedButton = poiButton;
	poiButton:SetSelected();
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
		poiButton:ClearSelection();
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

function POIButtonOwnerMixin:GetButtonForQuestInternal(questID, style, index)
	local poiButton, isNewButton = self.buttonPool:Acquire();
	poiButton:SetStyle(style);

	if style == POIButtonUtil.Style.Numeric then
		poiButton:SetNumber(index);
	end

	if isNewButton then
		self:CallOnCreateFunction(poiButton);
	end

	poiButton:SetEnabled(style ~= POIButtonUtil.Style.QuestDisabled);
	poiButton.questID = questID;
	poiButton.poiParent = self;
	poiButton.pingWorldMap = false;
	poiButton:EvaluateManagedHighlight();
	return poiButton;
end

function POIButtonOwnerMixin:GetButtonForQuest(questID, style, index)
	if C_QuestLog.IsQuestCalling(questID) then
		return nil;
	end

	local poiButton = self:GetButtonForQuestInternal(questID, style, index);
	poiButton:UpdateButtonStyle();
	poiButton:Show();
	return poiButton;
end

function POIButtonOwnerMixin:GetButtonForTrackable(trackableType, trackableID)
	local poiButton, isNewButton = self.buttonPool:Acquire();
	poiButton:SetStyle(POIButtonUtil.Style.ContentTracking);

	if isNewButton then
		self:CallOnCreateFunction(poiButton);
	end

	poiButton:SetTrackable(trackableType, trackableID);
	poiButton:UpdateButtonStyle();
	poiButton.poiParent = self;
	poiButton:Show();
	return poiButton;
end
