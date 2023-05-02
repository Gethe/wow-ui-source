
-- Instantiated when GroupLootHistoryFrame is loaded
local tooltipLinePool = nil;

LootHistoryElementMixin = {};

local LootHistoryElementEvents =
{
	"LOOT_HISTORY_UPDATE_DROP",
};

function LootHistoryElementMixin:OnLoad()
	self.Item.IconBorder:SetSize(self.Item:GetWidth(), self.Item:GetHeight());
end

function LootHistoryElementMixin:OnEvent(event, ...)
	if event == "LOOT_HISTORY_UPDATE_DROP" then
		local encounterID, lootListID = ...;
		if encounterID == self.encounterID and lootListID == self.lootListID then
			local dropInfo = C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID);
			self:Init(dropInfo);
		end
	end
end

function LootHistoryElementMixin:OnEnter()
	self:SetTooltip();
end

function LootHistoryElementMixin:OnLeave()
	GameTooltip:Hide();
	tooltipLinePool:ReleaseAll();
end

function LootHistoryElementMixin:SetTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -6);

	local item = Item:CreateFromItemLink(self.dropInfo.itemHyperlink);
	local itemQuality = item:GetItemQuality();
	local qualityColor = ITEM_QUALITY_COLORS[itemQuality].color;
	GameTooltip_SetTitle(GameTooltip, qualityColor:WrapTextInColorCode(item:GetItemName()));

	if self.dropInfo.allPassed then
		local allPassedFrame = tooltipLinePool:Acquire();
		allPassedFrame:SetToAllPassed();
		GameTooltip_InsertFrame(GameTooltip, allPassedFrame);
	else
		local topRollState = nil;
		local anyRollNumbers = false;
		local anyRollFrames = false;
		local waitingOnAny = false;
		local waitingOnText = LOOT_HISTORY_WAITING_ON;
		for _, roll in ipairs(self.dropInfo.rollInfos) do
			if not topRollState then
				topRollState = roll.state;
			end

			if roll.roll then
				anyRollNumbers = true; -- If there are any roll numbers, they will be at the top of the roll list
			end

			if (roll.state <= topRollState and roll.state < Enum.EncounterLootDropRollState.NoRoll) or (roll.isSelf and roll.state ~= Enum.EncounterLootDropRollState.NoRoll) then
				local newFrame = tooltipLinePool:Acquire();
				newFrame:Init(roll, anyRollNumbers);
				GameTooltip_InsertFrame(GameTooltip, newFrame);
				anyRollFrames = true;
			end

			if roll.state == Enum.EncounterLootDropRollState.NoRoll then
				local classColor = RAID_CLASS_COLORS[roll.playerClass];
				local playerName = classColor:WrapTextInColorCode(roll.playerName);
				if waitingOnAny then
					waitingOnText = waitingOnText..LOOT_HISTORY_PLAYER_DELIMITER..playerName;
				else
					waitingOnText = waitingOnText..playerName;
					waitingOnAny = true;
				end
			end
		end

		if waitingOnAny then
			if anyRollFrames then
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
			end
			local wrap = true;
			GameTooltip_AddNormalLine(GameTooltip, waitingOnText, wrap);
		end
	end

	GameTooltip:Show();
end

