function GetTextureInfo(obj)
	if obj:GetObjectType() == "Texture" then
		local assetName = obj:GetAtlas();
		local assetType = "Atlas";

		if not assetName then
			assetName = obj:GetTextureFilePath();
			assetType = "File";
		end

		if not assetName then
			assetName = obj:GetTextureFileID();
			assetType = "FileID";
		end

		if not assetName then
			assetName = "UnknownAsset";
			assetType = "Unknown";
		end

		local ulX, ulY, blX, blY, urX, urY, brX, brY = obj:GetTexCoord();
		return assetName, assetType, ulX, ulY, blX, blY, urX, urY, brX, brY;
	end
end

function SetClampedTextureRotation(texture, rotationDegrees)
	if (rotationDegrees ~= 0 and rotationDegrees ~= 90 and rotationDegrees ~= 180 and rotationDegrees ~= 270) then
		error("SetRotation: rotationDegrees must be 0, 90, 180, or 270");
		return;
	end

	if not (texture.rotationDegrees) then
		texture.origTexCoords = {texture:GetTexCoord()};
		texture.origWidth = texture:GetWidth();
		texture.origHeight = texture:GetHeight();
	end

	if (texture.rotationDegrees == rotationDegrees) then
		return;
	end

	texture.rotationDegrees = rotationDegrees;

	if (rotationDegrees == 0 or rotationDegrees == 180) then
		texture:SetWidth(texture.origWidth);
		texture:SetHeight(texture.origHeight);
	else
		texture:SetWidth(texture.origHeight);
		texture:SetHeight(texture.origWidth);
	end

	if (rotationDegrees == 0) then
		texture:SetTexCoord( texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[7], texture.origTexCoords[8] );
	elseif (rotationDegrees == 90) then
		texture:SetTexCoord( texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[5], texture.origTexCoords[6] );
	elseif (rotationDegrees == 180) then
		texture:SetTexCoord( texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[1], texture.origTexCoords[2] );
	elseif (rotationDegrees == 270) then
		texture:SetTexCoord( texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[3], texture.origTexCoords[4] );
	end
end

function ClearClampedTextureRotation(texture)
	if (texture.rotationDegrees) then
		SetClampedTextureRotation(texture, 0);
		texture.origTexCoords = nil;
		texture.origWidth = nil;
		texture.origHeight = nil;
	end
end


function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
end

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;

	if ( role == "GUIDE" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGER" ) then
		return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Unknown role: "..tostring(role));
	end
end

function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)
	return ("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"):format(
		  file
		, height
		, width
		, xOffset or 0
		, yOffset or 0
		, fileWidth
		, fileHeight
		, left * fileWidth
		, right * fileWidth
		, top * fileHeight
		, bottom * fileHeight
	);
end

function CreateAtlasMarkup(atlasName, height, width, offsetX, offsetY)
	return ("|A:%s:%d:%d:%d:%d|a"):format(
		  atlasName
		, height or 0
		, width or 0
		, offsetX or 0
		, offsetY or 0
	);
end

-- NOTE: Many of the TextureKit functions below use the following parameters
-- If setVisibilityOfRegions is true, the frame will be shown or hidden based on whether the textureKit and atlas element were found
-- If useAtlasSize is true, the frame will be resized to be the same size as the atlas element.
-- Use the constants in TextureKitConstants for both

TextureKitConstants = {
	SetVisibility = true;
	DoNotSetVisibility = false;

	UseAtlasSize = true;
	IgnoreAtlasSize = false;
}

-- Pass in a frame and a table containing parentKeys (on frame) as keys and atlas member names as the values
function SetupAtlasesOnRegions(frame, regionsToAtlases, useAtlasSize)
	for region, atlas in pairs(regionsToAtlases) do
		if frame[region] then
			if frame[region]:GetObjectType() == "StatusBar" then
				frame[region]:SetStatusBarAtlas(atlas);
			elseif frame[region].SetAtlas then
				frame[region]:SetAtlas(atlas, useAtlasSize);
			end
		end
	end
