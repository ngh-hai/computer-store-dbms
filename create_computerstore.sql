--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS computerstore;
--
-- Name: computerstore; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE computerstore WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Vietnamese_Vietnam.1258';


ALTER DATABASE computerstore OWNER TO postgres;

\connect computerstore

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE computerstore; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE computerstore IS 'Database Lab Project';


--
-- Name: brand; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA brand;


ALTER SCHEMA brand OWNER TO postgres;

--
-- Name: customer; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA customer;


ALTER SCHEMA customer OWNER TO postgres;

--
-- Name: employee; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA employee;


ALTER SCHEMA employee OWNER TO postgres;

--
-- Name: order; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "order";


ALTER SCHEMA "order" OWNER TO postgres;

--
-- Name: product; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA product;


ALTER SCHEMA product OWNER TO postgres;

--
-- Name: store; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA store;


ALTER SCHEMA store OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cpu_brand; Type: TABLE; Schema: brand; Owner: postgres
--

CREATE TABLE brand.cpu_brand (
    brand_id integer NOT NULL,
    brand_name character varying(50) NOT NULL
);


ALTER TABLE brand.cpu_brand OWNER TO postgres;

--
-- Name: cpu_brand_brand_id_seq; Type: SEQUENCE; Schema: brand; Owner: postgres
--

CREATE SEQUENCE brand.cpu_brand_brand_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brand.cpu_brand_brand_id_seq OWNER TO postgres;

--
-- Name: cpu_brand_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: brand; Owner: postgres
--

ALTER SEQUENCE brand.cpu_brand_brand_id_seq OWNED BY brand.cpu_brand.brand_id;


--
-- Name: manufacturer; Type: TABLE; Schema: brand; Owner: postgres
--

CREATE TABLE brand.manufacturer (
    manu_id integer NOT NULL,
    manu_name character varying(50) NOT NULL
);


ALTER TABLE brand.manufacturer OWNER TO postgres;

--
-- Name: manufacturer_manu_id_seq; Type: SEQUENCE; Schema: brand; Owner: postgres
--

CREATE SEQUENCE brand.manufacturer_manu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brand.manufacturer_manu_id_seq OWNER TO postgres;

--
-- Name: manufacturer_manu_id_seq; Type: SEQUENCE OWNED BY; Schema: brand; Owner: postgres
--

ALTER SEQUENCE brand.manufacturer_manu_id_seq OWNED BY brand.manufacturer.manu_id;


--
-- Name: vga_brand; Type: TABLE; Schema: brand; Owner: postgres
--

CREATE TABLE brand.vga_brand (
    brand_id integer NOT NULL,
    brand_name character varying(50) NOT NULL
);


ALTER TABLE brand.vga_brand OWNER TO postgres;

--
-- Name: vga_brand_brand_id_seq; Type: SEQUENCE; Schema: brand; Owner: postgres
--

CREATE SEQUENCE brand.vga_brand_brand_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brand.vga_brand_brand_id_seq OWNER TO postgres;

--
-- Name: vga_brand_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: brand; Owner: postgres
--

ALTER SEQUENCE brand.vga_brand_brand_id_seq OWNED BY brand.vga_brand.brand_id;


--
-- Name: customers; Type: TABLE; Schema: customer; Owner: postgres
--

CREATE TABLE customer.customers (
    customer_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    address character varying(50) NOT NULL,
    ward character varying(50),
    district character varying(50),
    city character varying(50) NOT NULL,
    email character varying(50),
    phone character varying(11) NOT NULL,
    CONSTRAINT check_valid_phone CHECK (((phone)::text !~~ '%[^0-9]%'::text))
);


ALTER TABLE customer.customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: customer; Owner: postgres
--

COMMENT ON TABLE customer.customers IS 'General customers information';


--
-- Name: COLUMN customers.phone; Type: COMMENT; Schema: customer; Owner: postgres
--

COMMENT ON COLUMN customer.customers.phone IS 'Serves Vietnamese phone number only';


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: customer; Owner: postgres
--

CREATE SEQUENCE customer.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customer.customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: customer; Owner: postgres
--

ALTER SEQUENCE customer.customers_customer_id_seq OWNED BY customer.customers.customer_id;