function LootHistoryElementMixin:Init(dropInfo)
	self.dropInfo = dropInfo;

	local item = Item:CreateFromItemLink(dropInfo.itemHyperlink);
	local itemQuality = item:GetItemQuality();
	local qualityColor = ITEM_QUALITY_COLORS[itemQuality].color;

	self.ItemName:SetText(item:GetItemName());
	self.ItemName:SetVertexColor(qualityColor:GetRGB());
	SetItemButtonQuality(self.Item, itemQuality, dropInfo.itemHyperlink);
	self.Item.icon:SetTexture(item:GetItemIcon());

	if dropInfo.allPassed then
		self.AllPassedInfo:Show();
		self.WinningRollInfo:Hide();
		self.PendingRollInfo:Hide();
		self.PendingRollInfo.WaitAnim:Stop();
	elseif dropInfo.winner then
		self.WinningRollInfo:Show();
		self.AllPassedInfo:Hide();
		self.PendingRollInfo:Hide();
		self.PendingRollInfo.WaitAnim:Stop();

		local classColor = RAID_CLASS_COLORS[dropInfo.winner.playerClass];
		self.WinningRollInfo.WinningRoll:SetText(classColor:WrapTextInColorCode(dropInfo.winner.playerName));
	else
		self.PendingRollInfo:Show();
		self.WinningRollInfo:Hide();
		self.AllPassedInfo:Hide();
		self.PendingRollInfo.WaitAnim:Restart();

		if dropInfo.currentLeader then
			local leaderName = nil
			if dropInfo.isTied then
				leaderName = LOOT_HISTORY_ROLL_TIE;
			else
				leaderName = dropInfo.currentLeader.playerName;
			end

			self.PendingRollInfo.CurrentWinnerText:SetText(LOOT_HISTORY_CURRENT_WINNER:format(leaderName, dropInfo.currentLeader.roll));
		else
			self.PendingRollInfo.CurrentWinnerText:SetText(nil);
			self.PendingRollInfo.WaitDot1:SetPoint("RIGHT", self.PendingRollInfo.CurrentWinnerText, "LEFT", -3, -1);
		end
	end

	local playerRollAtlas = nil;
	if dropInfo.playerRollState == Enum.EncounterLootDropRollState.NeedMainSpec or dropInfo.playerRollState == Enum.EncounterLootDropRollState.NeedOffSpec then
		playerRollAtlas = [[lootroll-rollicon-yourolled-need]];
	elseif dropInfo.playerRollState == Enum.EncounterLootDropRollState.Transmog then
		playerRollAtlas = [[lootroll-rollicon-yourolled-transmog]];
	elseif dropInfo.playerRollState == Enum.EncounterLootDropRollState.Greed then
		playerRollAtlas = [[lootroll-rollicon-yourolled-greed]];
	end
	if playerRollAtlas then
		self.PlayerRoll:Show();
		self.PlayerRoll.PlayerRollIcon:SetAtlas(playerRollAtlas, TextureKitConstants.IgnoreAtlasSize);
	else
		self.PlayerRoll:Hide();
	end

	self.Item:SetScript("OnClick", function(button, buttonName, down)
		if IsModifiedClick() then
			HandleModifiedItemClick(dropInfo.itemHyperlink);
		end
	end);

	self.Item:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.Item, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(dropInfo.itemHyperlink);
	end);

	self.Item:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	if self:IsMouseMotionFocus() then
		self:SetTooltip();
	end
end

function LootHistoryElementMixin:SetDrop(encounterID, lootListID)
	self.encounterID = encounterID;
	self.lootListID = lootListID;

	local dropInfo = C_LootHistory.GetSortedInfoForDrop(self.encounterID, self.lootListID);
	self:Init(dropInfo);
end

function LootHistoryElementMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LootHistoryElementEvents);
end

function LootHistoryElementMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LootHistoryElementEvents);
end


LootHistoryRollTooltipLineMixin = {};

function LootHistoryRollTooltipLineMixin:Init(rollInfo, anyRollNumbers)
	local rollAtlas;
	if rollInfo.state == Enum.EncounterLootDropRollState.NeedMainSpec or rollInfo.state == Enum.EncounterLootDropRollState.NeedOffSpec then
		rollAtlas = [[lootroll-icon-need]];
	elseif rollInfo.state == Enum.EncounterLootDropRollState.Transmog then
		rollAtlas = [[lootroll-icon-transmog]];
	elseif rollInfo.state == Enum.EncounterLootDropRollState.Greed then
		rollAtlas = [[lootroll-icon-greed]];
	elseif rollInfo.state == Enum.EncounterLootDropRollState.Pass then
		rollAtlas = [[lootroll-icon-pass]];
	end
	self.RollIcon:SetAtlas(rollAtlas, TextureKitConstants.IgnoreAtlasSize);

	if rollInfo.roll then
		self.RollText:Show();
		self.RollText:SetText(rollInfo.roll);
	else
		self.RollText:Hide();
	end

	self.PlayerName:ClearAllPoints();
	if anyRollNumbers then
		self.PlayerName:SetPoint("LEFT", self.RollIcon, "RIGHT", 33, 0);
	else
		self.PlayerName:SetPoint("LEFT", self.RollIcon, "RIGHT", 5, 0);
	end

	local classColor = RAID_CLASS_COLORS[rollInfo.playerClass];
	local playerName = classColor:WrapTextInColorCode(rollInfo.playerName);
	if rollInfo.state == Enum.EncounterLootDropRollState.NeedOffSpec then
		playerName = LOOT_HISTORY_OFF_SPEC_FMT:format(playerName);
	end
	self.PlayerName:SetText(playerName);

	if rollInfo.isWinner then
		self.Check:ClearAllPoints();
		self.Check:SetPoint("LEFT", self.PlayerName, "RIGHT", 2, 0);
	end
	self.Check:SetShown(rollInfo.isWinner);

	self:Layout();
