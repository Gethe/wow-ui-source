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
	for i = 1, NumActionBarButtons do
		_G["ActionButton"..i]:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	end
	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT, true);
end

function ActionButtonUtil.HideAllActionButtonGrids()
	for i = 1, NumActionBarButtons do
		_G["ActionButton"..i]:HideGrid(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	end
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
	ActionBarUpButton.QuickKeybindHighlightTexture:SetShown(show);
	ActionBarDownButton.QuickKeybindHighlightTexture:SetShown(show);
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