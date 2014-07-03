require "vagrant"

module Vagrant
  module Errors
    class SyncedFolderRSyncPullError < VagrantError
      error_key(:rsync_pull_error, "vagrant_rsync_pull.errors")
    end
  end
end
