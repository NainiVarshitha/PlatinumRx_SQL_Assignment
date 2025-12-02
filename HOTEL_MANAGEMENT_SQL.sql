--creating users table--
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address VARCHAR(200)
);
--inserting values into users table--
INSERT INTO users VALUES
('21wrcxuy-67erfn', 'John Doe', '97XXXXXXXX', 'john.doe@example.com', 'XX, Street Y, ABC City');
--retreving all records from users table--
SELECT * FROM users;
--creating bookings table--
CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
--inserting data into bookings table--
INSERT INTO bookings VALUES
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn');
--retreving all records from bookings table--
SELECT * FROM bookings;
--creating booking_commercials table--
CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
--inserting values into the booking_commercials table--
INSERT INTO booking_commercials VALUES
('q34r-3q4o8-q34u', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('q3o4-ahf32-o2u4', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1);
--retreving all records from booking_commercials--
SELECT * FROM booking_commercials;
--creating items table--
CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100),
    item_rate DECIMAL(10,2)
);
--entering values into the items table--
INSERT INTO items VALUES
('itm-a9e8-q8fu', 'Tawa Paratha', 18),
('itm-a07vh-aer8', 'Mix Veg', 89);
--retreving all records from the items table--
SELECT * FROM items;
--1st question--for every user in the sysytem,get the user_id and last booked room--
SELECT 
    u.user_id,
    u.name,
    MAX(b.booking_date) AS last_booking_date
FROM users u
LEFT JOIN bookings b 
    ON u.user_id = b.user_id
GROUP BY u.user_id, u.name;
--2nd question required coloumns--
SELECT * 
FROM bookings 
WHERE booking_date BETWEEN '2021-11-01' AND '2021-11-30';
SELECT * 
FROM booking_commercials;
SELECT * 
FROM items;
--2nd question--get booking_id and total billing amount of every booking created in november,2021--
SELECT b.booking_id, 
       SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE b.booking_date BETWEEN '2021-09-01' AND '2021-09-30'
GROUP BY b.booking_id;
--3rd question--get bill_id and bill_amount of the bills raised in october,2021 having bill amount>1000--
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;
--4th question--determine the most ordered and leas ordered item of each month of year 2021--
WITH monthly_item_sales AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        i.item_id,
        i.item_name,
        SUM(bc.item_quantity) AS total_quantity
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, i.item_id, i.item_name
),
ranked_items AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_quantity DESC) AS most_ordered_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_quantity ASC) AS least_ordered_rank
    FROM monthly_item_sales
)
SELECT month, item_id, item_name, total_quantity, 'Most Ordered' AS type
FROM ranked_items
WHERE most_ordered_rank = 1
UNION ALL
SELECT month, item_id, item_name, total_quantity, 'Least Ordered' AS type
FROM ranked_items
WHERE least_ordered_rank = 1
ORDER BY month, type;
--5th question--find the customers with the second highest bill value of each month of year 2021--
WITH monthly_bill_amount AS (
    SELECT 
        u.user_id,
        u.name,
        bc.bill_id,
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM users u
    JOIN bookings b ON u.user_id = b.user_id
    JOIN booking_commercials bc ON b.booking_id = bc.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, u.user_id, u.name, bc.bill_id
),
ranked_bills AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS bill_rank
    FROM monthly_bill_amount
)
SELECT month, user_id, name, bill_id, bill_amount
FROM ranked_bills
WHERE bill_rank = 2 OR bill_rank = 1 AND NOT EXISTS (
    SELECT 1 
    FROM ranked_bills rb2 
    WHERE rb2.month = ranked_bills.month AND rb2.bill_rank = 2
)
ORDER BY month;

