
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

			-- Skip rolls that are in a weird state due to multiple item instance win protection
			local skipRoll = self.dropInfo.winner and not roll.isWinner and roll.roll and roll.roll > self.dropInfo.winner.roll;

			if not skipRoll and ((roll.state <= topRollState and roll.state < Enum.EncounterLootDropRollState.NoRoll) or (roll.isSelf and roll.state ~= Enum.EncounterLootDropRollState.NoRoll)) then
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

		if waitingOnAny and not self.dropInfo.winner then
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
	if not dropInfo then
		return;
	end

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
			self.PendingRollInfo.WaitDot1:SetPoint("RIGHT", self.PendingRollInfo.CurrentWinnerText, "LEFT", -4, -1);
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

LootHistoryElementAnimationMixin = {};

function LootHistoryElementAnimationMixin:InitAndStartAnim(dropInfo)
	self.Item.IconBorder:SetSize(self.Item:GetWidth(), self.Item:GetHeight());

	self:Init(dropInfo);
	self:PlayPerfectRollAnim();
end

function LootHistoryElementAnimationMixin:PlayPerfectRollAnim()
	self:Show();

	PlaySound(SOUNDKIT.UI_NEED_ROLL_ONE_HUNDRED);
	self.PerfectRollFrame.Anim:Play();
	self.PerfectRollTopFrame.Anim:Play();
end

function LootHistoryElementAnimationMixin:StopPerfectRollAnim()
	self:Hide();

	self.PerfectRollFrame.Anim:Stop();
	self.PerfectRollTopFrame.Anim:Stop();
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
	"LOOT_HISTORY_CLEAR_HISTORY",
};

local LootHistoryFrameWhenShownEvents =
{
	"LOOT_HISTORY_UPDATE_ENCOUNTER",
	"LOOT_HISTORY_ONE_HUNDRED_ROLL",
};

function LootHistoryFrameMixin:OnLoad()
	local totalWidth = 239;
	local dropDownEdgeWidth = 16;
	self.EncounterDropdown:SetWidth(totalWidth - dropDownEdgeWidth);

	FrameUtil.RegisterFrameForEvents(self, LootHistoryFrameAlwaysListenEvents);
	self:InitRegions();
	self:InitScrollBox();

	tooltipLinePool = CreateFramePool("FRAME", nil, "LootHistoryRollTooltipLineTemplate");
end

function LootHistoryFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LootHistoryFrameWhenShownEvents);
	self.PerfectAnimFrame.PerfectRollFrame.Anim:SetScript("OnFinished", GenerateClosure(self.CleanUpPerfectRollAnim, self));

	self.perfectRollItemQueue = {};

	self:SetupEncounterDropdown();

	if not self:GetSelectedEncounterID() then
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

	self.ScrollBox:RemoveDataProvider();
	self.selectedEncounterID = nil;
end

function LootHistoryFrameMixin:OnEvent(event, ...)
	if event == "LOOT_HISTORY_GO_TO_ENCOUNTER" then
		local encounterID = ...;
		self:Show();
		self:OpenToEncounter(encounterID);
	elseif event == "LOOT_HISTORY_UPDATE_ENCOUNTER" then
		local encounterID = ...;
		if encounterID == self:GetSelectedEncounterID() then
			self:DoFullRefresh();
		end
	elseif event == "LOOT_HISTORY_CLEAR_HISTORY" then
		self:SetInfoShown(false);
		self:SetScript("OnUpdate", nil);
		self.selectedEncounterID = nil;
		self.encounterInfo = nil;
	elseif event == "LOOT_HISTORY_ONE_HUNDRED_ROLL" then
		local encounterID, lootListID = ...;

		if encounterID == self:GetSelectedEncounterID() then
			self:AddPerfectAnimToQueue(encounterID, lootListID);
			self:DoFullRefresh();
		end
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
		frame:SetDrop(self:GetSelectedEncounterID(), elementData.lootListID);
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

function LootHistoryFrameMixin:SetupEncounterDropdown()
	self.EncounterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LOOT_ENCOUNTER");

		local function IsSelected(encounterID)
			return self:GetSelectedEncounterID() == encounterID;
		end

		local function SetSelected(encounterID)
			self:OpenToEncounterInternal(encounterID);
		end

		for _, encounter in ipairs(C_LootHistory.GetAllEncounterInfos()) do
			rootDescription:CreateRadio(encounter.encounterName, IsSelected, SetSelected, encounter.encounterID);
		end
	end);
end

function LootHistoryFrameMixin:SetInfoShown(shown)
	self.ScrollBox:SetShown(shown);
	self.ScrollBar:SetShown(shown);
	self.EncounterDropdown:SetShown(shown);
	self.Timer:SetShown(shown);

	self.NoInfoString:SetShown(not shown);
