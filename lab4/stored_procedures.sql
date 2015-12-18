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
CALL addPlane('Fokker 70', 40);

# ----------------

DROP PROCEDURE IF EXISTS addFlight;
SELECT 'Add procedure addFlight for inserting new flight' AS '';
delimiter //
CREATE PROCEDURE addFlight(IN inDepartureAirport VARCHAR(3), IN inArrivalAirport VARCHAR(3), IN inYear INT(11), IN inDay VARCHAR(45), IN inDepartureTime TIME)
BEGIN
INSERT INTO WeeklySchedule(weekday, departureTime, route)
  VALUES (
    (SELECT idWeekday FROM Weekday WHERE name=inDay AND year=(SELECT idYear FROM Year where year=inYear)),
    inDepartureTime,
    (SELECT idRoute FROM Route WHERE fromAirport=inDepartureAirport AND toAirport=inArrivalAirport AND year=(SELECT idYear FROM Year where year=inYear))
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
    RETURN (SELECT Plane.seats FROM Flights,Plane
    WHERE Flights.idFlights=flightnumber AND
    Flights.plane=Plane.idPlane)
    -
    (SELECT COUNT(*) FROM Reservations,Payments,ResPass
    WHERE Reservations.idReservations=Payments.idReservations AND
    Reservations.idReservations=ResPass.idReservations AND
    Reservations.flight = flightnumber);

# ----------------

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
              (SELECT route FROM WeeklySchedule
              WHERE idWeeklySchedule = @weeklySchedule));

      SET @weekdayFactor =
          (SELECT weekdayFactor FROM Weekday
          WHERE idWeekday =
	      (SELECT weekday FROM WeeklySchedule
	      WHERE idWeeklySchedule=@weeklySchedule));

      SET @bookedPassengers = (SELECT Plane.seats FROM Flights,Plane
          WHERE Flights.idFlights=flightnumber AND
          Flights.plane=Plane.idPlane)
          -
	  calculateFreeSeats(flightnumber);

      SET @profitFactor =
          (SELECT profitfactor FROM Year
          WHERE idYear =
              (SELECT year FROM Weekday
              WHERE idWeekday =
                  (SELECT weekday FROM WeeklySchedule
                  WHERE idWeeklySchedule = @weeklySchedule)));

      RETURN ROUND(@routePrice * @weekdayFactor *
          ((@bookedPassengers + 1) / 40) * @profitFactor, 9);
    END//

delimiter ;

# ----------------

DROP TRIGGER IF EXISTS ins_ticket_id;
SELECT 'Add trigger for ticketId' AS '';
# Triggers warning since ENCRYPT is deprecated
delimiter //
CREATE TRIGGER ins_ticket_id BEFORE INSERT ON Payments
  FOR EACH ROW
  BEGIN
    UPDATE ResPass SET ResPass.ticketId=ENCRYPT(CONCAT(ResPass.idReservations,ResPass.passportNr)) WHERE ResPass.idReservations=NEW.idReservations;
  END//
delimiter ;

# -----------------

DROP PROCEDURE IF EXISTS addReservationProper;
SELECT 'Add procedure addReservationProper' AS '';
delimiter //
CREATE PROCEDURE addReservationProper(IN inDepartureAirport VARCHAR(3), IN inArrivalAirport VARCHAR(3), IN inYear INT(11), IN inWeek INT(11), IN inDay VARCHAR(45), IN inTime TIME, OUT outReservationId INT(11))
BEGIN
SET @_idFlights =
(SELECT idFlights FROM Flights
      WHERE weekNr=inWeek AND
      weeklySchedule=
        (SELECT idWeeklySchedule FROM WeeklySchedule
        WHERE departureTime=inTime AND
        weekday=
          (SELECT idWeekday FROM Weekday
          WHERE name=inDay AND
          year=
            (SELECT idYear FROM Year
            WHERE year = inYear)) AND
          route=
            (SELECT idRoute FROM Route
              WHERE fromAirport=inDepartureAirport AND
              toAirport=inArrivalAirport AND
              year=
                (SELECT idYear FROM Year where year=inYear))));
IF @_idFlights IS NOT NULL THEN
  INSERT INTO Reservations (flight)
    VALUES (@_idFlights);
  SET outReservationId=LAST_INSERT_ID();
