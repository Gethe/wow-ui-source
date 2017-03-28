PVPHonorRewardMixin = {};

function PVPHonorRewardMixin:OnLoad()
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function PVPHonorRewardMixin:OnEvent(event, ...)
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

PVPHonorRewardTalentMixin = Mixin({}, PVPHonorRewardInfoMixin);

function PVPHonorRewardTalentMixin:Set(...)
	local id = ...;
	self.id = id;
	self.icon = select(3, GetPvpTalentInfoByID(id, GetActiveSpecGroup));
end

function PVPHonorRewardTalentMixin:SetTooltip()
	GameTooltip:SetPvpTalent(self.id);
    return true;
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
	self.icon = select(3, GetCurrencyInfo(id));
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
	self:RegisterEvent("HONOR_PRESTIGE_UPDATE");
	
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
	local levelmax = GetMaxPlayerHonorLevel();
    
	if (level == levelmax) then
		-- Force the bar to full for the max level
		self.Bar:SetAnimatedValues(1, 0, 1, level);
	else
		self.Bar:SetAnimatedValues(current, 0, max, level);
		self.Bar.Spark:SetShown(current > 0);
	end
    
    local exhaustionStateID = GetHonorRestState();
    if (exhaustionStateID == 1) then
        self.Bar:SetStatusBarAtlas("_honorsystem-bar-fill-rested");
    else
        self.Bar:SetStatusBarAtlas("_honorsystem-bar-fill");
    end
    
    
    if (not self.locked) then
        self.Level:SetText(UnitHonorLevel("player"));
	    PVPHonorXPBar_SetNextAvailable(self);
	    HonorExhaustionTick_Update(self.Bar.ExhaustionTick);
    end
end

function PVPHonorXPBar_CheckLockState(self)
    if (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]) then
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

	local level = UnitHonorLevel("player");
	local levelmax = GetMaxPlayerHonorLevel();

	if (CanPrestige()) then
		self.OverlayFrame.Text:SetText(PVP_HONOR_PRESTIGE_AVAILABLE);
	elseif (level == levelmax) then
		self.OverlayFrame.Text:SetText(MAX_HONOR_LEVEL);
	else
		self.OverlayFrame.Text:SetText(HONOR_BAR:format(current, max));
	end
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
			
	local talentID = GetPvpTalentUnlock();	
	if (talentID) then
		 rewardInfo = CreateFromMixins(PVPHonorRewardTalentMixin);
		 rewardInfo:Set(talentID);
	-- TODO:  Remove this when we can figure this out in a better way
	elseif (UnitPrestige("player") == 1 and UnitHonorLevel("player") == 49) then
		rewardInfo = CreateHackRewardInfo();
	else
		local rewardPackID = GetHonorLevelRewardPack();
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
	end

	return rewardInfo;
end

function PVPHonorSystem_GetMaxPVPLevelReward(prestige)
    if (not prestige) then
        prestige = UnitPrestige("player");
    end
    
    local rewardInfo;
	
	-- TODO:  Remove this when we can figure this out in a better way
	if (UnitPrestige("player") == 0) then
		rewardInfo = CreateHackRewardInfo();
	else
		local rewardPackID = GetHonorLevelRewardPack(GetMaxPlayerHonorLevel(), prestige);
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
	end

    return rewardInfo;
end

function PVPHonorXPBar_SetNextAvailable(self)
	local showNext = false;
	local showPrestige = false;

	if (CanPrestige()) then
		showPrestige = true;
		PVPHonorXPBar_SetPrestige(self.PrestigeReward);
		self.PrestigeReward.PrestigeSpinAnimation:Play();
		self.PrestigeReward.PrestigePulseAnimation:Play();
	else
		showPrestige = false;
		self.PrestigeReward.PrestigeSpinAnimation:Stop();
		self.PrestigeReward.PrestigePulseAnimation:Stop();
	
		self.rewardInfo = PVPHonorSystem_GetNextReward();

		if (self.rewardInfo) then
			self.rewardInfo:SetUpFrame(self.NextAvailable);
			showNext = true;	
		end
	end

	self.NextAvailable:SetShown(showNext);
	self.PrestigeReward:SetShown(showPrestige);
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

function PVPHonorXPBar_SetPrestige(self)
	local newPrestigeLevel = UnitPrestige("player") + 1;

	local icon, name = GetPrestigeInfo(newPrestigeLevel);

	self.PortraitBg:SetAtlas("honorsystem-prestige-laurel-bg-"..UnitFactionGroup("player"), false);
	self.Icon:SetTexture(icon or 0);

	local canPrestigeHere = self:GetParent().canPrestigeHere;
	self.Accept:SetShown(canPrestigeHere);

	if (not canPrestigeHere) then
		self.tooltip = PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE;
	else
		self.tooltip = name;
	end
    
	self:Show();
end

