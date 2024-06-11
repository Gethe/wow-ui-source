--! TODO sounds

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
local MAX_NUM_REWARDS = 4;
local BOUNTIFUL_DELVE_WIDGET_TAG = "delveBountiful";

local DelvesKeyState = EnumUtil.MakeEnum(
	"None",
	"Normal",
	"Epic"
);

function GetPlayerKeyState()
	local normalKeyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.DelvesConsts.DELVE_NORMAL_KEY_CURRENCY_ID);
	local epicKeyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.DelvesConsts.DELVE_EPIC_KEY_CURRENCY_ID);

	if epicKeyInfo and epicKeyInfo.quantity > 0 then
		return DelvesKeyState.Epic;
	elseif normalKeyInfo and normalKeyInfo.quantity > 0 then
		return DelvesKeyState.Normal;
	else
		return DelvesKeyState.None;
	end
end

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
		pushable = 0,
		allowOtherPanels = 1,
	};
	RegisterUIPanel(self, panelAttributes);

	self.Dropdown:SetWidth(130);

	CustomGossipFrameBaseMixin.OnLoad(self);
end

-- TODO Will need to revisit this with continue screen
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
	self.Border.Bg:Hide();
	FrameUtil.RegisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);

	DelvesDifficultyPickerFrame:SetInitialLevel();
end

function DelvesDifficultyPickerFrameMixin:SetupDropdown()
	self.Dropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DELVES_DIFFICULTY");

		local options = DelvesDifficultyPickerFrame:GetOptions();
		if not options then
			return;
		end

		local function IsSelected(option)
			return DelvesDifficultyPickerFrame:GetSelectedLevel() == option.orderIndex;
		end

		local function SetSelected(option)
			DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:Hide();
			DelvesDifficultyPickerFrame:SetSelectedLevel(option.orderIndex);
			DelvesDifficultyPickerFrame:UpdateWidgets(option.gossipOptionID);
			DelvesDifficultyPickerFrame:SetSelectedOption(option);
			DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
			DelvesDifficultyPickerFrame:UpdatePortalButtonState();
		end

		local function SetupButton(option, isLocked)
			local radio = rootDescription:CreateRadio(option.name, IsSelected, SetSelected, option);

			if isLocked then
				radio:SetEnabled(false);
			end

			local spell = Spell:CreateFromSpellID(option.spellID);
			spell:ContinueWithCancelOnSpellLoad(function()
				radio:SetTooltip(function(tooltip, elementDescription)
					GameTooltip_AddNormalLine(tooltip, spell:GetSpellDescription());
				end);
			end);
		end
		
		for i, option in ipairs(options) do
			if option.status == Enum.GossipOptionStatus.Available or option.status == Enum.GossipOptionStatus.AlreadyComplete then
				SetupButton(option);
			elseif (option.status == Enum.GossipOptionStatus.Unavailable or option.status == Enum.GossipOptionStatus.Locked) then
				SetupButton(option, true);
			end
		end
	end);
end

-- TODO there may be other conditions for this in the future. We're no longer doing a ready check, but the continue screen might affect this
function DelvesDifficultyPickerFrameMixin:UpdatePortalButtonState()
	local optionSelected =  DelvesDifficultyPickerFrame:GetSelectedOption() ~= nil;
	local playerAtOrAboveMinLevel =  UnitLevel("player") >= Constants.DelvesConsts.MIN_PLAYER_LEVEL;

	self.EnterDelveButton:SetEnabled(self.isPartyLeader and playerAtOrAboveMinLevel and optionSelected);
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
	DelvesDifficultyPickerFrame:SetSelectedLevel(nil);
	DelvesDifficultyPickerFrame:SetSelectedOption(nil);
	local highestUnlockedLevel = nil;
	local highestUnlockedLevelOptionID = nil;

	if self.gossipOptions then
		highestUnlockedLevel = self.gossipOptions[1].orderIndex;
		highestUnlockedLevelOptionID = self.gossipOptions[1].gossipOptionID;

		for i, option in pairs(self.gossipOptions) do 
			if option.status == Enum.GossipOptionStatus.Available or option.status == Enum.GossipOptionStatus.AlreadyComplete then
				highestUnlockedLevel = option.orderIndex;
				highestUnlockedLevelOptionID = option.gossipOptionID;
				DelvesDifficultyPickerFrame:SetSelectedLevel(highestUnlockedLevel);
				DelvesDifficultyPickerFrame:SetSelectedOption(option);
			else
				break;
			end
		end
	end

	self:SetupDropdown();

	if highestUnlockedLevelOptionID then
		DelvesDifficultyPickerFrame:UpdateWidgets(highestUnlockedLevelOptionID);
		DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
		DelvesDifficultyPickerFrame:UpdatePortalButtonState();
	end
