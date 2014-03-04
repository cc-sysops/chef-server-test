include_recipe 'layouts::double'

num_webservers = 2

1.upto(num_webservers) do |i|
  machine "metalnode#{i}" do
    tag 'install'
    tag 'nginx'

    recipe 'apt'
    recipe 'nginx'


#    action [ :create, :converge ]
  end
end