ELSE
  SET outReservationId=NULL;
END IF;
END//
delimiter ;

# ----------------

DROP PROCEDURE IF EXISTS addReservation;
SELECT 'Add procedure addReservation' AS '';
delimiter //
CREATE PROCEDURE addReservation(IN inDepartureAirport VARCHAR(3), IN inArrivalAirport VARCHAR(3), IN inYear INT(11), IN inWeek INT(11), IN inDay VARCHAR(45), IN inTime TIME, IN nrPasengers INT(11), OUT outReservationId INT(11))
BEGIN
  CALL addReservationProper(inDepartureAirport, inArrivalAirport, inYear, inWeek, inDay, inTime, outReservationId);
END//
delimiter ;

# -----------------

SELECT 'Add procedure addPassenger' AS '';
DROP PROCEDURE IF EXISTS addPassenger;
delimiter //
CREATE PROCEDURE addPassenger(IN inReservationId INT(11),IN inPassportNr VARCHAR(45), IN inName VARCHAR(45))
BEGIN
IF (SELECT COUNT(*) FROM Reservations WHERE idReservations=inReservationId) != 0 THEN
  IF (SELECT COUNT(*) FROM Passengers WHERE passportNr=inPassportNr) = 0
  THEN
    INSERT INTO Passengers(passportNr, name) VALUES(inPassportNr, inName);
  END IF;
  INSERT INTO ResPass(idReservations, passportNr) VALUES(inReservationId, inPassportNr);
END IF;
END//
delimiter ;

# -----------------

SELECT 'Add procedure addContact' AS '';
DROP PROCEDURE IF EXISTS addContact;
delimiter //
CREATE PROCEDURE addContact(IN inReservationId INT(11),IN inPassportNr VARCHAR(45), IN inMail VARCHAR(255), IN inPhoneNumber BIGINT)
BEGIN
IF (SELECT COUNT(*) FROM ResPass
    WHERE idReservations=inReservationId AND
    passportNr = inPassportNr) != 0 THEN
  IF (SELECT COUNT(*) FROM Contacts WHERE passportNr=inPassportNr) = 0
  THEN
    INSERT INTO Contacts(passportNr, email, phoneNumber) VALUES(inPassportNr, inMail, inPhoneNumber);
  END IF;
  UPDATE Reservations SET contact = inPassportNr WHERE idReservations=inReservationId;
END IF;
END//
delimiter ;

# -----------------

SELECT 'Add procedure addPayment' AS '';
DROP PROCEDURE IF EXISTS addPayment;
delimiter //
CREATE PROCEDURE addPayment(IN inReservationId INT(11), IN inCardHolderName VARCHAR(45), IN inCreditCardNumber BIGINT(255))
BEGIN
IF calculateFreeSeats((SELECT flight FROM Reservations WHERE idReservations=inReservationId)) >= (SELECT COUNT(*) FROM ResPass WHERE idReservations=inReservationId) THEN
  IF (SELECT COUNT(*) FROM Reservations WHERE idReservations=inReservationId) != 0 THEN
    INSERT INTO Payments(idReservations, cardHolderName, creditCardNumber) VALUES(inReservationId, inCardHolderName, inCreditCardNumber);
    END IF;
ELSE
  SELECT 'Not enough free seats on plane!' AS '';
END IF;
END//
delimiter ;

# -----------------

SELECT 'Create view for all flights' AS '';
CREATE OR REPLACE VIEW allFlights AS SELECT
FromAirport.name AS departure_city_name,
ToAirport.name AS destination_city_name,
WeeklySchedule.departureTime AS departure_time,
Weekday.name AS departure_day,
Flights.weekNr AS departure_week,
Year.year AS departure_year,
calculateFreeSeats(Flights.idFlights) AS nr_of_free_seats,
calculatePrice(Flights.idFlights) AS current_price_per_seat

FROM
Flights,
WeeklySchedule,
Route,
Weekday,
Year,
Destination AS FromAirport,
Destination AS ToAirport

WHERE
Flights.weeklySchedule=WeeklySchedule.idWeeklySchedule AND
WeeklySchedule.route=Route.idRoute AND
Route.fromAirport=FromAirport.airportId AND
Route.toAirport=ToAirport.airportId AND
WeeklySchedule.weekday=Weekday.idWeekday AND
Route.year=Year.idYear;
