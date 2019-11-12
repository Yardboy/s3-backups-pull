# README

This is a simple docker-compose container with a ruby script to
download the latest backup files from one or more S3 buckets
where `dokku mysql:backup` files are being uploaded.

How to use:

* Update `CUSTOMERS` constant in `backups.rb` with customer keys

* Configure a `.env` file for these customer keys according to `.env.example`

* Run `bin/dev build` once to build the container

* Run `bin/dev up` any time to run the backups

* Run `bin/dev bash` to enter the container at a bash prompt
