# Use a Linux image
#vagrant_box 'precise64' do
#  url 'http://files.vagrantup.com/precise64.box' 
#end


vagrant_box 'opscode-ubuntu-12.04' do
  url 'https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box' 
end
