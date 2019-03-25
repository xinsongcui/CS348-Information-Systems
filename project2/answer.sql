set serveroutput on size 32000

-- Question 1: CarRentalSiteDetail detail
create or replace procedure CarRentalSiteDetail (id IN CarRentalSite.CarRentalSiteId%TYPE) as 
num_rentals number;
most_popular_car varchar(30);
largest_rental_days integer;
name CarRentalSite.CarRentalSiteName%TYPE;
city CarRentalSite.City%TYPE;
CURSOR enr_cur is SELECT CarRentalSiteName, City FROM CarRentalSite WHERE CarRentalSiteId=id;
enr_rec enr_cur%ROWTYPE;
CURSOR ren_cur is SELECT CarId, numOfDays  FROM Rentals WHERE CarRentalSiteId=id;
ren_rec ren_cur%ROWTYPE;
CURSOR car_cur is SELECT CarId, CarName, Category FROM Car;
car_rec car_cur%ROWTYPE;

BEGIN
	for enr_rec in enr_cur loop
		name := enr_rec.CarRentalSiteName;
		city := enr_rec.City;
		dbms_output.put_line('CarRentalSite Name: ' || name);
		dbms_output.put_line('CarRentalSite City: ' || city);
	end loop;
	
	num_rentals := 0;
	largest_rental_days := 0;
	
	for ren_rec in ren_cur loop
		num_rentals := num_rentals + 1;
		for car_rec in car_cur loop
			IF ren_rec.CarID=car_rec.CarID THEN	
				IF car_rec.Category='compact' THEN		
					IF ren_rec.numOfDays>largest_rental_days THEN
						most_popular_car:= car_rec.CarName;
						largest_rental_days := ren_rec.numOfDays;
					END IF;
				END IF;
			END IF;
		end loop;
	end loop;

	dbms_output.put_line('CarRentalSite Total Rentals: ' || num_rentals);
	dbms_output.put_line('Most Popular Compact Car: ' || most_popular_car);
	dbms_output.put_line('Total Days Rented: ' || largest_rental_days);

END CarRentalSiteDetail;
/

BEGIN
CarRentalSiteDetail(1); 
end;
/


-- Question 2:
create or replace procedure MonthlyBusinessRentalsReport1 as

CURSOR ren_cur is select  extract(year from RentalDate) as y, extract(month from RentalDate) as m, count(CarRentalSiteId) as c from Rentals where Status='BUSINESS' 
group by extract(year from RentalDate), extract(month from RentalDate) order by y, m;
ren_rec ren_cur%ROWTYPE;

CURSOR site_cur is select CarRentalSiteId, CarRentalSiteName from CarRentalSite order by CarRentalSiteName;
site_rec site_cur%ROWTYPE;

CURSOR rent_cur is select CarRentalSiteId, numOfDays, extract(year from RentalDate) as yr, extract(month from RentalDate) as mo from Rentals where Status='BUSINESS';
rent_rec rent_cur%ROWTYPE;

year integer;
month integer;
totalbus integer;
days integer;
site_ID integer;
site_Name varchar(255);

BEGIN

	for ren_rec in ren_cur loop
		year := ren_rec.y;
		month := ren_rec.m;
		days := ren_rec.c;
		dbms_output.put_line('Total Business Rentals in ' || year || '-' || month || ': ' || days);
		dbms_output.put_line('In Car Rental Sites: ');
		
		for site_rec in site_cur loop
			site_Name := site_rec.CarRentalSiteName;
			site_ID := site_rec.CarRentalSiteId;
			totalbus := 0;
			for rent_rec in rent_cur loop
				IF rent_rec.CarRentalSiteId = site_ID THEN
					IF rent_rec.yr = year then
						IF rent_rec.mo = month then
							totalbus := totalbus + rent_rec.numOfDays;
						end IF;
					end IF;
				end IF;
				
			end loop;
			IF totalbus != 0 then
				dbms_output.put_line('- ' || site_Name || ': ' || totalbus || ' days' );
			end IF;
		end loop;
		
	end loop;
	
END MonthlyBusinessRentalsReport1;
/
BEGIN
        MonthlyBusinessRentalsReport1;
End;
/


-- Question 3:
create or replace procedure MostandLeastProfitCarIndiana as

cars number;
avg_profit number;
num_cars number;
category varchar(255);
min_profit number;
min_name varchar(255);
max_profit number;
max_name varchar(255);

num_temp number;
avg_temp number;

