# Vagrant RSync-Pull Plugin

This is a [Vagrant](http://www.vagrantup.com) 1.5+ plugin that works the same as the built-in RSync plugin,
except files are sync'd from the guest to the host.

**NOTE:** This plugin requires Vagrant 1.5+

## Usage

Install using standard Vagrant 1.1+ plugin installation methods. 
```
$ vagrant plugin install vagrant-rsync-pull
```
After installing, edit your Vagrantfile and add a configuration directive similar to the below:
```
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.vm.synced_folder "/home/myuser/myproject", "/opt/myproject", type: "rsync_pull"
end
```
Start up your vagrant box as normal (eg: `vagrant up`)

## Start syncing folders

Folders will be pulled from the guest on `vagrant up`.

Run `vagrant rsync-pull` to manually sync files from the guest to your local host.
