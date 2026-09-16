
INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectGuildFrame" };

INSPECT_MODE_TAB_FRAMES = {
	[1] = "PaperDollFrame",
	[2] = "GuildFrame",
};

INSPECTPAPERDOLLFRAME_SLOTS = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"InspectBackSlot",
	"InspectChestSlot",
	"InspectShirtSlot",
	"InspectTabardSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
	"InspectRangedSlot",
};

function InspectFrame_GetGuildTabIndex()
	return 2;
end

function InspectGuildFrame_ShowRealm()
	return false;
end

function InspectGuildFrame_ShowPoints()
	return false;
end
