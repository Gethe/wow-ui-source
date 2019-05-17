
CommentatorCooldownDisplayMixin = {};

function CommentatorCooldownDisplayMixin:OnLoad()
	self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");
	self:RegisterEvent("COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE");

	self:MarkDirty();
end

function CommentatorCooldownDisplayMixin:OnUpdate()
	if self.isDirty then
		self:Refresh();
	end
end

function CommentatorCooldownDisplayMixin:OnEvent(event, ...)
	if event == "COMMENTATOR_PLAYER_UPDATE" or event == "COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE" then
		self:MarkDirty();
	end
end

function CommentatorCooldownDisplayMixin:MarkDirty()
	self.isDirty = true;
end

function CommentatorCooldownDisplayMixin:Refresh()
	self.isDirty = false;

	for teamIndex, teamFrame in ipairs(self.TeamFrames) do
		teamFrame:Refresh(teamIndex);
	end
end

CommentatorCooldownTeamMixin = {};

function CommentatorCooldownTeamMixin:OnLoad()
	self.playerRowPool = CreateFramePool("FRAME", self, "CommentatorCooldownPlayerTemplate");
end

local function RowComparator(left, right)
	local leftRole = left:GetRole();
	local rightRole = right:GetRole();
	if leftRole ~= rightRole then
		if leftRole == "HEALER" then
			return true;
		elseif rightRole == "HEALER" then
			return false;
		end

		if leftRole == "TANK" then
			return true;
		elseif rightRole == "TANK" then
			return false;
		end
	end

	return strcmputf8i(left:GetPlayerName(), right:GetPlayerName()) < 0;
end

