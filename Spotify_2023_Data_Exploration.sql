
-------------------------------------------------------------------------------------------------------------------


-- Spotify 2023 Data Exploration

-- Skills Used: Joins, Aggregate Functions, Window Functions, Subquery, CTE's, Temp Table


-------------------------------------------------------------------------------------------------------------------


-- Check number of records

SELECT 
    COUNT(*)
FROM
    TracksPerformance;


-- Check records for missing/null values
SELECT *
FROM TracksPerformance p
JOIN TracksAudioFeatures af ON p.track_id = af.track_id
WHERE p.track_id IS NULL
	OR track_name IS NULL
	OR [artist(s)_name] IS NULL
	OR artist_count IS NULL
	OR in_spotify_playlists IS NULL
	OR in_spotify_charts IS NULL
	OR streams IS NULL
	OR in_apple_playlists IS NULL
	OR in_apple_charts IS NULL
	OR in_deezer_playlists IS NULL
	OR in_deezer_charts IS NULL
	OR in_shazam_charts IS NULL
	OR bpm IS NULL
	OR [key] IS NULL
	OR mode IS NULL
	OR [danceability_%] IS NULL
	OR [valence_%] IS NULL
	OR [energy_%] IS NULL
	OR [acousticness_%] IS NULL
	OR [instrumentalness_%] IS NULL
	OR [liveness_%] IS NULL
	OR [speechiness_%] IS NULL;


-- Check number of records that has missing/null values

SELECT COUNT(*)
FROM TracksPerformance p
JOIN TracksAudioFeatures af ON p.track_id = af.track_id
WHERE p.track_id IS NULL
	OR track_name IS NULL
	OR [artist(s)_name] IS NULL
	OR artist_count IS NULL
	OR in_spotify_playlists IS NULL
	OR in_spotify_charts IS NULL
	OR streams IS NULL
	OR in_apple_playlists IS NULL
	OR in_apple_charts IS NULL
	OR in_deezer_playlists IS NULL
	OR in_deezer_charts IS NULL
	OR in_shazam_charts IS NULL
	OR bpm IS NULL
	OR [key] IS NULL
	OR mode IS NULL
	OR [danceability_%] IS NULL
	OR [valence_%] IS NULL
	OR [energy_%] IS NULL
	OR [acousticness_%] IS NULL
	OR [instrumentalness_%] IS NULL
	OR [liveness_%] IS NULL
	OR [speechiness_%] IS NULL;


-- Columns containing all the null/missing values

SELECT
    streams,
    [key]
FROM
    TracksPerformance p
    JOIN TracksAudioFeatures af ON p.track_id = af.track_id
WHERE
    streams IS NULL
    OR [key] IS NULL;


--------------------------------------------------------------------------------------------------------------------------


-- Top 10 Most Stream Artists

SELECT
    a.*,
    [rank] = ROW_NUMBER() OVER (ORDER BY total_streams desc) 
INTO #top10Artist
FROM
    (
        SELECT
            [artist(s)_name],
            total_streams = SUM(streams)
        FROM
            TracksPerformance
        GROUP BY
            [artist(s)_name]
    ) a
    
SELECT
    *
FROM
    #top10Artist
WHERE
    [rank] <= 10;


----------------------------------------------------------------------------------------------------------------------------


-- Top 10 Songs Based on Highest Streams

SELECT
    a.*
FROM
    (
        SELECT
            track_name,
            streams,
            [rank] = ROW_NUMBER() OVER (ORDER BY streams desc)
        FROM
            TracksPerformance
    ) a
WHERE
    [rank] <= 10;


----------------------------------------------------------------------------------------------------------------------------


-- Top 10 Songs Based on their Presence in Spotify Playlists

SELECT
    a.*
FROM
    (
        SELECT
            track_name,
            [artist(s)_name],
            in_spotify_playlists,
            [rank] = ROW_NUMBER() OVER (ORDER BY in_spotify_playlists desc)
        FROM
            TracksPerformance
    ) a
WHERE
    [rank] <= 10;



----------------------------------------------------------------------------------------------------------------------------


-- Top 10 Artists vs. Percentage features (Common Audio Features of songs of Top 10 Popular Artists)

SELECT
    p.[artist(s)_name],
    [avg_bpm] = AVG([bpm]),
    [avg_danceability_%] = AVG([danceability_%]),
    [avg_valence_%] = AVG([valence_%]),
    [avg_energy_%] = AVG([energy_%]),
    [avg_acousticness_ %] = AVG([acousticness_%]),
    [avg_instrumentalness_ %] = AVG([instrumentalness_%]),
    [avg_liveness_%] = AVG([liveness_%]),
    [avg_speechiness_%] = AVG([speechiness_%])
FROM
    TracksAudioFeatures af
    JOIN TracksPerformance p ON p.track_id = af.track_id
    JOIN #top10Artist acte ON p.[artist(s)_name] = acte.[artist(s)_name]
GROUP BY
    p.[artist(s)_name],
    acte.[rank]
HAVING
    acte.[rank] <= 10
ORDER BY
    acte.[rank];
    
