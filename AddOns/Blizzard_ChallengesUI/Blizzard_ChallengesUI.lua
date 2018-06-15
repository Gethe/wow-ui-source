local NUM_REWARDS_PER_MEDAL = 2;
local MAXIMUM_REWARDS_LEVEL = 15;
local MAX_PER_ROW = 9;

local function CreateFrames(self, array, num, template)
    while (#self[array] < num) do
		local frame = CreateFrame("Frame", nil, self, template);
	end
    
    for i = num + 1, #self[array] do
		self[array][i]:Hide();
	end
end
    
local function ReanchorFrames(frames, anchorPoint, anchor, relativePoint, width, spacing, distance)
    local num = #frames;
    local fullWidth = (width * num) + (spacing * (num - 1));
    local halfWidth = fullWidth / 2;
    
    -- First frame
    frames[1]:ClearAllPoints();
    frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, 5);

    -- n-rows after
    if (num > MAX_PER_ROW) then
		local calculateWidth = fullWidth / num; 
		for i = 2, #frames do
			frames[i]:SetWidth(calculateWidth); 
			frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", 0, 0);
		end
    end	
end

function ChallengesFrame_OnLoad(self)
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED");
    self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
    
    self.leadersAvailable = false;
	self.maps = C_ChallengeMode.GetMapTable();
end

function ChallengesFrame_OnEvent(self, event)
	if ( event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "CHALLENGE_MODE_LEADERS_UPDATE" or event =="CHALLENGE_MODE_MEMBER_INFO_UPDATED" or event =="CHALLENGE_MODE_COMPLETED") then
        if (event == "CHALLENGE_MODE_LEADERS_UPDATE") then
            self.leadersAvailable = true;
        end
        ChallengesFrame_Update(self);
	elseif (event == "CHALLENGE_MODE_RESET") then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
	end
end

function ChallengesFrame_OnShow(self)
    SetPortraitToTexture(PVEFrame.portrait, "Interface\\Icons\\achievement_bg_wineos_underxminutes");
	PVEFrame.TitleText:SetText(CHALLENGES);
	PVEFrame_HideLeftInset();
    
	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
    C_MythicPlus.RequestRewards();
    for i = 1, #self.maps do
        C_ChallengeMode.RequestLeaders(self.maps[i]);
    end
    ChallengesFrame_Update(self);
end

function ChallengesFrame_OnHide(self)
    PVEFrame_ShowLeftInset();
end

