local forceinsecure = forceinsecure;

AddonCompartmentMixin = { };

local function SortAddons(addonData1, addonData2)
	return strcmputf8i(StripHyperlinks(addonData1.text), StripHyperlinks(addonData2.text)) < 0;
end

function AddonCompartmentMixin:OnLoad()
	self.registeredAddons = { };
	
	self:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(GameTooltip, ADDONS);
		GameTooltip:Show();
	end);

	self:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_ADDON_COMPARTMENT");

		if not self.registeredAddons then
			return;
		end

		table.sort(self.registeredAddons, SortAddons);

		for index, addonData in ipairs(self.registeredAddons) do
			local text = addonData.text;
			local button = rootDescription:CreateButton(text, addonData.func);
			button:AddInitializer(function(button, description, menu)
				button:RegisterForClicks("AnyUp");

				local texture = button:AttachTexture();
				texture:SetPoint("LEFT");

				local icon = addonData.icon;
				local hasIcon = icon ~= nil;
				if hasIcon then
					texture:ClearAllPoints();
					texture:SetPoint("RIGHT");
					texture:SetSize(16, 16);
					if C_Texture.GetAtlasInfo(icon) then
						texture:SetAtlas(icon);
					else
						texture:SetTexture(icon);
					end
				end 
				texture:SetShown(hasIcon);

				local fontString = button.fontString;
				fontString:ClearAllPoints();
				fontString:SetPoint("LEFT");
				fontString:SetTextToFit(text);
				fontString:SetWidth(fontString:GetWidth() + (hasIcon and 16 or 0));
			end);

			button:SetOnEnter(addonData.funcOnEnter);
			button:SetOnLeave(addonData.funcOnLeave);
		end
	end);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function AddonCompartmentMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		-- RegisterAddons cannot be called OnLoad because addons are explicitly not loadable during FrameXML load
		self:RegisterAddons();
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function AddonCompartmentMixin:RegisterAddons()
	local character = UnitName("player");
	for addonIndex = 1, C_AddOns.GetNumAddOns() do
		local addonEnabled = C_AddOns.GetAddOnEnableState(addonIndex, character) == Enum.AddOnEnableState.All;
		local addonCompartmentFunc = C_AddOns.GetAddOnMetadata(addonIndex, "AddonCompartmentFunc");
		local name, title, notes, loadable, reason, security = C_AddOns.GetAddOnInfo(addonIndex);
		if addonEnabled and addonCompartmentFunc and (loadable or reason == "DEMAND_LOADED") then
			local addonData = {};
			addonData.text = title;
			addonData.icon = C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture") or C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas");

			local function CallAddonGlobalFunc(addonCompartmentFunc, addonName, ...)
				forceinsecure();
				if reason == "DEMAND_LOADED" and not C_AddOns.IsAddOnLoaded(addonName) then
					C_AddOns.LoadAddOn(addonName);
				end
				_G[addonCompartmentFunc](addonName, ...);
			end

			addonData.func = function(data, menuInputData, menu)
				CallAddonGlobalFunc(addonCompartmentFunc, name, menuInputData.buttonName);
			end;

			local onEnterGlobal = C_AddOns.GetAddOnMetadata(addonIndex, "AddonCompartmentFuncOnEnter");
			if onEnterGlobal then
				addonData.funcOnEnter = function(btn)
					CallAddonGlobalFunc(onEnterGlobal, name, btn);
				end
			end

			local onLeaveGlobal = C_AddOns.GetAddOnMetadata(addonIndex, "AddonCompartmentFuncOnLeave");
			if onLeaveGlobal then
				addonData.funcOnLeave = function(btn)
					CallAddonGlobalFunc(onLeaveGlobal, name, btn);
				end
			end

			table.insert(self.registeredAddons, addonData);
		end
	end

	self:UpdateDisplay();
end

--[[
Custom registration expects a table with the following keys:
text: Name of your addon
icon: Icon to appear to the right of the name
func: Click callback
funcOnEnter: OnEnter callback
funcOnLeave: OnLeave callback
]]--

function AddonCompartmentMixin:RegisterAddon(addonData)
	table.insert(self.registeredAddons, addonData);
	self:UpdateDisplay();
end

function AddonCompartmentMixin:UpdateDisplay()
	local addonCount = #self.registeredAddons;
	self.Text:SetText(addonCount);

	local addonsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserAddonsDisabled);
	local featureEnabled = IsTestBuild() or not addonsDisabled;
	self:SetShown(featureEnabled and (addonCount > 0));
end
