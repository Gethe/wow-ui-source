
function ShowAppropriateDialog(popupType, textArg1, textArg2, data, insertedFrame)
	if IsOnGlueScreen() then
		GlueDialog_Show(popupType, textArg1, data);
	else
		StaticPopup_Show(popupType, textArg1, textArg2, data, insertedFrame);
	end
end

function HideAppropriateDialog(popupType)
	if IsOnGlueScreen() then
		GlueDialog_Hide(popupType);
	else
		StaticPopup_Hide(popupType);
	end
end