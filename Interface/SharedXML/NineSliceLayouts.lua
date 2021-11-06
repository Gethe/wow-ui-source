---------------
--NOTE - Please do not change this section without talking to Dan
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);
end
---------------

NineSliceLayouts =
{
	Dialog =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
		TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
		TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
	};

	ChatBubble =
	{
		TopLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopLeft", },
		TopRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomRight", },
		TopEdge = { atlas = "_ChatBubble-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_ChatBubble-NineSlice-EdgeBottom", },
		LeftEdge = { atlas = "!ChatBubble-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!ChatBubble-NineSlice-EdgeRight", },
		Center = { atlas = "ChatBubble-NineSlice-Center", },
	};

	GMChatRequest =
	{
		["TopRightCorner"] = { atlas = "GMChat-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "GMChat-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "GMChat-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "GMChat-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_GMChat-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_GMChat-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!GMChat-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!GMChat-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -4, y = 4, x1 = 4, y1 = -4 },
	};

	TooltipDefaultLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -2, y = 2, x1 = 2, y1 = -2 },
	};

	TooltipGluesLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeTop", x = 0, y = -1, x1 = 0, y1 = -1 },
		["BottomEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Glues-NineSlice-Center", x = -8, y = 10, x1 = 8, y1 = -7, },
	};

	TooltipMixedLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeTop", x = 0, y = -1, x1 = 0, y1 = -1 },
		["BottomEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -8, y = 10, x1 = 8, y1 = -7, },
	};

	UniqueCornersLayout =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
		["Center"] = { atlas = "%s-NineSlice-Center" },
	};

	IdenticalCornersLayout =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true,},
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true,},
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
		["Center"] = { atlas = "%s-NineSlice-Center" },
	};
};