use aidev;
select * from tb_member;

create table tb_board(
	b_idx int auto_increment primary key,
    b_userid varchar(20) not null,
    b_name varchar(20) not null,
    b_title varchar(100) not null,
    b_content text not null,
    b_hit int default 0,
    b_regdate datetime default now(),
    b_like int default 0
);
select * from tb_board;
select * from tb_board order by b_idx desc limit 0, 10; -- 1page
select * from tb_board order by b_idx desc limit 10, 10; -- 2page
select * from tb_board order by b_idx desc limit 20, 10; -- 3page
select * from tb_board order by b_idx desc limit 30, 10; -- 3page
update tb_board set b_hit = b_hit + 1 where b_idx=2;

create table tb_reply(
	re_idx int auto_increment primary key,
    re_userid varchar(20) not null,
    re_name varchar(20) not null,
    re_content varchar(2000) not null,
    re_regdate datetime default now(),
    re_boardidx int,
    foreign key (re_boardidx) references tb_board(b_idx) on update cascade
);
select * from tb_reply;

create table tb_like(
	like_idx int auto_increment primary key,
    like_userid varchar(20) not null,
    like_boardidx int,
    foreign key (like_boardidx) references tb_board(b_idx) on update cascade
);
select * from tb_like;

create table tb_hit(
	hit_idx int auto_increment primary key,
    hit_userid varchar(20) not null,
    hit_boardidx int,
    foreign key (hit_boardidx) references tb_board(b_idx) on update cascade
);
select * from tb_hit;