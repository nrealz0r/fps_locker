#include amxmodx
#include fakemeta
#include hamsandwich
#include msgstocks
#include reapi
#pragma semicolon 1

public stock const PluginName[] = "FPS Locker";
public stock const PluginVersion[] = "1.1";
public stock const PluginAuthor[] = "_bekka.";
public stock const PluginDescription[] = "Adds the ability to lock fps for players.";

#define MAX_PLAYERS 32
#define FPS_VALUE 101 // Value you want to lock the fps to

#define FPS_VALUE_HUD 100 // Set Always -1 to the value you want to show on the HUD
#define REASON "set fps to 100" // Set Always -1 to the value you want to lock the fps to
#define MASSAGE "FPS is too !ghigh!y, please set it to !g100!y.." // Set Always -1 to the value you want to send in massage

new Float:LastCheck[MAX_PLAYERS + 1], Fps[MAX_PLAYERS + 1];
new Frames[MAX_PLAYERS + 1], Warnings[MAX_PLAYERS + 1];

public plugin_init()
{
    #if AMXX_VERSION_NUM == 190
    register_plugin(
        .plugin_name = PluginName,
        .version = PluginVersion,
        .author = PluginAuthor);
    #endif

    RegisterHam(Ham_Player_PreThink, "player", "OnPreThink");
}

public client_putinserver(id)
{
    Warnings[id] = 0;
    LastCheck[id] = 0.0;   
}

public OnPreThink(id)
{
    if (!is_user_connected(id)) return;

    if (LastCheck[id] <= get_gametime())
    {           
        Fps[id] = Frames[id];
        if (Fps[id] > FPS_VALUE)
        {
            if(++Warnings[id] > 3) 
            {
                set_task(3.0, "task_kick", id);
                send_msg(id, MASSAGE);
            }
        }
        Frames[id] = 0;       
        LastCheck[id] = get_gametime() + 1.0;   
    }
    Frames[id]++;
}

public task_kick(id)
{
    kick_user(id, REASON);
}

stock kick_user(id, szReason[])
{
    new iUserId = get_user_userid(id);
    server_cmd("kick #%d ^"%s^"", iUserId, szReason);
    return 1;
}

stock send_msg(id, szMassage[])
{
    UTIL_SayText(id, "!y[!gServer!y] !t'!g%s!t' !y%s", getUserName(id), szMassage);
    return 1;
}

stock getUserName(id) {
	new szName[128];
	get_user_name(id, szName, charsmax(szName));
	return szName;
}

stock UTIL_SayText(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
    
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!t", "^3");
    
	if(id) players[0] = id; else get_players(players, count, "ch");
    for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}