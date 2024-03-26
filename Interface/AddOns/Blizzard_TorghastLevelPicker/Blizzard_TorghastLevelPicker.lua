
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID = 90;
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET = -220; 

local gossipButtonTextureKitRegions = {
	["Background"] = "jailerstower-wayfinder-tierbackground-%s",
}

local TORGHAST_LEVEL_PICKER_EVENTS = {
	"PARTY_LEADER_CHANGED",
	"GOSSIP_OPTIONS_REFRESHED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_AREA_CHANGED",
	"UNIT_PHASE", 
	"GROUP_FORMED",
};

TorghastLevelPickerFrameMixin = {};

function TorghastLevelPickerFrameMixin:OnLoad()
	CustomGossipFrameBaseMixin.OnLoad(self);
	self.gossipOptionsPool = CreateFramePool("CHECKBUTTON", self.GridLayoutContainer, "TorghastLevelPickerOptionButtonTemplate");
end

function TorghastLevelPickerFrameMixin:OnEvent(event, ...)
	if (event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_FORMED") then 
		C_GossipInfo.RefreshOptions(); 
		local inParty = UnitInParty("player"); 
		self.isPartyLeader = not inParty or UnitIsGroupLeader("player");
	elseif(event == "UNIT_AREA_CHANGED" or event == "UNIT_PHASE") then 
		C_GossipInfo.RefreshOptions(); 
	elseif (event == "GOSSIP_OPTIONS_REFRESHED") then 
		self:SetupOptions();
		self:UpdatePortalButtonState();
	end 
end 

function TorghastLevelPickerFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TORGHAST_LEVEL_PICKER_EVENTS);
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_OPEN_UI); 
end 

function TorghastLevelPickerFrameMixin:CancelEffects()
	if(self.backgroundEffectController) then 
		self.backgroundEffectController:CancelEffect(); 
		self.backgroundEffectController = nil; 
	end 
end 

function TorghastLevelPickerFrameMixin:UpdatePortalButtonState(startingIndex)
	local enabled = true; 
	local isPartyInTorghast = C_PartyInfo.IsPartyInJailersTower(); 
	if	(startingIndex and self.currentSelectedButtonIndex) then 
		local maxIndexPerPage = (self.maxOptionsPerPage + startingIndex) - 1; 
		enabled = self.currentSelectedButtonIndex >= startingIndex and self.currentSelectedButtonIndex <= maxIndexPerPage;
	end 

	self.OpenPortalButton:SetEnabled(self.isPartyLeader and self.currentSelectedButton and enabled and isPartyInTorghast)
end

function TorghastLevelPickerFrameMixin:SetupOptions()
	self:BuildOptionList();
	self:SetupGrid();
	self:SetupLevelButtons(); 
end 

function TorghastLevelPickerFrameMixin:TryShow(textureKit) 
	self.textureKit = textureKit; 
	self.Title:SetText(C_GossipInfo.GetText());
	local inParty = UnitInParty("player"); 
	self.isPartyLeader = not inParty or UnitIsGroupLeader("player");

	self:CancelEffects(); 

	local smokeEffectDescription = { effectID = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID, offsetY = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET, };
	self.backgroundEffectController = GlobalFXBackgroundModelScene:AddDynamicEffect(smokeEffectDescription, self);

	self:SetupOptions();
	self:ScrollAndSelectHighestAvailableLayer();
	self:SetupDescription();
	ShowUIPanel(self); 
end 

function TorghastLevelPickerFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TORGHAST_LEVEL_PICKER_EVENTS);
	self:ClearLevelSelection(); 

	self.textureKit = nil; 
	EmbeddedItemTooltip:Hide(); 
	self:CancelEffects(); 
	C_GossipInfo.CloseGossip(); 
end		

function TorghastLevelPickerFrameMixin:SetupGrid()
	self.GridLayoutContainer:SetSize(420, 260); 
	self.GridLayoutContainer:ClearAllPoints();
	self.GridLayoutContainer:SetPoint("TOP", self.SubTitle, "BOTTOM", 20, -40)
end 

function TorghastLevelPickerFrameMixin:SetupLevelButtons()
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.GridLayoutContainer, "TOPLEFT");
	local overridePaddingX = 45; 
	local overridePaddingY = 45; 
	self:LayoutGridInit(anchor, overridePaddingX, overridePaddingY, GridLayoutMixin.Direction.TopLeftToBottomRight); 
	self:UpdatePortalButtonState(); 
