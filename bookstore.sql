CREATE TABLE Authors
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    birthday DATE
);

CREATE TABLE Publishers
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(150) NOT NULL,
    address NVARCHAR(200) NULL,
    city NVARCHAR(100) NULL,
    zip NVARCHAR(20) NULL,
    country NVARCHAR(100) NULL
);

CREATE TABLE Books
(
    isbn13 CHAR(13) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    language NVARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    publication_date DATE NOT NULL,
    publisher_id INT NULL,

    CONSTRAINT CK_Books_ISBN13
        CHECK (isbn13 NOT LIKE '%[^0-9]%' AND LEN(isbn13) = 13),

    CONSTRAINT CK_Books_Price
        CHECK (price >= 0),

    CONSTRAINT FK_Books_Publishers
        FOREIGN KEY (publisher_id) REFERENCES Publishers(id)
);

CREATE TABLE BookAuthors
(
    isbn13 CHAR(13) NOT NULL,
    author_id INT NOT NULL,

    CONSTRAINT PK_BookAuthors
        PRIMARY KEY (isbn13, author_id),

    CONSTRAINT FK_BookAuthors_Books
        FOREIGN KEY (isbn13) REFERENCES Books(isbn13),

    CONSTRAINT FK_BookAuthors_Authors
        FOREIGN KEY (author_id) REFERENCES Authors(id)
);

CREATE TABLE Stores
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    store_name NVARCHAR(150) NOT NULL,
    address NVARCHAR(200) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    zip NVARCHAR(20) NOT NULL,
    country NVARCHAR(100) NOT NULL
);

CREATE TABLE StockBalances
(
    store_id INT NOT NULL,
    isbn13 CHAR(13) NOT NULL,
    quantity INT NOT NULL,

    CONSTRAINT PK_StockBalances
        PRIMARY KEY (store_id, isbn13),

    CONSTRAINT FK_StockBalances_Stores
        FOREIGN KEY (store_id) REFERENCES Stores(id),

    CONSTRAINT FK_StockBalances_Books
        FOREIGN KEY (isbn13) REFERENCES Books(isbn13),

    CONSTRAINT CK_StockBalances_Quantity
        CHECK (quantity >= 0)
);

CREATE TABLE Customers
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    phone NVARCHAR(30) NULL,
    address NVARCHAR(200) NULL,
    city NVARCHAR(100) NULL,
    zip NVARCHAR(20) NULL,
    country NVARCHAR(100) NULL
);

CREATE TABLE Orders
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id) REFERENCES Customers(id)
);

CREATE TABLE OrderRows
(
    order_id INT NOT NULL,
    isbn13 CHAR(13) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_OrderRows
        PRIMARY KEY (order_id, isbn13),

    CONSTRAINT FK_OrderRows_Orders
        FOREIGN KEY (order_id) REFERENCES Orders(id),

    CONSTRAINT FK_OrderRows_Books
        FOREIGN KEY (isbn13) REFERENCES Books(isbn13),

    CONSTRAINT CK_OrderRows_Quantity
        CHECK (quantity > 0),

    CONSTRAINT CK_OrderRows_UnitPrice
        CHECK (unit_price >= 0)
);

CREATE TABLE Genres
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE BookGenres
(
    isbn13 CHAR(13) NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT PK_BookGenres
        PRIMARY KEY (isbn13, genre_id),

    CONSTRAINT FK_BookGenres_Books
        FOREIGN KEY (isbn13) REFERENCES Books(isbn13),

    CONSTRAINT FK_BookGenres_Genres
        FOREIGN KEY (genre_id) REFERENCES Genres(id)
);

CREATE TABLE Employees
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    store_id INT NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    role NVARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,

    CONSTRAINT FK_Employees_Stores
        FOREIGN KEY (store_id) REFERENCES Stores(id)
);

-- TEST DATA

-- Publishers

INSERT INTO Publishers
    (name, address, city, zip, country)
VALUES
    ('Penguin Random House', '20 Vauxhall Bridge Road', 'London', 'SW1V 2SA', 'United Kingdom'),
    ('Albert Bonniers Förlag', 'Sveavägen 56', 'Stockholm', '111 34', 'Sweden'),
    ('Knopf Doubleday', '1745 Broadway', 'New York', '10019', 'USA'),
    ('Cassava Republic Press', '27 Bosun Adekoya Street', 'Lagos', '100001', 'Nigeria');
GO

-- Authors

INSERT INTO Authors
    (first_name, last_name, birthday)
VALUES
    ('Toni', 'Morrison', '1931-02-18'),
    ('Ngũgĩ wa', 'Thiong’o', '1938-01-05'),
    ('Ursula K.', 'Le Guin', '1929-10-21'),
    ('Nnedi', 'Okorafor', '1974-04-08'),
    ('Octavia E.', 'Butler', '1947-06-22'),
    ('Chimamanda Ngozi', 'Adichie', '1977-09-15');
