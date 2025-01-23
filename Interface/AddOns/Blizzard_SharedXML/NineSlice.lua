
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
	-- Change texture coordinates before applying atlas.
	SetupTextureCoordinates(piece, setupInfo, pieceLayout, userLayout);

	-- textureKit is optional, that's fine; but if it's nil the caller should ensure that there are no format specifiers in .atlas
	local atlasName = GetFinalNameFromTextureKit(pieceLayout.atlas, textureKit);
	local info = C_Texture.GetAtlasInfo(atlasName);
	piece:SetHorizTile(info and info.tilesHorizontally or false);
	piece:SetVertTile(info and info.tilesVertically or false);

	if info then
		piece:SetAtlas(atlasName, true);
	end
end

local function SetupCorner(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();
	piece:SetPoint(pieceLayout.point or setupInfo.point, container, pieceLayout.relativePoint or setupInfo.point, pieceLayout.x, pieceLayout.y);
end

local function SetupEdge(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();

	local userLayout = NineSliceUtil.GetLayout(container.layoutType);
	if userLayout and (userLayout.threeSliceVertical or userLayout.threeSliceHorizontal) then
		piece:SetPoint(setupInfo.point, container, setupInfo.relativePoint, pieceLayout.x, pieceLayout.y);
		piece:SetPoint(setupInfo.relativePoint, container, setupInfo.point, pieceLayout.x1, pieceLayout.y1);
	else
		piece:SetPoint(setupInfo.point, GetNineSlicePiece(container, setupInfo.relativePieces[1]), setupInfo.relativePoint, pieceLayout.x, pieceLayout.y);
		piece:SetPoint(setupInfo.relativePoint, GetNineSlicePiece(container, setupInfo.relativePieces[2]), setupInfo.point, pieceLayout.x1, pieceLayout.y1);
	end
end

local function SetupCenter(container, piece, setupInfo, pieceLayout)
	piece:ClearAllPoints();

	local userLayout = NineSliceUtil.GetLayout(container.layoutType);
	if userLayout and userLayout.threeSliceVertical then
		piece:SetPoint("TOPLEFT", GetNineSlicePiece(container, "TopEdge"), "BOTTOMLEFT", pieceLayout.x, pieceLayout.y);
		piece:SetPoint("BOTTOMRIGHT", GetNineSlicePiece(container, "BottomEdge"), "TOPRIGHT", pieceLayout.x1, pieceLayout.y1);
	elseif userLayout and userLayout.threeSliceHorizontal then
		piece:SetPoint("TOPLEFT", GetNineSlicePiece(container, "LeftEdge"), "TOPRIGHT", pieceLayout.x, pieceLayout.y);
		piece:SetPoint("BOTTOMRIGHT", GetNineSlicePiece(container, "RightEdge"), "BOTTOMLEFT", pieceLayout.x1, pieceLayout.y1);
	else
		piece:SetPoint("TOPLEFT", GetNineSlicePiece(container, "TopLeftCorner"), "BOTTOMRIGHT", pieceLayout.x, pieceLayout.y);
		piece:SetPoint("BOTTOMRIGHT", GetNineSlicePiece(container, "BottomRightCorner"), "TOPLEFT", pieceLayout.x1, pieceLayout.y1);
	end
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

--------------------------------------------------
-- NINE SLICE UTILS
NineSliceUtil = {};

function NineSliceUtil.ApplyUniqueCornersLayout(self, textureKit)
	NineSliceUtil.ApplyLayout(self, NineSliceLayouts.UniqueCornersLayout, textureKit);
end

function NineSliceUtil.ApplyIdenticalCornersLayout(self, textureKit)
	NineSliceUtil.ApplyLayout(self, NineSliceLayouts.IdenticalCornersLayout, textureKit);
end

function NineSliceUtil.ApplyLayout(container, userLayout, textureKit)
	for pieceIndex, setup in ipairs(nineSliceSetup) do
		local pieceName = setup.pieceName;
		local pieceLayout = userLayout[pieceName];
		if pieceLayout then
			local piece, pieceAlreadyExisted = GetNineSlicePiece(container, pieceName);
			if not pieceAlreadyExisted then
				container[pieceName] = piece;
				local layer = container.layoutTextureLayer or pieceLayout.layer or "BORDER";
				local subLevel = container.layoutTextureSubLevel or pieceLayout.subLevel;
				piece:SetDrawLayer(layer, subLevel);
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

	if userLayout.disableSharpening then
		NineSliceUtil.DisableSharpening(container);
	end
end

do 
	local function ForEachPiece(fn)
		return function(container)
			for pieceIndex, setup in ipairs(nineSliceSetup) do
				local pieceName = setup.pieceName;
				local piece, pieceAlreadyExisted = GetNineSlicePiece(container, pieceName);
				if piece then
					fn(piece);
				end
			end
		end
	end

	NineSliceUtil.HideLayout = ForEachPiece(function(piece)
		piece:Hide();
	end);

	NineSliceUtil.ShowLayout = ForEachPiece(function(piece)
		piece:Show();
	end);

	function NineSliceUtil.SetLayoutShown(container, show)
		if show then
			NineSliceUtil.ShowLayout(container);
		else
			NineSliceUtil.HideLayout(container);
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
	return NineSliceLayouts[layoutName];
end

function NineSliceUtil.AddLayout(layoutName, layout)
	NineSliceLayouts[layoutName] = layout;
end

--------------------------------------------------
-- NINE SLICE PANEL MIXIN
 NineSlicePanelMixin = {};

function NineSlicePanelMixin:GetFrameLayoutType()
	return self.layoutType or self:GetParent().layoutType;
end

function NineSlicePanelMixin:GetFrameLayoutTextureKit()
	local parentAtlasKey = self.atlasKey or "layoutTextureKit";
	return self.layoutTextureKit or self:GetParent()[parentAtlasKey];
end

function NineSlicePanelMixin:OnLoad()
	local layout = NineSliceUtil.GetLayout(self:GetFrameLayoutType());
	if layout then
		NineSliceUtil.ApplyLayout(self, layout, self:GetFrameLayoutTextureKit());
	end
end

function NineSlicePanelMixin:SetCenterColor(r, g, b, a)
	local center = self["Center"];
	if center then
		center:SetVertexColor(r, g, b, a or 1);
	end
end

function NineSlicePanelMixin:GetCenterColor()
	local center = self["Center"];
	if center then
		return center:GetVertexColor();
	end
end

function NineSlicePanelMixin:SetBorderColor(r, g, b, a)
	for _, section in ipairs(nineSliceSetup) do
		if section.pieceName ~= "Center" then
			local piece = self[section.pieceName];
			if piece then
				piece:SetVertexColor(r, g, b, a or 1);
			end
		end
	end
end

function NineSlicePanelMixin:GetBorderColor()
	-- return the vertex color of any valid piece
	for _, section in ipairs(nineSliceSetup) do
		if section.pieceName ~= "Center" then
			local piece = self[section.pieceName];
			if piece then
				return piece:GetVertexColor();
			end
		end
	end
end

function NineSlicePanelMixin:SetVertexColor(r, g, b, a)
	self:SetCenterColor(r, g, b, a);
	self:SetBorderColor(r, g, b, a);
end

function NineSlicePanelMixin:SetBorderBlendMode(blendMode)
	for _, section in ipairs(nineSliceSetup) do
		if section.pieceName ~= "Center" then
			local piece = self[section.pieceName];
			if piece then
				piece:SetBlendMode(blendMode);
			end
		end
	end
end