CURSOR car_cur is SELECT Car.CarId, Car.CarName, Car.Category, Car.DealerId, Car.SuggestedDealerRentalPrice, CarDealers.State FROM CarDealers JOIN Car ON CarDealers.DealerId = Car.DealerId WHERE CarDealers.State = 'IN' ORDER BY Car.Category, Car.CarName ASC;
car_rec car_cur%ROWTYPE;

CURSOR cart_cur is SELECT Car.CarId, Car.CarName, Car.Category, Car.SuggestedDealerRentalPrice FROM CarDealers JOIN Car ON CarDealers.DealerId = Car.DealerId WHERE CarDealers.State = 'IN' ORDER BY Car.Category, Car.CarName ASC;
cart_rec cart_cur%ROWTYPE;

CURSOR ren_cur is SELECT CarId, RentalRate FROM Rentals;
ren_rec ren_cur%ROWTYPE;


BEGIN
	min_profit := 10000;
	max_profit := 0;
	category := 'none';

	for car_rec in car_cur loop
		avg_profit := 0;
		num_cars := 0;
		IF car_rec.Category != category and category != 'none' THEN
			dbms_output.put_line('Least Profit in ' || Category);
			for cart_rec in cart_cur loop
				avg_temp := 0;
				num_temp := 0;
				IF category = cart_rec.Category then
					for ren_rec in ren_cur loop
						IF cart_rec.CarId=ren_rec.CarId	THEN
							avg_temp := avg_temp + ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice;
							num_temp := num_temp + 1;
						end IF;
					end loop;
					avg_temp := avg_temp/num_temp;
					IF avg_temp = min_profit then
						min_name := cart_rec.CarName;
						
						dbms_output.put_line('- ' || min_name || ': ' || avg_temp);
					end IF;
				end IF;
			end loop;
			min_profit := 10000;
		end IF;
		for ren_rec in ren_cur loop
			IF car_rec.CarId=ren_rec.CarId	THEN
				avg_profit := avg_profit + ren_rec.RentalRate - car_rec.SuggestedDealerRentalPrice;
				num_cars := num_cars + 1;
			end IF;
		end loop;
		avg_profit := avg_profit/num_cars;		
		IF avg_profit < min_profit THEN
			min_profit := avg_profit;		
		end IF;
		category := car_rec.Category;
	end loop;
	dbms_output.put_line('Least Profit in ' || Category);
	for cart_rec in cart_cur loop
		avg_temp := 0;
		num_temp := 0;
		IF category = cart_rec.Category then
			for ren_rec in ren_cur loop
				IF cart_rec.CarId=ren_rec.CarId	THEN
					avg_temp := avg_temp + ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice;
					num_temp := num_temp + 1;
				end IF;
			end loop;
			avg_temp := avg_temp/num_temp;
			IF avg_temp = min_profit then
				min_name := cart_rec.CarName;
						
				dbms_output.put_line('- ' || min_name || ': ' || avg_temp);
			end IF;
		end IF;
	end loop;

	category := 'none';

	for car_rec in car_cur loop
		avg_profit := 0;
		num_cars := 0;
		IF car_rec.Category != category and category != 'none' THEN
			dbms_output.put_line('Most Profit in ' || Category);
			for cart_rec in cart_cur loop
				avg_temp := 0;
				num_temp := 0;
				IF category = cart_rec.Category then
					for ren_rec in ren_cur loop
						IF cart_rec.CarId=ren_rec.CarId	THEN
							avg_temp := avg_temp + ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice;
							num_temp := num_temp + 1;
						end IF;
					end loop;
					avg_temp := avg_temp/num_temp;
					IF avg_temp = max_profit then
						max_name := cart_rec.CarName;		
						dbms_output.put_line('- ' || max_name || ': ' || avg_temp);
					end IF;
				end IF;
			end loop;
			max_profit := 0;
		end IF;
			
		
		
		for ren_rec in ren_cur loop
			IF car_rec.CarId=ren_rec.CarId	THEN
				avg_profit := avg_profit + ren_rec.RentalRate - car_rec.SuggestedDealerRentalPrice;
				num_cars := num_cars + 1;
			end IF;
		end loop;
		avg_profit := avg_profit/num_cars;		
		IF avg_profit > max_profit THEN
			max_profit := avg_profit;
			max_name := car_rec.CarName;
		end IF;
		category := car_rec.Category;
	end loop;

	dbms_output.put_line('Most Profit in ' || Category);
	for cart_rec in cart_cur loop
		avg_temp := 0;
		num_temp := 0;
		IF category = cart_rec.Category then
			for ren_rec in ren_cur loop
				IF cart_rec.CarId=ren_rec.CarId	THEN
					avg_temp := avg_temp + ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice;
					num_temp := num_temp + 1;
				end IF;
			end loop;
			avg_temp := avg_temp/num_temp;
			IF avg_temp = max_profit then
				max_name := cart_rec.CarName;
						
				dbms_output.put_line('- ' || max_name || ': ' || avg_temp);
			end IF;
		end IF;
	end loop;