function ChallengesFrame_Update(self)
    local sortedMaps = {};
    local hasWeeklyRun = false;
    for i = 1, #self.maps do
		local _, level, _, _, members = C_MythicPlus.GetSeasonBestForMap(self.maps[i])
        if (not level) then
            level = 0;
        else
            hasWeeklyRun = true;
        end
        tinsert(sortedMaps, { id = self.maps[i], level = level});
    end
    
    table.sort(sortedMaps, function(a, b) return a.level > b.level end);
    
    local frameWidth, spacing, distance = 52, 2, 1;
    
    local num = #sortedMaps;

    CreateFrames(self, "DungeonIcons", num, "ChallengesDungeonIconFrameTemplate");
    ReanchorFrames(self.DungeonIcons, "BOTTOMLEFT", self, "BOTTOM", frameWidth, spacing, distance);
    
    for i = 1, #sortedMaps do
        local frame = self.DungeonIcons[i];
        frame:SetUp(sortedMaps[i], i == 1);
        frame:Show();
    end
    
    local name, _, _, _, backgroundTexture = C_ChallengeMode.GetMapUIInfo(sortedMaps[1].id);
    if (backgroundTexture ~= 0) then
        self.Background:SetTexture(backgroundTexture);
    end
	
    self.WeeklyInfo:SetUp(hasWeeklyRun, sortedMaps[1]);
	local weeklyChest = self.WeeklyInfo.Child.WeeklyChest;
	weeklyChest.ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel();
	if (weeklyChest.ownedKeystoneLevel and name ~= nil) then
		weeklyChest.difficulty, weeklyChest.rewardLevel, weeklyChest.nextRewardLevel = C_MythicPlus.GetWeeklyChestRewardLevel();
		weeklyChest.level = sortedMaps[1].level;
		if (C_MythicPlus.IsWeeklyRewardAvailable()) then 
			self.WeeklyInfo:HideAffixes();
			self.WeeklyInfo.Child.Label:Hide(); 
			self.WeeklyInfo.Child.RunStatus:SetPoint("TOP", self, "TOP", 0, -25);
			self.WeeklyInfo.Child.RunStatus:SetText(MYTHIC_PLUS_CLAIM_REWARD_MESSAGE); 
			weeklyChest.CollectChest.FinalKeyLevel:SetText(MYTHIC_PLUS_WEEKLY_CHEST_LEVEL:format(name, weeklyChest.level));  
			weeklyChest:SetupChest(weeklyChest.CollectChest); 		
		elseif (weeklyChest.level > 0) then 
			self.WeeklyInfo.Child.Label:Show(); 
			self.WeeklyInfo.Child.RunStatus:SetText(MYTHIC_PLUS_BEST_WEEKLY:format(name, weeklyChest.level)); 
			weeklyChest:SetupChest(weeklyChest.CompletedKeystoneChest); 
		elseif (weeklyChest.ownedKeystoneLevel) then
			self.WeeklyInfo.Child.Label:Show();
			weeklyChest:SetupChest(weeklyChest.MissingKeystoneChest); 
			self.WeeklyInfo.Child.RunStatus:SetText(MYTHIC_PLUS_INCOMPLETE_WEEKLY_KEYSTONE); 
		end
		weeklyChest:Show(); 
	else 
		weeklyChest:Hide(); 
		self.WeeklyInfo.Child.Label:Hide();
		self.WeeklyInfo:HideAffixes();
		self.WeeklyInfo.Child.RunStatus:SetText(MYTHIC_PLUS_MISSING_KEYSTONE_MESSAGE); 
	end
end

ChallengeModeWeeklyChestMixin = {}; 

function ChallengeModeWeeklyChestMixin:SetupChest(chestFrame)
	if (chestFrame == self.CollectChest) then 
		self.MissingKeystoneChest:Hide(); 
		self.CompletedKeystoneChest:Hide();
		
		chestFrame:Show();
		chestFrame.Level:SetText(self.level);
		
		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel); 
		
		if (self.level >= MAXIMUM_REWARDS_LEVEL) then 
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR:GetRGB());
		else
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	elseif (chestFrame == self.CompletedKeystoneChest) then 
		self.MissingKeystoneChest:Hide(); 
		self.CollectChest:Hide(); 
		
		chestFrame:Show(); 
		
		chestFrame.Level:SetText(self.level); 
		
		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel); 
		
		if (self.level >= MAXIMUM_REWARDS_LEVEL) then 
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_ABOVE_15;
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		else
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_BELOW_15:format(self.level + 1, self.nextRewardLevel); 
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	elseif (chestFrame == self.MissingKeystoneChest) then 
		self.CompletedKeystoneChest:Hide(); 
		self.CollectChest:Hide(); 
		chestFrame:Show();
		
		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.nextRewardLevel); 
	end
end

function ChallengeModeWeeklyChestMixin:OnEnter()
	GameTooltip:SetText(" ");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -15);
	if (self.level > 0) then 
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.level), HIGHLIGHT_FONT_COLOR);
	elseif (self.ownedKeystoneLevel) then
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.ownedKeystoneLevel), HIGHLIGHT_FONT_COLOR);
	end
	if (self.rewardTooltipText) then 
		GameTooltip:AddLine(self.rewardTooltipText); 
	end
	if (self.rewardTooltipText2) then 
		GameTooltip:AddLine(" "); 
		GameTooltip:AddLine(self.rewardTooltipText2); 
	end
    GameTooltip:Show();
