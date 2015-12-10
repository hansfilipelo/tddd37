/* Our stored procedures  */
DROP PROCEDURE IF EXISTS addYear;
SELECT 'Add procedure addYear for inserting new year' AS '';
delimiter //
CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO Year (year, profitfactor) VALUES ( year, factor );
END//
delimiter ;

DROP PROCEDURE IF EXISTS addDay;
SELECT 'Add procedure addDay for inserting new weekday into schedule' AS '';
delimiter //
CREATE PROCEDURE addDay (IN year INT, IN day VARCHAR(45), IN factor DOUBLE) BEGIN INSERT INTO Weekday (name, weekdayFactor, year) VALUES (day, factor, (SELECT idYear FROM Year WHERE Year=year)); END//
delimiter ;

DROP PROCEDURE IF EXISTS addDestination;
SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN destName VARCHAR(45), IN country VARCHAR(45))
BEGIN
INSERT INTO Country (name) VALUES (UPPER(country)) ON DUPLICATE KEY UPDATE name=UPPER(country);
INSERT INTO Destination (airportId, name, country) VALUES (airport_code, destName, (select idCountry from Country where name=UPPER(country)));
END//
delimiter ;

DROP PROCEDURE IF EXISTS addRoute;
SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addRoute(IN departureAirportCode VARCHAR(3), IN arrivalAirportCode VARCHAR(3), IN inYear INT(11), IN inRoutePrice INT(11))
BEGIN
INSERT INTO Route (from, to, routePrice, year)
VALUES (
  (select airportId from Destination where airportId=departureAirportCode),
  (select airportId from Destination where airportId=arrivalAirportCode),
  inRoutePrice,
  (select idYear from Year where year=inYear));
END//
delimiter ;
