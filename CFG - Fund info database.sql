CREATE DATABASE Project;
USE Project;

#Table 1 - Fund basic info
#Setting up Primary key
CREATE TABLE fundinfo (
	fund_id varchar(5) NOT NULL ,
    fund_name varchar(50) NOT NULL,
    launchdate date NOT NULL,
	PRIMARY KEY (fund_id)
    ); 
    
INSERT INTO fundinfo VALUES
	('F1','Global Fund', '2000-01-02'),
    ('F2','World Fund', '1990-01-02'),
    ('F3','Developed Fund', '1990-01-02'),
    ('F4','Random Fund', '2022-01-02'),
    ('F5','All Fund', '2006-01-02');
    
#Table 2.1 - Fund size for Q1
#Setting up Secondary key
create table q1_f_size(
	period varchar(5) NOT NULL,
	fund_id varchar(5) NOT NULL,
    fund_size_£ int,
    CONSTRAINT PK_f_size PRIMARY KEY (period,fund_id),
	FOREIGN KEY (fund_id) REFERENCES fundinfo(fund_id)) ;
select * from fund_region_breakdown;

INSERT INTO q1_f_size VALUES
	('Q1', 'F1', 2),
    ('Q1', 'F2', 4),
    ('Q1', 'F3', 6),
    ('Q1', 'F4', 8),
    ('Q1', 'F5', 10);
    
#Table 2.2 - Fund size for Q2
create table q2_f_size(
	period varchar(5) NOT NULL,
	fund_id varchar(5) NOT NULL,
    fund_size_£ int,
    CONSTRAINT PK_f_size PRIMARY KEY (period,fund_id),
	FOREIGN KEY (fund_id) REFERENCES fundinfo(fund_id)) ;
    
INSERT INTO q2_f_size VALUES
	('Q2', 'F1', 10),
    ('Q2', 'F2', 4),
    ('Q2', 'F3', 12),
    ('Q2', 'F4', 20),
    ('Q2', 'F5', 2);
    
#Table 3 - Fund Manager details
create table fund_manager(
	fund_id varchar(5) NOT NULL,
    fund_manager_name varchar(50),
    management_company varchar(50) NOT NULL,
    management_since date NOT NULL,
	FOREIGN KEY (fund_id) REFERENCES fundinfo(fund_id)) ;

 INSERT INTO fund_manager VALUES
	('F1', 'John Smith', 'ABC Company', '2000-01-02'),
    ('F2', 'David Johnson', 'XYZ Ltd', '1990-01-02'),
    ('F3', 'May Potter', 'ABC Company', '1990-01-02'),
    ('F4', 'May Potter', 'ABC Company', '2022-01-02'),
    ('F5', 'Lily Smith', 'XYZ Ltd', '2006-01-02');
    
#Table 4 - Fund Asset Class Breakdown
create table fund_asset_breakdown(
	fund_id varchar(5) NOT NULL,
    fund_name varchar(50) NOT NULL,
    asset_type varchar(50) NOT NULL,
    asset_portion float (3.2) NOT NULL,
	FOREIGN KEY (fund_id) REFERENCES fundinfo(fund_id)) ;
    
INSERT INTO fund_asset_breakdown VALUES
	('F1', 'Bond', 0.5 ),
	('F1', 'Equity', 0.5),
    ('F2', 'Bond', 0.2),
    ('F2', 'Equity', 0.8),    
    ('F3', 'Bond', 0.7),
	('F3', 'Equity', 0.3),
    ('F4', 'Bond', 1),
    ('F5', 'Equity', 1);
    
#Table 5 - Fund Region Breakdown
create table fund_region_breakdown (
	fund_id varchar(5) NOT NULL,
    region varchar(50) NOT NULL,
    portion float (3.2) NOT NULL,
	FOREIGN KEY (fund_id) REFERENCES fundinfo(fund_id)) ;	

INSERT INTO fund_region_breakdown VALUES
	('F1', 'North America', 0.2 ),
    ('F1', 'Europe ex UK', 0.2 ),
    ('F1', 'Emerging Markets', 0.2 ),
	('F1', 'Japan', 0.2),
    ('F1', 'Pacific ex Japan', 0.2 ),
	('F2', 'North America', 0.5 ),
    ('F2', 'Europe ex UK', 0.1 ),
    ('F2', 'Emerging Markets', 0.1 ),
	('F2', 'Japan', 0.1),
    ('F2', 'Pacific ex Japan', 0.2 ),
	('F3', 'Europe', 1),
    ('F4', 'North America', 1),
    ('F5', 'Emerging Markets', 0.8),
	('F5', 'Emerging Markets', 0.2);

###??
SELECT DISTINCT fundinfo.fund_id, fundinfo.fund_name, fund_region_breakdown.region, fund_region_breakdown.portion
From fundinfo
RIGHT JOIN fund_region_breakdown ON fundinfo.fund_id = fund_region_breakdown.fund_id
GROUP BY fundinfo.fund_id ;
    
    
SELECT fundinfo.fund_id, fundinfo.fund_name, fund_asset_breakdown.asset_type, fund_asset_breakdown.asset_portion, fund_region_breakdown.region, fund_region_breakdown.portion
FROM fundinfo

