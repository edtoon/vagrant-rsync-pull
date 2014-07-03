require "pathname"

require "vagrant-rsync-pull/plugin"
require "vagrant-rsync-pull/errors"

module VagrantPlugins
  module SyncedFolderRSyncPull
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