GO

-- Books

INSERT INTO Books
    (isbn13, title, language, price, publication_date, publisher_id)
VALUES
    ('9781400033416', 'Beloved', 'English', 149.00, '1987-09-02', 3),
    ('9780099768210', 'The Bluest Eye', 'English', 129.00, '1970-01-01', 1),
    ('9780435905484', 'A Grain of Wheat', 'English', 139.00, '1967-01-01', 1),
    ('9780143106692', 'The River Between', 'English', 119.00, '1965-01-01', 1),
    ('9780441478125', 'The Left Hand of Darkness', 'English', 159.00, '1969-03-01', 1),
    ('9780547773742', 'A Wizard of Earthsea', 'English', 119.00, '1968-01-01', 1),
    ('9780756416935', 'Binti', 'English', 109.00, '2015-09-22', 1),
    ('9780756415198', 'Akata Witch', 'English', 129.00, '2011-04-14', 1),
    ('9780446675505', 'Parable of the Sower', 'English', 159.00, '1993-10-01', 3),
    ('9780007306220', 'Half of a Yellow Sun', 'English', 149.00, '2006-09-12', 4);
GO

-- BookAuthors

INSERT INTO BookAuthors
    (isbn13, author_id)
VALUES
    ('9781400033416', 1),
    ('9780099768210', 1),
    ('9780435905484', 2),
    ('9780143106692', 2),
    ('9780441478125', 3),
    ('9780547773742', 3),
    ('9780756416935', 4),
    ('9780756415198', 4),
    ('9780446675505', 5),
    ('9780007306220', 6);
GO

-- Stores

INSERT INTO Stores
    (store_name, address, city, zip, country)
VALUES
    ('BiblioNest Central', 'Drottninggatan 12', 'Göteborg', '411 14', 'Sweden'),
    ('BiblioNest Riverside', 'Lindholmsallén 5', 'Göteborg', '417 55', 'Sweden'),
    ('BiblioNest Old Town', 'Västerlånggatan 22', 'Stockholm', '111 29', 'Sweden');
GO

-- StockBalances

INSERT INTO StockBalances
    (store_id, isbn13, quantity)
VALUES
    (1, '9781400033416', 8),
    (1, '9780099768210', 5),
    (1, '9780435905484', 4),
    (1, '9780143106692', 6),
    (1, '9780441478125', 7),
    (1, '9780547773742', 9),
    (1, '9780756416935', 10),
    (1, '9780756415198', 3),
    (1, '9780446675505', 6),
    (1, '9780007306220', 5),

    (2, '9781400033416', 2),
    (2, '9780099768210', 4),
    (2, '9780435905484', 7),
    (2, '9780143106692', 3),
    (2, '9780441478125', 4),
    (2, '9780547773742', 5),
    (2, '9780756416935', 6),
    (2, '9780756415198', 8),
    (2, '9780446675505', 2),
    (2, '9780007306220', 4),

    (3, '9781400033416', 4),
    (3, '9780099768210', 6),
    (3, '9780435905484', 2),
    (3, '9780143106692', 5),
    (3, '9780441478125', 3),
    (3, '9780547773742', 7),
    (3, '9780756416935', 4),
    (3, '9780756415198', 2),
    (3, '9780446675505', 8),
    (3, '9780007306220', 6);
GO

-- Customers

INSERT INTO Customers
    (first_name, last_name, email, phone, address, city, zip, country)
VALUES
    ('Amina', 'Hassan', 'amina.hassan@example.com', '070-1112233', 'Eklandagatan 18', 'Göteborg', '412 55', 'Sweden'),
    ('Sara', 'Lindberg', 'sara.lindberg@example.com', '070-2223344', 'Karl Johansgatan 42', 'Göteborg', '414 59', 'Sweden'),
    ('Mikael', 'Andersson', 'mikael.andersson@example.com', '070-3334455', 'Hornsgatan 7', 'Stockholm', '118 46', 'Sweden'),
    ('Leila', 'Okafor', 'leila.okafor@example.com', '070-4445566', 'Södra Vägen 20', 'Göteborg', '412 54', 'Sweden');
GO

-- Orders

INSERT INTO Orders
    (customer_id, order_date)
VALUES
    (1, '2026-05-01 14:23:00'),
    (2, '2026-05-03 11:10:00'),
    (3, '2026-05-05 16:45:00'),
    (1, '2026-05-07 13:05:00'),
    (4, '2026-05-08 10:30:00');
GO

-- OrderRows

INSERT INTO OrderRows
    (order_id, isbn13, quantity, unit_price)
