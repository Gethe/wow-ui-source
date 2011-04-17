

function IconIntroTracker_OnLoad(self)
	self.iconList = {};
	self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
end


function IconIntroTracker_OnEvent(self, event, ...)
	if event == "SPELL_PUSHED_TO_ACTIONBAR" then
		local spellID, slotIndex, slotPos = ...;
		local _, _, icon = GetSpellInfo(spellID);
		local freeIcon;
	
		for a,b in pairs(self.iconList) do
			if b.isFree then
				freeIcon = b;
			end
		end
		
		if not freeIcon then -- Make a new one
			freeIcon = CreateFrame("FRAME", self:GetName().."Icon"..(#self.iconList+1), UIParent, "IconIntroTemplate");
			self.iconList[#self.iconList+1] = freeIcon;
		end
	
		freeIcon.icon.icon:SetTexture(icon);
		freeIcon.icon.slot = slotIndex;
		
		freeIcon:ClearAllPoints();
		
		if BonusActionBarFrame:IsShown() then
			freeIcon:SetPoint("CENTER", _G["BonusActionButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["BonusActionBarFrame"]:GetFrameLevel()+5);
		else
			freeIcon:SetPoint("CENTER", _G["ActionButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["ActionButton"..slotPos]:GetFrameLevel()+1);
		end
		freeIcon.icon.flyin:Play(1);
		freeIcon.isFree = false;
	end
end