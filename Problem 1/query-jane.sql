WITH pix_movement_in AS (
    SELECT
        dm.action_month,
        dy.action_year,
        pix.account_id,
        pix.in_or_out,
        a.customer_id,
        sum(pix_amount) AS total_pix_in
    FROM
        public.pix_movements pix
        JOIN d_time dt ON dt.time_id = pix.pix_requested_at
        JOIN d_month dm ON dm.month_id = dt.month_id
        JOIN d_year dy ON dy.year_id = dt.year_id
        JOIN accounts a ON a.account_id = pix.account_id
    WHERE
        1 = 1
        AND dy.action_year = 2020
        AND pix.in_or_out = 'pix_in'
    GROUP BY
        1,
        2,
        3,
        4,
        5
),
pix_movement_out AS (
    SELECT
        dm.action_month,
        dy.action_year,
        pix.account_id,
        pix.in_or_out,
        a.customer_id,
        sum(pix_amount) AS total_pix_out
    FROM
        public.pix_movements pix
        JOIN d_time dt ON dt.time_id = pix.pix_requested_at
        JOIN d_month dm ON dm.month_id = dt.month_id
        JOIN d_year dy ON dy.year_id = dt.year_id
        JOIN accounts a ON a.account_id = pix.account_id
    WHERE
        1 = 1
        AND dy.action_year = 2020
        AND pix.in_or_out = 'pix_out'
    GROUP BY
        1,
        2,
        3,
        4,
        5
),
pix_movements_total AS (
    SELECT
        pix_in.action_month,
        pix_in.action_year,
        pix_in.account_id,
        a.customer_id,
        pix_in.total_pix_in,
        pix_out.total_pix_out,
        (
            pix_in.total_pix_in - COALESCE(pix_out.total_pix_out, 0)
        ) AS pix_monthly_balance
    FROM
        pix_movement_in pix_in
        LEFT JOIN pix_movement_out pix_out ON pix_in.account_id = pix_out.account_id
        AND pix_out.action_month = pix_in.action_month
        JOIN accounts a ON a.account_id = pix_in.account_id
),
transfers_in AS (
    SELECT
        dm.action_month,
        c.customer_id,
        a.account_id,
        sum(ti.amount) AS total_transfer_in_amount
    FROM
        customers c
        JOIN accounts a ON c.customer_id = a.customer_id
        JOIN transfer_ins ti ON ti.account_id = a.account_id
        JOIN d_time dt ON dt.time_id = ti.transaction_requested_at
        JOIN d_month dm ON dm.month_id = dt.month_id
        JOIN d_year dy ON dy.year_id = dt.year_id
    WHERE
        1 = 1
        AND dy.action_year = 2020
    GROUP BY
        1,
        2,
        3
),
transfers_out AS (
    SELECT
        dm.action_month,
        c.customer_id,
        a.account_id,
        sum(to2.amount) AS total_transfer_out_amount
    FROM
        customers c
        JOIN accounts a ON c.customer_id = a.customer_id
        JOIN transfer_outs to2 ON to2.account_id = a.account_id
        JOIN d_time dt ON dt.time_id = to2.transaction_requested_at
        JOIN d_month dm ON dm.month_id = dt.month_id
        JOIN d_year dy ON dy.year_id = dt.year_id
    WHERE
        1 = 1
        AND dy.action_year = 2020
    GROUP BY
        1,
        2,
        3
),
stage AS (
    SELECT
        ti.action_month,
        ti.customer_id,
        (
            pix_in.total_pix_in + ti.total_transfer_in_amount
        ) AS total_transfer_in,
        (
            coalesce(pix_out.total_pix_out, 0) + coalesce(to2.total_transfer_out_amount, 0)
        ) AS total_transfer_out
    FROM
        pix_movement_in pix_in
        LEFT JOIN transfers_in ti ON pix_in.customer_id = ti.customer_id
        AND ti.action_month = pix_in.action_month
        LEFT JOIN pix_movement_out pix_out ON pix_in.customer_id = pix_out.customer_id
        AND pix_in.action_month = pix_out.action_month
        LEFT JOIN transfers_out to2 ON pix_in.customer_id = to2.customer_id
        AND to2.action_month = pix_in.action_month
)
SELECT
    action_month AS "Month",
    customer_id AS "Customer",
    total_transfer_in AS "Total Transfer In",
    total_transfer_out AS "Total Transfer Out",
    (total_transfer_in - total_transfer_out) AS "Account Monthly Balance"
FROM
    stage