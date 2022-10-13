{%- macro elo_calc(home_team, visiting_team) -%}
   ( 1 - (1 / (10 ^ (-( {{visiting_team}} - {{home_team}} )::real/400)+1))) * 10000
{%- endmacro -%}