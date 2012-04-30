function DestinyFrame_OnEvent(self, event)
	PlaySound("igSpellBookOpen");
	MoveForwardStop();	-- in case the player was moving, need to check if it'll work in blizzcon build
	self:Show();
end
