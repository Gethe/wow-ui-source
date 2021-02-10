CovenantCallingQuestMixin = {};

function CovenantCallingQuestMixin:Set(calling, covenantData)
	self.calling = calling;
	self.questID = calling.questID;
	self.covenantData = covenantData;
	self:Update();
	self:Show();
end

function CovenantCallingQuestMixin:Update()
	self:UpdateIcon();
	self:UpdateBang();
end

function CovenantCallingQuestMixin:UpdateIcon()
	if self.covenantData then
		local icon = self.calling:GetIcon(self.covenantData);
		self.Icon:SetTexture(icon);
		self.Highlight:SetTexture(icon);
	end
end

function CovenantCallingQuestMixin:UpdateBang()
	local bang = self.calling:GetBang();
	self.Bang:SetShown(bang ~= nil);
	if bang then
		self.Bang:SetAtlas(bang, true);
	end

	self.Glow:SetShown(self.calling:GetState() == Enum.CallingStates.QuestOffer);
end

function CovenantCallingQuestMixin:GetDaysUntilNext()
	return self:GetParent():GetDaysUntilNext(self.calling);
end

function CovenantCallingQuestMixin:GetDaysUntilNextString()
	return _G["BOUNTY_BOARD_NO_CALLINGS_DAYS_" .. self:GetDaysUntilNext()] or BOUNTY_BOARD_NO_CALLINGS_DAYS_1;
end

function CovenantCallingQuestMixin:UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local state = self.calling:GetState();
	if state == Enum.CallingStates.QuestOffer then
		self:UpdateTooltipQuestOffer();
	elseif state == Enum.CallingStates.QuestActive then
		self:UpdateTooltipQuestActive();
	elseif state == Enum.CallingStates.QuestCompleted then
		GameTooltip:SetText(self:GetDaysUntilNextString(), HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	GameTooltip:Show();
end

function CovenantCallingQuestMixin:UpdateTooltipCheckHasQuestData()
	if HaveQuestData(self.calling.questID) then
		GameTooltip_SetTooltipWaitingForData(GameTooltip, false);
		return true;
	end

	GameTooltip_AddColoredLine(GameTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
	GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
	return false;
end

function CovenantCallingQuestMixin:UpdateTooltipQuestOffer()
	TaskPOI_OnEnter(self);
end

-- NOTE/TODO: Basically lifted from TaskPOI_OnEnter, but there were enough differences that I decided to keep this separate until we get approvals
function CovenantCallingQuestMixin:UpdateTooltipQuestActive()
	if not self:UpdateTooltipCheckHasQuestData() then
		return;
	end

	local questID = self.calling.questID;

	-- Add the quest title
	local title = QuestUtils_GetQuestName(questID);
	GameTooltip_SetTitle(GameTooltip, title);

	-- Add the "faction", really just the covenant name
	-- TODO: Not planning on being able to use the same system that WQs use to put the faction on the quest tooltip, so just grab covenant name for now
	if self.covenantData then
		GameTooltip_AddNormalLine(GameTooltip, self.covenantData.name);
	end

	-- Add the remaining time
	GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);

	-- Add the objectives
	local questCompleted = C_QuestLog.IsComplete(questID);
	local shouldShowObjectivesAsStatusBar = false; -- Not sure where to pull this from yet, MapIndicatorQuestDataProviderMixin:AddMapIndicatorQuest is what was setting it before

	if shouldShowObjectivesAsStatusBar then
		if questCompleted then
			GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. QUEST_WATCH_QUEST_READY, HIGHLIGHT_FONT_COLOR);
		else
			local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
			if questLogIndex then
				questDescription = select(2, GetQuestLogQuestText(questLogIndex));
				GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
			end
		end
	end

	local isFirstObjectiveFinished;
	for objectiveIndex = 1, self.calling.numObjectives do
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, objectiveIndex, false);
		if objectiveIndex == 1 then
			isFirstObjectiveFinished = finished;
		end

		local showObjective = not (finished and self.isThreat);
		if showObjective then
			if self.shouldShowObjectivesAsStatusBar and numRequired > 0 then
				local percent = math.floor((numFulfilled/numRequired) * 100);
				GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));
			elseif objectiveText and objectiveText ~= "" then
				local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
			end
		end
	end

	local showObjective = not (isFirstObjectiveFinished and self.isThreat);
	if showObjective then
		local percent = C_TaskQuest.GetQuestProgressBarInfo(questID);
		if percent then
			GameTooltip_ShowProgressBar(GameTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent));
		end
	end

	-- Add the rewards
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CALLING_QUEST_TOOLTIP_DESCRIPTION, true);
	GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD);
end

function CovenantCallingQuestMixin:OnEnter()
	self:UpdateTooltip();
	self.Highlight:Show();
end

function CovenantCallingQuestMixin:OnLeave()
	if self.usedTaskPOI then
		TaskPOI_OnLeave(self);
		self.usedTaskPOI = nil;
	else
		GameTooltip:Hide();
	end

	self.Highlight:Hide();
end

function CovenantCallingQuestMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" and upInside then
		local state = self.calling:GetState();

		if state == Enum.CallingStates.QuestActive then
			PlaySound(SOUNDKIT.UI_COVENANT_CALLINGS_CLICK_ON_QUEST);
			QuestMapFrame_OpenToQuestDetails(self.questID);
		elseif state == Enum.CallingStates.QuestOffer then
			OpenWorldMap(C_TaskQuest.GetQuestZoneID(self.questID));
		end
	end
