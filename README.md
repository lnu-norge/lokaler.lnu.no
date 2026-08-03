# LNU Lokaler
---
Landsrådet for Norges barne- og ungdomsorganisasjoner or LNU has created this open source project to help its members more easily find and book suitable spaces or venues. These spaces can be anything from a school to a community center.

The problem this app aims to solve is that booking these types of venues can take a long time, it can be difficult to find suitable venues and find venues that can accommodate the needs the members have. This process can take up to a year. This project wants to use its members feedback to maintain the database and the idea is to create a mix between a booking type of site and a wiki.

### Want to contribute!
Want to help and contribute to this project? Send an email to [lokaler@lnu.no](mailto:lokaler@lnu.no).

You can raise issues here on our github page or submit your own PR's.

### What is Lokaler.lnu.no?
Lokaler.lnu.no is built by [LNU](https://lnu.no) and this project was originally financed with subsidies from [Bufdir](https://www.bufdir.no/).

# Installation
---
If you want to install this project on your computer then follow the guides below.
If you find bugs, please submit them.

## Install 

### Pre-requisites

- **Ruby 4.0.6** — the exact version lives in `.ruby-version`, so most version
  managers (chruby, rbenv, mise, asdf) will pick it up on their own
- **Rails 8.1** — installed by `bundle install`, no need to install it yourself
- **Node 26.5.1** — the exact version lives in `.nvmrc` (`nvm use` reads it)
- **Yarn 4** — provided by Corepack, see below
- **PostgreSQL 15 or newer, with the PostGIS extension** — PostGIS is not
  optional, the app uses the `postgis` adapter and geo columns throughout

Production runs PostgreSQL 18 with PostGIS 3.6, so that is the safest pairing to
develop against.

### Pull the code locally

Use `git clone git@github.com:lnu-norge/lokaler.lnu.no.git` to pull the code.

### Install rails and ruby gems

Go into the folder lokaler.lnu.no, and run the command: `bundle install`
> TIP! After this command you  should see a long list of green and white lines

### Install node packages

The project uses Yarn 4, which comes from Corepack. Node stopped bundling
Corepack in version 25, so install it once:

```
> npm install -g corepack
> corepack enable
```

Without it, `yarn` resolves to whatever old global Yarn 1 you happen to have,
which cannot read `.yarnrc.yml` and will fail.

Then run: `yarn install`

### Set up database

Copy `config/database.yml.example` and name it `config/database.yml`
```
> cp config/database.yml.example config/database.yml
```
Now run the command: `rails db:create db:migrate`

Congratulations! You have now setup the project.

## Set up ENV variables for third party services

See the file `.env.example` for a list of third party services you can use with the app. 

Locally you need a `MAPBOX_API_KEY` to test the map functionality, and `GOOGLE_OAUTH_CLIENT_ID` as well as `GOOGLE_OAUTH_CLIENT_SECRET` to test logging in with Google. 

To get these, sign up at [https://mapbox.com/](https://mapbox.com/) for a free key, and at [https://console.cloud.google.com/apis/dashboard](https://console.cloud.google.com/apis/dashboard) 

If you are a core contributor, ask the admins for a key that works.

##  Run application in dev mode
To run the application there are two options:

#### Run with precompiled assets, like in prod

1. In the terminal and while in the folder lokaler.lnu.no run the command:
> `ASSETS_COMPILED_LIKE_IN_PROD=true rails s`
2. Now go to your browser and go to website: http://localhost:3000/

This will precompile the assets, like JS, images, and CSS. It's not suited for development, but works for testing the app out. It's also what's done behind the scenes when you run rspec tests. 

To remove the precompiled assets again run `rails assets:clobber`

You can now signup and use the app locally on your machine.

#### Run with live compilation of assets, for development

There are four commands to run everything for dev  mode: 

```bash
bin/rails s -p 3000 # Runs the rails server
bundle exec guard # Reloads the rails server and browser if rails files change
yarn build:dev --watch # Builds and rebuilds JS when files change
yarn build:css --watch # Builds and rebuilds CSS when files change
```

These are defined in `Procfile` and `Procfile.dev`

To run all at the same time, you can either use `foreman` or [overmind](https://github.com/DarthSim/overmind).  Overmind must be installed on your machine. Foreman ships with this project. Overmind is the better option, but foreman works.

1. While in the folder "lokaler.lnu.no  run the command:
> `foreman s` (This uses Procfile, which does not boot rails)
2. Open up a new terminal window, same folder, run the command:
> `rails s` (This boots rails in a seperate window, so you get the logs for rails there. 
3. Now go to your browser and go to website: http://localhost:3000/

You can now signup and use the app locally on your machine. At the same time you'll have access to the server logs in the terminal windows. First window is for Javascript and CSS bundling and the second one for the actual web server and database connection.

### Running tests
To run tests you can simply type `rspec`

This will run all the tests in `/spec`. You can also specify a specific test to run like this
> rspec spec/models/facility_category_spec.rb

#### Running tests in parallel
You can run the tests in parallel this will make them faster, this requires you to setup the parallel DB which is done with
`rails parallel:prepare`

After that you can run the tests with
`parallel_rspec`

# Install instructions Ruby on Rails
---
To get this project up and running on your computer you will need Ruby, Node and
PostgreSQL with PostGIS. Rails and the other gems are installed by `bundle
install`, so you do not install those separately.

Do not hard-code versions from a guide. This project pins its own in
`.ruby-version` and `.nvmrc`, and those files are the source of truth — follow a
guide for the tooling, then let the version manager read the pinned version.

## Ubuntu or other Linux versions
1. Follow the GoRails setup guide for your Ubuntu release:
   https://gorails.com/setup/ubuntu — pick your actual version from the list.
2. Any Ruby version manager works. We use chruby and rbenv, so those are the
   ones we can help debug.
3. Skip the git setup if you already have it.
4. You can skip the MySQL section. You do need PostgreSQL, and you also need the
   PostGIS extension:
   ```
   > sudo apt install postgresql postgis postgresql-<version>-postgis-3
   ```

## Apple MacOS
1. Install a Ruby version manager. [chruby](https://github.com/postmodern/chruby)
   with [ruby-install](https://github.com/postmodern/ruby-install), or rbenv, or
   [mise](https://mise.jdx.dev/) — all fine. Then install the version named in
   `.ruby-version`.
2. Install Node with [nvm](https://github.com/nvm-sh/nvm), then run `nvm use` in
   the project folder to pick up `.nvmrc`.
3. Install PostgreSQL with PostGIS. The simplest route is
   [Postgres.app](https://postgresapp.com/), which bundles PostGIS. With
   Homebrew you need both:
   ```
   > brew install postgresql@18 postgis
   ```

## Windows
If you are on Windows we recommend using Windows Subsystem for Linux version 2 if possible.

#### WSL2
1. Follow this guide. The simplified version should be fine. https://docs.microsoft.com/en-us/windows/wsl/install-win10
2. Now try to search on your start menu for Ubuntu (it should show up and have a orange icon). If it doesn't, then restart your computer and try again.

3. If it still does not appear, then go to Windows Store (it is Windows own app store) and search for Ubuntu 24.04 or a newer Ubuntu LTS. [Windows Store](https://www.microsoft.com/store/productId/9N6SVWS3RX71)
	*	Install Ubuntu from the Windows store, launch the software and follow the guide.
	*	You now should have Ubuntu installed. This will be your "window" into the world of Linux.
4. Now that you have Ubuntu, or other Linux, installed on your Windows computer you are ready to install the rest. You can now follow the Ubuntu guide above - just make sure you are using the newly installed Ubuntu terminal instead of Powershell or CMD.
> TIP! You can use any terminal you want, but it makes things a bit harder. Google it if you want.
5. After everything is finished you will need a Code Editor if you want to contribute (Sublime, VS-Code, or any other).

## Deploying to staging or production with Kamal

The app uses Kamal for deployments, and is currently set up to deploy to Hetzner.

To deploy, you need to have the right .env variables set up, including the Kamal Registry Password. You also need a SSH key for the prod server.

After you have that, you can deploy new versions with:

`kamal deploy --destination production` for production
`kamal deploy --destination staging` for staging

## Seeding

Run `rails db:seed` to get sample data into your app. 

You can also set the ENV variable ["SEED_FILE"](https://github.com/lnu-norge/lokaler.lnu.no/pull/66) to load a different seed file than the current environment dictates.

### Syncing

To get geographical data for Fylker and Kommuner from GeoNorge, run: `rails geo:import_geographical_areas_from_geonorge`. This will hit the APIs of GeoNorge and create or update any fylker and kommuner, as well as make sure all Spaces are matched with a Fylke and a Kommune.

To get data on all schools from Nasjonalt Skoleregister about schools after seeding, run `rake sync:sync_schools_from_nsr`.

To get contact information for all schools (and other spaces with an organization number) run `rake sync:brreg_space_contacts`.


# Want to learn to code or learn Rails?
---
Ruby on Rails is a great coding language to learn if you are a beginner as well as a seasoned developer. What makes people love Ruby on Rails is that making apps are quite straight forward - and does not necessary involve thousands of hours of coding. Once you know Ruby on Rails you will be able to create a prototype application in as little as a week. The language is quite verbose and therefore becomes easier for beginners to read then some other languages. Apps built with Ruby on Rails, Twitter (the first 10 years), Github, Stripe, Shopify, Airbnb and many more.

## If you know coding from before
If you know an other language like Javascript/React/Node, Python, Java, C (and all the variants) then picking up Ruby on Rails is fairly straight forward. Go to [Rails Tutorial](https://www.railstutorial.org/), the book costs a bit of money, but the older versions of the course is freely available on the site.

We use Hotwire, Turbo, StimulusJS and Tailwind in the project.
To learn [Hotwire and StimulsJS](https://hotwired.dev/) read the documentation and if you want see this in action then this [youtube tutorial](https://www.youtube.com/watch?v=NtTfYfWAzw0) is a good starting point.

[Tailwind](https://tailwindcss.com/) is our framework for styling. It takes a bit of time to get used to, but once you do then most people tend to fall in love with it. Hard to describe - needs to be tried. This [youtube tutorial](https://www.youtube.com/watch?v=UBOj6rqRUME) is a great resource.

## If you are starting from Scratch
We recommend [The Odin Project](https://www.theodinproject.com/) if you are starting from scratch. It is completely free, it teaches you everything you need to know and more. It starts off with the basics and by the time you are done with the course you are a junior developer with impressive skills. This course will take a complete beginner about 3-6 months to complete.

They have a Discord channel for help and they offer two paths - Rails and Javascript (Node). If you choose one, then the other will be easy afterwards.

Let us know if we can help you out in any way, and feel free to clone this project to experiment your new found knowledge on as you progress in the course.

# Backups and restoring

## Upgrading PostgreSQL / PostGIS

The database runs as a Kamal accessory (`db` in `config/deploy.yml`), currently
`postgis/postgis:15-3.3`, with its data in the `data` volume. Staging and
production share that image definition and both live on the same host.

PostgreSQL cannot read a data directory written by a different major version, so
moving 15 → 18 is a dump and restore, not an image bump. Changing the image
without migrating the data leaves the container unable to start.

The application itself is already verified against the target: the full suite
passes against PostgreSQL 18.4 / PostGIS 3.6.4, and CI runs `postgis:18-3.6`.

Two things to know before starting:

- **Dump with an 18 client.** `pg_dump` can read servers older than itself but
  not newer. Debian trixie — what the app image is built on — ships
  `postgresql-client` 17, whose `pg_dump` will refuse an 18 server later on. Run
  the dump from a `postgis/postgis:18-3.6` container instead.
- **The volume mount path changes.** From 18 on, these images keep data in a
  major-version subdirectory and expect a single mount at
  `/var/lib/postgresql`. The accessory currently mounts
  `data:/var/lib/postgresql/data`, which an 18 image treats as a stray volume
  and refuses to start on. That line has to change together with the image.
  See https://github.com/docker-library/postgres/pull/1259
- **Do staging first.** It is the same host and the same accessory definition, so
  it is a genuine rehearsal.

Rough sequence, per destination:

1. Put the app in maintenance and stop writes: `kamal app stop -d production`.
2. Dump from the running 15 server using an 18 client, writing outside the
   volume you are about to replace.
3. Verify the dump is complete and non-empty before touching anything else.
4. `kamal accessory stop db -d production`, then rename the data directory on the
   host rather than deleting it — that renamed directory is the rollback.
5. Change the `db` accessory image in `config/deploy.yml` to
   `postgis/postgis:18-3.6` and commit.
6. `kamal accessory boot db -d production` to initialise a fresh 18 data dir.
7. Restore the dump, then confirm `SELECT postgis_full_version();` reports 3.6
   and spot-check row counts against the dump.
8. `kamal app boot -d production` and smoke-test.
9. Keep the renamed 15 data directory until you are satisfied, then remove it.

`config/deploy.yml` is deliberately still on `15-3.3`, so step 5 is the point of
no return — nothing before it changes production.

