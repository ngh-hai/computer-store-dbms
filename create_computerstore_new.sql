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
-- Name: manufacturer; Type: TABLE; Schema: brand; Owner: postgres
--

CREATE TABLE brand.manufacturer (
    manu_id integer NOT NULL,
    manu_name character varying(255) NOT NULL
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
-- Name: customers; Type: TABLE; Schema: customer; Owner: postgres
--

CREATE TABLE customer.customers (
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    district character varying(50),
    city character varying(50) NOT NULL,
    email character varying(255),
    phone bigint NOT NULL
);


ALTER TABLE customer.customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: customer; Owner: postgres
--

COMMENT ON TABLE customer.customers IS 'General customers information';


--
-- Name: COLUMN customers.phone; Type: COMMENT; Schema: customer; Owner: postgres
--

COMMENT ON COLUMN customer.customers.phone IS 'Serves Vietnamese phone number only.
Prepend ''0'' or ''+84'' to get full phone number. ';


--
-- Name: employees; Type: TABLE; Schema: employee; Owner: postgres
--

CREATE TABLE employee.employees (
    employee_id integer NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255),
    district character varying(50),
    city character varying(50),
    email character varying(255) NOT NULL,
    phone bigint NOT NULL,
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
    CONSTRAINT check_salary CHECK ((salary > 0))
);


ALTER TABLE employee.employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: employee; Owner: postgres
--

COMMENT ON TABLE employee.employees IS 'General employee information';


--
-- Name: COLUMN employees.phone; Type: COMMENT; Schema: employee; Owner: postgres
--

COMMENT ON COLUMN employee.employees.phone IS 'Serves Vietnamese phone number only
Prepend ''0'' or ''+84'' to get full phone number';


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
-- Name: orders; Type: TABLE; Schema: order; Owner: postgres
--

CREATE TABLE "order".orders (
    order_id integer NOT NULL,
    customer_name character varying(255) NOT NULL,
    customer_phone bigint NOT NULL,
    is_online_order boolean DEFAULT false NOT NULL,
    order_date date NOT NULL,
    shipping_address character varying(255) DEFAULT NULL::character varying,
    shop_assist_id integer,
    cashier_id integer,
    payment_method character varying(20),
    total_amount bigint NOT NULL,
    description character varying(255),
    purchase_branch_id integer,
    CONSTRAINT check_offline_order CHECK (
CASE
    WHEN (is_online_order = false) THEN ((purchase_branch_id IS NOT NULL) AND (shop_assist_id IS NOT NULL) AND (cashier_id IS NOT NULL))
    ELSE NULL::boolean
END),
    CONSTRAINT check_online_order CHECK (
CASE
    WHEN (is_online_order = true) THEN (shipping_address IS NOT NULL)
    ELSE NULL::boolean
END)
);


ALTER TABLE "order".orders OWNER TO postgres;

--
-- Name: COLUMN orders.is_online_order; Type: COMMENT; Schema: order; Owner: postgres
--

COMMENT ON COLUMN "order".orders.is_online_order IS 'Online or offline order';


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
    serial_number character varying(255) NOT NULL,
    purchase_date date,
    warranty_issue_date date NOT NULL,
    description character varying(255),
    is_warranty_issue_finished boolean DEFAULT false
);


ALTER TABLE "order".warranty OWNER TO postgres;

--
-- Name: COLUMN warranty.is_warranty_issue_finished; Type: COMMENT; Schema: order; Owner: postgres
--

COMMENT ON COLUMN "order".warranty.is_warranty_issue_finished IS 'Check if a warranty issue is finised or not';


--
-- Name: general_specs; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.general_specs (
    display_title character varying(255),
    spec_type character varying(255) NOT NULL,
    spec_value integer NOT NULL,
    description integer,
    product_cate_id integer NOT NULL,
    spec_id integer NOT NULL
);


ALTER TABLE product.general_specs OWNER TO postgres;

--
-- Name: general_specs_spec_id_seq; Type: SEQUENCE; Schema: product; Owner: postgres
--

CREATE SEQUENCE product.general_specs_spec_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product.general_specs_spec_id_seq OWNER TO postgres;

--
-- Name: general_specs_spec_id_seq; Type: SEQUENCE OWNED BY; Schema: product; Owner: postgres
--

ALTER SEQUENCE product.general_specs_spec_id_seq OWNED BY product.general_specs.spec_id;


