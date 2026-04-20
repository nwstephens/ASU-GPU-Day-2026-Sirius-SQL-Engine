# Run

```
sirius/build/release/duckdb
```

***

# Define data views

```
.timer on

CREATE VIEW lineitem AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/lineitem/*.parquet');
CREATE VIEW customer AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/customer/*.parquet');
CREATE VIEW orders   AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/orders/*.parquet');
CREATE VIEW supplier AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/supplier/*.parquet');
CREATE VIEW partsupp AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/partsupp/*.parquet');
CREATE VIEW nation   AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/nation/*.parquet');
CREATE VIEW part     AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/part/*.parquet');
CREATE VIEW region   AS SELECT * FROM read_parquet('sirius/test_datasets/tpch_parquet_sf100/region/*.parquet');

.tables
```

***

# Q1

## Q1 - CPU

```
select
	nation,
	o_year,
	sum(amount) as sum_profit
from
	(
	select
		n.n_name as nation,
		extract(year from o.o_orderdate) as o_year,
		l.l_extendedprice * (1 - l.l_discount) - ps.ps_supplycost * l.l_quantity as amount
	from
		part p,
		supplier s,
		lineitem l,
		partsupp ps,
		orders o,
		nation n
	where
		s.s_suppkey = l.l_suppkey
		and ps.ps_suppkey = l.l_suppkey
		and ps.ps_partkey = l.l_partkey
		and p.p_partkey = l.l_partkey
		and o.o_orderkey = l.l_orderkey
		and s.s_nationkey = n.n_nationkey
		and p.p_name like '%yellow%'
	) as profit
group by
		nation,
		o_year
order by
		nation,
		o_year desc
limit 10;
```

## Q1 - GPU

```
CALL gpu_execution("
select
	nation,
	o_year,
	sum(amount) as sum_profit
from
	(
	select
		n.n_name as nation,
		extract(year from o.o_orderdate) as o_year,
		l.l_extendedprice * (1 - l.l_discount) - ps.ps_supplycost * l.l_quantity as amount
	from
		part p,
		supplier s,
		lineitem l,
		partsupp ps,
		orders o,
		nation n
	where
		s.s_suppkey = l.l_suppkey
		and ps.ps_suppkey = l.l_suppkey
		and ps.ps_partkey = l.l_partkey
		and p.p_partkey = l.l_partkey
		and o.o_orderkey = l.l_orderkey
		and s.s_nationkey = n.n_nationkey
		and p.p_name like '%yellow%'
	) as profit
group by
		nation,
		o_year
order by
		nation,
		o_year desc
limit 10
");
```

***

# Q2

## Q2 - CPU

```
SELECT c_count,
       count(*) AS custdist
FROM
  (SELECT c_custkey,
          count(o_orderkey) AS c_count
   FROM customer
   LEFT OUTER JOIN orders ON c_custkey = o_custkey
   AND o_comment NOT LIKE '%special%requests%'
   GROUP BY c_custkey)
GROUP BY c_count
ORDER BY custdist DESC,
         c_count DESC;
```

## Q2 - GPU

```
CALL gpu_execution("
SELECT c_count,
       count(*) AS custdist
FROM
  (SELECT c_custkey,
          count(o_orderkey) AS c_count
   FROM customer
   LEFT OUTER JOIN orders ON c_custkey = o_custkey
   AND o_comment NOT LIKE '%special%requests%'
   GROUP BY c_custkey)
GROUP BY c_count
ORDER BY custdist DESC,
         c_count DESC
");
```

***

# Q3

## Q3 - CPU

```
SELECT
	count(*) n,
    l_returnflag return,
    l_linestatus status,
    sum(l_quantity) as sum_qty,
    sum(l_extendedprice) as sum_base_price,
    sum(l_extendedprice * (1 - l_discount)) as sum_disc_price
FROM lineitem
WHERE l_shipdate <= date '1998-09-02'
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;
```

## Q3 - GPU

```
CALL gpu_execution("
SELECT
	count(*) n,
    l_returnflag return,
    l_linestatus status,
    sum(l_quantity) as sum_qty,
    sum(l_extendedprice) as sum_base_price,
    sum(l_extendedprice * (1 - l_discount)) as sum_disc_price
FROM lineitem
WHERE l_shipdate <= date '1998-09-02'
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus
");
```

