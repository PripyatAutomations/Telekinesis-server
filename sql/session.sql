drop table if exists netrig_sessions;
create table netrig_sessions (
    id integer primary key autoincrement,
    callsign text not null,
    token text not null,
    server text not null default 'localhost',
    created integer,
    last_active integer,
    sip_user text not null,
    sip_pass text not null
);