end 

function TorghastLevelPickerFrameMixin:SetStartingPage(page)
	self.Pager:Init(page); 
end 

function TorghastLevelPickerFrameMixin:GetCurrentPage()
	return self.Pager.currentPage; 
end

function TorghastLevelPickerFrameMixin:ClearLevelSelection() 
	if (self.currentSelectedButton) then 
		self.currentSelectedButton:ClearSelection(); 
		self.currentSelectedButton = nil;
		self.currentSelectedButtonIndex = nil;
	end
	self.highestAvailableLayerIndex = nil;
	self:UpdatePortalButtonState(); 
end 

function TorghastLevelPickerFrameMixin:SelectLevel(selectedLevelButton)
	if(self.currentSelectedButton == selectedLevelButton and self.currentSelectedButtonIndex == selectedLevelButton.index) then 
		self.currentSelectedButton:ClearSelection(); 
		self.currentSelectedButton = nil;
		self.currentSelectedButtonIndex = nil;
	else 
		if (self.currentSelectedButton) then 
			self.currentSelectedButton:ClearSelection(); 
		end 
		self.currentSelectedButton = selectedLevelButton; 
		self.currentSelectedButtonIndex = self.currentSelectedButton.index; 
	end
	self:UpdatePortalButtonState(); 
end		

function TorghastLevelPickerFrameMixin:SetupBackground()
	SetupTextureKitOnRegions(self.textureKit, self, gossipBackgroundTextureKitRegion, true, TextureKitConstants.UseAtlasSize);
end

function TorghastLevelPickerFrameMixin:SetupDescription() 
	local description = C_GossipInfo.GetCustomGossipDescriptionString() or "";
	self.Description:SetText(description);
end

function TorghastLevelPickerFrameMixin:ScrollAndSelectHighestAvailableLayer()
	local highestAvailableLayerIndex = nil

	--First get the highest unlocked layer. 
	for i = 1, #self.gossipOptions do 
		local optionInfo = self.gossipOptions[i];
		local optionCanBeSelected = optionInfo.status == Enum.GossipOptionStatus.Available or optionInfo.status == Enum.GossipOptionStatus.AlreadyComplete; 
		if (optionCanBeSelected and (not highestAvailableLayerIndex or (highestAvailableLayerIndex < i))) then 
			highestAvailableLayerIndex = i;
		end 
	end 

	-- If there is none which there shouldn't be.. return
	if(not highestAvailableLayerIndex) then 
		return;
	end 

	-- Go to the page that has this layer
	local page = math.ceil(highestAvailableLayerIndex / self.maxOptionsPerPage);  
	self:SetStartingPage(page); 

	local startingIndex = ((page - 1) * self.maxOptionsPerPage) + 1;
	self:SetupOptionsByStartingIndex(startingIndex);
	self.highestAvailableLayerIndex = highestAvailableLayerIndex;

	-- Select the option that is the highest available layer. 
	for layer in self.gossipOptionsPool:EnumerateActive() do 
		if (layer.index == highestAvailableLayerIndex) then 
			self:SelectLevel(layer);
			layer:SetState(self.gossipOptions[highestAvailableLayerIndex].status);
			return; 
		end 
	end 

end 

TorghastLevelPickerOptionButtonMixin = {}; 

function TorghastLevelPickerOptionButtonMixin:SetDifficultyTexture()
	if(not self.index) then 
		return; 
	end 
	if(self.index == 1) then 
		self.Icon:SetAtlas("jailerstower-skull-1",true);
	elseif (self.index == 2) then
		self.Icon:SetAtlas("jailerstower-skull-2",true);
	else 
		self.Icon:SetAtlas("jailerstower-skull-3",true);
	end 
end 

function TorghastLevelPickerOptionButtonMixin:Setup(textureKit, optionInfo, index) 
	self.optionInfo = optionInfo;
	self:SetupBase(textureKit, optionInfo, optionInfo.orderIndex, gossipButtonTextureKitRegions)
	self:SetState(optionInfo.status); 
	self:SetDifficultyTexture();
	self.spell = nil; 

	self:Show(); 

	if(not optionInfo.spellID)  then 
		return; 
	end 

	if not self.spell then
		self.spell = Spell:CreateFromSpellID(optionInfo.spellID);
	end

	local onSpellLoad = function()
		self:RefreshTooltip(); 
	end;
	self.spell:ContinueOnSpellLoad(onSpellLoad);