--
-- Name: employees; Type: TABLE; Schema: employee; Owner: postgres
--

CREATE TABLE employee.employees (
    employee_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    address character varying(50),
    ward character varying(50),
    district character varying(50),
    city character varying(50),
    email character varying(50) NOT NULL,
    phone character varying(11) NOT NULL,
    active boolean DEFAULT false NOT NULL,
    working_branch_id integer,
    role_id integer NOT NULL,
    username character varying(50),
    password character varying(50),
    salary integer NOT NULL,
    CONSTRAINT check_is_working CHECK (
CASE
    WHEN (active = true) THEN ((working_branch_id IS NOT NULL) AND (role_id IS NOT NULL) AND (username IS NOT NULL) AND (password IS NOT NULL))
    ELSE NULL::boolean
END),
    CONSTRAINT check_salary CHECK ((salary > 0)),
    CONSTRAINT check_valid_phone CHECK (((phone)::text !~~ '%[^0-9]%'::text))
);


ALTER TABLE employee.employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: employee; Owner: postgres
--

COMMENT ON TABLE employee.employees IS 'General employee information';


--
-- Name: COLUMN employees.phone; Type: COMMENT; Schema: employee; Owner: postgres
--

COMMENT ON COLUMN employee.employees.phone IS 'Serves Vietnamese phone number only';


--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: employee; Owner: postgres
--

CREATE SEQUENCE employee.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: employee; Owner: postgres
--

ALTER SEQUENCE employee.employees_employee_id_seq OWNED BY employee.employees.employee_id;


--
-- Name: roles; Type: TABLE; Schema: employee; Owner: postgres
--

CREATE TABLE employee.roles (
    role_id integer NOT NULL,
    role_name character varying(50) NOT NULL
);


ALTER TABLE employee.roles OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: employee; Owner: postgres
--

CREATE SEQUENCE employee.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee.roles_role_id_seq OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: employee; Owner: postgres
--

ALTER SEQUENCE employee.roles_role_id_seq OWNED BY employee.roles.role_id;


--
-- Name: orderlines; Type: TABLE; Schema: order; Owner: postgres
--

CREATE TABLE "order".orderlines (
    order_id integer NOT NULL,
    prod_id integer NOT NULL,
    serial_number character varying(30) NOT NULL
);


ALTER TABLE "order".orderlines OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: order; Owner: postgres
--

CREATE TABLE "order".orders (
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    customer_name character varying(100) NOT NULL,
    customer_phone character varying(11) NOT NULL,
    order_type character varying(20) NOT NULL,
    order_date date NOT NULL,
    shipping_address character varying(100) DEFAULT NULL::character varying,
    shop_assist_id integer,
    cashier_id integer,
    payment_method character varying(20),
    total_amount integer NOT NULL,
    status character varying(20),
    CONSTRAINT check_offline_order CHECK (
CASE
    WHEN ((order_type)::text = 'offline'::text) THEN ((shop_assist_id IS NOT NULL) AND (cashier_id IS NOT NULL))
    ELSE NULL::boolean
END),
    CONSTRAINT check_online_order CHECK (
CASE
    WHEN ((order_type)::text = 'online'::text) THEN (shipping_address IS NOT NULL)
    ELSE NULL::boolean
END),
    CONSTRAINT check_order_type CHECK (((order_type)::text = ANY ((ARRAY['online'::character varying, 'offline'::character varying])::text[])))
);


ALTER TABLE "order".orders OWNER TO postgres;

--
-- Name: COLUMN orders.order_type; Type: COMMENT; Schema: order; Owner: postgres
--

COMMENT ON COLUMN "order".orders.order_type IS 'Online or offline order';


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: order; Owner: postgres
--

CREATE SEQUENCE "order".orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "order".orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: order; Owner: postgres
--

ALTER SEQUENCE "order".orders_order_id_seq OWNED BY "order".orders.order_id;


--
-- Name: warranty; Type: TABLE; Schema: order; Owner: postgres
--

CREATE TABLE "order".warranty (
    order_id integer NOT NULL,
    prod_id integer NOT NULL,
    serial_number character varying(30) NOT NULL,
    purchase_date date,
    warranty_issue_date date NOT NULL,
    warranty_issue_time time without time zone NOT NULL,
    warranty_status character varying(20) DEFAULT 'in progress'::character varying,
    description character varying(255),
    CONSTRAINT check_status CHECK (((warranty_status)::text = ANY ((ARRAY['in progress'::character varying, 'finished'::character varying])::text[])))
);


