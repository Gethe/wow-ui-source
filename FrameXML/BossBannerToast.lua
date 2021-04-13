
-- ************************************************************************************************************************************************************
-- **** BOSS BANNER *******************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local BB_EXPAND_TIME = 0.25;		-- time to expand per item
local BB_EXPAND_HEIGHT = 50;		-- pixels to expand per item
local BB_MAX_LOOT = 7;

local BB_STATE_BANNER_IN = 1;		-- banner is animating in
local BB_STATE_KILL_HOLD = 2;		-- banner is holding with kill info
local BB_STATE_SWITCH = 3;			-- banner is switching from kill to loot look
local BB_STATE_LOOT_EXPAND = 4;		-- banner is expanding for loot items
local BB_STATE_LOOT_INSERT = 5;		-- loot item is being inserted. banner will hold for longer than insertion animation to catch more loot.
local BB_STATE_BANNER_OUT = 6;		-- banner is animating out

function BossBanner_AnimBannerIn(self, entry)
	self.lootShown = 0;		-- how many items the UI is displaying
	self.AnimIn:Play();
end

function BossBanner_AnimKillHold(self, entry)
	-- nothing here
end

function BossBanner_AnimSwitch(self, entry)
	if ( next(self.pendingLoot) ) then
		-- we have loot
		self.AnimSwitch:Play();
		PlaySound(SOUNDKIT.UI_PERSONAL_LOOT_BANNER);
		entry.duration = 0.5;
	else
		entry.duration = 0;
	end
end

function BossBanner_AnimLootExpand(self, entry)
	-- don't need to expand for first item
	if ( self.lootShown > 0 and self.lootShown < BB_MAX_LOOT and next(self.pendingLoot) ) then
		entry.duration = BB_EXPAND_TIME;
	else
		entry.duration = 0;
	end
end

function BossBanner_AnimLootInsert(self, entry)
	local key, data = next(self.pendingLoot);
	if ( key ) then
		-- we have an item, show it
		self.pendingLoot[key] = nil;
		self.lootShown = self.lootShown + 1;
		local lootFrame = self.LootFrames[self.lootShown];
		if ( not lootFrame ) then
			lootFrame = CreateFrame("FRAME", nil, self, "BossBannerLootFrameTemplate");
			lootFrame:SetPoint("TOP", self.LootFrames[self.lootShown - 1], "BOTTOM", 0, -6);
		end
		BossBanner_ConfigureLootFrame(lootFrame, data);
		lootFrame:Show();
		lootFrame.Anim:Play();
		-- loop back if more items
		if ( next(self.pendingLoot) and self.lootShown < BB_MAX_LOOT ) then
			BossBanner_SetAnimState(self, BB_STATE_LOOT_EXPAND);
			return true;
		end
	end
	if ( self.lootShown > 0 ) then
		entry.duration = 4;
	else
		entry.duration = 0;
	end
end

function BossBanner_ConfigureLootFrame(lootFrame, data)
	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture, _, _, _, _, _, setID = GetItemInfo(data.itemLink);
	lootFrame.ItemName:SetText(itemName);
	local rarityColor = ITEM_QUALITY_COLORS[itemRarity];
	lootFrame.ItemName:SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b);
	lootFrame.Background:SetVertexColor(rarityColor.r, rarityColor.g, rarityColor.b);
	lootFrame.Icon:SetTexture(itemTexture);

	SetItemButtonQuality(lootFrame.IconHitBox, itemRarity, data.itemLink);

	if ( data.quantity > 1 ) then
		lootFrame.Count:Show();
		lootFrame.Count:SetText(data.quantity);
	else
		lootFrame.Count:Hide();
	end

	if (setID) then
		local setName = GetItemSetInfo(setID);
		lootFrame.ItemName:ClearAllPoints();
		lootFrame.ItemName:SetPoint("TOPLEFT", 56, -2);
		lootFrame.SetName:SetText(BOSS_BANNER_LOOT_SET:format(setName));
		lootFrame.SetName:Show();
		lootFrame.PlayerName:ClearAllPoints();
		lootFrame.PlayerName:SetPoint("TOPLEFT", lootFrame.SetName, "BOTTOMLEFT", 0, 0);
	else
		lootFrame.ItemName:ClearAllPoints();
		lootFrame.ItemName:SetPoint("TOPLEFT", 56, -7);
		lootFrame.SetName:Hide();
		lootFrame.PlayerName:ClearAllPoints();
		lootFrame.PlayerName:SetPoint("TOPLEFT", lootFrame.ItemName, "BOTTOMLEFT", 0, 0);
	end

	lootFrame.PlayerName:SetText(data.playerName);
	local classColor = RAID_CLASS_COLORS[data.className];
	lootFrame.PlayerName:SetTextColor(classColor.r, classColor.g, classColor.b);
	lootFrame.itemLink = data.itemLink;
