drop table nofarm;

create table nofarm (
   dtm timestamp with time zone,
   farm int,
   farmland int,
   farmyard int);

create index idx_nofarm_dtm on nofarm(dtm);

