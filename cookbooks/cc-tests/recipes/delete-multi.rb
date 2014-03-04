include_recipe 'stacks::vagrant'
include_recipe 'os::ubuntu-12.04'

num_webservers = 2

1.upto(num_webservers) do |i|
  machine "metalnode#{i}" do
    tag 'install'
    recipe 'nginx'
#    action [ :create, :converge ]
    action :delete
  end
end
