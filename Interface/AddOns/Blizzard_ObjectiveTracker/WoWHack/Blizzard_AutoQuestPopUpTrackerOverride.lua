local centeredAutoQuestPopup;
local centeredAutoQuestID;

local function PlayCenteredAutoQuestPopupAnimation(popup)
	popup.Contents.Shine.Flash:Play();
	popup.Contents.IconShine.Flash:Play();
end

local function IsAutoQuestCompletionBlocked()
	return (GenericTraitFrame and GenericTraitFrame:IsShown()) or (ScribeFrame and ScribeFrame:IsShown());
end

local function UpdateCenteredAutoQuestPopup(popup)
	local centeredQuestID;
	local centeredQuestTitle;
	local _, instanceType = IsInInstance();
	local isSplashShown = SplashFrame and SplashFrame:IsShown();
	local canCenterCompletionPopup = PersonalGrowingResourceDisplay and PersonalGrowingResourceDisplay:IsShown() and not isSplashShown and not IsAutoQuestCompletionBlocked() and instanceType ~= "arena";
	if canCenterCompletionPopup then
		for i = 1, GetNumAutoQuestPopUps() do
			local questID, popUpType = GetAutoQuestPopUp(i);
			if not centeredQuestID and popUpType == "COMPLETE" and QuestObjectiveTracker:ShouldDisplayAutoQuest(questID) and C_QuestInfoSystem.GetQuestClassification(questID) ~= Enum.QuestClassification.Campaign then
				local questTitle = C_QuestLog.GetTitleForQuestID(questID);
				if questTitle and questTitle ~= "" then
					centeredQuestID = questID;
					centeredQuestTitle = questTitle;
				end
			end
		end
	end

	if centeredQuestID then
		popup:Show();
		popup:Update(centeredQuestTitle, centeredQuestID, "COMPLETE");
		popup:ClearAllPoints();
		popup:SetPoint("BOTTOM", PersonalGrowingResourceDisplay, "TOP", -25, 20);
	else
		popup:Hide();
	end
	if centeredAutoQuestID ~= centeredQuestID then
		centeredAutoQuestID = centeredQuestID;
		-- Moving a popup to or from the tracker must invalidate its block layout.
		QuestObjectiveTracker:MarkDirty();
	end
end

local function MarkCenteredAutoQuestPopupDirty()
	if centeredAutoQuestPopup then
		centeredAutoQuestPopup:MarkDirty();
	end
end

local function OnPersonalGrowingResourceDisplayVisibilityChanged(_owner, frame)
	if frame == PersonalGrowingResourceDisplay then
		MarkCenteredAutoQuestPopupDirty();
	end
end

local function RestoreAutoQuestCompletionPopUps()
	for questLogIndex = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questInfo = C_QuestLog.GetInfo(questLogIndex);
		if questInfo and not questInfo.isHeader and questInfo.isAutoComplete and C_QuestLog.IsComplete(questInfo.questID) and QuestObjectiveTracker:ShouldDisplayAutoQuest(questInfo.questID) then
			if AddAutoQuestPopUp(questInfo.questID, "COMPLETE") then
				QuestObjectiveTracker:MarkDirty();
			end
		end
	end
	MarkCenteredAutoQuestPopupDirty();
end

local function OnAutoQuestCompletionBlockerVisibilityChanged()
	if not IsAutoQuestCompletionBlocked() then
		RunNextFrame(RestoreAutoQuestCompletionPopUps);
	end
	MarkCenteredAutoQuestPopupDirty();
	QuestObjectiveTracker:MarkDirty();
	CampaignQuestObjectiveTracker:MarkDirty();
end

local shouldDisplayAutoQuest = AutoQuestPopupTrackerMixin.ShouldDisplayAutoQuest;
function AutoQuestPopupTrackerMixin:ShouldDisplayAutoQuest(questID, popUpType)
	if popUpType == "COMPLETE" and (IsAutoQuestCompletionBlocked() or questID == centeredAutoQuestID) then
		return false;
	end

	return shouldDisplayAutoQuest(self, questID, popUpType);
end

local addAutoQuestPopUp = AutoQuestPopupTrackerMixin.AddAutoQuestPopUp;
function AutoQuestPopupTrackerMixin:AddAutoQuestPopUp(questID, popUpType, itemID)
	MarkCenteredAutoQuestPopupDirty();
	return addAutoQuestPopUp(self, questID, popUpType, itemID);
end

local removeAutoQuestPopUp = AutoQuestPopupTrackerMixin.RemoveAutoQuestPopUp;
function AutoQuestPopupTrackerMixin:RemoveAutoQuestPopUp(questID)
	MarkCenteredAutoQuestPopupDirty();
	removeAutoQuestPopUp(self, questID);
	if centeredAutoQuestPopup and centeredAutoQuestPopup.questID == questID then
		centeredAutoQuestPopup:Hide();
	end
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_ObjectiveTracker", function()
	-- Keep the WoWHack popup independent of tracker layout and available height.
	centeredAutoQuestPopup = CreateFrame("Frame", nil, UIParent, "AutoQuestPopUpBlockTemplate");
	centeredAutoQuestPopup:Init();
	centeredAutoQuestPopup.parentModule = QuestObjectiveTracker;
	centeredAutoQuestPopup.SlideIn = PlayCenteredAutoQuestPopupAnimation;
	centeredAutoQuestPopup:SetFrameStrata("DIALOG");
	Mixin(centeredAutoQuestPopup, DirtiableMixin);
	centeredAutoQuestPopup:SetDirtyMethod(UpdateCenteredAutoQuestPopup);
	centeredAutoQuestPopup:SetScript("OnEvent", MarkCenteredAutoQuestPopupDirty);
	centeredAutoQuestPopup:RegisterEvent("QUEST_LOG_UPDATE");
	centeredAutoQuestPopup:RegisterEvent("PLAYER_ENTERING_WORLD");

	EventRegistry:RegisterCallback("GenericTraitFrame.OnShow", OnAutoQuestCompletionBlockerVisibilityChanged, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("GenericTraitFrame.OnHide", OnAutoQuestCompletionBlockerVisibilityChanged, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("ScribeFrame.Opened", OnAutoQuestCompletionBlockerVisibilityChanged, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("ScribeFrame.Closed", OnAutoQuestCompletionBlockerVisibilityChanged, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("SplashFrame.OnShow", MarkCenteredAutoQuestPopupDirty, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("SplashFrame.OnHide", MarkCenteredAutoQuestPopupDirty, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("PersonalGrowingResourceDisplay.OnShow", OnPersonalGrowingResourceDisplayVisibilityChanged, centeredAutoQuestPopup);
	EventRegistry:RegisterCallback("PersonalGrowingResourceDisplay.OnHide", OnPersonalGrowingResourceDisplayVisibilityChanged, centeredAutoQuestPopup);

	-- The popup queue may be empty after reload even when auto-completable quests remain.
	EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
		RunNextFrame(RestoreAutoQuestCompletionPopUps);
	end);

	EventUtil.ContinueOnAddOnLoaded("Blizzard_SplashFrame", MarkCenteredAutoQuestPopupDirty);
	EventUtil.ContinueOnAddOnLoaded("Blizzard_PersonalGrowingResourceDisplay", MarkCenteredAutoQuestPopupDirty);
	MarkCenteredAutoQuestPopupDirty();
end);
