# Reach Digital Development Vagrant Box

Super easy to install, fast and a pleasure to work with.

Based on images from https://github.com/byteinternet/hypernode-vagrant

# Requirements

a. Unison installed:

```bash
brew install unison
brew tap eugenmayer/dockersync
brew install eugenmayer/dockersync/unox
```

```bash
# Fatal error: Server: Filesystem watcher error: cannot add a watcher: system limit reached
sudo sysctl -w kern.maxfilesperproc=524288
sudo sysctl -w kern.maxfiles=524288
ulimit -n 524288
```

b. [Vagrant](https://www.vagrantup.com/downloads.html) installed

c. Vagrant plugins installed:

[`vagrant plugin install pluginname`](https://www.vagrantup.com/docs/plugins/usage.html)

* vagrant-hostmanager 
* vagrant-auto_network
* vagrant-unison2

d. [VirtualBox](https://www.virtualbox.org/) installed

# Getting Started

a. Create the following folder structure:
```
myproject/src
myproject/vagrant
```
b. Copy the vagrant box
```
cd myproject
git clone git@github.com:ho-nl/vagrant-development-box.git vagrant
cd vagrant
cp config.rb.dst config.rb
```
c. Edit it to reflect your project settings
```ruby
name 'projectname'
hostname name + '.box'
domains %w(www.'+ name + '.box)
profiler false
developer true
magento2 true
php7 true
linked_clone true
cpu 2
memory 2048
unison_host '../src'
unison_repeat 'watch'
varnish true
#varnish_vcl 'magento2/varnish.vcl'
xdebug false
```

d. Run `vagrant up` in this directory, if everything went alright you're greeted with this message:

```
==> hypernode: Welcome to Hypernode Vagrant Box!
==> hypernode: You can login now with in order to use your box:
==> hypernode: $ ssh app@your-project-name.box -A
==> hypernode: To access database, you can use the following credentials in your app:
==> hypernode: Username: app
==> hypernode: Password: ************
```

Please note: it will show some red errors but you can ignore that, those are mostly warnings that can be ignored. If you see a sea of red something probably goes wrong.

## Configuration Options

* `name` - name of your node
* `hostname` - default project hostname
* `domains` - list of additional domain names for your project 
* `varnish` - enable or disable varnish for your project (can be always enabled for Magento 2, can be disabled in the application) (default: `false`)
* `varnish_vcl` - relative path to the varnish file that is to be used, e.g. 'magento2/varnish.vcl' (default: null)
* `profiler` - enable or disable tideways-profiler (default: `false`)
* `developer` - enable or disable developer mode in Magento (default: `false`)
* `magento2` - Magento 2.0 installment? (default: `false`)
* `install` - Shall Magento be installed? (default: `false`, only Magento 2.0 installation supported)
* `shell` - Install FishShell? (default: `false`)
* `php7` - PHP7 instead of PHP5? (default: `false`)
* `linked_clone` - Link a master box instead of importing, should reduce disk space ussage (default: `false`)
* `cpu` - number of CPUs to dedicate to your VM (default: `1`)
* `memory` - memory in MB to dedicate to your VM (default: `1024`)
* `user` - User name for nfs share permissions (default: `app`)
* `group` - Group name for nfs share permissions (default: `app`)
* `uid` - User ID of your host to be mapped to linux VM (default: `Process.euid`)
* `gid` - Group ID of your host to be mapped to linux VM (default: `Process.egid`)
* `directory` - Directory to be used as mount on host machine (default: `server`)
* `network` - Network mast for automatic network assignment to VM (default: `33.33.33.0/24`)
* `unison_ignore` - Which files won't be used with updating changes with Unison (default `Name {.DS_Store,.git,var}`)
* `unison_host` - Relative path from this vagrant folder to the source of the root of the installation. (default: `../src`)
* `unison_guest` (default: `public`)
* `unison_repeat` (default: `5`) Unison repeat mode, can be a number in seconds or 'watch'
* `xdebug` Install xdebug? (default: `false`)
* `forward_port` Forward port 80 to 8080 on host (default: `false`) 

## Adding custom shell provisioners

You can easily add more provision shell scripts from configuration file (config.rb):
```ruby
shell_add 'some-custom-shell-script.sh'

# Will provision only if PHP7 flag is turned on
shell_add 'some-custom-script-for-php7.sh', :php7  
```

## Connecting to your Vagrant box

There are two ways to connect to your Vagrant box:
1. As Root to do system administration: `vagrant ssh`
	- DO NOT edit project files with the root user, this will give permission errors in the application
2. As User to do all development work on: `ssh app@your-project-name.box`

## Syncing the `../src` (unison) folder with the vagrant box.

The filesystem of your vagrant box must contain all files to be able to operate quickly.
The filesystem of your host system must contain all files for PHPStorm be able to operate.

To achieve this, we use Unison. From the vagrant folder, run the following.
```
vagrant vagrant unison-sync-polling
```

*You always need to enable this when working with the box, or else the local changes wont be made in the box.*

### Resolve sync issues `skipped: var (properties changed on both sides)`

Start unison with the following command `vagrant unison-sync-interact` to interactively solve issues. For more information take a look at the [vagrant plugin page](https://github.com/dcosson/vagrant-unison2#sync-in-interactive-mode).

## Connecting to MySQL externally (SequelPro)

You can directly connect to the vagrant box with the following credentials:
```
host: your-project-name.box
username: app
password: as mentioned in vagrant up
```


# Magento 2 configuration

## env.php

The system automatically creates a database named `test`, this can be used to upload your information. You can use the same DB connection info as used in SequelPro

## Running grunt/gulp

You can run your `grunt exec:all` from outside the box. If you have custom gulp scripts, those can also be ran from outside the box (even browserSync should work).

## Cache handling

Since box doesn't sync the `var` folder, Magento's cache needs to be flushed from the inside of the box: `php bin/magento c:f`.

## Varnish

This box supports Varnish by default. Installation and usage instructions can be found here:
- https://support.hypernode.com/knowledgebase/varnish-on-magento2/

## Redis

Magento 2.1: http://devdocs.magento.com/guides/v2.1/config-guide/redis/redis-pg-cache.html
Magento 2.2:

```
php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-db=0
php bin/magento setup:config:set --page-cache=redis --page-cache-redis-db=1
php bin/magento setup:config:set --session-save=redis --session-save-redis-db=2
```

## Sphinx

By default the `searchd` is installed so you can used.

# Magento 1 configuration

## Config needs to have correct unison_guest

By default this box will try to set the unison_guest folder to the magento2 pub folder. For a Magento 1 instalattion this will result in a default Nginx 404 page when you try to reach your server. Add the following rule to your `config.rb` file: `unison_guest 'public'`

## Need to run modman deploy in vagrant box

The symlinks created on your host machine won't work in the vagrant box. This will result in errors with finding files or (when you use PHP7) a error in layout.php (because the Inchoo_PHP7 module was not applied correctly). Run `modman deploy-all --force` in your vagrant box to fix these issues.

# Known issues:
- You can't run `vagrant provision` to update the configuration. Once you have enabled varnish for example and you want to disable it, you'll have to recreate the box or fix it in the box manually.

