-------------------------------------------------------
----------Constants
-------------------------------------------------------
UIPanelWindows["LFGParentFrame"] = { area = "left", pushable = 7, xoffset = -16, yoffset = 12, bottomClampOverride = 140+12, width = 353, height = 424, whileDead = 1 };

LFGVANILLA_SETTING_MODERN_STYLE = false;
LFGVANILLA_SETTING_SHOW_ON_MINIMAP = true;
LFGVANILLA_SETTING_BROWSE_SHOW_COLLAPSIBLE_CATEGORIES = false;

local LFGLISTING_DUNGEON_CATEGORY_ID = 2;
local LFGLISTING_RAID_CATEGORY_ID = 114;
local LFGLISTING_QUEST_CATEGORY_ID = 116;
local LFGLISTING_BATTLEGROUND_CATEGORY_ID = 118;
local LFGLISTING_CUSTOM_CATEGORY_ID = 120;

LFGLISTING_CATEGORY_TEXTURES = {
	[LFGLISTING_DUNGEON_CATEGORY_ID] = "groupfinder-button-dungeons", -- Dungeons
	[LFGLISTING_RAID_CATEGORY_ID] = "groupfinder-button-raids-classic", -- Raids
	[LFGLISTING_QUEST_CATEGORY_ID] = "groupfinder-button-questing", -- Quests & Zones
	[LFGLISTING_BATTLEGROUND_CATEGORY_ID] = "groupfinder-button-battlegrounds", -- PvP
	[LFGLISTING_CUSTOM_CATEGORY_ID] = "groupfinder-button-custom-pve", -- Custom
};
LFGLISTING_CATEGORY_TEXTURE_DEFAULT = "groupfinder-button-questing";
