require "vagrant/util/platform"
require "vagrant/util/subprocess"

module VagrantPlugins
  module SyncedFolderRSyncPull
    class RsyncPullHelper
      def self.rsync_single(machine, opts)
        ssh_info = machine.ssh_info
        guestpath = opts[:guestpath]
        hostpath = opts[:hostpath]
        hostpath = File.expand_path(hostpath, machine.env.root_path)
        hostpath = Vagrant::Util::Platform.fs_real_path(hostpath).to_s

        if Vagrant::Util::Platform.windows?
          hostpath = Vagrant::Util::Platform.cygwin_path(hostpath)
        end

        if !guestpath.end_with?("/")
          guestpath += "/"
        end

        if !hostpath.end_with?("/")
          hostpath += "/"
        end

        opts[:owner] ||= ssh_info[:username]
        opts[:group] ||= ssh_info[:username]

        username = ssh_info[:username]
        host = ssh_info[:host]
        proxy_command = ""
        if ssh_info[:proxy_command]
          proxy_command = "-o ProxyCommand='#{ssh_info[:proxy_command]}' "
        end

        rsh = [
          "ssh -p #{ssh_info[:port]} " +
          proxy_command +
          "-o StrictHostKeyChecking=no " +
          "-o UserKnownHostsFile=/dev/null",
          ssh_info[:private_key_path].map { |p| "-i '#{p}'" },
        ].flatten.join(" ")

        excludes = ['.vagrant/', 'Vagrantfile']
        excludes += Array(opts[:exclude]).map(&:to_s) if opts[:exclude]
        excludes.uniq!

        args = nil
        args = Array(opts[:args]).dup if opts[:args]
        args ||= ["--verbose", "--archive", "--delete", "-z", "--copy-links"]

        if Vagrant::Util::Platform.windows? && !args.any? { |arg| arg.start_with?("--chmod=") }
          args << "--chmod=ugo=rwX"

          args << "--no-perms" if args.include?("--archive") || args.include?("-a")
        end

        args << "--no-owner" unless args.include?("--owner") || args.include?("-o")
        args << "--no-group" unless args.include?("--group") || args.include?("-g")

        if machine.guest.capability?(:rsync_command)
          args << "--rsync-path"<< machine.guest.capability(:rsync_command)
        end

        command = [
          "rsync",
          args,
          "-e", rsh,
          excludes.map { |e| ["--exclude", e] },
          "#{username}@#{host}:#{guestpath}",
          hostpath,
        ].flatten

        command_opts = {}
        command_opts[:workdir] = machine.env.root_path.to_s

        machine.ui.info(I18n.t(
          "vagrant.rsync_folder", guestpath: guestpath, hostpath: hostpath))
        if excludes.length > 1
          machine.ui.info(I18n.t(
            "vagrant.rsync_folder_excludes", excludes: excludes.inspect))
        end

        if machine.guest.capability?(:rsync_pre)
          machine.guest.capability(:rsync_pre, opts)
        end

        command = command + [command_opts]

        r = Vagrant::Util::Subprocess.execute(*command)
        if r.exit_code != 0
          raise Vagrant::Errors::SyncedFolderRSyncPullError,
            command: command.inspect,
            guestpath: guestpath,
            hostpath: hostpath,
            stderr: r.stderr
        end

        if machine.guest.capability?(:rsync_post)
          machine.guest.capability(:rsync_post, opts)
        end
      end
    end
  end
end
