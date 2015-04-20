Code Generator Cookbook
=======================

This cookbook is used to generate new cookbooks, recipes, attributes,
lwrps, policy files, and basically any resource chef provides. The basic
invocation from the chef-repo is:

```shell
chef generate GENERATOR -g osuosl-cookbooks
```

Note: The `-g osuosl-cookbooks` should point to the directory containing
the `code_generator` cookbook. This is a bug that has since been fixed
in a newer version of chefdk, but may still be required.

Creating a Cookbook
-------------------
Using our organization defaults, the command to create a new cookbook
from the osuosl-cookbooks directory, is:

```shell
chef generate cookbook COOKBOOK -g . -I apache2 -C "Oregon State University" -m "chef@osuosl.org"
```
