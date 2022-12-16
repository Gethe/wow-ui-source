local NumActionBarButtons = 12;
local NumSpecialActionButtons = 10;
local NumBagSlots = 3;

local ActionBars = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
}

local MicroButtons = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"CollectionsMicroButton",
	"EJMicroButton",
	"MainMenuMicroButton",
	"QuickJoinToastButton",
}

ActionButtonUtil = {};

function ActionButtonUtil.ShowAllActionButtonGrids()
	MainMenuBar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.HideAllActionButtonGrids()
	MainMenuBar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.SetAllQuickKeybindButtonHighlights(show)
	for _, actionBar in ipairs(ActionBars) do
		for i = 1, NumActionBarButtons do
			_G[actionBar..i]:DoModeChange(show);
		end
	end
	for i = 1, NumSpecialActionButtons do
		PetActionBar.actionButtons[i]:DoModeChange(show);
		StanceBar.actionButtons[i]:DoModeChange(show);
	end
	ExtraActionButton1:DoModeChange(show);
	MainMenuBar.ActionBarPageNumber.UpButton:DoModeChange(show);
	MainMenuBar.ActionBarPageNumber.DownButton:DoModeChange(show);

	for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		bagButton:DoModeChange(show);
	end

	for _, microButton in ipairs(MicroButtons) do
		_G[microButton]:DoModeChange(show);
	end
end

function ActionButtonUtil.ShowAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(true);
end

function ActionButtonUtil.HideAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(false);
end