RIGHT JOIN fund_asset_breakdown ON fundinfo.fund_id = fund_asset_breakdown.fund_id
RIGHT  JOIN fund_region_breakdown ON fundinfo.fund_id = fund_region_breakdown.fund_id
WHERE fundinfo.fund_id = 'F1';

#Create a view for customer to see which fund manger is doing better 
CREATE VIEW performance_comparison AS
#select q1 and q2 fund sizes, and simple growth formular for comparison, round to 2 dp
SELECT q1.fund_id, fm.fund_manager_name , fm.management_company, q1.fund_size_£ as q1_fund_size_£ , q2.fund_size_£ as q2_fund_size_£,   
ROUND ((q2.fund_size_£- q1.fund_size_£)/q1.fund_size_£,2) as growth  
FROM q1_f_size as q1
JOIN fund_manager as fm ON q1.fund_id = fm.fund_id
JOIN q2_f_size as q2 ON q1.fund_id= q2.fund_id
ORDER BY growth DESC;

select * from performance_comparison;

###stored function to provide status to the funds according to their fund sizes
DELIMITER //
CREATE FUNCTION Fund_Status(
    fund_size_£ INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE Fund_Status VARCHAR(20);
    IF fund_size_£ >= 5 THEN
        SET Fund_Status = 'Developed';
    ELSEIF fund_size_£ < 5 THEN
        SET Fund_Status = 'Developing';
    END IF;
    RETURN (Fund_Status);
END//Fund_Status
DELIMITER ;


#check fund status for q1
select * , Fund_Status(fund_size_£)
from q1_f_size;

#compare the fund status between q1 and q2, look for those with change of status
select  q1.fund_id, q1.period, Fund_Status(q1.fund_size_£),  q2.period, Fund_Status(q2.fund_size_£)
from q1_f_size as q1
join q2_f_size as q2 on q1.fund_id = q2.fund_id
where Fund_Status(q1.fund_size_£) != Fund_Status(q2.fund_size_£);


# Subquery - What would be the asset breakdown of the fund, if customer only wants to invest in North America?
SELECT fundinfo.fund_id, fundinfo.fund_name,  ab.asset_type, ab.asset_portion
FROM fund_asset_breakdown as ab
JOIN fundinfo ON ab.fund_id = fundinfo.fund_id
WHERE ab.fund_id = 
#the fund should only invest in N.America
(SELECT fund_id
FROM fund_region_breakdown
WHERE region = 'North America' AND portion = 1);


#Stored procedure to look for fund managed by specific management company 
DELIMITER $$
-- Create Stored Procedure
CREATE PROCEDURE Filter_company(
IN company VARCHAR(100))
BEGIN
select fund_manager.fund_id, fundinfo.fund_name, fund_manager.management_company
from fund_manager 
join fundinfo on fundinfo.fund_id = fund_manager.fund_id
where management_company = company;
END$$
-- Change Delimiter again
DELIMITER ;

CALL Filter_company ('ABC Company');

#Trigger - log for launching new fund
create table new_fund_msg(
	fund_name varchar(50),
    launchdate varchar(50),
    msg varchar(50));
    
    
DELIMITER $$
CREATE
	TRIGGER new_fund_trigger BEFORE INSERT ON fundinfo
    FOR EACH ROW BEGIN 
		INSERT INTO new_fund_msg VALUES (NEW.fund_name, New.launchdate, 'A new fund is added.');
	END$$
DELIMITER ;

INSERT INTO fundinfo VALUES
	('F8','Global Fund', '2000-01-02');
    
    
drop table new_fund_msg;
drop TRIGGER new_fund_trigger;

#Event - set up quarterly reminder to input fund size data
CREATE TABLE quarterlyinput_reminder
(quarter_number INT NOT NULL AUTO_INCREMENT,
reminder varchar(50),
update_date  DATE,
PRIMARY KEY (Quarter_number));
-- Change Delimiter
DELIMITER //
CREATE EVENT recurring_time_event
ON SCHEDULE EVERY 1 second
STARTS NOW()
DO BEGIN
	INSERT INTO quarterlyinput_reminder(reminder, update_date)
	VALUES ('Time to input Fund Size data', NOW());
END//
-- Change Delimiter
DELIMITER ;
-- Select Data
SELECT *
FROM quarterlyinput_reminder
ORDER BY Quarter_number DESC;

DROP TABLE quarterlyinput_reminder;
DROP EVENT recurring_time_event;

#Customer is looking for a fund that invests in at least 5 different regions
SELECT rb.fund_id, fundinfo.fund_name, COUNT(rb.region) as number_of_regions_invested_in 
FROM fund_region_breakdown as rb
JOIN fundinfo ON fundinfo.fund_id = rb.fund_id
GROUP BY rb.fund_id
HAVING COUNT(rb.region) >=5;
