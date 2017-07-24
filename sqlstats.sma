#include <amxmodx>
#include <dbi>

#define PLUGIN "SQL Test"
#define VERSION "0.1"
#define AUTHOR "lagertonne"

new Sql:dbHandle

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
        console_print(0, "SQL Test wurde geladen!")
	
	db_init()
	db_finish()
}

public db_execute( query[] ) {
	new Result:res = dbi_query(dbHandle, query)

	if (res <= RESULT_FAILED) {
		new err[255]
		new errNum = dbi_error(dbHandle, err, 254)
		server_print("error: %s | %d", err, errNum)
	}
}
	

public db_init() {
	dbHandle = dbi_connect("127.0.0.1", "root", "my-secret-pw", "stats")
        if (dbHandle < SQL_OK) {
            new err[255]
            new errNum = dbi_error(dbHandle, err, 254)
            server_print("error: %s | %d", err, errNum)
        }

        server_print("Connection handle: %d", dbHandle)
}

public db_finish() {
	dbi_close(dbHandle)
}

public client_putinserver(id) {
	server_print( "%d entered server!", id )
	new pname[32]
	new pteam[32]
	get_user_name(id, pname, 32)
	get_user_team(id, pteam, 32)
	db_execute("INSERT INTO players (id, name, team) VALUES (id, %s, %d)
}
