SHARD_BAR_NUM_SHARDS = 3;
SHARDBAR_SHOW_LEVEL = 10;

function ShardBar_SetShard(self, active)
	if ( active ) then
		if (self.animOut:IsPlaying()) then
			self.animOut:Stop();
		end
		
		if (not self.active and not self.animIn:IsPlaying()) then
			self.animIn:Restart();
			self.active = true;
		end
	else
		if (self.animIn:IsPlaying()) then
			self.animIn:Stop();
		end
		
		if (self.active and not self.animOut:IsPlaying()) then
			self.animOut:Restart();
			self.active = false;
		end
	end
end

function ShardBar_Update()
	local numShards = UnitPower( ShardBarFrame:GetParent().unit, Enum.PowerType.SoulShards );
	for i=1,SHARD_BAR_NUM_SHARDS do
		local shard = _G["ShardBarFrameShard"..i];
		local shouldShow = i <= numShards;
		ShardBar_SetShard(shard, shouldShow);
	end
end


function ShardBar_OnLoad (self)
	-- Disable rune frame if not a Warlock.
	local _, class = UnitClass("player");	
	if ( class ~= "WARLOCK" ) then
		self:Hide();
	elseif UnitLevel("player") < SHARDBAR_SHOW_LEVEL then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:SetAlpha(0);
	end
	
	self:RegisterEvent("UNIT_POWER_FREQUENT");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
end


function ShardBar_OnEvent (self, event, arg1, arg2)
	if ( event == "UNIT_DISPLAYPOWER" ) then
		ShardBar_Update();	
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		ShardBar_Update();	
	elseif ( (event == "UNIT_POWER_FREQUENT") and (arg1 == self:GetParent().unit) ) then
		if ( arg2 == "SOUL_SHARDS" ) then
			ShardBar_Update();
		end
	elseif( event ==  "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if level >= SHARDBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self.showAnim:Play();
			ShardBar_Update();
		end
	end
end