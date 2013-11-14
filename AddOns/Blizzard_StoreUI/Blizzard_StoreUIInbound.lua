--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
function StoreFrame_SetShown(shown)
	StoreFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function StoreFrame_IsShown()
	return StoreFrame:GetAttribute("isshown");
end

function StoreFrame_EscapePressed()
	StoreFrame:SetAttribute("action", "EscapePressed");
	return StoreFrame:GetAttribute("escaperesult");
end

function StoreFrame_PreviewFrameIsShown(isShown)
	StoreFrame:SetAttribute("previewframeshown", isShown);
end