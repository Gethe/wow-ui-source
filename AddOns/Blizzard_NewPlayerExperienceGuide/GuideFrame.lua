UIPanelWindows["GuideFrame"] = { area = "left", pushable = 1, whileDead = 1, width = 359, height = 608 };

Enum.GuideFrameState =
{
	StartGuiding = 1,
	StopGuiding = 2,
	CannotGuide = 3,
};

GuideFrameMixin = {};

function GuideFrameMixin:OnLoad()
	self.Title:SetFontObjectsToTry("Fancy30Font", "Fancy27Font", "Fancy24Font", "Fancy24Font", "Fancy18Font", "Fancy16Font");
	self:SetPortraitToAsset("Interface/Icons/UI_GreenFlag");
end

function GuideFrameMixin:OnEvent(event, ...)
	-- TODO: Needs backend
end

function GuideFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	self:BeginGuideInteraction();
end

function GuideFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	C_GossipInfo.CloseGossip();
end

do
	local stateSetup =
	{
		[Enum.GuideFrameState.StartGuiding] =
		{
			title = NPEV2_CHAT_GUIDE_FRAME_TITLE_BE_A_GUIDE,
			descriptionAlignment = "LEFT",
			description = NPEV2_CHAT_GUIDE_FRAME_DESCRIPTION_BE_A_GUIDE,
			buttonText = NPEV2_CHAT_GUIDE_FRAME_BUTTON_APPLY,
			displayCriteria = true,
		},

		[Enum.GuideFrameState.StopGuiding] =
		{
			title = NPEV2_CHAT_GUIDE_FRAME_TITLE_STOP_GUIDING,
			description = NPEV2_CHAT_GUIDE_FRAME_DESCRIPTION_STOP_GUIDING,
			buttonText = NPEV2_CHAT_GUIDE_FRAME_BUTTON_STOP_GUIDING,
			anchorButtonAfterText = true,
		},

		[Enum.GuideFrameState.CannotGuide] =
		{
			title = NPEV2_CHAT_GUIDE_FRAME_TITLE_BE_A_GUIDE,
			buttonText = NPEV2_CHAT_GUIDE_FRAME_BUTTON_CLOSE,
		},
	};

	local function MakeAchievementLink(id)
		local link = GetAchievementLink(id);
		local _, complete = GetAchievementInfoFromHyperlink(link);
		if complete then
			return link:gsub("ffffff00", "ff20ff20"), complete;
		end

		return link, complete;
	end

	-- These functions return individual criterion data:
	-- Display Text (nil means not to show it to the user)
	-- IsComplete
	-- Error state to enter if not complete, if there's no error state, the "request to guide" pane is shown
	local criteria =
	{
		function()
			local requiredLevel = C_PlayerMentorship.GetMentorLevelRequirement() or GetMaxPlayerLevel();
			return UNIT_LEVEL_TEMPLATE:format(requiredLevel), UnitLevel("player") >= requiredLevel;
		end,

		function()
			local link, completed = MakeAchievementLink(978);
			return NPEV2_CHAT_GUIDE_FRAME_ACHIEVEMENT_EARNED:format(link), completed;
		end,

		function()
			local achievements = C_PlayerMentorship.GetMentorOptionalAchievementIDs();
			local achievementStrings = {};
			local mustEarnAtLeast = 2;
			local completedCount = 0;
			for index, achievementID in ipairs(achievements) do
				local link, completed = MakeAchievementLink(achievementID);

				if completed or not AchievementUtil.IsFeatOfStrength(achievementID) then
					table.insert(achievementStrings, link);
				end

				if completed  then
					completedCount = completedCount + 1;
				end
			end

			achievementStrings = table.concat(achievementStrings, "\n");
			return NPEV2_CHAT_GUIDE_FRAME_ACHIEVEMENT_COUNT_EARNED:format(mustEarnAtLeast, achievementStrings), completedCount >= mustEarnAtLeast;
		end,

		-- IsMentorRestricted backed by a combined state, check this first.
		function()
			return nil, not C_SocialRestrictions.IsMuted(), "muted";
		end,

		function()
			return nil, not C_PlayerMentorship.IsMentorRestricted(), "standing";
		end,

		function()
			return nil, not IsTrialAccount(), "starter";
		end,
	};

	local function AddUserCriteria(objectivesFrame)
		objectivesFrame:ClearCriteria();
		for index, criterion in ipairs(criteria) do
			local text, isComplete = criterion();
			if text then
				objectivesFrame:AddCriterion(text, isComplete);
			end
		end

		objectivesFrame:Update();
	end

	local function EvaluateCriteria()
		for index, criterion in ipairs(criteria) do
			local _, isComplete, errorState = criterion();
			if not isComplete then
				return isComplete, errorState;
			end
		end

		return true;
	end

	function GuideFrameMixin:SetStateInternal()
		local params = stateSetup[self:GetState()];

		self.Title:SetText(params.title);

		self.ScrollFrame.Child.Text:SetJustifyH(params.descriptionAlignment or "CENTER");
		self.ScrollFrame.Child.Text:SetText(self:GetDescription() or params.description);

		local objectivesFrame = self.ScrollFrame.Child.ObjectivesFrame;
		objectivesFrame:SetShown(params.displayCriteria ~= nil);
		if params.displayCriteria then
			AddUserCriteria(objectivesFrame);
		end

		self.ScrollFrame.ConfirmationButton:SetEnabled((self:GetState() ~= Enum.GuideFrameState.StartGuiding) or self:CanGuide());
		self.ScrollFrame.ConfirmationButton:SetText(params.buttonText);

		self.ScrollFrame.ConfirmationButton:ClearAllPoints();
		if params.anchorButtonAfterText then
			self.ScrollFrame.ConfirmationButton:SetPoint("TOP", self.ScrollFrame.Child.Text, "BOTTOM", 0, -25);
		else
			self.ScrollFrame.ConfirmationButton:SetPoint("BOTTOM", self.ScrollFrame, "BOTTOM", 0, 26);
		end
	end

	function GuideFrameMixin:BeginGuideInteraction()
		local status = C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player"));
		if status == Enum.PlayerMentorshipStatus.Mentor then
			self:SetState(Enum.GuideFrameState.StopGuiding);
		else
			local canGuide, errorState = EvaluateCriteria();
			self:SetDescription(nil); -- Clear override
			self:SetCanGuide(canGuide);

			if errorState then
				self:SetState(Enum.GuideFrameState.CannotGuide, errorState);
			else
				self:SetState(Enum.GuideFrameState.StartGuiding);
			end
		end
	end
