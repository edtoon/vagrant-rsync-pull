require "log4r"

require "vagrant/util/subprocess"
require "vagrant/util/which"

require_relative "helper"

module VagrantPlugins
  module SyncedFolderRSyncPull
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      include Vagrant::Util

      def initialize(*args)
        super

        @logger = Log4r::Logger.new("vagrant_rsync_pull")
      end

      def usable?(machine, raise_error=false)
        rsync_path = Which.which("rsync")
        return true if rsync_path
        return false if !raise_error
        raise Vagrant::Errors::RSyncNotFound
      end

      def prepare(machine, folders, opts)
      end

      def enable(machine, folders, opts)
        if machine.guest.capability?(:rsync_installed)
          installed = machine.guest.capability(:rsync_installed)
          if !installed
            can_install = machine.guest.capability?(:rsync_install)
            raise Vagrant::Errors::RSyncNotInstalledInGuest if !can_install
            machine.ui.info I18n.t("vagrant.rsync_installing")
            machine.guest.capability(:rsync_install)
          end
        end

        ssh_info = machine.ssh_info

        if ssh_info[:private_key_path].empty? && ssh_info[:password]
          machine.ui.warn(I18n.t("vagrant.rsync_ssh_password"))
        end

        folders.each do |id, folder_opts|
          RsyncPullHelper.rsync_single(machine, folder_opts)
        end
      end
    end
  end
end
