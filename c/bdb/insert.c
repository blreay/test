//#include <sqlite3.h>
#include <dbsql.h>
#include <stdio.h>

/* callback for SQL query */
int callbackq(void *NotUsed, int argc, char **argv, char **azColName) { 
    NotUsed = 0; 
	int i=0;
    for (i = 0; i < argc; i++) { 
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    } 
    printf("\n"); 
    return 0;
}

int main(void) {
    
    sqlite3 *db;
    char *err_msg = 0;
    
    int rc = sqlite3_open("test.db", &db);
    
    if (rc != SQLITE_OK) {
        
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        
        return 1;
    }
    
	/* create table and insert data */
    char *sql = "DROP TABLE IF EXISTS Cars;" 
                "CREATE TABLE Cars(Id INT, Name TEXT, Price INT);" 
                "INSERT INTO Cars VALUES(1, 'Audi', 52642);" 
                "INSERT INTO Cars VALUES(2, 'Mercedes', 57127);" 
                "INSERT INTO Cars VALUES(3, 'Skoda', 9000);" 
                "INSERT INTO Cars VALUES(4, 'Volvo', 29000);" 
                "INSERT INTO Cars VALUES(5, 'Bentley', 350000);" 
                "INSERT INTO Cars VALUES(6, 'Citroen', 21000);" 
                "INSERT INTO Cars VALUES(7, 'Hummer', 41400);" 
                "INSERT INTO Cars VALUES(8, 'Volkswagen', 21600);";

    rc = sqlite3_exec(db, sql, 0, 0, &err_msg); 
    if (rc != SQLITE_OK ) { 
        fprintf(stderr, "SQL error: %s\n", err_msg); 
        sqlite3_free(err_msg);        
        sqlite3_close(db); 
        return 1;
    } 
    
	/* query data */
	char *sqlq = "SELECT * FROM Cars WHERE name='Skoda';"; 
    rc = sqlite3_exec(db, sqlq, callbackq, 0, &err_msg); 
    if (rc != SQLITE_OK ) { 
        fprintf(stderr, "Failed to select data\n");
        fprintf(stderr, "SQL error: %s\n", err_msg); 
        sqlite3_free(err_msg);
        sqlite3_close(db); 
        return 1;
    } 
    
	/* close db */
    sqlite3_close(db);
    
    return 0;
}
