UiMapPoint = {};

function UiMapPoint.CreateFromCoordinates(mapID, x, y, z)
	local uiMapPoint = { uiMapID = mapID, position = CreateVector2D(x, y), z = z };
	return uiMapPoint;
end

function UiMapPoint.CreateFromVector2D(mapID, position, z)
	local uiMapPoint = { uiMapID = mapID, position = position, z = z };
	return uiMapPoint;
end

function UiMapPoint.CreateFromVector3D(mapID, position)
	local uiMapPoint = { uiMapID = mapID, position = CreateVector2D(position.x, position.y), z = position.z };
	return uiMapPoint;
end