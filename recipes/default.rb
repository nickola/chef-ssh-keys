if node[:ssh_keys]
  node[:ssh_keys].each do |node_user, bag_users|
    next unless node_user
    next unless bag_users

    # Getting node user data
    user = node['etc']['passwd'][node_user]

    if user and user['dir'] and user['dir'] != "/dev/null"
      # Preparing SSH keys
      ssh_keys = []

      authorized_keys_file = "#{user['dir']}/.ssh/authorized_keys"

      if File.exist?(authorized_keys_file)
        File.open(authorized_keys_file).each do |l|
          if l.start_with?("ssh")
            ssh_keys += Array(l.delete "\n")
          end
        end
      end

      Array(bag_users).each do |bag_user|
        data = data_bag_item('users', bag_user)
        if data and data['ssh_keys']
          ssh_keys += Array(data['ssh_keys'])
        end
      end

      ssh_keys.uniq!

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
