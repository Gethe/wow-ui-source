MenuConstants = 
{
	VerticalLinearDirection = 1,
	VerticalGridDirection = 2,
	HorizontalGridDirection = 3,
	AutoCalculateColumns = nil,
	ElementPollFrequencySeconds = .2,
	PrintSecure = false;
};

--[[
Response values are optional returns from description handlers to inform the menu
structure to remain open, reinitialize all the children, or only close the leafmost menu.
It is common for menus with checkboxes or radio options to return Refresh in order for
the children to visually update.
--]]
MenuResponse = 
{
	Open = 1, -- Menu remains open and unchanged
	Refresh = 2, -- All frames in the menu are reinitialized
	Close = 3, -- Parent menus remain open but this menu closes
	CloseAll = 4, -- All menus close
};


--[[
Passed to element handlers to inform which input is responsible for invoking the element handler,
which is relevant in some specialized use cases. See Blizzard_CharacterCustomize.lua.
Can be used to
]]--
MenuInputContext =
{
	None = 1,
	MouseButton = 2,
	MouseWheel = 3,
};