function CommentatorCooldownTeamMixin:Refresh(teamIndex)
	if self.teamIndex ~= teamIndex then
		self.teamIndex = teamIndex;
		self:SetTeam(teamIndex);
	end

	local numPlayers = C_Commentator.GetNumPlayers(teamIndex);
	if numPlayers == 0 then
		self:Hide();
		return;
	end

	local activeRows = {};

	self.playerRowPool:ReleaseAll();
	for playerIndex = 1, numPlayers do
		local row = self.playerRowPool:Acquire();
		row:Show();
		row:ClearAllPoints()

		row:SetTeamAndPlayer(teamIndex, playerIndex);

		activeRows[#activeRows + 1] = row;
	end

	table.sort(activeRows, RowComparator);

	for i, row in ipairs(activeRows) do
		local prevRow = activeRows[i - 1];
		row:SetPoint("TOP", prevRow or self, prevRow and "BOTTOM" or "TOP");
	end

	self:SetHeight(#activeRows > 0 and activeRows[1]:GetHeight() * numPlayers or 0);
	self:Show();
end

do
	local ATLASES_FOR_TEAM = {
		{ corner = "tournamentarena-frame-bg-corner-red", side = "tournamentarena-frame-bg-side-red" },
		{ corner = "tournamentarena-frame-bg-corner-blue", side = "tournamentarena-frame-bg-side-blue" },
	}

	function CommentatorCooldownTeamMixin:SetTeam(teamIndex)
		local atlases = ATLASES_FOR_TEAM[teamIndex];
		if atlases then
			for i, corner in ipairs(self.ColoredCorners) do
				corner:SetAtlas(atlases.corner);
			end

			for i, side in ipairs(self.ColoredSides) do
				side:SetAtlas(atlases.side);
			end
		end
	end
end


CommentatorCooldownPlayerMixin = {};

function CommentatorCooldownPlayerMixin:OnLoad()
	self.offensiveCooldownPool = CreateCommentatorCooldownPool(self, self:GetTeamAndPlayer());
	self.defensiveCooldownPool = CreateCommentatorCooldownPool(self, self:GetTeamAndPlayer());
end

function CommentatorCooldownPlayerMixin:SetTeamAndPlayer(teamIndex, playerIndex)
	self.teamIndex = teamIndex;
	self.playerIndex = playerIndex;

	local unitToken, playerName, faction, specID = C_Commentator.GetPlayerInfo(self.teamIndex, self.playerIndex);
	self:SetPlayerName(playerName);
	self:SetClass(select(2, UnitClass(unitToken)));
	self:SetRole(GetSpecializationRoleByID(specID));

	self.offensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	self.defensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	self:UpdateCooldowns(C_Commentator.GetTrackedOffensiveCooldowns(self.teamIndex, self.playerIndex), C_Commentator.GetTrackedDefensiveCooldowns(self.teamIndex, self.playerIndex));
end

function CommentatorCooldownPlayerMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorCooldownPlayerMixin:Clear()
	self:Hide();
end

function CommentatorCooldownPlayerMixin:SetPlayerName(name)
	self.Name:SetText(name);
end

function CommentatorCooldownPlayerMixin:GetPlayerName()
	return self.Name:GetText();
end

function CommentatorCooldownPlayerMixin:SetClass(class)
	local color = RAID_CLASS_COLORS[class];
	if color then
		self.Name:SetVertexColor(color.r, color.g, color.b, 1.0);
	else
		self.Name:SetVertexColor(0, 1.0, 0, 1.0);
	end
end

function CommentatorCooldownPlayerMixin:SetRole(role)
	if role == nil or role == "DAMAGER" then
		self.RoleIcon:Hide();
	else
		self.RoleIcon:Show();
		if role == "HEALER" then
			self.RoleIcon:SetAtlas("HealerBadge");
		elseif role == "TANK" then
			self.RoleIcon:SetAtlas("TankBadge");
		end
	end
	self.role = role;
end

function CommentatorCooldownPlayerMixin:GetRole()
	return self.role;
end

local MAX_NUM_COOLDOWNS = 10;
function CommentatorCooldownPlayerMixin:UpdateCooldowns(offensiveCooldowns, defensiveCooldowns)
	while #offensiveCooldowns + #defensiveCooldowns > MAX_NUM_COOLDOWNS do
		if #offensiveCooldowns > #defensiveCooldowns then
			offensiveCooldowns[#offensiveCooldowns] = nil;
		else
			defensiveCooldowns[#defensiveCooldowns] = nil;
		end
	end

	local PADDING = 5;
	self.offensiveCooldownPool:SetCooldowns(offensiveCooldowns, self.Container, "LEFT", PADDING);
	self.defensiveCooldownPool:SetCooldowns(defensiveCooldowns, self.Container, "RIGHT", PADDING);
end

CommentatorCooldownPoolMixin = {};

function CreateCommentatorCooldownPool(parent, teamIndex, playerIndex)
	local commentatorCooldownPool = CreateFromMixins(CommentatorCooldownPoolMixin);
	commentatorCooldownPool.cooldownPool = CreateFramePool("FRAME", parent, "CommentatorCooldownTemplate");
	commentatorCooldownPool.activeCooldowns = {};
	commentatorCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	return commentatorCooldownPool;
end

function CommentatorCooldownPoolMixin:SetTeamAndPlayer(teamIndex, playerIndex)
	wipe(self.activeCooldowns);
	self.teamIndex = teamIndex;
	self.playerIndex = playerIndex;
end

function CommentatorCooldownPoolMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorCooldownPoolMixin:SetCooldownIsActive(spellID, isActive)
	self.activeCooldowns[spellID] = isActive;
	for cooldownFrame in self.cooldownPool:EnumerateActive() do
		if cooldownFrame:GetSpellID() == spellID then
			cooldownFrame:SetActive(isActive);
		end
	end
end

function CommentatorCooldownPoolMixin:IsCooldownActive(spellID)
	return self.activeCooldowns[spellID];
end

function CommentatorCooldownPoolMixin:SetCooldowns(cooldownSpellIDs, anchor, point, padding)
	self.cooldownPool:ReleaseAll();
	for i, cooldownSpellID in ipairs(cooldownSpellIDs) do
		local cooldownFrame = self.cooldownPool:Acquire();
		cooldownFrame:Initialize(self);
		cooldownFrame:SetSpellID(cooldownSpellID);
		
		cooldownFrame:ClearAllPoints();
		local offset = (i - 1) * (cooldownFrame:GetWidth() + padding);
		if point == "RIGHT" then
			offset = -offset;
		end
		cooldownFrame:SetPoint(point, anchor, point, offset, 5);
		
		cooldownFrame:Show();
	end
end
 
CommentatorCooldownFrameMixin = {};

function CommentatorCooldownFrameMixin:Initialize(info)
	self.info = info;
end

function CommentatorCooldownFrameMixin:SetSpellID(spellID)
	self.spellID = spellID;
	self:Update();
end

function CommentatorCooldownFrameMixin:GetSpellID()
	return self.spellID;
end

function CommentatorCooldownFrameMixin:IsActive()
	return self.active;
end

function CommentatorCooldownFrameMixin:SetActive(active)
	self.active = active;
	self.ActiveGlow:SetShown(active);
	self.Ants:SetShown(active);
	
	self:UpdateCooldownSwipe();
end

function CommentatorCooldownFrameMixin:Update()	
	local teamIndex, playerIndex = self.info:GetTeamAndPlayer();
	local charges, maxCharges, chargeStart, chargeDuration = C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, self.spellID);
	if charges and maxCharges and maxCharges > 1 then
		self.ChargesText:SetText(charges);
	else
		self.ChargesText:SetText("");
	end
	
	local spellName, _, spellIcon = GetSpellInfo(self.spellID);
	self.Icon:SetTexture(spellIcon);
	
	self:SetActive(self.info:IsCooldownActive(self.spellID));
	self:UpdateCooldownSwipe();
end

function CommentatorCooldownFrameMixin:UpdateCooldownSwipe()
	if self:IsActive() then
		CooldownFrame_Clear(self.Cooldown);
	else
		local teamIndex, playerIndex = self.info:GetTeamAndPlayer();
		local charges, maxCharges, chargeStart, chargeDuration = C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, self.spellID);
		if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
			self.Charges:SetCooldown(chargeStart, chargeDuration);
		end
		
		local start, duration, enable = C_Commentator.GetPlayerCooldownInfo(teamIndex, playerIndex, self.spellID);
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
	end
end