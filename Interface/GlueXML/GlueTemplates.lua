function GlueScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or _G[self:GetName() .. "ScrollBar"];
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() / 2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 2));
	end
end

-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
function GlueScrollFrame_Update(frame, numItems, numToDisplay, valueStep, highlightFrame, smallHighlightWidth, bigHighlightWidth )
	-- If more than one screen full of skills then show the scrollbar
	local frameName = frame:GetName();
	local scrollBar = _G[ frameName.."ScrollBar" ];
	if ( numItems > numToDisplay ) then
		frame:Show();
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsShown() ) then
		local scrollChildFrame = frame.ChildFrame or _G[ frameName.."ScrollChildFrame" ];
		local scrollUpButton = _G[ frameName.."ScrollBarScrollUpButton" ];
		local scrollDownButton = _G[ frameName.."ScrollBarScrollDownButton" ];
		local scrollFrameHeight = 0;
		local scrollChildHeight = 0;

		if ( numItems > 0 ) then
			scrollFrameHeight = (numItems - numToDisplay) * valueStep;
			scrollChildHeight = numItems * valueStep;
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0;
			end
			scrollChildFrame:Show();
		else
			scrollChildFrame:Hide();
		end
		scrollBar:SetMinMaxValues(0, scrollFrameHeight);
		scrollBar:SetValueStep(valueStep);
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
	else
		-- Widen because scrollbar is hidden
		if ( highlightFrame ) then
			highlightFrame:SetWidth(bigHighlightWidth);
		end
	end
end

function GlueScrollFrame_OnScrollRangeChanged(self, yrange)
	local scrollbar = _G[self:GetName().."ScrollBar"];
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
		if (self.scrollBarHideable) then
			_G[self:GetName().."ScrollBar"]:Hide();
			_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
			_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
			_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
			_G[scrollbar:GetName().."ScrollDownButton"]:Show();
			_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		end
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		_G[self:GetName().."ScrollBar"]:Show();
		_G[scrollbar:GetName().."ScrollDownButton"]:Enable();
	end
end

function GlueScrollFrame_OnVerticalScroll(self, value)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(value);
	local min;
	local max;
	min, max = scrollbar:GetMinMaxValues();
	if ( value == 0 ) then
		_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
	else
		_G[scrollbar:GetName().."ScrollUpButton"]:Enable();
	end
	if ((scrollbar:GetValue() - max) == 0) then
		_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Enable();
	end
end

function GlueScrollFrame_OnLoad(self)
	_G[self:GetName().."ScrollBarScrollDownButton"]:Disable();
	_G[self:GetName().."ScrollBarScrollUpButton"]:Disable();

	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	self.offset = 0;
end

--Tab stuffs

local TAB_SIDES_PADDING = 30;

function GlueTemplates_TabResize(tab)
	local width = tab.Text:GetStringWidth() + TAB_SIDES_PADDING;
	tab:SetWidth(width);
end

function GlueTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function GlueTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = _G[frame:GetName().."Tab"..i];
			if ( tab.isDisabled ) then
				GlueTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				GlueTemplates_SelectTab(tab);
			else
				GlueTemplates_DeselectTab(tab);
			end
		end
	end
end

function GlueTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function GlueTemplates_DisableTab(frame, index)
	_G[frame:GetName().."Tab"..index].isDisabled = 1;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_EnableTab(frame, index)
	local tab = _G[frame:GetName().."Tab"..index];
	tab.isDisabled = nil;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_DeselectTab(tab)
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Enable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 2);
	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
end

function GlueTemplates_SelectTab(tab)
	tab.Left:Hide();
	tab.Middle:Hide();
	tab.Right:Hide();
	tab:Disable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, -3);
	tab.LeftActive:Show();
	tab.MiddleActive:Show();
	tab.RightActive:Show();
end

function GlueTemplates_SetDisabledTabState(tab)
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Disable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 2);
	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
end

HorizontalResizableCheckButtonMixin = {};

function HorizontalResizableCheckButtonMixin:OnLoad()
	self:SetPressed(false);
end

function HorizontalResizableCheckButtonMixin:OnMouseDown()
	if( self:IsEnabled() ) then
		self.checkedLeft:Show();
		self.checkedRight:Show();
		self.checkedMiddle:Show();

		self:SetPressed(true);
	end
end

function HorizontalResizableCheckButtonMixin:OnMouseUp()
	self:UpdateCheckState();
	self:SetPressed(false);
end

function HorizontalResizableCheckButtonMixin:OnEnter()
	if( self:IsEnabled() ) then
		self.mouseoverLeft:Show();
		self.mouseoverRight:Show();
		self.mouseoverMiddle:Show();
	end
end

function HorizontalResizableCheckButtonMixin:OnLeave()
	self.mouseoverLeft:Hide();
	self.mouseoverRight:Hide();
	self.mouseoverMiddle:Hide();
end

function HorizontalResizableCheckButtonMixin:SetChecked(checked)
	if checked ~= self.checked then
		self.checked = checked and self:IsEnabled();
		self:UpdateCheckState();
	end
end

function HorizontalResizableCheckButtonMixin:UpdateCheckState()
	local checked = self.checked;
	self.checkedLeft:SetShown(checked);
	self.checkedRight:SetShown(checked);
	self.checkedMiddle:SetShown(checked);
end

function HorizontalResizableCheckButtonMixin:SetPressed(isPressed)
	self.isPressed = isPressed;
	self:UpdatePressedState();
end

function HorizontalResizableCheckButtonMixin:UpdatePressedState()
	local offsetFrame = self[self.offsetFrameKey];
	local delta = self.isPressed and self.pressedOffsetDelta or 0;

	offsetFrame:ClearAllPoints();
	offsetFrame:SetPoint("TOPLEFT", offsetFrame:GetParent(), "TOPLEFT", self.normalOffsetX + delta, self.normalOffsetY - delta);
	offsetFrame:SetPoint("TOPRIGHT", offsetFrame:GetParent(), "TOPRIGHT", self.normalOffsetX + delta, self.normalOffsetY - delta);
end