end

function BossBanner_AnimBannerOut(self, entry)
	self.AnimOut:Play();
end

local BB_ANIMATION_CONTROL = {
	[BB_STATE_BANNER_IN] =	{ duration = 1.85,	onStartFunc = BossBanner_AnimBannerIn },
	[BB_STATE_KILL_HOLD] =	{ duration = 2,		onStartFunc = BossBanner_AnimKillHold },
	[BB_STATE_SWITCH] =		{ duration = nil,	onStartFunc = BossBanner_AnimSwitch },
	[BB_STATE_LOOT_EXPAND] ={ duration = nil,	onStartFunc = BossBanner_AnimLootExpand },
	[BB_STATE_LOOT_INSERT] ={ duration = nil,	onStartFunc = BossBanner_AnimLootInsert },
	[BB_STATE_BANNER_OUT] =	{ duration = 0.5,	onStartFunc = BossBanner_AnimBannerOut },
};

function BossBanner_BeginAnims(self, animState)
	BossBanner_SetAnimState(self, animState or BB_STATE_BANNER_IN);
end

function BossBanner_SetAnimState(self, animState)
	local entry = BB_ANIMATION_CONTROL[animState];
	if ( entry ) then
		local redirected = entry.onStartFunc(self, entry);
		if ( not redirected ) then
			self.animState = animState;
			self.animTimeLeft = entry.duration;
		end
	else
		self.animState = nil;
		self.animTimeLeft = nil;
	end
end

function BossBanner_OnUpdate(self, elapsed)
	if ( not self.animState ) then
		return;
	end
	self.animTimeLeft = self.animTimeLeft - elapsed;
	if ( self.animState == BB_STATE_LOOT_EXPAND ) then
		local newHeight = self.baseHeight + (self.lootShown * BB_EXPAND_HEIGHT) - (max(self.animTimeLeft, 0) / BB_EXPAND_TIME * BB_EXPAND_HEIGHT);
		self:SetHeight(newHeight);
	elseif ( self.animState == BB_STATE_LOOT_INSERT and self.showingTooltip ) then
		-- keep it at 2 seconds left
		self.animTimeLeft = 2;
	end
	if ( self.animTimeLeft <= 0 ) then
		BossBanner_SetAnimState(self, self.animState + 1);
		if ( not self.animTimeLeft ) then
			self.animState = nil;
		end
	end
end

function BossBanner_OnLoad(self)
	RegisterCVar("PraiseTheSun");
	self.PlayBanner = BossBanner_Play;
	self.StopBanner = BossBanner_Stop;
	self:RegisterEvent("BOSS_KILL");
	self:RegisterEvent("ENCOUNTER_LOOT_RECEIVED");
	self.pendingLoot = { };
	self.baseHeight = self:GetHeight();
end

