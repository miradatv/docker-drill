
-- events trace with info filtered by device id
SELECT t.`timestamp` as `timestamp`, t.`session`.device.ip AS ip, t.playSession.playSessionId AS playSessionId,
        t.`session`.device.class as deviceClass, t.appVersion as appVersion, t.protocolVersion as protocolVersion,
        t.`module` as `module`, t.event as event, t.playSession.playSession AS playSession, t.trickplay.trickplayMode AS trickPlayMode
    FROM `tvmetrix.json` AS t
    WHERE t.`session`.device.deviceId = '**********'
    ORDER BY t.`timestamp` ASC;

-- event type summary
select t.event as event, count(t.event) as total
    from `tvmetrix.json` as t group by t.event ORDER BY total DESC;

-- device class summary
SELECT t.session.device.class AS class, count(t.session.device.class) AS total
    FROM `tvmetrix.json` AS t GROUP BY t.session.device.class ORDER BY total DESC;

-- device id summary
SELECT t.session.device.deviceId AS deviceId, count(t.session.device.deviceId) AS total
    FROM `tvmetrix.json` AS t GROUP BY t.session.device.deviceId ORDER BY total DESC;

-- device ip summary
SELECT t.session.device.ip AS ip, count(t.session.device.ip) AS total
    FROM `tvmetrix.json` AS t GROUP BY t.session.device.ip ORDER BY total DESC;

-- app version summary
select t.appVersion, count(t.appVersion) as total
    from `tvmetrix.json` as t group by t.appVersion ORDER BY total DESC;

-- content summary
SELECT t.content.contentId AS contentId, t.content.title as title, count(t.content.contentId) AS total
    FROM `tvmetrix.json` AS t GROUP BY t.content.contentId, t.content.title ORDER BY total DESC;

-- content list filtered by genre
SELECT t.content.contentId AS contentId, t.content.title as title, t.content.genres
    FROM `tvmetrix.json` AS t
    WHERE REPEATED_CONTAINS(t.content.genres, '^Series?$');

-- show planning and execution options
SELECT name, kind, accessibleScopes, optionScope FROM sys.`options` order by name;

-- create table based on data and store (view is similar, but without storing data (virtual))
ALTER SESSION SET `store.format`='json';
DROP TABLE IF EXISTS tmp.prueba;
CREATE TABLE tmp.prueba AS SELECT DISTINCT(t.appVersion), count(t.appVersion) OVER (PARTITION BY t.appversion) AS total FROM `tvmetrix.json` AS t;
SELECT * FROM tmp.prueba;
