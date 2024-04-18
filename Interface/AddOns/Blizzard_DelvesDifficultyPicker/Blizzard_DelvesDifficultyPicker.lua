--! TODO sounds
--! TODO art
--! TODO strings

--[[ LOCALS ]]
-- TODO not sure all these events are needed, they were pulled from the torghast difficulty picker
local DELVES_DIFFICULTY_PICKER_EVENTS = {
	"PARTY_LEADER_CHANGED",
	"GOSSIP_OPTIONS_REFRESHED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_AREA_CHANGED",
	"UNIT_PHASE", 
	"GROUP_FORMED",
};

local DIFFICULTY_PICKER_DROPDOWN_WIDTH = 110;
local MAX_NUM_REWARDS = 4;
local REQUIRED_PLAYER_LEVEL = 70;

--[[ Difficulty Picker ]]
-- ! TODO need continue screen + reset button
DelvesDifficultyPickerFrameMixin = {};

-- Required function, unused.
function DelvesDifficultyPickerFrameMixin:SetStartingPage()
end

function DelvesDifficultyPickerFrameMixin:OnLoad()
	local panelAttributes = {
		area = "center",
        whileDead = 0,
	};
	RegisterUIPanel(self, panelAttributes);

	CustomGossipFrameBaseMixin.OnLoad(self);
end

-- TODO Will want to revisit this when building ready check
function DelvesDifficultyPickerFrameMixin:OnEvent(event, ...)
	if event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_FORMED" then 
		C_GossipInfo.RefreshOptions(); 
		local inParty = UnitInParty("player"); 
		self.isPartyLeader = not inParty or UnitIsGroupLeader("player");
	elseif event == "UNIT_AREA_CHANGED" or event == "UNIT_PHASE" then 
		C_GossipInfo.RefreshOptions(); 
	elseif event == "GOSSIP_OPTIONS_REFRESHED" then 
		self:SetupOptions();
	end 
end 

function DelvesDifficultyPickerFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
end

-- TODO there's going to be other conditions for the enabled state (party member range check, ready check, etc.), and a continue/reset at some point
function DelvesDifficultyPickerFrameMixin:UpdatePortalButtonState()
	self.EnterDelveButton:SetEnabled(self.isPartyLeader and UnitLevel("player") >= REQUIRED_PLAYER_LEVEL);
end

function DelvesDifficultyPickerFrameMixin:GetOptions()
	return self.gossipOptions;
end

function DelvesDifficultyPickerFrameMixin:SetSelectedLevel(level)
	self.selectedLevel = level;
end

function DelvesDifficultyPickerFrameMixin:SetSelectedOption(option)
	self.selectedOption = option;
end

function DelvesDifficultyPickerFrameMixin:SetInitialLevel()
	local highestUnlockedLevel = 0;
	local highestUnlockedLevelOptionID;

	if self.gossipOptions then
		highestUnlockedLevel = self.gossipOptions[1].orderIndex;
		highestUnlockedLevelOptionID = self.gossipOptions[1].gossipOptionID;
		DelvesDifficultyPickerFrame:SetSelectedOption(self.gossipOptions[1]);

		for i, option in pairs(self.gossipOptions) do 
			if option.status == Enum.GossipOptionStatus.Available or option.status == Enum.GossipOptionStatus.AlreadyComplete then
				highestUnlockedLevel = option.orderIndex;
				highestUnlockedLevelOptionID = option.gossipOptionID;
				DelvesDifficultyPickerFrame:SetSelectedOption(option);
			else
				break;
			end
		end
	end

	UIDropDownMenu_SetSelectedValue(DelvesDifficultyPickerLevelDropdown, highestUnlockedLevel);
	DelvesDifficultyPickerFrame:SetSelectedLevel(highestUnlockedLevel);

	if highestUnlockedLevelOptionID then
		DelvesDifficultyPickerFrame:UpdateWidgets(highestUnlockedLevelOptionID);
		DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
	end
end

function DelvesDifficultyPickerFrameMixin:UpdateWidgets(gossipOptionID)
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.DefaultBackground:Show();

	local widgetSetsForOption = C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID(gossipOptionID);

	for _, widgetSetInfo in pairs(widgetSetsForOption) do
		if widgetSetInfo.widgetType == Enum.GossipOptionUIWidgetSetTypes.Modifiers then
			self.DelveModifiersWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
		elseif widgetSetInfo.widgetType == Enum.GossipOptionUIWidgetSetTypes.Background then
			self.DelveBackgroundWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
			self.DefaultBackground:Hide();
		end
	end
end

function DelvesDifficultyPickerFrameMixin:GetSelectedLevel()
	return self.selectedLevel;
