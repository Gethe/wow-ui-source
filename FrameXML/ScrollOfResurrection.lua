
function ScrollOfResurrectionButton_OnClick(self)
	ScrollOfResurrection_Show(self.type, self.target, self.text);
end

function ScrollOfResurrection_Show(sendType, target, text)
	ScrollOfResurrectionFrame.type = sendType;
	ScrollOfResurrectionFrame.target = target;
	ScrollOfResurrectionFrame.text = text;
	ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:SetText("");
	
	StaticPopupSpecial_Show(ScrollOfResurrectionFrame);
	
	if ( not ScrollOfResurrectionFrame.type ) then
		ScrollOfResurrectionFrame.targetEditBox:Show();
		ScrollOfResurrectionFrame.targetEditBox:SetText("");
		ScrollOfResurrectionFrame.targetEditBox:SetFocus();
		ScrollOfResurrectionFrame.name:Hide();
	else
		ScrollOfResurrectionFrame.targetEditBox:Hide();
		ScrollOfResurrectionFrame.name:Show();
		ScrollOfResurrectionFrame.name:SetText(text);
		ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:SetFocus();
	end
end

function ScrollOfResurrectionAcceptButton_OnClick(self)
	local comment = ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:GetText();
	if ( ScrollOfResurrectionFrame.type == "bn" ) then
		BNSendSoR(ScrollOfResurrectionFrame.target, comment);
	elseif ( ScrollOfResurrectionFrame.type == "guild" ) then
		GuildRosterSendSoR(ScrollOfResurrectionFrame.target, comment);
	elseif ( not ScrollOfResurrectionFrame.type ) then
		local target = ScrollOfResurrectionFrame.targetEditBox:GetText();
		SendSoRByText(target, comment);
	end
	StaticPopupSpecial_Hide(ScrollOfResurrectionFrame);
end