ALTER TABLE "order".warranty OWNER TO postgres;

--
-- Name: product_category; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.product_category (
    cate_id integer NOT NULL,
    cate_name character varying(50) NOT NULL
);


ALTER TABLE product.product_category OWNER TO postgres;

--
-- Name: product_category_cate_id_seq; Type: SEQUENCE; Schema: product; Owner: postgres
--

CREATE SEQUENCE product.product_category_cate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product.product_category_cate_id_seq OWNER TO postgres;

--
-- Name: product_category_cate_id_seq; Type: SEQUENCE OWNED BY; Schema: product; Owner: postgres
--

ALTER SEQUENCE product.product_category_cate_id_seq OWNED BY product.product_category.cate_id;


--
-- Name: product_instance; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.product_instance (
    prod_id integer NOT NULL,
    serial_number character varying(30) NOT NULL,
    branch_id integer NOT NULL,
    is_sold_out boolean DEFAULT false NOT NULL,
    import_date date NOT NULL,
    warranty_period integer DEFAULT 0 NOT NULL,
    CONSTRAINT check_warranty_period CHECK ((warranty_period >= 0))
);


ALTER TABLE product.product_instance OWNER TO postgres;

--
-- Name: COLUMN product_instance.warranty_period; Type: COMMENT; Schema: product; Owner: postgres
--

COMMENT ON COLUMN product.product_instance.warranty_period IS 'Time of warranty since purchasing product (in days)';


--
-- Name: product_specs; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.product_specs (
    prod_id integer NOT NULL,
    cpu_brand_id integer NOT NULL,
    cpu_model character varying(50) NOT NULL,
    ram_capacity integer NOT NULL,
    ram_form_factor character varying(20),
    storage_capacity integer NOT NULL,
    storage_type character varying(20) NOT NULL,
    vga_type character varying(15) NOT NULL,
    vga_brand_id integer,
    vga_model character varying(50),
    display_size character varying(15) NOT NULL,
    release_year integer,
    description character varying(1000),
    CONSTRAINT check_storage_type CHECK (((storage_type)::text = ANY ((ARRAY['HDD'::character varying, 'SSD'::character varying, 'HDD & SSD'::character varying])::text[]))),
    CONSTRAINT check_valid_values CHECK (((ram_capacity > 0) AND (storage_capacity > 0) AND (release_year > 0))),
    CONSTRAINT check_vga_type CHECK (((vga_type)::text = ANY ((ARRAY['integrated'::character varying, 'discrete'::character varying])::text[])))
);


ALTER TABLE product.product_specs OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.products (
    prod_id integer NOT NULL,
    prod_brand_id integer NOT NULL,
    prod_model_name character varying(100) NOT NULL,
    prod_category_id integer NOT NULL,
    price integer NOT NULL
);


ALTER TABLE product.products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: product; Owner: postgres
--

COMMENT ON TABLE product.products IS 'General products information';


--
-- Name: products_prod_id_seq; Type: SEQUENCE; Schema: product; Owner: postgres
--

CREATE SEQUENCE product.products_prod_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product.products_prod_id_seq OWNER TO postgres;

--
-- Name: products_prod_id_seq; Type: SEQUENCE OWNED BY; Schema: product; Owner: postgres
--

ALTER SEQUENCE product.products_prod_id_seq OWNED BY product.products.prod_id;


--
-- Name: store_branch; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.store_branch (
    branch_id integer NOT NULL,
    address character varying(50) NOT NULL,
    ward character varying(50) NOT NULL,
    district character varying(50) NOT NULL,
    city character varying(50),
    open_time time without time zone NOT NULL,
    close_time time without time zone NOT NULL,
    email character varying(50) NOT NULL,
    phone character varying(11) NOT NULL,
    manager_id integer NOT NULL
);


ALTER TABLE store.store_branch OWNER TO postgres;

--
-- Name: TABLE store_branch; Type: COMMENT; Schema: store; Owner: postgres
--

COMMENT ON TABLE store.store_branch IS 'General store branches information';