end

ChallengesDungeonIconMixin = {};

function ChallengesDungeonIconMixin:SetUp(mapInfo, isFirst)
    self.mapID = mapInfo.id;
    
    local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.id);
    
    if (texture == 0) then
        texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes";
    end
    
    self.Icon:SetTexture(texture);
    self.Icon:SetDesaturated(mapInfo.level == 0);
    if (mapInfo.level > 0) then
        self.HighestLevel:SetText(mapInfo.level);
        if (isFirst) then
            self.HighestLevel:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        else
            self.HighestLevel:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        end
        self.HighestLevel:Show();
    else
        self.HighestLevel:Hide();
    end
end

function ChallengesDungeonIconMixin:OnEnter()
    local name = C_ChallengeMode.GetMapUIInfo(self.mapID);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(name, 1, 1, 1);

    local seasonBestDurationSec, seasonBestLevel, _, _, members = C_MythicPlus.GetSeasonBestForMap(self.mapID);
    if (seasonBestDurationSec and seasonBestLevel) then
        if (addSpacer) then
            GameTooltip:AddLine(" ");
        end
        GameTooltip:AddLine(MYTHIC_PLUS_SEASON_BEST);
        GameTooltip:AddLine(MYTHIC_PLUS_POWER_LEVEL:format(seasonBestLevel), 1, 1, 1);
        GameTooltip:AddLine(GetTimeStringFromSeconds(seasonBestDurationSec), 1, 1, 1);
		GameTooltip:AddLine(" ");
		for i, member in ipairs(members) do
			if (member.name) then
				local role = GetSpecializationRoleByID(member.specID);  
				local classInfo = C_CreatureInfo.GetClassInfo(member.classID); 
				local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
				local texture; 
				if (role == "TANK") then 
					texture = CreateAtlasMarkup("roleicon-tiny-tank"); 
				elseif (role == "DAMAGER") then
					texture = CreateAtlasMarkup("roleicon-tiny-dps"); 
				elseif (role == "HEALER") then
					texture = CreateAtlasMarkup("roleicon-tiny-healer"); 
				end
				GameTooltip:AddLine(MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, member.name), color.r, color.g, color.b); 
			end
		end
    end
    GameTooltip:Show();
end

ChallengesFrameWeeklyInfoMixin = {};

function ChallengesFrameWeeklyInfoMixin:SetUp(hasWeeklyRun, bestData)
	local affixes = C_MythicPlus.GetCurrentAffixes(); 		
	if (affixes) then 
		for i, affix in ipairs(affixes) do
			local frame = self.Child.Affixes[i];
			if (not frame) then
				frame = CreateFrame("Frame", nil, self.Child, "ChallengesKeystoneFrameAffixTemplate");
				frame:SetPoint("LEFT", self.Child.Affixes[i-1], "RIGHT", 10, 0);
			end
			frame:SetUp(affix);
		end
		self:Show();
	end 
end    

function ChallengesFrameWeeklyInfoMixin:HideAffixes()
	if(self.Child.Affixes) then 
		for i = 1, #self.Child.Affixes do 
			local frame = self.Child.Affixes[i];
			frame:Hide(); 
		end
	end
end
      
ChallengesKeystoneFrameMixin = {};

function ChallengesKeystoneFrameMixin:OnLoad()
	self.baseStates = {};
	
	local regions = {self:GetRegions()};
	for i = 1, #regions do
		local r = regions[i];
		self.baseStates[r] = {
			["shown"] = r:IsShown(),
			["alpha"] = r:GetAlpha(),
		};
	end
end

function ChallengesKeystoneFrameMixin:OnShow()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_OPEN);
    self:Reset();
end

