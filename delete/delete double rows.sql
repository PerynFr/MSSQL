create table t (
    id int primary key,
    v int
);

insert into t(id, v) values 
(1, 1),(2, 1),(3, 2),(4, 2),(5, 1),(6, 1),
(7, 2),(8, 3),(9, 2),(10, 4),(11, 3);

select * from t

delete t
from t
join t t1 on t.v = t1.v and t.id > t1.id

select * from t