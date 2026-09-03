function GMError(...)
	if ( IsGMClient() ) then
		error(...);
	end
end

function OnExcessiveErrors()
	StaticPopup_Show("TOO_MANY_LUA_ERRORS");
end
