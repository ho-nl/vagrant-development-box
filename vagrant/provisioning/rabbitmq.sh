

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb

echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -

sudo apt-get --assume-yes update
sudo apt-get --assume-yes install erlang-diameter erlang-eldap erlang

sudo apt-get --assume-yes install rabbitmq-server

sudo service rabbitmq-server start
sudo rabbitmq-plugins enable rabbitmq_management

# guest / guest
