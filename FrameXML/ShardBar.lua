WarlockPowerBar = {};
SHARDBAR_SHOW_LEVEL = 10;

function WarlockPowerBar:OnLoad()
	self:SetTooltip(SOUL_SHARDS_POWER, SOUL_SHARDS_TOOLTIP);
	self:SetPowerTokens("SOUL_SHARDS");
	self.class = "WARLOCK";
	self.spec = nil;
	self.Shards = {};

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

function WarlockPowerBar:CreateShards()
	local maxShards = UnitPowerMax(self:GetUnit(), SPELL_POWER_SOUL_SHARDS);

	while #self.Shards < maxShards do
		local shard = CreateFrame("FRAME", nil, self, "ShardTemplate");
		shard.shardIndex = #self.Shards - 1;

		if self.previousShard then
			shard:SetPoint("TOPLEFT", self.previousShard, "TOPLEFT", 25, 0);
		else
			shard:SetPoint("TOPLEFT", self, "TOPLEFT", -10, 0);
		end

		self.previousShard = shard;
	end
end

function WarlockPowerBar:SetShard(shard, powerAmount)
	local fillAmount = Saturate(powerAmount - shard.shardIndex);
	local active = fillAmount >= 1;

	if active then
		if shard.animOut:IsPlaying() then
			shard.animOut:Stop();
		end

		if not shard.active and not shard.animIn:IsPlaying() then
			shard.animIn:Play();
			shard.active = true;
		end

		shard.PartialFill:SetValue(0);
	else
		if shard.animIn:IsPlaying() then
			shard.animIn:Stop();
		end

		if shard.active and not shard.animOut:IsPlaying() then
			shard.animOut:Play();
			shard.active = false;
		end

		shard.PartialFill:SetValue(fillAmount);
	end
end

function WarlockPowerBar:UpdatePower()
	WarlockPowerBar_UpdatePower(self);
end

function WarlockPowerBar_UpdatePower(self)
	self:CreateShards();

	local shardPower = WarlockPowerBar_UnitPower(self:GetUnit());

	for i, shard in ipairs(self.Shards) do
		self:SetShard(shard, shardPower);
	end
end

function WarlockPowerBar_UnitPower(unit)
	local shardPower = UnitPower(unit, SPELL_POWER_SOUL_SHARDS, true);
	local shardModifier = UnitPowerDisplayMod(SPELL_POWER_SOUL_SHARDS);
	return (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
end