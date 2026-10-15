GossipTitleButtonMixin = CreateFromMixins(GossipSharedTitleButtonMixin)
function GossipTitleButtonMixin:OnEnter()
	if (self.spellID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show();
	end
end

function GossipTitleButtonMixin:OnLeave()
	GameTooltip:Hide();
end

GossipQuestButtonMixin = CreateFromMixins(GossipSharedQuestButtonMixin);
function GossipQuestButtonMixin:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial)
	GossipSharedQuestButtonMixin.UpdateTitleForQuest(self, questID, titleText, isIgnored, isTrivial);
	self:AddCallbackForQuest(questID, UpdateTitle);
end
function GossipQuestButtonMixin:OnHide()
	self:CancelCallback();
end

function GossipQuestButtonMixin:CancelCallback()
	if self.cancelCallback then
		self.cancelCallback();
		self.cancelCallback = nil;
	end
end

function GossipQuestButtonMixin:AddCallbackForQuest(questID, cb)
	self:CancelCallback();
	self.cancelCallback = QuestEventListener:AddCancelableCallback(questID, cb);
end

GossipAvailableQuestButtonMixin = CreateFromMixins(GossipSharedAvailableQuestButtonMixin);

function GossipAvailableQuestButtonMixin:Setup(questInfo)
	QuestUtil.ApplyQuestIconOfferToTextureForQuestID(self.Icon, questInfo.questID, questInfo.isLegendary, questInfo.frequency, questInfo.isRepeatable, questInfo.isImportant, questInfo.isMeta, questInfo.questInfoID);
	GossipSharedAvailableQuestButtonMixin.Setup(self, questInfo);
end

GossipActiveQuestButtonMixin = CreateFromMixins(GossipSharedActiveQuestButtonMixin);
function GossipActiveQuestButtonMixin:Setup(questInfo)
	QuestUtil.ApplyQuestIconActiveToTextureForQuestID(self.Icon, questInfo.questID, questInfo.isComplete, questInfo.isLegendary, questInfo.frequency, questInfo.isRepeatable, questInfo.isImportant, questInfo.isMeta, questInfo.questInfoID);
	GossipSharedActiveQuestButtonMixin.Setup(self, questInfo);
end

GossipFrameMixin = CreateFromMixins(GossipFrameSharedMixin);

function GossipFrameMixin:OnLoad()
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:UpdateScrollBox();

	local function OnQuestTextContrastSettingChanged()
		self:UpdateScrollBox();
	end
	Settings.SetOnValueChangedCallback("PROXY_QUEST_TEXT_CONTRAST", OnQuestTextContrastSettingChanged);
	self:RegisterForTransitions();
end

function GossipFrameMixin:HandleShow(textureKit)
	GossipFrameSharedMixin.HandleShow(self, textureKit);
	self:RegisterBackgroundTexture(self.Background, textureKit);
	self.FriendshipStatusBar:Update();
	self:Update();
end

function GossipFrameMixin:OnEvent(event, ...)
	if ( event == "QUEST_LOG_UPDATE" and GossipFrame.hasActiveQuests ) then
		self:Update();
	end
end

function GossipFrameMixin:Update()
	GossipFrameSharedMixin.Update(self);

	if InputUtil.IsGamepadUIEnabled() then
		local gossipFrames = self.GreetingPanel.ScrollBox:GetFrames();
		local firstButton = nil;

		if gossipFrames and #gossipFrames > 0 then
			for _, frame in ipairs(gossipFrames) do
				if (frame:IsObjectType("Button") and frame:IsShown()) then
					firstButton = frame;
					break;
				end
			end

			if firstButton then
				SmartNavigation:SelectButton(firstButton);
				SmartNavigation:ShowCursor();
			end
		end

		if not firstButton then
			SmartNavigation:SelectFirstButton();
		end
	end
end

function GossipFrameMixin:SetGossipTutorialMode(tutorialMode)
	self.tutorialMode = tutorialMode;
	self.tutorialButtons = { };
	self.GreetingPanel.GoodbyeButton:SetShown(not tutorialMode);
end

function GossipFrameMixin:GetTutorialButtons()
	return self.tutorialButtons;
end

function GossipFrameMixin:SortOrder(leftInfo, rightInfo)
	return leftInfo.orderIndex < rightInfo.orderIndex;
end

function GossipFrameMixin:SetUpGamepad()
	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "GossipFrameFooter");
	self.gamepadFooter:AddStandardSelectPrompt();
	self.gamepadFooter:AddStandardBackPrompt();
	self.gamepadFooter:Finalize();

	function GossipFrame.UnfocusGamepad()
		self.gamepadFooter:HideAndDeactivateBindings();
	end

	function GossipFrame.FocusGamepad()
		self.gamepadFooter:ShowAndActivateBindings();
		SmartNavigation:SetScrollFrameForFrame(self, self.GreetingPanel.ScrollBox);
		GamepadScrollBarHint:SetOwner(self.GreetingPanel.ScrollBar.Track.Thumb, "CENTER");
		GamepadScrollBarHint:Show();

	end
end

function GossipFrameMixin:InitializeGamepad()
	self.GreetingPanel.GoodbyeButton:Hide();
	GossipFrameCloseButton:Hide();
end

function GossipFrameMixin:UninitializeGamepad()
	self.GreetingPanel.GoodbyeButton:Show();
	GossipFrameCloseButton:Show();
end

function GossipFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetUpGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end
