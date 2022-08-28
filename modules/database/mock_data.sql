DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS discounts;

CREATE TABLE transactions (
    transaction_id serial PRIMARY KEY,
    sender VARCHAR ( 255 ) NOT NULL,
    sender_account VARCHAR ( 26 ) NOT NULL,
    amount NUMERIC ( 10, 2 ) NOT NULL,
    receiver VARCHAR ( 255 ) NOT NULL,
    receiver_account VARCHAR ( 26 ) NOT NULL,
    date VARCHAR ( 10 ) NOT NULL
);

CREATE TABLE accounts (
    account_id serial PRIMARY KEY,
    number VARCHAR ( 26 ) NOT NULL,
    account_owner VARCHAR ( 255 ) NOT NULL,
    balance NUMERIC ( 10, 2 ) NOT NULL
);

CREATE TABLE discounts (
    discount_id serial PRIMARY KEY,
    account VARCHAR ( 26 ) NOT NULL,
    account_owner VARCHAR ( 255 ) NOT NULL,
    no_transactions INTEGER NOT NULL,
    available_discount INTEGER NOT NULL
);

INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Jacek Długosz', '59109024025528758464273817', 135.56, 'Maria Załęcka', '14109024024221294379482596', '2021-06-12');
INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Mateusz Wiecek', '92109024024925258688665853', 34.89, 'Jan Niemczyk', '40109024025367855218432799', '2021-11-07');
INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Sonia Sokal', '14109024025129952183299739', 23.60, 'Fryderyk Wyrzykowski', '49109024028988825191899356', '2021-12-19');
INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Natasza Wójcik', '60109024024274598442276864', 55.45, 'Paweł Grabowski', '84109024021817185687656872', '2022-05-12');
INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Mateusz Wiecek', '92109024024925258688665853', 102.04, 'Szymon Sokół', '85109024026181469476495514', '2021-05-17');
INSERT INTO transactions (sender, sender_account, amount, receiver, receiver_account, date)
    VALUES ('Natasza Wójcik', '60109024024274598442276864', 55.45, 'Luiza Ławniczak', '25109024023176717431286547', '2022-01-30');

INSERT INTO accounts (number, account_owner, balance) VALUES ('59109024025528758464273817', 'Jacek Długosz', 1135.56);
INSERT INTO accounts (number, account_owner, balance) VALUES ('92109024024925258688665853', 'Mateusz Wiecek', 2034.89);
INSERT INTO accounts (number, account_owner, balance) VALUES ('14109024025129952183299739', 'Sonia Sokal', 534.56);
INSERT INTO accounts (number, account_owner, balance) VALUES ('60109024024274598442276864', 'Natasza Wójcik', 1478.08);

INSERT INTO discounts (account, account_owner, no_transactions, available_discount)
    VALUES ('59109024025528758464273817', 'Jacek Długosz', 1, 10);
INSERT INTO discounts (account, account_owner, no_transactions, available_discount)
    VALUES ('92109024024925258688665853', 'Mateusz Wiecek', 2, 20);
INSERT INTO discounts (account, account_owner, no_transactions, available_discount)
    VALUES ('14109024025129952183299739', 'Sonia Sokal', 1, 10);
INSERT INTO discounts (account, account_owner, no_transactions, available_discount)
    VALUES ('60109024024274598442276864', 'Natasza Wójcik', 2, 20);