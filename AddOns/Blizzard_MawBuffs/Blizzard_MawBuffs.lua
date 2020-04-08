MawBuffsContainerMixin = {};

function MawBuffsContainerMixin:OnLoad()
	self:Update();
	self:RegisterUnitEvent("UNIT_AURA", "player");
end

function MawBuffsContainerMixin:OnEvent(event, ...)
	local unit = ...;
	if event == "UNIT_AURA" then
		self:Update();
	end
end

function MawBuffsContainerMixin:Update()
	local mawBuffs = {};
	local totalCount = 0;
	for i=1, BUFF_MAX_DISPLAY do
		local _, icon, count = UnitAura("player", i, "MAW");
		if icon then
			if count == 0 then
				count = 1;
			end

			totalCount = totalCount + count;
			table.insert(mawBuffs, {icon = icon, count = count, slot = i});
		end
	end

	self:SetText(JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(totalCount));
	self.List:Update(mawBuffs);
	
	if(IsInJailersTower()) then
		self:Show();
	else
		self:Hide();
	end

	self.buffCount = #mawBuffs;
	if self.buffCount == 0 then
		self.List:Hide();
		self:Disable();
	else
		self:Enable();
	end
end

function MawBuffsContainerMixin:OnClick()
	self.List:SetShown(not self.List:IsShown());
end

MawBuffsListMixin = {};

local BUFF_HEIGHT = 45;
local BUFF_LIST_MIN_HEIGHT = 159;
local BUFF_LIST_PADDING_HEIGHT = 36;
local BUFF_LIST_NUM_COLUMNS = 4;

function MawBuffsListMixin:OnLoad()
	self.button = self:GetParent();
	self:SetFrameLevel(self.button:GetFrameLevel() - 1);
	self.buffPool = CreateFramePool("FRAME", self, "MawBuffTemplate");
end

function MawBuffsListMixin:OnShow()
	self.button:SetPushedAtlas("jailerstower-animapowerbutton-pressed");
	self.button:SetHighlightAtlas("jailerstower-animapowerbutton-pressed-highlight");
	self.button:SetWidth(268);
	self.button:SetPushedTextOffset(10, -1);
	self.button:SetButtonState("NORMAL");
	self.button:SetButtonState("PUSHED", true);
end

function MawBuffsListMixin:OnHide()
	self.button:SetPushedAtlas("jailerstower-animapowerbutton-normalpressed");
	self.button:SetHighlightAtlas("jailerstower-animapowerbutton-highlight");
	self.button:SetWidth(253);
	self.button:SetPushedTextOffset(2, -1);
	self.button:SetButtonState("NORMAL", false);
end

function MawBuffsListMixin:Update(mawBuffs)
	self.buffPool:ReleaseAll();

	local lastRowFirstFrame;
	local lastBuffFrame;
	local buffsTotalHeight = 0;
	for index, buffInfo in ipairs(mawBuffs) do
		local buffFrame = self.buffPool:Acquire();

		local column = mod(index, BUFF_LIST_NUM_COLUMNS);
		if column == 1 then
			if lastRowFirstFrame then
				buffFrame:SetPoint("TOPLEFT", lastRowFirstFrame, "BOTTOMLEFT", 0, -3);
				buffsTotalHeight = buffsTotalHeight + BUFF_HEIGHT + 3;
			else
				buffFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 12, -18);
				buffsTotalHeight = BUFF_HEIGHT;
			end
			lastRowFirstFrame = buffFrame;
		else
			buffFrame:SetPoint("TOPLEFT", lastBuffFrame, "TOPRIGHT", 3, 0);
		end

		lastBuffFrame = buffFrame;
		buffFrame:SetBuffInfo(mawBuffs[index]);
	end

	local totalListHeight = math.max(buffsTotalHeight + BUFF_LIST_PADDING_HEIGHT, BUFF_LIST_MIN_HEIGHT);
	self:SetHeight(totalListHeight);
end

MawBuffMixin = {};

function MawBuffMixin:SetBuffInfo(buffInfo)
	self.Icon:SetTexture(buffInfo.icon);
	self.slot = buffInfo.slot;
	self.Count:SetText(buffInfo.count);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end

	self:Show();
end

function MawBuffMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetUnitAura("player", self.slot, "MAW");
	GameTooltip:Show();
end
