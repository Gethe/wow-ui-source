function ModelPreviewFrame_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self.TitleText:SetText(PREVIEW);
end

function ModelPreviewFrame_ShowModel(displayID, allowZoom)
	local frame = ModelPreviewFrame;
	Model_Reset(frame.Display.Model);
	frame.Display.Model:SetDisplayInfo(displayID);

	if ( allowZoom ) then
		frame.Display.Model:SetScript("OnMouseWheel", Model_OnMouseWheel);
	else
		frame.Display.Model:SetScript("OnMouseWheel", nil);
	end

	frame:Show();
end
