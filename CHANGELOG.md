## Change Log

### [v2.1.7](https://github.com/khiav223577/active_model_cachers/compare/v2.1.6...v2.1.7) 2019/09/24
- [#50](https://github.com/khiav223577/active_model_cachers/pull/50) Support Rails 6.0 (@khiav223577)
- [#49](https://github.com/khiav223577/active_model_cachers/pull/49) Lock sqlite3 version to 1.3.x (@khiav223577)

### [v2.1.6](https://github.com/khiav223577/active_model_cachers/compare/v2.1.5...v2.1.6) 2019/01/20
- [#48](https://github.com/khiav223577/active_model_cachers/pull/48) Support `has_and_belongs_to_many` && `has_many through` (@khiav223577)
- [#47](https://github.com/khiav223577/active_model_cachers/pull/47) Fix: broken test cases after bundler 2.0 was released (@khiav223577)
- [#46](https://github.com/khiav223577/active_model_cachers/pull/46) fix typo in README (@Fatmylin)

### [v2.1.5](https://github.com/khiav223577/active_model_cachers/compare/v2.1.4...v2.1.5) 2018/08/03
- [#44](https://github.com/khiav223577/active_model_cachers/pull/44) should fire an extra query if the attribute used to clean cache is not selected (@khiav223577)
- [#45](https://github.com/khiav223577/active_model_cachers/pull/45) lazily add global callbacks to ActiveRecord::Base (@khiav223577)
- [#43](https://github.com/khiav223577/active_model_cachers/pull/43) Improve the structure of README. (@cybersol795)

### [v2.1.4](https://github.com/khiav223577/active_model_cachers/compare/v2.1.3...v2.1.4) 2018/06/14
- [#41](https://github.com/khiav223577/active_model_cachers/pull/41) Fix: binding problem (@khiav223577)
- [#40](https://github.com/khiav223577/active_model_cachers/pull/40) [Refactor] Solve warnings (@khiav223577)

### [v2.1.3](https://github.com/khiav223577/active_model_cachers/compare/v2.1.2...v2.1.3) 2018/06/07
- [#38](https://github.com/khiav223577/active_model_cachers/pull/38) Fix: Eager-loaded models will not register `after_commit` callback (@khiav223577)

### [v2.1.2](https://github.com/khiav223577/active_model_cachers/compare/v2.1.1...v2.1.2) 2018/06/01
- [#37](https://github.com/khiav223577/active_model_cachers/pull/37) Fix: ModelName cant be referred to in development (@khiav223577)

### [v2.1.1](https://github.com/khiav223577/active_model_cachers/compare/v2.1.0...v2.1.1) 2018/05/25
- [#35](https://github.com/khiav223577/active_model_cachers/pull/35) Preventing registering same callbacks in some cases (@khiav223577)
- [#34](https://github.com/khiav223577/active_model_cachers/pull/34) Enhance - automatically clean cache when `#touch` (@ff2248)
- [#33](https://github.com/khiav223577/active_model_cachers/pull/33) [Enhance] Code Climate Gem Deprecation (@berniechiu)

### [v2.1.0](https://github.com/khiav223577/active_model_cachers/compare/v2.0.3...v2.1.0) 2018/05/18
- [#32](https://github.com/khiav223577/active_model_cachers/pull/32) Add test cases to test "store all data in hash" (@khiav223577)
- [#31](https://github.com/khiav223577/active_model_cachers/pull/31) Change the syntax of getting self from cache (@khiav223577)
- [#29](https://github.com/khiav223577/active_model_cachers/pull/29) test assigning association (@khiav223577)

### [v2.0.3](https://github.com/khiav223577/active_model_cachers/compare/v2.0.2...v2.0.3) 2018/05/14
- [#28](https://github.com/khiav223577/active_model_cachers/pull/28) No need to dump all association caches (@khiav223577)

### [v2.0.2](https://github.com/khiav223577/active_model_cachers/compare/v2.0.1...v2.0.2) 2018/05/14
- [#27](https://github.com/khiav223577/active_model_cachers/pull/27) [Fix] will send query even if has one association is cached (@khiav223577)

### [v2.0.1](https://github.com/khiav223577/active_model_cachers/compare/v2.0.0...v2.0.1) 2018/05/13
- [#26](https://github.com/khiav223577/active_model_cachers/pull/26) Prevent infinite loop if someone override default associations' method (@khiav223577)

### [v2.0.0](https://github.com/khiav223577/active_model_cachers/compare/v1.0.0...v2.0.0) 2018/05/13
- [#25](https://github.com/khiav223577/active_model_cachers/pull/25) Support cache self by other column (@khiav223577)
- [#24](https://github.com/khiav223577/active_model_cachers/pull/24) Support cleaning the cache manually (@khiav223577)
- [#23](https://github.com/khiav223577/active_model_cachers/pull/23) use loaded model if possible to prevent extra queries (@khiav223577)
- [#22](https://github.com/khiav223577/active_model_cachers/pull/22) Support caching result from outer service (@khiav223577)
- [#21](https://github.com/khiav223577/active_model_cachers/pull/21) Support writing query in instance scope (@khiav223577)
- [#20](https://github.com/khiav223577/active_model_cachers/pull/20) instance cacher (@khiav223577)
- [#19](https://github.com/khiav223577/active_model_cachers/pull/19) Pass model to `delete` method to prevent an extra query (@khiav223577)
- [#18](https://github.com/khiav223577/active_model_cachers/pull/18) [Test] show all sql queries if query count doesn't equal to expected count. (@khiav223577)
- [#17](https://github.com/khiav223577/active_model_cachers/pull/17) Support cache at has_many association II - add test cases (@khiav223577)
- [#16](https://github.com/khiav223577/active_model_cachers/pull/16) Support cache at has_many association I (@khiav223577)
- [#15](https://github.com/khiav223577/active_model_cachers/pull/15) Adjust file structures (@khiav223577)
- [#14](https://github.com/khiav223577/active_model_cachers/pull/14) Support cache at belongs_to association (@khiav223577)
- [#13](https://github.com/khiav223577/active_model_cachers/pull/13) Fix that cache not cleaned if foreign_key is not `id` and calling `mode.delete` (@khiav223577)
- [#12](https://github.com/khiav223577/active_model_cachers/pull/12) [Refactor] move the active_record extension to proper directory (@khiav223577)
- [#11](https://github.com/khiav223577/active_model_cachers/pull/11) Fix id problem by specify foreign_key manually (@khiav223577)
- [#10](https://github.com/khiav223577/active_model_cachers/pull/10) cache on falsy result (@khiav223577)
- [#9](https://github.com/khiav223577/active_model_cachers/pull/9) Fix that all models cache with same id will be cleaned if any of one is cleaned (@khiav223577)
- [#8](https://github.com/khiav223577/active_model_cachers/pull/8)  allow developer to specify whether the cache should expire (@khiav223577)
- [#7](https://github.com/khiav223577/active_model_cachers/pull/7) custom query which allow you to specify how to expire the cache by `expire_by` option (@khiav223577)
- [#6](https://github.com/khiav223577/active_model_cachers/pull/6) test cache self (@khiav223577)
- [#5](https://github.com/khiav223577/active_model_cachers/pull/5) Deal with delete, dependent: :delete that do not fire after_commit callback (@khiav223577)
- [#4](https://github.com/khiav223577/active_model_cachers/pull/4) split test cases to several files and refactor the code (@khiav223577)
- [#3](https://github.com/khiav223577/active_model_cachers/pull/3) Safer cache mechanism: Prevent cache from being left over if someone forgets to write `cache_self` (@khiav223577)
- [#2](https://github.com/khiav223577/active_model_cachers/pull/2) Adjust usage (@khiav223577)
- [#1](https://github.com/khiav223577/active_model_cachers/pull/1) use after_commit hook to expire cached associations  (@khiav223577)
