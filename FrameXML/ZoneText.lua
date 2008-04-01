
AUTOFOLLOW_STATUS_FADETIME = 4.0;

function AutoFollowStatus_OnLoad()
	this:RegisterEvent("AUTOFOLLOW_BEGIN");
	this:RegisterEvent("AUTOFOLLOW_END");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function AutoFollowStatus_OnEvent(event)
	if ( event == "AUTOFOLLOW_BEGIN" ) then
		this.unit = arg1;
		this.fadeTime = nil;
		this:SetAlpha(1.0);
		AutoFollowStatusText:SetText(format(TEXT(AUTOFOLLOWSTART),this.unit));
		this:Show();
	end
	if ( event == "AUTOFOLLOW_END" ) then
		this.fadeTime = AUTOFOLLOW_STATUS_FADETIME;
		AutoFollowStatusText:SetText(format(TEXT(AUTOFOLLOWSTOP),this.unit));
		this:Show();
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this:Hide();
	end
end

function AutoFollowStatus_OnUpdate(elapsed)
	if( this.fadeTime ) then
		if( elapsed >= this.fadeTime ) then
			this:Hide();
		else
			this.fadeTime = this.fadeTime - elapsed;
			local alpha = this.fadeTime / AUTOFOLLOW_STATUS_FADETIME;
			this:SetAlpha(alpha);
		end
	end
end
