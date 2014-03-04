test_config       = data_bag_item 'tests', 'default'
host_cache_path   = test_config['cache_path']

num_webservers = 2

1.upto(num_webservers) do |i|
  machine "metalnode#{i}" do
    tag 'nginx'
#    attribute %w(nginx default_site_enabled), true 
    attribute %w(nginx client_max_body_size), '100M'
    attribute %w(nginx worker_connections), '512'
    recipe 'apt'

    local_provisioner_options = {
      'vagrant_config' => <<ENDCONFIG
      config.vm.synced_folder "#{host_cache_path}", '/tmp/cache'
ENDCONFIG
    }

    provisioner_options ChefMetal.enclosing_provisioner_options.merge(local_provisioner_options)
#    action [ :create, :converge ]
#    action :delete
#    provisioner_options ChefMetal.enclosing_provisioner_options.merge(local_provisioner_options)
  end
end