end

function GuideFrameMixin:SetDescription(description)
	self.description = description;
end

function GuideFrameMixin:GetDescription()
	return self.description;
end

function GuideFrameMixin:SetCanGuide(canGuide)
	self.canGuide = canGuide;
end

function GuideFrameMixin:CanGuide()
	return self.canGuide;
end

function GuideFrameMixin:SetStateCannotGuide(errorType)
	local message = NPEV2_CHAT_GUIDE_FRAME_ERROR_GENERIC;
	if errorType == "standing" then
		message = NPEV2_CHAT_GUIDE_FRAME_ERROR_BAD_STANDING;
	elseif errorType == "starter" then
		message = NPEV2_CHAT_GUIDE_FRAME_ERROR_STARTER_ACCOUNTS_CANNOT_GUIDE;
	elseif errorType == "muted" then
		message = NPEV2_CHAT_GUIDE_FRAME_ERROR_ACCOUNT_MUTED;
	end

	self:SetDescription(message);
	self:SetCanGuide(false);
	self:SetStateInternal();
end

do
	local GuideFrameStateHandlers = {
		[Enum.GuideFrameState.StartGuiding] = GuideFrameMixin.SetStateInternal,
		[Enum.GuideFrameState.StopGuiding] = GuideFrameMixin.SetStateInternal,
		[Enum.GuideFrameState.CannotGuide] = GuideFrameMixin.SetStateCannotGuide,
	};

	function GuideFrameMixin:SetState(state, ...)
		local fn = GuideFrameStateHandlers[state];
		if fn then
			self.state = state;
			fn(self, ...);
		end
	end

	function GuideFrameMixin:GetState()
		return self.state or Enum.GuideFrameState.StartGuiding;
	end
end

function GuideFrameMixin:ConfirmChoice()
	if self:GetState() ~= Enum.GuideFrameState.CannotGuide then
		C_GossipInfo.SelectOption(1); -- TODO: Probably enumerate the available options...this is a toggle so this is fine for now
	end

	C_GossipInfo.CloseGossip();
end