end

function LootHistoryRollTooltipLineMixin:SetToAllPassed()
	self.RollIcon:SetAtlas([[lootroll-icon-pass]], TextureKitConstants.IgnoreAtlasSize);
	self.RollText:Hide();
	self.PlayerName:ClearAllPoints();
	self.PlayerName:SetPoint("LEFT", self.RollIcon, "RIGHT", 5, 0);
	self.PlayerName:SetText(RED_FONT_COLOR:WrapTextInColorCode(LOOT_HISTORY_ALL_PASSED));
	self.Check:ClearAllPoints();
	self.Check:SetPoint("LEFT", self.PlayerName, "RIGHT", 2, 0);
	self.Check:Show();
	self:Layout();
end


LootHistoryFrameMixin = {};

local LootHistoryFrameAlwaysListenEvents =
{
	"LOOT_HISTORY_GO_TO_ENCOUNTER",
};

local LootHistoryFrameWhenShownEvents =
{
	"LOOT_HISTORY_UPDATE_ENCOUNTER",
	"LOOT_HISTORY_CLEAR_HISTORY",
};

function LootHistoryFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, LootHistoryFrameAlwaysListenEvents);
	self:InitRegions();
	self:InitScrollBox();

	tooltipLinePool = CreateFramePool("FRAME", nil, "LootHistoryRollTooltipLineTemplate");
end

function LootHistoryFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LootHistoryFrameWhenShownEvents);

	self:SetupEncounterDropDown();

	if not self.selectedEncounterID then
		local encounters = C_LootHistory.GetAllEncounterInfos();
		local firstEncounter = encounters[1];
		if firstEncounter then
			self:OpenToEncounter(firstEncounter.encounterID);
		else
			self:SetInfoShown(false);
		end
	end
end

function LootHistoryFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LootHistoryFrameWhenShownEvents);

	self.ScrollBox:ClearDataProvider();
	self.selectedEncounterID = nil;
end

function LootHistoryFrameMixin:OnEvent(event, ...)
	if event == "LOOT_HISTORY_GO_TO_ENCOUNTER" then
		local encounterID = ...;
		self:Show();
		self:OpenToEncounter(encounterID);
	elseif event == "LOOT_HISTORY_UPDATE_ENCOUNTER" then
		local encounterID = ...;
		if encounterID == self.selectedEncounterID then
			self:DoFullRefresh();
		end
	elseif event == "LOOT_HISTORY_CLEAR_HISTORY" then
		self:SetInfoShown(false);
	end
end

function LootHistoryFrameMixin:OnDragStart()
	self:StartMoving();
end

function LootHistoryFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

local ScrollBoxPad = 7;
local ScrollBoxSpacing = 8;
function LootHistoryFrameMixin:InitScrollBox()
	local view = CreateScrollBoxListLinearView(ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxSpacing);

	local function Initializer(frame, elementData)
		frame:SetDrop(self.selectedEncounterID, elementData.lootListID);
	end

	view:SetElementFactory(function(factory, elementData)
		if elementData.lootListID then
			factory("LootHistoryElementTemplate", Initializer);
		elseif elementData.isPassedHeader then
			factory("LootHistoryPassedHeaderTemplate");
		elseif elementData.isPassedSpacer then
			factory("LootHistoryPassedHeaderPaddingTemplate");
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if elementData.lootListID then
			return 58;
		elseif elementData.isPassedHeader then
			return 12;
		elseif elementData.isPassedSpacer then
			return 14;
		end
	end);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function LootHistoryFrameMixin:InitRegions()
	self.ResizeButton:SetScript("OnMouseDown", function()
		local alwaysStartFromMouse = true;
		self:StartSizing("BOTTOM", alwaysStartFromMouse);
	end);
	self.ResizeButton:SetScript("OnMouseUp", function()
		self:StopMovingOrSizing();
	end);

	self.TitleContainer.TitleText:SetText(LOOT_ROLLS);
end

function LootHistoryFrameMixin:SetupEncounterDropDown()
	local function Initializer(dropDown, level)
		local function DropDownButtonClick(button)
			self:OpenToEncounter(button.value);
		end
	
		local encounters = C_LootHistory.GetAllEncounterInfos();

		for _, encounter in ipairs(encounters) do
			local info = UIDropDownMenu_CreateInfo();
			info.fontObject = GameFontHighlightSmall;
			info.text = encounter.encounterName;
			info.minWidth = 236;
			info.value = encounter.encounterID;
			info.func = DropDownButtonClick;
			UIDropDownMenu_AddButton(info);
		end
	end

	local totalWidth = 239;
	local dropDownEdgeWidth = 16;
	UIDropDownMenu_SetWidth(self.EncounterDropDown, totalWidth - dropDownEdgeWidth);
	UIDropDownMenu_JustifyText(self.EncounterDropDown, "RIGHT");
	UIDropDownMenu_Initialize(self.EncounterDropDown, Initializer);
