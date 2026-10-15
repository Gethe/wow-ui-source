PartyMemberFrameMixin.ArtLayoutInfo.Player = {
	Name = {
		Width = 55
	},
	Role = {
		OffsetX = -5,
		OffsetY = -7
	},
	Health = {
		Width = 70,
		Height = 10,
		OffsetX = 47,
		OffsetY = -20,
		OffsetXMask = -28,
		OffsetYMask = 3
	},
	Mana = {
		Width = 74,
		OffsetX = 44,
		OffsetY = -31,
		OffsetXMask = 16,
		OffsetYMask = -26
	},
	Flash = {
		OffsetX = 1,
		OffsetY = -1,
	},
	Status = {
		OffsetX = -1,
		OffsetY = -1,
	}
};

PartyMemberFrameMixin.ArtLayoutInfo.Character = {
	Name = {
		Width = 55
	},
	Role = {
		OffsetX = -5,
		OffsetY = -7
	},
	Health = {
		Width = 71,
		Height = 10,
		OffsetX = 47,
		OffsetY = -19,
		OffsetXMask = -25,
		OffsetYMask = 3
	},
	Mana = {
		Width = 70,
		OffsetX = 47,
		OffsetY = -31,
		WidthMask = 128,
		HeightMask = 9,
		OffsetXMask = 19,
		OffsetYMask = -28
	},
	Flash = {
		OffsetX = 1,
		OffsetY = -1
	},
	Status = {
		OffsetX = -1,
		OffsetY = -1
	}
}

function PartyMemberFrameMixin:UpdateNameTextAnchors()
	local nameTextOffsetY = -7;
	if (LOCALE_zhCN or LOCALE_zhTW) then
		nameTextOffsetY = -6;
	end

	self.Name:SetPoint("TOPLEFT", self, "TOPLEFT", 48, nameTextOffsetY);
end