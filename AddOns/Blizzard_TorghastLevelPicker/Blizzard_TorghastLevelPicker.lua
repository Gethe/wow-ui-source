
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID = 90;
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET = -220; 

local gossipButtonTextureKitRegions = {
	["Background"] = "jailerstower-wayfinder-tierbackground-%s",
}

TorghastLevelPickerFrameMixin = {};

function TorghastLevelPickerFrameMixin:OnLoad()
	CustomGossipFrameBaseMixin.OnLoad(self);
	self.gossipOptionsPool = CreateFramePool("CHECKBUTTON", self.GridLayoutContainer, "TorghastLevelPickerOptionButtonTemplate");
end

function TorghastLevelPickerFrameMixin:OnEvent()
end 

function TorghastLevelPickerFrameMixin:OnShow()
end 

function TorghastLevelPickerFrameMixin:TryShow(textureKit) 
	self.textureKit = textureKit; 
	self.Title:SetText(C_GossipInfo.GetText());

	local smokeEffectDescription = { effectID = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID, offsetY = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET, };
	self.ModelScene:AddDynamicEffect(smokeEffectDescription, self);

	self:BuildOptionList();
	self:SetupGrid();
	self:SetupLevelButtons(); 
	self:Show(); 
end 

function TorghastLevelPickerFrameMixin:OnHide()
	if(self.currentSelectedButton) then 
		self.currentSelectedButton:ClearSelection(); 
	end 
	self.currentSelectedButton = nil; 
	self.textureKit = nil; 
	EmbeddedItemTooltip:Hide(); 
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
	self.OpenPortalButton:SetEnabled(self.currentSelectedButton);
end 

function TorghastLevelPickerFrameMixin:SetStartingPage(page)
	self.Pager:Init(page); 
end 

function TorghastLevelPickerFrameMixin:GetCurrentPage()
	return self.Pager.currentPage; 
end

function TorghastLevelPickerFrameMixin:SelectLevel(selectedLevelButton)
	if(self.currentSelectedButton) then 
		self.currentSelectedButton:ClearSelection(); 
	end 

	self.currentSelectedButton = selectedLevelButton; 
	self.OpenPortalButton:SetEnabled(self.currentSelectedButton);
end		

function TorghastLevelPickerFrameMixin:OpenPortalOnClick()
	if(not self.currentSelectedButton) then 
		return; 
	end
	C_GossipInfo.SelectOption(self.currentSelectedButton.index); 
end 

function TorghastLevelPickerFrameMixin:SetupBackground()
	SetupTextureKitOnRegions(self.textureKit, self, gossipBackgroundTextureKitRegion, true, TextureKitConstants.UseAtlasSize);
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
	self:SetupBase(textureKit, optionInfo, index, gossipButtonTextureKitRegions)
	self:SetState(optionInfo.status); 
	self:SetDifficultyTexture();
	self:Show(); 
end 

function TorghastLevelPickerOptionButtonMixin:ShouldOptionBeEnabled()
	return true; 
end 

function TorghastLevelPickerOptionButtonMixin:SetState(status)
	local lockedState = status == Enum.GossipOptionStatus.Locked;
	local completeState = status == Enum.GossipOptionStatus.AlreadyComplete; 
	self.RewardBanner.BannerDisabled:SetShown(lockedState);
	self.RewardBanner.Banner:SetShown(not lockedState);
	self.RewardBanner.Reward.completeState = completeState; 
	self.RewardBanner.Reward.lockedState = lockedState; 
	self.RewardBanner.Reward:Init()
	self.Background:SetDesaturated(lockedState);
	self.Icon:SetDesaturated(lockedState); 

	local fontColor = HIGHLIGHT_FONT_COLOR; 
	if(lockedState) then
		fontColor = LIGHTGRAY_FONT_COLOR;
	end 
	self.Title:SetTextColor(fontColor:GetRGB());
	self:SetEnabled(not lockedState);
end

function TorghastLevelPickerOptionButtonMixin:ClearSelection()
	self:SetChecked(false)
	self.SelectedBorder:Hide(); 
end 

function TorghastLevelPickerOptionButtonMixin:OnClick()
	self:SetChecked(true);
	self:GetParent():GetParent():SelectLevel(self);
	self.SelectedBorder:Show(); 
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
end 

function TorghastPagingContainerMixin:PageNext()
	self.currentPage = self.currentPage + 1; 
	local startingIndex = ((self.currentPage - 1) * self.maxOptionsPerPage) + 1;
	self:GetParent():SetupOptionsByStartingIndex(startingIndex);
	self:Setup(); 
end 

TorghastLevelPickerRewardCircleMixin = {}; 

local function TorghastLevelPickerRewardSortFunction(firstValue, secondValue)
	return firstValue > secondValue;
end

function TorghastLevelPickerRewardCircleMixin:SetSortedRewards()
	for _, reward in ipairs(self.rewards) do 
		if	(reward.rewardType == Enum.GossipOptionRewardType.Item) then 
			local _, _, quality = GetItemInfo(reward.id);
			table.insert(self.itemRewards, {id = reward.id, quality = quality});
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
	if (self.currencyRewards and #self.currencyRewards > 1) then
		table.sort(self.currencyRewards, function(a, b) 
			return TorghastLevelPickerRewardSortFunction(a.quality, b.quality); 
		end);
	end 

	if (self.itemRewards and #self.itemRewards > 1) then
		table.sort(self.itemRewards, function(a, b) 
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
	if(self.itemRewards and self.itemRewards[1]) then 
		if (self.itemRewards and self.itemRewards[1]) then 
			local texture = select(10, GetItemInfo(self.itemRewards[1].id));
			self.Icon:SetTexture(texture);
			return; 
		end 
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

	if (self.lockedState) then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_LOCKED, true)
		EmbeddedItemTooltip:Show(); 
		return; 
	end 

	if(self.completeState) then 
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_RECIEVED, true)
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

	if (self.itemRewards and self.itemRewards[1]) then 
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, self.itemRewards[1].id);
	end 

	if(self.index and self.index > 1) then 
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_HIGH_DIFFICULTY, true)
	end 

	EmbeddedItemTooltip:Show(); 
end 

function TorghastLevelPickerRewardCircleMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
end 