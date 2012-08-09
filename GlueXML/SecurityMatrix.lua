SECURITYMATRIX_NUM_ROWS = 10;
SECURITYMATRIX_NUM_COLUMNS = 8;
SECURITYMATRIX_GRID_SIZE = 32;
SECURITYMATRIX_CELL_HIGHLIGHT_SCALE = 1.2; --2.0 is good for 64 pixel cells, 0.8 is good for 32 pixel cells
SECURITYMATRIX_GRID_OVERLAP = 6;
SECURITYMATRIX_HIGHLIGHT_OVERHANG = 4;
SECURITYMATRIX_PINWHEEL_BUTTON_SIZE = 32;
SECURITYMATRIX_PINWHEEL_VERTICAL_OFFSET = 18;
SECURITYMATRIX_NUM_MIN_DIGITS = 2;
SECURITYMATRIX_NUM_MAX_DIGITS = 2;
-- Default is Columns are Alphabetic, rows are numeric.
SECURITYMATRIX_FLIP_COORDS = false;
SECURITYMATRIX_TEXT_LENGTH = 0
SECURITYMATRIX_ALL_COLUMN_HEADERS = {}
SECURITYMATRIX_ALL_ROW_HEADERS = {}
SECURITYMATRIX_ALL_ELEMENTS = {}

SecurityMatrix_Alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

SecurityMatrix_currentColumn = 1;
SecurityMatrix_currentRow = 1;
SecurityMatrix_currentValue = 0;
SecurityMatrix_isMoving = false;
SecurityMatrix_updateSpeed = 0.005;

-------------------------------------------------------------------------------

function SecurityMatrix_CreateHeaders()
	local prevFrame = nil;
	for i=1, SECURITYMATRIX_NUM_ROWS do
		local newFrame = SECURITYMATRIX_ALL_ROW_HEADERS[i]
		if not newFrame then
			newFrame = CreateFrame("Frame", "SecurityMatrixFrameRowHeader"..i, SecurityMatrixFrame, "SecurityMatrixHeaderElementTextFrameTemplate");
			SECURITYMATRIX_ALL_ROW_HEADERS[i] = newFrame
		end
		newFrame:Show()
		if(i == 1) then
			newFrame:SetPoint("TOPLEFT", 0, -(SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP));
		else
			newFrame:SetPoint("TOP", prevFrame, "BOTTOM", 0, SECURITYMATRIX_GRID_OVERLAP);
		end
		newFrame:SetWidth(SECURITYMATRIX_GRID_SIZE);
		newFrame:SetHeight(SECURITYMATRIX_GRID_SIZE);
		if SECURITYMATRIX_FLIP_COORDS then
			_G["SecurityMatrixFrameRowHeader"..i.."Text"]:SetText(SecurityMatrix_Alphabet[i])
		else
			_G["SecurityMatrixFrameRowHeader"..i.."Text"]:SetText(i);
		end
		_G["SecurityMatrixFrameRowHeader"..i]:SetID(i);
		prevFrame = newFrame;
	end
	for i=1, SECURITYMATRIX_NUM_COLUMNS do
		local newFrame = SECURITYMATRIX_ALL_COLUMN_HEADERS[i]
		if not newFrame then
			newFrame = CreateFrame("Frame", "SecurityMatrixFrameColumnHeader"..i, SecurityMatrixFrame, "SecurityMatrixHeaderElementTextFrameTemplate");
			SECURITYMATRIX_ALL_COLUMN_HEADERS[i] = newFrame
		end
		newFrame:Show()
		if(i == 1) then
			newFrame:SetPoint("TOPLEFT", (SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP), 0);
		else
			newFrame:SetPoint("LEFT", prevFrame, "RIGHT", -SECURITYMATRIX_GRID_OVERLAP, 0);
		end
		newFrame:SetWidth(SECURITYMATRIX_GRID_SIZE);
		newFrame:SetHeight(SECURITYMATRIX_GRID_SIZE);
		if SECURITYMATRIX_FLIP_COORDS then
			_G["SecurityMatrixFrameColumnHeader"..i.."Text"]:SetText(tostring(i))
		else
			_G["SecurityMatrixFrameColumnHeader"..i.."Text"]:SetText(SecurityMatrix_Alphabet[i]);
		end
		_G["SecurityMatrixFrameColumnHeader"..i]:SetID(i);
		prevFrame = newFrame;
	end
