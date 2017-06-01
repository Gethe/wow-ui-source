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
	local maxShards = UnitPowerMax("player", Enum.PowerType.SoulShards);

	while #self.Shards < maxShards do
		local shard = CreateFrame("FRAME", nil, self, "ClassNameplateBarShardFrame");
		shard:Setup(#self.Shards - 1);

		if self.shardPoolAnchor then
			shard:SetPoint("LEFT", self.shardPoolAnchor, "RIGHT", 6, 0);
		else
			shard:SetPoint("LEFT", self, "LEFT", -4, -4);
		end

		self.shardPoolAnchor = shard;
		shard:Show();
	end
end

function ClassNameplateBarWarlock:UpdatePower()
	WarlockPowerBar_UpdatePower(self);
end

ClassNameplateBarWarlockShardMixin = CreateFromMixins(WarlockShardMixin);

function ClassNameplateBarWarlockShardMixin:Setup(shardIndex)
	WarlockShardMixin.Setup(self, shardIndex);
	self.widthByFillAmount = {
		[0] = 0,
		[1] = 2,
		[2] = 8,
		[3] = 10,
		[4] = 14,
		[5] = 18,
		[6] = 18,
		[7] = 20,
		[8] = 16,
		[9] = 12,
		[10] = 0,
	};
end

function ClassNameplateBarWarlockShardMixin:Update(powerAmount)
	local fillAmount = Saturate(powerAmount - self.shardIndex);
	local active = fillAmount >= 1;

	local bar = self:GetParent();
	if fillAmount ~= self.fillAmount then
		self.fillAmount = fillAmount;

		if active then
			bar:TurnOn(self, self.ShardOn, 1);
			self.PartialFill:SetValue(0);
		else
			bar:TurnOff(self, self.ShardOn, 0);
			self.PartialFill:SetValue(fillAmount);
		end
		self:UpdateSpark(fillAmount);
	end
end
