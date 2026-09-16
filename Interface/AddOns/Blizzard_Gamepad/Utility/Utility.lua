-- Create a global namespace for gamepad features
if not GamepadMode then
	GamepadMode = {};
end

--[[
	Updates a full or half radial progress, setting, or health bar based on what percentage the bar is at from 0% to 100%

	rightHalf: The right half of the radial bar (if we are doing a half radial, we will default to using this variable)
	leftHalf: The left half of the radial bar
	percentage: The current percentage value of the radial bar from 0 to 100
	mode: The mode, as a string, we are using this function in ("FULL", "HALF")
]]
function GamepadMode.RadialBarUpdate(rightHalf, leftHalf, percentage, mode)
	if (mode == "FULL") then
		-- If we are above 50% health, we want to position the right half of the bar
		if (percentage >= 0.5) then
			leftHalf:SetRotation(math.pi);
			rightHalf:SetRotation(-2 * math.pi * (1 - percentage));
		-- If we are below 50% health, we want to position the left half of the bar
		else
			rightHalf:SetRotation(math.pi);
			leftHalf:SetRotation(-2 * math.pi * (1 - percentage));
		end
	elseif (mode == "HALF") then
		return;
	end
end

--[[
	Returns a frame that has a filled in radial slice that
	can be added or subtracted to

	maxRadius: 		Maximum radius of the slice
	minRadius: 		Minimum radius of the slice
	maxRadian: 		What radian are we going to
	minRadian: 		What radian to start on
	arcCount:  		How many arcs are going to be made to fill the slice
	arcDef:   		How many lines to use to make an arc
	lineColor: 		What color to make the lines, in format {r, g, b}
	lineThickness:	How thick to make each line
	radial:			Radial the slice fill will be attached to

	return: Frame containing all the lines
]]
function GamepadMode.CreateRadialSliceFill(maxRadius, minRadius, maxRadian, minRadian, arcCount, arcDef, lineColor, lineThickness, radial)
	assert(type(maxRadius) == "number", "Param maxRadius is of wrong type");
	assert(type(minRadius) == "number", "Param minRadius is of wrong type");
	assert(type(maxRadian) == "number", "Param maxRadian is of wrong type");
	assert(type(minRadian) == "number", "Param minRadian is of wrong type");
	assert(type(arcCount) == "number", "Param arcCount is of wrong type");
	assert(type(arcDef) == "number", "Param arcDef is of wrong type");
	assert(type(lineColor) == "table", "Param lineColor is of wrong type");
	assert(type(lineThickness) == "number", "Param lineThickness is of wrong type");
	assert(type(radial) == "table", "Param radial is of wrong type");

	-- Create frame
	local frame = CreateFrame("FRAME", nil, radial);
	frame:SetFrameLevel(1003);
	frame:SetAllPoints();

	-- Account for line thickness
	maxRadius = maxRadius - lineThickness/2;
	minRadius = minRadius + lineThickness/2 - 3;

	-- Create a table of the radian for each point on the arc
	local radiansPerSeg = (maxRadian - minRadian) / arcDef;
	local radianSegTable = {};
	for lineNum=0, arcDef, 1 do
		local radian = minRadian + radiansPerSeg * lineNum;

		-- Account for lines not being exact with some overlap
		if (lineNum > 0 and lineNum < arcDef - 1) then
			radian = radian - 0.1;
		end

		radianSegTable[lineNum+1] = radian;
	end

	-- Find out how much to increment the radius
	local radiusSeg = (maxRadius - minRadius) / arcCount;

	-- Half a percent to increment the arc color by
	local arcPercent = 0.5/arcCount;

	-- Iterate for each arc
	for arcNum=1, arcCount, 1 do

		-- Find this arc's radius
		local radius = minRadius + radiusSeg * arcNum;

		-- Find the gradient color for this arc of the section
		local r,g,b = unpack(lineColor);
		local arcMod = arcPercent*(arcNum-1);
		local gradR, gradG, gradB = r - arcMod, g - arcMod, b - arcMod;

		-- Iterate for each line along the arc
		for lineNum=1, arcDef, 1 do
			-- Create line
			local line = frame:CreateLine();
			line:SetThickness(lineThickness);
			line:SetColorTexture(gradR, gradG, gradB);
			line:Show();
			frame["line"..arcNum..":"..lineNum] = line;

			-- Find first point
			local x1 = math.cos(radianSegTable[lineNum]) * radius;
			local y1 = math.sin(radianSegTable[lineNum]) * radius;

			-- Find second point
			local x2 = math.cos(radianSegTable[lineNum+1]) * radius;
			local y2 = math.sin(radianSegTable[lineNum+1]) * radius;

			-- Anchor line
			line:SetStartPoint("CENTER", x1, y1);
			line:SetEndPoint("CENTER", x2, y2);
		end
	end

	-- Add Function to set percentage fills
	frame.SetFillPercent = function(self, percent)
		-- Get amount of arcs that make up 1%
		local arcPercent = arcCount / 100;

		-- Find out how many arcs we need to hide
		local arcsToHide = math.floor(arcPercent * (100 - percent));

		-- Iterate for each arc
		for arcNum=1, arcCount, 1 do
			-- Iterate for each line along the arc
			for lineNum=1, arcDef, 1 do
				if (arcNum <= arcsToHide) then
					self["line"..arcNum..":"..lineNum]:Hide();
				else
					self["line"..arcNum..":"..lineNum]:Show();
				end
			end
		end
	end

	-- Add Function to set color
	frame.SetColor = function(self, r, g, b)
		-- Iterate for each arc
		for arcNum=1, arcCount, 1 do

			-- Find the gradient color for this arc of the section
			local arcMod = arcPercent*(arcNum-1);
			local gradR, gradG, gradB = r - arcMod, g - arcMod, b - arcMod;

			-- Iterate for each line along the arc
			for lineNum=1, arcDef, 1 do
				-- Create line
				frame["line"..arcNum..":"..lineNum]:SetColorTexture(gradR, gradG, gradB);
			end
		end
	end

	return frame;
