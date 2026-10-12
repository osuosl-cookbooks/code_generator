# code_generator

The OSUOSL generator for `cinc generate`. It writes new cookbooks, recipes,
resources and helpers the way the live `osl-*` and `proj-*` cookbooks are
laid out: Berkshelf, the `cinc_infra` kitchen config targeting Cinc 19,
ChefSpec over `ALL_PLATFORMS`, an InSpec profile per suite, the Jenkinsfile
that puts the repo in the `osuosl-cookbooks` Jenkins folder, and Apache-2.0
headers for Oregon State University.

## Setup

Workstations at OSL get a checkout of this repository at
`/opt/osuosl/code_generator`, and OSL's chef-repo points `cinc generate` at
it, so commands run inside chef-repo need no flag.

If you are not using an OSL workstation, clone this repository into an
otherwise empty directory and pass its path with `-g`, which overrides any
config file:

```console
$ mkdir -p ~/code_generator-local
$ git clone git@github.com:osuosl-cookbooks/code_generator.git ~/code_generator-local/code_generator
$ cinc generate cookbook -g ~/code_generator-local/code_generator osl-foo
```

## Commands

Run these from `osuosl-cookbooks/`, naming the cookbook. Inside the cookbook,
drop the cookbook argument (`cinc generate recipe bar`) or pass `.`; the name
comes from `metadata.rb` either way. A generator never overwrites a file that
already exists, so re-running one only fills in what is missing, for example
the ChefSpec spec and fixture-cookbook test recipe for a resource that
predates them.

| Command | Writes |
|---|---|
| `cinc generate cookbook osl-foo` | the whole skeleton at version `0.1.0` |
| `cinc generate recipe osl-foo bar` | `recipes/bar.rb`, `spec/unit/recipes/bar_spec.rb` and an InSpec profile in `test/integration/bar/` |
| `cinc generate resource osl-foo osl_foo_bar` | `resources/osl_foo_bar.rb` providing `osl_foo_bar`, a fixture recipe, `spec/unit/resources/osl_foo_bar_spec.rb` and an InSpec profile |
| `cinc generate helpers osl-foo helpers` | `libraries/helpers.rb` (module `OslFoo::Cookbook::Helpers`) and its spec |
| `cinc generate attribute osl-foo default` | an empty `attributes/default.rb` |
| `cinc generate template osl-foo foo.conf` | an empty `templates/foo.conf.erb` (`-s <file>` copies a source into a new file; an existing one is left alone) |
| `cinc generate file osl-foo foo` | an empty `files/foo` (`-s <file>` copies a source into a new file; an existing one is left alone) |

The resource generator puts its test recipe in the cookbook's fixture
cookbook: the only one under `test/cookbooks/` or `test/fixtures/cookbooks/`,
or among several the one named `foo_test`, `foo-test` or `osl-foo-test`, or
the one named with `-a fixture=<name>`. When there is none it creates
`test/cookbooks/foo_test` and adds its `path:` line to the Berksfile. New
kitchen suites are left for you to add to `kitchen.yml`.

chef-cli only runs `git init` for a new cookbook when no parent directory is
a git checkout. chef-repo is one, so in `osuosl-cookbooks/` start the
repository yourself:

```console
$ cd osl-foo && git init -b main && git add . && git commit -m 'Initial commit'
```

`repo`, `policyfile`, `input`, `profile` and `waiver` are not supported: OSL
cookbooks use Berkshelf and the roles and environments in chef-repo.

## Contributing

To contribute to the `code_generator` cookbook, first clone the repository and
make your edits in a new branch.

To test your changes, run

```console
$ rake
```

The specs assert what each generator recipe declares; they cannot run
`ruby_block` bodies or prove the output is clean. Before opening a PR,
generate a cookbook from your working tree and test that too. The copy must
be named `code_generator` and sit alone in its directory (see How it works):

```console
$ CG=$(mktemp -d) && mkdir $CG/gen $CG/generator && cp -r . $CG/generator/code_generator
$ cd $CG/gen && cinc generate cookbook -g $CG/generator/code_generator osl-sample
$ cinc generate resource -g $CG/generator/code_generator osl-sample osl_sample_thing
$ cd osl-sample && rake
$ cinc exec inspec check test/integration/osl_sample_thing
```

### How it works

- chef-cli uses the generator's parent directory as the whole cookbook path
  and loads everything beside it as a cookbook. That is why the generator
  needs a directory of its own: a checkout next to other repositories fails
  with `Cookbook merging is no longer supported`.
- For the same reason `-g` cannot point at `osuosl-cookbooks/code_generator`,
  and chef-cli also refuses to create a cookbook in the generator's own
  parent directory.
- `-g` wins over `chefcli[:generator_cookbook]` in a config file. Cinc reads
  only the first config file it finds, `config.rb` before `knife.rb` and the
  nearest `.cinc/` directory before the one in your home directory, so add
  the setting to the file you already have rather than creating a second one.

## License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2014-2026, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
