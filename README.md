# Trac

Installs and configures Trac instances.

# Module Description

Trac is a wiki and issue tracking system for software development projects. This module
will aid in quickly provisioning a new Trac environment.

Currently, the module supports creation of either Subversion or Git repositories, and
either Sqlite or PostgreSQL for the backend database. An apache virtualhost and logo image
for you project will also be automatically created for you.

# Requirements

 * puppetlabs/apache ( version 1.2.0 or greater )
 * puppetlabs/concat
 * puppetlabs/stdlib
 * puppetlabs/vcsrepo
 * puppetlabs/firewall (if trac::tracenv::open_firewall is true)
 * puppetlabs/postgresql (if using postgresql)
 
# Usage

Most of the heavy lifting in the module is done by the trac::tracenv define, including
creating the config files for the trac environment and calling other defines which create
the database, apache virtualhost, code repository and logo image for the Trac install. 

In order to call a tracenv though, you'll first need to declare the trac class.

<pre>
  class{'trac':}
</pre>

After the trac class has been declared, you can call a trac::tracenv to install a new
Trac environment.

<pre>
  trac::tracenv{'test':
    redir_http => true,
    vhost_name => '*',
  }
</pre>

Note that passing a value to the vhost_name parameter is required (this is to avoid
a conflict if creating multiple trac environments.)

If you'd like to create an environment with a postgres database and a git repository,
it can be done as follows:

<pre>
  trac::tracenv{'test':
    redir_http => true,
    vhost_name => '*',
    repo_type  => 'git',
    db_type    => 'postgres',
  }
</pre>

If not specified, repo type will default to 'svn' and db type will default to 'sqlite'.

Using name based virtual hosts you can provision multiple Trac environments on the same
system. For example, if both project1.example.com and project2.example.com resolve to
the same system, you could set up two environments as follows:

<pre>
  trac::tracenv{'project1':
    vhost_name => 'project1.example.com',
  }
  
  trac::tracenv{'project2':
    vhost_name => 'project2.example.com',
  }
</pre>

### Trac Authentication

Authentication to the Trac web application is handled through htdisgest. The file
the application uses for auth will be located in '/trac/tracEnv/.htpasswd. 

Trac users can be created with the tracuser class. Note that the realm must match
the tracenv name: 

<pre>
   class {'trac':}

	trac::tracenv{'project1':
	}

	trac::tracuser { "user1":
		password   => "unencryptedPassword",
		realm      => "project1",
	}
</pre>

If you want to manage users outside of puppet, add them to the htpaasswd file manually, using a command
like this: 
<pre>
htdigest /pathToTrac/.htpasswd projectName user
</pre>

So if your project name is test, and your user name is jon, the command would probably be
the following (assuming you used the default path for your trac instance).

<pre>
htdigest /trac/test/.htpasswd test jon
</pre>

### Git

The Trac module will set up Git repositories to authenticate via SSH.

If using Trac with a Git repository, the default checkout will be:

<pre>
git clone ssh://pathToTrac/repos/projectName
</pre>

For example, if you simply declare a trac instance as follows:

<pre>
  trac::tracenv{'test':
    vhost_name => '*'
    repo_type  => 'git'
  }
</pre>

The command for the svn checkout will be:

<pre>
git clone ssh://pathToTrac/test/repos/test
</pre>

To give system users commit access to the repository, they will need to be added to the
group of the same name as the repository.

### Subversion

The Trac module will set up Subversion repositories to authenticate via SSH.

If using Trac with a Subversion repository, the default checkout will be:

<pre>
svn co svn+ssh://pathToTrac/repos/projectName
</pre>

For example, if you simply declare a trac instance as follows:

<pre>
  trac::tracenv{'test':
    vhost_name => '*',
    repo_type  => 'svn',
  }
</pre>

The command for the svn checkout will be:

<pre>
svn co svn+ssh://trac/test/repos/test
</pre>

To give system users commit access to the repository, they will need to be added to the
group of the same name as the repository.

# Limitations

Currently this module is only tested with Ubuntu 12.04, Ubuntu 14.04 and CentOS 6, although 
it's likely that it will function with other variants of Redhat and Debian OS families. 

Although telling the module not to create a virtualhost, database, or code repository
is possible via parameters in the trac::tracenv define, doing so is untested and is
likely to fail.

Installing of Trac is generally done via easy_install in this module. Installing Trac via 
package management (apt/yum) is also possible with parameters in trac::tracenv, but is 
untested. 