end 

function TorghastLevelPickerOptionButtonMixin:ShouldOptionBeEnabled()
	return true; 
end 

function TorghastLevelPickerOptionButtonMixin:SetState(status)
	local lockedState = status == Enum.GossipOptionStatus.Locked;
	local completeState = status == Enum.GossipOptionStatus.AlreadyComplete; 
	self.RewardBanner.BannerDisabled:SetShown(lockedState);
	self.RewardBanner.Reward.completeState = completeState; 
	self.RewardBanner.Reward.lockedState = lockedState; 
	self.RewardBanner.Reward:Init()
	self.Background:SetDesaturated(lockedState);
	self.Icon:SetDesaturated(lockedState); 
	local parent = self:GetParent():GetParent(); 
	local isHighestAvailableLayer = self.index == parent.highestAvailableLayerIndex;
	local isChecked = (self == parent.currentSelectedButton) and (self.index == parent.currentSelectedButtonIndex);
	self.RewardBanner.Banner:SetShown(not lockedState);
	self.RewardBanner.BannerSelected:SetShown(not lockedState and isChecked);
	self.RewardBanner.Reward.PulseAnim:Stop();

	-- We never want the locked icon to be checked.  
	if(isChecked and lockedState) then
		isChecked = false; 
		self:GetParent():GetParent():SelectLevel(self);
	end 
	self:SetChecked(isChecked); 
	self.SelectedBorder:SetShown(self:GetChecked());
	local fontColor = HIGHLIGHT_FONT_COLOR; 
	if(lockedState) then
		fontColor = LIGHTGRAY_FONT_COLOR;
	end 
	self.Title:SetTextColor(fontColor:GetRGB());
	self.RewardBanner.Reward.HighlightGlow:SetShown(isHighestAvailableLayer);
	self.RewardBanner.Reward.HighlightGlow2:SetShown(isHighestAvailableLayer);
	if(self.RewardBanner.Reward.HighlightGlow:IsShown()) then 
		self.RewardBanner.Reward.PulseAnim:Play();
	end
	self:SetEnabled(not lockedState);
end

function TorghastLevelPickerOptionButtonMixin:UpdateSelectionState()
	local isChecked = self:GetChecked(); 
	self.SelectedBorder:SetShown(isChecked); 
	self.RewardBanner.BannerSelected:SetShown(isChecked)
end 

function TorghastLevelPickerOptionButtonMixin:ClearSelection()
	self:SetChecked(false);
	self:UpdateSelectionState(); 
end 

function TorghastLevelPickerOptionButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_SELECT_DIFFICULTY); 
	self:SetChecked(true);
	self:GetParent():GetParent():SelectLevel(self);
	self:UpdateSelectionState(); 
end 

function TorghastLevelPickerOptionButtonMixin:RefreshTooltip()
	if (not RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self) or not self.spell) then 
		return;
	end 

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local description = self.spell:GetSpellDescription();
	GameTooltip_AddNormalLine(GameTooltip, description);
	GameTooltip:Show(); 
end 

function TorghastLevelPickerOptionButtonMixin:OnEnter()
	self:RefreshTooltip(); 
end 


function TorghastLevelPickerOptionButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end		

TorghastPagingContainerMixin = {}; 

function TorghastPagingContainerMixin:Init(startingPageNumber)
	self.currentPage = startingPageNumber;
	self.numPages = self:GetParent().numPages; 
	self.maxOptionsPerPage = self:GetParent().maxOptionsPerPage;
	self:Setup();
end		

function TorghastPagingContainerMixin:Setup()
	self:SetupPageNumberString(); 
	self:SetupPagingButtonStates();
end 

function TorghastPagingContainerMixin:SetupPageNumberString()
	self.CurrentPage:SetText(string.format(TORGHAST_WAYFINDER_PAGE, self.currentPage, self.numPages));	
end 