end

function GetFinalNameFromTextureKit(fmt, textureKits)
	if type(textureKits) == "table" then
		return fmt:format(unpack(textureKits));
	else
		return fmt:format(textureKits);
	end
end

-- Pass in a TextureKit name, a frame and a formatting string.
-- The TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
-- Use "%s" for fmt if the TextureKit name is the entire atlas element name
function SetupTextureKitOnFrame(textureKit, frame, fmt, setVisibility, useAtlasSize)
	if not frame then
		return;
	end
	
	local success = false;

	if textureKit then
		if frame:GetObjectType() == "StatusBar" then
			success = frame:SetStatusBarAtlas(GetFinalNameFromTextureKit(fmt, textureKit));
		elseif frame.SetAtlas then
			success = frame:SetAtlas(GetFinalNameFromTextureKit(fmt, textureKit), useAtlasSize);
		end
	end

	if setVisibility then
		frame:SetShown(success);
	end
end

-- Pass in a TextureKit name and a table containing frames as keys and formatting strings as values
-- For each frame key in frames, the TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
-- Use "%s" for fmt if the TextureKit name is the entire atlas element name
function SetupTextureKitOnFrames(textureKit, frames, setVisibilityOfRegions, useAtlasSize)
	if not textureKit and not setVisibilityOfRegions then
		return;
	end

	for frame, fmt in pairs(frames) do
		SetupTextureKitOnFrame(textureKit, frame, fmt, setVisibilityOfRegions, useAtlasSize);
	end
end

-- Pass in a TextureKit name, a frame and a table containing parentKeys (on frame) as keys and formatting strings as values
-- For each frame key in frames, the TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
-- Use "%s" for fmt if the TextureKit name is the entire atlas element name
function SetupTextureKitOnRegions(textureKit, frame, regions, setVisibilityOfRegions, useAtlasSize)
	if not textureKit and not setVisibilityOfRegions then
		return;
	end

	local frames = {};
	for region, fmt in pairs(regions) do
		if frame[region] then
			frames[frame[region]] = fmt;
		end
	end

	return SetupTextureKitOnFrames(textureKit, frames, setVisibilityOfRegions, useAtlasSize);
end

function SetupTextureKits(textureKitID, frame, regions, setVisibilityOfRegions, useAtlasSize)
	local textureKit = GetUITextureKitInfo(textureKitID);
	SetupTextureKitOnRegions(textureKit, frame, regions, setVisibilityOfRegions, useAtlasSize);
end

-- Pass in a TextureKit name, a frame and a table containing parentKeys (on frame) as keys and a table as values
-- The values table should contain formatString as a member (setVisibility and useAtlasSize can also be added if desired)
-- For each frame key in frames, the TextureKit name will be inserted into formatString (at the first %s). The resulting atlas name will be set on frame
-- Use "%s" for formatString if the TextureKit name is the entire atlas element name
function SetupTextureKitsFromRegionInfo(textureKit, frame, regionInfoList)
	if not frame or not regionInfoList then
		return;
	end

	for region, regionInfo in pairs(regionInfoList) do
		SetupTextureKitOnFrame(textureKit, frame[region], regionInfo.formatString, regionInfo.setVisibility, regionInfo.useAtlasSize);
	end
end

function SetupTextureKitsFromRegionInfoByID(textureKitID, frame, regionInfoList)
	local textureKit = GetUITextureKitInfo(textureKitID);
	SetupTextureKitsFromRegionInfo(textureKit, frame, regionInfoList);
end

--Pass the texture and the textureKit, if the atlas exists in data then it will return the actual atlas name otherwise, return nil. 
function GetFinalAtlasFromTextureKitIfExists(texture, textureKit)
	if not texture or not textureKit then
		return nil;
	end

	local atlas = GetFinalNameFromTextureKit(texture, textureKit);
	local atlasInfo = C_Texture.GetAtlasInfo(atlas);
	return atlasInfo and atlas or nil;
end