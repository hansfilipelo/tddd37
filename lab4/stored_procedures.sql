/* Our stored procedures  */
# ----------------

DROP PROCEDURE IF EXISTS addYear;
SELECT 'Add procedure addYear for inserting new year' AS '';
delimiter //
CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO Year (year, profitfactor) VALUES ( year, factor );
END//
delimiter ;

# ----------------

DROP PROCEDURE IF EXISTS addDay;
SELECT 'Add procedure addDay for inserting new weekday into schedule' AS '';
delimiter //
CREATE PROCEDURE addDay (IN inYear INT, IN inDay VARCHAR(45), IN inFactor DOUBLE)
BEGIN
  INSERT INTO Weekday (name, weekdayFactor, year)
  VALUES (inDay, inFactor, (SELECT idYear FROM Year WHERE Year=inYear)); END//
delimiter ;

# ----------------

DROP PROCEDURE IF EXISTS addDestination;
SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN destName VARCHAR(45), IN country VARCHAR(45))
BEGIN

IF (SELECT COUNT(*) FROM Country) = 0
THEN
	INSERT INTO Country (name) VALUES (UPPER(country));
ELSE
	INSERT INTO Country (name) SELECT country FROM Country
	WHERE (SELECT COUNT(*) FROM Country WHERE name=country)=0;
END IF;

INSERT INTO Destination (airportId, name, country) VALUES (airport_code, destName, (select idCountry from Country where name=UPPER(country)));
END//
delimiter ;

# ----------------

DROP PROCEDURE IF EXISTS addRoute;
SELECT 'Add procedure addDestination for inserting new destination' AS '';
delimiter //
CREATE PROCEDURE addRoute(IN departureAirportCode VARCHAR(3), IN arrivalAirportCode VARCHAR(3), IN inYear INT(11), IN inRoutePrice DOUBLE)
BEGIN
INSERT INTO Route (fromAirport, toAirport, routePrice, year)
VALUES (
  departureAirportCode,
  arrivalAirportCode,
  inRoutePrice,
  (SELECT idYear FROM Year WHERE year=inYear));
END//
delimiter ;

# ----------------

DROP PROCEDURE IF EXISTS addPlane;
delimiter //
CREATE PROCEDURE addPlane(IN inModel VARCHAR(45), IN inSeats INT(11))
BEGIN
INSERT INTO Plane (model, seats)
VALUES (
  inModel,
  inSeats);
END//
delimiter ;
CALL addPlane('Fokker 70',40);

# ----------------

DROP PROCEDURE IF EXISTS addFlight;
SELECT 'Add procedure addFlight for inserting new flight' AS '';
delimiter //
CREATE PROCEDURE addFlight(IN inDepartureAirport VARCHAR(3), IN inArrivalAirport VARCHAR(3), IN inYear INT(11), IN inDay VARCHAR(45), IN inDepartureTime TIME)
BEGIN
INSERT INTO WeeklySchedule(weekday, departureTime, route)
  VALUES (
    (SELECT idWeekday FROM Weekday WHERE name=inDay),
    inDepartureTime,
    (SELECT idRoute FROM Route WHERE fromAirport=inDepartureAirport AND toAirport=inArrivalAirport)
  );
# Create an "assembly style" loop for every week
SET @weeklyScheduleId = LAST_INSERT_ID();
SET @count = 0;
loopstart: LOOP
  SET @count = @count + 1;
  INSERT INTO Flights(weeklySchedule, weekNr, plane)
    VALUES(
      @weeklyScheduleId,
      @count,
      1);
  IF @count < 52 THEN
    ITERATE loopstart;
  END IF;
  LEAVE loopstart;
  END LOOP loopstart;
END //
delimiter ;
