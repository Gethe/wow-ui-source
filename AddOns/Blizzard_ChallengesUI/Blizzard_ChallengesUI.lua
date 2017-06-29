local NUM_REWARDS_PER_MEDAL = 2;
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
    local numButtons = math.min(MAX_PER_ROW, num);
    local fullWidth = (width * numButtons) + (spacing * (numButtons - 1));
    local halfWidth = fullWidth / 2;
    
    local numRows = math.floor((num + MAX_PER_ROW - 1) / MAX_PER_ROW) - 1;
    local fullDistance = numRows * frames[1]:GetHeight() + (numRows + 1) * distance;
    
    -- First frame
    frames[1]:ClearAllPoints();
    frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, fullDistance);

    -- first row
    for i = 2, math.min(MAX_PER_ROW, #frames) do
        frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
    end

    -- n-rows after
    if (num > MAX_PER_ROW) then
        local currentExtraRow = 0;
        local finished = false;
        repeat
            local setFirst = false;
            for i = (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + 1, (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + MAX_PER_ROW do
                if (not frames[i]) then
                    finished = true;
                    break;
                end
                if (not setFirst) then
                    frames[i]:SetPoint("TOPLEFT", frames[i - (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow))], "BOTTOMLEFT", 0, -distance);
                    setFirst = true;
                else
                    frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
                end
            end
            currentExtraRow = currentExtraRow + 1;
        until finished;
    end
end

function ChallengesFrame_OnLoad(self)
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
    self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");
    
    self.leadersAvailable = false;
	self.maps = C_ChallengeMode.GetMapTable();
end

function ChallengesFrame_OnEvent(self, event)
	if ( event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "CHALLENGE_MODE_LEADERS_UPDATE" ) then
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
    
	C_ChallengeMode.RequestMapInfo();
    C_ChallengeMode.RequestRewards();
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
        local _, _, level, affixes = C_ChallengeMode.GetMapPlayerStats(self.maps[i]);
        if (not level) then
            level = 0;
        else
            hasWeeklyRun = true;
        end
        tinsert(sortedMaps, { id = self.maps[i], level = level, affixes = affixes });
    end
    
    table.sort(sortedMaps, function(a, b) return a.level > b.level end);
    
    local frameWidth, spacing, distance = 52, 2, 8;
    
    local num = #sortedMaps;

    CreateFrames(self, "DungeonIcons", num, "ChallengesDungeonIconFrameTemplate");
    ReanchorFrames(self.DungeonIcons, "BOTTOMLEFT", self, "BOTTOM", frameWidth, spacing, distance);
    
    for i = 1, #sortedMaps do
        local frame = self.DungeonIcons[i];
        
        frame:SetUp(sortedMaps[i], i == 1);
        frame:Show();
    end
    
    local _, _, _, _, backgroundTexture = C_ChallengeMode.GetMapInfo(sortedMaps[1].id);
    if (backgroundTexture ~= 0) then
        self.Background:SetTexture(backgroundTexture);
    end
    
    self.WeeklyBest:SetUp(hasWeeklyRun, sortedMaps[1]);
    
    if (self.leadersAvailable) then
        local leaders = C_ChallengeMode.GetGuildLeaders();
        if (leaders and #leaders > 0) then
            self.GuildBest:SetUp(leaders);
            self.GuildBest:Show();
        else
            self.GuildBest:Hide();
        end
    end
    
    self.WeeklyChest:SetShown(C_ChallengeMode.IsWeeklyRewardAvailable());
end

ChallengesDungeonIconMixin = {};

function ChallengesDungeonIconMixin:SetUp(mapInfo, isFirst)
    self.mapID = mapInfo.id;
    
    local _, _, _, texture = C_ChallengeMode.GetMapInfo(mapInfo.id);
    
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
    local name = C_ChallengeMode.GetMapInfo(self.mapID);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(name, 1, 1, 1);
    local _, weeklyBestTime, weeklyBestLevel = C_ChallengeMode.GetMapPlayerStats(self.mapID);
    local addSpacer = false;
    if (weeklyBestTime and weeklyBestLevel) then
        GameTooltip:AddLine(CHALLENGE_MODE_THIS_WEEK);
        GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(weeklyBestLevel), 1, 1, 1);
        GameTooltip:AddLine(GetTimeStringFromSeconds(weeklyBestTime / 1000), 1, 1, 1);
        addSpacer = true;
    end
    
    local recentBestTime, recentBestLevel = C_ChallengeMode.GetRecentBestForMap(self.mapID);
    if (recentBestTime and recentBestLevel) then
        if (addSpacer) then
            GameTooltip:AddLine(" ");
        end
        GameTooltip:AddLine(CHALLENGE_MODE_RECENT_BEST);
        GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(recentBestLevel), 1, 1, 1);
        GameTooltip:AddLine(GetTimeStringFromSeconds(recentBestTime / 1000), 1, 1, 1);
    end
    GameTooltip:Show();
end

ChallengesGuildBestMixin = {};

function ChallengesGuildBestMixin:SetUp(leaderInfo)
    self.leaderInfo = leaderInfo;
    
    local str = CHALLENGE_MODE_GUILD_BEST_LINE;
    if (leaderInfo.isYou) then
        str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU;
    end
    
    local classColorStr = RAID_CLASS_COLORS[leaderInfo.classFileName].colorStr;
    
    self.CharacterName:SetText(str:format(classColorStr, leaderInfo.name));
    self.Level:SetText(leaderInfo.keystoneLevel);
end

function ChallengesGuildBestMixin:OnEnter()
    local leaderInfo = self.leaderInfo;
    
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    local name = C_ChallengeMode.GetMapInfo(leaderInfo.mapChallengeModeID);
    GameTooltip:SetText(name, 1, 1, 1);
    GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(leaderInfo.keystoneLevel));
    for i = 1, #leaderInfo.members do
        local classColorStr = RAID_CLASS_COLORS[leaderInfo.members[i].classFileName].colorStr;
        GameTooltip:AddLine(CHALLENGE_MODE_GUILD_BEST_LINE:format(classColorStr,leaderInfo.members[i].name));
    end
    GameTooltip:Show();
