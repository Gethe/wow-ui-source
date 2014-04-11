TOOLTIP_DEFAULT_COLOR = { r = 1, g = 1, b = 1 };
TOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.09, g = 0.09, b = 0.19 };

-- Panel Positions
PANEL_INSET_LEFT_OFFSET = 4;
PANEL_INSET_RIGHT_OFFSET = -6;
PANEL_INSET_BOTTOM_OFFSET = 4;
PANEL_INSET_BOTTOM_BUTTON_OFFSET = 26;
PANEL_INSET_TOP_OFFSET = -24;
PANEL_INSET_ATTIC_OFFSET = -60;

-- Magic Button code
function MagicButton_OnLoad(self)
	local leftHandled = false;
	local rightHandled = false;
	
	-- Find out where this button is anchored and adjust positions/separators as necessary
	for i=1, self:GetNumPoints() do
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);
		
		if (relativeTo:GetObjectType() == "Button" and (point == "TOPLEFT" or point == "LEFT")) then
			
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 1, 0);
			end	
			
			if (relativeTo.RightSeparator) then
				-- Modify separator to make it a Middle
				self.LeftSeparator = relativeTo.RightSeparator;
			else
				-- Add a Middle separator
				self.LeftSeparator = self:CreateTexture(self:GetName() and self:GetName().."_LeftSeparator" or nil, "BORDER");
				relativeTo.RightSeparator = self.LeftSeparator;
			end
			
			self.LeftSeparator:SetTexture("Interface\\FrameGeneral\\UI-Frame");
			self.LeftSeparator:SetTexCoord(0.00781250, 0.10937500, 0.75781250, 0.95312500);
			self.LeftSeparator:SetWidth(13);
			self.LeftSeparator:SetHeight(25);
			self.LeftSeparator:SetPoint("TOPRIGHT", self, "TOPLEFT", 5, 1);
			
			leftHandled = true;	
			
		elseif (relativeTo:GetObjectType() == "Button" and (point == "TOPRIGHT" or point == "RIGHT")) then
		
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -1, 0);
			end	
			
			if (relativeTo.LeftSeparator) then
				-- Modify separator to make it a Middle
				self.RightSeparator = relativeTo.LeftSeparator;
			else
				-- Add a Middle separator
				self.RightSeparator = self:CreateTexture(self:GetName() and self:GetName().."_RightSeparator" or nil, "BORDER");
				relativeTo.LeftSeparator = self.RightSeparator;
			end
			
			self.RightSeparator:SetTexture("Interface\\FrameGeneral\\UI-Frame");
			self.RightSeparator:SetTexCoord(0.00781250, 0.10937500, 0.75781250, 0.95312500);
			self.RightSeparator:SetWidth(13);
			self.RightSeparator:SetHeight(25);
			self.RightSeparator:SetPoint("TOPLEFT", self, "TOPRIGHT", -5, 1);
			
			rightHandled = true;
			
		elseif (point == "BOTTOMLEFT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 4, 4);
			end	
			leftHandled = true;
		elseif (point == "BOTTOMRIGHT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -6, 4);
			end
			rightHandled = true;
		elseif (point == "BOTTOM") then
			if (offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 0, 4);
			end
		end	
	end	
	
	-- If this button didn't have a left anchor, add the left border texture
	if (not leftHandled) then
		if (not self.LeftSeparator) then
			-- Add a Left border
			self.LeftSeparator = self:CreateTexture(self:GetName() and self:GetName().."_LeftSeparator" or nil, "BORDER");
			self.LeftSeparator:SetTexture("Interface\\FrameGeneral\\UI-Frame");
			self.LeftSeparator:SetTexCoord(0.24218750, 0.32812500, 0.63281250, 0.82812500);
			self.LeftSeparator:SetWidth(11);
			self.LeftSeparator:SetHeight(25);
			self.LeftSeparator:SetPoint("TOPRIGHT", self, "TOPLEFT", 6, 1);
		end
	end
	
	-- If this button didn't have a right anchor, add the right border texture
	if (not rightHandled) then
		if (not self.RightSeparator) then
			-- Add a Right border
			self.RightSeparator = self:CreateTexture(self:GetName() and self:GetName().."_RightSeparator" or nil, "BORDER");
			self.RightSeparator:SetTexture("Interface\\FrameGeneral\\UI-Frame");
			self.RightSeparator:SetTexCoord(0.90625000, 0.99218750, 0.00781250, 0.20312500);
			self.RightSeparator:SetWidth(11);
			self.RightSeparator:SetHeight(25);
			self.RightSeparator:SetPoint("TOPLEFT", self, "TOPRIGHT", -6, 1);
		end
	end
end

-- ButtonFrameTemplate code
function ButtonFrameTemplate_HideButtonBar(self)
	if self.bottomInset then 
		self.bottomInset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	else
		_G[self:GetName() .. "Inset"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	end
	_G[self:GetName() .. "BtnCornerLeft"]:Hide();
	_G[self:GetName() .. "BtnCornerRight"]:Hide();
	_G[self:GetName() .. "ButtonBottomBorder"]:Hide();
end

function ButtonFrameTemplate_ShowButtonBar(self)
	if self.topInset then 
		self.topInset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
	else
		_G[self:GetName() .. "Inset"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
	end
	_G[self:GetName() .. "BtnCornerLeft"]:Show();
	_G[self:GetName() .. "BtnCornerRight"]:Show();
	_G[self:GetName() .. "ButtonBottomBorder"]:Show();
end

function ButtonFrameTemplate_HideAttic(self)
	if self.topInset then 
		self.topInset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_TOP_OFFSET);
	else
		self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_TOP_OFFSET);
	end
	self.TopTileStreaks:Hide();
end

function ButtonFrameTemplate_ShowAttic(self)
	if self.topInset then 
		self.topInset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET);
	else
		self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET);
	end
	self.TopTileStreaks:Show();
