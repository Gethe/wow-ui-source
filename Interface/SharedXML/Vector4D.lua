-- Protecting from addons since we use this in secure code.
local cos = math.cos;
local sin = math.sin;
local atan2 = math.atan2;
local asin = math.asin;
local sqrt = math.sqrt;

function Vector4D_ScaleBy(scalar, x, y, z, w)
	return x * scalar, y * scalar, z * scalar, w * scalar;
end

function Vector4D_DivideBy(divisor, x, y, z, w)
	return x / divisor, y / divisor, z / divisor, w / divisor;
end

function Vector4D_Add(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
	return leftX + rightX, leftY + rightY, leftZ + rightZ, leftW + rightW;
end

function Vector4D_Subtract(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
	return leftX - rightX, leftY - rightY, leftZ - rightZ, leftW - rightW;
end

function Vector4D_Dot(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
	return leftX * rightX + leftY * rightY + leftZ * rightZ + leftW * rightW;
end

function Vector4D_GetLengthSquared(x, y, z, w)
	return Vector4D_Dot(x, y, z, w, x, y, z, w);
end

function Vector4D_GetLength(x, y, z, w)
	return sqrt(Vector4D_GetLengthSquared(x, y, z, w));
end

function Vector4D_Normalize(x, y, z, w)
	return Vector4D_DivideBy(Vector4D_GetLength(x, y, z, w), x, y, z, w);
end

function Vector4D_AddVector(left, right)
	local clone = left:Clone();
	clone:Add(right);
	return clone;
end

function Vector4D_SubtractVector(left, right)
	local clone = left:Clone();
	clone:Subtract(right);
	return clone;
end

function Vector4D_NormalizeVector(vector)
	local clone = vector:Clone();
	clone:Normalize();
	return clone;
end

function Vector4D_ScaleVector(scalar, vector)
	local clone = vector:Clone();
	clone:ScaleBy(scalar);
	return clone;
end

Vector4DMixin = {};

function CreateVector4D(x, y, z, w)
	local vector = CreateFromMixins(Vector4DMixin);
	vector:OnLoad(x, y, z, w);
	return vector;
end

function AreVector4DEqual(left, right)
	if left and right then
		return left:IsEqualTo(right);
	end
	return left == right;
end

function Vector4DMixin:OnLoad(x, y, z, w)
	self:SetXYZW(x, y, z, w);
end

function Vector4DMixin:IsEqualTo(otherVector)
	return self.x == otherVector.x
	   and self.y == otherVector.y
	   and self.z == otherVector.z
	   and self.w == otherVector.w;
end

function Vector4DMixin:GetXYZW()
	return self.x, self.y, self.z, self.w;
end

function Vector4DMixin:SetXYZW(x, y, z, w)
	self.x = x;
	self.y = y;
	self.z = z;
	self.w = w;
end

function Vector4DMixin:ScaleBy(scalar)
	self:SetXYZW(Vector4D_ScaleBy(scalar, self:GetXYZW()));
end

function Vector4DMixin:DivideBy(scalar)
	self:SetXYZW(Vector4D_DivideBy(scalar, self:GetXYZW()));
end

function Vector4DMixin:Add(other)
	self:SetXYZW(Vector4D_Add(self.x, self.y, self.z, self.w, other:GetXYZW()));
end

function Vector4DMixin:Subtract(other)
	self:SetXYZW(Vector4D_Subtract(self.x, self.y, self.z, self.w, other:GetXYZW()));
end

function Vector4DMixin:Dot(other)
	return Vector4D_Dot(self.x, self.y, self.z, self.w, other:GetXYZW());
end

function Vector4DMixin:GetLengthSquared()
	return Vector4D_GetLengthSquared(self:GetXYZW());
end

function Vector4DMixin:GetLength()
	return Vector4D_GetLength(self:GetXYZW());
end

function Vector4DMixin:Normalize()
	self:SetXYZW(Vector4D_Normalize(self:GetXYZW()));
end

function Vector4DMixin:Clone()
	return CreateVector4D(self:GetXYZW());
end
