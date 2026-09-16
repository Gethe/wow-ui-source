
RaidFrameSocialClassTypeMixin = {}

function RaidFrameSocialClassTypeMixin:OnLoad()
	self.Icon:SetAtlas(self.iconAtlas);
end

RaidFrameSocialAllAssistMixin = {};

function RaidFrameSocialAllAssistMixin:OnClick()
	PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	C_PartyInfo.SetEveryoneIsAssistant(self:GetChecked());
end

local RaidFrameSocialAllAssistButtonEvents =
{
	"GROUP_ROSTER_UPDATE",
	"PARTY_LEADER_CHANGED",
};

function RaidFrameSocialAllAssistMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RaidFrameSocialAllAssistButtonEvents);
	self:UpdateAvailable();
end

function RaidFrameSocialAllAssistMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RaidFrameSocialAllAssistButtonEvents);
end

function RaidFrameSocialAllAssistMixin:OnEvent(_event, ...)
	self:UpdateAvailable();
end

function RaidFrameSocialAllAssistMixin:UpdateAvailable()
	self:SetChecked(IsEveryoneAssistant());
	self:SetEnabled(UnitIsGroupLeader("player"));

	local fontColor = self:IsEnabled() and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self.AllText:SetText(fontColor:WrapTextInColorCode(ALL_ASSIST_LABEL_SHORT));
end

function RaidFrameSocialAllAssistMixin:OnEnter()
	self:ShowTooltip();
end

function RaidFrameSocialAllAssistMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, ALL_ASSIST_DESCRIPTION, wrapText);
	if not self:IsEnabled() then
		GameTooltip_AddErrorLine(GameTooltip, ALL_ASSIST_NOT_LEADER_ERROR, wrapText);
	end

	GameTooltip:Show();
end

function RaidFrameSocialAllAssistMixin:OnLeave()
	self:HideTooltip();
end

function RaidFrameSocialAllAssistMixin:HideTooltip()
	GameTooltip:Hide();
end

SocialRaidInfoMixin = {};

local RAID_INFO_BUTTON_EVENTS =
{
	"UPDATE_INSTANCE_INFO",
};

function SocialRaidInfoMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RAID_INFO_BUTTON_EVENTS);
	self:UpdateEnabledState();
end

function SocialRaidInfoMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RAID_INFO_BUTTON_EVENTS);
end

function SocialRaidInfoMixin:OnEvent(_event, ...)
	self:UpdateEnabledState();
end

function SocialRaidInfoMixin:UpdateEnabledState()
	local hasRaidLockoutData = GetNumSavedInstances() + GetNumSavedWorldBosses() > 0;
	self:SetEnabled(hasRaidLockoutData);
end

function SocialRaidInfoMixin:OnClick()
	self:SocialUIRequestToggleSideWindow(SocialUISideWindowType.RaidInfoFrame);
end

RaidFrameSocialGroupMixin = {};

function RaidFrameSocialGroupMixin:CreatePlayer(raidFrame, i, rank, role, name, level, class, fileName, subgroup, online, isDead)
	local playerFrame = self.playerPool:Acquire();
	table.insert(raidFrame.players, playerFrame);
	playerFrame.layoutIndex = #raidFrame.players;
	self.numPlayers = self.numPlayers + 1;

	local leaderAtlas = rank == 1 and "friends-icon-raidAssist" or "friends-icon-raidLead";
	playerFrame.LeaderIcon.Icon:SetAtlas(leaderAtlas, TextureKitConstants.UseAtlasSize);
	playerFrame.LeaderIcon:SetShown(rank > 0);
	playerFrame.LeaderIcon.tooltipText = (rank == 1) and RAID_ASSISTANT or RAID_LEADER;

	if role == "MAINTANK" then
		playerFrame.RoleIcon.Icon:SetAtlas("RaidFrame-Icon-MainTank");
		playerFrame.RoleIcon.tooltipText = MAIN_TANK;
		playerFrame.hasRoleIcon = true;
	elseif role == "MAINASSIST" then
		playerFrame.RoleIcon.Icon:SetAtlas("RaidFrame-Icon-MainAssist");
		playerFrame.RoleIcon.tooltipText = MAIN_ASSIST;
		playerFrame.hasRoleIcon = true;
	else
		playerFrame.RoleIcon.tooltipText = nil;
		playerFrame.hasRoleIcon = false;
	end

	playerFrame.CharacterName:SetText(name or UNKNOWN);
	local hasValidLevelText = level and (level > 0);
	playerFrame.CharacterLevel:SetText(hasValidLevelText and level or "");
	playerFrame.CharacterClass:SetText(class or "");

	local playerDisplayColor = NORMAL_FONT_COLOR;
	if not online then
		playerDisplayColor = GRAY_FONT_COLOR;
	elseif isDead then
		playerDisplayColor = RED_FONT_COLOR;
	else
		playerDisplayColor = RAID_CLASS_COLORS[fileName] or NORMAL_FONT_COLOR;
	end
	local r, g, b = playerDisplayColor:GetRGB();
	playerFrame.CharacterName:SetTextColor(r, g, b);
	playerFrame.CharacterLevel:SetTextColor(r, g, b);
	playerFrame.CharacterClass:SetTextColor(r, g, b);

	playerFrame.id = i;
	playerFrame.unit = "raid"..i;
	playerFrame.name = name;
	playerFrame.subgroup = subgroup;

	playerFrame.raidFrame = raidFrame;

	playerFrame:UpdateReadyCheck();

	playerFrame:Show();
