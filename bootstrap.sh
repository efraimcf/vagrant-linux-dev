# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.


# ********************************
# **** Choose what to install ****
# ********************************
UPDATE_PACKAGES=true
# ====== Ruby
RUBY_WITH_RVM=true
RUBY_WITH_RBENV=false # only install if RUBY_WITH_RVM is false
RUBY=false # only install if RUBY_WITH_RVM and RUBY_WITH_RBENV is false
RAILS=true
# ====== Java
JAVA_ORACLE=true
TOMCAT=true
# ====== NodeJS
NODEJS=true
# ====== Database
SQLITE=true
POSTGRESQL=true
MYSQL=true
PHP=true

# Variables
RUBY_VERSION=2.2.2
RAILS_VERSION=4.2.1
DB_USER=root
DB_PASSWORD=root
RBENV_DIR=~/.rbenv




function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo "updating package information"
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
add-apt-repository -y ppa:webupd8team/java >/dev/null 2>&1
add-apt-repository -y ppa:chris-lea/node.js >/dev/null 2>&1
add-apt-repository -y ppa:ondrej/php5 >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1
if $UPDATE_PACKAGES
then
	apt-get -y upgrade >/dev/null 2>&1
	apt-get -y dist-upgrade >/dev/null 2>&1
fi

install "Build Essencial" build-essential
install Git git-core
install CURL curl
install DevLibs zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev libffi-dev python-software-properties
install "Nokogiri dependencies" libxml2 libxml2-dev libxslt1-dev
install Memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server
install ImageMagick imagemagick


if $NODEJS
then
	echo "installing NodeJS"
	install NodeJS nodejs
fi

if $JAVA_ORACLE
then
	echo "installing JAVA 8"
	sudo apt-get -y remove --purge openjdk-*
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	install Java8 oracle-java8-installer
	install SetDefaultJava8 oracle-java8-set-default
	install Maven maven
fi
if $TOMCAT
then
	echo "installing Tomcat 8 Server"
	wget http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-8/v8.0.23/bin/apache-tomcat-8.0.23.tar.gz
	tar xvzf apache-tomcat-8.0.23.tar.gz
	rm apache-tomcat-8.0.23.tar.gz
	mv apache-tomcat-8.0.23 /opt/tomcat
	if ! [ -L /opt/tomcat/webapps ];
	then
 		rm -rf /opt/tomcat/webapps
  		ln -fs /vagrant/tomcat-webapps /opt/tomcat/webapps
	fi
fi

if $SQLITE
then
	echo "installing SQLite"
	install SQLite sqlite3 libsqlite3-dev
fi

if $POSTGRESQL
then
	echo "installing PostgreSQL"
	install PostgreSQL postgresql postgresql-contrib libpq-dev
	sudo -u postgres createuser --superuser vagrant
	sudo -u postgres createdb -O vagrant activerecord_unittest
	sudo -u postgres createdb -O vagrant activerecord_unittest2
fi

if $MYSQL
then
echo "installing MySQL"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_USER"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_PASSWORD"
install MySQL mysql-server libmysqlclient-dev
mysql -uroot -proot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL
fi

if $RUBY_WITH_RVM
then
	echo "installing RVM with RUBY $RUBY_VERSION"
	if ! type rvm >/dev/null 2>&1; then
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L https://get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh
  fi
	rvm requirements
	rvm install $RUBY_VERSION
	rvm use $RUBY_VERSION --default

elif $RUBY_WITH_RBENV
then
	echo "installing Rbenv with Ruby $RUBY_VERSION"
	cd
	if [ -d $RBENV_DIR ]
	then
		echo "Folder $RBENV_DIR already exists"
	else
		git clone https://github.com/sstephenson/rbenv.git .rbenv
		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
		echo 'eval "$(rbenv init -)"' >> ~/.bashrc
		export PATH="$HOME/.rbenv/bin:$PATH"
		eval "$(rbenv init -)"
	fi

	RUBY_BUILD_DIR=~/.rbenv/plugins/ruby-build
	if [ -d $RUBY_BUILD_DIR ]
	then
		echo "Folder $RUBY_BUILD_DIR already exists"
	else
		git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
		echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
		export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
	fi

	REHASH_DIR=~/.rbenv/plugins/rbenv-gem-rehash
	if [ -d $REHASH_DIR ]
	then
		echo "Folder $REHASH_DIR already exists"
	else
		git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
	fi

	echo "installing Ruby $RUBY_VERSION"
	rbenv install $RUBY_VERSION -s
	rbenv global $RUBY_VERSION

	echo "installing Bundler"
	echo "gem: --no-ri --no-rdoc" > ~/.gemrc
	gem install bundler -N >/dev/null 2>&1

elif $RUBY
then
	"installing Ruby 2.2"
	install Ruby ruby2.2 ruby2.2-dev
	update-alternatives --set ruby /usr/bin/ruby2.2 >/dev/null 2>&1
	update-alternatives --set gem /usr/bin/gem2.2 >/dev/null 2>&1

	echo installing Bundler
	gem install bundler -N >/dev/null 2>&1
fi

if  [ \($RUBY_WITH_RVM -o $RUBY_WITH_RBENV\) -o $RUBY ]
then
	if $MYSQL
	then
		echo installing Gem MySQL2
		gem install mysql2 -N >/dev/null 2>&1
	fi
	if $POSTGRESQL
	then
		echo installing Gem PG
		gem install pg -N >/dev/null 2>&1
	fi
fi

if $RAILS
then
	if ! $NODEJS
	then
		install NodeJS nodejs
	fi
	echo "installing Rails $RAILS_VERSION"
	gem install rails -v $RAILS_VERSION -N >/dev/null 2>&1
fi


if $PHP
then
	install Apache apache2
	if ! [ -L /var/www ];
	then
 		rm -rf /var/www
  		ln -fs /vagrant/apache-www /var/www
	fi
	install PHP php5 php5-mysql php5-curl php5-gd php5-mcrypt php5-xdebug

fi

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'all set, rock on!'
