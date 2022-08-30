-- YAY FOR SPARKLES~!

SparkleFrame = CreateFrame("FRAME");
local Sparkle = SparkleFrame:CreateTexture();

function Sparkle:New (sparkleFrame, sparkleTemplate)
	if ( sparkleFrame.freeSparkles[1] ) then
		local sparkle = sparkleFrame.freeSparkles[1];
		sparkle:Reuse(sparkleTemplate);
		tremove(sparkleFrame.freeSparkles, 1);
		tinsert(sparkleFrame.sparkles, sparkle);
		return sparkle;
	end
	
	sparkleTemplate = sparkleTemplate or "SparkleTextureNormal"
	local name = sparkleFrame:GetName();
	local sparkle;
	if ( name ) then
		sparkle = sparkleFrame:CreateTexture(name .. "Sparkle" .. sparkleFrame.numSparkles, "ARTWORK", sparkleTemplate)
	else
		sparkle = sparkleFrame:CreateTexture(nil, "ARTWORK", sparkleTemplate);
	end
	
	setmetatable(sparkle, self);
	self.__index = self;

	tinsert(sparkleFrame.sparkles, sparkle)
	sparkleFrame.numSparkles = sparkleFrame.numSparkles + 1;
	
	return sparkle;
end

function Sparkle:Free ()
	local sparkleFrame = self:GetParent();
	if ( self.OnFinished ) then
		self:OnFinished();
	end
	
	self:Hide(); 
	for i = 1, self.numArgs do
		self["param" .. i] = nil;
	end
	
	self.name = nil;
	self.elapsed = nil;
	self.loop = nil;
	self.Animate = nil;
	
	tinsert(sparkleFrame.freeSparkles, self);
end

SparkleDimensions = 
{
	["SparkleTextureNormal"] = { height = 13, width = 13 },
	["SparkleTextureKindaSmall"] = { height = 10, width = 10 },
	["SparkleTextureSmall"] = { height = 7, width = 7 },
}



function Sparkle:Reuse (sparkleTemplate)
	local dimensions = SparkleDimensions[sparkleTemplate]
	if ( not dimensions ) then
		error()
	end
	
	self:SetHeight(dimensions.height);
	self:SetWidth(dimensions.width);
end

function Sparkle:SetOnFinished (func)
	self.OnFinished = func;
end

function Sparkle:LinearTranslate (elapsed)
	-- Parameters for LinearTranslate:
	-- 1 - relativePoint, 2 - xStart, 3 - xStop, 4 - yStart, 5 - yStop, 6 - duration
	local relativePoint, xStart, xStop, yStart, yStop, duration = self.param1, self.param2, self.param3, self.param4, self.param5, self.param6;
	
	self:Show();
	self.elapsed = self.elapsed + elapsed;
	local xRange = xStart - xStop;
	local yRange = yStart - yStop;
	local xDir = ( xStart < xStop and 1 ) or -1;
	local yDir = ( yStart < yStop and 1 ) or -1;
	
	local position = self.elapsed / duration;
	self:SetPoint("CENTER", "$parent", relativePoint, xStart + (math.abs(xRange * position)*xDir), yStart + (math.abs(yRange * position)*yDir));
	if ( position >= 1 and self.loop ) then
		self.elapsed = 0;
	elseif ( position >= 1 ) then
		return true;
	end
	
	return false;
end

function Sparkle:Pulse (elapsed)
	-- Parameters for Sparkle:
	-- relativePoint, xPos, yPos, startAlpha, maxAlpha, endAlpha, fadeInDuration, holdDuration, fadeOutDuration
	
	local relativePoint, xPos, yPos = self.param1, self.param2, self.param3;
	local startAlpha, maxAlpha, endAlpha = self.param4, self.param5, self.param6;
	local fadeInDuration, holdDuration, fadeOutDuration = self.param7, self.param8, self.param9;
	
	self:Show();
	self:SetPoint("CENTER", "$parent", relativePoint, xPos, yPos);
	self.elapsed = self.elapsed + elapsed;
	if ( self.elapsed <= fadeInDuration ) then
		local range = maxAlpha - startAlpha;
		local percentage = self.elapsed/fadeInDuration;
		self:SetAlpha(startAlpha + (range*percentage));
	elseif ( self.elapsed <= holdDuration ) then
		self:SetAlpha(maxAlpha);
	elseif ( self.elapsed <= fadeOutDuration ) then
		local range = maxAlpha - endAlpha;
		local percentage = (self.elapsed-holdDuration)/(fadeOutDuration-holdDuration);
		self:SetAlpha(maxAlpha - (range*percentage));
	elseif ( self.loop ) then
		self.elapsed = 0;
	else
		return true;
	end
	
	return false;
