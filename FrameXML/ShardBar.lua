WarlockPowerBar = {};

function WarlockPowerBar:OnLoad()
	self:SetTooltip(SOUL_SHARDS_POWER, SOUL_SHARDS_TOOLTIP);
	self:SetPowerTokens("SOUL_SHARDS");
	self.class = "WARLOCK";
	self.spec = nil;
	
	ClassPowerBar.OnLoad(self);
end

function WarlockPowerBar:SetShard(shard, active)
	if ( active ) then
		if (shard.animOut:IsPlaying()) then
			shard.animOut:Stop();
		end
		
		if (not shard.active and not shard.animIn:IsPlaying()) then
			shard.animIn:Play();
			shard.active = true;
		end
	else
		if (shard.animIn:IsPlaying()) then
			shard.animIn:Stop();
		end
		
		if (shard.active and not shard.animOut:IsPlaying()) then
			shard.animOut:Play();
			shard.active = false;
		end
	end
end

function WarlockPowerBar:UpdatePower()
	local numShards = UnitPower( WarlockPowerFrame:GetParent().unit, SPELL_POWER_SOUL_SHARDS );
	local maxShards = UnitPowerMax( WarlockPowerFrame:GetParent().unit, SPELL_POWER_SOUL_SHARDS );
	-- update individual shard display
	for i = 1, maxShards do
		local shard = self.Shards[i];
		local shouldShow = i <= numShards;
		self:SetShard(shard, shouldShow);
	end
end