end

RaidFrameSocialMixin = {};

local PLAYERS_PER_GROUP = 5;

local RAID_FRAME_EVENTS =
{
	"RAID_ROSTER_UPDATE",
	"GROUP_ROSTER_UPDATE",
	"PARTY_LEADER_CHANGED",
	"PARTY_LFG_RESTRICTED",
	"PLAYER_ROLES_ASSIGNED",
	"UNIT_CONNECTION",
	"UNIT_LEVEL",
	"READY_CHECK",
	"READY_CHECK_CONFIRM",
	"READY_CHECK_FINISHED",
};

function RaidFrameSocialMixin:OnLoad()
	self.groupPool = CreateFramePool("Frame", self.GroupsFrame, "RaidFrameSocialGroupTemplate");
	self.groups = {};

	self.ConvertToRaidButton:SetScript("OnClick", function()
		C_PartyInfo.ConvertToRaid();
	end);
end

function RaidFrameSocialMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RAID_FRAME_EVENTS);
	RequestRaidInfo();
	self:UpdateContents();
end

function RaidFrameSocialMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RAID_FRAME_EVENTS);
end

function RaidFrameSocialMixin:OnEvent(event, ...)
	if event == "RAID_ROSTER_UPDATE" then
		self:UpdateContents();
	elseif event == "GROUP_ROSTER_UPDATE" then
		self:UpdateContents();
	elseif event == "PLAYER_ROLES_ASSIGNED" then
		self:UpdateContents();
	elseif event == "PARTY_LEADER_CHANGED" then
		self:UpdateContents();
	elseif event == "PARTY_LFG_RESTRICTED" then
		self:UpdateContents();
	elseif event == "UNIT_LEVEL" then
		self:UpdateContents();
	elseif event == "UNIT_CONNECTION" then
		self:UpdateContents();
	elseif event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" then
		self:UpdateReadyChecks();
	elseif event == "READY_CHECK_FINISHED" then
		self:FinishReadyChecks();
	end
end

local function ResetRaidFramePlayerResetter(framePool, playerFrame)
	Pool_HideAndClearAnchors(framePool, playerFrame);

	local readyCheckFrame = playerFrame.ReadyCheck;
	readyCheckFrame:SetScript("OnUpdate", nil);
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Hide();

	playerFrame:RefreshDragVisual();
end

function RaidFrameSocialMixin:MakeGroupFactoryFunction()
	return function(index)
		local groupFrame = self.groupPool:Acquire();
		groupFrame.id = index;
		groupFrame.GroupNumberText:SetText(GROUP_NUMBER:format(index));

		if not groupFrame.playerPool then
			groupFrame.playerPool = CreateSecureFramePool("BUTTON", groupFrame.PlayersFrame, "RaidFrameSocialPlayerTemplate", ResetRaidFramePlayerResetter);
		end

		groupFrame.numPlayers = 0;

		table.insert(self.groups, groupFrame);
		groupFrame:Show();
		return groupFrame;
	end
end

function RaidFrameSocialMixin:UpdateContents()
	self.players = {};
	for _, group in ipairs(self.groups) do
		group.playerPool:ReleaseAll();
	end
	self.groupPool:ReleaseAll();
	self.groups = {};

	local isRaid = IsInRaid();
	for _, frame in ipairs(self.NoRaid) do
		frame:SetShown(not isRaid);
	end
	for _, frame in ipairs(self.YesRaid) do
		frame:SetShown(isRaid);
	end
	if not isRaid then
		local convertToRaid = true;
		local canConvertToRaid = C_PartyInfo.AllowedToDoPartyConversion(convertToRaid);
		self.ConvertToRaidButton:SetEnabled(canConvertToRaid);
		return;
	end

	local stride = 2;
	local paddingX = 5;
	local paddingY = 6;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);
	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.GroupsFrame, "TOPLEFT", 9, -7);
	AnchorUtil.GridLayoutFactoryByCount(self:MakeGroupFactoryFunction(), NUM_RAID_GROUPS, initialAnchor, layout);

	local numRaidMembers = GetNumGroupMembers();
	for i=1, MAX_RAID_MEMBERS do
		if i <= numRaidMembers then
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot, lfgRole = GetRaidRosterInfo(i);

			local group = self.groups[subgroup];
			local groupHasRoomForPlayer = group and (group.numPlayers < PLAYERS_PER_GROUP);
			if groupHasRoomForPlayer then
				group:CreatePlayer(self, i, rank, role, name, level, class, fileName, subgroup, online, isDead);
			end
		end
	end

	for _, group in ipairs(self.groups) do
		group.PlayersFrame:Layout();
	end

	local roleCounts = GetGroupMemberCountsForDisplay();
	self.TankFrame.Count:SetText(roleCounts.TANK);
	self.HealerFrame.Count:SetText(roleCounts.HEALER);
	self.DamagerFrame.Count:SetText(roleCounts.DAMAGER);
