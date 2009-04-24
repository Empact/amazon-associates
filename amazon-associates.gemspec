# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon-associates}
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Woosley", "Dan Pickett", "Herryanto Siatono"]
  s.date = %q{2009-04-23}
  s.description = %q{amazon-associates offers object-oriented access to the Amazon Associates API, built on ROXML}
  s.email = %q{ben.woosley@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/amazon-associates.rb",
    "lib/amazon-associates/caching/filesystem_cache.rb",
    "lib/amazon-associates/errors.rb",
    "lib/amazon-associates/extensions/core.rb",
    "lib/amazon-associates/extensions/hpricot.rb",
    "lib/amazon-associates/request.rb",
    "lib/amazon-associates/requests/browse_node.rb",
    "lib/amazon-associates/requests/cart.rb",
    "lib/amazon-associates/requests/item.rb",
    "lib/amazon-associates/responses/browse_node_lookup_response.rb",
    "lib/amazon-associates/responses/cart_responses.rb",
    "lib/amazon-associates/responses/item_lookup_response.rb",
    "lib/amazon-associates/responses/item_search_response.rb",
    "lib/amazon-associates/responses/response.rb",
    "lib/amazon-associates/responses/similarity_lookup_response.rb",
    "lib/amazon-associates/types/api_result.rb",
    "lib/amazon-associates/types/browse_node.rb",
    "lib/amazon-associates/types/cart.rb",
    "lib/amazon-associates/types/customer_review.rb",
    "lib/amazon-associates/types/editorial_review.rb",
    "lib/amazon-associates/types/error.rb",
    "lib/amazon-associates/types/image.rb",
    "lib/amazon-associates/types/image_set.rb",
    "lib/amazon-associates/types/item.rb",
    "lib/amazon-associates/types/listmania_list.rb",
    "lib/amazon-associates/types/measurement.rb",
    "lib/amazon-associates/types/offer.rb",
    "lib/amazon-associates/types/ordinal.rb",
    "lib/amazon-associates/types/price.rb",
    "lib/amazon-associates/types/requests.rb",
    "spec/requests/browse_node_lookup_spec.rb",
    "spec/requests/item_search_spec.rb",
    "spec/spec_helper.rb",
    "spec/types/cart_spec.rb",
    "spec/types/item_spec.rb",
    "spec/types/measurement_spec.rb",
    "test/amazon/browse_node_test.rb",
    "test/amazon/cache_test.rb",
    "test/amazon/caching/filesystem_cache_test.rb",
    "test/amazon/item_test.rb",
    "test/test_helper.rb",
    "test/utilities/filesystem_test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Empact/amazon-associates}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0.}
  s.test_files = [
    "spec/types/measurement_spec.rb",
    "spec/types/item_spec.rb",
    "spec/types/cart_spec.rb",
    "spec/requests/item_search_spec.rb",
    "spec/requests/browse_node_lookup_spec.rb",
    "spec/spec_helper.rb",
    "test/amazon/browse_node_test.rb",
    "test/amazon/cache_test.rb",
    "test/amazon/item_test.rb",
    "test/amazon/caching/filesystem_cache_test.rb",
    "test/test_helper.rb",
    "test/utilities/filesystem_test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<Empact-roxml>, [">= 2.5.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_runtime_dependency(%q<mislav-will_paginate>, [">= 0"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<Empact-roxml>, [">= 2.5.2"])
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_dependency(%q<mislav-will_paginate>, [">= 0"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<Empact-roxml>, [">= 2.5.2"])
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    s.add_dependency(%q<mislav-will_paginate>, [">= 0"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
