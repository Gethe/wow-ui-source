ClassNameplateBarWarlock = {};

function ClassNameplateBarWarlock:OnLoad()
	self.class = "WARLOCK";
	self.powerToken = "SOUL_SHARDS";
	self.Shards = {};

	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarWarlock:Setup()
	local showBar = ClassNameplateBar.Setup(self);

	if (showBar and UnitLevel("player") < SHARDBAR_SHOW_LEVEL) then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:HideNameplateBar();
	end
end

function ClassNameplateBarWarlock:OnEvent(event, ...)
	local handled = ClassNameplateBar.OnEvent(self, event, ...);
	if handled then
		return handled;
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...;
		if level >= SHARDBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:Setup();
		end
	else
		return false;
	end

	return true;
end

function ClassNameplateBarWarlock:CreateShards()
	local maxShards = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS);

	while #self.Shards < maxShards do
		local shard = CreateFrame("FRAME", nil, self, "ClassNameplateBarShardFrame");
		shard.shardIndex = #self.Shards - 1;

		if self.shardPoolAnchor then
			shard:SetPoint("LEFT", self.shardPoolAnchor, "RIGHT", 4, 0);
		else
			shard:SetPoint("LEFT", self, "LEFT", 0, 0);
		end

		self.shardPoolAnchor = shard;
		shard:Show();
	end
end

function ClassNameplateBarWarlock:SetShard(shard, powerAmount)
	local fillAmount = Saturate(powerAmount - shard.shardIndex);
	local active = fillAmount >= 1;

	if fillAmount ~= shard.fillAmount then
		shard.fillAmount = fillAmount;

		if active then
			self:TurnOn(shard, shard.ShardOn, 1);
			shard.PartialFill:SetValue(0);
		else
			self:TurnOff(shard, shard.ShardOn, 0);
			shard.PartialFill:SetValue(fillAmount);
		end
	end
end

function ClassNameplateBarWarlock:UpdatePower()
	WarlockPowerBar_UpdatePower(self);
end