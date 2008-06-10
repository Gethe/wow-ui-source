function TicTacToe_Update()
	TicTacToe_UpdateGameState(GetMinigameState());
end

function TicTacToe_UpdateGameState(...)
	local player;
	local button;
	for i=1, arg.n do
		player = arg[i];
		button = getglobal("TicTacToeFrameButton"..i);
		if ( player == 1 ) then
			button:SetDisabledTexture("Interface\\TicTacToeFrame\\TicTacToe-X");
			button:Disable();
		elseif ( player == 0 ) then
			button:SetDisabledTexture("Interface\\TicTacToeFrame\\TicTacToe-O");
			button:Disable();
		else
			button:SetNormalTexture("");
			button:SetDisabledTexture("");
			button:Enable();
		end
	end
end