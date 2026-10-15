
function MultiCastButton_ApplyOverrides(button)
	-- The Mainline button template sizes these textures for 45x45 buttons and anchors them at TOPLEFT.
	local width, height = button:GetSize();
	button.NewActionTexture:SetSize(width, height);
	button.SpellHighlightTexture:SetSize(width, height);
	button.Border:SetSize(width, height);
	button.Flash:SetSize(width, height);
end