VALUES
    (1, '9781400033416', 1, 149.00),
    (1, '9780756416935', 2, 109.00),

    (2, '9780441478125', 1, 159.00),
    (2, '9780547773742', 1, 119.00),

    (3, '9780007306220', 1, 149.00),
    (3, '9780435905484', 1, 139.00),

    (4, '9780446675505', 1, 159.00),
    (4, '9780099768210', 1, 129.00),

    (5, '9780756415198', 2, 129.00),
    (5, '9780143106692', 1, 119.00);
GO

-- Genres

INSERT INTO Genres
    (name)
VALUES
    ('Literary Fiction'),
    ('Science Fiction'),
    ('Fantasy'),
    ('African Literature'),
    ('Historical Fiction'),
    ('Speculative Fiction');
GO

-- BookGenres

INSERT INTO BookGenres
    (isbn13, genre_id)
VALUES
    ('9781400033416', 1),
    ('9781400033416', 5),

    ('9780099768210', 1),

    ('9780435905484', 1),
    ('9780435905484', 4),
    ('9780435905484', 5),

    ('9780143106692', 1),
    ('9780143106692', 4),

    ('9780441478125', 2),
    ('9780441478125', 6),

    ('9780547773742', 3),
    ('9780547773742', 6),

    ('9780756416935', 2),
    ('9780756416935', 6),

    ('9780756415198', 3),
    ('9780756415198', 4),

    ('9780446675505', 2),
    ('9780446675505', 6),

    ('9780007306220', 1),
    ('9780007306220', 4),
    ('9780007306220', 5);
GO

-- Employees

INSERT INTO Employees
    (store_id, first_name, last_name, email, role, hire_date)
VALUES
    (1, 'Nora', 'Bergström', 'nora.bergstrom@biblionest.example', 'Store Manager', '2021-03-15'),
    (1, 'Jonas', 'Ek', 'jonas.ek@biblionest.example', 'Bookseller', '2023-08-01'),
    (2, 'Fatima', 'Ali', 'fatima.ali@biblionest.example', 'Store Manager', '2020-11-20'),
    (2, 'Elias', 'Nyström', 'elias.nystrom@biblionest.example', 'Bookseller', '2024-01-10'),
    (3, 'Maja', 'Sund', 'maja.sund@biblionest.example', 'Store Manager', '2019-06-03'),
    (3, 'Oskar', 'Lund', 'oskar.lund@biblionest.example', 'Bookseller', '2022-09-12');
GO

CREATE VIEW TitlesPerAuthor
AS
    SELECT
        CONCAT(a.first_name, ' ', a.last_name) AS [Name],
        DATEDIFF(YEAR, a.birthday, GETDATE()) AS [Age],
        COUNT(DISTINCT b.isbn13) AS [Titles],
        SUM(b.price * sb.quantity) AS [Stock value]
    FROM Authors AS a
        JOIN BookAuthors AS ba
        ON a.id = ba.author_id
        JOIN Books AS b
        ON ba.isbn13 = b.isbn13
        JOIN StockBalances AS sb
        ON b.isbn13 = sb.isbn13
    GROUP BY
    a.id,
    a.first_name,
    a.last_name,
    a.birthday;
GO

-- Extra demo book with multiple authors, to demonstrate many-to-many authors/books

INSERT INTO Books
    (isbn13, title, language, price, publication_date, publisher_id)
VALUES
    ('9780000000001', 'Speculative Futures', 'English', 179.00, '2024-01-15', 4);
GO

INSERT INTO BookAuthors
    (isbn13, author_id)
VALUES
    ('9780000000001', 4),
    ('9780000000001', 5);
GO

INSERT INTO BookGenres
    (isbn13, genre_id)
VALUES
    ('9780000000001', 2),
    ('9780000000001', 6);
GO

INSERT INTO StockBalances
    (store_id, isbn13, quantity)
VALUES
    (1, '9780000000001', 5),
    (2, '9780000000001', 3),
    (3, '9780000000001', 4);
GO

-- This view helps the bookstore identify active and high-value customers.
-- It can be used for customer service, loyalty offers, and marketing follow-up.

CREATE VIEW CustomerPurchaseSummary
AS
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS [Customer],
        COUNT(ot.order_id) AS [Order count],
        SUM(ot.books_bought) AS [Books bought],
        SUM(ot.order_total) AS [Total spent],
        CAST(AVG(ot.order_total) AS DECIMAL(10,2)) AS [Average order value]
    FROM Customers AS c
        JOIN Orders AS o
        ON c.id = o.customer_id
        JOIN (
        SELECT
            order_id,
            SUM(quantity) AS books_bought,
            SUM(quantity * unit_price) AS order_total
        FROM OrderRows
        GROUP BY order_id
    ) AS ot
        ON o.id = ot.order_id
    GROUP BY
    c.id,
    c.first_name,
    c.last_name;
GO


