%w(vagrant-hostmanager vagrant-auto_network).each do |plugin|
 unless Vagrant.has_plugin?(plugin)
   raise 'In order to use this box, you must install plugin: ' + plugin
 end
end

require_relative 'vagrant/inline/config'

# Define Vagrantfile configuration options
VagrantApp::Config
  .option(:varnish, false) # If varnish needs to be enabled
  .option(:varnish_vcl, false) # Path to your varnish vcl file
  .option(:xdebug, false) # Is xdebug needs to be installed
  .option(:developer, true) # Is developer mode should be enabled
  .option(:magento2, true) # Is it Magento 2.0
  .option(:install, false) # Install Magento? (for now only 2.0)
  .option(:shell, false) # Shell script?
  .option(:php_version, '7.2') # PHP version
  .option(:mysql_version, '5.6') # MySQL version
  .option(:ioncube, false) # Flag for installing IonCube loader PHP module
  .option(:name, '') # Name
  .option(:linked_clone, true) # Use a linked base box clone
  .option(:hostname, '') # Hostname
  .option(:domains, []) # Domain list
  .option(:cpu, 4) # Number of dedicated CPU
  .option(:memory, 2048) # Number of dedicated memory in MB
  .option(:memory_production, false) # Run in production memory mode
  .option(:user, 'app') # User name for share
  .option(:group, 'app') # Group name for share
  .option(:uid, Process.euid) # User ID for mapping
  .option(:gid, Process.egid) # Group ID for mapping
  .option(:network, '33.33.33.0/24') # Directory to be used as mount on host machine
  .option(:forward_port, false) # Forward port 80 to 8080 on host?
  .option(:redis_memory, false) # Set default value to false meaning: don't change the redis memory
  .option(:host_dir, '../src')
  .option(:guest_dir, 'magento2')

