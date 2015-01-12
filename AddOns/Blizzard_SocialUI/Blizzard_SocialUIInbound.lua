-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function Social_SetShown(shown)
	SocialPostFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function Social_IsShown()
	return SocialPostFrame:GetAttribute("isshown");
end

function Social_SetText(text)
	SocialPostFrame:SetAttribute("settext", text);
end

function Social_GetText()
	return SocialPostFrame:GetAttribute("gettext");
end

function Social_SetScreenshowView()
	SocialPostFrame:SetAttribute("viewmode", "screenshot");
end

function Social_SetDefaultView()
	SocialPostFrame:SetAttribute("viewmode", "default");
end