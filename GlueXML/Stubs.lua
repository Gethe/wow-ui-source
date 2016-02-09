

function StubFrame_OnEvent(self, event)
	if ( event == "FRAMES_LOADED" ) then
		AccountLogin_OnEvent(GlueParent, "SCREEN_FIRST_DISPLAYED");
	end
end

local STUBFRAME;
do
	STUBFRAME = CreateFrame("FRAME");
	STUBFRAME:SetScript("OnEvent", StubFrame_OnEvent);
	STUBFRAME:RegisterEvent("FRAMES_LOADED");
end

GLUESCREEN_DEBUG = false;

C_LoginStubs = { };
if ( GLUESCREEN_DEBUG ) then
	C_Login = {};
end

setmetatable(C_Login, { __index = C_LoginStubs });

LE_WOW_CONNECTION_STATE_CONNECTING2 = 13;

local BNET_STATE = LE_AURORA_STATE_NONE;
local WOW_STATE;
local CONNECTED_TO_WOW = false;
local HAS_REALM_LIST = false;
local LAST_ERROR;
local REALM;
local REALM_CONNECTED = false;

local password;
local checkAuthenticator = false;
local isLauncherLogin = true;
local DEBUG_PASSWORD = "b";

local function ChangeState(bnetState, connectedToWoW, wowState, hasRealmList, errorCode)
	BNET_STATE = bnetState;
	CONNECTED_TO_WOW = connectedToWoW;
	WOW_STATE = wowState;
	HAS_REALM_LIST = hasRealmList;
	LAST_ERROR = errorCode;
	if ( GLUESCREEN_DEBUG ) then
		print("[Debug state] "..BNET_STATE..", "..(CONNECTED_TO_WOW and "true, " or "false, ")..(WOW_STATE and WOW_STATE or "nil")..", "..(HAS_REALM_LIST and "true" or "false"));
	end
	GlueParent_OnEvent(GlueParent, "LOGIN_STATE_CHANGED");
end

function StubFrame_OnUpdateLogin(self, elapsed)
	STUBFRAME.wait = STUBFRAME.wait - elapsed;
	if ( STUBFRAME.wait < 0 ) then
		if ( BNET_STATE == LE_AURORA_STATE_CONNECTING ) then
			if ( checkAuthenticator and not isLauncherLogin ) then
				ChangeState(LE_AURORA_STATE_ENTER_EXTRA_AUTH, false, LE_WOW_CONNECTION_STATE_NONE, false);
				STUBFRAME:SetScript("OnUpdate", nil);
			else
				StubFrame_CheckPassword();
			end
		elseif ( BNET_STATE == LE_AURORA_STATE_CONNECTED and STUBFRAME.wait < -0.5 ) then
			if ( REALM ) then
				-- connected to a realm
				ChangeState(LE_AURORA_STATE_NONE, true, LE_WOW_CONNECTION_STATE_NONE, false);
			else
				ChangeState(LE_AURORA_STATE_CONNECTED, false, LE_WOW_CONNECTION_STATE_NONE, true);
			end
			STUBFRAME:SetScript("OnUpdate", nil);
		elseif ( state == LE_AURORA_STATE_ENTER_EXTRA_AUTH ) then
			StubFrame_CheckPassword();
		end
	end
end

function StubFrame_CheckPassword()
	if ( password == DEBUG_PASSWORD ) then
		ChangeState(LE_AURORA_STATE_CONNECTED, false, LE_WOW_CONNECTION_STATE_CONNECTING, true);
		STUBFRAME.wait = 0;
		STUBFRAME:SetScript("OnUpdate", StubFrame_OnUpdateLogin);
	else
		ChangeState(LE_AURORA_STATE_NONE, false, LE_WOW_CONNECTION_STATE_NONE, false, 104);
		GlueParent_OnEvent(GlueParent, "LOGIN_FAILED");
	end
end

function StubFrame_OnUpdateRealmChange(self, elapsed)
	STUBFRAME.wait = STUBFRAME.wait - elapsed;
	if ( STUBFRAME.wait < 0 ) then
		if ( WOW_STATE == LE_WOW_CONNECTION_STATE_CONNECTING ) then
			ChangeState(BNET_STATE, CONNECTED_TO_WOW, LE_WOW_CONNECTION_STATE_CONNECTING2, HAS_REALM_LIST);
		elseif ( WOW_STATE == LE_WOW_CONNECTION_STATE_CONNECTING2 and STUBFRAME.wait < -1 ) then
			ChangeState(LE_AURORA_STATE_NONE, true, LE_WOW_CONNECTION_STATE_NONE, false);
			STUBFRAME:SetScript("OnUpdate", nil);
		end
	end
end

function C_LoginStubs.Login(username, passwordEditBox)
	if ( BNET_STATE == LE_AURORA_STATE_NONE ) then
		if ( passwordEditBox ) then
			password = passwordEditBox:GetText();
		end
		ChangeState(LE_AURORA_STATE_CONNECTING, false, LE_WOW_CONNECTION_STATE_NONE, false);
		STUBFRAME.wait = 1;
		STUBFRAME:SetScript("OnUpdate", StubFrame_OnUpdateLogin);
	end
end

function C_LoginStubs.GetState()
	return BNET_STATE, CONNECTED_TO_WOW, WOW_STATE, HAS_REALM_LIST;
end

function C_LoginStubs.CancelLogin()
	if ( CONNECTED_TO_WOW ) then
		ChangeState(BNET_STATE, CONNECTED_TO_WOW, LE_WOW_CONNECTION_STATE_NONE, HAS_REALM_LIST);
	else
		ChangeState(LE_AURORA_STATE_NONE, false, LE_WOW_CONNECTION_STATE_NONE, HAS_REALM_LIST);
	end
	STUBFRAME:SetScript("OnUpdate", nil);