end

--[[
	Draws a highlight based on given points

	parentFrame: 	Frame for the highlight frame to child to, will be used for dimensions if points isn't passed
	thickness: 		(Optional) How thick to make the highlight lines
	color:			(Optional) Color to make the Highlight in the format {r, g, b}
	points: 		(Optional) Table of tables in this format for each point for a line {{x,y}, {x2, y2}, ...}

	return: Frame containing all the lines
]]
function GamepadMode.CreateLineHighlight(parentFrame, thickness, color, points)
	assert(type(parentFrame) == "table", "Param parentFrame is of wrong type");
	assert(type(thickness) == "number" or not thickness, "Param thickness is of wrong type");
	assert(type(color) == "table" or not color, "Param color is of wrong type");
	assert(type(points) == "table" or not points, "Param points is of wrong type");

	-- Defaults
	if (not thickness) then thickness = 5 end
	if (not color) then color = {1,1,0,1} end

	-- Set Up Frame
	local frame = CreateFrame("FRAME", nil, parentFrame);
	frame:SetAllPoints();
	frame:SetFrameLevel(1010);
	frame:Hide();

	-- Make this highlight behave like a normal one
	if (parentFrame.LockHighlight) then
		hooksecurefunc(parentFrame, "LockHighlight", function() frame:Show() end);
		hooksecurefunc(parentFrame, "UnlockHighlight", function() frame:Hide() end);
	end

	if (not points) then
		-- Set points to draw higlight around parent
		local width, height = parentFrame:GetSize();
		points = {{-width/2, height/2}, {width/2, height/2}, {width/2, -height/2}, {-width/2, -height/2}};
	end

	frame.highlightLines = {};
	frame.thickness = thickness;
	frame.color = color;

	GamepadMode.UpdateHighlightPoints(frame, points);

	return frame;
end

--[[
	Updates a highlight to use new points

	highlight: 		Highlight frame to update with new points
	newPoints: 		New points to draw the highlight with
]]
function GamepadMode.UpdateHighlightPoints(highlight, newPoints)
	for _, line in ipairs(highlight.highlightLines) do
		line:Hide();
	end

	local thickness = highlight.thickness;

	for i=1, #newPoints, 1 do
		local line = highlight.highlightLines[i];

		if line == nil then
			line = highlight:CreateLine();
			line:SetThickness(highlight.thickness);
			line:SetColorTexture(unpack(highlight.color));

			table.insert(highlight.highlightLines, line);
		end

		line:Show();

		line:SetStartPoint("CENTER", newPoints[i][1], newPoints[i][2]);

		if (i < #newPoints) then
			local xSign = -Sign(newPoints[i][1] - newPoints[i+1][1]);
			local ySign = -Sign(newPoints[i][2] - newPoints[i+1][2]);
			line:SetEndPoint("CENTER", newPoints[i+1][1] + (xSign * (thickness/2)), newPoints[i+1][2] + (ySign * (thickness/2)));
		else
			local xSign = -Sign(newPoints[i][1] - newPoints[1][1]);
			local ySign = -Sign(newPoints[i][2] - newPoints[1][2]);
			line:SetEndPoint("CENTER", newPoints[1][1] + (xSign * (thickness/2)), newPoints[1][2] + (ySign * (thickness/2)));
		end
	end
end
