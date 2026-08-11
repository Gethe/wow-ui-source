local AddonName = ...;

function GMChatFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function GMChatFrame_OnWhisperFromGM(event, ...)
	if select(1, ...) then
		if GMChatFrame_LoadUI() then
			GMChatFrame_OnEvent(GMChatFrame, event, ...);
		end
	end
end

function RestoreGMChatFrameSession(lastTalkedToGM)
	if not GMChatFrame_LoadUI() then
		return;
	end

	GMChatFrame:Show();

	local info = ChatTypeInfo["WHISPER"];
	GMChatFrame:AddMessage(format(GM_CHAT_LAST_SESSION, "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t " .. GetGMLink(lastTalkedToGM, "[" .. lastTalkedToGM .. "]")), info.r, info.g, info.b, info.id);
	GMChatFrameEditBox:SetTellTarget(lastTalkedToGM);
	GMChatFrameEditBox:SetChatType("WHISPER");
end

function AddGMChatStatusFrameToStatusFrames(statusFrames)
	if C_AddOns.IsAddOnLoaded(AddonName) and GMChatStatusFrame:IsShown() then
		table.insert(statusFrames, GMChatStatusFrame);
	end
end
