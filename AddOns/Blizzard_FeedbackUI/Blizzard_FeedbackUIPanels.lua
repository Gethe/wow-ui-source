--------------------------------------------------------------------------------
-- Abandon all hope....
--------------------------------------------------------------------------------


--[[	
function START_BUG_FUNCTIONS ()
end
]]--	
	

--[[	
function Bug_Info_Panel ()
end
]]--	
	
--Create panels for the Bug form--
FeedbackUI_SetupPanel{
	name = "InfoPanel",
	labelText = FEEDBACKUIINFOPANELLABEL_TEXT,
	parent = "FeedbackUIBugFrame",
	inherits = "FeedbackPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPLEFT", ["x"] = -2, ["y"] = -28 }, 
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPRIGHT", ["x"] = 2, ["y"] = -28 } },
	size = { ["y"] = 130 },
	Setup = function(obj)
				obj.infoLines = {}
				obj.infoTable = {}
			end,
	event = {"ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_LEVEL_UP" },
	Handler = function(self, event, ...) if ( event == "PLAYER_LEVEL_UP" ) then 
							local args = {...};
							for _, line in next, self.infoLines do
								if ( line:GetName():match("Char") ) then 
									local panel = self;
									local genderTable = FEEDBACKUI_GENDERTABLE;
									if ( not panel.infoTable ) then
										panel.infoTable = {}
									end
                                    panel.infoTable["character"] = FeedbackUI_GetLocalizedCharString(args[1], UnitRace("player"), genderTable[UnitSex("player")], UnitClass("player"));
									-- panel.infoTable["character"] = "Lvl "..arg1.." "..UnitRace("player").." "..genderTable[UnitSex("player")].." "..UnitClass("player");
									panel.infoTable["level"] = args[1];
									panel.infoTable["race"] = UnitRace("player");
									panel.infoTable["sex"] = genderTable[UnitSex("player")];
									panel.infoTable["class"] = UnitClass("player");
									line.value:SetText(panel.infoTable["character"])
								end
							end
						else
							pcall(self.OnShow, self) end
						end,	
	OnShow = 	function(obj) 
    				for _, line in next, obj.infoLines do
    					if ( line.Update ) then line.Update(line) end
    				end	
    			end,
	Load = 	function(obj)
				for _, line in next, obj.infoLines do
					if ( line.Load ) then line.Load(line) end
				end
			end }
			
--Lines for the Bug form's info panel--				
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Version",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMVER_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["version"], line:GetParent().infoTable["build"],line:GetParent().infoTable["date"] = GetBuildInfo();
				line.value:SetText("WoW " .. line:GetParent().infoTable["version"] .. " \[Release\] Build " .. line:GetParent().infoTable["build"]);
			end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Realm",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMREALM_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["realm"] = GetRealmName();
				line.value:SetText(line:GetParent().infoTable["realm"])
			end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Name",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMNAME_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["name"] = UnitName("player");
				line.value:SetText(line:GetParent().infoTable["name"])
			end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Char",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMCHAR_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["character"] = FeedbackUI_GetLocalizedCharString(UnitLevel("player"), UnitRace("player"), FEEDBACKUI_GENDERTABLE[UnitSex("player")], UnitClass("player"));
				line:GetParent().infoTable["level"] = UnitLevel("player");
				line:GetParent().infoTable["race"] = UnitRace("player");
				line:GetParent().infoTable["sex"] = FEEDBACKUI_GENDERTABLE[UnitSex("player")];
				line:GetParent().infoTable["class"] = UnitClass("player");
				line.value:SetText(line:GetParent().infoTable["character"])
			end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Map",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMMAP_TEXT,
	Update = function(line)
			line:GetParent().infoTable = line:GetParent().infoTable or {}
			
			--Record positioning information with the Map line since there isn't any particular place to do it with the new format.
			local debugStats, parseString
			
			if ( GetDebugStats() ) then 
				debugStats = {}
				parseString="([^%c]+)";
				for line in string.gmatch(GetDebugStats(), parseString) do
					table.insert(debugStats, line)
				end
			else
				debugStats = ""
			end	
			
			if ( debugStats ~= "" ) then 
				line:GetParent().infoTable["position"] = string.gsub(debugStats[2], "Player position: ", "");
				line:GetParent().infoTable["facing"] = debugStats[3]
				line:GetParent().infoTable["speed"] = debugStats[4]
				
				for _, debugStat in next, debugStats do
					if ( string.find(debugStat, "Obj") ) then
						line:GetParent().infoTable["chunk"] = string.gsub(string.gsub(debugStat, "Obj", ""), " ", "");
					end
					if ( string.find(debugStat, "Chunk ") ) then
						line:GetParent().infoTable["chunk"] = (line:GetParent().infoTable["chunk"] or "") .. " : " .. string.gsub(debugStat, "Chunk ", "");
						break;
					end
				end
			end
			
			local x, y = GetPlayerMapPosition("player");
			x = math.floor(x * 100)
			y = math.floor(y * 100)
			line:GetParent().infoTable["coords"] = x..", "..y	
			
			local mapCompare = { GetMapContinents() };
			SetMapToCurrentZone();
			line:GetParent().infoTable["map"] = mapCompare[GetCurrentMapContinent()];
			line.value:SetText(line:GetParent().infoTable["map"])
		end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Zone",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMZONE_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["zone"] = GetRealZoneText();
				line.value:SetText(line:GetParent().infoTable["zone"])
			end	
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Area",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMAREA_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["area"] = GetSubZoneText();
				line.value:SetText(line:GetParent().infoTable["area"])
			end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Addons",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMADDONS_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["addons"] = nil;
				line:GetParent().infoTable["addonsdisabled"] = nil;
				line:GetParent().infoTable["addonloaded"] = nil;
				line:GetParent().infoTable["addonsWrap"] = nil;

				local addonsList, addonsListCount, wrapCount
				
				addonsList = {}
				for i = 1, GetNumAddOns() do
					table.insert(addonsList, { GetAddOnInfo(i) })
				end
				if ( addonsList == nil ) then addonsList = { "None" } end
								
				addonsListCount = table.maxn(addonsList)
				wrapCount = 1
				
				for i = 1, addonsListCount do
					if not ( line:GetParent().infoTable["addons"] ) then
						if ( addonsList[i][4] == 1 ) then
							line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
							line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
							wrapCount = 1;
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
                        end
						line:GetParent().infoTable["addons"] = addonsList[i][1];
					else
						if ( addonsList[i][4] == 1 ) then
							if not ( line:GetParent().infoTable["addonsWrap"] ) then
								line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
								wrapCount = 1;
							elseif ( ( wrapCount / 3) == math.floor( wrapCount / 3 ) ) then
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"].."\n"..addonsList[i][1];
								wrapCount = wrapCount + 1;
							else
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"]..", "..addonsList[i][1];
								wrapCount = wrapCount + 1;
							end
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
						end
						line:GetParent().infoTable["addons"] = line:GetParent().infoTable["addons"]..", "..addonsList[i][1];
					end	
				end
				
                line.value:SetText(FEEDBACKUILBLADDONS_MOUSEOVER);
				
			end,
	
	Setup = function(line)	
				line:SetScript("OnEnter", 
								function(self)
									self:SetScript("OnUpdate", 
										function(self, elapsed) 
											local x, y = GetCursorPosition();
											x = x / self:GetEffectiveScale();
											y = y / self:GetEffectiveScale();
											local value = getglobal(self:GetName() .. "Value")
											if ( x > (value:GetLeft() + ( value:GetWidth() / self:GetEffectiveScale() ) ) - ( value:GetStringWidth() + 15 ) / self:GetEffectiveScale() ) then
												GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
												GameTooltip:SetText((self:GetParent().infoTable["addonsWrap"] or "")) 
											else
												GameTooltip:Hide()
											end
										end)
								end);
				line:SetScript("OnLeave", function(self) GameTooltip:Hide(); self:SetScript("OnUpdate", nil) end )
                if ( GetLocale() == "deDE" ) then
                    FeedbackUIBugFrameInfoPanelAddonsValue:ClearAllPoints();
                    FeedbackUIBugFrameInfoPanelAddonsValue:SetPoint("TOPLEFT", FeedbackUIBugFrameInfoPanelAddonsLabel, "TOPRIGHT", -24, 0);
                    FeedbackUIBugFrameInfoPanelAddonsValue:SetPoint("RIGHT", FeedbackUIBugFrameInfoPanelAddons, "RIGHT", -4, 0);              
                end
			end,
	
	handlers = { 	{ ["type"] = "OnEnter",	["func"] = 	function(line) 
																DEFAULT_CHAT_FRAME:AddMessage("Entered");
																GameTooltip:SetOwner(line, "ANCHOR_CURSOR"); 
																GameTooltip:SetText(line.infoTable["addonsWrap"]);
															end }, 
					{ ["type"] = "OnLeave", ["func"] = 	function() GameTooltip:Hide() end } }
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="Talents",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
            local talents = {};
            local points;
    		for tab=1, GetNumTalentTabs() do
    			for talent=1, GetNumTalents(tab) do
    				_, _, _, _, points = GetTalentInfo(tab, talent);
    				tinsert(talents, points);
    			end
    		end
            
            line:GetParent().infoTable["talents"] = table.concat(talents);
        end,
    Setup =
        function (line)
            line:Hide();
        end
    }
	
FeedbackUI_AddInfoLine{
    parent="FeedbackUIBugFrameInfoPanel",
    name="Equipment",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
            line:GetParent().infoTable["equipment"] = FeedbackUI_GetInventoryInfo();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };

FeedbackUI_AddInfoLine{
    parent="FeedbackUIBugFrameInfoPanel",
    name="SurveyID",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}            
            line:Hide();
            line:GetParent().infoTable["surveyid"] = g_FeedbackUI_feedbackVars["focusid"]
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="VideoOptions",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUI_BuildSettingsString("Video");
            
            line:GetParent().infoTable["videooptions"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="SoundOptions",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUI_BuildSettingsString("Sound");
            
            line:GetParent().infoTable["soundoptions"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="ObjectName",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUIWelcomeFrameBannerTargetName:GetText();
            
            line:GetParent().infoTable["objectname"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
    
FeedbackUI_AddInfoLine{
    parent="FeedbackUIBugFrameInfoPanel",
    name="Locale",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};
            line:Hide();
            line:GetParent().infoTable["locale"] = GetLocale();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };

FeedbackUI_AddInfoLine{
	parent="FeedbackUIBugFrameInfoPanel",
	name="ObjectName",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUIWelcomeFrameBannerTargetName:GetText();
            
            line:GetParent().infoTable["objectname"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };	
	
--[[	
function Bug_Status_Panel ()
end
]]--	
	
	
FeedbackUI_SetupPanel{
	name = "StatusPanel",
	parent = "FeedbackUIBugFrame",
	inherits = "FeedbackPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentInfoPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = 3 },
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parentInfoPanel", ["relativepoint"] = "TOPRIGHT", ["x"] = 0, ["y"] = 3 } },
	size = { ["y"] = 70 },
	Setup = function(obj)
				-- Create the seperator line that follows the Status panel.
                obj.infoLines = {};
				obj.seperator = CreateFrame("Frame", obj:GetName() .. "Line", obj, "FeedbackLineTemplate");
				obj.seperator:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", 0, -5);
				obj.seperator:SetPoint("TOPRIGHT", obj, "BOTTOMRIGHT", 0, -5);	
				obj.status = {};
                obj.statusValue = {};
                obj:GetParent().statusPanel = obj;
                
			end,
	OnShow = 	function(panel)
				for _, line in next, panel.infoLines do
					if ( line.Update ) then 
                        line.Update(line, panel) 
                    end
				end	
			end
	}

FeedbackUI_AddInfoLine{
	name = "Where",
	parent = "FeedbackUIBugFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHERE_TEXT,
	Setup = function(line)
				line.type = "where"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}
			
FeedbackUI_AddInfoLine{
	name = "Who",
	parent = "FeedbackUIBugFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHO_TEXT,
	Setup = function(line)
				line.type = "who"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}

FeedbackUI_AddInfoLine{
	name = "Type",
	parent = "FeedbackUIBugFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMTYPE_TEXT,
	Setup = function(line)
				line.type = "type"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}			
					
FeedbackUI_AddInfoLine{
	name = "When",
	parent = "FeedbackUIBugFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHEN_TEXT,
	Setup = function(line)
				line.type = "when"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}	

--[[	
function Bug_Stepthrough_Panel ()
end
]]--	
	
			
FeedbackUI_SetupPanel{
	name = "StepThroughPanel",
	parent = "FeedbackUIBugFrame",
	inherits = "FeedbackWizardTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentStatusPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -1 },
				{ ["point"] = "BOTTOMRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "BOTTOMRIGHT", ["x"] = 2, ["y"] = 19 } },
    OnHide =  function (panel)
                panel.Reset(panel);
            end,                                
	Setup = function(panel)
				panel.maxbuttons = 1
				panel.scrollResults = {}
				panel.history = {}
				panel.table = FEEDBACKUI_BUGWELCOMETABLE
				
                panel:GetParent().stepThroughPanel = panel;
                
                panel.Localize = 
                    function(panel)
                        if GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "deDE" then
                            panel.buttonWidth = 415
                            panel.buttonHeight = 28
                            panel.input:SetWidth(390)
                    
                            panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
                            panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        else
                            panel.buttonWidth = 325
                            panel.buttonHeight = 28
                            panel.input:SetWidth(307)
                            
            				panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
            				panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        end
                    end
                    
				
				panel.Start = function(panel) panel.Render(panel, panel.startlink) end
				
				panel.Back = 
					function(panel) 
						panel.Render(panel, panel.history[#panel.history]); 
                        panel:GetParent().submit:Disable();
						panel.history[#panel.history] = nil; 
						if ( #panel.history == 0 ) then panel:GetParent().back:Disable(); end 
                    end
						
				panel.Reset = 	
					function(panel) 
                        panel.history = {}; 
                        panel:GetParent().back:Disable();
                        panel:GetParent().submit:Disable();
                        panel.scrollResults = {};
                        panel.scroll.index = nil;
                        for index, panelElement in next, panel:GetParent().panels do 
                            if ( panelElement.name == "StatusPanel" ) then
                                panelElement.status = {}
                                for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							elseif ( panelElement.name == "InfoPanel" ) then
								panelElement.infoTable = {};
								for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							end
                        end
                        
                        panel.input:SetText(FEEDBACKUIBUGFRMINPUTBOX_TEXT);
                        panel.input.default = nil;
                        panel.input:HighlightText(0);
                        
                        if ( panel.table == FEEDBACKUI_BUGWELCOMETABLE ) then
                            FeedbackUITab4:Click()
                            return;
                        end
                        
                        panel.table = FEEDBACKUI_BUGWELCOMETABLE; 
                        panel.Render(panel) 
                        FeedbackUITab4:Click()
                    end
								
				panel.Submit = 
					function(panel)
						panel.infoString = "";
						local infoTable = {};
						-- local bs=FEEDBACKUI_DELIMITER;
						for _, panelElement in next, panel:GetParent().panels do 
							if ( panelElement.name == "StatusPanel" ) then
								for num, line in next, panelElement.infoLines do
									infoTable[line.type] = (panelElement.statusValue[line.type] or "")
								end
							elseif ( panelElement.name == "InfoPanel" ) then
								for index, value in next, panelElement.infoTable do
									infoTable[index] = value
								end
							end
						end
                        
                        infoTable["combats"] = 0;
                        infoTable["deaths"] = 0;
                        infoTable["averagelength"] = 0;
                        infoTable["feedbacktype"] = 0;
						
						inputString = string.gsub(panel.input:GetText(), "\n", " ");
						inputString = string.gsub(inputString, FEEDBACKUI_DELIMITER, " ");
						-- local objName = FeedbackUIWelcomeFrameBannerTargetName:GetText();
						-- if (objName) then objName = "(" .. objName .. ") "; end
						-- infoTable["text"] = panel.infoString .. (objName or "") .. inputString;
						--panel.infoString = panel.infoString .. (objName or "") .. inputString;
						infoTable["text"] = panel.infoString .. inputString;
						
						local indexLine;
						for index, field in next, FEEDBACKUI_FIELDS do
							if ( infoTable[field] ) then
                                infoTable[field] = string.gsub(infoTable[field], "[%<%>%/%\n]+", " ");
								indexLine = "<" .. index .. ">" .. infoTable[field] .. "</" .. index .. ">";
								panel.infoString = panel.infoString .. indexLine;
							end
						end
                        
                        -- for index, field in next, FEEDBACKUI_SURVEYFIELDS do
                            -- if not ( infoTable[field] ) then
								-- infoTable[field] = ""
								-- panel.infoString = panel.infoString .. bs
							-- else
								-- panel.infoString = panel.infoString .. string.gsub(infoTable[field],"\n"," ")..bs
							-- end
                        -- end
						
						ReportBug(panel.infoString);
						UIErrorsFrame:Clear();
						UIErrorsFrame:AddMessage(FEEDBACKUI_CONFIRMATION, 1, 1, .1, 1.0, 5);
                        panel.table = {};
						pcall(panel.Reset, panel)
						FeedbackUI:Hide();
					end
				
				panel.UpdateButtons = 
					function(panel) 
						panel.CreateButtons(panel)
					end
										
				panel.Click = 	
					function(panel, element)
						if ( not panel or not element ) then return end;
						table.insert(panel.history, panel.table);
						panel.parent.back:Enable();
                        
						
						if ( element.summary ) then
							for index, panelElement in next, panel:GetParent().panels do
								if ( panelElement.name == "StatusPanel" ) then
									for num, line in next, panelElement.infoLines do
										if ( line.type == element.summary.type ) then
											line.value:SetText(getglobal(element.summary.text));

											panelElement.status[line.type] = getglobal(element.summary.text);
                                            panelElement.statusValue[line.type] = element.summary.value;
										end
									end
								end
							end
						end
						
						if getglobal(element.link) then
							panel.Render(panel, getglobal(element.link));
						else
							panel.Render(panel, element.link);
						end
						
					end
				
				panel.Render = 	
					function(panel, renderTable)	
					
						-- Reset all the tracking values to their defaults, and hide all the buttons and things that will later be shown.
						panel.scroll:Hide();
						panel.prompt:Hide();
						panel.edit:Hide();
						panel:GetParent().start:Hide();
						panel:GetParent().back:Hide();
						panel:GetParent().reset:Hide();
						panel:GetParent().submit:Hide();
						panel.scroll.thumb:Disable()
						panel.scrollResults = {};
						
						for i = 1, #panel.scroll.buttons do
							panel.scroll.buttons[i]:Hide();
						end
						
						--Make sure we have something to render. If we get the "edit" string, then show the edit box.
						if ( not renderTable ) then 
							renderTable = panel.table 
						elseif ( ( type(renderTable) == "string" )  and ( renderTable == "edit" ) ) then 
							panel.table = renderTable;
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.header);
							panel.header:SetText(FEEDBACKUI_BUGINPUTHEADER)
							panel.subtext:SetText("")
                            if ( panel.input:GetText() == "" ) then
                                panel.input:SetText(FEEDBACKUIBUGFRMINPUTBOX_TEXT)
                                panel.input.default = FEEDBACKUIBUGFRMINPUTBOX_TEXT
                            else
                                panel.input.default = FEEDBACKUIBUGFRMINPUTBOX_TEXT
                            end
							panel.scroll:Hide();
							panel:GetParent().back:Show();
							panel:GetParent().reset:Show();
							panel:GetParent().submit:Show();
							panel.edit:Show();
							return;
						else
							panel.table = renderTable 
						end;
											
						if ( renderTable.header == "" and renderTable.subtext ) then
							panel.header:ClearAllPoints()
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.subtext);
							panel.subtext:SetText("");
						else
							if ( renderTable.header ) then
								panel.header:SetPoint("TOPLEFT", panel.header:GetParent(), "TOPLEFT", 8, -6)
								panel.header:SetText(renderTable.header);
							end
							
							if renderTable.subtext then
								panel.subtext:SetText(renderTable.subtext);
							end
						end
						
						local i = 0;
                        local maxSummary = math.huge
						for ordinal, element in ipairs(renderTable) do
							--Clear downlevel status lines.
							maxSummary = math.huge;
							if ( element.summary ) then
								for index, panelElement in next, panel:GetParent().panels do
									if ( panelElement.name == "StatusPanel" ) then
										for num, line in next, panelElement.infoLines do
											if ( line.type == element.summary.type ) then
												maxSummary = num;
											end
											if ( num >= maxSummary ) then 
												line.value:SetText("") 
												panelElement.status[line.type] = nil;
                                                panelElement.statusValue[line.type] = nil;
											elseif ( ( num < maxSummary ) and ( line.value:GetText() == "" or line.value:GetText() == nil ) ) then
                                                panelElement.status[line.type] = panelElement.status[line.type] or "N/A";
                                                panelElement.statusValue[line.type] = panelElement.statusValue[line.type] or 0;
                                                line.value:SetText(panelElement.status[line.type]);
											end
										end
									end
								end
							end

							i = i + 1;
							panel.scrollResults[ordinal] = element;
							if ( element.prompt ) then
								panel.prompt:Show();
								panel:GetParent().start:Show();
								panel.prompt:SetText(element.prompt);
								panel.startlink = getglobal(element.link);
							else											
								panel.scroll:Show();
								panel:GetParent().start:Hide();
								panel:GetParent().back:Show();
								panel:GetParent().reset:Show();
								panel:GetParent().submit:Show();
								if ( panel.scroll.buttons[i] ) then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - ( element.offset * FEEDBACKUI_OFFSETPIXELS ) - 15)
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - 15)
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.scroll.index = 1;
						panel.UpdateScrollButtons(panel);
					end
			
				panel.SetScrollVars = 	
					function(panel)
						-- Calculate values necessary to scroll
						panel.scroll.maxy = (panel.scroll.controls:GetTop() - 5);
						panel.scroll.miny = (panel.scroll.controls:GetBottom() + 13);
						panel.scroll.steprange = panel.scroll.maxy - panel.scroll.miny;
						panel.scroll.numsteps = #panel.scrollResults - #panel.scroll.buttons;
						panel.scroll.stepsize = panel.scroll.steprange / panel.scroll.numsteps;				
					end
			
				panel.ScrollOnUpdate =
					function(panel, elapsed)
						if ( not panel.timer ) then panel.timer = 0 end
						panel.timer = panel.timer + elapsed;
						if ( panel.timer > 0.1 ) then
							panel.SetScrollVars(panel);
							
							
							-- Compensate for UI scaling
							-- yarealy
							local x, y = GetCursorPosition();
							x = x / panel:GetEffectiveScale();
							y = y / panel:GetEffectiveScale();
							
							-- See where the user is trying to move the thumb to.
--~ 							local moveVariable = -(panel.scroll.maxy - y)
													
							if ( -(panel.scroll.maxy - y) > 0 ) then
								-- If the user has tried to move the thumb to the top of the track or above it, go to the first result.
								panel.scroll.thumb:ClearAllPoints();
								panel.scroll.thumb:SetPoint("TOP", 0, 0);
								panel.scroll.index = 1;
							elseif ( math.abs(-(panel.scroll.maxy - y)) > (panel.scroll.maxy - panel.scroll.miny) ) then
								-- If the user has tried to move the thumb to the bottom of the track or below it, go to the last result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - panel.scroll.miny))
								panel.scroll.index = ( #panel.scrollResults - #panel.scroll.buttons + 1 )
							else
								-- Otherwise, move the scroll thumb to the appropriate position and go to the appropriate result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - y));
								
								if ( (math.round( (math.abs(-(panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1) ~= panel.scroll.index ) then
									-- Determine the target index, and if it's not the current index, then change the index.
									panel.scroll.index = math.round( (math.abs(-(panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1
								end
							end
							panel.ScrollButtons(panel)							
                            panel.timer = 0;
						end
					end
                    
                panel.StartIncrementalScroll =
                    function(panel, direction)
                        panel.scrollDir = direction;
                        panel.MoveScroll(panel, panel.scrollDir);
                        panel:SetScript("OnUpdate", function(self, elapsed) panel.IncrementalUpdate(panel, elapsed) end);                
                    end
                    
                panel.StopIncrementalScroll =
                    function(panel)
                        panel:SetScript("OnUpdate", nil)
                        panel.scrollDir = nil;
                        panel.timeSinceLastIncrement = nil;
                    end
                
                panel.IncrementalUpdate =
                    function(panel, elapsed)
                        panel.timeSinceLastIncrement = ( panel.timeSinceLastIncrement or 0 ) + elapsed
                        if ( panel.timeSinceLastIncrement > .21 and panel.scrollDir ) then
                            panel.MoveScroll(panel, panel.scrollDir);
                            panel.timeSinceLastIncrement = 0.15;
                        end
                    end

				panel.StartScroll =
					function(panel)
						if ( panel.scroll.thumb:IsEnabled() == 1 ) then
							panel.scroll.update:Show();
						end
					end
					
				panel.StopScroll =
					function(panel)
						panel.scroll.update:Hide()
					end					
			
				panel.UpdateScrollButtons =
					function(panel)
					
						-- Update the position of the scroll thumb
						panel.SetScrollVars(panel);
						if not ( panel.scroll.update:IsVisible() == 1 ) then
							panel.scroll.thumb:ClearAllPoints();
--~ 							local moveto = -(panel.scroll.stepsize * ( panel.scroll.index -1))
							if ( -(panel.scroll.stepsize * ( panel.scroll.index -1)) > 0 ) then -- Yay crappy failsafes!
                                panel.scroll.thumb:SetPoint("TOP", 0, (panel.scroll.stepsize * ( panel.scroll.index -1)));
                            else
                                panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.stepsize * ( panel.scroll.index -1)));
                            end
						end
						
						-- Enable the up button if appropriate
						if ( panel.scroll.index > 1 ) then
							panel.scroll.upbtn:Enable()
						else
							panel.scroll.upbtn:Disable()
						end
						
						-- Enable the down button if appropriate
						if ( ( panel.scroll.index + #panel.scroll.buttons ) <= #panel.scrollResults ) then
							panel.scroll.downbtn:Enable()
						else
							panel.scroll.downbtn:Disable();
						end
						
						-- Enable the scroll thumb if either the up or down button is enabled.
						if ( ( panel.scroll.upbtn:IsEnabled() == 1 ) or ( panel.scroll.downbtn:IsEnabled() == 1 ) ) then
							panel.scroll.thumb:Enable();
						else
							panel.scroll.thumb:Disable();
						end
					end
			
				panel.MoveScroll = 	
					function(panel, int)
						if ( ( panel.scroll.index + int >= 1 ) and ( ( panel.scroll.index + int ) + #panel.scroll.buttons <= ( #panel.scrollResults + 1 ) ) ) then
							panel.scroll.index = panel.scroll.index + int
						end
						panel.ScrollButtons(panel)						
					end
			
				panel.ScrollButtons = 
					function(panel)
						local i = 0;
						
						for ordinal, element in ipairs(panel.table) do
							if ( ordinal >= panel.scroll.index ) then
								i = i + 1;
								if panel.scroll.buttons[i] then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - ( element.offset * FEEDBACKUI_OFFSETPIXELS ) - 15)
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - 15)
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.UpdateScrollButtons(panel);
					end
			
				panel.CreateButtons = 
					function(panel)
						if ( panel.scroll and panel.scroll.buttons ) then
							local buttoncapacity = ( math.floor(((panel.scroll:GetHeight()) / panel.scroll.buttons[1]:GetHeight())) )
							local numbuttons = #panel.scroll.buttons;
							if numbuttons < buttoncapacity and buttoncapacity > panel.maxbuttons then
                                local newButton;
								for i = 1, buttoncapacity - numbuttons do
									newButton = CreateFrame("Button", string.gsub(panel.scroll.buttons[1]:GetName(), "%d+", "") .. (numbuttons + i), panel.scroll, "ScrollElementTemplate")
									newButton:SetPoint("TOPLEFT", panel.scroll.buttons[numbuttons + i - 1], "BOTTOMLEFT", 0, 0)
									newButton:SetWidth(panel.scroll.buttons[1]:GetWidth());
									newButton:SetHeight(panel.scroll.buttons[1]:GetHeight());
									table.insert(panel.scroll.buttons, newButton)
									newButton.index = #panel.scroll.buttons;
								end
								panel.maxbuttons = buttoncapacity;
							end
						else
						end
					end	
					
			end
	}

--[[	
function START_SUGGESTION_FUNCTIONS ()
end
]]--	
--[[	
function Suggestion_Info_Panel ()
end
]]--		
--Create panels for the Suggest form--
FeedbackUI_SetupPanel{
	name = "InfoPanel",
	labelText = FEEDBACKUIINFOPANELLABEL_TEXT,
	parent = "FeedbackUISuggestFrame",
	inherits = "FeedbackPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPLEFT", ["x"] = -2, ["y"] = -28 }, 
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPRIGHT", ["x"] = 2, ["y"] = -28 } },
	size = { ["y"] = 130 },
	Setup = function(obj)
				obj.infoLines = {}
				obj.infoTable = {}
			end,
	event = {"ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_LEVEL_UP" },
	Handler = function(self, event, ...) if ( event == "PLAYER_LEVEL_UP" ) then 
							local args = {...};
							for _, line in next, self.infoLines do
								if ( line:GetName():match("Char") ) then 
									line:GetParent().infoTable = line:GetParent().infoTable or {};
									line:GetParent().infoTable["character"] = FeedbackUI_GetLocalizedCharString(args[1], UnitRace("player"), FEEDBACKUI_GENDERTABLE[UnitSex("player")], UnitClass("player"));
									line:GetParent().infoTable["level"] = args[1];
									line:GetParent().infoTable["race"] = UnitRace("player");
									line:GetParent().infoTable["sex"] = FEEDBACKUI_GENDERTABLE[UnitSex("player")];
									line:GetParent().infoTable["class"] = UnitClass("player");
									line.value:SetText(line:GetParent().infoTable["character"])
								end
							end
						else
							pcall(self.OnShow, self) end
						end,	 					
	OnShow = 	function(obj) 
    				for _, line in next, obj.infoLines do
    					if ( line.Update ) then line.Update(line) end
    				end	
    			end,
	Load = 	function(obj)
				for _, line in next, obj.infoLines do
					if ( line.Load ) then line.Load(line) end
				end
			end }

--Lines for the Suggest form's InfoPanel--
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Version",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMVER_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {};
				line:GetParent().infoTable["version"], line:GetParent().infoTable["build"], line:GetParent().infoTable["date"] = GetBuildInfo();
				line.value:SetText("WoW " .. line:GetParent().infoTable["version"] .. " \[Release\] Build " .. line:GetParent().infoTable["build"]);
			end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Realm",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMREALM_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {};
				line:GetParent().infoTable["realm"] = GetRealmName();
				line.value:SetText(line:GetParent().infoTable["realm"])
			end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Name",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMNAME_TEXT,
	Update = function(line)
			line:GetParent().infoTable = line:GetParent().infoTable or {};
			line:GetParent().infoTable["name"] = UnitName("player");
			line.value:SetText(line:GetParent().infoTable["name"])
		end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Char",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMCHAR_TEXT,
	Update = function(line)
			line:GetParent().infoTable = line:GetParent().infoTable or {};
			line:GetParent().infoTable["character"] = FeedbackUI_GetLocalizedCharString(UnitLevel("player"), UnitRace("player"), FEEDBACKUI_GENDERTABLE[UnitSex("player")], UnitClass("player"));
			line:GetParent().infoTable["level"] = UnitLevel("player");
			line:GetParent().infoTable["race"] = UnitRace("player");
			line:GetParent().infoTable["sex"] = FEEDBACKUI_GENDERTABLE[UnitSex("player")];
			line:GetParent().infoTable["class"] = UnitClass("player");
			line.value:SetText(line:GetParent().infoTable["character"])
		end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Map",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMMAP_TEXT,
	Update = function(line)
			line:GetParent().infoTable = line:GetParent().infoTable or {};
			
			--Record positioning information with the Map line since there isn't any particular place to do it with the new format.
			local debugStats, parseString
			
			if ( GetDebugStats() ) then 
				debugStats = {}
				parseString="([^%c]+)";
				for line in string.gmatch(GetDebugStats(), parseString) do
					table.insert(debugStats, line)
				end
			else
				debugStats = ""
			end	
			
			if ( debugStats ~= "" ) then 
				line:GetParent().infoTable["position"] = string.gsub(debugStats[2], "Player position: ", "");
				line:GetParent().infoTable["facing"] = debugStats[3]
				line:GetParent().infoTable["speed"] = debugStats[4]
	
				for _, debugStat in next, debugStats do
					if ( string.find(debugStat, "Obj") ) then
						line:GetParent().infoTable["chunk"] = string.gsub(string.gsub(debugStat, "Obj", ""), " ", "");
					end
					if ( string.find(debugStat, "Chunk ") ) then
						line:GetParent().infoTable["chunk"] = (line:GetParent().infoTable["chunk"] or "") .. " : " .. string.gsub(debugStat, "Chunk ", "");
						break;
					end
				end
			end
			
			local x, y = GetPlayerMapPosition("player");
			x = math.floor(x * 100)
			y = math.floor(y * 100)
			line:GetParent().infoTable["coords"] = x..", "..y	
			
			local mapCompare = { GetMapContinents() };
			SetMapToCurrentZone();
			line:GetParent().infoTable["map"] = mapCompare[GetCurrentMapContinent()];
			line.value:SetText(line:GetParent().infoTable["map"])
		end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Zone",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMZONE_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {};
				line:GetParent().infoTable["zone"] = GetRealZoneText();
				line.value:SetText(line:GetParent().infoTable["zone"])
			end	
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Area",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMAREA_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {};
				line:GetParent().infoTable["area"] = GetSubZoneText();
				line.value:SetText(line:GetParent().infoTable["area"])
			end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Addons",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMADDONS_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {};
                line:GetParent().infoTable["addons"] = nil
                line:GetParent().infoTable["addonsdisabled"] = nil
                line:GetParent().infoTable["addonloaded"] = nil
                line:GetParent().infoTable["addonsWrap"] = nil
            
				local addonsList, addonsListCount, wrapCount
				
				addonsList = {}
				for i = 1, GetNumAddOns() do
					local infoTable = { GetAddOnInfo(i) };
					table.insert(addonsList, infoTable)
				end
				if ( addonsList == nil ) then addonsList = { "None" } end
								
				addonsListCount = table.maxn(addonsList)
				wrapCount = 1
				
				for i = 1, addonsListCount do
					if not ( line:GetParent().infoTable["addons"] ) then
						if ( addonsList[i][4] == 1 ) then
							line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
							line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
							wrapCount = 1;
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
                        end
						line:GetParent().infoTable["addons"] = addonsList[i][1];
					else
						if ( addonsList[i][4] == 1 ) then
							if not ( line:GetParent().infoTable["addonsWrap"] ) then
								line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
								wrapCount = 1;
							elseif ( ( wrapCount / 3) == math.floor( wrapCount / 3 ) ) then
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"].."\n"..addonsList[i][1];
								wrapCount = wrapCount + 1;
							else
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"]..", "..addonsList[i][1];
								wrapCount = wrapCount + 1;
							end
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
						end
						line:GetParent().infoTable["addons"] = line:GetParent().infoTable["addons"]..", "..addonsList[i][1];
					end	
				end
                
                line.value:SetText(FEEDBACKUILBLADDONS_MOUSEOVER);
			end,
	
	Setup = function(line)				
				line:SetScript("OnEnter", 
								function(self)
									self:SetScript("OnUpdate", 
										function(self, elapsed) 
											local x, y = GetCursorPosition();
											x = x / self:GetEffectiveScale();
											y = y / self:GetEffectiveScale();
											local value = getglobal(self:GetName() .. "Value")
											if ( x > (value:GetLeft() + ( value:GetWidth() / self:GetEffectiveScale() ) ) - ( value:GetStringWidth() + 15 ) / self:GetEffectiveScale() ) then
												GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
												GameTooltip:SetText((self:GetParent().infoTable["addonsWrap"] or "")) 
											else
												GameTooltip:Hide()
											end
										end)
								end);
				line:SetScript("OnLeave", function(self) GameTooltip:Hide(); self:SetScript("OnUpdate", nil) end )
                if ( GetLocale() == "deDE" ) then
                    FeedbackUISuggestFrameInfoPanelAddonsValue:ClearAllPoints();
                    FeedbackUISuggestFrameInfoPanelAddonsValue:SetPoint("TOPLEFT", FeedbackUISuggestFrameInfoPanelAddonsLabel, "TOPRIGHT", -24, 0);
                    FeedbackUISuggestFrameInfoPanelAddonsValue:SetPoint("RIGHT", FeedbackUISuggestFrameInfoPanelAddons, "RIGHT", -4, 0);
                end
			end,
	
	handlers = { 	{ ["type"] = "OnEnter",	["func"] = 	function(line) 
																DEFAULT_CHAT_FRAME:AddMessage("Entered");
																GameTooltip:SetOwner(line, "ANCHOR_CURSOR");
																GameTooltip:SetText(line.infoTable["addonsWrap"]);
															end }, 
					{ ["type"] = "OnLeave", ["func"] = 	function() GameTooltip:Hide() end } }
	}
    
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="Talents",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};            
            line:Hide();
            local talents = {};
            local points;
    		for tab=1, GetNumTalentTabs() do
    			for talent=1, GetNumTalents(tab) do
    				_, _, _, _, points = GetTalentInfo(tab, talent);
    				tinsert(talents, points);
    			end
    		end
            
            line:GetParent().infoTable["talents"] = table.concat(talents);
        end,
    Setup =
        function (line)
            line:Hide();
        end
    }    
	
FeedbackUI_AddInfoLine{
    parent="FeedbackUISuggestFrameInfoPanel",
    name="Equipment",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};            
            line:Hide();
            line:GetParent().infoTable["equipment"] = FeedbackUI_GetInventoryInfo();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
    
FeedbackUI_AddInfoLine{
    parent="FeedbackUISuggestFrameInfoPanel",
    name="SurveyID",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};
            line:Hide();
            line:GetParent().infoTable["surveyid"] = g_FeedbackUI_feedbackVars["focusid"]
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };    
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISuggestFrameInfoPanel",
	name="ObjectName",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUIWelcomeFrameBannerTargetName:GetText();
            
            line:GetParent().infoTable["objectname"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
	
FeedbackUI_AddInfoLine{
    parent="FeedbackUISuggestFrameInfoPanel",
    name="Locale",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};
            line:Hide();
            line:GetParent().infoTable["locale"] = GetLocale();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };    

--[[	
function Suggestion_Status_Panel ()
end
]]--	
	
FeedbackUI_SetupPanel{
	name = "StatusPanel",
	parent = "FeedbackUISuggestFrame",
	inherits = "FeedbackPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentInfoPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = 3 },
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parentInfoPanel", ["relativepoint"] = "TOPRIGHT", ["x"] = 0, ["y"] = 3 } },
	size = { ["y"] = 70 },
	Setup = function(obj)
				-- Create the seperator line that follows the Status panel.
				obj.seperator = CreateFrame("Frame", obj:GetName() .. "Line", obj, "FeedbackLineTemplate");
				obj.seperator:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", 0, -5);
				obj.seperator:SetPoint("TOPRIGHT", obj, "BOTTOMRIGHT", 0, -5);
				obj.status = {};
                obj.statusValue = {};
                obj.infoLines = {};
                obj:GetParent().statusPanel = obj;
			end,
	OnShow = 	function(panel)
    				for _, line in next, panel.infoLines do
    					if ( line.Update ) then 
                            line.Update(line, panel)
                        end
    				end	
    			end
	
	}

FeedbackUI_AddInfoLine{
	name = "Where",
	parent = "FeedbackUISuggestFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHERE_TEXT,
	Setup = function(line)
				line.type = "where"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}
			
FeedbackUI_AddInfoLine{
	name = "Who",
	parent = "FeedbackUISuggestFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHO_TEXT,
	Setup = function(line)
				line.type = "who"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}

FeedbackUI_AddInfoLine{
	name = "Type",
	parent = "FeedbackUISuggestFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMTYPE_TEXT,
	Setup = function(line)
				line.type = "type"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}			
					
FeedbackUI_AddInfoLine{
	name = "When",
	parent = "FeedbackUISuggestFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMWHEN_TEXT,
	Setup = function(line)
				line.type = "when"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}	

--[[	
function Suggestion_Stepthrough_Panel ()
end
]]--	
			
FeedbackUI_SetupPanel{
	name = "StepThroughPanel",
	parent = "FeedbackUISuggestFrame",
	inherits = "FeedbackWizardTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentStatusPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -1 },
				{ ["point"] = "BOTTOMRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "BOTTOMRIGHT", ["x"] = 2, ["y"] = 19 } },
    OnHide =    function (panel)
                    panel.Reset(panel);
                end,                
	Setup = function (panel)
				panel.maxbuttons = 1
				panel.scrollResults = {}
				panel.history = {}
				panel.table = FEEDBACKUI_SUGGESTWELCOMETABLE
                
                panel:GetParent().stepThroughPanel = panel;
				
                panel.Localize = 
                    function(panel)
                        if GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "deDE" then
                            panel.buttonWidth = 415
                            panel.buttonHeight = 28
                            panel.input:SetWidth(390)
                    
                            panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
                            panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        else
                            panel.buttonWidth = 325
                            panel.buttonHeight = 28
                            panel.input:SetWidth(307)
                            
            				panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
            				panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        end
                    end
				
				panel.Start =   
                    function (panel) 
                        panel.Render(panel, panel.startlink) 
                    end
				
				panel.Back = 
					function (panel) 
						panel.Render(panel, panel.history[#panel.history]); 
                        panel:GetParent().submit:Disable();
						panel.history[#panel.history] = nil; 
                        if ( #panel.history == 0 ) then panel:GetParent().back:Disable(); end 
					end
						
				panel.Reset = 	
					function (panel) 
                        panel.history = {}; 
                        panel:GetParent().back:Disable();
                        panel.scrollResults = {};
                        panel.scroll.index = nil;
                        panel:GetParent().submit:Disable();
                        for index, panelElement in next, panel:GetParent().panels do 
                            if ( panelElement.name == "StatusPanel" ) then
                                panelElement.status = {}
                                panelElement.statusValue = {}
                                for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							elseif ( panelElement.name == "InfoPanel" ) then
								panelElement.infoTable = {};
								for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							end
                        end
                        panel.input:SetText(FEEDBACKUISUGGESTFRMINPUTBOX_TEXT)
                        panel.input.default = FEEDBACKUISUGGESTFRMINPUTBOX_TEXT
                        
                        if ( panel.table == FEEDBACKUI_SUGGESTWELCOMETABLE ) then
                            FeedbackUITab4:Click()
                            return;
                        end
                        
                        panel.table = FEEDBACKUI_SUGGESTWELCOMETABLE; 
                        panel.Render(panel) 
                        FeedbackUITab4:Click();
                    end
								
				panel.Submit = 
					function (panel)
						panel.infoString = "";
						local infoTable = {};
						-- local bs=FEEDBACKUI_DELIMITER;

						for _, panelElement in next, panel:GetParent().panels do 
							if ( panelElement.name == "StatusPanel" ) then
								for num, line in next, panelElement.infoLines do
									infoTable[line.type] = (panelElement.statusValue[line.type] or "")
								end
							elseif ( panelElement.name == "InfoPanel" ) then
								for index, value in next, panelElement.infoTable do
									infoTable[index] = value
								end
							end
						end
						
                        infoTable["feedbacktype"] = 1;
                        infoTable["combats"] = 0;
                        infoTable["deaths"] = 0;
                        infoTable["averagelength"] = 0;
						
						inputString = string.gsub(panel.input:GetText(), "\n", " ");
						inputString = string.gsub(inputString, FEEDBACKUI_DELIMITER, " ");
						-- local objName = FeedbackUIWelcomeFrameBannerTargetName:GetText();
						-- if (objName) then objName = "(" .. objName .. ") "; end
						-- infoTable["text"] = panel.infoString .. (objName or "") .. inputString;
						--panel.infoString = panel.infoString .. (objName or "") .. inputString;
						infoTable["text"] = panel.infoString .. inputString;
						
						local indexLine;
						for index, field in next, FEEDBACKUI_FIELDS do
							if ( infoTable[field] ) then
                                infoTable[field] = string.gsub(infoTable[field], "[%<%>%/%\n]+", " ");
								indexLine = "<" .. index .. ">" .. infoTable[field] .. "</" .. index .. ">";
								panel.infoString = panel.infoString .. indexLine;
							end
						end
						
                        -- for index, field in next, FEEDBACKUI_SURVEYFIELDS do
                            -- if not ( infoTable[field] ) then
								-- infoTable[field] = ""
								-- panel.infoString = panel.infoString .. bs
							-- else
								-- panel.infoString = panel.infoString .. string.gsub(infoTable[field],"\n"," ")..bs
							-- end
                        -- end
						
						ReportSuggestion(panel.infoString);
						UIErrorsFrame:Clear();
						UIErrorsFrame:AddMessage(FEEDBACKUI_CONFIRMATION, 1, 1, .1, 1.0, 5);
						pcall(panel.Reset, panel)
						FeedbackUI:Hide();
					end
				
				panel.UpdateButtons = 
					function (panel) 
						panel.CreateButtons(panel)
					end
										
				panel.Click = 	
					function (panel, element)
						if ( not panel or not element ) then return end;
						table.insert(panel.history, panel.table);
						panel.parent.back:Enable();
						
						if ( element.summary ) then
							for index, panelElement in next, panel:GetParent().panels do
								if ( panelElement.name == "StatusPanel" ) then
									for num, line in next, panelElement.infoLines do
										if ( line.type == element.summary.type ) then
											line.value:SetText(getglobal(element.summary.text));

											panelElement.status[line.type] = getglobal(element.summary.text);
                                            panelElement.statusValue[line.type] = element.summary.value;
										end
									end
								end
							end
						end
						
						if getglobal(element.link) then
							panel.Render(panel, getglobal(element.link));
						else
							panel.Render(panel, element.link);
						end
						
					end
				
				panel.Render = 	
					function (panel, renderTable)	
					
						-- Reset all the tracking values to their defaults, and hide all the buttons and things that will later be shown.
						panel.scroll:Hide();
						panel.prompt:Hide();
						panel.edit:Hide();
						panel:GetParent().start:Hide();
						panel:GetParent().back:Hide();
						panel:GetParent().reset:Hide();
						panel:GetParent().submit:Hide();
						panel.scroll.thumb:Disable()
						panel.scrollResults = {};
						
						for i = 1, #panel.scroll.buttons do
							panel.scroll.buttons[i]:Hide();
						end
						
						--Make sure we have something to render. If we get the "edit" string, then show the edit box.
						if ( not renderTable ) then 
							renderTable = panel.table 
						elseif ( ( type(renderTable) == "string" )  and ( renderTable == "edit" ) ) then 
							panel.table = renderTable;
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.header);
							panel.header:SetText(FEEDBACKUI_SUGGESTINPUTHEADER)
							panel.subtext:SetText("")
                            if ( panel.input:GetText() == "" ) then
                                panel.input:SetText(FEEDBACKUISUGGESTFRMINPUTBOX_TEXT)
                                panel.input.default = FEEDBACKUISUGGESTFRMINPUTBOX_TEXT
                            else
                                panel.input.default = FEEDBACKUISUGGESTFRMINPUTBOX_TEXT
                            end
							panel.scroll:Hide();
							panel:GetParent().back:Show();
							panel:GetParent().reset:Show();
							panel:GetParent().submit:Show();
							panel.edit:Show();
							return;
						else
							panel.table = renderTable 
						end;
											
						if ( renderTable.header == "" and renderTable.subtext ) then
							panel.header:ClearAllPoints()
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.subtext);
							panel.subtext:SetText("");
						else
							if ( renderTable.header ) then
								panel.header:SetPoint("TOPLEFT", panel.header:GetParent(), "TOPLEFT", 8, -6)
								panel.header:SetText(renderTable.header);
							end
							
							if ( renderTable.subtext ) then
								panel.subtext:SetText(renderTable.subtext);
							end
						end                     
                        
						local i = 0;
                        local maxSummary;
						for ordinal, element in ipairs(renderTable) do
							--Clear downlevel status lines, populate uplevel status lines.
							maxSummary = math.huge;
							if ( element.summary ) then
								for index, panelElement in next, panel:GetParent().panels do
									if ( panelElement.name == "StatusPanel" ) then
										for num, line in next, panelElement.infoLines do
											if ( line.type == element.summary.type ) then
												maxSummary = num;
											end
											if ( num >= maxSummary ) then 
												line.value:SetText("") 
												panelElement.status[line.type] = nil;
                                                panelElement.statusValue[line.type] = nil;
											elseif ( ( num < maxSummary ) and ( line.value:GetText() == "" or line.value:GetText() == nil ) ) then
                                                panelElement.status[line.type] = panelElement.status[line.type] or "N/A";
                                                panelElement.statusValue[line.type] = panelElement.statusValue[line.type] or 0;
                                                line.value:SetText(panelElement.status[line.type]);
											end
										end
									end
								end
							end

							i = i + 1;
							panel.scrollResults[ordinal] = element;
							if ( element.prompt ) then
								panel.prompt:Show();
								panel:GetParent().start:Show();
								panel.prompt:SetText(element.prompt);
								panel.startlink = getglobal(element.link);
							else											
								panel.scroll:Show();
								panel:GetParent().start:Hide();
								panel:GetParent().back:Show();
								panel:GetParent().reset:Show();
								panel:GetParent().submit:Show();
								if ( panel.scroll.buttons[i] ) then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - ( element.offset * FEEDBACKUI_OFFSETPIXELS ) - 15)
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - 15)
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.scroll.index = 1;
						panel.UpdateScrollButtons(panel);
					end
			
				panel.SetScrollVars = 	
					function(panel)
						-- Calculate values necessary to scroll
						panel.scroll.maxy = (panel.scroll.controls:GetTop() - 5);
						panel.scroll.miny = (panel.scroll.controls:GetBottom() + 13);
						panel.scroll.steprange = panel.scroll.maxy - panel.scroll.miny;
						panel.scroll.numsteps = #panel.scrollResults - #panel.scroll.buttons;
						panel.scroll.stepsize = panel.scroll.steprange / panel.scroll.numsteps;				
					end
			
				panel.ScrollOnUpdate =
					function(panel, elapsed)
						if ( not panel.timer ) then panel.timer = 0 end
						panel.timer = panel.timer + elapsed;
						if ( panel.timer > 0.1 ) then
							panel.SetScrollVars(panel);
							
							
							-- Compensate for UI scaling
							-- yarealy
							local x, y = GetCursorPosition();
							x = x / panel:GetEffectiveScale();
							y = y / panel:GetEffectiveScale();
							
							-- See where the user is trying to move the thumb to.
							local moveVariable = -(panel.scroll.maxy - y)
													
							if ( -(panel.scroll.maxy - y) > 0 ) then
								-- If the user has tried to move the thumb to the top of the track or above it, go to the first result.
								panel.scroll.thumb:ClearAllPoints();
								panel.scroll.thumb:SetPoint("TOP", 0, 0);
								panel.scroll.index = 1;
							elseif ( math.abs(panel.scroll.maxy - y) > (panel.scroll.maxy - panel.scroll.miny) ) then
								-- If the user has tried to move the thumb to the bottom of the track or below it, go to the last result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - panel.scroll.miny))
								panel.scroll.index = ( #panel.scrollResults - #panel.scroll.buttons + 1 )
							else
								-- Otherwise, move the scroll thumb to the appropriate position and go to the appropriate result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - y));
								
								local tempStep = math.round( (math.abs(panel.scroll.maxy - y) / panel.scroll.stepsize ) ) + 1;
								if ( ( math.round( (math.abs(panel.scroll.maxy - y) / panel.scroll.stepsize ) ) + 1 ) ~= panel.scroll.index ) then
									-- Determine the target index, and if it's not the current index, then change the index.
									panel.scroll.index = math.round( (math.abs(panel.scroll.maxy - y) / panel.scroll.stepsize ) ) + 1;
								end
							end
							panel.ScrollButtons(panel)			
                            panel.timer = 0;                            
						end
					end
                    
                panel.StartIncrementalScroll =
                    function(panel, direction)
                        panel.scrollDir = direction;
                        panel.MoveScroll(panel, panel.scrollDir);
                        panel:SetScript("OnUpdate", function(self, elapsed) panel.IncrementalUpdate(panel, elapsed) end);                
                    end
                    
                panel.StopIncrementalScroll =
                    function(panel)
                        panel:SetScript("OnUpdate", nil)
                        panel.scrollDir = nil;
                        panel.timeSinceLastIncrement = nil;
                    end
                
                panel.IncrementalUpdate =
                    function(panel, elapsed)
                        panel.timeSinceLastIncrement = ( panel.timeSinceLastIncrement or 0 ) + elapsed
                        if ( panel.timeSinceLastIncrement > .21 and panel.scrollDir ) then
                            panel.MoveScroll(panel, panel.scrollDir);
                            panel.timeSinceLastIncrement = 0.15;
                        end
                    end

				panel.StartScroll =
					function(panel)
						if ( panel.scroll.thumb:IsEnabled() == 1 ) then
							panel.scroll.update:Show();
						end
					end
					
				panel.StopScroll =
					function(panel)
						panel.scroll.update:Hide()
					end					
			
				panel.UpdateScrollButtons =
					function(panel)
					
						-- Update the position of the scroll thumb
						panel.SetScrollVars(panel);
						if not ( panel.scroll.update:IsVisible() == 1 ) then
							panel.scroll.thumb:ClearAllPoints();
							local moveto = -(panel.scroll.stepsize * ( panel.scroll.index -1))
							if ( -(panel.scroll.stepsize * ( panel.scroll.index -1)) > 0 ) then 
                                panel.scroll.thumb:SetPoint("TOP", 0, (panel.scroll.stepsize * ( panel.scroll.index -1)));
                            else
                                panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.stepsize * ( panel.scroll.index -1)));
                            end
						end
						
						-- Enable the up button if appropriate
						if ( panel.scroll.index > 1 ) then
							panel.scroll.upbtn:Enable()
						else
							panel.scroll.upbtn:Disable()
						end
						
						-- Enable the down button if appropriate
						if ( ( panel.scroll.index + #panel.scroll.buttons ) <= #panel.scrollResults ) then
							panel.scroll.downbtn:Enable()
						else
							panel.scroll.downbtn:Disable();
						end
						
						-- Enable the scroll thumb if either the up or down button is enabled.
						if ( ( panel.scroll.upbtn:IsEnabled() == 1 ) or ( panel.scroll.downbtn:IsEnabled() == 1 ) ) then
							panel.scroll.thumb:Enable();
						else
							panel.scroll.thumb:Disable();
						end
					end
			
				panel.MoveScroll = 	
					function(panel, int)
						if ( ( panel.scroll.index + int >= 1 ) and ( ( panel.scroll.index + int ) + #panel.scroll.buttons <= ( #panel.scrollResults + 1 ) ) ) then
							panel.scroll.index = panel.scroll.index + int
						end
						panel.ScrollButtons(panel)						
					end
			
				panel.ScrollButtons = 
					function(panel)
						local i = 0;
						
						for ordinal, element in ipairs(panel.table) do
							if ( ordinal >= panel.scroll.index ) then
								i = i + 1;
								if panel.scroll.buttons[i] then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - ( element.offset * FEEDBACKUI_OFFSETPIXELS ) - 15)
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
                                        panel.scroll.buttons[i].text:SetWidth(panel.buttonWidth - 15)
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.UpdateScrollButtons(panel);
					end
			
				panel.CreateButtons = 
					function(panel)
						if ( panel.scroll and panel.scroll.buttons ) then
							local buttoncapacity = ( math.floor(((panel.scroll:GetHeight()) / panel.scroll.buttons[1]:GetHeight())) )
							local numbuttons = #panel.scroll.buttons;
							if numbuttons < buttoncapacity and buttoncapacity > panel.maxbuttons then
								for i = 1, buttoncapacity - numbuttons do
									local newButton = CreateFrame("Button", string.gsub(panel.scroll.buttons[1]:GetName(), "%d+", "") .. (numbuttons + i), panel.scroll, "ScrollElementTemplate")
									newButton:SetPoint("TOPLEFT", panel.scroll.buttons[numbuttons + i - 1], "BOTTOMLEFT", 0, 0)
									newButton:SetWidth(panel.buttonWidth);
									newButton:SetHeight(panel.buttonHeight);
									table.insert(panel.scroll.buttons, newButton)
									newButton.index = #panel.scroll.buttons;
								end
								panel.maxbuttons = buttoncapacity;
							end
						else
							
						end
					end	
					
			end
	}			

--[[	
function START_SURVEY_FUNCTIONS ()
end
]]--	
--Create panels for the Survey form--
--[[	
function Survey_Surveys_Panel ()
end
]]--	

FeedbackUI_SetupPanel{
	name = "SurveysPanel",
	parent = "FeedbackUISurveyFrame",
	inherits = "FeedbackSurveyPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPLEFT", ["x"] = -2, ["y"] = -14 },
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "TOPRIGHT", ["x"] = 2, ["y"] = -14 } },
	size = { ["y"] = 185 },
	event = { "ZONE_CHANGED_NEW_AREA", "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "QUEST_COMPLETE", "QUEST_FINISHED" },
	OnShow = 
		function(panel)		
            if ( not panel.skipRenderOnShow ) then
    			panel.PopulateTable(panel)
                panel.sortdir = "dated"; 
                panel.SortResults(panel, "date");
            else
                panel.skipRenderOnShow = false;
            end
		end,                
    Load =
        function(panel)
            if ( not g_FeedbackUI_feedbackVars ) then
                g_FeedbackUI_feedbackVars = {}
                g_FeedbackUI_feedbackVars["alerts"] = true;
            elseif ( g_FeedbackUI_feedbackVars and g_FeedbackUI_feedbackVars["alerts"] == nil ) then
                g_FeedbackUI_feedbackVars["alerts"] = true;
            end
            
            g_FeedbackUI_feedbackVars["lastZone"] = nil;
                    
            if ( not g_FeedbackUI_surveysTable ) then
                g_FeedbackUI_surveysTable = {}
            end
            
            if ( not g_FeedbackUI_surveysTable["Quests"] ) then
                g_FeedbackUI_surveysTable["Quests"] = {};
            end
            
            if ( not g_FeedbackUI_surveysTable["Quests"]["Index"] ) then
                g_FeedbackUI_surveysTable["Quests"]["Index"] = {};
                for i, entry in ipairs(g_FeedbackUI_surveysTable["Quests"]) do
                    g_FeedbackUI_surveysTable["Quests"]["Index"][entry.id] = i;
                end
            end
            
            if ( not g_FeedbackUI_surveysTable["Areas"] ) then
                g_FeedbackUI_surveysTable["Areas"] = {};
            end
            
            if ( not g_FeedbackUI_surveysTable["Items"] ) then
                g_FeedbackUI_surveysTable["Items"] = {};
            end
            
            if ( not g_FeedbackUI_surveysTable["Mobs"] ) then
                g_FeedbackUI_surveysTable["Mobs"] = {};
            end
			
			if ( not g_FeedbackUI_surveysTable["Spells"] ) then
				g_FeedbackUI_surveysTable["Spells"] = {};
			end
            
            if ( not g_FeedbackUI_surveysTable["Alerts"] ) then
                g_FeedbackUI_surveysTable["Alerts"] = {};
            end
            
            -- if g_FeedbackUI_feedbackVars["alerts"] then
                -- panel.alertCheck:SetChecked(true)
            -- else
                -- panel.alertCheck:SetChecked(false)
            -- end

            panel.categories = { "Areas", "Items", "Mobs", "Quests", "Spells" };
            panel.category = 1;
            panel.maxbuttons = 1;
            panel.status = 2;
            panel.surveys = {};
            panel.tasks = {};
            panel.currentQuests = {};
            panel.timeSinceLast = 0;
            panel.UPDATEINTERVAL = .5;
            
            panel.Localize(panel);            
            panel.CreateButtons(panel);
            panel.CreateAlertButtons(panel);
            FeedbackUI_SetupTargets();
           
            panel.SortResults(panel, "date");
            panel.PopulateTable(panel);
            panel.UpdateAlertButtons(panel);
            panel.LoadCategory(panel.ddlCategory);
			
            -- UIDropDownMenu_Initialize(panel.ddlCategory, panel.DdlCategory_Initialize);
            panel.LoadStatus(panel.ddlStatus);
            -- UIDropDownMenu_Initialize(panel.ddlStatus, panel.DdlStatus_Initialize);
            
            for _, entry in pairs(FEEDBACKUI_SURVEYCATEGORIES) do
                panel.Expand(panel, entry.text);
            end
            
            tinsert(panel.tasks, {
                                func = 
                                    function (panel)
                                        panel:UnregisterEvent("QUEST_LOG_UPDATE")
                                        panel.UpdateQuestSurveys(panel);
                                        panel:RegisterEvent("QUEST_LOG_UPDATE")
                                        panel.PopulateTable(panel)
                                    end,
                                args = { panel },
                                exTime = GetTime() + 3,
                                taskType = "QUEST_LOG_UPDATE" } );  
            
        end,
	Handler = 
        function()
            local panel = FeedbackUISurveyFrameSurveysPanel;
            if ( event == "ZONE_CHANGED_NEW_AREA" ) or ( event == "PLAYER_ENTERING_WORLD" ) then                    
				panel.tasks = panel.tasks or {};                
                for _, task in next, panel.tasks do
                    if ( task.taskType == "ZONE_CHANGE" ) then
                        return;
                    end
                end
                
                tinsert(panel.tasks, { 
                    func =
                        function (panel)
                            local currentZone = GetRealZoneText() or ""
                            local zoneFound = false;
                            local zoneList = { GetMapZones(GetCurrentMapContinent()) }
                            
                            if ( g_FeedbackUI_feedbackVars["lastZone"] ) then    
                                local name = g_FeedbackUI_feedbackVars["lastZone"] .. ", " .. (g_FeedbackUI_feedbackVars["outerZone"] or GetZoneText());
                                local tempSurvey, addAlert = { ["type"] = "Areas", ["id"] = g_FeedbackUI_feedbackVars["lastZone"] .. ( g_FeedbackUI_feedbackVars["lastZoneDiff"] or 1 ) , ["name"] = name, ["level"] = FEEDBACKUI_AREADIFFICULTIES[(g_FeedbackUI_feedbackVars["lastZoneDiff"] or 1)] }, false;
                                tempSurvey, addAlert = panel.AddSurvey(panel, tempSurvey);
                                if ( addAlert ) then
                                    panel.AddAlert(panel, tempSurvey);
                                    
                                end
                                panel.PopulateTable(panel);
                                g_FeedbackUI_feedbackVars["lastZone"] = nil;
                                g_FeedbackUI_feedbackVars["outerZone"] = "";
                                return
                            end
                            
                            if currentZone == "" then return end
                            
                            if FEEDBACKUI_NONINSTANCEZONES[currentZone] then
                                zoneFound = true;
                            end
                            
                            SetMapToCurrentZone();
                            -- local coords = { GetPlayerMapPosition("player") }
                            -- if coords[1] > 0 or coords[2] > 0 then
                                -- zoneFound = true;
								-- msg(zoneFound);
                            -- end

                            if ( not zoneFound ) then   
                                g_FeedbackUI_feedbackVars["lastZone"] = currentZone;
                                g_FeedbackUI_feedbackVars["lastZoneDiff"] = GetInstanceDifficulty();
                                g_FeedbackUI_feedbackVars["outerZone"] = zoneList[GetCurrentMapZone()]
                            end      
                        end,
                    args = { panel },
                    exTime = GetTime() + 1,
                    taskType = "ZONE_CHANGE" } );
            elseif ( event == "QUEST_LOG_UPDATE" ) then
                for _, task in next, panel.tasks do
                    if ( task.taskType == "QUEST_LOG_UPDATE" ) then
                        return;
                    end
                end
                panel:UnregisterEvent("QUEST_LOG_UPDATE")
                tinsert(panel.tasks, {
                            func = 
                                function(panel)

                                    panel.UpdateQuestSurveys(panel);
                                    
                                    panel.PopulateTable(panel)
                                end,
                            args = { panel },
                            exTime = GetTime() + .5,
                            taskType = "QUEST_LOG_UPDATE"} );
                tinsert(panel.tasks, {
                            func =
                                function(panel)
                                    panel:RegisterEvent("QUEST_LOG_UPDATE")
                                end,
                            args = { panel },
                            exTime = GetTime() + 1, } );
            end
        end,
    OnUpdate = 
        function(panel, interval)
            panel.timeSinceLast = ( panel.timeSinceLast or 0 ) + interval;
            if ( panel.UPDATEINTERVAL and panel.timeSinceLast and panel.timeSinceLast > panel.UPDATEINTERVAL ) then
                
                for index, task in next, panel.tasks do
                    if ( task.exTime ) and ( GetTime() > task.exTime ) then
                        pcall(task.func, unpack(task.args))
                        tremove(panel.tasks, index);

                    -- else
                        -- pcall(task.func, unpack(task.args))
                        -- tremove(panel.tasks, index);
                    end
                end
                panel.timeSinceLast = 0;
            end
        end,
	Setup = 
        function(panel)                 

            panel.Localize = 
                    function(panel)
                        if GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "deDE" then
                            panel.buttonWidth = 390
                            panel.buttonHeight = 15
                    
                            panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
                            panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        else
                            panel.buttonWidth = 325
                            panel.buttonHeight = 15
                            
            				panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
            				panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        end
                    end
                
            panel.AddAlert =
                function (panel, prepSurvey)
                    if ( g_FeedbackUI_feedbackVars["alerts"] ) then
                        if not g_FeedbackUI_surveysTable["Alerts"] then return end;
                        table.insert(g_FeedbackUI_surveysTable["Alerts"], 1, prepSurvey)
                        if g_FeedbackUI_surveysTable["Alerts"][11] then
                            g_FeedbackUI_surveysTable["Alerts"][11] = nil;
                        end
                    end
                    panel.UpdateAlertButtons(panel)
                end
            
            panel.CreateAlertButtons =
                function (panel)
                    if ( panel.alert and panel.alert.buttons ) then
                        local numButtons = #panel.alert.buttons;
                        if numButtons < C_FEEDBACKUI_MAXALERTS then
                            local newButton
                            for i = 1, C_FEEDBACKUI_MAXALERTS - numButtons do
                                newButton = CreateFrame("Button", string.gsub(panel.alert.buttons[1]:GetName(), "%d+", "") .. (numButtons + i), panel.alert, "SurveyAlertButtonTemplate")
                                newButton:SetPoint("TOPLEFT", panel.alert.buttons[numButtons + i - 1], "TOPRIGHT", 2, 0)
                                newButton:SetWidth(panel.alert.buttons[1]:GetWidth());
                                newButton:SetHeight(panel.alert.buttons[1]:GetHeight());
                                table.insert(panel.alert.buttons, newButton)
                                newButton.index = #panel.alert.buttons;
                                newButton.panel = panel;
                                newButton.alert = panel.alert;
                            end
                        end
                    elseif ( not panel.alert ) then
                        panel.alert = CreateFrame(  "Frame", 
                                                    panel:GetName() .. "AlertFrame", 
                                                    UIParent, 
                                                    "SurveyAlertFrameTemplate"
                                                )
                        panel.alert:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 130);
                        panel.alert:SetWidth("100")
                        panel.alert:SetHeight("100")
                        panel.alert.panel = panel;
                        panel.CreateAlertButtons(panel);
                    end
                end
                
            panel.ScrollToSurvey = 
                function (panel, targetElement)
                    if ( not panel ) or ( not targetElement ) then return end
                    local targetButton, foundIndex = false, false;
                    local numButtons = #panel.scroll.buttons;
                    local startTime;
                    panel.sortdir = "dated"; 
                    panel.SortResults(panel, "date");

                    for index, element in ipairs(panel.table) do
                        if ( element.id == targetElement.id ) then
                            for num, button in ipairs(panel.scroll.buttons) do
                                if ( button.element ) and 
                                     ( button.element.id == element.id ) then
                                    targetButton = button;
                                end
                            end
                                
                            if ( not targetButton ) then
                                
                                foundIndex = false
                                startTime = GetTime();
                                while foundIndex == false do
                                    panel.MoveScroll(panel, 1)
                                    if ( panel.scroll.buttons[numButtons].element.id and panel.scroll.buttons[numButtons].element.id == element.id ) then
                                        targetButton = panel.scroll.buttons[numButtons];
                                        foundIndex = true;
                                    end
                                    if startTime + 5 < GetTime() then
                                        break;
                                    end
                                end
                            end
                        end
                    end
                    
                    panel.skipRenderOnShow = false;
                    
                    if type(targetButton) == "table" then
                        FeedbackUITab3:Click();
                        if not FeedbackUI:IsVisible() then FeedbackUI_Show(); end
                        panel.SelectSurvey(panel,targetButton.element, targetButton);
                    end
                end
                
            panel.UpdateAlertButtons =
                function (panel)
                    local pulseCounter = 0;
                    for index, button in ipairs(panel.alert.buttons) do
                        button.lines = {};
                        if g_FeedbackUI_surveysTable["Alerts"][index] and g_FeedbackUI_feedbackVars["alerts"] then
                            local element = g_FeedbackUI_surveysTable["Alerts"][index]
                            if ( element.type ) and ( element.type == "Areas" ) then
                                table.insert(button.lines, { ["left"] = FEEDBACKUI_WHITE .. FEEDBACKUIFEEDBACKFRMTITLE_TEXT .. " " } )
                                table.insert(button.lines, { ["left"] = element.name } )
                            elseif ( element.type ) and ( element.type == "Quests" ) then
                                table.insert(button.lines, { ["left"] = FEEDBACKUI_WHITE .. FEEDBACKUIFEEDBACKFRMTITLE_TEXT .. " " } )
                                table.insert(button.lines, { ["left"] = element.name } )
                            end
                            if ( not button:IsVisible() ) then 
                                button:Show()              
                                pulseCounter = pulseCounter + 1;
                            end
                        else
                            button:Hide()
                        end
                    end
                    for i = 1, pulseCounter do
                        SetButtonPulse(panel.alert.buttons[i], 5, 0.5);
                    end
                end
                
            panel.AddSurvey =
                function (panel, surveyElement)
                    local prepSurvey = {}

                    if ( surveyElement.type == "Quests" ) then
                        FeedbackUI_ReindexQuests()
                        local index = g_FeedbackUI_surveysTable["Quests"]["Index"][surveyElement.id];
                        
                        if ( g_FeedbackUI_surveysTable["Quests"][index] and g_FeedbackUI_surveysTable["Quests"][index].id == surveyElement.id ) then
                            return g_FeedbackUI_surveysTable["Quests"][index], index, true;
                            -- return "Survey item exists."
                        end
                        prepSurvey = {
                                        ["name"] = surveyElement.name, 
                                        ["id"] = surveyElement.id, 
                                        ["objectives"] = surveyElement.objectives, 
                                        ["added"] = time(), 
                                        ["status"] = surveyElement.status, 
                                        ["modified"] = time(),
                                        ["type"] = surveyElement.type
                                    }
                        table.insert(g_FeedbackUI_surveysTable["Quests"], prepSurvey)
                        g_FeedbackUI_surveysTable["Quests"]["Index"][prepSurvey.id] = #g_FeedbackUI_surveysTable["Quests"];
                        return g_FeedbackUI_surveysTable["Quests"][#g_FeedbackUI_surveysTable["Quests"]], #g_FeedbackUI_surveysTable["Quests"], false;
                    else
                        for _, element in pairs(g_FeedbackUI_surveysTable[surveyElement.type]) do
							--msg(surveyElement.id);
							if ( element.id == surveyElement.id ) then
                                return element, false;
                            end
                        end
                        
                        prepSurvey = {
                            ["name"] = surveyElement.name, 
                            ["id"] = surveyElement.id, 
                            ["added"] = time(), 
                            ["status"] = "Available",
                            ["modified"] = time(),
                            ["type"] = surveyElement.type,
                            ["zone"] = surveyElement.zone,
                            ["level"] = surveyElement.level
                        }
                        
                        
                        table.insert(g_FeedbackUI_surveysTable[surveyElement.type], prepSurvey);
                        if ( g_FeedbackUI_surveysTable["Targets"][surveyElement.id] ) then
							--msg(surveyElement.id);
                            return prepSurvey, true;
                        else
                            return prepSurvey, false;
                        end
                    end
                end	
                            
            OldAbandonQuest = AbandonQuest
            function AbandonQuest ()
                local panel = FeedbackUISurveyFrameSurveysPanel;
				
                --local _, objectives = GetQuestLogQuestText();
                --objectives = string.gsub(objectives, "%c", "");
                --local objectivesHash = FeedbackUI_HexHash(objectives)
                local questLink = GetQuestLink(GetQuestLogSelection())
				local questID, level, name = string.match(questLink, "quest:(%d+):([-%d]+)|h%[(.-)%]");
	
                for index, quest in pairs(g_FeedbackUI_surveysTable["Quests"]) do
                    if ( quest.id == questID ) then
                        table.remove(g_FeedbackUI_surveysTable["Quests"], index)
                    end
                end
                
                for index, quest in pairs(g_FeedbackUI_surveysTable["Quests"]["Index"]) do
                    if ( index == questID ) then
                        g_FeedbackUI_surveysTable["Quests"]["Index"][index] = nil;
                    end
                end
                OldAbandonQuest();
				if FeedbackUI:IsVisible() then
					FeedbackUI:Hide()
				end
            end
            
            -----------------------------------------------------------------------------------
            -- Update g_FeedbackUI_surveysTable["Quests"] by doing the following:
            --      Add any new quests obtained to the table.
            --      Show surveys for any quests that have been removed from the questlog
            -----------------------------------------------------------------------------------  
            
            panel.UpdateQuestSurveys =
                function (panel)
                    local currentQuests = {};
                    local headerStates = {}

                    --local name, collapsed, header, questFound, objectives, objectivesHash;
                    local name, collapsed, header, questFound, level, questID, questLink, objectives, playerLevel, diff
					
                    for i = 1, MAX_QUESTS do
                        name, _, _, _, _, collapsed = GetQuestLogTitle(i)
                        if ( collapsed == 1 ) then
                            headerStates[name] = 1;
                        end
                    end
                   
                    ExpandQuestHeader(0);
                    local currentSelected = GetQuestLogSelection();
                    
                    for i = 1, GetNumQuestLogEntries() do
                        name, _, _, _, header = GetQuestLogTitle(i)
                        if ( not header ) then                            
                            SelectQuestLogEntry(i)
							questLink = GetQuestLink(i)
							questID, level, name = string.match(questLink, "quest:(%d+):([-%d]+)|h%[(.-)%]");
                            _, objectives = GetQuestLogQuestText()
                            objectives = string.gsub(objectives, "%c", "")
                            --objectivesHash = FeedbackUI_HexHash(objectives)

							playerLevel = UnitLevel("player")
							diff = math.abs(playerLevel - level)
							local strID = tostring(questID);
							g_FeedbackUI_surveysTable["Targets"][strID] = true;			
							--determine if alert is needed

						if ( level ~= "-1" ) then

							if ( diff > GetQuestGreenRange() ) then
								local strID = tostring(questID);
								g_FeedbackUI_surveysTable["Targets"][strID] = false;
							end
						end	
							table.insert(currentQuests, questID)
                            
                            questFound = false;
                            for _, quest in pairs(g_FeedbackUI_surveysTable["Quests"]) do
                                
                                if ( quest.id == questID ) then
                                    questFound = true;
                                end
                            end
                            
                            if ( not questFound ) then
                                panel.AddSurvey(panel, { ["name"] = name, ["objectives"] = objectives, ["id"] = questID, ["type"] = "Quests", ["status"] = "Hidden" })
                            end
                        end
                    end
                    
                    for index, quest in pairs(g_FeedbackUI_surveysTable["Quests"]) do
                        if ( quest.status == "Hidden" ) then
                            questFound = false
                            for _, id in pairs(currentQuests) do
                                if ( id == quest.id ) then
                                    questFound = true;                                         
                                elseif ( not id ) then
                                    questFound = true;
                                end
                            end
                            
                            if ( not questFound ) then
                                g_FeedbackUI_surveysTable["Quests"][index].added = time();
                                g_FeedbackUI_surveysTable["Quests"][index].status = "Available"
                                
                                if ( ( g_FeedbackUI_surveysTable["Targets"] ) and ( g_FeedbackUI_surveysTable["Targets"][quest.id] ) ) then
                                    panel.AddAlert(panel, g_FeedbackUI_surveysTable["Quests"][index]);
								end
                            end
                        end
                    end
                    
                    SelectQuestLogEntry(currentSelected);
                    
                    for i = 1, GetNumQuestLogEntries() do
                        name = GetQuestLogTitle(i)
                        if ( ( name ~= 0 ) and ( headerStates[name] ) )then
                            CollapseQuestHeader(i)
                        end
                    end
                    
                end
                
            panel.DateSort = 
                function(element1, element2)
                    if ( not element1.added or not element2.added ) then 
                        return true
                    elseif ( g_FeedbackUI_feedbackVars["sortdir"] == "datea" ) then
                        if ( element1.added < element2.added ) then
                            return true;
                        end
                    elseif ( element1.added > element2.added ) then
                        return true;
                    end
                    
                    return false;
                end
                
            panel.NameSort =
                function(element1, element2)
                    if ( not element1.name or not element2.name ) then
                        return true;
                    elseif ( g_FeedbackUI_feedbackVars["sortdir"] == "namea" ) then
                        if ( string.lower(element1.name) > string.lower(element2.name) ) then 
                            return true;
                        end
                    elseif ( string.lower(element1.name) < string.lower(element2.name) ) then 
                        return true;
                    end
                    
                    return false;
                end
            
            panel.Sort = 
                function(panel, sortTable, sortType)
                    if ( sortType == "name" ) then
                        table.sort(sortTable, panel.NameSort)
                    else
                        table.sort(sortTable, panel.DateSort)
                    end
                end
                                        
            panel.SortResults =
                function(panel, sortType)
                    if ( sortType == "date" ) then
                        if not ( panel.sortdir == "datea" ) then panel.sortdir = "dated" end		
                        g_FeedbackUI_feedbackVars["sortdir"] = panel.sortdir;
                        table.sort(g_FeedbackUI_surveysTable["Areas"], panel.DateSort);
                        table.sort(g_FeedbackUI_surveysTable["Items"], panel.DateSort);
                        table.sort(g_FeedbackUI_surveysTable["Mobs"], panel.DateSort);
                        table.sort(g_FeedbackUI_surveysTable["Quests"], panel.DateSort);
						table.sort(g_FeedbackUI_surveysTable["Spells"], panel.DateSort);
                        if ( panel.sortdir == "dated" ) then panel.sortdir = "datea" else panel.sortdir = "dated" end
                    elseif ( sortType == "name" ) then
                        if not ( panel.sortdir == "namea" ) then panel.sortdir = "named" end
                        g_FeedbackUI_feedbackVars["sortdir"] = panel.sortdir;
                        table.sort(g_FeedbackUI_surveysTable["Areas"], panel.NameSort);
                        table.sort(g_FeedbackUI_surveysTable["Items"], panel.NameSort);
                        table.sort(g_FeedbackUI_surveysTable["Mobs"], panel.NameSort);
                        table.sort(g_FeedbackUI_surveysTable["Quests"], panel.NameSort);
						table.sort(g_FeedbackUI_surveysTable["Spells"], panel.NameSort);
                        if ( panel.sortdir == "named" ) then panel.sortdir = "namea" else panel.sortdir = "named" end
                    end
                    
                    panel.PopulateTable(panel)
                end    
                            
            panel.LocalizedDate = 
                function (timeAdded)
                    dT = date("*t", timeAdded);
                    local timeStr = "";
                    dT["min"] = string.format("%02d", dT["min"]);
                    dT["sec"] = string.format("%02d", dT["sec"]);
                    if ( GetLocale() == "enUS" ) then
                        return dT["month"] .. "/" .. dT["day"] .. "/" .. dT["year"] .. " " .. dT["hour"] .. ":" .. dT["min"] .. ":" .. dT["sec"];
                    elseif ( GetLocale() == "deDE" ) then
                        return dT["day"] .. "." .. dT["month"] .. "." .. dT["year"] .. " " .. dT["hour"] .. ":" .. dT["min"] .. ":" .. dT["sec"];
                    elseif ( GetLocale() == "koKR" ) then
                        if ( dT["hour"] == 12 ) then
                            timeStr = "오후"
                        elseif ( dT["hour"] > 12 ) then
                            timeStr = "오후"
                            dT["hour"] = mod(dT["hour"], 12);
                        else
                            timeStr = "오전"
                        end
                        return dT["year"] .. "-" .. dT["month"] .. "-" .. dT["day"] .. " " .. timeStr .. " " .. dT["hour"] .. ":" .. dT["min"] .. ":" .. dT["sec"];
                    elseif ( GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "enGB" ) then
                        return dT["day"] .. "/" .. dT["month"] .. "/" .. dT["year"] .. " " .. dT["hour"] .. ":" .. dT["min"] .. ":" .. dT["sec"];                    
                    end
                end
                            
            panel.ShowTooltip =
                function (panel, button)
                    local lines = {}
                    local normalColor = {};
                    normalColor.r, normalColor.g, normalColor.b, normalColor.a  = GameFontNormal:GetTextColor();
                    
                    -- Tremendous hack, but I'm tired.
                    panel.tooltip:SetOwner(panel, "ANCHOR_RIGHT")
                    panel.tooltip:SetText("Test")
                    panel.tooltip:ClearLines()
                    panel.tooltip:Hide()
                    -- End tremendous hack
                    panel.tooltip:SetOwner(panel, "ANCHOR_RIGHT")
                    
                    local dateStr = panel.LocalizedDate (button.element.added)
                    
                    if ( button.element.type == "Areas" ) then
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPAREAHEADER, ["right"] = button.element.name });
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPEXPERIENCEDHEADER, ["right"] = dateStr });
                        if ( button.element.level ) then
                            table.insert(lines, { ["left"] = DUNGEON_DIFFICULTY .. ": ", ["right"] = button.element.level });
                        end
                         
                        for index, line in ipairs(lines) do
                            panel.tooltip:AddDoubleLine(line["left"], line["right"])
                            getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetFontObject("GameFontNormal")
                            getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetTextColor(1, 1, 1, 1)
                            getglobal(panel.tooltip:GetName() .. "TextRight" .. index):SetFontObject("GameFontNormal")
                        end
                    elseif ( button.element.type == "Quests" ) then
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPQUESTHEADER, ["right"] = button.element.name });
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPEXPERIENCEDHEADER, ["right"] = dateStr });
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPQUESTOBJECTIVESHEADER, ["right"] = "" });
                        table.insert(lines, { ["left"] = button.element.objectives, ["right"] = "" })
                        for index, line in ipairs(lines) do
                            if ( index ~= #lines ) then
                                panel.tooltip:AddDoubleLine(line["left"], line["right"])
                                getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetFontObject("GameFontNormal")
                                getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetTextColor(1, 1, 1, 1)
                                getglobal(panel.tooltip:GetName() .. "TextRight" .. index):SetFontObject("GameFontNormal")
                            else
                            
                                panel.tooltip:AddLine(line["left"], normalColor.r, normalColor.g, normalColor.b, 1)
                                getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetFontObject("GameFontNormal")
                            end
                        end
                    elseif ( button.element.type == "Items" ) then
                        
                    elseif ( button.element.type == "Mobs" ) then
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPMOBHEADER, ["right"] = button.element.name });
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPEXPERIENCEDHEADER, ["right"] = dateStr });
                        table.insert(lines, { ["left"] = FEEDBACKUI_SURVEYTOOLTIPMOBZONEHEADER, ["right"] = button.element.zone });
                        for index, line in ipairs(lines) do
                            panel.tooltip:AddDoubleLine(line["left"], line["right"])
                            getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetFontObject("GameFontNormal")
                            getglobal(panel.tooltip:GetName() .. "TextLeft" .. index):SetTextColor(1, 1, 1, 1)
                            getglobal(panel.tooltip:GetName() .. "TextRight" .. index):SetFontObject("GameFontNormal")
                        end                            
                    end
                    panel.tooltip:Show()
                    panel.tooltip:ClearAllPoints()
                    panel.tooltip:SetPoint("TOPLEFT", panel, "TOPRIGHT", 10, -26)
                end

            panel.HideTooltip =
                function (panel)
                    panel.tooltip:ClearLines()
                    panel.tooltip:Hide()
                end
                            
            panel.FormatTime = 
                function(timeVar)
                    local timeString = ""
                    local timeNow = {}
                    local timeThen = {}
                
                    if ( timeVar == "" ) then
                        timeString = "New";
                        return timeString;
                    else
                        timeThen = date("*t", timeVar)
                        timeNow = date("*t")
                    end
                    
                    if FEEDBACKUI_TIMEPREFIX then
                        timeString = FEEDBACKUI_TIMEPREFIX
                    end
                    
                    if ( not timeThen or not timeNow ) then
                        return "Err"
                    end
                            
                    local monthDiff = timeNow.month - timeThen.month + (12 * (timeNow.year - timeThen.year));
                    if ( monthDiff >= 24 ) then
                        timeString = timeString .. tostring(math.floor(monthDiff/12)) .. FEEDBACKUI_YEARSAGO
                    elseif ( monthDiff > 12 ) then
                        timeString = timeString .. "1" .. FEEDBACKUI_YEARAGO
                    elseif ( monthDiff > 1 ) then
                        timeString = timeString .. monthDiff .. FEEDBACKUI_MONTHSAGO
                    else
                        local dayDiff = timeNow.day - timeThen.day + (31 * monthDiff)
                        if ( dayDiff > 31 ) then
                            timeString = timeString .. "1" .. FEEDBACKUI_MONTHAGO
                        elseif ( dayDiff > 1 and dayDiff < 31 ) then
                            timeString = timeString .. dayDiff .. FEEDBACKUI_DAYSAGO
                        else
                            local hoursDiff = timeNow.hour - timeThen.hour + (24 * dayDiff)
                            if ( hoursDiff > 24 ) then
                                timeString = timeString .. "1" .. FEEDBACKUI_DAYAGO
                            elseif ( hoursDiff > 1 and hoursDiff < 24 ) then
                                timeString = timeString .. hoursDiff .. FEEDBACKUI_HOURSAGO
                            else
                                local minsDiff = timeNow.min - timeThen.min + (60 * hoursDiff)
                                if ( minsDiff > 60 ) then
                                    timeString = timeString .. "1" .. FEEDBACKUI_HOURAGO
                                else
                                    timeString = FEEDBACKUI_NEW
                                end
                            end
                        end
                    end
                
                    return timeString;
                end
            
            panel.Collapse =
                function(panel, category)
                    local catValue;
                    for _, cat in next, FEEDBACKUI_SURVEYCATEGORIES do
                        if ( cat.text == category ) then 
                            catValue = cat.value
                        end
                    end
                    
                    catValue = ( catValue or category )
                    
                    for num, value in next, panel.categories do
                        if catValue == value then
                            table.remove(panel.categories, num);
                        end
                    end
                    for _, element in pairs(panel.table) do
                        if ( element.header and element.name == category ) then
                            element.expanded = false
                        end
                    end
                    panel.ScrollButtons(panel)
                end
                
            panel.Expand = 
                function(panel, category)
                    local categoryTable = {};
                    local catValue;
                    for _, cat in next, FEEDBACKUI_SURVEYCATEGORIES do
                        if ( cat.text == category ) then 
                            catValue = cat.value
                        end
                    end
                    
                    catValue = ( catValue or category )
                    
                    for _, category in pairs(panel.categories) do
                        categoryTable[category] = true;
                    end
                    
                    if ( not categoryTable[catValue] ) then
                        table.insert(panel.categories, catValue)
                    end
                    
                    for _, element in pairs(panel.table) do
                        if ( element.header and element.name == category ) then
                            element.expanded = true
                        end
                    end
                    panel.ScrollButtons(panel)								
                end
                
            panel.InsertQuests =
                function(panel)
                    local status;
					if ( panel.ddlStatus and panel.ddlStatus:GetSelectedValue() ) then
						status = panel.ddlStatus:GetSelectedValue();
					else
						status = "";
					end
                    table.insert(panel.table, FEEDBACKUI_QUESTHEADER);
                    
                    if ( status == "All" or status == "" ) then
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Quests"]) do
                            if val.status ~= "Hidden" then
                                val.type = "Quests"
                                table.insert(panel.table, val)
                            end
                        end
                    else
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Quests"]) do
                            if ( val.status == status ) then
                                val.type = "Quests"
                                table.insert(panel.table, val)
                            end
                        end
                    end	
                end
            
            panel.InsertItems =
                function (panel)
					local status;
					if ( panel.ddlStatus and panel.ddlStatus:GetSelectedValue() ) then
						status = panel.ddlStatus:GetSelectedValue();
					else
						status = "";
					end
                    table.insert(panel.table, FEEDBACKUI_ITEMHEADER);
                    
                    if ( status == "All" or status == "" ) then
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Items"]) do
                            val.type = "Items"
                            table.insert(panel.table, val);
                        end
                    else
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Items"]) do
                            if ( val.status == status ) then
                                val.type = "Items"
                                table.insert(panel.table, val);
                            end
                        end
                    end
                end
            
            panel.InsertMobs =
                function (panel)
                    local status;
					if ( panel.ddlStatus and panel.ddlStatus:GetSelectedValue() ) then
						status = panel.ddlStatus:GetSelectedValue();
					else
						status = "";
					end
                    table.insert(panel.table, FEEDBACKUI_MOBHEADER);
                    
                    if ( status == "All" or status == "" ) then
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Mobs"]) do
                            val.type = "Mobs"
                            table.insert(panel.table, val);
                        end
                    else
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Mobs"]) do
                            if ( val.status == status ) then
                                val.type = "Mobs"
                                table.insert(panel.table, val);
                            end
                        end
                    end
                end
                
            panel.InsertAreas =
                function (panel)
                    local status;
					if ( panel.ddlStatus and panel.ddlStatus:GetSelectedValue() ) then
						status = panel.ddlStatus:GetSelectedValue();
					else
						status = "";
					end
                    table.insert(panel.table, FEEDBACKUI_AREAHEADER);
                    
                    if ( status == "All" or status == "" ) then
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Areas"]) do
                            val.type = "Areas"
                            table.insert(panel.table, val);
                        end
                    else
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Areas"]) do
                            if ( val.status == status ) then
                                val.type = "Areas"
                                table.insert(panel.table, val);
                            end
                        end
                    end
                end    
				
            panel.InsertSpells =
                function (panel)
                    local status;
					if ( panel.ddlStatus and panel.ddlStatus:GetSelectedValue() ) then
						status = panel.ddlStatus:GetSelectedValue();
					else
						status = "";
					end
                    table.insert(panel.table, FEEDBACKUI_SPELLHEADER);
                    
                    if ( status == "All" or status == "" ) then
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Spells"]) do
                            val.type = "Spells"
                            table.insert(panel.table, val);
                        end
                    else
                        for _, val in ipairs(g_FeedbackUI_surveysTable["Spells"]) do
                            if ( val.status == status ) then
                                val.type = "Spells"
                                table.insert(panel.table, val);
                            end
                        end
                    end
                end 
            
            panel.PopulateTable =
                function(panel)
                    local category;
					if ( panel.ddlCategory and panel.ddlCategory:GetSelectedValue() ) then
						category = panel.ddlCategory:GetSelectedValue();
					else
						category = "";
					end

                    panel.table = {}	
                    
                    if ( category == "All" or category == "" ) then
                        panel.InsertAreas(panel);
                        panel.InsertItems(panel);
                        panel.InsertMobs(panel);
                        panel.InsertQuests(panel);
						panel.InsertSpells(panel);
                    elseif ( category == "Areas" ) then
                        panel.InsertAreas(panel);					
                    elseif ( category == "Items" ) then
                        panel.InsertItems(panel);
                    elseif ( category == "Mobs" ) then
                        panel.InsertMobs(panel);
                    elseif ( category == "Quests" ) then
                        panel.InsertQuests(panel);
					elseif ( category == "Spells" ) then
						panel.InsertSpells(panel);
                    end						
                    panel.Render(panel);
                end
            
            panel.GetStatusColor =
                function(status)
                    for _, value in next, FEEDBACKUI_SURVEYSTATUS do
                        if ( value.value == status ) then
                            return { ["r"] = value.r, ["g"] = value.g, ["b"] = value.b, ["a"] = value.a }
                        end
                    end
                end
            
            panel.HighlightButton =
                function (panel, button)
                    if ( not panel or not button ) then return end;
                    
                    local color = button.highlightColor
                    button.normalColor = button.highlightColor;
                    button.text:SetTextColor(color.r, color.g, color.b, color.a);
                    -- button.rightText:SetTextColor(color.r, color.g, color.b, color.a);
                    color = panel.GetStatusColor(button.element.status)
                    panel.highlight.texture:SetVertexColor(color.r, color.g, color.b)
                    panel.highlight:ClearAllPoints()
                    panel.highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 10, 1)
                    panel.highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, 0)
                    panel.highlight:Show();
                end
            
            panel.ResetButtons =
                function (panel)
                    local normalColor = {};
                    normalColor.r, normalColor.g, normalColor.b, normalColor.a  = GameFontNormal:GetTextColor();
                    
                    for i = 1, #panel.scroll.buttons do
                        local color = {}
                        if panel.scroll.buttons[i].element then
                            color = panel.GetStatusColor((panel.scroll.buttons[i].element.status or ""));
                        end
                        if not color then color = normalColor end;
                        panel.scroll.buttons[i].normalColor = color;
                        panel.scroll.buttons[i].text:SetTextColor(color.r, color.g, color.b, color.a);
                        -- panel.scroll.buttons[i].rightText:SetTextColor(color.r, color.g, color.b, color.a);
                    end
                end
                                            
            panel.SelectSurvey =
                function (panel, element, button)
                    if ( not panel or not element or not button ) then return end;
                    if element.id == panel.selectedId then return end;
                    panel.selectedId = element.id;	
                    element.newComments = nil;
                    
                    
                    local statusHistory = {};
                    
                    if ( element.status == "Completed" ) then
                        for index, val in next, FEEDBACKUI_SURVEYRESPONSETYPES[element.type] do                            
                            if ( element[val] ) then
                                statusHistory[val] = element[val];
                            end
                        end
                    end
                    
                    panel.ResetButtons(panel);
                    panel.HighlightButton(panel, button);
                    -- panel:GetParent().reset:Click();
                    panel:GetParent().skip:Disable();
                    panel:GetParent().submit:Disable();

                    for index, panelElement in next, panel:GetParent().panels do
                        if ( panelElement.name == "StepThroughPanel" ) then
                            -- msg("Found stepthrough panel");
                            panelElement.element = element;
                            panelElement.statusHistory = statusHistory;
                            if ( element.type == "Areas" ) then
                                panelElement.table = FEEDBACKUI_AREASDIFFICULTYTABLE
                                panelElement.startlink = FEEDBACKUI_AREASDIFFICULTYTABLE
                            elseif ( element.type == "Items" ) then
                                panelElement.table = FEEDBACKUI_ITEMSDIFFICULTYTABLE
                                panelElement.startlink = FEEDBACKUI_ITEMSDIFFICULTYTABLE
                            elseif ( element.type == "Mobs" ) then
                                panelElement.table = FEEDBACKUI_MOBSDIFFICULTYTABLE
                                panelElement.startlink = FEEDBACKUI_MOBSDIFFICULTYTABLE
                            elseif ( element.type == "Quests" ) then
                                panelElement.table = FEEDBACKUI_QUESTSCLARITYTABLE
                                panelElement.startlink = FEEDBACKUI_QUESTSCLARITYTABLE  
                            elseif ( element.type == "Spells" ) then
								panelElement.table = FEEDBACKUI_SPELLSPOWERTABLE;
								panelElement.startlink = FEEDBACKUI_SPELLSPOWERTABLE;
							end
                            panel:GetParent().statusPanel.SetupStatus(panel:GetParent().statusPanel, FEEDBACKUI_SURVEYRESPONSETYPES[element.type]);
                            panel:GetParent().stepThroughPanel.SoftReset(panel:GetParent().stepThroughPanel);
                            
                            -- panelElement.Render(panelElement)
                            if ( element.status == "Available" ) then
                                panel:GetParent().skip:Enable();
                                panel:GetParent().submit:SetText(FEEDBACKUISUBMIT_TEXT);
                            elseif ( element.status == "Completed" ) then
                                panel:GetParent().submit:SetText(FEEDBACKUIRESUBMIT_TEXT);
                            else
                                panel:GetParent().submit:SetText(FEEDBACKUISUBMIT_TEXT);
                            end
                        end
                    end
                    
                    for index, alert in next, g_FeedbackUI_surveysTable["Alerts"] do
                        if ( alert.id == element.id ) then
                            table.remove(g_FeedbackUI_surveysTable["Alerts"], index);
                        end
                    end
                    panel.UpdateAlertButtons(panel)
                    
                    for _, entry in next, g_FeedbackUI_surveysTable[element.type] do
                        if ( entry.id == element.id ) then
                            entry.modified = time();
                        end
                    end
                
                end    
            -----------------------------------------------------------------------------------
            -- These are standard scroll methods used by all scroll template children
            -----------------------------------------------------------------------------------
            
            panel.Click = 	
                function (panel, element, button)
                    if ( not panel or not element ) then return end;
                    
                    if ( element.header == true ) then
                        if ( element.expanded == true ) then
                            button.btn:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up.blp");
                            button.btn:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down.blp");
                            button.btn:SetDisabledTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled.blp");
                            panel.Collapse(panel, element.name)
                        else
                            button.btn:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up.blp");
                            button.btn:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down.blp");
                            button.btn:SetDisabledTexture("Interface\\BUTTONS\\UI-MinusButton-Disabled.blp");
                            panel.Expand(panel, element.name)
                        end
                    else
                        panel.SelectSurvey(panel, element, button)
                    end
                end
                
            panel.MoveScroll = 	
                function (panel, int)
                    if ( ( panel.scroll.index + int >= 1 ) and ( ( panel.scroll.index + int ) + #panel.scroll.buttons <= ( #panel.scrollResults + 1 ) ) ) then
                        panel.scroll.index = panel.scroll.index + int
                    end
                    panel.ScrollButtons(panel)						
                end
                            
            panel.Render = 	
                function (panel)	
                    local renderTable = {};
                    local normalColor = {};
                    normalColor.r, normalColor.g, normalColor.b, normalColor.a  = GameFontNormal:GetTextColor();
                    
                    --Disable the scroll controls.
                    panel.scroll:Hide();
                    panel.scroll.thumb:Disable();
                    panel.scrollResults = {};
                    
                    --Hide the button highlight
                    panel.highlight:Hide();
                    
                    -- Reset all the buttons to be blank.
                    for i = 1, #panel.scroll.buttons do
                        -- panel.scroll.buttons[i].rightText:SetWidth("75");
                        -- panel.scroll.buttons[i].rightText:SetText("")
                        -- panel.scroll.buttons[i].text:SetText("");
                        -- panel.scroll.buttons[i].text:SetNonSpaceWrap(false);
                        -- panel.scroll.buttons[i].text:ClearAllPoints();
                        -- panel.scroll.buttons[i].text:SetPoint("RIGHT", panel.scroll.buttons[i].rightText, "LEFT");
                        panel.scroll.buttons[i].normalColor = normalColor;
                        panel.scroll.buttons[i].text:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a);
                        -- panel.scroll.buttons[i].rightText:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a);							
                        panel.scroll.buttons[i]:Hide();
                        panel.scroll.buttons[i].btn:Hide();
                        panel.scroll.buttons[i].element = nil;
                        panel.scroll.buttons[i].tooltip = nil;
                        panel.scroll.buttons[i].selected = false;
                    end
                    
                    --Populate renderTable based on panel.categories, which is set by the DDLs.
                    for ordinal, element in next, panel.table do
                        if ( element.header ) then
                            table.insert(renderTable, element)
                        else
                            for _, category in next, panel.categories do
                                if ( category == element.type ) then
                                    table.insert(renderTable, element)
                                end
                            end
                        end
                    end
                    
                    local color;
                    --Display and customize the buttons based on the contents of renderTable.
                    for ordinal, element in ipairs(renderTable) do
                    
                        --Add all results to scrollResults so we can screw through them later.
                        panel.scrollResults[ordinal] = element;
                        panel.scroll:Show();
                        
                        --Render as many buttons as possible.
                        if ( panel.scroll.buttons[ordinal] ) then
                            --If the element is a header, show the Expander buttons and justify text appropriately.
                            if ( element.header ) then
                                panel.scroll.buttons[ordinal].text:ClearAllPoints();
                                panel.scroll.buttons[ordinal].text:SetPoint("TOPLEFT", ( FEEDBACKUI_OFFSETPIXELS ), 0);                                  
                                panel.scroll.buttons[ordinal].text:SetPoint("BOTTOMRIGHT");
                                if ( element.expanded == true ) or ( element.expanded == nil ) then
                                    element.expanded = true
                                    panel.scroll.buttons[ordinal].btn:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up.blp");
                                    panel.scroll.buttons[ordinal].btn:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down.blp");
                                    panel.scroll.buttons[ordinal].btn:SetDisabledTexture("Interface\\BUTTONS\\UI-MinusButton-Disabled.blp");
                                else
                                    panel.scroll.buttons[ordinal].btn:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up.blp");
                                    panel.scroll.buttons[ordinal].btn:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down.blp");
                                    panel.scroll.buttons[ordinal].btn:SetDisabledTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled.blp");
                                end
                                panel.scroll.buttons[ordinal].btn:Show();
                                panel.scroll.buttons[ordinal].element = element;
                            else
                                panel.scroll.buttons[ordinal].element = element;
                                panel.scroll.buttons[ordinal].text:ClearAllPoints();
                                panel.scroll.buttons[ordinal].text:SetPoint("TOPLEFT", ( FEEDBACKUI_OFFSETPIXELS * 1.5 ), 0);
                                panel.scroll.buttons[ordinal].text:SetPoint("BOTTOMRIGHT");
                                panel.scroll.buttons[ordinal].tooltip = true;
                                color = panel.GetStatusColor(element.status)
                                panel.scroll.buttons[ordinal].normalColor = color;
                                panel.scroll.buttons[ordinal].text:SetTextColor(color.r, color.g, color.b, color.a);
                            end
                            panel.scroll.buttons[ordinal].text:SetText(element.name);
                            panel.scroll.buttons[ordinal]:Show();
                        end
                    end
                    panel.scroll.index = 1;
                    
                    if panel.selectedId then
                        for i = 1, #panel.scroll.buttons do
                            if ( panel.scroll.buttons[i].element and panel.scroll.buttons[i].element.id ) then
                                if ( panel.scroll.buttons[i].element.id == panel.selectedId ) then
                                    panel.HighlightButton(panel, panel.scroll.buttons[i])
                                end
                            end
                        end
                    end    
                    
                    panel.UpdateScrollButtons(panel);
                end
            
            panel.SetScrollVars = 	
                function(panel)
                    -- Calculate values necessary to scroll
                    panel.scroll.maxy = (panel.scroll.controls:GetTop() - 5);
                    panel.scroll.miny = (panel.scroll.controls:GetBottom() + 13);
                    panel.scroll.steprange = panel.scroll.maxy - panel.scroll.miny;
                    panel.scroll.numsteps = #panel.scrollResults - #panel.scroll.buttons;
                    panel.scroll.stepsize = panel.scroll.steprange / panel.scroll.numsteps;				
                end
            
            panel.ScrollOnUpdate =
                function(panel, elapsed)
                    if ( not panel.timer ) then panel.timer = 0 end
                    panel.timer = panel.timer + elapsed;
                    if ( panel.timer > 0.01667 ) then
                        panel.SetScrollVars(panel);
                        
                        
                        -- Compensate for UI scaling
                        -- yarealy
                        local x, y = GetCursorPosition();
                        x = x / panel:GetEffectiveScale();
                        y = y / panel:GetEffectiveScale();
                        
                        -- See where the user is trying to move the thumb to.