end

function SecurityMatrix_HideHeaders()
	for i, v in ipairs(SECURITYMATRIX_ALL_COLUMN_HEADERS) do
		v:Hide()
	end
	for i, v in ipairs(SECURITYMATRIX_ALL_ROW_HEADERS) do
		v:Hide()
	end
end

function SecurityMatrix_CreateElements()
	local prevFrame, prevBackgroundFrame = nil, nil;
	--loop through all the rows
	for i=1, SECURITYMATRIX_NUM_ROWS do
		--loop through all the columns
		if not SECURITYMATRIX_ALL_ELEMENTS[i] then SECURITYMATRIX_ALL_ELEMENTS[i] = {} end
		for j=1, SECURITYMATRIX_NUM_COLUMNS do
			--create a new frame and name it with a suffix of column+row
			if not SECURITYMATRIX_ALL_ELEMENTS[i][j] then SECURITYMATRIX_ALL_ELEMENTS[i][j] = {} end
			local newBackgroundFrame = SECURITYMATRIX_ALL_ELEMENTS[i][j].background
			if not newBackgroundFrame then
				newBackgroundFrame = CreateFrame("Frame", "$parentElement"..i.."_"..j, SecurityMatrixFrame, "SecurityMatrixElementFrameTemplate");
				SECURITYMATRIX_ALL_ELEMENTS[i][j].background = newBackgroundFrame
			end
			newBackgroundFrame:Show()
			local newSparkleFrame = SECURITYMATRIX_ALL_ELEMENTS[i][j].sparkle
			if not newSparkleFrame then
				newSparkleFrame = CreateFrame("Frame", "$parentElementSparkle"..i.."_"..j, SecurityMatrixFrame, "SecurityMatrixElementSparkleFrameTemplate");
				SECURITYMATRIX_ALL_ELEMENTS[i][j].sparkle = newSparkleFrame
			end
			newSparkleFrame:Show()
			--if this is the first frame then anchor it to the top left of the parent frame
			if(j == 1) then
				newBackgroundFrame:SetPoint("TOPLEFT", (SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP), -((SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)*(i)));
			else
				newBackgroundFrame:SetPoint("LEFT", prevBackgroundFrame, "RIGHT", -SECURITYMATRIX_GRID_OVERLAP, 0);
			end
			--increment the frame layer for each frame so that they tile a little nicer
			newBackgroundFrame:SetFrameLevel(i*SECURITYMATRIX_NUM_COLUMNS + j + 10);
			--set the width/height here so we can change it easily without having to find it in the XML
			newBackgroundFrame:SetWidth(SECURITYMATRIX_GRID_SIZE);
			newBackgroundFrame:SetHeight(SECURITYMATRIX_GRID_SIZE);
			--line the text frame and highlight up with the background frame
			newSparkleFrame:SetAllPoints(newBackgroundFrame);
--			_G["SecurityMatrixFrameElementSparkle"..i.."_"..j.."Highlight"]:SetModelScale(SECURITYMATRIX_CELL_HIGHLIGHT_SCALE);
--			_G["SecurityMatrixFrameElementSparkle"..i.."_"..j.."Highlight"]:SetWidth(SECURITYMATRIX_GRID_SIZE);
--			_G["SecurityMatrixFrameElementSparkle"..i.."_"..j.."Highlight"]:SetHeight(SECURITYMATRIX_GRID_SIZE);
			prevBackgroundFrame = newBackgroundFrame;
		end
	end
