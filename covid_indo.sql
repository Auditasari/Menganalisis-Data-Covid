SELECT * FROM data_covid.indonesia;
# mengubah tipe data tanggal
alter table indonesia 
change column `tanggal` `tanggal` date not null;
alter table indonesia
change column `id` `id` int not null;
#menggubah nama kolom 
alter table indonesia 
change column `Population` `populasi` int not null,
change column `Longitude` `longitude` double not null,
change column `Latitude` `latitude` double not null,
change column `Case Fatality Rate` `tingkat_kematian` text not null,
change column `Case Recovered Rate` `tingkat_kesembuhan` text not null;
# menghapus kolom yang tidak terpakai 
alter table indonesia
drop `Area (km2)` ,
drop `Island`,
drop `Province`; 
# menjadikan kolom id mejadi primary key
alter table indonesia 
change column `id` `id` int not null,
add primary key (`id`);
#membuat tabel data kasus harian Indonesia 
create table data_kasus(
select tanggal, monthname(tanggal) as bulan, year(tanggal) as tahun, 
sum(kasus_aktif) as kasus_aktif, sum(kasus_baru) as kasus_baru, 
sum(meninggal_baru) as kasus_meninggal,
sum(sembuh_baru) as kasus_sembuh from indonesia 
group by tanggal order by tanggal);
create table data_kasus_indonesia(
select * 
from 
(
select tanggal,bulan, tahun, kategori,
case 
when kategori = 'kasus_baru' then kasus_baru
when kategori = 'kasus_meninggal'then kasus_meninggal
when kategori = 'kasus_sembuh' then kasus_sembuh
when kategori = 'kasus_aktif' then kasus_aktif
end as kasus
from data_kasus
cross join 
( 
select 'kasus_baru' as kategori
union all
select'kasus_meninggal'  
union all
select 'kasus_sembuh'
union all
select 'kasus_aktif'
) as kategori
) as unpivotset);
# membuat tabel data bulanan 
create table data_bulanan
select tahun,bulan, kategori, sum(kasus) as kasus from data_kasus_indonesia 
group by kategori, bulan,tahun order by tahun;
# mebuat tabel data tahunan
create table data_tahunan 
select tahun, kategori, sum(kasus) as kasus from data_kasus_indonesia
group by kategori, tahun order by tahun;

#data total 
select  kategori, sum(kasus) as kasus from data_kasus_indonesia group by kategori; 
#menyatukan total kasus menjadi satu kategori 
create table total_kasus
(
select * from
(
select tanggal,lokasi,kategori,
case
when kategori = 'total_aktif' then total_kasus_aktif
when kategori = 'total_meninggal' then total_meninggal
when kategori = 'total_sembuh' then total_sembuh 
when kategori = 'total_kasus' then total_kasus
end as total
from indonesia 
cross join 
(
select 'total_aktif' as kategori
union all
select 'total_meninggal'
union all
select 'total_sembuh'
union all
select 'total_kasus'
) as ketegotri
) as unpivotset);

create table data_total_2022
select tanggal, lokasi, kategori, total from total_kasus 
where tanggal between '2022-09-15' and '2022-09-16';

