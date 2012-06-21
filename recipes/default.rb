if node[:ssh_keys]
  node[:ssh_keys].each do |node_user, bag_users|
    next unless node_user
    next unless bag_users

    # Getting node user data
    user = node['etc']['passwd'][node_user]

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

        # Creating ".ssh" directory
        directory "#{home_dir}/.ssh" do
          owner user['id']
          group user['gid'] || user['id']
          mode "0700"
        end

        # Creating "authorized_keys"
        template "#{home_dir}/.ssh/authorized_keys" do
          owner user['id']
          group user['gid'] || user['id']
          mode "0600"
          variables :ssh_keys => ssh_keys
        end
      end
    end
  end
end
