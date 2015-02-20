if node['ssh_keys']
  node['ssh_keys'].each do |node_user, bag_users|
    next unless node_user
    next unless bag_users

    # Getting node user data
    user = node['etc']['passwd'][node_user]

    # Defaults for new user
    user = {'uid' => node_user, 'gid' => node_user, 'dir' => "/home/#{node_user}"} unless user

    if user and user['dir'] and user['dir'] != "/dev/null"
      # Preparing SSH keys
      ssh_keys = []
      bag_users_list = []

      if bag_users.kind_of?(String)
        bag_users_list = Array(bag_users)
      elsif bag_users.kind_of?(Array)
        bag_users_list = bag_users
      else
        bag_users_list = bag_users['users']
      end

      Array(bag_users_list).each do |bag_user|
        data = node['ssh_keys_use_encrypted_data_bag'] ?
          Chef::EncryptedDataBagItem.load('users', bag_user) :
          data_bag_item('users', bag_user)

        if data and data['ssh_keys']
          ssh_keys += Array(data['ssh_keys'])
        end
      end

      if not bag_users.kind_of?(String) and not bag_users.kind_of?(Array) and bag_users['groups'] != nil
        Array(bag_users['groups']).each do |group_name|
          if not Chef::Config[:solo]
            search(:users, 'groups:' + group_name) do |search_user|
              ssh_keys += Array(search_user['ssh_keys'])
            end
          else
            Chef::Log.warn("This recipe uses search for users detection by groups. Chef Solo does not support search.")
          end
        end
      end

      # Saving SSH keys
      if ssh_keys.length > 0
        home_dir = user['dir']

        if node['ssh_keys_skip_missing_home'] and not File.exists?(home_dir)
          next
        end

        authorized_keys_file = "#{home_dir}/.ssh/authorized_keys"

        if node['ssh_keys_keep_existing'] && File.exist?(authorized_keys_file)
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
          if node['ssh_keys_create_missing_home']
            directory "#{home_dir}/.ssh" do
              owner user['uid']
              group user['gid'] || user['uid']
              mode "0700"
              recursive true
            end
          else
            directory "#{home_dir}/.ssh" do
              owner user['uid']
              group user['gid'] || user['uid']
              mode "0700"
            end
          end
        end

        # Creating "authorized_keys"
        template authorized_keys_file do
          source "authorized_keys.erb"
          owner user['uid']
          group user['gid'] || user['uid']
          mode "0600"
          variables :ssh_keys => ssh_keys
        end
      end
    end
  end
end
