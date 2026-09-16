local animatedShines = {};

local function AnimatedShine_OnUpdate(_self, elapsed)
	for _, animatedShine in ipairs(animatedShines) do
		animatedShine:Update(elapsed);
	end
end

local animatedShineFrame = CreateFrame("Frame");
animatedShineFrame:SetScript("OnUpdate", AnimatedShine_OnUpdate);

AnimatedShineMixin = {};

local NUM_SHINES = 4;
local SHINE_SPEED = 2.5;

function AnimatedShineMixin:Start(r, g, b)
	if ( not tContains(animatedShines, self) ) then
		self.timer = 0;
		tinsert(animatedShines, self);
	end

	for i = 1, NUM_SHINES do
		local currShine = self["Shine"..i];
		currShine:Show();

		if ( r ) then
			currShine:SetVertexColor(r, g, b);
		end
	end
end

function AnimatedShineMixin:Stop()
	tDeleteItem(animatedShines, self);
	for i = 1, NUM_SHINES do
		local currShine = self["Shine"..i];
		currShine:Hide();
	end
end

function AnimatedShineMixin:Update(elapsed)
	local shine1 = self.Shine1;
	local shine2 = self.Shine2;
	local shine3 = self.Shine3;
	local shine4 = self.Shine4;

	self.timer = self.timer + elapsed;
	if ( self.timer > SHINE_SPEED * 4 ) then
		self.timer = 0;
	end

	local distance = self:GetWidth();
	if ( self.timer <= SHINE_SPEED ) then
		shine1:SetPoint("CENTER", self, "TOPLEFT", self.timer / SHINE_SPEED * distance, 0);
		shine2:SetPoint("CENTER", self, "BOTTOMRIGHT", -self.timer / SHINE_SPEED * distance, 0);
		shine3:SetPoint("CENTER", self, "TOPRIGHT", 0, -self.timer / SHINE_SPEED * distance);
		shine4:SetPoint("CENTER", self, "BOTTOMLEFT", 0, self.timer / SHINE_SPEED * distance);
	elseif ( self.timer <= SHINE_SPEED * 2 ) then
		shine1:SetPoint("CENTER", self, "TOPRIGHT", 0, -(self.timer - SHINE_SPEED) / SHINE_SPEED * distance);
		shine2:SetPoint("CENTER", self, "BOTTOMLEFT", 0, (self.timer - SHINE_SPEED) / SHINE_SPEED * distance);
		shine3:SetPoint("CENTER", self, "BOTTOMRIGHT", -(self.timer - SHINE_SPEED) / SHINE_SPEED * distance, 0);
		shine4:SetPoint("CENTER", self, "TOPLEFT", (self.timer - SHINE_SPEED) / SHINE_SPEED * distance, 0);
	elseif ( self.timer <= SHINE_SPEED * 3 ) then
		shine1:SetPoint("CENTER", self, "BOTTOMRIGHT", -(self.timer - SHINE_SPEED * 2) / SHINE_SPEED * distance, 0);
		shine2:SetPoint("CENTER", self, "TOPLEFT", (self.timer - SHINE_SPEED * 2) / SHINE_SPEED * distance, 0);
		shine3:SetPoint("CENTER", self, "BOTTOMLEFT", 0, (self.timer - SHINE_SPEED * 2) / SHINE_SPEED * distance);
		shine4:SetPoint("CENTER", self, "TOPRIGHT", 0, -(self.timer - SHINE_SPEED * 2) / SHINE_SPEED * distance);
	else
		shine1:SetPoint("CENTER", self, "BOTTOMLEFT", 0, (self.timer - SHINE_SPEED * 3) / SHINE_SPEED * distance);
		shine2:SetPoint("CENTER", self, "TOPRIGHT", 0, -(self.timer - SHINE_SPEED * 3) / SHINE_SPEED * distance);
		shine3:SetPoint("CENTER", self, "TOPLEFT", (self.timer - SHINE_SPEED * 3) / SHINE_SPEED * distance, 0);
		shine4:SetPoint("CENTER", self, "BOTTOMRIGHT", -(self.timer - SHINE_SPEED * 3) / SHINE_SPEED * distance, 0);
	end
end
