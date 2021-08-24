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

	Import("ipairs");
	Import("GetFinalNameFromTextureKit");
	Import("C_Texture");
end
---------------

--[[
	Nine-slice utility for creating themed background frames without rewriting a lot of boilerplate code.
	There are some utilities to help with anchoring, and others to create a border and theme it from scratch.
	NineSliceUtil.ApplyLayout makes use of a layout table, and is probably what most setups will use.

	What the layout table should look like:
	- A table of tables, where each inner table describes a corner, edge, or center of the nine-slice frame.

	- Inner table keys should exactly match the nine-slice API for setting up the various pieces (TitleCase matters here), and will also be used as the name of the parentKey on the container frame.

	- e.g. Layout = { TopLeftCorner = { ... }, LeftEdge = { ... }, Center = { ... }

	- Global attributes:
		- mirrorLayout: The nine slice atlases only exist for topLeftCorner, topEdge, leftEdge.  Create the rest of the pieces from those assets.

	- Key-values in each inner table:
		- Required:
			atlas: the atlas for this piece
		- Optional:
			- layer: texture draw layer, defaults to "BORDER"
			- subLevel: texture sublevel, defaults to the same default as the CreateTexture API.
			- point: which point on the piece you want to anchor from, defaults to whatever is appropriate for the piece (e.g. TopLeftCorner = TOPLEFT)
			- relativePoint: which point on the container frame you want to anchor to, same default as point.
			- x, y: the offsets for the piece, defaults to SetPoint API default.
			- x1, y1: the second offsets (ONLY for the edge and center pieces), defaults to SetPoint API default.

	- Legacy frames may not be authored such that the pieces of the nine-slice are named TopLeftCorner, BottomEdge, etc...for this reason,
	the container is allowed to provide a lookup override function for those pieces, in case they already existed.
	The API signature is: <container>.GetNineSlicePiece(pieceName).
	It's not required, if it's missing the fallbacks are:
	1. Look up the piece by key using the default piece name (e.g. container.TopLeft)
	2. Create a new texture and add it to the container, accessible by key (e.g. container.TopLeft = container:CreateTexture()).

	- The idea is that borders should be easy to set up, by describing the art theme in data, there should be minimal effort to setup a frame's background.
 	Offsets exist to provide some proper alignment for legacy frames, most new frames shouldn't need custom offsets.
	The NineSlice itself isn't intended to exist beyond frame setup, just release the reference to it after use.
]]

local function GetNineSlicePiece(container, pieceName)
	if container.GetNineSlicePiece then
		local piece = container:GetNineSlicePiece(pieceName);
		if piece then
			return piece, true;
		end
	end

	local piece = container[pieceName];
	if piece then
		return piece, true;
	else
		piece = container:CreateTexture()
		container[pieceName] = piece;
		return piece, false;
	end
end

local function SetupTextureCoordinates(piece, setupInfo, pieceLayout, userLayout)
	local left, right, top, bottom = 0, 1, 0, 1;
	
	local pieceMirrored = pieceLayout.mirrorLayout;
	if pieceMirrored == nil then
		pieceMirrored = userLayout and userLayout.mirrorLayout;
	end

	if pieceMirrored then
		if setupInfo.mirrorVertical then
			top, bottom = bottom, top;
		end

		if setupInfo.mirrorHorizontal then
			left, right = right, left;
		end
	end

	piece:SetHorizTile(setupInfo.tileHorizontal);
	piece:SetVertTile(setupInfo.tileVertical);
	piece:SetTexCoord(left, right, top, bottom);
end

local function SetupPieceVisuals(piece, setupInfo, pieceLayout, textureKit, userLayout)
	--- Change texture coordinates before applying atlas.
	SetupTextureCoordinates(piece, setupInfo, pieceLayout, userLayout);

	-- textureKit is optional, that's fine; but if it's nil the caller should ensure that there are no format specifiers in .atlas
	local atlasName = GetFinalNameFromTextureKit(pieceLayout.atlas, textureKit);
	local info = C_Texture.GetAtlasInfo(atlasName);
	piece:SetHorizTile(info and info.tilesHorizontally or false);
	piece:SetVertTile(info and info.tilesVertically or false);
	piece:SetAtlas(atlasName, true);
end

local function SetupCorner(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();
	piece:SetPoint(pieceLayout.point or setupInfo.point, container, pieceLayout.relativePoint or setupInfo.point, pieceLayout.x, pieceLayout.y);
end

local function SetupEdge(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();
	piece:SetPoint(setupInfo.point, GetNineSlicePiece(container, setupInfo.relativePieces[1]), setupInfo.relativePoint, pieceLayout.x, pieceLayout.y);
	piece:SetPoint(setupInfo.relativePoint, GetNineSlicePiece(container, setupInfo.relativePieces[2]), setupInfo.point, pieceLayout.x1, pieceLayout.y1);
end

local function SetupCenter(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();
	piece:SetPoint("TOPLEFT", GetNineSlicePiece(container, "TopLeftCorner"), "BOTTOMRIGHT", pieceLayout.x, pieceLayout.y);
	piece:SetPoint("BOTTOMRIGHT", GetNineSlicePiece(container, "BottomRightCorner"), "TOPLEFT", pieceLayout.x1, pieceLayout.y1);
end

-- Defines the order in which each piece should be set up, and how to do the setup.
--
-- Mirror types: As a texture memory and effort savings, many borders are assembled from a single topLeft corner, and top/left edges.
-- That's all that's required if everything is symmetrical (left edge is also superfluous, but allows for more detail variation)
-- The mirror flags specify which texture coords to flip relative to the piece that would use default texture coordinates: left = 0, top = 0, right = 1, bottom = 1
local nineSliceSetup =
{
	{ pieceName = "TopLeftCorner", point = "TOPLEFT", fn = SetupCorner, },
	{ pieceName = "TopRightCorner", point = "TOPRIGHT", mirrorHorizontal = true, fn = SetupCorner, },
	{ pieceName = "BottomLeftCorner", point = "BOTTOMLEFT", mirrorVertical = true, fn = SetupCorner, },
	{ pieceName = "BottomRightCorner", point = "BOTTOMRIGHT", mirrorHorizontal = true, mirrorVertical = true, fn = SetupCorner, },
	{ pieceName = "TopEdge", point = "TOPLEFT", relativePoint = "TOPRIGHT", relativePieces = { "TopLeftCorner", "TopRightCorner" }, fn = SetupEdge, tileHorizontal = true },
	{ pieceName = "BottomEdge", point = "BOTTOMLEFT", relativePoint = "BOTTOMRIGHT", relativePieces = { "BottomLeftCorner", "BottomRightCorner" }, mirrorVertical = true, tileHorizontal = true, fn = SetupEdge, },
	{ pieceName = "LeftEdge", point = "TOPLEFT", relativePoint = "BOTTOMLEFT", relativePieces = { "TopLeftCorner", "BottomLeftCorner" }, tileVertical = true, fn = SetupEdge, },
	{ pieceName = "RightEdge", point = "TOPRIGHT", relativePoint = "BOTTOMRIGHT", relativePieces = { "TopRightCorner", "BottomRightCorner" }, mirrorHorizontal = true, tileVertical = true, fn = SetupEdge, },
	{ pieceName = "Center", fn = SetupCenter, },
};

local layouts =
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
	},

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
	},

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
--------------------------------------------------
-- NINE SLICE UTILS
NineSliceUtil = {};

function NineSliceUtil.ApplyUniqueCornersLayout(self, textureKit)
	NineSliceUtil.ApplyLayout(self, layouts.UniqueCornersLayout, textureKit);
end

function NineSliceUtil.ApplyIdenticalCornersLayout(self, textureKit)
	NineSliceUtil.ApplyLayout(self, layouts.IdenticalCornersLayout, textureKit);
end

function NineSliceUtil.ApplyLayout(container, userLayout, textureKit)
	for pieceIndex, setup in ipairs(nineSliceSetup) do
		local pieceName = setup.pieceName;
		local pieceLayout = userLayout[pieceName];
		if pieceLayout then
			local piece, pieceAlreadyExisted = GetNineSlicePiece(container, pieceName);
			if not pieceAlreadyExisted then
				container[pieceName] = piece;
				piece:SetDrawLayer(pieceLayout.layer or "BORDER", pieceLayout.subLevel);
			end

			-- Piece setup can change arbitrary properties, do it before changing the texture.
			setup.fn(container, piece, setup, pieceLayout);
			if userLayout.setupPieceVisualsFunction then
				userLayout.setupPieceVisualsFunction(container, piece, setup, pieceLayout, textureKit, userLayout);
			else
				SetupPieceVisuals(piece, setup, pieceLayout, textureKit, userLayout);
			end
		end
	end
end

function NineSliceUtil.DisableSharpening(container)
	for pieceIndex, setup in ipairs(nineSliceSetup) do
		local piece = GetNineSlicePiece(container, setup.pieceName);
		piece:SetTexelSnappingBias(0);
		piece:SetSnapToPixelGrid(false);
	end
end

function NineSliceUtil.ApplyLayoutByName(container, userLayoutName, textureKit)
	return NineSliceUtil.ApplyLayout(container, NineSliceUtil.GetLayout(userLayoutName), textureKit);
end

function NineSliceUtil.GetLayout(layoutName)
	return layouts[layoutName];
end

function NineSliceUtil.AddLayout(layoutName, layout)
	layouts[layoutName] = layout;
end

--------------------------------------------------
-- NINE SLICE PANEL MIXIN
 NineSlicePanelMixin = {};

function NineSlicePanelMixin:GetFrameLayoutType()
	return self.layoutType or self:GetParent().layoutType;
end

function NineSlicePanelMixin:OnLoad()
	local layout = NineSliceUtil.GetLayout(self:GetFrameLayoutType());
	if layout then
		NineSliceUtil.ApplyLayout(self, layout, self.layoutTextureKit);
	end
end
