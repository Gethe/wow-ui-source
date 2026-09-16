function CharacterFrame_GetTab(tabID)
	do
		local tab = CharacterFrame:GetTab(tabID);
		if tab then
			return tab;
		end
	end

	do
		local tabs = CharacterFrame.ModeTabs and CharacterFrame.ModeTabs.Tabs;
		local tab = tabs and tabs[tabID];
		if tab then
			return tab;
		end
	end
	
	do
		local tabs = CharacterFrame.Tabs;
		local tab = tabs and tabs[tabID];
		if tab then
			return tab;
		end
	end

	local tab = _G["CharacterFrameTab"..tabID];
	return assert(tab, "CharacterFrame tab missing for ID: "..tostring(tabID));
end
