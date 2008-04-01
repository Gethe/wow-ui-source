
function ToggleCombatLog()
	if ( not FCF_IsAdvancedChatEnabled() ) then
		if ( ChatFrame2:IsVisible() ) then
			CombatLogButtons:Hide();
			ChatFrame2:Hide();
			SetCVar("combatLogOn", "0");
		else
			CombatLogButtons:Show();
			ChatFrame2:Show();
			SetCVar("combatLogOn", "1");
		end
	end
	GameTooltip_SetPoint(GameTooltip);
end

function CombatLogUpButton_OnClick(button)
	if ( button == "RightButton" ) then
		ChatFrame2.buttonPressed = "RIGHT";
		ChatFrame2:PageUp();
	elseif ( button == "LeftButton" ) then
		ChatFrame2.buttonPressed = "LEFT";
		ChatFrame2:ScrollUp();
	end
end

function CombatLogDownButton_OnClick(button)
	if ( button == "RightButton" ) then
		ChatFrame2.buttonPressed = "RIGHT";
		ChatFrame2:PageDown();
	elseif ( button == "LeftButton" ) then
		ChatFrame2.buttonPressed = "LEFT";
		ChatFrame2:ScrollDown();
	end
end

function CombatLog_ScrollToBottom()
	ChatFrame2:ScrollToBottom();
end
