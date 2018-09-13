# == Class: groovy
#
# Supported operating systems are:
#   - Ubuntu Linux
#   - Fedora Linux
#   - Debian Linux
#
# === Authors
#
# R. Tyler Croy <tyler@monkeypox.org>
# Spencer Herzberg <spencer.herzberg@gmail.com>
#
class groovy (
  $version       = $groovy::params::version,
  $base_url      = $groovy::params::base_url,
  $target        = $groovy::params::target,
  $manage_target = $groovy::params::manage_target,
  $manage_unzip  = $groovy::params::manage_unzip,
  $timeout       = $groovy::params::timeout,
) inherits groovy::params {

  include stdlib

  validate_string($version)
  validate_string($base_url)

  $groovy_dir      = "${target}/groovy-${version}"

  case $version {
    '/^1/','/^2.[0-3]/','/^2.4.[0-3]{1}$/': {
      $filename = "groovy-binary-${version}.zip"
    }
    default: {
      $filename = "apache-groovy-binary-${version}.zip"
    }
  }

  if $manage_target and $manage_unzip {
    $staging_require = [
      Staging::File[$filename],
      File[$target],
      Package['unzip'],
    ]
  } elsif $manage_target {
    $staging_require = [
      Staging::File[$filename],
      File[$target],
    ]
  } elsif $manage_unzip {
    $staging_require = [
      Staging::File[$filename],
      Package['unzip'],
    ]
  } else {
    $staging_require = Staging::File[$filename]
  }

  file { '/etc/profile.d/groovy.sh':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/groovy.sh.erb"),
  }

  file { '/etc/profile.d/groovy.csh':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/groovy.csh.erb"),
  }

  staging::file { $filename:
    source  => "${base_url}/${filename}",
    timeout => $timeout,
  }

  if $manage_unzip {
    ensure_resource('package','unzip', {'ensure' => 'present' })
  }

  if $manage_target {
    file { $target:
      ensure => directory,
    }
  }

  staging::extract { $filename:
    target  => $target,
    creates => $groovy_dir,
    require => $staging_require,
  }
}
