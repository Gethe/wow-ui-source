
VehicleDrawInfoMixin = {};

function VehicleDrawInfoMixin:GetTexture(isOccupied)
	if isOccupied then
		return self.occupiedTexture or self.texture;
	else
		return self.unoccupiedTexture or self.texture;
	end
end

function VehicleDrawInfoMixin:ShouldDrawBelowPlayerBlips()
	return self.belowPlayerBlips;
end

function VehicleDrawInfoMixin:GetWidth()
	return self.width;
end

function VehicleDrawInfoMixin:GetHeight()
	return self.height;
end

VECHICLE_DRAW_INFO = {};

VECHICLE_DRAW_INFO["Drive"] = Mixin({
	occupiedTexture = "Interface\\Minimap\\Vehicle-Ground-Unoccupied",
	unoccupiedTexture = "Interface\\Minimap\\Vehicle-Ground-Occupied",
	width=45,
	height=45,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Fly"] = Mixin({
	occupiedTexture = "Interface\\Minimap\\Vehicle-Air-Unoccupied",
	unoccupiedTexture = "Interface\\Minimap\\Vehicle-Air-Occupied",
	width=45,
	height=45,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Airship Horde"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Air-Horde",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Airship Alliance"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Air-Alliance",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Carriage"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Carriage",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Mogu"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Mogu",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Grummle Convoy"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-GrummleConvoy",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Minecart"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-SilvershardMines-MineCart",
	width=64,
	height=64,
	belowPlayerBlips = true,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Minecart Red"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed",
	width=64,
	height=64,
	belowPlayerBlips = true,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Minecart Blue"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue",
	width=64,
	height=64,
	belowPlayerBlips = true,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Arrow"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-SilvershardMines-Arrow",
	width=64,
	height=64,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Trap Gold"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Trap-Gold",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Trap Grey"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Trap-Grey",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Trap Red"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-Trap-Red",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Hammer Gold 0"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-HammerGold",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Hammer Gold 1"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-HammerGold-1",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Hammer Gold 2"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-HammerGold-2",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Hammer Gold 3"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-HammerGold-3",
	width=32,
	height=32,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Cart Horde"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-HordeCart",
	width=32,
	height=32,
	belowPlayerBlips = true,
}, VehicleDrawInfoMixin);

VECHICLE_DRAW_INFO["Cart Alliance"] = Mixin({
	texture = "Interface\\Minimap\\Vehicle-AllianceCart",
	width=32,
	height=32,
	belowPlayerBlips = true,
}, VehicleDrawInfoMixin);

VehicleUtil = {};

function VehicleUtil.GetVehicleInfo(vehicleType)
	return VECHICLE_DRAW_INFO[vehicleType];
end

function VehicleUtil.IsValidVehicleType(vehicleType)
	return VehicleUtil.GetVehicleInfo(vehicleType) ~= nil;
end

function VehicleUtil.GetVehicleTexture(vehicleType, isOccupied)
	if not VehicleUtil.IsValidVehicleType(vehicleType) then
		return nil;
	end
	return VehicleUtil.GetVehicleInfo(vehicleType):GetTexture(isOccupied);
end