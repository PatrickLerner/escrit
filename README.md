![](http://escrit.eu/assets/logo-i.png)

# Description

escrit.eu is a little private project I have been working on for the past few months, in it's earliest revisions which were originally written in PHP, since about late 2014. This current version of the software is written in Ruby on Rails and under current and constant development. A live version of it can be found, as the project name suggest under [escrit.eu](http://escrit.eu/).

The website is a tool that supports language learners in their endeavour to further their knowledge of vocabulary and grammar, primarily through extensive and intensive reading. It allows them to look up words in a text they provide (or pick from publicly available ones) to and save translations for words. In this project they acquire new vocabulary without much effort. The learning effort is, however, also extended by a build-in vocabulary trainer that allows the users to learn specific vocabulary more intensely as well.

# Setup

The application requires an active PostgreSQL server for all of production, development and testing. You can set the credentials for the user who accesses the server via the environment variables `ESCRIT_DATABASE_USER` and `ESCRIT_DATABASE_PASSWORD` while the database names need to be called `escrit_X` where `X` is mode in which rails operates (production, development, test).

You further must set two randomly generated strings as the secrets to the environment variables `SECRET_KEY_BASE` and `DEVISE_SECRET_KEY`. For production use you must also set credentials to a gmail account used to send emails when required. `GMAIL_USERNAME`, `GMAIL_PASSWORD` and `GMAIL_DOMAIN` (default `=escrit.eu`).

# Source code

The source code is not released under any open source license and all rights retain with the author(s). Redistribution or modification without permission is not permitted.

# Stylistic guidelines

  * Preference of British English over American
  * Absolutely no title case if avoidable (e.g. "Vocabulary trainer", never "Vocabulary Trainer")
  * Never capitalize the name, i.e. always `escrit.eu`, never `Escrit.eu`. The `.eu` is generally part of the branding, but does not always have to be included if it is stylistically undesireable.
