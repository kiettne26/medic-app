import pg8000.dbapi
import os

def run_migration():
    host = "db.sejuqjvdztgrrvclyevp.supabase.co"
    port = 5432
    user = "postgres"
    password = "Chukiet26##"
    database = "postgres"

    print(f"Connecting to database {database} at {host}:{port}...")
    
    conn = pg8000.dbapi.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database
    )
    
    cursor = conn.cursor()
    
    sql_file = "add_payment_columns.sql"
    if not os.path.exists(sql_file):
        # try parent directory or absolute path
        sql_file = r"c:\Adroid\medic_app\app_be\add_payment_columns.sql"
        
    print(f"Reading SQL file: {sql_file}")
    with open(sql_file, "r", encoding="utf-8") as f:
        sql = f.read()
        
    # Split by semicolon to run each statement, but be careful with empty lines
    statements = [stmt.strip() for stmt in sql.split(";") if stmt.strip()]
    
    for i, statement in enumerate(statements):
        print(f"Executing statement {i+1}/{len(statements)}:\n{statement}\n")
        try:
            cursor.execute(statement)
        except Exception as e:
            print(f"Error executing statement {i+1}: {e}")
            conn.rollback()
            conn.close()
            return False
            
    print("Committing transaction...")
    conn.commit()
    cursor.close()
    conn.close()
    print("Migration completed successfully!")
    return True

if __name__ == "__main__":
    run_migration()