end

function LootHistoryFrameMixin:GetSelectedEncounterID()
	return self.selectedEncounterID;
end

function LootHistoryFrameMixin:OpenToEncounterInternal(encounterID)
	self:SetInfoShown(true);
	
	if encounterID ~= self:GetSelectedEncounterID() then
		self.ScrollBox:ScrollToBegin();
		self.PerfectAnimFrame:StopPerfectRollAnim();
		self.perfectRollItemQueue = {};
	end

	self.selectedEncounterID = encounterID;

	self:DoFullRefresh();
end

function LootHistoryFrameMixin:OpenToEncounter(encounterID)
	self:OpenToEncounterInternal(encounterID);
	self.EncounterDropdown:GenerateMenu();
end

-- Set dynamically
function LootHistoryFrameMixin:OnUpdate()
	self:UpdateTimer();
end

function LootHistoryFrameMixin:UpdateTimer()
	local allRollsFinished = true;
	local drops = C_LootHistory.GetSortedDropsForEncounter(self:GetSelectedEncounterID());
	for _, drop in ipairs(drops) do
		if not (drop.winner or drop.allPassed) then
			allRollsFinished = false;
			break;
		end
	end

	local elapsed = C_LootHistory.GetLootHistoryTime() - self.encounterInfo.startTime;
	if allRollsFinished or elapsed >= self.encounterInfo.duration or self.encounterInfo.duration == 0 then
		self.Timer.Fill:Hide();
		self:SetScript("OnUpdate", nil);
	else
		self.Timer.Fill:Show();

		local fullFillWidth = 234;
		local pctLeft = 1.0 - (elapsed / self.encounterInfo.duration);
		self.Timer.Fill:SetWidth(fullFillWidth * pctLeft);
	end
end

function LootHistoryFrameMixin:DoFullRefresh()
	local selectedEncounterID = self:GetSelectedEncounterID();
	self.encounterInfo = C_LootHistory.GetInfoForEncounter(selectedEncounterID);
	self:SetScript("OnUpdate", self.OnUpdate);

	local dataProvider = CreateDataProvider();
	local drops = C_LootHistory.GetSortedDropsForEncounter(selectedEncounterID);
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

		dataProvider:Insert({encounterID = selectedEncounterID, lootListID = dropInfo.lootListID});
	end
	local scrollPercentage = self.ScrollBox:GetScrollPercentage();
	self.ScrollBox:SetDataProvider(dataProvider);
	self.ScrollBox:SetScrollPercentage(scrollPercentage);

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

	if self.perfectRollItemQueue[1] then
		local itemData = dataProvider:FindElementDataByPredicate(function(itemData)
			return self.perfectRollItemQueue[1].loot == itemData.lootListID and self.perfectRollItemQueue[1].encounter == itemData.encounterID;
		end);

		if itemData then
			self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
			self.ScrollBox:ScrollToElementData(itemData, ScrollBoxConstants.AlignCenter);

			local itemFrame = self.ScrollBox:FindFrame(itemData);
			local currDropInfo = drops[self.ScrollBox:FindElementDataIndex(itemData)];

			self:UpdatePerfectAnimQueue(itemData, itemFrame, currDropInfo);
		end
	else
		self.ScrollBox:SetScrollAllowed(true);
	end
end

function LootHistoryFrameMixin:UpdatePerfectAnimQueue(itemData, itemFrame, dropInfo)
	local currPerfectAnimItem = self.perfectRollItemQueue[1];

	if not currPerfectAnimItem.animStarted then
		self.ScrollBox:SetScrollAllowed(false);

		currPerfectAnimItem.animStarted = true;
		self.PerfectAnimFrame:InitAndStartAnim(dropInfo);
	end

	self.PerfectAnimFrame:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 0, 0);
	self.PerfectAnimFrame:SetPoint("BOTTOMRIGHT", itemFrame, "BOTTOMRIGHT", 0, 0);
end

function LootHistoryFrameMixin:AddPerfectAnimToQueue(encounterID, lootListID)
	table.insert(self.perfectRollItemQueue, {encounter = encounterID, loot = lootListID });
end

function LootHistoryFrameMixin:RemoveItemFromQueue()
	self.ScrollBox:SetScrollAllowed(true);

	if not self.perfectRollItemQueue[1] then
		return;
	end

	table.remove(self.perfectRollItemQueue, 1);
end

function LootHistoryFrameMixin:CleanUpPerfectRollAnim()
	self:RemoveItemFromQueue();

	self.PerfectAnimFrame:Hide();
	if self:IsShown() then
		self:DoFullRefresh();
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