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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA employee;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: add_new_brands(character varying[]); Type: PROCEDURE; Schema: brand; Owner: postgres
--

CREATE PROCEDURE brand.add_new_brands(VARIADIC new_brands character varying[])
    LANGUAGE plpgsql
    AS $$
    declare
    new_brand varchar(255);
    begin
        foreach new_brand in array new_brands loop
    if exists (select brand_name from brand.brands where brand_name = new_brand)
    then raise notice 'Brand % already exists. No changes were made.', new_brand;
    else
        execute 'insert into brand.brands values (''' || new_brand || ''');';
        raise notice 'Successfully added brand %.', new_brand;
end if;
end loop;
end;
$$;


ALTER PROCEDURE brand.add_new_brands(VARIADIC new_brands character varying[]) OWNER TO postgres;

--
-- Name: add_new_employee(character varying, character varying, character varying, character varying, character varying, bigint, character varying, character varying, character varying, integer, boolean); Type: PROCEDURE; Schema: employee; Owner: postgres
--

CREATE PROCEDURE employee.add_new_employee(IN new_name character varying, IN new_address character varying, IN new_district character varying, IN new_city character varying, IN new_email character varying, IN new_phone bigint, IN new_role character varying, IN new_username character varying, IN new_password character varying, IN new_salary integer, IN is_active boolean DEFAULT false)
    LANGUAGE plpgsql
    AS $$
    begin
    execute 'insert into employee.employees(name, address, district, city, email, phone, active, role, username, password, salary) values ('''
        || new_name || ''',''' || new_address || ''',''' || new_district || ''',''' || new_city || ''',''' || new_email || ''',' || new_phone
        || ',' || is_active  || ',''' || new_role || ''',''' || new_username || ''',''' || new_password || ''',' || new_salary || ');' ;
    end;
$$;


ALTER PROCEDURE employee.add_new_employee(IN new_name character varying, IN new_address character varying, IN new_district character varying, IN new_city character varying, IN new_email character varying, IN new_phone bigint, IN new_role character varying, IN new_username character varying, IN new_password character varying, IN new_salary integer, IN is_active boolean) OWNER TO postgres;

--
-- Name: encrypt_password(); Type: FUNCTION; Schema: employee; Owner: postgres
--

CREATE FUNCTION employee.encrypt_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
        update employee.employees
        set password = employee.crypt(password,gen_salt('bf'))
        where employee_id = new.employee_id;
        return new;
    end
    $$;


ALTER FUNCTION employee.encrypt_password() OWNER TO postgres;

--
-- Name: login(character varying, character varying); Type: FUNCTION; Schema: employee; Owner: postgres
--

CREATE FUNCTION employee.login(user_name character varying, pass_word character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare
        id integer;
    begin
        select employee_id
        into id
        from employees
        where username = user_name
        and password = employee.crypt(pass_word,password)
        and active;
        if id is null
           then return -1;
        else
            return id;
        end if;
    end;
    $$;


ALTER FUNCTION employee.login(user_name character varying, pass_word character varying) OWNER TO postgres;

--
-- Name: add_new_categories(character varying[]); Type: PROCEDURE; Schema: product; Owner: postgres
--

CREATE PROCEDURE product.add_new_categories(VARIADIC new_categories character varying[])
    LANGUAGE plpgsql
    AS $$
    declare
    new_category varchar(255);
    begin
        foreach new_category in array new_categories loop
    if exists (select category_name from product.product_category where category_name = new_category)
    then raise notice 'Category % already exists. No changes were made.', new_category;
    else
        execute 'insert into product.product_category values (''' || new_category || ''');';
        raise notice 'Successfully added category %.', new_category;
end if;
end loop;
end;
$$;


ALTER PROCEDURE product.add_new_categories(VARIADIC new_categories character varying[]) OWNER TO postgres;

--
-- Name: add_new_product(character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: product; Owner: postgres
--

CREATE PROCEDURE product.add_new_product(IN brand character varying, IN model character varying, IN category character varying, IN price integer)
    LANGUAGE plpgsql
    AS $$
    begin
        if not exists(select brand_name from brand.brands where brand_name = brand)
            then raise notice 'Brand % does not exist, please add this brand to the database. No changes were made.', brand;
        elsif not exists(select category_name from product.product_category where category_name = category)
            then raise notice 'Category % does not exist, please add this category to the database. No changes were made.', category;
        elsif (price < 0)
            then raise notice 'Invalid price, please check again. No changes were made.';
        elsif exists(select prod_id from product.products where prod_brand_name = brand and prod_model_name = model
             and prod_category_name = category)
            then raise notice 'This item already existed. No changes were made.';
        else
            execute 'insert into product.products(prod_brand_name, prod_model_name, prod_category_name, price) values ('''
            || brand || ''',''' || model || ''',''' || category || ''',' || price || ');' ;
            raise notice 'Successfully added item % %.', brand, model;
        end if;
    end;
$$;


ALTER PROCEDURE product.add_new_product(IN brand character varying, IN model character varying, IN category character varying, IN price integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: brands; Type: TABLE; Schema: brand; Owner: postgres
--

CREATE TABLE brand.brands (
    brand_name character varying(255) NOT NULL
);


ALTER TABLE brand.brands OWNER TO postgres;

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
    role character varying(255) NOT NULL,
    username character varying(60),
    password character varying(60),
    salary integer NOT NULL,
    CONSTRAINT check_is_working CHECK (
CASE
    WHEN (active = true) THEN ((working_branch_id IS NOT NULL) AND (role IS NOT NULL) AND (username IS NOT NULL) AND (password IS NOT NULL))
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
    role_name character varying(255) NOT NULL
);


ALTER TABLE employee.roles OWNER TO postgres;

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
    spec_value character varying(255) NOT NULL,
    description character varying(255),
    product_category character varying(255) NOT NULL,
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
    category_name character varying(255) NOT NULL
);


ALTER TABLE product.product_category OWNER TO postgres;

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
    prod_brand_name character varying(255) NOT NULL,
    prod_model_name character varying(255) NOT NULL,
    prod_category_name character varying(255) NOT NULL,
    price integer NOT NULL,
    variant character varying(255),
    description character varying(255),
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
    manager_id integer
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
-- Name: employees employee_id; Type: DEFAULT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees ALTER COLUMN employee_id SET DEFAULT nextval('employee.employees_employee_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: order; Owner: postgres
--

ALTER TABLE ONLY "order".orders ALTER COLUMN order_id SET DEFAULT nextval('"order".orders_order_id_seq'::regclass);


--
-- Name: general_specs spec_id; Type: DEFAULT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs ALTER COLUMN spec_id SET DEFAULT nextval('product.general_specs_spec_id_seq'::regclass);


--
-- Name: products prod_id; Type: DEFAULT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products ALTER COLUMN prod_id SET DEFAULT nextval('product.products_prod_id_seq'::regclass);


--
-- Name: store_branch branch_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.store_branch ALTER COLUMN branch_id SET DEFAULT nextval('store.storebranch_branch_id_seq'::regclass);


--
-- Data for Name: brands; Type: TABLE DATA; Schema: brand; Owner: postgres
--

INSERT INTO brand.brands VALUES ('Acer');
INSERT INTO brand.brands VALUES ('Asus');
INSERT INTO brand.brands VALUES ('Apple');
INSERT INTO brand.brands VALUES ('Dell');
INSERT INTO brand.brands VALUES ('Gigabyte');
INSERT INTO brand.brands VALUES ('HP');
INSERT INTO brand.brands VALUES ('Lenovo');
INSERT INTO brand.brands VALUES ('LG');
INSERT INTO brand.brands VALUES ('MSI');
INSERT INTO brand.brands VALUES ('Xiaomi');
INSERT INTO brand.brands VALUES ('Huawei');
INSERT INTO brand.brands VALUES ('Sony');
INSERT INTO brand.brands VALUES ('Microsoft');
INSERT INTO brand.brands VALUES ('Intel');
INSERT INTO brand.brands VALUES ('AMD');
INSERT INTO brand.brands VALUES ('Samsung');
INSERT INTO brand.brands VALUES ('Western Digital');
INSERT INTO brand.brands VALUES ('Kingston');
INSERT INTO brand.brands VALUES ('Seagate');
INSERT INTO brand.brands VALUES ('Adata');
INSERT INTO brand.brands VALUES ('Sandisk');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: customer; Owner: postgres
--

INSERT INTO customer.customers VALUES ('Tran Hoang Van', '332 Lan Ong', 'Nam Tu Liem', 'Yen Bai', 'van.th674@gmail.com', 1258654537);
INSERT INTO customer.customers VALUES ('Bui Nam Hung', '18 Hang Chieu', 'Phu Nhuan', 'Thai Nguyen', 'hung.bn196@gmail.com', 8797058920);
INSERT INTO customer.customers VALUES ('Duong Chi Long', '171 Hung Vuong', 'Hoang Mai', 'Bac Ninh', 'long.dc533@gmail.com', 1911797457);
INSERT INTO customer.customers VALUES ('Ta Khanh Thuy', '833 Phan Chu Trinh', 'Thanh Xuan', 'Binh Dinh', 'thuy.tk568@gmail.com', 5632522540);
INSERT INTO customer.customers VALUES ('Le Chi Nhung', '589 Hang Ma', 'Hai Ba Trung', 'Binh Thuan', 'nhung.lc335@gmail.com', 3467529325);
INSERT INTO customer.customers VALUES ('Do Hoang Xuan', '517 Hang Ca', 'Binh Thanh', 'Yen Bai', 'xuan.dh303@gmail.com', 7022356125);
INSERT INTO customer.customers VALUES ('Pham Manh Ly', '538 Thuoc Bac', 'Long Bien', 'Phu Tho', 'ly.pm818@gmail.com', 6536011284);
INSERT INTO customer.customers VALUES ('Dang Manh Huy', '672 Le Duan', 'Cau Giay', 'Kon Tum', 'huy.dm304@gmail.com', 9963171473);
INSERT INTO customer.customers VALUES ('Quach Ngoc Tuyet', '422 Hung Vuong', 'Binh Thanh', 'Kon Tum', 'tuyet.qn288@gmail.com', 6682223036);
INSERT INTO customer.customers VALUES ('Dau Hai Linh', '523 Hang Can', 'Hoan Kiem', 'Can Tho', 'linh.dh36@gmail.com', 6729452283);
INSERT INTO customer.customers VALUES ('Ho Tuan Linh', '476 Hang Ca', 'Thanh Xuan', 'Bien Hoa', 'linh.ht520@gmail.com', 1765656152);
INSERT INTO customer.customers VALUES ('Ho Hai Duc', '243 Kim Ma', 'Hai Chau', 'Can Tho', 'duc.hh839@gmail.com', 8093930564);
INSERT INTO customer.customers VALUES ('Pham Chi Linh', '987 Hoang Quoc Viet', 'Hoang Mai', 'Can Tho', 'linh.pc791@gmail.com', 5952113361);
INSERT INTO customer.customers VALUES ('Pham Thi Minh', '638 Hang Gai', 'Quan 2', 'Bien Hoa', 'minh.pt534@gmail.com', 8675211077);
INSERT INTO customer.customers VALUES ('Dang Kieu Chien', '489 Ly Thuong Kiet', 'Quan 1', 'Kon Tum', 'chien.dk596@gmail.com', 7119695905);
INSERT INTO customer.customers VALUES ('Pham Hai My', '220 Phan Chu Trinh', 'Hoang Mai', 'Phu Yen', 'my.ph230@gmail.com', 5941765628);
INSERT INTO customer.customers VALUES ('Dang Thi Anh', '403 Pham Ngu Lao', 'Ngo Quyen', 'Vung Tau', 'anh.dt150@gmail.com', 6665702795);
INSERT INTO customer.customers VALUES ('Dinh Minh Thuy', '70 Tran Phu', 'Quan 5', 'Can Tho', 'thuy.dm921@gmail.com', 1714349038);
INSERT INTO customer.customers VALUES ('Tran Minh Ly', '567 Luong Dinh Cua', 'Long Bien', 'Bac Ninh', 'ly.tm294@gmail.com', 7881373495);
INSERT INTO customer.customers VALUES ('Duong Minh Giang', '52 Hang Mam', 'Son Tra', 'Quang Ninh', 'giang.dm566@gmail.com', 8696303945);
INSERT INTO customer.customers VALUES ('Ly Manh Hoa', '914 Hang Khay', 'Quan 1', 'Gia Lai', 'hoa.lm863@gmail.com', 6115152678);
INSERT INTO customer.customers VALUES ('Huynh Thanh Loan', '433 Hang Ca', 'Hoan Kiem', 'Ha Tinh', 'loan.ht627@gmail.com', 6711329190);
INSERT INTO customer.customers VALUES ('Vo Ngoc My', '178 Hang Voi', 'Son Tra', 'Ha Noi', 'my.vn204@gmail.com', 2890437720);
INSERT INTO customer.customers VALUES ('Nguyen Hai Lam', '782 Nguyen Trai', 'Quan 2', 'Ha Nam', 'lam.nh111@gmail.com', 4665870641);
INSERT INTO customer.customers VALUES ('Phan Ngoc Huy', '687 Hang Can', 'Quan 4', 'Binh Thuan', 'huy.pn937@gmail.com', 6936830931);
INSERT INTO customer.customers VALUES ('Ho Chi Huy', '878 Hang Tre', 'Hong Bang', 'Da Nang', 'huy.hc534@gmail.com', 3352365088);
INSERT INTO customer.customers VALUES ('Vo Ngoc Tien', '891 Hoang Quoc Viet', 'Tay Ho', 'Vung Tau', 'tien.vn348@gmail.com', 6283959150);
INSERT INTO customer.customers VALUES ('Phan Tuan Quynh', '994 Lan Ong', 'Thanh Xuan', 'Phu Tho', 'quynh.pt116@gmail.com', 9059985459);
INSERT INTO customer.customers VALUES ('Luong Ngoc Sang', '215 Hang Khay', 'Hai Ba Trung', 'Gia Lai', 'sang.ln636@gmail.com', 3629609789);
INSERT INTO customer.customers VALUES ('Vo Ngoc Ly', '479 Hoang Cau', 'Ba Dinh', 'Vinh', 'ly.vn725@gmail.com', 1555155814);
INSERT INTO customer.customers VALUES ('Diep Hai Van', '531 O Cho Dua', 'Quan 2', 'Vinh', 'van.dh613@gmail.com', 8535381206);
INSERT INTO customer.customers VALUES ('Dau Thi Hiep', '915 Luong Dinh Cua', 'Thanh Xuan', 'Quang Binh', 'hiep.dt66@gmail.com', 7586999026);
INSERT INTO customer.customers VALUES ('Ta Thanh Thanh', '372 Lan Ong', 'Hoan Kiem', 'Dak Lak', 'thanh.tt325@gmail.com', 2809706358);
INSERT INTO customer.customers VALUES ('Pham Thanh Linh', '222 Phan Dinh Phung', 'Ba Dinh', 'Kon Tum', 'linh.pt859@gmail.com', 9337100242);
INSERT INTO customer.customers VALUES ('Ho Manh Khoa', '104 Thuoc Bac', 'Ba Dinh', 'Ha Nam', 'khoa.hm225@gmail.com', 6841964252);
INSERT INTO customer.customers VALUES ('Ta Chi Tien', '123 Nguyen Xi', 'Le Chan', 'Thai Nguyen', 'tien.tc693@gmail.com', 8766977107);
INSERT INTO customer.customers VALUES ('Huynh Hoang Nhung', '852 Phung Hung', 'Dong Da', 'Hai Phong', 'nhung.hh91@gmail.com', 3959490683);
INSERT INTO customer.customers VALUES ('Pham Khanh Khoa', '996 Le Loi', 'Binh Thanh', 'Dak Lak', 'khoa.pk767@gmail.com', 7300286673);
INSERT INTO customer.customers VALUES ('Vu Thanh Thao', '121 Thuoc Bac', 'Quan 3', 'Ho Chi Minh', 'thao.vt131@gmail.com', 1843679598);
INSERT INTO customer.customers VALUES ('Duong Thi Anh', '646 Quan Thanh', 'Thanh Khe', 'Vinh', 'anh.dt518@gmail.com', 7648707985);
INSERT INTO customer.customers VALUES ('Duong Ngoc Nhi', '399 Hang Chieu', 'Bac Tu Liem', 'Ha Noi', 'nhi.dn393@gmail.com', 5311740196);
INSERT INTO customer.customers VALUES ('Vu Tuan Ha', '746 Le Loi', 'Quan 5', 'Yen Bai', 'ha.vt226@gmail.com', 1001019125);
INSERT INTO customer.customers VALUES ('Nguyen Manh Khanh', '311 Hang Luoc', 'Le Chan', 'Phu Yen', 'khanh.nm493@gmail.com', 4844714167);
INSERT INTO customer.customers VALUES ('Ta Chi Tien', '800 Hung Vuong', 'Son Tra', 'Hai Phong', 'tien.tc118@gmail.com', 7827435659);
INSERT INTO customer.customers VALUES ('Vo Thanh Ha', '408 Hang Bong', 'Le Chan', 'Quang Ninh', 'ha.vt118@gmail.com', 2333797201);
INSERT INTO customer.customers VALUES ('Tran Khanh Phuong', '142 Hang Non', 'Quan 5', 'Binh Dinh', 'phuong.tk356@gmail.com', 2929052880);
INSERT INTO customer.customers VALUES ('Huynh Ngoc Linh', '740 Phan Dinh Phung', 'Ba Dinh', 'Bac Ninh', 'linh.hn295@gmail.com', 2864426020);
INSERT INTO customer.customers VALUES ('Ho Thanh Van', '450 Hang Bo', 'Quan 2', 'Hue', 'van.ht318@gmail.com', 6003777296);
INSERT INTO customer.customers VALUES ('Ly Hai Thanh', '595 Hang Mam', 'Dong Da', 'Hai Phong', 'thanh.lh523@gmail.com', 6801005149);
INSERT INTO customer.customers VALUES ('Tran Chi Ngan', '772 Hoang Quoc Viet', 'Quan 1', 'Phu Yen', 'ngan.tc960@gmail.com', 6540805655);
INSERT INTO customer.customers VALUES ('Vu Hoang Van', '465 Pham Ngu Lao', 'Thanh Khe', 'Bien Hoa', 'van.vh278@gmail.com', 8109453887);
INSERT INTO customer.customers VALUES ('Nguyen Thanh Tien', '306 Hoang Quoc Viet', 'Quan 4', 'Quang Ninh', 'tien.nt351@gmail.com', 9483244345);
INSERT INTO customer.customers VALUES ('Huynh Minh Lam', '133 Hang Chieu', 'Hoang Mai', 'Binh Thuan', 'lam.hm937@gmail.com', 2467908219);
INSERT INTO customer.customers VALUES ('Dinh Manh Linh', '433 Hang Ma', 'Hoang Mai', 'Da Lat', 'linh.dm89@gmail.com', 2098948769);
INSERT INTO customer.customers VALUES ('Dinh Hoang Khoa', '681 Hang Dao', 'Hai Ba Trung', 'Phu Tho', 'khoa.dh614@gmail.com', 2434545000);
INSERT INTO customer.customers VALUES ('Dang Chi Hoa', '390 Giang Vo', 'Nam Tu Liem', 'Dak Lak', 'hoa.dc406@gmail.com', 4352768590);
INSERT INTO customer.customers VALUES ('Ho Hoang Cuong', '803 Hoang Quoc Viet', 'Quan 2', 'Da Nang', 'cuong.hh543@gmail.com', 7358876792);
INSERT INTO customer.customers VALUES ('Trinh Chi Thanh', '937 Quan Thanh', 'Phu Nhuan', 'Hai Phong', 'thanh.tc324@gmail.com', 3008994605);
INSERT INTO customer.customers VALUES ('Hoang Khanh Ngan', '292 Hang Bo', 'Phu Nhuan', 'Yen Bai', 'ngan.hk900@gmail.com', 7227767952);
INSERT INTO customer.customers VALUES ('Nguyen Hoang Ngoc', '97 Hang Da', 'Cam Le', 'Da Lat', 'ngoc.nh678@gmail.com', 9897669144);
INSERT INTO customer.customers VALUES ('Ho Hai Thao', '61 Tran Dai Nghia', 'Hoang Mai', 'Khanh Hoa', 'thao.hh102@gmail.com', 8218049845);
INSERT INTO customer.customers VALUES ('Ho Minh Ly', '919 Luong Van Can', 'Ngo Quyen', 'Hai Phong', 'ly.hm832@gmail.com', 9690178195);
INSERT INTO customer.customers VALUES ('Diep Nam Trang', '545 Ton Duc Thang', 'Hoang Mai', 'Quang Ninh', 'trang.dn105@gmail.com', 3299070539);
INSERT INTO customer.customers VALUES ('Trinh Hai Tien', '529 Hoang Cau', 'Quan 5', 'Hue', 'tien.th345@gmail.com', 7626416212);
INSERT INTO customer.customers VALUES ('Vu Hoang Nhi', '371 Hang Khay', 'Ba Dinh', 'Thai Nguyen', 'nhi.vh723@gmail.com', 6560289611);
INSERT INTO customer.customers VALUES ('Pham Nam Hung', '134 Hang Khay', 'Nam Tu Liem', 'Phu Yen', 'hung.pn343@gmail.com', 9328917843);
INSERT INTO customer.customers VALUES ('Diep Ngoc Thuy', '439 Ngo Quyen', 'Quan 4', 'Ha Nam', 'thuy.dn157@gmail.com', 7912079279);
INSERT INTO customer.customers VALUES ('Phan Tuan Nhi', '485 Pham Ngu Lao', 'Long Bien', 'Thai Nguyen', 'nhi.pt539@gmail.com', 2868458695);
INSERT INTO customer.customers VALUES ('Dinh Hoang Anh', '325 Le Loi', 'Quan 5', 'Dak Lak', 'anh.dh22@gmail.com', 1071091056);
INSERT INTO customer.customers VALUES ('Duong Manh Van', '441 Luong Dinh Cua', 'Hoan Kiem', 'Bac Ninh', 'van.dm273@gmail.com', 8258010936);
INSERT INTO customer.customers VALUES ('Do Nam Trang', '661 Tran Dai Nghia', 'Bac Tu Liem', 'Ho Chi Minh', 'trang.dn786@gmail.com', 3050056037);
INSERT INTO customer.customers VALUES ('Huynh Kieu Van', '628 Hung Vuong', 'Ngo Quyen', 'Binh Thuan', 'van.hk24@gmail.com', 2163050733);
INSERT INTO customer.customers VALUES ('Luong Manh Phuong', '581 Ly Thuong Kiet', 'Long Bien', 'Ho Chi Minh', 'phuong.lm459@gmail.com', 9248089230);
INSERT INTO customer.customers VALUES ('Ngo Nam Khoa', '805 Tran Phu', 'Ba Dinh', 'Quang Tri', 'khoa.nn910@gmail.com', 2538402351);
INSERT INTO customer.customers VALUES ('Vo Kieu Nhung', '47 Hang Ngang', 'Ha Dong', 'Phu Tho', 'nhung.vk300@gmail.com', 6680139297);
INSERT INTO customer.customers VALUES ('Pham Kieu Thanh', '17 Hoang Cau', 'Dong Da', 'Kon Tum', 'thanh.pk1000@gmail.com', 8739128553);
INSERT INTO customer.customers VALUES ('Ly Nam Lan', '982 Xuan Thuy', 'Ngo Quyen', 'Dak Lak', 'lan.ln947@gmail.com', 8035214409);
INSERT INTO customer.customers VALUES ('Ly Ngoc Hai', '429 Nguyen Trai', 'Son Tra', 'Binh Dinh', 'hai.ln948@gmail.com', 6570033082);
INSERT INTO customer.customers VALUES ('Bui Nam Duc', '526 Hang Non', 'Hai Chau', 'Quang Ninh', 'duc.bn173@gmail.com', 6520127286);
INSERT INTO customer.customers VALUES ('Duong Hai Minh', '207 Hang Voi', 'Son Tra', 'Quang Binh', 'minh.dh322@gmail.com', 1345622758);
INSERT INTO customer.customers VALUES ('Ta Chi Trinh', '599 Luong Van Can', 'Hoan Kiem', 'Khanh Hoa', 'trinh.tc491@gmail.com', 9805375773);
INSERT INTO customer.customers VALUES ('Ly Tuan Huyen', '355 Le Loi', 'Son Tra', 'Vung Tau', 'huyen.lt66@gmail.com', 1387707741);
INSERT INTO customer.customers VALUES ('Phan Khanh Nhi', '423 Phan Dinh Phung', 'Hai Ba Trung', 'Vinh', 'nhi.pk340@gmail.com', 1094008900);
INSERT INTO customer.customers VALUES ('Trinh Chi Nam', '258 Nguyen Trai', 'Ngo Quyen', 'Ha Noi', 'nam.tc221@gmail.com', 3252866869);
INSERT INTO customer.customers VALUES ('Phan Thanh Huyen', '107 Hang Ca', 'Quan 4', 'Binh Dinh', 'huyen.pt787@gmail.com', 1518797998);
INSERT INTO customer.customers VALUES ('Ho Nam Tien', '537 Hang Da', 'Long Bien', 'Ha Noi', 'tien.hn133@gmail.com', 3951496580);
INSERT INTO customer.customers VALUES ('Huynh Tuan Ngan', '85 Hoang Cau', 'Thanh Khe', 'Da Lat', 'ngan.ht165@gmail.com', 7438348866);
INSERT INTO customer.customers VALUES ('Vu Thi Huy', '931 Hang Bong', 'Hai Ba Trung', 'Ha Tinh', 'huy.vt182@gmail.com', 4107207512);
INSERT INTO customer.customers VALUES ('Phan Chi Quynh', '472 Ngo Quyen', 'Quan 4', 'Kon Tum', 'quynh.pc881@gmail.com', 9207945967);
INSERT INTO customer.customers VALUES ('Vu Hai Tien', '214 Ly Nam De', 'Tay Ho', 'Gia Lai', 'tien.vh463@gmail.com', 6800789022);
INSERT INTO customer.customers VALUES ('Ho Thanh Lan', '461 Ly Thuong Kiet', 'Hoang Mai', 'Binh Dinh', 'lan.ht321@gmail.com', 8533949601);
INSERT INTO customer.customers VALUES ('Duong Manh Xuan', '966 Ton Duc Thang', 'Binh Thanh', 'Hue', 'xuan.dm776@gmail.com', 5502919116);
INSERT INTO customer.customers VALUES ('Ta Khanh Quynh', '331 Lan Ong', 'Thanh Khe', 'Nha Trang', 'quynh.tk140@gmail.com', 9308246352);
INSERT INTO customer.customers VALUES ('Ta Hai Chien', '960 Hang Bo', 'Quan 5', 'Vung Tau', 'chien.th760@gmail.com', 5976238491);
INSERT INTO customer.customers VALUES ('Luong Thanh Chien', '924 Ba Trieu', 'Phu Nhuan', 'Can Tho', 'chien.lt11@gmail.com', 8306107096);
INSERT INTO customer.customers VALUES ('Dinh Hai Thanh', '405 Hoang Quoc Viet', 'Hai Chau', 'Gia Lai', 'thanh.dh880@gmail.com', 2730412503);
INSERT INTO customer.customers VALUES ('Quach Khanh Xuan', '815 Hoang Cau', 'Quan 3', 'Bac Ninh', 'xuan.qk457@gmail.com', 4714232176);
INSERT INTO customer.customers VALUES ('Bui Tuan Giang', '590 Phung Hung', 'Ha Dong', 'Ha Noi', 'giang.bt19@gmail.com', 6859603536);
INSERT INTO customer.customers VALUES ('Duong Thanh Cuong', '112 Nguyen Trai', 'Binh Thanh', 'Ha Nam', 'cuong.dt525@gmail.com', 1523140142);
INSERT INTO customer.customers VALUES ('Hoang Kieu Quynh', '67 Luong Van Can', 'Hoang Mai', 'Bien Hoa', 'quynh.hk320@gmail.com', 9128645539);
INSERT INTO customer.customers VALUES ('Bui Hai Huyen', '676 Hang Ma', 'Phu Nhuan', 'Vung Tau', 'huyen.bh308@gmail.com', 8012369942);
INSERT INTO customer.customers VALUES ('Dang Tuan Thao', '658 Xuan Thuy', 'Thanh Khe', 'Ha Noi', 'thao.dt469@gmail.com', 5081059399);
INSERT INTO customer.customers VALUES ('Dau Chi My', '22 Ho Tung Mau', 'Tay Ho', 'Binh Dinh', 'my.dc359@gmail.com', 9352395639);
INSERT INTO customer.customers VALUES ('Vu Khanh Huyen', '784 Pham Ngu Lao', 'Phu Nhuan', 'Ha Noi', 'huyen.vk639@gmail.com', 5833455990);
INSERT INTO customer.customers VALUES ('Ly Hoang Long', '978 Le Ngoc Han', 'Quan 5', 'Ha Tinh', 'long.lh388@gmail.com', 4207385908);
INSERT INTO customer.customers VALUES ('Hoang Chi Van', '881 Nguyen Trai', 'Long Bien', 'Quang Ninh', 'van.hc626@gmail.com', 9560202158);
INSERT INTO customer.customers VALUES ('Ngo Hai Huy', '991 Phan Chu Trinh', 'Bac Tu Liem', 'Thai Nguyen', 'huy.nh662@gmail.com', 7484193767);
INSERT INTO customer.customers VALUES ('Diep Minh Loan', '745 Hang Da', 'Phu Nhuan', 'Bien Hoa', 'loan.dm414@gmail.com', 8913880653);
INSERT INTO customer.customers VALUES ('Ho Hoang My', '612 Hoang Cau', 'Cau Giay', 'Bien Hoa', 'my.hh896@gmail.com', 5864610856);
INSERT INTO customer.customers VALUES ('Duong Tuan Lan', '364 Pham Ngu Lao', 'Binh Thanh', 'Da Nang', 'lan.dt414@gmail.com', 1269134220);
INSERT INTO customer.customers VALUES ('Nguyen Kieu Huong', '900 Hang Khay', 'Quan 2', 'Nam Dinh', 'huong.nk970@gmail.com', 7568285736);
INSERT INTO customer.customers VALUES ('Dau Thi Hiep', '767 Hung Vuong', 'Nam Tu Liem', 'Da Nang', 'hiep.dt42@gmail.com', 3171441613);
INSERT INTO customer.customers VALUES ('Nguyen Minh Tuyet', '551 Phan Dinh Phung', 'Ha Dong', 'Khanh Hoa', 'tuyet.nm991@gmail.com', 2846813093);
INSERT INTO customer.customers VALUES ('Bui Thi Ly', '416 Hang Gai', 'Hai Ba Trung', 'Vung Tau', 'ly.bt670@gmail.com', 3750917563);
INSERT INTO customer.customers VALUES ('Le Minh Quynh', '833 Hang Da', 'Hoan Kiem', 'Bien Hoa', 'quynh.lm280@gmail.com', 4122546507);
INSERT INTO customer.customers VALUES ('Ly Minh Nga', '401 Le Loi', 'Hai Chau', 'Quy Nhon', 'nga.lm532@gmail.com', 4858291277);
INSERT INTO customer.customers VALUES ('Ngo Nam Hung', '998 Hang Bo', 'Hai Chau', 'Quang Nam', 'hung.nn371@gmail.com', 3697831165);
INSERT INTO customer.customers VALUES ('Duong Ngoc Minh', '998 Luong Van Can', 'Cau Giay', 'Thai Nguyen', 'minh.dn627@gmail.com', 1535810291);
INSERT INTO customer.customers VALUES ('Ho Chi Hoa', '678 Hang Ngang', 'Quan 3', 'Phu Tho', 'hoa.hc874@gmail.com', 3258515163);
INSERT INTO customer.customers VALUES ('Phan Minh Chien', '937 Hang Can', 'Hong Bang', 'Quang Tri', 'chien.pm391@gmail.com', 8034803067);
INSERT INTO customer.customers VALUES ('Nguyen Chi Nhi', '700 Phung Hung', 'Le Chan', 'Hai Phong', 'nhi.nc742@gmail.com', 1966275482);
INSERT INTO customer.customers VALUES ('Trinh Minh Hoa', '441 Hoang Cau', 'Hong Bang', 'Can Tho', 'hoa.tm886@gmail.com', 3896732615);
INSERT INTO customer.customers VALUES ('Le Chi My', '944 Hang Khay', 'Thanh Khe', 'Nha Trang', 'my.lc224@gmail.com', 1309807938);
INSERT INTO customer.customers VALUES ('Quach Chi Ngan', '681 Ly Thuong Kiet', 'Ha Dong', 'Bac Ninh', 'ngan.qc444@gmail.com', 4162187354);
INSERT INTO customer.customers VALUES ('Ngo Kieu Duc', '956 O Cho Dua', 'Hai Ba Trung', 'Nam Dinh', 'duc.nk212@gmail.com', 3517999113);
INSERT INTO customer.customers VALUES ('Diep Tuan Ly', '692 Phan Chu Trinh', 'Hong Bang', 'Yen Bai', 'ly.dt587@gmail.com', 3608930136);
INSERT INTO customer.customers VALUES ('Trinh Hai Ngoc', '830 Nguyen Trai', 'Son Tra', 'Quang Tri', 'ngoc.th401@gmail.com', 4316198993);
INSERT INTO customer.customers VALUES ('Trinh Minh Lan', '696 Pham Hong Thai', 'Cau Giay', 'Ha Noi', 'lan.tm729@gmail.com', 9728979167);
INSERT INTO customer.customers VALUES ('Phan Chi Linh', '911 Hang Voi', 'Cam Le', 'Quang Ninh', 'linh.pc949@gmail.com', 9623070368);
INSERT INTO customer.customers VALUES ('Nguyen Minh Trinh', '661 Hang Luoc', 'Bac Tu Liem', 'Da Lat', 'trinh.nm179@gmail.com', 5185632333);
INSERT INTO customer.customers VALUES ('Dang Thi Tien', '418 Hoang Cau', 'Dong Da', 'Binh Dinh', 'tien.dt459@gmail.com', 2584297206);
INSERT INTO customer.customers VALUES ('Vo Minh Hoa', '47 Hoang Quoc Viet', 'Long Bien', 'Hai Phong', 'hoa.vm906@gmail.com', 7929738565);
INSERT INTO customer.customers VALUES ('Trinh Thi Xuan', '497 Nguyen Sieu', 'Son Tra', 'Gia Lai', 'xuan.tt757@gmail.com', 6983934859);
INSERT INTO customer.customers VALUES ('Quach Hoang Khanh', '912 Giang Vo', 'Hong Bang', 'Quang Ngai', 'khanh.qh386@gmail.com', 2783822183);
INSERT INTO customer.customers VALUES ('Luong Thanh Thuy', '314 Nguyen Trai', 'Hoang Mai', 'Quang Binh', 'thuy.lt908@gmail.com', 8734993741);
INSERT INTO customer.customers VALUES ('Trinh Thi Hoa', '427 Thuoc Bac', 'Le Chan', 'Ha Noi', 'hoa.tt401@gmail.com', 1046050980);
INSERT INTO customer.customers VALUES ('Bui Khanh Loan', '647 Hang Ma', 'Quan 1', 'Quy Nhon', 'loan.bk146@gmail.com', 9315881055);
INSERT INTO customer.customers VALUES ('Dang Thi Ngoc', '303 Hoang Cau', 'Long Bien', 'Bien Hoa', 'ngoc.dt744@gmail.com', 6718714017);
INSERT INTO customer.customers VALUES ('Pham Nam Ly', '109 Xuan Thuy', 'Quan 1', 'Khanh Hoa', 'ly.pn918@gmail.com', 9100133057);
INSERT INTO customer.customers VALUES ('Dinh Kieu Hai', '440 Hang Gai', 'Ba Dinh', 'Ha Nam', 'hai.dk61@gmail.com', 5840262368);
INSERT INTO customer.customers VALUES ('Diep Minh Huong', '853 Ly Nam De', 'Le Chan', 'Binh Dinh', 'huong.dm757@gmail.com', 5884831898);
INSERT INTO customer.customers VALUES ('Ngo Hai Hung', '179 Hang Da', 'Phu Nhuan', 'Nha Trang', 'hung.nh979@gmail.com', 4109548702);
INSERT INTO customer.customers VALUES ('Ta Thanh Huong', '218 Kim Ma', 'Ngo Quyen', 'Binh Thuan', 'huong.tt848@gmail.com', 1025029812);
INSERT INTO customer.customers VALUES ('Ta Khanh Phuong', '17 Hang Luoc', 'Hai Chau', 'Binh Dinh', 'phuong.tk300@gmail.com', 5460484750);
INSERT INTO customer.customers VALUES ('Trinh Hai Van', '584 Hang Voi', 'Hoang Mai', 'Ha Noi', 'van.th586@gmail.com', 9808374522);
INSERT INTO customer.customers VALUES ('Ta Chi Thao', '707 Pham Hong Thai', 'Thanh Khe', 'Can Tho', 'thao.tc259@gmail.com', 1152158663);
INSERT INTO customer.customers VALUES ('Vo Tuan Xuan', '850 Ba Trieu', 'Ngo Quyen', 'Da Lat', 'xuan.vt468@gmail.com', 8993477209);
INSERT INTO customer.customers VALUES ('Ngo Chi Nga', '539 Tran Quoc Toan', 'Son Tra', 'Quang Tri', 'nga.nc525@gmail.com', 8032436124);
INSERT INTO customer.customers VALUES ('Diep Thi Khoa', '507 Ly Nam De', 'Dong Da', 'Can Tho', 'khoa.dt53@gmail.com', 5323066351);
INSERT INTO customer.customers VALUES ('Bui Hoang Sang', '33 Tran Phu', 'Le Chan', 'Hue', 'sang.bh340@gmail.com', 9047408540);
INSERT INTO customer.customers VALUES ('Nguyen Tuan Ha', '498 Hang Gai', 'Ba Dinh', 'Da Lat', 'ha.nt980@gmail.com', 1514525894);
INSERT INTO customer.customers VALUES ('Huynh Kieu Khanh', '1 Pham Ngu Lao', 'Quan 1', 'Quang Tri', 'khanh.hk753@gmail.com', 7832007218);
INSERT INTO customer.customers VALUES ('Vu Manh Duc', '973 Hoang Quoc Viet', 'Hong Bang', 'Thai Nguyen', 'duc.vm160@gmail.com', 7718966063);
INSERT INTO customer.customers VALUES ('Hoang Minh Hoa', '43 Hang Ma', 'Hong Bang', 'Bac Ninh', 'hoa.hm396@gmail.com', 5934858839);
INSERT INTO customer.customers VALUES ('Pham Kieu Sang', '166 Thuoc Bac', 'Thanh Xuan', 'Hai Phong', 'sang.pk620@gmail.com', 4445130811);
INSERT INTO customer.customers VALUES ('Ta Hai Cuong', '867 Hang Da', 'Hong Bang', 'Phu Yen', 'cuong.th466@gmail.com', 3652713130);
INSERT INTO customer.customers VALUES ('Quach Manh Thao', '61 Hoang Quoc Viet', 'Phu Nhuan', 'Da Lat', 'thao.qm749@gmail.com', 8795911577);
INSERT INTO customer.customers VALUES ('Ly Kieu Quynh', '206 Hoang Cau', 'Phu Nhuan', 'Thai Nguyen', 'quynh.lk528@gmail.com', 6791962534);
INSERT INTO customer.customers VALUES ('Huynh Manh Phuong', '284 Le Thanh Ton', 'Ba Dinh', 'Gia Lai', 'phuong.hm278@gmail.com', 3070241339);
INSERT INTO customer.customers VALUES ('Ly Kieu Tuyet', '741 Hang Bo', 'Quan 5', 'Binh Dinh', 'tuyet.lk436@gmail.com', 5756308415);
INSERT INTO customer.customers VALUES ('Ho Kieu Duc', '193 Lan Ong', 'Le Chan', 'Khanh Hoa', 'duc.hk447@gmail.com', 5621743275);
INSERT INTO customer.customers VALUES ('Dang Thanh Linh', '937 Le Loi', 'Son Tra', 'Ha Nam', 'linh.dt727@gmail.com', 5320427441);
INSERT INTO customer.customers VALUES ('Ly Kieu Tien', '747 Hang Luoc', 'Long Bien', 'Da Nang', 'tien.lk900@gmail.com', 7266153543);
INSERT INTO customer.customers VALUES ('Ta Ngoc Nga', '361 Ton Duc Thang', 'Hoang Mai', 'Binh Dinh', 'nga.tn290@gmail.com', 4566042934);
INSERT INTO customer.customers VALUES ('Duong Minh Anh', '276 Hoang Quoc Viet', 'Binh Thanh', 'Ha Tinh', 'anh.dm213@gmail.com', 5157069395);
INSERT INTO customer.customers VALUES ('Ho Minh Hoa', '967 Phung Hung', 'Quan 2', 'Yen Bai', 'hoa.hm279@gmail.com', 5681895484);
INSERT INTO customer.customers VALUES ('Huynh Chi Thanh', '865 Le Ngoc Han', 'Hoang Mai', 'Da Nang', 'thanh.hc838@gmail.com', 5739833106);
INSERT INTO customer.customers VALUES ('Dinh Kieu Chien', '382 Hoang Cau', 'Dong Da', 'Da Nang', 'chien.dk684@gmail.com', 9555315873);
INSERT INTO customer.customers VALUES ('Ta Thi Ngan', '892 Nguyen Sieu', 'Quan 3', 'Hai Phong', 'ngan.tt909@gmail.com', 8605105589);
INSERT INTO customer.customers VALUES ('Le Kieu Tien', '813 Hoang Cau', 'Hong Bang', 'Quy Nhon', 'tien.lk55@gmail.com', 6908553417);
INSERT INTO customer.customers VALUES ('Dinh Minh Hiep', '48 Hang Gai', 'Nam Tu Liem', 'Binh Dinh', 'hiep.dm582@gmail.com', 7272027280);
INSERT INTO customer.customers VALUES ('Luong Tuan Thao', '229 Luong Van Can', 'Quan 3', 'Quang Tri', 'thao.lt111@gmail.com', 8034598996);
INSERT INTO customer.customers VALUES ('Nguyen Kieu Ngoc', '354 Phung Hung', 'Hai Ba Trung', 'Da Lat', 'ngoc.nk559@gmail.com', 1286714646);
INSERT INTO customer.customers VALUES ('Dinh Thanh Trang', '618 Hang Gai', 'Quan 5', 'Quang Ngai', 'trang.dt623@gmail.com', 1959281225);
INSERT INTO customer.customers VALUES ('Bui Tuan Chien', '698 Hang Khay', 'Hoan Kiem', 'Ha Noi', 'chien.bt92@gmail.com', 9878608735);
INSERT INTO customer.customers VALUES ('Luong Thanh Nam', '806 Phung Hung', 'Dong Da', 'Can Tho', 'nam.lt205@gmail.com', 7208378650);
INSERT INTO customer.customers VALUES ('Ho Manh Van', '198 Hoang Quoc Viet', 'Quan 5', 'Ho Chi Minh', 'van.hm452@gmail.com', 2253853922);
INSERT INTO customer.customers VALUES ('Do Tuan Giang', '377 Xuan Thuy', 'Bac Tu Liem', 'Hai Phong', 'giang.dt319@gmail.com', 1113026119);
INSERT INTO customer.customers VALUES ('Ta Thi Hung', '926 Le Thanh Ton', 'Hong Bang', 'Ha Noi', 'hung.tt787@gmail.com', 8490006631);
INSERT INTO customer.customers VALUES ('Bui Tuan Quynh', '861 Hang Chieu', 'Long Bien', 'Quang Nam', 'quynh.bt73@gmail.com', 2317813977);
INSERT INTO customer.customers VALUES ('Duong Minh Lan', '560 Tran Hung Dao', 'Quan 1', 'Da Nang', 'lan.dm820@gmail.com', 4729368753);
INSERT INTO customer.customers VALUES ('Ta Manh Nhi', '730 Hang Chieu', 'Hoan Kiem', 'Can Tho', 'nhi.tm695@gmail.com', 9787395577);
INSERT INTO customer.customers VALUES ('Dau Khanh Lam', '155 Hang Ngang', 'Nam Tu Liem', 'Nam Dinh', 'lam.dk45@gmail.com', 8439800283);
INSERT INTO customer.customers VALUES ('Ta Manh Huong', '376 Hoang Cau', 'Hoang Mai', 'Nha Trang', 'huong.tm465@gmail.com', 2309858513);
INSERT INTO customer.customers VALUES ('Tran Hai Phuong', '900 Thuoc Bac', 'Le Chan', 'Nha Trang', 'phuong.th943@gmail.com', 2837847446);
INSERT INTO customer.customers VALUES ('Quach Khanh Ha', '376 Xuan Thuy', 'Dong Da', 'Bac Ninh', 'ha.qk259@gmail.com', 9814135594);
INSERT INTO customer.customers VALUES ('Duong Hai Minh', '791 Hang Da', 'Cam Le', 'Bac Ninh', 'minh.dh530@gmail.com', 5552834066);
INSERT INTO customer.customers VALUES ('Le Chi Sang', '342 Ly Nam De', 'Thanh Khe', 'Ha Tinh', 'sang.lc459@gmail.com', 6091804027);
INSERT INTO customer.customers VALUES ('Dang Hoang Hung', '922 Ngo Quyen', 'Quan 2', 'Quang Ninh', 'hung.dh815@gmail.com', 3808788036);
INSERT INTO customer.customers VALUES ('Quach Hai Hiep', '561 Hoang Cau', 'Hoang Mai', 'Da Nang', 'hiep.qh988@gmail.com', 9883005894);
INSERT INTO customer.customers VALUES ('Trinh Minh Van', '751 Tran Dai Nghia', 'Hai Ba Trung', 'Nam Dinh', 'van.tm635@gmail.com', 6559790985);
INSERT INTO customer.customers VALUES ('Phan Hoang Ha', '292 Hang Tre', 'Hoan Kiem', 'Quang Ninh', 'ha.ph964@gmail.com', 7769635619);
INSERT INTO customer.customers VALUES ('Do Hoang Trang', '928 Hang Gai', 'Dong Da', 'Binh Thuan', 'trang.dh323@gmail.com', 2023031399);
INSERT INTO customer.customers VALUES ('Duong Kieu Linh', '21 Hoang Cau', 'Quan 1', 'Ha Noi', 'linh.dk381@gmail.com', 2118359860);
INSERT INTO customer.customers VALUES ('Ly Hoang Tien', '657 Luong Van Can', 'Binh Thanh', 'Ha Nam', 'tien.lh204@gmail.com', 3638827399);
INSERT INTO customer.customers VALUES ('Ho Ngoc Khoa', '583 Ngo Quyen', 'Long Bien', 'Gia Lai', 'khoa.hn60@gmail.com', 2151148616);
INSERT INTO customer.customers VALUES ('Ngo Tuan Ngan', '86 O Cho Dua', 'Nam Tu Liem', 'Binh Thuan', 'ngan.nt196@gmail.com', 1104252957);
INSERT INTO customer.customers VALUES ('Pham Hoang Lan', '811 Giang Vo', 'Binh Thanh', 'Hai Phong', 'lan.ph803@gmail.com', 5687883827);
INSERT INTO customer.customers VALUES ('Le Thi Loan', '322 Hang Ca', 'Tay Ho', 'Da Nang', 'loan.lt835@gmail.com', 3918129125);
INSERT INTO customer.customers VALUES ('Dang Minh Hoa', '500 Hang Tre', 'Ngo Quyen', 'Vinh', 'hoa.dm486@gmail.com', 3368694769);
INSERT INTO customer.customers VALUES ('Phan Thi Loan', '1 Hang Bo', 'Hoan Kiem', 'Ha Nam', 'loan.pt510@gmail.com', 8232831004);
INSERT INTO customer.customers VALUES ('Pham Minh Cuong', '550 Hang Non', 'Binh Thanh', 'Ninh Thuan', 'cuong.pm514@gmail.com', 7852428390);
INSERT INTO customer.customers VALUES ('Nguyen Thanh Nhung', '289 Hang Ma', 'Phu Nhuan', 'Ha Noi', 'nhung.nt748@gmail.com', 9164358440);
INSERT INTO customer.customers VALUES ('Nguyen Kieu Xuan', '358 Hang Bong', 'Phu Nhuan', 'Ninh Thuan', 'xuan.nk296@gmail.com', 3073076750);
INSERT INTO customer.customers VALUES ('Ngo Nam Duc', '351 Hang Tre', 'Binh Thanh', 'Phu Tho', 'duc.nn528@gmail.com', 3024838882);
INSERT INTO customer.customers VALUES ('Do Hoang Xuan', '402 Hang Da', 'Le Chan', 'Binh Dinh', 'xuan.dh499@gmail.com', 5939921515);
INSERT INTO customer.customers VALUES ('Le Manh Huy', '798 Hang Voi', 'Hai Ba Trung', 'Ha Nam', 'huy.lm784@gmail.com', 9105510437);
INSERT INTO customer.customers VALUES ('Ta Thanh Ngoc', '193 Hang Ca', 'Long Bien', 'Ha Nam', 'ngoc.tt665@gmail.com', 9471763072);
INSERT INTO customer.customers VALUES ('Dinh Thanh Lan', '964 Hang Can', 'Hong Bang', 'Nha Trang', 'lan.dt713@gmail.com', 2501748502);
INSERT INTO customer.customers VALUES ('Huynh Thanh Huong', '378 Hang Voi', 'Ba Dinh', 'Quang Ninh', 'huong.ht495@gmail.com', 2842742590);
INSERT INTO customer.customers VALUES ('Dang Thanh Chien', '302 Luong Dinh Cua', 'Quan 3', 'Quang Nam', 'chien.dt11@gmail.com', 2020569634);
INSERT INTO customer.customers VALUES ('Luong Nam Hiep', '853 Hang Ca', 'Phu Nhuan', 'Dak Lak', 'hiep.ln439@gmail.com', 4356478522);
INSERT INTO customer.customers VALUES ('Trinh Kieu Quynh', '219 Hang Chieu', 'Le Chan', 'Ninh Thuan', 'quynh.tk202@gmail.com', 5793576859);
INSERT INTO customer.customers VALUES ('Quach Kieu Chien', '489 Ngo Quyen', 'Le Chan', 'Dak Lak', 'chien.qk128@gmail.com', 9889441006);
INSERT INTO customer.customers VALUES ('Vu Hai Nhi', '109 Nguyen Sieu', 'Hai Ba Trung', 'Vinh', 'nhi.vh212@gmail.com', 4074246453);
INSERT INTO customer.customers VALUES ('Dinh Manh Lam', '947 Tran Hung Dao', 'Ngo Quyen', 'Da Nang', 'lam.dm717@gmail.com', 6211610846);
INSERT INTO customer.customers VALUES ('Do Nam Ngoc', '969 Ly Thuong Kiet', 'Quan 4', 'Hue', 'ngoc.dn494@gmail.com', 5021405417);
INSERT INTO customer.customers VALUES ('Vu Thi Anh', '820 Hoang Cau', 'Long Bien', 'Can Tho', 'anh.vt468@gmail.com', 9491730236);
INSERT INTO customer.customers VALUES ('Trinh Hoang Thanh', '385 Nguyen Xi', 'Hai Chau', 'Phu Tho', 'thanh.th830@gmail.com', 4697892813);
INSERT INTO customer.customers VALUES ('Nguyen Thi Tuyet', '784 Hang Da', 'Long Bien', 'Ha Noi', 'tuyet.nt448@gmail.com', 8693983426);
INSERT INTO customer.customers VALUES ('Dau Kieu Hiep', '376 Hang Bong', 'Quan 3', 'Gia Lai', 'hiep.dk319@gmail.com', 1963558348);
INSERT INTO customer.customers VALUES ('Hoang Thanh Thanh', '470 Le Duan', 'Hai Ba Trung', 'Ninh Thuan', 'thanh.ht387@gmail.com', 8691614924);
INSERT INTO customer.customers VALUES ('Vu Chi Trinh', '120 Tran Dai Nghia', 'Quan 5', 'Quy Nhon', 'trinh.vc824@gmail.com', 1240060222);
INSERT INTO customer.customers VALUES ('Ngo Minh Cuong', '605 Hang Ca', 'Ha Dong', 'Phu Yen', 'cuong.nm663@gmail.com', 8996272275);
INSERT INTO customer.customers VALUES ('Ly Hai Trinh', '885 Phung Hung', 'Quan 2', 'Nha Trang', 'trinh.lh234@gmail.com', 5084725389);
INSERT INTO customer.customers VALUES ('Hoang Khanh Lam', '134 Hoang Quoc Viet', 'Quan 4', 'Quang Nam', 'lam.hk738@gmail.com', 9789038941);
INSERT INTO customer.customers VALUES ('Vu Tuan Hai', '75 Hang Tre', 'Hoan Kiem', 'Phu Tho', 'hai.vt304@gmail.com', 5510775668);
INSERT INTO customer.customers VALUES ('Tran Hoang Lam', '444 Le Ngoc Han', 'Quan 4', 'Da Nang', 'lam.th450@gmail.com', 5513775448);
INSERT INTO customer.customers VALUES ('Dau Chi Tuyet', '806 Ly Thuong Kiet', 'Cam Le', 'Hai Phong', 'tuyet.dc563@gmail.com', 3881481852);
INSERT INTO customer.customers VALUES ('Ngo Kieu Loan', '364 Hang Tre', 'Quan 1', 'Quang Ninh', 'loan.nk619@gmail.com', 8788332127);
INSERT INTO customer.customers VALUES ('Huynh Ngoc Huong', '584 Hoang Quoc Viet', 'Ha Dong', 'Hai Phong', 'huong.hn801@gmail.com', 7159533618);
INSERT INTO customer.customers VALUES ('Pham Hoang Lam', '849 Hang Ngang', 'Quan 1', 'Da Nang', 'lam.ph942@gmail.com', 9706084762);
INSERT INTO customer.customers VALUES ('Vo Thanh Duc', '468 O Cho Dua', 'Cau Giay', 'Ha Tinh', 'duc.vt56@gmail.com', 4676053945);
INSERT INTO customer.customers VALUES ('Dau Hoang Nhi', '647 O Cho Dua', 'Cau Giay', 'Da Lat', 'nhi.dh444@gmail.com', 4150061136);
INSERT INTO customer.customers VALUES ('Pham Manh Duc', '722 Hang Voi', 'Hoang Mai', 'Gia Lai', 'duc.pm376@gmail.com', 5307615625);
INSERT INTO customer.customers VALUES ('Dinh Tuan Khoa', '546 Nguyen Sieu', 'Ba Dinh', 'Yen Bai', 'khoa.dt402@gmail.com', 7274972817);
INSERT INTO customer.customers VALUES ('Le Thanh Minh', '999 Ton Duc Thang', 'Thanh Xuan', 'Binh Thuan', 'minh.lt698@gmail.com', 8361523135);
INSERT INTO customer.customers VALUES ('Vu Khanh Nhi', '113 Phan Dinh Phung', 'Ba Dinh', 'Hue', 'nhi.vk72@gmail.com', 9413302528);
INSERT INTO customer.customers VALUES ('Ho Thanh Linh', '978 Kim Ma', 'Thanh Khe', 'Quang Ngai', 'linh.ht331@gmail.com', 7506411217);
INSERT INTO customer.customers VALUES ('Diep Ngoc Huong', '231 Kim Ma', 'Nam Tu Liem', 'Vinh', 'huong.dn949@gmail.com', 4470551224);
INSERT INTO customer.customers VALUES ('Dau Chi Hiep', '302 Pham Hong Thai', 'Phu Nhuan', 'Can Tho', 'hiep.dc962@gmail.com', 3929231678);
INSERT INTO customer.customers VALUES ('Le Thi Thao', '384 Le Loi', 'Son Tra', 'Da Nang', 'thao.lt57@gmail.com', 8386496589);
INSERT INTO customer.customers VALUES ('Do Tuan Tien', '868 Tran Hung Dao', 'Hoan Kiem', 'Hai Phong', 'tien.dt729@gmail.com', 1479096719);
INSERT INTO customer.customers VALUES ('Vu Ngoc Thuy', '174 Phung Hung', 'Quan 5', 'Khanh Hoa', 'thuy.vn631@gmail.com', 8668213093);
INSERT INTO customer.customers VALUES ('Dinh Manh Hai', '901 Hang Luoc', 'Ha Dong', 'Quang Binh', 'hai.dm12@gmail.com', 8908648623);
INSERT INTO customer.customers VALUES ('Diep Hai Lan', '404 Kim Ma', 'Son Tra', 'Khanh Hoa', 'lan.dh322@gmail.com', 3409802468);
INSERT INTO customer.customers VALUES ('Dinh Kieu Nhi', '292 Ngo Quyen', 'Hong Bang', 'Hai Phong', 'nhi.dk232@gmail.com', 4352165496);
INSERT INTO customer.customers VALUES ('Trinh Tuan Hung', '557 Hang Bo', 'Thanh Xuan', 'Quy Nhon', 'hung.tt94@gmail.com', 2943298053);
INSERT INTO customer.customers VALUES ('Duong Thi Hai', '218 Le Ngoc Han', 'Phu Nhuan', 'Khanh Hoa', 'hai.dt582@gmail.com', 4849081424);
INSERT INTO customer.customers VALUES ('Ho Tuan Khanh', '273 Hang Tre', 'Quan 3', 'Ha Nam', 'khanh.ht767@gmail.com', 7072438265);
INSERT INTO customer.customers VALUES ('Bui Kieu Linh', '779 Hang Mam', 'Quan 4', 'Gia Lai', 'linh.bk352@gmail.com', 9741340504);
INSERT INTO customer.customers VALUES ('Le Nam Tien', '392 Luong Van Can', 'Quan 1', 'Thai Nguyen', 'tien.ln171@gmail.com', 8368657920);
INSERT INTO customer.customers VALUES ('Phan Manh Khoa', '260 Ba Trieu', 'Hong Bang', 'Gia Lai', 'khoa.pm511@gmail.com', 6017732986);
INSERT INTO customer.customers VALUES ('Dang Khanh Long', '341 Ton Duc Thang', 'Hong Bang', 'Hue', 'long.dk967@gmail.com', 1856752107);
INSERT INTO customer.customers VALUES ('Duong Thanh My', '702 O Cho Dua', 'Le Chan', 'Ho Chi Minh', 'my.dt494@gmail.com', 8636196286);
INSERT INTO customer.customers VALUES ('Pham Kieu Duc', '668 Luong Dinh Cua', 'Cam Le', 'Gia Lai', 'duc.pk804@gmail.com', 7030303080);
INSERT INTO customer.customers VALUES ('Ta Khanh Chien', '483 Pham Hong Thai', 'Quan 2', 'Yen Bai', 'chien.tk280@gmail.com', 8818665347);
INSERT INTO customer.customers VALUES ('Duong Nam Chien', '378 O Cho Dua', 'Phu Nhuan', 'Vinh', 'chien.dn1000@gmail.com', 1893245742);
INSERT INTO customer.customers VALUES ('Diep Manh Lan', '99 Lan Ong', 'Nam Tu Liem', 'Bien Hoa', 'lan.dm349@gmail.com', 3564892975);
INSERT INTO customer.customers VALUES ('Do Minh Tuyet', '110 Ba Trieu', 'Ngo Quyen', 'Binh Dinh', 'tuyet.dm387@gmail.com', 1662061197);
INSERT INTO customer.customers VALUES ('Quach Thanh Ha', '731 Hang Can', 'Ba Dinh', 'Can Tho', 'ha.qt599@gmail.com', 6622527545);
INSERT INTO customer.customers VALUES ('Tran Khanh Tien', '233 Phan Chu Trinh', 'Quan 2', 'Phu Tho', 'tien.tk154@gmail.com', 5429233668);
INSERT INTO customer.customers VALUES ('Tran Hoang Anh', '229 Le Duan', 'Hong Bang', 'Khanh Hoa', 'anh.th771@gmail.com', 2796561927);
INSERT INTO customer.customers VALUES ('Do Kieu Trang', '479 Le Loi', 'Long Bien', 'Da Nang', 'trang.dk125@gmail.com', 2933541731);
INSERT INTO customer.customers VALUES ('Do Hai Hiep', '246 Hang Bong', 'Ha Dong', 'Yen Bai', 'hiep.dh527@gmail.com', 6983667305);
INSERT INTO customer.customers VALUES ('Pham Manh Nhi', '541 Ba Trieu', 'Cam Le', 'Quy Nhon', 'nhi.pm137@gmail.com', 9086525413);
INSERT INTO customer.customers VALUES ('Duong Ngoc Hiep', '925 Luong Van Can', 'Bac Tu Liem', 'Ninh Thuan', 'hiep.dn796@gmail.com', 9215687827);
INSERT INTO customer.customers VALUES ('Quach Hai Khanh', '833 Hang Luoc', 'Ba Dinh', 'Vung Tau', 'khanh.qh438@gmail.com', 5369219888);
INSERT INTO customer.customers VALUES ('Ho Tuan Thanh', '846 Thuoc Bac', 'Quan 2', 'Quang Tri', 'thanh.ht811@gmail.com', 5997135108);
INSERT INTO customer.customers VALUES ('Pham Kieu Trang', '630 Hoang Cau', 'Dong Da', 'Hai Phong', 'trang.pk6@gmail.com', 8756290934);
INSERT INTO customer.customers VALUES ('Dau Nam Hiep', '854 Nguyen Sieu', 'Hoang Mai', 'Ho Chi Minh', 'hiep.dn9@gmail.com', 9093883195);
INSERT INTO customer.customers VALUES ('Duong Hoang Tien', '394 Hang Mam', 'Quan 5', 'Da Nang', 'tien.dh674@gmail.com', 6437199106);
INSERT INTO customer.customers VALUES ('Le Minh Lan', '211 Quan Thanh', 'Son Tra', 'Vinh', 'lan.lm920@gmail.com', 4196347417);
INSERT INTO customer.customers VALUES ('Luong Thi Anh', '20 Phan Dinh Phung', 'Hai Ba Trung', 'Ninh Thuan', 'anh.lt444@gmail.com', 2088672979);
INSERT INTO customer.customers VALUES ('Tran Nam Huong', '527 Ly Thuong Kiet', 'Quan 4', 'Gia Lai', 'huong.tn873@gmail.com', 2695120017);
INSERT INTO customer.customers VALUES ('Ngo Nam Phuong', '555 Kim Ma', 'Bac Tu Liem', 'Vung Tau', 'phuong.nn365@gmail.com', 3018369765);
INSERT INTO customer.customers VALUES ('Bui Tuan Thao', '137 Hang Bong', 'Ngo Quyen', 'Bien Hoa', 'thao.bt306@gmail.com', 5486205415);
INSERT INTO customer.customers VALUES ('Dau Hoang Huong', '687 Hang Bong', 'Hoang Mai', 'Thai Nguyen', 'huong.dh478@gmail.com', 7845768699);
INSERT INTO customer.customers VALUES ('Le Thi Cuong', '678 Hoang Cau', 'Cam Le', 'Thai Nguyen', 'cuong.lt329@gmail.com', 6748073580);
INSERT INTO customer.customers VALUES ('Duong Kieu Van', '536 Tran Quoc Toan', 'Dong Da', 'Bac Ninh', 'van.dk78@gmail.com', 5309393462);
INSERT INTO customer.customers VALUES ('Hoang Tuan Huong', '585 Quan Thanh', 'Phu Nhuan', 'Nam Dinh', 'huong.ht663@gmail.com', 4732666573);
INSERT INTO customer.customers VALUES ('Ho Nam Thuy', '459 Ly Thuong Kiet', 'Tay Ho', 'Vung Tau', 'thuy.hn240@gmail.com', 8250568021);
INSERT INTO customer.customers VALUES ('Ngo Manh Phuong', '420 Xuan Thuy', 'Tay Ho', 'Hai Phong', 'phuong.nm642@gmail.com', 8543526555);
INSERT INTO customer.customers VALUES ('Duong Thanh Huong', '18 Le Ngoc Han', 'Thanh Xuan', 'Quang Binh', 'huong.dt10@gmail.com', 2187430843);
INSERT INTO customer.customers VALUES ('Duong Hai Giang', '690 Tran Dai Nghia', 'Hoan Kiem', 'Ninh Thuan', 'giang.dh979@gmail.com', 8053888470);
INSERT INTO customer.customers VALUES ('Vu Kieu Long', '53 Thuoc Bac', 'Bac Tu Liem', 'Thai Nguyen', 'long.vk746@gmail.com', 2204163584);
INSERT INTO customer.customers VALUES ('Dang Tuan Huy', '754 Thuoc Bac', 'Le Chan', 'Khanh Hoa', 'huy.dt594@gmail.com', 2947762206);
INSERT INTO customer.customers VALUES ('Hoang Manh Lam', '703 Nguyen Sieu', 'Quan 5', 'Dak Lak', 'lam.hm445@gmail.com', 2731837259);
INSERT INTO customer.customers VALUES ('Dau Thi Hai', '573 Hang Ngang', 'Ngo Quyen', 'Ninh Thuan', 'hai.dt610@gmail.com', 4286744153);
INSERT INTO customer.customers VALUES ('Duong Ngoc Ha', '376 Hang Chieu', 'Tay Ho', 'Dak Lak', 'ha.dn929@gmail.com', 1234286442);
INSERT INTO customer.customers VALUES ('Dau Chi Ha', '404 Hang Bo', 'Quan 2', 'Can Tho', 'ha.dc187@gmail.com', 5073694922);
INSERT INTO customer.customers VALUES ('Dau Nam Nhi', '567 Nguyen Xi', 'Bac Tu Liem', 'Bien Hoa', 'nhi.dn483@gmail.com', 4164131661);
INSERT INTO customer.customers VALUES ('Huynh Chi Tien', '736 Nguyen Xi', 'Tay Ho', 'Binh Dinh', 'tien.hc989@gmail.com', 3468475269);
INSERT INTO customer.customers VALUES ('Dang Ngoc Lam', '181 Hang Ngang', 'Tay Ho', 'Bien Hoa', 'lam.dn779@gmail.com', 4066523194);
INSERT INTO customer.customers VALUES ('Diep Tuan Lam', '482 Hang Bo', 'Hai Ba Trung', 'Quang Tri', 'lam.dt800@gmail.com', 8273742784);
INSERT INTO customer.customers VALUES ('Bui Manh Sang', '148 Lan Ong', 'Son Tra', 'Hue', 'sang.bm421@gmail.com', 1446511644);
INSERT INTO customer.customers VALUES ('Ta Chi Tien', '672 Pham Hong Thai', 'Ngo Quyen', 'Ha Noi', 'tien.tc761@gmail.com', 3092490169);
INSERT INTO customer.customers VALUES ('Bui Tuan Long', '512 Le Loi', 'Quan 3', 'Ha Noi', 'long.bt32@gmail.com', 6742659979);
INSERT INTO customer.customers VALUES ('Nguyen Hai Loan', '177 Hang Non', 'Long Bien', 'Bac Ninh', 'loan.nh832@gmail.com', 8644401599);
INSERT INTO customer.customers VALUES ('Vo Hai Thao', '690 Hang Mam', 'Cau Giay', 'Phu Tho', 'thao.vh554@gmail.com', 8309133929);
INSERT INTO customer.customers VALUES ('Dang Thanh Phuong', '4 Lan Ong', 'Ba Dinh', 'Ha Nam', 'phuong.dt766@gmail.com', 8028826792);
INSERT INTO customer.customers VALUES ('Tran Khanh Van', '816 Pham Ngu Lao', 'Long Bien', 'Phu Yen', 'van.tk372@gmail.com', 4547983319);
INSERT INTO customer.customers VALUES ('Hoang Hoang Lan', '311 Hang Gai', 'Cam Le', 'Yen Bai', 'lan.hh617@gmail.com', 2189242585);
INSERT INTO customer.customers VALUES ('Diep Hoang Ly', '849 Luong Dinh Cua', 'Hoan Kiem', 'Bac Ninh', 'ly.dh380@gmail.com', 9703693296);
INSERT INTO customer.customers VALUES ('Ly Chi Cuong', '829 Nguyen Trai', 'Thanh Khe', 'Yen Bai', 'cuong.lc426@gmail.com', 3200528711);
INSERT INTO customer.customers VALUES ('Ngo Tuan Hai', '947 Tran Phu', 'Ngo Quyen', 'Ha Nam', 'hai.nt575@gmail.com', 5332408565);
INSERT INTO customer.customers VALUES ('Trinh Thi Tuyet', '558 Nguyen Xi', 'Nam Tu Liem', 'Ha Noi', 'tuyet.tt335@gmail.com', 2345059476);
INSERT INTO customer.customers VALUES ('Duong Ngoc Ngan', '152 Ho Tung Mau', 'Son Tra', 'Vung Tau', 'ngan.dn486@gmail.com', 1408218255);
INSERT INTO customer.customers VALUES ('Ly Minh Huy', '788 Hang Khay', 'Hai Ba Trung', 'Ha Noi', 'huy.lm718@gmail.com', 5279562006);
INSERT INTO customer.customers VALUES ('Huynh Thanh Ngoc', '573 Hang Luoc', 'Ba Dinh', 'Khanh Hoa', 'ngoc.ht462@gmail.com', 2696849734);
INSERT INTO customer.customers VALUES ('Dinh Thi Ngoc', '964 Le Loi', 'Quan 1', 'Phu Tho', 'ngoc.dt427@gmail.com', 5562228549);
INSERT INTO customer.customers VALUES ('Dang Hai Ngan', '690 Hang Ca', 'Tay Ho', 'Kon Tum', 'ngan.dh310@gmail.com', 5698561044);
INSERT INTO customer.customers VALUES ('Phan Kieu Thuy', '564 O Cho Dua', 'Ha Dong', 'Ninh Thuan', 'thuy.pk477@gmail.com', 2500533827);
INSERT INTO customer.customers VALUES ('Diep Chi Minh', '327 Thuoc Bac', 'Quan 5', 'Quang Ninh', 'minh.dc877@gmail.com', 6921962799);
INSERT INTO customer.customers VALUES ('Hoang Hoang Giang', '924 Hang Da', 'Quan 5', 'Quang Ninh', 'giang.hh636@gmail.com', 4031272135);
INSERT INTO customer.customers VALUES ('Bui Thi Xuan', '120 Le Duan', 'Hoang Mai', 'Binh Thuan', 'xuan.bt27@gmail.com', 2249835189);
INSERT INTO customer.customers VALUES ('Duong Khanh Van', '47 Nguyen Xi', 'Hong Bang', 'Dak Lak', 'van.dk726@gmail.com', 3048001166);
INSERT INTO customer.customers VALUES ('Le Manh Cuong', '656 Phung Hung', 'Cau Giay', 'Da Nang', 'cuong.lm630@gmail.com', 5489341215);
INSERT INTO customer.customers VALUES ('Dinh Thi Ly', '820 Pham Ngu Lao', 'Hoan Kiem', 'Nam Dinh', 'ly.dt703@gmail.com', 5683555732);
INSERT INTO customer.customers VALUES ('Hoang Kieu Chien', '391 Hoang Cau', 'Hai Ba Trung', 'Nha Trang', 'chien.hk470@gmail.com', 4541824214);
INSERT INTO customer.customers VALUES ('Vo Manh Van', '636 Hang Tre', 'Quan 4', 'Thai Nguyen', 'van.vm326@gmail.com', 9298937794);
INSERT INTO customer.customers VALUES ('Ngo Hoang Trang', '714 Hung Vuong', 'Hai Chau', 'Dak Lak', 'trang.nh148@gmail.com', 2203928104);
INSERT INTO customer.customers VALUES ('Dang Chi Anh', '27 Hang Ngang', 'Ngo Quyen', 'Kon Tum', 'anh.dc602@gmail.com', 3186820264);
INSERT INTO customer.customers VALUES ('Duong Tuan Thuy', '503 Tran Phu', 'Son Tra', 'Kon Tum', 'thuy.dt368@gmail.com', 2958717434);
INSERT INTO customer.customers VALUES ('Hoang Chi Thanh', '381 Hang Can', 'Ngo Quyen', 'Quang Ngai', 'thanh.hc346@gmail.com', 8051698349);
INSERT INTO customer.customers VALUES ('Ta Tuan Hiep', '248 Hang Bong', 'Quan 1', 'Ha Nam', 'hiep.tt713@gmail.com', 9621171012);
INSERT INTO customer.customers VALUES ('Ta Ngoc Ha', '398 Le Thanh Ton', 'Binh Thanh', 'Phu Tho', 'ha.tn28@gmail.com', 9731477660);
INSERT INTO customer.customers VALUES ('Do Kieu Van', '510 Ly Nam De', 'Hai Chau', 'Quang Tri', 'van.dk613@gmail.com', 9485809857);
INSERT INTO customer.customers VALUES ('Do Hai Nhung', '568 Ngo Quyen', 'Long Bien', 'Quang Nam', 'nhung.dh228@gmail.com', 2092639003);
INSERT INTO customer.customers VALUES ('Vo Kieu Ngoc', '820 Nguyen Sieu', 'Quan 2', 'Kon Tum', 'ngoc.vk797@gmail.com', 1571155211);
INSERT INTO customer.customers VALUES ('Do Hoang Quynh', '629 Quan Thanh', 'Hong Bang', 'Gia Lai', 'quynh.dh310@gmail.com', 8835366680);
INSERT INTO customer.customers VALUES ('Ho Kieu Thuy', '718 Hang Gai', 'Son Tra', 'Phu Tho', 'thuy.hk697@gmail.com', 8402767443);
INSERT INTO customer.customers VALUES ('Phan Tuan Hai', '275 Ho Tung Mau', 'Dong Da', 'Ha Noi', 'hai.pt814@gmail.com', 5768106679);
INSERT INTO customer.customers VALUES ('Dinh Ngoc Chien', '156 Kim Ma', 'Long Bien', 'Quy Nhon', 'chien.dn960@gmail.com', 9571254925);
INSERT INTO customer.customers VALUES ('Huynh Manh Nam', '164 Hang Tre', 'Long Bien', 'Quang Binh', 'nam.hm519@gmail.com', 4576788425);
INSERT INTO customer.customers VALUES ('Do Nam My', '262 Phan Chu Trinh', 'Dong Da', 'Binh Thuan', 'my.dn189@gmail.com', 8778570029);
INSERT INTO customer.customers VALUES ('Dinh Thanh Ngan', '577 Hang Voi', 'Ba Dinh', 'Ha Tinh', 'ngan.dt225@gmail.com', 7045654351);
INSERT INTO customer.customers VALUES ('Vu Ngoc Lam', '821 Hoang Cau', 'Hai Ba Trung', 'Binh Dinh', 'lam.vn6@gmail.com', 1508065966);
INSERT INTO customer.customers VALUES ('Diep Minh Huyen', '653 Nguyen Sieu', 'Long Bien', 'Ha Noi', 'huyen.dm654@gmail.com', 8626986986);
INSERT INTO customer.customers VALUES ('Duong Minh Loan', '770 Nguyen Trai', 'Son Tra', 'Quang Nam', 'loan.dm180@gmail.com', 7764826401);
INSERT INTO customer.customers VALUES ('Diep Khanh Lam', '592 Hang Mam', 'Thanh Khe', 'Quang Binh', 'lam.dk933@gmail.com', 6302154979);
INSERT INTO customer.customers VALUES ('Hoang Hoang Nhung', '598 Hang Bo', 'Ngo Quyen', 'Bac Ninh', 'nhung.hh538@gmail.com', 3301311028);
INSERT INTO customer.customers VALUES ('Luong Chi Van', '647 Phung Hung', 'Ha Dong', 'Quang Ngai', 'van.lc210@gmail.com', 5305653437);
INSERT INTO customer.customers VALUES ('Hoang Hoang Van', '419 Tran Hung Dao', 'Binh Thanh', 'Hai Phong', 'van.hh528@gmail.com', 7560984763);
INSERT INTO customer.customers VALUES ('Tran Chi Quynh', '638 Hang Khay', 'Quan 3', 'Thai Nguyen', 'quynh.tc498@gmail.com', 9995520950);
INSERT INTO customer.customers VALUES ('Trinh Thi Xuan', '480 Hoang Cau', 'Hoang Mai', 'Quang Binh', 'xuan.tt895@gmail.com', 8845013819);
INSERT INTO customer.customers VALUES ('Quach Manh Ly', '380 Tran Quoc Toan', 'Quan 3', 'Quang Ninh', 'ly.qm579@gmail.com', 1435036578);
INSERT INTO customer.customers VALUES ('Hoang Khanh Linh', '182 Hang Bo', 'Bac Tu Liem', 'Ho Chi Minh', 'linh.hk482@gmail.com', 8077909054);
INSERT INTO customer.customers VALUES ('Nguyen Manh Tuyet', '671 Phan Dinh Phung', 'Ha Dong', 'Vinh', 'tuyet.nm851@gmail.com', 4282302963);
INSERT INTO customer.customers VALUES ('Tran Chi Sang', '80 Luong Van Can', 'Thanh Khe', 'Nha Trang', 'sang.tc434@gmail.com', 4342564013);
INSERT INTO customer.customers VALUES ('Trinh Khanh Tuyet', '455 Hang Tre', 'Le Chan', 'Binh Dinh', 'tuyet.tk355@gmail.com', 6914983057);
INSERT INTO customer.customers VALUES ('Ho Hoang Nhi', '894 Hang Ngang', 'Thanh Khe', 'Nha Trang', 'nhi.hh646@gmail.com', 3505232358);
INSERT INTO customer.customers VALUES ('Hoang Kieu Sang', '45 Le Loi', 'Quan 4', 'Quy Nhon', 'sang.hk604@gmail.com', 5276193105);
INSERT INTO customer.customers VALUES ('Ly Khanh Ha', '483 Nguyen Trai', 'Hong Bang', 'Quang Binh', 'ha.lk639@gmail.com', 7318932408);
INSERT INTO customer.customers VALUES ('Diep Khanh Thao', '738 Luong Van Can', 'Cau Giay', 'Quang Binh', 'thao.dk229@gmail.com', 3426190011);
INSERT INTO customer.customers VALUES ('Huynh Hoang Thuy', '106 Phung Hung', 'Ngo Quyen', 'Kon Tum', 'thuy.hh852@gmail.com', 8674114570);
INSERT INTO customer.customers VALUES ('Dang Kieu Van', '28 Tran Dai Nghia', 'Ha Dong', 'Khanh Hoa', 'van.dk367@gmail.com', 7691216145);
INSERT INTO customer.customers VALUES ('Do Tuan Cuong', '496 Pham Ngu Lao', 'Quan 3', 'Binh Dinh', 'cuong.dt995@gmail.com', 4826879575);
INSERT INTO customer.customers VALUES ('Duong Hoang Ly', '417 Hang Dao', 'Dong Da', 'Quang Ninh', 'ly.dh152@gmail.com', 2187468398);
INSERT INTO customer.customers VALUES ('Huynh Kieu Ngan', '549 Hung Vuong', 'Hong Bang', 'Gia Lai', 'ngan.hk558@gmail.com', 7201216788);
INSERT INTO customer.customers VALUES ('Dinh Hai Chien', '777 Le Ngoc Han', 'Ba Dinh', 'Quang Binh', 'chien.dh285@gmail.com', 5766706592);
INSERT INTO customer.customers VALUES ('Vo Hai Hai', '318 Hang Khay', 'Nam Tu Liem', 'Quang Nam', 'hai.vh991@gmail.com', 6316730237);
INSERT INTO customer.customers VALUES ('Pham Nam Ha', '588 Ho Tung Mau', 'Hong Bang', 'Ha Tinh', 'ha.pn856@gmail.com', 6477147044);
INSERT INTO customer.customers VALUES ('Nguyen Khanh Van', '536 Xuan Thuy', 'Le Chan', 'Bac Ninh', 'van.nk522@gmail.com', 4658113090);
INSERT INTO customer.customers VALUES ('Huynh Khanh Tien', '819 Nguyen Trai', 'Dong Da', 'Vinh', 'tien.hk321@gmail.com', 3881283558);
INSERT INTO customer.customers VALUES ('Do Nam Sang', '41 Hoang Quoc Viet', 'Long Bien', 'Binh Thuan', 'sang.dn307@gmail.com', 6492139619);
INSERT INTO customer.customers VALUES ('Hoang Khanh Hiep', '554 Hang Ma', 'Son Tra', 'Quang Ninh', 'hiep.hk482@gmail.com', 5020083644);
INSERT INTO customer.customers VALUES ('Trinh Ngoc Khanh', '773 Hang Ngang', 'Quan 4', 'Yen Bai', 'khanh.tn304@gmail.com', 7278197106);
INSERT INTO customer.customers VALUES ('Pham Khanh Duc', '43 O Cho Dua', 'Quan 5', 'Khanh Hoa', 'duc.pk233@gmail.com', 9190505434);
INSERT INTO customer.customers VALUES ('Phan Manh Xuan', '457 Hang Bo', 'Ha Dong', 'Binh Dinh', 'xuan.pm679@gmail.com', 3534023023);
INSERT INTO customer.customers VALUES ('Ngo Thanh Lam', '289 Hoang Quoc Viet', 'Long Bien', 'Binh Thuan', 'lam.nt392@gmail.com', 8450573061);
INSERT INTO customer.customers VALUES ('Ta Nam Trinh', '447 Hang Ngang', 'Quan 4', 'Quy Nhon', 'trinh.tn496@gmail.com', 7334781816);
INSERT INTO customer.customers VALUES ('Dang Nam Khoa', '963 Hang Chieu', 'Hoang Mai', 'Quang Nam', 'khoa.dn173@gmail.com', 7298390548);
INSERT INTO customer.customers VALUES ('Luong Hoang Anh', '321 Phung Hung', 'Ba Dinh', 'Thai Nguyen', 'anh.lh363@gmail.com', 8532350725);
INSERT INTO customer.customers VALUES ('Pham Nam Ngoc', '913 Hang Bong', 'Quan 2', 'Ninh Thuan', 'ngoc.pn583@gmail.com', 6169965989);
INSERT INTO customer.customers VALUES ('Ho Khanh Khanh', '820 Tran Dai Nghia', 'Hoan Kiem', 'Hai Phong', 'khanh.hk755@gmail.com', 5407074237);
INSERT INTO customer.customers VALUES ('Tran Thi Minh', '821 Ton Duc Thang', 'Hoang Mai', 'Binh Dinh', 'minh.tt552@gmail.com', 2852365113);
INSERT INTO customer.customers VALUES ('Trinh Khanh Khanh', '986 Hang Luoc', 'Hoang Mai', 'Quang Ninh', 'khanh.tk343@gmail.com', 5729124104);
INSERT INTO customer.customers VALUES ('Vo Manh Hung', '814 Hang Da', 'Binh Thanh', 'Vinh', 'hung.vm200@gmail.com', 9875416605);
INSERT INTO customer.customers VALUES ('Duong Hai Thao', '114 Nguyen Xi', 'Quan 4', 'Ha Nam', 'thao.dh123@gmail.com', 2422394751);
INSERT INTO customer.customers VALUES ('Trinh Nam Thuy', '873 Ton Duc Thang', 'Bac Tu Liem', 'Phu Tho', 'thuy.tn996@gmail.com', 3321454039);
INSERT INTO customer.customers VALUES ('Dang Hai Minh', '5 Nguyen Trai', 'Quan 5', 'Yen Bai', 'minh.dh704@gmail.com', 6692338350);
INSERT INTO customer.customers VALUES ('Dinh Minh Cuong', '905 Hoang Quoc Viet', 'Cau Giay', 'Binh Thuan', 'cuong.dm823@gmail.com', 2782961426);
INSERT INTO customer.customers VALUES ('Bui Thi Khanh', '537 Hang Bo', 'Hoan Kiem', 'Phu Tho', 'khanh.bt444@gmail.com', 3730428128);
INSERT INTO customer.customers VALUES ('Pham Tuan Ly', '150 Lan Ong', 'Quan 1', 'Khanh Hoa', 'ly.pt840@gmail.com', 9692571846);
INSERT INTO customer.customers VALUES ('Duong Hai Giang', '626 Ngo Quyen', 'Hai Ba Trung', 'Thai Nguyen', 'giang.dh216@gmail.com', 3837842743);
INSERT INTO customer.customers VALUES ('Nguyen Ngoc Huong', '321 Tran Phu', 'Ha Dong', 'Quang Nam', 'huong.nn947@gmail.com', 8709994110);
INSERT INTO customer.customers VALUES ('Vu Kieu Khanh', '27 Le Loi', 'Hai Ba Trung', 'Quy Nhon', 'khanh.vk703@gmail.com', 4046207950);
INSERT INTO customer.customers VALUES ('Duong Manh Loan', '576 Hang Luoc', 'Quan 1', 'Hue', 'loan.dm403@gmail.com', 3576356117);
INSERT INTO customer.customers VALUES ('Vo Kieu Nam', '1 Hang Dao', 'Le Chan', 'Ha Noi', 'nam.vk822@gmail.com', 2199117080);
INSERT INTO customer.customers VALUES ('Hoang Chi Ly', '476 Nguyen Sieu', 'Hai Ba Trung', 'Ha Tinh', 'ly.hc836@gmail.com', 9976982232);
INSERT INTO customer.customers VALUES ('Duong Tuan Minh', '637 Hang Dao', 'Long Bien', 'Nam Dinh', 'minh.dt755@gmail.com', 9696436089);
INSERT INTO customer.customers VALUES ('Pham Kieu Huong', '906 Hang Da', 'Hai Chau', 'Thai Nguyen', 'huong.pk75@gmail.com', 6150492207);
INSERT INTO customer.customers VALUES ('Duong Tuan Sang', '983 Hoang Cau', 'Quan 3', 'Hue', 'sang.dt308@gmail.com', 2678679488);
INSERT INTO customer.customers VALUES ('Ta Hoang Huong', '301 Ngo Quyen', 'Hai Chau', 'Dak Lak', 'huong.th605@gmail.com', 6174091118);
INSERT INTO customer.customers VALUES ('Bui Chi Khanh', '658 Hang Bo', 'Quan 5', 'Gia Lai', 'khanh.bc882@gmail.com', 5458866314);
INSERT INTO customer.customers VALUES ('Duong Nam Hiep', '95 Hang Gai', 'Quan 4', 'Quang Tri', 'hiep.dn991@gmail.com', 7350940303);
INSERT INTO customer.customers VALUES ('Duong Khanh Huyen', '147 Phan Dinh Phung', 'Binh Thanh', 'Can Tho', 'huyen.dk440@gmail.com', 2033502172);
INSERT INTO customer.customers VALUES ('Vo Nam Ly', '520 Nguyen Sieu', 'Hai Chau', 'Can Tho', 'ly.vn603@gmail.com', 9639803363);
INSERT INTO customer.customers VALUES ('Duong Khanh Lam', '50 Luong Van Can', 'Cam Le', 'Quang Nam', 'lam.dk280@gmail.com', 3626678643);
INSERT INTO customer.customers VALUES ('Diep Khanh Thao', '979 Ho Tung Mau', 'Quan 4', 'Vung Tau', 'thao.dk628@gmail.com', 6269425314);
INSERT INTO customer.customers VALUES ('Ho Chi Nam', '627 Giang Vo', 'Hoan Kiem', 'Da Lat', 'nam.hc894@gmail.com', 6620878386);
INSERT INTO customer.customers VALUES ('Diep Hoang Tien', '903 Thuoc Bac', 'Cau Giay', 'Ha Nam', 'tien.dh541@gmail.com', 3987994909);
INSERT INTO customer.customers VALUES ('Le Ngoc Ngoc', '731 Hang Non', 'Hoan Kiem', 'Dak Lak', 'ngoc.ln89@gmail.com', 3560189894);
INSERT INTO customer.customers VALUES ('Le Kieu Van', '805 Hoang Cau', 'Hai Ba Trung', 'Vung Tau', 'van.lk502@gmail.com', 6623729471);
INSERT INTO customer.customers VALUES ('Tran Nam Tien', '959 Hang Voi', 'Hai Ba Trung', 'Can Tho', 'tien.tn762@gmail.com', 8823889852);
INSERT INTO customer.customers VALUES ('Diep Khanh Cuong', '453 Xuan Thuy', 'Hai Chau', 'Binh Thuan', 'cuong.dk898@gmail.com', 7909615567);
INSERT INTO customer.customers VALUES ('Trinh Thi Tien', '435 Hang Bo', 'Ngo Quyen', 'Vinh', 'tien.tt920@gmail.com', 9779767749);
INSERT INTO customer.customers VALUES ('Quach Chi Nam', '397 Kim Ma', 'Bac Tu Liem', 'Bien Hoa', 'nam.qc32@gmail.com', 8386992436);
INSERT INTO customer.customers VALUES ('Huynh Ngoc Tien', '644 Hoang Cau', 'Cam Le', 'Yen Bai', 'tien.hn674@gmail.com', 6976820683);
INSERT INTO customer.customers VALUES ('Ly Kieu Cuong', '950 Nguyen Sieu', 'Long Bien', 'Quy Nhon', 'cuong.lk141@gmail.com', 9629972782);
INSERT INTO customer.customers VALUES ('Duong Chi Loan', '431 Ton Duc Thang', 'Quan 2', 'Vung Tau', 'loan.dc420@gmail.com', 5518385021);
INSERT INTO customer.customers VALUES ('Ngo Hai Thao', '785 Ly Thuong Kiet', 'Hai Chau', 'Quang Nam', 'thao.nh222@gmail.com', 5162672279);
INSERT INTO customer.customers VALUES ('Ta Nam Nga', '128 Luong Van Can', 'Thanh Xuan', 'Quang Ngai', 'nga.tn154@gmail.com', 3642353498);
INSERT INTO customer.customers VALUES ('Do Hoang My', '662 Hang Mam', 'Cam Le', 'Ha Tinh', 'my.dh1000@gmail.com', 2936158240);
INSERT INTO customer.customers VALUES ('Do Chi Thanh', '847 Hang Ngang', 'Thanh Xuan', 'Da Lat', 'thanh.dc645@gmail.com', 8731907046);
INSERT INTO customer.customers VALUES ('Nguyen Minh Nhung', '755 Hoang Cau', 'Quan 1', 'Ho Chi Minh', 'nhung.nm276@gmail.com', 7088480781);
INSERT INTO customer.customers VALUES ('Dinh Kieu Hung', '560 Luong Van Can', 'Hai Ba Trung', 'Phu Yen', 'hung.dk150@gmail.com', 2327998991);
INSERT INTO customer.customers VALUES ('Duong Ngoc Thao', '652 Le Ngoc Han', 'Hoang Mai', 'Quang Nam', 'thao.dn239@gmail.com', 5914669128);
INSERT INTO customer.customers VALUES ('Quach Khanh Hung', '680 Ton Duc Thang', 'Phu Nhuan', 'Ha Nam', 'hung.qk132@gmail.com', 9708897234);
INSERT INTO customer.customers VALUES ('Ho Hai Xuan', '871 Tran Hung Dao', 'Hai Ba Trung', 'Thai Nguyen', 'xuan.hh671@gmail.com', 8436221683);
INSERT INTO customer.customers VALUES ('Dau Thanh Hiep', '158 Hang Non', 'Bac Tu Liem', 'Ha Noi', 'hiep.dt72@gmail.com', 5419956959);
INSERT INTO customer.customers VALUES ('Vu Ngoc Phuong', '819 Hang Khay', 'Hai Ba Trung', 'Thai Nguyen', 'phuong.vn539@gmail.com', 6658629810);
INSERT INTO customer.customers VALUES ('Tran Hoang Quynh', '376 Le Ngoc Han', 'Ha Dong', 'Hue', 'quynh.th21@gmail.com', 7826386321);
INSERT INTO customer.customers VALUES ('Ly Hai Lan', '499 Phan Dinh Phung', 'Le Chan', 'Can Tho', 'lan.lh234@gmail.com', 4040930092);
INSERT INTO customer.customers VALUES ('Do Manh Duc', '771 Hang Voi', 'Quan 1', 'Phu Yen', 'duc.dm952@gmail.com', 9082323428);
INSERT INTO customer.customers VALUES ('Tran Chi Ngan', '273 O Cho Dua', 'Thanh Xuan', 'Ha Tinh', 'ngan.tc1@gmail.com', 9238853572);
INSERT INTO customer.customers VALUES ('Trinh Thi Nhi', '48 Hang Tre', 'Cau Giay', 'Nam Dinh', 'nhi.tt420@gmail.com', 3100693458);
INSERT INTO customer.customers VALUES ('Vo Hai Quynh', '648 Le Duan', 'Son Tra', 'Phu Tho', 'quynh.vh135@gmail.com', 9480586222);
INSERT INTO customer.customers VALUES ('Ngo Nam Ngoc', '197 Hang Mam', 'Quan 2', 'Phu Tho', 'ngoc.nn149@gmail.com', 8024925235);
INSERT INTO customer.customers VALUES ('Do Thi Nhung', '787 Tran Hung Dao', 'Son Tra', 'Quy Nhon', 'nhung.dt911@gmail.com', 3114212462);
INSERT INTO customer.customers VALUES ('Hoang Chi Ngan', '995 Tran Hung Dao', 'Hoang Mai', 'Quang Tri', 'ngan.hc62@gmail.com', 7236890412);
INSERT INTO customer.customers VALUES ('Duong Thi Huong', '205 Tran Dai Nghia', 'Quan 2', 'Ninh Thuan', 'huong.dt418@gmail.com', 8079227714);
INSERT INTO customer.customers VALUES ('Ngo Ngoc Trang', '611 Giang Vo', 'Cam Le', 'Da Nang', 'trang.nn710@gmail.com', 6898427227);
INSERT INTO customer.customers VALUES ('Dinh Thi Giang', '101 Hang Dao', 'Hong Bang', 'Yen Bai', 'giang.dt289@gmail.com', 7013674236);
INSERT INTO customer.customers VALUES ('Ho Thi Hoa', '857 Tran Hung Dao', 'Quan 4', 'Ho Chi Minh', 'hoa.ht600@gmail.com', 6450859665);
INSERT INTO customer.customers VALUES ('Dang Kieu Nga', '106 Le Ngoc Han', 'Quan 5', 'Bien Hoa', 'nga.dk296@gmail.com', 9515793073);
INSERT INTO customer.customers VALUES ('Ly Hai Huy', '20 Hoang Quoc Viet', 'Ba Dinh', 'Da Nang', 'huy.lh748@gmail.com', 3671481748);
INSERT INTO customer.customers VALUES ('Trinh Nam Cuong', '551 Hoang Cau', 'Nam Tu Liem', 'Yen Bai', 'cuong.tn334@gmail.com', 1813061868);
INSERT INTO customer.customers VALUES ('Dinh Nam Linh', '716 Giang Vo', 'Nam Tu Liem', 'Da Nang', 'linh.dn784@gmail.com', 4307923206);
INSERT INTO customer.customers VALUES ('Quach Kieu Nhi', '908 Ton Duc Thang', 'Hoang Mai', 'Ninh Thuan', 'nhi.qk876@gmail.com', 5581642046);
INSERT INTO customer.customers VALUES ('Diep Minh Hai', '270 Hang Ngang', 'Dong Da', 'Bien Hoa', 'hai.dm466@gmail.com', 2947073918);
INSERT INTO customer.customers VALUES ('Phan Nam Duc', '632 Ly Nam De', 'Nam Tu Liem', 'Kon Tum', 'duc.pn465@gmail.com', 2039322341);
INSERT INTO customer.customers VALUES ('Luong Minh My', '330 Hang Bo', 'Binh Thanh', 'Yen Bai', 'my.lm436@gmail.com', 6871091213);
INSERT INTO customer.customers VALUES ('Dang Thi Tien', '981 Lan Ong', 'Son Tra', 'Quy Nhon', 'tien.dt237@gmail.com', 3341214079);
INSERT INTO customer.customers VALUES ('Duong Chi Thanh', '235 Le Duan', 'Bac Tu Liem', 'Da Nang', 'thanh.dc102@gmail.com', 3409534168);
INSERT INTO customer.customers VALUES ('Pham Khanh Thao', '140 Luong Dinh Cua', 'Quan 5', 'Binh Dinh', 'thao.pk303@gmail.com', 9103068542);
INSERT INTO customer.customers VALUES ('Pham Hai Xuan', '732 Hang Gai', 'Tay Ho', 'Vung Tau', 'xuan.ph683@gmail.com', 9299759986);
INSERT INTO customer.customers VALUES ('Duong Thanh Nga', '979 Tran Hung Dao', 'Cam Le', 'Quy Nhon', 'nga.dt324@gmail.com', 3417321182);
INSERT INTO customer.customers VALUES ('Dinh Khanh Tuyet', '835 Ngo Quyen', 'Hai Chau', 'Ha Noi', 'tuyet.dk507@gmail.com', 2437216262);
INSERT INTO customer.customers VALUES ('Diep Tuan Khoa', '439 Le Thanh Ton', 'Le Chan', 'Hue', 'khoa.dt743@gmail.com', 4291935880);
INSERT INTO customer.customers VALUES ('Pham Chi Ly', '591 Ly Thuong Kiet', 'Bac Tu Liem', 'Quy Nhon', 'ly.pc58@gmail.com', 6711872338);
INSERT INTO customer.customers VALUES ('Nguyen Thanh Long', '971 Tran Phu', 'Le Chan', 'Kon Tum', 'long.nt31@gmail.com', 6780278863);
INSERT INTO customer.customers VALUES ('Ngo Kieu Phuong', '220 Hang Gai', 'Tay Ho', 'Da Lat', 'phuong.nk204@gmail.com', 2311973979);
INSERT INTO customer.customers VALUES ('Vu Hai Ngoc', '446 Hang Ngang', 'Cau Giay', 'Ha Noi', 'ngoc.vh851@gmail.com', 5394771568);
INSERT INTO customer.customers VALUES ('Ta Thi Duc', '935 Tran Dai Nghia', 'Tay Ho', 'Da Nang', 'duc.tt810@gmail.com', 4365241093);
INSERT INTO customer.customers VALUES ('Trinh Minh Ngan', '920 Hung Vuong', 'Hai Chau', 'Da Lat', 'ngan.tm100@gmail.com', 8259543311);
INSERT INTO customer.customers VALUES ('Dau Thi Cuong', '802 Tran Dai Nghia', 'Long Bien', 'Quy Nhon', 'cuong.dt878@gmail.com', 9998446661);
INSERT INTO customer.customers VALUES ('Nguyen Kieu Lan', '721 Ly Nam De', 'Hai Ba Trung', 'Bac Ninh', 'lan.nk355@gmail.com', 3678728832);
INSERT INTO customer.customers VALUES ('Pham Manh Van', '634 Kim Ma', 'Quan 5', 'Quang Nam', 'van.pm274@gmail.com', 9373516376);
INSERT INTO customer.customers VALUES ('Ho Minh Nhi', '246 Hang Chieu', 'Quan 5', 'Vinh', 'nhi.hm910@gmail.com', 6470608909);
INSERT INTO customer.customers VALUES ('Quach Hoang Van', '130 O Cho Dua', 'Thanh Xuan', 'Hai Phong', 'van.qh517@gmail.com', 4673866637);
INSERT INTO customer.customers VALUES ('Duong Hai Minh', '973 Hang Dao', 'Dong Da', 'Nha Trang', 'minh.dh473@gmail.com', 9576050920);
INSERT INTO customer.customers VALUES ('Quach Thanh Phuong', '155 Hang Khay', 'Cau Giay', 'Can Tho', 'phuong.qt862@gmail.com', 7047221557);
INSERT INTO customer.customers VALUES ('Pham Hoang Hoa', '321 Hung Vuong', 'Ba Dinh', 'Nha Trang', 'hoa.ph765@gmail.com', 7857921088);
INSERT INTO customer.customers VALUES ('Pham Minh Chien', '72 Nguyen Trai', 'Hai Chau', 'Ha Nam', 'chien.pm20@gmail.com', 9043544229);
INSERT INTO customer.customers VALUES ('Diep Ngoc Ngoc', '188 Nguyen Trai', 'Dong Da', 'Yen Bai', 'ngoc.dn591@gmail.com', 1801691407);
INSERT INTO customer.customers VALUES ('Bui Thanh Minh', '256 Phan Dinh Phung', 'Cau Giay', 'Ha Tinh', 'minh.bt315@gmail.com', 3695114893);
INSERT INTO customer.customers VALUES ('Bui Thanh Hung', '778 Ly Nam De', 'Quan 3', 'Bac Ninh', 'hung.bt599@gmail.com', 2422480950);
INSERT INTO customer.customers VALUES ('Do Thi Huong', '419 Pham Ngu Lao', 'Binh Thanh', 'Hue', 'huong.dt709@gmail.com', 1080423782);
INSERT INTO customer.customers VALUES ('Nguyen Chi Giang', '610 Pham Hong Thai', 'Cam Le', 'Can Tho', 'giang.nc572@gmail.com', 1716966401);
INSERT INTO customer.customers VALUES ('Trinh Hai Ngoc', '356 Nguyen Sieu', 'Phu Nhuan', 'Quy Nhon', 'ngoc.th968@gmail.com', 5495536391);
INSERT INTO customer.customers VALUES ('Diep Ngoc Hiep', '48 Ton Duc Thang', 'Quan 4', 'Quang Ninh', 'hiep.dn709@gmail.com', 6650179394);
INSERT INTO customer.customers VALUES ('Vo Minh Long', '150 O Cho Dua', 'Hong Bang', 'Kon Tum', 'long.vm293@gmail.com', 9383729555);
INSERT INTO customer.customers VALUES ('Huynh Thi Huong', '789 Nguyen Sieu', 'Phu Nhuan', 'Da Nang', 'huong.ht3@gmail.com', 9485843754);
INSERT INTO customer.customers VALUES ('Le Tuan Khanh', '149 Ly Thuong Kiet', 'Son Tra', 'Ha Tinh', 'khanh.lt180@gmail.com', 2121423077);
INSERT INTO customer.customers VALUES ('Hoang Khanh Nam', '440 Phan Chu Trinh', 'Quan 5', 'Phu Tho', 'nam.hk173@gmail.com', 1354643011);
INSERT INTO customer.customers VALUES ('Ly Tuan Huyen', '490 Hang Da', 'Ha Dong', 'Phu Tho', 'huyen.lt206@gmail.com', 7134596980);
INSERT INTO customer.customers VALUES ('Quach Hoang Trang', '166 Hang Tre', 'Ngo Quyen', 'Ho Chi Minh', 'trang.qh64@gmail.com', 6554404939);
INSERT INTO customer.customers VALUES ('Dau Khanh Khanh', '872 Lan Ong', 'Hong Bang', 'Can Tho', 'khanh.dk230@gmail.com', 6461437301);
INSERT INTO customer.customers VALUES ('Vu Manh Long', '767 Hang Chieu', 'Binh Thanh', 'Hai Phong', 'long.vm700@gmail.com', 5798614165);
INSERT INTO customer.customers VALUES ('Ho Chi Trang', '544 Tran Quoc Toan', 'Phu Nhuan', 'Ha Tinh', 'trang.hc891@gmail.com', 2296208618);
INSERT INTO customer.customers VALUES ('Phan Hoang Huyen', '865 Hang Tre', 'Thanh Khe', 'Vinh', 'huyen.ph842@gmail.com', 1984301037);
INSERT INTO customer.customers VALUES ('Luong Chi Duc', '821 Pham Hong Thai', 'Binh Thanh', 'Binh Dinh', 'duc.lc523@gmail.com', 3320848789);
INSERT INTO customer.customers VALUES ('Ngo Nam Tien', '415 Ton Duc Thang', 'Quan 1', 'Binh Dinh', 'tien.nn119@gmail.com', 6302573263);
INSERT INTO customer.customers VALUES ('Tran Hoang Huyen', '471 Le Duan', 'Quan 1', 'Quang Binh', 'huyen.th796@gmail.com', 2559597706);
INSERT INTO customer.customers VALUES ('Trinh Minh Huong', '364 Hoang Cau', 'Cau Giay', 'Nha Trang', 'huong.tm466@gmail.com', 8244008187);
INSERT INTO customer.customers VALUES ('Dinh Tuan Linh', '270 Pham Ngu Lao', 'Le Chan', 'Da Nang', 'linh.dt7@gmail.com', 2589876312);
INSERT INTO customer.customers VALUES ('Ly Thanh Cuong', '570 Hoang Cau', 'Bac Tu Liem', 'Nam Dinh', 'cuong.lt155@gmail.com', 9525553950);
INSERT INTO customer.customers VALUES ('Dang Manh Ngan', '423 Hang Luoc', 'Bac Tu Liem', 'Ninh Thuan', 'ngan.dm694@gmail.com', 1421507589);
INSERT INTO customer.customers VALUES ('Nguyen Chi Thao', '296 Tran Quoc Toan', 'Dong Da', 'Ha Tinh', 'thao.nc559@gmail.com', 9267237641);
INSERT INTO customer.customers VALUES ('Ly Ngoc Long', '98 Pham Ngu Lao', 'Dong Da', 'Yen Bai', 'long.ln438@gmail.com', 5488520913);
INSERT INTO customer.customers VALUES ('Dinh Nam Trang', '910 Hang Bo', 'Quan 4', 'Da Lat', 'trang.dn441@gmail.com', 1363102697);
INSERT INTO customer.customers VALUES ('Ngo Hai Linh', '948 Nguyen Trai', 'Bac Tu Liem', 'Da Lat', 'linh.nh910@gmail.com', 5742238728);
INSERT INTO customer.customers VALUES ('Quach Chi Duc', '899 Giang Vo', 'Binh Thanh', 'Nha Trang', 'duc.qc959@gmail.com', 2342898410);
INSERT INTO customer.customers VALUES ('Ta Kieu Chien', '175 Hang Bo', 'Hoan Kiem', 'Quang Nam', 'chien.tk685@gmail.com', 5922538985);
INSERT INTO customer.customers VALUES ('Dau Kieu Hung', '584 Hang Ngang', 'Ha Dong', 'Binh Thuan', 'hung.dk366@gmail.com', 2617624353);
INSERT INTO customer.customers VALUES ('Tran Khanh Hung', '43 Hang Luoc', 'Tay Ho', 'Thai Nguyen', 'hung.tk43@gmail.com', 2811968686);
INSERT INTO customer.customers VALUES ('Hoang Hoang Thanh', '459 Kim Ma', 'Quan 4', 'Bac Ninh', 'thanh.hh868@gmail.com', 2444612092);
INSERT INTO customer.customers VALUES ('Quach Chi Minh', '655 Hang Ma', 'Long Bien', 'Phu Tho', 'minh.qc551@gmail.com', 3949295747);
INSERT INTO customer.customers VALUES ('Trinh Tuan Nhi', '407 Le Ngoc Han', 'Tay Ho', 'Quang Ninh', 'nhi.tt702@gmail.com', 4963808399);
INSERT INTO customer.customers VALUES ('Ta Kieu Trang', '536 Ton Duc Thang', 'Binh Thanh', 'Bac Ninh', 'trang.tk298@gmail.com', 4700941404);
INSERT INTO customer.customers VALUES ('Quach Chi Ly', '601 Hang Tre', 'Tay Ho', 'Kon Tum', 'ly.qc491@gmail.com', 8807455624);
INSERT INTO customer.customers VALUES ('Duong Hai Giang', '389 Tran Phu', 'Ba Dinh', 'Da Nang', 'giang.dh32@gmail.com', 3548002222);
INSERT INTO customer.customers VALUES ('Diep Chi Hoa', '432 Nguyen Xi', 'Quan 5', 'Ha Noi', 'hoa.dc185@gmail.com', 1941898401);
INSERT INTO customer.customers VALUES ('Hoang Khanh Tien', '12 Pham Hong Thai', 'Binh Thanh', 'Yen Bai', 'tien.hk621@gmail.com', 6512426771);
INSERT INTO customer.customers VALUES ('Diep Hoang Sang', '4 Hoang Cau', 'Quan 3', 'Hai Phong', 'sang.dh197@gmail.com', 2217903299);
INSERT INTO customer.customers VALUES ('Phan Minh Cuong', '141 Ly Thuong Kiet', 'Ngo Quyen', 'Bien Hoa', 'cuong.pm250@gmail.com', 3062487771);
INSERT INTO customer.customers VALUES ('Dinh Thi Lan', '116 Ly Nam De', 'Cam Le', 'Da Nang', 'lan.dt570@gmail.com', 3728109464);
INSERT INTO customer.customers VALUES ('Diep Ngoc Van', '14 Lan Ong', 'Ha Dong', 'Binh Thuan', 'van.dn838@gmail.com', 7614051452);
INSERT INTO customer.customers VALUES ('Dau Minh Trang', '119 Hang Ma', 'Quan 2', 'Quang Binh', 'trang.dm112@gmail.com', 2369422279);
INSERT INTO customer.customers VALUES ('Dinh Hai Tuyet', '485 Nguyen Trai', 'Quan 4', 'Quy Nhon', 'tuyet.dh306@gmail.com', 7681204007);
INSERT INTO customer.customers VALUES ('Bui Tuan Tuyet', '106 Ho Tung Mau', 'Long Bien', 'Bac Ninh', 'tuyet.bt869@gmail.com', 9331233288);
INSERT INTO customer.customers VALUES ('Hoang Chi Thuy', '59 Tran Dai Nghia', 'Long Bien', 'Ha Nam', 'thuy.hc356@gmail.com', 6028072551);
INSERT INTO customer.customers VALUES ('Hoang Tuan Van', '586 Hang Khay', 'Cam Le', 'Khanh Hoa', 'van.ht394@gmail.com', 5802129282);
INSERT INTO customer.customers VALUES ('Diep Hai Loan', '12 Tran Quoc Toan', 'Ha Dong', 'Gia Lai', 'loan.dh946@gmail.com', 9259609472);
INSERT INTO customer.customers VALUES ('Huynh Chi Linh', '806 Ly Thuong Kiet', 'Thanh Khe', 'Binh Dinh', 'linh.hc436@gmail.com', 3516675393);
INSERT INTO customer.customers VALUES ('Dang Minh Chien', '173 Hang Tre', 'Le Chan', 'Nam Dinh', 'chien.dm68@gmail.com', 9009541841);
INSERT INTO customer.customers VALUES ('Quach Hai Van', '329 Hang Mam', 'Quan 2', 'Vinh', 'van.qh934@gmail.com', 2440609780);
INSERT INTO customer.customers VALUES ('Trinh Manh Tien', '722 Ho Tung Mau', 'Cau Giay', 'Quang Ngai', 'tien.tm321@gmail.com', 2167068033);
INSERT INTO customer.customers VALUES ('Nguyen Tuan Nhi', '262 Hang Gai', 'Quan 2', 'Hue', 'nhi.nt744@gmail.com', 8577190079);
INSERT INTO customer.customers VALUES ('Duong Ngoc Chien', '794 Hang Chieu', 'Ba Dinh', 'Khanh Hoa', 'chien.dn428@gmail.com', 2255921151);
INSERT INTO customer.customers VALUES ('Trinh Chi Hiep', '418 Luong Van Can', 'Quan 1', 'Ha Nam', 'hiep.tc850@gmail.com', 9791664599);
INSERT INTO customer.customers VALUES ('Nguyen Hai Ngoc', '236 Luong Van Can', 'Bac Tu Liem', 'Quang Binh', 'ngoc.nh519@gmail.com', 1443983269);
INSERT INTO customer.customers VALUES ('Do Manh Thao', '709 Hang Chieu', 'Thanh Xuan', 'Binh Dinh', 'thao.dm865@gmail.com', 7961938922);
INSERT INTO customer.customers VALUES ('Ngo Hoang Ha', '377 Hung Vuong', 'Hoan Kiem', 'Can Tho', 'ha.nh147@gmail.com', 6109341293);
INSERT INTO customer.customers VALUES ('Trinh Thanh Van', '222 Hoang Cau', 'Quan 2', 'Da Nang', 'van.tt886@gmail.com', 2187108684);
INSERT INTO customer.customers VALUES ('Do Khanh Trinh', '289 Luong Van Can', 'Quan 4', 'Ha Tinh', 'trinh.dk148@gmail.com', 6173152599);
INSERT INTO customer.customers VALUES ('Trinh Nam Nam', '324 Hang Ngang', 'Quan 5', 'Hai Phong', 'nam.tn397@gmail.com', 5378606319);
INSERT INTO customer.customers VALUES ('Ho Thanh Nhi', '48 Hang Mam', 'Quan 1', 'Bien Hoa', 'nhi.ht49@gmail.com', 8488515297);
INSERT INTO customer.customers VALUES ('Quach Minh Hung', '219 Giang Vo', 'Quan 5', 'Khanh Hoa', 'hung.qm157@gmail.com', 4798956985);
INSERT INTO customer.customers VALUES ('Vu Tuan Khanh', '393 Le Ngoc Han', 'Thanh Khe', 'Dak Lak', 'khanh.vt514@gmail.com', 6268154745);
INSERT INTO customer.customers VALUES ('Ngo Hai Long', '284 Quan Thanh', 'Ngo Quyen', 'Yen Bai', 'long.nh241@gmail.com', 9268509058);
INSERT INTO customer.customers VALUES ('Quach Ngoc Minh', '982 Luong Van Can', 'Hai Ba Trung', 'Dak Lak', 'minh.qn183@gmail.com', 3924062650);
INSERT INTO customer.customers VALUES ('Ly Ngoc Linh', '850 Luong Dinh Cua', 'Dong Da', 'Kon Tum', 'linh.ln921@gmail.com', 9270016614);
INSERT INTO customer.customers VALUES ('Vo Tuan Chien', '592 Le Loi', 'Quan 1', 'Thai Nguyen', 'chien.vt860@gmail.com', 6414010665);
INSERT INTO customer.customers VALUES ('Le Kieu Anh', '721 Quan Thanh', 'Long Bien', 'Nha Trang', 'anh.lk26@gmail.com', 8687221980);
INSERT INTO customer.customers VALUES ('Luong Khanh Huong', '963 Ba Trieu', 'Ba Dinh', 'Quang Nam', 'huong.lk167@gmail.com', 1136593757);
INSERT INTO customer.customers VALUES ('Luong Thi Khoa', '439 Hung Vuong', 'Quan 3', 'Nam Dinh', 'khoa.lt763@gmail.com', 3762424769);
INSERT INTO customer.customers VALUES ('Pham Hai Long', '976 Le Loi', 'Hoan Kiem', 'Dak Lak', 'long.ph366@gmail.com', 5289896039);
INSERT INTO customer.customers VALUES ('Le Thi Huong', '371 Hang Ca', 'Hoan Kiem', 'Bien Hoa', 'huong.lt84@gmail.com', 4520135976);
INSERT INTO customer.customers VALUES ('Dinh Kieu Huong', '622 Hang Luoc', 'Binh Thanh', 'Nam Dinh', 'huong.dk624@gmail.com', 4378439087);
INSERT INTO customer.customers VALUES ('Trinh Manh Minh', '539 Hang Bong', 'Le Chan', 'Phu Yen', 'minh.tm16@gmail.com', 4059119530);
INSERT INTO customer.customers VALUES ('Dang Khanh Long', '329 Hang Ngang', 'Ha Dong', 'Hai Phong', 'long.dk654@gmail.com', 7143224062);
INSERT INTO customer.customers VALUES ('Ngo Tuan Minh', '485 Hang Mam', 'Le Chan', 'Vung Tau', 'minh.nt589@gmail.com', 2095322756);
INSERT INTO customer.customers VALUES ('Diep Kieu Duc', '97 Le Thanh Ton', 'Thanh Xuan', 'Phu Yen', 'duc.dk406@gmail.com', 6952072679);
INSERT INTO customer.customers VALUES ('Hoang Nam Huyen', '284 Hang Gai', 'Long Bien', 'Ha Nam', 'huyen.hn244@gmail.com', 9397208384);
INSERT INTO customer.customers VALUES ('Pham Hai Ha', '830 Le Thanh Ton', 'Binh Thanh', 'Nam Dinh', 'ha.ph477@gmail.com', 1778106123);
INSERT INTO customer.customers VALUES ('Vu Hoang Huy', '870 Hoang Cau', 'Quan 1', 'Kon Tum', 'huy.vh357@gmail.com', 7097386600);
INSERT INTO customer.customers VALUES ('Duong Tuan Lam', '973 Tran Quoc Toan', 'Tay Ho', 'Quang Binh', 'lam.dt510@gmail.com', 8024689415);
INSERT INTO customer.customers VALUES ('Dau Hoang Long', '62 Tran Hung Dao', 'Quan 4', 'Khanh Hoa', 'long.dh27@gmail.com', 6381627607);
INSERT INTO customer.customers VALUES ('Hoang Hai Duc', '952 Ton Duc Thang', 'Quan 2', 'Ha Noi', 'duc.hh432@gmail.com', 8979790313);
INSERT INTO customer.customers VALUES ('Le Hoang Nam', '102 Tran Dai Nghia', 'Nam Tu Liem', 'Kon Tum', 'nam.lh491@gmail.com', 1647090768);
INSERT INTO customer.customers VALUES ('Nguyen Manh Nga', '407 Phung Hung', 'Phu Nhuan', 'Hai Phong', 'nga.nm152@gmail.com', 8817120222);
INSERT INTO customer.customers VALUES ('Le Hai Cuong', '785 O Cho Dua', 'Phu Nhuan', 'Ha Tinh', 'cuong.lh538@gmail.com', 1155087720);
INSERT INTO customer.customers VALUES ('Dang Khanh Giang', '48 Tran Quoc Toan', 'Hoan Kiem', 'Quy Nhon', 'giang.dk149@gmail.com', 7090518048);
INSERT INTO customer.customers VALUES ('Duong Manh Nga', '39 Tran Phu', 'Ha Dong', 'Hue', 'nga.dm149@gmail.com', 5683237705);
INSERT INTO customer.customers VALUES ('Huynh Khanh Linh', '103 Ba Trieu', 'Ngo Quyen', 'Phu Yen', 'linh.hk635@gmail.com', 4254161962);
INSERT INTO customer.customers VALUES ('Ngo Tuan Lam', '745 Hang Ma', 'Cam Le', 'Nha Trang', 'lam.nt878@gmail.com', 8948753027);
INSERT INTO customer.customers VALUES ('Quach Thi Ngan', '885 Hang Ngang', 'Hong Bang', 'Ha Noi', 'ngan.qt765@gmail.com', 4479879547);
INSERT INTO customer.customers VALUES ('Le Chi Ha', '152 Hang Chieu', 'Hoang Mai', 'Gia Lai', 'ha.lc197@gmail.com', 6347404600);
INSERT INTO customer.customers VALUES ('Ly Ngoc Lam', '519 Xuan Thuy', 'Long Bien', 'Hai Phong', 'lam.ln76@gmail.com', 9235138958);
INSERT INTO customer.customers VALUES ('Diep Manh Ngan', '506 Tran Phu', 'Hai Chau', 'Nha Trang', 'ngan.dm276@gmail.com', 5214817626);
INSERT INTO customer.customers VALUES ('Nguyen Hoang Anh', '152 Ba Trieu', 'Binh Thanh', 'Ha Noi', 'anh.nh300@gmail.com', 6970018642);
INSERT INTO customer.customers VALUES ('Ly Nam Nhung', '426 Ba Trieu', 'Quan 5', 'Quy Nhon', 'nhung.ln323@gmail.com', 5328501105);
INSERT INTO customer.customers VALUES ('Tran Chi Van', '237 Ba Trieu', 'Long Bien', 'Nam Dinh', 'van.tc858@gmail.com', 6221501823);
INSERT INTO customer.customers VALUES ('Nguyen Khanh Khanh', '305 Hang Dao', 'Binh Thanh', 'Ha Nam', 'khanh.nk92@gmail.com', 6182388410);
INSERT INTO customer.customers VALUES ('Duong Kieu Sang', '421 Kim Ma', 'Dong Da', 'Da Nang', 'sang.dk577@gmail.com', 8309103729);
INSERT INTO customer.customers VALUES ('Ly Hai Nhung', '397 Tran Dai Nghia', 'Hai Ba Trung', 'Dak Lak', 'nhung.lh673@gmail.com', 8209420765);
INSERT INTO customer.customers VALUES ('Le Nam Tien', '748 Quan Thanh', 'Ba Dinh', 'Binh Thuan', 'tien.ln203@gmail.com', 6908342196);
INSERT INTO customer.customers VALUES ('Pham Chi Thuy', '421 Le Duan', 'Quan 5', 'Vung Tau', 'thuy.pc17@gmail.com', 2964865238);
INSERT INTO customer.customers VALUES ('Hoang Hoang Nga', '898 Hoang Quoc Viet', 'Hai Chau', 'Quang Binh', 'nga.hh685@gmail.com', 2846670187);
INSERT INTO customer.customers VALUES ('Pham Thi Huy', '304 Ho Tung Mau', 'Tay Ho', 'Phu Tho', 'huy.pt249@gmail.com', 8285452191);
INSERT INTO customer.customers VALUES ('Do Hai Sang', '81 Le Duan', 'Binh Thanh', 'Bien Hoa', 'sang.dh360@gmail.com', 4850569248);
INSERT INTO customer.customers VALUES ('Tran Nam Linh', '451 Luong Van Can', 'Ha Dong', 'Ha Tinh', 'linh.tn336@gmail.com', 4920718935);
INSERT INTO customer.customers VALUES ('Trinh Manh Sang', '821 Ton Duc Thang', 'Binh Thanh', 'Binh Thuan', 'sang.tm513@gmail.com', 2805839342);
INSERT INTO customer.customers VALUES ('Ta Hai Lan', '435 Ton Duc Thang', 'Hai Chau', 'Quang Nam', 'lan.th11@gmail.com', 8432000746);
INSERT INTO customer.customers VALUES ('Huynh Kieu Tien', '646 Hang Ca', 'Le Chan', 'Ha Noi', 'tien.hk102@gmail.com', 8762507451);
INSERT INTO customer.customers VALUES ('Le Hoang Tien', '32 O Cho Dua', 'Hong Bang', 'Bac Ninh', 'tien.lh312@gmail.com', 8073428308);
INSERT INTO customer.customers VALUES ('Ho Khanh Tien', '873 Hang Can', 'Thanh Xuan', 'Da Lat', 'tien.hk908@gmail.com', 5450153176);
INSERT INTO customer.customers VALUES ('Vu Ngoc Ha', '891 Hung Vuong', 'Thanh Khe', 'Quang Binh', 'ha.vn727@gmail.com', 6285846025);
INSERT INTO customer.customers VALUES ('Huynh Khanh Minh', '578 Le Ngoc Han', 'Hoan Kiem', 'Quang Tri', 'minh.hk351@gmail.com', 5336288152);
INSERT INTO customer.customers VALUES ('Le Hoang Chien', '730 Luong Dinh Cua', 'Ba Dinh', 'Da Lat', 'chien.lh684@gmail.com', 4177087801);
INSERT INTO customer.customers VALUES ('Vu Thi Ngan', '94 Hang Da', 'Thanh Khe', 'Gia Lai', 'ngan.vt79@gmail.com', 5756208014);
INSERT INTO customer.customers VALUES ('Quach Khanh Hiep', '436 Hung Vuong', 'Bac Tu Liem', 'Thai Nguyen', 'hiep.qk632@gmail.com', 5306458213);
INSERT INTO customer.customers VALUES ('Trinh Khanh Van', '255 Ly Nam De', 'Tay Ho', 'Ha Nam', 'van.tk121@gmail.com', 6677667637);
INSERT INTO customer.customers VALUES ('Dinh Khanh Hung', '693 Nguyen Trai', 'Cau Giay', 'Thai Nguyen', 'hung.dk703@gmail.com', 1244970306);
INSERT INTO customer.customers VALUES ('Do Thi Van', '8 Hang Non', 'Nam Tu Liem', 'Thai Nguyen', 'van.dt532@gmail.com', 7979781711);
INSERT INTO customer.customers VALUES ('Dinh Thi Thao', '801 Pham Hong Thai', 'Nam Tu Liem', 'Bien Hoa', 'thao.dt786@gmail.com', 4841895626);
INSERT INTO customer.customers VALUES ('Tran Manh Loan', '412 Ton Duc Thang', 'Ngo Quyen', 'Dak Lak', 'loan.tm839@gmail.com', 9658268519);
INSERT INTO customer.customers VALUES ('Ngo Hai Huy', '604 Hang Mam', 'Ba Dinh', 'Quang Ngai', 'huy.nh67@gmail.com', 3784547963);
INSERT INTO customer.customers VALUES ('Ho Nam Nam', '129 Hung Vuong', 'Ba Dinh', 'Phu Tho', 'nam.hn480@gmail.com', 8167951743);
INSERT INTO customer.customers VALUES ('Dinh Tuan Huong', '326 Hang Voi', 'Hai Ba Trung', 'Khanh Hoa', 'huong.dt521@gmail.com', 8550795989);
INSERT INTO customer.customers VALUES ('Ho Khanh Ha', '809 Ly Nam De', 'Quan 3', 'Ha Nam', 'ha.hk717@gmail.com', 3288942783);
INSERT INTO customer.customers VALUES ('Quach Thanh Hung', '405 Kim Ma', 'Quan 5', 'Ha Noi', 'hung.qt67@gmail.com', 2679421266);
INSERT INTO customer.customers VALUES ('Tran Tuan Hoa', '571 O Cho Dua', 'Cau Giay', 'Ninh Thuan', 'hoa.tt402@gmail.com', 1043034538);
INSERT INTO customer.customers VALUES ('Ho Thi Huy', '141 Hang Da', 'Ha Dong', 'Nam Dinh', 'huy.ht587@gmail.com', 1406999804);
INSERT INTO customer.customers VALUES ('Quach Minh Van', '603 Hang Tre', 'Quan 3', 'Da Nang', 'van.qm897@gmail.com', 3283235750);
INSERT INTO customer.customers VALUES ('Huynh Chi Phuong', '542 Hang Can', 'Ha Dong', 'Thai Nguyen', 'phuong.hc30@gmail.com', 3276391385);
INSERT INTO customer.customers VALUES ('Dau Kieu Giang', '527 Le Ngoc Han', 'Hai Ba Trung', 'Hue', 'giang.dk365@gmail.com', 8217984765);
INSERT INTO customer.customers VALUES ('Ho Chi Van', '938 Hang Khay', 'Hoan Kiem', 'Ha Noi', 'van.hc233@gmail.com', 4414058809);
INSERT INTO customer.customers VALUES ('Do Manh Tien', '817 Tran Dai Nghia', 'Nam Tu Liem', 'Nam Dinh', 'tien.dm467@gmail.com', 9939303972);
INSERT INTO customer.customers VALUES ('Duong Tuan Loan', '180 Hang Luoc', 'Quan 1', 'Dak Lak', 'loan.dt603@gmail.com', 2543025800);
INSERT INTO customer.customers VALUES ('Phan Minh Ngoc', '496 Hoang Cau', 'Quan 2', 'Ha Tinh', 'ngoc.pm402@gmail.com', 5508481151);
INSERT INTO customer.customers VALUES ('Ly Khanh Khoa', '862 Hang Non', 'Cau Giay', 'Vinh', 'khoa.lk553@gmail.com', 7185116790);
INSERT INTO customer.customers VALUES ('Do Nam Hiep', '189 Thuoc Bac', 'Son Tra', 'Da Nang', 'hiep.dn825@gmail.com', 5211058138);
INSERT INTO customer.customers VALUES ('Diep Tuan Hoa', '822 Pham Hong Thai', 'Quan 2', 'Vung Tau', 'hoa.dt433@gmail.com', 1811554558);
INSERT INTO customer.customers VALUES ('Dinh Tuan Anh', '472 Hang Dao', 'Phu Nhuan', 'Gia Lai', 'anh.dt742@gmail.com', 4361907945);
INSERT INTO customer.customers VALUES ('Do Khanh Cuong', '881 O Cho Dua', 'Long Bien', 'Khanh Hoa', 'cuong.dk742@gmail.com', 4175113201);
INSERT INTO customer.customers VALUES ('Ngo Chi Thao', '311 Ba Trieu', 'Ba Dinh', 'Kon Tum', 'thao.nc116@gmail.com', 7063760380);
INSERT INTO customer.customers VALUES ('Hoang Nam Khoa', '202 Ly Nam De', 'Hai Ba Trung', 'Ha Tinh', 'khoa.hn671@gmail.com', 8271358628);
INSERT INTO customer.customers VALUES ('Trinh Khanh Lan', '644 Luong Dinh Cua', 'Ngo Quyen', 'Khanh Hoa', 'lan.tk19@gmail.com', 9738747089);
INSERT INTO customer.customers VALUES ('Le Nam Khanh', '235 Le Duan', 'Ba Dinh', 'Binh Dinh', 'khanh.ln4@gmail.com', 6391357241);
INSERT INTO customer.customers VALUES ('Quach Chi Loan', '356 Tran Quoc Toan', 'Cam Le', 'Quy Nhon', 'loan.qc615@gmail.com', 6895584820);
INSERT INTO customer.customers VALUES ('Diep Manh Ngan', '463 Hoang Cau', 'Cau Giay', 'Thai Nguyen', 'ngan.dm170@gmail.com', 8138302742);
INSERT INTO customer.customers VALUES ('Do Chi Huong', '82 Ba Trieu', 'Long Bien', 'Ha Noi', 'huong.dc504@gmail.com', 1766378329);
INSERT INTO customer.customers VALUES ('Do Thi Xuan', '239 Kim Ma', 'Hong Bang', 'Hai Phong', 'xuan.dt437@gmail.com', 3317700634);
INSERT INTO customer.customers VALUES ('Vo Hoang Hoa', '133 Pham Hong Thai', 'Nam Tu Liem', 'Gia Lai', 'hoa.vh373@gmail.com', 9847270747);
INSERT INTO customer.customers VALUES ('Luong Thi Van', '4 Ton Duc Thang', 'Quan 2', 'Vung Tau', 'van.lt471@gmail.com', 4296747479);
INSERT INTO customer.customers VALUES ('Tran Thanh Phuong', '504 Tran Dai Nghia', 'Hai Ba Trung', 'Dak Lak', 'phuong.tt763@gmail.com', 8919573045);
INSERT INTO customer.customers VALUES ('Dau Kieu Thao', '723 Le Ngoc Han', 'Tay Ho', 'Phu Tho', 'thao.dk241@gmail.com', 1598760712);
INSERT INTO customer.customers VALUES ('Ly Nam Hung', '318 Ton Duc Thang', 'Thanh Khe', 'Ho Chi Minh', 'hung.ln662@gmail.com', 7779148785);
INSERT INTO customer.customers VALUES ('Ho Manh Anh', '294 Hang Chieu', 'Hoan Kiem', 'Quang Nam', 'anh.hm537@gmail.com', 8295133954);
INSERT INTO customer.customers VALUES ('Vo Ngoc Giang', '74 Hang Ca', 'Hai Ba Trung', 'Quang Binh', 'giang.vn889@gmail.com', 4028277176);
INSERT INTO customer.customers VALUES ('Do Ngoc Xuan', '244 Xuan Thuy', 'Long Bien', 'Quang Ngai', 'xuan.dn216@gmail.com', 3720891004);
INSERT INTO customer.customers VALUES ('Ta Minh Duc', '823 Le Thanh Ton', 'Son Tra', 'Quang Nam', 'duc.tm45@gmail.com', 4101330852);
INSERT INTO customer.customers VALUES ('Phan Nam Trinh', '175 Hang Bong', 'Son Tra', 'Quang Ninh', 'trinh.pn171@gmail.com', 9838842244);
INSERT INTO customer.customers VALUES ('Ly Hai Van', '876 Phan Dinh Phung', 'Bac Tu Liem', 'Binh Dinh', 'van.lh204@gmail.com', 3137271008);
INSERT INTO customer.customers VALUES ('Hoang Kieu Nhi', '100 Hang Dao', 'Cam Le', 'Gia Lai', 'nhi.hk580@gmail.com', 4820502547);
INSERT INTO customer.customers VALUES ('Huynh Hoang Huy', '587 Tran Hung Dao', 'Binh Thanh', 'Binh Dinh', 'huy.hh42@gmail.com', 3029110034);
INSERT INTO customer.customers VALUES ('Ta Manh Chien', '587 Pham Ngu Lao', 'Quan 3', 'Ninh Thuan', 'chien.tm747@gmail.com', 8924014065);
INSERT INTO customer.customers VALUES ('Pham Minh Hiep', '481 Tran Quoc Toan', 'Thanh Khe', 'Kon Tum', 'hiep.pm580@gmail.com', 6048427079);
INSERT INTO customer.customers VALUES ('Bui Thi Thanh', '784 Le Loi', 'Hong Bang', 'Da Lat', 'thanh.bt180@gmail.com', 1482172601);
INSERT INTO customer.customers VALUES ('Quach Thanh Linh', '448 Giang Vo', 'Quan 3', 'Hai Phong', 'linh.qt626@gmail.com', 3909044975);
INSERT INTO customer.customers VALUES ('Hoang Kieu Linh', '549 Hang Ma', 'Le Chan', 'Thai Nguyen', 'linh.hk439@gmail.com', 7055285750);
INSERT INTO customer.customers VALUES ('Dinh Ngoc Van', '891 Ngo Quyen', 'Hai Chau', 'Bac Ninh', 'van.dn909@gmail.com', 2983844279);
INSERT INTO customer.customers VALUES ('Ho Hai Van', '697 Thuoc Bac', 'Quan 1', 'Binh Dinh', 'van.hh600@gmail.com', 1100082490);
INSERT INTO customer.customers VALUES ('Pham Chi Huong', '708 Hang Tre', 'Thanh Xuan', 'Quang Tri', 'huong.pc979@gmail.com', 7780697183);
INSERT INTO customer.customers VALUES ('Tran Khanh Khoa', '728 Hang Ngang', 'Dong Da', 'Nam Dinh', 'khoa.tk267@gmail.com', 8852288088);
INSERT INTO customer.customers VALUES ('Ngo Chi Van', '364 Ly Thuong Kiet', 'Cam Le', 'Gia Lai', 'van.nc255@gmail.com', 2625205184);
INSERT INTO customer.customers VALUES ('Duong Ngoc Tien', '882 Le Thanh Ton', 'Nam Tu Liem', 'Da Nang', 'tien.dn458@gmail.com', 3070886699);
INSERT INTO customer.customers VALUES ('Diep Minh Long', '265 Kim Ma', 'Hoang Mai', 'Quy Nhon', 'long.dm269@gmail.com', 6679047545);
INSERT INTO customer.customers VALUES ('Huynh Nam Thuy', '576 Le Thanh Ton', 'Hoan Kiem', 'Kon Tum', 'thuy.hn109@gmail.com', 1010555739);
INSERT INTO customer.customers VALUES ('Do Hai Linh', '633 Le Thanh Ton', 'Binh Thanh', 'Bien Hoa', 'linh.dh16@gmail.com', 2169880257);
INSERT INTO customer.customers VALUES ('Luong Minh Anh', '708 Le Loi', 'Dong Da', 'Yen Bai', 'anh.lm198@gmail.com', 5955822520);
INSERT INTO customer.customers VALUES ('Ly Chi Ngan', '936 Nguyen Sieu', 'Cau Giay', 'Nha Trang', 'ngan.lc952@gmail.com', 2921707800);
INSERT INTO customer.customers VALUES ('Ngo Nam Cuong', '911 Hang Ca', 'Cau Giay', 'Ninh Thuan', 'cuong.nn693@gmail.com', 6544897382);
INSERT INTO customer.customers VALUES ('Nguyen Chi Sang', '392 Hang Luoc', 'Phu Nhuan', 'Vung Tau', 'sang.nc350@gmail.com', 3843625459);
INSERT INTO customer.customers VALUES ('Ly Hai Van', '512 Lan Ong', 'Quan 1', 'Khanh Hoa', 'van.lh65@gmail.com', 9836338967);
INSERT INTO customer.customers VALUES ('Luong Ngoc Nhung', '890 Hang Gai', 'Ngo Quyen', 'Quang Binh', 'nhung.ln893@gmail.com', 1817420400);
INSERT INTO customer.customers VALUES ('Le Manh Long', '940 Le Ngoc Han', 'Long Bien', 'Quang Nam', 'long.lm152@gmail.com', 1502512652);
INSERT INTO customer.customers VALUES ('Tran Nam My', '95 Ba Trieu', 'Thanh Xuan', 'Phu Yen', 'my.tn210@gmail.com', 6437489494);
INSERT INTO customer.customers VALUES ('Dinh Hai Nhung', '815 Kim Ma', 'Quan 5', 'Quang Ninh', 'nhung.dh434@gmail.com', 4446476568);
INSERT INTO customer.customers VALUES ('Ly Minh Van', '20 Hang Luoc', 'Quan 4', 'Quang Ngai', 'van.lm329@gmail.com', 1050360112);
INSERT INTO customer.customers VALUES ('Pham Minh Hiep', '347 Hang Chieu', 'Tay Ho', 'Phu Yen', 'hiep.pm582@gmail.com', 3833231319);
INSERT INTO customer.customers VALUES ('Diep Hai Trang', '224 Tran Quoc Toan', 'Hai Chau', 'Gia Lai', 'trang.dh161@gmail.com', 4920186527);
INSERT INTO customer.customers VALUES ('Ly Thanh Trinh', '732 Hang Bong', 'Quan 1', 'Kon Tum', 'trinh.lt842@gmail.com', 6624696757);
INSERT INTO customer.customers VALUES ('Vu Ngoc Ngoc', '682 Nguyen Xi', 'Nam Tu Liem', 'Quang Binh', 'ngoc.vn117@gmail.com', 5408345971);
INSERT INTO customer.customers VALUES ('Le Hai Thao', '374 Luong Dinh Cua', 'Quan 4', 'Nam Dinh', 'thao.lh92@gmail.com', 7880236547);
INSERT INTO customer.customers VALUES ('Bui Ngoc Chien', '328 Hang Chieu', 'Hong Bang', 'Da Nang', 'chien.bn730@gmail.com', 4841112299);
INSERT INTO customer.customers VALUES ('Pham Khanh Linh', '410 Nguyen Xi', 'Cam Le', 'Ho Chi Minh', 'linh.pk580@gmail.com', 4950183201);
INSERT INTO customer.customers VALUES ('Bui Ngoc Huong', '257 Tran Quoc Toan', 'Phu Nhuan', 'Quang Ngai', 'huong.bn16@gmail.com', 6058623286);
INSERT INTO customer.customers VALUES ('Do Ngoc Tuyet', '713 Hang Voi', 'Quan 4', 'Nam Dinh', 'tuyet.dn461@gmail.com', 9620873532);
INSERT INTO customer.customers VALUES ('Ngo Thi Phuong', '254 Le Loi', 'Son Tra', 'Da Nang', 'phuong.nt408@gmail.com', 4775206234);
INSERT INTO customer.customers VALUES ('Tran Minh Lan', '858 Thuoc Bac', 'Tay Ho', 'Dak Lak', 'lan.tm665@gmail.com', 6121807245);
INSERT INTO customer.customers VALUES ('Pham Ngoc Huyen', '957 Le Duan', 'Quan 2', 'Phu Yen', 'huyen.pn194@gmail.com', 7981585518);
INSERT INTO customer.customers VALUES ('Tran Kieu Nhi', '67 Nguyen Sieu', 'Tay Ho', 'Quang Ngai', 'nhi.tk206@gmail.com', 1482062018);
INSERT INTO customer.customers VALUES ('Le Hoang Xuan', '349 Le Ngoc Han', 'Quan 5', 'Gia Lai', 'xuan.lh621@gmail.com', 9037261647);
INSERT INTO customer.customers VALUES ('Tran Hai Hung', '422 Hang Ma', 'Quan 3', 'Da Nang', 'hung.th414@gmail.com', 7522113920);
INSERT INTO customer.customers VALUES ('Quach Kieu Tien', '46 Ho Tung Mau', 'Quan 4', 'Da Nang', 'tien.qk825@gmail.com', 2278067626);
INSERT INTO customer.customers VALUES ('Dang Ngoc Duc', '673 Hang Can', 'Cau Giay', 'Gia Lai', 'duc.dn343@gmail.com', 6268063732);
INSERT INTO customer.customers VALUES ('Trinh Khanh Giang', '588 Tran Dai Nghia', 'Long Bien', 'Phu Tho', 'giang.tk988@gmail.com', 1181902983);
INSERT INTO customer.customers VALUES ('Pham Khanh Anh', '396 Lan Ong', 'Hoan Kiem', 'Kon Tum', 'anh.pk931@gmail.com', 2475210146);
INSERT INTO customer.customers VALUES ('Ly Hoang Quynh', '997 Kim Ma', 'Thanh Xuan', 'Binh Thuan', 'quynh.lh915@gmail.com', 4457692376);
INSERT INTO customer.customers VALUES ('Phan Kieu Ngoc', '757 Hang Ngang', 'Quan 4', 'Ninh Thuan', 'ngoc.pk223@gmail.com', 9937378361);
INSERT INTO customer.customers VALUES ('Dinh Thi Lam', '197 Hang Tre', 'Hai Chau', 'Quang Tri', 'lam.dt999@gmail.com', 6283889213);
INSERT INTO customer.customers VALUES ('Diep Nam Cuong', '593 Nguyen Xi', 'Quan 3', 'Ha Noi', 'cuong.dn663@gmail.com', 4213564138);
INSERT INTO customer.customers VALUES ('Vu Thanh Nam', '700 Hang Khay', 'Quan 3', 'Can Tho', 'nam.vt225@gmail.com', 9863098201);
INSERT INTO customer.customers VALUES ('Do Khanh Thao', '499 Nguyen Sieu', 'Dong Da', 'Bien Hoa', 'thao.dk185@gmail.com', 4078169306);
INSERT INTO customer.customers VALUES ('Vu Hai Xuan', '255 Hoang Quoc Viet', 'Ha Dong', 'Dak Lak', 'xuan.vh224@gmail.com', 8370465504);
INSERT INTO customer.customers VALUES ('Dau Khanh Loan', '193 Ly Nam De', 'Hai Chau', 'Quang Binh', 'loan.dk294@gmail.com', 9378704086);
INSERT INTO customer.customers VALUES ('Do Nam Nga', '702 Ly Thuong Kiet', 'Thanh Xuan', 'Can Tho', 'nga.dn775@gmail.com', 9232345659);
INSERT INTO customer.customers VALUES ('Luong Nam Nga', '851 Phan Dinh Phung', 'Ba Dinh', 'Can Tho', 'nga.ln67@gmail.com', 6253437687);
INSERT INTO customer.customers VALUES ('Duong Hai Tien', '887 Le Duan', 'Ba Dinh', 'Quang Tri', 'tien.dh999@gmail.com', 9394495163);
INSERT INTO customer.customers VALUES ('Dinh Thi Huyen', '748 Hang Ma', 'Long Bien', 'Ho Chi Minh', 'huyen.dt458@gmail.com', 3674888564);
INSERT INTO customer.customers VALUES ('Ho Thi Duc', '407 Hang Luoc', 'Hoang Mai', 'Nam Dinh', 'duc.ht1000@gmail.com', 7379244529);
INSERT INTO customer.customers VALUES ('Vu Thanh Tien', '37 Nguyen Sieu', 'Thanh Khe', 'Nam Dinh', 'tien.vt334@gmail.com', 7932542265);
INSERT INTO customer.customers VALUES ('Trinh Thanh Thuy', '717 Ton Duc Thang', 'Quan 1', 'Nha Trang', 'thuy.tt698@gmail.com', 1925806150);
INSERT INTO customer.customers VALUES ('Dau Nam Nhung', '156 Hang Da', 'Thanh Khe', 'Nam Dinh', 'nhung.dn804@gmail.com', 8608170766);
INSERT INTO customer.customers VALUES ('Luong Hai Van', '77 Hang Bo', 'Thanh Khe', 'Phu Tho', 'van.lh890@gmail.com', 1401480405);
INSERT INTO customer.customers VALUES ('Quach Nam Tuyet', '844 Hang Ca', 'Ba Dinh', 'Ha Nam', 'tuyet.qn702@gmail.com', 6303116485);
INSERT INTO customer.customers VALUES ('Dang Tuan Chien', '268 Pham Ngu Lao', 'Hai Ba Trung', 'Ninh Thuan', 'chien.dt108@gmail.com', 5200388427);
INSERT INTO customer.customers VALUES ('Diep Hai Ngan', '233 Hang Dao', 'Le Chan', 'Ninh Thuan', 'ngan.dh856@gmail.com', 4151340075);
INSERT INTO customer.customers VALUES ('Ho Manh Van', '319 Thuoc Bac', 'Ha Dong', 'Nha Trang', 'van.hm101@gmail.com', 6801750657);
INSERT INTO customer.customers VALUES ('Phan Thanh My', '611 Nguyen Trai', 'Hai Chau', 'Ho Chi Minh', 'my.pt311@gmail.com', 8354926082);
INSERT INTO customer.customers VALUES ('Trinh Manh Hung', '495 Hang Dao', 'Tay Ho', 'Can Tho', 'hung.tm609@gmail.com', 8385203642);
INSERT INTO customer.customers VALUES ('Hoang Kieu Loan', '887 Thuoc Bac', 'Son Tra', 'Hai Phong', 'loan.hk93@gmail.com', 1975252753);
INSERT INTO customer.customers VALUES ('Ho Tuan Giang', '162 Nguyen Xi', 'Nam Tu Liem', 'Phu Tho', 'giang.ht635@gmail.com', 6694809252);
INSERT INTO customer.customers VALUES ('Pham Khanh Xuan', '492 Hoang Quoc Viet', 'Thanh Xuan', 'Da Nang', 'xuan.pk486@gmail.com', 1952217864);
INSERT INTO customer.customers VALUES ('Dau Chi Sang', '584 Phan Chu Trinh', 'Thanh Khe', 'Kon Tum', 'sang.dc633@gmail.com', 7695924944);
INSERT INTO customer.customers VALUES ('Duong Nam Hiep', '452 Xuan Thuy', 'Cau Giay', 'Kon Tum', 'hiep.dn675@gmail.com', 3888780524);
INSERT INTO customer.customers VALUES ('Luong Khanh Ha', '760 Pham Hong Thai', 'Phu Nhuan', 'Vung Tau', 'ha.lk861@gmail.com', 1684073597);
INSERT INTO customer.customers VALUES ('Pham Thanh Huyen', '759 Ly Nam De', 'Thanh Xuan', 'Vinh', 'huyen.pt935@gmail.com', 6366828819);
INSERT INTO customer.customers VALUES ('Dau Minh Van', '732 Phan Dinh Phung', 'Quan 1', 'Ha Tinh', 'van.dm456@gmail.com', 3209953695);
INSERT INTO customer.customers VALUES ('Duong Thanh Hai', '571 Hang Bong', 'Cau Giay', 'Quang Binh', 'hai.dt538@gmail.com', 7287125573);
INSERT INTO customer.customers VALUES ('Vo Kieu Tien', '709 Le Ngoc Han', 'Long Bien', 'Ha Noi', 'tien.vk657@gmail.com', 1901654508);
INSERT INTO customer.customers VALUES ('Le Hai Tien', '304 Hang Mam', 'Quan 5', 'Da Lat', 'tien.lh311@gmail.com', 9428929696);
INSERT INTO customer.customers VALUES ('Tran Tuan Thanh', '82 Hang Gai', 'Tay Ho', 'Quang Tri', 'thanh.tt465@gmail.com', 4118975296);
INSERT INTO customer.customers VALUES ('Ly Minh Hiep', '70 Ho Tung Mau', 'Hai Ba Trung', 'Can Tho', 'hiep.lm27@gmail.com', 6555949263);
INSERT INTO customer.customers VALUES ('Vu Ngoc Phuong', '961 Tran Hung Dao', 'Ngo Quyen', 'Dak Lak', 'phuong.vn476@gmail.com', 9256771309);
INSERT INTO customer.customers VALUES ('Pham Manh Minh', '586 Hoang Cau', 'Son Tra', 'Ha Nam', 'minh.pm858@gmail.com', 8822558825);
INSERT INTO customer.customers VALUES ('Ta Ngoc Xuan', '319 Tran Phu', 'Cam Le', 'Quy Nhon', 'xuan.tn545@gmail.com', 5287051165);
INSERT INTO customer.customers VALUES ('Tran Thanh Huy', '882 Ho Tung Mau', 'Cam Le', 'Binh Thuan', 'huy.tt421@gmail.com', 8067466146);
INSERT INTO customer.customers VALUES ('Pham Manh Minh', '337 Tran Quoc Toan', 'Son Tra', 'Quang Ninh', 'minh.pm8@gmail.com', 5740227108);
INSERT INTO customer.customers VALUES ('Hoang Nam Huyen', '297 Pham Ngu Lao', 'Hong Bang', 'Ha Tinh', 'huyen.hn225@gmail.com', 7765348851);
INSERT INTO customer.customers VALUES ('Ngo Thanh Huy', '198 Hang Luoc', 'Tay Ho', 'Nha Trang', 'huy.nt397@gmail.com', 3390723187);
INSERT INTO customer.customers VALUES ('Quach Hai Nhung', '932 Quan Thanh', 'Binh Thanh', 'Yen Bai', 'nhung.qh383@gmail.com', 6805949799);
INSERT INTO customer.customers VALUES ('Phan Manh Huyen', '110 Hang Mam', 'Tay Ho', 'Nam Dinh', 'huyen.pm543@gmail.com', 1569187103);
INSERT INTO customer.customers VALUES ('Duong Minh Nhi', '413 Pham Ngu Lao', 'Ngo Quyen', 'Phu Yen', 'nhi.dm603@gmail.com', 2756161202);
INSERT INTO customer.customers VALUES ('Pham Thi Ngoc', '963 Hang Non', 'Quan 2', 'Phu Tho', 'ngoc.pt546@gmail.com', 2090720988);
INSERT INTO customer.customers VALUES ('Diep Nam Ha', '176 Hang Luoc', 'Dong Da', 'Ha Noi', 'ha.dn542@gmail.com', 6832947009);
INSERT INTO customer.customers VALUES ('Le Minh Ngoc', '148 Ly Nam De', 'Nam Tu Liem', 'Binh Thuan', 'ngoc.lm104@gmail.com', 5086908751);
INSERT INTO customer.customers VALUES ('Vu Thanh Hoa', '971 Hang Luoc', 'Le Chan', 'Binh Dinh', 'hoa.vt678@gmail.com', 1093465838);
INSERT INTO customer.customers VALUES ('Phan Hoang Khanh', '603 Xuan Thuy', 'Quan 2', 'Can Tho', 'khanh.ph222@gmail.com', 7890430801);
INSERT INTO customer.customers VALUES ('Vu Thi Khanh', '36 Ton Duc Thang', 'Hoan Kiem', 'Quang Tri', 'khanh.vt882@gmail.com', 5988804846);
INSERT INTO customer.customers VALUES ('Vu Khanh Nga', '893 Hang Da', 'Ngo Quyen', 'Bac Ninh', 'nga.vk355@gmail.com', 1166615251);
INSERT INTO customer.customers VALUES ('Diep Ngoc Nhung', '828 Ngo Quyen', 'Bac Tu Liem', 'Thai Nguyen', 'nhung.dn92@gmail.com', 8291508036);
INSERT INTO customer.customers VALUES ('Do Kieu Ngan', '712 Hang Ca', 'Ngo Quyen', 'Ha Noi', 'ngan.dk751@gmail.com', 1563124279);
INSERT INTO customer.customers VALUES ('Trinh Khanh Thanh', '568 Lan Ong', 'Le Chan', 'Ho Chi Minh', 'thanh.tk259@gmail.com', 5567548644);
INSERT INTO customer.customers VALUES ('Pham Hai My', '369 Hoang Cau', 'Quan 1', 'Ho Chi Minh', 'my.ph473@gmail.com', 1513336876);
INSERT INTO customer.customers VALUES ('Hoang Chi Ngoc', '715 Nguyen Xi', 'Cam Le', 'Quy Nhon', 'ngoc.hc362@gmail.com', 1219472446);
INSERT INTO customer.customers VALUES ('Ly Thi Lam', '726 Kim Ma', 'Hai Ba Trung', 'Quang Ninh', 'lam.lt730@gmail.com', 1646929258);
INSERT INTO customer.customers VALUES ('Duong Nam Khoa', '301 Luong Van Can', 'Quan 3', 'Nam Dinh', 'khoa.dn282@gmail.com', 3835784925);
INSERT INTO customer.customers VALUES ('Vu Manh Van', '869 Tran Phu', 'Hai Chau', 'Da Lat', 'van.vm345@gmail.com', 9268255315);
INSERT INTO customer.customers VALUES ('Bui Kieu Ngoc', '337 Hang Chieu', 'Tay Ho', 'Ha Nam', 'ngoc.bk353@gmail.com', 8033484104);
INSERT INTO customer.customers VALUES ('Vu Minh Hiep', '17 Hang Dao', 'Binh Thanh', 'Hue', 'hiep.vm77@gmail.com', 7870733562);
INSERT INTO customer.customers VALUES ('Phan Tuan Van', '807 Phan Dinh Phung', 'Dong Da', 'Binh Thuan', 'van.pt887@gmail.com', 7799984610);
INSERT INTO customer.customers VALUES ('Quach Ngoc Nam', '654 Phung Hung', 'Quan 5', 'Quy Nhon', 'nam.qn546@gmail.com', 1636864191);
INSERT INTO customer.customers VALUES ('Luong Thanh Xuan', '641 Hoang Quoc Viet', 'Tay Ho', 'Phu Tho', 'xuan.lt530@gmail.com', 1668199713);
INSERT INTO customer.customers VALUES ('Quach Chi Huyen', '238 Thuoc Bac', 'Cam Le', 'Da Nang', 'huyen.qc795@gmail.com', 4237672624);
INSERT INTO customer.customers VALUES ('Dang Kieu My', '688 Hang Non', 'Binh Thanh', 'Nam Dinh', 'my.dk265@gmail.com', 9818142975);
INSERT INTO customer.customers VALUES ('Dau Hai Nhung', '732 Tran Hung Dao', 'Cam Le', 'Nha Trang', 'nhung.dh990@gmail.com', 6179176817);
INSERT INTO customer.customers VALUES ('Duong Khanh Ngan', '960 Hoang Cau', 'Bac Tu Liem', 'Quang Tri', 'ngan.dk219@gmail.com', 9011965221);
INSERT INTO customer.customers VALUES ('Phan Chi Van', '18 Luong Dinh Cua', 'Tay Ho', 'Khanh Hoa', 'van.pc570@gmail.com', 3211778135);
INSERT INTO customer.customers VALUES ('Luong Thi Hai', '374 Tran Phu', 'Tay Ho', 'Ninh Thuan', 'hai.lt340@gmail.com', 1692596459);
INSERT INTO customer.customers VALUES ('Quach Kieu Khoa', '963 Hang Bong', 'Thanh Khe', 'Quang Ninh', 'khoa.qk30@gmail.com', 7006750413);
INSERT INTO customer.customers VALUES ('Vo Thanh Ha', '76 Nguyen Xi', 'Cau Giay', 'Da Nang', 'ha.vt222@gmail.com', 9036370215);
INSERT INTO customer.customers VALUES ('Quach Nam Nhi', '859 Hang Tre', 'Hong Bang', 'Hue', 'nhi.qn383@gmail.com', 7681020122);
INSERT INTO customer.customers VALUES ('Diep Manh Hiep', '130 Le Duan', 'Hoang Mai', 'Nha Trang', 'hiep.dm476@gmail.com', 1726275085);
INSERT INTO customer.customers VALUES ('Pham Khanh Nhi', '406 Kim Ma', 'Quan 3', 'Binh Thuan', 'nhi.pk917@gmail.com', 7480269981);
INSERT INTO customer.customers VALUES ('Phan Thi Loan', '945 Hang Gai', 'Binh Thanh', 'Da Nang', 'loan.pt402@gmail.com', 6364770673);
INSERT INTO customer.customers VALUES ('Do Thanh Cuong', '760 Tran Dai Nghia', 'Hoang Mai', 'Phu Tho', 'cuong.dt776@gmail.com', 8862056695);
INSERT INTO customer.customers VALUES ('Ta Khanh Lam', '601 Hang Khay', 'Hoang Mai', 'Quy Nhon', 'lam.tk129@gmail.com', 5407675366);
INSERT INTO customer.customers VALUES ('Nguyen Khanh Huong', '821 Luong Dinh Cua', 'Cam Le', 'Phu Tho', 'huong.nk731@gmail.com', 9533472773);
INSERT INTO customer.customers VALUES ('Vo Thi Ha', '553 Hang Non', 'Ngo Quyen', 'Da Nang', 'ha.vt181@gmail.com', 1088537484);
INSERT INTO customer.customers VALUES ('Phan Ngoc Linh', '44 Thuoc Bac', 'Quan 3', 'Quang Tri', 'linh.pn926@gmail.com', 2077939920);
INSERT INTO customer.customers VALUES ('Diep Hai Trinh', '534 Tran Hung Dao', 'Binh Thanh', 'Thai Nguyen', 'trinh.dh62@gmail.com', 7783207342);
INSERT INTO customer.customers VALUES ('Ly Hoang Tuyet', '924 Nguyen Xi', 'Long Bien', 'Binh Dinh', 'tuyet.lh146@gmail.com', 3980193920);
INSERT INTO customer.customers VALUES ('Trinh Tuan Ly', '429 Lan Ong', 'Thanh Xuan', 'Quang Nam', 'ly.tt633@gmail.com', 2075214607);
INSERT INTO customer.customers VALUES ('Duong Kieu Thanh', '143 Giang Vo', 'Hai Chau', 'Gia Lai', 'thanh.dk835@gmail.com', 3846887187);
INSERT INTO customer.customers VALUES ('Ho Kieu Tuyet', '199 Nguyen Trai', 'Le Chan', 'Bien Hoa', 'tuyet.hk447@gmail.com', 4915899461);
INSERT INTO customer.customers VALUES ('Dinh Thi Nga', '318 Hoang Quoc Viet', 'Quan 5', 'Quang Binh', 'nga.dt461@gmail.com', 7813988386);
INSERT INTO customer.customers VALUES ('Ho Kieu Lan', '433 Hang Can', 'Thanh Xuan', 'Gia Lai', 'lan.hk206@gmail.com', 5959016935);
INSERT INTO customer.customers VALUES ('Duong Minh Quynh', '596 Kim Ma', 'Hong Bang', 'Binh Thuan', 'quynh.dm745@gmail.com', 3730805977);
INSERT INTO customer.customers VALUES ('Diep Kieu Ha', '135 Pham Hong Thai', 'Tay Ho', 'Thai Nguyen', 'ha.dk603@gmail.com', 7065674521);
INSERT INTO customer.customers VALUES ('Ngo Minh Ngan', '42 Hoang Quoc Viet', 'Hong Bang', 'Da Lat', 'ngan.nm746@gmail.com', 8980279420);
INSERT INTO customer.customers VALUES ('Ly Thi Tien', '177 Nguyen Xi', 'Long Bien', 'Dak Lak', 'tien.lt340@gmail.com', 3374825508);
INSERT INTO customer.customers VALUES ('Bui Hoang Van', '578 Le Loi', 'Ba Dinh', 'Quang Tri', 'van.bh392@gmail.com', 2429381481);
INSERT INTO customer.customers VALUES ('Ngo Hai Van', '675 Ton Duc Thang', 'Ba Dinh', 'Quang Ninh', 'van.nh903@gmail.com', 5581131758);
INSERT INTO customer.customers VALUES ('Diep Thanh Nhung', '425 Hang Chieu', 'Ngo Quyen', 'Hue', 'nhung.dt768@gmail.com', 3724024886);
INSERT INTO customer.customers VALUES ('Duong Manh Linh', '719 Nguyen Xi', 'Hoan Kiem', 'Quang Tri', 'linh.dm534@gmail.com', 1103965867);
INSERT INTO customer.customers VALUES ('Dau Nam Giang', '716 Hang Voi', 'Ba Dinh', 'Nam Dinh', 'giang.dn374@gmail.com', 1676192608);
INSERT INTO customer.customers VALUES ('Dang Thi Nga', '211 Tran Hung Dao', 'Ba Dinh', 'Da Nang', 'nga.dt927@gmail.com', 5624479688);
INSERT INTO customer.customers VALUES ('Huynh Chi Duc', '289 Hang Bo', 'Hoang Mai', 'Da Nang', 'duc.hc640@gmail.com', 4231927807);
INSERT INTO customer.customers VALUES ('Huynh Hai Ngan', '948 Hoang Cau', 'Cam Le', 'Ha Noi', 'ngan.hh908@gmail.com', 7287352908);
INSERT INTO customer.customers VALUES ('Nguyen Hai Chien', '91 Hang Luoc', 'Quan 1', 'Ha Noi', 'chien.nh941@gmail.com', 4947214090);
INSERT INTO customer.customers VALUES ('Dau Tuan Long', '960 Hang Non', 'Quan 3', 'Hai Phong', 'long.dt3@gmail.com', 6430659486);
INSERT INTO customer.customers VALUES ('Vo Thi Ngoc', '880 Ly Nam De', 'Thanh Xuan', 'Bac Ninh', 'ngoc.vt664@gmail.com', 5728053346);
INSERT INTO customer.customers VALUES ('Tran Nam Linh', '749 Lan Ong', 'Long Bien', 'Dak Lak', 'linh.tn870@gmail.com', 5495040880);
INSERT INTO customer.customers VALUES ('Luong Hoang Ly', '171 Nguyen Trai', 'Phu Nhuan', 'Da Nang', 'ly.lh659@gmail.com', 1747339160);
INSERT INTO customer.customers VALUES ('Quach Minh Linh', '500 Hang Khay', 'Hong Bang', 'Vung Tau', 'linh.qm646@gmail.com', 9205282955);
INSERT INTO customer.customers VALUES ('Duong Ngoc Sang', '967 Hang Gai', 'Le Chan', 'Thai Nguyen', 'sang.dn738@gmail.com', 8677445799);
INSERT INTO customer.customers VALUES ('Diep Chi Hiep', '696 Hang Tre', 'Cau Giay', 'Quang Nam', 'hiep.dc301@gmail.com', 2141196109);
INSERT INTO customer.customers VALUES ('Duong Hai Tien', '296 Thuoc Bac', 'Long Bien', 'Bien Hoa', 'tien.dh489@gmail.com', 3400732029);
INSERT INTO customer.customers VALUES ('Duong Minh Van', '595 Hoang Quoc Viet', 'Quan 2', 'Quang Binh', 'van.dm966@gmail.com', 8245528683);
INSERT INTO customer.customers VALUES ('Pham Tuan Sang', '442 Pham Ngu Lao', 'Son Tra', 'Da Lat', 'sang.pt766@gmail.com', 5462094798);
INSERT INTO customer.customers VALUES ('Dau Tuan Hung', '708 Hang Bong', 'Dong Da', 'Da Lat', 'hung.dt65@gmail.com', 6887202973);
INSERT INTO customer.customers VALUES ('Duong Kieu Hai', '346 Nguyen Sieu', 'Thanh Khe', 'Quang Ngai', 'hai.dk216@gmail.com', 4787649840);
INSERT INTO customer.customers VALUES ('Pham Nam Cuong', '104 Luong Dinh Cua', 'Quan 4', 'Quang Binh', 'cuong.pn773@gmail.com', 8888101444);
INSERT INTO customer.customers VALUES ('Le Kieu Thao', '638 Thuoc Bac', 'Long Bien', 'Ha Nam', 'thao.lk80@gmail.com', 5208841837);
INSERT INTO customer.customers VALUES ('Vu Hai Quynh', '900 Tran Hung Dao', 'Hai Ba Trung', 'Binh Thuan', 'quynh.vh404@gmail.com', 9110091963);
INSERT INTO customer.customers VALUES ('Tran Hoang Khanh', '519 Le Duan', 'Cau Giay', 'Nha Trang', 'khanh.th835@gmail.com', 5812516599);
INSERT INTO customer.customers VALUES ('Ngo Ngoc Chien', '157 Hung Vuong', 'Long Bien', 'Binh Thuan', 'chien.nn555@gmail.com', 3907566980);
INSERT INTO customer.customers VALUES ('Ta Khanh Tuyet', '964 Hoang Cau', 'Binh Thanh', 'Vung Tau', 'tuyet.tk197@gmail.com', 2149007908);
INSERT INTO customer.customers VALUES ('Duong Ngoc Ngan', '989 Phan Chu Trinh', 'Hai Chau', 'Nam Dinh', 'ngan.dn39@gmail.com', 5446574149);
INSERT INTO customer.customers VALUES ('Ngo Thi Anh', '688 Luong Dinh Cua', 'Dong Da', 'Ho Chi Minh', 'anh.nt861@gmail.com', 5440424076);
INSERT INTO customer.customers VALUES ('Le Hai Khoa', '873 Hang Gai', 'Hong Bang', 'Gia Lai', 'khoa.lh324@gmail.com', 7776345158);
INSERT INTO customer.customers VALUES ('Bui Manh My', '123 Luong Dinh Cua', 'Quan 3', 'Ha Noi', 'my.bm471@gmail.com', 1966993825);
INSERT INTO customer.customers VALUES ('Pham Nam Anh', '947 Hoang Quoc Viet', 'Ha Dong', 'Da Nang', 'anh.pn412@gmail.com', 9488254305);
INSERT INTO customer.customers VALUES ('Quach Chi Thuy', '802 Hang Gai', 'Quan 4', 'Ho Chi Minh', 'thuy.qc734@gmail.com', 7009102163);
INSERT INTO customer.customers VALUES ('Bui Kieu Van', '489 Hang Dao', 'Dong Da', 'Quang Ninh', 'van.bk514@gmail.com', 7778943806);
INSERT INTO customer.customers VALUES ('Dang Ngoc Thuy', '747 Giang Vo', 'Thanh Khe', 'Quang Binh', 'thuy.dn538@gmail.com', 1068884123);
INSERT INTO customer.customers VALUES ('Duong Hoang Long', '420 Tran Quoc Toan', 'Cam Le', 'Dak Lak', 'long.dh269@gmail.com', 9783302701);
INSERT INTO customer.customers VALUES ('Quach Minh Nga', '58 Le Ngoc Han', 'Le Chan', 'Da Lat', 'nga.qm382@gmail.com', 2862136829);
INSERT INTO customer.customers VALUES ('Hoang Kieu Van', '2 Hang Ma', 'Hoan Kiem', 'Kon Tum', 'van.hk674@gmail.com', 6751442038);
INSERT INTO customer.customers VALUES ('Diep Chi Nga', '547 Hang Voi', 'Thanh Xuan', 'Bac Ninh', 'nga.dc639@gmail.com', 8952769393);
INSERT INTO customer.customers VALUES ('Ho Nam Tien', '395 Ho Tung Mau', 'Long Bien', 'Dak Lak', 'tien.hn111@gmail.com', 1125773846);
INSERT INTO customer.customers VALUES ('Vo Thanh Phuong', '977 Ly Nam De', 'Tay Ho', 'Quang Ninh', 'phuong.vt453@gmail.com', 1468753786);
INSERT INTO customer.customers VALUES ('Hoang Manh Lan', '139 Kim Ma', 'Cam Le', 'Dak Lak', 'lan.hm576@gmail.com', 9158464639);
INSERT INTO customer.customers VALUES ('Ho Ngoc Khoa', '459 Le Ngoc Han', 'Hoan Kiem', 'Quang Ninh', 'khoa.hn315@gmail.com', 1540278499);
INSERT INTO customer.customers VALUES ('Quach Ngoc Ngan', '997 Luong Van Can', 'Binh Thanh', 'Phu Tho', 'ngan.qn993@gmail.com', 7597539025);
INSERT INTO customer.customers VALUES ('Duong Ngoc Cuong', '736 Phung Hung', 'Son Tra', 'Vung Tau', 'cuong.dn827@gmail.com', 1294335378);
INSERT INTO customer.customers VALUES ('Ly Tuan Ngan', '538 Le Thanh Ton', 'Ngo Quyen', 'Nam Dinh', 'ngan.lt785@gmail.com', 8274649981);
INSERT INTO customer.customers VALUES ('Dang Tuan Ha', '726 Le Ngoc Han', 'Hoan Kiem', 'Phu Tho', 'ha.dt424@gmail.com', 9840543650);
INSERT INTO customer.customers VALUES ('Ly Thi Khanh', '633 Hang Bo', 'Quan 4', 'Gia Lai', 'khanh.lt338@gmail.com', 4115087245);
INSERT INTO customer.customers VALUES ('Ho Hoang Linh', '146 Hoang Cau', 'Ba Dinh', 'Kon Tum', 'linh.hh660@gmail.com', 3964353995);
INSERT INTO customer.customers VALUES ('Ly Thanh Nhung', '253 Nguyen Trai', 'Ha Dong', 'Khanh Hoa', 'nhung.lt899@gmail.com', 1020183966);
INSERT INTO customer.customers VALUES ('Ngo Thanh Thanh', '969 Luong Dinh Cua', 'Hai Ba Trung', 'Gia Lai', 'thanh.nt780@gmail.com', 9392307368);
INSERT INTO customer.customers VALUES ('Do Minh Hung', '30 Phan Dinh Phung', 'Long Bien', 'Quang Tri', 'hung.dm520@gmail.com', 6449808655);
INSERT INTO customer.customers VALUES ('Tran Chi My', '719 Hang Gai', 'Tay Ho', 'Ha Tinh', 'my.tc854@gmail.com', 7008993750);
INSERT INTO customer.customers VALUES ('Phan Hoang Thanh', '386 Hang Chieu', 'Le Chan', 'Ninh Thuan', 'thanh.ph747@gmail.com', 7568103908);
INSERT INTO customer.customers VALUES ('Vo Hoang Giang', '310 Hang Khay', 'Binh Thanh', 'Ninh Thuan', 'giang.vh653@gmail.com', 5195412182);
INSERT INTO customer.customers VALUES ('Vu Chi Hai', '437 Ly Thuong Kiet', 'Dong Da', 'Kon Tum', 'hai.vc904@gmail.com', 4409277455);
INSERT INTO customer.customers VALUES ('Trinh Khanh Trinh', '849 Hang Luoc', 'Hoang Mai', 'Thai Nguyen', 'trinh.tk933@gmail.com', 7448188591);
INSERT INTO customer.customers VALUES ('Do Thanh Nhung', '376 O Cho Dua', 'Le Chan', 'Kon Tum', 'nhung.dt904@gmail.com', 1582299269);
INSERT INTO customer.customers VALUES ('Huynh Ngoc Hung', '418 Le Thanh Ton', 'Quan 1', 'Nha Trang', 'hung.hn923@gmail.com', 8252700655);
INSERT INTO customer.customers VALUES ('Ly Kieu Van', '88 Hang Mam', 'Hai Chau', 'Quang Nam', 'van.lk94@gmail.com', 6230975588);
INSERT INTO customer.customers VALUES ('Duong Ngoc Ngan', '586 Nguyen Xi', 'Hoan Kiem', 'Bac Ninh', 'ngan.dn244@gmail.com', 8700298098);
INSERT INTO customer.customers VALUES ('Phan Khanh Tien', '860 Nguyen Sieu', 'Nam Tu Liem', 'Kon Tum', 'tien.pk524@gmail.com', 6748886421);
INSERT INTO customer.customers VALUES ('Quach Chi Khanh', '745 Phung Hung', 'Thanh Khe', 'Hue', 'khanh.qc172@gmail.com', 4940170893);
INSERT INTO customer.customers VALUES ('Duong Ngoc Ha', '630 O Cho Dua', 'Hoan Kiem', 'Ho Chi Minh', 'ha.dn537@gmail.com', 4386725298);
INSERT INTO customer.customers VALUES ('Vo Chi Huyen', '244 Hoang Cau', 'Ba Dinh', 'Ho Chi Minh', 'huyen.vc210@gmail.com', 2577235874);
INSERT INTO customer.customers VALUES ('Quach Chi Linh', '671 Ngo Quyen', 'Ha Dong', 'Phu Tho', 'linh.qc421@gmail.com', 6891199396);
INSERT INTO customer.customers VALUES ('Duong Nam Khoa', '898 Xuan Thuy', 'Nam Tu Liem', 'Quang Ngai', 'khoa.dn546@gmail.com', 1493376812);
INSERT INTO customer.customers VALUES ('Ngo Hai Xuan', '778 Phung Hung', 'Cau Giay', 'Ha Noi', 'xuan.nh651@gmail.com', 3263051693);
INSERT INTO customer.customers VALUES ('Do Minh Giang', '877 Pham Hong Thai', 'Quan 2', 'Da Lat', 'giang.dm977@gmail.com', 1973568700);
INSERT INTO customer.customers VALUES ('Ly Minh Nam', '896 Hang Luoc', 'Ha Dong', 'Yen Bai', 'nam.lm913@gmail.com', 8737896176);
INSERT INTO customer.customers VALUES ('Phan Hai Sang', '714 Hoang Cau', 'Le Chan', 'Dak Lak', 'sang.ph445@gmail.com', 5747221017);
INSERT INTO customer.customers VALUES ('Quach Minh Hai', '434 Hoang Quoc Viet', 'Ba Dinh', 'Bien Hoa', 'hai.qm534@gmail.com', 4519416338);
INSERT INTO customer.customers VALUES ('Vo Hai Sang', '592 Lan Ong', 'Hong Bang', 'Quang Tri', 'sang.vh301@gmail.com', 6773532616);
INSERT INTO customer.customers VALUES ('Luong Thi Anh', '296 Tran Hung Dao', 'Hoang Mai', 'Quang Ngai', 'anh.lt901@gmail.com', 7024126389);
INSERT INTO customer.customers VALUES ('Ly Ngoc Van', '359 Kim Ma', 'Bac Tu Liem', 'Nha Trang', 'van.ln869@gmail.com', 3685432687);
INSERT INTO customer.customers VALUES ('Diep Minh Ly', '699 Hang Khay', 'Quan 1', 'Vinh', 'ly.dm392@gmail.com', 6280503757);
INSERT INTO customer.customers VALUES ('Duong Nam Tien', '396 Phan Chu Trinh', 'Hong Bang', 'Ninh Thuan', 'tien.dn562@gmail.com', 6559769474);
INSERT INTO customer.customers VALUES ('Bui Kieu Van', '472 Tran Dai Nghia', 'Cam Le', 'Quang Tri', 'van.bk313@gmail.com', 9508155809);
INSERT INTO customer.customers VALUES ('Hoang Nam Trang', '243 Hoang Cau', 'Quan 5', 'Hue', 'trang.hn950@gmail.com', 9985190105);
INSERT INTO customer.customers VALUES ('Dau Thanh Long', '37 Hang Voi', 'Hong Bang', 'Quang Binh', 'long.dt762@gmail.com', 2217130758);
INSERT INTO customer.customers VALUES ('Ta Nam My', '615 O Cho Dua', 'Hoan Kiem', 'Ha Nam', 'my.tn486@gmail.com', 7487779407);
INSERT INTO customer.customers VALUES ('Diep Hai Lan', '219 Thuoc Bac', 'Hai Chau', 'Bien Hoa', 'lan.dh436@gmail.com', 7010472160);
INSERT INTO customer.customers VALUES ('Huynh Hoang Nhi', '249 Xuan Thuy', 'Son Tra', 'Bien Hoa', 'nhi.hh493@gmail.com', 5282249992);
INSERT INTO customer.customers VALUES ('Luong Hoang Long', '905 Hoang Cau', 'Phu Nhuan', 'Quang Ninh', 'long.lh167@gmail.com', 5737234075);
INSERT INTO customer.customers VALUES ('Tran Thanh Phuong', '33 Lan Ong', 'Hoang Mai', 'Bien Hoa', 'phuong.tt879@gmail.com', 3987539988);
INSERT INTO customer.customers VALUES ('Phan Thanh Tuyet', '975 Le Loi', 'Nam Tu Liem', 'Gia Lai', 'tuyet.pt203@gmail.com', 1983331463);
INSERT INTO customer.customers VALUES ('Trinh Khanh Phuong', '924 Le Thanh Ton', 'Thanh Khe', 'Phu Yen', 'phuong.tk456@gmail.com', 6318240833);
INSERT INTO customer.customers VALUES ('Ly Chi Tien', '218 Hung Vuong', 'Cau Giay', 'Ha Tinh', 'tien.lc967@gmail.com', 6662295185);
INSERT INTO customer.customers VALUES ('Phan Kieu Cuong', '991 Hang Voi', 'Quan 2', 'Ninh Thuan', 'cuong.pk628@gmail.com', 2817125213);
INSERT INTO customer.customers VALUES ('Diep Kieu Tien', '276 Hang Non', 'Hoang Mai', 'Hai Phong', 'tien.dk207@gmail.com', 7958860009);
INSERT INTO customer.customers VALUES ('Nguyen Nam Cuong', '339 Hang Mam', 'Phu Nhuan', 'Ha Tinh', 'cuong.nn411@gmail.com', 5097034562);
INSERT INTO customer.customers VALUES ('Ho Thi Nam', '184 Pham Ngu Lao', 'Long Bien', 'Da Nang', 'nam.ht266@gmail.com', 9959594962);
INSERT INTO customer.customers VALUES ('Pham Tuan Sang', '707 Ba Trieu', 'Quan 1', 'Vung Tau', 'sang.pt814@gmail.com', 6842370509);
INSERT INTO customer.customers VALUES ('Vo Hai Tien', '956 Tran Quoc Toan', 'Son Tra', 'Ninh Thuan', 'tien.vh648@gmail.com', 9383689862);
INSERT INTO customer.customers VALUES ('Ly Khanh Quynh', '189 Hang Gai', 'Cam Le', 'Ha Tinh', 'quynh.lk944@gmail.com', 5382135965);
INSERT INTO customer.customers VALUES ('Dinh Minh Van', '833 Ngo Quyen', 'Phu Nhuan', 'Thai Nguyen', 'van.dm435@gmail.com', 8758887233);
INSERT INTO customer.customers VALUES ('Dinh Khanh Long', '799 Hang Can', 'Quan 4', 'Vung Tau', 'long.dk889@gmail.com', 3464221402);
INSERT INTO customer.customers VALUES ('Huynh Tuan Giang', '197 Le Ngoc Han', 'Bac Tu Liem', 'Da Nang', 'giang.ht697@gmail.com', 2021304725);
INSERT INTO customer.customers VALUES ('Tran Manh Phuong', '690 Hung Vuong', 'Quan 1', 'Can Tho', 'phuong.tm582@gmail.com', 3569802959);
INSERT INTO customer.customers VALUES ('Le Hai My', '125 Pham Ngu Lao', 'Le Chan', 'Bac Ninh', 'my.lh660@gmail.com', 5835684772);
INSERT INTO customer.customers VALUES ('Tran Nam Nam', '105 Le Duan', 'Cau Giay', 'Bien Hoa', 'nam.tn281@gmail.com', 3407801992);
INSERT INTO customer.customers VALUES ('Phan Khanh Ly', '611 Hoang Quoc Viet', 'Quan 2', 'Vinh', 'ly.pk738@gmail.com', 6891928094);
INSERT INTO customer.customers VALUES ('Ho Manh Thuy', '359 Hung Vuong', 'Hai Ba Trung', 'Khanh Hoa', 'thuy.hm632@gmail.com', 2919003961);
INSERT INTO customer.customers VALUES ('Hoang Thi Ly', '931 Hang Ma', 'Thanh Xuan', 'Quang Binh', 'ly.ht791@gmail.com', 9066562325);
INSERT INTO customer.customers VALUES ('Dau Thanh Linh', '140 Hoang Cau', 'Cau Giay', 'Ha Tinh', 'linh.dt563@gmail.com', 9975257083);
INSERT INTO customer.customers VALUES ('Tran Nam Tuyet', '722 Phung Hung', 'Dong Da', 'Gia Lai', 'tuyet.tn434@gmail.com', 4965906439);
INSERT INTO customer.customers VALUES ('Vu Khanh Linh', '395 Luong Dinh Cua', 'Ha Dong', 'Kon Tum', 'linh.vk597@gmail.com', 5988491398);
INSERT INTO customer.customers VALUES ('Hoang Kieu Huy', '979 Hang Ca', 'Dong Da', 'Hai Phong', 'huy.hk793@gmail.com', 6999484850);
INSERT INTO customer.customers VALUES ('Ta Chi Long', '810 Tran Quoc Toan', 'Ha Dong', 'Bac Ninh', 'long.tc871@gmail.com', 3315969825);
INSERT INTO customer.customers VALUES ('Tran Ngoc Khanh', '331 Ngo Quyen', 'Thanh Xuan', 'Ha Noi', 'khanh.tn91@gmail.com', 6332539774);
INSERT INTO customer.customers VALUES ('Trinh Hoang Van', '846 Hang Luoc', 'Quan 5', 'Vinh', 'van.th614@gmail.com', 7362807915);
INSERT INTO customer.customers VALUES ('Luong Thi Lam', '70 Nguyen Sieu', 'Cau Giay', 'Vung Tau', 'lam.lt497@gmail.com', 1183902221);
INSERT INTO customer.customers VALUES ('Ngo Khanh Trinh', '373 Quan Thanh', 'Son Tra', 'Hue', 'trinh.nk65@gmail.com', 4759426862);
INSERT INTO customer.customers VALUES ('Nguyen Thi Trinh', '77 Ton Duc Thang', 'Ba Dinh', 'Ha Nam', 'trinh.nt948@gmail.com', 5709198273);
INSERT INTO customer.customers VALUES ('Tran Manh Khoa', '367 Hang Tre', 'Ngo Quyen', 'Quy Nhon', 'khoa.tm587@gmail.com', 6397275715);
INSERT INTO customer.customers VALUES ('Duong Thi Xuan', '361 Tran Hung Dao', 'Phu Nhuan', 'Vinh', 'xuan.dt653@gmail.com', 7268159451);
INSERT INTO customer.customers VALUES ('Dau Thi Tuyet', '121 Hung Vuong', 'Thanh Khe', 'Quy Nhon', 'tuyet.dt412@gmail.com', 7941352701);
INSERT INTO customer.customers VALUES ('Luong Thi Lam', '203 Ly Nam De', 'Ba Dinh', 'Quang Tri', 'lam.lt283@gmail.com', 4321959456);
INSERT INTO customer.customers VALUES ('Hoang Nam Xuan', '788 Hang Gai', 'Thanh Khe', 'Ha Tinh', 'xuan.hn924@gmail.com', 6668522544);
INSERT INTO customer.customers VALUES ('Do Tuan Thuy', '415 Tran Quoc Toan', 'Ha Dong', 'Nha Trang', 'thuy.dt199@gmail.com', 8147148207);
INSERT INTO customer.customers VALUES ('Quach Kieu Hung', '140 Le Ngoc Han', 'Hai Ba Trung', 'Bac Ninh', 'hung.qk584@gmail.com', 7404165190);
INSERT INTO customer.customers VALUES ('Tran Manh Quynh', '206 Nguyen Sieu', 'Hai Chau', 'Nam Dinh', 'quynh.tm518@gmail.com', 8640557423);
INSERT INTO customer.customers VALUES ('Duong Hai Khoa', '598 Hoang Cau', 'Dong Da', 'Hai Phong', 'khoa.dh959@gmail.com', 9235140776);
INSERT INTO customer.customers VALUES ('Ta Minh Huong', '832 Ton Duc Thang', 'Tay Ho', 'Da Lat', 'huong.tm730@gmail.com', 1370386938);
INSERT INTO customer.customers VALUES ('Vo Thanh Hung', '81 Le Duan', 'Quan 5', 'Binh Dinh', 'hung.vt228@gmail.com', 9947668207);
INSERT INTO customer.customers VALUES ('Quach Nam Lam', '574 Hung Vuong', 'Son Tra', 'Nam Dinh', 'lam.qn670@gmail.com', 5961996896);
INSERT INTO customer.customers VALUES ('Dang Chi Khoa', '958 O Cho Dua', 'Phu Nhuan', 'Kon Tum', 'khoa.dc979@gmail.com', 2243667894);
INSERT INTO customer.customers VALUES ('Ho Hoang Ha', '373 Kim Ma', 'Binh Thanh', 'Nha Trang', 'ha.hh703@gmail.com', 8645152919);
INSERT INTO customer.customers VALUES ('Luong Manh Hoa', '827 Hang Bong', 'Ha Dong', 'Nam Dinh', 'hoa.lm814@gmail.com', 4784846991);
INSERT INTO customer.customers VALUES ('Duong Minh Tien', '152 Nguyen Xi', 'Nam Tu Liem', 'Binh Thuan', 'tien.dm984@gmail.com', 6913247139);
INSERT INTO customer.customers VALUES ('Phan Tuan Tien', '929 Hang Mam', 'Quan 2', 'Quang Ngai', 'tien.pt415@gmail.com', 8626700811);
INSERT INTO customer.customers VALUES ('Ta Nam Phuong', '380 Hang Can', 'Binh Thanh', 'Vung Tau', 'phuong.tn744@gmail.com', 7002466284);
INSERT INTO customer.customers VALUES ('Dang Minh Hoa', '158 Hang Bo', 'Ba Dinh', 'Bac Ninh', 'hoa.dm427@gmail.com', 9884689080);
INSERT INTO customer.customers VALUES ('Pham Thi Minh', '424 Le Duan', 'Quan 4', 'Ha Tinh', 'minh.pt666@gmail.com', 7312650733);
INSERT INTO customer.customers VALUES ('Huynh Khanh Nhi', '49 Ly Nam De', 'Quan 2', 'Nha Trang', 'nhi.hk278@gmail.com', 6785290509);
INSERT INTO customer.customers VALUES ('Le Minh Cuong', '827 Tran Dai Nghia', 'Quan 5', 'Quang Tri', 'cuong.lm178@gmail.com', 4215948929);
INSERT INTO customer.customers VALUES ('Diep Thanh Sang', '738 Le Duan', 'Quan 1', 'Ha Nam', 'sang.dt446@gmail.com', 4470880065);
INSERT INTO customer.customers VALUES ('Tran Thanh Ha', '411 Le Thanh Ton', 'Cau Giay', 'Ha Nam', 'ha.tt241@gmail.com', 3683846009);
INSERT INTO customer.customers VALUES ('Luong Chi Van', '659 Le Ngoc Han', 'Thanh Xuan', 'Ha Tinh', 'van.lc837@gmail.com', 7056742634);
INSERT INTO customer.customers VALUES ('Do Khanh Ly', '507 Nguyen Xi', 'Tay Ho', 'Dak Lak', 'ly.dk265@gmail.com', 5147772091);
INSERT INTO customer.customers VALUES ('Le Chi Giang', '113 Ho Tung Mau', 'Dong Da', 'Da Lat', 'giang.lc469@gmail.com', 9183550605);
INSERT INTO customer.customers VALUES ('Ly Hai Trang', '136 Hang Bong', 'Long Bien', 'Yen Bai', 'trang.lh240@gmail.com', 9881000516);
INSERT INTO customer.customers VALUES ('Do Khanh Cuong', '319 Hang Luoc', 'Binh Thanh', 'Nam Dinh', 'cuong.dk947@gmail.com', 3906039290);
INSERT INTO customer.customers VALUES ('Dau Ngoc Anh', '618 O Cho Dua', 'Long Bien', 'Gia Lai', 'anh.dn571@gmail.com', 5467305531);
INSERT INTO customer.customers VALUES ('Vu Tuan Khanh', '85 Lan Ong', 'Son Tra', 'Quang Ninh', 'khanh.vt217@gmail.com', 2568451920);
INSERT INTO customer.customers VALUES ('Ho Thi Tien', '179 Hung Vuong', 'Quan 4', 'Quang Ngai', 'tien.ht24@gmail.com', 2331825217);
INSERT INTO customer.customers VALUES ('Ta Thanh Ngan', '563 Thuoc Bac', 'Ba Dinh', 'Nam Dinh', 'ngan.tt409@gmail.com', 1609605454);
INSERT INTO customer.customers VALUES ('Huynh Kieu Ngan', '506 Tran Hung Dao', 'Son Tra', 'Nha Trang', 'ngan.hk640@gmail.com', 9072488196);
INSERT INTO customer.customers VALUES ('Do Ngoc Ha', '449 Hoang Cau', 'Cam Le', 'Hue', 'ha.dn645@gmail.com', 7460742656);
INSERT INTO customer.customers VALUES ('Ta Tuan Trang', '366 Phung Hung', 'Quan 2', 'Da Nang', 'trang.tt823@gmail.com', 2542769896);
INSERT INTO customer.customers VALUES ('Phan Hai Linh', '296 Ton Duc Thang', 'Le Chan', 'Kon Tum', 'linh.ph945@gmail.com', 1472125548);
INSERT INTO customer.customers VALUES ('Duong Minh Thao', '583 Quan Thanh', 'Hoan Kiem', 'Hai Phong', 'thao.dm897@gmail.com', 4360849584);
INSERT INTO customer.customers VALUES ('Huynh Minh Lan', '122 Hang Bo', 'Ba Dinh', 'Ha Tinh', 'lan.hm699@gmail.com', 5369346712);
INSERT INTO customer.customers VALUES ('Quach Kieu Xuan', '84 Tran Quoc Toan', 'Son Tra', 'Ninh Thuan', 'xuan.qk520@gmail.com', 3847095085);
INSERT INTO customer.customers VALUES ('Huynh Tuan Sang', '748 Hang Non', 'Quan 4', 'Vinh', 'sang.ht389@gmail.com', 5758871885);
INSERT INTO customer.customers VALUES ('Ta Nam Huong', '834 Giang Vo', 'Nam Tu Liem', 'Phu Yen', 'huong.tn17@gmail.com', 4976414068);
INSERT INTO customer.customers VALUES ('Duong Ngoc Khanh', '893 Ly Thuong Kiet', 'Quan 4', 'Khanh Hoa', 'khanh.dn781@gmail.com', 7316296184);
INSERT INTO customer.customers VALUES ('Diep Minh Tien', '677 Nguyen Sieu', 'Ngo Quyen', 'Ha Nam', 'tien.dm597@gmail.com', 2770098775);
INSERT INTO customer.customers VALUES ('Hoang Thanh Thao', '40 Ho Tung Mau', 'Le Chan', 'Hai Phong', 'thao.ht707@gmail.com', 9250387066);
INSERT INTO customer.customers VALUES ('Duong Thi Huy', '771 Kim Ma', 'Quan 3', 'Quy Nhon', 'huy.dt317@gmail.com', 9411461783);
INSERT INTO customer.customers VALUES ('Quach Hai Nhung', '997 Tran Phu', 'Dong Da', 'Vung Tau', 'nhung.qh210@gmail.com', 2175730844);
INSERT INTO customer.customers VALUES ('Ta Chi Ly', '817 Hang Mam', 'Bac Tu Liem', 'Nam Dinh', 'ly.tc493@gmail.com', 2509624833);
INSERT INTO customer.customers VALUES ('Vo Nam Khanh', '583 Thuoc Bac', 'Ha Dong', 'Thai Nguyen', 'khanh.vn485@gmail.com', 2453750156);
INSERT INTO customer.customers VALUES ('Huynh Hai Lam', '735 Nguyen Xi', 'Bac Tu Liem', 'Thai Nguyen', 'lam.hh43@gmail.com', 4787480081);
INSERT INTO customer.customers VALUES ('Nguyen Minh Giang', '116 Le Thanh Ton', 'Ba Dinh', 'Yen Bai', 'giang.nm446@gmail.com', 4929064467);
INSERT INTO customer.customers VALUES ('Ta Thanh Quynh', '577 Hang Luoc', 'Hai Ba Trung', 'Can Tho', 'quynh.tt686@gmail.com', 4509154113);
INSERT INTO customer.customers VALUES ('Ho Nam Sang', '196 Giang Vo', 'Hai Ba Trung', 'Thai Nguyen', 'sang.hn415@gmail.com', 5282166232);
INSERT INTO customer.customers VALUES ('Trinh Thi Tien', '721 Nguyen Trai', 'Son Tra', 'Binh Thuan', 'tien.tt418@gmail.com', 7463143597);
INSERT INTO customer.customers VALUES ('Diep Hoang Hai', '58 Giang Vo', 'Long Bien', 'Hue', 'hai.dh900@gmail.com', 6511132670);
INSERT INTO customer.customers VALUES ('Ngo Manh Van', '562 Xuan Thuy', 'Binh Thanh', 'Binh Dinh', 'van.nm964@gmail.com', 2063842376);
INSERT INTO customer.customers VALUES ('Do Tuan Tien', '785 Le Thanh Ton', 'Dong Da', 'Da Lat', 'tien.dt998@gmail.com', 5362586900);
INSERT INTO customer.customers VALUES ('Do Minh Nga', '387 Ba Trieu', 'Quan 5', 'Ha Nam', 'nga.dm679@gmail.com', 4200000652);
INSERT INTO customer.customers VALUES ('Do Manh Hoa', '352 Hang Voi', 'Phu Nhuan', 'Vinh', 'hoa.dm572@gmail.com', 4758199833);
INSERT INTO customer.customers VALUES ('Bui Kieu Linh', '893 Pham Hong Thai', 'Thanh Khe', 'Bac Ninh', 'linh.bk226@gmail.com', 1815032049);
INSERT INTO customer.customers VALUES ('Ly Thi Ngoc', '50 Hang Bong', 'Ha Dong', 'Nha Trang', 'ngoc.lt904@gmail.com', 3370306899);
INSERT INTO customer.customers VALUES ('Vu Khanh Trang', '324 Hang Tre', 'Ha Dong', 'Ha Noi', 'trang.vk495@gmail.com', 5816455498);
INSERT INTO customer.customers VALUES ('Ta Hoang Khoa', '924 Nguyen Sieu', 'Binh Thanh', 'Nam Dinh', 'khoa.th88@gmail.com', 1274082037);
INSERT INTO customer.customers VALUES ('Vo Ngoc Xuan', '728 Tran Dai Nghia', 'Ngo Quyen', 'Binh Thuan', 'xuan.vn351@gmail.com', 9572082568);
INSERT INTO customer.customers VALUES ('Nguyen Tuan Duc', '778 Hang Da', 'Hai Chau', 'Binh Dinh', 'duc.nt326@gmail.com', 4665672277);
INSERT INTO customer.customers VALUES ('Duong Minh Huy', '34 Quan Thanh', 'Hong Bang', 'Kon Tum', 'huy.dm586@gmail.com', 7248770772);
INSERT INTO customer.customers VALUES ('Do Tuan Van', '993 Ngo Quyen', 'Cam Le', 'Quang Tri', 'van.dt678@gmail.com', 3019293455);
INSERT INTO customer.customers VALUES ('Ngo Thi Van', '468 Ba Trieu', 'Ba Dinh', 'Vinh', 'van.nt734@gmail.com', 9453533542);
INSERT INTO customer.customers VALUES ('Ngo Khanh Phuong', '417 Giang Vo', 'Ba Dinh', 'Binh Thuan', 'phuong.nk763@gmail.com', 9148880833);
INSERT INTO customer.customers VALUES ('Dau Khanh Thao', '542 Tran Dai Nghia', 'Le Chan', 'Nha Trang', 'thao.dk59@gmail.com', 8249786628);
INSERT INTO customer.customers VALUES ('Vo Kieu Nam', '76 Ly Nam De', 'Binh Thanh', 'Da Nang', 'nam.vk227@gmail.com', 2744602650);
INSERT INTO customer.customers VALUES ('Duong Khanh Nga', '323 Hang Non', 'Quan 3', 'Thai Nguyen', 'nga.dk464@gmail.com', 7144019809);
INSERT INTO customer.customers VALUES ('Dinh Thanh Huy', '975 Ngo Quyen', 'Quan 3', 'Hai Phong', 'huy.dt876@gmail.com', 4294948678);
INSERT INTO customer.customers VALUES ('Huynh Thi Huong', '692 Hang Da', 'Long Bien', 'Quang Ninh', 'huong.ht860@gmail.com', 4963322253);
INSERT INTO customer.customers VALUES ('Duong Ngoc Thuy', '192 Hang Da', 'Thanh Xuan', 'Bien Hoa', 'thuy.dn881@gmail.com', 9888928431);
INSERT INTO customer.customers VALUES ('Do Ngoc Minh', '97 Xuan Thuy', 'Thanh Xuan', 'Bac Ninh', 'minh.dn602@gmail.com', 9627946401);
INSERT INTO customer.customers VALUES ('Ho Hai Nga', '413 Thuoc Bac', 'Ha Dong', 'Phu Yen', 'nga.hh608@gmail.com', 9358836665);
INSERT INTO customer.customers VALUES ('Trinh Manh Nga', '446 Phan Chu Trinh', 'Nam Tu Liem', 'Ha Nam', 'nga.tm100@gmail.com', 9990967867);
INSERT INTO customer.customers VALUES ('Do Thanh Huyen', '982 Hang Can', 'Thanh Khe', 'Nam Dinh', 'huyen.dt803@gmail.com', 6478927680);
INSERT INTO customer.customers VALUES ('Huynh Khanh Nhi', '536 Phan Chu Trinh', 'Hoan Kiem', 'Phu Tho', 'nhi.hk180@gmail.com', 9485147165);
INSERT INTO customer.customers VALUES ('Le Nam Giang', '569 Ly Thuong Kiet', 'Quan 4', 'Thai Nguyen', 'giang.ln519@gmail.com', 7730616927);
INSERT INTO customer.customers VALUES ('Quach Ngoc Khanh', '82 Ngo Quyen', 'Dong Da', 'Thai Nguyen', 'khanh.qn557@gmail.com', 3203878114);
INSERT INTO customer.customers VALUES ('Huynh Manh Loan', '847 Ba Trieu', 'Binh Thanh', 'Vung Tau', 'loan.hm671@gmail.com', 8460738566);
INSERT INTO customer.customers VALUES ('Ly Kieu Khanh', '442 Hang Non', 'Thanh Xuan', 'Thai Nguyen', 'khanh.lk158@gmail.com', 7447373030);
INSERT INTO customer.customers VALUES ('Dang Manh Nhi', '201 Quan Thanh', 'Quan 2', 'Quy Nhon', 'nhi.dm939@gmail.com', 4100007945);
INSERT INTO customer.customers VALUES ('Do Thi Phuong', '464 Hang Luoc', 'Ha Dong', 'Da Lat', 'phuong.dt426@gmail.com', 2604138125);
INSERT INTO customer.customers VALUES ('Tran Tuan Loan', '53 Ba Trieu', 'Nam Tu Liem', 'Da Nang', 'loan.tt406@gmail.com', 9710686514);
INSERT INTO customer.customers VALUES ('Dau Ngoc Van', '492 Hang Da', 'Ba Dinh', 'Da Nang', 'van.dn366@gmail.com', 6869928110);
INSERT INTO customer.customers VALUES ('Nguyen Minh Tuyet', '23 Hang Non', 'Quan 3', 'Ha Noi', 'tuyet.nm736@gmail.com', 6040045297);
INSERT INTO customer.customers VALUES ('Hoang Tuan Van', '304 O Cho Dua', 'Son Tra', 'Ha Nam', 'van.ht743@gmail.com', 6824421791);
INSERT INTO customer.customers VALUES ('Ta Minh Nhung', '286 Ton Duc Thang', 'Dong Da', 'Da Lat', 'nhung.tm992@gmail.com', 4232295176);
INSERT INTO customer.customers VALUES ('Luong Manh Duc', '871 Hang Chieu', 'Binh Thanh', 'Ha Tinh', 'duc.lm393@gmail.com', 3957503806);
INSERT INTO customer.customers VALUES ('Duong Manh Van', '745 Hang Ma', 'Thanh Khe', 'Da Nang', 'van.dm712@gmail.com', 9928241274);
INSERT INTO customer.customers VALUES ('Duong Khanh Tuyet', '712 Hang Bo', 'Quan 4', 'Binh Dinh', 'tuyet.dk1@gmail.com', 3025266301);
INSERT INTO customer.customers VALUES ('Huynh Minh Anh', '715 Phan Chu Trinh', 'Long Bien', 'Vinh', 'anh.hm688@gmail.com', 8455202199);
INSERT INTO customer.customers VALUES ('Huynh Hoang Thao', '58 Ton Duc Thang', 'Nam Tu Liem', 'Gia Lai', 'thao.hh426@gmail.com', 7827062426);
INSERT INTO customer.customers VALUES ('Bui Thanh Ngoc', '251 Luong Dinh Cua', 'Quan 2', 'Hai Phong', 'ngoc.bt205@gmail.com', 8008486021);
INSERT INTO customer.customers VALUES ('Vu Thanh Thao', '450 Nguyen Xi', 'Tay Ho', 'Hue', 'thao.vt718@gmail.com', 5947628717);
INSERT INTO customer.customers VALUES ('Huynh Nam Thuy', '758 Nguyen Xi', 'Quan 3', 'Gia Lai', 'thuy.hn148@gmail.com', 3442253450);
INSERT INTO customer.customers VALUES ('Tran Nam Long', '567 Hang Ca', 'Thanh Xuan', 'Ninh Thuan', 'long.tn162@gmail.com', 2929795124);
INSERT INTO customer.customers VALUES ('Duong Thi My', '988 Tran Dai Nghia', 'Hong Bang', 'Binh Thuan', 'my.dt885@gmail.com', 2673554517);
INSERT INTO customer.customers VALUES ('Ta Tuan Tien', '159 Nguyen Sieu', 'Nam Tu Liem', 'Binh Thuan', 'tien.tt592@gmail.com', 3124850776);
INSERT INTO customer.customers VALUES ('Tran Khanh Ly', '16 Lan Ong', 'Cam Le', 'Phu Tho', 'ly.tk1000@gmail.com', 6948797178);
INSERT INTO customer.customers VALUES ('Dau Nam Huyen', '636 Hung Vuong', 'Long Bien', 'Gia Lai', 'huyen.dn190@gmail.com', 5547758849);
INSERT INTO customer.customers VALUES ('Tran Nam Quynh', '621 Phan Dinh Phung', 'Quan 5', 'Yen Bai', 'quynh.tn669@gmail.com', 3051362517);
INSERT INTO customer.customers VALUES ('Trinh Thi Thanh', '220 Phung Hung', 'Hai Chau', 'Kon Tum', 'thanh.tt560@gmail.com', 6721353674);
INSERT INTO customer.customers VALUES ('Tran Manh Linh', '351 Xuan Thuy', 'Ngo Quyen', 'Hue', 'linh.tm985@gmail.com', 1088217202);
INSERT INTO customer.customers VALUES ('Ngo Manh Thao', '918 Nguyen Sieu', 'Hong Bang', 'Binh Thuan', 'thao.nm640@gmail.com', 7336876325);
INSERT INTO customer.customers VALUES ('Quach Manh Hai', '496 Hang Ngang', 'Ba Dinh', 'Kon Tum', 'hai.qm792@gmail.com', 7715990931);
INSERT INTO customer.customers VALUES ('Do Thi Trang', '570 Ba Trieu', 'Bac Tu Liem', 'Quy Nhon', 'trang.dt130@gmail.com', 5711341449);
INSERT INTO customer.customers VALUES ('Dang Thi Huong', '806 Hang Non', 'Thanh Khe', 'Quang Ngai', 'huong.dt137@gmail.com', 3180205061);
INSERT INTO customer.customers VALUES ('Huynh Hoang Huy', '567 Nguyen Sieu', 'Phu Nhuan', 'Ha Noi', 'huy.hh698@gmail.com', 7625240535);
INSERT INTO customer.customers VALUES ('Pham Thanh Anh', '643 O Cho Dua', 'Hoang Mai', 'Nha Trang', 'anh.pt94@gmail.com', 8922361759);
INSERT INTO customer.customers VALUES ('Duong Hai Duc', '983 Hang Dao', 'Hoang Mai', 'Binh Thuan', 'duc.dh561@gmail.com', 4460484329);
INSERT INTO customer.customers VALUES ('Duong Hai Anh', '63 Hung Vuong', 'Hai Chau', 'Binh Thuan', 'anh.dh257@gmail.com', 9463339095);
INSERT INTO customer.customers VALUES ('Trinh Ngoc Thanh', '806 Luong Van Can', 'Hong Bang', 'Ha Tinh', 'thanh.tn439@gmail.com', 2518778940);
INSERT INTO customer.customers VALUES ('Quach Chi Minh', '421 Quan Thanh', 'Cam Le', 'Vinh', 'minh.qc58@gmail.com', 7778406022);
INSERT INTO customer.customers VALUES ('Huynh Khanh Anh', '892 Xuan Thuy', 'Le Chan', 'Kon Tum', 'anh.hk24@gmail.com', 2791767081);
INSERT INTO customer.customers VALUES ('Bui Thanh Tien', '398 Hang Can', 'Le Chan', 'Nha Trang', 'tien.bt871@gmail.com', 4804407207);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: employee; Owner: postgres
--

INSERT INTO employee.employees VALUES (1, 'Cao Thi Thu', '816 Hang Luoc', 'Quan 4', 'Quang Ngai', 'Thu.CaoThi71@gmail.com', 2683227771, false, NULL, 'Manager', 'CaoThu', '$2a$06$HLwranV5F/TalByNrIIoQuUZStOBv8L6TqDsuvE95nlfJzQz6MBS2', 7514115);
INSERT INTO employee.employees VALUES (73, 'Pham Minh Tu', '95 Giang Vo', 'Hai Chau', 'Nha Trang', 'Tu.PhamMinh9@gmail.com', 8264567909, false, NULL, 'Cashier', 'PhamTu', '$2a$06$JByafakHhiYgbSjEnPhP4OpkDr.XERaOgvQj0Q.YVxH6YyFTZB/3O', 6349218);
INSERT INTO employee.employees VALUES (74, 'Dau Khanh Long', '945 Hang Dao', 'Hong Bang', 'Hai Phong', 'Long.DauKhanh27@gmail.com', 9150226727, false, NULL, 'Cashier', 'DauLong', '$2a$06$SiEvMHFCFMhMIytXzoBx2.dklDLI6naxme6qNN7TqGFF02tUQktm.', 4579977);
INSERT INTO employee.employees VALUES (108, 'Phan Manh Anh', '589 Pham Ngu Lao', 'Quan 4', 'Quang Nam', 'Anh.PhanManh9@gmail.com', 3481771509, false, NULL, 'Cashier', 'PhanAnh', '$2a$06$S.rGM1MkGmnQdFa9qSg0P.cb4DHbcXCKeBTEJCZY0EesaJavuJXcm', 5144214);
INSERT INTO employee.employees VALUES (109, 'Doan Hai Tien', '279 Hung Vuong', 'Hoan Kiem', 'Can Tho', 'Tien.DoanHai50@gmail.com', 6903258650, false, NULL, 'Cashier', 'DoanTien', '$2a$06$UtY.0ogwbXGfAc0nWbZmv.G2NbyRpZvkuZFkt0jIFFUkCrb5UnAlG', 6221225);
INSERT INTO employee.employees VALUES (110, 'Duong Khanh Thanh', '262 Ly Thuong Kiet', 'Cam Le', 'Nam Dinh', 'Thanh.DuongKhanh23@gmail.com', 1051358123, false, NULL, 'Cashier', 'DuongThanh', '$2a$06$0kpR.6XxYxnLcYQ4kswnqekKvpGM.w.W39CkJnyIAgEIMQhqhfvWm', 6462674);
INSERT INTO employee.employees VALUES (111, 'Vu Khanh Thanh', '45 Hang Dao', 'Tay Ho', 'Ha Nam', 'Thanh.VuKhanh58@gmail.com', 7239348158, false, NULL, 'Cashier', 'VuThanh', '$2a$06$p4zDalomBYZP9Asfx9ghWuBGc.MgIRmtvPAlAfSo3LR2yRWB9QRLW', 4810165);
INSERT INTO employee.employees VALUES (112, 'Ly Thanh Linh', '298 Quan Thanh', 'Hong Bang', 'Vung Tau', 'Linh.LyThanh44@gmail.com', 1835595844, false, NULL, 'Cashier', 'LyLinh', '$2a$06$A9DF8aJrXztGWDBfvT.VNuzpbgWWmMghZ4PJPFWpEUWSfoWxTfGvm', 5770379);
INSERT INTO employee.employees VALUES (113, 'Dang Tuan Hiep', '419 Giang Vo', 'Ngo Quyen', 'Hai Phong', 'Hiep.DangTuan55@gmail.com', 9933202755, false, NULL, 'Cashier', 'DangHiep', '$2a$06$FxMzODgAhH3ORk5Vy2kBJODcOLr529Ks8y3mHt0B9VDC/q7WcyC1G', 5997074);
INSERT INTO employee.employees VALUES (114, 'Vu Thi An', '693 Hang Tre', 'Phu Nhuan', 'Bien Hoa', 'An.VuThi39@gmail.com', 7893525139, false, NULL, 'Cashier', 'VuAn', '$2a$06$WMTpFy2unN8bKCzPXwJfUu8xomACJkMflOq17D86XRduzsaLOQ6R.', 4882981);
INSERT INTO employee.employees VALUES (115, 'Phan Tuan Mai', '687 Hang Voi', 'Phu Nhuan', 'Thai Nguyen', 'Mai.PhanTuan50@gmail.com', 2684900750, false, NULL, 'Cashier', 'PhanMai', '$2a$06$6QkBciH4zYBPiV/8km4ZfuHMVr89bMTI6gGiVmQBqoQe5R.FMq7WK', 6475044);
INSERT INTO employee.employees VALUES (116, 'Vo Chi Giang', '520 Hang Ma', 'Nam Tu Liem', 'Phu Tho', 'Giang.VoChi58@gmail.com', 4667872058, false, NULL, 'Inventory Clerk', 'VoGiang', '$2a$06$.xyYKVjWFQ/mu8XtRd6DxuaU4fO6r5Z4NcmjgHWt5lqQMDvtnEg/S', 6933608);
INSERT INTO employee.employees VALUES (117, 'Vo Khanh Duc', '62 Thuoc Bac', 'Nam Tu Liem', 'Dak Lak', 'Duc.VoKhanh10@gmail.com', 1187551510, false, NULL, 'Inventory Clerk', 'VoDuc', '$2a$06$sAMVqdGoRr0i2pertKnv2uD3aXOoFFvTzr6nn4PG82jwpSZFc65wu', 4391040);
INSERT INTO employee.employees VALUES (118, 'Duong Tuan Linh', '201 Hang Bo', 'Hoan Kiem', 'Ha Tinh', 'Linh.DuongTuan10@gmail.com', 7332148710, false, NULL, 'Inventory Clerk', 'DuongLinh', '$2a$06$u662rO8.sQ0Tng4q4h2VXuHE23k.nnsQMLtnmSFxPZ8z9tQ.9c20a', 4926657);
INSERT INTO employee.employees VALUES (119, 'Ly Van Thao', '81 Ton Duc Thang', 'Cau Giay', 'Quang Nam', 'Thao.LyVan78@gmail.com', 9377602878, false, NULL, 'Inventory Clerk', 'LyThao', '$2a$06$XEIb8jMoQRrUYcch3IZTuekcZWygQGK4RYpERkS5eMBEmAtNx3d7q', 4365337);
INSERT INTO employee.employees VALUES (120, 'Tran Tuan Bang', '457 Hang Bo', 'Hong Bang', 'Da Lat', 'Bang.TranTuan67@gmail.com', 7769694867, false, NULL, 'Inventory Clerk', 'TranBang', '$2a$06$CFeNiaGGdoaLTT5easGm6OVV8E50.AGmw9WmP0.b8uKfTo2tPhV2q', 6638488);
INSERT INTO employee.employees VALUES (121, 'Le Tuan Quynh', '988 Hang Luoc', 'Nam Tu Liem', 'Ha Nam', 'Quynh.LeTuan30@gmail.com', 5868478530, false, NULL, 'Inventory Clerk', 'LeQuynh', '$2a$06$ZzgtnvlAyAQdO0IAnEzsyehPeFJsNyxk4Sb7bZqb7vev/l22yTsFa', 5226896);
INSERT INTO employee.employees VALUES (122, 'Hoang Minh Chien', '173 Hoang Cau', 'Quan 4', 'Ha Nam', 'Chien.HoangMinh81@gmail.com', 4435036581, false, NULL, 'Inventory Clerk', 'HoangChien', '$2a$06$ztrALZnjXYsH29IH6hPPzOLBdnWSHBUfRYotnvYaXCLeEvxDAmvOi', 5215621);
INSERT INTO employee.employees VALUES (123, 'Quach Manh Hai', '941 Thuoc Bac', 'Binh Thanh', 'Ninh Thuan', 'Hai.QuachManh96@gmail.com', 7647685996, false, NULL, 'Inventory Clerk', 'QuachHai', '$2a$06$QJATBpSQtKle4N5RDnk2AOebfW3mVkt/Qyk83rl9MtmDvRg9lXNjy', 5800028);
INSERT INTO employee.employees VALUES (124, 'Trinh Ngoc Huong', '296 Hang Dao', 'Thanh Khe', 'Da Nang', 'Huong.TrinhNgoc68@gmail.com', 5430638268, false, NULL, 'Inventory Clerk', 'TrinhHuong', '$2a$06$qmOj2FRiwhrWTLGRt1Eneu/mNG0Xwmvw4cSqx72Vx8v7gT0c1Ofpu', 5484650);
INSERT INTO employee.employees VALUES (125, 'Pham Thanh Chien', '361 Luong Dinh Cua', 'Quan 2', 'Phu Yen', 'Chien.PhamThanh75@gmail.com', 7644321075, false, NULL, 'Inventory Clerk', 'PhamChien', '$2a$06$LE4nRpYFT89WFB3vXgLxd.sBHG3AxhskiAol/7zNiTn3RcIT3qvai', 5606177);
INSERT INTO employee.employees VALUES (126, 'Duong Van Nga', '25 Le Loi', 'Hai Chau', 'Quy Nhon', 'Nga.DuongVan49@gmail.com', 1722776149, false, NULL, 'Inventory Clerk', 'DuongNga', '$2a$06$SdX.GYVcrE5m/g.lNtXwUOyWyBtC3UvEH1LLj.cwiclz53UzPl3Oi', 4802878);
INSERT INTO employee.employees VALUES (127, 'Tieu Thanh Lan', '716 Hang Chieu', 'Binh Thanh', 'Dak Lak', 'Lan.TieuThanh9@gmail.com', 6951045509, false, NULL, 'Inventory Clerk', 'TieuLan', '$2a$06$tAF4N.0T7Ygwn9hjYDlI3ufYiUdnzgqBpcd.tMTJxE.0q6vJZx4Zy', 6574599);
INSERT INTO employee.employees VALUES (128, 'Vo Chi Nhi', '157 Hang Mam', 'Cau Giay', 'Gia Lai', 'Nhi.VoChi99@gmail.com', 7873610899, false, NULL, 'Inventory Clerk', 'VoNhi', '$2a$06$3CLBzyFwgbD/MK1RQyy0mO3PzK0s06IyT2HaVYBRP7ebCv167Y1aS', 6491610);
INSERT INTO employee.employees VALUES (129, 'Dau Ngoc Ly', '744 Ba Trieu', 'Hai Ba Trung', 'Nha Trang', 'Ly.DauNgoc3@gmail.com', 2898865803, false, NULL, 'Inventory Clerk', 'DauLy', '$2a$06$8bRDRaC71naEMcZIT.klo.b/GuU0nkMs7lEg21KbOixIgtf4VqNAi', 5452725);
INSERT INTO employee.employees VALUES (130, 'Tieu Tuan Duc', '847 Hang Ngang', 'Hai Ba Trung', 'Kon Tum', 'Duc.TieuTuan8@gmail.com', 8138564508, false, NULL, 'Inventory Clerk', 'TieuDuc', '$2a$06$g.EdMFmvKbc8cPBM84HStut5BcbeaznC9Vcbzz2/sR7t71LTiW1kq', 4675770);
INSERT INTO employee.employees VALUES (131, 'Luong Nam Huong', '918 Hang Khay', 'Hoang Mai', 'Da Lat', 'Huong.LuongNam82@gmail.com', 1991066582, false, NULL, 'Inventory Clerk', 'LuongHuong', '$2a$06$wT581XNy0JgbQJYhkXMOJe1m7.0jRmZJGS/hsG7YAzNpQ6F5dbs86', 6636074);
INSERT INTO employee.employees VALUES (132, 'Doan Nam Hiep', '144 Luong Van Can', 'Quan 2', 'Ha Nam', 'Hiep.DoanNam66@gmail.com', 5513435966, false, NULL, 'Inventory Clerk', 'DoanHiep', '$2a$06$5QkH/lVKsZSll/L/7yGsreFHMfbkmjWrIjLhQeGzN8rCXivFXy7Q.', 5081351);
INSERT INTO employee.employees VALUES (133, 'Bui Khanh My', '752 Hang Voi', 'Hong Bang', 'Can Tho', 'My.BuiKhanh38@gmail.com', 1265924938, false, NULL, 'Inventory Clerk', 'BuiMy', '$2a$06$MCXGvvSJHAUJ4LSw3Mg1z.CBZPdTiWu14dZKdOAIv1f87mNRPFMj.', 4126496);
INSERT INTO employee.employees VALUES (134, 'Do Hai Ngoc', '428 Thuoc Bac', 'Long Bien', 'Quang Ninh', 'Ngoc.DoHai35@gmail.com', 8318519735, false, NULL, 'Inventory Clerk', 'DoNgoc', '$2a$06$rsM74.j7xSfLzvLw3qgDmOVI4QhAJQzPsY19uD8c98z4OHB.i9LYC', 4357305);
INSERT INTO employee.employees VALUES (135, 'Doan Hoang Linh', '738 Le Loi', 'Ha Dong', 'Gia Lai', 'Linh.DoanHoang29@gmail.com', 4137243229, false, NULL, 'Inventory Clerk', 'DoanLinh', '$2a$06$E./3TpFyeFtWthoHeXwiXu8o6KEKQOtpCzLcTQHQ.ZZQpPlNbku4a', 4817309);
INSERT INTO employee.employees VALUES (136, 'Duong Ngoc Ngoc', '993 Le Ngoc Han', 'Quan 3', 'Ha Noi', 'Ngoc.DuongNgoc25@gmail.com', 5455121225, false, NULL, 'Inventory Clerk', 'DuongNgoc', '$2a$06$BE9e/VSiK5YUe.Pu/cfkQumQQJqehoDRv7Uf3i41qnAuJ93lJtan2', 4388116);
INSERT INTO employee.employees VALUES (137, 'Ho Tuan Tien', '252 Hang Non', 'Long Bien', 'Quang Nam', 'Tien.HoTuan77@gmail.com', 5371235377, false, NULL, 'Inventory Clerk', 'HoTien', '$2a$06$kORSE3vFoLa2OCmqLQsZa.lTUOSlbo8BllnjNu65VTknJ7x/Mcye.', 4918778);
INSERT INTO employee.employees VALUES (138, 'Quach Thanh Phuong', '475 Hoang Quoc Viet', 'Thanh Khe', 'Da Lat', 'Phuong.QuachThanh38@gmail.com', 9806948138, false, NULL, 'Inventory Clerk', 'QuachPhuong', '$2a$06$LPkjHcHxnymKk3S5iR7WB.RA9x6pHADnC85Gv767rAyhd/r/DpGcG', 4435036);
INSERT INTO employee.employees VALUES (2, 'Cao Khanh Giang', '646 Hung Vuong', 'Long Bien', 'Da Nang', 'Giang.CaoKhanh5@gmail.com', 2321305505, false, NULL, 'Manager', 'CaoGiang', '$2a$06$Fkef6Ydlvr6TyHronOjaUuDuzZMA2aoLNyEhjrf3kDE.DI/m3ZARq', 7632058);
INSERT INTO employee.employees VALUES (139, 'Vo Thi Nhung', '409 Hang Can', 'Hoang Mai', 'Phu Yen', 'Nhung.VoThi44@gmail.com', 8287712444, false, NULL, 'Inventory Clerk', 'VoNhung', '$2a$06$7AuE.SiMcTUGamxwKlg9seQ/QNVkNgQBQptU318jz.ofiweKbCE5a', 6708497);
INSERT INTO employee.employees VALUES (140, 'Diep Minh Loan', '658 Ngo Quyen', 'Tay Ho', 'Ho Chi Minh', 'Loan.DiepMinh37@gmail.com', 2805713937, false, NULL, 'Inventory Clerk', 'DiepLoan', '$2a$06$Bvjdcy37hatueqMjh3mrle7ADuFwm03md5xSRlpV03gxGKjphWuFO', 5566523);
INSERT INTO employee.employees VALUES (141, 'Ngo Van Ha', '997 Phan Chu Trinh', 'Cau Giay', 'Ninh Thuan', 'Ha.NgoVan74@gmail.com', 2473259774, false, NULL, 'Inventory Clerk', 'NgoHa', '$2a$06$bK4WmPZvkBmkveBIIpkVxu6Ecz9oZmPO/NEv06S7LtwwQi4Ee9klW', 4311690);
INSERT INTO employee.employees VALUES (142, 'Doan Minh Phuong', '702 Kim Ma', 'Binh Thanh', 'Ha Nam', 'Phuong.DoanMinh14@gmail.com', 2022889914, false, NULL, 'Inventory Clerk', 'DoanPhuong', '$2a$06$OCn9qVD0/wEIGWiJItHUEuzD95SN2TJRfVzMSI7Ou4Fr.FT3aPy0W', 5550573);
INSERT INTO employee.employees VALUES (143, 'Luong Nam Mai', '873 Hung Vuong', 'Bac Tu Liem', 'Da Nang', 'Mai.LuongNam97@gmail.com', 1479460597, false, NULL, 'Inventory Clerk', 'LuongMai', '$2a$06$Me4DaFby3RyOoFt2ahIuDuTuNMf0wW9N2D0hw1Cx.LpqQWS8T1WeG', 4075681);
INSERT INTO employee.employees VALUES (144, 'Luong Nam Minh', '736 Tran Quoc Toan', 'Hoang Mai', 'Khanh Hoa', 'Minh.LuongNam3@gmail.com', 8377477203, false, NULL, 'Inventory Clerk', 'LuongMinh', '$2a$06$AcmCMvwwvOFdTd1BE0YqsO6ebYdXOUwEVzmL.5KKFDaF0962wMQ52', 5329618);
INSERT INTO employee.employees VALUES (145, 'Trinh Chi My', '300 O Cho Dua', 'Quan 5', 'Binh Dinh', 'My.TrinhChi75@gmail.com', 2126593275, false, NULL, 'Inventory Clerk', 'TrinhMy', '$2a$06$elQ8L1EHeKbIISNiVvaCSeNyELIJKu1TtYY4ui8CwY2vf/JcMtlFi', 4774232);
INSERT INTO employee.employees VALUES (146, 'Cao Manh Duc', '752 Hang Khay', 'Hoan Kiem', 'Hai Phong', 'Duc.CaoManh74@gmail.com', 1879820474, false, NULL, 'Inventory Clerk', 'CaoDuc', '$2a$06$4KZbhSuXUmWB.SeBRZQ40.06W7v20ilEHtrRDnpTUu/J9YPKgrk0.', 6023342);
INSERT INTO employee.employees VALUES (147, 'Ho Thanh Long', '145 Lan Ong', 'Hai Ba Trung', 'Kon Tum', 'Long.HoThanh32@gmail.com', 5367225332, false, NULL, 'Inventory Clerk', 'HoLong', '$2a$06$sH3e0RsHLK8psrq/aC8qmeQbUeqIBDL6MMDXLHE35UpX64BdaaN5S', 4514033);
INSERT INTO employee.employees VALUES (148, 'Luu Tuan Tuyen', '114 Hang Gai', 'Thanh Xuan', 'Nha Trang', 'Tuyen.LuuTuan96@gmail.com', 2756589596, false, NULL, 'Inventory Clerk', 'LuuTuyen', '$2a$06$LLNGL3P1Xb.jt9ytBR7Uy.pJjwzGDXQqyOVln6sOK8s6rQ08VUyHm', 6694122);
INSERT INTO employee.employees VALUES (149, 'Ngo Hai Sang', '720 Phung Hung', 'Cau Giay', 'Da Nang', 'Sang.NgoHai22@gmail.com', 1311767722, false, NULL, 'Inventory Clerk', 'NgoSang', '$2a$06$q7P3KhCTzZu55j8o2eiyKO40kXo6EetXp9gkKVoVD4J5tX4vHYDYG', 6059560);
INSERT INTO employee.employees VALUES (150, 'Quach Hoang Ngoc', '136 Hang Ngang', 'Quan 4', 'Da Nang', 'Ngoc.QuachHoang29@gmail.com', 5109264329, false, NULL, 'Inventory Clerk', 'QuachNgoc', '$2a$06$QbwPbJHUS2Ss7mLjyVHhLueuu5ChidglkADf6a8YG7mhj4KfEE51e', 6895721);
INSERT INTO employee.employees VALUES (151, 'Duong Hoang Ha', '367 Hang Khay', 'Long Bien', 'Binh Thuan', 'Ha.DuongHoang44@gmail.com', 3302832144, false, NULL, 'Inventory Clerk', 'DuongHa', '$2a$06$TeVTa5VbI7iRtxkoMGQ2WO59tVwRtxLBaZwvixQH2VV.grFQB.fL6', 5384107);
INSERT INTO employee.employees VALUES (152, 'Luu Minh Trinh', '576 Hang Dao', 'Hong Bang', 'Nha Trang', 'Trinh.LuuMinh8@gmail.com', 9597891308, false, NULL, 'Inventory Clerk', 'LuuTrinh', '$2a$06$NdHL6w1gE0KZlbrXKN2Sb.IpxiuzwMa3.YcWfgokTl3o0139o0Yoe', 6285543);
INSERT INTO employee.employees VALUES (153, 'Huynh Thanh Mai', '910 Ton Duc Thang', 'Cam Le', 'Da Nang', 'Mai.HuynhThanh10@gmail.com', 5458777510, false, NULL, 'Inventory Clerk', 'HuynhMai', '$2a$06$seksOeGqBA9RJ8yla977Z.tpGpdwECTJvJYGLQ.pRzinss3kEqqVm', 6557638);
INSERT INTO employee.employees VALUES (154, 'Vo Minh Hiep', '338 Tran Dai Nghia', 'Quan 5', 'Quang Nam', 'Hiep.VoMinh14@gmail.com', 7961051714, false, NULL, 'Inventory Clerk', 'VoHiep', '$2a$06$T71jPirHzMJ3Wc6i2J4K.ulpfAsBbxVxcTOVWjTsDN/L11GACmTPS', 6032829);
INSERT INTO employee.employees VALUES (155, 'Vo Hai Linh', '459 Hoang Quoc Viet', 'Quan 2', 'Ha Nam', 'Linh.VoHai79@gmail.com', 2011186479, false, NULL, 'Inventory Clerk', 'VoLinh', '$2a$06$QnK694kvO14FggjRNfiw9eYzgstbhPlNaN2D/d9uKTwWxs9wfVorO', 6374777);
INSERT INTO employee.employees VALUES (156, 'Cao Minh Van', '628 Phan Chu Trinh', 'Thanh Khe', 'Vung Tau', 'Van.CaoMinh74@gmail.com', 4490497574, false, NULL, 'Inventory Clerk', 'CaoVan', '$2a$06$SS8m/.m0e92FiQTXKShfrOdy6IGdNtpQAWfwQt5JA6Qif/VFjmepq', 6496920);
INSERT INTO employee.employees VALUES (157, 'Dinh Thi Linh', '570 Tran Phu', 'Ha Dong', 'Vung Tau', 'Linh.DinhThi98@gmail.com', 2082554298, false, NULL, 'Inventory Clerk', 'DinhLinh', '$2a$06$oZ.OSnPMonf8zQj20XLQ0.epO9SRZ99AuydqhP4HjUS7kWwTADqfu', 5766673);
INSERT INTO employee.employees VALUES (158, 'Vu Tuan Tuyen', '482 Pham Hong Thai', 'Ba Dinh', 'Phu Tho', 'Tuyen.VuTuan6@gmail.com', 4666720106, false, NULL, 'Inventory Clerk', 'VuTuyen', '$2a$06$o0dNP5mukp571ryrjbzWUu2BDztsPhWINvJiG4oTlYLO1wKRV.yU2', 4052382);
INSERT INTO employee.employees VALUES (159, 'Ngo Thi Hung', '209 Ba Trieu', 'Quan 3', 'Can Tho', 'Hung.NgoThi21@gmail.com', 3215856721, false, NULL, 'Inventory Clerk', 'NgoHung', '$2a$06$sSmIrwdzpw.OXNoUQY8qcuGGrFsfqaI0Fd7qWAWTKv1c.2QU/Rqyi', 6987988);
INSERT INTO employee.employees VALUES (160, 'Duong Nam Nhung', '867 Hang Voi', 'Ngo Quyen', 'Yen Bai', 'Nhung.DuongNam49@gmail.com', 2574438949, false, NULL, 'Inventory Clerk', 'DuongNhung', '$2a$06$Pgrfd1prg3rRi5J2Rey.aOOqT.8Z9sAljdvOKKHYRfNx1fs/qcEVO', 5489558);
INSERT INTO employee.employees VALUES (161, 'Duong Khanh Sang', '400 Hoang Quoc Viet', 'Hai Chau', 'Ninh Thuan', 'Sang.DuongKhanh21@gmail.com', 5325898121, false, NULL, 'Inventory Clerk', 'DuongSang', '$2a$06$hsDI/otj7H0MrrVafl6fw.3mDp5xH7NGKHCDJ.nnOzmSUzsuQm1lm', 6323541);
INSERT INTO employee.employees VALUES (162, 'Vu Nam Hiep', '838 Kim Ma', 'Binh Thanh', 'Quy Nhon', 'Hiep.VuNam5@gmail.com', 9663524205, false, NULL, 'Inventory Clerk', 'VuHiep', '$2a$06$ht2lkkv4FeHNz4Fzmx76Ver69fsYPEjFU3xO6gYn9lqRG5wHc9O6u', 6779735);
INSERT INTO employee.employees VALUES (163, 'Phan Nam Tien', '142 Hang Tre', 'Ha Dong', 'Can Tho', 'Tien.PhanNam42@gmail.com', 2601282142, false, NULL, 'Inventory Clerk', 'PhanTien', '$2a$06$gn5QtRsJ4L4bLVUldbxuhu2tCxLzhG20YfwRlcVqRsxku7oKj9rpu', 6573665);
INSERT INTO employee.employees VALUES (164, 'Do Manh Trinh', '770 Hang Tre', 'Quan 3', 'Ho Chi Minh', 'Trinh.DoManh68@gmail.com', 1981923368, false, NULL, 'Inventory Clerk', 'DoTrinh', '$2a$06$ZqmhkCrDzahoPhBdu8NUe.YCLc/3ujWzlhtodHh/DuQjY4co5eGZ6', 4966033);
INSERT INTO employee.employees VALUES (165, 'Pham Thi Mai', '136 Ly Nam De', 'Hoang Mai', 'Quang Binh', 'Mai.PhamThi24@gmail.com', 4366775224, false, NULL, 'Inventory Clerk', 'PhamMai', '$2a$06$dP4XhyULF3I8b77pyKNdnuIEIY41FBD6k5gvSm/T1rC/o.LyNVhZW', 4441753);
INSERT INTO employee.employees VALUES (166, 'Tran Manh Lam', '617 Hung Vuong', 'Quan 4', 'Khanh Hoa', 'Lam.TranManh74@gmail.com', 2654254474, false, NULL, 'Inventory Clerk', 'TranLam', '$2a$06$uy4OYS/GUDcMSxsHrHENXeiIYjH6vXVdWZe5slHMqOVTg2yo7yxOK', 6171908);
INSERT INTO employee.employees VALUES (167, 'Nguyen Thi Nhi', '637 Hang Non', 'Hoang Mai', 'Phu Tho', 'Nhi.NguyenThi27@gmail.com', 4297022727, false, NULL, 'Inventory Clerk', 'NguyenNhi', '$2a$06$Ys06y09BS4.UokOxa1AAy.V9tz0np2pMGB83QtunYEGfs1qifD1kO', 6912932);
INSERT INTO employee.employees VALUES (168, 'Le Thi Linh', '10 Hoang Cau', 'Quan 4', 'Phu Tho', 'Linh.LeThi78@gmail.com', 3558362278, false, NULL, 'Inventory Clerk', 'LeLinh', '$2a$06$2Pe1mvcpV3gJMRiMdWCPUuq8oJGKlf.k58zrHgaw7xrQefzNE7wVG', 4136787);
INSERT INTO employee.employees VALUES (169, 'Diep Tuan Xuan', '193 Xuan Thuy', 'Phu Nhuan', 'Hue', 'Xuan.DiepTuan35@gmail.com', 5098780635, false, NULL, 'Inventory Clerk', 'DiepXuan', '$2a$06$1qQ99QGM83iLXQ6wXxYu5e6BZ.7z5Moa5xKqoua/FO3ABABS/6IVm', 4303491);
INSERT INTO employee.employees VALUES (170, 'Ho Van Trang', '136 Hang Bong', 'Ha Dong', 'Gia Lai', 'Trang.HoVan71@gmail.com', 7166869171, false, NULL, 'Inventory Clerk', 'HoTrang', '$2a$06$hMpMEocvDxgJH0yv3IdR2.CQvjbbeaNpgEzQXGY3JhnrAg/xNoMvK', 4266295);
INSERT INTO employee.employees VALUES (171, 'Tran Thanh Trang', '959 Hang Chieu', 'Tay Ho', 'Quang Ngai', 'Trang.TranThanh77@gmail.com', 3424154577, false, NULL, 'Inventory Clerk', 'TranTrang', '$2a$06$ajgR5moFmpxc.yGRo4jw/uSqXexn.OW8YqqRL66wi9WZITa/s.8sS', 6947319);
INSERT INTO employee.employees VALUES (172, 'Ta Ngoc Ha', '608 Ton Duc Thang', 'Binh Thanh', 'Hue', 'Ha.TaNgoc85@gmail.com', 6782531285, false, NULL, 'Inventory Clerk', 'TaHa', '$2a$06$Nxse3/wEZbfANDLDX72wtuWO8ZwaXwvGm1n1dqjIpgUl90jfM/Ddq', 6347307);
INSERT INTO employee.employees VALUES (173, 'Tieu Tuan Dong', '76 Ly Thuong Kiet', 'Quan 3', 'Quang Nam', 'Dong.TieuTuan16@gmail.com', 6968955616, false, NULL, 'Inventory Clerk', 'TieuDong', '$2a$06$qYToPkxufEIY2i6nGixvf.42WLzqduAnWKg0TxK5SPTqwtSWc/w8O', 6922295);
INSERT INTO employee.employees VALUES (174, 'Dang Hai Giang', '788 Phung Hung', 'Hoan Kiem', 'Thua Thien Hue', 'Giang.DangHai8@gmail.com', 6573495408, false, NULL, 'Inventory Clerk', 'DangGiang', '$2a$06$4DmuSK4SHXAIk/O7Uc7VLOBRNML/1RugG09NGBcJXxObJ6gzzT2Bm', 6842977);
INSERT INTO employee.employees VALUES (175, 'Tran Van Nhung', '574 Hoang Quoc Viet', 'Quan 5', 'Dak Lak', 'Nhung.TranVan24@gmail.com', 5620436724, false, NULL, 'Inventory Clerk', 'TranNhung', '$2a$06$v5qcOw638omOdl9UL/xxCe5YLiSeqsjkzc29/tHGY9jr116ZM/W7q', 6289623);
INSERT INTO employee.employees VALUES (176, 'Ngo Chi Nhung', '626 Hang Ma', 'Ha Dong', 'Phu Yen', 'Nhung.NgoChi7@gmail.com', 7217567907, false, NULL, 'Inventory Clerk', 'NgoNhung', '$2a$06$1t1v9mDOw8Dk6.wPYrMsUug0urYq.7ts6t3JHZxBRia8NihtDJLFy', 6967458);
INSERT INTO employee.employees VALUES (177, 'Cao Ngoc Dong', '104 Nguyen Trai', 'Hai Ba Trung', 'Da Lat', 'Dong.CaoNgoc24@gmail.com', 9112577824, false, NULL, 'Inventory Clerk', 'CaoDong', '$2a$06$NIQKUXCm18WECuni96rOnewjYcmXrhbzNuQiQWzt5TnQAV4OANpVu', 4241085);
INSERT INTO employee.employees VALUES (178, 'Tong Nam Anh', '365 Hang Ma', 'Quan 4', 'Ninh Thuan', 'Anh.TongNam55@gmail.com', 2564401355, false, NULL, 'Inventory Clerk', 'TongAnh', '$2a$06$kHvxWK43rl.3gaJzUOyB4u7C2fiFLG.sIlXmxe3b1cwOE5DAaJ3rm', 6597829);
INSERT INTO employee.employees VALUES (179, 'Cao Nam Loan', '754 Hung Vuong', 'Quan 1', 'Quang Nam', 'Loan.CaoNam85@gmail.com', 3169722585, false, NULL, 'Inventory Clerk', 'CaoLoan', '$2a$06$/AcGFjynCJHM3ucgCLbZQOioe65r4sfLh3gD2IQEJlaFX6ogj84bS', 4324262);
INSERT INTO employee.employees VALUES (180, 'Duong Chi Tuyen', '767 Lan Ong', 'Quan 4', 'Da Nang', 'Tuyen.DuongChi35@gmail.com', 3790796635, false, NULL, 'Inventory Clerk', 'DuongTuyen', '$2a$06$/fz4pFD1Aeho3YClbnGBsu9o1y4uTiABPHDgH337XYqxkVvYSWiF.', 5650067);
INSERT INTO employee.employees VALUES (181, 'Ho Thanh Van', '874 Hang Tre', 'Quan 2', 'Vung Tau', 'Van.HoThanh38@gmail.com', 2835789838, false, NULL, 'Inventory Clerk', 'HoVan', '$2a$06$8CsW4mJVGA6qyVgqD8.jx.g0paIEBcma1yPHUTEWdAvtBtEirfxxS', 6809665);
INSERT INTO employee.employees VALUES (182, 'Huynh Khanh Linh', '950 Le Ngoc Han', 'Long Bien', 'Yen Bai', 'Linh.HuynhKhanh5@gmail.com', 3784595105, false, NULL, 'Inventory Clerk', 'HuynhLinh', '$2a$06$iq9xCsUbvMIj45JsS4koY.cE.aF8VhovE7HogXT6I5YVfh9Rj9zYm', 4176609);
INSERT INTO employee.employees VALUES (183, 'Phan Thi Lam', '197 Ho Tung Mau', 'Quan 2', 'Quang Binh', 'Lam.PhanThi39@gmail.com', 8561769639, false, NULL, 'Inventory Clerk', 'PhanLam', '$2a$06$wa6HQgLTCllw.U906Az3oOBTrPiukZ/7iSLkpa16/n3ZoRejCViKG', 5018652);
INSERT INTO employee.employees VALUES (184, 'Trinh Hai Ngan', '586 Phung Hung', 'Ba Dinh', 'Quang Ngai', 'Ngan.TrinhHai48@gmail.com', 7523865248, false, NULL, 'Inventory Clerk', 'TrinhNgan', '$2a$06$6H5zHIcntHyOUaqi3kjWquFEqaieuBG2ImFgzZ8v8ZM47nMI6DaKK', 5218308);
INSERT INTO employee.employees VALUES (185, 'Dau Thanh An', '887 Pham Hong Thai', 'Quan 5', 'Bien Hoa', 'An.DauThanh16@gmail.com', 1216983116, false, NULL, 'Inventory Clerk', 'DauAn', '$2a$06$qBDtamcb0WqmX4DGQq8uNu.XhPotzk8AgmK1usVnsE/eZfyDdaAc.', 6897505);
INSERT INTO employee.employees VALUES (186, 'Nguyen Hai Dong', '71 Hoang Quoc Viet', 'Thanh Khe', 'Khanh Hoa', 'Dong.NguyenHai56@gmail.com', 6809734056, false, NULL, 'Inventory Clerk', 'NguyenDong', '$2a$06$UyveZviHS2tu9FOn7A9C2.9gpvMkQAi2IOauUlu3zqqHPQej.RAiO', 5799453);
INSERT INTO employee.employees VALUES (187, 'Duong Khanh Hiep', '276 Hang Chieu', 'Quan 4', 'Da Nang', 'Hiep.DuongKhanh93@gmail.com', 7945927493, false, NULL, 'Inventory Clerk', 'DuongHiep', '$2a$06$0MNZ5XmvgDd1cdkuammMxevnhtpJ46NX0BetUbLaU04H1xo2UWrNa', 4801747);
INSERT INTO employee.employees VALUES (188, 'Dinh Ngoc Chien', '272 Hang Dao', 'Le Chan', 'Quang Ngai', 'Chien.DinhNgoc84@gmail.com', 7608283584, false, NULL, 'Inventory Clerk', 'DinhChien', '$2a$06$PuDvxFYPfK2UUlh8WTOyGOpvcTAok9ZJkV2tAE9hOOpF1x1ykP6M2', 6033493);
INSERT INTO employee.employees VALUES (189, 'Dinh Chi Trinh', '243 Lan Ong', 'Ba Dinh', 'Da Nang', 'Trinh.DinhChi32@gmail.com', 7938284432, false, NULL, 'Inventory Clerk', 'DinhTrinh', '$2a$06$/4RJF2232Ek5dM16UElw0Ob/RDhMRdiLZArlS/wz8mwe9QpBlnm5C', 6223945);
INSERT INTO employee.employees VALUES (190, 'Duong Hoang Mai', '90 Lan Ong', 'Quan 3', 'Binh Dinh', 'Mai.DuongHoang86@gmail.com', 4256860686, false, NULL, 'Inventory Clerk', 'DuongMai', '$2a$06$XFhCV3U1dwKo79VHU8b//e/TQ54Ug7X2mV01qalwIxg10r3wXtUy.', 5935872);
INSERT INTO employee.employees VALUES (191, 'Nguyen Kieu Khoa', '154 Luong Van Can', 'Tay Ho', 'Nha Trang', 'Khoa.NguyenKieu64@gmail.com', 7596972864, false, NULL, 'Inventory Clerk', 'NguyenKhoa', '$2a$06$bLAvfVg3FeruYEaOsVg9beVWnBvQsYOw01pjeR93Hq1KFiQzkmWQ6', 4297251);
INSERT INTO employee.employees VALUES (192, 'Ngo Kieu Thuy', '70 Hang Dao', 'Long Bien', 'Hai Phong', 'Thuy.NgoKieu18@gmail.com', 2078304418, false, NULL, 'Inventory Clerk', 'NgoThuy', '$2a$06$wEuFzpOz4qBFUWo0329tteqUkAJbw/tNds1njBmPnirKtCJBG5Srm', 4709639);
INSERT INTO employee.employees VALUES (193, 'Vu Manh Ngan', '230 Hang Luoc', 'Thanh Xuan', 'Dak Lak', 'Ngan.VuManh82@gmail.com', 3609435582, false, NULL, 'Inventory Clerk', 'VuNgan', '$2a$06$ikBUcS7p8aqgLp41aLNqke.1G59wWgh13zvn/vGlcOtZQMPNuobAq', 5158425);
INSERT INTO employee.employees VALUES (194, 'Diep Minh Lan', '282 Le Loi', 'Le Chan', 'Thua Thien Hue', 'Lan.DiepMinh48@gmail.com', 2530760448, false, NULL, 'Inventory Clerk', 'DiepLan', '$2a$06$R/pnkF5rQ3uyBtj3ZzTMKuf/FPtVasej2s27Z2lo1wCxHFatFCTeC', 5647450);
INSERT INTO employee.employees VALUES (195, 'Ho Khanh Dong', '284 Le Loi', 'Quan 2', 'Vung Tau', 'Dong.HoKhanh49@gmail.com', 6517048349, false, NULL, 'Inventory Clerk', 'HoDong', '$2a$06$LBpi/FwtMhQ2hSa9sxssdOu99i2jQg7HYeO2wv66140ZzHgQvI.pK', 4243835);
INSERT INTO employee.employees VALUES (196, 'Ly Minh Ngan', '932 Hang Tre', 'Quan 3', 'Da Lat', 'Ngan.LyMinh32@gmail.com', 3305804732, false, NULL, 'Inventory Clerk', 'LyNgan', '$2a$06$RYp9AOTeb8VF/Etb70Ntme8feHPlukjhYSWmLI9KUOpL7iP6GyxJK', 4682379);
INSERT INTO employee.employees VALUES (197, 'Duong Hai Van', '192 Phan Chu Trinh', 'Nam Tu Liem', 'Quy Nhon', 'Van.DuongHai64@gmail.com', 8788546264, false, NULL, 'Inventory Clerk', 'DuongVan', '$2a$06$GJPHFvAcSDm0a4XtGdYrOO7nZVAvhlBxKT6Typ8LAnsZxEjDIndda', 6033767);
INSERT INTO employee.employees VALUES (198, 'Dau Kieu Trang', '543 Nguyen Xi', 'Quan 4', 'Da Nang', 'Trang.DauKieu71@gmail.com', 6875195271, false, NULL, 'Inventory Clerk', 'DauTrang', '$2a$06$GWkmjfR2vY2vxxLiKpgVieOfpxtgZOeqQwYbS3QVHNbuUQsG8AOTO', 6346119);
INSERT INTO employee.employees VALUES (199, 'Dinh Khanh Thao', '522 Hoang Quoc Viet', 'Cam Le', 'Phu Yen', 'Thao.DinhKhanh31@gmail.com', 5162513231, false, NULL, 'Inventory Clerk', 'DinhThao', '$2a$06$WvufPMfj7lvDzVJ3x5WLV.2CWD7er3VxZN4kF2XSLUv3NGR4Kg/aW', 6385634);
INSERT INTO employee.employees VALUES (200, 'Lac Chi My', '368 Ton Duc Thang', 'Bac Tu Liem', 'Can Tho', 'My.LacChi18@gmail.com', 9767997118, false, NULL, 'Inventory Clerk', 'LacMy', '$2a$06$rEdQh4988RVpPNntCNehBO74zeFMAhO0Z0t0DVbQ2wkPaBhJJcW7K', 6760730);
INSERT INTO employee.employees VALUES (201, 'Le Tuan Van', '962 Hang Dao', 'Bac Tu Liem', 'Phu Yen', 'Van.LeTuan78@gmail.com', 5359299478, false, NULL, 'Inventory Clerk', 'LeVan', '$2a$06$maI85VTdHLQ4EJZgz3ZQl.hlbHmNiAg.od0ODmth2dq7gXvS5mLWW', 5031848);
INSERT INTO employee.employees VALUES (202, 'Tong Ngoc Nga', '590 Hung Vuong', 'Hoang Mai', 'Da Lat', 'Nga.TongNgoc40@gmail.com', 2966687440, false, NULL, 'Inventory Clerk', 'TongNga', '$2a$06$o5I.S1LaeOCo7xdy5slFVegCSACd9sAvnlcjlHpZZPTXOMgKYoCR2', 5187113);
INSERT INTO employee.employees VALUES (203, 'Hoang Minh Hoa', '426 Luong Dinh Cua', 'Ngo Quyen', 'Da Nang', 'Hoa.HoangMinh34@gmail.com', 6353013934, false, NULL, 'Inventory Clerk', 'HoangHoa', '$2a$06$umH9m1E0Nm8S49MCVq8UjOJcVDDKJneNhGarge9vF/769zn6iwXZW', 5410270);
INSERT INTO employee.employees VALUES (204, 'Vo Hai Minh', '870 Lan Ong', 'Phu Nhuan', 'Thua Thien Hue', 'Minh.VoHai49@gmail.com', 3281749349, false, NULL, 'Inventory Clerk', 'VoMinh', '$2a$06$0HKovDGkzzQ4YzMBE9JcMudDbQf8zqQH49pce4Y3In1d6tUGYDobG', 5160289);
INSERT INTO employee.employees VALUES (205, 'Huynh Hai Dong', '393 Hang Luoc', 'Hoang Mai', 'Da Nang', 'Dong.HuynhHai13@gmail.com', 4807689413, false, NULL, 'Shop Assistant', 'HuynhDong', '$2a$06$hwrhJn78ks7MM0Ya.F0XDOgj1DEDhqYQGeWqCkyC2UVr2Kz1xTbxC', 5068617);
INSERT INTO employee.employees VALUES (206, 'Bui Thi Ngan', '495 Hang Chieu', 'Cam Le', 'Binh Thuan', 'Ngan.BuiThi76@gmail.com', 3196397476, false, NULL, 'Shop Assistant', 'BuiNgan', '$2a$06$XD52czC3wXDeW8Zip0uN9OHlFTtrgFYl8eLU13APNkUQx3EnoI1oi', 4091996);
INSERT INTO employee.employees VALUES (207, 'Dau Hoang Hung', '911 Hang Dao', 'Long Bien', 'Ha Noi', 'Hung.DauHoang42@gmail.com', 4334605942, false, NULL, 'Shop Assistant', 'DauHung', '$2a$06$0EEIvlhNhTnx2wsYNa5hNOGGOTBX1ucNha7Pyt/.k5qVXmNRehBdu', 5854377);
INSERT INTO employee.employees VALUES (208, 'Tieu Kieu Anh', '851 Hang Voi', 'Ngo Quyen', 'Gia Lai', 'Anh.TieuKieu25@gmail.com', 9913701925, false, NULL, 'Shop Assistant', 'TieuAnh', '$2a$06$ACCRIQFO0RoBHn741jdJb.IhN2t6EtVaMB6qFJPI4deUBbzcPD3hW', 5841137);
INSERT INTO employee.employees VALUES (209, 'Vo Manh Cuong', '180 Ngo Quyen', 'Phu Nhuan', 'Vung Tau', 'Cuong.VoManh54@gmail.com', 3812786354, false, NULL, 'Shop Assistant', 'VoCuong', '$2a$06$avXUuK5kj/LSS/LrXpuZ2e6.7371hCZENXeyLg1raOc1uugERwOYm', 4074596);
INSERT INTO employee.employees VALUES (3, 'Phan Manh Sang', '859 Nguyen Sieu', 'Quan 5', 'Bien Hoa', 'Sang.PhanManh9@gmail.com', 2141231309, false, NULL, 'Manager', 'PhanSang', '$2a$06$sU2KjmLdN46m6zXpWvZIfuS.3fWM1n1AbfFcXOPNIYRDiyZTySWQi', 7175781);
INSERT INTO employee.employees VALUES (4, 'Le Ngoc Hoa', '145 Xuan Thuy', 'Phu Nhuan', 'Da Nang', 'Hoa.LeNgoc72@gmail.com', 4653900872, false, NULL, 'Manager', 'LeHoa', '$2a$06$C5vt5NfuHHwotJwAKGdfSOWsTq.8KfW6k.8zGhNjc9gLl0O/61ynm', 8537065);
INSERT INTO employee.employees VALUES (5, 'Luu Tuan My', '286 Phung Hung', 'Bac Tu Liem', 'Bien Hoa', 'My.LuuTuan23@gmail.com', 9393795123, false, NULL, 'Manager', 'LuuMy', '$2a$06$UfsCjfouVwOAFAIRryaSIuJ8tvFaEZBIuoes6qdRYO3ng5bcDtNp2', 8673147);
INSERT INTO employee.employees VALUES (210, 'Tieu Chi My', '798 Hoang Cau', 'Hong Bang', 'Ha Tinh', 'My.TieuChi30@gmail.com', 7907087830, false, NULL, 'Shop Assistant', 'TieuMy', '$2a$06$mesLhSOdwC0Z4E61SpF7muwbj6gtCsOKbRfZxSouNk7DdNhR4nha.', 4269637);
INSERT INTO employee.employees VALUES (211, 'Diep Manh Tien', '70 Phan Chu Trinh', 'Cam Le', 'Da Nang', 'Tien.DiepManh40@gmail.com', 2245250840, false, NULL, 'Shop Assistant', 'DiepTien', '$2a$06$amNy8t89g0z34R0okw3GceJvch2wRar10D8FjoC6ZBfvp2pTl37Zq', 5490980);
INSERT INTO employee.employees VALUES (212, 'Quach Khanh Minh', '446 Phan Chu Trinh', 'Long Bien', 'Khanh Hoa', 'Minh.QuachKhanh3@gmail.com', 9770430703, false, NULL, 'Shop Assistant', 'QuachMinh', '$2a$06$UXtq/SDtgN2h5q2asSejTuhFJHJH9VVYnaCM/H24/TGXU4vrwwu2q', 5891843);
INSERT INTO employee.employees VALUES (213, 'Diep Minh Van', '945 Nguyen Trai', 'Quan 4', 'Bac Ninh', 'Van.DiepMinh4@gmail.com', 7738847304, false, NULL, 'Shop Assistant', 'DiepVan', '$2a$06$kMj9hqzEKFidKPO7w0KODexGCu8rb1.MizjM9f34ReJZ4mHnMXJmG', 6316928);
INSERT INTO employee.employees VALUES (214, 'Ly Ngoc Nga', '457 Hang Gai', 'Quan 3', 'Quang Binh', 'Nga.LyNgoc35@gmail.com', 6813144935, false, NULL, 'Shop Assistant', 'LyNga', '$2a$06$GNqANL9XZeqksU.5Q3QS5e1lvGcJphGfSOgoHyhG3GIp4DEWqAaHy', 6497111);
INSERT INTO employee.employees VALUES (215, 'Ngo Khanh Minh', '678 Hang Mam', 'Quan 2', 'Binh Thuan', 'Minh.NgoKhanh43@gmail.com', 9886534143, false, NULL, 'Shop Assistant', 'NgoMinh', '$2a$06$Edpar7tHL4/7hTYmvgVKx.Vnyzufl078m2yH6D67OmrYZBAQ8Uoxu', 5069131);
INSERT INTO employee.employees VALUES (216, 'Ta Ngoc Tu', '808 Tran Dai Nghia', 'Ba Dinh', 'Phu Yen', 'Tu.TaNgoc98@gmail.com', 1720453698, false, NULL, 'Shop Assistant', 'TaTu', '$2a$06$LtgBx2RsXp1NhtjsfcIyxe2BTubB//6xlwQIBt9z8Ri8hqnlYh0N6', 5871189);
INSERT INTO employee.employees VALUES (217, 'Tieu Hai Tien', '530 Pham Ngu Lao', 'Bac Tu Liem', 'Quang Binh', 'Tien.TieuHai35@gmail.com', 7010803235, false, NULL, 'Shop Assistant', 'TieuTien', '$2a$06$SVDwZiC3Wp5vjhpTeLh4jecOB1tjpS1nD2TpCCJ1TxUJWYIDrprZq', 4808194);
INSERT INTO employee.employees VALUES (218, 'Luong Khanh Linh', '683 Hang Ma', 'Cam Le', 'Ha Nam', 'Linh.LuongKhanh6@gmail.com', 9650175506, false, NULL, 'Shop Assistant', 'LuongLinh', '$2a$06$xPnXSLNETgp5KPQUrGTBHefEwBu/833JUL9vlvbHjOQwUxmcXkdCO', 5881650);
INSERT INTO employee.employees VALUES (219, 'Diep Hoang Linh', '707 Hang Dao', 'Long Bien', 'Yen Bai', 'Linh.DiepHoang40@gmail.com', 7737326040, false, NULL, 'Shop Assistant', 'DiepLinh', '$2a$06$dO5R1ROewKfkk0lTWmb6NuqhxnDqqZDzReLsxuRWvMhx6K8EW064O', 4950012);
INSERT INTO employee.employees VALUES (220, 'Tran Thanh An', '674 Nguyen Trai', 'Quan 2', 'Yen Bai', 'An.TranThanh48@gmail.com', 3074065248, false, NULL, 'Shop Assistant', 'TranAn', '$2a$06$Ticq/kD6SSHOfW.jYfJttulRongXUb/H0MJCiMyBvb9FdH2Dwmucq', 5781187);
INSERT INTO employee.employees VALUES (221, 'Vo Thanh Sang', '550 Hang Gai', 'Son Tra', 'Ho Chi Minh', 'Sang.VoThanh48@gmail.com', 9142385348, false, NULL, 'Shop Assistant', 'VoSang', '$2a$06$L4NWp6YQeQ4/iOmT6aXVT.IqsfwU.ytPIFE4Za14za8e2gETCYpqm', 4555929);
INSERT INTO employee.employees VALUES (222, 'Quach Ngoc Quynh', '834 Hang Bo', 'Dong Da', 'Ha Nam', 'Quynh.QuachNgoc81@gmail.com', 4636640681, false, NULL, 'Shop Assistant', 'QuachQuynh', '$2a$06$uk6nPdrMNwTFBpTS25Gn8.pGWBNt4htjlGdGu3lwXcd/spCK11QkC', 4716767);
INSERT INTO employee.employees VALUES (223, 'Vu Thi Nam', '382 Hang Khay', 'Cam Le', 'Gia Lai', 'Nam.VuThi24@gmail.com', 8147227724, false, NULL, 'Shop Assistant', 'VuNam', '$2a$06$phD/evPo4xwE2b59IVjSFu8XuXhxIiXvYZL6HbHxQ9HviNBlQOTQC', 5568042);
INSERT INTO employee.employees VALUES (224, 'Diep Minh Hai', '841 Hang Bong', 'Dong Da', 'Ho Chi Minh', 'Hai.DiepMinh7@gmail.com', 8724914107, false, NULL, 'Shop Assistant', 'DiepHai', '$2a$06$KYWwl6zZe0ntnoTGXy29x.mv5Ntodhos7fW05Q8tMwqRt5ea2Dx7m', 4465605);
INSERT INTO employee.employees VALUES (225, 'Ta Thanh Huy', '578 Hang Khay', 'Hong Bang', 'Vung Tau', 'Huy.TaThanh89@gmail.com', 2070252389, false, NULL, 'Shop Assistant', 'TaHuy', '$2a$06$7xEJuo2Fztekp3d1nLteaumImf6SwlgW9wml.zelEuUk5a7tzDBZC', 5805705);
INSERT INTO employee.employees VALUES (226, 'Dau Van Tien', '389 Tran Quoc Toan', 'Cau Giay', 'Binh Thuan', 'Tien.DauVan52@gmail.com', 6625619452, false, NULL, 'Shop Assistant', 'DauTien', '$2a$06$cO0ZJ.MV444p4LU/6PM9D.LwJGs1WuXC02qEpDb2am1vbxv0khmVC', 4505643);
INSERT INTO employee.employees VALUES (227, 'Nghiem Tuan Huong', '446 Tran Hung Dao', 'Le Chan', 'Ho Chi Minh', 'Huong.NghiemTuan92@gmail.com', 6091622692, false, NULL, 'Shop Assistant', 'NghiemHuong', '$2a$06$ZifgNWexE/2zE3tLGkGs1OLfwtAjQ5EcWOp7j5nxXolElptugyOyO', 5536241);
INSERT INTO employee.employees VALUES (228, 'Le Manh Giang', '799 Lan Ong', 'Le Chan', 'Quang Binh', 'Giang.LeManh27@gmail.com', 6694293527, false, NULL, 'Shop Assistant', 'LeGiang', '$2a$06$c.XMy0SwH5a8QtEBjT88P.Hu69H5HYPYmRG3M1JeJ8YQRm7W3cb9y', 6761532);
INSERT INTO employee.employees VALUES (229, 'Phan Hoang Bang', '630 Hung Vuong', 'Ha Dong', 'Kon Tum', 'Bang.PhanHoang19@gmail.com', 1945930319, false, NULL, 'Shop Assistant', 'PhanBang', '$2a$06$NDbbsRZ09h9QKG/Uc/mKxeIHG/y30YNcDsq0lLiLZjaTxEomkmxKO', 5701925);
INSERT INTO employee.employees VALUES (230, 'Ngo Kieu Khang', '357 Hang Mam', 'Binh Thanh', 'Thai Nguyen', 'Khang.NgoKieu65@gmail.com', 9785397565, false, NULL, 'Shop Assistant', 'NgoKhang', '$2a$06$CBdOWvGiZvW.qT/bH4CHfeZHVtiGBEZO0lJy7/sDfGhMW8sZH1t2i', 4969323);
INSERT INTO employee.employees VALUES (231, 'Nghiem Ngoc Minh', '434 Ton Duc Thang', 'Ngo Quyen', 'Thai Nguyen', 'Minh.NghiemNgoc77@gmail.com', 8088706077, false, NULL, 'Shop Assistant', 'NghiemMinh', '$2a$06$HjOBZtMFDAcCtm1rgxmy4.vijlDHWnj/bkoCMb3rh2moeYQIseA5G', 5393024);
INSERT INTO employee.employees VALUES (232, 'Tong Hoang Duc', '84 Nguyen Trai', 'Dong Da', 'Phu Tho', 'Duc.TongHoang64@gmail.com', 2776273264, false, NULL, 'Shop Assistant', 'TongDuc', '$2a$06$lpB6VLbuNeUHiuoJt0negOqiPc292Vk3p/QIkqBtZxVpMltQya1iu', 4590352);
INSERT INTO employee.employees VALUES (233, 'Dinh Kieu Lan', '625 Quan Thanh', 'Thanh Khe', 'Quang Nam', 'Lan.DinhKieu93@gmail.com', 2597182393, false, NULL, 'Shop Assistant', 'DinhLan', '$2a$06$AkxUa0dxufagjpCtLJmzYO1/RPL56jbDnAyXehZOiES2wFIJwmj.6', 5094006);
INSERT INTO employee.employees VALUES (234, 'Tran Thi Khanh', '981 Hang Can', 'Binh Thanh', 'Thai Nguyen', 'Khanh.TranThi91@gmail.com', 8540979491, false, NULL, 'Shop Assistant', 'TranKhanh', '$2a$06$HRj/3gF15utCotjiX.OF8uIqIPEG8AIUptTD7mz4Clm8U5KbVpqSS', 5412234);
INSERT INTO employee.employees VALUES (235, 'Lac Chi Nhi', '588 Le Thanh Ton', 'Ngo Quyen', 'Quy Nhon', 'Nhi.LacChi1@gmail.com', 2726910201, false, NULL, 'Shop Assistant', 'LacNhi', '$2a$06$VakVEF2/7Fyyo3s2qQrIfu6hjgntp5jU62tPRFL7VlHQT9BEllvSq', 6357839);
INSERT INTO employee.employees VALUES (236, 'Bui Manh Trinh', '222 Pham Ngu Lao', 'Le Chan', 'Ha Noi', 'Trinh.BuiManh30@gmail.com', 3612465630, false, NULL, 'Shop Assistant', 'BuiTrinh', '$2a$06$wC8tZVV4aIG1/VlEU4bm4ePMQCZ0Fly4mCXOB4RvPvrkaFeG.j1G.', 5183533);
INSERT INTO employee.employees VALUES (237, 'Nghiem Hai Loan', '466 Hang Dao', 'Thanh Khe', 'Nha Trang', 'Loan.NghiemHai83@gmail.com', 3904604883, false, NULL, 'Shop Assistant', 'NghiemLoan', '$2a$06$.CkqQY59hHBRwnE1h8rGE.PM7qd2vehjziQVTLYdvT3/5sszVbRpW', 4485899);
INSERT INTO employee.employees VALUES (238, 'Luong Hoang Ly', '735 Hang Mam', 'Quan 5', 'Binh Thuan', 'Ly.LuongHoang76@gmail.com', 5988177676, false, NULL, 'Shop Assistant', 'LuongLy', '$2a$06$kef//7k0ui3rqHxYrUrq1ObPMwM.06EwnPYTDPRA0/pW4Fvww5ybu', 5094684);
INSERT INTO employee.employees VALUES (239, 'Luu Khanh Bang', '38 Tran Dai Nghia', 'Thanh Khe', 'Quang Tri', 'Bang.LuuKhanh84@gmail.com', 4084792684, false, NULL, 'Shop Assistant', 'LuuBang', '$2a$06$.h68mYQvfb1PpY2XlsU3s.9XK1IL8zt/FCMegjBGPj9D4z1FvGDLO', 5436638);
INSERT INTO employee.employees VALUES (240, 'Doan Kieu Thao', '703 Ho Tung Mau', 'Quan 2', 'Quang Ninh', 'Thao.DoanKieu2@gmail.com', 9796262402, false, NULL, 'Shop Assistant', 'DoanThao', '$2a$06$lF.9LyHZSD2foguFLHFLw.ACN9U5uAr80eLhpkPnNNvInr7gpmeSG', 6061028);
INSERT INTO employee.employees VALUES (6, 'Hoang Ngoc Tien', '508 Lan Ong', 'Quan 4', 'Bac Ninh', 'Tien.HoangNgoc87@gmail.com', 9517086887, false, NULL, 'Manager', 'HoangTien', '$2a$06$C8oR6lPmkxK45mhMPytwDuePbH5nCzVbFnDrW56y/F7ur8H9E/P8.', 7167215);
INSERT INTO employee.employees VALUES (7, 'Dinh Thanh Huy', '566 Ho Tung Mau', 'Hoang Mai', 'Ha Tinh', 'Huy.DinhThanh43@gmail.com', 5028631243, false, NULL, 'Manager', 'DinhHuy', '$2a$06$CTbME/DDE3qrOqP6nIRdA.UEVtw64fMecZvqsC0Bi.sewsVGouSvq', 7860549);
INSERT INTO employee.employees VALUES (8, 'Doan Thanh Ha', '404 Ly Thuong Kiet', 'Quan 3', 'Phu Yen', 'Ha.DoanThanh49@gmail.com', 6777138749, false, NULL, 'Manager', 'DoanHa', '$2a$06$tKDDKmUif1Z2XeA0FTtJ3utXkqgQIxrfI2TOQq8lHlBqWr.1bG8US', 8929293);
INSERT INTO employee.employees VALUES (241, 'Hoang Hoang Huong', '479 Hang Mam', 'Quan 1', 'Quy Nhon', 'Huong.HoangHoang55@gmail.com', 2826642855, false, NULL, 'Shop Assistant', 'HoangHuong', '$2a$06$.W4WXoyKPcr434dQDCL/xOFZVkKoCjZdPkDNGQXe4Rx1oIpfMCwMe', 5442700);
INSERT INTO employee.employees VALUES (242, 'Ho Kieu Bang', '463 Hang Ngang', 'Long Bien', 'Binh Thuan', 'Bang.HoKieu95@gmail.com', 2195808595, false, NULL, 'Shop Assistant', 'HoBang', '$2a$06$YcQ6GBpwRZhG6sbarfuD9Opwzv6UTetZ3uUH4POQWHnxbocgJA4Na', 5364411);
INSERT INTO employee.employees VALUES (243, 'Phan Ngoc Nhi', '134 Hoang Quoc Viet', 'Binh Thanh', 'Binh Thuan', 'Nhi.PhanNgoc86@gmail.com', 2242767486, false, NULL, 'Shop Assistant', 'PhanNhi', '$2a$06$5gUwuuaVsIM5tD8gvzohGOvtP5XdYGfdrZ1MvMQd9ewZPTpPAOBVe', 6439002);
INSERT INTO employee.employees VALUES (244, 'Luu Tuan Tien', '446 Hang Luoc', 'Long Bien', 'Thua Thien Hue', 'Tien.LuuTuan6@gmail.com', 7847377306, false, NULL, 'Shop Assistant', 'LuuTien', '$2a$06$W.aJ2N8ifZd7BSkRNVexXuCgtQh0YZ8o0jRLJ5RJengIpRXSy5PkO', 4883844);
INSERT INTO employee.employees VALUES (245, 'Huynh Hoang Sang', '834 Hang Dao', 'Ba Dinh', 'Quy Nhon', 'Sang.HuynhHoang95@gmail.com', 1800128695, false, NULL, 'Shop Assistant', 'HuynhSang', '$2a$06$yKZP3SEJZFeRAIlf7AmNvOJTwRQFJxL.e2Rk9Ais6qgXhyOTX934O', 6253184);
INSERT INTO employee.employees VALUES (246, 'Tong Thanh Linh', '357 Hung Vuong', 'Long Bien', 'Phu Yen', 'Linh.TongThanh43@gmail.com', 1485829943, false, NULL, 'Shop Assistant', 'TongLinh', '$2a$06$htIdOxY5TtReAw9mi/2VC.kmu9Iv3y.sBTdfVsMNTsSTpTNML1wZm', 5213597);
INSERT INTO employee.employees VALUES (247, 'Ta Thanh Duc', '105 Lan Ong', 'Binh Thanh', 'Binh Dinh', 'Duc.TaThanh87@gmail.com', 5537424887, false, NULL, 'Shop Assistant', 'TaDuc', '$2a$06$aHRg0PvS1MYxKdsguzAOWe24jptEgrKmVCnA0p4jqreazkQJpWREe', 6264963);
INSERT INTO employee.employees VALUES (248, 'Do Manh Binh', '293 Ton Duc Thang', 'Hai Chau', 'Dak Lak', 'Binh.DoManh96@gmail.com', 4267215296, false, NULL, 'Shop Assistant', 'DoBinh', '$2a$06$WVIK7aoOO1DBthZmVXPgfeeBAS/6096uJ70ONEzuDGJ5VY7y1353m', 5338397);
INSERT INTO employee.employees VALUES (249, 'Nguyen Kieu Ngan', '654 Tran Hung Dao', 'Quan 4', 'Hue', 'Ngan.NguyenKieu18@gmail.com', 5048385518, false, NULL, 'Shop Assistant', 'NguyenNgan', '$2a$06$0KjIih8i7UTw.BTsaoNzZuA1Fsv.MQTU1WHK2HY8Uy1GAs0F3k./W', 5627902);
INSERT INTO employee.employees VALUES (250, 'Luong Thi Hung', '636 Tran Phu', 'Thanh Xuan', 'Ha Nam', 'Hung.LuongThi1@gmail.com', 1294771201, false, NULL, 'Shop Assistant', 'LuongHung', '$2a$06$azfd6o5EQqPO/xwG.zEb5.h.k3IZqGLBK33bppGpMaz.zi/h1iyAC', 4749495);
INSERT INTO employee.employees VALUES (251, 'Bui Van Lan', '468 Hang Ca', 'Phu Nhuan', 'Ha Noi', 'Lan.BuiVan21@gmail.com', 7684529721, false, NULL, 'Shop Assistant', 'BuiLan', '$2a$06$jTTmYH1rSor.wcEtX9zKzeWFRXaw6OjTHPQQzNUOMEJYqCxq7j.9e', 4597208);
INSERT INTO employee.employees VALUES (252, 'Luu Hai Thuy', '16 Hang Bo', 'Long Bien', 'Quang Ninh', 'Thuy.LuuHai88@gmail.com', 5345875888, false, NULL, 'Shop Assistant', 'LuuThuy', '$2a$06$VxewMZ5NTgMUBxBeAp8rV.a5GqlExdBaGA.A3beM6vRdBJtax.qZK', 5083749);
INSERT INTO employee.employees VALUES (253, 'Nguyen Tuan Thao', '564 Hang Tre', 'Thanh Xuan', 'Bac Ninh', 'Thao.NguyenTuan52@gmail.com', 6357042652, false, NULL, 'Shop Assistant', 'NguyenThao', '$2a$06$lp09xMTEod0ld797xcPN7O8I40gH8uRyqfKq0VNWlAn28z1iifL5G', 4282560);
INSERT INTO employee.employees VALUES (254, 'Diep Minh Hung', '131 Hang Chieu', 'Tay Ho', 'Thai Nguyen', 'Hung.DiepMinh59@gmail.com', 9387142459, false, NULL, 'Shop Assistant', 'DiepHung', '$2a$06$pWcvlJmqBCh.nmOmnvz9AO9iwfJDZYHeavvaCrX2JIoTkSWCaDXuW', 6982849);
INSERT INTO employee.employees VALUES (255, 'Bui Minh Tuyen', '931 Ly Nam De', 'Quan 4', 'Ha Tinh', 'Tuyen.BuiMinh15@gmail.com', 9409966515, false, NULL, 'Shop Assistant', 'BuiTuyen', '$2a$06$zlFehIFND6ahyTtbjCRQQ.YPSIOdcWhPML9kQHG2CD.sEAtLiIbpK', 5230154);
INSERT INTO employee.employees VALUES (256, 'Lac Khanh Minh', '101 Hang Bong', 'Quan 4', 'Ha Noi', 'Minh.LacKhanh17@gmail.com', 2728475017, false, NULL, 'Shop Assistant', 'LacMinh', '$2a$06$N8aC0fUwKWS2EtOBuiUOLOC/rxtxq.6DG1EI/PDQkMQrumZwYiBJ6', 5483280);
INSERT INTO employee.employees VALUES (257, 'Le Thi Anh', '441 Ly Thuong Kiet', 'Le Chan', 'Quang Binh', 'Anh.LeThi73@gmail.com', 4698382173, false, NULL, 'Shop Assistant', 'LeAnh', '$2a$06$L/BpU.wSvB4AQP/KzxdixuiUKprLg7OPiQL4NWeQ8OVrNXuEl.5Mm', 5157267);
INSERT INTO employee.employees VALUES (258, 'Nguyen Thi Huy', '198 Le Ngoc Han', 'Binh Thanh', 'Quang Tri', 'Huy.NguyenThi1@gmail.com', 7043626501, false, NULL, 'Shop Assistant', 'NguyenHuy', '$2a$06$IkKjAC/YTSvHCW.1T4tFLe/Pmg07m9o8RkDi3sWkW8LZaEOIIfWiG', 5344597);
INSERT INTO employee.employees VALUES (259, 'Do Kieu Ly', '669 Quan Thanh', 'Ngo Quyen', 'Ha Nam', 'Ly.DoKieu98@gmail.com', 7736637998, false, NULL, 'Shop Assistant', 'DoLy', '$2a$06$wqxNExtpTL/iww8DFn607ui692jj0THJxAUnIGyef.haISDXI0pOW', 4570473);
INSERT INTO employee.employees VALUES (260, 'Dinh Chi Sang', '901 Hang Da', 'Nam Tu Liem', 'Da Lat', 'Sang.DinhChi5@gmail.com', 3550130705, false, NULL, 'Shop Assistant', 'DinhSang', '$2a$06$Ju6wl8ZXLSkOhVw6ur7J..fPUNu5MdDsKhIAbFslHoHVGRa9mSVZO', 4188454);
INSERT INTO employee.employees VALUES (261, 'Ly Chi Tien', '191 Giang Vo', 'Cam Le', 'Kon Tum', 'Tien.LyChi62@gmail.com', 3177437662, false, NULL, 'Shop Assistant', 'LyTien', '$2a$06$L5VsQ0JXmElnzDDeS31z6uzrC.LwIpOBZUzSa9orJkZ7zVnlQEidG', 5608268);
INSERT INTO employee.employees VALUES (262, 'Ngo Manh Loan', '169 O Cho Dua', 'Le Chan', 'Ha Tinh', 'Loan.NgoManh30@gmail.com', 6166532630, false, NULL, 'Shop Assistant', 'NgoLoan', '$2a$06$JSBs2Su4Xn1/9HdY5ZCmjeR7DBZQ1KtdmY4BvStFHWuFvP2s3ryLe', 5817556);
INSERT INTO employee.employees VALUES (263, 'Dinh Minh Mai', '909 Hang Khay', 'Ba Dinh', 'Yen Bai', 'Mai.DinhMinh2@gmail.com', 9999118202, false, NULL, 'Shop Assistant', 'DinhMai', '$2a$06$PMlFjyRd1m7YnH0GEmNoVeuHqPScc1rHVFUZmGxGqxrxD1a9oWKHG', 4023753);
INSERT INTO employee.employees VALUES (264, 'Pham Kieu Ngoc', '640 Hang Bong', 'Quan 5', 'Nam Dinh', 'Ngoc.PhamKieu83@gmail.com', 5604287083, false, NULL, 'Shop Assistant', 'PhamNgoc', '$2a$06$m9iwYfvOBjy1ujpMO0RpSOVZrWdml/sVZkhtnlWWqI7PM63fvOOfC', 4030436);
INSERT INTO employee.employees VALUES (265, 'Ho Hai Linh', '661 Hang Chieu', 'Cam Le', 'Da Nang', 'Linh.HoHai32@gmail.com', 6436342132, false, NULL, 'Shop Assistant', 'HoLinh', '$2a$06$.SwJYBs6RVbZtZeAw6FF0ewT4zgl.BsyhaoEGdXzBLsZ5lfftN/Si', 6731747);
INSERT INTO employee.employees VALUES (266, 'Dinh Thi Nga', '573 Hang Ca', 'Binh Thanh', 'Quang Nam', 'Nga.DinhThi46@gmail.com', 7652838946, false, NULL, 'Shop Assistant', 'DinhNga', '$2a$06$HzRbdsYDZHeFVURDRzkGm.hdG5jf5uB9gm8LpWFF4mbm9xyPrtng.', 5799464);
INSERT INTO employee.employees VALUES (267, 'Trinh Khanh Lam', '640 Thuoc Bac', 'Tay Ho', 'Khanh Hoa', 'Lam.TrinhKhanh84@gmail.com', 8527739084, false, NULL, 'Shop Assistant', 'TrinhLam', '$2a$06$ZA2XmievL4E9IzjJ9V2yMOOhrKmpvCL9gJ2nMISbxxrWoriE/QYY6', 6392405);
INSERT INTO employee.employees VALUES (268, 'Ngo Hoang Lan', '34 Hung Vuong', 'Hai Chau', 'Quang Ninh', 'Lan.NgoHoang97@gmail.com', 6668596297, false, NULL, 'Shop Assistant', 'NgoLan', '$2a$06$BKb.vYWo5v.3s04l8mCKZuJ0EXES8n4pIacz74LdqmJIu3cCoJdsi', 6379461);
INSERT INTO employee.employees VALUES (269, 'Quach Minh Loan', '680 Le Thanh Ton', 'Ha Dong', 'Thua Thien Hue', 'Loan.QuachMinh81@gmail.com', 6212798881, false, NULL, 'Shop Assistant', 'QuachLoan', '$2a$06$/W9D0Ai2pl2HVxm7lV5ovutzNu.UFnEaYsgSm6wxmpnOYARvPuByG', 4274734);
INSERT INTO employee.employees VALUES (270, 'Vu Hoang Nga', '139 Hung Vuong', 'Tay Ho', 'Ha Nam', 'Nga.VuHoang87@gmail.com', 6589037487, false, NULL, 'Shop Assistant', 'VuNga', '$2a$06$CzTu..UfmSvXvOmyAPegBumUUoai6acm5ZRoJlse4MU48BZSGIXEi', 4466210);
INSERT INTO employee.employees VALUES (271, 'Luu Thi Hoa', '451 Tran Dai Nghia', 'Phu Nhuan', 'Khanh Hoa', 'Hoa.LuuThi10@gmail.com', 7610079110, false, NULL, 'Shop Assistant', 'LuuHoa', '$2a$06$xvQT9TY.y0Q8yDJDUJVO0O5jRlQ3pjF48c.mXrgVab/UsOkyk2.oK', 6665720);
INSERT INTO employee.employees VALUES (9, 'Bui Kieu Lam', '839 Phan Dinh Phung', 'Long Bien', 'Vung Tau', 'Lam.BuiKieu11@gmail.com', 2389391011, false, NULL, 'Manager', 'BuiLam', '$2a$06$5zrD0rIk6GDJdVedsTZHqey5IepeMmjEA1dAIjIBmb5wEu9TUxQhO', 7501629);
INSERT INTO employee.employees VALUES (10, 'Ngo Kieu Duc', '289 Ly Thuong Kiet', 'Hai Ba Trung', 'Ninh Thuan', 'Duc.NgoKieu2@gmail.com', 2922104302, false, NULL, 'Manager', 'NgoDuc', '$2a$06$xoVhnDEGSo1xwURN3okiDu42y/or5V1vE4AFLfPZl30kQjOmS1/b2', 8701498);
INSERT INTO employee.employees VALUES (11, 'Hoang Thanh Huyen', '377 Hoang Cau', 'Hong Bang', 'Thai Nguyen', 'Huyen.HoangThanh93@gmail.com', 7500378693, false, NULL, 'Manager', 'HoangHuyen', '$2a$06$FBF1B3oF/LNl3yF1LIAO3OpkVN1zBsh0mlG02nAmnh6zlmBhAafsC', 8967439);
INSERT INTO employee.employees VALUES (12, 'Ly Khanh Huyen', '410 Hang Non', 'Quan 3', 'Vung Tau', 'Huyen.LyKhanh18@gmail.com', 5334649618, false, NULL, 'Manager', 'LyHuyen', '$2a$06$G/Vy5v5Idget/DnFGDO7r.nO.fnU1uOhQiDhYazemdIAFqdO961T6', 7182161);
INSERT INTO employee.employees VALUES (13, 'Nguyen Hai Giang', '620 Hoang Cau', 'Cau Giay', 'Da Nang', 'Giang.NguyenHai33@gmail.com', 5230854633, false, NULL, 'Manager', 'NguyenGiang', '$2a$06$al4.3d0zaiBoIaFLm404duC.fFZUbhtq8yA3nsfAOUEEKSLdNgpee', 7125142);
INSERT INTO employee.employees VALUES (14, 'Pham Van Huyen', '624 Giang Vo', 'Ngo Quyen', 'Ha Tinh', 'Huyen.PhamVan41@gmail.com', 5512795741, false, NULL, 'Manager', 'PhamHuyen', '$2a$06$GBf/kEZtmtuip3SZJyrQKuCH4oX4.JXn8N7r4LGtgbIXTynlAYlGi', 7512079);
INSERT INTO employee.employees VALUES (272, 'Dinh Van Loan', '412 Ngo Quyen', 'Binh Thanh', 'Quang Binh', 'Loan.DinhVan10@gmail.com', 9880956310, false, NULL, 'Shop Assistant', 'DinhLoan', '$2a$06$/lv/.5Ei13cNpBD0Yk93eueSxmiP/l7Xu/36D2Oy0zcXJlGNpom/S', 6995298);
INSERT INTO employee.employees VALUES (273, 'Do Hai Long', '767 Hang Mam', 'Thanh Xuan', 'Phu Tho', 'Long.DoHai14@gmail.com', 3259184214, false, NULL, 'Shop Assistant', 'DoLong', '$2a$06$o7Oio2iUFkY4njzQKql9Lexc9wdbZNBdEEkIdHK9ZH.vTe00VD4sa', 4514578);
INSERT INTO employee.employees VALUES (274, 'Dau Chi Trinh', '542 Hang Voi', 'Bac Tu Liem', 'Kon Tum', 'Trinh.DauChi51@gmail.com', 5261190251, false, NULL, 'Shop Assistant', 'DauTrinh', '$2a$06$CvWQsjpyfCEvTiwK3cO3kOGQnIoRTH/pgWN32t1BhUA7XkmFzmdJ.', 6450865);
INSERT INTO employee.employees VALUES (275, 'Duong Hai Loan', '697 Ngo Quyen', 'Long Bien', 'Bac Ninh', 'Loan.DuongHai1@gmail.com', 3888875401, false, NULL, 'Shop Assistant', 'DuongLoan', '$2a$06$upgec8KnliTkj.V5pdkzjeKG1y.z2oSNI7SBZa4ftpGp29Lb8jNBS', 5127240);
INSERT INTO employee.employees VALUES (276, 'Trinh Chi Thuy', '259 Hang Mam', 'Quan 1', 'Quang Nam', 'Thuy.TrinhChi83@gmail.com', 1231054183, false, NULL, 'Shop Assistant', 'TrinhThuy', '$2a$06$T0S1q6vsifZODVMxm1nG3eMoqV4GJcMSqI7Xber9Go7kNsojWAhyu', 4714382);
INSERT INTO employee.employees VALUES (277, 'Luu Manh Nhung', '426 Le Duan', 'Le Chan', 'Da Nang', 'Nhung.LuuManh87@gmail.com', 7763151687, false, NULL, 'Shop Assistant', 'LuuNhung', '$2a$06$BdU5g4jKcbgSqbZZPR5RAeca5.FMhVzzYKn3N/vrn918hMf/0WYSS', 6577948);
INSERT INTO employee.employees VALUES (278, 'Hoang Manh Dong', '61 Nguyen Sieu', 'Quan 3', 'Ha Tinh', 'Dong.HoangManh1@gmail.com', 5401179501, false, NULL, 'Shop Assistant', 'HoangDong', '$2a$06$lI9aAzlgDqnv9POYPmPOo.TQdX.D2nYCYhK9pH7tOakKY9cSEWA4K', 4034393);
INSERT INTO employee.employees VALUES (279, 'Duong Thanh Khang', '242 Nguyen Xi', 'Nam Tu Liem', 'Quy Nhon', 'Khang.DuongThanh60@gmail.com', 5993304460, false, NULL, 'Shop Assistant', 'DuongKhang', '$2a$06$oGkqZ8DEIOu26dJPLk1c.uTodiNyJkPrL/AufF7UqEG.nME7HXLpG', 4538033);
INSERT INTO employee.employees VALUES (280, 'Nguyen Tuan Thuy', '991 Ngo Quyen', 'Quan 1', 'Bac Ninh', 'Thuy.NguyenTuan82@gmail.com', 8362354182, false, NULL, 'Shop Assistant', 'NguyenThuy', '$2a$06$FwMDDTbbTxTzti5ZSZxPj.Pv5HZiD1LJ5hNU7uxz7M9AvCdgcfC5C', 5918503);
INSERT INTO employee.employees VALUES (281, 'Quach Khanh An', '504 O Cho Dua', 'Ba Dinh', 'Quang Ngai', 'An.QuachKhanh13@gmail.com', 5094868913, false, NULL, 'Shop Assistant', 'QuachAn', '$2a$06$dtweGCKw3tdDgSm6K3ZdQuFmYD3/3qAd86pOin13wA94Twd2lx9a.', 5644868);
INSERT INTO employee.employees VALUES (282, 'Dinh Hoang Giang', '796 Pham Ngu Lao', 'Ngo Quyen', 'Quang Nam', 'Giang.DinhHoang70@gmail.com', 7695655970, false, NULL, 'Shop Assistant', 'DinhGiang', '$2a$06$vwPJidhhntYVGML37oWdY.naQVVU4garbeo1sPfyJ0xARyE7u/Wpy', 5474826);
INSERT INTO employee.employees VALUES (283, 'Vo Manh Ly', '893 Xuan Thuy', 'Binh Thanh', 'Yen Bai', 'Ly.VoManh10@gmail.com', 8014575710, false, NULL, 'Shop Assistant', 'VoLy', '$2a$06$FBXsVaf42STje9gAKJJM2.nYMVthZYtqcjFnuSOXLLPCQ/NmtZSEW', 4466445);
INSERT INTO employee.employees VALUES (284, 'Quach Thi My', '866 Le Duan', 'Le Chan', 'Binh Dinh', 'My.QuachThi52@gmail.com', 9420403852, false, NULL, 'Shop Assistant', 'QuachMy', '$2a$06$2AerB7577B61h/rj8.FwgOe5qxQ4PeTILS/0qh89FrByLgZzfYrpu', 6190929);
INSERT INTO employee.employees VALUES (285, 'Tran Van Cuong', '265 Hang Ma', 'Cam Le', 'Quang Tri', 'Cuong.TranVan90@gmail.com', 5815991890, false, NULL, 'Shop Assistant', 'TranCuong', '$2a$06$BuTwa0CyJEXKwIry38.Qf.IwcPxUs7cKsE9dNm/xXr8zf1iaWe6F.', 6692372);
INSERT INTO employee.employees VALUES (286, 'Dinh Minh Hiep', '394 Lan Ong', 'Ngo Quyen', 'Nha Trang', 'Hiep.DinhMinh92@gmail.com', 2808095092, false, NULL, 'Shop Assistant', 'DinhHiep', '$2a$06$Yz5sZICyz9Ry7zm5SFhCLOIK9.o5suk35ptuGDpRGbRr19pNHLbLS', 6653052);
INSERT INTO employee.employees VALUES (287, 'Duong Chi An', '302 Hang Mam', 'Quan 5', 'Khanh Hoa', 'An.DuongChi86@gmail.com', 6188141086, false, NULL, 'Shop Assistant', 'DuongAn', '$2a$06$xMzxMDFpwF.7geZfgwe2VuMjuk6hWochw3NpgKnJos8JOv6ok5Dsi', 4195955);
INSERT INTO employee.employees VALUES (288, 'Tran Thi Dong', '975 Hang Non', 'Quan 3', 'Dak Lak', 'Dong.TranThi81@gmail.com', 7630557881, false, NULL, 'Shop Assistant', 'TranDong', '$2a$06$henzRY9aWU1Bth6GJcDTFeEBZWBLSSs.sj0RL7SpSeiX0ehFJBpcC', 4345059);
INSERT INTO employee.employees VALUES (289, 'Lac Hoang Huong', '228 Hang Tre', 'Quan 4', 'Da Nang', 'Huong.LacHoang88@gmail.com', 4556373288, false, NULL, 'Shop Assistant', 'LacHuong', '$2a$06$s1d9OGU4Aj36uoYMIYfBLO.pJOsSIE88yiW3u3awLjC73RLw3fY4G', 5204112);
INSERT INTO employee.employees VALUES (290, 'Quach Chi Nam', '204 Le Thanh Ton', 'Bac Tu Liem', 'Nha Trang', 'Nam.QuachChi19@gmail.com', 8139334819, false, NULL, 'Shop Assistant', 'QuachNam', '$2a$06$AsNHkG9q.4RrzvXLU0WGHuWwWr02S4lp3UhnXAc06QMOQcd6vIuZe', 5589446);
INSERT INTO employee.employees VALUES (291, 'Lac Khanh Lam', '409 Hung Vuong', 'Hong Bang', 'Binh Dinh', 'Lam.LacKhanh94@gmail.com', 8106486594, false, NULL, 'Shop Assistant', 'LacLam', '$2a$06$hCyxhmky9qQwq0sFFpjCWOmSlM422mhbO5lHPKXoYngal.smse4Ma', 5217456);
INSERT INTO employee.employees VALUES (292, 'Cao Chi Nam', '164 Hang Dao', 'Ba Dinh', 'Nha Trang', 'Nam.CaoChi36@gmail.com', 7443252536, false, NULL, 'Shop Assistant', 'CaoNam', '$2a$06$1Hr8ZwXQKjAnJ1VC6JErRuF89OXUCZYEOjd4qXFwecyjcLJs1FAWO', 5941416);
INSERT INTO employee.employees VALUES (293, 'Luu Nam Minh', '121 Hang Non', 'Long Bien', 'Thua Thien Hue', 'Minh.LuuNam59@gmail.com', 6095819659, false, NULL, 'Shop Assistant', 'LuuMinh', '$2a$06$SLgy3uqd7kSKZO1GfKjEoOpWLdoSWB7YH4G1O2iH8UjA77m.J0VCy', 5455052);
INSERT INTO employee.employees VALUES (294, 'Ta Manh Minh', '164 Nguyen Sieu', 'Quan 2', 'Quang Nam', 'Minh.TaManh13@gmail.com', 8527451713, false, NULL, 'Shop Assistant', 'TaMinh', '$2a$06$YB2B9HcmoU7QvamaTdSX7.MTkyKpwo4x9EiYum/0rNxkHGz8YFe32', 6523107);
INSERT INTO employee.employees VALUES (295, 'Ly Chi My', '492 Hang Non', 'Ba Dinh', 'Ho Chi Minh', 'My.LyChi40@gmail.com', 6155947640, false, NULL, 'Shop Assistant', 'LyMy', '$2a$06$h08pAleR0LxRwPlgM5eeN.JNH8jzTEa4y11tb..uvNy0v97f247Ye', 5593852);
INSERT INTO employee.employees VALUES (296, 'Tran Van Tuyen', '120 Hang Gai', 'Son Tra', 'Quang Binh', 'Tuyen.TranVan94@gmail.com', 5790342294, false, NULL, 'Shop Assistant', 'TranTuyen', '$2a$06$zVmrF/03Ty5Q5.e2Us.eDOp.Q1NrABtsbXNrDXVepEdp2oRt1OfS6', 6923495);
INSERT INTO employee.employees VALUES (15, 'Ta Hai Xuan', '891 Pham Hong Thai', 'Thanh Xuan', 'Ha Tinh', 'Xuan.TaHai20@gmail.com', 7282813920, false, NULL, 'Manager', 'TaXuan', '$2a$06$MiejY1icin9qtaD0bemK3.DZeE/v6xCjBx3yxl7pEJEZyTI2lg2Ii', 7840127);
INSERT INTO employee.employees VALUES (16, 'Trinh Kieu Trinh', '535 Tran Dai Nghia', 'Quan 2', 'Quang Ninh', 'Trinh.TrinhKieu49@gmail.com', 8769646949, false, NULL, 'Manager', 'TrinhTrinh', '$2a$06$uI1nMGKfxUxJyTAR/8EIsuH/0xOy/v8fzvND1nUVXsGawKzMn7e.6', 8176896);
INSERT INTO employee.employees VALUES (17, 'Cao Ngoc Nhi', '560 Ton Duc Thang', 'Hong Bang', 'Quy Nhon', 'Nhi.CaoNgoc19@gmail.com', 8065195219, false, NULL, 'Manager', 'CaoNhi', '$2a$06$1XTabLm2I03z7pHQplfdSezeUbHpWpSBNov9kOkXQ0oEFEwDY0Y7a', 7850652);
INSERT INTO employee.employees VALUES (18, 'Nguyen Chi Phuong', '244 Hang Chieu', 'Quan 3', 'Bien Hoa', 'Phuong.NguyenChi44@gmail.com', 2958387344, false, NULL, 'Manager', 'NguyenPhuong', '$2a$06$mC.ZvRw52ryhQxEIsQPJB.cMBTlWyQLBwQhUCpHoo7MnGq2O4xSEm', 7395350);
INSERT INTO employee.employees VALUES (19, 'Vu Thanh Mai', '862 Nguyen Xi', 'Tay Ho', 'Da Nang', 'Mai.VuThanh59@gmail.com', 7384052459, false, NULL, 'Manager', 'VuMai', '$2a$06$vnClk76jCog3DWeyMo5eru.cum.dVq84rffXTUdsuQ2D9yOL1not2', 7932034);
INSERT INTO employee.employees VALUES (20, 'Trinh Hai Lan', '390 Tran Phu', 'Le Chan', 'Yen Bai', 'Lan.TrinhHai3@gmail.com', 9355340303, false, NULL, 'Cashier', 'TrinhLan', '$2a$06$oF5T/4Gsjt4MZEjru4/ZveScsRWqpR6kWu6NMqaqTZf3Xbyr86O22', 4045098);
INSERT INTO employee.employees VALUES (297, 'Lac Chi Khoa', '779 Giang Vo', 'Quan 3', 'Binh Thuan', 'Khoa.LacChi49@gmail.com', 8300115149, false, NULL, 'Shop Assistant', 'LacKhoa', '$2a$06$aDBfXOXYdXavonX.fpB3YeCWmg6Xwyc0VAuTaG3ZxaiUwywiIsO8y', 4512984);
INSERT INTO employee.employees VALUES (298, 'Dau Thi Khanh', '473 Hang Bo', 'Quan 1', 'Nam Dinh', 'Khanh.DauThi82@gmail.com', 5989663782, false, NULL, 'Shop Assistant', 'DauKhanh', '$2a$06$XiuNrKP7DwwpWTE5pxGpx.tCY5PgOjK.4F2ubN8hv86opAa5QqvNK', 4674334);
INSERT INTO employee.employees VALUES (299, 'Cao Nam Ly', '497 Tran Dai Nghia', 'Long Bien', 'Thai Nguyen', 'Ly.CaoNam42@gmail.com', 2050887242, false, NULL, 'Shop Assistant', 'CaoLy', '$2a$06$MQO2iuiIcXSeJIDhtURhbeoqgSLl2A8NuXhRUG0FsRLOnqotgR6VK', 5326239);
INSERT INTO employee.employees VALUES (300, 'Dinh Thanh Duc', '974 Hang Da', 'Long Bien', 'Quang Tri', 'Duc.DinhThanh48@gmail.com', 5613280648, false, NULL, 'Shop Assistant', 'DinhDuc', '$2a$06$naGwd9NNCvEPb5IajfAFKOA29uyE5awBwKE91HZk8p68akg1qEbJi', 4989281);
INSERT INTO employee.employees VALUES (301, 'Vu Thanh Nhi', '940 Hoang Quoc Viet', 'Quan 5', 'Quang Ninh', 'Nhi.VuThanh14@gmail.com', 4061593714, false, NULL, 'Shop Assistant', 'VuNhi', '$2a$06$S/TxfJLvgjnEGakAxkR6ge9uUCpg27aM4VEh0QOdpE/UdnfU3KLIy', 4491808);
INSERT INTO employee.employees VALUES (302, 'Ho Hoang Loan', '964 Hang Dao', 'Hong Bang', 'Da Nang', 'Loan.HoHoang18@gmail.com', 7486629518, false, NULL, 'Shop Assistant', 'HoLoan', '$2a$06$yBIo4Z8.X8y3T6YpTNnlGeLfRYZdV1V1e/gjEnoJ.Y2QpYqx7bhLq', 6969163);
INSERT INTO employee.employees VALUES (303, 'Huynh Van Huyen', '273 Phan Dinh Phung', 'Hai Ba Trung', 'Can Tho', 'Huyen.HuynhVan44@gmail.com', 4612761044, false, NULL, 'Shop Assistant', 'HuynhHuyen', '$2a$06$kBtgXTRWn1ZardxtBml1ZOFm6Ux/uYPHOXrKZAqdRfw.fpCjms2YO', 5587840);
INSERT INTO employee.employees VALUES (304, 'Trinh Manh Thu', '437 Lan Ong', 'Hoang Mai', 'Kon Tum', 'Thu.TrinhManh74@gmail.com', 7559804274, false, NULL, 'Shop Assistant', 'TrinhThu', '$2a$06$QoXjFfn9dVhqceqwisj/leTJzLkrvyJTIx9uCpMiSkRQgLFJndLOy', 6579377);
INSERT INTO employee.employees VALUES (305, 'Nghiem Tuan Dong', '662 Luong Van Can', 'Bac Tu Liem', 'Da Lat', 'Dong.NghiemTuan22@gmail.com', 3474052822, false, NULL, 'Shop Assistant', 'NghiemDong', '$2a$06$QEnjrIDGmkN37wDu2FzsJ.4EsUnWLY5UBC5R1rHb1iplADDX.v78G', 4628595);
INSERT INTO employee.employees VALUES (306, 'Doan Hai Huong', '67 Le Duan', 'Tay Ho', 'Phu Tho', 'Huong.DoanHai11@gmail.com', 3652569011, false, NULL, 'Shop Assistant', 'DoanHuong', '$2a$06$yX7QC9fLSs/xGrSH0kIDWeRUYEwFYAK8dDZ3UZD96fcqsqkhqeYmO', 5024022);
INSERT INTO employee.employees VALUES (307, 'Dinh Van Huyen', '895 Le Thanh Ton', 'Nam Tu Liem', 'Nam Dinh', 'Huyen.DinhVan20@gmail.com', 3741879420, false, NULL, 'Shop Assistant', 'DinhHuyen', '$2a$06$KyyFytdgfzvduQUPq0j/O.Gb/90EWRkfg8B5qH5OCyjcnBO4mhZom', 5909163);
INSERT INTO employee.employees VALUES (308, 'Dinh Khanh Binh', '639 Hang Da', 'Son Tra', 'Phu Yen', 'Binh.DinhKhanh23@gmail.com', 5208751223, false, NULL, 'Shop Assistant', 'DinhBinh', '$2a$06$eXtT.Nkwj9TeBd7DxgNxv.ffDRAalcl4XnIjre3CkGfHLn7z0AS16', 4499420);
INSERT INTO employee.employees VALUES (309, 'Huynh Tuan Thanh', '711 Ly Thuong Kiet', 'Hai Ba Trung', 'Quang Ngai', 'Thanh.HuynhTuan36@gmail.com', 2042692736, false, NULL, 'Shop Assistant', 'HuynhThanh', '$2a$06$2CS1KaHny8gNgQ6/EYhh0u2Pj1sMRALibI8ZtAu7IHbSp5dLXrrEC', 6711974);
INSERT INTO employee.employees VALUES (310, 'Doan Hai My', '735 Ngo Quyen', 'Cau Giay', 'Quy Nhon', 'My.DoanHai1@gmail.com', 4420184801, false, NULL, 'Shop Assistant', 'DoanMy', '$2a$06$myansFjTd6lsS4McV.fYg.ZMWMolvcShilp.kAmXvNpTpzRZjQvvu', 6142151);
INSERT INTO employee.employees VALUES (311, 'Dinh Van Tu', '858 Luong Dinh Cua', 'Quan 1', 'Kon Tum', 'Tu.DinhVan66@gmail.com', 6168623566, false, NULL, 'Shop Assistant', 'DinhTu', '$2a$06$QD8ykDSHEB4A8arkaeYo5.fO1X00dGIWRNMyUvSRS6.j4CXBTtwwK', 4724742);
INSERT INTO employee.employees VALUES (312, 'Vo Khanh Thao', '931 O Cho Dua', 'Hoan Kiem', 'Quy Nhon', 'Thao.VoKhanh12@gmail.com', 6793110212, false, NULL, 'Shop Assistant', 'VoThao', '$2a$06$/qZoOUKI98qdrmiLd6mm9OnsmdeDelPjlRvJPwXZRDGQKnm0g68hG', 5136194);
INSERT INTO employee.employees VALUES (313, 'Do Hai Cuong', '573 Hang Luoc', 'Thanh Khe', 'Bac Ninh', 'Cuong.DoHai69@gmail.com', 5443360669, false, NULL, 'Shop Assistant', 'DoCuong', '$2a$06$l9FEZYUr4K4U.vwMrVtGjOxlWguKYEEveYH/Ku9IrT4uDV/qTpqn2', 6189318);
INSERT INTO employee.employees VALUES (314, 'Do Kieu Tien', '221 Nguyen Xi', 'Quan 5', 'Ho Chi Minh', 'Tien.DoKieu30@gmail.com', 8138527630, false, NULL, 'Shop Assistant', 'DoTien', '$2a$06$XSDcXbB9ZHPa60eBC6Szn.89P6DX6XOUB130n1vGfVv.o4UcFrYQy', 5524467);
INSERT INTO employee.employees VALUES (315, 'Ngo Nam Dong', '120 Hang Bong', 'Le Chan', 'Can Tho', 'Dong.NgoNam63@gmail.com', 8675703563, false, NULL, 'Shop Assistant', 'NgoDong', '$2a$06$Kzv8w9djKtd0v6dideRQ9OI.nXoFuPRnZTqMdaWNDgDUupD0oGyey', 6141358);
INSERT INTO employee.employees VALUES (316, 'Nghiem Tuan Sang', '216 Hang Da', 'Phu Nhuan', 'Kon Tum', 'Sang.NghiemTuan62@gmail.com', 1476426562, false, NULL, 'Shop Assistant', 'NghiemSang', '$2a$06$OYlCNwSvTSCBMDivpe9pk.HaLPZ.aqnH8/2qLpG136k1WG7Rk2glq', 6262354);
INSERT INTO employee.employees VALUES (317, 'Luong Manh Tu', '181 Hoang Quoc Viet', 'Hai Chau', 'Ha Tinh', 'Tu.LuongManh15@gmail.com', 7686668815, false, NULL, 'Shop Assistant', 'LuongTu', '$2a$06$cPs2PqSSqQcAnYQIzi4rDuW98Hxwyrwnxha5nU26wWo8cxIyZDsEa', 6057375);
INSERT INTO employee.employees VALUES (318, 'Doan Khanh Hung', '463 Hung Vuong', 'Hai Chau', 'Da Lat', 'Hung.DoanKhanh11@gmail.com', 4901469111, false, NULL, 'Shop Assistant', 'DoanHung', '$2a$06$XeyvChv4AAQlXmfwo.0HaOB10BI3G/3rmiO9lfnHNhi4ypaMHQFkS', 4953211);
INSERT INTO employee.employees VALUES (319, 'Tong Khanh Thanh', '103 Hung Vuong', 'Hai Ba Trung', 'Ha Tinh', 'Thanh.TongKhanh68@gmail.com', 2182366168, false, NULL, 'Shop Assistant', 'TongThanh', '$2a$06$yaF8LjXwcyb.fPdsGnk8H./XN.5ZLiI7h.gDjvCNQObVELr07GPya', 4276700);
INSERT INTO employee.employees VALUES (320, 'Tieu Manh Loan', '203 Xuan Thuy', 'Son Tra', 'Quang Ninh', 'Loan.TieuManh36@gmail.com', 7352093936, false, NULL, 'Shop Assistant', 'TieuLoan', '$2a$06$zSsn57VZJcYFdpyScI5O9.zWY3R5I2p6QRgbZPiMJcZoKdzsGkMOu', 6627981);
INSERT INTO employee.employees VALUES (321, 'Do Ngoc An', '307 Pham Ngu Lao', 'Hai Ba Trung', 'Da Lat', 'An.DoNgoc52@gmail.com', 8485978352, false, NULL, 'Shop Assistant', 'DoAn', '$2a$06$E7UAtEI5k2ZT/2ZypxKSfeGxmYl0JHS3D3gsAhtbPERYDHesBUnIe', 6669718);
INSERT INTO employee.employees VALUES (21, 'Vu Tuan Lam', '1000 Hang Da', 'Binh Thanh', 'Quang Ninh', 'Lam.VuTuan44@gmail.com', 1242228744, false, NULL, 'Cashier', 'VuLam', '$2a$06$KJDAMl6L0T3y/JScPJ4a/u8qLtsum2PsShkSR7ijA9EFNQy64wJlG', 6798126);
INSERT INTO employee.employees VALUES (22, 'Tran Van Nhi', '631 Hang Gai', 'Hoan Kiem', 'Vung Tau', 'Nhi.TranVan53@gmail.com', 2951636753, false, NULL, 'Cashier', 'TranNhi', '$2a$06$vYufR02uYuJWF1vkpmiKlOQUtT44zsjgVsLqy7bJwZoGHHnD2Djvq', 5485372);
INSERT INTO employee.employees VALUES (23, 'Do Tuan Lam', '236 Le Ngoc Han', 'Le Chan', 'Thai Nguyen', 'Lam.DoTuan61@gmail.com', 1130110361, false, NULL, 'Cashier', 'DoLam', '$2a$06$.LyIhXfi6NrrcKcxkF1/I.d8GhBhOEzd3G4dtFuyKrnGrUO.IGqm2', 6333613);
INSERT INTO employee.employees VALUES (322, 'Ho Hoang Thanh', '563 Hung Vuong', 'Quan 2', 'Binh Thuan', 'Thanh.HoHoang64@gmail.com', 2310082764, false, NULL, 'Shop Assistant', 'HoThanh', '$2a$06$iN3EjIozR71vBUSd3MyvWewRfTbEM1PedSTqTLS3m80vlSz64RroC', 6866530);
INSERT INTO employee.employees VALUES (323, 'Huynh Manh Hai', '355 Tran Quoc Toan', 'Thanh Khe', 'Quang Ninh', 'Hai.HuynhManh71@gmail.com', 4139831371, false, NULL, 'Shop Assistant', 'HuynhHai', '$2a$06$RNOtFVdGmslDTOWrrP1fxu2UK6tzwRSymQV/r/E/6szdBzz7m3d2C', 6048168);
INSERT INTO employee.employees VALUES (324, 'Ngo Hoang Binh', '675 Hang Tre', 'Hoang Mai', 'Bac Ninh', 'Binh.NgoHoang73@gmail.com', 7870157873, false, NULL, 'Shop Assistant', 'NgoBinh', '$2a$06$ShWNS79v4WxVvT91/RBOae9r8e1oWJ1QEt//k8Dw8Z3HAU.RUUKp6', 4083634);
INSERT INTO employee.employees VALUES (325, 'Diep Hoang Dong', '438 Pham Hong Thai', 'Hai Chau', 'Phu Tho', 'Dong.DiepHoang43@gmail.com', 4993034743, false, NULL, 'Shop Assistant', 'DiepDong', '$2a$06$kj2laiEQ7Rv5nuwfVV/oIOaZMFJij0eDq7XT/uKHt.M9eMWmoW2k6', 5404222);
INSERT INTO employee.employees VALUES (326, 'Nghiem Tuan Van', '842 Hang Bo', 'Binh Thanh', 'Nam Dinh', 'Van.NghiemTuan76@gmail.com', 9378946576, false, NULL, 'Shop Assistant', 'NghiemVan', '$2a$06$l1RJqZVk6C2JV.cvzky6ouZ97uMofPllwAmwTvJD9GfOJLo6K7Rr2', 5381361);
INSERT INTO employee.employees VALUES (327, 'Ly Hoang Thuy', '892 Luong Van Can', 'Phu Nhuan', 'Ha Nam', 'Thuy.LyHoang1@gmail.com', 8214521001, false, NULL, 'Shop Assistant', 'LyThuy', '$2a$06$iU/phIZqGE0SSYO29Ne5keQmkgEEmhDiVEYN2HUNqTGRlDXn9g9ry', 4500800);
INSERT INTO employee.employees VALUES (328, 'Phan Ngoc Hai', '528 Ngo Quyen', 'Quan 1', 'Nha Trang', 'Hai.PhanNgoc29@gmail.com', 5155504529, false, NULL, 'Shop Assistant', 'PhanHai', '$2a$06$RSVbRDxOF1LYx5jVfpiLAu/F7RE.oWc2hjCJHmiqpwDzM1qT7gpLW', 4106954);
INSERT INTO employee.employees VALUES (329, 'Pham Thanh Tuyen', '66 Phung Hung', 'Long Bien', 'Nha Trang', 'Tuyen.PhamThanh81@gmail.com', 3539945781, false, NULL, 'Shop Assistant', 'PhamTuyen', '$2a$06$ZAbz23h47zxzwC4Jqx4pIegcBGPcL9An2MTbwCvYBPhHn7UnZAjie', 6184493);
INSERT INTO employee.employees VALUES (330, 'Phan Chi Cuong', '462 Tran Hung Dao', 'Cau Giay', 'Quang Nam', 'Cuong.PhanChi77@gmail.com', 7505996677, false, NULL, 'Shop Assistant', 'PhanCuong', '$2a$06$Jfoe6ZsrJXY10/7fBo8h9ewRF5DW8wssABmANEcImXlXyOTrk14Ry', 4301365);
INSERT INTO employee.employees VALUES (331, 'Quach Ngoc Linh', '563 Quan Thanh', 'Binh Thanh', 'Phu Yen', 'Linh.QuachNgoc79@gmail.com', 8680354279, false, NULL, 'Shop Assistant', 'QuachLinh', '$2a$06$QAU6K8UxJpS55xTz1Q2qEOQhPjxEYXuU7KAf1b/j.9f7284iHG74S', 6592938);
INSERT INTO employee.employees VALUES (332, 'Trinh Khanh Duc', '648 Phan Dinh Phung', 'Quan 3', 'Dak Lak', 'Duc.TrinhKhanh56@gmail.com', 7863609156, false, NULL, 'Shop Assistant', 'TrinhDuc', '$2a$06$GGEDI20pq0NzHe5b4WWvHeKZliNnOItXMmgRsCRkBYvEZq67XdBAS', 6358844);
INSERT INTO employee.employees VALUES (333, 'Nghiem Nam Mai', '472 Hang Bong', 'Binh Thanh', 'Da Lat', 'Mai.NghiemNam21@gmail.com', 5556837621, false, NULL, 'Shop Assistant', 'NghiemMai', '$2a$06$eyLPqmM8wtUqBh4yqTTXxeYArM5LpYkgcewKDcsa87UkJbLq2Eybq', 6769132);
INSERT INTO employee.employees VALUES (334, 'Trinh Kieu Hai', '368 Giang Vo', 'Hai Ba Trung', 'Da Nang', 'Hai.TrinhKieu1@gmail.com', 2378138301, false, NULL, 'Shop Assistant', 'TrinhHai', '$2a$06$qWo57eAy7nC/e.yiBDW5nOHejpNwymtUYMdxdVqnZub2GoKAMoIcS', 4349752);
INSERT INTO employee.employees VALUES (335, 'Doan Nam Sang', '268 Ly Thuong Kiet', 'Phu Nhuan', 'Phu Yen', 'Sang.DoanNam35@gmail.com', 9320944735, false, NULL, 'Shop Assistant', 'DoanSang', '$2a$06$yxqlgNQ7XDkUQMxpyHdvcuy/K1rBa.p8Ptf5ShibBtcYl.rkudy6S', 6217916);
INSERT INTO employee.employees VALUES (336, 'Lac Tuan Hung', '345 Quan Thanh', 'Long Bien', 'Gia Lai', 'Hung.LacTuan90@gmail.com', 5435266890, false, NULL, 'Shop Assistant', 'LacHung', '$2a$06$VPKXS/0EZE0LZ3xwlGj5NetA3wHkkcGm1WBz86okFMT/GTL1fIkwu', 4861121);
INSERT INTO employee.employees VALUES (337, 'Vu Manh Hai', '957 Tran Hung Dao', 'Hong Bang', 'Quang Binh', 'Hai.VuManh96@gmail.com', 7491794896, false, NULL, 'Shop Assistant', 'VuHai', '$2a$06$c.9sNuwcW2DjYFjBLooZJupr89pyrYQKqcfNs6JQNQ3RWOZRt2z.q', 6313900);
INSERT INTO employee.employees VALUES (338, 'Vu Thanh Thuy', '465 Quan Thanh', 'Hoan Kiem', 'Can Tho', 'Thuy.VuThanh96@gmail.com', 2072912396, false, NULL, 'Shop Assistant', 'VuThuy', '$2a$06$Kv2c2NCuCIo3gGqvsB6x1uod.46UmWYTealOTQiDNCGwEoTrfY8Vi', 4302009);
INSERT INTO employee.employees VALUES (339, 'Dau Thi Ngan', '989 Tran Phu', 'Nam Tu Liem', 'Ho Chi Minh', 'Ngan.DauThi57@gmail.com', 9981884657, false, NULL, 'Shop Assistant', 'DauNgan', '$2a$06$FOmx5Bf9HaRVRuZY9YAgmu1GXu.uuohH.4TnMM.sFSblKNhIHjc6O', 4549850);
INSERT INTO employee.employees VALUES (340, 'Ngo Kieu Nhi', '752 Hang Ngang', 'Nam Tu Liem', 'Hue', 'Nhi.NgoKieu79@gmail.com', 9477397479, false, NULL, 'Shop Assistant', 'NgoNhi', '$2a$06$LT8POonyL4KkFk3HrClwEeryxB12Q7N4kpyFnwRJALn/cYzg924fW', 5570516);
INSERT INTO employee.employees VALUES (341, 'Duong Chi Duc', '692 Pham Hong Thai', 'Ngo Quyen', 'Bien Hoa', 'Duc.DuongChi2@gmail.com', 9101648902, false, NULL, 'Shop Assistant', 'DuongDuc', '$2a$06$1xVxVHCjw1lAZBWeGosQjuKqR0tPcnEkXl6uyNYUHs/FDnwTjHCs6', 4228966);
INSERT INTO employee.employees VALUES (342, 'Vo Chi Ngan', '394 Hang Tre', 'Nam Tu Liem', 'Hai Phong', 'Ngan.VoChi78@gmail.com', 6315600778, false, NULL, 'Shop Assistant', 'VoNgan', '$2a$06$gncPmLUkD7uPrdwmry1ZkOZQ5mxX8oVxWk5MtVWEXOOcWK1hnMZAy', 6892140);
INSERT INTO employee.employees VALUES (343, 'Lac Hoang Trang', '264 Le Thanh Ton', 'Thanh Khe', 'Phu Yen', 'Trang.LacHoang4@gmail.com', 1525403004, false, NULL, 'Shop Assistant', 'LacTrang', '$2a$06$qGxqkmZvewga7OBXUFL.tusFtjVVQrj7Z7CNpgQIgAgNr2e0le8wu', 4660360);
INSERT INTO employee.employees VALUES (344, 'Do Minh Thanh', '101 Ly Thuong Kiet', 'Cau Giay', 'Phu Tho', 'Thanh.DoMinh23@gmail.com', 5876934523, false, NULL, 'Shop Assistant', 'DoThanh', '$2a$06$TnqgUJmyZMpRTkwOKVVVdePXF/r9PpTca2AvumEExHKfvpXvPUpNi', 6624607);
INSERT INTO employee.employees VALUES (345, 'Huynh Thi Van', '419 Ho Tung Mau', 'Dong Da', 'Quang Ngai', 'Van.HuynhThi77@gmail.com', 5443993577, false, NULL, 'Shop Assistant', 'HuynhVan', '$2a$06$LN5xVtqSKGLrYkYOA66lQOze07W9C8eJ2tRWP5rbO9xCPzcx0zMHy', 5636337);
INSERT INTO employee.employees VALUES (346, 'Vo Nam Ha', '737 Thuoc Bac', 'Quan 4', 'Phu Yen', 'Ha.VoNam0@gmail.com', 8819056300, false, NULL, 'Shop Assistant', 'VoHa', '$2a$06$TJqeoPxEZcr2J5G73cz9y.1tBDnjPPqPeaBYfiyAq/WRNnqzq/Fry', 5288242);
INSERT INTO employee.employees VALUES (347, 'Le Van Thu', '635 Hang Chieu', 'Cau Giay', 'Da Nang', 'Thu.LeVan84@gmail.com', 5908131084, false, NULL, 'Shop Assistant', 'LeThu', '$2a$06$yPcG4KzBEGAf2DrmDtkiM.JVKqPtrpqDawRz8N8s9WXd6LUMRNCDe', 5247235);
INSERT INTO employee.employees VALUES (348, 'Dau Kieu Lam', '183 Pham Hong Thai', 'Dong Da', 'Ha Noi', 'Lam.DauKieu73@gmail.com', 5369979273, false, NULL, 'Shop Assistant', 'DauLam', '$2a$06$3KYVZxhM.jhD0w/5d6hEdOd9xGd5PNGYgJUdBedXJxWQBeRoFC8VK', 6367417);
INSERT INTO employee.employees VALUES (349, 'Hoang Chi Huy', '746 Ly Thuong Kiet', 'Long Bien', 'Kon Tum', 'Huy.HoangChi20@gmail.com', 7813435920, false, NULL, 'Shop Assistant', 'HoangHuy', '$2a$06$gvDoSUUgvWLbvN/0IJ.3LeyLo23oj.DvHhFSFUYknsTSxzNy.qDUa', 5916638);
INSERT INTO employee.employees VALUES (350, 'Tong Manh Cuong', '824 Ly Nam De', 'Quan 5', 'Quang Ninh', 'Cuong.TongManh14@gmail.com', 1959399914, false, NULL, 'Shop Assistant', 'TongCuong', '$2a$06$RgLy/R0TxrfWB1wcwqASEuLjuczqXVJd5uh7LIiQJigjqM2s9Qi.K', 6415635);
INSERT INTO employee.employees VALUES (351, 'Dang Ngoc Dong', '624 Hang Ngang', 'Hai Chau', 'Bien Hoa', 'Dong.DangNgoc47@gmail.com', 5561343447, false, NULL, 'Shop Assistant', 'DangDong', '$2a$06$/P0zNNRGqb9.rO70h1J3QuX6j/mPFQybfX5ZB0qARcTuoLzHrqe7q', 6721295);
INSERT INTO employee.employees VALUES (352, 'Tran Manh Huong', '501 Hang Luoc', 'Cau Giay', 'Nam Dinh', 'Huong.TranManh16@gmail.com', 8608292616, false, NULL, 'Shop Assistant', 'TranHuong', '$2a$06$W6/51L/kdYgE74.C58hpSOqbMMQRfrzn6/YoNk04/bvbcpD3vSaTi', 6876926);
INSERT INTO employee.employees VALUES (24, 'Diep Thi Quynh', '237 Thuoc Bac', 'Le Chan', 'Gia Lai', 'Quynh.DiepThi86@gmail.com', 4283495386, false, NULL, 'Cashier', 'DiepQuynh', '$2a$06$5QR9Y6b4yKr39uodE99uvuaO5Fh4rPC8uwR/3NCkLZPviXtRbeemS', 6487064);
INSERT INTO employee.employees VALUES (25, 'Ngo Manh Huong', '929 Le Loi', 'Hong Bang', 'Binh Thuan', 'Huong.NgoManh60@gmail.com', 3886755460, false, NULL, 'Cashier', 'NgoHuong', '$2a$06$MIacLj2qcIDoup3qkKIpqe/sG.XRP4uB1GVn9ol5PKoz0FDH5aF9C', 6580105);
INSERT INTO employee.employees VALUES (26, 'Tong Chi Khanh', '547 Hang Ca', 'Cau Giay', 'Da Nang', 'Khanh.TongChi37@gmail.com', 7014306737, false, NULL, 'Cashier', 'TongKhanh', '$2a$06$LKycemP9EH9KRi/7QgqAXe9e4UIsYQp4VHLueWTNKeOHXwHVdPc8e', 6830183);
INSERT INTO employee.employees VALUES (27, 'Nghiem Kieu Tien', '825 Ly Thuong Kiet', 'Hai Chau', 'Ha Noi', 'Tien.NghiemKieu72@gmail.com', 9610570772, false, NULL, 'Cashier', 'NghiemTien', '$2a$06$aSTzttP8l9Ru30nha47CpeAd7WzZBdH4.USjBsR5z/2MewJBWVBeu', 4634270);
INSERT INTO employee.employees VALUES (28, 'Quach Khanh Bang', '967 Nguyen Xi', 'Bac Tu Liem', 'Thai Nguyen', 'Bang.QuachKhanh39@gmail.com', 3014879739, false, NULL, 'Cashier', 'QuachBang', '$2a$06$tYjyCrdpG/yEbSlJnCBXPei1qkDHIBzzY20f36fkSXcswANE.ILvC', 4376278);
INSERT INTO employee.employees VALUES (29, 'Luu Minh Ha', '25 Tran Hung Dao', 'Quan 2', 'Bien Hoa', 'Ha.LuuMinh97@gmail.com', 8618299697, false, NULL, 'Cashier', 'LuuHa', '$2a$06$VC0LconCQwp9LDdrDIY5IOHMO9iZds73m7G9yEGxKOxLpE6MYNVfG', 4586285);
INSERT INTO employee.employees VALUES (30, 'Le Ngoc Loan', '771 Hoang Cau', 'Quan 2', 'Nha Trang', 'Loan.LeNgoc13@gmail.com', 8376550013, false, NULL, 'Cashier', 'LeLoan', '$2a$06$KDzDXmVAVMTP6h5N5O8Af..O4GTUDB9PykZVL/kdv0uXr5ValRiDa', 4001141);
INSERT INTO employee.employees VALUES (31, 'Do Ngoc Nhi', '806 Ly Nam De', 'Quan 2', 'Bac Ninh', 'Nhi.DoNgoc3@gmail.com', 7614316903, false, NULL, 'Cashier', 'DoNhi', '$2a$06$YONXUsLZ4fTWRuqdEBN4K.U8h9wbKav4fKbz0Mb/5/QCn40A3p3Ja', 6706714);
INSERT INTO employee.employees VALUES (32, 'Dau Minh Minh', '214 Ho Tung Mau', 'Ngo Quyen', 'Da Nang', 'Minh.DauMinh18@gmail.com', 1945562018, false, NULL, 'Cashier', 'DauMinh', '$2a$06$PNEH9wyPdDsrT0Jf9.XureKSEHsi6SgWLVUq9eQcsTExgf9.5zdR2', 4437184);
INSERT INTO employee.employees VALUES (353, 'Ly Thi Cuong', '194 Hung Vuong', 'Quan 4', 'Gia Lai', 'Cuong.LyThi21@gmail.com', 7619542121, false, NULL, 'Shop Assistant', 'LyCuong', '$2a$06$DKQ2tXM6e8t8sIxrV3.nkurKT95NyqfxNboxUZ.0BhWnVRyH4oqfC', 6094744);
INSERT INTO employee.employees VALUES (354, 'Lac Khanh Nga', '330 Pham Ngu Lao', 'Son Tra', 'Gia Lai', 'Nga.LacKhanh47@gmail.com', 2115941747, false, NULL, 'Shop Assistant', 'LacNga', '$2a$06$v4Z7fxrEjILeke98wHY.e.6IApeN7VQrpn.qJFmF9TjNPY1GbxxJ6', 4499565);
INSERT INTO employee.employees VALUES (355, 'Quach Khanh Thanh', '776 Hang Khay', 'Tay Ho', 'Quang Nam', 'Thanh.QuachKhanh18@gmail.com', 1340899818, false, NULL, 'Shop Assistant', 'QuachThanh', '$2a$06$wsh9ONE5XzfGPU8GHoYs3uHc1IsM9L2TiGd7mI6l3dx2AeIkAGB66', 6031253);
INSERT INTO employee.employees VALUES (356, 'Nghiem Minh Khoa', '98 Tran Hung Dao', 'Ngo Quyen', 'Vung Tau', 'Khoa.NghiemMinh78@gmail.com', 4923353478, false, NULL, 'Shop Assistant', 'NghiemKhoa', '$2a$06$2v77vXR5qT57oZI.QN4MMuOKBBYfVdXDbYFP2s4T501QGFO5lArbC', 5330329);
INSERT INTO employee.employees VALUES (357, 'Luong Thanh Ha', '290 Lan Ong', 'Hoan Kiem', 'Nha Trang', 'Ha.LuongThanh73@gmail.com', 5467213673, false, NULL, 'Shop Assistant', 'LuongHa', '$2a$06$Y5m1qWj9nafXDmp2ZTxBdOY6Oi6d65PvIvKUEWYm6CjhNs3RfebMe', 4741193);
INSERT INTO employee.employees VALUES (358, 'Dinh Manh Thuy', '936 Hang Dao', 'Hai Chau', 'Yen Bai', 'Thuy.DinhManh90@gmail.com', 7514322390, false, NULL, 'Shop Assistant', 'DinhThuy', '$2a$06$EU0imrjWl0J5IvSyNr0/OefSZlXtZ8FbRocbPf5aEGdjDje4oQdAW', 5838249);
INSERT INTO employee.employees VALUES (359, 'Vu Manh My', '40 Hoang Cau', 'Hoan Kiem', 'Da Lat', 'My.VuManh22@gmail.com', 5640952022, false, NULL, 'Shop Assistant', 'VuMy', '$2a$06$FFxUmV.aNQ5664.d3EXig.0nLjnw0adaqBZelrii1hwB.88jnwm8e', 5385264);
INSERT INTO employee.employees VALUES (360, 'Doan Kieu Chien', '347 Hang Non', 'Quan 1', 'Da Nang', 'Chien.DoanKieu30@gmail.com', 5310608230, false, NULL, 'Shop Assistant', 'DoanChien', '$2a$06$P1WK144FHWUND88BEvu1/OIp.qJerrwKiy1ZM0NVV4H/qituRY2Jq', 6955950);
INSERT INTO employee.employees VALUES (361, 'Tran Khanh Linh', '773 Le Thanh Ton', 'Quan 4', 'Thai Nguyen', 'Linh.TranKhanh85@gmail.com', 8517666085, false, NULL, 'Shop Assistant', 'TranLinh', '$2a$06$5qOMpidXUCkF2Xe.d0nrfe07eXQHjCtbRXxztem09iAWRBVsUv3pG', 4118519);
INSERT INTO employee.employees VALUES (362, 'Tran Van Chien', '262 Thuoc Bac', 'Hai Ba Trung', 'Hue', 'Chien.TranVan90@gmail.com', 1904606690, false, NULL, 'Shop Assistant', 'TranChien', '$2a$06$zs92gQJMv4grJr0n.sCCqenmyTpjpF.Wlz8X3BX84.Dc6DPzsThQu', 6816539);
INSERT INTO employee.employees VALUES (363, 'Diep Ngoc Khang', '616 Hang Voi', 'Phu Nhuan', 'Phu Yen', 'Khang.DiepNgoc34@gmail.com', 5947736334, false, NULL, 'Shop Assistant', 'DiepKhang', '$2a$06$0NAvvI5uPc833g44twmFvuee6x/u6GhxPtIUbag4y.y.j986P9uD6', 5303944);
INSERT INTO employee.employees VALUES (364, 'Tong Nam Loan', '595 Pham Hong Thai', 'Binh Thanh', 'Hue', 'Loan.TongNam77@gmail.com', 3077620177, false, NULL, 'Shop Assistant', 'TongLoan', '$2a$06$z1jKAclAR0qQMo93sKYLtu1TxhrrSwGnlmZnI1ypxVaWAr3eJ8mNe', 5158370);
INSERT INTO employee.employees VALUES (365, 'Phan Thanh Linh', '81 Nguyen Sieu', 'Hoan Kiem', 'Thua Thien Hue', 'Linh.PhanThanh61@gmail.com', 8407150561, false, NULL, 'Shop Assistant', 'PhanLinh', '$2a$06$OV8Zm.Jt/hxSRd2JsNob4ugKw4hy8F4ZAYiwMlRU8Q43Ku4x16wwq', 6923118);
INSERT INTO employee.employees VALUES (366, 'Cao Thanh An', '834 Le Thanh Ton', 'Hai Chau', 'Binh Thuan', 'An.CaoThanh68@gmail.com', 6198596668, false, NULL, 'Shop Assistant', 'CaoAn', '$2a$06$c.vHN01tY9t9JDl6c5nNYuj.bhdmFkxRsBEi7TzCVDOX3meloXKuK', 4400421);
INSERT INTO employee.employees VALUES (367, 'Ngo Hoang Quynh', '946 Hang Can', 'Thanh Xuan', 'Ha Nam', 'Quynh.NgoHoang29@gmail.com', 1795196129, false, NULL, 'Shop Assistant', 'NgoQuynh', '$2a$06$7/WSzvRi8zOF/ThZG3PDf./39zlZqBOw4fCyYATNBKg4P79W4Dsii', 4437932);
INSERT INTO employee.employees VALUES (368, 'Nguyen Hai Thanh', '590 Xuan Thuy', 'Quan 3', 'Quang Binh', 'Thanh.NguyenHai3@gmail.com', 3017283303, false, NULL, 'Shop Assistant', 'NguyenThanh', '$2a$06$vNNKa395DJngYfFSDQDqLOnOLWxu72dWN5uXxMeLGCvOHakVL3KWW', 5215641);
INSERT INTO employee.employees VALUES (369, 'Dinh Chi Bang', '231 Tran Phu', 'Thanh Xuan', 'Bien Hoa', 'Bang.DinhChi54@gmail.com', 5041870454, false, NULL, 'Shop Assistant', 'DinhBang', '$2a$06$U1dG0iX2M/jSEbpl737iReTCBuuQjs5iMjNCy64r/y/hUxHhmYoq6', 5559844);
INSERT INTO employee.employees VALUES (370, 'Ngo Van Tuyen', '676 Hang Bong', 'Long Bien', 'Quang Ninh', 'Tuyen.NgoVan46@gmail.com', 5089060946, false, NULL, 'Shop Assistant', 'NgoTuyen', '$2a$06$jbf.ai2b2HFVNvEz.MqC8OxnIOPIIvz/7tf4RjzdgQ7BJhIw4Aiv2', 5740940);
INSERT INTO employee.employees VALUES (371, 'Do Hoang Loan', '796 Hang Da', 'Binh Thanh', 'Dak Lak', 'Loan.DoHoang1@gmail.com', 2808652901, false, NULL, 'Shop Assistant', 'DoLoan', '$2a$06$ZQ6w511RazuXah9BX42s.ud19aZ2yahrNLlB5daCu8mV61lOJUv4O', 5091504);
INSERT INTO employee.employees VALUES (372, 'Do Khanh Quynh', '213 Hang Tre', 'Cau Giay', 'Ho Chi Minh', 'Quynh.DoKhanh96@gmail.com', 1717692396, false, NULL, 'Shop Assistant', 'DoQuynh', '$2a$06$ySrd2yHIB3rA8ZVrym1EYOwnuXVaomRwLEGL/4HysSmZ0b7popxTS', 5473401);
INSERT INTO employee.employees VALUES (33, 'Cao Chi Bang', '555 Nguyen Sieu', 'Ba Dinh', 'Bien Hoa', 'Bang.CaoChi8@gmail.com', 6702177308, false, NULL, 'Cashier', 'CaoBang', '$2a$06$L0FEtxE2LVAQczpGDHWaIuteUlwgXi8JyIGulW2aGRcjzP971xZnO', 6228150);
INSERT INTO employee.employees VALUES (34, 'Huynh Nam Binh', '788 Ho Tung Mau', 'Long Bien', 'Quang Tri', 'Binh.HuynhNam95@gmail.com', 6578885995, false, NULL, 'Cashier', 'HuynhBinh', '$2a$06$oeowgHt1AvK8kqqeBwsnD.WTZXS4MTYSz5s636VdZ/nk67KUGSol6', 5877350);
INSERT INTO employee.employees VALUES (35, 'Quach Van Trinh', '956 Pham Ngu Lao', 'Dong Da', 'Thua Thien Hue', 'Trinh.QuachVan94@gmail.com', 5065812994, false, NULL, 'Cashier', 'QuachTrinh', '$2a$06$iRNSjer2fWxI5mhA7INy/egUkeOp0odxkI6jp2LgqWtbvOEBJfQEu', 4397410);
INSERT INTO employee.employees VALUES (36, 'Nghiem Thanh Huy', '632 Pham Hong Thai', 'Nam Tu Liem', 'Ho Chi Minh', 'Huy.NghiemThanh74@gmail.com', 9528460174, false, NULL, 'Cashier', 'NghiemHuy', '$2a$06$AM3a4h4J7NtcWYcTaW/u4ODKjsEZR8MJEVyJsEtrNdfuG3i8BPzma', 5126731);
INSERT INTO employee.employees VALUES (373, 'Dinh Van My', '871 Luong Dinh Cua', 'Dong Da', 'Quang Ninh', 'My.DinhVan66@gmail.com', 4939626066, false, NULL, 'Shop Assistant', 'DinhMy', '$2a$06$6abFg0hT/qIAyIRdHU9fKu8eL9qmXWlkV/wjW1XMSfk6Dc0q.nf2G', 4466357);
INSERT INTO employee.employees VALUES (374, 'Hoang Nam Hung', '21 Hang Voi', 'Phu Nhuan', 'Quang Binh', 'Hung.HoangNam16@gmail.com', 5835920016, false, NULL, 'Shop Assistant', 'HoangHung', '$2a$06$1G.TN8g5tGe0w14Gfo7FhOFYc0AihVshl4jEhVMufe6ou/1rwt2ZK', 6225248);
INSERT INTO employee.employees VALUES (375, 'Ta Khanh Thanh', '492 Phan Dinh Phung', 'Thanh Khe', 'Hai Phong', 'Thanh.TaKhanh48@gmail.com', 1467999148, false, NULL, 'Shop Assistant', 'TaThanh', '$2a$06$nFMr4U.p8tZ1Z.cbmzRTyOfjccX.d/9.FY5YWXkw1Hp0RY0ZctyZq', 4022670);
INSERT INTO employee.employees VALUES (376, 'Phan Tuan Quynh', '957 Ngo Quyen', 'Ha Dong', 'Binh Thuan', 'Quynh.PhanTuan71@gmail.com', 9591731771, false, NULL, 'Shop Assistant', 'PhanQuynh', '$2a$06$usftD5HksYY59y0lDvYwP.ubrW8j3e8SpDWk4GiYNXL1y0nFFbQH2', 5472285);
INSERT INTO employee.employees VALUES (377, 'Duong Tuan Anh', '611 Nguyen Trai', 'Bac Tu Liem', 'Phu Tho', 'Anh.DuongTuan90@gmail.com', 7497365090, false, NULL, 'Shop Assistant', 'DuongAnh', '$2a$06$8nuEe4MAjdpaXE8z3aUS4eEKYbz/7RAV4pjIIcK6JL1KUdll7amKe', 5562853);
INSERT INTO employee.employees VALUES (378, 'Vo Thanh Hai', '69 Nguyen Sieu', 'Quan 4', 'Phu Tho', 'Hai.VoThanh32@gmail.com', 8964560932, false, NULL, 'Shop Assistant', 'VoHai', '$2a$06$AR4W9ZR/Dc0PsOf.YFPHiOQlPF4tjwjWqfsVU6kvkJU/za6KxuYB6', 4397678);
INSERT INTO employee.employees VALUES (379, 'Cao Van Tuyen', '262 Le Ngoc Han', 'Binh Thanh', 'Hue', 'Tuyen.CaoVan93@gmail.com', 2121977493, false, NULL, 'Shop Assistant', 'CaoTuyen', '$2a$06$uSGL3VQyublBV2jD35c9recoqd9fP7Lwrbr9WsOcsQ2JFb/cDKeJm', 5173727);
INSERT INTO employee.employees VALUES (380, 'Tieu Van Linh', '502 Phan Dinh Phung', 'Hong Bang', 'Thai Nguyen', 'Linh.TieuVan6@gmail.com', 9375716406, false, NULL, 'Shop Assistant', 'TieuLinh', '$2a$06$O2m0xwPRLfwjqQwe0/d4O.4YTggQoYS5MxkvGO0FlzUGNqxmTOWTa', 5760690);
INSERT INTO employee.employees VALUES (381, 'Duong Manh Quynh', '710 Nguyen Trai', 'Phu Nhuan', 'Bac Ninh', 'Quynh.DuongManh91@gmail.com', 8617060691, false, NULL, 'Shop Assistant', 'DuongQuynh', '$2a$06$5.22Wq.d/IEluGr8nGsfmOWYky2ehtOALqOIi6tO5pdgJkYE7JzRu', 4993043);
INSERT INTO employee.employees VALUES (382, 'Ta Van Lam', '205 Thuoc Bac', 'Ba Dinh', 'Quang Binh', 'Lam.TaVan54@gmail.com', 9169844054, false, NULL, 'Shop Assistant', 'TaLam', '$2a$06$JCf6PfW8CfaGGO8rzcM//.owIUgkX9TylTjE50L6oglqo21HGGvE6', 4622770);
INSERT INTO employee.employees VALUES (383, 'Duong Minh Thu', '286 Ly Thuong Kiet', 'Quan 2', 'Yen Bai', 'Thu.DuongMinh71@gmail.com', 2357113171, false, NULL, 'Shop Assistant', 'DuongThu', '$2a$06$9PQxXzunDKYmzOe2d4EqMeg10vDpMqe2WP4DUAkU7yHyZGyVYrYiu', 5616481);
INSERT INTO employee.employees VALUES (384, 'Hoang Thanh Quynh', '669 Phan Dinh Phung', 'Long Bien', 'Binh Thuan', 'Quynh.HoangThanh81@gmail.com', 4383612681, false, NULL, 'Shop Assistant', 'HoangQuynh', '$2a$06$VixhAUTIoYzdwItPw2Jy6eSDYtuvzAxV4D3aryDuof4SV4fRdXUae', 5219623);
INSERT INTO employee.employees VALUES (385, 'Huynh Ngoc Nhi', '656 Hoang Cau', 'Hoang Mai', 'Ninh Thuan', 'Nhi.HuynhNgoc40@gmail.com', 8395398040, false, NULL, 'Shop Assistant', 'HuynhNhi', '$2a$06$TGVy4kQnYBQNawojwQ223Oq7UQSifJ8DaRqjh0CBM33PZtxvsPah6', 5009982);
INSERT INTO employee.employees VALUES (386, 'Nguyen Manh Anh', '708 Lan Ong', 'Hai Chau', 'Quang Ninh', 'Anh.NguyenManh94@gmail.com', 4743866594, false, NULL, 'Shop Assistant', 'NguyenAnh', '$2a$06$l1VNNLQVsj9pseofR18/m.2j/fzBkj/WxVmsZEpYlWADmgbCWJOsm', 6159159);
INSERT INTO employee.employees VALUES (387, 'Luong Van Tuyen', '99 Luong Van Can', 'Ngo Quyen', 'Vung Tau', 'Tuyen.LuongVan81@gmail.com', 7366763581, false, NULL, 'Shop Assistant', 'LuongTuyen', '$2a$06$oxBrm0y7PzV.uIZCM5hCkeyeyRhOwQyrqL.hbkFOqjg/2M0owY4dK', 6887588);
INSERT INTO employee.employees VALUES (388, 'Duong Ngoc Tu', '766 Phung Hung', 'Phu Nhuan', 'Khanh Hoa', 'Tu.DuongNgoc91@gmail.com', 3096527291, false, NULL, 'Shop Assistant', 'DuongTu', '$2a$06$CGr4LR.jUiS9TTMYoFitgubSDlpwtcsRlpqrasV8n0wo9vr/d4seu', 6526942);
INSERT INTO employee.employees VALUES (389, 'Nguyen Van Ly', '317 Hang Voi', 'Ba Dinh', 'Nha Trang', 'Ly.NguyenVan21@gmail.com', 6551852621, false, NULL, 'Customer Service Representative', 'NguyenLy', '$2a$06$WXtOZLnufU3vrrRqtpIkeeaYb3X.KiE12ZBOMgdedmbOlk8g1zwLe', 4943538);
INSERT INTO employee.employees VALUES (390, 'Ta Tuan Huyen', '538 Pham Ngu Lao', 'Ngo Quyen', 'Phu Tho', 'Huyen.TaTuan87@gmail.com', 9301200387, false, NULL, 'Customer Service Representative', 'TaHuyen', '$2a$06$ldDBFay4ZAVtKLz1cJsu.uDT0zYrlFY9dQMWThB8PJ8G5mr5QbceC', 6189106);
INSERT INTO employee.employees VALUES (391, 'Le Ngoc Huong', '650 Phung Hung', 'Quan 5', 'Ha Nam', 'Huong.LeNgoc1@gmail.com', 6213088301, false, NULL, 'Customer Service Representative', 'LeHuong', '$2a$06$NBftQwpe3l3O69bvITKPU.fFIZTEN6oXPDWwQih/BqnEcdbCnqMse', 6070697);
INSERT INTO employee.employees VALUES (392, 'Cao Manh Huy', '538 Hang Chieu', 'Tay Ho', 'Ha Noi', 'Huy.CaoManh73@gmail.com', 5004158973, false, NULL, 'Customer Service Representative', 'CaoHuy', '$2a$06$OuHpW2gQyGVob9/IBA0E3eGLrucfbHAqIAQhVFYV5Q4k0On2TF/C2', 5186475);
INSERT INTO employee.employees VALUES (393, 'Huynh Nam Lam', '693 Thuoc Bac', 'Ngo Quyen', 'Quang Ngai', 'Lam.HuynhNam46@gmail.com', 4936177946, false, NULL, 'Customer Service Representative', 'HuynhLam', '$2a$06$OJr8xMNFkRVMKv6Y4R26gOFEn10n.SWfXEwVtZx38P5Ndr42i0eT2', 6124764);
INSERT INTO employee.employees VALUES (394, 'Phan Thanh Long', '322 Hang Ca', 'Le Chan', 'Vung Tau', 'Long.PhanThanh45@gmail.com', 7270172245, false, NULL, 'Customer Service Representative', 'PhanLong', '$2a$06$d6eZhOBVZPM4V7rRiMzIJOzYSYUAto2J.WwUrxVRQhz9JQPuXPtiG', 6696453);
INSERT INTO employee.employees VALUES (395, 'Trinh Hai Tien', '709 Le Ngoc Han', 'Ba Dinh', 'Bac Ninh', 'Tien.TrinhHai6@gmail.com', 6264557006, false, NULL, 'Customer Service Representative', 'TrinhTien', '$2a$06$UCoFc/EMw0MIOrXL0Cn9R.cmQl3JyVpoMEED9lFKinMGPb4cHXBse', 5533497);
INSERT INTO employee.employees VALUES (396, 'Vo Kieu Nam', '183 Tran Hung Dao', 'Dong Da', 'Can Tho', 'Nam.VoKieu45@gmail.com', 7708144345, false, NULL, 'Customer Service Representative', 'VoNam', '$2a$06$UMkyHfIbgTYjGdeuqc7MVu6b/vEhArOSxiX3to3k9PcM61UBuUYrK', 5763606);
INSERT INTO employee.employees VALUES (397, 'Huynh Khanh Thu', '83 Hang Bo', 'Hai Ba Trung', 'Can Tho', 'Thu.HuynhKhanh17@gmail.com', 3418461917, false, NULL, 'Customer Service Representative', 'HuynhThu', '$2a$06$aSp8wy150J65ISSrRoZxxu66K1dGfygzt6ptqDOlh5iSk1vuxp5J6', 6701611);
INSERT INTO employee.employees VALUES (398, 'Doan Van Khanh', '338 Phan Chu Trinh', 'Hai Chau', 'Bien Hoa', 'Khanh.DoanVan31@gmail.com', 6592437931, false, NULL, 'Customer Service Representative', 'DoanKhanh', '$2a$06$rMnEFlxnvERLzYCgGGEbWuDQKnTr.py3/4dLLE5RVfnlXIWXXZWHC', 5254832);
INSERT INTO employee.employees VALUES (399, 'Vo Van Khanh', '469 Nguyen Xi', 'Ngo Quyen', 'Quang Tri', 'Khanh.VoVan96@gmail.com', 8893383696, false, NULL, 'Customer Service Representative', 'VoKhanh', '$2a$06$MDAuOmgNh3/hASS0blhuaOEMYVKBZk0BFdMwZoHdM3TVhb9dLAng6', 4813162);
INSERT INTO employee.employees VALUES (400, 'Lac Hai Thuy', '576 Giang Vo', 'Cam Le', 'Thua Thien Hue', 'Thuy.LacHai52@gmail.com', 6959191552, false, NULL, 'Customer Service Representative', 'LacThuy', '$2a$06$nBr2H1EDHen6oe7SY.VciervxPdaKnTIQ3oezt8HyOIPJ9lhYRGMm', 4870995);
INSERT INTO employee.employees VALUES (37, 'Le Minh Nhi', '288 Tran Phu', 'Quan 3', 'Da Nang', 'Nhi.LeMinh93@gmail.com', 4443085093, false, NULL, 'Cashier', 'LeNhi', '$2a$06$c0ZWyADBjTUFhZMhfzX4qewJ8RD3NZZAljfM6anMGJrNLt1BSQO0y', 6592949);
INSERT INTO employee.employees VALUES (38, 'Dinh Chi Ha', '24 Le Duan', 'Cam Le', 'Ha Noi', 'Ha.DinhChi3@gmail.com', 4622594103, false, NULL, 'Cashier', 'DinhHa', '$2a$06$SfhpuETnaGb0EdxiucDjn.SMw9B6DBeLqWDrJxinQS6D5OYl0pWXC', 6980597);
INSERT INTO employee.employees VALUES (39, 'Huynh Thanh An', '186 Phan Chu Trinh', 'Quan 3', 'Dak Lak', 'An.HuynhThanh57@gmail.com', 5605632857, false, NULL, 'Cashier', 'HuynhAn', '$2a$06$nW9UJ5kelOptRPq7RvgD9..sz1S9XWIEOlRIKwEbaBCiAYNM696WC', 4788813);
INSERT INTO employee.employees VALUES (40, 'Trinh Kieu Trang', '441 Hang Dao', 'Dong Da', 'Dak Lak', 'Trang.TrinhKieu40@gmail.com', 9618572140, false, NULL, 'Cashier', 'TrinhTrang', '$2a$06$qxJChDezG9PPYbKC12Tmeut.hcxspHSGbfydhD4n3o1LXmB3guBRq', 4822878);
INSERT INTO employee.employees VALUES (41, 'Vo Tuan An', '999 Tran Dai Nghia', 'Hoang Mai', 'Vung Tau', 'An.VoTuan66@gmail.com', 5447459866, false, NULL, 'Cashier', 'VoAn', '$2a$06$i4D.1C3zoCx9pa9jL2tM.Oe3UoYOgf/MW1VpGUwewJFUf.lqgaXsq', 6704679);
INSERT INTO employee.employees VALUES (42, 'Ho Hoang Quynh', '269 Hang Can', 'Hai Chau', 'Quang Tri', 'Quynh.HoHoang42@gmail.com', 2710707742, false, NULL, 'Cashier', 'HoQuynh', '$2a$06$guvGJuzLAkYr56jH7gMcmucgNTHMS91YH7zf1Xf9jqNBFQ6SC8yNW', 4745364);
INSERT INTO employee.employees VALUES (43, 'Doan Hoang Van', '170 Hang Gai', 'Son Tra', 'Da Nang', 'Van.DoanHoang66@gmail.com', 3542742766, false, NULL, 'Cashier', 'DoanVan', '$2a$06$cYAl2DN6ooUrgCf5FPx1XO2E3Z3H1fh7hg0HFlg..C29.6yfeC83C', 6490283);
INSERT INTO employee.employees VALUES (44, 'Do Khanh Nga', '674 Hoang Quoc Viet', 'Quan 1', 'Phu Yen', 'Nga.DoKhanh29@gmail.com', 1112368929, false, NULL, 'Cashier', 'DoNga', '$2a$06$d1dfq2ewy0DV9OO1OdvJCeOy5EgHc7CcJLF7sOemVTXef962lBZVW', 4374141);
INSERT INTO employee.employees VALUES (401, 'Ly Manh Quynh', '433 Ho Tung Mau', 'Nam Tu Liem', 'Gia Lai', 'Quynh.LyManh75@gmail.com', 1601325575, false, NULL, 'Customer Service Representative', 'LyQuynh', '$2a$06$Fp/jFIw.xyrfK7DmBo95MuyVV8uMVjHCmOSgYXT5/QsdrzFF5Q112', 6882985);
INSERT INTO employee.employees VALUES (402, 'Dang Khanh Ha', '224 Hung Vuong', 'Hoan Kiem', 'Nha Trang', 'Ha.DangKhanh14@gmail.com', 6368793714, false, NULL, 'Customer Service Representative', 'DangHa', '$2a$06$2SLc6HxP7G6z6FsbaTvxh..96OVrnmllaOABGTwJ6Oia.IDrzGc3y', 5434070);
INSERT INTO employee.employees VALUES (403, 'Doan Thi Trang', '82 Ho Tung Mau', 'Ngo Quyen', 'Dak Lak', 'Trang.DoanThi33@gmail.com', 8236156133, false, NULL, 'Customer Service Representative', 'DoanTrang', '$2a$06$0WjXaselGajtw7THhsCvm.ZO6kyDfWnyIrVaveQ081EFGfTlQELeq', 6012510);
INSERT INTO employee.employees VALUES (404, 'Trinh Thi Phuong', '411 Hang Ca', 'Thanh Khe', 'Can Tho', 'Phuong.TrinhThi48@gmail.com', 8657489348, false, NULL, 'Customer Service Representative', 'TrinhPhuong', '$2a$06$wp44Yx4bNoaMJDt2EDduuO65w64fxKBn2FTRpZVf3qwBjfwhYH8/a', 6387126);
INSERT INTO employee.employees VALUES (405, 'Le Hai Trang', '300 Hang Can', 'Hai Chau', 'Quang Ninh', 'Trang.LeHai26@gmail.com', 7970886826, false, NULL, 'Customer Service Representative', 'LeTrang', '$2a$06$Upnrvumqzhy9zkKDnLgJDOIBuV2FU8.DkZ48dU3cTWjxDYHyKJu0e', 6007347);
INSERT INTO employee.employees VALUES (406, 'Phan Tuan Minh', '760 Ngo Quyen', 'Quan 3', 'Nha Trang', 'Minh.PhanTuan56@gmail.com', 8294815556, false, NULL, 'Customer Service Representative', 'PhanMinh', '$2a$06$1hgUQhRLSQJ6v/0WtwHuCeMRZ59edppcVjh7qnDz6DjV1N7kM/5Z6', 5732289);
INSERT INTO employee.employees VALUES (407, 'Pham Nam Cuong', '376 Hang Ma', 'Long Bien', 'Quang Ngai', 'Cuong.PhamNam59@gmail.com', 9486483559, false, NULL, 'Customer Service Representative', 'PhamCuong', '$2a$06$rHCpltw3IMcUxlm5dPpEyOeNY/4F6O9qGZDkvIo/HDPhoCI7VMEsm', 5900424);
INSERT INTO employee.employees VALUES (408, 'Lac Chi Giang', '924 Le Loi', 'Long Bien', 'Khanh Hoa', 'Giang.LacChi90@gmail.com', 6609659190, false, NULL, 'Customer Service Representative', 'LacGiang', '$2a$06$ioKBkOuyRWyKGH1Epd7piuoGOKI1yYnJfFUv2j8Gju2kKRE/HkhTK', 6126663);
INSERT INTO employee.employees VALUES (409, 'Phan Thi Thu', '268 Thuoc Bac', 'Cam Le', 'Thai Nguyen', 'Thu.PhanThi25@gmail.com', 3349228325, false, NULL, 'Customer Service Representative', 'PhanThu', '$2a$06$k/dtTr3T1Xuy7Livq4lQ5eWKuGM4fqj58Fn5cAxVpbyRELxSos89G', 5984644);
INSERT INTO employee.employees VALUES (410, 'Tieu Hoang Bang', '421 Hoang Cau', 'Ha Dong', 'Quy Nhon', 'Bang.TieuHoang87@gmail.com', 1290966487, false, NULL, 'Customer Service Representative', 'TieuBang', '$2a$06$3NLcrJzbe0Ga/ZaXVzu4L.SG5w5jYZXl4gy/MjKxOh08jVoL5MpQ.', 5925818);
INSERT INTO employee.employees VALUES (411, 'Luu Ngoc Nga', '153 Hang Bong', 'Long Bien', 'Ha Tinh', 'Nga.LuuNgoc4@gmail.com', 4776587404, false, NULL, 'Customer Service Representative', 'LuuNga', '$2a$06$vL1U4sLDSxxqYuIFJljIUORBK9RU9b.9HdhgU2zo4Pqo9wnB4zX/.', 4007240);
INSERT INTO employee.employees VALUES (412, 'Luong Minh Huy', '769 O Cho Dua', 'Phu Nhuan', 'Thua Thien Hue', 'Huy.LuongMinh6@gmail.com', 2869989906, false, NULL, 'Customer Service Representative', 'LuongHuy', '$2a$06$uzn/etiW4pj2R9vkFqy.b.tRibmJkKhy9ND3YtOk2iUIJIwufgBNa', 4638410);
INSERT INTO employee.employees VALUES (413, 'Ta Thanh Hung', '446 Hang Bo', 'Phu Nhuan', 'Bac Ninh', 'Hung.TaThanh17@gmail.com', 4704653017, false, NULL, 'Customer Service Representative', 'TaHung', '$2a$06$uqhNcZKYUar5C6ZThhHv1.8pmUJkQwHy2Wf.9QJn1k1v1CYzgZCAu', 6789796);
INSERT INTO employee.employees VALUES (414, 'Ho Tuan Ngoc', '689 Hang Mam', 'Ba Dinh', 'Dak Lak', 'Ngoc.HoTuan83@gmail.com', 8431164783, false, NULL, 'Customer Service Representative', 'HoNgoc', '$2a$06$YBghI8.lGqLlwf5AXQ7WDutLqlXMAO8KjXot371H.2uu7NXqK4O.6', 6379224);
INSERT INTO employee.employees VALUES (415, 'Nguyen Thanh Khang', '530 Hang Ma', 'Quan 3', 'Bien Hoa', 'Khang.NguyenThanh46@gmail.com', 7620523046, false, NULL, 'Customer Service Representative', 'NguyenKhang', '$2a$06$2wv1qKEJ6hSw0dRCIujG5eMXOLISzkQeM9KUF0.WBd2lgNbCn.uhi', 6239242);
INSERT INTO employee.employees VALUES (416, 'Ho Tuan Hung', '816 Pham Hong Thai', 'Long Bien', 'Thai Nguyen', 'Hung.HoTuan25@gmail.com', 8982032125, false, NULL, 'Customer Service Representative', 'HoHung', '$2a$06$zX3DTqsOw770R2bnj3uB8uawNFs/.NG7K4fSmVU.jCkZToqNrRd2G', 5866345);
INSERT INTO employee.employees VALUES (417, 'Vu Hoang Thu', '810 Hang Da', 'Binh Thanh', 'Nha Trang', 'Thu.VuHoang41@gmail.com', 5262790141, false, NULL, 'Customer Service Representative', 'VuThu', '$2a$06$URpYJXDp8t0ObrgL1VJzVu9Q4Qi262K5/l7y9ELnfglBstW2ft1lm', 4440474);
INSERT INTO employee.employees VALUES (418, 'Doan Hoang Thanh', '35 Ly Thuong Kiet', 'Ngo Quyen', 'Binh Thuan', 'Thanh.DoanHoang5@gmail.com', 3248256305, false, NULL, 'Customer Service Representative', 'DoanThanh', '$2a$06$eNaNVe1cKrKAep8iKC94OuSjW0v82nZfT3r.J8uUYrU0f0XblJCUa', 6244937);
INSERT INTO employee.employees VALUES (419, 'Ho Chi Xuan', '501 Le Ngoc Han', 'Quan 2', 'Phu Tho', 'Xuan.HoChi44@gmail.com', 9752521644, false, NULL, 'Customer Service Representative', 'HoXuan', '$2a$06$U5I.X52kPaP3CIaapHSNuOtAJDc8Yu7TlEzAed.Tqu1OE5jgtRC4a', 5235817);
INSERT INTO employee.employees VALUES (420, 'Duong Thi Cuong', '700 Le Thanh Ton', 'Quan 5', 'Quang Nam', 'Cuong.DuongThi42@gmail.com', 7926628642, false, NULL, 'Customer Service Representative', 'DuongCuong', '$2a$06$fWxuP8hTrTwAJlv62xBhzOjTCS9WBKiI2qsv1om/oJk2rE8o/JNTO', 4237175);
INSERT INTO employee.employees VALUES (45, 'Lac Thi Van', '134 Hang Luoc', 'Ba Dinh', 'Ninh Thuan', 'Van.LacThi28@gmail.com', 7044408528, false, NULL, 'Cashier', 'LacVan', '$2a$06$qwVDFkhlKy6wf4qbtBBbaeHnbn5cUha5/IUZfMdgd.l0CM3uiWaaO', 6687978);
INSERT INTO employee.employees VALUES (46, 'Nguyen Thi Long', '903 Hang Khay', 'Le Chan', 'Ha Tinh', 'Long.NguyenThi59@gmail.com', 3607778559, false, NULL, 'Cashier', 'NguyenLong', '$2a$06$DEiyg1m5hfbzq91OP7jVKOpLvMH288p5pLfuR0.wDGj0YwlafOfE.', 5703142);
INSERT INTO employee.employees VALUES (47, 'Nguyen Hoang Quynh', '434 Pham Hong Thai', 'Hoan Kiem', 'Bac Ninh', 'Quynh.NguyenHoang10@gmail.com', 2699393410, false, NULL, 'Cashier', 'NguyenQuynh', '$2a$06$542NoqnE/DiJdGm8qS2PVO/2fzjL5.loy.CO3MW77GVa09Ssa1Hbu', 4032470);
INSERT INTO employee.employees VALUES (48, 'Dinh Ngoc Trang', '532 Hang Da', 'Hoang Mai', 'Ha Nam', 'Trang.DinhNgoc23@gmail.com', 7076651723, false, NULL, 'Cashier', 'DinhTrang', '$2a$06$ImISdGguhP.k3jBFbDH87.XaUNRvN4Q/QQJRkfi/2oV7O3B9r2V2i', 4308580);
INSERT INTO employee.employees VALUES (49, 'Tieu Ngoc Binh', '981 Ly Nam De', 'Quan 3', 'Nam Dinh', 'Binh.TieuNgoc37@gmail.com', 1696924037, false, NULL, 'Cashier', 'TieuBinh', '$2a$06$F/3uj/KgoY2rgp3kuKrHPeuIf6uHTLaMnDRgru5WUfPQKfDB36Iom', 5396689);
INSERT INTO employee.employees VALUES (50, 'Vo Hoang Huyen', '703 Ba Trieu', 'Son Tra', 'Gia Lai', 'Huyen.VoHoang75@gmail.com', 6294900975, false, NULL, 'Cashier', 'VoHuyen', '$2a$06$NyVHQlU/wICyIiwSR.Vi5.YveOxJE1I75mPBHXjtDgfBfDw7t/Vq6', 4967342);
INSERT INTO employee.employees VALUES (51, 'Ta Ngoc My', '641 Ly Nam De', 'Cam Le', 'Khanh Hoa', 'My.TaNgoc0@gmail.com', 5066448100, false, NULL, 'Cashier', 'TaMy', '$2a$06$B8luGv1AgM8z/W8L9KMwMOZZx/ucNC6/hU0RJJaMTBh0zCgJGrlO2', 4285578);
INSERT INTO employee.employees VALUES (52, 'Ho Tuan Anh', '216 Hoang Quoc Viet', 'Hai Chau', 'Gia Lai', 'Anh.HoTuan30@gmail.com', 6338834330, false, NULL, 'Cashier', 'HoAnh', '$2a$06$eCyiJdPWU.wT8TaH8SPTkuIVMefTZ6t65Wb1NbK6srFNkUm8yc7Ni', 5939771);
INSERT INTO employee.employees VALUES (53, 'Dinh Tuan Nhi', '296 Hang Non', 'Ba Dinh', 'Nha Trang', 'Nhi.DinhTuan58@gmail.com', 7021890058, false, NULL, 'Cashier', 'DinhNhi', '$2a$06$69gDz4xSI8qzrERS8OjrseWco9JnK670SE1VVwfnOibHFO3IKQplC', 5006924);
INSERT INTO employee.employees VALUES (54, 'Tran Thanh Thao', '821 Luong Dinh Cua', 'Cam Le', 'Quy Nhon', 'Thao.TranThanh42@gmail.com', 3087089042, false, NULL, 'Cashier', 'TranThao', '$2a$06$vrGOebpmz/m2JC7ImY/QOuwNYOUpNnsOcGKgLqnrIg9hsdMmeKrmS', 5127022);
INSERT INTO employee.employees VALUES (421, 'Dang Tuan Huyen', '100 Xuan Thuy', 'Quan 3', 'Ninh Thuan', 'Huyen.DangTuan40@gmail.com', 7910605240, false, NULL, 'Customer Service Representative', 'DangHuyen', '$2a$06$OYju40Sj1bVe6C7uPbFi.e5j.bhlwiXtuyt6ScezAf9EZBlzbNmP2', 6018986);
INSERT INTO employee.employees VALUES (422, 'Ho Nam Lan', '241 Hoang Quoc Viet', 'Bac Tu Liem', 'Phu Yen', 'Lan.HoNam16@gmail.com', 6352052116, false, NULL, 'Customer Service Representative', 'HoLan', '$2a$06$I5Ohy7Wi8RetjGKEWYrza.sjT9mmKC5e8xmBCPFalJ5.g8KMSZpQ2', 4100894);
INSERT INTO employee.employees VALUES (423, 'Phan Chi Huong', '860 Le Thanh Ton', 'Quan 4', 'Phu Yen', 'Huong.PhanChi4@gmail.com', 6212321904, false, NULL, 'Customer Service Representative', 'PhanHuong', '$2a$06$6dsC2UisJA0Y2A.L1lZ3uuZ.lXfSwyStEQ34Ci.km/eLsF3ZkfgSG', 5209663);
INSERT INTO employee.employees VALUES (424, 'Phan Ngoc Huy', '256 Hang Mam', 'Nam Tu Liem', 'Phu Yen', 'Huy.PhanNgoc73@gmail.com', 7882316373, false, NULL, 'Customer Service Representative', 'PhanHuy', '$2a$06$ZucjjNEcXmVMnutJHRqB5u6YsVJreCoZBRsXjLg2.lausVNnaFiGC', 5019286);
INSERT INTO employee.employees VALUES (425, 'Tong Hai Hung', '405 Hang Gai', 'Quan 3', 'Hue', 'Hung.TongHai66@gmail.com', 2053015366, false, NULL, 'Customer Service Representative', 'TongHung', '$2a$06$rmS.9prYZb.lS0u0OTrjBuLLi6lx1LEPHDL2Dohgo1z6arJRd9yLq', 4199721);
INSERT INTO employee.employees VALUES (426, 'Dang Hoang Khang', '849 Hang Da', 'Hong Bang', 'Bien Hoa', 'Khang.DangHoang10@gmail.com', 3203641810, false, NULL, 'Customer Service Representative', 'DangKhang', '$2a$06$neMAfR.H1sXhk5ZNio6Zje89rtix2hSnK.A6MBM4W2oYkLUgMQ6n6', 6855992);
INSERT INTO employee.employees VALUES (427, 'Trinh Ngoc Loan', '257 Luong Van Can', 'Hong Bang', 'Gia Lai', 'Loan.TrinhNgoc74@gmail.com', 6122809774, false, NULL, 'Customer Service Representative', 'TrinhLoan', '$2a$06$l9C.VfATvwHyhwavhxapMu3wcAIYty4pk65n9DTjbW5Xx9VyJhPpG', 4432931);
INSERT INTO employee.employees VALUES (428, 'Nguyen Kieu Hai', '769 Kim Ma', 'Cam Le', 'Ha Noi', 'Hai.NguyenKieu53@gmail.com', 7520419553, false, NULL, 'Customer Service Representative', 'NguyenHai', '$2a$06$NjGL7rTCq2W5S0sV2JPkU.ywtPP0OoXeDL2VVbmQqZZ11y.apviJS', 4876685);
INSERT INTO employee.employees VALUES (429, 'Ta Hai Huong', '77 O Cho Dua', 'Tay Ho', 'Quang Nam', 'Huong.TaHai94@gmail.com', 8495853994, false, NULL, 'Customer Service Representative', 'TaHuong', '$2a$06$8I9yWfXwX62DkaBUuOUFG.88YVSCPc9bXeROCB5qrDt4M1WipdfgO', 4437531);
INSERT INTO employee.employees VALUES (430, 'Doan Khanh Nhung', '151 Hang Dao', 'Hai Ba Trung', 'Yen Bai', 'Nhung.DoanKhanh8@gmail.com', 1417721408, false, NULL, 'Customer Service Representative', 'DoanNhung', '$2a$06$A5g8RlekskpwluDnpE2kx.xvQOxlFiuL9tPUeZgXy8iLpeQEMONgK', 5686287);
INSERT INTO employee.employees VALUES (431, 'Vu Hoang Loan', '320 Pham Hong Thai', 'Bac Tu Liem', 'Hue', 'Loan.VuHoang15@gmail.com', 5285680415, false, NULL, 'Customer Service Representative', 'VuLoan', '$2a$06$lOhQbk9lITBs90YpQS7fe.HaAc.2NSIKuQyA.pVmzDOoz9dCDkgEW', 5826337);
INSERT INTO employee.employees VALUES (432, 'Tran Khanh Mai', '971 Hang Non', 'Bac Tu Liem', 'Thai Nguyen', 'Mai.TranKhanh73@gmail.com', 1369755773, false, NULL, 'Customer Service Representative', 'TranMai', '$2a$06$fwyaQS/DgdzJafv.QCyYeOQzGEP6yO28Si3Z88kkFn31zaUNSOms6', 6387834);
INSERT INTO employee.employees VALUES (433, 'Nguyen Tuan Lan', '689 Le Loi', 'Le Chan', 'Ha Tinh', 'Lan.NguyenTuan64@gmail.com', 3712797164, false, NULL, 'Customer Service Representative', 'NguyenLan', '$2a$06$8xnLINdNbj7OrrMxc3UMIe5UEBCyz.tyocXh11cSnq595iXpIHQRe', 4076559);
INSERT INTO employee.employees VALUES (434, 'Duong Kieu Trang', '346 Hang Mam', 'Bac Tu Liem', 'Phu Tho', 'Trang.DuongKieu17@gmail.com', 7976354117, false, NULL, 'Customer Service Representative', 'DuongTrang', '$2a$06$vaqzl4/UpSKq5JvPzP0Ia.wZo8CXfKZYq17BuQt2rs5VqmWQBnDe2', 4495041);
INSERT INTO employee.employees VALUES (435, 'Nghiem Minh Nhung', '366 Hang Ca', 'Ha Dong', 'Ninh Thuan', 'Nhung.NghiemMinh64@gmail.com', 1393837464, false, NULL, 'Customer Service Representative', 'NghiemNhung', '$2a$06$bpFjz8x8EcNRBE/MOtZ8j.PlCgR8hTl/aqdIw4K004OfVjR5A/j7K', 6128912);
INSERT INTO employee.employees VALUES (436, 'Ngo Hoang Khanh', '624 Luong Van Can', 'Hoang Mai', 'Da Nang', 'Khanh.NgoHoang61@gmail.com', 5930762061, false, NULL, 'Customer Service Representative', 'NgoKhanh', '$2a$06$E1/RfpygZsdULZgE6azCvOFy5TsQvyWQKZQwEh6ygpoZvBAD/6iSm', 4996802);
INSERT INTO employee.employees VALUES (55, 'Vu Chi Hung', '79 Phan Dinh Phung', 'Hong Bang', 'Da Nang', 'Hung.VuChi77@gmail.com', 4204747977, false, NULL, 'Cashier', 'VuHung', '$2a$06$wyuaYZWWtpNDPh55GuaGCOHUyjhMBuRGaI5KvjJ.opmxXQOxOiAye', 4663624);
INSERT INTO employee.employees VALUES (56, 'Huynh Manh Ngoc', '503 Ly Nam De', 'Hai Chau', 'Quang Ngai', 'Ngoc.HuynhManh96@gmail.com', 4410912596, false, NULL, 'Cashier', 'HuynhNgoc', '$2a$06$/UUsX6Gus3pqTO1./Slls.eXUunUONiRAyls6OFc9YqlJeNOIN5FG', 6263645);
INSERT INTO employee.employees VALUES (57, 'Diep Minh Binh', '565 Hang Da', 'Hong Bang', 'Quang Ninh', 'Binh.DiepMinh0@gmail.com', 3074490100, false, NULL, 'Cashier', 'DiepBinh', '$2a$06$c8sdxxZwK0rl8uGUtS07WOCqtJh4qapuz2Y7V0rJuynla3OmTMKte', 4972519);
INSERT INTO employee.employees VALUES (58, 'Dang Kieu Linh', '659 Hang Bong', 'Quan 2', 'Bac Ninh', 'Linh.DangKieu48@gmail.com', 6119592048, false, NULL, 'Cashier', 'DangLinh', '$2a$06$kaXVFysSi9yB15uMRbgw3OKct2eKQ9p9oO5TfbdAjROFm7mtv90pO', 6410898);
INSERT INTO employee.employees VALUES (59, 'Dinh Kieu Anh', '528 Giang Vo', 'Hoang Mai', 'Quy Nhon', 'Anh.DinhKieu83@gmail.com', 8483375583, false, NULL, 'Cashier', 'DinhAnh', '$2a$06$FR0OeDTXmXk2tReFe6ZDe.IH3RyLhKocbrqzImHTJqeBYCKve2TAi', 5714986);
INSERT INTO employee.employees VALUES (60, 'Doan Nam Loan', '848 Ngo Quyen', 'Hoan Kiem', 'Khanh Hoa', 'Loan.DoanNam97@gmail.com', 3039814997, false, NULL, 'Cashier', 'DoanLoan', '$2a$06$T94h1wE2XSZwoZBwJ.So9exjY4SMUJRh/VDYpofJEadraxcisQvwK', 5292459);
INSERT INTO employee.employees VALUES (61, 'Ngo Thi Bang', '721 Ly Thuong Kiet', 'Le Chan', 'Vung Tau', 'Bang.NgoThi29@gmail.com', 1270848429, false, NULL, 'Cashier', 'NgoBang', '$2a$06$8rp1QAcZvnBO0xO/FcE8KOQzVmee46lmKZIMs.vbKF.caEOL1z9we', 5916821);
INSERT INTO employee.employees VALUES (62, 'Vo Thi Nga', '189 Le Duan', 'Hong Bang', 'Yen Bai', 'Nga.VoThi19@gmail.com', 5677848719, false, NULL, 'Cashier', 'VoNga', '$2a$06$6G4/3ACNy63AvyAvqRCdv.RTGibjb6GEKOVnZ6cFHyccxY2OZXrUa', 5344171);
INSERT INTO employee.employees VALUES (63, 'Bui Hai Hung', '456 Tran Quoc Toan', 'Cam Le', 'Quang Binh', 'Hung.BuiHai49@gmail.com', 4670357749, false, NULL, 'Cashier', 'BuiHung', '$2a$06$i7UJ84uASepTrYw8P.q7NudMJQcBxD2cLB1SFfEg.6RuglTWPJXNS', 6364919);
INSERT INTO employee.employees VALUES (64, 'Dinh Kieu Cuong', '902 Tran Quoc Toan', 'Hoan Kiem', 'Da Lat', 'Cuong.DinhKieu19@gmail.com', 1736064319, false, NULL, 'Cashier', 'DinhCuong', '$2a$06$fUDwkTDvbWSrsGWqe./8petq9qCkQqwDkxfH.CVAiEWFq8xmIKf.S', 4866260);
INSERT INTO employee.employees VALUES (65, 'Huynh Hoang Minh', '819 Hang Non', 'Phu Nhuan', 'Quy Nhon', 'Minh.HuynhHoang0@gmail.com', 1012207100, false, NULL, 'Cashier', 'HuynhMinh', '$2a$06$rzrB1625OgdbGOXRsxWruuHa3FRa9BhHzcImeQyCV22CTy1glouNK', 6639103);
INSERT INTO employee.employees VALUES (66, 'Tong Thanh Hoa', '547 Hang Voi', 'Hoan Kiem', 'Nha Trang', 'Hoa.TongThanh64@gmail.com', 1983521964, false, NULL, 'Cashier', 'TongHoa', '$2a$06$HfR/dQOJ6y6krn15qIG33OvEtvnHn3dObo4EFsMNOw2emfx.KDXyq', 5825282);
INSERT INTO employee.employees VALUES (67, 'Dang Minh Cuong', '281 Hang Da', 'Le Chan', 'Thai Nguyen', 'Cuong.DangMinh37@gmail.com', 2488418537, false, NULL, 'Cashier', 'DangCuong', '$2a$06$cY1Feu.2NslOB5NL8ZQTRewVu6jM0sx6.nCGmiN4gXFuJsiD.wrLS', 4974046);
INSERT INTO employee.employees VALUES (68, 'Duong Ngoc Bang', '145 Phan Dinh Phung', 'Ngo Quyen', 'Ha Nam', 'Bang.DuongNgoc67@gmail.com', 4483075867, false, NULL, 'Cashier', 'DuongBang', '$2a$06$ahRCoFugggtpV.iOG/KM7uGJhRrZrL4Pl8obVJ9vvpmEJ43XTjAPS', 5582441);
INSERT INTO employee.employees VALUES (69, 'Nghiem Chi Ngan', '475 Ly Nam De', 'Le Chan', 'Khanh Hoa', 'Ngan.NghiemChi91@gmail.com', 2651666291, false, NULL, 'Cashier', 'NghiemNgan', '$2a$06$pQuqk0TH0UUS73n/xfJeeOc7FCS7/4lNp9ZjsJAQ78M5IEMDSohr2', 5656952);
INSERT INTO employee.employees VALUES (70, 'Diep Thi Nam', '546 Hang Dao', 'Tay Ho', 'Thai Nguyen', 'Nam.DiepThi49@gmail.com', 4202748149, false, NULL, 'Cashier', 'DiepNam', '$2a$06$YmnDkXPvLiOvsTrixAG2CuG4T2GRA87DDyVpwCshhg0oLc7QrIPRK', 6137330);
INSERT INTO employee.employees VALUES (71, 'Dinh Hai Quynh', '508 Hang Gai', 'Hoang Mai', 'Binh Thuan', 'Quynh.DinhHai13@gmail.com', 9661520513, false, NULL, 'Cashier', 'DinhQuynh', '$2a$06$0coywVcxR1Ytuf2aKtFUqe6.7SoLX6AbAwudZ0s6bmQVBj9a2Z.J6', 6955601);
INSERT INTO employee.employees VALUES (72, 'Pham Hoang Giang', '886 Hang Tre', 'Ba Dinh', 'Ha Nam', 'Giang.PhamHoang17@gmail.com', 4914320417, false, NULL, 'Cashier', 'PhamGiang', '$2a$06$rTFFD/r1yQv9zqW.mwP1m.xKFNpqR6ozZvYEZxJtSrdd/yXVRddLC', 4499792);
INSERT INTO employee.employees VALUES (75, 'Ta Chi Nhung', '241 Hang Tre', 'Nam Tu Liem', 'Hue', 'Nhung.TaChi29@gmail.com', 1869566229, false, NULL, 'Cashier', 'TaNhung', '$2a$06$2A4AInh.O5grxFPWVo8qZumZWD79gAQoqOq2fQQMuy/yQ.bl1DGDK', 5496504);
INSERT INTO employee.employees VALUES (76, 'Cao Thi Thanh', '205 Hoang Cau', 'Tay Ho', 'Quy Nhon', 'Thanh.CaoThi6@gmail.com', 4911861206, false, NULL, 'Cashier', 'CaoThanh', '$2a$06$fPENCc1pNc1r2vIBYNUiMuub6kLN.r1iqR5P.G3iIxXnwofE9f5WC', 6756001);
INSERT INTO employee.employees VALUES (77, 'Bui Khanh Thuy', '849 Pham Ngu Lao', 'Son Tra', 'Hai Phong', 'Thuy.BuiKhanh19@gmail.com', 9485826019, false, NULL, 'Cashier', 'BuiThuy', '$2a$06$uCZLvupzUg.1OELyh.eZv.vsMrThvlC4tmEUuhK5qPtGjBR9jMqR6', 4082961);
INSERT INTO employee.employees VALUES (78, 'Nghiem Kieu Khanh', '283 Hang Ca', 'Binh Thanh', 'Yen Bai', 'Khanh.NghiemKieu20@gmail.com', 6866164920, false, NULL, 'Cashier', 'NghiemKhanh', '$2a$06$ncSqUdoWsRdfSWybr/2zkeum/2.KJErV8Vt41/.76QXsQYHqCDoce', 5312613);
INSERT INTO employee.employees VALUES (79, 'Lac Van Xuan', '386 Nguyen Trai', 'Dong Da', 'Quang Binh', 'Xuan.LacVan10@gmail.com', 8745867410, false, NULL, 'Cashier', 'LacXuan', '$2a$06$hDzzKkfI2H15Jap2UweD7uVuVgss/UAd.5PU9EQCuOwzVoDOmjiI6', 5483463);
INSERT INTO employee.employees VALUES (80, 'Pham Nam Dong', '745 Ton Duc Thang', 'Hai Ba Trung', 'Dak Lak', 'Dong.PhamNam96@gmail.com', 5556689696, false, NULL, 'Cashier', 'PhamDong', '$2a$06$w4wbqnOohFyEf1fmk3Gw.Ol5IYQdjyqMQdTYfW9BwIZRpWGyA0rY2', 5957838);
INSERT INTO employee.employees VALUES (81, 'Duong Minh Huong', '647 Tran Quoc Toan', 'Thanh Khe', 'Quy Nhon', 'Huong.DuongMinh53@gmail.com', 4919045653, false, NULL, 'Cashier', 'DuongHuong', '$2a$06$dZ1D9EFPdntzB1ACC52LBuUMV.0maJN0QAQaUaYm2OTTYk/vt.eDO', 5418674);
INSERT INTO employee.employees VALUES (82, 'Lac Chi Phuong', '977 Tran Dai Nghia', 'Quan 5', 'Quang Ngai', 'Phuong.LacChi40@gmail.com', 9349540540, false, NULL, 'Cashier', 'LacPhuong', '$2a$06$HqIW4k035ZMGgrLiMS6v0uMhAVuWODyYcxwxD9DeDmhOG6EFJ//4.', 6729328);
INSERT INTO employee.employees VALUES (83, 'Trinh Van Sang', '669 Ly Nam De', 'Cau Giay', 'Vung Tau', 'Sang.TrinhVan52@gmail.com', 4613744352, false, NULL, 'Cashier', 'TrinhSang', '$2a$06$6wpRoTuD6iQwBPHVXKIzAeRbMzEi.psdkCVi5OAWJk.nyo9rf7ENa', 5729655);
INSERT INTO employee.employees VALUES (84, 'Ly Thi Khoa', '89 Tran Dai Nghia', 'Ba Dinh', 'Ninh Thuan', 'Khoa.LyThi47@gmail.com', 5716843547, false, NULL, 'Cashier', 'LyKhoa', '$2a$06$1w03TwUnqzil0gHJDWrQQeuBmZKp5sOBvnKO3yTah33pN25pxR17C', 5575606);
INSERT INTO employee.employees VALUES (85, 'Huynh Thi Ly', '305 Hang Mam', 'Quan 3', 'Yen Bai', 'Ly.HuynhThi17@gmail.com', 6057853517, false, NULL, 'Cashier', 'HuynhLy', '$2a$06$mS/fmnxZDF00jJzTYPjjouyr6C2bKwXYPL6YTyzFNhwm7yE7scSAS', 5585273);
INSERT INTO employee.employees VALUES (86, 'Tong Manh Giang', '111 Lan Ong', 'Hai Ba Trung', 'Gia Lai', 'Giang.TongManh59@gmail.com', 8211152959, false, NULL, 'Cashier', 'TongGiang', '$2a$06$MRlPQBsxPainbn06GyywneO2B9Pn6xwtKTfcUX/ECd95f9xnoh01m', 5871455);
INSERT INTO employee.employees VALUES (87, 'Tong Thi Ngan', '163 Hang Voi', 'Tay Ho', 'Quang Tri', 'Ngan.TongThi37@gmail.com', 9975006037, false, NULL, 'Cashier', 'TongNgan', '$2a$06$fveMSypSB4RS2uvom35ke.b64CoeDrHQOv7ggrNALGPKLgw2ch1xC', 6715471);
INSERT INTO employee.employees VALUES (88, 'Ta Manh Chien', '252 Hang Voi', 'Hai Ba Trung', 'Quy Nhon', 'Chien.TaManh72@gmail.com', 9109172572, false, NULL, 'Cashier', 'TaChien', '$2a$06$9pi8bY9IK1hICsOe2vCtZ.90przytBhpi1OUD50GKYkhsGXf3Uxr6', 6404532);
INSERT INTO employee.employees VALUES (89, 'Trinh Chi Khoa', '239 Tran Hung Dao', 'Thanh Khe', 'Binh Dinh', 'Khoa.TrinhChi62@gmail.com', 4206950862, false, NULL, 'Cashier', 'TrinhKhoa', '$2a$06$qnx1MWegYkWIf3L/7/92jONJ/rw9axnef1uvZ8acVLgGhcDNQAYIu', 5534654);
INSERT INTO employee.employees VALUES (90, 'Luong Thi Nhung', '343 Hang Luoc', 'Hoang Mai', 'Gia Lai', 'Nhung.LuongThi37@gmail.com', 6330589237, false, NULL, 'Cashier', 'LuongNhung', '$2a$06$//.pW93B5/nnGkIvmSD9pef1VC28R8Jt4qb6CU7BEC7znxjP7j0gy', 4728084);
INSERT INTO employee.employees VALUES (91, 'Vo Nam Dong', '511 Ho Tung Mau', 'Phu Nhuan', 'Gia Lai', 'Dong.VoNam53@gmail.com', 9200898653, false, NULL, 'Cashier', 'VoDong', '$2a$06$15a50MTwrZe8xieh2aFRmOfjFIJdP2uWiJyRO8FV5oi/365bw5uv2', 5914437);
INSERT INTO employee.employees VALUES (92, 'Nghiem Kieu Tu', '47 Thuoc Bac', 'Quan 5', 'Gia Lai', 'Tu.NghiemKieu42@gmail.com', 1808594342, false, NULL, 'Cashier', 'NghiemTu', '$2a$06$48eNwy63rG0Sz3fwCSBiW.NA4ayxt1B5IqKCdvifocHvdfgGGRvu6', 6617867);
INSERT INTO employee.employees VALUES (93, 'Ta Chi Tien', '277 Hang Da', 'Dong Da', 'Binh Dinh', 'Tien.TaChi74@gmail.com', 2496958274, false, NULL, 'Cashier', 'TaTien', '$2a$06$VADg6xosWe4rxGT83MhHyOyRY29QsXrZnOgEmPxa4OgGCiKBHDzPq', 6040708);
INSERT INTO employee.employees VALUES (94, 'Cao Tuan Khang', '620 Hang Voi', 'Binh Thanh', 'Ha Noi', 'Khang.CaoTuan83@gmail.com', 1654206783, false, NULL, 'Cashier', 'CaoKhang', '$2a$06$XMHw6x0afPLg30S1VuEcq..wkax8ZJOC88sExy8.CigV8EL02qo6y', 6908384);
INSERT INTO employee.employees VALUES (95, 'Quach Chi Cuong', '950 Phan Chu Trinh', 'Nam Tu Liem', 'Quang Ninh', 'Cuong.QuachChi14@gmail.com', 5931736714, false, NULL, 'Cashier', 'QuachCuong', '$2a$06$KHs3R2HlZYkILjE4c2Twfe4VEXND4AEqMwdy22rBSGyUWnkfXxSNi', 4577099);
INSERT INTO employee.employees VALUES (96, 'Phan Minh Khoa', '884 Hang Tre', 'Hoang Mai', 'Quy Nhon', 'Khoa.PhanMinh93@gmail.com', 9619433993, false, NULL, 'Cashier', 'PhanKhoa', '$2a$06$MP.1ysLTclGqC3cged4Pa.mA.sTxBcmQS1l5mYKLhXPNtH7alaAPG', 5852415);
INSERT INTO employee.employees VALUES (97, 'Ta Ngoc Loan', '137 Ngo Quyen', 'Bac Tu Liem', 'Ha Nam', 'Loan.TaNgoc78@gmail.com', 6218320378, false, NULL, 'Cashier', 'TaLoan', '$2a$06$1dbrt6fuC1VjJ3FQ3RI/TuUEIngm1lCppe9gE0wYS6E.2TQ8a92wq', 5408634);
INSERT INTO employee.employees VALUES (98, 'Diep Kieu Thuy', '587 O Cho Dua', 'Long Bien', 'Hai Phong', 'Thuy.DiepKieu69@gmail.com', 5627451269, false, NULL, 'Cashier', 'DiepThuy', '$2a$06$OAS4OephrW5dyyJfY0OSo.Vuix.HWO/No.uPwRgsnD6yxi8/c5w7S', 6629135);
INSERT INTO employee.employees VALUES (99, 'Phan Manh Nhung', '266 Phung Hung', 'Quan 3', 'Binh Thuan', 'Nhung.PhanManh30@gmail.com', 7306206930, false, NULL, 'Cashier', 'PhanNhung', '$2a$06$htVELd5MrvhWT1xPPVZJEOOn1xn6iotxusN7enwOnLwsD/XZwbFVC', 6756760);
INSERT INTO employee.employees VALUES (100, 'Phan Tuan Van', '718 Tran Quoc Toan', 'Son Tra', 'Binh Dinh', 'Van.PhanTuan83@gmail.com', 3307543983, false, NULL, 'Cashier', 'PhanVan', '$2a$06$qZN9eo0UXnhPf.Y76tB/V.g5BR.Jg1Jt1HwmzL733nzVA8Y07dT2q', 5213492);
INSERT INTO employee.employees VALUES (101, 'Cao Khanh Minh', '489 Phan Dinh Phung', 'Hoan Kiem', 'Binh Thuan', 'Minh.CaoKhanh9@gmail.com', 3778317009, false, NULL, 'Cashier', 'CaoMinh', '$2a$06$MvM296DMwgmrt86sIL.FfOUPHsraT/h7wnLGYaUebCkHoRQg1iyf6', 6116108);
INSERT INTO employee.employees VALUES (102, 'Do Tuan Huy', '348 Giang Vo', 'Long Bien', 'Bien Hoa', 'Huy.DoTuan77@gmail.com', 6842839377, false, NULL, 'Cashier', 'DoHuy', '$2a$06$4tB7g50FFat7912H65COluciHh/ChT.HqVPAaM64n2V1VRYhlqdYm', 5112027);
INSERT INTO employee.employees VALUES (103, 'Ly Manh Tuyen', '16 Giang Vo', 'Phu Nhuan', 'Quang Nam', 'Tuyen.LyManh94@gmail.com', 7340834594, false, NULL, 'Cashier', 'LyTuyen', '$2a$06$fX.BCUgXh4BqGVXhw3P4Kuxqh9nNaBcAn/MyE0kJuQ4Tb9vJaDfny', 6480812);
INSERT INTO employee.employees VALUES (104, 'Luu Kieu Sang', '404 Hang Khay', 'Long Bien', 'Phu Yen', 'Sang.LuuKieu88@gmail.com', 9368719888, false, NULL, 'Cashier', 'LuuSang', '$2a$06$nib/Wt2fMRNrwH5S0rLuOO66AX0SVzm2/Ks6sOIUOxOVW4IuREWqm', 5465128);
INSERT INTO employee.employees VALUES (105, 'Ta Van Thuy', '643 Hang Da', 'Tay Ho', 'Dak Lak', 'Thuy.TaVan52@gmail.com', 9525160152, false, NULL, 'Cashier', 'TaThuy', '$2a$06$5eFoBbIMrRDWOM6Zn2tRHuNmSHFjpp1t/SLmHW2Rt7cghuuLXbc3m', 4781769);
INSERT INTO employee.employees VALUES (106, 'Luong Minh Lan', '900 Tran Hung Dao', 'Hong Bang', 'Quang Binh', 'Lan.LuongMinh14@gmail.com', 4340832714, false, NULL, 'Cashier', 'LuongLan', '$2a$06$7h4F4qLFEVsgi3ym/tQ5k.AHJDN4Lmggf63Cp18Dv5qvRJN5Wz49a', 5864689);
INSERT INTO employee.employees VALUES (107, 'Huynh Thanh Hung', '872 Hang Ca', 'Ba Dinh', 'Quang Ninh', 'Hung.HuynhThanh0@gmail.com', 2274290900, false, NULL, 'Cashier', 'HuynhHung', '$2a$06$32KNBh/mYXKVwB80jl32ieq3fEYQK.KKauG6BODFXKufFQGJczXW2', 4175035);
INSERT INTO employee.employees VALUES (437, 'Tong Van Tien', '124 Pham Hong Thai', 'Hoan Kiem', 'Ha Tinh', 'Tien.TongVan86@gmail.com', 8446094486, false, NULL, 'Customer Service Representative', 'TongTien', '$2a$06$PbaSZmofMyBp57RqJZ5EFe/tg5SLqYVezdAFCwDf8sZUfdkR8ILG2', 4990796);
INSERT INTO employee.employees VALUES (438, 'Phan Van Trinh', '738 Hang Non', 'Tay Ho', 'Vung Tau', 'Trinh.PhanVan77@gmail.com', 9362809877, false, NULL, 'Customer Service Representative', 'PhanTrinh', '$2a$06$IrGFDmqQLmoeRVnqH/2FV.TY0auQKqHCSUD4qaO4.tcr9nkaWJXBy', 5342512);
INSERT INTO employee.employees VALUES (439, 'Trinh Van Nhi', '611 Tran Quoc Toan', 'Ha Dong', 'Bac Ninh', 'Nhi.TrinhVan67@gmail.com', 1187894667, false, NULL, 'Customer Service Representative', 'TrinhNhi', '$2a$06$Dwtwpy2ipS7Vmrszkbld2Ok0fzHsKE3xAbN9eWHPqTHMohSlOeqwm', 5353176);
INSERT INTO employee.employees VALUES (440, 'Hoang Hoang Khoa', '449 Pham Hong Thai', 'Cau Giay', 'Ha Tinh', 'Khoa.HoangHoang22@gmail.com', 1155667422, false, NULL, 'Customer Service Representative', 'HoangKhoa', '$2a$06$CUOr8WV8CAWsRONg7YKKWubr856AJwuU.L/5WOVFBw9rCC8kEdbmu', 5181712);
INSERT INTO employee.employees VALUES (441, 'Le Thanh Thao', '626 Thuoc Bac', 'Hoang Mai', 'Quang Ninh', 'Thao.LeThanh80@gmail.com', 6401469480, false, NULL, 'Customer Service Representative', 'LeThao', '$2a$06$Srrvl0aoaitYwcHok831P.7HvFk6KGFCXDAnSH6RaZHZAB8Qxm6i.', 6824683);
INSERT INTO employee.employees VALUES (442, 'Tieu Nam Thu', '990 Nguyen Sieu', 'Le Chan', 'Binh Thuan', 'Thu.TieuNam12@gmail.com', 5680938812, false, NULL, 'Customer Service Representative', 'TieuThu', '$2a$06$lAHCU/xXgVK0SiOy6C4RHO3M3GlmcO92w9fYbN0PA1ww/g944dyf2', 6606384);
INSERT INTO employee.employees VALUES (443, 'Ta Kieu Sang', '746 Phan Dinh Phung', 'Hong Bang', 'Ha Noi', 'Sang.TaKieu56@gmail.com', 8232057656, false, NULL, 'Customer Service Representative', 'TaSang', '$2a$06$W8m9zPURcBHvJ4mF/V2Q9OBuwpEy.VORW3zP6EfiJDkzIK4AtEpOG', 6835235);
INSERT INTO employee.employees VALUES (444, 'Lac Tuan Hiep', '846 Hang Gai', 'Son Tra', 'Nam Dinh', 'Hiep.LacTuan96@gmail.com', 6070217296, false, NULL, 'Customer Service Representative', 'LacHiep', '$2a$06$64TBAoCeugqkquVusJQPne722QfOTSHPlkCBpq2hombWw3FB1EKRa', 4462650);
INSERT INTO employee.employees VALUES (445, 'Ngo Nam Lam', '790 Xuan Thuy', 'Phu Nhuan', 'Kon Tum', 'Lam.NgoNam15@gmail.com', 8544077115, false, NULL, 'Customer Service Representative', 'NgoLam', '$2a$06$bgqTNWRNlDw106saH2AUVOQOMuZ9mKu88.jk96Tj.j/Y7WC8UjQEy', 6451730);
INSERT INTO employee.employees VALUES (446, 'Vo Thi Huy', '631 Giang Vo', 'Hoan Kiem', 'Ho Chi Minh', 'Huy.VoThi49@gmail.com', 4078407249, false, NULL, 'Customer Service Representative', 'VoHuy', '$2a$06$YauUEHlmmmWoYmMb6g3QKebf54BLg18KpVIqaj3qFBrYdgrqtTyVu', 6457763);
INSERT INTO employee.employees VALUES (447, 'Huynh Tuan Khanh', '41 Le Loi', 'Ba Dinh', 'Ha Nam', 'Khanh.HuynhTuan42@gmail.com', 9449310142, false, NULL, 'Customer Service Representative', 'HuynhKhanh', '$2a$06$pML9JgqJIufH7pgCeQXV0uP/2X//Y3u1glAXowhUx5eUWXdnIf.vu', 6874470);
INSERT INTO employee.employees VALUES (448, 'Quach Nam Ly', '1000 Hang Gai', 'Hai Ba Trung', 'Quang Tri', 'Ly.QuachNam86@gmail.com', 4927348486, false, NULL, 'Customer Service Representative', 'QuachLy', '$2a$06$qsaFtqsoUtuk.DMlC09kDu3nK7GdmLLi86mCyG/vCZVMxjWue05Ky', 5119247);
INSERT INTO employee.employees VALUES (449, 'Le Hai Hai', '687 Le Loi', 'Quan 2', 'Hai Phong', 'Hai.LeHai19@gmail.com', 6932988919, false, NULL, 'Customer Service Representative', 'LeHai', '$2a$06$nJPxEenebPIf3hhD/DMEseQLENGaNksbargXYVbRTeM0bUeyLLJYu', 5561341);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: employee; Owner: postgres
--

INSERT INTO employee.roles VALUES ('Admin');
INSERT INTO employee.roles VALUES ('Manager');
INSERT INTO employee.roles VALUES ('Cashier');
INSERT INTO employee.roles VALUES ('Inventory Clerk');
INSERT INTO employee.roles VALUES ('Shop Assistant');
INSERT INTO employee.roles VALUES ('Customer Service Representative');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: warranty; Type: TABLE DATA; Schema: order; Owner: postgres
--



--
-- Data for Name: general_specs; Type: TABLE DATA; Schema: product; Owner: postgres
--

INSERT INTO product.general_specs VALUES ('10"', 'display_size', '10_inch', '10 inches', 'Laptop', 1);
INSERT INTO product.general_specs VALUES ('11"', 'display_size', '11_inch', '11 inches', 'Laptop', 2);
INSERT INTO product.general_specs VALUES ('12"', 'display_size', '12_inch', '12 inches', 'Laptop', 3);
INSERT INTO product.general_specs VALUES ('13"', 'display_size', '13_inch', '13 inches', 'Laptop', 4);
INSERT INTO product.general_specs VALUES ('14"', 'display_size', '14_inch', '14 inches', 'Laptop', 5);
INSERT INTO product.general_specs VALUES ('15"', 'display_size', '15_inch', '15 inches', 'Laptop', 6);
INSERT INTO product.general_specs VALUES ('17"', 'display_size', '17_inch', '17 inches', 'Laptop', 7);
INSERT INTO product.general_specs VALUES ('18"', 'display_size', '18_inch', '18 inches', 'Laptop', 8);
INSERT INTO product.general_specs VALUES ('Touchscreen', 'display_touch', 'touch_screen', NULL, 'Laptop', 9);
INSERT INTO product.general_specs VALUES ('1366 x 768', 'display_resolution', '1366_768', 'HD', 'Laptop', 10);
INSERT INTO product.general_specs VALUES ('1920 x 1080', 'display_resolution', '1920_1080', 'Full HD', 'Laptop', 11);
INSERT INTO product.general_specs VALUES ('2560 x 1440', 'display_resolution', '2560_1440', 'Quad HD+ (2K)', 'Laptop', 12);
INSERT INTO product.general_specs VALUES ('3840 x 2160', 'display_resolution', '3840_2160', 'Ultra HD (4K)', 'Laptop', 13);
INSERT INTO product.general_specs VALUES ('4GB', 'ram_capacity', '4_gb', NULL, 'Laptop', 14);
INSERT INTO product.general_specs VALUES ('8GB', 'ram_capacity', '8_gb', NULL, 'Laptop', 15);
INSERT INTO product.general_specs VALUES ('16GB', 'ram_capacity', '16_gb', NULL, 'Laptop', 16);
INSERT INTO product.general_specs VALUES ('Windows 10', 'os', 'win10', 'Windows 10 Home', 'Laptop', 17);
INSERT INTO product.general_specs VALUES ('Windows 10', 'os', 'win10', 'Windows 10 Pro', 'Laptop', 18);
INSERT INTO product.general_specs VALUES ('Windows 11', 'os', 'win11', 'Windows 11 Home', 'Laptop', 19);
INSERT INTO product.general_specs VALUES ('Windows 11', 'os', 'win11', 'Windows 11 Pro', 'Laptop', 20);
INSERT INTO product.general_specs VALUES ('Linux', 'os', 'linux', NULL, 'Laptop', 21);
INSERT INTO product.general_specs VALUES ('MacOS', 'os', 'mac', NULL, 'Laptop', 22);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i3', 'cpu_model', 'i3_13100', 'i3 - 13100, 4C/8T, 3.40 GHz up to 4.50GHz, 12MB Cache, 60W', 'CPU', 23);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i3', 'cpu_model', 'i3_1315u', 'i3 - 1315U, 6C/8T, 3.30 GHz up to 4.50GHz, 10MB Cache, 15W', 'CPU', 24);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i3', 'cpu_model', 'i3_1315u', 'i3 - 1315U, 6C/8T, 3.30 GHz up to 4.50GHz, 10MB Cache, 15W', 'Laptop', 25);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i5', 'cpu_model', 'i5_13400', 'i5 - 13400, 10C/16T, 1.80 GHz up to 4.60GHz, 20MB Cache, 65W', 'CPU', 26);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i5', 'cpu_model', 'i5_1334u', 'i4 - 1334U, 10C/12T, 3.40GHz up to 4.60GHz, 12MB Cache, 15W', 'CPU', 27);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i5', 'cpu_model', 'i5_1334u', 'i4 - 1334U, 10C/12T, 3.40GHz up to 4.60GHz, 12MB Cache, 15W', 'Laptop', 28);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i7', 'cpu_model', 'i7_13700', 'i7 - 13700, 16C/24T, 1.50GHz up to 5.20GHz, 30MB Cache, 65W', 'CPU', 29);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i7', 'cpu_model', 'i7_1355u', 'i7 - 1355U, 10C/12T, 3.70GHz up to 5.00GHz, 12MB Cache, 12W', 'CPU', 30);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i7', 'cpu_model', 'i7_1355u', 'i7 - 1355U, 10C/12T, 3.70GHz up to 5.00GHz, 12MB Cache, 12W', 'Laptop', 31);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i9', 'cpu_model', 'i9_13900', 'i9 - 13900, 24C/32T, 1.50GHz up to 5.60GHz, 36MB Cache, 65W', 'CPU', 32);
INSERT INTO product.general_specs VALUES ('AMD Ryzen™', 'cpu_model', 'ryzen_9_pro_5945', 'Ryzen™ 9 PRO 5945, 12C/24T, 3.0GHz up to 4.7GHz, 64MB Cache, 65W', 'CPU', 33);
INSERT INTO product.general_specs VALUES ('AMD Ryzen™', 'cpu_model', 'ryzen_7_pro_5750g', 'Ryzen™ 7 PRO 5750G, 8C/16T, 3.8GHz up to 4.6GHz, 16MB Cache, 65W', 'CPU', 34);
INSERT INTO product.general_specs VALUES ('AMD Ryzen™', 'cpu_model', 'ryzen_3_pro_5350g', 'Ryzen™ 3 PRO 5350G, 4C/8T, 4.0GHz up to 4.2GHz, 8MB Cache, 65W', 'CPU', 35);


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: product; Owner: postgres
--

INSERT INTO product.product_category VALUES ('Laptop');
INSERT INTO product.product_category VALUES ('PC');
INSERT INTO product.product_category VALUES ('CPU');
INSERT INTO product.product_category VALUES ('RAM');
INSERT INTO product.product_category VALUES ('VGA');
INSERT INTO product.product_category VALUES ('Monitor');
INSERT INTO product.product_category VALUES ('Keyboard');
INSERT INTO product.product_category VALUES ('Mouse');


--
-- Data for Name: product_instance; Type: TABLE DATA; Schema: product; Owner: postgres
--



--
-- Data for Name: product_specs; Type: TABLE DATA; Schema: product; Owner: postgres
--

INSERT INTO product.product_specs VALUES (1, 6);
INSERT INTO product.product_specs VALUES (1, 15);
INSERT INTO product.product_specs VALUES (1, 17);
INSERT INTO product.product_specs VALUES (1, 31);


--
-- Data for Name: products; Type: TABLE DATA; Schema: product; Owner: postgres
--

INSERT INTO product.products VALUES (1, 'Dell', 'Inspiron 3593', 'Laptop', 21790000, NULL, NULL);


--
-- Data for Name: store_branch; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.store_branch VALUES (1, '113 Cau Giay', 'Cau Giay ', 'Ba Dinh', 'Ha Noi', '07:30:00', '18:00:00', 'caugiaystore@gmail.com', 3850848123, NULL);
INSERT INTO store.store_branch VALUES (2, '220 Tran Nguyen Han', 'Tran Nguyen Han', 'Le Chan', 'Ha Noi', '08:00:00', '18:00:00', 'trannguyenhanstore@gmail.com', 5290955819, NULL);
INSERT INTO store.store_branch VALUES (3, '67 To Hieu', 'To Hieu', 'Hong Bang', 'Ha Noi', '08:30:00', '22:00:00', 'tohieustore@gmail.com', 3754205360, NULL);
INSERT INTO store.store_branch VALUES (4, '95 Pham Hong Thai', 'Pham Hong Thai', 'Quan 4', 'Ho Chi Minh', '09:00:00', '21:30:00', 'phamhongthaistore@gmail.com', 4053661565, NULL);
INSERT INTO store.store_branch VALUES (5, '450 Hoang Quoc Viet ', 'Hoang Quoc Viet', 'Quan 5', 'Ho Chi Minh', '09:00:00', '21:00:00', 'hoangquocvietstore@gmail.com', 7316245202, NULL);
INSERT INTO store.store_branch VALUES (6, '12 Ly Nam De', 'Ly Nam De', 'Long Bien', 'Hai Phong', '08:00:00', '22:00:00', 'lynamdestore@gmail.com', 2202941776, NULL);
INSERT INTO store.store_branch VALUES (7, '45 Ton Duc Thang', 'Ton Duc Thang', 'Thanh Xuan', 'Da Nang', '07:30:00', '21:30:00', 'tonducthangstore@gmail.com', 1338352254, NULL);
INSERT INTO store.store_branch VALUES (8, '3 Phan Chu Trinh', 'Phan Chu Trinh', 'Phu Nhuan', 'Hue', '09:00:00', '21:30:00', 'phanchutrinhstore@gmail.com', 2036494727, NULL);
INSERT INTO store.store_branch VALUES (9, '16 Le Thanh Tong', 'Le Thanh Tong', 'Hoang Mai', 'Ha Noi', '07:30:00', '22:00:00', 'lethanhtongstore@gmail.com', 9657598022, NULL);
INSERT INTO store.store_branch VALUES (10, '12 Tran Phu', 'Tran Phu', 'Hong Bang', 'Nha Trang', '07:30:00', '21:00:00', 'tranphustore@gmail.com', 7809273715, NULL);
INSERT INTO store.store_branch VALUES (11, '450 Le Hong Phong', 'Le Hong Phong', 'Thanh Xuan', 'Ninh Thuan', '07:30:00', '18:00:00', 'lehongphongstore@gmail.com', 3054999796, NULL);
INSERT INTO store.store_branch VALUES (12, '13 Tran Dai Nghia', 'Tran Dai Nghia', 'Ba Dinh', 'Ha Noi', '09:00:00', '17:00:00', 'trandainghiastore@gmail.com', 2407718507, NULL);
INSERT INTO store.store_branch VALUES (13, '60 Ngo Quyen', 'Ngo Quyen', 'Dong Da', 'Bac Ninh', '08:00:00', '21:30:00', 'ngoquyenstore@gmail.com', 7841748006, NULL);
INSERT INTO store.store_branch VALUES (14, '780 Nguyen Trai', 'Nguyen Trai', 'Long Bien', 'Thai Nguyen', '08:00:00', '22:00:00', 'nguyentraistore@gmail.com', 1851450015, NULL);
INSERT INTO store.store_branch VALUES (15, '90 Giang Vo', 'Giang Vo', 'Quan 3', 'Ho Chi Minh', '08:30:00', '21:30:00', 'giangvostore@gmail.com', 3414977620, NULL);
INSERT INTO store.store_branch VALUES (16, '89 Hoang Cau', 'Hoang Cau', 'Hai Ba Trung', 'Ha Noi', '09:00:00', '22:00:00', 'hoangcaustore@gmail.com', 8589990166, NULL);
INSERT INTO store.store_branch VALUES (17, '334 Le Duan', 'Le Duan', 'Ha Dong', 'Ha Noi', '08:00:00', '21:00:00', 'leduanstore@gmail.com', 5959598063, NULL);
INSERT INTO store.store_branch VALUES (18, '154 Phung Hung', 'Phung Hung', 'Ngo Quyen', 'Hai Phong', '07:30:00', '22:00:00', 'phunghungstore@gmail.com', 4489726466, NULL);
INSERT INTO store.store_branch VALUES (19, '116 Le Loi', 'Le Loi', 'Son Tra', 'Binh Dinh', '08:30:00', '18:00:00', 'leloistore@gmail.com', 3591152800, NULL);
INSERT INTO store.store_branch VALUES (20, '49 Quan Thanh', 'Quan Thanh', 'Quan 1', 'Ho Chi Minh', '09:00:00', '21:00:00', 'quanthanhstore@gmail.com', 7313912569, NULL);
INSERT INTO store.store_branch VALUES (21, '89 Thai Ha', 'Lang Ha', 'Dong Da', 'Ha Noi', '08:30:00', '21:30:00', 'thaihastore@gmail.com', 9846215476, NULL);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: employee; Owner: postgres
--

SELECT pg_catalog.setval('employee.employees_employee_id_seq', 449, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: order; Owner: postgres
--

SELECT pg_catalog.setval('"order".orders_order_id_seq', 1, false);


--
-- Name: general_specs_spec_id_seq; Type: SEQUENCE SET; Schema: product; Owner: postgres
--

SELECT pg_catalog.setval('product.general_specs_spec_id_seq', 35, true);


--
-- Name: products_prod_id_seq; Type: SEQUENCE SET; Schema: product; Owner: postgres
--

SELECT pg_catalog.setval('product.products_prod_id_seq', 1, true);


--
-- Name: storebranch_branch_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.storebranch_branch_id_seq', 21, true);


--
-- Name: brands brands_pk; Type: CONSTRAINT; Schema: brand; Owner: postgres
--

ALTER TABLE ONLY brand.brands
    ADD CONSTRAINT brands_pk PRIMARY KEY (brand_name);


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
-- Name: roles roles_pk2; Type: CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.roles
    ADD CONSTRAINT roles_pk2 PRIMARY KEY (role_name);


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
    ADD CONSTRAINT general_specs_pk2 UNIQUE (spec_type, spec_value, product_category, description);


--
-- Name: product_category product_category_pk; Type: CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.product_category
    ADD CONSTRAINT product_category_pk PRIMARY KEY (category_name);


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
-- Name: employees encrypt_new_password; Type: TRIGGER; Schema: employee; Owner: postgres
--

CREATE TRIGGER encrypt_new_password AFTER INSERT OR UPDATE OF password ON employee.employees FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION employee.encrypt_password();


--
-- Name: employees employees___fk; Type: FK CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees___fk FOREIGN KEY (working_branch_id) REFERENCES store.store_branch(branch_id);


--
-- Name: employees employees_roles_role_name_fk; Type: FK CONSTRAINT; Schema: employee; Owner: postgres
--

ALTER TABLE ONLY employee.employees
    ADD CONSTRAINT employees_roles_role_name_fk FOREIGN KEY (role) REFERENCES employee.roles(role_name);


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
-- Name: general_specs general_specs_product_category_category_name_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.general_specs
    ADD CONSTRAINT general_specs_product_category_category_name_fk FOREIGN KEY (product_category) REFERENCES product.product_category(category_name);


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
-- Name: products products_brands_brand_name_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_brands_brand_name_fk FOREIGN KEY (prod_brand_name) REFERENCES brand.brands(brand_name);


--
-- Name: products products_product_category_category_name_fk; Type: FK CONSTRAINT; Schema: product; Owner: postgres
--

ALTER TABLE ONLY product.products
    ADD CONSTRAINT products_product_category_category_name_fk FOREIGN KEY (prod_category_name) REFERENCES product.product_category(category_name);


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

