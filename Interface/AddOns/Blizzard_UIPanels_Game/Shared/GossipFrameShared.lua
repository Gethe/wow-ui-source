GOSSIP_BUTTON_TYPE_TITLE = 1;
GOSSIP_BUTTON_TYPE_DIVIDER = 2;
GOSSIP_BUTTON_TYPE_OPTION = 3;
GOSSIP_BUTTON_TYPE_ACTIVE_QUEST = 4;
GOSSIP_BUTTON_TYPE_AVAILABLE_QUEST = 5;

GossipSharedTitleButtonMixin = {};

function GossipSharedTitleButtonMixin:Resize()
	self:SetHeight(math.max(self:GetTextHeight() + 2, self.Icon:GetHeight()));
end

function GossipSharedTitleButtonMixin:SetTextAndResize(text)
	self:SetText(text);
	self:Resize();
end

function GossipSharedTitleButtonMixin:OnEnter()

end

function GossipSharedTitleButtonMixin:OnLeave()

end

GossipSharedQuestButtonMixin = CreateFromMixins(GossipSharedTitleButtonMixin);
function GossipSharedQuestButtonMixin:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial)

	if ( isIgnored ) then
		self:SetFormattedText(IGNORED_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(0.5,0.5,0.5);
	elseif ( isTrivial ) then
		self:SetFormattedText(TRIVIAL_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(0.5,0.5,0.5);
	else
		self:SetFormattedText(NORMAL_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(1,1,1);
	end

	self:Resize();

end

GossipSharedAvailableQuestButtonMixin = CreateFromMixins(GossipSharedQuestButtonMixin);

function GossipSharedAvailableQuestButtonMixin:Setup(questInfo)
	self:SetID(questInfo.questID);
	self:UpdateTitleForQuest(questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial);
	self:Show();
end
function GossipSharedAvailableQuestButtonMixin:OnClick(button)
	C_GossipInfo.SelectAvailableQuest(self:GetID());
end

GossipSharedActiveQuestButtonMixin = CreateFromMixins(GossipSharedQuestButtonMixin);
function GossipSharedActiveQuestButtonMixin:Setup(questInfo)
	self:SetID(questInfo.questID);
	self:UpdateTitleForQuest(questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial);
	self:Show();
end

function GossipSharedActiveQuestButtonMixin:OnClick(button)
	C_GossipInfo.SelectActiveQuest(self:GetID());
end

GossipOptionButtonMixin = { };

function GossipOptionButtonMixin:Setup(optionInfo)
	self:SetID(optionInfo.orderIndex or 0);
	self.spellID = optionInfo.spellID;

	if (FlagsUtil.IsAnySet(optionInfo.flags, bit.bor(Enum.GossipOptionRecFlags.QuestLabelPrepend, Enum.GossipOptionRecFlags.PlayMovieLabelPrepend))) then
		local prepends = {};
		if FlagsUtil.IsSet(optionInfo.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend) then
			table.insert(prepends, QUEST_PREPEND);
		end

		if FlagsUtil.IsSet(optionInfo.flags, Enum.GossipOptionRecFlags.PlayMovieLabelPrepend) then
			table.insert(prepends, PLAY_MOVIE_PREPEND);
		end

		local prependString = table.concat(prepends, ' ');
		self:SetText(GOSSIP_OPTION_PREPEND:format(prependString, optionInfo.name));
	else
		self:SetText(optionInfo.name);
	end

	if(optionInfo.overrideIconID) then
		self.Icon:SetTexture(optionInfo.overrideIconID);
	else
		self.Icon:SetTexture(optionInfo.icon);
	end
	self.Icon:SetVertexColor(1, 1, 1, 1);

	self:Resize();
	self:Show();
end

function GossipOptionButtonMixin:OnClick(button)
	C_GossipInfo.SelectOptionByIndex(self:GetID());
end

GossipGreetingTextMixin = { }
function GossipGreetingTextMixin:Setup(text)
	self.GreetingText:SetText(text);
	self:Show();
	self:SetSize(270, self.GreetingText:GetHeight());
end

GossipFrameSharedMixin = {};

function GossipFrameSharedMixin:AvailableQuestButtonInit(button, elementData)
	button:Setup(elementData.info);
	if(self.tutorialMode) then
		table.insert(self.tutorialButtons, button);
	end
end

function GossipFrameSharedMixin:UpdateScrollBox()
	self.tutorialButtons = { };
	self.tutorialMode = nil;
	local view = CreateScrollBoxListLinearView();

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if (elementData.greetingTextFrame) then
			elementData.greetingTextFrame.GreetingText:SetText(elementData.text);
			return elementData.greetingTextFrame.GreetingText:GetHeight();
		elseif(elementData.titleOptionButton) then
			elementData.titleOptionButton:Setup(elementData.info);
			return elementData.titleOptionButton:GetHeight();
		elseif(elementData.availableQuestButton) then
			elementData.availableQuestButton:Setup(elementData.info);
			return elementData.availableQuestButton:GetHeight();
		elseif(elementData.activeQuestButton) then
			elementData.activeQuestButton:Setup(elementData.info);
			return elementData.activeQuestButton:GetHeight();
		else
			return 16;
		end
	end);

	local GreetingTextInitializer = function(greetingTextFrame, elementData)
		self:RegisterFontString(greetingTextFrame.GreetingText);
		greetingTextFrame:Setup(elementData.text);
	end
	
	local ButtonInitializer = function(button, elementData)
		self:RegisterFontString(button:GetFontString());
		button:Setup(elementData.info);
	end

	local elementTypes = 
	{
		[GOSSIP_BUTTON_TYPE_TITLE] = { template = "GossipGreetingTextTemplate", initializer = GreetingTextInitializer, },
		[GOSSIP_BUTTON_TYPE_DIVIDER] = { template = "GossipSpacerFrameTemplate", },
		[GOSSIP_BUTTON_TYPE_OPTION] = { template = "GossipTitleOptionButtonTemplate", initializer = ButtonInitializer, },
		[GOSSIP_BUTTON_TYPE_ACTIVE_QUEST] = { template = "GossipTitleActiveQuestButtonTemplate", initializer = ButtonInitializer, },
		[GOSSIP_BUTTON_TYPE_AVAILABLE_QUEST] = { template = "GossipTitleAvailableQuestButtonTemplate", initializer = ButtonInitializer, },
	};

	view:SetElementFactory(function(factory, elementData)
		local elementTypeData = elementTypes[elementData.buttonType];
		if elementTypeData then
			factory(elementTypeData.template, elementTypeData.initializer);
		end
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.GreetingPanel.ScrollBox, self.GreetingPanel.ScrollBar, view);
end

function GossipFrameSharedMixin:OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	if ( StaticPopup_Visible("XP_LOSS") ) then
		StaticPopup_Hide("XP_LOSS");
	end
end

function GossipFrameSharedMixin:OnHide()
	self.gossipOptions = {};

	if self.interactionIsContinuing then
		self.interactionIsContinuing = nil;
	else
		PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
		C_GossipInfo.CloseGossip();
	end
end

function GossipOptionSort(leftInfo, rightInfo)
	return GossipFrameMixin:SortOrder(leftInfo, rightInfo)
end

function GossipFrameSharedMixin:HandleShow(_textureKit)
-- if there is only a non-gossip option, then go to it directly
	self.gossipOptions = C_GossipInfo.GetOptions();
	table.sort(self.gossipOptions, GossipOptionSort);
	if ( (C_GossipInfo.GetNumAvailableQuests() == 0) and (C_GossipInfo.GetNumActiveQuests()  == 0) and (#self.gossipOptions == 1) and not C_GossipInfo.ForceGossip() ) then
		if (self.gossipOptions and self.gossipOptions[1].selectOptionWhenOnlyOption) then
			C_GossipInfo.SelectOptionByIndex(self.gossipOptions[1].orderIndex);
			return;
		end
	end

	if ( not self:IsShown() ) then
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			C_GossipInfo.CloseGossip();
			return;
		end
	end
end

function GossipFrameSharedMixin:HandleHide(interactionIsContinuing)
	if interactionIsContinuing and self:IsShown() then
		self:SetInteractionIsContinuing(interactionIsContinuing);
	end
	HideUIPanel(self);
end

function GossipFrameSharedMixin:SetInteractionIsContinuing(interactionIsContinuing)
	self.interactionIsContinuing = true;
end

--This is an API for players and addon authors to continue to be able to select by index rather than ID
function GossipFrameSharedMixin:SelectGossipOption(index)
	if(not self.gossipOptions) then 
		return;
	end 

	if(not self.gossipOptions[index]) then 
		return; 
	end

	C_GossipInfo.SelectOptionByIndex(self.gossipOptions[index].orderIndex);
end	

local greetingTextFrame;
local titleOptionButton;
local activeQuestButton;
local availableQuestButton;

function GossipFrameSharedMixin:Update()
	self.buttons = {};

	if not greetingTextFrame then
		greetingTextFrame = CreateFrame("FRAME", nil, self, "GossipGreetingTextTemplate");
		titleOptionButton = CreateFrame("Button", nil, self,"GossipTitleOptionButtonTemplate");
		activeQuestButton = CreateFrame("Button", nil, self, "GossipTitleActiveQuestButtonTemplate");
		availableQuestButton = CreateFrame("Button", nil, self, "GossipTitleAvailableQuestButtonTemplate");
	end

	local dataProvider = CreateDataProvider();
	dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_TITLE, text=C_GossipInfo.GetText() or "", greetingTextFrame = greetingTextFrame});
	dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_DIVIDER});
	dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_DIVIDER});

	local availableQuests = C_GossipInfo.GetAvailableQuests();
	local hasAvailableQuests = availableQuests and #availableQuests > 0;

	local index = 1;
	for _, questInfo in ipairs(availableQuests) do
		dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_AVAILABLE_QUEST, info=questInfo, availableQuestButton = availableQuestButton, index = index});
		index = index + 1;
	end

	if(hasAvailableQuests) then
		dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_DIVIDER});
	end

	local activeQuests = C_GossipInfo.GetActiveQuests();
	self.hasActiveQuests = (#activeQuests > 0);
	for _, questInfo in ipairs(activeQuests) do
		dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_ACTIVE_QUEST, info=questInfo, activeQuestButton = activeQuestButton, index = index});
		index = index + 1;
	end

	if(self.hasActiveQuests) then
		dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_DIVIDER});
	end

	for _, optionInfo in ipairs(self.gossipOptions) do
		dataProvider:Insert({buttonType= GOSSIP_BUTTON_TYPE_OPTION, info=optionInfo, titleOptionButton = titleOptionButton, index = index});
		index = index + 1;
	end

	self.GreetingPanel.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	self:SetGossipTitle(UnitName("npc"));
	if ( UnitExists("npc") ) then
		self:SetPortraitToUnit("npc");
	else
		self:SetPortraitToAsset("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	end

	self:UpdateTheme();
end

function GossipFrameSharedMixin:SetGossipTitle(title)
	self:SetTitle(title);
end

--This is an API for players and addon authors to continue to be able to select by index rather than ID
function SelectGossipOption(index)
	if (GossipFrame and GossipFrame:IsShown()) then
		GossipFrame:SelectGossipOption(index);
	end 
end