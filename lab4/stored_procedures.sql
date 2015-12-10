SELECT 'Add procedure addYear for inserting new year' AS '';
delimiter //
CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO Year (year, profitfactor) VALUES ( year, factor );
END//
delimiter ;

SELECT 'Add procedure addDay for inserting new weekday into schedule' AS '';
delimiter //
CREATE PROCEDURE addDay (IN year INT, IN day VARCHAR(45), IN factor DOUBLE) BEGIN INSERT INTO Weekday (name, weekdayFactor, year) VALUES (day, factor, (SELECT idYear FROM Year WHERE Year=year)); END//
delimiter ;

SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(45), IN country VARCHAR(45)) 
BEGIN 
INSERT INTO Destination (airportId, name, country) VALUES (airport_code, name, country); 
END//
delimiter ;


SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT(11), IN routeprice INT(11)) 
BEGIN 
INSERT INTO Route (from, to, routePrice, year) VALUES ((select airportId from Destination where airportId=departure_airport_code), (select airportId from Destination where airportId=arrival_airport_code), routeprice, year); 
END//
delimiter ;

