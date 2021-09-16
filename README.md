# Lokaler.lnu.no

## Lisens
Lisens: [AGPL 3.0. Se egen lisensfil](./LICENSE).

LNU har også (c) på lokaler.lnu.no, og kan velge å dobbelt-lisensiere kildekoden om de ønsker det.

## Bidra gjerne!

Ønsker du å hjelpe til? Les hvordan på [om.lokaler.lnu.no/bidra](https://om.lokaler.lnu.no/bidra/)

PR tas imot med takk.

Bugs rapporteres her i Github som issues.

## Hva er Lokaler.lnu.no?

Målet med lokaler.lnu.no er å gjøre det enklere å finne og dele informasjon om lokaler for barne- og ungdomsfrivilligheten.

Lokaler.lnu.no er bygget av [LNU](https://lnu.no). Bygggingen er finansiert av tilskudd fra Bufdir.

Les gjerne mer om prosjektet på [om.lokaler.lnu.no](https://om.lokaler.lnu.no/)


## Install
1. Open your terminal
2. Go to the folder you want the repository
> TIP! This is the command: cd myfolder/myOtherFolder
3. Write and run command: git clone git@github.com:lnu-norge/lokaler.lnu.no.git
4. Go into the folder lokaler.lnu.no
5. Run the command: bundle install
> TIP! After this command you  should see a long list of green and white lines
6. Now run the command: rails db:create db:migrate
7. Lastly run the yarn command

Congratulations!!! You have now setup the project.

###  Run application
To run the application there are two options:
#### I only want to see the application and play around
1. While in the folder lokaler.lnu.no run the command:
> foreman s -f Procfile.dev
2. Now go to your browser and go to website: http://localhost:3000/

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

## Install instructions Ruby on Rails
To get this project up and running on your computer you will need to install a few things on your system - Ruby, Rails, Yarn and PostgresQL. It is slightly different how you do this depending on whether you are on Ubuntu, Mac or Windows.
### Ubuntu or other Linux versions
1. Follow the instructions in this guide: https://gorails.com/setup/ubuntu/20.04
2. We recommend using the Rbenv option, only because we can support you if issues.
3. Skip the git setup if you already have it
4. The MySQL part is optional, but you have to setup Postgres.

That should be it.
### Apple MacOS
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

### Windows
If you are on Windows we recommend using Windows Subsystem for Linux version 2 if possible.

#### WSL2
1. Follow this quide. The simplified version should be fine. https://docs.microsoft.com/en-us/windows/wsl/install-win10
2. Now try to search on your start menu for Ubuntu (it should show up and have a orange icon). If it doesn't, then restart your computer and try again.

3. If it still does not appear, then go to Windows Store (it is Windows own app store) and search for Ubuntu 20.04 or any other Linux distribution that you may want. [Windows Store](https://www.microsoft.com/store/productId/9N6SVWS3RX71)
	*	Install Ubuntu from the Windows store, launch the software and follow the guide.
	*	You now should have Ubuntu installed. This will be your "window" into the world of Linux.
4. Now that you have Ubuntu, or other Linux, installed on your Windows computer you are ready to install the rest. You can now follow the Ubuntu guide above - just make sure you are using the newly installed Ubuntu terminal instead of Powershell or CMD.
> TIP! You can use any terminal you want, but it makes things a bit harder. Google it if you want.
5. After everything is finished you will need a Code Editor if you want to contribute (Sublime, VS-Code, or any other).
