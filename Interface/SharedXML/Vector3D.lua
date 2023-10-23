-- Protecting from addons since we use this in secure code.
local cos = math.cos;
local sin = math.sin;
local atan2 = math.atan2;
local asin = math.asin;
local sqrt = math.sqrt;

function Vector3D_ScaleBy(scalar, x, y, z)
	return x * scalar, y * scalar, z * scalar;
end

function Vector3D_DivideBy(divisor, x, y, z)
	return x / divisor, y / divisor, z / divisor;
end

function Vector3D_Add(leftX, leftY, leftZ, rightX, rightY, rightZ)
	return leftX + rightX, leftY + rightY, leftZ + rightZ;
end

function Vector3D_Subtract(leftX, leftY, leftZ, rightX, rightY, rightZ)
	return leftX - rightX, leftY - rightY, leftZ - rightZ;
end

function Vector3D_Cross(leftX, leftY, leftZ, rightX, rightY, rightZ)
	return leftY * rightZ - leftZ * rightY, leftZ * rightX - leftX * rightZ, leftX * rightY - leftY * rightX;
end

function Vector3D_Dot(leftX, leftY, leftZ, rightX, rightY, rightZ)
	return leftX * rightX + leftY * rightY + leftZ * rightZ;
end

function Vector3D_GetLengthSquared(x, y, z)
	return Vector3D_Dot(x, y, z, x, y, z);
end

function Vector3D_GetLength(x, y, z)
	return sqrt(Vector3D_GetLengthSquared(x, y, z));
end

function Vector3D_Normalize(x, y, z)
	return Vector3D_DivideBy(Vector3D_GetLength(x, y, z), x, y, z);
end

function Vector3D_AddVector(left, right)
	local clone = left:Clone();
	clone:Add(right);
	return clone;
end

function Vector3D_SubtractVector(left, right)
	local clone = left:Clone();
	clone:Subtract(right);
	return clone;
end

function Vector3D_NormalizeVector(vector)
	local clone = vector:Clone();
	clone:Normalize();
	return clone;
end

function Vector3D_ScaleVector(scalar, vector)
	local clone = vector:Clone();
	clone:ScaleBy(scalar);
	return clone;
end

function Vector3D_CalculateNormalFromYawPitch(yaw, pitch)
	return	cos(-pitch) * cos(yaw),
			cos(-pitch) * sin(yaw),
			sin(-pitch);
end

function Vector3D_CalculateYawPitchFromNormal(x, y, z)
	if x ~= 0 or y ~= 0 then
		return atan2(y, x), asin(-z);
	end

	return 0, asin(-z);
end

function Vector3D_CalculateYawPitchFromNormalVector(vector)
	return Vector3D_CalculateYawPitchFromNormal(vector:GetXYZ());
end


function Vector3D_CreateNormalVectorFromYawPitch(yawRadians, pitchRadians)
	return CreateVector3D(Vector3D_CalculateNormalFromYawPitch(yawRadians, pitchRadians));
end

Vector3DMixin = {};

function CreateVector3D(x, y, z)
	local vector = CreateFromMixins(Vector3DMixin);
	vector:OnLoad(x, y, z);
	return vector;
end

function AreVector3DEqual(left, right)
	if left and right then
		return left:IsEqualTo(right);
	end
	return left == right;
end

function Vector3DMixin:OnLoad(x, y, z)
	self:SetXYZ(x, y, z);
end

function Vector3DMixin:IsEqualTo(otherVector)
	return self.x == otherVector.x
	   and self.y == otherVector.y
	   and self.z == otherVector.z;
end

function Vector3DMixin:GetXYZ()
	return self.x, self.y, self.z;
end

function Vector3DMixin:SetXYZ(x, y, z)
	self.x = x;
	self.y = y;
	self.z = z;
end

function Vector3DMixin:ScaleBy(scalar)
	self:SetXYZ(Vector3D_ScaleBy(scalar, self:GetXYZ()));
end

function Vector3DMixin:DivideBy(scalar)
	self:SetXYZ(Vector3D_DivideBy(scalar, self:GetXYZ()));
end

function Vector3DMixin:Add(other)
	self:SetXYZ(Vector3D_Add(self.x, self.y, self.z, other:GetXYZ()));
end

function Vector3DMixin:Subtract(other)
	self:SetXYZ(Vector3D_Subtract(self.x, self.y, self.z, other:GetXYZ()));
end

function Vector3DMixin:Cross(other)
	self:SetXYZ(Vector3D_Cross(self.x, self.y, self.z, other:GetXYZ()));
end

function Vector3DMixin:Dot(other)
	return Vector3D_Dot(self.x, self.y, self.z, other:GetXYZ());
end

function Vector3DMixin:GetLengthSquared()
	return Vector3D_GetLengthSquared(self:GetXYZ());
end

function Vector3DMixin:GetLength()
	return Vector3D_GetLength(self:GetXYZ());
end

function Vector3DMixin:Normalize()
	self:SetXYZ(Vector3D_Normalize(self:GetXYZ()));
end

function Vector3DMixin:Clone()
	return CreateVector3D(self:GetXYZ());
end