end

ChallengesFrameGuildBestMixin = {};

function ChallengesFrameGuildBestMixin:SetUp(leaders)
    for i = 1, #leaders do
        local frame = self.GuildBests[i];
        if (not frame) then
            frame = CreateFrame("Frame", nil, self, "ChallengesGuildBestTemplate");
            frame:SetPoint("TOP", self.GuildBests[i-1], "BOTTOM");
        end
        frame:SetUp(leaders[i]);
        frame:Show();
    end
    for i = #leaders + 1, #self.GuildBests do
        self.GuildBests[i]:Hide();
    end
end

ChallengesFrameWeeklyBestMixin = {};

function ChallengesFrameWeeklyBestMixin:SetUp(hasWeeklyRun, bestData)
    if (hasWeeklyRun) then
        self.Child.NoRunsThisWeek:Hide();
        local lvlStr = tostring(bestData.level);
        if (tonumber(lvlStr:sub(1,1)) == 1) then
            self.Child.Level:SetPoint("CENTER", self.Child.Star, -4, -5);
        else
            self.Child.Level:SetPoint("CENTER", self.Child.Star, 0, -5);
        end
        self.Child.Level:SetText(bestData.level);
        local name = C_ChallengeMode.GetMapInfo(bestData.id);
        self.Child.DungeonName:SetText(name);
        self.Child.DungeonName:Show();
        local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(bestData.level);

        for i = 1, #bestData.affixes + 2 do
            local frame = self.Child.Affixes[i];
            if (not frame) then
                frame = CreateFrame("Frame", nil, self.Child, "ChallengesKeystoneFrameAffixTemplate");
                frame:SetPoint("LEFT", self.Child.Affixes[i-1], "RIGHT", 10, 0);
            end
            if (i == 1) then
                frame:SetUp({key = "dmg", pct = dmgPct});
            elseif(i == 2) then
                frame:SetUp({key = "health", pct = healthPct});
            else
                frame:SetUp(bestData.affixes[i-2]);
            end
        end
        for i = 3 + #bestData.affixes, #self.Child.Affixes do
            self.Child.Affixes[i]:Hide();
        end
     else
        self.Child.Level:SetText(0);
        self.Child.DungeonName:Hide();
        for i = 1, #self.Child.Affixes do
            self.Child.Affixes[i]:Hide();
        end
        self.Child.NoRunsThisWeek:Show();
     end
     self:Show();
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
	self.InstructionBackground:Hide();
	self.Instructions:Hide();
	
	local mapID, affixes, powerLevel, charged = C_ChallengeMode.GetSlottedKeystoneInfo();
	local name, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID);

    self.DungeonName:SetText(name);
    self.DungeonName:Show();
    self.TimeLimit:SetText(SecondsToTime(timeLimit, false, true));
    self.TimeLimit:Show();

	self.PowerLevel:SetText(CHALLENGE_MODE_POWER_LEVEL:format(powerLevel));
	self.PowerLevel:Show();
	
	local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel);
	
	self:CreateAndPositionAffixes(2 + #affixes);
	
	self.Affixes[1]:SetUp({key = "dmg", pct = dmgPct});
	self.Affixes[2]:SetUp({key = "health", pct = healthPct});
	
	for i = 1, #affixes do
		self.Affixes[i+2]:SetUp(affixes[i]);
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
    local name, _, timeLimit = C_ChallengeMode.GetMapInfo(data.mapID);
    
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
