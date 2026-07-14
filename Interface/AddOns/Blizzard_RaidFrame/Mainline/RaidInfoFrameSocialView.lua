SocialUIRaidInfoFrameMixin = {};

local RAID_INFO_FRAME_EVENTS =
{
	"PLAYER_ENTERING_WORLD",
	"UPDATE_INSTANCE_INFO",
};

function SocialUIRaidInfoFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("SocialUIRaidInfoContentFrameTemplate", GenerateClosure(self.InitButton, self));

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");

	self.CloseButton:SetScript("OnClick", function()
		self:SocialUIRequestHideSideWindow(SocialUISideWindowType.RaidInfoFrame);
	end);
end

function SocialUIRaidInfoFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		RequestRaidInfo();
	elseif event == "UPDATE_INSTANCE_INFO" then
		self:UpdateScrollAndButtons();
	end
end

function SocialUIRaidInfoFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RAID_INFO_FRAME_EVENTS);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	RequestRaidInfo();
	self:UpdateScrollAndButtons();
end

function SocialUIRaidInfoFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RAID_INFO_FRAME_EVENTS);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function SocialUIRaidInfoFrameMixin:UpdateButtons()
	local function Lock()
		self.ExtendButton:SetTextToFit(EXTEND_RAID_LOCK);
		self.ExtendButton:Disable();
	end
	if self.selectedIndex then
		if self.selectedIsInstance then
			local _, _, _, _, locked, extended, _, _, _, _, _, _, extendDisabled, _ = GetSavedInstanceInfo(self.selectedIndex);
			self.ExtendButton:SetEnabled(not extendDisabled);
			self.ExtendButton.doExtend = not extended;
			if extended then
				self.ExtendButton:SetTextToFit(UNEXTEND_RAID_LOCK);
			else
				self.ExtendButton:SetTextToFit(locked and EXTEND_RAID_LOCK or REACTIVATE_RAID_LOCK);
			end
		else
			Lock();
		end
	else
		Lock();
	end
end

function SocialUIRaidInfoFrameMixin:UpdateScrollAndButtons()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumSavedInstances() do
		dataProvider:Insert({index=index, isInstance=true});
	end

	for index = 1, GetNumSavedWorldBosses() do
		dataProvider:Insert({index=index});
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:UpdateButtons();
end

function SocialUIRaidInfoFrameMixin:InitButton(button, elementData)
	local function Init(extended, locked, reset, name, difficulty)
		if extended or locked then
			button.reset:SetText(SecondsToTime(reset, true, nil, 3));
			button.name:SetText(name);
		else
			button.reset:SetText(DISABLED_FONT_COLOR:WrapTextInColorCode(RAID_INSTANCE_EXPIRES_EXPIRED));
			button.name:SetText(DISABLED_FONT_COLOR:WrapTextInColorCode(name));
		end
		button.difficulty:SetText(difficulty);
		button.extended:SetShown(extended);
		button.parent = self;
	end

	local index = elementData.index;
	if elementData.isInstance then
		local name, instanceID, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);
		Init(extended, locked, reset, name, difficultyName);
		button.instanceID = instanceID;
	else
		local name, _, reset = GetSavedWorldBossInfo(index);
		local locked = true;
		local extended = false;
		Init(extended, locked, reset, name, RAID_INFO_WORLD_BOSS);

		button.instanceID = nil;
	end

	local selected = self.selectedIndex == index and self.selectedIsInstance == elementData.isInstance;
	self:SetButtonSelected(button, selected);
end

function SocialUIRaidInfoFrameMixin:SetButtonSelected(button, selected)
	button:SetHighlightLocked(selected);
end

SocialUIRaidInfoExtendMixin = CreateFromMixins(UIButtonFitToTextBehaviorMixin);

function SocialUIRaidInfoExtendMixin:OnShow()
	self:FitToText();
end

function SocialUIRaidInfoExtendMixin:OnClick()
	local parent = self:GetParent();
	if parent.selectedIndex and parent.selectedIndex <= GetNumSavedInstances() then
		SetSavedInstanceExtend(parent.selectedIndex, self.doExtend);
		RequestRaidInfo();
		parent:UpdateScrollAndButtons();
	end
end

SocialUIRaidInfoContentFrameMixin = {};

function SocialUIRaidInfoContentFrameMixin:OnMouseUp()
	self.name:SetPoint("TOPLEFT", 5, -10);
	self.reset:SetPoint("TOPRIGHT", -5, -10);
end

function SocialUIRaidInfoContentFrameMixin:OnMouseDown()
	self.name:SetPoint("TOPLEFT", 7, -12);
	self.reset:SetPoint("TOPRIGHT", -3, -12);
end

function SocialUIRaidInfoContentFrameMixin:OnClick()
	if self.instanceID and IsModifiedClick("CHATLINK") then
		ChatFrameUtil.InsertLink(GetSavedInstanceChatLink(self:GetElementData().index));
	else
		local oldSelectedIndex = self.parent.selectedIndex;
		local oldSelectedIsInstance = self.parent.selectedIsInstance;
		local elementData = self:GetElementData();
		self.parent.selectedIndex = elementData.index;
		self.parent.selectedIsInstance = elementData.isInstance;

		local function UpdateButtonSelected(index, isInstance, selected)
			if index then
				local button = self.parent.ScrollBox:FindFrameByPredicate(function(button, elementData)
					return elementData.index == index and elementData.isInstance == isInstance;
				end);
				if button then
					self.parent:SetButtonSelected(button, selected);
				end
			end
		end

		UpdateButtonSelected(oldSelectedIndex, oldSelectedIsInstance, false);
		UpdateButtonSelected(self.parent.selectedIndex, self.parent.selectedIsInstance, true);

		self.parent:UpdateButtons();
	end
end

function SocialUIRaidInfoContentFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.instanceID then
		GameTooltip:SetInstanceLockEncountersComplete(self:GetElementData().index);
	else
		local instanceName, _, _ = GetSavedWorldBossInfo(self:GetElementData().index);
		GameTooltip:SetText(instanceName);
	end
	GameTooltip:Show();
end

function SocialUIRaidInfoContentFrameMixin:OnLeave()
	GameTooltip:Hide();
end
