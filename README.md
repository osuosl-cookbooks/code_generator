Code Generator Cookbook
=======================

This cookbook is used to generate new cookbooks, recipes, attributes,
lwrps, policy files, and basically any resource chef provides. The basic
invocation from the chef-repo is:

First, ensure you have this set in your ``~/.chef/knife.rb``:
```ruby
chefcli[:generator_cookbook] = '/opt/code_generator/code_generator'
```


```shell
chef generate GENERATOR
```

Creating a Cookbook
-------------------
Using our organization defaults, the command to create a new cookbook
from the osuosl-cookbooks directory, is:

```shell
chef generate cookbook COOKBOOK
```