function ChallengesKeystoneFrameMixin:OnHide()
    if (not self.startedChallengeMode) then
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_CLOSE);
    end
	C_ChallengeMode.CloseKeystoneFrame();
	C_ChallengeMode.ClearKeystone();
	self:Reset();
end

function ChallengesKeystoneFrameMixin:Reset()
	self.KeystoneSlot:Reset();
	self.PulseAnim:Stop();
	self.InsertedAnim:Stop();
	self.RunesLargeAnim:Stop();
	self.RunesLargeRotateAnim:Stop();
	self.RunesSmallAnim:Stop();
	self.WeeklyChest.CollectChestAnim:Stop();
	self.RunesSmallRotateAnim:Stop();
	self.StartButton:Disable();
	self.TimeLimit:Hide();
    self.DungeonName:Hide();

	for i = 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end

	for k, v in pairs(self.baseStates) do
		k:SetShown(v.shown);
		k:SetAlpha(v.alpha);
	end

    self.startedChallengeMode = nil;
end

function ChallengesKeystoneFrameMixin:OnMouseUp()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

function ChallengesKeystoneFrameMixin:ShowKeystoneFrame()	
	self:Show();
end

function ChallengesKeystoneFrameMixin:CreateAndPositionAffixes(num)
	local index = #self.Affixes + 1;
	local frameWidth, spacing, distance = 52, 4, -34;
	while (#self.Affixes < num) do
		local frame = CreateFrame("Frame", nil, self, "ChallengesKeystoneFrameAffixTemplate");
		local prev = self.Affixes[index - 1];
		frame:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
		index = index + 1;
	end
	-- Figure out where to place the leftmost spell
	local frame = self.Affixes[1];
	frame:ClearAllPoints();
	if (num % 2 == 1) then
		local x = (num - 1) / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), distance);
	else
		local x = num / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), distance);
	end
	
	for i = num + 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneSlotted()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_SOCKET);
	self.InsertedAnim:Play();
	self.RunesLargeAnim:Play();
	self.RunesSmallAnim:Play();
	self.RunesLargeRotateAnim:Play();
	self.RunesSmallRotateAnim:Play();
	self.WeeklyChest.CollectChestAnim:Play();
	self.InstructionBackground:Hide();
	self.Instructions:Hide();
	
	local mapID, affixes, powerLevel, charged = C_ChallengeMode.GetSlottedKeystoneInfo();
	local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID);

    self.DungeonName:SetText(name);
    self.DungeonName:Show();
    self.TimeLimit:SetText(SecondsToTime(timeLimit, false, true));
    self.TimeLimit:Show();

	self.PowerLevel:SetText(CHALLENGE_MODE_POWER_LEVEL:format(powerLevel));
	self.PowerLevel:Show();
	
	local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel);
	local highLevelKeyDamageHealthModifier = 0;
	
	if (powerLevel >= 3) then
		highLevelKeyDamageHealthModifier = 2; 
		self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
		self.Affixes[1]:SetUp({key = "dmg", pct = dmgPct});
		self.Affixes[2]:SetUp({key = "health", pct = healthPct});
	else 
		self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
	end 
	
	for i = 1, #affixes do
		self.Affixes[i+highLevelKeyDamageHealthModifier]:SetUp(affixes[i]);
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneRemoved()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_REMOVE_KEYSTONE);
	self:Reset();
	self.StartButton:Disable();
end

function ChallengesKeystoneFrameMixin:StartChallengeMode()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_ACTIVATE_BUTTON);
    C_ChallengeMode.StartChallengeMode();
    self.startedChallengeMode = true;
    self:Hide();
end

ChallengesKeystoneSlotMixin = {};

function ChallengesKeystoneSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED");
end

function ChallengesKeystoneSlotMixin:OnEvent(event, ...)
	if (event == "CHALLENGE_MODE_KEYSTONE_SLOTTED") then
		local itemID= ...;
		
		local texture = select(10, GetItemInfo(itemID));
		
		SetPortraitToTexture(self.Texture, texture);
		
		self:GetParent():OnKeystoneSlotted();
	end
