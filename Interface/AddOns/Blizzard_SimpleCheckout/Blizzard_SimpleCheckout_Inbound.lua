-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
SimpleCheckoutInboundInterface = {};

function SimpleCheckout_EscapePressed()
	return SimpleCheckoutInboundInterface.EscapePressed();
end

function SimpleCheckoutInboundInterface.IsShown()
	return SimpleCheckout:GetAttribute("isshown");
end

function SimpleCheckoutInboundInterface.EscapePressed()
	-- Escape key presses from ToggleGameMenu() can close housing, shop, and other UIs that brought up SimpleCheckout,
	-- and we don't want Esc to close SimpleCheckout.
	if SimpleCheckout:GetAttribute("isshown") then
		return true;
	end
	return false;
end
