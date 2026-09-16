STATUS_BAR_CONTAINER_WIDTH = 1192;
STATUS_BAR_CONTAINER_HEIGHT = 17;
STATUS_BAR_SIZE_ADJUSTMENT = 3;
STATUS_BAR_NUM_SEGMENTS = 20;

STATUS_BAR_MANAGER_WIDTH = STATUS_BAR_CONTAINER_WIDTH;
STATUS_BAR_MANAGER_HEIGHT = STATUS_BAR_CONTAINER_HEIGHT;

EXHAUSTION_TICK_OFFSET_Y = 0;

-- Gamepad overrides
STATUS_BAR_CONTAINER_WIDTH_GAMEPAD = STATUS_BAR_CONTAINER_WIDTH / 2;
STATUS_BAR_MANAGER_WIDTH_GAMEPAD = STATUS_BAR_MANAGER_WIDTH / 2;
STATUS_BAR_NUM_SEGMENTS_GAMEPAD = STATUS_BAR_NUM_SEGMENTS / 2;


function ShouldRestedXpBarDisplayWhenOverflowing()
	return true;
end

StatusTrackingBarInfo.BarPriorities = {
	[StatusTrackingBarInfo.BarsEnum.Experience] = 0,
	[StatusTrackingBarInfo.BarsEnum.Azerite] = 1,
	[StatusTrackingBarInfo.BarsEnum.Reputation] = 2,
	[StatusTrackingBarInfo.BarsEnum.Honor] = 3,
	[StatusTrackingBarInfo.BarsEnum.Artifact] = 4,
	[StatusTrackingBarInfo.BarsEnum.HouseFavor] = 5,
}
