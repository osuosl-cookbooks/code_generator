# code_generator

The OSUOSL generator for `cinc generate`. It writes new cookbooks, recipes,
resources and helpers the way the live `osl-*` and `proj-*` cookbooks are
laid out: Berkshelf, the `cinc_infra` kitchen config targeting Cinc 19,
ChefSpec over `ALL_PLATFORMS`, an InSpec profile per suite, the Jenkinsfile
that puts the repo in the `osuosl-cookbooks` Jenkins folder, and Apache-2.0
headers for Oregon State University.

## Setup

Workstations get a checkout of this repository's default branch at
`/opt/osuosl/code_generator` from the `workstation::code_generator` recipe.
`chef-repo/.cinc/knife.rb` points `cinc generate` at it, so commands run
anywhere inside chef-repo need no flag. Elsewhere, pass it explicitly:

```console
$ cinc generate cookbook -g /opt/osuosl/code_generator osl-foo
```

or add `chefcli[:generator_cookbook] = '/opt/osuosl/code_generator'` to the
`~/.cinc/knife.rb` or `~/.cinc/config.rb` you already have. Cinc reads only
the first config file it finds, `config.rb` before `knife.rb`, and the nearest
`.cinc/` directory before the one in your home directory, so creating a second
file hides the first.

The generator needs a directory of its own. chef-cli uses its parent
directory as the whole cookbook path and loads everything beside it as a
cookbook, so a checkout next to other repositories fails with `Cookbook
merging is no longer supported`. `/opt/osuosl/` holds nothing else.

On a machine without the `workstation::code_generator` checkout, `cinc
generate` inside chef-repo fails with `Cookbook code_generator not found`.
Clone this repository into an otherwise empty directory and pass its path
with `-g`, which overrides any config file:

```console
$ mkdir -p ~/code_generator-local
$ git clone git@github.com:osuosl-cookbooks/code_generator.git ~/code_generator-local/code_generator
$ cinc generate cookbook -g ~/code_generator-local/code_generator osl-foo
```

That is also why `-g` cannot point at `osuosl-cookbooks/code_generator`:
chef-cli would load every cookbook beside it, and it refuses to create a
cookbook in the generator's own parent directory.

## Commands

Run these from `osuosl-cookbooks/`, naming the cookbook. Inside the cookbook,
drop the cookbook argument (`cinc generate recipe bar`) or pass `.`; the name
comes from `metadata.rb` either way. A generator never overwrites a file that
already exists, so re-running one only fills in what is missing, such as the
spec and fixture recipe for an older resource.

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

## Testing

```console
$ cinc exec cookstyle
$ rm -f Berksfile.lock && cinc exec rspec
```

The specs assert what each generator recipe declares; they cannot run
`ruby_block` bodies or prove the output is clean. Before opening a PR,
generate a cookbook from your working tree and test that too. The copy must
live in a directory named `code_generator`:

```console
$ CG=$(mktemp -d) && mkdir $CG/gen && cp -r . $CG/code_generator && cd $CG/gen
$ cinc generate cookbook -g $CG/code_generator osl-sample
$ cinc generate resource -g $CG/code_generator osl-sample osl_sample_thing
$ cd osl-sample && cinc exec cookstyle && cinc exec rspec
$ cinc exec inspec check test/integration/osl_sample_thing
```

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
