local _, addonTbl = ...;

-- Set up a private editbox to handle macro execution. This generally isn't
-- needed in glues, however IsMacroEditBox must be defined as other
-- parts of the chat frame which are in glues will call this.

function IsMacroEditBox(editBox)
	return editBox == addonTbl.MacroEditBox;
end

if not C_Glue.IsOnGlueScreen() then
	local function GetDefaultChatEditBox(field)
		return DEFAULT_CHAT_FRAME.editBox;
	end

	addonTbl.MacroEditBox = CreateFrame("Editbox");
	addonTbl.MacroEditBox:Hide();

	local setMacroExecutionCallback = C_Macro.SetMacroExecuteLineCallback;
	C_Macro.SetMacroExecuteLineCallback = nil; -- explicitly only set this once per ui-instance

	EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
		setMacroExecutionCallback(function(line)
			local defaultEditBox = securecall(GetDefaultChatEditBox);
			local macroEditBox = addonTbl.MacroEditBox;
			macroEditBox:SetAttribute("chatType", defaultEditBox:GetAttribute("chatType"));
			macroEditBox:SetAttribute("tellTarget", defaultEditBox:GetAttribute("tellTarget"));
			macroEditBox:SetAttribute("channelTarget", ChatEdit_GetChannelTarget(defaultEditBox));
			macroEditBox:SetText(line);
			ChatEdit_SendText(macroEditBox);
		end);
	end);
end
