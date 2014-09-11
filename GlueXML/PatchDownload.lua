function PatchDownload_OnLoad(self)
	self:SetSequence(0);
	self:SetCamera(0);
end

function PatchDownload_OnShow(self)
	self.PatchDownloadUI.Logo:SetTexture(EXPANSION_LOGOS[GetClientDisplayExpansionLevel()]);
end

function PatchDownload_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		QuitGame();
	elseif ( key == "ENTER" ) then
		QuitGame();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end