--
-- Name: product_category; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.product_category (
    cate_id integer NOT NULL,
    cate_name character varying(255) NOT NULL
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
    serial_number character varying(255) NOT NULL,
    branch_id integer NOT NULL,
    import_date date NOT NULL,
    warranty_period integer DEFAULT 0 NOT NULL,
    order_id integer,
    selling_price integer,
    CONSTRAINT check_valid_price_in_order CHECK (
CASE
    WHEN (order_id IS NOT NULL) THEN (selling_price > 0)
    ELSE NULL::boolean
END),
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
    spec_id integer NOT NULL
);


ALTER TABLE product.product_specs OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: product; Owner: postgres
--

CREATE TABLE product.products (
    prod_id integer NOT NULL,
    prod_brand_id integer NOT NULL,
    prod_model_name character varying(255) NOT NULL,
    prod_category_id integer NOT NULL,
    price integer NOT NULL,
    CONSTRAINT check_valid_price CHECK ((price > 0))
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
    address character varying(255) NOT NULL,
    ward character varying(50) NOT NULL,
    district character varying(50) NOT NULL,
    city character varying(50),
    open_time time without time zone NOT NULL,
    close_time time without time zone NOT NULL,
    email character varying(255) NOT NULL,
    phone bigint NOT NULL,
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
-- Name: manufacturer manu_id; Type: DEFAULT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.manufacturer ALTER COLUMN manu_id SET DEFAULT nextval('brand.manufacturer_manu_id_seq'::regclass);


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
-- Name: general_specs spec_id; Type: DEFAULT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs ALTER COLUMN spec_id SET DEFAULT nextval('product.general_specs_spec_id_seq'::regclass);


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
-- Data for Name: manufacturer; Type: TABLE DATA; Schema: brand; Owner: postgres
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
-- Data for Name: orders; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: warranty; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: general_specs; Type: TABLE DATA; Schema: product; Owner: postgres
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
-- Name: manufacturer_manu_id_seq; Type: SEQUENCE SET; Schema: brand; Owner: postgres
--

SELECT pg_catalog.setval('brand.manufacturer_manu_id_seq', 1, false);


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
-- Name: general_specs_spec_id_seq; Type: SEQUENCE SET; Schema: product; Owner: postgres
--

SELECT pg_catalog.setval('product.general_specs_spec_id_seq', 1, false);


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
-- Name: customers customers_pk; Type: CONSTRAINT; Schema: customer; Owner: postgres
--

ALTER TABLE ONLY customer.customers
    ADD CONSTRAINT customers_pk PRIMARY KEY (phone);


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
    ADD CONSTRAINT warranty_pk PRIMARY KEY (serial_number);


--
-- Name: general_specs general_specs_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs
    ADD CONSTRAINT general_specs_pk PRIMARY KEY (spec_id);


--
-- Name: general_specs general_specs_pk2; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs
    ADD CONSTRAINT general_specs_pk2 UNIQUE (spec_type, spec_value, product_cate_id);


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
    ADD CONSTRAINT product_instance_pk PRIMARY KEY (serial_number);


--
-- Name: product_instance product_instance_pk2; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance_pk2 UNIQUE (serial_number);


--
-- Name: product_specs product_specs_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_pk PRIMARY KEY (prod_id, spec_id);


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
-- Name: employees employees___fk; Type: FK CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees___fk FOREIGN KEY (working_branch_id) REFERENCES store.store_branch(branch_id);


--
-- Name: employees employees_roles_role_id_fk; Type: FK CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES employee.roles(role_id);


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
-- Name: orders orders_store_branch_branch_id_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders
    ADD CONSTRAINT orders_store_branch_branch_id_fk FOREIGN KEY (purchase_branch_id) REFERENCES store.store_branch(branch_id);


--
-- Name: warranty warranty_product_instance_serial_number_fk; Type: FK CONSTRAINT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".warranty
    ADD CONSTRAINT warranty_product_instance_serial_number_fk FOREIGN KEY (serial_number) REFERENCES product.product_instance(serial_number);


--
-- Name: general_specs general_specs_product_category_cate_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs
    ADD CONSTRAINT general_specs_product_category_cate_id_fk FOREIGN KEY (product_cate_id) REFERENCES product.product_category(cate_id);


--
-- Name: product_instance product_instance___fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_instance
    ADD CONSTRAINT product_instance___fk FOREIGN KEY (order_id) REFERENCES "order".orders(order_id);


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
-- Name: product_specs product_specs_general_specs_spec_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_general_specs_spec_id_fk FOREIGN KEY (spec_id) REFERENCES product.general_specs(spec_id);


--
-- Name: product_specs product_specs_products_prod_id_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_specs
    ADD CONSTRAINT product_specs_products_prod_id_fk FOREIGN KEY (prod_id) REFERENCES product.products(prod_id);


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

