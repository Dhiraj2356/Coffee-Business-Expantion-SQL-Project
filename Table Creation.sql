---Tables Creation for GoodLuck Coffee db

create table city (
	city_id	 int primary key,
	city_name  varchar(50),	 	
	population	bigint,
	estimated_rent	numeric(10,2),
	city_rank int

);

create table customers (
	customer_id	int primary key,
	customer_name	varchar(50),
	city_id int,
	constraint fk_city FOREIGN KEY (city_id) references city(city_id)

);


create table products (
	product_id	int primary key,
	product_name varchar(50),
	price numeric(10,2)

);


create table sales (
	sale_id	 int primary key,
	sale_date	date,
	product_id	int,
	customer_id	int,
	total	numeric(10,2),
	rating float,
	constraint fk_product foreign key (product_id) references products(product_id),
	constraint fk_customer foreign key (customer_id) references customers(customer_id)

);
