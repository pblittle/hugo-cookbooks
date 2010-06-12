execute "add-gem-sources" do
  not_if "gem sources -a http://gems.github.com | grep http://gems.github.com"
end