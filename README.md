# Lokaler fra LNU
---
Landsrådet for Norges barne- og ungdomsorganisasjoner or LNU has created this open source project to help its members more easily find and book suitable spaces or venues. These spaces can be anything from a school to a community center.

The problem this app aims to solve is that booking these types of venues can take a long time, it can be difficult to find suitable venues and find venues that can accommodate the needs the members have. This process can take up to a year. This project wants to use its members feedback to maintain the database and the idea is to create a mix between a booking type of site and a wiki.

### Want to contribute!
Want to help and contribute to this project? Read how on [om.lokaler.lnu.no/bidra](https://om.lokaler.lnu.no/bidra/).

You can raise issues here on our github page or submit your own PR's.
We will review these and give you feedback.

### What is Lokaler.lnu.no?
Lokaler.lnu.no is built by [LNU](https://lnu.no) and this project is financed with subsidies from [Bufdir](https://www.bufdir.no/).

If you want to read more about the project go to [om.lokaler.lnu.no](https://om.lokaler.lnu.no/)

# Installation
---
If you want to install this project on your computer then follow the guides below.
If you find bugs, please submit them.

## Install (If you have Ruby and Rails already installed)

1. Copy `config/database.yml.example` and name it `config/database.yml`
> cp config/database.yml.example config/database.yml
2. Open your terminal
3. Go to the folder you want the repository
> TIP! This is the command: cd myFolder/myOtherFolder
3. Write and run command: git clone git@github.com:lnu-norge/lokaler.lnu.no.git
4. Go into the folder lokaler.lnu.no
5. Run the command: bundle install
> TIP! After this command you  should see a long list of green and white lines
6. Run the command: yarn
7. Now run the command: rails db:create db:migrate

Congratulations!!! You have now setup the project.

###  Run application
To run the application there are two options:
#### I only want to see the application and play around
1. In the terminal and while in the folder lokaler.lnu.no run the command:
> rails s
2. Now go to your browser and go to website: http://localhost:3000/
It takes a little time for the application to bundle itself so if it does not show up straight away then wait up to a minute. If you get errors please let us know.

You can now signup and use the app locally on your machine.

#### I want to contribute or play around with the code
1. While in the folder "lokaler.lnu.no  run the command:
> foreman s
2. Open up a new terminal window, same folder, run the command:
> rails s
3. Now go to your browser and go to website: http://localhost:3000/

You can now signup and use the app locally on your machine. At the same time you'll have access to the server logs in the terminal windows. First window is for Javascript and CSS bundling and the second one for the actual web server and database connection.

First window also contains something called live reload.
You can active that now inside your browser and the browser will automatically reload when you change code view specific code.
[Live Reload for Chrome](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei)
[Live Reload for Firefox](https://addons.mozilla.org/nb-NO/firefox/addon/livereload-web-extension/)

### Running tests
To run tests you can simply type
> rspec

This will run all the tests in `/spec`. You can also specify a specific test to run like this
> rspec spec/models/facility_category_spec.rb

#### Running in parallel
You can run the tests in parallel this will make them faster, this requires you to setup the parallel DB which is done with
> rails parallel:prepare

After that you can run the tests with
> parallel_rspec

# Install instructions Ruby on Rails
---
To get this project up and running on your computer you will need to install a few things on your system - Ruby, Rails, Yarn and PostgresQL. It is slightly different how you do this depending on whether you are on Ubuntu, Mac or Windows.
## Ubuntu or other Linux versions
1. Follow the instructions in this guide: https://gorails.com/setup/ubuntu/20.04
2. We recommend using the Rbenv option, only because we can support you if issues.
3. Skip the git setup if you already have it
4. The MySQL part is optional, but you have to setup Postgres.

That should be it.
## Apple MacOS
1. Follow the instructions in this guide: https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-macos
> IMPORTANT- for  STEP 2
> When prompted to run the command: rbenv install 2.6.3
> Use the command: rbenv install 3.0.1
>
> After that it asks you to run: rbenv global 2.6.3
> Run: rbenv global 3.0.1 instead
>
> This is the version of Ruby we are using.

> IMPORTANT - for STEP 4
> -   gem install rails -v 5.2.3 should be changed to: gem install rails -v 6.1.4.1
>
> This is the version of Rails we are using

2. You can skip STEP 5 and the rest of the steps.
3. You now need Postgresql, download the installer here. Latest version should be okay.
https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
> TIP - If you want to follow a guide then this guide is okay. They install a much older version then you will be doing but it should be very similar.
>https://www.postgresqltutorial.com/install-postgresql-macos/

## Windows
If you are on Windows we recommend using Windows Subsystem for Linux version 2 if possible.

#### WSL2
1. Follow this guide. The simplified version should be fine. https://docs.microsoft.com/en-us/windows/wsl/install-win10
2. Now try to search on your start menu for Ubuntu (it should show up and have a orange icon). If it doesn't, then restart your computer and try again.

3. If it still does not appear, then go to Windows Store (it is Windows own app store) and search for Ubuntu 20.04 or any other Linux distribution that you may want. [Windows Store](https://www.microsoft.com/store/productId/9N6SVWS3RX71)
	*	Install Ubuntu from the Windows store, launch the software and follow the guide.
	*	You now should have Ubuntu installed. This will be your "window" into the world of Linux.
4. Now that you have Ubuntu, or other Linux, installed on your Windows computer you are ready to install the rest. You can now follow the Ubuntu guide above - just make sure you are using the newly installed Ubuntu terminal instead of Powershell or CMD.
> TIP! You can use any terminal you want, but it makes things a bit harder. Google it if you want.
5. After everything is finished you will need a Code Editor if you want to contribute (Sublime, VS-Code, or any other).

## Deploying to Heroku

We deploy the main app to Heroku, following Herokus standard practice.

In addition to the standard procedure, we have added an ENV variable ["SEED_FILE"](https://github.com/lnu-norge/lokaler.lnu.no/pull/66) for when you want Heroku (or any other system) to load a different seed file than the current environment dictates. Useful for Heroku, as Heroku always wants you to run in production mode - but you might want to seed with development data.
To get sendgrid to work you will also need to set the ENV variable ["HOST"] to equal to the domain you are using, example: `ENV["HOST"] = "app.herokuapp.com`

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