end

function DelvesDifficultyPickerFrameMixin:GetSelectedOption()
	return self.selectedOption;
end

function DelvesDifficultyPickerFrameMixin:SetupOptions()
	self:BuildOptionList();
	self:UpdatePortalButtonState();
end 

function DelvesDifficultyPickerFrameMixin:TryShow(textureKit) 
	self.textureKit = textureKit; 
	self.Title:SetText(C_GossipInfo.GetText());
	local inParty = UnitInParty("player"); 
	self.isPartyLeader = not inParty or UnitIsGroupLeader("player");
	self:SetupOptions();
	ShowUIPanel(self); 
end 

function DelvesDifficultyPickerFrameMixin:OnHide()
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.DelveRewardsContainerFrame:Hide();
	FrameUtil.UnregisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
	C_GossipInfo.CloseGossip();
end		

-- [[ Difficulty Dropdown ]]
DelvesDifficultyPickerLevelDropdownMixin = {};

function DelvesDifficultyPickerLevelDropdownMixin:OnShow()
	UIDropDownMenu_SetWidth(self, DIFFICULTY_PICKER_DROPDOWN_WIDTH);
	UIDropDownMenu_JustifyText(self, "LEFT");
	UIDropDownMenu_Initialize(self, self.Init);
	DelvesDifficultyPickerFrame:SetInitialLevel();
end

function DelvesDifficultyPickerLevelDropdownMixin:Init()
	local options = DelvesDifficultyPickerFrame:GetOptions();
	local firstLockedOptionShown = false;
	local buttons = {};

	if options then
		local function SetupButton(option, isLocked)
			local info = UIDropDownMenu_CreateInfo();
			info.text = option.name;
			info.value = option.orderIndex;
			info.func = self.DropdownClickHandler;
			info.minWidth = DIFFICULTY_PICKER_DROPDOWN_WIDTH;
			info.tooltipOnButton = true;
			info.tooltipWhileDisabled = true;
			info.tooltipTitle = "";
			info.checked = DelvesDifficultyPickerFrame:GetSelectedLevel() == option.orderIndex;

			if isLocked then
				info.disabled = true;
				info.tooltipWarning = option.failureDescription;
			else
				local spell = Spell:CreateFromSpellID(option.spellID);
				spell:ContinueWithCancelOnSpellLoad(function()
					info.tooltipText = spell:GetSpellDescription();
				end);
			end

			tinsert(buttons, info);
		end
		
		-- Add buttons (dropdown info) to table
		for i, option in pairs(options) do
			if option.status == Enum.GossipOptionStatus.Available or option.status == Enum.GossipOptionStatus.AlreadyComplete then
				SetupButton(option);
			elseif (option.status == Enum.GossipOptionStatus.Unavailable or option.status == Enum.GossipOptionStatus.Locked) and not firstLockedOptionShown then
				SetupButton(option, true);
				firstLockedOptionShown = true;
				break;
			end
		end

		-- Add buttons in reverse order
		for i = #buttons, 1, -1 do
			UIDropDownMenu_AddButton(buttons[i]);
		end
	end
end

function DelvesDifficultyPickerLevelDropdownMixin:DropdownClickHandler()
	DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:Hide();
	UIDropDownMenu_SetSelectedValue(DelvesDifficultyPickerLevelDropdown, self.value);
	DelvesDifficultyPickerFrame:SetSelectedLevel(self.value);

	-- Get the optionID so we can update widgets
	for _, option in pairs(DelvesDifficultyPickerFrame:GetOptions()) do
		if option.orderIndex == self.value then
			DelvesDifficultyPickerFrame:UpdateWidgets(option.gossipOptionID);
			DelvesDifficultyPickerFrame:SetSelectedOption(option);
			break;
		end
	end

	DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
end

--[[ Enter Button ]]
-- ! TODO Need ready check
DelvesDifficultyPickerEnterDelveButtonMixin = {};

-- ! TODO Need to do range check for party members - put tooltip in if party members out of range
function DelvesDifficultyPickerEnterDelveButtonMixin:OnEnter()
	if not self:GetParent().isPartyLeader then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddNormalLine(GameTooltip, TORGHAST_LEVEL_PICKER_LEADER_ERROR); --! TODO string
		GameTooltip:Show(); 
	elseif UnitLevel("player") < REQUIRED_PLAYER_LEVEL then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddErrorLine(GameTooltip, "You must be at least level 70 to enter a Delve."); --! TODO string
		GameTooltip:Show(); 
	end
end 

function DelvesDifficultyPickerEnterDelveButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

