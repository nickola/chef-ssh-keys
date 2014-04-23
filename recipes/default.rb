if node[:ssh_keys]
  node[:ssh_keys].each do |node_user, bag_users|
    next unless node_user
    next unless bag_users

    # Getting node user data
    user = node['etc']['passwd'][node_user]

    # Defaults for new user
    user = {'uid' => node_user, 'gid' => node_user, 'dir' => "/home/#{node_user}"} unless user

    if user and user['dir'] and user['dir'] != "/dev/null"
      # Preparing SSH keys
      ssh_keys = []

      Array(bag_users).each do |bag_user|
        data = data_bag_item('users', bag_user)
        if data and data['ssh_keys']
          ssh_keys += Array(data['ssh_keys'])
        end
      end

      # Saving SSH keys
      if ssh_keys.length > 0
        home_dir = user['dir']
        authorized_keys_file = "#{home_dir}/.ssh/authorized_keys"

        if node[:ssh_keys_keep_existing] && File.exist?(authorized_keys_file)
          Chef::Log.info("Keep authorized keys from: #{authorized_keys_file}")

          # Loading existing keys
          File.open(authorized_keys_file).each do |line|
            if line.start_with?("ssh")
              ssh_keys += Array(line.delete "\n")
            end
          end

          ssh_keys.uniq!
        else
          # Creating ".ssh" directory
          directory "#{home_dir}/.ssh" do
            owner user['uid']
            group user['gid'] || user['uid']
            mode "0700"
            recursive true
          end
        end

        # Creating "authorized_keys"
        template authorized_keys_file do
          owner user['uid']
          group user['gid'] || user['uid']
          mode "0600"
          variables :ssh_keys => ssh_keys
        end
      end
    end
  end
end
