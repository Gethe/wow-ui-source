STAMINA_BREAK = 0;
MANA_PER_INTELLECT = 0;

PAPERDOLL_SIDEBARTAB_STATS =
	{
		name=PAPERDOLL_SIDEBAR_STATS;
		icon = nil;  -- Uses the character portrait
		texCoords = {0.109375, 0.890625, 0.09375, 0.90625};
		disabledTooltip = nil;
		IsActive = function() return true; end;
	};

PAPERDOLL_SIDEBARTAB_TITLES =
	{
		name=PAPERDOLL_SIDEBAR_TITLES;
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.32421875, 0.46093750};
		disabledTooltip = NO_TITLES_TOOLTIP;
		IsActive = function()
			-- You always have the "No Title" title so you need to have more than one to have an option.
			return #GetKnownTitles() > 1;
		end;
	};

PAPERDOLL_SIDEBARTAB_EQUIPMENTMANAGER =
	{
		name=PAPERDOLL_EQUIPMENTMANAGER;
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.46875000, 0.60546875};
		disabledTooltip = function()
			local _, failureReason = C_LFGInfo.CanPlayerUseLFD();
			return failureReason;
		end;
		IsActive = function()
			return C_EquipmentSet.GetNumEquipmentSets() > 0 or C_LFGInfo.CanPlayerUseLFD();
		end;
	};

PAPERDOLL_SIDEBARTAB_PET =
	{
		name = PET;
		atlas = "paw-icon";
		disabledTooltip = ERR_NO_PET;
		IsActive = function() return HasPetUI(); end;
		texCoords = { 0.109375, 0.890625, 0.09375, 0.90625 };
		OnEvent = function(self, event, ...)
			if (event == "UNIT_PORTRAIT_UPDATE") then
				local unit = ...;
				if (unit == "pet") then
					SetPortraitTexture(self.Icon, "pet");
				end
			else
				SetPortraitTexture(self.Icon, "pet");
			end
		end;
		OnLoad = function(self)
			self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
			self:RegisterEvent("PORTRAITS_UPDATED");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterEvent("UNIT_PET");

			local tcoords = PAPERDOLL_SIDEBARS[self:GetID()].texCoords;
			self.Icon:SetTexCoord(tcoords[1], tcoords[2], tcoords[3], tcoords[4]);
			self.Icon:SetSize(29, 31);
		end
	};
