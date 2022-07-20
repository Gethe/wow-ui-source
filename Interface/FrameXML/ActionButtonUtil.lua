local NumActionBarButtons = 12;
local NumSpecialActionButtons = 10;
local NumBagSlots = 3;

local ActionBars = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
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
			_G[actionBar..i].QuickKeybindHighlightTexture:SetShown(show);
		end
	end
	for i = 1, NumSpecialActionButtons do
		_G["PetActionButton"..i].QuickKeybindHighlightTexture:SetShown(show);
		_G["StanceButton"..i].QuickKeybindHighlightTexture:SetShown(show);
	end
	ExtraActionButton1.QuickKeybindHighlightTexture:SetShown(show);
	MainMenuBar.ActionBarPageNumber.UpButton.QuickKeybindHighlightTexture:SetShown(show);
	MainMenuBar.ActionBarPageNumber.DownButton.QuickKeybindHighlightTexture:SetShown(show);
	for i = 0, NumBagSlots do
		_G["CharacterBag"..i.."Slot"].QuickKeybindHighlightTexture:SetShown(show);
	end
	MainMenuBarBackpackButton.QuickKeybindHighlightTexture:SetShown(show);
	for _, microButton in ipairs(MicroButtons) do
		_G[microButton].QuickKeybindHighlightTexture:SetShown(show);
	end
end

function ActionButtonUtil.ShowAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(true);
end

function ActionButtonUtil.HideAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(false);
end