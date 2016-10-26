WarlockPowerBar = {};
SHARDBAR_SHOW_LEVEL = 10;

function WarlockPowerBar:OnLoad()
	self:SetTooltip(SOUL_SHARDS_POWER, SOUL_SHARDS_TOOLTIP);
	self:SetPowerTokens("SOUL_SHARDS");
	self.class = "WARLOCK";
	self.spec = nil;

	ClassPowerBar.OnLoad(self);
end

function WarlockPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);

	if showBar then
		if UnitLevel("player") < SHARDBAR_SHOW_LEVEL then
			self:RegisterEvent("PLAYER_LEVEL_UP");
			self:SetAlpha(0);
		end
	end
end

function WarlockPowerBar:OnEvent(event, ...)
	local handled = ClassPowerBar.OnEvent(self, event, ...);
	if handled then
		return true;
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...;
		if level >= SHARDBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:SetAlpha(1);
			self:UpdatePower();
		end
	else
		return false;
	end

	return true;
end

function WarlockPowerBar:SetShard(shard, active)
	if active then
		if shard.animOut:IsPlaying() then
			shard.animOut:Stop();
		end

		if not shard.active and not shard.animIn:IsPlaying() then
			shard.animIn:Play();
			shard.active = true;
		end
	else
		if shard.animIn:IsPlaying() then
			shard.animIn:Stop();
		end

		if shard.active and not shard.animOut:IsPlaying() then
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