DROP TABLE #top10Artist;


--------------------------------------------------------------------------------------------------------------------------


--Top 10 Popular Songs Based on Stream vs Percentage Features (Audio Features of Top 10 popular songs)

WITH top10PopularSongs AS (
    SELECT
        a.*
    FROM
        (
            SELECT
                track_name,
                streams,
                [rank] = ROW_NUMBER() OVER (ORDER BY streams desc)
            FROM
                TracksPerformance
        ) a
    WHERE
        [rank] <= 10
)
SELECT
    ps.track_name,
    af.bpm,
    af.[danceability_%],
    af.[valence_%],
    af.[energy_%],
    af.[acousticness_%],
    af.[instrumentalness_%],
    af.[liveness_%],
    af.[speechiness_%]
FROM
    TracksAudioFeatures af
    JOIN TracksPerformance p ON p.track_id = af.track_id
    JOIN top10PopularSongs ps ON p.track_name = ps.track_name
ORDER BY
    ps.[rank];


----------------------------------------------------------------------------------------------------------------------------


-- Tracks Released Over the Years

SELECT
    [year] = YEAR(date_released),
    track_count = COUNT(track_name)
FROM
    TracksPerformance
GROUP BY
    YEAR(date_released)
ORDER BY 1;


---------------------------------------------------------------------------------------------------------------------------


-- Yearly Trend in tracks releases

SELECT
    [year] = YEAR(date_released),
    no_of_released = COUNT(track_name)
FROM
    TracksPerformance
GROUP BY
    YEAR(date_released)
ORDER BY
    COUNT(track_name) desc;


---------------------------------------------------------------------------------------------------------------------------


-- Monthly Trend in track releases

SELECT
    [year] = YEAR(date_released),
    [month] = MONTH(date_released),
    no_of_released = COUNT(track_name)
FROM
    TracksPerformance
GROUP BY
    YEAR(date_released),
    MONTH(date_released)
ORDER BY 1, 2;


---------------------------------------------------------------------------------------------------------------------------


-- Other platforms


-- Top 10 Songs Based on their Presence in Apple Playlist

SELECT
    a.*
FROM
    (
        SELECT
            track_name,
            [artist(s)_name],
            in_apple_playlists,
            [rank] = ROW_NUMBER() OVER (ORDER BY in_apple_playlists desc)
        FROM
            TracksPerformance
    ) a
WHERE
    [rank] <= 10;


-- Top 10 Songs Based on their Presence in Deezer Playlist

SELECT
    a.*
FROM
    (
        SELECT
            track_name,
            [artist(s)_name],
            in_deezer_playlists,
            [rank] = ROW_NUMBER() OVER (ORDER BY in_deezer_playlists desc)
        FROM
            TracksPerformance
    ) a
WHERE
    [rank] <= 10;


------------------------------------------------------------------------------------------------------------------


-- Percentage of songs released per year over total count of songs

SELECT
    [year] = YEAR(date_released),
    track_count = COUNT(track_name) 
INTO #trackCountPerYear
FROM
    TracksPerformance
GROUP BY
    YEAR(date_released)
ORDER BY 1 desc;

SELECT
    [year],
    percentOfSumTrackCount = track_count * 100 / (
        SELECT
            SUM(track_count)
        FROM
            #trackCountPerYear
    )
FROM
    #trackCountPerYear;
    
DROP TABLE #trackCountPerYear;


------------------------------------------------------------------------------------------------------------------------


-- Top 5 Artist who have most number of released tracks in year 2023

WITH artists2023 AS (
    SELECT
        *
    FROM
        TracksPerformance
    WHERE
        YEAR(date_released) = 2023
)

SELECT
    *
FROM
    (
        SELECT
            [artist(s)_name],
            track_count = COUNT([artist(s)_name]),
            [RANK] = ROW_NUMBER() OVER (ORDER BY COUNT([artist(s)_name]) desc)
        FROM
            artists2023
        GROUP BY
            [artist(s)_name]
    ) a
WHERE
    a.[rank] <= 5;


----------------------------------------------------------------------------------------------------------------------


-- Top 5 Most stream Songs released in 2023

WITH songs2023 AS (
    SELECT
        track_name,
        [artist(s)_name],
        streams
    FROM
        TracksPerformance
    WHERE
        YEAR(date_released) = 2023
)

SELECT
    *
FROM
    (
        SELECT
            track_name,
            [artist(s)_name],
            [rank] = ROW_NUMBER() OVER ( ORDER BY streams desc )
        FROM
            songs2023
    ) a
WHERE
    a.[rank] <= 5; 


--------------------------------------------------------------------------------------------------------------------


-- Average number of streams for songs released in each month of 2023

SELECT
    [MONTH] = MONTH(date_released),
    avg_stream = AVG(streams)
FROM
    (
        SELECT
            *
        FROM
            TracksPerformance
        WHERE
            YEAR(date_released) = 2023
    ) a
GROUP BY
    MONTH(date_released)
ORDER BY 2 desc;


------------------------------------------------------------------------------------------------------------------------