--~                         local moveVariable = -(panel.scroll.maxy - y)
                                                
                        if ( -(panel.scroll.maxy - y) > 0 ) then
                            -- If the user has tried to move the thumb to the top of the track or above it, go to the first result.
                            panel.scroll.thumb:ClearAllPoints();
                            panel.scroll.thumb:SetPoint("TOP", 0, 0);
                            panel.scroll.index = 1;
                        elseif ( math.abs((panel.scroll.maxy - y)) > (panel.scroll.maxy - panel.scroll.miny) ) then
                            -- If the user has tried to move the thumb to the bottom of the track or below it, go to the last result.
                            panel.scroll.thumb:ClearAllPoints()
                            panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - panel.scroll.miny))
                            panel.scroll.index = ( #panel.scrollResults - #panel.scroll.buttons + 1 )
                        else
                            -- Otherwise, move the scroll thumb to the appropriate position and go to the appropriate result.
                            panel.scroll.thumb:ClearAllPoints()
                            panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - y));
                            
--~                             local tempStep = math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1;
                            if ( (math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1) ~= panel.scroll.index ) then
                                -- Determine the target index, and if it's not the current index, then change the index.
                                panel.scroll.index = (math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1)
                            end
                        end
                        panel.ScrollButtons(panel)		
                        panel.timer = 0;
                    end
                end
            
            panel.StartIncrementalScroll =
                function(panel, direction)
                    panel.scrollDir = direction;
                    panel.MoveScroll(panel, panel.scrollDir);
                    panel:SetScript("OnUpdate", function(self, elapsed) panel.IncrementalUpdate(panel, elapsed) end);                
                end
                
            panel.StopIncrementalScroll =
                function(panel)
                    panel:SetScript("OnUpdate", nil)
                    panel.scrollDir = nil;
                    panel.timeSinceLastIncrement = nil;
                end
            
            panel.IncrementalUpdate =
                function(panel, elapsed)
                    panel.timeSinceLastIncrement = ( panel.timeSinceLastIncrement or 0 ) + elapsed
                    if ( panel.timeSinceLastIncrement > .21 and panel.scrollDir ) then
                        panel.MoveScroll(panel, panel.scrollDir);
                        panel.timeSinceLastIncrement = 0.15;
                    end
                end
                
            panel.StartScroll =
                function(panel)
                    if ( panel.scroll.thumb:IsEnabled() == 1 ) then
                        panel.scroll.update:Show();
                    end
                end
                
            panel.StopScroll =
                function(panel)
                    panel.scroll.update:Hide()
                end					
                   
            panel.UpdateScrollButtons =
                function(panel)
                
                    -- Update the position of the scroll thumb
                    panel.SetScrollVars(panel);
                    if not ( panel.scroll.update:IsVisible() == 1 ) then
                        panel.scroll.thumb:ClearAllPoints();
                        if ( panel.scroll.numsteps == 0 ) then
                            panel.scroll.thumb:SetPoint("TOP", 0, 0);
                        else
                            
                            if ( -(panel.scroll.stepsize * ( panel.scroll.index -1) ) > 0 ) then 
                                panel.scroll.thumb:SetPoint("TOP", 0, (panel.scroll.stepsize * ( panel.scroll.index -1))); -- Yay crappy failsafes!
                            else
                                panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.stepsize * ( panel.scroll.index -1)));
                            end
                        end
                    end
                    
                    -- Enable the up button if appropriate
                    if ( panel.scroll.index > 1 ) then
                        panel.scroll.upbtn:Enable()
                    else
                        panel.scroll.upbtn:Disable()
                    end
                    
                    -- Enable the down button if appropriate
                    if ( ( panel.scroll.index + #panel.scroll.buttons ) <= #panel.scrollResults ) then
                        panel.scroll.downbtn:Enable()
                    else
                        panel.scroll.downbtn:Disable();
                    end
                    
                    -- Enable the scroll thumb if either the up or down button is enabled.
                    if ( ( panel.scroll.upbtn:IsEnabled() == 1 ) or ( panel.scroll.downbtn:IsEnabled() == 1 ) ) then
                        panel.scroll.thumb:Enable();
                    else
                        panel.scroll.thumb:Disable();
                    end
                end
        
            panel.ScrollButtons = 
                function(panel)
                    local i = 0;
                    local renderTable = {};
                    local normalColor = {};
                    
                    normalColor.r, normalColor.g, normalColor.b, normalColor.a  = GameFontNormal:GetTextColor();
                
                    for ordinal, element in next, panel.table do
                        if ( element.header ) then
                            table.insert(renderTable, element)
                        else
                            for _, category in next, panel.categories do
                                if ( category == element.type ) then
                                    table.insert(renderTable, element)
                                end
                            end
                        end
                    end
                    
                    local numElements = #renderTable;
                    local numButtons = #panel.scroll.buttons
                    
                    if ( numElements < numButtons ) then
                        panel.scroll.index = 1;
                    elseif ( numElements - panel.scroll.index < numButtons ) then
                        panel.scroll.index = numElements - numButtons + 1;
                    end                                 
                    
                    panel.highlight:Hide()
                    for i = 1, numButtons do
                        panel.scroll.buttons[i].text:SetText("")
                        -- panel.scroll.buttons[i].rightText:SetText("")
                        panel.scroll.buttons[i].normalColor = normalColor;
                        panel.scroll.buttons[i].text:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a);
                        -- panel.scroll.buttons[i].rightText:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a);							
                        panel.scroll.buttons[i]:Hide();
                        panel.scroll.buttons[i].btn:Hide();
                        panel.scroll.buttons[i].element = nil;
                        panel.scroll.buttons[i].tooltip = nil;
                        panel.scroll.buttons[i].selected = false;
                    end
                    
                    local color;
                    for ordinal, element in ipairs(renderTable) do
                        if ( ordinal >= panel.scroll.index ) then
                            i = i + 1;
                            -- panel.scrollResults[ordinal] = element;
                            panel.scroll:Show();
                            if panel.scroll.buttons[i] then
                                if ( element.header ) then
                                    panel.scroll.buttons[i].text:ClearAllPoints();
                                    panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( FEEDBACKUI_OFFSETPIXELS ), 0);
                                    panel.scroll.buttons[i].text:SetPoint("BOTTOMRIGHT");
                                    if ( element.expanded ) then
                                        panel.scroll.buttons[i].btn:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up.blp");
                                        panel.scroll.buttons[i].btn:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down.blp");
                                        panel.scroll.buttons[i].btn:SetDisabledTexture("Interface\\BUTTONS\\UI-MinusButton-Disabled.blp");
                                    else
                                        panel.scroll.buttons[i].btn:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up.blp");
                                        panel.scroll.buttons[i].btn:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down.blp");
                                        panel.scroll.buttons[i].btn:SetDisabledTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled.blp");
                                    end
                                    panel.scroll.buttons[i].btn:Show();
                                    panel.scroll.buttons[i].element = element;
                                else
                                    panel.scroll.buttons[i].element = element;
                                    panel.scroll.buttons[i].text:ClearAllPoints();
                                    panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( FEEDBACKUI_OFFSETPIXELS * 1.5 ), 0);
                                    panel.scroll.buttons[i].text:SetPoint("BOTTOMRIGHT");
                                    panel.scroll.buttons[i].tooltip = true;
                                    color = panel.GetStatusColor(element.status)
                                    panel.scroll.buttons[i].normalColor = color;
                                    panel.scroll.buttons[i].text:SetTextColor(color.r, color.g, color.b, color.a);
                                end
                                panel.scroll.buttons[i].text:SetText(element.name);
                                panel.scroll.buttons[i]:Show();
                            end
                        end
                    end

                    if panel.selectedId then
                        for i = 1, numButtons do
                            if ( panel.scroll.buttons[i].element and panel.scroll.buttons[i].element.id ) then
                                if ( panel.scroll.buttons[i].element.id == panel.selectedId ) then
                                    panel.HighlightButton(panel, panel.scroll.buttons[i])
                                end
                            end
                        end
                    end    
                    
                    panel.scrollResults = renderTable;
                    panel.UpdateScrollButtons(panel);
                    
                    
                end
        
            panel.CreateButtons = 
                function(panel)
                    if ( panel.scroll and panel.scroll.buttons ) then
                        local buttoncapacity = ( math.floor(((panel.scroll:GetHeight()) / panel.scroll.buttons[1]:GetHeight())) )
                        local numbuttons = #panel.scroll.buttons;
                        if numbuttons < buttoncapacity and buttoncapacity > panel.maxbuttons then
                            local newButton;
                            for i = 1, buttoncapacity - numbuttons do
                                newButton = CreateFrame("Button", string.gsub(panel.scroll.buttons[1]:GetName(), "%d+", "") .. (numbuttons + i), panel.scroll, "ScrollElementTemplate")
                                newButton:SetPoint("TOPLEFT", panel.scroll.buttons[numbuttons + i - 1], "BOTTOMLEFT", 0, 0)
                                newButton:SetWidth(panel.scroll.buttons[1]:GetWidth());
                                newButton:SetHeight(panel.scroll.buttons[1]:GetHeight());
                                table.insert(panel.scroll.buttons, newButton)
                                newButton.index = #panel.scroll.buttons;
                            end
                            panel.maxbuttons = buttoncapacity;
                        end
                    else

                    end
                end		
            
            ----------------------------------------------------------------------------------------------------
            -- Code for populating and managing dropdown lists
            ----------------------------------------------------------------------------------------------------
                        
            panel.LoadCategory = 
                function(ddl)
					panel.ddlCategory =  BQAE_DropDown:Init("FeedbackUISurveyFrameSurveysPanelDdlCategory", FeedbackUISurveyFrameSurveysPanel, "Type:");
					panel.ddlCategory:SetPoint("TOPRIGHT", FeedbackUISurveyFrameSurveysPanel, "TOPRIGHT", 0, -3);
					panel.ddlCategory:SetWidth(110);
					for i, value in next, FEEDBACKUI_SURVEYCATEGORIES do
						panel.ddlCategory:AddButton(value.text, value.value, panel.Category_OnClick);
                    end
                end

            panel.LoadStatus =
                function(ddl)
					panel.ddlStatus = BQAE_DropDown:Init("FeedbackUISurveyFrameSurveysPanelDdlStatus", FeedbackUISurveyFrameSurveysPanel, "Status:");
					panel.ddlStatus:SetPoint("RIGHT", FeedbackUISurveyFrameSurveysPanelDdlCategory, "LEFT", -60, 0);
					panel.ddlStatus:SetWidth(110);
					for i, value in next, FEEDBACKUI_SURVEYSTATUS do
						panel.ddlStatus:AddButton(value.text, value.value, panel.Status_OnClick);
                    end
                end

            panel.Category_OnClick =
                function()
                    panel.PopulateTable(FeedbackUISurveyFrameSurveysPanel);
                end
                
            panel.Status_OnClick =
                function()
                    panel.PopulateTable(FeedbackUISurveyFrameSurveysPanel)
                end
            
            -----------------------------------------------------------------------------------
            -- Define all values the panel needs to run functions correctly, then
            -- run the setup functions that were defined earlier in panel.setup.
            -----------------------------------------------------------------------------------
        end
}