end

function SecurityMatrix_HideElements()
	for columnNum, column in ipairs(SECURITYMATRIX_ALL_ELEMENTS) do
		for rowNum, cell in ipairs(column) do
			SECURITYMATRIX_ALL_ELEMENTS[columnNum][rowNum].background:Hide()
			SECURITYMATRIX_ALL_ELEMENTS[columnNum][rowNum].sparkle:Hide()
		end
	end
end

function SecurityMatrix_NewCoordinate(row, column)
	--start the movement animation
	SecurityMatrix_isMoving = true;
	
	--turn off the sparkle on the old cell
--	_G["SecurityMatrixFrameElementSparkle"..SecurityMatrix_currentRow.."_"..SecurityMatrix_currentColumn.."Highlight"]:Hide();
	_G["SecurityMatrixFrameElementSparkle"..SecurityMatrix_currentRow.."_"..SecurityMatrix_currentColumn.."Texture"]:Hide();
	
	--turn off the text highlight on the old row/column headers
	if SECURITYMATRIX_FLIP_COORDS then
		_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn.."Text"]:SetText(_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn]:GetID());
		_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow.."Text"]:SetText(SecurityMatrix_Alphabet[_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow]:GetID()]);
	else
		_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow.."Text"]:SetText(_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow]:GetID());
		_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn.."Text"]:SetText(SecurityMatrix_Alphabet[_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn]:GetID()]);
	end
	
	--set the new row/column
	SecurityMatrix_currentRow = row;
	SecurityMatrix_currentColumn = column;
	
	--turn on the sparkle on the new cell
--	_G["SecurityMatrixFrameElementSparkle"..SecurityMatrix_currentRow.."_"..SecurityMatrix_currentColumn.."Highlight"]:Show();
	_G["SecurityMatrixFrameElementSparkle"..SecurityMatrix_currentRow.."_"..SecurityMatrix_currentColumn.."Texture"]:Show();
	
	--turn on the text highlight on the new row/column headers
	if SECURITYMATRIX_FLIP_COORDS then
		_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn.."Text"]:SetText("|cFF00FF00".._G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn]:GetID().."|r");
		_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow.."Text"]:SetText("|cFF00FF00"..SecurityMatrix_Alphabet[_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow]:GetID()].."|r");
	else
		_G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow.."Text"]:SetText("|cFF00FF00".._G["SecurityMatrixFrameRowHeader"..SecurityMatrix_currentRow]:GetID().."|r");
		_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn.."Text"]:SetText("|cFF00FF00"..SecurityMatrix_Alphabet[_G["SecurityMatrixFrameColumnHeader"..SecurityMatrix_currentColumn]:GetID()].."|r");
	end
	
	--set the direction text to mention the new cell
	if SECURITYMATRIX_FLIP_COORDS then
		SecurityMatrixKeypadDirections:SetText(string.format(SECURITYMATRIX_ENTER_CELL, SecurityMatrix_Alphabet[SecurityMatrix_currentRow], SecurityMatrix_currentColumn));
	else
		SecurityMatrixKeypadDirections:SetText(string.format(SECURITYMATRIX_ENTER_CELL, SecurityMatrix_Alphabet[SecurityMatrix_currentColumn], SecurityMatrix_currentRow));
	end
	
	--set a flag so the update function knows we are just starting a move
	SecurityMatrix_startMoving = true;
end

function SecurityMatrix_GetNewCoordinates()
	--get the next set of coordinates
	local notDone, x, y = GetMatrixCoordinates();
	--if we are done entering numbers then hide the matrix
	if(not notDone) then
		SecurityMatrixLoginFrame:Hide();
		return;
	end
	--move to the next set of coordinates
	SecurityMatrix_NewCoordinate(y + 1, x + 1);
	--enable the rotating buttons
	SecurityMatrixPinwheel_EnableNumbers();
