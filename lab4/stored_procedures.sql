USE brianair;
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
SELECT 'Add procedure addPlane for inserting new plane type' AS '';
delimiter //
CREATE PROCEDURE addPlane(IN inModel VARCHAR(45), IN inSeats INT(11))
BEGIN
INSERT INTO Plane (model, seats)
VALUES (
  inModel,
  inSeats);
END//
delimiter ;

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

# ----------------

DROP FUNCTION IF EXISTS calculateFreeSeats;
SELECT 'Add helper function for checking number of free seats' AS '';
CREATE FUNCTION calculateFreeSeats(flightnumber INT)
  RETURNS INT
    RETURN 40-(SELECT COUNT(*) FROM Reservations,Payments WHERE Reservations.idReservations=Payments.idReservations AND Reservations.flight = flightnumber);

# ----------------

DROP PROCEDURE IF EXISTS calculatePriceHelper;
DROP FUNCTION IF EXISTS calculatePrice;
SELECT 'Add helper function for calculating seat price for a flight' AS '';
delimiter //
CREATE FUNCTION calculatePrice(flightnumber INT(11))
  RETURNS DOUBLE
    BEGIN
      SET @weeklySchedule =
          (SELECT weeklySchedule FROM Flights WHERE idFlights = flightnumber);

      SET @routePrice =
          (SELECT routePrice FROM Route
          WHERE idRoute =
              (SELECT weekday FROM WeeklySchedule
              WHERE idWeeklySchedule = @weeklySchedule));

      SET @weekdayFactor =
          (SELECT weekdayFactor FROM Weekday
          WHERE idWeekday = @weeklySchedule);

      SET @bookedPassengers =
          (SELECT COUNT(*) FROM Reservations,Payments
          WHERE Reservations.idReservations=Payments.idReservations AND
          Reservations.flight = flightnumber);

      SET @profitFactor =
          (SELECT profitfactor FROM Year
          WHERE idYear =
              (SELECT year FROM Weekday
              WHERE idWeekday =
                  (SELECT weekday FROM WeeklySchedule
                  WHERE idWeeklySchedule = @weeklySchedule)));

      RETURN @routePrice * @weekdayFactor *
          (@bookedPassengers + 1) / 40 * @profitFactor;
    END//

delimiter ;