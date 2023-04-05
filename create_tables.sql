/*
This query creates the tables for the given schema. 
The primary keys were change to `varchar` due to incompatible data formats 
in the CSV files.
*/
CREATE TABLE public.country (
    country_id varchar(255) PRIMARY KEY,
    country varchar(128) NOT NULL
);

CREATE TABLE public.state (
    state_id varchar(255) PRIMARY KEY,
    state varchar(128) NOT NULL,
    country_id varchar(255) NOT NULL REFERENCES public.country(country_id)
);

CREATE TABLE public.city (
    city_id varchar PRIMARY KEY,
    city varchar(256) NOT NULL,
    state_id varchar(255) NOT NULL REFERENCES public.state(state_id)
);

CREATE TABLE public.customers (
    customer_id varchar(255) PRIMARY KEY,
    first_name varchar(128) NOT NULL,
    last_name varchar(128) NOT NULL,
    customer_city varchar NOT NULL REFERENCES public.city(city_id),
    country_name varchar(128) NOT NULL,
    cpf int NOT NULL
);

CREATE TABLE public.accounts (
    account_id varchar(255) PRIMARY KEY,
    customer_id varchar(255) NOT NULL REFERENCES public.customers(customer_id),
    created_at timestamp NOT NULL,
    status varchar(128) NOT NULL,
    account_branch varchar(128) NOT NULL,
    account_check_digit varchar(128) NOT NULL,
    account_number varchar(128) NOT NULL
);

CREATE TABLE public.d_month (
    month_id varchar PRIMARY KEY,
    action_month int NOT NULL
);

CREATE TABLE public.d_year (
    year_id varchar PRIMARY KEY,
    action_year int NOT NULL
);



CREATE TABLE public.d_week (
    week_id varchar PRIMARY KEY,
    action_week int NOT NULL
);

CREATE TABLE public.d_weekday (
    weekday_id varchar PRIMARY KEY,
    action_weekday varchar(128) NOT NULL
);

CREATE TABLE public.d_time (
    time_id varchar PRIMARY KEY,
    action_timestamp timestamp NOT NULL,
    week_id varchar NOT NULL REFERENCES public.d_week(week_id),
    month_id varchar NOT NULL REFERENCES public.d_month(month_id),
    year_id varchar NOT NULL REFERENCES public.d_year(year_id),
    weekday_id varchar NOT NULL REFERENCES public.d_weekday(weekday_id)
);



CREATE TABLE public.transfer_ins (
    id varchar(255) PRIMARY KEY,
    account_id varchar(255) NOT NULL REFERENCES public.accounts(account_id),
    amount float NOT NULL,
    transaction_requested_at varchar NOT NULL REFERENCES public.d_time(time_id),
    transaction_completed_at varchar NOT NULL REFERENCES public.d_time(time_id),
    status varchar(128) NOT NULL
);

CREATE TABLE public.transfer_outs (
    id varchar(255) PRIMARY KEY,
    account_id varchar(255) NOT NULL REFERENCES public.accounts(account_id),
    amount float NOT NULL,
    transaction_requested_at varchar NOT NULL REFERENCES public.d_time(time_id),
    transaction_completed_at varchar NOT NULL REFERENCES public.d_time(time_id),
    status varchar(128) NOT NULL
);

CREATE TABLE public.pix_movements (
    id varchar(255) PRIMARY KEY,
    account_id varchar(255) NOT NULL REFERENCES public.accounts(account_id),
    in_or_out varchar(128) NOT NULL,
    pix_amount float NOT NULL,
    pix_requested_at varchar NOT NULL REFERENCES public.d_time(time_id),
    pix_completed_at varchar NOT NULL REFERENCES public.d_time(time_id),
    status varchar(128) NOT NULL
);

CREATE TABLE public.investments (
    transaction_id varchar(255) PRIMARY KEY,
    account_id varchar(255) NOT NULL REFERENCES public.accounts(account_id),
    type varchar(128) NOT NULL,
    amount float NOT NULL,
    investment_requested_at varchar NOT NULL REFERENCES public.d_time(time_id),
    investment_completed_at varchar NOT NULL REFERENCES public.d_time(time_id),
    status varchar(128) NOT NULL
);


ALTER TABLE state ADD CONSTRAINT state_fk_country_id FOREIGN KEY (country_id) REFERENCES country(country_id);

ALTER TABLE city ADD CONSTRAINT city_fk_state_id FOREIGN KEY (state_id) REFERENCES state(state_id);

ALTER TABLE customers ADD CONSTRAINT customers_fk_city_id FOREIGN KEY (customer_city) REFERENCES city(city_id);

ALTER TABLE accounts ADD CONSTRAINT accounts_fk_customer_id FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE transfer_ins ADD CONSTRAINT transfer_ins_fk_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id);

ALTER TABLE transfer_outs ADD CONSTRAINT transfer_outs_fk_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id);

ALTER TABLE pix_movements ADD CONSTRAINT pix_movements_fk_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id);

ALTER TABLE investments ADD CONSTRAINT investments_fk_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id);

ALTER TABLE investments ADD CONSTRAINT investments_fk_investment_requested_at FOREIGN KEY (investment_requested_at) REFERENCES d_time(time_id);

ALTER TABLE investments ADD CONSTRAINT investments_fk_investment_completed_at FOREIGN KEY (investment_completed_at) REFERENCES d_time(time_id);

ALTER TABLE transfer_outs ADD CONSTRAINT transfer_outs_fk_transaction_requested_at FOREIGN KEY (transaction_requested_at) REFERENCES d_time(time_id);

ALTER TABLE transfer_outs ADD CONSTRAINT transfer_outs_fk_transaction_completed_at FOREIGN KEY (transaction_completed_at) REFERENCES d_time(time_id);

ALTER TABLE transfer_ins ADD CONSTRAINT transfer_ins_fk_transaction_requested_at FOREIGN KEY (transaction_requested_at) REFERENCES d_time(time_id);

ALTER TABLE transfer_ins ADD CONSTRAINT transfer_ins_fk_transaction_completed_at FOREIGN KEY (transaction_completed_at) REFERENCES d_time(time_id);

ALTER TABLE pix_movements ADD CONSTRAINT pix_movements_fk_pix_requested_at FOREIGN KEY (pix_requested_at) REFERENCES d_time(time_id);

ALTER TABLE pix_movements ADD CONSTRAINT pix_movements_fk_pix_completed_at FOREIGN KEY (pix_completed_at) REFERENCES d_time(time_id);

ALTER TABLE d_time ADD CONSTRAINT d_time_fk_week_id FOREIGN KEY (week_id) REFERENCES d_week(week_id);

ALTER TABLE d_time ADD CONSTRAINT d_time_fk_month_id FOREIGN KEY (month_id) REFERENCES d_month(month_id);

ALTER TABLE d_time ADD CONSTRAINT d_time_fk_year_id FOREIGN KEY (year_id) REFERENCES d_year(year_id);

ALTER TABLE d_time ADD CONSTRAINT d_time_fk_weekday_id FOREIGN KEY (weekday_id) REFERENCES d_weekday(weekday_id);