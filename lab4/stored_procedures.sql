SELECT 'Add procedure addYear for inserting new year' AS '';
delimiter //
CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO Year (Year, Profitfactor) VALUES ( year, factor );
END//
delimiter ;

SELECT 'Add procedure addDay for inserting new weekday into schedule' AS '';
delimiter //
CREATE PROCEDURE addDay (IN year INT, IN day VARCHAR(45), IN factor DOUBLE) BEGIN INSERT INTO Weekday (Name, WeekdayFactor, Year) VALUES (day, factor, (SELECT idYear FROM Year WHERE Year=year)); END//
delimiter ;
