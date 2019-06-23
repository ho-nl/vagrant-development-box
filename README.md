# Reach Digital Development Vagrant Box

Super easy to install, fast and a pleasure to work with.

Based on images from https://github.com/byteinternet/hypernode-vagrant

# Requirements

a. Mutagen installed

```
brew install havoc-io/mutagen/mutagen
mutagen daemon register
mutagen daemon start
```

b. [Vagrant](https://www.vagrantup.com/downloads.html) installed

c. Vagrant plugins installed:

```
vagrant plugin install vagrant-hostmanager 
vagrant plugin install vagrant-auto_network
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

c. Create a config.rb file in you project folder with your project settings

M2:

```ruby
name 'yourboxname'
hostname name + '.box'
php_version 7.2
mysql_version 5.7
#varnish true
#varnish_vcl 'magento2/varnish.vcl'
```

M1:
```ruby
name 'yourboxname'
hostname name + '.box'
php_version 7.2
mysql_version 5.6
guest_dir 'public'
magento2 false
```

d. Run `vagrant up` in the `vagrant` directory, if everything went alright you're greeted with this message:
<img width="613" alt="schermafbeelding 2017-09-30 om 14 57 29" src="https://user-images.githubusercontent.com/1244416/31045958-bb833756-a5ef-11e7-918b-6529dbc8480e.png">

e. Optional: run `mutagen monitor` to monitor changes  

Please note: it will show some red errors but you can ignore that, those are mostly warnings that can be ignored. If you see a sea of red something probably goes wrong.

## Configuration Options

* `name` - name of your node
* `hostname` - default project hostname
* `domains` - list of additional domain names for your project 
* `host_dir` Sets the host sync dir (default: `../src`)
* `guest_dir` Sets the guest sync dir (default: `magento2`)
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
* `uid` - User ID of your host to be mapped to linux VM (default: `Process.euid`)
* `gid` - Group ID of your host to be mapped to linux VM (default: `Process.egid`)
* `network` - Network mast for automatic network assignment to VM (default: `33.33.33.0/24`)
* `xdebug` Install xdebug? (default: `false`)
* `forward_port` Forward port 80 to 8080 on host (default: `false`) 
* `redis_memory` Set the redis memory. E.g. `'128mb'` (default: `false`)

## Connecting to your Vagrant box

There are two ways to connect to your Vagrant box:
1. As Root to do system administration: `vagrant ssh`
	- DO NOT edit project files with the root user, this will give permission errors in the application
2. As User to do all development work on: `ssh app@yourboxname.box`

## Syncing the `../src` folder with the vagrant box.

The filesystem of your vagrant box must contain all files to be able to operate quickly.
The filesystem of your host system must contain all files for PHPStorm be able to operate.

To achieve this, we use [Mutagen sync](https://mutagen.io/). When starting a vagrant box the mutagen sync is automatically started.

## Connecting to MySQL externally (SequelPro)

You can directly connect to the vagrant box with the following credentials:
```
host: yourboxname.box
username: app
password: as mentioned in vagrant provision
```

## Enabling browser-sync

You can setup port-forwarding to enable browser-sync with gulp. This enables you to test your development environment on your mobile phone or other PC.

By default the port-forwarding is setup for port 3000, this is the default port gulp uses to setup browsersync. If this is different because of reasons you can edit this in the `Vagrantfile`.

Change your `config.rb` and add `forward_port true` to your config. Provision and restart your box. During the box init you should see messages that port 3000 is being setup for your box.

Next start gulp in your box and you should be able to connect to your box using your hostname or ip-adres (for example: nick.local:3000).

Keep in mind that you can't have two boxes running at the same time with `forward_port true` because these would clash with each other. Also keep in mind that you should use the IP address when you want to test on Android.

## Debugging e-mail sending using MailHog

By default, `mailhog` is installed in your vagrant box. This runs as a daemon and will intercept all e-mail being sent from your Magento setup (if configured to deliver e-mail locally on port `1025`) and present it through a convenient web-interface on port `8025`, i.e. `http://your.box:8025`).

Due to an issue with the `mailhog` service not starting on its own some additional steps are currently required to run this as a service: https://github.com/ho-nl/vagrant-development-box/issues/77

Alternatively you can just run `mailhog` from the command line and let it run in the foreground when needed.

# Magento 2 configuration

## env.php

The system automatically creates a database named `test`, this can be used to upload your information. You can use the same DB connection info as used in SequelPro

## Cache handling

The box doesn't sync the `var/cache` folder, Magento's cache needs to be flushed from the inside of the box: `php bin/magento c:f`.

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

## Need to run modman deploy in vagrant box

The symlinks created on your host machine won't work in the vagrant box. This will result in errors with finding files or (when you use PHP7) a error in layout.php (because the Inchoo_PHP7 module was not applied correctly). Run `modman deploy-all --force` in your vagrant box to fix these issues.

# Common issues

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

## Error: The machine with the name 'hypernode' was not found configured for this Vagrant environment.
This usually happens when you upgrade the vagrant box version from 1.x to 2.x or higher. The error occors becuase vagrant creates a new box with the correct project name but doesn't delete the old vagrant box. When you do the `vagrant up` command it tries to start all the boxes that are availble in the `vagrant/.vagrant` folder, which includes the hypernode box and which doesn't have a configuration after the update.

Remove the hypernode box from `vagrant/.vagrant` and the error will disapear.

## 'permission denied' on npm install or npm install -g
Change the prefix of npm to solve this:
```bash
npm config set prefix '/data/web/.npm-global'
npm install -g gulp grunt grunt-cli polymer-cli
```
