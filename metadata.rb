name              "ssh-keys"
maintainer        "Nickolay Kovalev"
maintainer_email  "nickola@nickola.ru"
license           "Apache 2.0"
description       "Creates \"authorized_keys\" in user \"~/.ssh\" directory from a data bag"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0"

%w{ubuntu debian redhat centos fedora freebsd}.each do |os|
  supports os
end
