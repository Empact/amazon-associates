# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon-associates}
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Woosley", "Dan Pickett", "Herryanto Siatono"]
  s.date = %q{2009-03-22}
  s.description = %q{amazon-associates offers object-oriented access to the Amazon Associates API, built on ROXML}
  s.email = %q{ben.woosley@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "lib/amazon-associates", "lib/amazon-associates/caching", "lib/amazon-associates/caching/filesystem_cache.rb", "lib/amazon-associates/errors.rb", "lib/amazon-associates/extensions", "lib/amazon-associates/extensions/core.rb", "lib/amazon-associates/extensions/hpricot.rb", "lib/amazon-associates/request.rb", "lib/amazon-associates/requests", "lib/amazon-associates/requests/browse_node.rb", "lib/amazon-associates/requests/cart.rb", "lib/amazon-associates/requests/item.rb", "lib/amazon-associates/responses", "lib/amazon-associates/responses/browse_node_lookup_response.rb", "lib/amazon-associates/responses/cart_responses.rb", "lib/amazon-associates/responses/item_lookup_response.rb", "lib/amazon-associates/responses/item_search_response.rb", "lib/amazon-associates/responses/response.rb", "lib/amazon-associates/responses/similarity_lookup_response.rb", "lib/amazon-associates/types", "lib/amazon-associates/types/api_result.rb", "lib/amazon-associates/types/browse_node.rb", "lib/amazon-associates/types/cart.rb", "lib/amazon-associates/types/customer_review.rb", "lib/amazon-associates/types/editorial_review.rb", "lib/amazon-associates/types/error.rb", "lib/amazon-associates/types/image.rb", "lib/amazon-associates/types/image_set.rb", "lib/amazon-associates/types/item.rb", "lib/amazon-associates/types/listmania_list.rb", "lib/amazon-associates/types/measurement.rb", "lib/amazon-associates/types/offer.rb", "lib/amazon-associates/types/ordinal.rb", "lib/amazon-associates/types/price.rb", "lib/amazon-associates/types/requests.rb", "lib/amazon-associates.rb", "test/amazon", "test/amazon/browse_node_test.rb", "test/amazon/cache_test.rb", "test/amazon/caching", "test/amazon/caching/filesystem_cache_test.rb", "test/amazon/item_test.rb", "test/test_helper.rb", "test/utilities", "test/utilities/cache", "test/utilities/cache/03f", "test/utilities/cache/03f/03f0a2aeb04403531b23c877017efa5616c8e71b", "test/utilities/cache/049", "test/utilities/cache/049/049d1b39673b0d6e1bda1f016f3b896726831c6b", "test/utilities/cache/11a", "test/utilities/cache/11a/11a06809d57ceefc6547ada675bed9f60cd60f2c", "test/utilities/cache/15a", "test/utilities/cache/15a/15aee397b24e59c80e491779fc5e282897f6882a", "test/utilities/cache/16c", "test/utilities/cache/16c/16c1c17c8c73d1362f0358a9302e27c422b72158", "test/utilities/cache/1c7", "test/utilities/cache/1c7/1c733bb047ab27f9da935d9161f5ac6b9d53fc5a", "test/utilities/cache/1d1", "test/utilities/cache/1d1/1d1e0e9c95b15a48badfcf10e541e11596fdb1d3", "test/utilities/cache/251", "test/utilities/cache/251/2516349a2f0288e542c819fec0d273cfa39f70e4", "test/utilities/cache/2ed", "test/utilities/cache/2ed/2ed2554981ee180647a4cf449badc31ea2b33fd3", "test/utilities/cache/368", "test/utilities/cache/368/36877440b5b441c0488fd53ede6f2895f92ed5fd", "test/utilities/cache/3c8", "test/utilities/cache/3c8/3c87b272875ab1be55d9d63dbf70241503ed1659", "test/utilities/cache/3e5", "test/utilities/cache/3e5/3e596d8dd0676dcf53a60fffa3bc3ce9780a4e29", "test/utilities/cache/436", "test/utilities/cache/436/436179c66ca99ab0648820002a31b1dfa1cc5f8a", "test/utilities/cache/468", "test/utilities/cache/468/46864993eda0dd31a0aebfc7b07c774fd0107bd2", "test/utilities/cache/488", "test/utilities/cache/488/488dfbf89923d763ee9cb3cb49ea85b4bc0def05", "test/utilities/cache/489", "test/utilities/cache/489/4899603fd0c488c477a95b73c0895794f5184a40", "test/utilities/cache/56a", "test/utilities/cache/56a/56ab86c7e27346195a303325005bdbd15a222667", "test/utilities/cache/57d", "test/utilities/cache/57d/57d9e6a9c6c5667482339f6c25c121d45e5a2853", "test/utilities/cache/591", "test/utilities/cache/591/5910aff27a0130da6fa03186a837be7a8fe76f24", "test/utilities/cache/5ae", "test/utilities/cache/5ae/5ae3e3c0c4fd057fee0b1bb71d936a7308aad9fd", "test/utilities/cache/5f1", "test/utilities/cache/5f1/5f1a8aafca0fd43979bf2540c30979834679797e", "test/utilities/cache/61f", "test/utilities/cache/61f/61fe0c9ef6842c72905fdf0bb106a1d4f66e3b86", "test/utilities/cache/6a1", "test/utilities/cache/6a1/6a169bae29bdc5a518032018d155a2c2ac51159e", "test/utilities/cache/6b9", "test/utilities/cache/6b9/6b9fc23afc8396b933734445dc4fcffc3dee3ef2", "test/utilities/cache/6eb", "test/utilities/cache/6eb/6eb831f6995e258ba81f70a85d6fa7460fd4c2ba", "test/utilities/cache/73d", "test/utilities/cache/73d/73d52ec65e7c1f6942df0599efe537aade1c9c9c", "test/utilities/cache/781", "test/utilities/cache/781/781c9d4d2dc76b90e1a08711f89fbda17175e2f2", "test/utilities/cache/825", "test/utilities/cache/825/825dfe5b6edef9ec6a5b77cbf409fa81f23b7f08", "test/utilities/cache/864", "test/utilities/cache/864/864e3eab0274b0d51de9a5b7cd7c5ebb0395d7f5", "test/utilities/cache/8ce", "test/utilities/cache/8ce/8cecf63bc1d55419d01bf125172296aa6fa1e7d6", "test/utilities/cache/8d8", "test/utilities/cache/8d8/8d8df954524dd2508149a7c10e46e6f87d7f8611", "test/utilities/cache/992", "test/utilities/cache/992/9928b30d6d493eb1b754959a0c602634ee05760e", "test/utilities/cache/a56", "test/utilities/cache/a56/a56c37773013ac7d2101733ed49958be6ee3b918", "test/utilities/cache/b34", "test/utilities/cache/b34/b34d43ecdef187a4b41035b078c2f54bd6ea90da", "test/utilities/cache/b7d", "test/utilities/cache/b7d/b7d0c8ac0790474d36f10e0a1515039cc9eaca54", "test/utilities/cache/ca8", "test/utilities/cache/ca8/ca8119a7b64738a294337bcf3c18ed1b9cd4da98", "test/utilities/cache/d6a", "test/utilities/cache/d6a/d6aed5807109507a78b933c5b17418db3faa9bd3", "test/utilities/cache/de5", "test/utilities/cache/de5/de541d737300ce69636d75c5e73303c8fbfca243", "test/utilities/cache/ded", "test/utilities/cache/ded/ded62f266be262bf4d34880cb4be94ab2d317c3a", "test/utilities/cache/e20", "test/utilities/cache/e20/e206f86f5905110b4d539261b7e14b5a24095e56", "test/utilities/cache/e21", "test/utilities/cache/e21/e21a5c8f3b6120a52e373e3be8f500e87e3059c3", "test/utilities/cache/e2c", "test/utilities/cache/e2c/e2c035bb0b2fc06f06d916d73109db07a7904264", "test/utilities/cache/e90", "test/utilities/cache/e90/e9079a973144b70c94616e6e5fbc9c9d6ffce726", "test/utilities/cache/ea6", "test/utilities/cache/ea6/ea6c73b8f87b2a5f424192eb7f6ae0c5b8a792b3", "test/utilities/cache/ed0", "test/utilities/cache/ed0/ed0518fd7145b63911dd4b56265a10c836671bd4", "test/utilities/cache/f2e", "test/utilities/cache/f2e/f2e55f7a34b24f9cf199d1687a26979e17ba2d9f", "test/utilities/cache/fd6", "test/utilities/cache/fd6/fd692b69cbe55bd875840d3d484657083797b178", "test/utilities/filesystem_test_helper.rb", "spec/requests", "spec/requests/browse_node_lookup_spec.rb", "spec/requests/item_search_spec.rb", "spec/spec_helper.rb", "spec/types", "spec/types/cart_spec.rb", "spec/types/item_spec.rb", "spec/types/measurement_spec.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Empact/amazon-associates}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

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
