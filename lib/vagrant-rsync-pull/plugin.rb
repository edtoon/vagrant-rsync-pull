begin
  require "vagrant"
rescue LoadError
  raise "The vagrant-rsync-pull plugin must be run within Vagrant."
end

if Vagrant::VERSION < "1.5"
  raise "The vagrant-rsync-pull plugin is only compatible with Vagrant 1.5+"
end

module VagrantPlugins
  module SyncedFolderRSyncPull
    class Plugin < Vagrant.plugin("2")
      name "SyncedFolderRSyncPull"
      description "Vagrant plugin to rsync guest files to host"

      command "rsync-pull" do
        setup_logging
        setup_i18n
        require_relative "command"
        Command
      end

      synced_folder("rsync_pull", 5) do
        require_relative "synced_folder"
        SyncedFolder
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", SyncedFolderRSyncPull.source_root)
        I18n.reload!
      end

      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          level = nil
        end

        level = nil if !level.is_a?(Integer)

        if level
          logger = Log4r::Logger.new("vagrant_rsync_pull")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