-- ! TODO Need to do range check for party members - don't allow enter unless party members in range
function DelvesDifficultyPickerEnterDelveButtonMixin:OnClick()
	local selectedLevel = DelvesDifficultyPickerFrame:GetSelectedLevel();
	if not selectedLevel then
		return; 
	end
	C_GossipInfo.SelectOptionByIndex(selectedLevel);
end 

--[[ Rewards Container + Buttons ]]
DelveRewardsContainerFrameMixin = {};

function DelveRewardsContainerFrameMixin:OnLoad()
	local function RewardResetter(framePool, frame)
		SetItemButtonTexture(frame, nil);
		SetItemButtonQuality(frame, nil);
		SetItemButtonCount(frame, nil);
		frame.Name:SetText("");
		frame.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		frame:ClearAllPoints();
		frame:Hide();
	end

	self.rewardPool = CreateFramePool("FRAME", self, "DelveRewardItemButtonTemplate", RewardResetter);
end

function DelveRewardsContainerFrameMixin:SetRewards()
	local continuableContainer = ContinuableContainer:Create();
	local optionRewards = DelvesDifficultyPickerFrame:GetSelectedOption().rewards;
	local rewardInfo = {};

	self.rewardPool:ReleaseAll();

	if not optionRewards then
		return;
	end
	
	for _, reward in ipairs(optionRewards) do
		if reward.rewardType == Enum.GossipOptionRewardType.Item then 
			local item = Item:CreateFromItemID(reward.id);
			continuableContainer:AddContinuable(item);
		else
			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(reward.id, reward.quantity); 
			if IsCurrencyContainer then 
				local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, quantity);
				table.insert(rewardInfo, {id = reward.id, texture = texture, quantity = quantity, quality = quality, name = name, isCurrencyContainer = true, sortOrder = 0});
			else 
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
				table.insert(rewardInfo, {id = reward.id, texture = currencyInfo.iconFileID, quantity = reward.quantity, quality = currencyInfo.quality, name = currencyInfo.name, isCurrencyContainer = false, sortOrder = 0});
			end 
		end
	end

	continuableContainer:ContinueOnLoad(function()
		for  _, reward in ipairs(optionRewards) do
			if	reward.rewardType == Enum.GossipOptionRewardType.Item then 
				local name, _, quality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(reward.id);
				table.insert(rewardInfo, {id = reward.id, quality = quality, quantity = reward.quantity, texture = itemIcon, name = name, sortOrder = 1});
			end
		end

		table.sort(rewardInfo, function(a, b)
			if a.sortOrder == b.sortOrder then
				return a.quality > b.quality;
			 end
			 return a.sortOrder < b.sortOrder;
		end);
	
		if #rewardInfo > 0 then
			local buttons = {};
			for i, reward in ipairs(rewardInfo) do
				if i > MAX_NUM_REWARDS then 
					break;
				else
					local button = self.rewardPool:Acquire();
	
					SetItemButtonTexture(button, reward.texture);
					SetItemButtonQuality(button, reward.quality);
					button.Name:SetText(reward.name);
					button.Name:SetTextColor(ITEM_QUALITY_COLORS[reward.quality].color:GetRGB());
	
					if reward.quantity and reward.quantity > 1 then
						SetItemButtonCount(button, reward.quantity);
					end
	
					tinsert(buttons, button);
					button.id = reward.id;
					button:Show();
				end
			end
	
			local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 2, 3, 3);
			local anchor = CreateAnchor("TOP", self.RewardText, "BOTTOM", 20, -5);
			AnchorUtil.GridLayout(buttons, anchor, layout);
	
			self:Show();
		end
	end);
end

DelveRewardsButtonMixin = {};

function DelveRewardsButtonMixin:OnEnter()
	if not self.id then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local item = Item:CreateFromItemID(self.id);
	self.itemCancelFunc = item:ContinueWithCancelOnItemLoad(function()
		if GameTooltip:GetOwner() == self then
			self.itemLink = item:GetItemLink();
			GameTooltip:SetItemByID(self.id);
			GameTooltip:Show();
		end
	end);
end

function DelveRewardsButtonMixin:OnUpdate()
	if TooltipUtil.ShouldDoItemComparison() then
		GameTooltip_ShowCompareItem(GameTooltip);
	else
		GameTooltip_HideShoppingTooltips(GameTooltip);
	end
end

function DelveRewardsButtonMixin:OnMouseDown()
	if not self.itemLink then
		return;
	end

	if IsModifiedClick() then
		HandleModifiedItemClick(self.itemLink);
	end
end

function DelveRewardsButtonMixin:OnLeave()
	if self.itemCancelFunc then
		self.itemCancelFunc();
		self.itemCancelFunc = nil;
	end
	GameTooltip:Hide();
end