
function StaticPopup_ResizeWidth(dialog, info)
	local width = nil;

	if (info.showAlert or info.showAlertGear or info.customAlertIcon or info.closeButton or info.wide) then
		width = 420;
	elseif ( info.editBoxWidth and info.editBoxWidth > 260 ) then
		width = 320 + (info.editBoxWidth - 260);
	elseif ( which == "GUILD_IMPEACH" ) then
		width = 375;
	end

	return width;
end

function StaticPopup_SetCloseButtonTexture(closeButton, info)
	if ( info.closeButtonIsHide ) then
		closeButton:SetNormalAtlas("RedButton-Exit");
		closeButton:SetPushedAtlas("RedButton-exit-pressed");
	else
		closeButton:SetNormalAtlas("RedButton-MiniCondense");
		closeButton:SetPushedAtlas("RedButton-MiniCondense-pressed");
	end
end
