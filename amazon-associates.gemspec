# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon-associates}
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Woosley", "Dan Pickett", "Herryanto Siatono"]
  s.autorequire = %q{amazon-associates}
  s.date = %q{2008-12-29}
  s.email = ["ben.woosley@gmail.com", "dpickett@enlightsolutions.com", "herryanto@pluitsolutions.com"]
  s.extra_rdoc_files = ["README", "CHANGELOG"]
  s.files = ["lib/amazon-associates.rb", "lib/amazon-associates", "lib/amazon-associates/responses", "lib/amazon-associates/responses/response.rb", "lib/amazon-associates/responses/browse_node_lookup_response.rb", "lib/amazon-associates/responses/item_lookup_response.rb", "lib/amazon-associates/responses/item_search_response.rb", "lib/amazon-associates/responses/cart_responses.rb", "lib/amazon-associates/extensions", "lib/amazon-associates/extensions/core.rb", "lib/amazon-associates/extensions/hpricot.rb", "lib/amazon-associates/request.rb", "lib/amazon-associates/caching", "lib/amazon-associates/caching/filesystem_cache.rb", "lib/amazon-associates/errors.rb", "lib/amazon-associates/types", "lib/amazon-associates/types/ordinal.rb", "lib/amazon-associates/types/browse_node.rb", "lib/amazon-associates/types/operation_request.rb", "lib/amazon-associates/types/offer.rb", "lib/amazon-associates/types/item.rb", "lib/amazon-associates/types/price.rb", "lib/amazon-associates/types/image.rb", "lib/amazon-associates/types/customer_review.rb", "lib/amazon-associates/types/cart.rb", "lib/amazon-associates/types/editorial_review.rb", "lib/amazon-associates/types/image_set.rb", "lib/amazon-associates/types/listmania_list.rb", "lib/amazon-associates/types/measurement.rb", "lib/amazon-associates/types/requests.rb", "lib/amazon-associates/types/error.rb", "lib/amazon-associates/types/item_search_request.rb", "lib/amazon-associates/requests", "lib/amazon-associates/requests/browse_node.rb", "lib/amazon-associates/requests/item.rb", "lib/amazon-associates/requests/cart.rb", "test/amazon/cache_test.rb", "test/amazon/item_test.rb", "test/amazon/browse_node_test.rb", "test/amazon/caching/filesystem_cache_test.rb", "test/amazon/cart_test.rb", "test/amazon/measurement_test.rb", "README", "CHANGELOG"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Empact/amazon-associates/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1.xported}
  s.summary = %q{Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0.}
  s.test_files = ["test/amazon/cache_test.rb", "test/amazon/item_test.rb", "test/amazon/browse_node_test.rb", "test/amazon/caching/filesystem_cache_test.rb", "test/amazon/cart_test.rb", "test/amazon/measurement_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<roxml>, [">= 2.3.1"])
    else
      s.add_dependency(%q<roxml>, [">= 2.3.1"])
    end
  else
    s.add_dependency(%q<roxml>, [">= 2.3.1"])
  end
end
