-- Colors for item quality tooltip borders
ITEM_QUALITY0_TOOLTIP_COLOR = { r = 0.8, g = 0.8, b = 0.8 };
ITEM_QUALITY1_TOOLTIP_COLOR = { r = 0.5, g = 0.5, b = 0.5 };
ITEM_QUALITY2_TOOLTIP_COLOR = { r = 0, g = 1.0, b = 0 };
ITEM_QUALITY3_TOOLTIP_COLOR = { r = 0, g = 0.18, b = 0.35 };
ITEM_QUALITY4_TOOLTIP_COLOR = { r = 0.5, g = 0, b = 1.0 };
ITEM_QUALITY5_TOOLTIP_COLOR = { r = 1.0, g = 0, b = 0 };
ITEM_QUALITY6_TOOLTIP_COLOR = { r = 1.0, g = 0.5, b = 0 };
-- Colors for item quality tooltip backgrounds
ITEM_QUALITY3_TOOLTIP_BGCOLOR = { r = 0, g = 0.18, b = 0.35 };
ITEM_QUALITY4_TOOLTIP_BGCOLOR = { r = 0.15, g = 0, b = 0.28 };
ITEM_QUALITY5_TOOLTIP_BGCOLOR = { r = 0.28, g = 0, b = 0 };
ITEM_QUALITY6_TOOLTIP_BGCOLOR = { r = 0.28, g = 0.15, b = 0 };
-- The default tooltip border color
--TOOLTIP_DEFAULT_COLOR = { r = 0.5, g = 0.5, b = 0.5 };
TOOLTIP_DEFAULT_COLOR = { r = 1, g = 1, b = 1 };
TOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.09, g = 0.09, b = 0.19 };

function GameTooltip_UnitColor(unit)
	local r, g, b;
	if ( UnitPlayerControlled(unit) ) then
		if ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				--[[
				r = 1.0;
				g = 0.5;
				b = 0.5;
				]]
				r = 0.0;
				g = 0.0;
				b = 1.0;
			else
				r = FACTION_BAR_COLORS[2].r;
				g = FACTION_BAR_COLORS[2].g;
				b = FACTION_BAR_COLORS[2].b;
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			r = FACTION_BAR_COLORS[4].r;
			g = FACTION_BAR_COLORS[4].g;
			b = FACTION_BAR_COLORS[4].b;
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			r = FACTION_BAR_COLORS[6].r;
			g = FACTION_BAR_COLORS[6].g;
			b = FACTION_BAR_COLORS[6].b;
		else
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.0;
			g = 0.0;
			b = 1.0;
		end
	else
		local reaction = UnitReaction(unit, "player");
		if ( reaction ) then
			r = FACTION_BAR_COLORS[reaction].r;
			g = FACTION_BAR_COLORS[reaction].g;
			b = FACTION_BAR_COLORS[reaction].b;
		else
			r = 0.0;
			g = 0.0;
			b = 1.0;
		end
	end
	return r, g, b;
end

function GameTooltip_SetDefaultAnchor(tooltip, parent)		
	tooltip:SetOwner(parent, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -13, 64);
end

function GameTooltip_OnLoad()
	this:RegisterEvent("TOOLTIP_ADD_MONEY");
	this:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	this:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function GameTooltip_OnEvent()
	if ( event == "UPDATE_MOUSEOVER_UNIT" ) then
		if ( UnitExists("mouseover") ) then
			GameTooltip_SetDefaultAnchor(this, UIParent);
			this:SetUnit("mouseover");
			local r, g, b = GameTooltip_UnitColor("mouseover");
			this:SetBackdropColor(r, g, b);
		else
			this:FadeOut();
		end
	elseif ( event == "CLEAR_TOOLTIP" ) then
		GameTooltip_ClearMoney();
	elseif ( event == "TOOLTIP_ADD_MONEY" ) then
		if ( arg1 == this:GetName() ) then
			SetTooltipMoney(this, arg2);
		end
	elseif ( event == "TOOLTIP_ANCHOR_DEFAULT" ) then
		GameTooltip_SetDefaultAnchor(this, UIParent);
	end
end

function SetTooltipMoney(frame, money)
	frame:AddLine(" ", 1.0, 1.0, 1.0);
	local numLines = frame:NumLines();
	local moneyFrame = getglobal(frame:GetName().."MoneyFrame");
	moneyFrame:SetPoint("LEFT", frame:GetName().."TextLeft"..numLines, "LEFT", 4, 0);
	moneyFrame:Show();
	MoneyFrame_Update(moneyFrame:GetName(), money);
	frame:SetMoneyWidth(moneyFrame:GetWidth());
end

function GameTooltip_ClearMoney()
	local moneyFrame = getglobal(this:GetName().."MoneyFrame");
	moneyFrame:SetPoint("LEFT", this:GetName().."TextLeft1", "LEFT", 0, 0);
	moneyFrame:Hide();
end

function GameTooltip_OnHide()
	this:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	this:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function GameTooltip_AddNewbieTip(normalText, r, g, b, newbieText, noNormalText)
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		if ( normalText ) then
			GameTooltip:SetText(normalText, r, g, b);
			GameTooltip:AddLine(newbieText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		else
			GameTooltip:SetText(newbieText, r, g, b, 1, 1);
		end
		GameTooltip:Show();
	else
		if ( not noNormalText ) then
			GameTooltip:SetOwner(this);
			GameTooltip:SetText(normalText, r, g, b);
		end
		
	end
end

--Not currently used but left in just in case
function GameTooltip_SetQuality(quality)
	if ( quality and quality ~= -1 ) then
		local color = getglobal("ITEM_QUALITY".. quality .."_TOOLTIP_COLOR");
		this:SetBackdropBorderColor(color.r, color.g, color.b);
		if ( quality > 2 ) then
			color = getglobal("ITEM_QUALITY".. quality .."_TOOLTIP_BGCOLOR");
			this:SetBackdropColor(color.r, color.g, color.b);
		end
	else
		this:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	end
end