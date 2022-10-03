{{
  config(
    materialized = "view"
) }}

SELECT *
FROM {{ ref( 'random_num_gen_1' ) }}
UNION ALL
SELECT *
FROM {{ ref( 'random_num_gen_2' ) }}
UNION ALL
SELECT *
FROM {{ ref( 'random_num_gen_3' ) }}
UNION ALL
SELECT *
FROM {{ ref( 'random_num_gen_4' ) }}