end

function DelvesDifficultyPickerFrameMixin:UpdateWidgets(gossipOptionID)
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.Bg:Show();

	local widgetSetsForOption = C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID(gossipOptionID);

	for _, widgetSetInfo in pairs(widgetSetsForOption) do
		if widgetSetInfo.widgetType == Enum.GossipOptionUIWidgetSetTypes.Modifiers then
			-- If no level selected, or player ineligible, break out of showing modifers (but continue to show background and story text)
			if not DelvesDifficultyPickerFrame:GetSelectedLevel() then
				break;
			end

			self.DelveModifiersWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
		elseif widgetSetInfo.widgetType == Enum.GossipOptionUIWidgetSetTypes.Background then
			self.DelveBackgroundWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
			self.Bg:Hide();
		end
	end

	self:UpdateBountifulWidgetVisualization();
end

function DelvesDifficultyPickerFrameMixin:UpdateBountifulWidgetVisualization()
	for _, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag(BOUNTIFUL_DELVE_WIDGET_TAG) do
		local playerKeyState = GetPlayerKeyState();
		
		-- Cancel the model scene effect if player does not own any epic keys
		if playerKeyState ~= DelvesKeyState.Epic and widgetFrame.effectController then
			widgetFrame.effectController:CancelEffect();
			widgetFrame.effectController = nil;
		end

		-- Add glow animation if player owns any key
		if playerKeyState >= DelvesKeyState.Normal and not self.bountifulAnimFrame then
			self.bountifulAnimFrame = CreateFrame("FRAME", "BountifulWidgetAnimationFrame", widgetFrame, "BountifulWidgetAnimationTemplate");
			self.bountifulAnimFrame.FadeIn:Play();
			self.bountifulAnimFrame.RaysTranslation:Play();
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
	self.Description:SetText(C_GossipInfo.GetCustomGossipDescriptionString());
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
	if self.bountifulAnimFrame then
		self.bountifulAnimFrame:Hide();
		self.bountifulAnimFrame = nil;
	end
end		

--[[ Enter Button ]]
DelvesDifficultyPickerEnterDelveButtonMixin = {};

-- ! TODO Need to do range check for party members - put tooltip in if party members out of range
function DelvesDifficultyPickerEnterDelveButtonMixin:OnEnter()
	if not self:GetParent().isPartyLeader then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddNormalLine(GameTooltip, DELVES_LEVEL_PICKER_LEADER_ERROR);
		GameTooltip:Show(); 
	elseif UnitLevel("player") < Constants.DelvesConsts.MIN_PLAYER_LEVEL then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ENTRANCE_LEVEL_REQUIREMENT_ERROR:format(Constants.DelvesConsts.MIN_PLAYER_LEVEL));
		GameTooltip:Show();
	elseif not DelvesDifficultyPickerFrame:GetSelectedOption() then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 175);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ERR_SELECT_TIER);
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
	if not DelvesDifficultyPickerFrame:GetSelectedOption() then
		return;
	end

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
				table.insert(rewardInfo, {id = reward.id, texture = texture, quantity = quantity, quality = quality, name = name, isCurrencyContainer = true});
			else 
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
				table.insert(rewardInfo, {id = reward.id, texture = currencyInfo.iconFileID, quantity = reward.quantity, quality = currencyInfo.quality, name = currencyInfo.name, isCurrencyContainer = false});
			end 
		end
	end

	continuableContainer:ContinueOnLoad(function()
		for  _, reward in ipairs(optionRewards) do
			if	reward.rewardType == Enum.GossipOptionRewardType.Item then 
				local name, _, quality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(reward.id);
				table.insert(rewardInfo, {id = reward.id, quality = quality, quantity = reward.quantity, texture = itemIcon, name = name});
			end
		end

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
	
			local vertPadding = 5;
			local buttonHeight = C_XMLUtil.GetTemplateInfo("DelveRewardItemButtonTemplate").height;
			self:SetHeight(self.RewardText:GetHeight() + ((buttonHeight + vertPadding) * #rewardInfo));
	
			local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, vertPadding);
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