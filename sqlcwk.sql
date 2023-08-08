/*
@author: Zeyad Bassyouni

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 chinook.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vCustomerPerEmployee;
DROP VIEW IF EXISTS v10WorstSellingGenres;
DROP VIEW IF EXISTS vBestSellingGenreAlbum;
DROP VIEW IF EXISTS v10BestSellingArtists;
DROP VIEW IF EXISTS vTopCustomerEachGenre;

.header on
.mode columns

/*
============================================================================
Question 1: Complete the query for vCustomerPerEmployee.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vCustomerPerEmployee AS"
============================================================================
*/
CREATE VIEW vCustomerPerEmployee  AS
SELECT e.LastName, e.FirstName, e.EmployeeId, COUNT(c.SupportRepId) AS TotalCustomer
FROM employees e
LEFT JOIN customers c
ON e.EmployeeId = c.SupportRepId
GROUP BY e.EmployeeId;



/*
============================================================================
Question 2: Complete the query for v10WorstSellingGenres.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10WorstSellingGenres AS"
============================================================================
*/
CREATE VIEW v10WorstSellingGenres  AS
SELECT g.Name AS Genre, COALESCE(SUM(qty), 0) AS Sales
FROM genres g
LEFT JOIN (
  SELECT t.GenreId, SUM(ii.Quantity) AS qty
  FROM tracks t
  LEFT JOIN invoice_items ii ON ii.TrackId = t.TrackId
  GROUP BY t.GenreId
) sub ON sub.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY Sales ASC
LIMIT 10;


/*
============================================================================
Question 3:
Complete the query for vBestSellingGenreAlbum
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vBestSellingGenreAlbum AS"
============================================================================
*/
CREATE VIEW vBestSellingGenreAlbum  AS
SELECT g.Name AS Genre, a.Title AS Album, ar.Name AS Artist, SUM(ii.Quantity) AS Sales
FROM genres g 
JOIN tracks t ON g.GenreId = t.GenreId 
JOIN invoice_items ii ON t.TrackId = ii.TrackId 
JOIN albums a ON t.AlbumId = a.AlbumId 
JOIN artists ar ON a.ArtistId = ar.ArtistId 
GROUP BY g.Name, a.Title, ar.Name
HAVING SUM(ii.Quantity) = (
   SELECT MAX(total_sales)
   FROM (
      SELECT g.GenreId, a.AlbumId, SUM(ii.Quantity) AS total_sales
      FROM genres g
      JOIN tracks t ON g.GenreId = t.GenreId
      JOIN invoice_items ii ON t.TrackId = ii.TrackId
      JOIN albums a ON t.AlbumId = a.AlbumId
      GROUP BY g.GenreId, a.AlbumId
   ) AS genre_album_sales
   WHERE genre_album_sales.GenreId = g.GenreId
   GROUP BY genre_album_sales.GenreId
);



/*
============================================================================
Question 4:
Complete the query for v10BestSellingArtists
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10BestSellingArtists AS"
============================================================================
*/

CREATE VIEW v10BestSellingArtists AS
SELECT a.Name AS Artist, COUNT(DISTINCT al.AlbumId) AS TotalAlbum, SUM(ii.Quantity) AS TotalTrackSales
FROM artists a
JOIN albums al ON a.ArtistId = al.ArtistId
JOIN tracks t ON al.AlbumId = t.AlbumId
JOIN invoice_items ii ON t.TrackId = ii.TrackId
GROUP BY Artist
ORDER BY TotalTrackSales DESC
LIMIT 10;




/*
============================================================================
Question 5:
Complete the query for vTopCustomerEachGenre
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
SELECT subquery.Genre, subquery.TopSpender, subquery.TotalSpending
FROM (
   SELECT g.Name AS Genre,
      c.FirstName || ' ' || c.LastName AS TopSpender,
      SUM(ii.Quantity * ii.UnitPrice) AS TotalSpending,
      ROW_NUMBER() OVER (PARTITION BY g.Name ORDER BY SUM(ii.Quantity * ii.UnitPrice) DESC) AS Rank
   FROM invoice_items ii
   JOIN tracks t ON ii.TrackId = t.TrackId
   JOIN genres g ON t.GenreId = g.GenreId
   JOIN invoices i ON ii.InvoiceId = i.InvoiceId
   JOIN customers c ON i.CustomerId = c.CustomerId
   GROUP BY g.Name, TopSpender
) AS subquery
WHERE subquery.Rank = 1
ORDER BY subquery.Genre;





/*
To view the created views, use SELECT * FROM views;
You can uncomment the following to look at individual views created
*/
SELECT * FROM vCustomerPerEmployee;
SELECT * FROM v10WorstSellingGenres;
SELECT * FROM vBestSellingGenreAlbum;
SELECT * FROM v10BestSellingArtists;
SELECT * FROM vTopCustomerEachGenre;