function PVPHonorXPBarPrestige_OnClick(self)
	local frame = PVPTalentPrestigeLevelDialog;

	local newPrestigeLevel = UnitPrestige("player") + 1;

	frame.NextRank:SetText(newPrestigeLevel);
    local texture, name = GetPrestigeInfo(newPrestigeLevel);
	frame.NextRankLabel:SetText(name);
	frame.PrestigeIcon:SetTexture(texture);
	frame.LaurelBackground:SetAtlas("honorsystem-prestige-laurel-bg-"..UnitFactionGroup("player"), false);
    
    local rewardFrame = frame.MaxLevelReward;
    
    rewardFrame.rewardInfo = PVPHonorSystem_GetMaxPVPLevelReward(newPrestigeLevel);
    
    if (rewardFrame.rewardInfo) then
        rewardFrame.rewardInfo:SetUpFrame(rewardFrame);
        rewardFrame:Show();
        frame.TopDivider:Show();
		frame.NextMaxLevelReward:SetFormattedText(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD, GetMaxPlayerHonorLevel());
        frame.NextMaxLevelReward:Show();
        frame.BottomDivider:Show();
        frame:SetHeight(500);
    else
        rewardFrame:Hide();
        frame.TopDivider:Hide();
        frame.NextMaxLevelReward:Hide();
        frame.BottomDivider:Hide();
        frame:SetHeight(440);
    end
    
    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HONOR_TALENT_PRESTIGE, true);
    PlayerTalentFramePVPTalents.TutorialBox:Hide();
	PlaySound("UI_PVP_Honor_Prestige_OpenWindow");                          
    frame:Show();
end

function HonorExhaustionTick_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXHAUSTION");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");

	self.fillBarAlpha = 0.15;
end

function HonorExhaustionTick_Update(self, isMainMenuBar)
	local fillBar = self:GetParent().ExhaustionLevelFillBar;
    local level = UnitHonorLevel("player");
    local levelmax = GetMaxPlayerHonorLevel();
	-- Hide exhaustion tick if player is max level
	if ( level == levelmax ) then
		self:Hide();
		fillBar:Hide();
		return;
	end

	local playerCurrXP = UnitHonor("player");
	local playerMaxXP = UnitHonorMax("player");
	local exhaustionThreshold = GetHonorExhaustion();
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier, exhaustionTickSet;
	exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetHonorRestState();
	
	if (not exhaustionThreshold or exhaustionThreshold == 0) then
		self:Hide();
		fillBar:Hide();
		return;
	else
		exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * self:GetParent():GetWidth(), 0);
		if (exhaustionTickSet > self:GetParent():GetWidth()) then
			self:Hide();
			fillBar:Hide();
		else
			fillBar:SetWidth(exhaustionTickSet);
			fillBar:Show();
			self:Show();
		end
	end

	local exhaustionStateID = GetHonorRestState();
	if (exhaustionStateID == 1) then
        local r, g, b = 1.0, 0.50, 0.0;
        if (isMainMenuBar) then
            g = 0.71;
        end
		fillBar:SetVertexColor(r, g, b, self.fillBarAlpha);
		self.Highlight:SetVertexColor(r, g, b, 1.0);
	end
end

function HonorExhaustionToolTipText(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);	
	
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier;
	exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetHonorRestState();

	local exhaustionCurrXP, exhaustionMaxXP;
	local exhaustionThreshold = GetHonorExhaustion();

	exhaustionStateMultiplier = exhaustionStateMultiplier * 100;
	local exhaustionCountdown = nil;
	if ( GetTimeToWellRested() ) then
		exhaustionCountdown = GetTimeToWellRested() / 60;
	end
	
	local currXP = UnitHonor("player");
	local nextXP = UnitHonorMax("player");
	local percentXP = math.ceil(currXP/nextXP*100);
	local XPText = format( XP_TEXT, BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP );
	local tooltipText = XPText..format(EXHAUST_HONOR_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier);
	local append = nil;
	if ( IsResting() ) then
		if ( exhaustionThreshold and exhaustionCountdown ) then
			append = format(EXHAUST_TOOLTIP4, exhaustionCountdown);
		end
	elseif ( (exhaustionStateID == 4) or (exhaustionStateID == 5) ) then
		append = EXHAUST_TOOLTIP2;
	end

	if ( append ) then
		tooltipText = tooltipText..append;
	end

	if ( SHOW_NEWBIE_TIPS ~= "1" ) then
		GameTooltip:SetText(tooltipText);
	else
		if ( GameTooltip.canAddRestStateLine ) then
			GameTooltip:AddLine("\n"..tooltipText);
			GameTooltip:Show();
			GameTooltip.canAddRestStateLine = nil;
		end
	end
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

function PrestigeLevelUpBanner_OnLoad(self)
	self:RegisterEvent("HONOR_PRESTIGE_UPDATE");
end

function PrestigeLevelUpBanner_OnEvent(self, event, ...)
	if (event == "HONOR_PRESTIGE_UPDATE") then
		local prestige = UnitPrestige("player");
		local factionGroup = UnitFactionGroup("player");
		local texture, name = GetPrestigeInfo(prestige);
		self.Text:SetText(name);
		self.Level:SetText(prestige);
		self.IconPlate:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.IconPlate2:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.IconPlate3:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.Icon:SetTexture(texture);
		self.Icon2:SetTexture(texture);
		self.Icon3:SetTexture(texture);
		self:Show();
		self.Anim:Play();
	end
end
