#include <amxmodx>
#include <dbi>
#include <string>
#include <tsstats>
#include <sqlx>

#define PLUGIN "SQL Test"
#define VERSION "0.1"
#define AUTHOR "lagertonne"

new Handle:g_SqlTuple
new Handle:g_SqlConnection
new g_Error[512]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
        console_print(0, "SQL Test wurde geladen!")
	db_init()
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
	get_stats(id, p_stats, p_bodyStats, p_authId, 32)
	server_print("Name of p: ", p_name)
	
	format(request, 254, "INSERT INTO players (id, name, team) VALUES (%d, '%s', %d) ON DUPLICATE KEY UPDATE name='%s', team=%d", id, p_name, p_team, p_name, p_team)
	
	server_print(request)	
	db_execute(request)
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
