
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("math");
	Import("PlaySound");
	Import("SOUNDKIT");
end
----------------

--[[All code in this file are deprecated. All variations of HybridScrollFrame and FauxScrollFrame are deprecated. 
	It is VERY HIGHLY encouraged to instead convert to or choose the ScrollBox API for creating scrollable content in your UI.
	Any ScrollFrame intrinsic in this file should be replaced with ScrollFrameTemplate if ScrollBox is not suitable.
	See the ScrollBox and ScrollBar files in the /Scroll directory for API details.]]--

function UIPanelScrollBarScrollUpButton_OnClick(self)
	local parent = self:GetParent();
	local scrollStep = self:GetParent().scrollStep or (parent:GetHeight() / 2);
	parent:SetValue(parent:GetValue() - scrollStep);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function UIPanelScrollBarScrollDownButton_OnClick(self)
	local parent = self:GetParent();
	local scrollStep = self:GetParent().scrollStep or (parent:GetHeight() / 2);
	parent:SetValue(parent:GetValue() + scrollStep);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function UIPanelScrollBar_OnValueChanged(self, value)
	self:GetParent():SetVerticalScroll(value);
end

function UIPanelScrollFrame_OnLoad(self)
	local scrollbar = self.ScrollBar or _G[self:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	self.offset = 0;

	local scrollDownButton = scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"];
	local scrollUpButton = scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"];

	scrollDownButton:Disable();
	scrollUpButton:Disable();

	if ( self.scrollBarHideable ) then
		scrollbar:Hide();
		scrollDownButton:Hide();
		scrollUpButton:Hide();
	else
		scrollDownButton:Disable();
		scrollUpButton:Disable();
		scrollDownButton:Show();
		scrollUpButton:Show();
	end
	if ( self.noScrollThumb ) then
		(scrollbar.ThumbTexture or _G[scrollbar:GetName().."ThumbTexture"]):Hide();
	end
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or self.ScrollBar or _G[self:GetName() .. "ScrollBar"];
	local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
	else
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
	end
end

function ScrollFrame_OnScrollRangeChanged(self, xrange, yrange)
	local name = self:GetName();
	local scrollbar = self.ScrollBar or _G[name.."ScrollBar"];
	if ( not yrange ) then
		yrange = self:GetVerticalScrollRange();
	end

	-- Accounting for very small ranges
	yrange = math.floor(yrange);

	local value = math.min(scrollbar:GetValue(), yrange);
	scrollbar:SetMinMaxValues(0, yrange);
	scrollbar:SetValue(value);

	local scrollDownButton = scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"];
	local scrollUpButton = scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"];
	local thumbTexture = scrollbar.ThumbTexture or _G[scrollbar:GetName().."ThumbTexture"];

	if ( yrange == 0 ) then
		if ( self.scrollBarHideable ) then
			scrollbar:Hide();
			scrollDownButton:Hide();
			scrollUpButton:Hide();
			thumbTexture:Hide();
		else
			scrollDownButton:Disable();
			scrollUpButton:Disable();
			scrollDownButton:Show();
			scrollUpButton:Show();
			if ( not self.noScrollThumb ) then
				thumbTexture:Show();
			end
		end
	else
		scrollDownButton:Show();
		scrollUpButton:Show();
		scrollbar:Show();
		if ( not self.noScrollThumb ) then
			thumbTexture:Show();
		end
		-- The 0.005 is to account for precision errors
		if ( yrange - value > 0.005 ) then
			scrollDownButton:Enable();
		else
			scrollDownButton:Disable();
		end
	end

	-- Hide/show scrollframe borders
	local top = self.Top or name and _G[name.."Top"];
	local bottom = self.Bottom or name and _G[name.."Bottom"];
	local middle = self.Middle or name and _G[name.."Middle"];
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

function ScrollFrame_OnVerticalScroll(self, offset)
	local scrollbar = self.ScrollBar or _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);

	local min, max = scrollbar:GetMinMaxValues();
	(scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"]):SetEnabled(offset ~= 0);
	(scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"]):SetEnabled((scrollbar:GetValue() - max) ~= 0);
end

function ScrollFrame_SetScrollOffset(self, scrollOffset)
	local scrollbar = self.ScrollBar or _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(scrollOffset);
end


function FauxScrollFrame_GetChildFrames(frame)
	local frameName = frame:GetName();
	if frameName then
		return _G[ frameName.."ScrollBar" ], _G[ frameName.."ScrollChildFrame" ], _G[ frameName.."ScrollBarScrollUpButton" ], _G[ frameName.."ScrollBarScrollDownButton" ];
	else
		return frame.ScrollBar, frame.ScrollChildFrame, frame.ScrollBar.ScrollUpButton, frame.ScrollBar.ScrollDownButton;
	end
end

function FauxScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar)
	local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton = FauxScrollFrame_GetChildFrames(frame);
	-- If more than one screen full of items then show the scrollbar
	local showScrollBar;
	if ( numItems > numToDisplay or alwaysShowScrollBar ) then
		frame:Show();
		showScrollBar = 1;
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsShown() ) then
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
	local scrollbar = FauxScrollFrame_GetChildFrames(self);
	scrollbar:SetValue(value);
	self.offset = math.floor((value / itemHeight) + 0.5);
	if ( updateFunction ) then
		updateFunction(self);
	end
end

function FauxScrollFrame_GetOffset(frame)
	return frame.offset or 0;
end

function FauxScrollFrame_SetOffset(frame, offset)
	frame.offset = offset;
end

function UIPanelInputScrollFrame_OnLoad(self)
	local scrollBar = self.ScrollBar;
	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -13, -11);
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -13, 9);
	-- reposition the up and down buttons
	self.ScrollBar.ScrollDownButton:SetPoint("TOP", scrollBar, "BOTTOM", 0, 4);
	self.ScrollBar.ScrollUpButton:SetPoint("BOTTOM", scrollBar, "TOP", 0, -4);
	-- make the scroll bar hideable and force it to start off hidden so positioning calculations can be done
	-- as soon as it needs to be shown
	self.scrollBarHideable = 1;
	scrollBar:Hide();
	self.EditBox:SetWidth(self:GetWidth() - 18);
	self.EditBox:SetMaxLetters(self.maxLetters);
	self.EditBox.Instructions:SetText(self.instructions);
	self.EditBox.Instructions:SetWidth(self:GetWidth());
	self.CharCount:SetShown(not self.hideCharCount);
end