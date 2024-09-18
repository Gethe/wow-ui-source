--[[ LOCALS ]]
local DELVES_DIFFICULTY_PICKER_EVENTS = {
	"PARTY_LEADER_CHANGED",
	"GOSSIP_OPTIONS_REFRESHED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_AREA_CHANGED",
	"UNIT_PHASE", 
	"GROUP_FORMED",
	"WALK_IN_DATA_UPDATE",
	"ACTIVE_DELVE_DATA_UPDATE",
	"PARTY_ELIGIBILITY_FOR_DELVE_TIERS_CHANGED",
};

-- Max number of rewards shown on the right side of the UI
local MAX_NUM_REWARDS = 4;

-- Used to select the bountiful widget, in order to show VFX based on the tier of key owned.
-- See DelvesKeyState enum and its usages
local BOUNTIFUL_DELVE_WIDGET_TAG = "delveBountiful";

-- Stores the last selected tier. If one hasn't been selected (value: 0), we'll force the player to select one.
-- If the last selected isn't available, we'll default to the highest unlocked tier.
local LAST_TIER_SELECTED_CVAR = "lastSelectedDelvesTier";

local TIER_SELECT_DROPDOWN_MENU_MIN_WIDTH = 110;
local TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH = 130;

local DelvesKeyState = EnumUtil.MakeEnum(
	"None",
	"Normal"
);

function GetPlayerKeyState()
	local normalKeyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.DelvesConsts.DELVES_NORMAL_KEY_CURRENCY_ID);

	if normalKeyInfo and normalKeyInfo.quantity > 0 then
		return DelvesKeyState.Normal;
	else
		return DelvesKeyState.None;
	end
end

--[[ Difficulty Picker ]]
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
	self.Dropdown:SetWidth(TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH);
end

function DelvesDifficultyPickerFrameMixin:OnEvent(event, ...)
	if event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_FORMED" then 
		C_GossipInfo.RefreshOptions();
	elseif event == "UNIT_AREA_CHANGED" or event == "UNIT_PHASE" then 
		C_GossipInfo.RefreshOptions(); 
	elseif event == "GOSSIP_OPTIONS_REFRESHED" then 
		self:SetupOptions();
	elseif event == "ACTIVE_DELVE_DATA_UPDATE" or event == "WALK_IN_DATA_UPDATE" then
		self:CheckForActiveDelveAndUpdate();
	elseif event == "PARTY_ELIGIBILITY_FOR_DELVE_TIERS_CHANGED" then
		local playerName, maxEligibleLevel = ...;
		self:OnPartyEligibilityChanged(playerName, maxEligibleLevel);
	end 
end 

function DelvesDifficultyPickerFrameMixin:OnShow()
	self.Border.Bg:Hide();
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 110);
	FrameUtil.RegisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuClose, self.TryShowHelpTip, self);
	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuOpen, self.HideHelpTip, self);
	
	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuOpen, function(dropdown)
		local selectedOption = self:GetSelectedOption();
		local index = selectedOption and selectedOption.orderIndex or 1;

		if dropdown.menu.ScrollBox:HasScrollableExtent() then
			dropdown.menu.ScrollBox:ScrollToElementDataIndex(index, ScrollBoxConstants.AlignBegin);
		end
	end, self.Dropdown);
	
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self:SetInitialLevel();
	self:CheckForActiveDelveAndUpdate();
	self:TryShowHelpTip();
	self.partyTierEligibility = {};
	if self.gossipOptions then
		C_DelvesUI.RequestPartyEligibilityForDelveTiers(self.gossipOptions[1].gossipOptionID);
	end
end

function DelvesDifficultyPickerFrameMixin:TryShowHelpTip()
	local selectedOption = self:GetSelectedOption();
	local lastSelectedTier = GetCVarNumberOrDefault(LAST_TIER_SELECTED_CVAR);

	-- If there's no option selected and last selected tier is 0, we're seeing the FTUE and should show the helptip
	if not selectedOption and lastSelectedTier == 0 then
		local helpTipInfo = {
			text = DELVES_TIER_SELECT_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			offsetX = -3,
		};
		HelpTip:Show(self.Dropdown, helpTipInfo);
	else
		self:HideHelpTip();
	end
end

function DelvesDifficultyPickerFrameMixin:HideHelpTip()
	HelpTip:HideAll(self.Dropdown);
end