end

function SecurityMatrix_ButtonClick(self)
	-- Don't allow too many digits
	if(SECURITYMATRIX_TEXT_LENGTH >= SECURITYMATRIX_NUM_MAX_DIGITS) then return end

	--show another star to the user 
	SecurityMatrix_SetShownLength(SECURITYMATRIX_TEXT_LENGTH+1)
	-- If we have enough digits, enable the Ok button
	if(SECURITYMATRIX_TEXT_LENGTH >= SECURITYMATRIX_NUM_MIN_DIGITS) then
		--enable the OK button if we have both digits
		SecurityMatrixKeypadButtonOK:Enable();
	end
	
	-- If we've hit the max, disable the inputs
	if(SECURITYMATRIX_TEXT_LENGTH >= SECURITYMATRIX_NUM_MAX_DIGITS) then
		--disable the rotating buttons so the user doesn't enter more
		SecurityMatrixPinwheel_DisableNumbers();
	end
	
	-- Send the number to the client
	MatrixEntered(self:GetID());
	--enable the clear button if it's not already
	SecurityMatrixKeypadButtonClear:Enable();
end

function SecurityMatrix_OKClick()
	--don't move on to the next coordinate if this one is not filled in
	if(SECURITYMATRIX_TEXT_LENGTH < SECURITYMATRIX_NUM_MIN_DIGITS) then return; end
	--clear the *s
	SecurityMatrix_SetShownLength(0)
	--enter the coordinates
	MatrixCommit();
	SecurityMatrix_GetNewCoordinates();
	--disable the OK button until we have two digits from the user
	SecurityMatrixKeypadButtonOK:Disable();
	SecurityMatrixKeypadButtonClear:Disable();
end

function SecurityMatrix_ClearClick()
	MatrixRevert();
	--hide the current cell *s
	SecurityMatrix_SetShownLength(0)
	--disable the clear and OK buttons
	SecurityMatrixKeypadButtonClear:Disable();
	SecurityMatrixKeypadButtonOK:Disable();
	--enable the rotating buttons
	SecurityMatrixPinwheel_EnableNumbers();
end

function SecurityMatrix_SetShownLength(length)
	SecurityMatrixKeypadEntryDigits:SetText(string.rep('*', length))
	SECURITYMATRIX_TEXT_LENGTH = length
end

function SecurityMatrix_OnLoad()
	SecurityMatrixFrame.timeSinceLastUpdate = 0;
	SecurityMatrix_CreateElements();
	SecurityMatrix_CreateHeaders();
	
	SecurityMatrixFrameHorizontalHighlightSlider:SetWidth((SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)*(SECURITYMATRIX_NUM_COLUMNS+1) + (SECURITYMATRIX_HIGHLIGHT_OVERHANG + SECURITYMATRIX_GRID_OVERLAP));
	SecurityMatrixFrameHorizontalHighlightSlider:SetHeight(SECURITYMATRIX_GRID_SIZE+SECURITYMATRIX_HIGHLIGHT_OVERHANG*2);
	SecurityMatrixFrameVerticalHighlightSlider:SetHeight((SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)*(SECURITYMATRIX_NUM_ROWS+1) + (SECURITYMATRIX_HIGHLIGHT_OVERHANG + SECURITYMATRIX_GRID_OVERLAP));
	SecurityMatrixFrameVerticalHighlightSlider:SetWidth(SECURITYMATRIX_GRID_SIZE+SECURITYMATRIX_HIGHLIGHT_OVERHANG*2);
	SecurityMatrixFrame:SetWidth((SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)*(SECURITYMATRIX_NUM_COLUMNS+1) + (SECURITYMATRIX_HIGHLIGHT_OVERHANG + SECURITYMATRIX_GRID_OVERLAP));
	SecurityMatrixFrame:SetHeight((SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)*(SECURITYMATRIX_NUM_ROWS+1) + (SECURITYMATRIX_HIGHLIGHT_OVERHANG + SECURITYMATRIX_GRID_OVERLAP));
