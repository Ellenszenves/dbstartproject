-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE categories (
    category_id SERIAL,
    category_name character varying(15) NOT NULL UNIQUE,
    description text
);

-- Name: customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE customers (
    customer_id SERIAL,
    company_name character varying(40),
    contact_name character varying(30) NOT NULL UNIQUE,
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    tax character varying(24)
);

-- Name: employees; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE employees (
    employee_id SERIAL,
    employee_name varchar(40) NOT NULL UNIQUE,
    title character varying(30),
    title_of_courtesy character varying(25),
    birth_date date,
    hire_date date,
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    extension character varying(4),
    photo bytea,
    notes text,
    reports_to smallint,
    photo_path character varying(255)
);

-- Name: employee_territories; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE employee_territories (
    employee_id smallint NOT NULL,
    territory_id character varying(20) NOT NULL
);

-- Name: order_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE order_details (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL
);

-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE orders (
    order_id SERIAL,
    customer_id bpchar,
    employee_id smallint,
    order_date date,
    required_date date,
    company_id int,
    order_status varchar(8)
);

-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE products (
    product_id serial,
    product_name character varying(40) NOT NULL UNIQUE,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit character varying(20),
    unit_price real,
    units_in_stock smallint,
    units_on_order smallint,
    reorder_level smallint,
    discontinued integer DEFAULT '0'
);

-- Name: region; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE region (
    region_id smallint NOT NULL,
    region_description bpchar NOT NULL
);

-- Name: shippers; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE shippers (
    shipper_id smallint NOT NULL,
    company_name character varying(40) NOT NULL,
    phone character varying(24)
);

-- Name: suppliers; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE suppliers (
    supplier_id smallint NOT NULL,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24),
    homepage text
);

-- Name: territories; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE territories (
    territory_id character varying(20) NOT NULL,
    territory_description bpchar NOT NULL,
    region_id smallint NOT NULL
);

-- Name: us_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 

CREATE TABLE us_states (
    state_id smallint NOT NULL,
    state_name character varying(100),
    state_abbr character varying(2),
    state_region character varying(50)
);

-- Ezt nézi meg a funkció, ami alapján eldönti, hogy renben üzemel e az adatbázis.

CREATE TABLE teszt (
    teszt varchar(5)
);

INSERT INTO teszt VALUES ('aaaaa');

CREATE TABLE company (
    comp_id SERIAL,
    comp_name varchar(30),
    comp_city varchar(20),
    comp_address varchar(50),
    comp_phone varchar(20),
    comp_country varchar(30),
    comp_zipcode varchar(10)
);

INSERT INTO company (comp_name, comp_city, comp_address, comp_phone, comp_country, comp_zipcode) 
VALUES ('Teszt kft.', 'Makó', 'Teszt utca 16.', '06301234567', 'Magyarország', '6900');