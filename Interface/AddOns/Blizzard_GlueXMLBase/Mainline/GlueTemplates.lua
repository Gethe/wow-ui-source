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