function DelvesDifficultyPickerFrameMixin:CheckForActiveDelveAndUpdate()
	if C_DelvesUI.HasActiveDelve() then
		local activeDelveGossip = C_GossipInfo.GetActiveDelveGossip();

		-- Prefer active delve gossip (from walk in party)
		if activeDelveGossip and activeDelveGossip.orderIndex and activeDelveGossip.gossipOptionID then
			self:SetSelectedLevel(activeDelveGossip.orderIndex);
			self:SetSelectedOption(activeDelveGossip);
			self:UpdateWidgets(activeDelveGossip.gossipOptionID);
		elseif self.selectedOption and self.selectedOption.orderIndex and self.selectedOption.gossipOptionID then
			-- If active delve gossip is empty, player probably entered and then left. Fall back on the last selected tier/gossip,
			-- which should match the active delve gossip
			self:SetSelectedLevel(self.selectedOption.orderIndex);
			self:SetSelectedOption(self.selectedOption);
			self:UpdateWidgets(self.selectedOption.gossipOptionID);
		end
		self.DelveRewardsContainerFrame:SetRewards();
		self.Dropdown:Update();
		self.Dropdown:SetEnabled(false);
		self:UpdatePortalButtonState();
	else
		self.Dropdown:SetEnabled(true);
	end
end

function DelvesDifficultyPickerFrameMixin:SetupDropdown()
	self.Dropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DELVES_DIFFICULTY");

		local buttonSize = 20;
		local maxButtons = 7;
		rootDescription:SetScrollMode(buttonSize * maxButtons);
		rootDescription:SetMinimumWidth(TIER_SELECT_DROPDOWN_MENU_MIN_WIDTH);
		
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
			SetCVar(LAST_TIER_SELECTED_CVAR, option.orderIndex + 1); -- order index starts at 0, so we need to offset it.
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
					local partyTierEligibility = DelvesDifficultyPickerFrame:GetPartyTierEligibility();
					if not isLocked and partyTierEligibility ~= nil then
						for playerName,maxEligibleLevel in pairs(partyTierEligibility) do
							if maxEligibleLevel < option.orderIndex then
								GameTooltip_AddErrorLine(tooltip, DELVES_PARTY_MEMBER_INELIGIBLE_FOR_TIER_TOOLTIP:format(playerName), false);
							end
						end
					end
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

function DelvesDifficultyPickerFrameMixin:UpdatePortalButtonState()
	local optionSelected =  self:GetSelectedOption();
	local minLevel = C_DelvesUI.GetDelvesMinRequiredLevel();

	local playerAtOrAboveMinLevel = minLevel and UnitLevel("player") >= minLevel;
	local selectedOptionValid = optionSelected ~= nil and (optionSelected.status == Enum.GossipOptionStatus.Available or optionSelected.status == Enum.GossipOptionStatus.AlreadyComplete);
	
	self.EnterDelveButton:SetEnabled(playerAtOrAboveMinLevel and selectedOptionValid);
end

-- gossipOptions are the individual gossip options returned from the gossip record.
-- In the context of Delves, they represent the tiers, starting from the lowest to the highest.
-- The order should mirror exactly how it is ordered in data.
-- This data comes from CustomGossipFrameBase
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
	local lastSelectedTier = GetCVarNumberOrDefault(LAST_TIER_SELECTED_CVAR);

	if self.gossipOptions then
		highestUnlockedLevel = self.gossipOptions[1].orderIndex;
		highestUnlockedLevelOptionID = self.gossipOptions[1].gossipOptionID;

		-- If last selected tier is 0, then the player is opening Delves for the first time. We'll force them to pick a tier.
		-- Otherwise, try to use their last selected tier. Failing that, use the highest unlocked tier
		if lastSelectedTier > 0 then
			local lastSelectedTierOption = self.gossipOptions[lastSelectedTier];
			local lastSelectedTierValid = lastSelectedTierOption and (lastSelectedTierOption.status == Enum.GossipOptionStatus.Available or lastSelectedTierOption.status == Enum.GossipOptionStatus.AlreadyComplete);

			if lastSelectedTierValid then
				highestUnlockedLevel = lastSelectedTierOption.orderIndex;
				highestUnlockedLevelOptionID = lastSelectedTierOption.gossipOptionID;
				DelvesDifficultyPickerFrame:SetSelectedLevel(highestUnlockedLevel);
				DelvesDifficultyPickerFrame:SetSelectedOption(lastSelectedTierOption);
			else
				-- See DelvesDifficultyPickerFrameMixin:GetOptions 
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
			-- If level selected or player eligible for tier, show modifiers
			if DelvesDifficultyPickerFrame:GetSelectedLevel() then
				self.DelveModifiersWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
			end
		end

		if widgetSetInfo.widgetType == Enum.GossipOptionUIWidgetSetTypes.Background then
			self.DelveBackgroundWidgetContainer:RegisterForWidgetSet(widgetSetInfo.uiWidgetSetID);
			self.Bg:Hide();
		end
	end

	self:UpdateBountifulWidgetVisualization();