end

CovenantCallingsMixin = {};

function CovenantCallingsMixin:OnLoad()
	self.pool = CreateFramePool("Frame", self, "CovenantCallingQuestTemplate");
	self.layout = AnchorUtil.CreateGridLayout(nil, Constants.Callings.MaxCallings, 44, 0);
end

local CovenantCallingsEvents = {
	"COVENANT_CALLINGS_UPDATED",
	"QUEST_TURNED_IN",
	"QUEST_ACCEPTED",
}

function CovenantCallingsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantCallingsEvents);
end

function CovenantCallingsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantCallingsEvents);
end

function CovenantCallingsMixin:OnEvent(event, ...)
	if event == "COVENANT_CALLINGS_UPDATED" then
		self:OnCovenantCallingsUpdated(...);
	elseif event == "QUEST_TURNED_IN" then
		self:OnQuestTurnedIn(...);
	elseif event == "QUEST_ACCEPTED" then
		self:OnQuestAccepted(...);
	end
end

function CovenantCallingsMixin:CheckUpdateForQuestID(questID)
	if C_QuestLog.IsQuestCalling(questID) then
		self:Update();
	end
end

function CovenantCallingsMixin:OnQuestTurnedIn(questID)
	self:CheckUpdateForQuestID(questID);
end

function CovenantCallingsMixin:OnQuestAccepted(questID)
	self:CheckUpdateForQuestID(questID);
end

function CovenantCallingsMixin:Update()
	self.covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
	C_CovenantCallings.RequestCallings();
	self:UpdateBackground();
end

function CovenantCallingsMixin:UpdateBackground()
	if self.covenantData then
		local decor = ("shadowlands-landingpage-callingsdecor-%s"):format(self.covenantData.textureKit);
		self.Decor:SetAtlas(decor, true);
	end
end

function CovenantCallingsMixin:OnCovenantCallingsUpdated(callings)
	self.pool:ReleaseAll();

	local unlocked = C_CovenantCallings.AreCallingsUnlocked();
	self:SetShown(unlocked);

	if unlocked and self.covenantData then
		self:ProcessCallings(callings);

		local frames = {};
		for index, calling in ipairs(self.callings) do
			local callingFrame = self.pool:Acquire();
			callingFrame:Set(calling, self.covenantData);
			table.insert(frames, callingFrame);
		end

		AnchorUtil.GridLayout(frames, AnchorUtil.CreateAnchor("LEFT", self.Decor, "LEFT", -42, 0), self.layout);
		self:CheckDisplayHelpTip();
	end
end

-- TODO: Not sure how we want the sort to behave yet...maybe using time remaining similar to emissary quests?
local function CompareCallings(c1, c2)
	if c1:IsLocked() ~= c2:IsLocked() then
		return c2:IsLocked();
	end

	if c2:IsLocked() then
		return true;
	end

	if c1:IsActive() ~= c2:IsActive() then
		return not c1:IsActive();
	end

	return c1.tempTimeRemaining < c2.tempTimeRemaining;
end

function CovenantCallingsMixin:ProcessCallings(callings)
	self.callings = {};
	for index = 1, Constants.Callings.MaxCallings do
		local calling = callings[index];
		if calling then
			calling = CovenantCalling_Create(calling);

			-- Cache the remaining time on the quest to help sort
			calling.tempTimeRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(calling.questID) or 0;
		else
			calling = CovenantCalling_Create();
			calling.tempTimeRemaining = 0;
		end

		self.callings[index] = calling;
	end

	table.sort(self.callings, CompareCallings);

	self.firstLockedIndex = nil;
	for index, calling in ipairs(self.callings) do
		calling:SetIndex(index);

		if not self.firstLockedIndex and calling:IsLocked() then
			self.firstLockedIndex = index;
		end

		-- Then nuke the remaining time after the sort, must be updated anyway.
		calling.tempTimeRemaining = nil;
	end
end

function CovenantCallingsMixin:GetHelptipTargetFrame()
	-- Find right-most frame
	local maxX = 0;
	local targetFrame;
	for frame in self.pool:EnumerateActive() do
		if frame.calling:GetState() == Enum.CallingStates.QuestOffer then
			if not targetFrame or maxX < frame:GetLeft() then
				targetFrame = frame;
				maxX = frame:GetLeft();
			end
		end
	end

	return targetFrame;
end

function CovenantCallingsMixin:GetDaysUntilNext(calling)
	if self.firstLockedIndex and calling:IsLocked() then
		return math.max(0, calling:GetIndex() - self.firstLockedIndex + 1);
	end

	return 0;
end

function CovenantCallingsMixin:CheckDisplayHelpTip()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_CALLINGS) then
		local target = self:GetHelptipTargetFrame();

		-- It's ok to wait to show this until there's a valid target.
		if target then
			HelpTip:Show(target, {
				text = FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_CALLINGS,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_CALLINGS,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = 14,
				offsetY = 1,
				useParentStrata = true,
			});
		end
	end
end

CovenantCallings = {};

function CovenantCallings.Create(parent)
	return CreateFrame("Frame", nil, parent, "CovenantCallingsTemplate");
end