end

local cos = cos;
local sin = sin;

local cosTable = {};
local sinTable = {};

function Sparkle:RadialTranslate (elapsed)
	-- Parameters for RadialTranslate:
	-- relativePoint, radius, startDegree, stopDegree, duration
	local relativePoint, offsetX, offsetY, radius, startDegree, stopDegree, duration = self.param1, self.param2, self.param3, self.param4, self.param5, self.param6, self.param7;
	
	self:Show();
	self.elapsed = self.elapsed + elapsed;
	local range = startDegree - stopDegree;
	local position = self.elapsed/duration
	local degree = math.floor(startDegree + (range * position));
	
	local xPos, yPos
	local cosVal = cosTable[degree];
	if ( cosVal ) then
		xPos = offsetX + (radius * cosVal);
	else
		cosTable[degree] = cos(degree);
		xPos = offsetX + (radius * cosTable[degree]);
	end
	
	local sinVal = sinTable[degree];
	if ( sinVal ) then
		yPos = offsetY + (radius * sinVal);
	else
		sinTable[degree] = sin(degree);
		yPos = offsetY + (radius + sinTable[degree]);
	end
	
	local xPos = offsetX + (radius * cos(degree));
	local yPos = offsetY + (radius * sin(degree));
	self:SetPoint("CENTER", "$parent", relativePoint, xPos, yPos);
	if ( position >= 1 and self.loop ) then
		self.elapsed = 0;
	elseif ( position >= 1 ) then
		return true;
	end
	
	return false;
end

function SparkleFrame:New (parent)
	local sparkleFrame;
	if ( parent ) then
		sparkleFrame = CreateFrame("FRAME", parent:GetName() .. "SparkleFrame", parent);
		sparkleFrame:SetPoint("TOPLEFT");
		sparkleFrame:SetPoint("BOTTOMRIGHT");
	else
		sparkleFrame = CreateFrame("FRAME");
	end
	
	setmetatable(sparkleFrame, self);
	self.__index = self;

	sparkleFrame.timeSinceLast = 0;
	sparkleFrame.updateTime = 0.0334 -- Roughly 30 frames per second.
--	sparkleFrame.updateTime = 0
	sparkleFrame.numSparkles = 0;
	sparkleFrame.freeSparkles = {};
	sparkleFrame.sparkles = {};	
	
	sparkleFrame:SetScript("OnUpdate", sparkleFrame.OnUpdate);
	
	return sparkleFrame;
end

function SparkleFrame:SetFrameRate(framesPerSec)
	self.updateTime = 1/(framesPerSec or 30);
end

function SparkleFrame:OnUpdate(elapsed)
	local timeSinceLast = self.timeSinceLast + elapsed;
	if ( timeSinceLast >= self.updateTime ) then
		local sparkles = self.sparkles;
		for i = #sparkles, 1, -1 do
			if ( sparkles[i] and sparkles[i]:Animate(timeSinceLast) ) then
				sparkles[i]:Free();
				tremove(sparkles, i);
			end
		end
		self.timeSinceLast = 0;
		return;
	end
	self.timeSinceLast = timeSinceLast;
end

function SparkleFrame:StartAnimation (name, animationType, sparkleTemplate, loop, ...)
	if ( not Sparkle[animationType] ) then
		return;
	end
	
	local sparkle = Sparkle:New(self, sparkleTemplate);
	sparkle.numArgs = select("#", ...);
	for i = 1, sparkle.numArgs do 
		sparkle["param"..i] = select(i, ...);
	end
	
	sparkle.name = name;
	sparkle.elapsed = 0;
	sparkle.loop = loop;
	sparkle.Animate = Sparkle[animationType];
	
	return sparkle
end

function SparkleFrame:EndAnimation (name)
	local sparkles, sparkle = self.sparkles;
	for i = #sparkles, 1, -1 do
		if ( sparkles[i].name == name ) then
			sparkles[i]:Free();
			tremove(sparkles, i);
		end
	end
end

function SparkleFrame:SetAnimationVertexColor (name, r, g, b, a)
	for i, sparkle in next, self.sparkles do
		if ( sparkle.name == name ) then
			sparkle:SetVertexColor(r, g, b, a);
		end
	end
end