end

function DelvesDifficultyPickerFrameMixin:UpdateBountifulWidgetVisualization()
	for _, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag(BOUNTIFUL_DELVE_WIDGET_TAG) do
		local playerKeyState = GetPlayerKeyState();
		
		-- Cancel the model scene effect if player does not own any keys
		if playerKeyState ~= DelvesKeyState.Normal and widgetFrame.effectController then
			widgetFrame.effectController:CancelEffect();
			widgetFrame.effectController = nil;
		end

		-- Add glow animation if player owns at least one key
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
	self:SetupOptions();
	ShowUIPanel(self);
end 

function DelvesDifficultyPickerFrameMixin:OnHide()
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.DelveRewardsContainerFrame:Hide();
	FrameUtil.UnregisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
	self.Dropdown:UnregisterCallback(DropdownButtonMixin.Event.OnMenuClose, self);
	self.Dropdown:UnregisterCallback(DropdownButtonMixin.Event.OnMenuOpen, self);
	C_GossipInfo.CloseGossip();
	if self.bountifulAnimFrame then
		self.bountifulAnimFrame:Hide();
		self.bountifulAnimFrame = nil;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end		

--[[ Enter Button ]]
DelvesDifficultyPickerEnterDelveButtonMixin = {};

function DelvesDifficultyPickerEnterDelveButtonMixin:OnEnter()
	local selectedOption = self:GetParent():GetSelectedOption();
	local minLevel = C_DelvesUI.GetDelvesMinRequiredLevel();

	if minLevel and UnitLevel("player") < minLevel then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ENTRANCE_LEVEL_REQUIREMENT_ERROR:format(minLevel));
		GameTooltip:Show();
	elseif not selectedOption then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 175);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ERR_SELECT_TIER);
		GameTooltip:Show();
	elseif selectedOption.status == Enum.GossipOptionStatus.Locked or selectedOption.status == Enum.GossipOptionStatus.Unavailable then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 175);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ERR_TIER_INELIGIBLE);
		GameTooltip:Show();
	else
		local partyTierEligibility = self:GetParent():GetPartyTierEligibility();
		if partyTierEligibility ~= nil then
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 50);
			local ineligibleParty = false;
			for playerName,maxEligibleLevel in pairs(partyTierEligibility) do
				if maxEligibleLevel < selectedOption.orderIndex then
					GameTooltip_AddErrorLine(GameTooltip, DELVES_PARTY_MEMBER_INELIGIBLE_FOR_TIER_TOOLTIP:format(playerName), false);
					ineligibleParty = true;
				end
			end

			if ineligibleParty then
				GameTooltip:Show();
			end
		end
	end
end 

function DelvesDifficultyPickerEnterDelveButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function DelvesDifficultyPickerEnterDelveButtonMixin:OnClick()
	local selectedLevel = DelvesDifficultyPickerFrame:GetSelectedLevel();
	if not selectedLevel then
		return; 
	end
	PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
	C_GossipInfo.SelectOptionByIndex(selectedLevel);
end 

function DelvesDifficultyPickerFrameMixin:OnPartyEligibilityChanged(playerName, maxEligibleLevel)
	self.partyTierEligibility[playerName] = maxEligibleLevel;
end

function DelvesDifficultyPickerFrameMixin:GetPartyTierEligibility()
	return self.partyTierEligibility;
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
				table.insert(rewardInfo, {id = reward.id, quality = quality, quantity = reward.quantity, texture = itemIcon, name = name, context = reward.context});
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
					button.context = reward.context;
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
			if self.context then
				self.itemLink = C_Item.GetDelvePreviewItemLink(self.id, self.context);
			else
				self.itemLink = item:GetItemLink();
			end
			GameTooltip:SetHyperlink(self.itemLink);
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

--[[ Difficulty Dropdown ]]
DelvesDifficultyPickerDropdownMixin = {};

function DelvesDifficultyPickerDropdownMixin:OnEnter()
	if not self:IsEnabled() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, ERR_DELVE_IN_PROGRESS:format(self.text or ""));
		GameTooltip:Show();
	end
end

function DelvesDifficultyPickerDropdownMixin:OnLeave()
	GameTooltip:Hide();
end
