# nubank_repo

Repository to store all the code created for Nubank exercise (case)

## Changes

- Convert all foreign key from `uuid` type to `varchar`.
- Export CSV file with Pandas end Python because the file was exported incorrectly.
It was converting id, account_id to wrong numbers, for example: `1783896702851019520` -> `1783896702851010000`
- Clean NaN values in `transfer_ins` table because the `transaction_completed_at` field did not match the foreign key in `d_time` table.
-

## Steps to load data manually

Import tha data in the following order:

1. Country
2. Month
3. Week
4. Weekday
5. Year
6. State
7. City
8. d_time
9. Customers
10. Accounts
11. Transfer_ins (Disable temporarily to insert data)
12. Transfer_outs (Disable temporarily to insert data)
13. Pix_movements (Disable temporarily to insert data)
14.
