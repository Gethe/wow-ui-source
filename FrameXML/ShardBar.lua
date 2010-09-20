SHARD_BAR_NUM_SHARDS = 3;
SHARDBAR_SHOW_LEVEL = 10;



function ShardBar_OnRecharge(self)
	UIFrameFadeOut(self.shardGlow, 0.05);
end

local shardFadeInfo={
				mode = "IN",
				timeToFade = 0.2,
				finishedFunc = ShardBar_OnRecharge,
				finishedArg1 = "",
			}

function ShardBar_ToggleShard(self, visible)
	if visible then
		self.shardFill:Hide();
		self.shardGlow:Hide();
		self.shardSmoke1.animUsed:Play();
		self.shardSmoke2.animUsed:Play();
	else
		for a,b in pairs(shardFadeInfo) do 
			shardFadeInfo[a] = nil;
		end
		shardFadeInfo.mode = "IN";
		shardFadeInfo.timeToFade = 0.2;
		shardFadeInfo.finishedFunc = ShardBar_OnRecharge;
		shardFadeInfo.finishedArg1 = self;
		UIFrameFade(self.shardGlow, shardFadeInfo);	
		UIFrameFadeIn(self.shardFill, 0.2);		
	end
end


function ShardBar_Update()
	local numShards = UnitPower( ShardBarFrame:GetParent().unit, SPELL_POWER_SOUL_SHARDS );
	for i=1,SHARD_BAR_NUM_SHARDS do
		local shard = _G["ShardBarFrameShard"..i];
		local isShown = shard.shardFill:IsVisible() == 1;
		local shouldShow = i <= numShards;
		if isShown ~= shouldShow then 
			ShardBar_ToggleShard(shard, isShown);
		end
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
	
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self.shard1.shardSmoke1:SetAlpha(0.0);
	self.shard1.shardSmoke2:SetAlpha(0.0);
	self.shard2.shardSmoke1:SetAlpha(0.0);
	self.shard2.shardSmoke2:SetAlpha(0.0);
	self.shard3.shardSmoke1:SetAlpha(0.0);
	self.shard3.shardSmoke2:SetAlpha(0.0);
end



function ShardBar_OnEvent (self, event, arg1, arg2)
	if ( event == "UNIT_DISPLAYPOWER" ) then
		ShardBar_Update();	
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then
		ShardBar_Update();	
	elseif ( (event == "UNIT_POWER") and (arg1 == self:GetParent().unit) ) then
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