end

function RaidFrameSocialMixin:UpdateReadyChecks()
	for _, playerFrame in ipairs(self.players) do
		playerFrame:UpdateReadyCheck();
	end
end

function RaidFrameSocialMixin:FinishReadyChecks()
	for _, playerFrame in ipairs(self.players) do
		playerFrame:FinishReadyCheck();
	end
end

RaidFrameSocialPlayerMixin = {}

function RaidFrameSocialPlayerMixin:OnClick(button, down)
	if button == "RightButton" then
		if self.id and self.name then
			local contextData = { unit = self.unit, name = self.name };
			UnitPopup_OpenMenu("RAID", contextData);
		end
	else
		SecureUnitButton_OnClick(self, button, down);
	end
end

function RaidFrameSocialPlayerMixin:RefreshDragVisual()
	local isDragging = self:IsDragging();
	self.Background:SetShown(not isDragging);
	self.DragBackground:SetShown(isDragging);
end

function RaidFrameSocialPlayerMixin:UpdateReadyCheck()
	local status = GetReadyCheckStatus(self.unit);
	if not status then
		self.ReadyCheck:Hide();
		self.RoleIcon:SetShown(self.hasRoleIcon);
		return;
	end

	-- The ready check indicator shares the role icon's slot, so only one can show at a time
	self.RoleIcon:Hide();
	if status == "ready" then
		ReadyCheck_Confirm(self.ReadyCheck, 1);
	elseif status == "notready" then
		ReadyCheck_Confirm(self.ReadyCheck, 0);
	else -- "waiting"
		ReadyCheck_Start(self.ReadyCheck);
	end
end

function RaidFrameSocialPlayerMixin:FinishReadyCheck()
	if not self.ReadyCheck:IsShown() then
		return;
	end

	-- ReadyCheck_Finish plays a stay + fade animation, then UpdateReadyCheck restores the role icon
	local READY_CHECK_FADE_TIME = 1.5;
	ReadyCheck_Finish(self.ReadyCheck, DEFAULT_READY_CHECK_STAY_TIME, READY_CHECK_FADE_TIME, self.UpdateReadyCheck, self);
end

function RaidFrameSocialPlayerMixin:OnDragStart()
	if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
		return;
	end
	self:StartMoving();
	self:RefreshDragVisual();
end

function RaidFrameSocialPlayerMixin:OnDragStop()
	if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
		return;
	end

	self:StopMovingOrSizing();
	self:RefreshDragVisual();

	for _, player in ipairs(self.raidFrame.players) do
		if player:IsMouseOver() and self.id ~= player.id and self.subgroup ~= player.subgroup then
			SwapRaidSubgroup(self.id, player.id);
			return;
		end
	end

	for _, group in ipairs(self.raidFrame.groups) do
		if group:IsMouseOver() and self.subgroup ~= group.id and group.numPlayers < PLAYERS_PER_GROUP then
			SetRaidSubgroup(self.id, group.id);
			return;
		end
	end

	--if we got here it means we need to return to our original position. Easiest way to do that is to UpdateContents
	--has to be in a timer because we are releasing self
	C_Timer.After(0.1, function() self.raidFrame:UpdateContents(); end);
end

function RaidFrameSocialPlayerMixin:OnEnter()
	UnitFrame_UpdateTooltip(self);
end

function RaidFrameSocialPlayerMixin:OnLeave()
	GameTooltip:Hide();
end

RaidFrameSocialPlayerRoleIconMixin = {};

function RaidFrameSocialPlayerRoleIconMixin:OnEnter()
	self:TryShowTooltip();
end

function RaidFrameSocialPlayerRoleIconMixin:TryShowTooltip()
	if not self.tooltipText then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function RaidFrameSocialPlayerRoleIconMixin:OnLeave()
	self:HideTooltip();
end

function RaidFrameSocialPlayerRoleIconMixin:HideTooltip()
	GameTooltip:Hide();
end