function BossBanner_OnEvent(self, event, ...)
	if ( event == "BOSS_KILL" ) then
		wipe(self.pendingLoot);
		local encounterID, name = ...;
		TopBannerManager_Show(self, { encounterID = encounterID, name = name, mode = "KILL" });
	elseif ( event == "ENCOUNTER_LOOT_RECEIVED" ) then
		local encounterID, itemID, itemLink, quantity, playerName, className = ...;
		local _, instanceType = GetInstanceInfo();
		if ( encounterID == self.encounterID and (instanceType == "party" or instanceType == "raid") ) then
			-- add loot to pending list
			local data = { itemID = itemID, quantity = quantity, playerName = playerName, className = className, itemLink = itemLink };
			tinsert(self.pendingLoot, data);
			-- check state
			if ( self.animState == BB_STATE_LOOT_INSERT and self.lootShown < BB_MAX_LOOT ) then
				-- show it now
				BossBanner_SetAnimState(self, BB_STATE_LOOT_EXPAND);
			elseif ( not self.animState and self.lootShown == 0 ) then
				-- banner is not displaying and have not done loot for this encounter yet
				-- TODO: animate in kill banner
				TopBannerManager_Show(self, { encounterID = encounterID, name = nil, mode = "LOOT" });
			end
		end
	end
end

function BossBanner_OnLootItemEnter(self)
	-- no tooltip when banner is animating out
	if ( BossBanner.animState ~= BB_STATE_BANNER_OUT ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetHyperlink(self:GetParent().itemLink);
		GameTooltip:Show();
		BossBanner.showingTooltip = true;
	end
end

function BossBanner_OnLootItemLeave(self)
	GameTooltip:Hide();
	BossBanner.showingTooltip = false;
end

function BossBanner_Play(self, data)
	if ( data ) then
		if ( data.mode == "KILL" ) then
			if ( GetCVarBool("PraiseTheSun") ) then
				self.Title:SetText(BOSS_YOU_DEFEATED);
				self.SubTitle:Hide();
			else
				self.Title:SetText(data.name);
				self.SubTitle:Show();
			end
			self.Title:Show();
			self:Show();
			self.encounterID = data.encounterID;
			BossBanner_BeginAnims(self);
			PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED);
		elseif ( data.mode == "LOOT" ) then
			if(C_Loot.IsLegacyLootModeEnabled()) then
				return
			end
			self.BannerTop:SetAlpha(1);
			self.BannerBottom:SetAlpha(1);
			self.BannerMiddle:SetAlpha(1);
			self.RightFillagree:SetAlpha(1);
			self.LeftFillagree:SetAlpha(1);
			self.BottomFillagree:SetAlpha(1);
			self.SkullSpikes:SetAlpha(1);
			self.SkullCircle:SetAlpha(0);
			self.LootCircle:SetAlpha(1);
			self.Title:Hide();
			self.SubTitle:Hide();
			self:Show();
			BossBanner_BeginAnims(self, BB_STATE_LOOT_EXPAND);
			PlaySound(SOUNDKIT.UI_PERSONAL_LOOT_BANNER);
		end
	end
end

function BossBanner_Stop(self)
	self.AnimIn:Stop();
	self.AnimSwitch:Stop();
	self.AnimOut:Stop();
	self:Hide();
end

function BossBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner.animState = nil;
	banner:Hide();
	banner:SetHeight(banner.baseHeight);
	banner.BannerTop:SetAlpha(0);
	banner.BannerBottom:SetAlpha(0);
	banner.BannerMiddle:SetAlpha(0);
	banner.BottomFillagree:SetAlpha(0);
	banner.SkullSpikes:SetAlpha(0);
	banner.RightFillagree:SetAlpha(0);
	banner.LeftFillagree:SetAlpha(0);
	banner.Title:SetAlpha(0);
	banner.SubTitle:SetAlpha(0);
	banner.FlashBurst:SetAlpha(0);
	banner.FlashBurstLeft:SetAlpha(0);
	banner.FlashBurstCenter:SetAlpha(0);
	banner.RedFlash:SetAlpha(0);
	for i = 1, #banner.LootFrames do
		banner.LootFrames[i]:Hide();
	end
	TopBannerManager_BannerFinished();
end