
-------------------------------------------------------------------------------------------------------------------------------


-- Spotify 2023 Data Cleaning

-- Skills used: CRUD, Join's, CTE's, Window Function, Constraints, Converting Data Types


-------------------------------------------------------------------------------------------------------------------------------


--- Standardize the DataTypes and Constraints of columns


-- Set the appropriate data type

ALTER TABLE TracksPerformance
ALTER COLUMN track_id INT NOT NULL; 

ALTER TABLE TracksPerformance
ADD PRIMARY KEY (track_id);

ALTER TABLE TracksPerformance
ALTER COLUMN artist_count INT NULL;


-- Adding 'date_released' column and updating it with date values from released_year, released_month, and released_day

ALTER TABLE TracksPerformance
ADD date_released date NULL;

UPDATE 
  TracksPerformance 
SET 
  date_released = cast(
    CONCAT (
      released_year, '-', released_month, '-', released_day
    ) AS DATE
  )


-- Set the appropriate data type for following columns

ALTER TABLE TracksPerformance
ALTER COLUMN in_spotify_playlists INT NULL;

ALTER TABLE TracksPerformance
ALTER COLUMN in_spotify_charts INT NULL;


-- Giving NULL value to specific column to resolve issues caused by gibberish data for successful datatype transformation

UPDATE TracksPerformance
SET streams = NULL
WHERE [artist(s)_name] = 'Edison Lighthouse';

ALTER TABLE TracksPerformance
ALTER COLUMN streams BIGINT NULL;


-- Set the appropriate data type for following columns

ALTER TABLE TracksPerformance
ALTER COLUMN in_apple_playlists INT NULL;

ALTER TABLE TracksPerformance
ALTER COLUMN in_apple_charts INT NULL;


-- Removing comma in values on in_deezer_playlists column then setting appropriate datatype

UPDATE
    TracksPerformance
SET
    in_deezer_playlists = replace(in_deezer_playlists, ',', '')
WHERE
    in_deezer_playlists LIKE '%,%';

ALTER TABLE TracksPerformance
ALTER COLUMN in_deezer_playlists INT NULL;


--Set the appropriate data type for following columns

ALTER TABLE TracksPerformance
ALTER COLUMN in_deezer_charts INT NULL;


-- Removing comma in values on in_shazam_charts column and setting 'null' value into '0' then setting appropriate datatype 

UPDATE
    TracksPerformance
SET
    in_shazam_charts = replace(in_shazam_charts, ',', '')
WHERE
    in_shazam_charts LIKE '%,%';

UPDATE
    TracksPerformance
SET
    in_shazam_charts = '0'
WHERE
    in_shazam_charts = LOWER('null');

ALTER TABLE TracksPerformance
ALTER COLUMN in_shazam_charts INT NULL;


-- Set the appropriate data type for following columns

ALTER TABLE TracksAudioFeatures
ALTER COLUMN track_id INT NOT NULL; 

ALTER TABLE TracksAudioFeatures
ADD FOREIGN KEY (track_id) REFERENCES TracksPerformance(track_id) ON DELETE CASCADE;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN bpm INT NULL;

UPDATE
    TracksAudioFeatures
SET
    [key] = NULL
WHERE
    [key] = 'null';

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [danceability_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [valence_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [energy_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [acousticness_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [instrumentalness_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [liveness_%] INT NULL;

ALTER TABLE TracksAudioFeatures
ALTER COLUMN [speechiness_%] INT NULL;

--------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates --


-- TracksAudioFeatures Table

WITH afDuplicateRows AS (
    SELECT 
        p.track_id,
		track_name,
		[artist(s)_name],
        ROW_NUMBER() OVER (
            PARTITION BY p.track_name, p.[artist(s)_name] 
            ORDER BY p.track_id
        ) AS duplicate_count
    FROM TracksPerformance p
    JOIN TracksAudioFeatures af ON p.track_id = af.track_id
)

DELETE af
FROM
    TracksAudioFeatures af
    JOIN afDuplicateRows d ON af.track_id = d.track_id
WHERE
    d.duplicate_count > 1;


-- Tracks Performance Table

WITH pDuplicateRows AS (
    SELECT 
        track_id,
		track_name,
		[artist(s)_name],
        ROW_NUMBER() OVER (
            PARTITION BY track_name, [artist(s)_name] 
            ORDER BY track_id
        ) AS duplicate_count
    FROM TracksPerformance 
)

DELETE p
FROM
    TracksPerformance p
    JOIN pDuplicateRows d ON p.track_id = d.track_id
WHERE
    d.duplicate_count > 1;


--------------------------------------------------------------------------------------------------------------------------------


-- Delete unused columns


-- Removing separate year, month, and day columns after combining following columns data into a single DATE column

ALTER TABLE TracksPerformance
drop COLUMN released_year;

ALTER TABLE TracksPerformance
drop COLUMN released_month;

ALTER TABLE TracksPerformance
drop COLUMN released_day;


---------------------------------------------------------------------------------------------------------------------------------




