# A Linux Virtual Machine for Development

## Introduction

This is a project based on [Rails-Dev-Box](https://github.com/rails/rails-dev-box.git) project. (Tks to Xavier Noria and [Daniel Alvarenga](https://github.com/danielalvarenga))

This project automates the setup of a development environment for working. Use this virtual machine to work on a pull request with everything ready to hack and run the test suites.

## Requirements

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant](http://vagrantup.com)

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    host $ git clone https://github.com/efraimcf/vagrant-linux-dev.git
    host $ cd vagrant-linux-dev
    host $ vagrant up

That's it.

## What's In The Box
*Choose what to install in bootstrap.sh*

* Operation System upgrades
* Ruby (rvm, rbenv or ruby interpreter)
* Java 8 Oracle (with Maven)
* NodeJS (with NPM)
* PHP (with Apache)
* MySQL
* PostgreSQL
* SQLite3
* Memcached
* Redis
* RabbitMQ
* Git
* Curl
* ImageMagick

## Port Forward

There are 4 ports foward configurated:

* Port 8880 (PHP + Apache)
* Port 3000 (Ruby on Rails Applications) [1]
* Port 8080 (Java + Tomcat)
* Port 3306 (MySQL)
* Port 5432 (PostgreSQL)

[1] Be sure the web server is bound to the IP 0.0.0.0, instead of 127.0.0.1, so it can access all interfaces:

    bin/rails server -b 0.0.0.0

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    host $ vagrant suspend

then, resume to hack again

    host $ vagrant resume

Run

    host $ vagrant halt

to shutdown the virtual machine, and

    host $ vagrant up

to boot it again.

You can find out the state of a virtual machine anytime by invoking

    host $ vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    host $ vagrant destroy
    
Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

### rsync

Vagrant 1.5 implements a [sharing mechanism based on rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html)
that dramatically improves read/write because files are actually stored in the
guest. Just throw

    config.vm.synced_folder '.', '/vagrant', type: 'rsync'

to the _Vagrantfile_ and either rsync manually with

    vagrant rsync

or run

    vagrant rsync-auto

for automatic syncs. See the post linked above for details.

### NFS

If you're using Mac OS X or Linux you can increase the speed of Rails test suites with Vagrant's NFS synced folders.

With a NFS server installed (already installed on Mac OS X), add the following to the Vagrantfile:

    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
    config.vm.network 'private_network', ip: '192.168.50.4' # ensure this is available

Then

    host $ vagrant up

Please check the Vagrant documentation on [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) for more information.

## License

(Rails-dev-box) Released under the MIT License, Copyright (c) 2012–<i>ω</i> Xavier Noria.