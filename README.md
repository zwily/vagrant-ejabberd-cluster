# What

Installing ejabberd in a clustered fashion is kind of a pain. Created
through many hours of googling and trial-and-error, this Vagrant project
will:
* Start two Ubuntu nodes.
* Install ejabberd.
* Set up clustering between them, programmatically. If you've wrestled
  with this before you'll understand why that's significant.
* Adds an admin user.

Yeah I know... you're welcome.

# How

1. Install [vagrant](http://vagrantup.com/)

        gem install vagrant

2. Download and install [VirtualBox](http://www.virtualbox.org/)
3. Install [vagrant-hostmaster](https://github.com/mosaicxm/vagrant-hostmaster)
 
        vagrant gem install vagrant-hostmaster

4. Clone this repo
5. (Optional) Tweak the settings in the Vagrantfile. There are ip
   addresses and domain names and stuff.
5. Run it!

        cd [repo]
        vagrant up

Once that's done, you will have two ejabberd nodes running in a cluster
Go to http://chat1.example.com:5280/admin/nodes/ to verify.
(default credentials: `admin@example.com`/`password`)

# Thanks

* The initial chef recipe for ejabberd comes from
https://github.com/cookbooks/ejabberd, but was heavily modified.
* This StackOverflow answer was invaluable in getting this going:
http://stackoverflow.com/questions/5156443/ejabberd-clustering/9101761#9101761

