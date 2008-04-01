-- functions to manage tab interfaces where only one tab of a group may be selected
function PanelTemplates_Tab_OnClick(frame)
	PanelTemplates_SetTab(frame, this:GetID())
end

function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = getglobal(frame:GetName().."Tab"..i);
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

function PanelTemplates_TabResize(padding, tab, absoluteSize)
	local tabName;
	if ( tab ) then
		tabName = tab:GetName();
	else
		tabName = this:GetName();
		tab = this;
	end
	local buttonMiddle = getglobal(tabName.."Middle");
	local buttonMiddleDisabled = getglobal(tabName.."MiddleDisabled");
	local sideWidths = 2 * getglobal(tabName.."Left"):GetWidth();
	local tabText = getglobal(tab:GetName().."Text");
	local width, tabWidth;
	
	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = tabText:GetStringWidth() + padding;
		else
			width = tabText:GetStringWidth() + 24;
		end
		tabWidth = width + sideWidths;
		tabText:SetWidth(0);
	end
	
	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end
	
	tab:SetWidth(tabWidth);
	local highlightTexture = getglobal(tabName.."HighlightTexture");
	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

function PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function PanelTemplates_DisableTab(frame, index)
	getglobal(frame:GetName().."Tab"..index).isDisabled = 1;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_EnableTab(frame, index)
	local tab = getglobal(frame:GetName().."Tab"..index);
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Enable();
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Hide();
	getglobal(name.."Middle"):Hide();
	getglobal(name.."Right"):Hide();
	--tab:LockHighlight();
	tab:Disable();
	getglobal(name.."LeftDisabled"):Show();
	getglobal(name.."MiddleDisabled"):Show();
	getglobal(name.."RightDisabled"):Show();
	
	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

function ScrollFrameTemplate_OnMouseWheel(value)
	local scrollBar = getglobal(this:GetName().."ScrollBar");
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() / 2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 2));
	end
end

-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, highlightFrame, smallHighlightWidth, bigHighlightWidth )
	-- If more than one screen full of skills then show the scrollbar
	local frameName = frame:GetName();
	local scrollBar = getglobal( frameName.."ScrollBar" );
	if ( numItems > numToDisplay ) then
		frame:Show();
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsVisible() ) then
		local scrollChildFrame = getglobal( frameName.."ScrollChildFrame" );
		local scrollUpButton = getglobal( frameName.."ScrollBarScrollUpButton" );
		local scrollDownButton = getglobal( frameName.."ScrollBarScrollDownButton" );
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

		-- To handle bad initialization
		if ( scrollBar:GetValue() < 0 ) then
			scrollBar:SetValue(0);
		end
		
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

function FauxScrollFrame_OnVerticalScroll(itemHeight, updateFunction)
	local scrollbar = getglobal(this:GetName().."ScrollBar");
	scrollbar:SetValue(arg1);
	this.offset = floor((arg1 / itemHeight) + 0.5);
	updateFunction();
end

function FauxScrollFrame_GetOffset(frame)
	return frame.offset;
end

function FauxScrollFrame_SetOffset(frame, offset)
	frame.offset = offset;
end

-- Scrollframe functions
function ScrollFrame_OnLoad()
	getglobal(this:GetName().."ScrollBarScrollDownButton"):Disable();
	getglobal(this:GetName().."ScrollBarScrollUpButton"):Disable();
	this.offset = 0;
end

function ScrollFrame_OnScrollRangeChanged(scrollrange)
	local scrollbar = getglobal(this:GetName().."ScrollBar");
	if ( not scrollrange ) then
		scrollrange = this:GetVerticalScrollRange();
	end
	local value = scrollbar:GetValue();
	if ( value > scrollrange ) then
		value = scrollrange;
	end
	scrollbar:SetMinMaxValues(0, scrollrange);
	scrollbar:SetValue(value);
	if ( floor(scrollrange) == 0 ) then
		if (this.scrollBarHideable ) then
			getglobal(this:GetName().."ScrollBar"):Hide();
			getglobal(scrollbar:GetName().."ScrollDownButton"):Hide();
			getglobal(scrollbar:GetName().."ScrollUpButton"):Hide();
		else
			getglobal(scrollbar:GetName().."ScrollDownButton"):Disable();
			getglobal(scrollbar:GetName().."ScrollUpButton"):Disable();
			getglobal(scrollbar:GetName().."ScrollDownButton"):Show();
			getglobal(scrollbar:GetName().."ScrollUpButton"):Show();
		end
		
	else
		getglobal(scrollbar:GetName().."ScrollDownButton"):Show();
		getglobal(scrollbar:GetName().."ScrollUpButton"):Show();
		getglobal(this:GetName().."ScrollBar"):Show();
		getglobal(scrollbar:GetName().."ScrollDownButton"):Enable();
	end
	
	-- Hide/show scrollframe borders
	local top = getglobal(this:GetName().."Top");
	local bottom = getglobal(this:GetName().."Bottom");
	if ( top and bottom and this.scrollBarHideable) then
		if ( this:GetVerticalScrollRange() == 0 ) then
			top:Hide();
			bottom:Hide();
		else
			top:Show();
			bottom:Show();
		end
	end
end

function ScrollingEdit_OnTextChanged(scrollFrame)
	if ( not scrollFrame ) then
		scrollFrame = this:GetParent();
	end
	scrollFrame:UpdateScrollChildRect();
end

function ScrollingEdit_OnCursorChanged(x, y, w, h)
	this.cursorOffset = y;
	this.cursorHeight = h;
end

function ScrollingEdit_OnUpdate(scrollFrame)
	if ( this.cursorOffset ) then
		if ( not scrollFrame ) then
			scrollFrame = this:GetParent();
		end
		local height = scrollFrame:GetHeight();
		local range = scrollFrame:GetVerticalScrollRange();
		local scroll = scrollFrame:GetVerticalScroll();
		local size = height + range;
		local cursorOffset = -this.cursorOffset;
		while ( cursorOffset < scroll ) do
			scroll = (scroll - (height / 2));
			if ( scroll < 0 ) then
				scroll = 0;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end
		while ( (cursorOffset + this.cursorHeight) > (scroll + height) and scroll < range ) do
			scroll = (scroll + (height / 2));
			if ( scroll > range ) then
				scroll = range;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end
		this.cursorOffset = nil;
	end
end
