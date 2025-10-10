ColorMixin = {};

function CreateColor(r, g, b, a)
	local color = CreateFromMixins(ColorMixin);
	color:OnLoad(r, g, b, a);
	return color;
end

function ColorMixin:OnLoad(r, g, b, a)
	self:SetRGBA(r, g, b, a);
end

function ColorMixin:IsRGBEqualTo(otherColor)
	return self.r == otherColor.r 
		and self.g == otherColor.g 
		and self.b == otherColor.b;
end

function ColorMixin:IsEqualTo(otherColor)
	return self:IsRGBEqualTo(otherColor) and self.a == otherColor.a;
end

function ColorMixin:GetRGB()
	return self.r, self.g, self.b;
end



function ColorMixin:GetHSL()
	local r, g, b, a = self.r, self.g, self.b, self.a;
	local max, min = math.max(r, g, b), math.min(r, g, b);
	local h, s, l;
	
	l = (max + min) / 2;
	
	if max == min then
		h, s = 0, 0; -- achromatic
	else
		local d = max - min
		if l > 0.5 then 
			s = d / (2 - max - min);
		else 
			s = d / (max + min); 
		end
		if max == r then
			h = (g - b) / d;
			if g < b then 
				h = h + 6 ;
			end
		elseif max == g then 
			h = (b - r) / d + 2;
		elseif max == b then 
			h = (r - g) / d + 4;
		end
		h = h / 6;
	end
	
	return h, s, l, a or 1;
end

function ColorMixin:GetRGBAsBytes()
	return Round(self.r * 255), Round(self.g * 255), Round(self.b * 255);
end

function ColorMixin:GetRGBA()
	return self.r, self.g, self.b, self.a;
end

function ColorMixin:GetRGBAAsBytes()
	return Round(self.r * 255), Round(self.g * 255), Round(self.b * 255), Round((self.a or 1) * 255);
end

function ColorMixin:SetRGBA(r, g, b, a)
	self.r = r;
	self.g = g;
	self.b = b;
	self.a = a or 1;
end

function ColorMixin:SetRGB(r, g, b)
	self:SetRGBA(r, g, b, nil);
end

function ColorMixin:GenerateHexColor()
	return ("ff%.2x%.2x%.2x"):format(self:GetRGBAsBytes());
end

function ColorMixin:GenerateHexColorNoAlpha()
	return ("%.2X%.2X%.2X"):format(self:GetRGBAsBytes());
end

function ColorMixin:GenerateHexColorMarkup()
	return "|c"..self:GenerateHexColor();
end

function ColorMixin:WrapTextInColorCode(text)
	return WrapTextInColorCode(text, self:GenerateHexColor());
end

function WrapTextInColorCode(text, colorHexString)
	return ("|c%s%s|r"):format(colorHexString, text);
end

function WrapTextInColor(text, color)
	return WrapTextInColorCode(text, color:GenerateHexColor());
end

do
	local envTbl = GetCurrentEnvironment();
	local DBColors = C_UIColor.GetColors();
	for _, dbColor in ipairs(DBColors) do
		local color = CreateColor(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a);
		envTbl[dbColor.baseTag] = color;
		envTbl[dbColor.baseTag.."_CODE"] = color:GenerateHexColorMarkup();
	end
end