end

function ChallengesKeystoneSlotMixin:OnEnter()
	if (C_ChallengeMode.HasSlottedKeystone()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		C_ChallengeMode.SetKeystoneTooltip();
		GameTooltip:Show();
	end
end

function ChallengesKeystoneSlotMixin:Reset()
	self.Texture:SetTexture(nil);
end

function ChallengesKeystoneSlotMixin:OnReceiveDrag()
	C_ChallengeMode.SlotKeystone();
end

function ChallengesKeystoneSlotMixin:OnDragStart()
	if (C_ChallengeMode.RemoveKeystone()) then
		self:GetParent():Reset();
	end
end

function ChallengesKeystoneSlotMixin:OnClick()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

ChallengesKeystoneFrameAffixMixin = {};

CHALLENGE_MODE_EXTRA_AFFIX_INFO = {
	["dmg"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE_DESCRIPTION,
		texture = "Interface\\Icons\\Ability_DualWield",
	},
	["health"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH_DESCRIPTION,
		texture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
	},
};

function ChallengesKeystoneFrameAffixMixin:OnEnter()
	if (self.affixID or self.info) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		
		local name, description;

		if (self.info) then
			local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[self.info.key];
			name = tbl.name;
			description = string.format(tbl.desc, self.info.pct);
		else
			name, description = C_ChallengeMode.GetAffixInfo(self.affixID);
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, 1, 1, 1, 1, true);
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function ChallengesKeystoneFrameAffixMixin:SetUp(affixInfo)
	if (type(affixInfo) == "table") then
		local info = affixInfo;

		SetPortraitToTexture(self.Portrait, CHALLENGE_MODE_EXTRA_AFFIX_INFO[info.key].texture);
	    
        if (info.pct > 999) then
            self.Percent:SetFontObject("SystemFont_Shadow_Med1_Outline");
        else
            self.Percent:SetFontObject("SystemFont_Shadow_Large_Outline");
        end
                
		self.Percent:SetText(("+%d%%"):format(info.pct));
		self.Percent:Show();

		self.info = info;
	else
		local affixID = affixInfo;

		local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);

        SetPortraitToTexture(self.Portrait, filedataid);

		self.Percent:Hide();

		self.affixID = affixID;
	end

	self:Show();
end

ChallengeModeCompleteBannerMixin = {};

function ChallengeModeCompleteBannerMixin:OnLoad()
    self.timeToHold = 5;
    self.unitTokens = { "player", "party1", "party2", "party3", "party4" };
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
end

function ChallengeModeCompleteBannerMixin:OnEvent(event, ...)
    if (event == "CHALLENGE_MODE_COMPLETED") then
        local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo();
    
        TopBannerManager_Show(self, { mapID = mapID, level = level, time = time, onTime = onTime, keystoneUpgradeLevels = keystoneUpgradeLevels });
    end
end

