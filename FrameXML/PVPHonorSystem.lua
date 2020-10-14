PVPHonorRewardCodeMixin = {};

function PVPHonorRewardCodeMixin:OnLoad()
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function PVPHonorRewardCodeMixin:OnEvent(event, ...)
    if (event == "GET_ITEM_INFO_RECEIVED" and self.rewardInfo and self.rewardInfo.waitingOnItem) then
        local id = ...;
        if (id == self.rewardInfo.id) then
            self.rewardInfo:Set(id);
            self.rewardInfo:SetUpFrame(self);
        end
    end
end

PVPHonorRewardInfoMixin = {};

function PVPHonorRewardInfoMixin:Set(...)
	-- Override in your mixin to set self.icon and self.quantity if needed
end

function PVPHonorRewardInfoMixin:SetTooltip()
	-- Override in your mixin to set the game tooltip properly
end

function PVPHonorRewardInfoMixin:GetIcon()
	return self.icon;
end

function PVPHonorRewardInfoMixin:GetQuantity()
	return self.quantity;
end

function PVPHonorRewardInfoMixin:SetUpFrame(frame)
	frame.Icon:SetTexture(self.icon);
	if (self.texCoords) then
		frame.Icon:SetTexCoord(unpack(self.texCoords));
	else
		frame.Icon:SetTexCoord(0, 1, 0, 1);
	end

    frame.Icon:Show();
    frame.Frame:Show();

    if (frame.Text) then
        frame.Text:Hide();
    end
end

PVPHonorRewardArtifactPowerMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardArtifactPowerMixin:Set(...)
	local quantity = ...;
	self.icon = select(4, C_ArtifactUI.GetEquippedArtifactInfo()) or 1109508;
	self.quantity = quantity;
end

function PVPHonorRewardArtifactPowerMixin:SetTooltip()
	GameTooltip:SetText(HONOR_REWARD_ARTIFACT_POWER);
	GameTooltip:AddLine(ARTIFACT_POWER_GAIN:format(self.quantity), 1, 1, 1, true);
    return true;
end

PVPHonorRewardItemMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardItemMixin:Set(...)
	local id = ...;
	self.id = id;
	self.icon = select(10, GetItemInfo(id));
	self.waitingOnItem = not self.icon;	
end

function PVPHonorRewardItemMixin:SetTooltip()
	GameTooltip:SetItemByID(self.id);
    return true;
end

PVPHonorRewardCurrencyMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardCurrencyMixin:Set(...)
	local id, quantity = ...;

	self.id = id;
	self.quantity = quantity;
	self.icon = C_CurrencyInfo.GetCurrencyInfo(id).iconFileID;
end

function PVPHonorRewardCurrencyMixin:SetTooltip()
	GameTooltip:SetCurrencyByID(self.id);
    return true;
end

PVPHonorRewardMoneyMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardMoneyMixin:Set(...)
	local quantity = ...;

	self.icon = "Interface\\Icons\\inv_misc_coin_01";
	self.quantity = floor(quantity / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	self.realQuantity = quantity;
end

function PVPHonorRewardMoneyMixin:SetTooltip()
	GameTooltip:SetText(HONOR_REWARD_MONEY);
	GameTooltip:AddLine(GetMoneyString(self.realQuantity), 1, 1, 1, true);
    return true;
end

PVPHonorRewardTitleMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardTitleMixin:Set(...)
    local id = ...;
    
	self.icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
	self.texCoords = {0.01562500, 0.53125000, 0.32421875, 0.46093750};
    self.text = GetRewardPackTitleName(id);
end

function PVPHonorRewardTitleMixin:SetTooltip()
	if (not self.showTooltip) then
		return false;
	end

	GameTooltip:SetText(HONOR_REWARD_TITLE_TOOLTIP);
	GameTooltip:AddLine(self.text, 1, 1, 1, true);
	return true;
end

function PVPHonorRewardTitleMixin:SetUpFrame(frame)
    if (not frame.Text) then
		self.showTooltip = true;
       	PVPHonorRewardInfoMixin.SetUpFrame(self, frame);
		return;
    end
    
	self.showTooltip = false;

    if (frame.formatString) then
        frame.Text:SetFormattedText(frame.formatString, self.text);
    else
        frame.Text:SetText(self.text);
    end
    
    frame.Icon:Hide();
    frame.Frame:Hide();
    frame.Text:Show();
end

function IsWatchingHonorAsXP()
	return GetCVarBool("showHonorAsExperience");
end

function SetWatchingHonorAsXP(value)
	SetCVar("showHonorAsExperience", value);
end

function PVPHonorXPBar_OnLoad(self)
	local tex = self.Bar:GetStatusBarTexture();
	self.Bar.Spark:ClearAllPoints();
	if (self.isSmall) then
		self.Bar.Spark:SetPoint("CENTER", tex, "RIGHT", 0, 2);
	else
		self.Bar.Spark:SetPoint("CENTER", tex, "RIGHT", 0, 0);
	end
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	
	if (self.Lock) then
        PVPHonorXPBar_CheckLockState(self);
    end
	PVPHonorXPBar_Update(self);
	self.Bar:Reset();
end

function PVPHonorXPBar_Update(self)
	local current = UnitHonor("player");
	local max = UnitHonorMax("player");

	local level = UnitHonorLevel("player");

	self.Bar:SetAnimatedValues(current, 0, max, level);
	self.Bar.Spark:SetShown(current > 0);

    self.Bar:SetStatusBarAtlas("_honorsystem-bar-fill");
    
    
    if (not self.locked) then
        self.Level:SetText(UnitHonorLevel("player"));
	    PVPHonorXPBar_SetNextAvailable(self);
    end
end

function PVPHonorXPBar_CheckLockState(self)
    if not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
        PVPHonorXPBar_Lock(self);
    else
        PVPHonorXPBar_Unlock(self);
    end
end

function PVPHonorXPBar_Lock(self)
    self.NextAvailable:Hide();
    self.Level:Hide();
    self.Bar.ExhaustionLevelFillBar:Hide();
    self.Bar.ExhaustionTick:Hide();
    self.Bar.Lock:Show();
    self.Frame:SetAlpha(.5);
    self.Bar.Background:SetAlpha(.5);
    self.Frame:SetDesaturated(true);
    self.Bar.Background:SetDesaturated(true);

    self.locked = true;
end

function PVPHonorXPBar_Unlock(self)
    self.Level:Show();
    self.Frame:SetAlpha(1);
    self.Bar.Background:SetAlpha(1);
    self.Bar.Lock:Hide();
    self.Frame:SetDesaturated(false);
    self.Bar.Background:SetDesaturated(false);
    self.locked = false;
    PVPHonorXPBar_Update(self);
end

function PVPHonorXPBar_OnEnter(self)
    if (self:GetParent().locked) then
        return;
    end
    
	local current = UnitHonor("player");
	local max = UnitHonorMax("player");

	if (not current or not max) then
		return;
	end

	self.OverlayFrame.Text:SetText(HONOR_BAR:format(current, max));
	self.OverlayFrame.Text:Show();
end

function PVPHonorXPBar_OnLeave(self)
	self.OverlayFrame.Text:Hide();
end

local function CreateHackRewardInfo()
	local rewardInfo;
	local factionGroup = UnitFactionGroup("player");
	local itemID;
	if ( factionGroup == "Horde" ) then
		itemID = 138996;
	else
		itemID = 138992;
	end
	rewardInfo = CreateFromMixins(PVPHonorRewardItemMixin);
	rewardInfo:Set(itemID);
	return rewardInfo;
end

function PVPHonorSystem_GetNextReward()
	local rewardInfo;
			
	local rewardPackID = nil;
	if (rewardPackID) then
		local items = GetRewardPackItems(rewardPackID);
		local currencies = GetRewardPackCurrencies(rewardPackID);
		local money = GetRewardPackMoney(rewardPackID);
		local artifactPower = GetRewardPackArtifactPower(rewardPackID);
		local title = GetRewardPackTitle(rewardPackID);
		if (items and #items > 0) then
			rewardInfo = CreateFromMixins(PVPHonorRewardItemMixin);
			rewardInfo:Set(items[1]);
		elseif (artifactPower and artifactPower > 0) then
			rewardInfo = CreateFromMixins(PVPHonorRewardArtifactPowerMixin);
			rewardInfo:Set(artifactPower);
		elseif (currencies and #currencies > 0) then
			rewardInfo = CreateFromMixins(PVPHonorRewardCurrencyMixin);
			rewardInfo:Set(currencies[1].currencyType, currencies[1].quantity);
		elseif (money and money > 0) then
			rewardInfo = CreateFromMixins(PVPHonorRewardMoneyMixin);
			rewardInfo:Set(money);
        elseif (title and title > 0) then
            rewardInfo = CreateFromMixins(PVPHonorRewardTitleMixin);
            rewardInfo:Set(title);
        end
	end

	return rewardInfo;
end

function PVPHonorXPBar_SetNextAvailable(self)
	local showNext = false;

	self.PrestigeReward.PrestigeSpinAnimation:Stop();
	self.PrestigeReward.PrestigePulseAnimation:Stop();
	
	self.rewardInfo = PVPHonorSystem_GetNextReward();

	if (self.rewardInfo) then
		self.rewardInfo:SetUpFrame(self.NextAvailable);
		showNext = true;	
	end
	

	self.NextAvailable:SetShown(showNext);
	self.PrestigeReward:SetShown(false);
end

function PVPHonorSystemXPBarNextAvailable_OnEnter(self)
	local rewardInfo = self:GetParent().rewardInfo;
	if (rewardInfo) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (rewardInfo:SetTooltip()) then
    		GameTooltip:Show();
        end
	end
end	

function HonorExhaustionTick_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXHAUSTION");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");

	self.fillBarAlpha = 0.15;
end

function HonorExhaustionToolTipText(self)
	return;
end

function HonorLevelUpBanner_OnLoad(self)
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
end

function HonorLevelUpBanner_OnEvent(self, event, ...)
	if (event == "HONOR_LEVEL_UPDATE") then
        local showBanner = ...;
        if (showBanner) then
		    local level = UnitHonorLevel("player");
            self.Title:SetText(HONOR_LEVEL_LABEL:format(level));
			self.TitleFlash:SetText(HONOR_LEVEL_LABEL:format(level));
			self:Show();
			self.Anim:Play();
			self.currentLevel = level;
		end
	end
end