--[[	
function Survey_Status_Panel ()
end
]]--	

FeedbackUI_SetupPanel{
	name = "StatusPanel",
	parent = "FeedbackUISurveyFrame",
	inherits = "FeedbackPanelTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentSurveysPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = 3 },
				{ ["point"] = "TOPRIGHT", ["relativeto"] = "$parentSurveysPanel", ["relativepoint"] = "TOPRIGHT", ["x"] = 0, ["y"] = 3 } },
	size = { ["y"] = 70 },
	Setup = function (obj)
				-- Create the seperator line that follows the Status panel.
				obj.seperator = CreateFrame("Frame", obj:GetName() .. "Line", obj, "FeedbackLineTemplate");
				obj.seperator:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", 0, -5);
				obj.seperator:SetPoint("TOPRIGHT", obj, "BOTTOMRIGHT", 0, -5);
				obj.status = {};
                obj.statusValue = {};
                obj.infoLines = {};
                obj:GetParent().statusPanel = obj;
				
				obj.UpdateInfoLines = 
					function (panel)
	    				for _, line in next, panel.infoLines do
	    					if ( line.Update ) then 
	                            line.Update(line, panel)
	                        end
	    				end	
	    			end;
                
                obj.SetupStatus =
                    function (panel, typesTable)
                        if ( type(typesTable) ~= "table" ) then
                            return;
                        end
                        
                        panel.status = {};
                        panel.statusValue = {};
                        
                        for _, element in ipairs(typesTable) do
                            panel.status[element] = "";
                            panel.statusValue[element] = nil;
                        end
                        
                        for num, line in ipairs(panel.infoLines) do
                            if ( typesTable[num] ) then
                                line.type = typesTable[num]
                                line.label:SetText(FEEDBACKUI_RESPONSELABELS[line.type]);
                            else
                                line.type = nil;
                                line.label:SetText("");
                            end
                        end
                        
                        
                        
                        if ( #typesTable == 3 ) then
                            panel.infoLines[1]:SetPoint("TOPLEFT", panel.infoLines[1]:GetParent():GetName(), "TOPLEFT", 3, -16);
                        else
                            panel.infoLines[1]:SetPoint("TOPLEFT", panel.infoLines[1]:GetParent():GetName(), "TOPLEFT", 3, -8);
                        end
                    end
			end,
	OnShow = 	function (panel)
    				for _, line in next, panel.infoLines do
    					if ( line.Update ) then 
                            line.Update(line, panel)
                        end
    				end	
    			end,
	}
	

	
