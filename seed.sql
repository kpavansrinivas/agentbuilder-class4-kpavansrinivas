-- =====================================================================
-- Project 1 - SpaceX launches (single-table SQLite seed)
-- =====================================================================
-- Tiny by design. One table, 18 launches, mix of vehicles, destinations,
-- customers, and successes/failures so the data tells real stories.

DROP TABLE IF EXISTS launches;

CREATE TABLE launches (
    launch_id      INTEGER PRIMARY KEY,
    mission_name   TEXT NOT NULL,
    vehicle        TEXT NOT NULL,                              -- Falcon 1 / Falcon 9 / Falcon Heavy / Starship
    payload_type   TEXT NOT NULL,                              -- Test / Cargo / Crew / Satellite / Probe
    payload_kg     INTEGER NOT NULL,                           -- 0 = no orbital payload (e.g. test flights)
    destination    TEXT NOT NULL,                              -- LEO / ISS / L1 / Heliocentric / Suborbital / ...
    success        INTEGER NOT NULL CHECK (success IN (0, 1)), -- 0 = failure, 1 = success (boolean)
    launch_date    DATE NOT NULL,
    customer       TEXT NOT NULL                               -- NASA / SpaceX / Iridium / NOAA / DARPA / ...
);

INSERT INTO launches VALUES
( 1, 'Falcon 1 Flight 1',    'Falcon 1',     'Test',      20,    'LEO',              0, '2006-03-24', 'DARPA'),
( 2, 'Falcon 1 Flight 4',    'Falcon 1',     'Test',      165,   'LEO',              1, '2008-09-28', 'SpaceX'),
( 3, 'COTS Demo Flight 2',   'Falcon 9',     'Cargo',     525,   'ISS',              1, '2012-05-22', 'NASA'),
( 4, 'CASSIOPE',             'Falcon 9',     'Satellite', 500,   'LEO',              1, '2013-09-29', 'MDA'),
( 5, 'DSCOVR',               'Falcon 9',     'Satellite', 570,   'L1',               1, '2015-02-11', 'NOAA'),
( 6, 'CRS-7',                'Falcon 9',     'Cargo',     1952,  'ISS',              0, '2015-06-28', 'NASA'),
( 7, 'Iridium NEXT-1',       'Falcon 9',     'Satellite', 9600,  'LEO',              1, '2017-01-14', 'Iridium'),
( 8, 'Falcon Heavy Demo',    'Falcon Heavy', 'Test',      1350,  'Heliocentric',     1, '2018-02-06', 'SpaceX'),
( 9, 'Crew Dragon Demo-2',   'Falcon 9',     'Crew',      12500, 'ISS',              1, '2020-05-30', 'NASA'),
(10, 'Starship SN10',        'Starship',     'Test',      0,     'Suborbital',       0, '2021-03-03', 'SpaceX'),
(11, 'Starship SN15',        'Starship',     'Test',      0,     'Suborbital',       1, '2021-05-05', 'SpaceX'),
(12, 'Inspiration4',         'Falcon 9',     'Crew',      12500, 'LEO',              1, '2021-09-15', 'Shift4'),
(13, 'DART',                 'Falcon 9',     'Probe',     610,   'Heliocentric',     1, '2021-11-24', 'NASA'),
(14, 'Starlink Group 4-7',   'Falcon 9',     'Satellite', 13620, 'LEO',              1, '2022-02-03', 'SpaceX'),
(15, 'Starship IFT-1',       'Starship',     'Test',      0,     'Suborbital',       0, '2023-04-20', 'SpaceX'),
(16, 'Starship IFT-3',       'Starship',     'Test',      0,     'Suborbital',       1, '2024-03-14', 'SpaceX'),
(17, 'Polaris Dawn',         'Falcon 9',     'Crew',      12500, 'LEO',              1, '2024-09-10', 'Shift4'),
(18, 'Europa Clipper',       'Falcon Heavy', 'Probe',     6065,  'Jupiter Transfer', 1, '2024-10-14', 'NASA');

-- Stories baked into the rows (so the agent has real things to say):
-- - Falcon 1: 2 flights here, 1 success  -> 50% success rate
-- - Falcon 9: 10 flights, 1 failure (CRS-7) -> very reliable
-- - Falcon Heavy: 2 flights, both success
-- - Starship: 4 test flights, 2 successes, 2 failures
-- - Heaviest payload: Starlink Group 4-7 (13,620 kg)
-- - Crew missions: Demo-2, Inspiration4, Polaris Dawn (mix of NASA + civilian)
-- - Furthest destination: Europa Clipper (Jupiter Transfer)