END MostandLeastProfitCarIndiana; 
/

BEGIN
        MostandLeastProfitCarIndiana;
END;
/


-- Question 4:

create table BusinessRentalCategoryTable(CarRentalSiteId integer, Compact integer, Luxury integer, SUV integer, primary key(CarRentalSiteId));
create or replace procedure BusinessRentalCategory as

num_compact integer;
num_luxury integer;
num_SUV integer;
site_ID integer;
site_num integer;
CURSOR ren_cur is SELECT CarId, CarRentalSiteId, Status FROM Rentals WHERE Status = 'BUSINESS';
ren_rec ren_cur%ROWTYPE;
CURSOR car_cur is SELECT CarId, Category FROM Car;
car_rec car_cur%ROWTYPE;
CURSOR site_cur is select CarRentalSiteId from CarRentalSite;
site_rec site_cur%ROWTYPE;

BEGIN
site_ID := 1;
FOR site_rec IN site_cur LOOP
	num_compact := 0;
	num_luxury := 0;
	num_SUV := 0;
	for ren_rec in ren_cur loop
		IF ren_rec.CarRentalSiteId = site_ID THEN
			for car_rec in car_cur loop 
				IF car_rec.CarId = ren_rec.CarId THEN
					IF car_rec.Category = 'compact' THEN
						num_compact := num_compact + 1;
					end IF;
					IF car_rec.Category = 'luxury' THEN
						num_luxury := num_luxury + 1;
					end IF;
					IF car_rec.Category = 'SUV' THEN
						num_SUV := num_SUV + 1;
					end IF;
				end IF;
			end loop;
		end IF;
		
	end loop;
	INSERT INTO BusinessRentalCategoryTable VALUES (site_ID, num_compact, num_luxury, num_SUV);
	site_ID := site_ID + 1;
END LOOP;

END BusinessRentalCategory;
/     

BEGIN
BusinessRentalCategory;
END;
/
select * from BusinessRentalCategoryTable;

drop table BusinessRentalCategoryTable;



-- Question 5:

create or replace procedure CarCategoryInventoryInfo(crsid IN CarRentalSite.CarRentalSiteId%TYPE) as
CURSOR exe_cur is SELECT CarRentalSiteId FROM CarRentalSite WHERE CarRentalSiteId=crsid;

CURSOR enr_cur is SELECT CarRentalSiteName, City, CarRentalSiteId FROM CarRentalSite WHERE CarRentalSiteId=crsid order by CarRentalSiteName ASC;
enr_rec enr_cur%ROWTYPE;
CURSOR ren_cur is SELECT distinct Car.CarId, Car.CarName, Rentals.CarRentalSiteId FROM Car join Rentals On Rentals.CarId = Car.CarId order by Car.CarName ASC;
ren_rec ren_cur%ROWTYPE;
CURSOR inv_cur is SELECT CarRentalSiteId, CarId, TotalCars FROM RentalInventories;
inv_rec inv_cur%ROWTYPE;
site_Name varchar(255);
car_Name varchar(255);
car_Num integer;
site_ID integer;

sb exception;

BEGIN
dbms_output.put_line('CarRentalSiteId: ' || crsid);
open exe_cur;
fetch exe_cur into site_ID;
IF exe_cur%notfound then
	raise sb;
end if;


for enr_rec in enr_cur loop
	site_Name := enr_rec.CarRentalSiteName;
	
	
	dbms_output.put_line('CarRentalSiteName: ' || site_Name);
	for ren_rec in ren_cur loop
		IF ren_rec.CarRentalSiteId = enr_rec.CarRentalSiteId THEN
			car_Name := ren_rec.CarName;
			for inv_rec in inv_cur loop
				IF inv_rec.CarId = ren_rec.CarId THEN
						IF inv_rec.CarRentalSiteId = ren_rec.CarRentalSiteId THEN
							car_Num := inv_rec.TotalCars;
						end IF;

				end IF;
			end loop;
			dbms_output.put_line('CarName: ' || car_Name || ': ' || car_Num);	
		end IF;
	end loop;
end loop;
	
exception
	when sb then
		dbms_output.put_line('Invalid CarRentalSiteId!');	
END CarCategoryInventoryInfo;
/

BEGIN
CarCategoryInventoryInfo(1);
END;
/

BEGIN
CarCategoryInventoryInfo(111);
END;
/

