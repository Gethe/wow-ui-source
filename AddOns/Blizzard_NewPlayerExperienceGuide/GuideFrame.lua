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
end

function GuideFrameMixin:OnEvent(event, ...)
	-- TODO: Needs backend
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
			achievementID = 11240, -- bogus
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

	function GuideFrameMixin:SetStateInternal(descriptionOverride, overrideAchievementID)
		local params = stateSetup[self:GetState()];

		self.Title:SetText(params.title);

		self.ScrollFrame.Child.Text:SetJustifyH(params.descriptionAlignment or "CENTER");
		self.ScrollFrame.Child.Text:SetText(descriptionOverride or params.description);

		local achievementID = params.achievementID;
		-- This is debug code
		if achievementID then
			if overrideAchievementID then
				achievementID = overrideAchievementID;
			end
		end

		self.ScrollFrame.Child.ObjectivesFrame:SetShown(achievementID ~= nil);
		if achievementID then
			self.ScrollFrame.Child.ObjectivesFrame:SetAchievement(achievementID);
		end

		self.ScrollFrame.ConfirmationButton:SetEnabled(not achievementID or not select(4, GetAchievementInfo(achievementID)));
		self.ScrollFrame.ConfirmationButton:SetText(params.buttonText);

		self.ScrollFrame.ConfirmationButton:ClearAllPoints();
		if params.anchorButtonAfterText then
			self.ScrollFrame.ConfirmationButton:SetPoint("TOP", self.ScrollFrame.Child.Text, "BOTTOM", 0, -10);
		else
			self.ScrollFrame.ConfirmationButton:SetPoint("BOTTOM", self.ScrollFrame, "BOTTOM", 0, 20);
		end
	end
end

function GuideFrameMixin:SetStateCannotGuide(errorType)
	local message = NPEV2_CHAT_GUIDE_FRAME_ERROR_GENERIC;
	if errorType == "standing" then
		message = NPEV2_CHAT_GUIDE_FRAME_ERROR_BAD_STANDING;
	elseif errorType == "starter" then
		message = NPEV2_CHAT_GUIDE_FRAME_ERROR_STARTER_ACCOUNTS_CANNOT_GUIDE;
	end

	self:SetStateInternal(message);
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

function GuideFrameMixin:BeginGuideInteraction(state, ...)
	self:SetState(state, ...);
	ShowUIPanel(self);
end

function GuideFrameMixin:ConfirmChoice()
	-- TODO: Do a thing
	print("Confirming guide frame choice for state: " .. self:GetState());
	HideUIPanel(self);
end