--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.

function WowToken_IsWowTokenAuctionDialogShown()
	return WowTokenDialog:GetAttribute("isauctiondialogshown");
end

function WowTokenRedemptionFrame_EscapePressed()
	WowTokenRedemptionFrame:SetAttribute("action", "EscapePressed");
	return WowTokenRedemptionFrame:GetAttribute("escaperesult");
end

function WowTokenRedemptionFrame_GetBalanceString()
	WowTokenRedemptionFrame:SetAttribute("getbalancestring");
	return WowTokenRedemptionFrame:GetAttribute("balancestring");
end

function WowTokenRedemptionFrame_ShowDialog(dialogName)
	WowTokenRedemptionFrame:SetAttribute("showdialog", dialogName);
end