end

function LootHistoryFrameMixin:SetInfoShown(shown)
	self.ScrollBox:SetShown(shown);
	self.ScrollBar:SetShown(shown);
	self.EncounterDropDown:SetShown(shown);
	self.Timer:SetShown(shown);

	self.NoInfoString:SetShown(not shown);
end

function LootHistoryFrameMixin:OpenToEncounter(encounterID)
	self:SetInfoShown(true);
	self.selectedEncounterID = encounterID;
	self:SetupEncounterDropDown();
	UIDropDownMenu_SetSelectedValue(self.EncounterDropDown, encounterID);
	self:DoFullRefresh();
end

-- Set dynamically
function LootHistoryFrameMixin:OnUpdate()
	self:UpdateTimer();
end

function LootHistoryFrameMixin:UpdateTimer()
	local allRollsFinished = true;
	local drops = C_LootHistory.GetSortedDropsForEncounter(self.selectedEncounterID);
	for _, drop in ipairs(drops) do
		if not (drop.winner or drop.allPassed) then
			allRollsFinished = false;
			break;
		end
	end

	local elapsed = C_LootHistory.GetLootHistoryTime() - self.encounterInfo.startTime;
	if allRollsFinished or elapsed >= self.encounterInfo.duration or self.encounterInfo.duration == 0 then
		self.Timer:Hide();
		self:SetScript("OnUpdate", nil);
	else
		self.Timer:Show();

		local fullFillWidth = 234;
		local pctLeft = 1.0 - (elapsed / self.encounterInfo.duration);
		self.Timer.Fill:SetWidth(fullFillWidth * pctLeft);
	end
end

function LootHistoryFrameMixin:DoFullRefresh()
	self.encounterInfo = C_LootHistory.GetInfoForEncounter(self.selectedEncounterID);
	self:SetScript("OnUpdate", self.OnUpdate);

	local dataProvider = CreateDataProvider();
	local drops = C_LootHistory.GetSortedDropsForEncounter(self.selectedEncounterID);
	local anyNotPassed = false;
	local anyRolledOn = false;
	local passedHeaderAdded = false;
	for _, dropInfo in ipairs(drops) do
		if dropInfo.playerRollState == Enum.EncounterLootDropRollState.Pass and not passedHeaderAdded then
			if anyNotPassed then
				dataProvider:Insert({isPassedSpacer = true});
			end
			dataProvider:Insert({isPassedHeader = true});
			passedHeaderAdded = true;
		elseif dropInfo.playerRollState ~= Enum.EncounterLootDropRollState.Pass then
			anyNotPassed = true;
		end

		if dropInfo.playerRollState < Enum.EncounterLootDropRollState.NoRoll then
			anyRolledOn = true;
		end

		dataProvider:Insert({encounterID = self.selectedEncounterID, lootListID = dropInfo.lootListID});
	end
	self.ScrollBox:SetDataProvider(dataProvider);

	if anyRolledOn and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LOOT_HISTORY_ROLL) then
		local rolledHelpTipInfo =
		{
			text = LOOT_HISTORY_ROLL_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeTop,
			alignment = HelpTip.Alignment.Left,
			offsetX = -40,
			offsetY = -125,
			acknowledgeOnHide = true,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_LOOT_HISTORY_ROLL,
		};
		HelpTip:Show(self, rolledHelpTipInfo, self);
	end
end

function ToggleLootHistoryFrame()
	GroupLootHistoryFrame:SetShown(not GroupLootHistoryFrame:IsShown());
end

function SetLootHistoryFrameToEncounter(encounterID)
	if GroupLootHistoryFrame.selectedEncounterID == encounterID then
		return;
	end

	local encounters = C_LootHistory.GetAllEncounterInfos();
	local encounterFound = false;
	for _, encounter in ipairs(encounters) do
		if encounter.encounterID == encounterID then
			encounterFound = true;
			break;
		end
	end

	if encounterFound then
		GroupLootHistoryFrame:OpenToEncounter(encounterID);
		GroupLootHistoryFrame:Show();
	end
end