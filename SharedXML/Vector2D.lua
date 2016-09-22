function Vector2D_ScaleBy(scalar, x, y)
	return x * scalar, y * scalar;
end

function Vector2D_DivideBy(divisor, x, y)
	return x / divisor, y / divisor;
end

function Vector2D_Add(leftX, leftY, rightX, rightY)
	return leftX + rightX, leftY + rightY;
end

function Vector2D_Subtract(leftX, leftY, rightX, rightY)
	return leftX - rightX, leftY - rightY;
end

function Vector2D_Cross(leftX, leftY, rightX, rightY)
	return leftX * rightY - leftY * rightX;
end

function Vector2D_Dot(leftX, leftY, rightX, rightY)
	return leftX * rightX + leftY * rightY;
end

function Vector2D_GetLengthSquared(x, y)
	return Vector2D_Dot(x, y, x, y);
end

function Vector2D_GetLength(x, y)
	return math.sqrt(Vector2D_GetLengthSquared(x, y));
end

function Vector2D_Normalize(x, y)
	return Vector2D_DivideBy(Vector2D_GetLength(x, y), x, y);
end