end

function SecurityMatrixLoginFrame_OnLoad()
	SecurityMatrixLoginFrame:RegisterEvent("PLAYER_ENTER_MATRIX");
	SecurityMatrixLoginFrame:EnableKeyboard(true);
	
	SecurityMatrixKeypadDirections:SetPoint("TOPLEFT", SecurityMatrixFrame, "TOPRIGHT", 0, 16);
	SecurityMatrixKeypadDirections:SetPoint("BOTTOMRIGHT", SecurityMatrixKeypadFrame, "TOPRIGHT", 0, 4);
	
	SecurityMatrixLoginFrame:SetWidth(SecurityMatrixFrame:GetWidth() + SecurityMatrixKeypadFrame:GetWidth() + 16);
	SecurityMatrixLoginFrame:SetHeight(math.max(SecurityMatrixFrame:GetHeight(), SecurityMatrixKeypadFrame:GetHeight() + SecurityMatrixKeypadDirections:GetHeight()) + 58);
	
	SecurityMatrixKeypadButtonOK:Disable();
	SecurityMatrixKeypadButtonClear:Disable();
end

function SecurityMatrixLoginFrame_Adjust()
	SecurityMatrixKeypadDirections:SetWidth(SecurityMatrixKeypadFrame:GetWidth())
	SecurityMatrixLoginFrame:SetHeight(math.max(SecurityMatrixFrame:GetHeight(), SecurityMatrixKeypadFrame:GetHeight() + SecurityMatrixKeypadDirections:GetHeight()) + 58);
end


function SecurityMatrix_Cleanup()
	SecurityMatrix_HideHeaders();
	SecurityMatrix_HideElements();
end

function SecurityMatrixLoginFrame_OnEvent(event, height, width, minDigits, maxDigits, flipCoords)
	if(event == "PLAYER_ENTER_MATRIX") then
		SecurityMatrix_Cleanup();
		SECURITYMATRIX_NUM_COLUMNS = height;
		SECURITYMATRIX_NUM_ROWS = width;
		SECURITYMATRIX_NUM_MIN_DIGITS = minDigits;
		SECURITYMATRIX_NUM_MAX_DIGITS = maxDigits;
		SECURITYMATRIX_FLIP_COORDS = flipCoords
		SecurityMatrix_OnLoad();
		SecurityMatrixLoginFrame_OnLoad();
		SecurityMatrix_GetNewCoordinates();
		SecurityMatrixLoginFrame_Adjust();
		SecurityMatrixLoginFrame:Show();
	end
end

function SecurityMatrix_OnUpdateFade(self, elapsed)
	--don't do anything if the security matrix isn't currently fading in
	if(not SecurityMatrix_isMoving) then
		self.timeSinceLastUpdate = 0;
		return;
	end
	
	--if this is the first run then setup the highlights
	if(SecurityMatrix_startMoving) then
		--move the highlight bars to the appropriate location and fade them all the way out
		SecurityMatrixFrameHorizontalHighlightSlider:SetPoint("TOPLEFT", 0, -((SecurityMatrix_currentRow)*(SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)-SECURITYMATRIX_HIGHLIGHT_OVERHANG));
		SecurityMatrixFrameVerticalHighlightSlider:SetPoint("TOPLEFT", ((SecurityMatrix_currentColumn)*(SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)-SECURITYMATRIX_HIGHLIGHT_OVERHANG), 0);
		SecurityMatrixFrameHorizontalHighlightSlider:SetAlpha(0.0);
		SecurityMatrixFrameVerticalHighlightSlider:SetAlpha(0.0);
		SecurityMatrix_startMoving = false;
	end
	
	--update the time since our last update
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed;
	--keep the fading frame rate independant, increasing 1% every update
	while(self.timeSinceLastUpdate > SecurityMatrix_updateSpeed) do
		if(SecurityMatrixFrameVerticalHighlightSlider:GetAlpha() ~= 1.0) then
			SecurityMatrixFrameVerticalHighlightSlider:SetAlpha(SecurityMatrixFrameVerticalHighlightSlider:GetAlpha() + 0.01);
		elseif(SecurityMatrixFrameHorizontalHighlightSlider:GetAlpha() ~= 1.0) then
			SecurityMatrixFrameHorizontalHighlightSlider:SetAlpha(SecurityMatrixFrameHorizontalHighlightSlider:GetAlpha() + 0.01);
		else
			SecurityMatrix_isMoving = false;
		end
		self.timeSinceLastUpdate = self.timeSinceLastUpdate - SecurityMatrix_updateSpeed;
	end
