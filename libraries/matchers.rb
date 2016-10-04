if defined?(ChefSpec)
  def add_djbdns_rr(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:djbdns_rr, :add, resource_name)
  end
end
