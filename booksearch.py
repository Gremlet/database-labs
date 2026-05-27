from getpass import getpass

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import SQLAlchemyError

import pandas as pd

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
            b.title AS [Title],
            b.isbn13 AS [ISBN13],
            s.store_name AS [Store],
            sb.quantity AS [Copies]
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
            df = pd.read_sql_query(
                query, connection, params={"search_term": f"%{search_term}%"}
            )

            if df.empty:
                print("No matching books found.")
                return

        # pivot table for a prettier df
        stock_table = df.pivot_table(
            index=["Title", "ISBN13"], columns="Store", values="Copies", fill_value=0
        ).reset_index()

        stock_table.columns.name = None

        store_columns = stock_table.columns.drop(["Title", "ISBN13"])
        stock_table[store_columns] = stock_table[store_columns].astype(
            int
        )  # cast stock count to ints instead of floats

        print(stock_table.to_string(index=False))

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