end


function ButtonFrameTemplate_HidePortrait(self)
	self.portrait:Hide();
	self.portraitFrame:Hide();
	self.topLeftCorner:Show();
	self.topBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "TOPRIGHT",  0, 0);
	self.leftBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "BOTTOMLEFT",  0, 0);
end


function ButtonFrameTemplate_ShowPortrait(self)
	self.portrait:Show();
	self.portraitFrame:Show();
	self.topLeftCorner:Hide();
	self.topBorderBar:SetPoint("TOPLEFT", self.portraitFrame, "TOPRIGHT",  0, -10);
	self.leftBorderBar:SetPoint("TOPLEFT", self.portraitFrame, "BOTTOMLEFT",  8, 0);
end

-- A bit ugly, we want the talent frame to display a dialog box in certain conditions.
function PortraitFrameCloseButton_OnClick(self)
	if ( self:GetParent().onCloseCallback) then
		self:GetParent().onCloseCallback(self);
	elseif ( IsOnGlueScreen() ) then
		self:GetParent():Hide();
	else
		HideParentPanel(self);
	end	
end


-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
function FauxScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar )
	-- If more than one screen full of skills then show the scrollbar
	local frameName = frame:GetName();
	local scrollBar = _G[ frameName.."ScrollBar" ];
	local showScrollBar;
	if ( numItems > numToDisplay or alwaysShowScrollBar ) then
		frame:Show();
		showScrollBar = 1;
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsShown() ) then
		local scrollChildFrame = _G[ frameName.."ScrollChildFrame" ];
		local scrollUpButton = _G[ frameName.."ScrollBarScrollUpButton" ];
		local scrollDownButton = _G[ frameName.."ScrollBarScrollDownButton" ];
		local scrollFrameHeight = 0;
		local scrollChildHeight = 0;

		if ( numItems > 0 ) then
			scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
			scrollChildHeight = numItems * buttonHeight;
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0;
			end
			scrollChildFrame:Show();
		else
			scrollChildFrame:Hide();
		end
		local maxRange = (numItems - numToDisplay) * buttonHeight;
		if (maxRange < 0) then
			maxRange = 0;
		end
		scrollBar:SetMinMaxValues(0, maxRange); 
		scrollBar:SetValueStep(buttonHeight);
		scrollBar:SetStepsPerPage(numToDisplay-1);
		scrollChildFrame:SetHeight(scrollChildHeight);
		
		-- Arrow button handling
		if ( scrollBar:GetValue() == 0 ) then
			scrollUpButton:Disable();
		else
			scrollUpButton:Enable();
		end
		if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
			scrollDownButton:Disable();
		else
			scrollDownButton:Enable();
		end
		
		-- Shrink because scrollbar is shown
		if ( highlightFrame ) then
			highlightFrame:SetWidth(smallHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(smallWidth);
			end
		end
	else
		-- Widen because scrollbar is hidden
		if ( highlightFrame ) then
			highlightFrame:SetWidth(bigHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(bigWidth);
			end
		end
	end
	return showScrollBar;
end

function FauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	if ( updateFunction ) then
		updateFunction(self);
	end
end

function FauxScrollFrame_GetOffset(frame)
	return frame.offset;
end

function FauxScrollFrame_SetOffset(frame, offset)
	frame.offset = offset;
end

-- Scrollframe functions
function ScrollFrame_OnLoad(self)
	_G[self:GetName().."ScrollBarScrollDownButton"]:Disable();
	_G[self:GetName().."ScrollBarScrollUpButton"]:Disable();

	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	self.offset = 0;
	
	if ( self.scrollBarHideable ) then
		_G[self:GetName().."ScrollBar"]:Hide();
		_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
		_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
		_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
	end
	if ( self.noScrollThumb ) then
		_G[scrollbar:GetName().."ThumbTexture"]:Hide();
	end
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or _G[self:GetName() .. "ScrollBar"];
	local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
	else
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
	end
end

function ScrollFrame_OnScrollRangeChanged(self, xrange, yrange)
	local scrollbar = self.ScrollBar or _G[self:GetName().."ScrollBar"];
	if ( not yrange ) then
		yrange = self:GetVerticalScrollRange();
	end
	local value = scrollbar:GetValue();
	if ( value > yrange ) then
		value = yrange;
	end
	scrollbar:SetMinMaxValues(0, yrange);
	scrollbar:SetValue(value);
	if ( floor(yrange) == 0 ) then
		if ( self.scrollBarHideable ) then
			_G[self:GetName().."ScrollBar"]:Hide();
			_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
			_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
			_G[scrollbar:GetName().."ThumbTexture"]:Hide();
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
			_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
			_G[scrollbar:GetName().."ScrollDownButton"]:Show();
			_G[scrollbar:GetName().."ScrollUpButton"]:Show();
			if ( not self.noScrollThumb ) then
				_G[scrollbar:GetName().."ThumbTexture"]:Show();
			end
		end
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		_G[self:GetName().."ScrollBar"]:Show();
		if ( not self.noScrollThumb ) then
			_G[scrollbar:GetName().."ThumbTexture"]:Show();
		end
		-- The 0.005 is to account for precision errors
		if ( yrange - value > 0.005 ) then
			_G[scrollbar:GetName().."ScrollDownButton"]:Enable();
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
		end
	end
	
	-- Hide/show scrollframe borders
	local top = _G[self:GetName().."Top"];
	local bottom = _G[self:GetName().."Bottom"];
	local middle = _G[self:GetName().."Middle"];
	if ( top and bottom and self.scrollBarHideable ) then
		if ( self:GetVerticalScrollRange() == 0 ) then
			top:Hide();
			bottom:Hide();
		else
			top:Show();
			bottom:Show();
		end
	end
	if ( middle and self.scrollBarHideable ) then
		if ( self:GetVerticalScrollRange() == 0 ) then
			middle:Hide();
		else
			middle:Show();
		end
	end
end

function ScrollBar_AdjustAnchors(scrollBar, topAdj, bottomAdj, xAdj)
	-- assumes default anchoring of topleft-topright, bottomleft-bottomright
	local topY = 0;
	local bottomY = 0;
	local point, parent, refPoint, x, y;
	for i = 1, 2 do
		point, parent, refPoint, x, y = scrollBar:GetPoint(i);
		if ( point == "TOPLEFT" ) then
			topY = y;
		elseif ( point == "BOTTOMLEFT" ) then
			bottomY = y;
		end
	end
	xAdj = xAdj or 0;
	topAdj = topAdj or 0;
	bottomAdj = bottomAdj or 0;
	scrollBar:SetPoint("TOPLEFT", parent, "TOPRIGHT", x + xAdj, topY + topAdj);
	scrollBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", x + xAdj, bottomY + bottomAdj);
end

function HideParentPanel(self)	
	HideUIPanel(self:GetParent());
end

function EditBox_HandleTabbing(self, tabList)
	local editboxName = self:GetName();
	local index;
	for i=1, #tabList do
		if ( editboxName == tabList[i] ) then
			index = i;
			break;
		end
	end
	if ( IsShiftKeyDown() ) then
		index = index - 1;
	else
		index = index + 1;
	end

	if ( index == 0 ) then
		index = #tabList;
	elseif ( index > #tabList ) then
		index = 1;
	end

	local target = tabList[index];
	_G[target]:SetFocus();
end

function EditBox_ClearFocus (self)
	self:ClearFocus();
end

function EditBox_SetFocus (self)
	self:SetFocus();
end

function EditBox_HighlightText (self)
	self:HighlightText();
end

function EditBox_ClearHighlight (self)
	self:HighlightText(0, 0);
end

function InputBoxInstructions_OnTextChanged(self)
	self.Instructions:SetShown(self:GetText() == "")
end
