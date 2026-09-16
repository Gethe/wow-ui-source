function ChatFrameEditBoxMixin:ShouldDeactivateChatOnEditFocusLost()
	return self:GetText() == "";
end

function ChatFrameEditBoxMixin:UpdateLanguageHeader()
	local header = _G[self:GetName().."Header"];
	local languageHeaderWidth = 0;
	if (type == "SAY" or type == "YELL") and header:IsShown() and self.language and self.language ~= GetDefaultLanguage() then
		self.languageHeader:Show();
		self.languageHeader:SetWidth(0);
		self.languageHeader:SetText(string.format(CHAT_LANGUAGE_NAME_TAG, self.language));
		languageHeaderWidth = self.languageHeader:GetWidth();
	else
		self.languageHeader:Hide();
	end

	return languageHeaderWidth;
end

function ChatFrameEditBoxMixin:SetFocusRegionVertexColors(color)
	self.focusLeft:SetVertexColor(color.r, color.g, color.b);
	self.focusMid:SetVertexColor(color.r, color.g, color.b);
	self.focusRight:SetVertexColor(color.r, color.g, color.b);
end

function ChatFrameEditBoxMixin:SetFocusRegionsShown(shown)
	self.focusLeft:SetShown(shown);
	self.focusMid:SetShown(shown);
	self.focusRight:SetShown(shown);
end

function ChatFrameEditBoxMixin:UpdateNewcomerEditBoxHint(excludeChannel)
	local shouldBeShown = not self.isGM and not self.header:IsShown() and IsActivePlayerNewcomer();
	if shouldBeShown then
		local localID = ChatFrameUtil.GetFirstChannelIDOfChannelMatchingRuleset(Enum.ChatChannelRuleset.Mentor, excludeChannel);
		self.NewcomerHint:SetShown(localID);

		if localID then
			self:SetAlpha(1.0);
			if self:DoesCurrentChannelTargetMatch(localID) then
				self.NewcomerHint:SetText(NPEV2_CHAT_HELP_HINT_HERE);
			else
				self.NewcomerHint:SetFormattedText(NPEV2_CHAT_HELP_HINT_DIFFERENT, ChatFrameUtil.GetSlashCommandForChannelOpenChat(localID));
			end
		end
	else
		self.NewcomerHint:Hide();
	end

	self.prompt:SetShown(not self.header:IsShown() and not self.NewcomerHint:IsShown());
end
