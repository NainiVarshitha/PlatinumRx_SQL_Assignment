

CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

INSERT INTO clinics (cid, clinic_name, city, state, country)
VALUES
('cnc-0100001', 'XYZ clinic', 'lorem', 'ipsum', 'dolor');

SELECT * FROM clinics;

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(20)
);

INSERT INTO customer (uid, name, mobile)
VALUES
('bk-09f3e-95hj', 'Jon Doe', '97XXXXXXXX');

SELECT * FROM customer;

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount DECIMAL(10,2),
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

INSERT INTO clinic_sales (oid, uid, cid, amount, datetime, sales_channel)
VALUES
('ord-00100-00100', 'bk-09f3e-95hj', 'cnc-0100001', 24999, '2021-09-23 12:03:22', 'sodat');

SELECT * FROM clinic_sales;

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(200),
    amount DECIMAL(10,2),
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);
INSERT INTO expenses (eid, cid, description, amount, datetime)
VALUES
('exp-0100-00100', 'cnc-0100001', 'first-aid supplies', 557, '2021-09-23 07:36:48');

SELECT * FROM expenses;

SELECT sales_channel,
       SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel
ORDER BY total_revenue DESC;

SELECT c.uid,
       c.name,
       SUM(cs.amount) AS total_spent
FROM customer c
JOIN clinic_sales cs ON c.uid = cs.uid
WHERE YEAR(cs.datetime) = 2021
GROUP BY c.uid, c.name
ORDER BY total_spent DESC
LIMIT 10;

SELECT DATE_FORMAT(cs.datetime, '%Y-%m') AS month,
       SUM(cs.amount) AS revenue,
       COALESCE(SUM(e.amount),0) AS expense,
       SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit,
       CASE 
           WHEN SUM(cs.amount) - COALESCE(SUM(e.amount),0) > 0 THEN 'Profitable'
           ELSE 'Not-Profitable'
       END AS status
FROM clinic_sales cs
LEFT JOIN expenses e 
       ON cs.cid = e.cid 
       AND MONTH(cs.datetime) = MONTH(e.datetime)
       AND YEAR(cs.datetime) = YEAR(e.datetime)
WHERE YEAR(cs.datetime) = 2021
GROUP BY month
ORDER BY month;

WITH clinic_profit AS (
    SELECT cl.city,
           cs.cid,
           SUM(cs.amount) AS revenue,
           COALESCE(SUM(e.amount),0) AS expense,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics cl
    JOIN clinic_sales cs ON cl.cid = cs.cid
    LEFT JOIN expenses e 
           ON cs.cid = e.cid 
           AND MONTH(e.datetime) = 9      
           AND YEAR(e.datetime) = 2021   
    WHERE YEAR(cs.datetime) = 2021
      AND MONTH(cs.datetime) = 9         
    GROUP BY cl.city, cs.cid
)
SELECT city, cid, profit
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
) ranked
WHERE rnk = 1;



INSERT INTO clinics (cid, clinic_name, city, state, country)
VALUES
('cnc-0100002', 'ABC Clinic', 'lorem', 'ipsum', 'dolor'),
('cnc-0100003', 'DEF Clinic', 'ipsum', 'ipsum', 'dolor');

INSERT INTO clinic_sales (oid, uid, cid, amount, datetime, sales_channel)
VALUES
('ord-00100-00101', 'bk-09f3e-95hj', 'cnc-0100002', 15000, '2021-09-23 12:03:22', 'online'),
('ord-00100-00102', 'bk-09f3e-95hj', 'cnc-0100003', 10000, '2021-09-23 12:03:22', 'offline');

INSERT INTO expenses (eid, cid, description, amount, datetime)
VALUES
('exp-0100-00101', 'cnc-0100002', 'supplies', 2000, '2021-09-23 07:36:48'),
('exp-0100-00102', 'cnc-0100003', 'supplies', 1000, '2021-09-23 07:36:48');

WITH clinic_profit AS (
    SELECT cl.state,
           cs.cid,
           SUM(cs.amount) AS revenue,
           COALESCE(SUM(e.amount),0) AS expense,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics cl
    JOIN clinic_sales cs ON cl.cid = cs.cid
    LEFT JOIN expenses e 
           ON cs.cid = e.cid 
           AND MONTH(e.datetime) = 9     
           AND YEAR(e.datetime) = 2021    
    WHERE YEAR(cs.datetime) = 2021
      AND MONTH(cs.datetime) = 9         
    GROUP BY cl.state, cs.cid
)
SELECT state, cid, profit
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
) ranked
WHERE rnk = 2;

