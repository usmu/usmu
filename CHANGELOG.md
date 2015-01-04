# Usmu Change Log

## 0.3.0

Matthew Scharley <matt.scharley@gmail.com>

* Ignore vendored gems (5ed00eda230ad69d727d61197a2eff6269bcc640)
* Bump CHANGELOG to 0.2.2 (daea8c79c04acfd7048aa7f801c9e34462e4a06d)
* Fix a bug with #load_configuration (ab08a884c346fcbca784bf229b42e65bbff2b63a)
* Enable rvm 2.2 for the latest and greatest (e28532f0fe25f46c03e18fd9e6a2dd05c388647e)
* [\[\#12\]][GH-12] Fix layout loop issues finally (b3164c5bd0374837c56c1cab6554a2a7b7b207ef)
* Add libnotify for guard (e51971a22b7d57bcb892e90fa2feb89571b2311b)
* [\[\#14\]][GH-14] Don't list directories in Configuration#get_files (e56d81d7bfeae9d3312c84f2cfe3d03e268ca738)
* [\[\#17\]][GH-17] Fix Sass processing (5b00cc3f29e32ce31d8a13c2979d953509b3a334)
* [\[\#13\]][GH-13] Add page metadata to parent layouts (c2da294e1f19e6404df178ee650c3818cc0f3846)
* Add a Sass partials exclude to default init site (4f70d5b1b5958b6c56338b8d077711c780c85763)

## 0.2.2

Matthew Scharley <matt.scharley@gmail.com>

* Bump version to 0.3.0.dev for further dev (896cbde8191b8123a280b5a2c96af524d8055d07)
* Ignore CR's in generated site to tame diff on Windows (839ab4bfea0bea1a1932b569b636540172d3e633)
* Setup logging properly in Usmu::Plugin::Core (6b4f6cbc133830dc93248d3bc4fb71a2c2aab5a9)
* Allow --trace from commander to function properly (815bb4f12ef7128cb404fe93745c130b990e073d)
* [\[GH-8\]][GH-8] Add an init command (feb3fd659c0180b572449dbdc186d4ada5fb6c61)
* [\[GH-8\]][GH-8] Add tests for the init command (5bbf4031708278b27b7779d170a2a54ca708dd9f)
* Clean up the tmp folder with `rake clean` (2efe4a713fe75569d292bc17801dcd9b1ea2aa02)
* Always use --trace with the acceptance tests (cf9cacccb9faef248d52053c90a0be92f60b7704)
* Fix bug in init command where directories could be uncreated before usage (c53cf247923c48a6d6f84581fdf3e8845ad9d4da)
* Update Rubinius runs for Travis (688f32a76a08a95f261fa6f35f12bce23a0daa39)
* Remove the rbx-head exclude (6ded194e282909f9e7672e645f6c7b626f2ebb1c)
* Remove rbx-2.0 from Travis again - unsupported (de6d536ac04f16352878e92cc7561c0f9a145f54)
* Allow rbx-2.3 (7de8f4ca7fc27647edf9ac1e59d138ec2cd8ff1e)
* Add jruby 2.0 runs (e865e35445ccffb91e20aebf5c17a948ab38f336)
* Fix matrix excludes for jruby (9fa82f64cddb6096e891c418790aadddb00d58a8)
* Fix matrix excludes (again) (hopefully) (4b3dd6370369310219cdc38d9c2ed1169ee28eca)
* Last run at fixing the jruby 2.0 stuff (febb399e8cc5facd29cc1d164a0bddf75c953741)
* Greatly simplify travis.yml using matrix include instead of exclude (5ad500f8ec428be5d86c400006735f8b4cf1c61f)
* Fix gemfile name because I'm a derp (10e73938565049e8ff323da99fca35d024a34134)
* Add a changelog (ea82ed9826517920c7e39d73a5e3df167f9512b4)
* Enable rbx-2.4 build for testing (34fd5415af64ce0fafad3805188b34b99119f37e)
* Track mruby compatibility (163cd5a5956f39a1e46fdf9c381c961d2d21e52d)
* Officially support Rubinius 2.3 (2abe1da65e4f65d065d9d8f084bffae607045043)
* Update compatibility information (1be9e1cee10f3aab20f514195dfbc17deb8138f4)
* Bump slim to 3.0 (f258e53bb3f04187406a1ba0736c53be4105ee09)
* Massive refactor to create the Usmu::Template namespace (425956dd04b199e5ac32582ed5856d01b6251e35)
* Add an irb task to rake (e7506c686696344b506da2df8705d918bf1b0ba0)
* [\[\#9\]][GH-9] Add tests for includes in slim (95f4c4992e4984fcdd95c0ba66805714da215cfc)
* [\[\#9\]][GH-9] Implement includes (5a4e69aa8b45fac4a697d56814177023f052c585)
* Remove RBX 2.3 again. (b8675c07d0fe066c466144c27e690f1863a88888)
* Release 0.2.2 (986f611b167a0503108d41ac0a115e38d6aac2f9)

## 0.2.1

Matthew Scharley <matt.scharley@gmail.com>

* Add a proper description to the gemspecs (a0830bdb81582b5d2cf2c60215d725a8a47c8086)

## 0.2.0

Matthew Scharley <matt.scharley@gmail.com>

* Add a logging library and a bunch of default messages (2691935b5a519378dbf41539f610bea58bc12f63)
* Add a few basic commandline options (833098ae38f22b3699bc411ee806d26a4b36f1d9)
* Update mtime in destination folder from source folder (558d03efd4f4f3875c7cf5b99ff18ec69cf5ba45)
* Move contributing information to it's own file for GitHub's sake (f241549ced0c8804d406685a7d5877e7eb597262)
* Add basic plugin loading. (a6fdad0e0331b7daa679db99c7c00e7fc1543363)
* Fix issues with 'layout' as a default metadata property (9ae696aa9237adc5ba8048957eefcd4fb8f7782c)
* Implement simplecov for rspec tests (606841eeed2e30801313aee56a815644f901a1b4)
* Fix output extensions for all templates I know the answer for. (bad1eed984a634f1dd28ce198fa1e40a10b2c9c8)
* Clean up configuration and simplecov a bit (bf4288e6155fdab9354616e65e5531e9a4e7ca0f)
* Clean up coverage statistics a bit that were scewed (734563c8b627da33d853e453437790b4ca64b7a2)
* Add tests for the CLI interface (8e1a520ed74000b180e780121a426f4fea55ad56)
* Add guard for quick feedback on tests (7bae19eaad9728968e764ea237ee3dd6f0cd03ce)
* Updates so specs can be run individually (6071120890347fd2c04bcfb4e8387d4b1dd839ba)
* Use turnip for the few gherkin scripts we have (d018752de127c788ec79d1a65df12e4d1b3f03d3)
* Remove cucumber from the CI task (d4094db005db5205542eb8256e86f01d9cd49d05)
* Allow the rspec rake task to find it's own spec files (35d6f7e4486f14034544884090b5cccfd7bd82ad)
* Use Redcarpet 3.2! (5c7a9d34f5ec2c12089b1e045e174f26f34877f2)
* [\[GH-7\]][GH-7] Allow for excluding files via usmu.conf (da0f1123316ce1cede23a63cea8e6c46c3a17a01)
* Add one more guard test on exclude globs (143460ea5f5427845e01119a8aba039207382a1b)
* [\[GH-5\]][GH-5] Add an initial pass at a plugin system (73588da4bfaf03fa27a47747b56f6e31d95c8704)
* [\[GH-5\]][GH-5] Transition to commander instead of trollop and make `generate` an official command (1aaaf43c0884c70980af3b7e6fcaa8ce57f7474c)
* 1.9.3 compatibility (cba51ad465576ac542111d200cfcbb62835c097c)
* Re-enable 1.9.3 CI and add some compat notes to the readme (cf34053aaaf6a85752ec8be70f7c9969a89990d9)
* Bump to 0.2.0 release (7e7dde04c180b5ae63268db647ba45ef63a6b3f3)

## 0.1.0

Matthew Scharley <matt.scharley@gmail.com>

* Add some gems for testing (638e064d1bfbababf2a89a6197a6ac692dcba127)
* Add an empty RSpec and Cucumber configuration with no tests (469881ef414558f27abf753335470564fd95c2dc)
* Fix my mispellings (83b27fa4fa39453e50068d1f29ae717e6be12040)
* Add a basic overarching test for a basic generator (c48a823bbdad7171b3cd530f8345a30710aeeaba)
* Add a new embedded layout test (f982f4e3e6dfddefb1a5c952600afc1c45c57da1)
* Add empty step definitions (a6c485fbcf5da30b3d65ab40820e251da56aecc1)
* Add a bunch of information to the README (292acc057ca369e3544fb9ea0552d6e96a7b648e)
* Update names to the new 'final' name (859ca5cd1523588e6d764d96304b9e62d7b5dc6c)
* Grammar (ce48ccbc227c8a0871752cb97d296a68ad9c0139)
* Add a few more dev tools (9be06d7e8be1edea83c14f43aeea0f5c1d6aa64f)
* Fix license link (fce28223da57998980a398edc31415fa458bfd60)
* Add Cane/Yard configurations (8dc2c5d8163f4f0fcbdb7c69fb0b49aac8745fa0)
* Add a Travis CI configuration (2c78a309125e665499e0c45a6bb7e270c54282f9)
* Add Travis tag to the readme (d6f1188a8db93c991203f86b592b8f02227fe31f)
* Add configuration reading and final versions of cumumber steps (09b565c1ba5a7459a53e8c75fc0efcb29204316c)
* Start to build out some specs (8435564ee4a3adc85c45742a34a7538fd3fbe8d2)
* Only run specs on the CI for now (bff24ee9222da0e7184d77fbbff13062ef4d22ce)
* Make RSpec a little less verbose in it's successes (15fc343c9faadfefa3212f790d10d48f06e60fe0)
* Add some more options for travis (e4122c192629abff76227e218b5272fcbea1f37b)
* Allow JRuby builds to fail. (b7bc4cdea0c4060326f290e71cbf4b494105ccf0)
* Allow non-MRI builds to run but also allow them to fail (d29b17cbccf56ce1cbe9c29cc67e4db682a83230)
* Add some more specs for Usmu::Configuration (7a0ae9a1727281b9bbf78c6dcbeb4983d3c1b083)
* Add a workable Layout class (345028c1217c65ea78b7d805007c8c655d7d93e7)
* Test jruby builds (98a490e1d66cd508695b767b43075f3f2446e432)
* Disallow jruby failures (954b0eb96ddb5f4ea74066e0105e092ec8a13997)
* Use Rspec 3.1.x not 3.x (f6221fbdc0e4bb7929df3390488a3e5ed0774b5a)
* Convert layout spec to a shared example (a3047928e560d91cf50bd41939d932dc5ae5d617)
* Add a functional Page class (009d0c4c8c48a4928a3c09642a205ebe7fca9328)
* Switch from Maruku to Kramdown for jruby (8ad1336bdadb109018dd1eba35cf06a2728407ca)
* Fix jruby tests by allowing config per provider not per template type (bdab71c2b7675f7a8b9f116556332a97472ea513)
* Add a public attr_reader for name and type to Layout (011031c7663fc1e1e457ae38b69f2505b1e9a343)
* Update README with minor change in functionality (0a95ce878a77a25135f8147663758922fd2528a5)
* Stylistic fix (da849668ef37022e11d85ebaab48fa8a5ecedddd)
* Large refactor of how Layout's are initialised and a new StaticFile class (81b0f3f9d707d9d9dc866713942d47217921c67f)
* Some minor refactors inspired by cane (b2f7ed7ec78292fcd0dbfb57b13cef68103bff91)
* Successfully generate a website! (f1952e8776337626606834607db557fd0301a8e2)
* Allow jruby failures again (2926aab2dc14f6b7c35db80dc93be3a24becf7ab)
* Add documentation across the board. Yard reports 100%! (3122de04ed052a31d391845ce87251d9823a3773)
* Small stylistic change (ae008aa5492b2463774e4e4659d90666059b45e0)
* Add new custom rake tasks for building gems and fix a few small issues with the specs (5b1a4241cd9f31f39179ffaad49f7155617c0e6f)
* Bump to full 0.1.0 release (fb91c2b54f79eeaeb615f98f874c990e4cdddfd3)

  [GH-5]:  https://github.com/usmu/usmu/issues/5
  [GH-7]:  https://github.com/usmu/usmu/issues/7
  [GH-8]:  https://github.com/usmu/usmu/issues/8
  [GH-9]:  https://github.com/usmu/usmu/issues/9
  [GH-12]: https://github.com/usmu/usmu/issues/12
  [GH-13]: https://github.com/usmu/usmu/issues/13
  [GH-14]: https://github.com/usmu/usmu/issues/14
  [GH-17]: https://github.com/usmu/usmu/issues/17
