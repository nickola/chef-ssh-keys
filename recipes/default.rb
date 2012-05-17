if node[:ssh_keys]
    node[:ssh_keys].each do |node_user, bag_user|
        next unless node_user
        next unless bag_user
        user = node['etc']['passwd'][node_user]
        data = data_bag_item('users', bag_user)
        if user and user['dir'] and user['dir'] != "/dev/null" and data['ssh_keys']
            home_dir = user['dir']
            # Creating directory
            directory "#{home_dir}/.ssh" do
                owner user['id']
                group user['gid'] || user['id']
                mode "0700"
            end
            # Creating "authorized_keys"
            template "#{home_dir}/.ssh/authorized_keys" do
              source "authorized_keys.erb"
              owner user['id']
              group user['gid'] || user['id']
              mode "0600"
              variables :ssh_keys => data['ssh_keys']
            end
        end
    end
end