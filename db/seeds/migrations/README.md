# Seed migrations

These are one-off seeds meant to run after migrations, to keep the migration file clean.

Will only be needed to run if you are running the migrations on an existing server with existing data.

Currently needs to be run manually by specifying SEED_FILE like this:

```bash
 SEED_FILE=migrations/foo rails db:seed
```

This will run the seed in migrations/foo.rb
