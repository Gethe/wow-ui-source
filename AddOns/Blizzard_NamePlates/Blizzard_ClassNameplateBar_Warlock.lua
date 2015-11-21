ClassNameplateBarWarlock = {};

function ClassNameplateBarWarlock:OnLoad()
	self.class = "WARLOCK";
	self.powerToken = "SOUL_SHARDS";
	
	for i = 1, #self.Shards do
		self.Shards[i].on = false;
	end
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarWarlock:UpdatePower()
	local shards = UnitPower("player", SPELL_POWER_SOUL_SHARDS);
	for i = 1, min(shards, #self.Shards) do
		if (not self.Shards[i].on) then
			self:TurnOn(self.Shards[i], self.Shards[i].ShardOn, 1);
		end
	end
	for i = shards + 1, #self.Shards do
		if (self.Shards[i].on) then
			self:TurnOff(self.Shards[i], self.Shards[i].ShardOn, 0);
		end
	end
end