--
-- Name: storebranch_branch_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.storebranch_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE store.storebranch_branch_id_seq OWNER TO postgres;

--
-- Name: storebranch_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.storebranch_branch_id_seq OWNED BY store.store_branch.branch_id;


--
-- Name: cpu_brand brand_id; Type: DEFAULT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.cpu_brand ALTER COLUMN brand_id SET DEFAULT nextval('brand.cpu_brand_brand_id_seq'::regclass);


--
-- Name: manufacturer manu_id; Type: DEFAULT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.manufacturer ALTER COLUMN manu_id SET DEFAULT nextval('brand.manufacturer_manu_id_seq'::regclass);


--
-- Name: vga_brand brand_id; Type: DEFAULT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.vga_brand ALTER COLUMN brand_id SET DEFAULT nextval('brand.vga_brand_brand_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: customer; Owner: postgres
--

ALTER TABLE ONLY customer.customers ALTER COLUMN customer_id SET DEFAULT nextval('customer.customers_customer_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees ALTER COLUMN employee_id SET DEFAULT nextval('employee.employees_employee_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.roles ALTER COLUMN role_id SET DEFAULT nextval('employee.roles_role_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders ALTER COLUMN order_id SET DEFAULT nextval('"order".orders_order_id_seq'::regclass);


--
-- Name: product_category cate_id; Type: DEFAULT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_category ALTER COLUMN cate_id SET DEFAULT nextval('product.product_category_cate_id_seq'::regclass);


--
-- Name: products prod_id; Type: DEFAULT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products ALTER COLUMN prod_id SET DEFAULT nextval('product.products_prod_id_seq'::regclass);


--
-- Name: store_branch branch_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch ALTER COLUMN branch_id SET DEFAULT nextval('store.storebranch_branch_id_seq'::regclass);


--
-- Data for Name: cpu_brand; Type: TABLE DATA; Schema: brand; Owner: postgres
--



--
-- Data for Name: manufacturer; Type: TABLE DATA; Schema: brand; Owner: postgres
--



--
-- Data for Name: vga_brand; Type: TABLE DATA; Schema: brand; Owner: postgres
--



--
-- Data for Name: customers; Type: TABLE DATA; Schema: customer; Owner: postgres
--



--
-- Data for Name: employees; Type: TABLE DATA; Schema: employee; Owner: postgres
--



--
-- Data for Name: roles; Type: TABLE DATA; Schema: employee; Owner: postgres
--

INSERT INTO employee.roles VALUES (1, 'Admin');
INSERT INTO employee.roles VALUES (2, 'Manager');
INSERT INTO employee.roles VALUES (3, 'Cashier');
INSERT INTO employee.roles VALUES (4, 'Inventory Clerk');
INSERT INTO employee.roles VALUES (5, 'Shop Assistant');
INSERT INTO employee.roles VALUES (6, 'Customer Service Representative');


--
-- Data for Name: orderlines; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: orders; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: warranty; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: product_category; Type: TABLE DATA; Schema: product; Owner: postgres
--

INSERT INTO product.product_category VALUES (1, 'Laptop');
INSERT INTO product.product_category VALUES (2, 'PC');
INSERT INTO product.product_category VALUES (3, 'Mini PC');
INSERT INTO product.product_category VALUES (4, 'All-in-one');


--
-- Data for Name: product_instance; Type: TABLE DATA; Schema: product; Owner: postgres
--



--
-- Data for Name: product_specs; Type: TABLE DATA; Schema: product; Owner: postgres
--



--
-- Data for Name: products; Type: TABLE DATA; Schema: product; Owner: postgres
--



--
-- Data for Name: store_branch; Type: TABLE DATA; Schema: store; Owner: postgres
--



--
-- Name: cpu_brand_brand_id_seq; Type: SEQUENCE SET; Schema: brand; Owner: postgres
--

SELECT pg_catalog.setval('brand.cpu_brand_brand_id_seq', 1, false);


--
-- Name: manufacturer_manu_id_seq; Type: SEQUENCE SET; Schema: brand; Owner: postgres
--

SELECT pg_catalog.setval('brand.manufacturer_manu_id_seq', 1, false);


--
-- Name: vga_brand_brand_id_seq; Type: SEQUENCE SET; Schema: brand; Owner: postgres
--

SELECT pg_catalog.setval('brand.vga_brand_brand_id_seq', 1, false);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: customer; Owner: postgres
--

SELECT pg_catalog.setval('customer.customers_customer_id_seq', 1, false);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: employee; Owner: postgres
--

SELECT pg_catalog.setval('employee.employees_employee_id_seq', 1, false);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: employee; Owner: postgres
--

SELECT pg_catalog.setval('employee.roles_role_id_seq', 6, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: order; Owner: postgres
--

SELECT pg_catalog.setval('"order".orders_order_id_seq', 1, false);


--
-- Name: product_category_cate_id_seq; Type: SEQUENCE SET; Schema: product; Owner: postgres
--

SELECT pg_catalog.setval('product.product_category_cate_id_seq', 4, true);


--
-- Name: products_prod_id_seq; Type: SEQUENCE SET; Schema: product; Owner: postgres
--

SELECT pg_catalog.setval('product.products_prod_id_seq', 1, false);


--
-- Name: storebranch_branch_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.storebranch_branch_id_seq', 1, false);


--
-- Name: cpu_brand cpu_brand_pk; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.cpu_brand
    ADD CONSTRAINT cpu_brand_pk PRIMARY KEY (brand_id);


--
-- Name: cpu_brand cpu_brand_pk2; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.cpu_brand
    ADD CONSTRAINT cpu_brand_pk2 UNIQUE (brand_name);


--
-- Name: manufacturer manufacturer_pk; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.manufacturer
    ADD CONSTRAINT manufacturer_pk PRIMARY KEY (manu_id);


--
-- Name: manufacturer manufacturer_pk2; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.manufacturer
    ADD CONSTRAINT manufacturer_pk2 UNIQUE (manu_name);


--
-- Name: vga_brand vga_brand_pk; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.vga_brand
    ADD CONSTRAINT vga_brand_pk PRIMARY KEY (brand_id);


--
-- Name: vga_brand vga_brand_pk2; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.vga_brand
    ADD CONSTRAINT vga_brand_pk2 UNIQUE (brand_name);


--
-- Name: customers customers_pk; Type: CONSTRAINT; Schema: customer; Owner: postgres
--

ALTER TABLE ONLY customer.customers
    ADD CONSTRAINT customers_pk PRIMARY KEY (phone);


--
-- Name: customers customers_pk2; Type: CONSTRAINT; Schema: customer; Owner: postgres
--

ALTER TABLE ONLY customer.customers
    ADD CONSTRAINT customers_pk2 UNIQUE (customer_id);


--
-- Name: employees employees_pk; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_pk UNIQUE (username);


--
-- Name: employees employees_pk2; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_pk2 PRIMARY KEY (employee_id);


--
-- Name: employees employees_pk3; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_pk3 UNIQUE (email);


--
-- Name: employees employees_pk4; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_pk4 UNIQUE (phone);


--
-- Name: roles roles_pk; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.roles
    ADD CONSTRAINT roles_pk PRIMARY KEY (role_id);


--
-- Name: roles roles_pk2; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.roles
    ADD CONSTRAINT roles_pk2 UNIQUE (role_name);


--
-- Name: orderlines orderlines_pk; Type: CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orderlines
    ADD CONSTRAINT orderlines_pk PRIMARY KEY (prod_id, order_id, serial_number);


--
-- Name: orders orders_pk; Type: CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_pk PRIMARY KEY (order_id, customer_phone);


--
-- Name: orders orders_pk2; Type: CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_pk2 UNIQUE (order_id);


--
-- Name: warranty warranty_pk; Type: CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".warranty
    ADD CONSTRAINT warranty_pk PRIMARY KEY (order_id, prod_id, serial_number, warranty_issue_date, warranty_issue_time);


--
-- Name: product_category product_category_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_category
    ADD CONSTRAINT product_category_pk PRIMARY KEY (cate_id);


--
-- Name: product_category product_category_pk2; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_category
    ADD CONSTRAINT product_category_pk2 UNIQUE (cate_name);


--
-- Name: product_instance product_instance_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance_pk PRIMARY KEY (prod_id, serial_number);


--
-- Name: product_instance product_instance_pk2; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance_pk2 UNIQUE (serial_number);


--
-- Name: product_specs product_specs_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_pk PRIMARY KEY (prod_id);


--
-- Name: products products_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_pk PRIMARY KEY (prod_id);


--
-- Name: products products_pk2; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_pk2 UNIQUE (prod_model_name);


--
-- Name: store_branch storebranch_pk; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch
    ADD CONSTRAINT storebranch_pk PRIMARY KEY (branch_id);


--
-- Name: store_branch storebranch_pk2; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch
    ADD CONSTRAINT storebranch_pk2 UNIQUE (email);


--
-- Name: store_branch storebranch_pk3; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch
    ADD CONSTRAINT storebranch_pk3 UNIQUE (phone);


--
-- Name: store_branch storebranch_pk4; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch
    ADD CONSTRAINT storebranch_pk4 UNIQUE (address);


--
-- Name: employees employees_roles_role_id_fk; Type: FK CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES employee.roles(role_id);


--
-- Name: orderlines orderlines_orders_order_id_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orderlines
    ADD CONSTRAINT orderlines_orders_order_id_fk FOREIGN KEY (order_id) REFERENCES "order".orders(order_id);


--
-- Name: orderlines orderlines_product_instance_serial_number_prod_id_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orderlines
    ADD CONSTRAINT orderlines_product_instance_serial_number_prod_id_fk FOREIGN KEY (serial_number, prod_id) REFERENCES product.product_instance(serial_number, prod_id);


--
-- Name: orders orders_customers_customer_id_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_customers_customer_id_fk FOREIGN KEY (customer_id) REFERENCES customer.customers(customer_id);


--
-- Name: orders orders_customers_phone_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_customers_phone_fk FOREIGN KEY (customer_phone) REFERENCES customer.customers(phone);


--
-- Name: orders orders_employees_employee_id_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_employees_employee_id_fk FOREIGN KEY (cashier_id) REFERENCES employee.employees(employee_id);


--
-- Name: orders orders_employees_employee_id_fk2; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_employees_employee_id_fk2 FOREIGN KEY (shop_assist_id) REFERENCES employee.employees(employee_id);


--
-- Name: warranty warranty_orderlines_order_id_prod_id_serial_number_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".warranty
    ADD CONSTRAINT warranty_orderlines_order_id_prod_id_serial_number_fk FOREIGN KEY (order_id, prod_id, serial_number) REFERENCES "order".orderlines(order_id, prod_id, serial_number);


--
-- Name: product_instance product_instance_products_prod_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance_products_prod_id_fk FOREIGN KEY (prod_id) REFERENCES product.products(prod_id);


--
-- Name: product_instance product_instance_storebranch_branch_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance_storebranch_branch_id_fk FOREIGN KEY (branch_id) REFERENCES store.store_branch(branch_id);


--
-- Name: product_specs product_specs_cpu_brand_brand_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_cpu_brand_brand_id_fk FOREIGN KEY (cpu_brand_id) REFERENCES brand.cpu_brand(brand_id);


--
-- Name: product_specs product_specs_products_prod_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_products_prod_id_fk FOREIGN KEY (prod_id) REFERENCES product.products(prod_id);


--
-- Name: product_specs product_specs_vga_brand_brand_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_vga_brand_brand_id_fk FOREIGN KEY (vga_brand_id) REFERENCES brand.vga_brand(brand_id);


--
-- Name: products products_manufacturer_manu_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_manufacturer_manu_id_fk FOREIGN KEY (prod_brand_id) REFERENCES brand.manufacturer(manu_id);


--
-- Name: products products_product_category_cate_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_product_category_cate_id_fk FOREIGN KEY (prod_category_id) REFERENCES product.product_category(cate_id);


--
-- Name: store_branch storebranch_employees_employee_id_fk; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch
    ADD CONSTRAINT storebranch_employees_employee_id_fk FOREIGN KEY (manager_id) REFERENCES employee.employees(employee_id);


--
-- Name: CONSTRAINT storebranch_employees_employee_id_fk ON store_branch; Type: COMMENT; Schema: store; Owner: postgres
--

COMMENT ON CONSTRAINT storebranch_employees_employee_id_fk ON store.store_branch IS 'The manager who manages the branch';


--
-- PostgreSQL database dump complete
--