end

function C_LoginStubs.GetLastError()
	return LAST_ERROR;
end

function C_LoginStubs.GetExtraAuthInfo()
	return LE_AUTH_AUTHENTICATOR;
end

function C_LoginStubs.SubmitExtraAuthInfo(info)
	StubFrame_CheckPassword();
end

local OldDisconnectFromServer = DisconnectFromServer;
function DisconnectFromServer()
	OldDisconnectFromServer();
	ChangeState(LE_AURORA_STATE_NONE, false, LE_WOW_CONNECTION_STATE_NONE, false);
end

-- === DEBUG/OVERRIDE ===

if ( GLUESCREEN_DEBUG ) then

	function GetRealmCategories()
		return "Development", "Test";
	end

	function GetNumRealms(category)
		if ( category == 1 ) then
			return 2;
		else
			return 1;
		end
	end

	function GetRealmInfo(category, index)
		local selected = not REALM or (REALM == index)
		if ( category == 1 and index == 1 ) then
			return "Khaz Modan", 2, false, false, selected, false, false, 0, false, 7, 0, 0, 20391, 0;
		elseif ( category == 1 and index == 2 ) then
			return "Lightbringer", 0, false, false, selected, false, false, -1, false, 7, 0, 0, 20391, 0;
		elseif ( category == 2 and index == 1 ) then	
			return "Moonguard", 0, true, true, false, true, false, -1, false, 7, 0, 0, 19987, 1;
		else
			return nil, 0, false, false, false, false, false, 0, false, 0, 0, 0, 0, 0;
		end
	end

	function GetNumCharacters()
		if ( REALM == 1 ) then
			return 2;
		else
			return 0;
		end
	end
	
	function GetCharacterInfo(index)
		if ( REALM == 1 ) then
			if ( index == 1 ) then
				return "Huntorc", "Orc", "Hunter", "HUNTER", 3, 100, "Tanaan Jungle", 2, false, false, false, false, false, "Player-10163-807F8870", 773, 0, 1, false, false, false;
			elseif ( index == 2 ) then
				return "Gachi", "Night Elf", "Rogue", "ROGUE", 4, 100, nil, 2, false, false, false, false, false, "Player-10163-807F88F8", 202, 164, 1, false, false, false;
			end
		else
			
		end
	end
	
	function GetServerName()
		if ( REALM == 1 ) then
			return "Khaz Modan", false, false;
		elseif ( REALM == 2 ) then
			return "Lightbringer", false, false;
		end
	end
	
	function IsConnectedToServer()
		return REALM_CONNECTED;
	end
	
	function RequestRealmList()
		ChangeState(BNET_STATE, CONNECTED_TO_WOW, LE_WOW_CONNECTION_STATE_NONE, true);
	end
	
	function GetCharacterListUpdate()
		CharacterSelect_OnEvent(CharacterSelect, "CHARACTER_LIST_UPDATE", GetNumCharacters());
	end
	
	function GetCharacterUndeleteStatus()
		return false;
	end
	
	function GetAccountExpansionLevel()
		return 5;
	end
	
	function GetExpansionLevel()
		return 5;
	end
	
	function IsLauncherLogin()
		return true;
	end
	
	function GetSavedAccountName()
		return "Thrall";
	end

	function CanLogIn()
		return true;
	end

	_SetLauncherLoginAutoAttempted = false;
	function SetLauncherLoginAutoAttempted()
		_SetLauncherLoginAutoAttempted = true;
	end
	
	function IsLauncherLoginAutoAttempted()
		return _SetLauncherLoginAutoAttempted;
	end
	
	function IsLauncherLogin()
		return isLauncherLogin and not _SetLauncherLoginAutoAttempted;
	end
	
	function AttemptFastLogin()
		password = DEBUG_PASSWORD;
		C_LoginStubs.Login(nil, nil);
	end
	
	function C_RealmList.GetAvailableCategories()
		return { "Development", "Test" };
	end
	
	function C_RealmList.GetCategoryInfo(category)
		if ( category == "Development" ) then
			return "Development", false, false;
		elseif ( category == "Test" ) then
			return "Test", false, false;
		end	
	end

	function C_RealmList.GetRealmsInCategory(category)
		if ( category == "Development" ) then
			return { "Khaz Modan", "Lightbringer" };
		elseif ( category == "Test" ) then
			return { "Moonguard" };
		end
	end
	
	function C_RealmList.GetRealmInfo(realm)
		local selected = not REALM or (REALM == realm)
		if ( realm == "Khaz Modan" ) then
			return "Khaz Modan", 2, false, false, false, "ONLINE", 7, 0, 0, 20391, 1001;
		elseif ( realm == "Lightbringer" ) then
			return "Lightbringer", 0, false, false, false, "ONLINE", 7, 0, 0, 20391, 1002;
		elseif ( realm == "Moonguard" ) then	
			return "Moonguard", 0, false, true, true, "OFFLINE", 7, 0, 0, 19987, 1003;
		else
			return nil, 0, false, false, false, false, false, 0, false, 0, 0, 0, 0, 0;
		end
	end
	
	function C_RealmList.ConnectToRealm(realm)
		REALM = realm;
		REALM_CONNECTED = true;
		ChangeState(BNET_STATE, CONNECTED_TO_WOW, LE_WOW_CONNECTION_STATE_CONNECTING, true);
		STUBFRAME.wait = 1;
		STUBFRAME:SetScript("OnUpdate", StubFrame_OnUpdateRealmChange);
	end	
end