end

function SecurityMatrix_OnUpdateSlide(self, elapsed)
	--don't do anything if the security matrix isn't currently moving
	if(not SecurityMatrix_isMoving) then
		self.timeSinceLastUpdate = 0;
		return;
	end
	
	--if this is the first run then setup the slider
	if(SecurityMatrix_startMoving) then
		--set the new row/column goal coordinates (so we don't have to keep calculating them over and over)
		SecurityMatrixFrame.goalHorizontalOffset = -((SecurityMatrix_currentRow)*(SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)-SECURITYMATRIX_HIGHLIGHT_OVERHANG);
		SecurityMatrixFrame.goalVerticalOffset = ((SecurityMatrix_currentColumn)*(SECURITYMATRIX_GRID_SIZE-SECURITYMATRIX_GRID_OVERLAP)-SECURITYMATRIX_HIGHLIGHT_OVERHANG);
		SecurityMatrix_startMoving = false;
	end
	
	--make the sliders visible, otherwise the fade code will make the sliders invisible
	SecurityMatrixFrameHorizontalHighlightSlider:SetAlpha(1.0);
	SecurityMatrixFrameVerticalHighlightSlider:SetAlpha(1.0);
	
	--update the time since our last update
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed;
	--keep the animation frame rate independant moving every 0.01 seconds
	while(self.timeSinceLastUpdate > SecurityMatrix_updateSpeed) do
		--get the current yOffset for the horizontal highlight
		local horizontalPoint, horizontalRelativeTo, horizontalRelativePoint, horizontalXOfs, horizontalYOfs = SecurityMatrixFrameHorizontalHighlightSlider:GetPoint(1)
		--fix the floating point errors in WoW UI coordinates
		horizontalYOfs = floor(horizontalYOfs+0.5);
		--if the horizontal highlight is below the target row then move it up
		if(horizontalYOfs < self.goalHorizontalOffset) then
			SecurityMatrixFrameHorizontalHighlightSlider:ClearAllPoints();
			SecurityMatrixFrameHorizontalHighlightSlider:SetPoint("TOPLEFT", 0, horizontalYOfs + 1);
		--if the horizontal highlight is above the target row then move it down
		elseif(horizontalYOfs > self.goalHorizontalOffset) then
			SecurityMatrixFrameHorizontalHighlightSlider:ClearAllPoints();
			SecurityMatrixFrameHorizontalHighlightSlider:SetPoint("TOPLEFT", 0, horizontalYOfs - 1);
		end
		
		--get the current yOffset for the horizontal highlight
		local verticalPoint, verticalRelativeTo, verticalRelativePoint, verticalXOfs, verticalYOfs = SecurityMatrixFrameVerticalHighlightSlider:GetPoint(1)
		--fix the floating point errors in WoW UI coordinates
		verticalXOfs = floor(verticalXOfs+0.5);
		--if the vertical highlight is below the target row then move it up
		if(verticalXOfs+0.5 < self.goalVerticalOffset) then
			SecurityMatrixFrameVerticalHighlightSlider:ClearAllPoints();
			SecurityMatrixFrameVerticalHighlightSlider:SetPoint("TOPLEFT", verticalXOfs + 1, 0);
		--if the vertical highlight is above the target row then move it down
		elseif(verticalXOfs > self.goalVerticalOffset) then
			SecurityMatrixFrameVerticalHighlightSlider:ClearAllPoints();
			SecurityMatrixFrameVerticalHighlightSlider:SetPoint("TOPLEFT", verticalXOfs - 1, 0);
		end
		
		--check to see if we are done moving
		if(verticalXOfs == self.goalVerticalOffset and horizontalYOfs == self.goalHorizontalOffset) then
			SecurityMatrix_isMoving = false;
		end
		
		--we are done with this update frame, go on to the next
		self.timeSinceLastUpdate = self.timeSinceLastUpdate - SecurityMatrix_updateSpeed;
	end
end

function SecurityMatrixPinwheel_OnLoad(self)
	self.angle = 36 * self:GetID();
	self.timeSinceLastUpdate = 0;
	self:SetWidth(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE);
	self:SetHeight(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE);
	self:SetPoint("CENTER", SecurityMatrixKeypadFrame, "CENTER", (-(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE*2) * math.cos(self.angle * (math.pi/180))), (15+(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE*2) * math.sin(self.angle * (math.pi/180))));
end

function SecurityMatrixPinwheel_OnShow(self)
	self.stopSpinning = false;
end

function SecurityMatrixPinwheel_OnHide(self)
	self.stopSpinning = true;
end

function SecurityMatrixPinwheel_OnUpdate(self, elapsed)
	if(self.stopSpinning) then
		self.timeSinceLastUpdate = 0;
		return;
	end
	
	local cursorX, cursorY = GetCursorPosition(SecurityMatrixKeypadFrame);
	local centerX, centerY = SecurityMatrixKeypadFrame:GetCenter();
	local xOffset = cursorX - centerX;
	local yOffset = cursorY - centerY - SECURITYMATRIX_PINWHEEL_VERTICAL_OFFSET;
	local distance = math.sqrt(xOffset*xOffset + yOffset*yOffset);
	
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed;
	while(self.timeSinceLastUpdate > 0.01) do
		self.timeSinceLastUpdate = self.timeSinceLastUpdate - 0.01;
		if(SecurityMatrixKeypadFrame.superSpin) then
			self.angle = self.angle + 3;
		else
			self.angle = self.angle + (distance - SECURITYMATRIX_PINWHEEL_BUTTON_SIZE*2)/100;
		end
		if(self.angle > 360) then
			self.angle = self.angle-360;
		end
		self:ClearAllPoints();
		self:SetPoint("CENTER", SecurityMatrixKeypadFrame, "CENTER", (-(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE*2) * math.cos(self.angle * (math.pi/180))), (SECURITYMATRIX_PINWHEEL_VERTICAL_OFFSET+(SECURITYMATRIX_PINWHEEL_BUTTON_SIZE*2) * math.sin(self.angle * (math.pi/180))));
	end
end

function SecurityMatrixPinwheel_HideNumbers()
	for i=0, 9, 1 do
		local button = _G["SecurityMatrixPinwheelButton"..i];
		button:SetText("");
		button.stopSpinning = true;
	end
end

function SecurityMatrixPinwheel_ShowNumbers()
	for i=0, 9, 1 do
		local button = _G["SecurityMatrixPinwheelButton"..i];
		button:SetText(i);
		button.stopSpinning = false;
	end
end

function SecurityMatrixPinwheel_EnableNumbers()
	for i=0, 9, 1 do
		local button = _G["SecurityMatrixPinwheelButton"..i];
		button:Enable();
	end
end

function SecurityMatrixPinwheel_DisableNumbers()
	for i=0, 9, 1 do
		local button = _G["SecurityMatrixPinwheelButton"..i];
		button:Disable();
	end
end
