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

```
vagrant plugin install vagrant-hostmanager 
vagrant plugin install vagrant-auto_network
vagrant plugin install vagrant-unison2
```

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
```

c. Create a config.rb file with your project settings
```ruby
name 'paracord'
hostname name + '.box'
magento2 true
#unison_guest 'public' #when magento 1
#varnish true
#varnish_vcl 'magento2/varnish.vcl'
#xdebug true
```

d. Run `vagrant up` in this directory, if everything went alright you're greeted with this message:

<img width="613" alt="schermafbeelding 2017-09-30 om 14 57 29" src="https://user-images.githubusercontent.com/1244416/31045958-bb833756-a5ef-11e7-918b-6529dbc8480e.png">

Please note: it will show some red errors but you can ignore that, those are mostly warnings that can be ignored. If you see a sea of red something probably goes wrong.

## Configuration Options

<details>
  <summary>Expand to view all available options</summary>
	
* `name` - name of your node
* `hostname` - default project hostname
* `domains` - list of additional domain names for your project 
* `varnish` - enable or disable varnish for your project (can be always enabled for Magento 2, can be disabled in the application) (default: `false`)
* `varnish_vcl` - relative path to the varnish file that is to be used, e.g. 'magento2/varnish.vcl' (default: null)
* `developer` - enable or disable developer mode in Magento (default: `false`)
* `magento2` - Magento 2.0 installment? (default: `false`)
* `install` - Shall Magento be installed? (default: `false`, only Magento 2.0 installation supported)
* `shell` - Install FishShell? (default: `false`)
* `php_version` - 5.5|5.6|7.0|7.1? (default: `7.0`)
* `mysql_version` - 5.6|5.7? (only upgrades possible, default: `5.6`)
* `linked_clone` - Link a master box instead of importing, should reduce disk space usage (default: `false`)
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
* `unison_repeat` (default: `watch`) Unison repeat mode, can be a number in seconds or 'watch'
* `xdebug` Install xdebug? (default: `false`)
* `forward_port` Forward port 80 to 8080 on host (default: `false`) 

### Adding custom shell provisioners

You can easily add more provision shell scripts from configuration file (config.rb):
```ruby
shell_add 'some-custom-shell-script.sh'

# Will provision only if PHP7 flag is turned on
shell_add 'some-custom-script-for-php7.sh', :php7  
```

</details>

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
vagrant unison-sync-polling
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

Run your `grunt exec:all` or `gulp production` from **outside** the box.
They do work inside the box, but beware that the symlinks wont be correct in your local environment.

## Cache handling

The box doesn't sync the `var` folder, Magento's cache needs to be flushed from the inside of the box: `php bin/magento c:f`.

## Varnish

Vagrant is supported by default. Make sure you have a varnish.vcl generated for your project.

1. Log in to the Magento Admin as an administrator.
2. Navigate to Stores > Configuration > Advanced > System > Full Page Cache
3. From the Caching Application list, click Varnish Caching
4. Expand Varnish Configuration and insert the correct information:
	- Backend Host: 127.0.0.1
	- Backend Port: 8080
5. Save your VCL by clicking the button ‘Save config‘ in the top right
6. Click Export VCL for varnish 4

```
php bin/magento setup:config:set --http-cache-hosts=127.0.0.1:6081
```

Now we need to load in the varnish.vcl into varnish. To do this set the following configuration in your config.rb

```
varnish_vcl 'magento2/varnish.vcl'
```

And run `vagrant provision`

If everything is running 

## Redis

Magento 2.1: http://devdocs.magento.com/guides/v2.1/config-guide/redis/redis-pg-cache.html

Magento 2.2:
```
php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-db=0
php bin/magento setup:config:set --page-cache=redis --page-cache-redis-db=1
php bin/magento setup:config:set --session-save=redis --session-save-redis-db=2
```

### Make Redis accessible from outside your box:
`sudo vi /etc/redis/redis.conf`, replace `bind 127.0.0.1` with `bind 0.0.0.0`. Restart `sudo service redis-server restart`.

## Sphinx

By default the `searchd` is installed so you can used.

## Cron

Add the following to `crontab -e`
```
* * * * * php /data/web/magento2/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /data/web/magento2/var/log/magento.cron.log
```

```
* * * * * php /data/web/magento2/bin/magento queue:consumers:start quoteItemCleaner --max-messages=500
* * * * * php /data/web/magento2/bin/magento queue:consumers:start inventoryQtyCounter --max-messages=500
```

# Magento 1 configuration

## Config needs to have correct unison_guest

By default this box will try to set the unison_guest folder to the magento2 pub folder. For a Magento 1 installation this will result in a default Nginx 404 page when you try to reach your server. Add the following rule to your `config.rb` file: `unison_guest 'public'`

## Need to run modman deploy in vagrant box

The symlinks created on your host machine won't work in the vagrant box. This will result in errors with finding files or (when you use PHP7) a error in layout.php (because the Inchoo_PHP7 module was not applied correctly). Run `modman deploy-all --force` in your vagrant box to fix these issues.

# Common issues

## Error: The archive file is missing on some hosts.

When trying to use unison sync files between your machine and your vagrant box you might get a error that some archive files are missing. This happens mostly when you removed/changed/updated/moved your vagrant box. The error tells you what archive file is giving the issue, for example:
```
atal error: Warning: inconsistent state.  
The archive file is missing on some hosts.
For safety, the remaining copies should be deleted.
  Archive ard815862d1c3d858683fe30cd114e54e4 on host name.local should be DELETED
  Archive arc673d39eaeb32660a3e4c5296436adbf on host totalplants is MISSING
```
In this case the archive file `ard815862d1c3d858683fe30cd114e54e4` should be deleted. The local files are archived in `~/Library/Application\ Support/Unison/`.

Sometimes the archive should be deleted on your vagrant machine, these archive files can be found in `/data/web/.unison` 

## Box size is much larger than necessary (2-3x file size reduction)

Make sure `vmware-vdiskmanager` is available:

```bash
brew install caskroom/cask/vmware-fusion
```
Do this in your box:

```bash
sudo dd if=/dev/zero of=wipefile bs=1024x1024; rm wipefile
```

Do this outside your box:
```
vagrant halt
cd ~/VirtualBox\ VMs/yourboxnamehere/Snapshots
vmware-vdiskmanager -k \{somestringhere\}.vmdk #pro tip: press tab after you entered vmware-vdiskmanager and the file will be autofilled
```
