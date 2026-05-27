from getpass import getpass

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import SQLAlchemyError

server_name = "localhost"
database_name = "BookstoreLab2"
user_name = "bookstore_reader_login"
password = getpass("Password:")

connection_string = (
    f"DRIVER=ODBC Driver 18 for SQL Server;"
    f"SERVER={server_name};"
    f"UID={user_name};"
    f"PWD={password};"
    f"DATABASE={database_name};"
    f"Encrypt=yes;"
    f"TrustServerCertificate=yes"
)

url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})

engine = create_engine(url)


def search_books(search_term: str) -> None:
    query = text("""
        SELECT
            b.title,
            b.isbn13,
            s.store_name,
            sb.quantity
        FROM Books AS b
            JOIN StockBalances AS sb
                ON b.isbn13 = sb.isbn13
            JOIN Stores AS s
                ON sb.store_id = s.id
        WHERE b.title LIKE :search_term
        ORDER BY
            b.title,
            s.store_name;
    """)

    try:
        with engine.connect() as connection:
            result = connection.execute(query, {"search_term": f"%{search_term}%"})

            rows = result.fetchall()

            if not rows:
                print("No matching books found.")
                return

            current_book = None

            for row in rows:
                if row.title != current_book:
                    current_book = row.title
                    print(f"\n{row.title}")
                    print(f"ISBN13: {row.isbn13}")

                print(f"  {row.store_name}: {row.quantity} copies")

    except SQLAlchemyError as error:
        print("Database error:")
        print(error)


def main() -> None:
    print("Bookstore title search")
    print("Type 'quit' to exit.")

    while True:
        search_term = input("\nSearch for a book title: ").strip()

        if search_term.lower() in {"quit", "exit", "q"}:
            print("Goodbye!")
            break

        if not search_term:
            print("Please enter a search term.")
            continue

        search_books(search_term)


if __name__ == "__main__":
    main()