function ChallengeModeCompleteBannerMixin:PlayBanner(data)
    local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(data.mapID);
    
    self.Title:SetText(name);
    
    self.Level:SetText(data.level);
    local lvlStr = tostring(data.level);
    if (tonumber(lvlStr:sub(1,1)) == 1) then
        self.Level:SetPoint("CENTER", self.SkullCircle, -4, 0);
    else
        self.Level:SetPoint("CENTER", self.SkullCircle, 0, 0);
    end
        
	self.Level:Show();
	
    if (data.onTime) then
        self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_BEAT_TIMER);
        self.DescriptionLineTwo:SetFormattedText(CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, data.keystoneUpgradeLevels);
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
    else
        self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_TIME_EXPIRED);
        self.DescriptionLineTwo:SetText(CHALLENGE_MODE_COMPLETE_TRY_AGAIN);
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);
    end
    
    local sortedUnitTokens = self:GetSortedPartyMembers();
    
    self:Show();
    self.AnimIn:Play();
    
    self:CreateAndPositionPartyMembers(#sortedUnitTokens);
	for i = 1, #sortedUnitTokens do
        self.PartyMembers[i]:SetUp(sortedUnitTokens[i]);
    end
    
    
    C_Timer.After(self.timeToHold, function()
        self:PerformAnimOut();
    end);
end

function ChallengeModeCompleteBannerMixin:StopBanner()
    self.AnimIn:Stop();
    self:Hide();
end

function ChallengeModeCompleteBannerMixin:GetSortedPartyMembers()
    local unitRoleMap = {};
    
    local sortedUnitTokens = {};
    
    for i = 1, #self.unitTokens do
        if (UnitExists(self.unitTokens[i])) then
            local role = UnitGroupRolesAssigned(self.unitTokens[i]);
            if (role == "DAMAGER" or role == "NONE") then
                if (not unitRoleMap[role]) then
                    unitRoleMap[role] = {};
                end
                tinsert(unitRoleMap[role], self.unitTokens[i]);
            else
                unitRoleMap[role] = self.unitTokens[i];
            end
        end
    end
    
    if (unitRoleMap["TANK"]) then
        tinsert(sortedUnitTokens, unitRoleMap["TANK"]);
    end
    
    if (unitRoleMap["HEALER"]) then
        tinsert(sortedUnitTokens, unitRoleMap["HEALER"]);
    end
    
    if (unitRoleMap["DAMAGER"]) then
        for i = 1, #unitRoleMap["DAMAGER"] do
            tinsert(sortedUnitTokens, unitRoleMap["DAMAGER"][i]);
        end
    end
     
    if (unitRoleMap["NONE"]) then
        for i = 1, #unitRoleMap["NONE"] do
            tinsert(sortedUnitTokens, unitRoleMap["NONE"][i]);
        end
    end
    
    return sortedUnitTokens;
end

function ChallengeModeCompleteBannerMixin:CreateAndPositionPartyMembers(num)
	local frameWidth, spacing, distance = 61, 22, -100;
    
    CreateFrames(self, "PartyMembers", num, "ChallengeModeBannerPartyMemberTemplate");
    ReanchorFrames(self.PartyMembers, "TOPLEFT", self.Title, "TOP", frameWidth, spacing, distance);
end

function ChallengeModeCompleteBannerMixin:PerformAnimOut()
    self.AnimOut:Play()
    for i = 1, #self.PartyMembers do
        if (self.PartyMembers[i]:IsShown()) then
            self.PartyMembers[i].AnimOut:Play();
        end
    end
end

function ChallengeModeCompleteBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner:Hide();
	banner.BannerTop:SetAlpha(0);
	banner.BannerBottom:SetAlpha(0);
	banner.BannerMiddle:SetAlpha(0);
	banner.BottomFillagree:SetAlpha(0);
	banner.RightFillagree:SetAlpha(0);
	banner.LeftFillagree:SetAlpha(0);
	banner.Title:SetAlpha(0);
	TopBannerManager_BannerFinished();
end

ChallengeModeBannerPartyMemberMixin = {};

function ChallengeModeBannerPartyMemberMixin:SetUp(unitToken)
    SetPortraitTexture(self.Portrait, unitToken);
    
    local name = UnitName(unitToken);
    local _, classFileName = UnitClass(unitToken);
    
    local classColorStr = RAID_CLASS_COLORS[classFileName].colorStr;
    self.Name:SetText(("|c%s%s|r"):format(classColorStr, name));
    
    local role = UnitGroupRolesAssigned(unitToken);
    if ( role == "TANK" or role == "HEALER" or role == "DAMAGER" ) then
		self.RoleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
		self.RoleIcon:Show();
	else
		self.RoleIcon:Hide();
	end
    
    self:SetAlpha(0);
    self:Show();
    self.AnimIn:Play();
end
