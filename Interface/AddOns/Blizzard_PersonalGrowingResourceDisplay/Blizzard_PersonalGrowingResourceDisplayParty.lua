local PARTY_FRAME_SCALE = 1;
local PARTY_FRAME_SPACING = 20;
local MAX_PARTY_MEMBERS = 2;

local GROUP_EVENTS = {
	"GROUP_ROSTER_UPDATE",
	"PLAYER_ENTERING_WORLD",
};

PartyGrowingResourceContainerMixin = {};

function PartyGrowingResourceContainerMixin:OnLoad()
	self.partyFrames = {};
	self.growsUpward = true;
	self.isAnchoredToDock = true;

	FrameUtil.RegisterFrameForEvents(self, GROUP_EVENTS);
end

WoWHackPartyFrameSettings = WoWHackPartyFrameSettings or {};

function PartyGrowingResourceContainerMixin:SetAnchoredToDock(anchored)
	self.isAnchoredToDock = anchored;

	WoWHackPartyFrameSettings.isAnchoredToDock = anchored;

	if anchored then
		self:UpdateAnchor();
	else
		self:ClearAllPoints();
		self:SetPoint("LEFT", UIParent, "LEFT", 50, 0);
	end
end

function PartyGrowingResourceContainerMixin:UpdateAnchor()
	if not self.isAnchoredToDock then
		return;
	end

	local primary = GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.primary;
	if not primary then
		return;
	end

	local buttonSide = FCF_GetButtonSide(primary);
	local primaryTop = primary:GetTop() or 0;
	local primaryBottom = primary:GetBottom() or 0;
	local primaryCenter = (primaryTop + primaryBottom) / 2;
	local isAboveScreenMidpoint = primaryCenter < (GetScreenHeight() / 2);

	self.growsUpward = isAboveScreenMidpoint;

	self:ClearAllPoints();
	if isAboveScreenMidpoint then
		if buttonSide == "left" then
			self:SetPoint("BOTTOMLEFT", primary, "TOPLEFT", 0, 155);
		else
			self:SetPoint("BOTTOMRIGHT", primary, "TOPRIGHT", 0, 155);
		end
	else
		if buttonSide == "left" then
			self:SetPoint("TOPLEFT", primary, "BOTTOMLEFT", 0, -57);
		else
			self:SetPoint("TOPRIGHT", primary, "BOTTOMRIGHT", 0, -57);
		end
	end

	self:UpdatePartyFrames();
end

function PartyGrowingResourceContainerMixin:OnEvent(event, ...)
	self:UpdatePartyFrames();
end

function PartyGrowingResourceContainerMixin:UpdatePartyFrames()
	local numGroupMembers = GetNumGroupMembers();
	local numPartyMembers = math.min(MAX_PARTY_MEMBERS, numGroupMembers - 1);

	if not IsInGroup() then
		numPartyMembers = 0;
	end

	self:SetShown(numPartyMembers > 0);

	-- Hide excess frames
	for i = numPartyMembers + 1, #self.partyFrames do
		if self.partyFrames[i] then
			self.partyFrames[i]:Hide();
			self.partyFrames[i]:SetUnit(nil);
		end
	end

	-- Create or update needed frames
	for i = 1, numPartyMembers do
		local frame = self.partyFrames[i];
		if not frame then
			frame = CreateFrame("Button", nil, self, "PersonalGrowingResourceDisplayTemplate");
			frame:SetScale(PARTY_FRAME_SCALE);
			frame:SetScript("OnEnter", UnitFrame_OnEnter);
			frame:SetScript("OnLeave", UnitFrame_OnLeave);
			self.partyFrames[i] = frame;
		end

		local unit = "party" .. i;
		frame:Init(unit);

		-- Anchor vertically stacked, direction determined by self.growsUpward
		frame:ClearAllPoints();
		if self.growsUpward then
			if i == 1 then
				frame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0);
			else
				frame:SetPoint("BOTTOMLEFT", self.partyFrames[i - 1], "TOPLEFT", 0, PARTY_FRAME_SPACING);
			end
		else
			if i == 1 then
				frame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			else
				frame:SetPoint("TOPLEFT", self.partyFrames[i - 1], "BOTTOMLEFT", 0, -PARTY_FRAME_SPACING);
			end
		end

		frame:SetShown(UnitExists(unit));
	end
end
