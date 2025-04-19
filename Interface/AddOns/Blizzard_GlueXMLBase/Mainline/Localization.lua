-- luacheck: ignore 111 (setting non-standard global variable)

local l10nTable = {
	deDE = {},
	enGB = {
		localize = function()
			-- Put all locale specific string adjustments here
			ACCOUNT_CREATE_URL = "http://signup.wow-europe.com/";
			AUTH_ALREADY_ONLINE = "This character is still logged on. If this character is not logged in and you continue to experience this issue for more than 15 minutes, please contact our Technical Support Department at http://www.wow-europe.com/en/support/";
			AUTH_BANNED = "This account has been banned for violating the Terms of Use Agreement - http://www.wow-europe.com/en/legal. Please contact our GM department at http://www.wow-europe.com/en/support/ for more information.";
			AUTH_BANNED_URL = "http://www.wow-europe.com/en/legal";
			AUTH_DB_BUSY = "This session has timed out. Please try again at a later time or check the status of our WoW realms at http://www.wow-europe.com/en/serverstatus";
			AUTH_DB_BUSY_URL = "http://www.wow-europe.com/en/serverstatus";
			AUTH_NO_TIME = "Your World of Warcraft subscription has expired. You will need to reactivate your account. To do so, please visit http://signup.wow-europe.com/ for more information.";
			AUTH_NO_TIME_URL = "http://enGB.nydus.battle.net/WOW/enGB/client/manage_account";
			AUTH_REJECT = "Login unavailable - Please contact Technical Support at http://www.wow-europe.com/en/support/";
			AUTH_SUSPENDED = "This account has been temporarily suspended for violating the Terms of Use Agreement - http://www.wow-europe.com/en/legal. Please contact our GM department at http://www.wow-europe.com/en/support/ for more information.";
			AUTH_SUSPENDED_URL = "http://www.wow-europe.com/en/legal";
			CATEGORY_DESCRIPTION = "Realm Language";
			CATEGORY_DESCRIPTION_TEXT = "The realm language is the language used by players and Game Masters in that realm. Players should use that language when they speak in general channels.";
			CHAR_CREATE_PVP_TEAMS_VIOLATION = "You cannot have both a Horde and an Alliance character on the same PvP realm";
			CHOOSE_LOCATION = "Choose your language:";
			CHOOSE_LOCATION_DESCRIPTION = "(choose the language in which you will speak while in-game and receive customer support if needed)";
			CLIENT_ACCOUNT_MISMATCH = "<html><body><p>Your account is authorized for the Burning Crusade expansion, but the computer you are playing on does not contain Burning Crusade data. To play on this machine with this account, you must install the Burning Crusade. Additional data is available at:<a href=\"http://www.wow-europe.com/en/burningcrusade/download\">www.wow-europe.com/en/burningcrusade/download/</a></p></body></html>";
			COMMUNITY_URL = "http://www.wow-europe.com/en";
			GAMETYPE_PVE_TEXT = "These realms allow you focus on adventuring and fighting monsters. Other players can't attack you unless you decide to permit it by enabling yourself for PvP combat.";
			LOAD_NEW = "Recommended";
			LOGIN_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Our login system has detected a change in your access pattern. In order to protect the account, we require you to verify your identity and change your password via our web site.|nFor more information, please visit|n<a href='https://eu.battle.net/account/support/password-reset.html'>https://eu.battle.net/account/support/password-reset.html</a></p></body></html>";
			LOGIN_BADVERSION = "<html><body><p align=\"CENTER\">Unable to validate game version.  This may be caused by file corruption or the interference of another program.  Please visit <a href=\"http://eu.blizzard.com/support/article.xml?articleId=19654\">http://eu.blizzard.com/support/article.xml?articleId=19654</a> for more information and possible solutions to this issue.</p></body></html>";
			LOGIN_BANNED = "<html><body><p align=\"CENTER\">This World of Warcraft account has been closed and is no longer available for use.  Please go to <a href=\"http://www.wow-europe.com/en/misc/banned.html\">http://www.wow-europe.com/en/misc/banned.html</a> for further information.</p></body></html>";
			LOGIN_SUSPENDED = "This World of Warcraft account has been temporarily suspended.  Please go to http://www.wow-europe.com/en/misc/banned.html for further information.";
			LOGIN_UNKNOWN_ACCOUNT = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name and password.  If you need help in retrieving a lost or stolen password and account, see <a href=\"https://www.wow-europe.com/login-support/?locale=en_GB\">https://www.wow-europe.com/login-support</a> for more information.</p></body></html>";
			PVP_PARENTHESES = "PVP";
			REALM_DESCRIPTION_TEXT = "A realm is a discrete game world that exists only for the players within it. You can interact with all the players in your realm, but not with players in other realms. You cannot move your characters between realms. Realms are differentiated by language and play style.";
			REALM_LIST_REALM_NOT_FOUND = "The game server you have chosen is currently down. Use the Change Realm button to choose another Realm. Check http://www.wow-europe.com/en/serverstatus for current server status.";
			RESPONSE_FAILED_TO_CONNECT = "Failed to connect. Please be sure that your computer is currently connected to the internet, and that no security features on your system might be blocking traffic. See www.wow-europe.com/en/support for more information.";
			RP_PARENTHESES = "RP";
			RPPVP_PARENTHESES = "RPPVP";
			GAMETYPE_RPPVP_TEXT = "These PvP realms have strict naming conventions and behavior rules for players interested in immersing themselves as a character in a fantasy-based world.  They also focus on player combat; you are always at risk of being attacked by opposing players except in starting areas and cities.";
			TECH_SUPPORT_URL = "http://www.wow-europe.com/en/support/";
			SCANDLL_URL_LAUNCHER_TXT = "http://eu.scan.worldofwarcraft.com/update/Launcher.txt";
			SCANDLL_URL_WIN32_SCAN_DLL = "http://eu.scan.worldofwarcraft.com/update/Scan.dll";
			SCANDLL_URL_WIN64_SCAN_DLL = "http://eu.scan.worldofwarcraft.com/update/Scan-64.dll";
			SCANDLL_URL_HACK = "http://eu.blizzard.com/support/article.xml?articleId=19633";
			SCANDLL_URL_TROJAN = "http://eu.blizzard.com/support/article.xml?articleId=19644";
			COMMUNITY_SITE = "Official Site";
			AUTH_PARENTAL_CONTROL_URL = "http://www.wow-europe.com/en/account/";
			REALM_TYPE_TOURNAMENT_WARNING = "This account is currently not flagged to participate in the tournament realms.\n\nFor more information regarding the World of Warcraft Arena Tournament, please visit: www.wow-europe.com.";
			REALM_HELP_FRAME_URL = "<a href=\"http://www.wow-europe.com\">www.wow-europe.com</a>";
			SERVER_ALERT_URL = "http://status.wow-europe.com/en/alert";
			SERVER_ALERT_BETA_URL = "http://beta.wow-europe.com/en/alert";
			LOGIN_GAME_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Access to your account has been temporarily disabled. Please contact support for more information at: <a href=\"https://www.wow-europe.com/account/account-error.html\">https://www.wow-europe.com/account/account-error.html</a></p></body></html>";
			LOGIN_BAD_SERVER_PROOF = "<html><body><p align=\"CENTER\">You are connecting to an invalid game server. Please contact Technical Support for assistance at: <a href=\"http://eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2088\">http://eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2088</a></p></body></html>";
			LOGIN_FAILED = "<html><body><p align=\"CENTER\">Unable to connect. Please try again later. If the problem persists, please contact technical support at: <a href=\"http://eu.blizzard.com/support/article.xml?locale=en_GB&amp;articleId=19432&amp;parentCategoryId&amp;pageNumber=1&amp;categoryId=2091\">http://eu.blizzard.com/support/article.xml?locale=en_GB&amp;articleId=19432&amp;parentCategoryId&amp;pageNumber=1&amp;categoryId=2091</a></p></body></html>";
			LOGIN_NOTIME = "<html><body><p align=\"CENTER\">You have used up your prepaid time for this account. Please visit <a href=\"http://www.wow-europe.com/account\">www.wow-europe.com/account</a> to purchase more to continue playing.</p></body></html>";
			LOGIN_SUSPENDED = "<html><body><p align=\"CENTER\">This World of Warcraft account has been temporarily suspended. Please go to <a href=\"http://www.wow-europe.com/en/misc/banned.html\">http://www.wow-europe.com/en/misc/banned.html</a> for further information.</p></body></html>";
			AUTH_PARENTAL_CONTROL_URL = "https://www.wow-europe.com/en/account/";
			LOGIN_UNKNOWN_ACCOUNT_PIN = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name, password, and PIN.  If you need help in retrieving a lost or stolen password, account, or PIN see <a href=\"https://www.wow-europe.com/login-support/?locale=en_GB\">https://www.wow-europe.com/login-support</a> for more information.</p></body></html>";
			CLIENT_ACCOUNT_MISMATCH_BC = "<html><body><p>Your account is authorized for the Burning Crusade expansion, but the computer you are playing on does not contain Burning Crusade data. To play on this machine with this account, you must install the Burning Crusade. Additional data is available at:<a href=\"http://www.wow-europe.com/en/burningcrusade/download\">http://www.wow-europe.com/en/burningcrusade/download/</a></p></body></html>";
			ACCOUNT_MESSAGE_HEADERS_URL = "http://support.wow-europe.com/accountmessaging/getMessageHeaders.xml";
			ACCOUNT_MESSAGE_BODY_URL = "http://support.wow-europe.com/accountmessaging/getMessageBody.xml";
			LATEST_TOS_URL = "http://launcher.wow-europe.com/en/tos.htm";
			LATEST_EULA_URL = "http://launcher.wow-europe.com/en/eula.htm";
			LATEST_TERMINATION_WITHOUT_NOTICE_URL = "http://launcher.wow-europe.com/en/legal/notice.htm";
			ACCOUNT_MESSAGE_BODY_NO_READ_URL = "http://support.wow-europe.com/accountmessaging/getMessageBodyUnread.xml";
			ACCOUNT_MESSAGE_READ_URL = "http://support.wow-europe.com/accountmessaging/markMessageAsRead.xml";
			LATEST_AGREEMENTS_URL = "http://launcher.wow-europe.com/en/legal/agreements.mpq";
			LATEST_AGREEMENTS_BETA_URL = "http://launcher.wow-europe.com/en/legal/beta/agreements.mpq";
			CLIENT_TRIAL = "<html><body><p>Your account is a full retail account, and is not compatible with the World of Warcraft Trial version. Please install the retail version of World of Warcraft. If you need more help, see <a href=\"http://www.wow-europe.com/en/burningcrusade/download/index.html\">www.wow-europe.com/en/burningcrusade/download/index.html </a></p></body></html>";
			REALM_HELP_FRAME_URL = "<a href=\"http://www.wow-europe.com/en\">www.wow-europe.com</a>";
			LOGIN_EXPIRED = "<html><body><p align=\"CENTER\">Your game account subscription has expired. Please visit <a href=\"http://www.wow-europe.com/account\">www.wow-europe.com/account</a> to purchase. more time.</p></body></html>";
			LOGIN_TRIAL_EXPIRED = "<html><body><p align=\"CENTER\">Your trial subscription has expired. Please visit <a href=\"http://www.wow-europe.com/account\">www.wow-europe.com/account</a> to upgrade your account.</p></body></html>";
			LOGIN_AUTH_OUTAGE = "<html><body><p align=\"CENTER\">The login server is currently busy. Please try again later. If the problem persists, please contact Technical Support at: <a href=\"http://eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2088\">eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2088</a></p></body></html>";
			LOGIN_GAME_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Access to your account has been temporarily disabled. Please contact support for more information at: <a href=\"https://www.wow-europe.com/account/account-error.html\">www.wow-europe.com/account/account-error.html</a></p></body></html>";
			LOGIN_NO_BATTLENET_MANAGER = "<html><body><p align=\"CENTER\">There was an error loging in. Please try again later. If the problem persists, please contact Technical Support at: <a href=\"http://eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2100\">eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2100</a></p></body></html>";
			LOGIN_NO_BATTLENET_APPLICATION = "<html><body><p align=\"CENTER\">There was an error loging in. Please try again later. If the problem persists, please contact Technical Support at: <a href=\"http://eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2100\">eu.blizzard.com/support/index.xml?gameId=11&amp;rootCategoryId=2100</a></p></body></html>";
			LOGIN_MALFORMED_ACCOUNT_NAME = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name and password.  If you need help in retrieving a lost or stolen password and account, see <a href=\"http://www.wow-europe.com\">www.wow-europe.com</a> for more information.</p></body></html>";
			LOGIN_CHARGEBACK = "<html><body><p align=\"CENTER\">This World of Warcraft account has been temporary closed due to a chargeback on its subscription.  Please refer to this <a href=\"http://eu.blizzard.com/support/article/chargeback\">http://eu.blizzard.com/support/article/chargeback</a> for further information.</p></body></html>";
			LOGIN_IGR_WITHOUT_BNET = "<html><body><p align=\"CENTER\">In order to log in to World of Warcraft using IGR time, this World of Warcraft account must first be merged with a Battle.net account. Please visit <a href=\"http://eu.battle.net/\">http://eu.battle.net/</a> to merge this account.</p></body></html>";
			LOGIN_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Due to suspicious activity, this account is locked.|nA message has been sent to this account's email address containing details on how to resolve this issue.|nVisit <a href=\"http://eu.battle.net/wow/account-locked/en-gb\">eu.battle.net/wow/account-locked/en-gb</a> for more information.</p></body></html>";
			CLIENT_ACCOUNT_MISMATCH_LK = "<html><body><p>Your account is authorized for the Wrath of the Lich King expansion, but the computer you are playing on does not contain Wrath of the Lich King data. To play on this machine with this account, you must install the Wrath of the Lich King. Additional data is available at:<a href=\"http://www.wow-europe.com/en/lichking/download\">www.wow-europe.com/en/lichking/download/</a></p></body></html>";
			LOGIN_CONVERSION_REQUIRED = "<html><body><p align=\"CENTER\">This account needs to be converted to a Battle.net account. Please <a href=\"https://eu.battle.net/account/creation/landing.xml\">Click Here</a>|nor go to:|n<a href=\"https://eu.battle.net/account/creation/landing.xml\">https://eu.battle.net/account/creation/landing.xml</a>|nto begin the conversion.</p></body></html>";
			CLIENT_TRIAL = "<html><body><p>Your account is a full retail account, and is not compatible with the World of Warcraft Trial version. Please install the retail version of World of Warcraft. If you need more help, see <a href=\"http://www.wow-europe.com/en/info/faq/trial.html\">www.wow-europe.com/en/info/faq/trial.html</a></p></body></html>";
			DRIVER_BLACKLISTED = "<html><body><p align=\"CENTER\">Your device driver is not compatiple. Please see <a href=\"http://nydus.battle.net/WoW/enGB/launcher/driver-unsupported\">http://nydus.battle.net/WoW/enGB/launcher/driver-unsupported</a> for more information.</p></body></html>";
			DRIVER_OUTOFDATE = "<html><body><p align=\"CENTER\">Your device driver is out of date. Please see <a href=\"http://nydus.battle.net/WoW/enGB/launcher/driverupdates\">http://nydus.battle.net/WoW/enGB/launcher/driverupdates</a> for more information.</p></body></html>";
			DEVICE_BLACKLISTED = "<html><body><p align=\"CENTER\">Your video device is not compatiple. Please see <a href=\"http://nydus.battle.net/WoW/enGB/launcher/video-unsupported\">http://nydus.battle.net/WoW/enGB/launcher/video-unsupported</a> for more information.</p></body></html>";
			SYSTEM_INCOMPATIBLE_SSE = "<html><body><p align=\"CENTER\">This system will not be supported in future versions of World of Warcraft. Please see <a href=\"http://nydus.battle.net/WoW/enGB/launcher/sse1-unsupported\">http://nydus.battle.net/WoW/enGB/launcher/sse1-unsupported</a> for more information.</p></body></html>";
			FIXEDFUNCTION_UNSUPPORTED = "<html><body><p align=\"CENTER\">This video card will not be supported in future versions of World of Warcraft. Please see <a href=\"http://nydus.battle.net/WoW/enGB/launcher/fixedfunction-unsupported\">http://nydus.battle.net/WoW/enGB/launcher/fixedfunction-unsupported</a> for more information.</p></body></html>";
			VISITABLE_URL3 = "http://enGB.nydus.battle.net/wow/enGB/client/item-restoration";
			VISITABLE_URL4 = "http://enGB.nydus.battle.net/wow/enGB/client/challenge/%d/%d";
			VISITABLE_URL6 = "https://eu.battle.net/support/en/ticket/submit?loc";
			VISITABLE_URL5 = "https://eu.battle.net/support/en/games/wow?loc";
			VISITABLE_URL7 = "https://eu.battle.net/support/en/ticket/status?loc";
			VISITABLE_URL11 = "https://nydus.battle.net/WoW/enGB/client/add-payment?targetRegion=EU";
			VISITABLE_URL12 = "https://nydus.battle.net/WoW/enGB/client/support/recruit-a-friend-basics?targetRegion=EU";
			VISITABLE_URL22 = "http://nydus.battle.net/WoW/enGB/client/subscription-setup?targetRegion=EU";
			VISITABLE_URL50 = "https://%s.battle.net/support/en/help/home";
        end,
	},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {
		localize = function()
			VISITABLE_URL50 = "https://%s.battle.net/support/pt/help/home";
        end,
	},
	ptPT = {
		localize = function()
			ACCOUNT_CREATE_URL = "http://signup.wow-europe.com";
			AUTH_ALREADY_ONLINE = "O personagem ainda está conectado. Se o personagem não estiver conectado e ainda assim o problema persistir por mais de 15 minutos, entre em contato com o Departamento de Suporte Técnico em http://eu.blizzard.com/support/index.xml?locale=pt_PT";
			AUTH_BANNED = "Esta conta foi banida por violação ao Contrato de Termos de Uso - http://eu.blizzard.com/pt-pt/company/legal/ . Entre em contato com o departamento de MJ em http://eu.blizzard.com/support/index.xml?locale=pt_PT para obter mais informações.";
			AUTH_BANNED_URL = "http://eu.blizzard.com/pt-pt/company/legal/";
			AUTH_DB_BUSY = "Essa sessão expirou. Tente novamente mais tarde ou consulte o status dos servidores do WoW em http://eu.battle.net/wow/pt/status";
			AUTH_DB_BUSY_URL = "http://eu.battle.net/wow/pt/status";
			AUTH_NO_TIME = "Sua assinatura do World of Warcraft expirou. É necessário reativar a conta. Para isso, acesse http://signup.wow-europe.com e obtenha mais informações.";
			AUTH_NO_TIME_URL = "http://ptPT.nydus.battle.net/WOW/ptPT/client/manage_account";
			AUTH_REJECT = "Login indisponível - Entre em contato com o Suporte Técnico em http://eu.blizzard.com/support/index.xml?locale=pt_PT";
			AUTH_SUSPENDED = "Esta conta foi temporariamente suspensa por violação ao Contrato de Termos de Uso - http://eu.blizzard.com/pt-pt/company/legal/ . Entre em contato com o departamento de MJ em http://eu.blizzard.com/support/index.xml?locale=pt_PT para obter mais informações.";
			AUTH_SUSPENDED_URL = "http://eu.blizzard.com/pt-pt/company/legal/";
			CATEGORY_DESCRIPTION = "Categoria do Reino";
			CATEGORY_DESCRIPTION_TEXT = "Categorias de reinos referem-se à região geográfica. Os jogadores devem escolher o reino mais próximo a eles. Isso garante a menor latência e proporciona a melhor experiência de jogo possível.";
			CHAR_CREATE_PVP_TEAMS_VIOLATION = "Não é possível ter um personagem da Horda e outro da Aliança no mesmo servidor JxJ";
			CHOOSE_LOCATION = "Escolha um local de preferência:";
			CHOOSE_LOCATION_DESCRIPTION = "(para obter o resultado ideal, escolha uma região perto de você)";
			CLIENT_ACCOUNT_MISMATCH_BC = "<html><body><p>Sua conta foi autorizada para a expansão Wrath of the Lich King, mas o computador em que você está jogando não contém os dados dessa expansão. Para jogar neste computador com esta conta, é preciso instalar a expansão Wrath of the Lich King. Mais informações disponíveis em <a href=\"https://eu.battle.net/account/download\">https://eu.battle.net/account/download/</a></p></body></html>";
			COMMUNITY_URL = "http://eu.battle.net/wow/pt/";
			GAMETYPE_PVE_TEXT = "Estes reinos permitem que você se concentre em aventuras e em combates contra monstros, além de permitir que enfrente outros jogadores à vontade.";
			LOAD_NEW = "Novo";
			LOGIN_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Nosso sistema de login detectou uma alteração no seu padrão de acesso. Para proteger a conta, pedimos que você confirme sua identidade por meio de uma mensagem enviada ao endereço de e-mail vinculado a esta conta.|nPara obter mais informações, acesse|n<a href='https://eu.battle.net/account/support/password-reset.html?locale=pt_PT'>https://us.battle.net/account/support/password-reset.html</a></p></body></html>";
			LOGIN_BADVERSION = "<html><body><p align=\"CENTER\">Não foi possível validar a versão do jogo. A causa pode ser um arquivo danificado ou a interferência de outro programa. Visite <a href=\"http://eu.blizzard.com/support/article.xml?articleId=19654\">http://eu.blizzard.com/support/article.xml?articleId=19654</a> para obter mais informações e possíveis soluções para o problema.</p></body></html>";
			LOGIN_BANNED = "<html><body><p align=\"CENTER\">Esta conta do World of Warcraft foi encerrada e não está mais disponível para uso. Acesse <a href=\"http://eu.blizzard.com/support/article.xml?tag=banned\">http://eu.blizzard.com/support/article.xml?tag=banned</a> para obter mais informações.</p></body></html>";
			LOGIN_SUSPENDED = "<html><body><p align=\"CENTER\">Esta conta do World of Warcraft foi temporariamente suspensa. Acesse <a href=\"http://eu.blizzard.com/support/article.xml?tag=banned\">http://eu.blizzard.com/support/article.xml?tag=banned</a> para obter mais informações.</p></body></html>";
			LOGIN_UNKNOWN_ACCOUNT = "<html><body><p align=\"CENTER\">As informações que você inseriu não são válidas. Verifique se o nome da conta e a senha estão corretos. Se precisar de ajuda para recuperar uma senha ou conta perdida ou furtada, consulte <a href=\"https://eu.battle.net/account/support/password-reset.html\">https://eu.battle.net/account/support/password-reset.html</a> para obter mais informações.</p></body></html>";
			PVP_PARENTHESES = "(JxJ)";
			REALM_DESCRIPTION_TEXT = "Reinos são mundos do jogo independentes, que só existem para os jogadores que fazem parte dele. Você pode interagir com todos os jogadores do seu reino, mas não com jogadores de outros reinos. Não é possível transferir personagens de um reino para outro. Os reinos distinguem-se pelo local e estilo de jogo.";
			REALM_LIST_REALM_NOT_FOUND = "O servidor de jogo escolhido está indisponível. Use o botão Mudar de Reino para escolher outro Reino. Consulte http://eu.battle.net/wow/pt/status para obter o status atual dos servidores.";
			RESPONSE_FAILED_TO_CONNECT = "Falha na conexão. Verifique se o computador está conectado à Internet e se os recursos de segurança do sistema não estão bloqueando o tráfego. Consulte http://eu.blizzard.com/support/index.xml?locale=pt_PT para obter mais informações.";
			RP_PARENTHESES = "(RP)";
			RPPVP_PARENTHESES = "(RPJxJ)";
			GAMETYPE_RPPVP_TEXT = "Estes reinos têm convenções de nomenclatura e regras de comportamento rigorosos para jogadores interessados em mergulhar como personagens em um mundo de fantasia. Eles também são voltados para o combate entre jogadores; o risco de ser atacado por jogadores inimigos é constante, exceto nas áreas e cidades iniciais.";
			TECH_SUPPORT_URL = "http://eu.blizzard.com/support/index.xml?locale=pt_PT";
			SCANDLL_URL_LAUNCHER_TXT = "http://eu.scan.worldofwarcraft.com/update/Launcher.txt";
			SCANDLL_URL_WIN32_SCAN_DLL = "http://eu.scan.worldofwarcraft.com/update/Scan.dll";
			SCANDLL_URL_WIN64_SCAN_DLL = "http://eu.scan.worldofwarcraft.com/update/Scan-64.dll";
			SCANDLL_URL_HACK = "http://eu.blizzard.com/support/article.xml?articleId=19633";
			SCANDLL_URL_TROJAN = "http://eu.blizzard.com/support/article.xml?articleId=19644";
			COMMUNITY_SITE = "Comunidade";
			AUTH_PARENTAL_CONTROL_URL = "http://eu.battle.net/account/";
			REALM_TYPE_TOURNAMENT_WARNING = "Esta conta não está sinalizada para participar de reinos de torneio.\n\nPara obter mais informações sobre o Torneio de Arena do World of Warcraft, visite: http://eu.battle.net/wow/pt/game/.";
			REALM_HELP_FRAME_URL = "<a href=\"http://eu.battle.net/wow/pt\">http://eu.battle.net/wow/</a>";
			SERVER_ALERT_URL = "http://status.wow-europe.com/pt/alert";
			SERVER_ALERT_BETA_URL = "http://beta.wow-europe.com/pt/alert";
			LOGIN_GAME_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">O acesso à sua conta foi temporariamente desativado. Entre em contato com o suporte para obter mais informações em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support/</a></p></body></html>";
			LOGIN_BAD_SERVER_PROOF = "<html><body><p align=\"CENTER\">Você está se conectando a um servidor inválido de jogo. Entre em contato com o Suporte Técnico para obter ajuda em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support/</a></p></body></html>";
			LOGIN_FAILED = "<html><body><p align=\"CENTER\">Não foi possível conectar. Tente novamente mais tarde. Se o problema persistir, entre em contato com o suporte técnico em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support/</a></p></body></html>";
			LOGIN_NOTIME = "<html><body><p align=\"CENTER\">Você já usou todo o tempo pré-pago desta conta. Visite <a href=\"http://eu.battle.net/account\">http://eu.battle.net/account</a> para adquirir mais tempo de jogo.</p></body></html>";
			LOGIN_SUSPENDED = "<html><body><p align=\"CENTER\">Esta conta do World of Warcraft foi temporariamente suspensa. Acesse <a href=\"http://eu.blizzard.com/support/article.xml?tag=banned\">http://eu.blizzard.com/support/article.xml?tag=banned</a> para obter mais informações.</p></body></html>";
			AUTH_PARENTAL_CONTROL_URL = "http://eu.battle.net/account/";
			LOGIN_UNKNOWN_ACCOUNT_PIN = "<html><body><p align=\"CENTER\">As informações que você inseriu não são válidas. Verifique se o nome da conta, a senha e o PIN estão corretos. Se precisar de ajuda para recuperar uma senha, conta ou PIN perdidos ou furtados, consulte <a href=\"https://eu.battle.net/account/support/password-reset.html?locale=pt_PT\">https://eu.battle.net/account/support/password-reset.html</a> para obter mais informações.</p></body></html>";
			CLIENT_ACCOUNT_MISMATCH_BC = "<html><body><p>Sua conta foi autorizada para a expansão Burning Crusade, mas o computador em que você está jogando não contém os dados dessa expansão. Para jogar neste computador com esta conta, você precisa instalar a expansão Burning Crusade. Mais informações disponíveis em <a href=\"https://eu.battle.net/account/download\">https://eu.battle.net/account/download/</a></p></body></html>";
			ACCOUNT_MESSAGE_HEADERS_URL = "http://support.wow-europe.com/accountmessaging/getMessageHeaders.xml";
			ACCOUNT_MESSAGE_BODY_URL = "http://support.wow-europe.com/accountmessaging/getMessageBody.xml";
			LATEST_TOS_URL = "http://launcher.wow-europe.com/pt/tos.htm";
			LATEST_EULA_URL = "http://launcher.wow-europe.com/pt/eula.htm";
			LATEST_TERMINATION_WITHOUT_NOTICE_URL = "http://launcher.wow-europe.com/pt/legal/notice.htm";
			ACCOUNT_MESSAGE_BODY_NO_READ_URL = "http://support.wow-europe.com/accountmessaging/getMessageBodyUnread.xml";
			ACCOUNT_MESSAGE_READ_URL = "http://support.wow-europe.com/accountmessaging/markMessageAsRead.xml";
			LATEST_AGREEMENTS_URL = "http://launcher.wow-europe.com/pt/legal/agreements.mpq";
			LATEST_AGREEMENTS_BETA_URL = "http://launcher.wow-europe.com/pt/legal/beta/agreements.mpq";
			CLIENT_TRIAL = "<html><body><p>Sua conta é de uma versão completa de revenda e não é compatível com a versão de avaliação do World of Warcraft. Instale a versão de revenda. Se precisar de mais ajuda, consulte <a href=\"https://eu.battle.net/account/download/\">https://eu.battle.net/account/download/</a></p></body></html>";
			REALM_HELP_FRAME_URL = "<a href=\"http://eu.battle.net/wow/pt\">http://eu.battle.net/wow/</a>";
			LOGIN_EXPIRED = "<html><body><p align=\"CENTER\">A assinatura da sua conta de jogo expirou. Visite <a href=\"https://eu.battle.net/account\">https://eu.battle.net/account/</a> para adquirir mais tempo.</p></body></html>";
			LOGIN_TRIAL_EXPIRED = "<html><body><p align=\"CENTER\">Sua assinatura de avaliação expirou. Visite <a href=\"https://eu.battle.net/account\">https://eu.battle.net/account/</a> para atualizar a conta.</p></body></html>";
			LOGIN_AUTH_OUTAGE = "<html><body><p align=\"CENTER\">O servidor de login está ocupado. Tente novamente mais tarde. Se o problema persistir, entre em contato com o Suporte Técnico em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support/</a></p></body></html>";
			LOGIN_GAME_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">O acesso à sua conta foi temporariamente desativado. Entre em contato com o suporte para obter mais informações em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support/</a></p></body></html>";
			LOGIN_NO_BATTLENET_MANAGER = "<html><body><p align=\"CENTER\">Houve um erro ao conectar. Tente novamente mais tarde. Se o problema persistir, entre em contato com o Suporte Técnico em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support</a></p></body></html>";
			LOGIN_NO_BATTLENET_APPLICATION = "<html><body><p align=\"CENTER\">Houve um erro ao conectar. Tente novamente mais tarde. Se o problema persistir, entre em contato com o Suporte Técnico em <a href=\"http://eu.blizzard.com/support/index.xml?locale=pt_PT\">http://eu.blizzard.com/support</a></p></body></html>";
			LOGIN_MALFORMED_ACCOUNT_NAME = "<html><body><p align=\"CENTER\">As informações que você inseriu não são válidas. Verifique se o nome da conta e a senha estão corretos. Se precisar de ajuda para recuperar uma senha ou conta perdida ou furtada, consulte <a href=\"https://eu.battle.net/account/support/password-reset.html?locale=pt_PT\">https://eu.battle.net/account/support/password-reset.html</a> para obter mais informações.</p></body></html>";
			LOGIN_CHARGEBACK = "<html><body><p align=\"CENTER\">Esta conta do World of Warcraft foi temporariamente encerrada devido a um estorno da assinatura. Consulte <a href=\"http://eu.blizzard.com/support/article/chargeback\">http://eu.blizzard.com/support/article/chargeback</a> para obter mais informações.</p></body></html>";
			LOGIN_IGR_WITHOUT_BNET = "<html><body><p align=\"CENTER\">Para que você possa se conectar ao World of Warcraft usando o tempo de IGR, primeiro é necessário mesclar esta conta do World of Warcraft com uma conta do Battle.net. Acesse <a href=\"http://eu.battle.net/\">http://eu.battle.net/</a> para mesclar a conta.</p></body></html>";
			LOGIN_ACCOUNT_LOCKED = "<html><body><p align=\"CENTER\">Nosso sistema de login detectou uma alteração no seu padrão de acesso. Para proteger a conta, pedimos que você confirme sua identidade por meio de uma mensagem enviada ao endereço de e-mail vinculado a esta conta.|nPara obter mais informações, acesse|n<a href='https://eu.battle.net/account/support/password-reset.html?locale=pt_PT'>https://eu.battle.net/account/support/password-reset.html</a></p></body></html>";
			CLIENT_ACCOUNT_MISMATCH_LK = "<html><body><p>Sua conta foi autorizada para a expansão Wrath of the Lich King, mas o computador em que você está jogando não contém os dados dessa expansão. Para jogar neste computador com esta conta, é preciso instalar a expansão Wrath of the Lich King. Mais informações disponíveis em <a href=\"https://eu.battle.net/account/download\">https://eu.battle.net/account/download/</a></p></body></html>";
			LOGIN_CONVERSION_REQUIRED = "<html><body><p align=\"CENTER\">Você precisa usar o nome de usuário e a senha da conta do Battle.net para se conectar. Para criar uma conta <a href=\"https://eu.battle.net/account/creation/landing.xml\">Clique aqui</a> ou acesse a página:|n<a href=\"https://eu.battle.net/account/creation/landing.xml\">https://eu.battle.net/account/creation/landing.xml</a>|npara iniciar a conversão.</p></body></html>";
			CLIENT_TRIAL = "<html><body><p>Sua conta é de uma versão completa de revenda e não é compatível com a versão de avaliação do World of Warcraft. Instale a versão de revenda. Se precisar de mais ajuda, consulte <a href=\"https://eu.battle.net/account/download\">https://eu.battle.net/account/download/</a></p></body></html>";
			DRIVER_BLACKLISTED = "<html><body><p align=\"CENTER\">O driver do seu dispositivo não é compatível. Consulte o endereço <a href=\"http://nydus.battle.net/WoW/ptPT/launcher/driver-unsupported\">http://nydus.battle.net/WoW/ptPT/launcher/driver-unsupported</a> para mais informações.</p></body></html>";
			DRIVER_OUTOFDATE = "<html><body><p align=\"CENTER\">O driver do seu dispositivo está desatualizado. Consulte o endereço <a href=\"http://nydus.battle.net/WoW/ptPT/launcher/driverupdates\">http://nydus.battle.net/WoW/ptPT/launcher/driverupdates</a> para mais informações.</p></body></html>";
			DEVICE_BLACKLISTED = "<html><body><p align=\"CENTER\">Seu dispositivo de vídeo não é compatível. Consulte o endereço <a href=\"http://nydus.battle.net/WoW/ptPT/launcher/video-unsupported\">http://nydus.battle.net/WoW/ptPT/launcher/video-unsupported</a> para mais informações.</p></body></html>";
			SYSTEM_INCOMPATIBLE_SSE = "<html><body><p align=\"CENTER\">Este sistema não será compatível com as versões futuras de World of Warcraft. Consulte o endereço <a href=\"http://nydus.battle.net/WoW/ptPT/launcher/sse1-unsupported\">http://nydus.battle.net/WoW/ptPT/launcher/sse1-unsupported</a> para mais informações.</p></body></html>";
			FIXEDFUNCTION_UNSUPPORTED = "<html><body><p align=\"CENTER\">Esta placa de vídeo não será compatível com as verões futuras de World of Warcraft. Consulte o endereço <a href=\"http://nydus.battle.net/WoW/ptPT/launcher/fixedfunction-unsupported\">http://nydus.battle.net/WoW/ptPT/launcher/fixedfunction-unsupported</a> para mais informações.</p></body></html>";
			VISITABLE_URL3 = "http://ptPT.nydus.battle.net/wow/ptPT/client/item-restoration";
			VISITABLE_URL4 = "http://ptPT.nydus.battle.net/wow/ptPT/client/challenge/%d/%d";
			VISITABLE_URL6 = "https://eu.battle.net/support/pt/ticket/submit?loc";
			VISITABLE_URL5 = "https://eu.battle.net/support/pt/games/wow?loc";
			VISITABLE_URL7 = "https://eu.battle.net/support/pt/ticket/status?loc";
			VISITABLE_URL11 = "https://nydus.battle.net/WoW/ptPT/client/add-payment?targetRegion=EU";
			VISITABLE_URL12 = "https://nydus.battle.net/WoW/ptPT/client/support/recruit-a-friend-basics?targetRegion=EU";
			VISITABLE_URL22 = "http://nydus.battle.net/WoW/ptPT/client/subscription-setup?targetRegion=EU";
			VISITABLE_URL50 = "https://%s.battle.net/support/pt/help/home";
        end,
	},
	ruRU = {},
	zhCN = {},
	zhTW = {},
};

SetupLocalization(l10nTable);