FeedbackUI_AddInfoLine{
	name = "Clarity",
	parent = "FeedbackUISurveyFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMCLARITY_TEXT,
	Setup = function(line)
				line.type = "clarity"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}
			
FeedbackUI_AddInfoLine{
	name = "Difficulty",
	parent = "FeedbackUISurveyFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMDIFFICULTY_TEXT,
	Setup = function(line)
				line.type = "difficulty"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}

FeedbackUI_AddInfoLine{
	name = "Reward",
	parent = "FeedbackUISurveyFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMREWARD_TEXT,
	Setup = function(line)
				line.type = "reward"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}			
					
FeedbackUI_AddInfoLine{
	name = "Fun",
	parent = "FeedbackUISurveyFrameStatusPanel",
	inherits = "InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMFUN_TEXT,
	Setup = function(line)
				line.type = "fun"
			end,
	Update = function(line, panel)
				if ( panel.status ) and ( line.type ) then
					line.value:SetText(panel.status[line.type]);
				end			
			end
			}	
	
				
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Version",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMVER_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["version"], line:GetParent().infoTable["build"],line:GetParent().infoTable["date"] = GetBuildInfo();
				line.value:SetText("WoW " .. line:GetParent().infoTable["version"] .. " \[Release\] Build " .. line:GetParent().infoTable["build"]);
			end,
    Setup =
        function (line)
            line:Hide();
        end,
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Realm",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMREALM_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["realm"] = GetRealmName();
				line.value:SetText(line:GetParent().infoTable["realm"])
			end,
    Setup =
        function (line)
            line:Hide();
        end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Name",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMNAME_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["name"] = UnitName("player");
				line.value:SetText(line:GetParent().infoTable["name"])
			end,
    Setup =
        function (line)
            line:Hide();
        end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Char",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMCHAR_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["character"] = FeedbackUI_GetLocalizedCharString(UnitLevel("player"), UnitRace("player"), FEEDBACKUI_GENDERTABLE[UnitSex("player")], UnitClass("player"));
				line:GetParent().infoTable["level"] = UnitLevel("player");
				line:GetParent().infoTable["race"] = UnitRace("player");
				line:GetParent().infoTable["sex"] = FEEDBACKUI_GENDERTABLE[UnitSex("player")];
				line:GetParent().infoTable["class"] = UnitClass("player");
				line.value:SetText(line:GetParent().infoTable["character"])
			end,
    Setup =
        function (line)
            line:Hide();
        end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Map",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMMAP_TEXT,
	Update = function(line)
			line:GetParent().infoTable = line:GetParent().infoTable or {}
			
			--Record positioning information with the Map line since there isn't any particular place to do it with the new format.
			local debugStats, parseString
			
			if ( GetDebugStats() ) then 
				debugStats = {}
				parseString="([^%c]+)";
				for line in string.gmatch(GetDebugStats(), parseString) do
					table.insert(debugStats, line)
				end
			else
				debugStats = ""
			end	
			
			if ( debugStats ~= "" ) then 
				line:GetParent().infoTable["position"] = string.gsub(debugStats[2], "Player position: ", "");
				line:GetParent().infoTable["facing"] = debugStats[3]
				line:GetParent().infoTable["speed"] = debugStats[4]
				
				for _, debugStat in next, debugStats do
					if ( string.find(debugStat, "Obj") ) then
						line:GetParent().infoTable["chunk"] = string.gsub(string.gsub(debugStat, "Obj", ""), " ", "");
					end
					if ( string.find(debugStat, "Chunk ") ) then
						line:GetParent().infoTable["chunk"] = (line:GetParent().infoTable["chunk"] or "") .. " : " .. string.gsub(debugStat, "Chunk ", "");
						break;
					end
				end
			end
			
			local x, y = GetPlayerMapPosition("player");
			x = math.floor(x * 100)
			y = math.floor(y * 100)
			line:GetParent().infoTable["coords"] = x..", "..y	
			
			local mapCompare = { GetMapContinents() };
			SetMapToCurrentZone();
			line:GetParent().infoTable["map"] = mapCompare[GetCurrentMapContinent()];
			line.value:SetText(line:GetParent().infoTable["map"])
		end,
    Setup =
        function (line)
            line:Hide();
        end
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Zone",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMZONE_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["zone"] = GetRealZoneText();
				line.value:SetText(line:GetParent().infoTable["zone"])
			end,
    Setup =
        function (line)
            line:Hide();
        end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Area",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMAREA_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["area"] = GetSubZoneText();
				line.value:SetText(line:GetParent().infoTable["area"])
			end,
    Setup =
        function (line)
            line:Hide();
        end
	}
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Addons",
	inherits="InfoLineTemplate",
	labelText = FEEDBACKUILBLFRMADDONS_TEXT,
	Update = function(line)
				line:GetParent().infoTable = line:GetParent().infoTable or {}
				line:GetParent().infoTable["addons"] = nil;
				line:GetParent().infoTable["addonsdisabled"] = nil;
				line:GetParent().infoTable["addonloaded"] = nil;
				line:GetParent().infoTable["addonsWrap"] = nil;

				local addonsList, addonsListCount, wrapCount
				
				addonsList = {}
				for i = 1, GetNumAddOns() do
					table.insert(addonsList, { GetAddOnInfo(i) })
				end
				if ( addonsList == nil ) then addonsList = { "None" } end
								
				addonsListCount = table.maxn(addonsList)
				wrapCount = 1
				
				for i = 1, addonsListCount do
					if not ( line:GetParent().infoTable["addons"] ) then
						if ( addonsList[i][4] == 1 ) then
							line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
							line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
							wrapCount = 1;
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
                        end
						line:GetParent().infoTable["addons"] = addonsList[i][1];
					else
						if ( addonsList[i][4] == 1 ) then
							if not ( line:GetParent().infoTable["addonsWrap"] ) then
								line:GetParent().infoTable["addonsloaded"] = addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = HIGHLIGHT_FONT_COLOR_CODE..FEEDBACKUILBLADDONSWRAP_TEXT..FONT_COLOR_CODE_CLOSE..addonsList[i][1];					
								wrapCount = 1;
							elseif ( ( wrapCount / 3) == math.floor( wrapCount / 3 ) ) then
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"].."\n"..addonsList[i][1];
								wrapCount = wrapCount + 1;
							else
								line:GetParent().infoTable["addonsloaded"] = line:GetParent().infoTable["addonsloaded"]..", "..addonsList[i][1]
								line:GetParent().infoTable["addonsWrap"] = line:GetParent().infoTable["addonsWrap"]..", "..addonsList[i][1];
								wrapCount = wrapCount + 1;
							end
						else
                            line:GetParent().infoTable["addonsdisabled"] = addonsList[i][1]
						end
						line:GetParent().infoTable["addons"] = line:GetParent().infoTable["addons"]..", "..addonsList[i][1];
					end	
				end
				
                line.value:SetText(FEEDBACKUILBLADDONS_MOUSEOVER);
				
			end,
    Setup =
        function (line)
            line:Hide();
        end
	
	}

FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="Talents",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
            local talents = {};
            local points;
    		for tab=1, GetNumTalentTabs() do
    			for talent=1, GetNumTalents(tab) do
    				_, _, _, _, points = GetTalentInfo(tab, talent);
    				tinsert(talents, points);
    			end
    		end
            
            line:GetParent().infoTable["talents"] = table.concat(talents);
        end,
    Setup =
        function (line)
            line:Hide();
        end
    }
	
FeedbackUI_AddInfoLine{
    parent="FeedbackUISurveyFrameStatusPanel",
    name="Equipment",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
            line:GetParent().infoTable["equipment"] = FeedbackUI_GetInventoryInfo();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };

FeedbackUI_AddInfoLine{
    parent="FeedbackUISurveyFrameStatusPanel",
    name="SurveyID",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}            
            line:Hide();
            line:GetParent().infoTable["surveyid"] = g_FeedbackUI_feedbackVars["focusid"]
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="VideoOptions",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUI_BuildSettingsString("Video");
            
            line:GetParent().infoTable["videooptions"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };
	
FeedbackUI_AddInfoLine{
	parent="FeedbackUISurveyFrameStatusPanel",
	name="SoundOptions",
	inherits="InfoLineTemplate",
	labelText = "",
	Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {}
            
            line:Hide();
			local dataString = FeedbackUI_BuildSettingsString("Sound");
            
            line:GetParent().infoTable["soundoptions"] = dataString;
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };

FeedbackUI_AddInfoLine{
    parent="FeedbackUISurveyFrameStatusPanel",
    name="Locale",
    inherits="InfoLineTemplate",
    labelText = "",
    Update = 
        function (line)
            line:GetParent().infoTable = line:GetParent().infoTable or {};
            line:Hide();
            line:GetParent().infoTable["locale"] = GetLocale();
        end,
    Setup =
        function (line)
            line:Hide();
        end
    };    	
	

--[[	
function Survey_Stepthrough_Panel ()
end
]]--	

		
FeedbackUI_SetupPanel{
	name = "StepThroughPanel",
	parent = "FeedbackUISurveyFrame",
	inherits = "FeedbackWizardTemplate",
	anchors = { { ["point"] = "TOPLEFT", ["relativeto"] = "$parentStatusPanel", ["relativepoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -1 },
				{ ["point"] = "BOTTOMRIGHT", ["relativeto"] = "$parent", ["relativepoint"] = "BOTTOMRIGHT", ["x"] = 2, ["y"] = 19 } },
    OnHide =    function (panel)
                    panel.Reset(panel);
                end,                    
	Setup = function(panel)
				panel.maxbuttons = 1
				panel.scrollResults = {}
				panel.history = {}
				panel.table = FEEDBACKUI_SURVEYWELCOMETABLE
				panel.startlink = FEEDBACKUI_SURVEYWELCOMETABLE
                panel:GetParent().stepThroughPanel = panel;
								
                panel.Localize = 
                    function(panel)
                        if GetLocale() == "esES" or GetLocale() == "frFR" or GetLocale() == "deDE" then
                            panel.buttonWidth = 415
                            panel.buttonHeight = 26
                            panel.input:SetWidth(390)
                            panel:GetParent().skip:SetWidth(panel:GetParent().skip:GetWidth() + 35);
                    
                            panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
                            panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        else
                            panel.buttonWidth = 325
                            panel.buttonHeight = 26
                            panel.input:SetWidth(307)
                            
            				panel.scroll.buttons[1]:SetWidth(panel.buttonWidth);
            				panel.scroll.buttons[1]:SetHeight(panel.buttonHeight);
                        end
                    end
                
				panel.Back = 
					function(panel) 
						panel.Render(panel, panel.history[#panel.history]); 
                        panel:GetParent().submit:Disable();
                        if ( ( panel.input:GetText() ~= FEEDBACKUISURVEYFRMINPUTBOX_TEXT ) and ( panel.input:GetText() ~= panel.element.comments ) and ( panel.input:GetText() ~= "" ) ) then
                            panel.element.newComments = panel.input:GetText();
                        end
						panel.history[#panel.history] = nil; 
						if ( #panel.history == 0 ) then 
                            panel:GetParent().back:Disable() 
                            -- panel:GetParent().reset:Disable();
                        end 
                        -- if ( #panel.history == 0 ) then FeedbackUITab4:Click() end 
                    end
						
				panel.Reset = 	
					function(panel) 
                        FeedbackUISurveyFrameSurveysPanel.selectedId = nil;
                        FeedbackUISurveyFrameSurveysPanel.ResetButtons(FeedbackUISurveyFrameSurveysPanel);
                        panel.startlink = FEEDBACKUI_SURVEYWELCOMETABLE;
                        
                        panel.table = FEEDBACKUI_SURVEYWELCOMETABLE;     
                        panel.SoftReset(panel);
                        FeedbackUITab4:Click()
                    end
                    
                panel.SoftReset =
                    function(panel)
                        panel.history = {}; 
                        panel:GetParent().back:Disable();
                        panel:GetParent().submit:Disable();
                        panel:GetParent().skip:Disable();
                        -- panel:GetParent().reset:Disable();
                        panel.scrollResults = {};
                        panel.scroll.index = nil;
                        panel:GetParent().statusPanel.status = {}
                        panel:GetParent().statusPanel.statusValue = {};
                        -- for num, line in ipairs(panel:GetParent().statusPanel.infoLines) do
                            -- line.value:SetText("");
                        -- end
						
						for index, panelElement in next, panel:GetParent().panels do 
                            if ( panelElement.name == "StatusPanel" ) then
                                panelElement.status = {}
                                panelElement.statusValue = {}
                                for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							elseif ( panelElement.name == "InfoPanel" ) then
								panelElement.infoTable = {};
								for num, line in next, panelElement.infoLines do
                                    line.value:SetText("")
                                end
							end
                        end
                        -- msg(#panel.startlink)
                        panel.table = panel.startlink; 
                        -- msg(#panel.table)
                        
                        panel.input:SetText(FEEDBACKUISURVEYFRMINPUTBOX_TEXT);
                        panel.input.default = nil;
                        panel.input:HighlightText(0);
                        
                        panel.Render(panel)
                    end
                    
                panel.Skip =
                    function(panel)
                        for _, value in next, g_FeedbackUI_surveysTable[panel.element.type] do
                            if ( value.id == panel.element.id ) then
                                value.status = "Skipped";
                            end
                        end
                        
                        for _, panelElement in next, panel:GetParent().panels do 
                            if ( panelElement.name == "SurveysPanel" ) then
                                panelElement.selectedId = nil;
                                panelElement.PopulateTable(panelElement);
                                panel:GetParent().back:Disable();
                                -- panel:GetParent().reset:Disable();
                                panel:GetParent().skip:Disable();
                                panel:GetParent().submit:Disable();
                            end
                        end
                        
                        panel.startlink = FEEDBACKUI_SURVEYWELCOMETABLE;
                        panel.table = FEEDBACKUI_SURVEYWELCOMETABLE;
                        panel.SoftReset(panel)
                    end
                    
				panel.Submit = 
					function (panel)
						local statusPanel = panel:GetParent().statusPanel;
						statusPanel.UpdateInfoLines(statusPanel);
						
						panel.infoString = "";
                        FeedbackUIBugFrameInfoPanel.Show(FeedbackUIBugFrameInfoPanel);
						local infoTable = FeedbackUISurveyFrameStatusPanel.infoTable;
                        --local infoTable = FeedbackUIBugFrameInfoPanel.infoTable;
						-- local bs = FEEDBACKUI_DELIMITER;
                        
                        
                        -- infoTable = bugFrameInfoPanel.infoTable;
                        
                        for num, line in ipairs(statusPanel.infoLines) do
                            infoTable["category"..num] = statusPanel.statusValue[line.type]
                            
                        end
						
                        infoTable["surveyname"] = panel.element.name
                        infoTable["surveyid"] = panel.element.id
                        infoTable["surveyobjectives"] = panel.element.objectives
                        infoTable["surveytype"] = panel.element.type

                        --Wonderful workaround for date formatting being different across platforms
                        local function formatDateString (timeString)
                            local dateInfo = date("*t", timeString);
                            dateInfo["month"] = string.format("%02d", dateInfo["month"]);
                            dateInfo["day"] = string.format("%02d", dateInfo["day"]);
                            dateInfo["year"] = string.format("%04d", dateInfo["year"])
                            dateInfo["hour"] = string.format("%02d", dateInfo["hour"]);
                            dateInfo["min"] = string.format("%02d", dateInfo["min"]);
                            dateInfo["sec"] = string.format("%02d", dateInfo["sec"]);
                            
                            dateInfo["str"] = dateInfo["month"] .. "/" .. dateInfo["day"] .. "/" .. dateInfo["year"] .. " ";
                            dateInfo["str"] = dateInfo["str"] .. dateInfo["hour"] .. ":" .. dateInfo["min"] .. ":" .. dateInfo["sec"];
                            
                            return dateInfo["str"];
                        end
                            
                        infoTable["surveyobtained"] = formatDateString(panel.element.added)
                        infoTable["surveysubmitted"] = formatDateString(time())                        
						
                        
                        
                        infoTable["combats"] = 0;
                        infoTable["deaths"] = 0;
                        infoTable["averagelength"] = 0;
                        infoTable["feedbacktype"] = 2;
						
                        inputString = panel.input:GetText();
                        
                        if ( inputString == FEEDBACKUISURVEYFRMINPUTBOX_TEXT ) then
                            inputString = ""
                        end
                        
                        inputString = string.gsub(inputString, "\n", " ");
						inputString = string.gsub(inputString, FEEDBACKUI_DELIMITER, " ");
						infoTable["text"] = inputString;
						--panel.infoString = panel.infoString .. (objName or "") .. inputString;
						
						local indexLine;
						for index, field in next, FEEDBACKUI_FIELDS do
							if ( infoTable[field] ) then
                                infoTable[field] = string.gsub(infoTable[field], "[%<%>%/%\n]+", " ");
								indexLine = "<" .. index .. ">" .. infoTable[field] .. "</" .. index .. ">";
								panel.infoString = panel.infoString .. indexLine;
							end
						end
                        
						-- for index, field in next, FEEDBACKUI_FIELDS do
							-- if not ( infoTable[field] ) then
								-- infoTable[field] = "";
								-- panel.infoString = panel.infoString .. bs;
							-- else
                                -- infoTable[field] = string.gsub(infoTable[field], bs, " ");
								-- panel.infoString = panel.infoString .. string.gsub(infoTable[field], "\n", " ") .. bs;
							-- end
						-- end
						--DeleteFile("Interface\\Addons\\test.txt");
						--AppendToFile("Interface\\Addons\\test.txt", panel.infoString)
						ReportSuggestion(panel.infoString);
						UIErrorsFrame:Clear();
						UIErrorsFrame:AddMessage(FEEDBACKUI_CONFIRMATION, 1, 1, .1, 1.0, 5);
                        
                        for _, value in next, g_FeedbackUI_surveysTable[panel.element.type] do
                            if ( value.id == panel.element.id ) then
                                value.comments = panel.input:GetText();
                                value.status = "Completed";
                                value.completed = time();
                            end
                        end
                        
                        for _, panelElement in next, panel:GetParent().panels do 
                            if ( panelElement.name == "SurveysPanel" ) then
                                panelElement.selectedId = nil;
                                panelElement.PopulateTable(panelElement);
                                panel:GetParent().back:Disable();
                                -- panel:GetParent().reset:Disable();
                                panel:GetParent().skip:Disable();
                                panel:GetParent().submit:Disable();
                            end
                        end
                        
                        panel:GetParent().submit:SetText(FEEDBACKUISUBMIT_TEXT);
                        panel.startlink = FEEDBACKUI_SURVEYWELCOMETABLE;
                        panel.table = FEEDBACKUI_SURVEYWELCOMETABLE;                
						panel.SoftReset(panel);
                        collectgarbage("collect");
						-- FeedbackUITab4:Click();
					end
				
				panel.UpdateButtons = 
					function(panel) 
						panel.CreateButtons(panel)
					end
										
				panel.Click = 	
					function(panel, element)
						if ( not panel or not element ) then return end;
						table.insert(panel.history, panel.table);
						panel.parent.back:Enable();
                        panel.parent.reset:Enable();
						
						if ( element.summary ) then
                            for num, line in ipairs(panel:GetParent().statusPanel.infoLines) do
                                if ( line.type == element.summary.type ) then
                                    line.value:SetText(getglobal(element.summary.text));
                                    line.value:SetTextColor(GameFontNormal:GetTextColor());
                                    panel:GetParent().statusPanel.status[line.type] = getglobal(element.summary.text);
                                    panel:GetParent().statusPanel.statusValue[line.type] = element.summary.value;
                                end
							end
						end
						
						if getglobal(element.link) then
							panel.Render(panel, getglobal(element.link));
						else
							panel.Render(panel, element.link);
						end
						
                        for _, value in next, g_FeedbackUI_surveysTable[panel.element.type] do
                            if ( value.id == panel.element.id ) then
                                value[element.summary.type] = element.summary
                            end
                        end
                        
					end
				
				panel.Render = 	
					function(panel, renderTable)	
					
						-- Reset all the tracking values to their defaults, and hide all the buttons and things that will later be shown.
						panel.scroll:Hide();
						panel.prompt:Hide();
						panel.edit:Hide();
						panel.scroll.thumb:Disable()
						panel.scrollResults = {};
						
						for i = 1, #panel.scroll.buttons do
							panel.scroll.buttons[i]:Hide();
						end
						
						--Make sure we have something to render. If we get the "edit" string, then show the edit box.
						if ( not renderTable ) then 
							renderTable = panel.table 
						elseif ( ( type(renderTable) == "string" )  and ( renderTable == "edit" ) ) then 
							panel.table = renderTable;
                            panel.header:ClearAllPoints()
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.header);
							panel.header:SetText(FEEDBACKUI_SURVEYINPUTHEADER)
							panel.subtext:SetText("")
                            panel.input.blankString = nil;
                            if panel.element.comments then
                                panel.input:SetText((panel.element.newComments or panel.element.comments));
                                panel.input.default = nil;
                                panel.input:HighlightText(0);
                            elseif panel.input:GetText() == "" then
                                panel.input:SetText(FEEDBACKUISURVEYFRMINPUTBOX_TEXT);
                                panel.input.default = nil;
                                panel.input:HighlightText(0);
                            else
                                panel.input.default = nil;
                            end
							panel.scroll:Hide();
							panel:GetParent().back:Show();
							panel:GetParent().skip:Show();
							panel:GetParent().reset:Show();
							panel:GetParent().submit:Show();
                            panel:GetParent().submit:Enable();
							panel.edit:Show();
							return;
						else
							panel.table = renderTable 
						end;
											
						if ( renderTable.header == "" and renderTable.subtext ) then
							panel.header:ClearAllPoints()
							panel.header:SetPoint("LEFT", panel.header:GetParent(), "LEFT", 8, 0)
							panel.header:SetText(renderTable.subtext);
							panel.subtext:SetText("");
						else
							if ( renderTable.header ) then
								panel.header:SetPoint("TOPLEFT", panel.header:GetParent(), "TOPLEFT", 8, -6)
								panel.header:SetText(renderTable.header);
							end
							
							if renderTable.subtext then
								panel.subtext:SetText(renderTable.subtext);
							end
						end
						
						local i = 0;
                        local maxSummary;
						for ordinal, element in ipairs(renderTable) do
							--Clear downlevel status lines.
							maxSummary = math.huge
							if ( element.summary ) then
                                for num, line in ipairs(panel:GetParent().statusPanel.infoLines) do
                                    if ( line.type ) then
                                        if ( line.type == element.summary.type ) then
                                            maxSummary = num;
                                        end
                                        if ( num >= maxSummary ) then 
                                            if ( panel.element.status ~= FEEDBACKUI_STATUSAVAILABLETEXT ) then
                                                if ( panel.element[line.type] and panel.statusHistory[line.type] ) then
                                                    line.value:SetTextColor(GameFontDisable:GetTextColor());
                                                    line.value:SetText((getglobal(panel.statusHistory[line.type].text) or "" ));
                                                else
                                                    line.value:SetText("");
                                                end
                                            else
                                                line.value:SetText("") 
                                                panel:GetParent().statusPanel.status[line.type] = nil;
                                                panel:GetParent().statusPanel.statusValue[line.type] = nil;
                                            end
                                        elseif ( ( num < maxSummary ) and ( line.value:GetText() == "" or line.value:GetText() == nil ) ) then
                                            panel:GetParent().statusPanel.status[line.type] = "N/A";
                                            panel:GetParent().statusPanel.statusValue[line.type] = 0;
                                            line.value:SetText("N/A");
                                        end
                                    end
                                end
							end

							i = i + 1;
							panel.scrollResults[ordinal] = element;
							if ( element.prompt ) then
								panel.prompt:Show();
								panel.prompt:SetText(element.prompt);
								-- panel.startlink = getglobal(element.link);
							else											
								panel.scroll:Show();
								panel:GetParent().back:Show();
								panel:GetParent().skip:Show();
								panel:GetParent().reset:Show();
								panel:GetParent().submit:Show();
								if panel.scroll.buttons[i] then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.scroll.index = 1;
						panel.UpdateScrollButtons(panel);
					end
			
				panel.SetScrollVars = 	
					function(panel)
						-- Calculate values necessary to scroll
						panel.scroll.maxy = (panel.scroll.controls:GetTop() - 5);
						panel.scroll.miny = (panel.scroll.controls:GetBottom() + 13);
						panel.scroll.steprange = panel.scroll.maxy - panel.scroll.miny;
						panel.scroll.numsteps = #panel.scrollResults - #panel.scroll.buttons;
						panel.scroll.stepsize = panel.scroll.steprange / panel.scroll.numsteps;				
					end
			
				panel.ScrollOnUpdate =
					function(panel, elapsed)
						if ( not panel.timer ) then panel.timer = 0 end
						panel.timer = panel.timer + elapsed;
						if ( panel.timer > 0.1 ) then
							panel.SetScrollVars(panel);
							
							
							-- Compensate for UI scaling
							-- yarealy
							local x, y = GetCursorPosition();
							x = x / panel:GetEffectiveScale();
							y = y / panel:GetEffectiveScale();
							
							-- See where the user is trying to move the thumb to.
							local moveVariable = -(panel.scroll.maxy - y)
													
							if ( -(panel.scroll.maxy - y) > 0 ) then
								-- If the user has tried to move the thumb to the top of the track or above it, go to the first result.
								panel.scroll.thumb:ClearAllPoints();
								panel.scroll.thumb:SetPoint("TOP", 0, 0);
								panel.scroll.index = 1;
							elseif ( math.abs((panel.scroll.maxy - y)) > (panel.scroll.maxy - panel.scroll.miny) ) then
								-- If the user has tried to move the thumb to the bottom of the track or below it, go to the last result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - panel.scroll.miny))
								panel.scroll.index = ( #panel.scrollResults - #panel.scroll.buttons + 1 )
							else
								-- Otherwise, move the scroll thumb to the appropriate position and go to the appropriate result.
								panel.scroll.thumb:ClearAllPoints()
								panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.maxy - y));
								
--~ 								local tempStep = ( math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1 );
								if ( ( math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1 ) ~= panel.scroll.index ) then
									-- Determine the target index, and if it's not the current index, then change the index.
									panel.scroll.index = ( math.round( (math.abs((panel.scroll.maxy - y)) / panel.scroll.stepsize ) ) + 1 );
								end
							end
							panel.ScrollButtons(panel)	
                            panel.timer = 0;                            
						end
					end
                    
                panel.StartIncrementalScroll =
                    function(panel, direction)
                        panel.scrollDir = direction;
                        panel.MoveScroll(panel, panel.scrollDir);
                        panel:SetScript("OnUpdate", function(self, elapsed) panel.IncrementalUpdate(panel, elapsed) end);                
                    end
                    
                panel.StopIncrementalScroll =
                    function(panel)
                        panel:SetScript("OnUpdate", nil)
                        panel.scrollDir = nil;
                        panel.timeSinceLastIncrement = nil;
                    end
                
                panel.IncrementalUpdate =
                    function(panel, elapsed)
                        panel.timeSinceLastIncrement = ( panel.timeSinceLastIncrement or 0 ) + elapsed
                        if ( panel.timeSinceLastIncrement > .21 and panel.scrollDir ) then
                            panel.MoveScroll(panel, panel.scrollDir);
                            panel.timeSinceLastIncrement = 0.15;
                        end
                    end
                
				panel.StartScroll =
					function(panel)
						if ( panel.scroll.thumb:IsEnabled() == 1 ) then
							panel.scroll.update:Show();
						end
					end
					
				panel.StopScroll =
					function(panel)
						panel.scroll.update:Hide()
					end					
			
				panel.UpdateScrollButtons =
					function(panel)
					
						-- Update the position of the scroll thumb
						panel.SetScrollVars(panel);
						if not ( panel.scroll.update:IsVisible() == 1 ) then
							panel.scroll.thumb:ClearAllPoints();
--~ 							local moveto = -(panel.scroll.stepsize * ( panel.scroll.index -1))
                            
							if ( -(panel.scroll.stepsize * ( panel.scroll.index -1)) > 0 ) then -- Yay crappy failsafes!
                                panel.scroll.thumb:SetPoint("TOP", 0, (panel.scroll.stepsize * ( panel.scroll.index -1)));
                            else
                                panel.scroll.thumb:SetPoint("TOP", 0, -(panel.scroll.stepsize * ( panel.scroll.index -1)));
                            end
						end
						
						-- Enable the up button if appropriate
						if ( panel.scroll.index > 1 ) then
							panel.scroll.upbtn:Enable()
						else
							panel.scroll.upbtn:Disable()
						end
						
						-- Enable the down button if appropriate
						if ( ( panel.scroll.index + #panel.scroll.buttons ) <= #panel.scrollResults ) then
							panel.scroll.downbtn:Enable()
						else
							panel.scroll.downbtn:Disable();
						end
						
						-- Enable the scroll thumb if either the up or down button is enabled.
						if ( ( panel.scroll.upbtn:IsEnabled() == 1 ) or ( panel.scroll.downbtn:IsEnabled() == 1 ) ) then
							panel.scroll.thumb:Enable();
						else
							panel.scroll.thumb:Disable();
						end
					end
			
				panel.MoveScroll = 	
					function(panel, int)
						if ( ( panel.scroll.index + int >= 1 ) and ( ( panel.scroll.index + int ) + #panel.scroll.buttons <= ( #panel.scrollResults + 1 ) ) ) then
							panel.scroll.index = panel.scroll.index + int
						end
						panel.ScrollButtons(panel)						
					end
			
				panel.ScrollButtons = 
					function(panel)
						local i = 0;
						
						for ordinal, element in ipairs(panel.table) do
							if ( ordinal >= panel.scroll.index ) then
								i = i + 1;
								if panel.scroll.buttons[i] then
									if ( element.offset ) then
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", ( element.offset * FEEDBACKUI_OFFSETPIXELS ), 0);
									else
										panel.scroll.buttons[i].text:ClearAllPoints();
										panel.scroll.buttons[i].text:SetPoint("TOPLEFT", 0, 0);
									end
									panel.scroll.buttons[i].element = element;
									panel.scroll.buttons[i].text:SetText(element.index);
									panel.scroll.buttons[i]:Show();
								end
							end
						end
						panel.UpdateScrollButtons(panel);
					end
			
				panel.CreateButtons = 
					function(panel)
						if ( panel.scroll and panel.scroll.buttons ) then
							local buttoncapacity = ( math.floor(((panel.scroll:GetHeight()) / panel.scroll.buttons[1]:GetHeight())) )
							local numbuttons = #panel.scroll.buttons;
							if numbuttons < buttoncapacity and buttoncapacity > panel.maxbuttons then
                                local newButton;
								for i = 1, buttoncapacity - numbuttons do
									newButton = CreateFrame("Button", string.gsub(panel.scroll.buttons[1]:GetName(), "%d+", "") .. (numbuttons + i), panel.scroll, "ScrollElementTemplate")
									newButton:SetPoint("TOPLEFT", panel.scroll.buttons[numbuttons + i - 1], "BOTTOMLEFT", 0, 0)
									newButton:SetWidth(panel.scroll.buttons[1]:GetWidth());
									newButton:SetHeight(panel.scroll.buttons[1]:GetHeight());
									table.insert(panel.scroll.buttons, newButton)
									newButton.index = #panel.scroll.buttons;
								end
								panel.maxbuttons = buttoncapacity;
							end
						else

						end
					end	
					
			end
	}		
