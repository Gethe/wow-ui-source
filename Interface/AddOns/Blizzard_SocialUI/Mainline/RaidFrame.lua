
RaidFrameSocialClassTypeMixin = {}

function RaidFrameSocialClassTypeMixin:OnLoad()
	self.Icon:SetAtlas(self.iconAtlas);
end

RaidFrameSocialAllAssistMixin = {};

function RaidFrameSocialAllAssistMixin:OnClick()
	C_PartyInfo.SetEveryoneIsAssistant(self:GetChecked());
end

SocialRaidInfoMixin = {};

function SocialRaidInfoMixin:OnClick()
	self:SocialUIRequestToggleSideWindow(SocialUISideWindowType.RaidInfo);
end

RaidFrameSocialGroupMixin = {};

function RaidFrameSocialGroupMixin:CreatePlayer(raidFrame, i, rank, name, level, class, fileName, subgroup)
	local playerFrame = self.playerPool:Acquire();
	table.insert(raidFrame.players, playerFrame);
	playerFrame.layoutIndex = #raidFrame.players;
	self.numPlayers = self.numPlayers + 1;

	playerFrame.LeaderIcon:SetShown(rank > 0);
	playerFrame.LeaderIcon:SetAtlas(rank == 1 and "friends-icon-raidAssist" or "friends-icon-raidLead");

	playerFrame.CharacterName:SetText(name);
	playerFrame.CharacterLevel:SetText(level);
	playerFrame.CharacterClass:SetText(class);

	local r, g, b = GetClassColor(fileName);
	playerFrame.CharacterName:SetTextColor(r, g, b);
	playerFrame.CharacterLevel:SetTextColor(r, g, b);
	playerFrame.CharacterClass:SetTextColor(r, g, b);

	playerFrame.id = i;
	playerFrame.unit = "raid"..i;
	playerFrame.name = name;
	playerFrame.subgroup = subgroup;

	playerFrame.raidFrame = raidFrame;

	local readyCheckStatus = GetReadyCheckStatus(playerFrame.unit);

	if readyCheckStatus then
		if readyCheckStatus == "ready" then
			ReadyCheck_Confirm(playerFrame.ReadyCheck, 1);
		elseif readyCheckStatus == "notready" then
			ReadyCheck_Confirm(playerFrame.ReadyCheck, 0);
		else -- "waiting"
			ReadyCheck_Start(playerFrame.ReadyCheck);
		end
	else
		playerFrame.ReadyCheck:Hide();
	end

	playerFrame:Show();
end

RaidFrameSocialMixin = {};

local PLAYERS_PER_GROUP = 5;

local RAID_FRAME_EVENTS =
{
	"RAID_ROSTER_UPDATE",
	"GROUP_ROSTER_UPDATE",
	"UNIT_LEVEL",
	"READY_CHECK";
	"READY_CHECK_CONFIRM";
	"READY_CHECK_FINISHED";
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
	elseif event == "UNIT_LEVEL" then
		self:UpdateContents();
	elseif event == "READY_CHECK" then
		self:UpdateContents();
	elseif event == "READY_CHECK_CONFIRM" then
		self:UpdateContents();
	elseif event == "READY_CHECK_FINISHED" then
		self:UpdateContents();
	end
end

function RaidFrameSocialMixin:MakeGroupFactoryFunction()
	return function(index)
		local groupFrame = self.groupPool:Acquire();
		groupFrame.id = index;
		groupFrame.GroupNumberText:SetText(GROUP_NUMBER:format(index));

		groupFrame.playerPool = CreateFramePool("BUTTON", groupFrame.PlayersFrame, "RaidFrameSocialPlayerTemplate");

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
	local paddingY = 5;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);
	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.GroupsFrame, "TOPLEFT", 10, -10);
	AnchorUtil.GridLayoutFactoryByCount(self:MakeGroupFactoryFunction(), NUM_RAID_GROUPS, initialAnchor, layout);

	local roleCounts = {
		DAMAGER = 0,
		HEALER = 0,
		TANK = 0,
	}

	local numRaidMembers = GetNumGroupMembers();
	for i=1, MAX_RAID_MEMBERS do
		if i <= numRaidMembers then
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot, lfgRole = GetRaidRosterInfo(i);

			roleCounts[lfgRole] = roleCounts[lfgRole] + 1;

			self.groups[subgroup]:CreatePlayer(self, i, rank, name, level, class, fileName, subgroup);
		end
	end

	for _, group in ipairs(self.groups) do
		group.PlayersFrame:Layout();
	end

	self.TankFrame.Count:SetText(roleCounts.TANK);
	self.HealerFrame.Count:SetText(roleCounts.HEALER);
	self.DamagerFrame.Count:SetText(roleCounts.DAMAGER);
end

RaidFrameSocialPlayerMixin = {}

function RaidFrameSocialPlayerMixin:OnClick(button, down)
	if button == "RightButton" then
		RaidGroupButton_OpenMenu(self);
	else
		SecureUnitButton_OnClick(self, button, down);
	end
end

function RaidFrameSocialPlayerMixin:OnDragStart()
	if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
		return;
	end
	self:StartMoving();
end

function RaidFrameSocialPlayerMixin:OnDragStop()
	if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then
		return;
	end

	self:StopMovingOrSizing();

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
