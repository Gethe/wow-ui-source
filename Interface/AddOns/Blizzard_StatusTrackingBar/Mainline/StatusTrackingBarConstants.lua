STATUS_BAR_CONTAINER_WIDTH = 571;
STATUS_BAR_CONTAINER_HEIGHT = 17;
STATUS_BAR_SIZE_ADJUSTMENT = 6;
STATUS_BAR_NUM_SEGMENTS = 1;

STATUS_BAR_MANAGER_WIDTH = STATUS_BAR_CONTAINER_WIDTH;
STATUS_BAR_MANAGER_HEIGHT = STATUS_BAR_CONTAINER_HEIGHT * 2;

EXHAUSTION_TICK_OFFSET_Y = 2;


function ShouldRestedXpBarDisplayWhenOverflowing()
	return false;
end

StatusTrackingBarInfo.BarPriorities = {
	[StatusTrackingBarInfo.BarsEnum.Azerite] = 0,
	[StatusTrackingBarInfo.BarsEnum.Reputation] = 1,
	[StatusTrackingBarInfo.BarsEnum.Honor] = 2,
	[StatusTrackingBarInfo.BarsEnum.Artifact] = 3,
	[StatusTrackingBarInfo.BarsEnum.Experience] = 4,
	[StatusTrackingBarInfo.BarsEnum.HouseFavor] = 5,
}