Vagrant.configure("2") do |config|

  # Prepare configuration and setup shell scripts for it
  current_file = Pathname.new(__FILE__)
  box_config = VagrantApp::Config.new
  # Base hypernode provisioner
  box_config
    .shell_add('hypernode.sh')
    .shell_add('developer.sh', :developer)
    .shell_add('mysql_version.sh')
    .shell_add('php_version.sh')
    .shell_add('php_composer.sh')
    .shell_add('php_xdebug.sh')
    .shell_add('php_show_errors.sh')
    .shell_add('bash-alias.sh')
    .shell_add('memory_management.sh')
    .shell_add('nginx_rate_limiting.sh')
    .shell_add('nginx_aoejscsststamp.sh')
    .shell_add('disable-varnish.sh', :varnish, true) # Varnish disabler, depends on :varnish inverted flag
    .shell_add('magento2.sh', :magento2) # M2 Nginx Config Flag, depends on :magento2 flag
    .shell_add('magento2-install.sh', [:magento2, :install]) # M2 Installer, depends on :magento2 and :install
    .shell_add('magento2-developer.sh', [:magento2, :install, :developer]) # M2 Developer options, depends on :magento2, :install, :developer
    .shell_add('shell.sh', :shell) # Fish shell installer, depends on :shell flag
    .shell_add('ioncube.sh', :ioncube) # IonCube installer shell script, depends on :ioncube flag
    .shell_add('ssh_key.sh')
    .shell_add('redis_memory.sh')
    .shell_add('nodejs.sh')
    .shell_add('sudoers.sh')
    .shell_add('hello.sh') # Final message with connection instructions

  # Loads config.rb from the same directory where Vagrantfile is in
  box_config.load(File.join(current_file.dirname, 'config.rb.dst'))
  box_config.load(File.join(current_file.dirname, 'config.rb'))
  box_config.load(File.join(current_file.dirname, '../config.rb'))
  box_config.load(File.join(current_file.dirname, '../src/config.rb'))

  AutoNetwork.default_pool = box_config.get(:network)

  if box_config.get(:name)
    config.vm.provider :virtualbox do |v|
      v.name = box_config.get(:name)
    end
  end

  config.vm.box = 'hypernode_xenial'
  config.vm.box_url = 'http://vagrant.hypernode.com/customer/xenial/catalog.json'

  config.vm.provision "file", source: File.join(current_file.dirname, 'vagrant/resources'), destination: "vagrant-resources"

  if box_config.flag?(:linked_clone)
    config.vm.provider :virtualbox do |v|
      v.linked_clone = true
    end
  end

  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v, o|
    v.memory = box_config.get(:memory)
    v.cpus =  box_config.get(:cpu)
    v.customize [
      "modifyvm", :id,
      "--paravirtprovider", "kvm", # for linux guest
      "--audio", "none"
    ]
  end

  config.vm.provider :lxc do |lxc|
    lxc.customize 'cgroup.memory.limit_in_bytes', box_config.get(:memory).to_s + 'M'
  end

  # Disable default /vagrant mount as we use custom user for box
  config.vm.synced_folder '.', '/vagrant/', disabled: true

  # Automatically upload the users id_rsa.pub to the box
  public_key_path = File.join(Dir.home, ".ssh", "id_rsa.pub")

  if File.exist?(public_key_path)
    public_key = IO.read(public_key_path)
  end

  # Upload custom shell profile
  custom_profile_path = File.join(Dir.home, ".vagrant_profile")

  if File.exist?(custom_profile_path)
    custom_profile = IO.read(custom_profile_path)
  end

  box_config.shell_list.each do |file|
    config.vm.provision 'shell', path: 'vagrant/provisioning/' + file, env: {
        VAGRANT_UID: box_config.get(:uid).to_s,
        VAGRANT_GID: box_config.get(:gid).to_s,
        VAGRANT_USER: box_config.get(:user),
        VAGRANT_GROUP: box_config.get(:group),
        VAGRANT_HOSTNAME: box_config.get(:hostname),
        VAGRANT_PROJECT_DIR: box_config.get(:guest_dir),
        VAGRANT_HOST_PUBLIC_KEY: public_key,
        VAGRANT_HOST_CUSTOM_PROFILE: custom_profile,
        VAGRANT_XDEBUG: box_config.get(:xdebug),
        VAGRANT_MYSQL_VERSION: box_config.get(:mysql_version),
        VAGRANT_PHP_VERSION: box_config.get(:php_version),
        VAGRANT_REDIS_MEMORY: box_config.get(:redis_memory),
        VAGRANT_CGROUP_ENABLED: box_config.get(:memory_production)
    }
  end

  if box_config.flag?(:varnish)
    config.vm.provision 'shell', path: 'vagrant/boot/varnish.sh', run: 'always', env: {
        VARNISH_VCL: box_config.get(:varnish_vcl),
        VAGRANT_USER: box_config.get(:user),
        VAGRANT_PROJECT_DIR: box_config.get(:guest_dir)
    }
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  if box_config.flag?(:forward_port)
    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.network :forwarded_port, guest: 3000, host: 3000
  end

  config.vm.define box_config.get(:name) do |node|
    node.vm.hostname = box_config.get(:hostname)
    node.vm.network :private_network, auto_network: true
    node.hostmanager.aliases = box_config.get(:domains)
  end

  config.trigger.after :up do |trigger|
    trigger.info = "💥 Starting up sync: mutagen create 💥"
    trigger.ruby do |env,machine|
      system("mutagen terminate #{box_config.get(:name)} > /dev/null 2>&1")
      system("until mutagen create #{box_config.get(:host_dir)} app@#{box_config.get(:hostname)}:~/#{box_config.get(:guest_dir)} --no-global-configuration --configuration-file ./.mutagen.toml --label #{box_config.get(:name)}; do echo \"Waiting for the box to be available in the network... (can take up to a minute)\"; sleep 2; done")
    end
  end

  config.trigger.before :halt, :destroy do |trigger|
    trigger.info = "Stopping sync: mutagen terminate"
    trigger.ruby do |env,machine|
      system("mutagen terminate #{box_config.get(:name)} > /dev/null 2>&1")
    end
  end

end