function TorghastPagingContainerMixin:SetupPagingButtonStates()
	self.PreviousPage:SetEnabled(self.currentPage > 1);
	self.NextPage:SetEnabled(self.currentPage < self.numPages);
end 

function TorghastPagingContainerMixin:PagePrevious()
	self.currentPage = self.currentPage - 1; 
	local startingIndex = ((self.currentPage - 1) * self.maxOptionsPerPage) + 1;
	self:GetParent():SetupOptionsByStartingIndex(startingIndex);
	self:Setup(); 
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_PAGING_CLICK);
	self:GetParent():UpdatePortalButtonState(startingIndex);
end 

function TorghastPagingContainerMixin:PageNext()
	self.currentPage = self.currentPage + 1; 
	local startingIndex = ((self.currentPage - 1) * self.maxOptionsPerPage) + 1;
	self:GetParent():SetupOptionsByStartingIndex(startingIndex);
	self:Setup(); 
	self:GetParent():UpdatePortalButtonState(startingIndex);
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_PAGING_CLICK);
end 

TorghastLevelPickerRewardCircleMixin = {}; 

local function TorghastLevelPickerRewardSortFunction(firstValue, secondValue)
	return firstValue > secondValue;
end

function TorghastLevelPickerRewardCircleMixin:SetSortedRewards()
	local continuableContainer = ContinuableContainer:Create();
	self.currencyRewards = { };

	for _, reward in ipairs(self.rewards) do 
		if	(reward.rewardType == Enum.GossipOptionRewardType.Item) then 
			local item = Item:CreateFromItemID(reward.id);
			continuableContainer:AddContinuable(item);
		else
			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(reward.id, reward.quantity); 
			if (IsCurrencyContainer) then 
				local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, quantity);
				table.insert(self.currencyRewards, {id = reward.id, texture = texture, quantity = quantity, quality = quality, name = name, isCurrencyContainer = true, });
			else 
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
				table.insert(self.currencyRewards, {id = reward.id, texture = currencyInfo.iconFileID, quantity = reward.quantity, quality = currencyInfo.quality, name = currencyInfo.name, isCurrencyContainer = false, });
			end 
		end
	end 

	continuableContainer:ContinueOnLoad(function()
		self.itemRewards = { };
		for  _, reward in ipairs(self.rewards) do
			if	(reward.rewardType == Enum.GossipOptionRewardType.Item) then 
				local name, _, quality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(reward.id);
				table.insert(self.itemRewards, {id = reward.id, quality = quality, quantity = reward.quantity, texture = itemIcon, name = name});
			end
		end
		if (self.itemRewards and #self.itemRewards > 1) then
			table.sort(self.itemRewards, function(a, b) 
				return TorghastLevelPickerRewardSortFunction(a.quality, b.quality); 
			end);
		end 
		self:RefreshTooltip();
		self:SetRewardIcon(); 
	end);

	if (self.currencyRewards and #self.currencyRewards > 1) then
		table.sort(self.currencyRewards, function(a, b) 
			return TorghastLevelPickerRewardSortFunction(a.quality, b.quality); 
		end);
	end 
end 

function TorghastLevelPickerRewardCircleMixin:AddCurrencyToTooltip(currency, tooltip)
	if (tooltip) then
		if currency.isCurrencyContainer then
			local text = JAILERS_TOWER_CURRENCY_REWARD_CONTAINER:format(currency.texture, currency.name);
			local color = ITEM_QUALITY_COLORS[currency.quality];
			tooltip:AddLine(text, color.r, color.g, color.b);
		else
			local text = JAILERS_TOWER_CURRENCY_REWARD_FORMAT:format(currency.texture, currency.quantity, currency.name);
			tooltip:AddLine(text, HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	end
end 

function TorghastLevelPickerRewardCircleMixin:SetRewardIcon()
	if (self.itemRewards and self.itemRewards[1]) then 
		local texture = select(5, C_Item.GetItemInfoInstant(self.itemRewards[1].id));
		self.Icon:SetTexture(texture);
		return; 
	end 

	if(self.currencyRewards and self.currencyRewards[1]) then 
		self.Icon:SetTexture(self.currencyRewards[1].texture);
	end 
end 

function TorghastLevelPickerRewardCircleMixin:Init()
	self.rewards = self:GetParent():GetParent().optionInfo.rewards;
	self.currencyRewards = { };
	self.itemRewards = { }; 

	local shouldShow = self.completeState or self.lockedState or (not self.lockedState and (self.rewards and #self.rewards > 0)); 
	local shouldShowRewards = not self.completeState and not self.lockedState; 

	self:SetShown(shouldShow);
	if (not shouldShow) then 
		return; 
	end 
	
	self.index = self:GetParent():GetParent().index;

	self.RewardBorder:SetShown(shouldShowRewards);
	self.Icon:SetShown(shouldShowRewards);
	self.QuestComplete:SetShown(self.completeState);
	self.LockedIcon:SetShown(self.lockedState); 

	if(shouldShowRewards) then 
		self:SetSortedRewards(); 
		self:SetRewardIcon(); 
	end 

end 

function TorghastLevelPickerRewardCircleMixin:OnEnter()
	self:RefreshTooltip(); 
end 

function TorghastLevelPickerRewardCircleMixin:RefreshTooltip()
	if (not self:IsMouseOver()) then 
		return;
	end 

	if (self.lockedState) then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local timeLockedError = IsJailersTowerLayerTimeLocked(self.index);
		if (timeLockedError) then
			GameTooltip_AddErrorLine(EmbeddedItemTooltip, timeLockedError, true);
		elseif (UnitInParty("player")) then 
			GameTooltip_AddErrorLine(EmbeddedItemTooltip, JAILERS_TOWER_LEVEL_PICKER_PARTY_LOCK, true);
		else 
			GameTooltip_AddErrorLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_LOCKED, true);
		end 
		EmbeddedItemTooltip:Show(); 
		return; 
	end 

	if(self.completeState) then 
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local completeString = C_GossipInfo.GetCompletedOptionDescriptionString() or ""; 
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, completeString, true)
		EmbeddedItemTooltip:Show(); 
		return; 
	end 

	if (not self.currencyRewards and not self.itemRewards) then 
		return; 
	end 

	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(EmbeddedItemTooltip, JAILERS_TOWER_REWARDS_TITLE, HIGHLIGHT_FONT_COLOR, true);

	for _, currencyReward in ipairs(self.currencyRewards) do 
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		self:AddCurrencyToTooltip(currencyReward, EmbeddedItemTooltip);
	end 

	for i, itemReward in ipairs(self.itemRewards) do 
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		if(i == 1) then 
			EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, itemReward.id)
		else 
			local text;
			if itemReward.quantity > 1 then
				text = string.format(JAILERS_TOWER_ITEM_REWARD_TOOLTIP_WITH_COUNT_FORMAT, itemReward.texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(itemReward.quantity), itemReward.name);
			else
				text = string.format(JAILERS_TOWER_ITEM_REWARD_TOOLTIP_FORMAT, itemReward.texture, itemReward.name);
			end
			if text then
				local color = ITEM_QUALITY_COLORS[itemReward.quality];
				EmbeddedItemTooltip:AddLine(text, color.r, color.g, color.b);
			end
		end
	end 

	if(self.index and self.index > 1) then 
		GameTooltip_SetBottomText(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_HIGH_DIFFICULTY, NORMAL_FONT_COLOR);
	end 

	EmbeddedItemTooltip:Show(); 
end 

function TorghastLevelPickerRewardCircleMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
end 

TorghastLevelPickerOpenPortalButtonMixin = { };

function TorghastLevelPickerOpenPortalButtonMixin:OnEnter()
	if (not self:GetParent().isPartyLeader) then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddNormalLine(GameTooltip, TORGHAST_LEVEL_PICKER_LEADER_ERROR); 
		GameTooltip:Show(); 
	elseif(not C_PartyInfo.IsPartyInJailersTower()) then 
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddNormalLine(GameTooltip, TORGHAST_WAYFINDER_GATHER_PARTY); 
		GameTooltip:Show(); 
	end 
end 

function TorghastLevelPickerOpenPortalButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function TorghastLevelPickerOpenPortalButtonMixin:OnClick()
	local selectedPortal = self:GetParent().currentSelectedButton; 
	if(not selectedPortal) then 
		return; 
	end
	C_GossipInfo.SelectOptionByIndex(selectedPortal.optionInfo.orderIndex);
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_OPEN_PORTAL); 
end 
