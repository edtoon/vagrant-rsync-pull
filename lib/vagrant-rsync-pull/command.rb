require "optparse"
require "log4r"
require "vagrant"
require "vagrant/action/builtin/mixin_synced_folders"

require_relative "helper"

module VagrantPlugins
  module SyncedFolderRSyncPull
    class Command < Vagrant.plugin("2", :command)
      include Vagrant::Action::Builtin::MixinSyncedFolders

      def self.synopsis
        "rsyncs guest files to host"
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant rsync-pull [vm-name]"
          o.separator ""
        end

        argv = parse_options(opts)
        return if !argv

        error = false
        with_target_vms do |machine|
          if !machine.communicate.ready?
            machine.ui.error(I18n.t("vagrant.rsync_communicator_not_ready"))
            error = true
            next
          end

          folders = synced_folders(machine)[:rsync_pull]
          next if !folders || folders.empty?

          folders.each do |id, folder_opts|
            RsyncPullHelper.rsync_single(machine, folder_opts)
          end
        end

        return error ? 1 : 0
      end
    end
  end
end
