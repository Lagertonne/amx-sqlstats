#include <amxmodx>
#include <string>
#include <tsstats>
#include <sqlx>

#define PLUGIN "SQL Test"
#define VERSION "0.1"
#define AUTHOR "lagertonne"

#define S_KILLS 0
#define S_DEATHS 1
#define S_HEADSHOTS 2
#define S_TEAMKILLS 3
#define S_SHOTS 4
#define S_HITS 5
#define S_DAMAGE 6

new Handle:g_SqlTuple
new Handle:g_SqlConnection
new g_Error[512]



public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("update_stats", "put_stats", ADMIN_SLAY, "<>")
        console_print(0, "SQL Test wurde geladen!")
	set_task(4.0, "put_stats", 0, "", 0, "b")
	db_init()
	db_execute("DELETE FROM players")
}

public plugin_end() {
	db_finish()
}

public db_execute( query[] ) {
	new Handle:sqlQuery
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, query)

	if ( !SQL_Execute(sqlQuery) ) {
		SQL_QueryError( sqlQuery, g_Error, 511)	
		server_print("error: %s ", g_Error)
		set_fail_state(g_Error)
	}

}
	

public db_init() {
	new Host[64],User[64],Pass[64],Db[64]
	
	Host = "127.0.0.1"
	User = "root"
	Pass = "my-secret-pw"
	Db = "stats"
	g_SqlTuple = SQL_MakeDbTuple(Host, User, Pass, Db)

	new ErrorCode
	g_SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,511)

	if (g_SqlConnection == Empty_Handle) {
        	server_print("error: %d | %s", ErrorCode, g_Error)
		set_fail_state(g_Error)
	}

        server_print("Connection handle: %d", g_SqlConnection)
}

public db_finish() {
	db_execute("DELETE FROM players")
	SQL_FreeHandle(g_SqlConnection)
}

public update_player(id) {
	new p_name[32]
	new p_team
	new p_id[4]
	new p_authId[32]
	new p_stats[8], p_bodyStats[8]
	new request[254]

	num_to_str(id, p_id, 3)
	p_team = get_user_team(id)

	get_user_name(id, p_name, 31)
	get_user_stats(id, p_stats, p_bodyStats)
	server_print("Name of p: ", p_name)
	
	format(request, 254, "INSERT INTO players (id, name, team) VALUES (%d, '%s', %d) ON DUPLICATE KEY UPDATE name='%s', team=%d", id, p_name, p_team, p_name, p_team)
	
	server_print(request)	
	db_execute(request)
}

public put_stats() {

	new request[512]
	for (new id=1; id<=get_playersnum(); id++) {
		new p_stats[8]
		new p_bodyStats[8]
		get_user_stats(id, p_stats, p_bodyStats)
		format(request, 512, 
				"INSERT INTO statistic (id, kills, deaths, headshots, teamkills, shots, hits, damage, rank) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d) ON DUPLICATE KEY UPDATE kills = VALUES(kills), deaths = VALUES(deaths), headshots = VALUES(headshots), teamkills = VALUES(teamkills), shots = VALUES(shots), hits = VALUES(hits), damage = VALUES(damage), rank = VALUES(rank)", id, p_stats[S_KILLS], p_stats[S_DEATHS], p_stats[S_HEADSHOTS], p_stats[S_TEAMKILLS], p_stats[S_SHOTS], p_stats[S_HITS], p_stats[S_DAMAGE], 0)
	
		server_print(request)
		db_execute(request)
	}
}

public client_putinserver(id) {
	server_print( "%d entered server!", id )
	update_player(id)
}

public client_infochanged(id) {
	server_print( "%d changed something!", id )
	update_player(id)
}

public client_disconnect(id) {
	new request[254]
	format(request, 254, "DELETE FROM players WHERE id=%d", id)
	db_execute( request )
}
