CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "ReputationFrame", "TokenFrame" };

characterFrameDisplayInfo = {
	["Default"] = {
		title = UnitPVPName("player"),
		titleColor = HIGHLIGHT_FONT_COLOR,
		width = PANEL_DEFAULT_WIDTH, -- Dynamically updated by CharacterFrameMixin:Expand()/CharacterFrameMixin:Collapse();
	},
	["ReputationFrame"] = {
		title = REPUTATION,
		titleColor = NORMAL_FONT_COLOR,
		width = 400,
	},
	["TokenFrame"] = {
		title = CURRENCY,
		titleColor = NORMAL_FONT_COLOR,
		width = 400,
	},
};

NUM_CHARACTERFRAME_TABS = 3;
