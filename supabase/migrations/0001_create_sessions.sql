-- Durable table for sessions (idempotent)
create table if not exists sessions (
  id           text primary key,
  activity_id  text unique,
  source       text not null default 'strava',
  name         text,
  distance     integer not null,
  duration     integer not null,
  created_at   timestamptz not null,
  ppi          integer not null,
  best_ppi     integer not null
);

-- Enable Row Level Security (service role bypasses RLS so no policies needed)
alter table sessions enable row level security;



